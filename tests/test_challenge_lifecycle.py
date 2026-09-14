
# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__)))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import copy
import json
import os
import tempfile
import threading
import unittest
from concurrent.futures import ThreadPoolExecutor
from unittest import mock
import urllib.request

import config
import jm_crypto
from handlers import challenge_map as cm
from state import StateStore
from server import create_server


class ChallengeLifecycleTest(unittest.TestCase):
    def setUp(self):
        self.now = 2000000000
        self.clock = mock.patch.object(cm.time, "time", side_effect=lambda: self.now)
        self.clock.start()
        self.addCleanup(self.clock.stop)
        self.interval = mock.patch.object(cm, "RECOVER_SECONDS", 600)
        self.interval.start()
        self.addCleanup(self.interval.stop)
        self.store = StateStore(initial={"archives": {
            "101": {"lv": 1000, "name": "测试", "items": [
                {"id": 1, "itemId": "tzn01001", "count": 2},
                {"id": 2, "itemId": "other", "count": 3},
            ]},
            "102": {"lv": 1000, "items": []},
        }}, autosave=False)

    def ctx(self, body=None, uid="101", store=None):
        return {"state": store or self.store, "headers": {"userid": uid}, "body": body or {}}

    def preview(self, map_id="tzfb0101", uid="101"):
        return cm.challengemap_enter(self.ctx({"map_id": map_id}, uid))

    def confirm(self, map_id="tzfb0101", items=None, uid="101"):
        return cm.challengemap_confirm_consume(self.ctx({"map_id": map_id, "consume_map": items or []}, uid))

    def balance(self, uid="101"):
        return cm.get_user_anecdote(self.ctx(uid=uid))["data"]["number"]

    def test_preview_does_not_charge_and_confirm_uses_real_config(self):
        preview = self.preview()
        self.assertEqual(preview["errcode"], 0)
        self.assertEqual(preview["data"]["level"], 600)
        self.assertEqual(preview["data"]["strain"], 15)
        self.assertEqual(self.balance(), 100)
        self.assertEqual(cm.challengemap_unfinished(self.ctx())["data"]["status"], 0)
        result = self.confirm()
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["number"], 85)
        self.assertEqual(cm.challengemap_unfinished(self.ctx())["data"]["status"], 1)
        self.assertEqual(self.store.get_archive(101)["anecdote"], 85)

    def test_concurrent_confirm_charges_ticket_and_currency_once(self):
        self.assertEqual(self.preview("tzfb0102")["errcode"], 0)
        with ThreadPoolExecutor(max_workers=8) as pool:
            replies = list(pool.map(lambda _: self.confirm("tzfb0102", [{"id": "tzn01001", "num": 1}]), range(12)))
        self.assertTrue(all(r == replies[0] for r in replies))
        self.assertEqual(replies[0]["errcode"], 0)
        self.assertEqual(self.balance(), 70)
        items = self.store.get_archive(101)["items"]
        self.assertEqual(items[0]["count"], 1)
        self.assertEqual(items[1]["count"], 3)
        self.assertEqual(self.store.get_account(101)["challenge_map"]["counts"]["tzfb0102"]["total"], 1)
        self.assertEqual(self.confirm("tzfb0102")["errcode"], 409)

    def test_reentry_after_restart_preserves_session_and_never_charges(self):
        self.preview()
        paid = self.confirm()
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "state.json")
            saved = StateStore(json_path=path, initial=self.store.snapshot())
            saved.save()
            restored = StateStore(json_path=path)
            result = cm.reenter_challengemap(self.ctx(store=restored))
            self.assertEqual(result["errcode"], 0)
            self.assertEqual(result["data"]["challengemap"]["session_id"], paid["data"]["session_id"])
            self.assertEqual(result["data"]["challengemap"]["map_id"], "tzfb0101")
            repeated = cm.challengemap_confirm_consume(self.ctx({"map_id": "tzfb0101", "consume_map": []}, store=restored))
            self.assertEqual(repeated, paid)
            self.assertEqual(restored.get_account(101)["currencies"]["anecdote"], 85)
        self.assertEqual(cm.reenter_challengemap(self.ctx(uid="102"))["errcode"], 404)

    def test_expired_session_status_and_exit_clear_without_refund(self):
        self.preview()
        paid = self.confirm()
        self.now = paid["data"]["expires_at"]
        self.assertEqual(cm.challengemap_unfinished(self.ctx())["data"]["status"], 2)
        self.assertEqual(cm.reenter_challengemap(self.ctx())["errcode"], 410)
        self.assertEqual(self.confirm()["errcode"], 409)
        self.assertEqual(self.preview()["errcode"], 409)
        for _ in range(2):
            self.assertEqual(cm.challengemap_leave(self.ctx({"type": 3}))["errcode"], 0)
        self.assertEqual(self.store.get_account(101)["currencies"]["anecdote"], 85)
        self.assertEqual(cm.challengemap_unfinished(self.ctx())["data"]["status"], 0)
        self.assertEqual(self.confirm()["errcode"], 409)

    def test_leave_then_new_preview_starts_distinct_paid_session(self):
        self.preview()
        first = self.confirm()
        self.assertEqual(cm.challengemap_leave(self.ctx({"type": 1}))["errcode"], 0)
        self.assertEqual(self.balance(), 85)
        self.preview()
        second = self.confirm()
        self.assertNotEqual(first["data"]["session_id"], second["data"]["session_id"])
        self.assertEqual(self.balance(), 70)

    def test_insufficient_currency_ticket_or_tampered_consumption_does_not_charge(self):
        self.preview("tzfb0102")
        for items in ([], [{"id": "other", "num": 1}], [{"id": "tzn01001", "num": -1}],
                      [{"id": "tzn01001", "num": "1"}], [{"id": "tzn01001", "num": True}]):
            with self.subTest(items=items):
                self.assertNotEqual(self.confirm("tzfb0102", items)["errcode"], 0)
        self.assertEqual(self.balance(), 100)
        self.assertEqual(self.store.get_archive(101)["items"][0]["count"], 2)
        self.store.update_account(101, {"currencies": {"anecdote": 1}})
        self.assertNotEqual(self.confirm("tzfb0102", [{"id": "tzn01001", "num": 1}])["errcode"], 0)
        self.assertEqual(self.balance(), 1)
        self.assertEqual(cm.challengemap_unfinished(self.ctx())["data"]["status"], 0)
        self.assertNotEqual(self.preview()["errcode"], 0)

    def test_configured_alternative_tickets(self):
        role = self.store.get_archive(101)
        role["items"] = [{"itemId": "challengelv4", "count": "1"}]
        self.store.put_archive(101, role)
        self.assertEqual(self.preview("tzfb0104")["errcode"], 0)
        result = self.confirm("tzfb0104", [{"id": "challengelv4", "num": 1}])
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(self.balance(), 40)
        self.assertEqual(self.store.get_archive(101)["items"], [])

    def test_multiple_ticket_stacks_preserve_unrelated_inventory(self):
        spec = copy.deepcopy(cm.map_configs()["tzfb0102"])
        spec["ExpendItem"] = [[["tzn01001", 3]]]
        role = self.store.get_archive(101)
        unrelated = [{"itemId": "other", "count": 0}, {"itemId": "legacy"}]
        role["items"] = [{"itemId": "tzn01001", "count": "1"},
                         {"itemId": "tzn01001", "count": 3}] + unrelated
        self.store.put_archive(101, role)
        with mock.patch.object(cm, "map_configs", return_value={spec["id"]: spec}):
            self.preview(spec["id"])
            result = self.confirm(spec["id"], [{"id": "tzn01001", "num": 3}])
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(self.store.get_archive(101)["items"],
                         [{"itemId": "tzn01001", "count": 1}] + unrelated)

    def test_missing_ticket_and_invalid_user_leave_do_not_mutate_session(self):
        self.preview("tzfb0102", uid="102")
        result = self.confirm("tzfb0102", [{"id": "tzn01001", "num": 1}], uid="102")
        self.assertNotEqual(result["errcode"], 0)
        self.assertEqual(self.balance("102"), 100)
        self.preview()
        self.confirm()
        before = self.store.snapshot()
        for handler in (cm.challengemap_enter, cm.challengemap_confirm_consume,
                        cm.reenter_challengemap, cm.challengemap_leave,
                        cm.test_revert_anecdote, cm.get_festivalmap_info):
            self.assertEqual(handler(self.ctx(uid="bad"))["errcode"], 552)
        for leave_type in (None, 0, 4, "1", True):
            self.assertEqual(cm.challengemap_leave(self.ctx({"type": leave_type}))["errcode"], 400)
        self.assertEqual(before, self.store.snapshot())

    def test_invalid_map_level_preview_expiry_and_account_isolation(self):
        self.assertEqual(self.preview("unknown")["errcode"], 404)
        role = self.store.get_archive(102)
        role["lv"] = 599
        self.store.put_archive(102, role)
        self.assertNotEqual(self.preview(uid="102")["errcode"], 0)
        self.assertEqual(self.confirm()["errcode"], 409)
        self.preview()
        self.now += cm.PREVIEW_SECONDS
        self.assertEqual(self.confirm()["errcode"], 409)
        self.assertEqual(self.balance(), 100)
        self.assertEqual(self.balance("102"), 100)

    def test_recovery_partial_ticks_cap_idle_time_and_clock_rollback(self):
        self.preview()
        self.confirm()
        start = self.now
        self.now += 599
        self.assertEqual(self.balance(), 85)
        self.now += 1
        self.assertEqual(self.balance(), 86)
        self.now = start + 1250
        self.assertEqual(self.balance(), 87)
        self.assertEqual(self.store.get_account(101)["anecdote_recovered_at"], start + 1200)
        self.now = start
        self.assertEqual(self.balance(), 87)
        self.now = start + 20000
        self.assertEqual(self.balance(), 100)
        cm.challengemap_leave(self.ctx({"type": 1}))
        self.preview()
        self.confirm()
        self.assertEqual(self.balance(), 85)
        self.now += 599
        self.assertEqual(self.balance(), 85)
        self.now += 1
        self.assertEqual(self.balance(), 86)

    def test_offline_recovery_and_explicit_refill_do_not_touch_session(self):
        self.preview()
        self.confirm()
        snapshot = self.store.snapshot()
        self.now += 1800
        restored = StateStore(initial=snapshot, autosave=False)
        self.assertEqual(cm.get_user_anecdote(self.ctx(store=restored))["data"]["number"], 88)
        active = copy.deepcopy(restored.get_account(101)["challenge_map"])
        self.assertEqual(cm.test_revert_anecdote(self.ctx(store=restored))["data"]["number"], 100)
        self.assertEqual(restored.get_account(101)["challenge_map"], active)

    def test_time_window_sign_and_daily_limits(self):
        spec = copy.deepcopy(cm.map_configs()["tzfb0101"])
        spec.update({"daily": 1, "activity": 2, "type": 2, "section": [999, 1]})
        with mock.patch.object(cm, "map_configs", return_value={spec["id"]: spec}):
            spec["startTime"] = "2099010100"
            self.assertNotEqual(self.preview()["errcode"], 0)
            spec.pop("startTime")
            spec["endTime"] = "2000010100"
            self.assertNotEqual(self.preview()["errcode"], 0)
            spec.pop("endTime")
            spec["sign"] = ["testflag", 1]
            self.assertNotEqual(self.preview()["errcode"], 0)
            spec["sign"] = []
            self.preview()
            self.assertEqual(self.confirm()["errcode"], 0)
            cm.challengemap_leave(self.ctx({"type": 1}))
            self.assertNotEqual(self.preview()["errcode"], 0)
            info = cm.get_festivalmap_info(self.ctx({"groupId": 999}))["data"][0]
            self.assertEqual((info["dayTime"], info["finalTime"]), (1, 1))
            self.now += 86400
            self.preview()
            self.assertEqual(self.confirm()["errcode"], 0)
            cm.challengemap_leave(self.ctx({"type": 1}))
            self.now += 86400
            self.assertNotEqual(self.preview()["errcode"], 0)

    def test_encrypted_http_lifecycle(self):
        with mock.patch.object(config, "PORT", 0):
            server = create_server("127.0.0.1", 0, state=self.store)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()

        def call(endpoint, data=None):
            payload = jm_crypto.encrypt(json.dumps(data), "FZJH03").encode("ascii") if data is not None else None
            request = urllib.request.Request(
                "http://127.0.0.1:%d/api/v5/%s" % (server.server_port, endpoint), data=payload,
                headers={"userid": "101", "Content-Type": "application/x-www-form-urlencoded"})
            with urllib.request.urlopen(request, timeout=5) as res:
                return json.loads(jm_crypto.decrypt(res.read().decode("ascii")))

        try:
            self.assertEqual(call("challengemap_enter", {"map_id": "tzfb0101"})["errcode"], 0)
            result = call("challengemap_confirm_consume", {"map_id": "tzfb0101", "consume_map": []})
            self.assertEqual(result["data"]["number"], 85)
            self.assertEqual(call("challengemap_unfinished")["data"]["status"], 1)
            self.assertEqual(call("reenter_challengemap")["data"]["challengemap"]["session_id"], result["data"]["session_id"])
            self.now += 600
            self.assertEqual(call("get_user_anecdote")["data"]["number"], 86)
            self.assertEqual(call("challengemap_leave", {"type": 1})["errcode"], 0)
            self.assertEqual(call("challengemap_unfinished")["data"]["status"], 0)
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)


if __name__ == "__main__":
    unittest.main()
