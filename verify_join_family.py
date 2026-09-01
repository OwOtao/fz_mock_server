# -*- coding: utf-8 -*-
"""端到端验证: 拜师接口 join_family (含隐藏门派)。

场景:
  1. 测试账号上传散人存档 -> join_family 拜入隐藏门派(永夜楼) ->
     errcode=0, currencyVersion 递增, 存档 family.name 同步镜像。
  2. 同门派重复 join_family -> 辈分保留。
  3. 换门派(模拟叛师归隐后再拜) -> family 切换且辈分回到第1代。
  4. 老存档门派id xiaoyao -> 映射为 tianshan。
  5. 未知/缺失 familyId -> errcode=1; 缺 userid 头 -> errcode=552。
"""

import sys
import time

import config
config.HOST = "127.0.0.1"  # 0.0.0.0 在 Windows 上不能作为连接目标

from test_client import req  # noqa: E402


def _family_of(userid):
    payload = req("download_user_file_2", headers={"userid": str(userid)})
    role = payload["data"][0]
    return role.get("family"), role.get("isSeclusion")


def main():
    test_userid = 9200000000 + int(time.time()) % 800000000
    created = req("create_account", {"userid": test_userid},
                  headers={"userid": str(test_userid)})
    assert created["errcode"] == 0, created

    print("== 1. 上传散人存档后拜入隐藏门派(永夜楼) ==")
    uploaded = {
        "userid": test_userid,
        "name": "拜师测试",
        "exp": 100,
        "family": {"name": "youxia", "level": 1},
        "isSeclusion": 1,
        "currencyVersion": 3,
    }
    p = req("upload_user_file_3/Account/3", [uploaded, {"loginCount": 1}],
            headers={"userid": str(test_userid)})
    assert p["errcode"] == 0, p

    p = req("join_family", {"familyId": "yongyelou", "currencyVersion": 3},
            headers={"userid": str(test_userid)})
    assert p["errcode"] == 0, p
    data = p["data"]
    print("  data =", data)
    assert data["familyId"] == "yongyelou"
    assert data["currencyVersion"] >= 4, data
    version1 = data["currencyVersion"]

    family, seclusion = _family_of(test_userid)
    print("  archive family =", family, "isSeclusion =", seclusion)
    assert family == {"name": "yongyelou", "level": 1}, family
    assert seclusion is None, seclusion

    print("== 2. 同门派重复 join_family(辈分保留) ==")
    uploaded["family"] = {"name": "yongyelou", "level": 4}
    req("upload_user_file_3/Account/3", [uploaded, {"loginCount": 1}],
        headers={"userid": str(test_userid)})
    p = req("join_family", {"familyId": "yongyelou", "currencyVersion": version1},
            headers={"userid": str(test_userid)})
    assert p["errcode"] == 0, p
    version2 = p["data"]["currencyVersion"]
    assert version2 > version1, (version1, version2)
    family, _ = _family_of(test_userid)
    print("  archive family =", family)
    assert family == {"name": "yongyelou", "level": 4}, family

    print("== 3. 换门派(归隐后再拜 -> 辈分回到第1代) ==")
    p = req("join_family", {"familyId": "youming", "currencyVersion": version2},
            headers={"userid": str(test_userid)})
    assert p["errcode"] == 0, p
    family, _ = _family_of(test_userid)
    print("  archive family =", family)
    assert family == {"name": "youming", "level": 1}, family

    print("== 4. 老存档门派id 映射(xiaoyao -> tianshan) ==")
    p = req("join_family", {"familyId": "xiaoyao", "currencyVersion": version2},
            headers={"userid": str(test_userid)})
    assert p["errcode"] == 0, p
    assert p["data"]["familyId"] == "tianshan", p["data"]
    family, _ = _family_of(test_userid)
    assert family["name"] == "tianshan", family

    print("== 5. 非法参数 ==")
    rejected = req("join_family", {"familyId": "not_a_family", "currencyVersion": 1},
                   headers={"userid": str(test_userid)}, expect_errcode=1)
    print("  unknown family rejected:", rejected["errmsg"])
    rejected = req("join_family", {"currencyVersion": 1},
                   headers={"userid": str(test_userid)}, expect_errcode=1)
    print("  missing familyId rejected:", rejected["errmsg"])
    rejected = req("join_family", {"familyId": "yongyelou", "currencyVersion": 1},
                   expect_errcode=552)
    print("  missing userid rejected:", rejected["errmsg"])

    print("ALL OK")


if __name__ == "__main__":
    sys.exit(main())
