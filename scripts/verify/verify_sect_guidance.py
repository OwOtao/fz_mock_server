# -*- coding: utf-8 -*-
"""端到端验证: 师门指点 get_sectGuidance_info / execute_sectGuidance。

场景:
  1. 获取指点信息: 新账号本周 2 次, speedUpTime 3600。
  2. 连续指点 2 次: 次数递减, version 递增(客户端语义: finishTime -= speedUpTime)。
  3. 第 3 次被拒(次数耗尽, 客户端触发回档返还逻辑时同样收到该错误)。
  4. test_reset_sect_guidance(GET) 重置后次数恢复。
  5. 缺 userid 被拒。
"""


# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import sys
import time

import config
config.HOST = "127.0.0.1"  # 0.0.0.0 在 Windows 上不能作为连接目标

from test_client import req  # noqa: E402

FAMILY = "gumu"  # 问情宫


def main():
    userid = 9600000000 + int(time.time()) % 300000000
    headers = {"userid": str(userid)}
    created = req("create_account", {"userid": userid}, headers=headers)
    assert created["errcode"] == 0, created

    print("== 1. 获取指点信息 ==")
    payload = req("get_sectGuidance_info", {"familyId": FAMILY}, headers=headers)
    data = payload["data"]
    print("  data =", data)
    assert data == {"guidanceCount": 2, "speedUpTime": 3600}, data

    print("== 2. 指点 x2(模拟破境加速) ==")
    version = 0
    for i in (1, 2):
        payload = req("execute_sectGuidance",
                      {"familyId": FAMILY, "id": "hiddenMeridianChart01", "version": version},
                      headers=headers)
        data = payload["data"]
        version = data["version"]
        print("  #%d -> %s" % (i, data))
        assert data["guidanceCount"] == 2 - i, data
        assert data["speedUpTime"] == 3600, data
        assert data["version"] == i, data

    info = req("get_sectGuidance_info", {"familyId": FAMILY}, headers=headers)["data"]
    assert info["guidanceCount"] == 0, info

    print("== 3. 次数耗尽被拒 ==")
    rejected = req("execute_sectGuidance",
                   {"familyId": FAMILY, "id": "hiddenMeridianChart01", "version": version},
                   headers=headers, expect_errcode=1)
    print("  exhausted rejected:", rejected["errmsg"])

    print("== 4. 测试接口重置次数(GET) ==")
    payload = req("test_reset_sect_guidance", None, force_method="GET", headers=headers)
    assert payload["data"]["guidanceCount"] == 2, payload
    info = req("get_sectGuidance_info", {"familyId": FAMILY}, headers=headers)["data"]
    print("  after reset:", info)
    assert info["guidanceCount"] == 2, info
    payload = req("execute_sectGuidance",
                  {"familyId": FAMILY, "id": "acupoint01", "version": version},
                  headers=headers)
    assert payload["data"]["guidanceCount"] == 1, payload

    print("== 5. 缺 userid 被拒 ==")
    rejected = req("get_sectGuidance_info", {"familyId": FAMILY}, expect_errcode=552)
    print("  missing userid rejected:", rejected["errmsg"])

    print("ALL OK")


if __name__ == "__main__":
    sys.exit(main())
