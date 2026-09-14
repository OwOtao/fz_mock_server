# -*- coding: utf-8 -*-
"""Contracts used when opening the JiangHuAnecdote screen."""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__)))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import json
import os
import tempfile
import threading
import unittest
from unittest import mock
import urllib.request

import config
import jm_crypto
from handlers.basic import challengemap_unfinished, get_user_anecdote
from server import create_server
from state import StateStore


class ChallengeEntryTest(unittest.TestCase):
    def ctx(self, store, userid="9048162379"):
        return {"state": store, "headers": {"userid": userid}, "body": {}}

    def test_unfinished_has_numeric_idle_status_without_creating_progress(self):
        store = StateStore(autosave=False)
        before = store.snapshot()
        result = challengemap_unfinished(self.ctx(store))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"], {"status": 0})
        self.assertIs(type(result["data"]["status"]), int)
        self.assertEqual(store.snapshot(), before)

    def test_missing_and_invalid_userids_are_rejected_without_mutation(self):
        store = StateStore(autosave=False)
        before = store.snapshot()
        for userid in (None, "", "bad", "0", "-1"):
            for handler in (challengemap_unfinished, get_user_anecdote):
                with self.subTest(userid=userid, handler=handler.__name__):
                    result = handler(self.ctx(store, userid))
                    self.assertEqual(result["errcode"], 552)
        self.assertEqual(store.snapshot(), before)

    def test_default_balance_is_persisted_and_queries_do_not_refill(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "state.json")
            store = StateStore(json_path=path)
            ctx = self.ctx(store)
            self.assertEqual(get_user_anecdote(ctx)["data"], {"number": 100, "max_number": 100})
            store.update_account(9048162379, {"currencies": {"anecdote": 0}})
            before = store.snapshot()
            self.assertEqual(get_user_anecdote(ctx)["data"]["number"], 0)
            self.assertEqual(get_user_anecdote(ctx)["data"]["number"], 0)
            self.assertEqual(store.snapshot(), before)
            restored = StateStore(json_path=path)
            self.assertEqual(get_user_anecdote(self.ctx(restored))["data"]["number"], 0)

    def test_archive_seeding_and_account_isolation(self):
        store = StateStore(initial={"archives": {
            "101": {"anecdote": 37}, "102": {"anecdote": 0},
            "103": {"anecdote": "65"},
        }}, autosave=False)
        for userid, expected in (("101", 37), ("102", 0), ("103", 65), ("104", 100)):
            result = get_user_anecdote(self.ctx(store, userid))
            self.assertEqual(result["data"], {"number": expected, "max_number": 100})
            self.assertIs(type(result["data"]["number"]), int)
        store.update_account(101, {"currencies": {"anecdote": 12}})
        self.assertEqual(get_user_anecdote(self.ctx(store, "101"))["data"]["number"], 12)
        self.assertEqual(store.get_archive(101)["anecdote"], 37)
        self.assertEqual(get_user_anecdote(self.ctx(store, "103"))["data"]["number"], 65)

    def test_existing_balances_are_not_replaced_with_defaults(self):
        for value, expected in ((0, 0), ("12", 12), (-3, 0), (None, 0), ("bad", 0), (150, 150)):
            with self.subTest(value=value):
                store = StateStore(initial={"accounts": {
                    "101": {"userid": 101, "currencies": {"anecdote": value, "gold": 9}},
                }}, autosave=False)
                result = get_user_anecdote(self.ctx(store, "101"))
                self.assertEqual(result["data"]["number"], expected)
                self.assertEqual(store.get_account(101)["currencies"]["gold"], 9)

    def test_http_get_sequence_has_encrypted_success_payloads(self):
        store = StateStore(autosave=False)
        with mock.patch.object(config, "PORT", 0):
            server = create_server("127.0.0.1", 0, state=store)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()

        def get(endpoint, userid="9048162379", data=None):
            request = urllib.request.Request(
                "http://127.0.0.1:%d/api/v5/%s" % (server.server_port, endpoint),
                headers={"userid": userid}, data=data,
            )
            with urllib.request.urlopen(request, timeout=5) as response:
                self.assertEqual(response.status, 200)
                wire = response.read().decode("ascii")
            self.assertTrue(jm_crypto.is_encrypted(wire))
            return json.loads(jm_crypto.decrypt(wire))

        try:
            unfinished = get("challengemap_unfinished")
            self.assertEqual(unfinished["errcode"], 0)
            self.assertIs(type(unfinished["data"]["status"]), int)
            self.assertEqual(unfinished["data"]["status"], 0)
            anecdote = get("get_user_anecdote")
            self.assertEqual(anecdote["errcode"], 0)
            self.assertEqual(anecdote["data"], {"number": 100, "max_number": 100})
            for endpoint in ("challengemap_unfinished", "get_user_anecdote"):
                self.assertEqual(get(endpoint, userid="0")["errcode"], 552)
                self.assertEqual(get(endpoint, data=b"{}")["errcode"], 405)
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)


if __name__ == "__main__":
    unittest.main()
