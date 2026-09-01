# -*- coding: utf-8 -*-
"""端到端验证: 师门建树 get_teacherFeat_info / get_teacherFeat_reward。

场景(问情宫 gumu, camp=3):
  1. 新号建树列表: 24 项日积月累(state 0) + 千里之任 100003(state 1, 从未离开师门),
     不含 camp1/camp2 称号; featscount=0。
  2. 领取 100003: 称号商品 600002x1, featscount 1, dataVer 递增。
  3. 重复领取被拒(errcode 2); 领取未达成建树被拒(errcode 3); 未知 featId 被拒。
  4. test_sect_build_action 注入昌盛度 200 -> 10000(state 1)/10001(state 0);
     领取 10000 -> +35 名绩点。
  5. 注入资历 1300 -> 12000 可领取; 领取后 +18。
  6. 缺 userid 被拒。
"""

import sys
import time

import config
config.HOST = "127.0.0.1"  # 0.0.0.0 在 Windows 上不能作为连接目标

from test_client import req  # noqa: E402

FAMILY = "gumu"  # 问情宫 camp=3


def _info(headers):
    return req("get_teacherFeat_info", {"familyId": FAMILY}, headers=headers)["data"]


def _states(data):
    return {item["id"]: item["state"] for item in data["list"]}


def main():
    userid = 9700000000 + int(time.time()) % 200000000
    headers = {"userid": str(userid)}
    created = req("create_account", {"userid": userid}, headers=headers)
    assert created["errcode"] == 0, created

    print("== 1. 新号建树列表 ==")
    data = _info(headers)
    states = _states(data)
    print("  feats =", len(data["list"]), "featscount =", data["featscount"])
    print("  state1 =", [k for k, v in states.items() if v == 1])
    assert len(data["list"]) == 25, len(data["list"])
    assert data["featscount"] == 0
    assert states["100003"] == 1, states
    assert "100001" not in states and "100002" not in states
    assert all(states[f] == 0 for f in
               ("10000", "10005", "11000", "12000", "13000")), states

    print("== 2. 领取千里之任称号 100003 ==")
    payload = req("get_teacherFeat_reward",
                  {"familyId": FAMILY, "featId": "100003", "dataVer": 1},
                  headers=headers)
    data = payload["data"]
    print("  data =", data)
    assert data["featscount"] == 1, data
    assert data["reward"] == [{"id": "600002", "num": 1}], data
    assert data["dataVer"] >= 2, data
    assert "义薄云天" in data["msg"], data

    info = _info(headers)
    assert _states(info)["100003"] == 2, info
    assert info["featscount"] == 1

    print("== 3. 重复领取 / 条件未达成 / 未知 featId ==")
    rejected = req("get_teacherFeat_reward",
                   {"familyId": FAMILY, "featId": "100003", "dataVer": data["dataVer"]},
                   headers=headers, expect_errcode=2)
    print("  claimed rejected:", rejected["errmsg"])
    rejected = req("get_teacherFeat_reward",
                   {"familyId": FAMILY, "featId": "10000", "dataVer": data["dataVer"]},
                   headers=headers, expect_errcode=3)
    print("  not met rejected:", rejected["errmsg"])
    rejected = req("get_teacherFeat_reward",
                   {"familyId": FAMILY, "featId": "999999", "dataVer": 1},
                   headers=headers, expect_errcode=1)
    print("  unknown feat rejected:", rejected["errmsg"])

    print("== 4. 注入昌盛度 200 -> 领取 10000 ==")
    req("test_sect_build_action",
        {"type": 1, "number": 200, "familyId": FAMILY}, headers=headers)
    states = _states(_info(headers))
    assert states["10000"] == 1 and states["10001"] == 0, states
    payload = req("get_teacherFeat_reward",
                  {"familyId": FAMILY, "featId": "10000", "dataVer": 1},
                  headers=headers)
    data = payload["data"]
    print("  10000 ->", data["reward"], "featscount =", data["featscount"])
    assert data["featscount"] == 36, data
    assert data["reward"] == [{"id": "400030", "num": 35}], data

    print("== 5. 注入资历 1300 -> 领取 12000 ==")
    req("test_sect_build_action",
        {"type": 3, "number": 1300, "familyId": FAMILY}, headers=headers)
    states = _states(_info(headers))
    assert states["12000"] == 1 and states["12001"] == 0, states
    payload = req("get_teacherFeat_reward",
                  {"familyId": FAMILY, "featId": "12000", "dataVer": 1},
                  headers=headers)
    assert payload["data"]["featscount"] == 54, payload["data"]
    print("  12000 -> featscount =", payload["data"]["featscount"])

    print("== 6. 缺 userid 被拒 ==")
    rejected = req("get_teacherFeat_info", {"familyId": FAMILY}, expect_errcode=552)
    print("  missing userid rejected:", rejected["errmsg"])

    print("ALL OK")


if __name__ == "__main__":
    sys.exit(main())
