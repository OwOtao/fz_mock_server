# -*- coding: utf-8 -*-
"""DebugLayer/TestLayer「家园」面板调试接口的回归覆盖。

覆盖 TestLayer.lua 调用的:
  * test_homeland/1..8      (忠诚度/删仆人/随机特性/删家园/仆人列表/地皮状态)
  * make_servant_change     (闹事/离开/云游)
  * set_auction_time        (竞拍过期时间)
  * update_currency_by_type (家园面板「银票 +N」, 同时是全局货币增删接口)
以及 type=5 与 updateEmployRoleData/deleteEmployee 的串联契约。
"""
import copy
import json
import os
import sys
import tempfile
import threading
import unittest
from unittest import mock
import urllib.request

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import config
import jm_crypto
from handlers.basic import update_currency_by_type, view_currency_by_type
from handlers.homeland import (
    _user_bucket,
    add_employee,
    delete_employee,
    get_employee_list,
    make_servant_change,
    save_employee_list,
    set_auction_time,
    test_homeland,
    update_employee_data,
)
from handlers.role_trait_data import TRAIT_NEED, USABLE_TRAIT_IDS
from server import create_server
from state import StateStore


class HomelandDebugTestBase(unittest.TestCase):
    USER = 9048162379
    MID = 14750

    def ctx(self, store, body, kind=None, userid=None):
        value = {
            "state": store,
            "headers": {"userid": str(userid or self.USER)},
            "body": body,
        }
        if kind is not None:
            value["route_tail"] = [str(kind)]
        return value

    def employees(self):
        return {
            "guanjia1001": {
                "objId": "guanjia1001", "rwId": "guanjia1001", "name": "权令枫",
                "job": "guanjia001", "jobType": "guanjia001", "defaultZhongCheng": 691,
                "trait1": "texing001", "trait2": "texing013", "trait3": "",
                "traitVal": 300, "extra": {"naoshi": 0, "shenshi_status": 0},
            },
            "puren2001": {
                "objId": "puren2001", "rwId": "puren2001", "name": "小四",
                "job": "puren001", "jobType": "puren001", "defaultZhongCheng": 120,
                "trait1": "", "traitVal": 0, "extra": {},
            },
        }

    def initial_state(self):
        house = {"mid": self.MID, "uid": self.USER, "fqId": "yangzhou002",
                 "hxId": "huxing002", "name": "普通房屋", "mapId": "fb10",
                 "isDispose": True, "loc_mark": [2, 2, 20], "loc_sort": 2}
        return {
            "accounts": {str(self.USER): {"userid": self.USER}},
            "archives": {str(self.USER): {
                "name": "角色", "yinpiao": 500,
                "items": [{"id": 1, "itemId": "fq100", "count": 1},
                          {"id": 2, "itemId": "dunfu", "count": 3}],
                "Homeland": {"fq": copy.deepcopy(house)},
            }},
            "homeland": {
                "users": {str(self.USER): {
                    "house": copy.deepcopy(house), "lands": [], "rooms": [],
                    "employees": self.employees(),
                    "employee_lists": {"a": ["guanjia1001"]},
                    "dispatch": {"puren2001": {"x": 1}},
                    "furniture": [], "version": 7,
                }},
                "mid_owners": {str(self.MID): self.USER},
                "next_mid": 14751,
            },
        }

    def make_store(self, path=None):
        if path:
            return StateStore(json_path=path, initial=self.initial_state(), autosave=True)
        return StateStore(initial=self.initial_state(), autosave=False)

    def bucket(self, store):
        return store._state["homeland"]["users"][str(self.USER)]

    NPC = "guanjia1401"

    def uploaded(self, count=2, unit="yinpiao", price=200):
        # 字段照抄客户端 PuRenModel:getRandomPuRenResult 上传的结构
        return [{
            "jobType": "puren001", "name": "小四%d" % (index + 1), "sex": "男",
            "age": 20 + index, "looks": 30, "shenShi": "life%03d" % index,
            "character": "xingge004", "defaultZhongCheng": 500 + index,
            "speedZhongCheng": 3, "price": price, "price_unit": unit,
            "traitVal": 42, "modal": "moban001", "leave_day": 7,
            "mobanSkill": {"jibenquanjiao": 100},
        } for index in range(count)]

    def list_request(self, store, npc_id=None):
        return {
            "state": store, "headers": {"userid": str(self.USER)}, "body": {},
            "route_tail": [npc_id or self.NPC, str(self.MID)],
        }

    def yinpiao(self, store):
        return view_currency_by_type(self.ctx(store, {"currency_type": "yinpiao"}))["data"]["number"]


class TestHomelandDebugTests(HomelandDebugTestBase):
    def test_type1_adds_loyalty_to_every_servant(self):
        store = self.make_store()
        result = test_homeland(self.ctx(store, {"mid": self.MID, "loyal": 180}, kind=1))
        self.assertEqual(result["errcode"], 0)
        employees = self.bucket(store)["employees"]
        self.assertEqual(employees["puren2001"]["defaultZhongCheng"], 300)
        self.assertEqual(employees["guanjia1001"]["defaultZhongCheng"], 871)
        self.assertEqual(self.bucket(store)["version"], 8)

    def test_type2_removes_every_servant_and_dispatch(self):
        store = self.make_store()
        result = test_homeland(self.ctx(store, {"mid": self.MID}, kind=2))
        self.assertEqual(result["errcode"], 0)
        bucket = self.bucket(store)
        self.assertEqual(bucket["employees"], {})
        self.assertEqual(bucket["dispatch"], {})
        self.assertEqual(bucket["employee_lists"], {})

    def test_type3_unlocks_three_distinct_usable_traits(self):
        store = self.make_store()
        result = test_homeland(self.ctx(store, {"mid": self.MID, "loyal": 180}, kind=3))
        self.assertEqual(result["errcode"], 0)
        for employee in self.bucket(store)["employees"].values():
            traits = [employee["trait1"], employee["trait2"], employee["trait3"]]
            self.assertTrue(all(traits), traits)
            self.assertEqual(len(set(traits)), 3)
            for trait in traits:
                self.assertIn(trait, USABLE_TRAIT_IDS)
                self.assertLessEqual(TRAIT_NEED[trait], max(employee.get("traitVal", 0), 0))

    def test_type5_returns_client_consumable_npc_array(self):
        store = self.make_store()
        result = test_homeland(self.ctx(store, {"mid": self.MID}, kind=5))
        rows = result["data"]
        self.assertIsInstance(rows, list)
        self.assertEqual(sorted(row["rwId"] for row in rows), ["guanjia1001", "puren2001"])
        for row in rows:
            self.assertTrue(row["name"])
            self.assertEqual(row["mid"], self.MID)

    def test_type5_entries_drive_update_and_delete_employee(self):
        store = self.make_store()
        rows = test_homeland(self.ctx(store, {"mid": self.MID}, kind=5))["data"]
        target = next(row for row in rows if row["rwId"] == "puren2001")
        result = update_employee_data(self.ctx(store, {
            "objId": target["rwId"], "mid": target["mid"],
            "zc_type": "free", "zc_val": 100, "currency": 0,
        }))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(
            self.bucket(store)["employees"]["puren2001"]["defaultZhongCheng"], 220)
        self.assertEqual(delete_employee(
            self.ctx(store, {"objId": "puren2001", "mid": self.MID}))["errcode"], 0)
        self.assertNotIn("puren2001", self.bucket(store)["employees"])

    def test_type7_and_8_record_land_state_and_type6_clears_it(self):
        store = self.make_store()
        self.assertEqual(
            test_homeland(self.ctx(store, {"mid": self.MID, "datime": 180}, kind=7))["errcode"], 0)
        house = self.bucket(store)["house"]
        self.assertEqual(house["land_state"], "paying")
        self.assertEqual(house["land_datime"], 180)
        self.assertEqual(
            test_homeland(self.ctx(store, {"mid": self.MID, "datime": 0}, kind=8))["errcode"], 0)
        self.assertEqual(house["land_state"], "recycle")
        self.assertEqual(
            test_homeland(self.ctx(store, {"mid": self.MID}, kind=6))["errcode"], 0)
        self.assertNotIn("land_state", house)

    def test_type4_deletes_homeland_state_and_persists(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "state.json")
            store = self.make_store(path)
            result = test_homeland(self.ctx(store, {"mid": self.MID}, kind=4))
            self.assertEqual(result["errcode"], 0)
            self.assertNotIn(str(self.USER), store._state["homeland"]["users"])
            self.assertNotIn(str(self.MID), store._state["homeland"]["mid_owners"])
            archive = store.get_archive(self.USER)
            self.assertFalse((archive.get("Homeland") or {}).get("fq"))
            self.assertTrue(all(item["itemId"] != "fq100" for item in archive["items"]))
            self.assertTrue(any(item["itemId"] == "dunfu" for item in archive["items"]))
            # 重复调用幂等
            self.assertEqual(
                test_homeland(self.ctx(store, {"mid": self.MID}, kind=4))["errcode"], 0)
            reloaded = StateStore(json_path=path)
            self.assertNotIn(str(self.USER), reloaded._state["homeland"]["users"])
            self.assertFalse((reloaded.get_archive(self.USER).get("Homeland") or {}).get("fq"))
            # 删除后仍可重新获得家园(下次 _user_bucket 会重新建房)
            self.assertTrue(_user_bucket(self.ctx(store, {}), self.USER)["house"]["mid"])

    def test_unknown_type_and_mid_mismatch_are_rejected(self):
        store = self.make_store()
        self.assertEqual(
            test_homeland(self.ctx(store, {"mid": self.MID}, kind=99))["errcode"], 400)
        self.assertEqual(
            test_homeland(self.ctx(store, {"mid": 1}, kind=1))["errcode"], 403)


class MakeServantChangeTests(HomelandDebugTestBase):
    def test_naoshi_sets_extra_flag(self):
        store = self.make_store()
        result = make_servant_change(self.ctx(store, {
            "mid": self.MID, "rwId": "puren2001", "type": "naoshi", "time": 0}))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(self.bucket(store)["employees"]["puren2001"]["extra"]["naoshi"], 1)

    def test_leave_and_wild_remove_the_servant(self):
        store = self.make_store()
        self.assertEqual(make_servant_change(self.ctx(store, {
            "mid": self.MID, "rwId": "puren2001", "type": "leave", "time": 0}))["errcode"], 0)
        bucket = self.bucket(store)
        self.assertNotIn("puren2001", bucket["employees"])
        self.assertNotIn("puren2001", bucket["dispatch"])
        self.assertEqual(make_servant_change(self.ctx(store, {
            "mid": self.MID, "rwId": "guanjia1001", "type": "wild", "time": 0}))["errcode"], 0)
        self.assertNotIn("guanjia1001", self.bucket(store)["employees"])
        self.assertEqual(
            [event["type"] for event in bucket["servant_events"]], ["leave", "wild"])

    def test_invalid_type_target_and_mid(self):
        store = self.make_store()
        self.assertEqual(make_servant_change(self.ctx(store, {
            "mid": self.MID, "rwId": "puren2001", "type": "??"}))["errcode"], 400)
        self.assertEqual(make_servant_change(self.ctx(store, {
            "mid": self.MID, "rwId": "nobody", "type": "naoshi"}))["errcode"], 404)
        self.assertEqual(make_servant_change(self.ctx(store, {
            "mid": 1, "rwId": "puren2001", "type": "naoshi"}))["errcode"], 403)


class AuctionTimeTests(HomelandDebugTestBase):
    def test_set_auction_time_records_remaining_seconds(self):
        store = self.make_store()
        self.assertEqual(set_auction_time(self.ctx(store, {"time": 180}))["errcode"], 0)
        root = store._state["homeland"]
        self.assertEqual(root["auction_time"], 180)
        self.assertGreater(root["auction_end"], 0)
        self.assertEqual(set_auction_time(self.ctx(store, {"time": 0}))["data"]["time"], 0)
        self.assertEqual(store._state["homeland"]["auction_time"], 0)


class UpdateCurrencyByTypeTests(HomelandDebugTestBase):
    def test_add_then_view_and_remove_caps_at_balance(self):
        store = self.make_store()
        result = update_currency_by_type(self.ctx(store, {
            "action": "add", "currency": {"yinpiao": 1000}, "addType": None}))
        self.assertEqual(result["data"], {"yinpiao": 1000})
        self.assertEqual(
            view_currency_by_type(self.ctx(store, {"currency_type": "yinpiao"}))["data"]["number"],
            1500)
        self.assertEqual(
            store._state["accounts"][str(self.USER)]["currencies"]["yinpiao"], 1500)
        result = update_currency_by_type(self.ctx(store, {
            "action": "remove", "currency": {"yinpiao": 400}}))
        self.assertEqual(result["data"], {"yinpiao": 400})
        result = update_currency_by_type(self.ctx(store, {
            "action": "remove", "currency": {"yinpiao": 999999}}))
        self.assertEqual(result["data"], {"yinpiao": 1100})
        self.assertEqual(
            view_currency_by_type(self.ctx(store, {"currency_type": "yinpiao"}))["data"]["number"], 0)

    def test_add_respects_reported_currency_limit(self):
        store = self.make_store()
        result = update_currency_by_type(self.ctx(store, {
            "action": "add", "currency": {"zongheng": 999999}}))
        self.assertEqual(result["data"], {"zongheng": 9999})
        self.assertEqual(
            view_currency_by_type(self.ctx(store, {"currency_type": "zongheng"}))["data"]["number"],
            9999)

    def test_currency_table_form_and_invalid_payloads(self):
        store = self.make_store()
        result = update_currency_by_type(self.ctx(store, {
            "action": "add", "currency": [{"yinpiao": 10}, {"meiyu": 5}]}))
        self.assertEqual(result["data"], {"yinpiao": 10, "meiyu": 5})
        self.assertEqual(
            update_currency_by_type(self.ctx(store, {
                "action": "??", "currency": {"yinpiao": 1}}))["errcode"], 400)
        self.assertEqual(
            update_currency_by_type(self.ctx(store, {
                "action": "add", "currency": {}}))["errcode"], 400)


class RecruitEmployeeListTests(HomelandDebugTestBase):
    """招聘列表契约: save_employee_list 的 data 必须是数组。

    客户端 PuRenModel/MenKeModel/GuanJiaModel:refresh 里是 `for i = 1, #data` +
    `data[i].state == 0`, 返回 {list = ...} 会让 #data == 0, 列表永远空白。
    """

    def test_save_returns_array_with_server_assigned_hid_and_state(self):
        store = self.make_store()
        result = save_employee_list(self.ctx(store, {
            "type": 1, "npcId": self.NPC, "list": self.uploaded()}))
        self.assertEqual(result["errcode"], 0)
        entries = result["data"]
        # 这是"数组本身"而不是 {"list": [...]}: 客户端读 #data
        self.assertIsInstance(entries, list)
        self.assertEqual(len(entries), 2)
        self.assertEqual([entry["hid"] for entry in entries], [1, 2])
        self.assertTrue(all(entry["state"] == 0 for entry in entries))
        self.assertEqual(entries[0]["name"], "小四1")
        self.assertEqual(self.bucket(store)["employee_lists"][self.NPC], entries)

    def test_get_employee_list_returns_list_and_shenshi_object(self):
        store = self.make_store()
        save_employee_list(self.ctx(store, {
            "type": 1, "npcId": self.NPC, "list": self.uploaded()}))
        # get_employee_list 走的是 data.list / data.shenshi, 与 save 的数组响应不同
        result = get_employee_list(self.list_request(store))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(len(result["data"]["list"]), 2)
        self.assertEqual(result["data"]["shenshi"], {})
        self.assertTrue(all(entry["state"] == 0 for entry in result["data"]["list"]))

    def test_hire_by_hid_uses_saved_entry_and_charges_price(self):
        store = self.make_store()
        entries = save_employee_list(self.ctx(store, {
            "type": 1, "npcId": self.NPC, "list": self.uploaded()}))["data"]
        result = add_employee(self.ctx(store, {
            "hid": entries[0]["hid"], "objId": "pr_1001", "mid": self.MID,
            "npcId": self.NPC, "push_data": {}}))
        self.assertEqual(result["errcode"], 0)
        hired = result["data"]
        self.assertEqual(hired["rwId"], "pr_1001")
        self.assertEqual(hired["objId"], "pr_1001")
        self.assertTrue(hired["fjId"])
        # 人物数据来自服务端保存的条目, 不能退化成默认的"小四/moban001"
        self.assertEqual(hired["name"], "小四1")
        self.assertEqual(hired["jobType"], "puren001")
        self.assertEqual(hired["defaultZhongCheng"], 500)
        self.assertEqual(hired["mobanSkill"], {"jibenquanjiao": 100})
        self.assertEqual(
            self.bucket(store)["employees"]["pr_1001"]["name"], "小四1")
        # 扣银票并标记条目已雇佣(save 的响应是副本, 状态看服务端存的那份)
        self.assertEqual(self.yinpiao(store), 300)
        stored = self.bucket(store)["employee_lists"][self.NPC]
        self.assertEqual([entry["state"] for entry in stored], [1, 0])
        self.assertEqual([entry["hid"] for entry in stored],
                         [entry["hid"] for entry in entries])
        # 已雇佣条目仍随 get_employee_list 下发(客户端按 state 过滤)
        listed = get_employee_list(self.list_request(store))["data"]["list"]
        self.assertEqual([entry["state"] for entry in listed], [1, 0])

    def test_hire_refunds_nothing_when_currency_is_short(self):
        store = self.make_store()
        entries = save_employee_list(self.ctx(store, {
            "type": 1, "npcId": self.NPC, "list": self.uploaded(price=99999)}))["data"]
        result = add_employee(self.ctx(store, {
            "hid": entries[0]["hid"], "objId": "pr_1002", "mid": self.MID,
            "npcId": self.NPC, "push_data": {}}))
        self.assertEqual(result["errcode"], 2)
        self.assertIn("银票不足", result["errmsg"])
        self.assertNotIn("pr_1002", self.bucket(store)["employees"])
        self.assertEqual(entries[0]["state"], 0)
        self.assertEqual(self.yinpiao(store), 500)

    def test_hire_with_unknown_or_zero_hid(self):
        store = self.make_store()
        result = add_employee(self.ctx(store, {
            "hid": 999, "objId": "pr_1003", "mid": self.MID,
            "npcId": self.NPC, "push_data": {}}))
        self.assertEqual(result["errcode"], 404)
        # hid = 0 是初始管家/副本产出路径, 数据全部来自 push_data
        result = add_employee(self.ctx(store, {
            "hid": 0, "objId": "guanjia1001", "mid": self.MID, "npcId": 0,
            "push_data": {"name": "权令枫", "jobType": "guanjia001",
                          "defaultZhongCheng": 691, "price": 0,
                          "price_unit": "yinpiao"}}))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["name"], "权令枫")
        self.assertEqual(result["data"]["jobType"], "guanjia001")

    def test_refresh_replaces_list_and_reassigns_hid(self):
        store = self.make_store()
        first = save_employee_list(self.ctx(store, {
            "type": 1, "npcId": self.NPC, "list": self.uploaded(1)}))["data"]
        second = save_employee_list(self.ctx(store, {
            "type": 2, "npcId": self.NPC, "list": self.uploaded(3)}))["data"]
        self.assertEqual(len(second), 3)
        # 新一批 hid 不与旧批冲突, 旧 hid 自然失效
        self.assertEqual([entry["hid"] for entry in second], [2, 3, 4])
        self.assertEqual(first[0]["hid"], 1)
        self.assertEqual(
            add_employee(self.ctx(store, {
                "hid": first[0]["hid"], "objId": "pr_1004", "mid": self.MID,
                "npcId": self.NPC, "push_data": {}}))["errcode"], 404)
        self.assertEqual(self.bucket(store)["employee_hid_seq"], 4)

    def test_yuanbao_priced_hire_deducts_yuanbao(self):
        store = self.make_store()
        entries = save_employee_list(self.ctx(store, {
            "type": 1, "npcId": "menke001", "list": self.uploaded(1, unit="yuanbao", price=50)}))["data"]
        before = view_currency_by_type(self.ctx(store, {"currency_type": "yuanbao"}))["data"]["number"]
        result = add_employee(self.ctx(store, {
            "hid": entries[0]["hid"], "objId": "pr_1005", "mid": self.MID,
            "npcId": "menke001", "push_data": {}}))
        self.assertEqual(result["errcode"], 0)
        after = view_currency_by_type(self.ctx(store, {"currency_type": "yuanbao"}))["data"]["number"]
        self.assertEqual(before - after, 50)


class HomelandDebugHttpTests(HomelandDebugTestBase):
    def test_encrypted_debug_endpoints(self):
        store = self.make_store()
        # create_server treats port=0 as config.PORT; isolate from the live port.
        with mock.patch.object(config, "PORT", 0):
            server = create_server("127.0.0.1", 0, state=store)
        thread = threading.Thread(target=server.serve_forever, daemon=True)
        thread.start()

        def post(endpoint, body):
            payload = jm_crypto.encrypt(json.dumps(body), "FZJH03").encode("ascii")
            request = urllib.request.Request(
                "http://127.0.0.1:%d/api/v5/%s" % (server.server_port, endpoint),
                data=payload,
                headers={"userid": str(self.USER),
                         "Content-Type": "application/x-www-form-urlencoded"},
            )
            with urllib.request.urlopen(request, timeout=5) as response:
                wire = response.read().decode("ascii")
            self.assertTrue(jm_crypto.is_encrypted(wire))
            return json.loads(jm_crypto.decrypt(wire))

        def get(endpoint):
            request = urllib.request.Request(
                "http://127.0.0.1:%d/api/v5/%s" % (server.server_port, endpoint),
                headers={"userid": str(self.USER)},
            )
            with urllib.request.urlopen(request, timeout=5) as response:
                wire = response.read().decode("ascii")
            self.assertTrue(jm_crypto.is_encrypted(wire))
            return json.loads(jm_crypto.decrypt(wire))

        try:
            rows = post("test_homeland/5", {"mid": self.MID})["data"]
            self.assertIsInstance(rows, list)
            self.assertEqual(sorted(row["rwId"] for row in rows),
                             ["guanjia1001", "puren2001"])
            self.assertEqual(post("test_homeland/1", {"mid": self.MID, "loyal": 180})["errcode"], 0)
            self.assertEqual(post("make_servant_change", {
                "mid": self.MID, "rwId": "puren2001", "type": "naoshi", "time": 0})["errcode"], 0)
            self.assertEqual(post("set_auction_time", {"time": 0})["errcode"], 0)
            self.assertEqual(post("update_currency_by_type", {
                "action": "add", "currency": {"yinpiao": 10000}})["errcode"], 0)

            # 招聘三步: get_employee_list -> save_employee_list(数组) -> add_employee(hid)
            saved = post("save_employee_list", {
                "type": 1, "npcId": self.NPC, "list": self.uploaded()})
            self.assertEqual(saved["errcode"], 0)
            self.assertIsInstance(saved["data"], list)
            self.assertEqual([entry["hid"] for entry in saved["data"]], [1, 2])
            listed = get("get_employee_list/%s/%d" % (self.NPC, self.MID))
            self.assertEqual(len(listed["data"]["list"]), 2)
            hired = post("add_employee", {
                "hid": saved["data"][0]["hid"], "objId": "pr_1001", "mid": self.MID,
                "npcId": self.NPC, "push_data": {}})
            self.assertEqual(hired["errcode"], 0)
            self.assertEqual(hired["data"]["name"], "小四1")
            self.assertEqual(hired["data"]["rwId"], "pr_1001")
            self.assertEqual(
                get("get_employee_list/%s/%d" % (self.NPC, self.MID))["data"]["list"][0]["state"], 1)
        finally:
            server.shutdown()
            server.server_close()
            thread.join(timeout=5)


if __name__ == "__main__":
    unittest.main(verbosity=2)
