# -*- coding: utf-8 -*-
"""端到端验证: 续卷相关接口 get_zhao_upgrade_matters / zhao_upgrade / matters_shop_info / buy_matters。

场景:
  1. 现有玩家账号(userid=1000000002)只读查询 -> errcode=0, matters_list 为列表。
  2. 测试账号: admin_send_email 发放续卷 -> get_email_reward 领取 -> 查询 matters_list。
  3. zhao_upgrade: 消耗 skillUpItem01 x2 突破招式到 10 重, 再次突破被拒绝。
  4. matters_shop_info: type 1/2 均返回 goods_list 与功法学识余额。
  5. buy_matters: 功法学识兑换续卷, 余额不足 errcode=2。
"""

import sys
import time

import config
config.HOST = "127.0.0.1"  # 0.0.0.0 在 Windows 上不能作为连接目标

from test_client import req  # noqa: E402


def _matter_num(matters, item_id):
    for item in matters:
        if item["id"] == item_id:
            return item["num"]
    return 0


def main():
    print("== 1. 只读查询现有玩家 ==")
    payload = req("get_zhao_upgrade_matters", {"currencyVersion": 6},
                  headers={"userid": "1000000002"})
    matters = payload["data"]["matters_list"]
    assert isinstance(matters, list), "matters_list 不是列表: %r" % matters
    for item in matters:
        assert isinstance(item.get("id"), str) and item["id"].startswith("skillUpItem")
        assert isinstance(item.get("num"), int) and item["num"] > 0
    print("  matters_list =", matters)

    print("== 2. 测试账号: 邮件发放续卷 -> 领取 -> 查询 ==")
    # 每次运行使用新账号, 保证脚本可重复执行(邮件 request_id 与招式重数全局持久)
    test_userid = 9100000000 + int(time.time()) % 900000000
    created = req("create_account", {"userid": test_userid},
                  headers={"userid": str(test_userid)})
    assert created["errcode"] == 0, created
    sent = req("admin_send_email", {
        "request_id": "verify-zhao-matters-e2e-%d" % test_userid,
        "userid": test_userid,
        "title": "续卷测试",
        "content": "领取附件",
        "sender": "验证脚本",
        "expire_days": 1,
        "rewards": {
            "new_currencys": [
                {"id": "skillUpItem01", "num": 3},
                {"id": "skillUpItem16", "num": 12},
            ],
        },
    }, headers={"userid": str(test_userid)})
    mail_id = sent["data"]["mail_id"]
    print("  mail_id =", mail_id)

    claimed = req("get_email_reward",
                  {"id": mail_id, "dataVer": 1, "currencyVersion": 1,
                   "retrievables": ["new_currencys-1", "new_currencys-2"]},
                  headers={"userid": str(test_userid)})
    assert claimed["errcode"] == 0, claimed

    payload = req("get_zhao_upgrade_matters", {"currencyVersion": 2},
                  headers={"userid": str(test_userid)})
    matters = payload["data"]["matters_list"]
    print("  matters_list =", matters)
    assert {"id": "skillUpItem01", "num": 3} in matters, matters
    assert {"id": "skillUpItem16", "num": 12} in matters, matters

    print("== 3. zhao_upgrade: 招式突破 ==")
    before = _matter_num(matters, "skillUpItem01")
    granted = req("admin_send_email", {
        "request_id": "verify-zhao-upgrade-e2e-%d" % test_userid,
        "userid": test_userid,
        "title": "突破材料",
        "content": "领取附件",
        "sender": "验证脚本",
        "expire_days": 1,
        "rewards": {"new_currencys": [{"id": "skillUpItem01", "num": 2}]},
    }, headers={"userid": str(test_userid)})
    mail_id = granted["data"]["mail_id"]
    claimed = req("get_email_reward",
                  {"id": mail_id, "dataVer": 1, "currencyVersion": 1,
                   "retrievables": ["new_currencys-1"]},
                  headers={"userid": str(test_userid)})
    assert claimed["errcode"] == 0, claimed
    before = before + 2

    zhao_id = "AblationMoonbeam"
    payload = req("zhao_upgrade",
                  {"id": "100010", "zhao_id": zhao_id, "currencyVersion": 2},
                  headers={"userid": str(test_userid)})
    assert payload["errcode"] == 0, payload
    assert payload["data"]["reitem_list"] == [{"id": "skillUpItem01", "num": 2}], payload
    currency_version = payload["data"]["currencyVersion"]
    print("  reitem_list =", payload["data"]["reitem_list"],
          "currencyVersion =", currency_version)
    assert currency_version >= 2

    payload = req("get_zhao_upgrade_matters", {"currencyVersion": currency_version},
                  headers={"userid": str(test_userid)})
    after = _matter_num(payload["data"]["matters_list"], "skillUpItem01")
    assert after == before - 2, (before, after)
    print("  skillUpItem01 %d -> %d" % (before, after))

    # 已是 10 重(最高), 重复突破被拒绝
    rejected = req("zhao_upgrade",
                   {"id": "100010", "zhao_id": zhao_id, "currencyVersion": currency_version},
                   headers={"userid": str(test_userid)},
                   expect_errcode=1)
    print("  repeat upgrade rejected:", rejected["errmsg"])

    # 材料不足 (skillUpItem08 为 0, 170010 需要 x2)
    poor = req("zhao_upgrade",
               {"id": "170010", "zhao_id": "AdvantageCowEnemy", "currencyVersion": currency_version},
               headers={"userid": str(test_userid)},
               expect_errcode=2)
    print("  insufficient matters rejected:", poor["errmsg"])

    print("== 4. matters_shop_info: 续卷商人 ==")
    for shop_type in (1, 2):
        payload = req("matters_shop_info",
                      {"type": shop_type, "currencyVersion": currency_version},
                      headers={"userid": str(test_userid)})
        data = payload["data"]
        assert len(data["goods_list"]) == 24, len(data["goods_list"])
        assert data["goods_list"][0]["id"] == "skillUpItem01"
        assert data["currency_name"] == "功法学识"
        assert data["yuanbao_num"] == 0 and not data["isRefreshLimit"]
        assert _matter_num(data["matters_list"], "skillUpItem01") == after
        print("  type=%d goods=%d currency_number=%d" %
              (shop_type, len(data["goods_list"]), data["currency_number"]))

    print("== 5. buy_matters: 功法学识兑换续卷 ==")
    granted = req("admin_send_email", {
        "request_id": "verify-buy-matters-e2e-%d" % test_userid,
        "userid": test_userid,
        "title": "功法学识",
        "content": "领取附件",
        "sender": "验证脚本",
        "expire_days": 1,
        "rewards": {"new_currencys": [{"id": "dmartial", "num": 100}]},
    }, headers={"userid": str(test_userid)})
    claimed = req("get_email_reward",
                  {"id": granted["data"]["mail_id"], "dataVer": 1, "currencyVersion": currency_version,
                   "retrievables": ["new_currencys-1"]},
                  headers={"userid": str(test_userid)})
    assert claimed["errcode"] == 0, claimed

    payload = req("buy_matters",
                  {"goodsKey": "skillUpItem02", "currencyVersion": currency_version},
                  headers={"userid": str(test_userid)})
    assert payload["errcode"] == 0, payload
    assert payload["data"]["reward"] == {"id": "skillUpItem02", "num": 1}, payload
    currency_version = payload["data"]["currencyVersion"]
    print("  reward =", payload["data"]["reward"], "currencyVersion =", currency_version)

    payload = req("buy_matters",
                  {"goodsKey": "skillUpItem17", "currencyVersion": currency_version},
                  headers={"userid": str(test_userid)})
    assert payload["errcode"] == 0, payload
    currency_version = payload["data"]["currencyVersion"]

    # 商人界面应显示: 功法学识 100-20-80=0, 新增 skillUpItem02/17 各 1
    payload = req("matters_shop_info",
                  {"type": 1, "currencyVersion": currency_version},
                  headers={"userid": str(test_userid)})
    data = payload["data"]
    assert data["currency_number"] == 0, data["currency_number"]
    assert _matter_num(data["matters_list"], "skillUpItem02") == 1
    assert _matter_num(data["matters_list"], "skillUpItem17") == 1
    print("  currency_number =", data["currency_number"],
          "skillUpItem02/17 = 1/1")

    # 功法学识耗尽 -> errcode=2
    poor = req("buy_matters",
               {"goodsKey": "skillUpItem01", "currencyVersion": currency_version},
               headers={"userid": str(test_userid)},
               expect_errcode=2)
    print("  insufficient dmartial rejected:", poor["errmsg"])

    print("ALL OK")


if __name__ == "__main__":
    sys.exit(main())
