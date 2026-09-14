# -*- coding: utf-8 -*-

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__)))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import copy
import json
import os
import random
import tempfile
import threading
import unittest
import urllib.request
from concurrent.futures import ThreadPoolExecutor
from unittest import mock

import config
import jm_crypto
from handlers import challenge_map as cm
from handlers.challenge_rewards import reward_configs, roll_rewards, rule_parts
from handlers.system import _game_user_info_payload
from state import StateStore
from server import create_server


class ChallengeRewardsTest(unittest.TestCase):
    def setUp(self):
        self.now = 2000000000
        clock = mock.patch.object(cm.time, "time", side_effect=lambda: self.now)
        clock.start()
        self.addCleanup(clock.stop)
        self.store = StateStore(initial={"archives": {
            "101": {"lv": 1000, "items": [{"id": 1, "itemId": "tzn01001", "count": 3}]},
            "102": {"lv": 1000, "items": []},
        }}, autosave=False)

    def ctx(self, body=None, uid="101"):
        return {"state": self.store, "headers": {"userid": uid}, "body": body or {}}

    def enter(self, map_id="tzfb0101"):
        self.assertEqual(cm.challengemap_enter(self.ctx({"map_id": map_id}))["errcode"], 0)
        items = [] if map_id == "tzfb0101" else [{"id": "tzn01001", "num": 1}]
        result = cm.challengemap_confirm_consume(self.ctx({"map_id": map_id, "consume_map": items}))
        self.assertEqual(result["errcode"], 0)
        return result

    def finish(self, kind=1, map_id="tzfb0101"):
        return cm.challengemap_finish(self.ctx({"map_id": map_id, "finish_type": kind}))

    def award(self, kind=1, delivery=1, map_id="tzfb0101", **extra):
        return cm.challengemap_award(self.ctx({"map_id": map_id, "finish_type": kind,
                                              "type": delivery, "award_list": [], **extra}))

    def sweep_preview(self, map_id="tzfb0101"):
        return cm.challengemap_is_customs(self.ctx({"map_id": map_id}))

    def normal_completion(self, map_id="tzfb0101"):
        self.enter(map_id)
        self.assertEqual(self.finish(map_id=map_id)["errcode"], 0)
        result = self.award(map_id=map_id)
        self.assertEqual(result["errcode"], 0)
        return result

    def count(self, item_id):
        return sum(int(i["count"]) for i in self.store.get_archive(101)["items"] if i["itemId"] == item_id)

    def test_normal_reward_server_roll_and_resources(self):
        self.enter()
        result = self.finish()
        self.assertEqual(result["data"]["award_id"], "Challengecelue0101")
        self.assertEqual(self.count("tzbox01001"), 0)
        reward = self.award(award_list=[{"type": 1, "id": "hacked", "num": 100000000}], currencyVersion=999999)
        self.assertEqual(reward["errcode"], 0)
        self.assertEqual(self.count("tzbox01001"), 1)
        self.assertEqual(self.count("hacked"), 0)
        self.assertEqual(self.store.get_account(101)["currencies"], {"anecdote": 85, "amartial": 45, "dmartial": 2})
        self.assertEqual(reward["data"]["currencyVersion"], 1)
        self.assertEqual(cm.challengemap_unfinished(self.ctx())["data"]["status"], 0)
        self.assertEqual(_game_user_info_payload(self.ctx(), 101)["challengeMapCompleted"], ["tzfb0101"])

    def test_finish_and_award_concurrent_retries_are_once_only(self):
        self.enter()
        with ThreadPoolExecutor(max_workers=8) as pool:
            finishes = list(pool.map(lambda _: self.finish(), range(12)))
            awards = list(pool.map(lambda _: self.award(), range(12)))
        self.assertTrue(all(v == finishes[0] for v in finishes))
        self.assertTrue(all(v == awards[0] for v in awards))
        self.assertEqual(awards[0]["errcode"], 0)
        self.assertEqual(self.count("tzbox01001"), 1)
        self.assertEqual(self.finish(), finishes[0])
        self.assertEqual(self.award(delivery=2)["errcode"], 409)
        self.assertEqual(self.store.get_account(101)["currencies"]["amartial"], 45)

    def test_unclaimed_reward_survives_expiry_and_restart(self):
        self.enter()
        finish = self.finish()
        self.now += cm.SESSION_SECONDS * 2
        self.assertEqual(cm.challengemap_unfinished(self.ctx())["data"]["status"], 1)
        self.assertEqual(cm.challengemap_leave(self.ctx({"type": 3}))["errcode"], 409)
        self.assertEqual(self.sweep_preview()["errcode"], 409)
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "state.json")
            self.store = StateStore(json_path=path, initial=self.store.snapshot())
            self.store.save()
            self.store = StateStore(json_path=path)
            self.assertEqual(self.finish(), finish)
            result = self.award()
            self.assertEqual(result["errcode"], 0)
            self.store = StateStore(json_path=path)
            self.assertEqual(self.award(), result)
            self.assertEqual(self.count("tzbox01001"), 1)

    def test_mail_delivery_only_defers_items_and_does_not_duplicate_mail(self):
        self.enter()
        self.finish()
        first = self.award(delivery=2)
        self.assertEqual(first["errcode"], 0)
        self.assertEqual(self.award(delivery=2), first)
        self.assertEqual(self.count("tzbox01001"), 0)
        mails = self.store.list_mail(101)
        self.assertEqual(len(mails), 1)
        self.assertEqual(mails[0]["rewards"]["loc_items"], [{"id": "tzbox01001", "num": 1, "state": 0}])
        self.assertEqual(self.store.get_account(101)["currencies"]["amartial"], 45)

    def test_sweep_cost_and_reward_are_distinct_and_retries_are_free(self):
        self.normal_completion()
        self.assertEqual(self.sweep_preview()["errcode"], 0)
        self.assertEqual(self.store.get_account(101)["currencies"]["anecdote"], 85)
        with ThreadPoolExecutor(max_workers=8) as pool:
            results = list(pool.map(lambda _: self.finish(2), range(12)))
        self.assertTrue(all(r == results[0] for r in results))
        self.assertEqual(results[0]["data"]["award_id"], "mopupcelue01")
        self.assertEqual(self.store.get_account(101)["currencies"]["anecdote"], 70)
        first = self.award(2)
        self.assertEqual(first["errcode"], 0)
        self.assertEqual(self.award(2), first)
        self.assertEqual(self.finish(2), results[0])
        self.assertEqual((self.count("tzbox01001"), self.count("tzmopupbox01")), (1, 1))
        self.assertEqual(self.sweep_preview()["errcode"], 0)
        self.assertEqual(self.finish(2)["errcode"], 0)
        self.assertEqual(self.award(2)["errcode"], 0)
        self.assertEqual(self.count("tzmopupbox01"), 2)
        self.assertEqual(self.store.get_account(101)["currencies"]["anecdote"], 55)

    def test_sweep_requires_completion_preview_and_rechecks_ticket(self):
        self.assertNotEqual(self.sweep_preview()["errcode"], 0)
        self.assertEqual(self.finish(2)["errcode"], 409)
        self.normal_completion("tzfb0102")
        self.assertEqual(self.finish(2, "tzfb0102")["errcode"], 409)
        self.assertEqual(self.sweep_preview("tzfb0102")["errcode"], 0)
        role = self.store.get_archive(101)
        role["items"] = []
        self.store.put_archive(101, role)
        self.assertNotEqual(self.finish(2, "tzfb0102")["errcode"], 0)
        self.assertEqual(self.store.get_account(101)["currencies"]["anecdote"], 70)

    def test_sweep_ticket_deduction_and_insufficient_balance(self):
        self.normal_completion("tzfb0102")
        self.sweep_preview("tzfb0102")
        self.assertEqual(self.finish(2, "tzfb0102")["errcode"], 0)
        self.assertEqual(self.count("tzn01001"), 1)
        self.assertEqual(self.award(2, map_id="tzfb0102")["errcode"], 0)
        self.sweep_preview("tzfb0102")
        self.store.update_account(101, {"currencies": {"anecdote": 0}})
        self.assertNotEqual(self.finish(2, "tzfb0102")["errcode"], 0)
        self.assertEqual(self.count("tzn01001"), 1)

    def test_invalid_finish_award_isolation_and_expired_session(self):
        self.assertEqual(self.finish()["errcode"], 409)
        self.assertEqual(self.award()["errcode"], 409)
        self.enter()
        for handler in (cm.challengemap_finish, cm.challengemap_award, cm.challengemap_is_customs):
            self.assertEqual(handler(self.ctx(uid="bad"))["errcode"], 552)
        self.assertEqual(self.finish(map_id="tzfb0102")["errcode"], 409)
        self.assertEqual(self.finish(2)["errcode"], 409)
        self.assertEqual(cm.challengemap_finish(self.ctx({"map_id": "tzfb0101", "finish_type": 1}, "102"))["errcode"], 409)
        for kind in (True, None, 0, 3, "1"):
            self.assertEqual(self.finish(kind)["errcode"], 400)
        self.now += cm.SESSION_SECONDS
        self.assertEqual(self.finish()["errcode"], 409)
        self.assertEqual(self.award()["errcode"], 409)

    def test_sweep_preview_expiry_cancel_unsupported_and_limits(self):
        self.normal_completion()
        self.sweep_preview()
        self.now += cm.PREVIEW_SECONDS
        self.assertEqual(self.finish(2)["errcode"], 409)
        self.sweep_preview()
        cm.challengemap_leave(self.ctx({"type": 1}))
        # No new payment after cancellation (an old normal receipt is not a sweep).
        self.assertEqual(self.finish(2)["errcode"], 409)
        self.assertNotEqual(self.sweep_preview("hdfb101")["errcode"], 0)
        spec = copy.deepcopy(cm.map_configs()["tzfb0101"])
        spec["daily"] = 1
        with mock.patch.object(cm, "map_configs", return_value={spec["id"]: spec}):
            self.assertNotEqual(self.sweep_preview()["errcode"], 0)
            spec["daily"] = -1
            self.sweep_preview()
            spec["daily"] = 1
            self.assertNotEqual(self.finish(2)["errcode"], 0)

    def test_bad_reward_config_does_not_charge_sweep(self):
        self.normal_completion()
        self.sweep_preview()
        before = self.store.snapshot()
        with mock.patch.object(cm, "roll_rewards", side_effect=ValueError("bad config")):
            self.assertEqual(self.finish(2)["errcode"], 500)
        self.assertEqual(self.store.snapshot(), before)

    def test_attributes_titles_and_resource_cap(self):
        self.enter()
        rewards = [{"type": 2, "id": "pot", "num": 300}, {"type": 4, "id": "10001", "num": 1},
                   {"type": 3, "id": "zongheng", "num": 5}]
        with mock.patch.object(cm, "roll_rewards", return_value=rewards):
            self.finish()
        self.store.update_account(101, {"currencies": {"anecdote": 85, "zongheng": 9998}})
        result = self.award(delivery=2)
        self.assertEqual(result["errcode"], 0)
        role = self.store.get_archive(101)
        self.assertEqual(role["pot"], 300)
        self.assertEqual(role["basicTitleData"]["titleList"], ["10001"])
        self.assertEqual(role["zongheng"], 9999)
        self.assertEqual(result["data"]["award_list"][-1]["num"], 1)
        self.assertEqual(self.store.list_mail(101), [])

    def test_all_reachable_config_branches_are_supported(self):
        schemes, leaves = reward_configs()
        visited, rewards = set(), set()

        def walk(key):
            if key == "-1" or key in visited:
                return
            visited.add(key)
            spec = schemes[key]
            choices, weights = rule_parts(spec["rule"])
            for choice in choices:
                for value in choice if isinstance(choice, list) else [choice]:
                    if spec["type"] == "策略":
                        walk(value)
                    elif value != "-1":
                        rewards.add(value)

        for spec in cm.map_configs().values():
            for key in ("awardId", "cleanId"):
                if spec.get(key):
                    walk(spec[key])
                    self.assertIsInstance(roll_rewards(spec[key], spec.get("rsesources"), random.Random(42)), list)
        self.assertEqual(len(rewards), 210)
        for key in rewards:
            spec = leaves[key]
            self.assertIn(spec["rwType"], ("物品", "属性", "称号"))
            self.assertEqual(spec["calcType"], "固定类")
            self.assertIs(type(spec["rwNumber"]), int)
        with self.assertRaises(ValueError):
            rule_parts("os.execute('anything')")

    def test_encrypted_http_normal_and_sweep(self):
        with mock.patch.object(config, "PORT", 0):
            server = create_server("127.0.0.1", 0, state=self.store)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()

        def call(endpoint, data):
            req = urllib.request.Request("http://127.0.0.1:%d/api/v5/%s" % (server.server_port, endpoint),
                data=jm_crypto.encrypt(json.dumps(data), "FZJH03").encode("ascii"),
                headers={"userid": "101", "Content-Type": "application/x-www-form-urlencoded"})
            with urllib.request.urlopen(req, timeout=5) as result:
                return json.loads(jm_crypto.decrypt(result.read().decode("ascii")))

        try:
            self.enter()
            for kind in (1, 2):
                if kind == 2:
                    self.assertEqual(call("challengemap_is_customs", {"map_id": "tzfb0101"})["errcode"], 0)
                self.assertEqual(call("challengemap_finish", {"map_id": "tzfb0101", "finish_type": kind})["errcode"], 0)
                result = call("challengemap_award", {"map_id": "tzfb0101", "finish_type": kind, "type": 1, "award_list": {}})
                self.assertEqual(result["errcode"], 0)
            self.assertEqual(self.count("tzmopupbox01"), 1)
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)


if __name__ == "__main__":
    unittest.main()
