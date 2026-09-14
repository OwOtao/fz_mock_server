# -*- coding: utf-8 -*-
"""端到端验证: 活动充值积分兑换 get_shop_info / shop_exchange_goods。

1. 活动入口: get_spring_festival_list 含"充值积分兑换", get_spring_festival_status/19 开放。
2. get_shop_info 响应与抓包 098 逐字段一致(total_points 除外, 为用户实时积分)。
3. 积分发放(邮件 chongzhijifen)后 total_points 正确显示。
4. shop_exchange_goods: 兑换扣积分、幂等重放、限购、积分不足。
"""


# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import json
import sys
import time

import config
config.HOST = "127.0.0.1"  # 0.0.0.0 在 Windows 上不能作为连接目标

from test_client import req  # noqa: E402


def main():
    with open(r"so\har_decrypt_91\entries\098_get_shop_info.json", encoding="utf-8") as f:
        captured = json.loads(json.load(f)["response_plain"])["data"]

    print("== 1. 活动入口 ==")
    listing = req("get_spring_festival_list", None, force_method="GET",
                  headers={"userid": "1000000002"})
    names = [action["name"] for action in listing["data"]]
    assert "充值积分兑换" in names, names
    action = next(a for a in listing["data"] if a["name"] == "充值积分兑换")
    assert action["id"] == 19 and action["is_open"] == 1 and action["status"] == 1

    state = req("get_spring_festival_status/19", None, force_method="GET",
                headers={"userid": "1000000002"})
    assert state["data"]["is_open"] == 1 and state["data"]["status"] == 1
    assert state["data"]["end"] > int(time.time())
    print("  活动入口与状态 OK (id=19, is_open=1)")

    print("== 2. get_shop_info vs 抓包 ==")
    payload = req("get_shop_info", {"shop_id": "zhounianqin_cz"},
                  headers={"userid": "1000000002"})
    data = payload["data"]
    assert data["shop_info"] == captured["shop_info"], "shop_info 与抓包不一致"
    assert data["isDis"] == captured["isDis"]
    assert data["disInfo"] == captured["disInfo"]
    shop_info = data["shop_info"]
    print("  shop_id=%s 分类=%s" % (
        shop_info["shop_id"],
        {k: len(v) for k, v in shop_info["goods"].items()}))
    print("  total_points =", data["total_points"])

    print("== 3. 积分发放 -> total_points ==")
    granted = req("admin_send_email", {
        "request_id": "verify-shop-points-e2e",
        "userid": 1000000002,
        "title": "充值积分",
        "content": "领取附件",
        "sender": "验证脚本",
        "expire_days": 1,
        "rewards": {"new_currencys": [{"id": "chongzhijifen", "num": 5000}]},
    }, headers={"userid": "1000000002"})
    claimed = req("get_email_reward",
                  {"id": granted["data"]["mail_id"], "dataVer": 1, "currencyVersion": 1,
                   "retrievables": ["new_currencys-1"]},
                  headers={"userid": "1000000002"})
    assert claimed["errcode"] == 0, claimed

    payload = req("get_shop_info", {"shop_id": "zhounianqin_cz"},
                  headers={"userid": "1000000002"})
    points = payload["data"]["total_points"]
    assert points >= 5000, points
    print("  total_points =", points)

    missing = req("get_shop_info", {"shop_id": "no_such_shop"},
                  headers={"userid": "1000000002"}, expect_errcode=404)
    print("  unknown shop rejected:", missing["errmsg"])

    print("== 4. shop_exchange_goods 兑换 ==")
    # xinggongsan: price=50, times=30 -> 买 3 个花 150
    exchange = req("shop_exchange_goods", {
        "itemId": "xinggongsan",
        "client_trans_id": "e2e-exchange-1",
        "shop_id": "zhounianqin_cz",
        "number": 3,
        "dataVer": 1,
        "currencyVersion": 1,
    }, headers={"userid": "1000000002"})
    assert exchange["errcode"] == 0, exchange
    assert exchange["data"]["reward"] == {
        "itemId": "xinggongsan", "number": 3, "itype": 1, "name": "行功散"}, exchange
    assert exchange["data"]["romove_point"] == 150
    remaining = exchange["data"]["total_points"]
    print("  reward =", exchange["data"]["reward"],
          "romove_point =", exchange["data"]["romove_point"],
          "total_points =", remaining)

    # 幂等重放: 重复请求不重复扣分
    replay = req("shop_exchange_goods", {
        "itemId": "xinggongsan",
        "client_trans_id": "e2e-exchange-1",
        "shop_id": "zhounianqin_cz",
        "number": 3,
    }, headers={"userid": "1000000002"})
    assert replay["data"]["total_points"] == remaining, replay

    # 商店余额同步
    payload = req("get_shop_info", {"shop_id": "zhounianqin_cz"},
                  headers={"userid": "1000000002"})
    assert payload["data"]["total_points"] == remaining

    # 限购: xinbawangqiangfa times=1 -> 第二次被拒
    skill = req("shop_exchange_goods", {
        "itemId": "xinbawangqiangfa",
        "client_trans_id": "e2e-exchange-2",
        "shop_id": "zhounianqin_cz",
        "number": 1,
    }, headers={"userid": "1000000002"})
    assert skill["errcode"] == 0, skill
    print("  skill reward =", skill["data"]["reward"],
          "total_points =", skill["data"]["total_points"])
    again = req("shop_exchange_goods", {
        "itemId": "xinbawangqiangfa",
        "client_trans_id": "e2e-exchange-3",
        "shop_id": "zhounianqin_cz",
        "number": 1,
    }, headers={"userid": "1000000002"}, expect_errcode=1)
    print("  limit rejected:", again["errmsg"])

    # 积分不足
    poor = req("shop_exchange_goods", {
        "itemId": "mianju1029",
        "client_trans_id": "e2e-exchange-4",
        "shop_id": "zhounianqin_cz",
        "number": 1,
    }, headers={"userid": "1000000002"}, expect_errcode=1)
    print("  insufficient points rejected:", poor["errmsg"])

    print("ALL OK")


if __name__ == "__main__":
    sys.exit(main())
