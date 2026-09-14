# -*- coding: utf-8 -*-
"""端到端验证: 师门日常任务流转(start/stop/speedUp/finish) + 建筑捐献/名位升级。

账号A(任务流): 开始/重复开始/未完成即领/加速不足/终止/加速/完成/每日次数上限。
账号B(捐献流): 邮件发放楠木 -> 3次昌盛度任务(sgbpoint 14) -> 捐献恩义祠(b102)5+1次
  -> 修筑度/资历/佳绩累积 -> 名位升级成功 -> 重复升级被拒。
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

FAMILY = "gumu"  # 问情宫 camp=3, 任务前缀 52/53/25


def _info(headers):
    return req("get_teacherBuild_info", {"familyId": FAMILY}, headers=headers)["data"]


def _start(headers, task_id, expect_errcode=0):
    return req("start_teacherBuild_task", {"taskId": task_id, "familyId": FAMILY},
               headers=headers, expect_errcode=expect_errcode)


def _speed_up(headers, task_id, cost, expect_errcode=0):
    return req("speedUp_teacherBuild_task",
               {"taskId": task_id, "cost": cost, "familyId": FAMILY},
               headers=headers, expect_errcode=expect_errcode)


def _finish(headers, task_id, expect_errcode=0):
    return req("finish_teacherBuild_task", {"taskId": task_id, "familyId": FAMILY},
               headers=headers, expect_errcode=expect_errcode)


def _new_account(tag):
    userid = 9400000000 + (int(time.time()) % 500000000) + tag
    headers = {"userid": str(userid)}
    created = req("create_account", {"userid": userid}, headers=headers)
    assert created["errcode"] == 0, created
    return userid, headers


def main():
    print("== A1. 账号A: 勤建之志种子 / 任务开始 ==")
    _userid, headers = _new_account(0)
    data = _info(headers)
    print("  diligent = %s/%s taskNumDay/Limit = %s/%s" %
          (data["diligent"], data["diligentLimit"],
           data["taskNumDay"], data["taskNumLimit"]))
    assert data["diligent"] == 100 and data["diligentLimit"] == 9999, data
    assert data["guajiInfo"] == {}, data

    payload = _start(headers, "520001")
    start_time = payload["data"]["startTime"]
    print("  startTime =", start_time)

    print("== A2. 重复开始 / 未知任务 / 未完成即领 / 加速不足 ==")
    rejected = _start(headers, "520001", expect_errcode=2)
    print("  duplicate start rejected:", rejected["errmsg"])
    rejected = _start(headers, "999999", expect_errcode=1)
    print("  unknown task rejected:", rejected["errmsg"])
    rejected = _finish(headers, "520001", expect_errcode=2)
    print("  premature finish rejected:", rejected["errmsg"])
    rejected = _speed_up(headers, "520001", 200, expect_errcode=2)
    print("  insufficient diligent rejected:", rejected["errmsg"])

    print("== A3. 终止日常 ==")
    req("stop_teacherBuild_task", {"taskId": "520001", "familyId": FAMILY}, headers=headers)
    assert _info(headers)["guajiInfo"] == {}
    rejected = req("stop_teacherBuild_task", {"taskId": "520001", "familyId": FAMILY},
                   headers=headers, expect_errcode=1)
    print("  double stop rejected:", rejected["errmsg"])

    print("== A4. 加速并完成(520001 1小时=12点) ==")
    _start(headers, "520001")
    payload = _speed_up(headers, "520001", 12)
    assert payload["data"] == {"cost": 12, "speedUpTime": 3600}, payload
    payload = _finish(headers, "520001")
    data = payload["data"]
    print("  finish:", data["taskNumDay"], data["sgbpoint"], data["reward"])
    assert data["taskNumDay"] == 1 and data["sgbpoint"] == 1, data
    assert data["reward"] == [["sgbpoint", 1]], data
    assert _info(headers)["diligent"] == 88

    print("== A5. 分段加速(520002 2小时: 5+19点) ==")
    _start(headers, "520002")
    _speed_up(headers, "520002", 5)
    _finish(headers, "520002", expect_errcode=2)
    _speed_up(headers, "520002", 19)
    payload = _finish(headers, "520002")
    assert payload["data"]["taskNumDay"] == 2, payload
    assert payload["data"]["sgbpoint"] == 3, payload

    print("== A6. 第三次完成(520003)后触发每日上限 ==")
    _start(headers, "520003")
    _speed_up(headers, "520003", 24)
    payload = _finish(headers, "520003")
    assert payload["data"]["taskNumDay"] == 3, payload
    tasks = req("get_teacherBuild_tasks", {"familyId": FAMILY}, headers=headers)["data"]
    print("  taskNumDay/Limit = %s/%s" % (tasks["taskNumDay"], tasks["taskNumLimit"]))
    assert tasks["taskNumDay"] == 3 and tasks["taskNumLimit"] == 3
    rejected = _start(headers, "520001", expect_errcode=3)
    print("  daily limit rejected:", rejected["errmsg"])

    print("== A7. 标记接口 ==")
    payload = req("updata_teacherBuild_flag",
                  {"addFlags": ["sign100", "sign1001"], "deleteFlags": [], "familyId": FAMILY},
                  headers=headers)
    assert payload["errcode"] == 0, payload

    print("== B1. 账号B: 邮件发放楠木 -> 材料信息 ==")
    b_userid, b_headers = _new_account(1000)
    sent = req("admin_send_email", {
        "request_id": "verify-teacherbuild-donate-%d" % b_userid,
        "userid": b_userid,
        "title": "捐献材料",
        "content": "领取附件",
        "sender": "验证脚本",
        "expire_days": 1,
        "rewards": {"new_currencys": [{"id": "bmaterials3", "num": 60}]},
    }, headers=b_headers)
    mail_id = sent["data"]["mail_id"]
    claimed = req("get_email_reward",
                  {"id": mail_id, "dataVer": 1, "currencyVersion": 1,
                   "retrievables": ["new_currencys-1"]},
                  headers=b_headers)
    assert claimed["errcode"] == 0, claimed
    items = req("get_teacherBuild_items", {"familyId": FAMILY}, headers=b_headers)["data"]
    print("  items =", items)
    assert {"itemId": "bmaterials3", "count": 60, "countLimit": 300} in items, items

    print("== B2. 3次昌盛度任务(sgbpoint 5+5+4=14) ==")
    for task_id, cost in (("520004", 36), ("520004", 36), ("520003", 24)):
        _start(b_headers, task_id)
        _speed_up(b_headers, task_id, cost)
        _finish(b_headers, task_id)
    data = _info(b_headers)
    print("  sgbpoint =", data["sgbpoint"], "diligent =", data["diligent"])
    assert data["sgbpoint"] == 14, data

    print("== B3. 恩义祠(b102)捐献信息(lv0) ==")
    donate_info = req("get_teacherBuild_donateInfo",
                      {"buildTypeId": "102", "familyId": FAMILY}, headers=b_headers)["data"]
    print("  donateInfo =", {k: donate_info[k] for k in
                             ("buildTeacherExp", "donateNum", "donateMax")},
          "list =", donate_info["donateList"])
    assert donate_info["donateList"] == [
        {"donateId": "30000", "state": 0},
        {"donateId": "50002", "state": 1},
        {"donateId": "50102", "state": 1},
    ], donate_info["donateList"]

    print("== B4. 捐献 50102(楠木x10 -> 40修筑度) x6 ==")
    currency_version = 1
    for i in range(6):
        payload = req("donate_teacherBuild",
                      {"buildTypeId": "102", "familyId": FAMILY, "donateId": "50102",
                       "donateState": 1, "currencyVersion": currency_version},
                      headers=b_headers)
        assert payload["errcode"] == 0, payload
        currency_version = payload["data"]["currencyVersion"]
    data = payload["data"]
    print("  exp =", data["buildTeacherExp"], "renown =", data["renown"],
          "donate =", data["donate"], "currencyVersion =", currency_version)
    assert data["buildTeacherExp"] == 240, data
    assert data["renown"] == 60 and data["donate"] == 48, data

    items = req("get_teacherBuild_items", {"familyId": FAMILY}, headers=b_headers)["data"]
    assert {"itemId": "bmaterials3", "count": 0, "countLimit": 300} in items, items

    print("== B5. 材料不足被拒 ==")
    rejected = req("donate_teacherBuild",
                   {"buildTypeId": "102", "familyId": FAMILY, "donateId": "50102",
                    "donateState": 1, "currencyVersion": currency_version},
                   headers=b_headers, expect_errcode=2)
    print("  insufficient material rejected:", rejected["errmsg"])

    print("== B6. 名位升级(需修筑度150/昌盛度12/资历48) ==")
    payload = req("upgrade_teacherBuild", {"buildTypeId": "102", "familyId": FAMILY},
                  headers=b_headers)
    assert payload["errcode"] == 0, payload
    print("  buildLv =", payload["data"]["buildLv"], "renown =", payload["data"]["renown"])
    assert payload["data"] == {"buildLv": 1, "renown": 12}, payload

    listed = req("get_teacherBuild_list", {"familyId": FAMILY}, headers=b_headers)["data"]
    entry = {str(b["buildTypeId"]): b for b in listed}["102"]
    assert entry["buildLv"] == 1 and entry["buildTeacherExp"] == 240, entry

    print("== B7. 重复升级被拒(2级需修筑度1650) ==")
    rejected = req("upgrade_teacherBuild", {"buildTypeId": "102", "familyId": FAMILY},
                   headers=b_headers, expect_errcode=2)
    print("  repeat upgrade rejected:", rejected["errmsg"])

    print("== C1. 振兴门派信息(撷英阁效果) ==")
    info = req("get_sectRevitalization_info", {"familyId": FAMILY},
               headers=b_headers)["data"]
    print("  buildReward =", info["buildReward"],
          "buildings =", len(info["buildingList"]))
    assert info["buildReward"] == [{"id": "renown", "number": 10},
                                    {"id": "upresources", "number": 100}], info
    assert len(info["buildingList"]) == 17, len(info["buildingList"])
    b102 = [b for b in info["buildingList"] if b["buildTypeId"] == "102"][0]
    print("  恩义祠 =", b102)
    assert b102["buildName"] == "恩义祠" and b102["buildCurrentExp"] == 240, b102
    assert b102["buildLv"] == 1 and b102["buildMaxExp"] == 1650, b102
    assert b102["state"] == 0, b102

    print("== C2. 分配到泰安阁(107) ==")
    payload = req("get_sectRevitalization_reward",
                  {"familyId": FAMILY, "buildTypeId": "107"}, headers=b_headers)
    assert payload["errcode"] == 0, payload
    info = req("get_sectRevitalization_info", {"familyId": FAMILY},
               headers=b_headers)["data"]
    b107 = [b for b in info["buildingList"] if b["buildTypeId"] == "107"][0]
    print("  泰安阁 =", b107)
    assert b107["buildCurrentExp"] == 100 and b107["buildLv"] == 0, b107
    data = req("get_teacherBuild_info", {"familyId": FAMILY}, headers=b_headers)["data"]
    assert data["renown"] == 22, data  # 升级余 12 + 分配 10

    print("== C3. 每日一次 / 未知建筑被拒 ==")
    rejected = req("get_sectRevitalization_reward",
                   {"familyId": FAMILY, "buildTypeId": "107"},
                   headers=b_headers, expect_errcode=2)
    print("  daily limit rejected:", rejected["errmsg"])
    rejected = req("get_sectRevitalization_reward",
                   {"familyId": FAMILY, "buildTypeId": "999"},
                   headers=b_headers, expect_errcode=1)
    print("  unknown building rejected:", rejected["errmsg"])

    print("ALL OK")


if __name__ == "__main__":
    sys.exit(main())
