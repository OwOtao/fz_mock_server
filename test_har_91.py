# -*- coding: utf-8 -*-
"""9 月 1 日抓包新增接口的协议与状态回归测试。"""

import unittest

import handlers  # noqa: F401 - 注册全部路由
from handlers.basic import add_training_task_point
from handlers.har_91 import (
    claim_all_new_login_reward,
    get_ckitems_list,
    get_client_data,
    get_cuilian_material_store_list,
    get_fist_foot_shop_info,
    get_growth_info,
    get_limited_package_reward_list,
    get_luck_box_list,
    get_new_login_reward_info,
    get_sachet_attic_new_list,
    get_spring_festival_list,
    get_spring_festival_status,
    get_training_task_list,
    get_training_task_reward,
    get_weapon_cuilian_num,
    get_game_activity,
    get_login_reward_list,
    incr_weapon_cuilian_num,
    outgoing_ckitems,
    refresh_training_task_list,
    set_fist_foot_shop_daily_cost,
    upload_map_extra,
)
from handlers.homeland import get_user_map
from server import ROUTES, match_route
from state import StateStore


class Har91FeatureTest(unittest.TestCase):
    def setUp(self):
        self.state = StateStore(autosave=False)
        self.userid = self.state.ensure_account()["userid"]
        self.state.put_archive(self.userid, {
            "name": "测试角色",
            "yinpiao": 100,
            "currencyVersion": 3,
            "serverActionSystem": {"dataVersion": 7},
            "ckLimit": 66,
            "ckitems": [
                {"itemId": "year2jifen5", "count": 2, "info": ""},
                {"itemId": "weapon_3", "total": 1, "info": {"name": "紫霞剑"}},
            ],
        })

    def ctx(self, body=None, tail=None):
        return {
            "state": self.state,
            "headers": {"userid": str(self.userid)},
            "body": body or {},
            "route_tail": tail or [],
        }

    def test_all_har_game_routes_exist_and_dynamic_tails_match(self):
        expected = {
            "claim_all_new_login_reward", "get_client_data",
            "get_cuiLianCaiLiao_store_list", "get_fistFootShop_info",
            "get_growth_info", "get_luck_box_list", "get_new_login_reward_Info",
            "get_payMask_gift_info", "get_sachet_attic_new_list",
            "get_spend_reward_list", "get_spring_new_reward",
            "get_training_task_list", "get_training_task_reward",
            "get_xianshilibao_gift_list_2", "get_zhenpinge_lottery_list",
            "incr_weapon_cuilian_num", "outgoing_ckitems",
            "refresh_training_task_list", "set_fistFootShop_dailyCost",
            "upload_map_extra",
        }
        self.assertTrue(expected.issubset(ROUTES))
        entry, matched, full = match_route(
            "/api/v5/get_sachet_attic_new_list/scachetAttic"
        )
        self.assertIsNotNone(entry)
        self.assertEqual(matched, "get_sachet_attic_new_list")
        self.assertIsNotNone(full)

    def test_remote_storage_uses_md5_object_and_version_conflicts(self):
        listed = get_ckitems_list(self.ctx({
            "ckname": "xuanbingdong", "ver": "old-local-version",
        }))
        self.assertEqual(listed["errcode"], 0)
        self.assertIsInstance(listed["data"]["list"], dict)
        self.assertEqual(len(listed["data"]["ver"]), 32)
        self.assertEqual(listed["data"]["list"]["year2jifen5"]["total"], 2)

        stale = outgoing_ckitems(self.ctx({
            "ckname": "xuanbingdong", "itemId": "year2jifen5",
            "count": 1, "ver": "stale",
        }))
        self.assertEqual(stale["errcode"], 2)

        taken = outgoing_ckitems(self.ctx({
            "ckname": "xuanbingdong", "itemId": "year2jifen5",
            "count": 1, "ver": listed["data"]["ver"],
        }))
        self.assertEqual(taken["errcode"], 0)
        self.assertEqual(taken["data"]["total"], 1)
        self.assertNotEqual(taken["data"]["ver"], listed["data"]["ver"])

        client_data = get_client_data(self.ctx({
            "type": "xuanbingdong", "offset": "0", "count": "200",
        }))
        self.assertEqual(client_data["data"]["flag"], 1)
        self.assertEqual(client_data["data"]["list"]["year2jifen5"]["total"], 1)

    def test_numeric_storage_version_keeps_legacy_contract(self):
        listed = get_ckitems_list(self.ctx({"ckname": "cangyige", "ver": 4}))
        self.assertIsInstance(listed["data"]["list"], list)
        self.assertEqual(listed["data"]["ver"], 4)
        self.assertEqual(listed["data"]["size"], 66)

    def test_training_list_refresh_progress_and_reward(self):
        pool = ["tiaoxi", "jina", "smketou", "nanyang", "paihangbang", "meirijifen"]
        listed = get_training_task_list(self.ctx({
            "activityId": "trainingtask", "taskList": pool,
        }))
        self.assertEqual([item["id"] for item in listed["data"]["task_list"]], [2, 5, 11])
        self.assertIn("reward_pool_list", listed["data"])

        progress = add_training_task_point(self.ctx({"tid": "tiaoxi", "taskList": pool}))
        self.assertEqual(progress["data"]["added_point"], 1)
        listed = get_training_task_list(self.ctx({"taskList": pool}))
        self.assertEqual(listed["data"]["task_list"][0]["state"], 1)

        refreshed = refresh_training_task_list(self.ctx({"taskList": pool}))
        self.assertEqual([item["id"] for item in refreshed["data"]["task_list"]], [7, 13, 14])
        denied = get_training_task_reward(self.ctx({
            "rid": 1, "giftId": 1000, "dataVer": 7, "currencyVersion": 3,
        }))
        self.assertEqual(denied["errcode"], 1)

        bucket = self.state._state["activity_users"][str(self.userid)]["limited_time_experience"]
        bucket["point"] = 5
        claimed = get_training_task_reward(self.ctx({
            "rid": 1, "giftId": 1000, "dataVer": 7, "currencyVersion": 3,
        }))
        self.assertEqual(claimed["errcode"], 0)
        self.assertEqual(claimed["data"]["reward"][0], {"id": "400002", "num": 50})
        replay = get_training_task_reward(self.ctx({"rid": 1, "giftId": 1000}))
        self.assertEqual(replay["errcode"], 1)

    def test_login_reward_claim_updates_followup_info(self):
        initial = get_new_login_reward_info(self.ctx({
            "activityId": "tenyearslogin", "userAttr": {"lv": 547},
        }))
        self.assertEqual(initial["data"]["loginDayCount"], 5)
        self.assertEqual(initial["data"]["cyclic_pools"]["availableCount"], 3)

        claimed = claim_all_new_login_reward(self.ctx({
            "activityId": "tenyearslogin", "type": 1,
            "dataVer": 7, "currencyVersion": 3,
        }))
        self.assertEqual(claimed["data"]["reward"], [
            {"id": "400034", "num": 90},
            {"id": "400058", "num": 3},
        ])
        self.assertEqual(claimed["data"]["availableCount"], 0)
        followup = get_new_login_reward_info(self.ctx({}))
        self.assertEqual(followup["data"]["cyclic_pools"]["availableCount"], 0)
        self.assertEqual(claim_all_new_login_reward(self.ctx({"type": 1}))["errcode"], 1)

    def test_fist_shop_cost_and_capture_schemas_persist(self):
        invalid = set_fist_foot_shop_daily_cost(self.ctx({"dailySelectCost": 250}))
        self.assertEqual(invalid["errcode"], 400)
        saved = set_fist_foot_shop_daily_cost(self.ctx({"dailySelectCost": 2000}))
        self.assertEqual(saved["errcode"], 0)
        info = get_fist_foot_shop_info(self.ctx())
        self.assertEqual(info["data"]["dailySelectCost"], 2000)
        self.assertIn("specialOfferOrder", info["data"])

        cuilian_store = get_cuilian_material_store_list(self.ctx({"currencyVersion": 3}))
        self.assertEqual(len(cuilian_store["data"]["buy_list"]), 35)
        self.assertEqual(len(cuilian_store["data"]["exchange_list"]), 21)
        self.assertEqual(cuilian_store["data"]["currencyVersion"], 3)

        sachet = get_sachet_attic_new_list(self.ctx({}, ["scachetAttic"]))
        self.assertIn("exchange_list", sachet["data"])
        limited = get_limited_package_reward_list(self.ctx())
        self.assertEqual(limited["data"]["list"][0]["item_id"], "xianshilibaoleiji21")

    def test_previously_placeholder_activity_routes_use_capture_data(self):
        daily_pay = get_game_activity(self.ctx(None, ["dailypaynew"]))
        self.assertEqual(daily_pay["data"]["activity_id"], "dailypaynew")
        self.assertEqual(daily_pay["data"]["id"], 149)

        login = get_login_reward_list(self.ctx(None, ["mingshidenglu1"]))
        self.assertEqual(login["data"]["act_name"], "名士之约")
        self.assertEqual(len(login["data"]["list"]), 2)

        actions = get_spring_festival_list(self.ctx())
        self.assertEqual(len(actions["data"]), 20)
        self.assertEqual(actions["data"][0]["id"], 14)
        self.assertIn(149, {value["id"] for value in actions["data"]})
        status = get_spring_festival_status(self.ctx(None, ["149"]))
        self.assertEqual(status["data"]["activity_id"], "dailypaynew")
        self.assertIsInstance(status["data"]["rule_desc"], list)

    def test_luck_box_refresh_changes_captured_selection(self):
        first = get_luck_box_list(self.ctx({"is_refresh": "Y", "menpai": "huashan"}))
        second = get_luck_box_list(self.ctx({"is_refresh": "Y", "menpai": "huashan"}))
        self.assertEqual(len(first["data"]["list"]), 6)
        self.assertNotEqual(
            [item["rid"] for item in first["data"]["list"]],
            [item["rid"] for item in second["data"]["list"]],
        )

    def test_map_extra_growth_and_cuilian_are_stateful(self):
        uploaded = upload_map_extra(self.ctx({
            "mid": 14750, "attr": {"collectScore": 2780}, "point": 20,
        }))
        self.assertEqual(uploaded["errcode"], 0)
        self.assertEqual(uploaded["data"]["remove_point"], 20)
        self.assertEqual(self.state.get_archive(self.userid)["yinpiao"], 80)
        user_map = get_user_map(self.ctx({"mid": 14750}))
        self.assertEqual(user_map["data"]["usermap"]["extra"]["collectScore"], 2780)

        growth = get_growth_info(self.ctx({"requirement": ["homeland", "lunjian"]}))
        self.assertIn("homeland", growth["data"])
        self.assertIsInstance(growth["data"]["lunjian"], int)

        report = {"cuiliancailiao2": {"sucNum": 1, "defNum": 0}}
        first = incr_weapon_cuilian_num(self.ctx({
            "wid": "weapon_8", "results": report, "sum": 85,
        }))
        replay = incr_weapon_cuilian_num(self.ctx({
            "wid": "weapon_8", "results": report, "sum": 85,
        }))
        self.assertEqual(first["errcode"], 0)
        self.assertEqual(replay["errcode"], 0)
        stats = get_weapon_cuilian_num(self.ctx({
            "wid": "weapon_8", "itemId": "cuiliancailiao2",
        }))
        self.assertEqual(stats["data"]["sum"], 85)
        self.assertEqual(stats["data"]["sucNum"], 1)


if __name__ == "__main__":
    unittest.main()
