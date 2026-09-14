# -*- coding: utf-8 -*-
"""Regression coverage for walking out to a village and back into one's house."""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__)))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import copy
import json
import os
from pathlib import Path
import re
import tempfile
import threading
import unittest
from unittest import mock
import urllib.request

import config
import jm_crypto
from handlers.familytype_data import HX_TABLE
from handlers.homeland import buy_homeland, get_location_map, get_user_map
from state import StateStore
from server import create_server


class HomelandReturnTest(unittest.TestCase):
    USER = 9048162379

    def ctx(self, store, body, userid=None):
        return {"state": store, "headers": {"userid": str(userid or self.USER)}, "body": body}

    def legacy_state(self):
        house = {"mid": 14751, "uid": self.USER, "fqId": "yangzhou146",
                 "hxId": "huxing006", "name": "高门大户", "mapId": "fb10"}
        return {
            "accounts": {str(self.USER): {"userid": self.USER}},
            "archives": {str(self.USER): {"name": "角色", "yinpiao": 60000,
                         "Homeland": {"fq": copy.deepcopy(house)}}},
            "homeland": {"users": {str(self.USER): {"house": house}}},
        }

    def test_legacy_exit_list_restores_the_actual_client_plot_and_reentry(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "state.json")
            store = StateStore(json_path=path, initial=self.legacy_state())
            # Reproduce a client already indoors when the server is upgraded.
            result = get_location_map(self.ctx(store, {"loc_mark": [2, 2, 20]}))
            self.assertEqual(result["errcode"], 0)
            self.assertEqual(len(result["data"]["list"]), 1)
            entrance = result["data"]["list"][0]
            self.assertEqual((entrance["mid"], entrance["uid"], entrance["loc_sort"]),
                             (14751, self.USER, 2))
            # These are the real village's static rooms; model the Lua tableCover.
            # 归类后 tests/ 比 mock_server 根多一层, 路径基于上面的 _REORG_ROOT 解析
            source = Path(_REORG_ROOT) / "fzjh_lua/assets/res/script/map/mapRoom/fb209.lua"
            text = source.read_text(encoding="utf-8")
            rooms = {rid: data for rid, data in re.findall(r'\["(fb209_\d+)"\]=\{(.*?)\}', text)}
            matches = [rid for rid, data in rooms.items()
                       if re.search(r'\["flag1"\]=2(?:,|$)', data)]
            self.assertEqual(matches, ["fb209_02"])
            self.assertIn('["dpRoomId"]=[[fb209_03]]', rooms[matches[0]])
            mapped = get_user_map(self.ctx(store, {
                "mid": entrance["mid"], "userid": entrance["uid"], "ver": 0,
            }))
            self.assertEqual(mapped["errcode"], 0)
            home = mapped["data"]["usermap"]
            self.assertEqual(home["entryRoom"], HX_TABLE["huxing006"]["entryRoom"])
            self.assertEqual((home["loc_mark"], home["loc_sort"]), ([2, 2, 20], 2))
            # Reload from disk, including the separate role archive.
            restored = StateStore(json_path=path)
            repeated = get_location_map(self.ctx(restored, {"loc_mark": [2, 2, 20]}))
            self.assertEqual(repeated["data"]["list"], result["data"]["list"])
            contract = restored.get_archive(self.USER)["Homeland"]["fq"]
            self.assertEqual((contract["loc_mark"], contract["loc_sort"]), ([2, 2, 20], 2))

    def test_new_purchase_and_replacement_keep_return_address(self):
        store = StateStore(initial={
            "archives": {str(self.USER): {"name": "角色", "yinpiao": 100000, "items": []}},
        }, autosave=False)
        first = buy_homeland(self.ctx(store, {"npcId": "yangzhou001", "fqId": "yangzhou001"}))
        self.assertEqual(first["errcode"], 0)
        contract = store.get_archive(self.USER)["Homeland"]["fq"]
        address = (contract["loc_mark"], contract["loc_sort"])
        second = buy_homeland(self.ctx(store, {"npcId": "yangzhou002", "fqId": "yangzhou146"}))
        self.assertEqual(second["errcode"], 0)
        self.assertEqual(second["data"]["mid"], first["data"]["mid"])
        entrance = get_location_map(self.ctx(store, {"loc_mark": address[0]}))["data"]["list"][0]
        self.assertEqual((entrance["loc_mark"], entrance["loc_sort"]), address)
        self.assertEqual(entrance["entryRoom"], HX_TABLE["huxing006"]["entryRoom"])

    def test_encrypted_http_exit_and_return(self):
        store = StateStore(initial=self.legacy_state(), autosave=False)
        # create_server treats port=0 as config.PORT; isolate from the live port.
        with mock.patch.object(config, "PORT", 0):
            server = create_server("127.0.0.1", 0, state=store)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()

        def post(endpoint, body):
            payload = jm_crypto.encrypt(json.dumps(body), "FZJH03").encode("ascii")
            request = urllib.request.Request(
                "http://127.0.0.1:%d/api/v5/%s" % (server.server_port, endpoint),
                data=payload, headers={"userid": str(self.USER),
                                      "Content-Type": "application/x-www-form-urlencoded"},
            )
            with urllib.request.urlopen(request, timeout=5) as response:
                wire = response.read().decode("ascii")
            self.assertTrue(jm_crypto.is_encrypted(wire))
            return json.loads(jm_crypto.decrypt(wire))

        try:
            listed = post("get_location_map", {"loc_mark": [2, 2, 20]})
            self.assertEqual(listed["errcode"], 0)
            entrance = listed["data"]["list"][0]
            returned = post("get_user_map", {
                "mid": entrance["mid"], "userid": entrance["uid"], "ver": 0,
            })
            self.assertEqual(returned["errcode"], 0)
            self.assertEqual(returned["data"]["usermap"]["mid"], 14751)
            self.assertEqual(returned["data"]["usermap"]["uid"], self.USER)
            self.assertEqual(len(returned["data"]["maproom"]), 61)
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)

    def test_filter_full_address_exclude_city_land_and_preserve_existing_plots(self):
        initial = self.legacy_state()
        users = initial["homeland"]["users"]
        for uid, mark, slot, dp in [
            (101, [2, 2, 20], 2, ""),
            (102, [2, 3, 20], 2, ""),
            (103, [2, 2, 20], 4, "yangzhou201"),
            (104, [2, 2, 20], 3, ""),
        ]:
            users[str(uid)] = {"house": {"mid": uid, "hxId": "huxing002",
                "loc_mark": mark, "loc_sort": slot, "dpId": dp}}
        store = StateStore(initial=initial, autosave=False)
        result = get_location_map(self.ctx(store, {"loc_mark": [2, 2, 20]}))
        houses = result["data"]["list"]
        self.assertEqual({h["uid"] for h in houses}, {self.USER, 101, 104})
        self.assertEqual(len({h["loc_sort"] for h in houses}), 3)
        self.assertEqual(next(h["loc_sort"] for h in houses if h["uid"] == 101), 2)
        self.assertEqual(next(h["loc_sort"] for h in houses if h["uid"] == 104), 3)
        for house in houses:
            self.assertIs(type(house["loc_sort"]), int)
            self.assertIs(type(house["mid"]), int)
            self.assertIs(type(house["uid"]), int)
        before = json.dumps(store._state, sort_keys=True)
        get_location_map(self.ctx(store, {"loc_mark": [2, 2, 20]}))
        self.assertEqual(json.dumps(store._state, sort_keys=True), before)

    def test_full_village_moves_new_house_to_another_valid_address(self):
        initial = self.legacy_state()
        users = initial["homeland"]["users"]
        for slot in range(1, 15):
            users[str(slot)] = {"house": {"mid": slot, "hxId": "huxing002",
                "loc_mark": [2, 2, 20], "loc_sort": slot}}
        store = StateStore(initial=initial, autosave=False)
        home = get_user_map(self.ctx(store, {"mid": 14751}))["data"]["usermap"]
        self.assertNotEqual(home["loc_mark"], [2, 2, 20])
        self.assertIn(home["loc_sort"], range(1, 15))
        result = get_location_map(self.ctx(store, {"loc_mark": home["loc_mark"]}))
        self.assertEqual(result["data"]["list"][0]["mid"], 14751)

    def test_empty_village_does_not_create_a_house_and_invalid_requests_do_not_mutate(self):
        store = StateStore(autosave=False)
        result = get_location_map(self.ctx(store, {"loc_mark": [1, 1, 1]}))
        self.assertEqual(result["data"]["list"], [])
        self.assertEqual(store._state["homeland"]["users"], {})
        before = json.dumps(store._state, sort_keys=True)
        for mark in (None, [], [2, 2], [2, 2, 27], [0, 2, 20], [True, 2, 20], "2,2,20"):
            with self.subTest(mark=mark):
                result = get_location_map(self.ctx(store, {"loc_mark": mark}))
                self.assertEqual(result["errcode"], 400)
        self.assertEqual(json.dumps(store._state, sort_keys=True), before)


if __name__ == "__main__":
    unittest.main()
