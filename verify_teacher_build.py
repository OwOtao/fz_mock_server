# -*- coding: utf-8 -*-
"""端到端验证: 师门日常任务 get_teacherBuild_tasks 与师门建筑兴建 build_teacherBuild。

场景:
  1. 正派(camp=1, 官府)获取任务列表: errcode=0, list 非空且全部为 3x/23 前缀任务,
     state=1(解锁), taskNumDay/taskNumLimit 为数值。
  2. 散人(camp=0, youxia)任务列表: 全部为 1x/20 前缀任务。
  3. 邪派/中立门派各校验一次前缀(4x/24, 5x/25)。
  4. build_teacherBuild 兴建建筑 100: errcode=0, buildList 中该建筑 state=1。
  5. 再兴建建筑 101: 建筑 100 复位 state=0, 101 为 1(与客户端 setBuildIngState 对齐)。
  6. 未知 buildTypeId -> errcode=1; 缺 userid -> errcode=552。
"""

import sys
import time

import config
config.HOST = "127.0.0.1"  # 0.0.0.0 在 Windows 上不能作为连接目标

from test_client import req  # noqa: E402


def _task_list(family_id, headers):
    payload = req("get_teacherBuild_tasks", {"familyId": family_id}, headers=headers)
    data = payload["data"]
    assert isinstance(data["taskNumDay"], int), data
    assert isinstance(data["taskNumLimit"], int) and data["taskNumLimit"] > 0, data
    task_list = data["list"]
    assert isinstance(task_list, list) and task_list, data
    for item in task_list:
        assert set(item) == {"taskId", "state", "cdTime"}, item
        assert item["state"] in (0, 1, 2), item
        assert isinstance(item["taskId"], str) and item["taskId"].isdigit(), item
    return data


def main():
    test_userid = 9300000000 + int(time.time()) % 700000000
    headers = {"userid": str(test_userid)}
    created = req("create_account", {"userid": test_userid}, headers=headers)
    assert created["errcode"] == 0, created

    print("== 1. 正派(官府 camp=1) 师门日常任务 ==")
    data = _task_list("guanfu", headers)
    ids = [item["taskId"] for item in data["list"]]
    print("  tasks =", len(ids), "first =", ids[:4],
          "taskNumDay/Limit = %s/%s" % (data["taskNumDay"], data["taskNumLimit"]))
    assert all(i[:2] in ("23", "31", "32", "33") for i in ids), ids[:10]
    assert all(item["state"] == 1 for item in data["list"])

    print("== 2. 散人(youxia camp=0) 任务 ==")
    data = _task_list("youxia", headers)
    ids = [item["taskId"] for item in data["list"]]
    print("  tasks =", len(ids), "first =", ids[:4])
    assert all(i[:2] in ("10", "11", "12", "13", "20") for i in ids), ids[:10]

    print("== 3. 邪派(万灵谷 camp=2) / 中立(永夜楼 camp=3) ==")
    ids2 = [item["taskId"] for item in _task_list("wudu", headers)["list"]]
    ids3 = [item["taskId"] for item in _task_list("yongyelou", headers)["list"]]
    print("  camp2 tasks =", len(ids2), "camp3 tasks =", len(ids3))
    assert all(i[:2] in ("24", "41", "42", "43") for i in ids2), ids2[:10]
    assert all(i[:2] in ("25", "51", "52", "53") for i in ids3), ids3[:10]

    print("== 4. build_teacherBuild 兴建建筑 100(勤务阁) ==")
    payload = req("build_teacherBuild", {"buildTypeId": "100", "familyId": "guanfu"},
                  headers=headers)
    assert payload["errcode"] == 0, payload
    print("  data =", payload["data"])

    listed = req("get_teacherBuild_list", {"familyId": "guanfu"}, headers=headers)
    build_list = listed["data"]
    states = {str(b["buildTypeId"]): b["state"] for b in build_list}
    print("  buildList states =", states)
    assert states.get("100") == 1, states

    print("== 5. 改建建筑 101(储宝库) -> 100 复位 ==")
    payload = req("build_teacherBuild", {"buildTypeId": "101", "familyId": "guanfu"},
                  headers=headers)
    assert payload["errcode"] == 0, payload
    listed = req("get_teacherBuild_list", {"familyId": "guanfu"}, headers=headers)
    states = {str(b["buildTypeId"]): b["state"] for b in listed["data"]}
    print("  buildList states =", states)
    assert states.get("101") == 1 and states.get("100") == 0, states

    print("== 6. 非法参数 ==")
    rejected = req("build_teacherBuild", {"buildTypeId": "999", "familyId": "guanfu"},
                   headers=headers, expect_errcode=1)
    print("  unknown building rejected:", rejected["errmsg"])
    rejected = req("build_teacherBuild", {"familyId": "guanfu"},
                   headers=headers, expect_errcode=1)
    print("  missing buildTypeId rejected:", rejected["errmsg"])
    rejected = req("get_teacherBuild_tasks", {"familyId": "guanfu"},
                   expect_errcode=552)
    print("  missing userid rejected:", rejected["errmsg"])

    print("ALL OK")


if __name__ == "__main__":
    sys.exit(main())
