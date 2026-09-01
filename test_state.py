# -*- coding: utf-8 -*-

import json
import os
import tempfile
import threading
import time
import unittest
from unittest import mock

import config
import protocol

from handlers.basic import (
    add_training_task_point,
    add_devote_point,
    admin_send_email,
    buy_goods,
    buy_matters,
    challengemap_unfinished,
    check_goods_valid,
    delete_email,
    delete_processed_emails,
    get_devote_list,
    get_devote_point,
    get_email_info,
    get_email_reward,
    get_sign_list,
    get_sign_prize,
    get_shop_info,
    get_spring_festival_list,
    get_spring_festival_status,
    get_group_rank,
    get_goods,
    get_goods_2,
    get_board,
    get_limit_package,
    get_rank_list,
    get_store_list,
    get_user_group,
    get_zhao_upgrade_matters,
    is_changed_name,
    matters_shop_info,
    read_email,
    shop_exchange_goods,
    update_username,
    zhao_upgrade,
    upgrade_user_bag,
    view_currency_by_type,
)
from handlers.practice import get_xin_shen_value, recover_xin_shen_value
from handlers.familytype_data import HX_TABLE
from handlers.homeland import (
    add_employee,
    delete_employee,
    get_employee_data,
    get_employee_list,
    get_affair_list,
    get_guaike_reward,
    get_home_switch,
    get_house_info,
    get_user_map,
    update_employee_data,
    update_employee_extra,
)
from handlers.system import (
    create_account,
    download_user_file_2,
    get_email,
    get_game_user_info_2,
    login_device,
    send_email,
)
from handlers.teacher_build import (
    get_teacher_build_info,
    get_teacher_build_items,
    get_teacher_build_list,
)
from state import StateStore


class StateStoreTest(unittest.TestCase):
    def test_store_main_items_match_capture(self):
        store = StateStore(autosave=False)
        userid = store.ensure_account()["userid"]
        base_ctx = {"state": store, "headers": {"userid": str(userid)}}

        listed = get_store_list(base_ctx)
        category = listed["data"]["list"][1]
        self.assertEqual(category["classId"], "store_goods")
        self.assertEqual(category["name"], "商城")
        self.assertEqual(
            [item["itemId"] for item in category["items"]],
            [
                "xiyanshui", "dundifu", "fenshenfu", "guanfugongwen",
                "byfenshenfu", "jingxinwan", "jingmai105", "shimenbuff1",
                "yuhuiling", "drxiang02", "diligent",
            ],
        )
        self.assertEqual(
            [item["price"] for item in category["items"]],
            [50, 10, 10, 300, 1800, 50, 100, 1200, 1800, 10, 250],
        )
        self.assertEqual(category["items"][0]["name"], "RAN洗颜水")
        self.assertEqual(category["items"][0]["id"], 3)
        self.assertEqual(category["items"][4]["number"], 0)
        self.assertEqual(category["items"][4]["share"], "(当前角色绑定)")
        self.assertEqual(category["items"][4]["expired_time"], 0)
        self.assertIn("\n入梦概率：40%\n", category["items"][9]["dsc1"])
        self.assertEqual(category["items"][10]["to"], "0")

        detail = get_goods(dict(base_ctx, route_tail=["byfenshenfu"]))
        self.assertEqual(detail["errcode"], 0)
        self.assertEqual(detail["data"]["id"], "11")
        self.assertEqual(detail["data"]["price"], 1800)
        self.assertEqual(detail["data"]["share"], "(当前角色绑定)")
        self.assertEqual(detail["data"]["expired_time"], 0)

    def test_monthly_clone_talisman_accumulates_and_replays_purchase(self):
        store = StateStore(autosave=False)
        userid = store.ensure_account()["userid"]
        base_ctx = {"state": store, "headers": {"userid": str(userid)}}
        duration = 30 * 24 * 60 * 60
        first_now = 1800000000

        with mock.patch("handlers.basic.time.time", return_value=first_now):
            first = buy_goods(dict(
                base_ctx,
                route_tail=["byfenshenfu"],
                body={
                    "id": 11,
                    "itemId": "byfenshenfu",
                    "quantity": 1,
                    "client_trans_id": "monthly-clone-1",
                    "discount": 0,
                },
            ))
        self.assertEqual(first["errcode"], 0)
        self.assertEqual(first["data"]["expired_time"], first_now + duration)
        self.assertEqual(first["data"]["total_yuanbao"], 8199)

        second_ctx = dict(
            base_ctx,
            route_tail=["byfenshenfu"],
            body={
                "id": 11,
                "itemId": "byfenshenfu",
                "quantity": 1,
                "client_trans_id": "monthly-clone-2",
                "discount": 0,
            },
        )
        with mock.patch("handlers.basic.time.time", return_value=first_now + 10):
            second = buy_goods(second_ctx)
            replay = buy_goods(second_ctx)
        expected_expiry = first_now + duration * 2
        self.assertEqual(second["data"]["expired_time"], expected_expiry)
        self.assertEqual(replay["data"]["expired_time"], expected_expiry)
        self.assertEqual(second["data"]["total_yuanbao"], 6399)
        self.assertEqual(replay["data"]["total_yuanbao"], 6399)
        self.assertEqual(store.get_account(userid)["yuanbao"], 6399)
        self.assertEqual(len(store.snapshot()["orders"]), 2)

        listed = get_store_list(base_ctx)
        self.assertEqual(listed["data"]["list"][1]["items"][4]["expired_time"], expected_expiry)
        detail = get_goods(dict(base_ctx, route_tail=["byfenshenfu"]))
        self.assertEqual(detail["data"]["expired_time"], expected_expiry)
        with mock.patch("handlers.basic.time.time", return_value=expected_expiry - 1):
            active = check_goods_valid(dict(
                base_ctx,
                body={"itemIds": ["byfenshenfu"]},
            ))
        self.assertEqual(active["data"][0]["number"], 1)
        with mock.patch("handlers.basic.time.time", return_value=expected_expiry + 1):
            expired = check_goods_valid(dict(
                base_ctx,
                body={"itemIds": ["byfenshenfu"]},
            ))
        self.assertEqual(expired["data"][0]["number"], 0)

    def test_monthly_clone_talisman_rebuilds_previous_successful_orders(self):
        userid = 12345
        duration = 30 * 24 * 60 * 60
        store = StateStore(initial={
            "accounts": {str(userid): {"userid": userid, "yuanbao": 5000}},
            "orders": {
                "trans-1": {
                    "userid": userid,
                    "status": "success",
                    "item_id": "byfenshenfu",
                    "quantity": 1,
                    "created_at": 1700000000,
                },
                "trans-2": {
                    "userid": userid,
                    "status": "success",
                    "payload": {"itemId": "byfenshenfu"},
                    "quantity": 1,
                    "created_at": 1700000010,
                },
            },
        }, autosave=False)
        listed = get_store_list({
            "state": store,
            "headers": {"userid": str(userid)},
        })
        self.assertEqual(
            listed["data"]["list"][1]["items"][4]["expired_time"],
            1700000000 + duration * 2,
        )

    def test_get_goods_2_returns_fenshenfu_and_uses_resource_price(self):
        store = StateStore(autosave=False)
        userid = store.ensure_account()["userid"]
        base_ctx = {"state": store, "headers": {"userid": str(userid)}}

        detail = get_goods_2(dict(
            base_ctx,
            route_tail=["fenshenfu"],
            body={"mark": {"isFreeSingle": False}},
        ))
        self.assertEqual(detail["errcode"], 0)
        self.assertEqual(detail["data"]["id"], "5")
        self.assertEqual(detail["data"]["itemId"], "fenshenfu")
        self.assertEqual(detail["data"]["name"], "分身符")
        self.assertEqual(detail["data"]["price"], 10)
        self.assertEqual(
            detail["data"]["others"],
            {"mark": {"isFreeSingle": False}},
        )

        purchased = buy_goods(dict(
            base_ctx,
            route_tail=["fenshenfu"],
            body={
                "id": 5,
                "itemId": "fenshenfu",
                "quantity": 1,
                "client_trans_id": "buy-fenshenfu",
                "discount": 0,
            },
        ))
        self.assertEqual(purchased["errcode"], 0)
        self.assertEqual(purchased["data"]["remove_yuanbao"], 10)
        self.assertEqual(purchased["data"]["total_yuanbao"], 9989)

    def test_store_limited_items_match_capture_and_open_package(self):
        store = StateStore(autosave=False)
        userid = store.ensure_account()["userid"]
        base_ctx = {"state": store, "headers": {"userid": str(userid)}}

        listed = get_store_list(base_ctx)
        limited_category = listed["data"]["list"][0]
        self.assertEqual(limited_category["classId"], "xianshi_goods")
        self.assertEqual(limited_category["name"], "限时")
        self.assertEqual(len(limited_category["items"]), 17)
        self.assertEqual(
            [item["itemId"] for item in limited_category["items"][:4]],
            ["libao1425", "libao1426", "libao1427", "libao1428"],
        )
        self.assertEqual(
            [item["price"] for item in limited_category["items"][:4]],
            [588, 588, 488, 388],
        )
        self.assertEqual(limited_category["items"][0]["name"], "限时礼包(桂秋)")
        self.assertEqual(limited_category["items"][6]["client_exp"][0]["v1"], "19")
        self.assertEqual(limited_category["items"][-1]["itemId"], "xinshoulibao1")
        self.assertEqual(limited_category["items"][-1]["price"], 0)

        package = get_limit_package(dict(base_ctx, route_tail=["libao1425"]))
        self.assertEqual(package["errcode"], 0)
        self.assertEqual(package["data"]["price"], 588)
        self.assertEqual(package["data"]["id"], 1529)
        self.assertEqual(package["data"]["limit_num"], 15)
        self.assertEqual(package["data"]["beyond"], 500)
        self.assertGreater(package["data"]["end_time"], int(time.time()))
        self.assertEqual(
            package["data"]["list"],
            [
                {"name": "兵器武学录", "price": 0, "imagePath": "Image/UI/StoreUI/shujuan6.png", "number": 1, "itemId": "2021bingqicanpian1"},
                {"name": "行功散", "price": 0, "imagePath": "Image/UI/StoreUI/shenlishan.png", "number": 5, "itemId": "xinggongsan"},
                {"name": "潜能丹", "price": 0, "imagePath": "Image/UI/StoreUI/qiannengdan.png", "number": 5, "itemId": "qiannengdan"},
                {"name": "RED醉梦生NOR", "price": 500, "imagePath": "Image/UI/StoreUI/juhuajiu100.png", "number": 2, "itemId": "jiu106"},
            ],
        )

        # 每个限时礼包都有明细, 未收录的返回 404
        for item in limited_category["items"]:
            if item["itemId"] == "xinshoulibao1":
                continue
            detail = get_limit_package(dict(base_ctx, route_tail=[item["itemId"]]))
            self.assertEqual(detail["errcode"], 0, item["itemId"])
            self.assertTrue(detail["data"]["list"])
        missing = get_limit_package(dict(base_ctx, route_tail=["libao9999"]))
        self.assertEqual(missing["errcode"], 404)

        purchased = buy_goods(dict(
            base_ctx,
            route_tail=["libao1436"],
            body={
                "id": 8495,
                "itemId": "libao1436",
                "quantity": 1,
                "client_trans_id": "buy-libao-1436",
                "discount": 0,
            },
        ))
        self.assertEqual(purchased["errcode"], 0)
        self.assertEqual(purchased["data"]["remove_yuanbao"], 100)
        self.assertEqual(purchased["data"]["total_yuanbao"], 9899)

    def test_store_level_items_match_capture_and_use_real_price(self):
        store = StateStore(autosave=False)
        userid = store.ensure_account()["userid"]
        base_ctx = {"state": store, "headers": {"userid": str(userid)}}

        listed = get_store_list(base_ctx)
        categories = listed["data"]["list"]
        level_category = categories[2]
        self.assertEqual(level_category["classId"], "fuben_goods")
        self.assertEqual(level_category["name"], "关卡")
        self.assertEqual(
            [item["itemId"] for item in level_category["items"]],
            ["volume_2", "volume_3", "volume_4", "volume_5", "volume_6", "volume_7"],
        )
        self.assertEqual(
            [item["price"] for item in level_category["items"]],
            [100, 200, 150, 150, 100, 100],
        )

        detail = get_goods(dict(base_ctx, route_tail=["volume_3"]))
        self.assertEqual(detail["errcode"], 0)
        self.assertEqual(detail["data"]["name"], "柳玄风卷(上)")
        self.assertEqual(detail["data"]["price"], 200)
        self.assertEqual(
            detail["data"]["dsc1"],
            "购买后可开启【柳玄风卷上】第一章至第十章。",
        )

        purchased = buy_goods(dict(
            base_ctx,
            route_tail=["volume_3"],
            body={
                "id": 4136,
                "itemId": "volume_3",
                "quantity": 1,
                "client_trans_id": "buy-volume-3",
                "discount": 0,
            },
        ))
        self.assertEqual(purchased["errcode"], 0)
        self.assertEqual(purchased["data"]["remove_yuanbao"], 200)
        self.assertEqual(purchased["data"]["total_yuanbao"], 9799)
        self.assertEqual(store.get_account(userid)["yuanbao"], 9799)

    def test_add_training_task_point_accumulates_and_is_idempotent(self):
        store = StateStore(autosave=False)
        userid = store.ensure_account()["userid"]
        ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"tid": "smketou", "taskList": ["guaji", "smketou"]},
        }

        first = add_training_task_point(ctx)
        second = add_training_task_point(ctx)
        third = add_training_task_point(ctx)
        replay = add_training_task_point(ctx)

        self.assertEqual(first["errcode"], 0)
        self.assertEqual(first["data"]["progress"], 1)
        self.assertFalse(first["data"]["completed"])
        self.assertEqual(second["data"]["progress"], 2)
        self.assertEqual(third["data"]["added_point"], 1)
        self.assertTrue(third["data"]["completed"])
        self.assertEqual(third["data"]["point"], 1)
        self.assertEqual(third["data"]["completion_times"], 1)
        self.assertEqual(replay["data"]["added_point"], 0)
        self.assertEqual(replay["data"]["point"], 1)
        self.assertEqual(replay["data"]["completion_times"], 1)

        bucket = store.snapshot()["activity_users"][str(userid)]["limited_time_experience"]
        self.assertEqual(bucket["tasks"]["smketou"]["count"], 3)
        self.assertTrue(bucket["tasks"]["smketou"]["completed"])

    def test_add_training_task_point_is_noop_for_inactive_task(self):
        store = StateStore(autosave=False)
        userid = store.ensure_account()["userid"]
        response = add_training_task_point({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"tid": "guaji", "taskList": []},
        })

        self.assertEqual(response["errcode"], 0)
        self.assertFalse(response["data"]["accepted"])
        self.assertFalse(response["data"]["completed"])
        self.assertEqual(response["data"]["added_point"], 0)
        self.assertEqual(response["data"]["point"], 0)

        invalid = add_training_task_point({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"tid": "guaji", "taskList": "guaji"},
        })
        self.assertEqual(invalid["errcode"], 400)

    def test_account_archive_isolation_and_copying(self):
        store = StateStore()
        account = store.ensure_account()
        userid = account["userid"]
        archive = store.put_archive(userid, {"name": "角色", "exp": 10})
        archive["exp"] = 99
        self.assertEqual(store.get_archive(userid)["exp"], 10)
        other = store.ensure_account()
        self.assertIsNone(store.get_archive(other["userid"]))

    def test_device_email_and_order(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.set_email_code(userid, " Test@Example.COM ", "123456", "bind")
        self.assertEqual(store.get_email(userid)["email"], "")
        store.validate_email_code(userid, "test@example.com", "123456")
        device = store.bind_device(userid, "TEST@example.com", "123456")
        self.assertTrue(device["bound"])
        self.assertEqual(store.get_email(userid)["email"], "test@example.com")
        self.assertEqual(store.get_account(userid)["email"], "test@example.com")
        self.assertEqual(store.get_userid_by_email(" test@EXAMPLE.com "), userid)
        order = store.create_order(userid, {"item_id": "item-1"})
        self.assertEqual(store.get_order(order["trans_id"])["status"], "pending")
        updated = store.update_order(order["order_id"], {"status": "success"})
        self.assertEqual(updated["status"], "success")

    def test_get_email_returns_legacy_numeric_binding_flags(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        ctx = {"state": store, "headers": {"userid": str(userid)}}

        unbound = get_email(ctx)
        self.assertEqual(unbound["errcode"], 0)
        self.assertIs(type(unbound["data"]["is_bind"]), int)
        self.assertIs(type(unbound["data"]["is_logout"]), int)
        self.assertEqual(unbound["data"]["is_bind"], 0)
        self.assertEqual(unbound["data"]["is_logout"], 0)

        store.bind_device(userid, "rank@example.com")
        bound = get_email(ctx)
        self.assertEqual(bound["data"]["email"], "rank@example.com")
        self.assertEqual(bound["data"]["is_bind"], 1)
        self.assertEqual(bound["data"]["is_logout"], 0)

        store.unbind_device(userid)
        logged_out = get_email(ctx)
        self.assertEqual(logged_out["data"]["is_bind"], 0)
        self.assertEqual(logged_out["data"]["is_logout"], 1)

    def test_ranking_name_state_and_legacy_board_contract(self):
        store = StateStore()
        userid = store.ensure_account(defaults={"name": "无名小辈"})["userid"]
        store.put_archive(userid, {
            "userid": userid,
            "name": "无名小辈",
            "lv": 175,
            "exp": 577763,
            "money": 600000000,
            "gold": 6000000,
            "kongfu": 59.9,
            "sex": "男",
            "looks": 18,
            "family": {"name": "youxia"},
        })
        ctx = {"state": store, "headers": {"userid": str(userid)}}

        initial = is_changed_name(ctx)
        self.assertEqual(initial["errcode"], 0)
        self.assertFalse(initial["data"]["changed"])

        renamed = update_username(dict(ctx, body={"name": "哈基米"}))
        self.assertEqual(renamed["errcode"], 0)
        self.assertEqual(store.get_account(userid)["name"], "哈基米")
        self.assertTrue(store.get_account(userid)["ranking_name_changed"])

        changed = is_changed_name(ctx)
        self.assertEqual(changed["errcode"], 1)
        self.assertTrue(changed["data"]["changed"])

        response = get_rank_list(dict(ctx, body={"page": 1}))
        self.assertEqual(response["errcode"], 0)
        self.assertIsInstance(response["data"], list)
        board = response["data"][0]
        self.assertEqual(board["title"], "高手榜")
        self.assertEqual(board["type"], "total_board")
        self.assertEqual(board["header"], ["名次", "昵称", "武学造诣"])
        self.assertEqual(board["board_type"], "default")
        self.assertEqual(board["total_page"], 1)
        self.assertEqual(board["nums"], 10)
        self.assertEqual(board["body"]["list"][0]["name"], "哈基米")
        self.assertEqual(board["body"]["list"][0]["sort"], 1)
        self.assertEqual(board["body"]["list"][0]["dsc"], "ALS勉勉强强")
        self.assertEqual(board["body"]["list"][0]["menpai"], "江湖浪人")
        self.assertEqual(board["body"]["list"][0]["real_menpai"], "江湖浪人")

        page = get_board(dict(ctx, body={"page": 1}, route_tail=["default"]))
        self.assertEqual(page["errcode"], 0)
        self.assertEqual(page["data"]["title"], "高手榜")
        self.assertEqual(page["data"]["body"]["list"][0]["userid"], userid)

    def test_email_binding_is_unique(self):
        store = StateStore()
        first = store.ensure_account()["userid"]
        second = store.ensure_account()["userid"]
        store.bind_device(first, "User@Example.com")
        store.unbind_device(first)
        self.assertEqual(store.get_userid_by_email("user@example.com"), first)
        with self.assertRaisesRegex(ValueError, "email already bound"):
            store.bind_device(second, " user@example.COM ")

    def test_verify_code_checks_target_and_expiry(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.set_email_code(userid, "user@example.com", "123456", "login", expires_at=100)
        with self.assertRaisesRegex(ValueError, "invalid verify target"):
            store.validate_email_code(userid, "other@example.com", "123456", now=99)
        with self.assertRaisesRegex(ValueError, "invalid verify code"):
            store.validate_email_code(userid, "user@example.com", "000000", now=99)
        with self.assertRaisesRegex(ValueError, "verify code expired"):
            store.validate_email_code(userid, "user@example.com", "123456", now=100)

    def test_sending_code_does_not_change_bound_email(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.bind_device(userid, "old@example.com")
        response = send_email({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"email": " New@Example.COM ", "event_type": 1},
        })
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(store.get_email(userid)["email"], "old@example.com")
        self.assertEqual(store.get_account(userid)["email"], "old@example.com")
        store.validate_email_code(userid, "new@example.com", "123456")

    def test_legacy_device_email_binding_is_migrated(self):
        initial = {
            "version": 2,
            "accounts": {"42": {"userid": 42}},
            "devices": {
                "42": {
                    "userid": 42,
                    "email": " Legacy@Example.COM ",
                    "bound": True,
                }
            },
        }
        store = StateStore(initial=initial)
        self.assertEqual(store.get_userid_by_email("legacy@example.com"), 42)
        self.assertEqual(store.get_email(42)["email"], "legacy@example.com")
        self.assertEqual(store.snapshot()["version"], StateStore.VERSION)

    def test_email_login_maps_uuid_for_download(self):
        store = StateStore()
        original = store.ensure_account()["userid"]
        current = store.ensure_account()["userid"]
        store.put_archive(original, {"userid": original, "name": "原角色"})
        store.put_archive(current, {"userid": current, "name": "当前角色"})
        store.bind_device(original, "user@example.com")
        store.set_email_code(current, " USER@example.com ", "123456", "2")
        response = login_device({
            "state": store,
            "headers": {"userid": str(current), "uuid": "device-1"},
            "body": {"email": "User@Example.com", "verify_code": "123456"},
        })
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(response["data"]["userid"], original)
        download = download_user_file_2({
            "state": store,
            "headers": {"userid": str(current), "uuid": "device-1"},
        })
        self.assertEqual(download["data"][0]["userid"], original)

    def test_legacy_transfer_binds_unowned_email_with_mock_code(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.put_archive(userid, {"userid": userid, "name": "当前角色"})

        response = login_device({
            "state": store,
            "headers": {"userid": str(userid), "uuid": "legacy-transfer"},
            "body": {"email": " New@Example.COM ", "verify_code": 123456},
        })

        self.assertEqual(response["errcode"], 0)
        self.assertEqual(response["data"]["userid"], userid)
        self.assertEqual(store.get_email(userid)["email"], "new@example.com")
        self.assertTrue(store.get_email(userid)["is_bind"])
        self.assertEqual(store.get_userid_by_email("new@example.com"), userid)
        self.assertEqual(store.get_active_archive("legacy-transfer")["userid"], userid)

    def test_legacy_transfer_does_not_replace_pending_verify_target(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.put_archive(userid, {"userid": userid, "name": "当前角色"})
        store.set_email_code(
            userid,
            "expected@example.com",
            "123456",
            "login",
            expires_at=int(time.time()) + 60,
        )

        response = login_device({
            "state": store,
            "headers": {"userid": str(userid), "uuid": "legacy-transfer"},
            "body": {"email": "other@example.com", "verify_code": 123456},
        })

        self.assertEqual(response["errcode"], 400)
        self.assertEqual(response["errmsg"], "invalid verify target")
        self.assertIsNone(store.get_userid_by_email("other@example.com"))

    def test_admin_mail_delivery_and_reward_claim_are_idempotent(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        body = {
            "request_id": "grant-20260820-1",
            "userid": userid,
            "title": "后台奖励",
            "content": "请领取附件",
            "rewards": {
                "loc_items": [{"id": "huashancanye", "num": 1}],
                "net_items": [{"id": "jiu106", "num": 2}],
                "net_attrs": [{"id": "yuanbao", "num": 100}],
                "new_currencys": [{"id": "yinpiao", "num": 50}],
            },
        }
        ctx = {"state": store, "headers": {}, "body": body}
        sent = admin_send_email(ctx)
        replay = admin_send_email(ctx)
        self.assertEqual(sent["errcode"], 0)
        self.assertEqual(replay["data"]["mail_id"], sent["data"]["mail_id"])
        self.assertTrue(replay["data"]["replayed"])
        self.assertEqual(len(store.list_mail(userid)), 1)
        info = get_email_info({"state": store, "headers": {"userid": str(userid)}})
        email = info["data"]["emailList"][0]
        self.assertEqual(email["state"], 1)
        self.assertEqual(email["is_get"], 1)
        self.assertEqual(email["loc_items"][0]["state"], 0)
        self.assertTrue(email["loc_items"][0]["onlyId"])
        self.assertEqual(email["net_items"][0]["id"], "jiu106")
        detail = read_email({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"id": email["id"]},
        })
        self.assertEqual(detail["errcode"], 0)
        self.assertEqual(detail["data"]["contents"], "请领取附件")
        self.assertEqual(detail["data"]["is_get"], 1)
        self.assertEqual(detail["data"]["net_items"][0]["name"], "jiu106")
        self.assertEqual(detail["data"]["net_attrs"][0]["state"], 0)
        claim_ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "id": email["id"],
                "retrievables": [email["loc_items"][0]["onlyId"]],
                "dataVer": 1,
                "currencyVersion": 1,
            },
        }
        claimed = get_email_reward(claim_ctx)
        claimed_again = get_email_reward(claim_ctx)
        self.assertEqual(claimed["errcode"], 0)
        self.assertTrue(claimed_again["data"]["replayed"])
        self.assertEqual(store.get_inventory_item_count(userid, "jiu106"), 2)
        account = store.get_account(userid)
        self.assertEqual(
            account["yuanbao"],
            100,
        )
        self.assertEqual(
            account["currencies"]["yinpiao"],
            50,
        )
        archive = store.get_archive(userid)
        jiu = next(item for item in archive["items"] if item["itemId"] == "jiu106")
        self.assertEqual(jiu["count"], 2)
        self.assertEqual(archive["yuanbao"], 100)
        self.assertEqual(archive["yinpiao"], 50)
        self.assertEqual(archive["currencyVersion"], claimed["data"]["currencyVersion"])
        self.assertEqual(archive["dataVer"], claimed["data"]["dataVer"])
        self.assertEqual(
            claimed["data"]["is_get"],
            2,
        )
        self.assertIn("dataVer", claimed["data"])
        self.assertIn("currencyVersion", claimed["data"])

    def test_mail_reward_accepts_empty_retrievables_for_server_rewards(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        sent = admin_send_email({
            "state": store,
            "headers": {},
            "body": {
                "request_id": "grant-empty-retrievables",
                "userid": userid,
                "title": "网络附件",
                "content": "领取",
                "rewards": {
                    "net_items": [{"id": "jiu106", "num": 2}],
                    "net_attrs": [{"id": "yuanbao", "num": 3}],
                },
            },
        })
        mail_id = sent["data"]["mail_id"]
        info = get_email_info({"state": store, "headers": {"userid": str(userid)}})
        email = info["data"]["emailList"][0]
        self.assertEqual(email["is_get"], 1)
        self.assertIsInstance(email["net_items"][0]["state"], int)
        self.assertTrue(email["net_items"][0]["onlyId"])
        claimed = get_email_reward({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"id": mail_id, "retrievables": []},
        })
        self.assertEqual(claimed["errcode"], 0)
        self.assertEqual(store.get_archive(userid)["items"][0]["count"], 2)

    def test_admin_mail_routes_money_and_gold_to_client_applied_attrs(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.put_archive(userid, {
            "userid": userid,
            "money": 10,
            "gold": 20,
            "currencyVersion": 1,
            "dataVer": 1,
        }, data_ver=1)
        sent = admin_send_email({
            "state": store,
            "headers": {},
            "body": {
                "request_id": "grant-money-gold",
                "userid": userid,
                "title": "本地货币奖励",
                "content": "领取",
                "rewards": {
                    "net_attrs": [
                        {"id": "yuanbao", "num": 30},
                        {"id": "money", "num": 100},
                    ],
                    "new_currencys": [
                        {"id": "yinpiao", "num": 40},
                        {"id": "gold", "num": 200},
                    ],
                },
            },
        })
        mail_id = sent["data"]["mail_id"]

        info = get_email_info({"state": store, "headers": {"userid": str(userid)}})
        email = info["data"]["emailList"][0]
        self.assertEqual(
            [(reward["id"], reward["num"]) for reward in email["loc_attrs"]],
            [("money", 100), ("gold", 200)],
        )
        self.assertEqual([reward["id"] for reward in email["net_attrs"]], ["yuanbao"])
        self.assertEqual([reward["id"] for reward in email["new_currencys"]], ["yinpiao"])

        claimed = get_email_reward({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "id": mail_id,
                "retrievables": [reward["onlyId"] for reward in email["loc_attrs"]],
                "dataVer": 1,
                "currencyVersion": 1,
            },
        })
        self.assertEqual(claimed["errcode"], 0)
        self.assertEqual([reward["id"] for reward in claimed["data"]["loc_attrs"]], ["money", "gold"])
        archive = store.get_archive(userid)
        self.assertEqual(archive["money"], 110)
        self.assertEqual(archive["gold"], 220)
        self.assertNotIn("money", store.get_account(userid)["currencies"])
        self.assertNotIn("gold", store.get_account(userid)["currencies"])

    def test_queued_mail_reclassifies_legacy_money_and_gold_rewards(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.add_mail(userid, {
            "title": "旧格式奖励",
            "content": "领取",
            "rewards": {
                "net_attrs": [{"id": "money", "num": 7}],
                "new_currencys": [{"id": "gold", "num": 9}],
            },
        })

        info = get_email_info({"state": store, "headers": {"userid": str(userid)}})
        email = info["data"]["emailList"][0]
        self.assertEqual([reward["id"] for reward in email["loc_attrs"]], ["money", "gold"])
        self.assertEqual(email["net_attrs"], [])
        self.assertEqual(email["new_currencys"], [])

    def test_admin_mail_requires_configured_token(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        body = {
            "request_id": "grant-token-1",
            "userid": userid,
            "title": "后台奖励",
            "content": "请领取附件",
        }
        with mock.patch.object(config, "ADMIN_API_TOKEN", "secret"):
            denied = admin_send_email({"state": store, "headers": {}, "body": body})
            allowed = admin_send_email({
                "state": store,
                "headers": {"x-admin-token": "secret"},
                "body": body,
            })
        self.assertEqual(denied["errcode"], 403)
        self.assertEqual(allowed["errcode"], 0)

    def test_parse_request_json_accepts_wrapped_and_messy_payloads(self):
        payload = {
            "request_id": "grant-messy-1",
            "userid": 9048162373,
            "title": "测试奖励",
            "content": "请领取附件",
        }
        dumped = json.dumps(payload, ensure_ascii=False)
        cases = [
            protocol.parse_request_json("\ufeff" + dumped + ",", content_type="application/json"),
            protocol.parse_request_json('callback(%s);' % dumped, content_type="application/json"),
            protocol.parse_request_json(json.dumps(dumped, ensure_ascii=False), content_type="application/json"),
            protocol.parse_request_json(json.dumps({"data": dumped}, ensure_ascii=False), content_type="application/json"),
        ]
        utf16 = protocol.parse_request_json(
            protocol.decode_request_body(dumped.encode("utf-16"))[0],
            content_type="application/json",
        )
        cases.append(utf16)
        for parsed in cases:
            self.assertEqual(parsed.get("request_id"), "grant-messy-1")
            self.assertEqual(parsed.get("userid"), 9048162373)
        trailing = protocol.parse_request_json(
            '{\n'
            '  "request_id": "<<$timestamp>>",\n'
            '  "userid": 9048162373,\n'
            '  "title": "测试奖励",\n'
            '  "content": "这是一封通过发送的测试邮件，请领取附件。",\n'
            '  "sender": "后台测试",\n'
            '  "expire_days": 30,\n'
            '  "rewards": {\n'
            '    "loc_items": [\n'
            '      {\n'
            '        "id": "fuyuandan",\n'
            '        "num": 99\n'
            '      },\n'
            '      {\n'
            '        "id": "xiyanshui",\n'
            '        "num": 99\n'
            '      },\n'
            '      {\n'
            '        "id": "shenlisan",\n'
            '        "num": 99\n'
            '      },\n'
            '      {\n'
            '        "id": "qingshenyao",\n'
            '        "num": 99\n'
            '      },\n'
            '    ],\n'
            '    "net_attrs": [\n'
            '      {\n'
            '        "id": "yuanbao",\n'
            '        "num": 1000\n'
            '      }\n'
            '    ],\n'
            '    "new_currencys": [\n'
            '      {\n'
            '        "id": "yinpiao",\n'
            '        "num": 500\n'
            '      }\n'
            '    ]\n'
            '  }\n'
            '}',
            content_type="application/json",
        )
        self.assertEqual(trailing.get("request_id"), "<<$timestamp>>")
        self.assertEqual(trailing.get("userid"), 9048162373)
        self.assertEqual(len(trailing["rewards"]["loc_items"]), 4)

    def test_admin_send_email_accepts_aliases_and_wrapped_body(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        sent = admin_send_email({
            "state": store,
            "headers": {"content-type": "application/json"},
            "query": {},
            "body": {},
            "raw_body": json.dumps({
                "data": {
                    "requestId": "grant-alias-1",
                    "user_id": userid,
                    "subject": "别名邮件",
                    "contents": "请领取附件",
                }
            }, ensure_ascii=False),
        })
        self.assertEqual(sent["errcode"], 0)
        self.assertEqual(sent["data"]["userid"], userid)
        wrapped = admin_send_email({
            "state": store,
            "headers": {},
            "body": {
                "requestId": "grant-alias-2",
                "uid": userid,
                "title": "第二封",
                "text": "内容",
            },
        })
        self.assertEqual(wrapped["errcode"], 0)
        self.assertEqual(len(store.list_mail(userid)), 2)

    def test_mail_activity_ranking_and_biwu(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        empty_response = get_email_info({
            "state": store,
            "headers": {"userid": str(userid)},
        })
        self.assertEqual(empty_response["data"]["emailList"], [])
        self.assertEqual(empty_response["data"]["emailMaxNum"], 50)
        mail = store.add_mail(userid, {"title": "奖励"})
        response = get_email_info({
            "state": store,
            "headers": {"userid": str(userid)},
        })
        self.assertEqual(response["data"]["emailList"][0]["id"], mail["mail_id"])
        self.assertEqual(response["data"]["emailList"][0]["is_read"], 0)
        self.assertEqual(response["data"]["emailList"][0]["is_get"], 0)
        self.assertEqual(response["data"]["emailList"][0]["expired_time"], 0)
        self.assertFalse(store.list_mail(userid)[0]["read"])
        self.assertTrue(store.update_mail(userid, mail["mail_id"], {"read": True})["read"])
        store.put_activity("a1", {"type": 2, "enabled": True})
        self.assertEqual(len(store.get_activities(2)), 1)
        store.update_activity_user(userid, "a1", {"point": 5})
        store.upsert_ranking("default", userid, {"name": "角色", "score": 20})
        self.assertEqual(store.get_rankings()["list"][0]["userid"], userid)
        fight = store.add_biwu_fight(userid, {"status": "finished"})
        self.assertEqual(store.list_biwu_fights(userid)[0]["fight_id"], fight["fight_id"])

    def test_delete_single_and_processed_emails(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        plain = store.add_mail(userid, {"title": "普通邮件"})
        claimed = store.add_mail(userid, {
            "title": "已领取邮件",
            "claimed": True,
            "rewards": {"net_items": [{"id": "jiu106", "num": 1}]},
        })
        pending = store.add_mail(userid, {
            "title": "未领取邮件",
            "rewards": {"loc_items": [{"id": "innatePointSwitchbox", "num": 1}]},
        })
        single = delete_email({
            "state": store,
            "headers": {"userid": str(userid)},
            "route_tail": [pending["mail_id"]],
        })
        self.assertEqual(single["errcode"], 0)
        self.assertTrue(store.get_mail(userid, pending["mail_id"])["deleted"])
        result = delete_processed_emails({
            "state": store,
            "headers": {"userid": str(userid)},
        })
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(
            result["data"]["delete_ids"],
            [plain["mail_id"], claimed["mail_id"]],
        )
        visible = get_email_info({
            "state": store,
            "headers": {"userid": str(userid)},
        })
        self.assertEqual(visible["data"]["emailList"], [])

    def test_upgrade_bag_and_warehouse_capacity(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        store.put_archive(userid, {
            "money": 1000000,
            "weight": 30,
            "wUpCount": 0,
            "baseCkLimit": 30,
            "ckLimit": 40,
            "ckUpCount": 0,
            "dataVer": 5,
        }, data_ver=5)
        bag = upgrade_user_bag({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"type": 1, "level": 1001},
        })
        self.assertEqual(bag["errcode"], 0)
        self.assertEqual(bag["data"]["currency"], 1)
        self.assertEqual(bag["data"]["count"], 12000)
        role = store.get_archive(userid)
        self.assertEqual(role["weight"], 35)
        self.assertEqual(role["wUpCount"], 1)
        self.assertEqual(role["money"], 988000)
        warehouse = upgrade_user_bag({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"type": 2, "level": 1001},
        })
        self.assertEqual(warehouse["errcode"], 0)
        role = store.get_archive(userid)
        self.assertEqual(role["baseCkLimit"], 35)
        self.assertEqual(role["ckLimit"], 45)
        self.assertEqual(role["ckUpCount"], 1)
        self.assertEqual(role["money"], 982000)
        conflict = upgrade_user_bag({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"type": 1, "level": 1001},
        })
        self.assertEqual(conflict["errcode"], 409)
        self.assertEqual(store.get_archive(userid)["money"], 982000)

    def test_device_uuid_persists_across_restart(self):
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "state.json")
            first = StateStore(path)
            expected_uuid = "guanfangd0b80cf7aa09ea3538329b0d"
            device_uuid = first.get_or_create_device_uuid(expected_uuid)
            self.assertEqual(device_uuid, expected_uuid)
            self.assertEqual(
                first.get_or_create_device_uuid("guanfang-other"),
                device_uuid,
            )
            second = StateStore(path)
            self.assertEqual(
                second.get_or_create_device_uuid("guanfang-other"),
                device_uuid,
            )

    def test_json_persistence_and_corrupt_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "state.json")
            archives_dir = os.path.join(directory, "archives")
            first = StateStore(path, archives_dir=archives_dir)
            userid = first.ensure_account()["userid"]
            first.put_archive(userid, {"userid": userid, "name": "持久化", "lv": 1})
            self.assertTrue(os.path.isfile(os.path.join(archives_dir, "%d.json" % userid)))
            second = StateStore(path, archives_dir=archives_dir)
            self.assertEqual(second.get_archive(userid)["name"], "持久化")
            with open(path, "w", encoding="utf-8") as handle:
                handle.write("{")
            third = StateStore(path, archives_dir=archives_dir)
            self.assertIsNone(third.get_account(userid))
            # 账号索引丢了, 但分文件存档仍可回放
            self.assertEqual(third.get_archive(userid)["name"], "持久化")

    def test_register_account_is_empty_by_default(self):
        with tempfile.TemporaryDirectory() as directory:
            store = StateStore(
                os.path.join(directory, "state.json"),
                archives_dir=os.path.join(directory, "archives"),
            )
            account = store.register_account(
                username="demo",
                password_hash="x",
                email=" User@Example.COM ",
            )
            self.assertFalse(account["has_archive"])
            self.assertEqual(account["email"], "user@example.com")
            self.assertEqual(store.get_userid_by_email("USER@example.com"), account["userid"])
            self.assertIsNone(store.get_archive(account["userid"]))

    def test_create_account_accepts_optional_email(self):
        store = StateStore()
        response = create_account({
            "state": store,
            "headers": {},
            "body": {"userid": 0, "email": " New@Example.COM "},
        })
        userid = response["data"]["userid"]
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(store.get_account(userid)["email"], "new@example.com")
        self.assertEqual(store.get_userid_by_email("NEW@example.com"), userid)
        self.assertNotEqual(userid, 9048162373)

    def test_empty_login_falls_back_to_seed_archive(self):
        with tempfile.TemporaryDirectory() as directory:
            seed = os.path.join(directory, "RoleData.json")
            with open(seed, "w", encoding="utf-8") as handle:
                json.dump(
                    {
                        "userid": 9048162373,
                        "name": "和风无声",
                        "lv": 550,
                        "serverActionSystem": {"dataVersion": 2, "requestId": 1},
                    },
                    handle,
                    ensure_ascii=False,
                )
            store = StateStore(
                os.path.join(directory, "state.json"),
                archives_dir=os.path.join(directory, "archives"),
            )
            store.import_seed_roledata(seed, overwrite=False)
            created = create_account({
                "state": store,
                "headers": {"userid": "0", "uuid": "device-empty"},
                "body": {},
            })
            self.assertEqual(created["errcode"], 0)
            self.assertEqual(created["data"]["userid"], 9048162373)
            empty = store.ensure_account(None)
            self.assertNotEqual(empty["userid"], 9048162373)
            recovered = create_account({
                "state": store,
                "headers": {"userid": str(empty["userid"])},
                "body": {},
            })
            self.assertEqual(recovered["data"]["userid"], 9048162373)
            download = download_user_file_2({
                "state": store,
                "headers": {"userid": str(empty["userid"])},
            })
            self.assertEqual(download["errcode"], 0)
            self.assertEqual(download["data"][0]["userid"], 9048162373)
            self.assertEqual(download["data"][0]["name"], "和风无声")
            registered = create_account({
                "state": store,
                "headers": {"userid": "0"},
                "body": {"userid": 0, "email": "new@example.com"},
            })
            self.assertEqual(registered["errcode"], 0)
            self.assertNotEqual(registered["data"]["userid"], 9048162373)

    def test_create_account_rejects_duplicate_email(self):
        store = StateStore()
        store.register_account(email="user@example.com")
        response = create_account({
            "state": store,
            "headers": {},
            "body": {"userid": 0, "email": " User@Example.COM "},
        })
        self.assertEqual(response["errcode"], 409)
        self.assertEqual(len(store.snapshot()["accounts"]), 1)

    def test_seed_import_and_switch(self):
        with tempfile.TemporaryDirectory() as directory:
            seed = os.path.join(directory, "RoleData.json")
            with open(seed, "w", encoding="utf-8") as handle:
                json.dump({"userid": 9048162373, "name": "和风无声", "lv": 550, "serverActionSystem": {"dataVersion": 2, "requestId": 1}}, handle, ensure_ascii=False)
            store = StateStore(
                os.path.join(directory, "state.json"),
                archives_dir=os.path.join(directory, "archives"),
            )
            doc = store.import_seed_roledata(seed, overwrite=False)
            self.assertEqual(doc["userid"], 9048162373)
            self.assertEqual(store.get_archive(9048162373)["name"], "和风无声")
            store.set_active_archive("uuid-1", 9048162373)
            self.assertEqual(store.get_active_archive("uuid-1")["userid"], 9048162373)
            self.assertEqual(store.list_archives()[0]["name"], "和风无声")

    def test_snapshot_and_reset(self):
        store = StateStore()
        store.ensure_account()
        snapshot = store.snapshot()
        snapshot["accounts"].clear()
        self.assertEqual(len(store.snapshot()["accounts"]), 1)
        store.reset()
        self.assertEqual(store.snapshot()["accounts"], {})
        self.assertEqual(store.ensure_account()["userid"], StateStore.DEFAULT_USER_ID)

    def test_missing_api_contracts(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        base_ctx = {"state": store, "headers": {"userid": str(userid)}}

        challenge = challengemap_unfinished(dict(base_ctx))
        self.assertEqual(challenge["data"], {"status": 0})
        spring = get_spring_festival_list(dict(base_ctx))
        self.assertIsInstance(spring["data"], list)
        self.assertEqual(spring["data"][0]["name"], "签到活动")
        self.assertEqual(spring["data"][0]["id"], 14)
        self.assertEqual(spring["data"][0]["activity_id"], "qiandao")
        self.assertEqual(spring["data"][0]["status"], 1)
        self.assertEqual(spring["data"][0]["is_open"], 1)

        chongzhi = get_spring_festival_status(dict(base_ctx, route_tail=["19"]))
        self.assertEqual(chongzhi["errcode"], 0)
        self.assertEqual(chongzhi["data"]["id"], 19)
        self.assertEqual(chongzhi["data"]["name"], "充值积分兑换")
        self.assertEqual(chongzhi["data"]["status"], 1)
        self.assertEqual(chongzhi["data"]["is_open"], 1)
        self.assertGreater(chongzhi["data"]["end"], int(time.time()))

        shop = get_shop_info(dict(base_ctx, body={"shop_id": "zhounianqin_cz"}))
        self.assertEqual(shop["errcode"], 0)
        shop_info = shop["data"]["shop_info"]
        self.assertEqual(shop_info["shop_id"], "zhounianqin_cz")
        self.assertEqual(shop_info["is_open"], "Y")
        self.assertEqual(shop_info["typeName"]["tuijian"]["name"], "推荐")
        self.assertEqual(
            {key: len(items) for key, items in shop_info["goods"].items()},
            {"tuijian": 49, "shuxing": 16, "wuxue": 32,
             "shenbing": 8, "guashi": 7, "mianju": 7, "default": 25},
        )
        first = shop_info["goods"]["tuijian"][0]
        self.assertEqual(first["itemId"], "xinbawangqiangfa")
        self.assertEqual(first["price"], 4000)
        self.assertEqual(first["extra"]["limit"], 1)
        self.assertEqual(shop["data"]["total_points"], 0)
        self.assertFalse(shop["data"]["isDis"])

        # 积分余额跟随账户变化
        account = store.get_account(userid) or {}
        account["currencies"] = {"chongzhijifen": 1200}
        store.update_account(userid, account)
        shop = get_shop_info(dict(base_ctx, body={"shop_id": "zhounianqin_cz"}))
        self.assertEqual(shop["data"]["total_points"], 1200)

        missing = get_shop_info(dict(base_ctx, body={"shop_id": "no_such_shop"}))
        self.assertEqual(missing["errcode"], 404)
        invalid = get_shop_info({"state": store, "headers": {}, "body": {}})
        self.assertEqual(invalid["errcode"], 550)

        sign = get_sign_list(dict(base_ctx))
        self.assertEqual(sign["errcode"], 0)
        self.assertEqual(
            set(sign["data"]),
            {
                "beginDate", "endDate", "seasonId", "signedList",
                "historySignCount", "prizeList", "prizeId", "yuanbao",
                "createDate",
            },
        )
        self.assertEqual(len(sign["data"]["beginDate"]), 8)
        self.assertEqual(len(sign["data"]["endDate"]), 8)
        self.assertIsInstance(sign["data"]["signedList"], list)
        self.assertEqual(sign["data"]["prizeId"], 15)

        today = time.strftime("%Y%m%d", time.localtime())
        claim_ctx = dict(base_ctx, body={
            "trans_id": "sign-today-1",
            "date": today,
            "item_id": "qiandao1",
            "is_homeland": 1,
        })
        claimed = get_sign_prize(claim_ctx)
        self.assertEqual(claimed["errcode"], 0)
        self.assertEqual(claimed["data"]["daily_point"], 10)
        self.assertIn(today, get_sign_list(dict(base_ctx))["data"]["signedList"])
        self.assertEqual(get_sign_list(dict(base_ctx))["data"]["historySignCount"], 1)

        replay = get_sign_prize(claim_ctx)
        self.assertEqual(replay, claimed)
        duplicate = get_sign_prize(dict(claim_ctx, body=dict(
            claim_ctx["body"], trans_id="sign-today-2"
        )))
        self.assertEqual(duplicate["errcode"], 2)
        self.assertEqual(get_sign_list(dict(base_ctx))["data"]["historySignCount"], 1)

        info_ctx = dict(base_ctx, body={"familyId": "huashan"})
        info = get_teacher_build_info(info_ctx)
        self.assertEqual(info["data"]["guajiInfo"], {})
        builds = get_teacher_build_list(info_ctx)
        self.assertIsInstance(builds["data"], list)
        self.assertEqual(builds["data"][0]["state"], 0)
        items = get_teacher_build_items(info_ctx)
        self.assertEqual(
            items["data"],
            [
                {"itemId": "bmaterials1", "count": 0, "countLimit": 300},
                {"itemId": "bmaterials2", "count": 0, "countLimit": 300},
                {"itemId": "bmaterials3", "count": 0, "countLimit": 300},
            ],
        )

        added = add_devote_point(dict(base_ctx, body={"type": 5, "point": 100}))
        self.assertEqual(added["data"]["get_point"], 100)
        self.assertEqual(added["data"]["dev_point"], 100)
        current = get_devote_point(dict(base_ctx))
        self.assertEqual(current["data"]["dev_point"], 100)
        devote_list = get_devote_list(dict(base_ctx, body={"type": 1, "menpai": "huashan"}))
        self.assertTrue(devote_list["data"]["list"])
        self.assertEqual(devote_list["data"]["list"][0]["status"], 0)
        group = get_user_group(dict(base_ctx, body={
            "userid": userid,
            "tid": "fenglao",
            "menpai": "huashan",
            "isCache": 0,
        }))
        self.assertEqual(group["errcode"], 0)
        self.assertEqual(group["data"][0]["userid"], userid)
        self.assertEqual(group["data"][0]["name"], "玩家%s" % userid)
        rank = get_group_rank(dict(base_ctx))
        self.assertEqual(rank["errcode"], 0)
        self.assertIsInstance(rank["data"], list)
        self.assertEqual(rank["data"][0]["userid"], userid)
        self.assertEqual(rank["data"][0]["kongfu"], 0)
        self.assertEqual(rank["data"][0]["prestige"], 100)

    def test_shop_exchange_goods_deducts_points_and_enforces_limit(self):
        userid = 9048162383
        store = StateStore(initial={
            "accounts": {
                str(userid): {
                    "userid": userid,
                    "currencies": {"chongzhijifen": 5000},
                    "currency_version": 2,
                }
            },
            "archives": {
                str(userid): {"name": "角色", "chongzhijifen": 5000, "currencyVersion": 2},
            },
        }, autosave=False)
        ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "itemId": "xinggongsan",
                "client_trans_id": "exchange-1",
                "shop_id": "zhounianqin_cz",
                "number": 3,
                "dataVer": 1,
                "currencyVersion": 2,
            },
        }

        # xinggongsan: price=50, times=30
        response = shop_exchange_goods(ctx)
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(
            response["data"]["reward"],
            {"itemId": "xinggongsan", "number": 3, "itype": 1, "name": "行功散"},
        )
        self.assertEqual(response["data"]["romove_point"], 150)
        self.assertEqual(response["data"]["total_points"], 4850)
        self.assertFalse(response["data"]["isDis"])
        self.assertEqual(response["data"]["currencyVersion"], 3)

        archive = store.get_archive(userid)
        self.assertEqual(archive["chongzhijifen"], 4850)
        self.assertEqual(store.get_account(userid)["currencies"]["chongzhijifen"], 4850)

        # 幂等重放: 同 client_trans_id 返回同响应且不重复扣分
        replay = shop_exchange_goods(dict(ctx))
        self.assertEqual(replay, response)
        self.assertEqual(store.get_archive(userid)["chongzhijifen"], 4850)

        # 同 trans_id 不同内容 -> 409
        conflict = shop_exchange_goods(dict(ctx, body=dict(ctx["body"], number=1)))
        self.assertEqual(conflict["errcode"], 409)

        # 商店余额同步
        shop = get_shop_info(dict(ctx, body={"shop_id": "zhounianqin_cz"}))
        self.assertEqual(shop["data"]["total_points"], 4850)

        # 限购: xinbawangqiangfa times=1, price=4000
        skill = shop_exchange_goods(dict(ctx, body=dict(
            ctx["body"], itemId="xinbawangqiangfa", client_trans_id="exchange-2", number=1)))
        self.assertEqual(skill["errcode"], 0)
        self.assertEqual(skill["data"]["total_points"], 850)
        again = shop_exchange_goods(dict(ctx, body=dict(
            ctx["body"], itemId="xinbawangqiangfa", client_trans_id="exchange-3", number=1)))
        self.assertEqual(again["errcode"], 1)
        self.assertEqual(again["errmsg"], "您已经达到购买上限")
        self.assertEqual(store.get_archive(userid)["chongzhijifen"], 850)

        # 积分不足: mianju1029 price=1800 > 850
        poor = shop_exchange_goods(dict(ctx, body=dict(
            ctx["body"], itemId="mianju1029", client_trans_id="exchange-4", number=1)))
        self.assertEqual(poor["errcode"], 1)
        self.assertEqual(poor["errmsg"], "充值积分不足")

        # 未知商品 / 未知商店 / 非法参数 / 非法 userid / 无存档
        unknown_goods = shop_exchange_goods(dict(ctx, body=dict(
            ctx["body"], itemId="no_such_item", client_trans_id="exchange-5")))
        self.assertEqual(unknown_goods["errcode"], 1)
        unknown_shop = shop_exchange_goods(dict(ctx, body=dict(
            ctx["body"], shop_id="no_such_shop", client_trans_id="exchange-6")))
        self.assertEqual(unknown_shop["errcode"], 404)
        bad_request = shop_exchange_goods(dict(ctx, body={"itemId": "xinggongsan", "number": 1}))
        self.assertEqual(bad_request["errcode"], 1)
        invalid_user = shop_exchange_goods({"state": store, "headers": {}, "body": {}})
        self.assertEqual(invalid_user["errcode"], 550)
        no_archive = shop_exchange_goods({
            "state": StateStore(initial={"accounts": {"1": {"userid": 1}}, "archives": {}}, autosave=False),
            "headers": {"userid": "1"},
            "body": {"itemId": "xinggongsan", "shop_id": "zhounianqin_cz",
                     "client_trans_id": "exchange-7", "number": 1},
        })
        self.assertEqual(no_archive["errcode"], 404)

    def test_sign_in_state_persists_across_restart(self):
        with tempfile.TemporaryDirectory() as directory:
            path = os.path.join(directory, "state.json")
            first = StateStore(path)
            userid = first.ensure_account()["userid"]
            today = time.strftime("%Y%m%d", time.localtime())
            ctx = {
                "state": first,
                "headers": {"userid": str(userid)},
                "body": {
                    "trans_id": "persisted-sign-1",
                    "date": today,
                    "item_id": "qiandao1",
                },
            }
            self.assertEqual(get_sign_prize(ctx)["errcode"], 0)

            second = StateStore(path)
            restored = get_sign_list({
                "state": second,
                "headers": {"userid": str(userid)},
            })
            self.assertEqual(restored["data"]["signedList"], [today])
            self.assertEqual(restored["data"]["historySignCount"], 1)

    def test_legacy_teacher_build_idle_state_is_normalized(self):
        store = StateStore(initial={
            "accounts": {"42": {"userid": 42}},
            "teacher_build": {
                "42": {
                    "families": {
                        "huashan": {
                            "familyId": "huashan",
                            "guajiInfo": {"status": 0},
                        }
                    }
                }
            },
        })
        response = get_teacher_build_info({
            "state": store,
            "headers": {"userid": "42"},
            "body": {"familyId": "huashan"},
        })
        self.assertEqual(response["data"]["guajiInfo"], {})

    def test_xin_shen_query_settles_recovery_every_300_seconds(self):
        userid = 42
        store = StateStore(initial={
            "practice": {
                str(userid): {
                    "xinShen": {
                        "curr": 100,
                        "max": 400,
                        "level": 1,
                        "recoverStartTime": 1000,
                    },
                },
            },
        })
        ctx = {"state": store, "headers": {"userid": str(userid)}, "body": {}}
        with mock.patch("handlers.practice.time.time", return_value=1601):
            response = get_xin_shen_value(ctx)
        self.assertEqual(response["data"]["curr"], 120)
        self.assertEqual(response["data"]["max"], 400)
        self.assertEqual(response["data"]["time"], 1600)
        xin = store.snapshot()["practice"][str(userid)]["xinShen"]
        self.assertEqual(xin["curr"], 120)
        self.assertEqual(xin["recoverStartTime"], 1600)

    def test_xin_shen_query_caps_at_max_and_resets_recovery_time(self):
        userid = 42
        store = StateStore(initial={
            "practice": {
                str(userid): {
                    "xinShen": {
                        "curr": 395,
                        "max": 400,
                        "level": 1,
                        "recoverStartTime": 1000,
                    },
                },
            },
        })
        ctx = {"state": store, "headers": {"userid": str(userid)}, "body": {}}
        with mock.patch("handlers.practice.time.time", return_value=1300):
            response = get_xin_shen_value(ctx)
        self.assertEqual(response["data"]["curr"], 400)
        self.assertEqual(response["data"]["time"], 1300)

    def test_recover_xin_shen_rejects_unsafe_client_values(self):
        userid = 42
        store = StateStore(initial={
            "practice": {
                str(userid): {
                    "xinShen": {
                        "curr": 100,
                        "max": 400,
                        "level": 1,
                        "recoverStartTime": 1000,
                    },
                },
            },
        })
        base = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"codeVer": 1, "dataVer": 1, "value": 10, "time": 1300},
        }
        with mock.patch("handlers.practice.time.time", return_value=1300):
            too_large = recover_xin_shen_value(dict(base, body=dict(base["body"], value=999999)))
            stale_time = recover_xin_shen_value(dict(base, body=dict(base["body"], time=999)))
        self.assertEqual(too_large["errcode"], 400)
        self.assertEqual(stale_time["errcode"], 400)
        self.assertEqual(store.snapshot()["practice"][str(userid)]["xinShen"]["curr"], 100)

    def test_recover_xin_shen_accepts_one_due_server_verified_tick(self):
        userid = 42
        store = StateStore(initial={
            "practice": {
                str(userid): {
                    "xinShen": {
                        "curr": 100,
                        "max": 400,
                        "level": 1,
                        "recoverStartTime": 1000,
                    },
                },
            },
        })
        ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"codeVer": 1, "dataVer": 3, "value": 10, "time": 1300},
        }
        with mock.patch("handlers.practice.time.time", return_value=1300):
            response = recover_xin_shen_value(ctx)
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(response["data"]["curr"], 110)
        self.assertEqual(response["data"]["time"], 1300)
        self.assertEqual(response["data"]["dataVer"], 4)

    def test_homeland_house_employee_and_dispatch_state_persist(self):
        userid = 9048162373
        store = StateStore(initial={
            "accounts": {str(userid): {"userid": userid}},
            "archives": {},
        }, autosave=False)
        ctx = {"state": store, "headers": {"userid": str(userid)}, "body": {}}

        house = get_house_info(ctx)
        self.assertEqual(house["errcode"], 0)
        mid = house["data"]["mid"]
        self.assertEqual(mid, 14750)
        self.assertTrue(house["data"]["person"])

        user_info = get_game_user_info_2(ctx)
        self.assertEqual(user_info["errcode"], 0)
        self.assertIs(user_info["data"]["jiayuantch"], True)

        home_switch = get_home_switch(ctx)
        self.assertEqual(home_switch["errcode"], 0)
        self.assertIs(home_switch["data"]["open"], True)
        self.assertIs(type(home_switch["data"]["yinpiao"]), int)

        steward = add_employee({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": "guanjia_test_1",
                "mid": mid,
                "npcId": 0,
                "push_data": {},
            },
        })
        self.assertEqual(steward["errcode"], 0)
        self.assertEqual(steward["data"]["jobType"], "guanjia001")

        employee = add_employee({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": "puren_test_1",
                "mid": mid,
                "npcId": 1,
                "push_data": {"jobType": "puren001", "name": "小四"},
            },
        })
        self.assertEqual(employee["errcode"], 0)
        self.assertEqual(employee["data"]["rwId"], "puren_test_1")

        updated = update_employee_extra({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"mid": mid, "up_data": [{
                "rwId": "puren_test_1",
                "extra": {"stay_room_time": 4102444800},
            }]},
        })
        self.assertEqual(updated["errcode"], 0)

        mapped = get_user_map({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"mid": mid, "userid": userid, "ver": 0},
        })
        self.assertEqual(mapped["errcode"], 0)
        self.assertEqual(mapped["data"]["usermap"]["hxId"], "huxing002")
        self.assertEqual(mapped["data"]["usermap"]["dirMark"], 0)
        room_by_id = {
            room["fjId"]: room
            for room in mapped["data"]["maproom"]
        }
        self.assertEqual(room_by_id["fb320_01"]["up"], "fb320_02")
        self.assertEqual(room_by_id["fb320_02"]["roomType"], "tsfangjian003")
        # huxing002 布局与 familytype.lua 对齐: 全图房间数与入口
        self.assertEqual(len(room_by_id), 9)
        self.assertEqual(mapped["data"]["usermap"]["entryRoom"], "fb320_02")
        self.assertEqual(
            mapped["data"]["usermap"]["mapAppearanceIndex"].count("fb320_"), 9
        )
        affairs = get_affair_list({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"biz_type": 3, "mid": mid},
            "route_tail": ["5"],
        })
        self.assertEqual(affairs["errcode"], 0)
        self.assertEqual(affairs["data"], [])
        self.assertEqual(
            [person["rwId"] for person in mapped["data"]["roomperson"]],
            ["guanjia_test_1"],
        )

        detail = get_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"mid": mid, "objId": "puren_test_1"},
        })
        self.assertEqual(detail["data"]["extra"]["stay_room_time"], 4102444800)
        listed = get_employee_list({
            "state": store,
            "headers": {"userid": str(userid)},
            "route_tail": ["1", str(mid)],
        })
        self.assertEqual(listed["errcode"], 0)

        deleted = delete_employee({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"mid": mid, "objId": "puren_test_1"},
        })
        self.assertEqual(deleted["errcode"], 0)

    def test_get_guaike_reward_grants_yinpiao_gold_and_items(self):
        userid = 9048162374
        store = StateStore(initial={
            "accounts": {str(userid): {"userid": userid}},
            "archives": {str(userid): {"name": "角色", "yinpiao": 10, "gold": 5, "items": []}},
        }, autosave=False)
        house = get_house_info({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {},
        })
        self.assertEqual(house["errcode"], 0)
        mid = house["data"]["mid"]
        employee = add_employee({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": "puren_gk_1",
                "mid": mid,
                "npcId": 1,
                "push_data": {"jobType": "puren001", "name": "小四", "defaultZhongCheng": 700},
            },
        })
        self.assertEqual(employee["errcode"], 0)

        response = get_guaike_reward({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "isMenKe": 1,
                "menKeId": "puren_gk_1",
                "mid": mid,
                "guaikeLv": 2,
            },
        })
        self.assertEqual(response["errcode"], 0)
        data = response["data"]
        self.assertEqual(data["yinpiao"], 200)
        self.assertEqual(data["gold"], 100)
        self.assertEqual(data["yueli"], 0)
        self.assertEqual(data["weiwang"], 0)
        self.assertEqual(data["level_up"], False)
        self.assertEqual(data["trait"], {})
        self.assertEqual(data["defaultZhongCheng"], 700)
        self.assertEqual(data["activityItems"], [
            {"itemId": "qiannengdan", "num": 1},
            {"itemId": "jingmai102", "num": 1},
        ])

        archive = store.get_archive(userid)
        self.assertEqual(archive["yinpiao"], 210)
        self.assertEqual(archive["gold"], 105)
        item_counts = {item["itemId"]: item["count"] for item in archive["items"]}
        self.assertEqual(item_counts["qiannengdan"], 1)
        self.assertEqual(item_counts["jingmai102"], 1)

    def test_get_user_map_returns_familytype_appearance_for_each_hxid(self):
        userid = 9048162375
        expected_hx = (
            "huxing001", "huxing002", "huxing003", "huxing004",
            "huxing005", "huxing006", "huxing008", "huxing009",
            "huxing010", "huxing011", "huxing012",
        )
        self.assertEqual(tuple(sorted(HX_TABLE)), tuple(sorted(expected_hx)))
        for hx_id in expected_hx:
            spec = HX_TABLE[hx_id]
            store = StateStore(initial={
                "accounts": {str(userid): {"userid": userid}},
                "archives": {},
            }, autosave=False)
            ctx = {"state": store, "headers": {"userid": str(userid)}, "body": {}}
            house = get_house_info(ctx)
            self.assertEqual(house["errcode"], 0)
            mid = house["data"]["mid"]
            with store._lock:
                bucket = store._normalize_homeland(store._state)["users"][str(userid)]
                bucket["house"]["hxId"] = hx_id
                bucket["rooms"] = [{"fjId": "room_stale", "name": "旧房间"}]
            mapped = get_user_map({
                "state": store,
                "headers": {"userid": str(userid)},
                "body": {"mid": mid, "userid": userid, "ver": 0},
            })
            self.assertEqual(mapped["errcode"], 0, hx_id)
            usermap = mapped["data"]["usermap"]
            self.assertEqual(usermap["hxId"], hx_id)
            self.assertEqual(usermap["entryRoom"], spec["entryRoom"])
            self.assertEqual(usermap["BGM"], spec["BGM"])
            self.assertEqual(usermap["mapAppearance"], spec["mapAppearance"])
            self.assertEqual(usermap["mapAppearanceIndex"], spec["mapAppearanceIndex"])
            room_ids = [room["fjId"] for room in mapped["data"]["maproom"]]
            self.assertEqual(len(room_ids), len(spec["rooms"]), hx_id)
            self.assertTrue(all(fjid.startswith(spec["roomPrefix"]) for fjid in room_ids), hx_id)
            self.assertIn(spec["entryRoom"], room_ids)
            for room in mapped["data"]["maproom"]:
                self.assertEqual(room["stepMusic"], "jiaobu", room["fjId"])
            roomperson = mapped["data"]["roomperson"]
            self.assertEqual([person["rwId"] for person in roomperson], ["guanjia1001"], hx_id)
            self.assertIn(roomperson[0]["fjId"], room_ids)
            self.assertEqual(roomperson[0]["job"], "guanjia001")

    def test_get_user_map_includes_default_hired_steward(self):
        userid = 9048162376
        store = StateStore(initial={
            "accounts": {str(userid): {"userid": userid}},
            "archives": {},
        }, autosave=False)
        ctx = {"state": store, "headers": {"userid": str(userid)}, "body": {}}
        house = get_house_info(ctx)
        self.assertEqual(house["errcode"], 0)
        self.assertTrue(house["data"]["person"])
        mid = house["data"]["mid"]
        mapped = get_user_map({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"mid": mid, "userid": userid, "ver": 0},
        })
        self.assertEqual(mapped["errcode"], 0)
        room_ids = {room["fjId"] for room in mapped["data"]["maproom"]}
        persons = mapped["data"]["roomperson"]
        self.assertEqual(len(persons), 1)
        steward = persons[0]
        self.assertEqual(steward["rwId"], "guanjia1001")
        self.assertEqual(steward["job"], "guanjia001")
        self.assertEqual(steward["jobType"], "guanjia001")
        self.assertEqual(steward["name"], "权令枫")
        self.assertEqual(steward["modal"], "moban010")
        self.assertIn(steward["fjId"], room_ids)
        extra = steward.get("extra") or {}
        self.assertNotIn("stay_room_time", extra)

    def test_view_currency_by_type_reads_archive_balance(self):
        userid = 9048162377
        store = StateStore(initial={
            "accounts": {str(userid): {"userid": userid, "currencies": {"mingbi": 8}}},
            "archives": {str(userid): {"name": "角色", "yinpiao": 321, "zongheng": 12}},
        }, autosave=False)
        ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao", "currencyVersion": 1},
        }
        response = view_currency_by_type(ctx)
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(response["data"]["number"], 321)
        self.assertEqual(response["data"]["costYb"], 10)

        zongheng = view_currency_by_type(dict(ctx, body={"currency_type": "zongheng"}))
        self.assertEqual(zongheng["errcode"], 0)
        self.assertEqual(zongheng["data"]["number"], 12)
        self.assertEqual(zongheng["data"]["limitNumber"], 9999)

        mingbi = view_currency_by_type(dict(ctx, body={"currency_type": "mingbi"}))
        self.assertEqual(mingbi["data"]["number"], 8)

        missing = view_currency_by_type(dict(ctx, body={"currency_type": "spcl"}))
        self.assertEqual(missing["data"]["number"], 0)

        empty = view_currency_by_type({
            "state": StateStore(initial={"accounts": {"1": {"userid": 1}}, "archives": {}}, autosave=False),
            "headers": {"userid": "1"},
            "body": {"currency_type": "yinpiao"},
        })
        self.assertEqual(empty["errcode"], 0)
        self.assertEqual(empty["data"]["number"], 0)
        self.assertEqual(empty["data"]["costYb"], 10)

    def test_view_currency_by_type_follows_email_reward_balances(self):
        store = StateStore()
        userid = store.ensure_account()["userid"]
        sent = admin_send_email({
            "state": store,
            "headers": {},
            "body": {
                "request_id": "grant-view-currency",
                "userid": userid,
                "title": "货币奖励",
                "content": "领取",
                "rewards": {
                    "net_attrs": [{"id": "yuanbao", "num": 100}],
                    "new_currencys": [{"id": "yinpiao", "num": 50}],
                },
            },
        })
        self.assertEqual(sent["errcode"], 0)
        mail_id = sent["data"]["mail_id"]
        claimed = get_email_reward({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"id": mail_id, "dataVer": 1, "currencyVersion": 1},
        })
        self.assertEqual(claimed["errcode"], 0)

        yinpiao = view_currency_by_type({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao"},
        })
        yuanbao = view_currency_by_type({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yuanbao"},
        })
        self.assertEqual(yinpiao["data"]["number"], 50)
        self.assertEqual(yuanbao["data"]["number"], 100)

        stale = StateStore(initial={
            "accounts": {str(userid): {"userid": userid, "yuanbao": 100, "currencies": {"yinpiao": 50}}},
            "archives": {str(userid): {"name": "角色", "yinpiao": 0, "yuanbao": 0}},
        }, autosave=False)
        stale_yinpiao = view_currency_by_type({
            "state": stale,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao"},
        })
        stale_yuanbao = view_currency_by_type({
            "state": stale,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yuanbao"},
        })
        self.assertEqual(stale_yinpiao["data"]["number"], 50)
        self.assertEqual(stale_yuanbao["data"]["number"], 100)

    def test_get_zhao_upgrade_matters_lists_owned_breakthrough_items(self):
        userid = 9048162379
        store = StateStore(initial={
            "accounts": {
                str(userid): {
                    "userid": userid,
                    "currencies": {
                        "skillUpItem01": 5,
                        "skillUpItem24": 1,
                        "skillUpItem99": 7,
                        "yinpiao": 3,
                    },
                }
            },
            "archives": {str(userid): {"name": "角色", "skillUpItem08": 2}},
        }, autosave=False)
        ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currencyVersion": 1},
        }
        response = get_zhao_upgrade_matters(ctx)
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(
            response["data"]["matters_list"],
            [
                {"id": "skillUpItem01", "num": 5},
                {"id": "skillUpItem08", "num": 2},
                {"id": "skillUpItem24", "num": 1},
            ],
        )

        empty = get_zhao_upgrade_matters({
            "state": StateStore(initial={"accounts": {"1": {"userid": 1}}, "archives": {}}, autosave=False),
            "headers": {"userid": "1"},
            "body": {},
        })
        self.assertEqual(empty["errcode"], 0)
        self.assertEqual(empty["data"]["matters_list"], [])

        invalid = get_zhao_upgrade_matters({
            "state": store,
            "headers": {},
            "body": {},
        })
        self.assertEqual(invalid["errcode"], 550)

    def test_zhao_upgrade_consumes_matters_and_persists_level(self):
        userid = 9048162380
        store = StateStore(initial={
            "accounts": {str(userid): {"userid": userid, "currencies": {"skillUpItem01": 5}}},
            "archives": {str(userid): {"name": "角色", "skillUpItem01": 5, "currencyVersion": 3}},
        }, autosave=False)
        ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"id": "100010", "zhao_id": "AblationMoonbeam", "currencyVersion": 3},
        }
        response = zhao_upgrade(ctx)
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(response["data"]["reitem_list"], [{"id": "skillUpItem01", "num": 2}])
        self.assertEqual(response["data"]["currencyVersion"], 4)

        archive = store.get_archive(userid)
        self.assertEqual(archive["zhaoBreakData"]["AblationMoonbeam"], "100010")
        self.assertEqual(archive["skillUpItem01"], 3)
        self.assertEqual(store.get_account(userid)["currencies"]["skillUpItem01"], 3)

        # 再突破同一招式: 已是 10 重(最高), errcode=1
        again = zhao_upgrade(dict(ctx, body={"id": "100010", "zhao_id": "AblationMoonbeam"}))
        self.assertEqual(again["errcode"], 1)

        # 余额不足: errcode=2 且不扣减
        poor = zhao_upgrade(dict(ctx, body={"id": "170010", "zhao_id": "AdvantageCowEnemy"}))
        self.assertEqual(poor["errcode"], 2)
        self.assertEqual(store.get_archive(userid)["skillUpItem01"], 3)

        # 未知突破配置 / 缺参数
        unknown = zhao_upgrade(dict(ctx, body={"id": "999999", "zhao_id": "AblationMoonbeam"}))
        self.assertEqual(unknown["errcode"], 1)
        missing = zhao_upgrade(dict(ctx, body={"id": "100010"}))
        self.assertEqual(missing["errcode"], 1)

        # 无存档
        no_archive = zhao_upgrade({
            "state": StateStore(initial={"accounts": {"1": {"userid": 1}}, "archives": {}}, autosave=False),
            "headers": {"userid": "1"},
            "body": {"id": "100010", "zhao_id": "AblationMoonbeam"},
        })
        self.assertEqual(no_archive["errcode"], 404)

    def test_matters_shop_info_returns_goods_and_currency(self):
        userid = 9048162381
        store = StateStore(initial={
            "accounts": {
                str(userid): {
                    "userid": userid,
                    "currencies": {"dmartial": 120, "skillUpItem03": 4},
                    "currency_version": 2,
                }
            },
            "archives": {str(userid): {"name": "角色"}},
        }, autosave=False)
        for shop_type in (1, 2):
            response = matters_shop_info({
                "state": store,
                "headers": {"userid": str(userid)},
                "body": {"type": shop_type, "currencyVersion": 2},
            })
            self.assertEqual(response["errcode"], 0)
            data = response["data"]
            self.assertEqual(data["matters_list"], [{"id": "skillUpItem03", "num": 4}])
            self.assertEqual(len(data["goods_list"]), 24)
            self.assertEqual(data["goods_list"][0],
                             {"key": "skillUpItem01", "id": "skillUpItem01", "num": 1, "price": 20})
            self.assertEqual(data["goods_list"][16]["price"], 80)
            self.assertEqual(data["currency_number"], 120)
            self.assertEqual(data["currency_name"], "功法学识")
            self.assertEqual(data["yuanbao_num"], 0)
            self.assertFalse(data["isRefreshLimit"])
            self.assertEqual(data["currencyVersion"], 2)

        invalid = matters_shop_info({
            "state": store,
            "headers": {},
            "body": {},
        })
        self.assertEqual(invalid["errcode"], 550)

    def test_buy_matters_exchanges_dmartial_for_matters(self):
        userid = 9048162382
        store = StateStore(initial={
            "accounts": {
                str(userid): {
                    "userid": userid,
                    "currencies": {"dmartial": 100, "skillUpItem01": 1},
                    "currency_version": 2,
                }
            },
            "archives": {str(userid): {"name": "角色", "dmartial": 100, "skillUpItem01": 1, "currencyVersion": 2}},
        }, autosave=False)
        ctx = {
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"goodsKey": "skillUpItem01", "currencyVersion": 2},
        }
        response = buy_matters(ctx)
        self.assertEqual(response["errcode"], 0)
        self.assertEqual(response["data"]["reward"], {"id": "skillUpItem01", "num": 1})
        self.assertEqual(response["data"]["currencyVersion"], 3)

        archive = store.get_archive(userid)
        self.assertEqual(archive["dmartial"], 80)      # 100 - 20
        self.assertEqual(archive["skillUpItem01"], 2)  # 1 + 1
        self.assertEqual(store.get_account(userid)["currencies"]["dmartial"], 80)
        self.assertEqual(store.get_account(userid)["currencies"]["skillUpItem01"], 2)

        # 商人列表反映新余额
        shop = matters_shop_info(dict(ctx, body={"type": 1, "currencyVersion": 3}))
        self.assertEqual(shop["data"]["currency_number"], 80)
        self.assertIn({"id": "skillUpItem01", "num": 2}, shop["data"]["matters_list"])

        # 功法学识不足: errcode=2 且不扣减 (80 - 100 < 0, 用 skillUpItem17 price=80 买两次)
        first = buy_matters(dict(ctx, body={"goodsKey": "skillUpItem17", "currencyVersion": 3}))
        self.assertEqual(first["errcode"], 0)
        self.assertEqual(store.get_archive(userid)["dmartial"], 0)
        poor = buy_matters(dict(ctx, body={"goodsKey": "skillUpItem17", "currencyVersion": 4}))
        self.assertEqual(poor["errcode"], 2)
        self.assertEqual(store.get_archive(userid)["dmartial"], 0)
        self.assertEqual(store.get_archive(userid)["skillUpItem17"], 1)

        # 未知商品 / 非法 userid / 无存档
        unknown = buy_matters(dict(ctx, body={"goodsKey": "no_such_item"}))
        self.assertEqual(unknown["errcode"], 1)
        invalid = buy_matters({"state": store, "headers": {}, "body": {}})
        self.assertEqual(invalid["errcode"], 550)
        no_archive = buy_matters({
            "state": StateStore(initial={"accounts": {"1": {"userid": 1}}, "archives": {}}, autosave=False),
            "headers": {"userid": "1"},
            "body": {"goodsKey": "skillUpItem01"},
        })
        self.assertEqual(no_archive["errcode"], 404)

    def test_update_employee_data_give_limits_and_rejects_negative_yinpiao(self):
        userid = 9048162378
        store = StateStore(initial={
            "accounts": {str(userid): {"userid": userid, "currencies": {"yinpiao": 80}}},
            "archives": {str(userid): {"name": "角色", "yinpiao": 0}},
        }, autosave=False)
        ctx = {"state": store, "headers": {"userid": str(userid)}, "body": {}}
        house = get_house_info(ctx)
        self.assertEqual(house["errcode"], 0)
        mid = house["data"]["mid"]
        obj_id = "guanjia1001"
        employee = get_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"objId": obj_id, "mid": mid},
        })
        self.assertEqual(employee["errcode"], 0)
        loyalty = employee["data"]["defaultZhongCheng"]

        first = update_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": obj_id,
                "mid": mid,
                "zc_type": "give",
                "zc_val": 10,
                "currency": 30,
            },
        })
        self.assertEqual(first["errcode"], 0)
        self.assertEqual(first["data"]["defaultZhongCheng"], loyalty + 10)
        self.assertEqual(first["data"]["trait"], {})
        yinpiao = view_currency_by_type({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao"},
        })
        self.assertEqual(yinpiao["data"]["number"], 50)
        self.assertEqual(store.get_account(userid)["currencies"]["yinpiao"], 50)
        self.assertEqual(store.get_archive(userid)["yinpiao"], 50)

        second = update_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": obj_id,
                "mid": mid,
                "zc_type": "give",
                "zc_val": 10,
                "currency": 30,
            },
        })
        self.assertEqual(second["errcode"], 2)
        self.assertEqual(
            get_employee_data({
                "state": store,
                "headers": {"userid": str(userid)},
                "body": {"objId": obj_id, "mid": mid},
            })["data"]["defaultZhongCheng"],
            loyalty + 10,
        )
        self.assertEqual(view_currency_by_type({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao"},
        })["data"]["number"], 50)

        chat = update_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": obj_id,
                "mid": mid,
                "zc_type": "chat",
                "zc_val": 5,
                "currency": 0,
            },
        })
        self.assertEqual(chat["errcode"], 0)
        self.assertEqual(chat["data"]["defaultZhongCheng"], loyalty + 15)
        self.assertEqual(view_currency_by_type({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao"},
        })["data"]["number"], 50)

        servant = add_employee({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": "puren_give_1",
                "mid": mid,
                "npcId": 1,
                "push_data": {"jobType": "puren001", "name": "小四", "defaultZhongCheng": 100},
            },
        })
        self.assertEqual(servant["errcode"], 0)
        overspend = update_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": "puren_give_1",
                "mid": mid,
                "zc_type": "give",
                "zc_val": 20,
                "currency": 999,
            },
        })
        self.assertEqual(overspend["errcode"], 1)
        self.assertEqual(overspend["errmsg"], "银票不足")
        self.assertEqual(view_currency_by_type({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao"},
        })["data"]["number"], 50)
        self.assertGreaterEqual(
            view_currency_by_type({
                "state": store,
                "headers": {"userid": str(userid)},
                "body": {"currency_type": "yinpiao"},
            })["data"]["number"],
            0,
        )
        self.assertEqual(get_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"objId": "puren_give_1", "mid": mid},
        })["data"]["defaultZhongCheng"], 100)

        spend_all = update_employee_data({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {
                "objId": "puren_give_1",
                "mid": mid,
                "zc_type": "give",
                "zc_val": 8,
                "currency": 50,
            },
        })
        self.assertEqual(spend_all["errcode"], 0)
        self.assertEqual(spend_all["data"]["defaultZhongCheng"], 108)
        self.assertEqual(view_currency_by_type({
            "state": store,
            "headers": {"userid": str(userid)},
            "body": {"currency_type": "yinpiao"},
        })["data"]["number"], 0)

    def test_concurrent_account_ids_are_unique(self):
        store = StateStore()
        values = []
        lock = threading.Lock()

        def create():
            value = store.ensure_account()["userid"]
            with lock:
                values.append(value)

        threads = [threading.Thread(target=create) for _ in range(20)]
        for thread in threads:
            thread.start()
        for thread in threads:
            thread.join()
        self.assertEqual(len(values), len(set(values)))


if __name__ == "__main__":
    unittest.main()
