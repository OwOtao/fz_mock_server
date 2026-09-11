# -*- coding: utf-8 -*-
"""端到端验证: 拳脚系统 get_fist_info / get_fist_tasks 与修行链路。

自起临时服务 + 临时存档 (不碰 data/ 里的真实存档):
    python _test_fist_e2e.py

覆盖:
  1. 未解锁账号 get_fist_info -> errcode=2 "拳脚系统未解锁" (与抓包一致)
  2. 已解锁账号 get_fist_info 字段与 so/har_decrypt_99/entries/010 抓包一致
  3. get_fist_tasks 契约 (taskId/state/cdTime) 与时间窗过滤
  4. start / expedite / finish 链路: guajiInfo、固身元气扣减、奖励入账、周冷却
"""

import hashlib
import json
import os
import shutil
import sys
import tempfile
import threading
import urllib.request

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)

import config  # noqa: E402
import handlers  # noqa: E402,F401  (触发路由注册)
import jm_crypto  # noqa: E402
from server import create_server  # noqa: E402
from state import StateStore  # noqa: E402

PORT = int(os.getenv("MOCK_FIST_E2E_PORT", "18099"))
UNLOCKED = 9048162379
LOCKED = 9048162373
WEEKLY_TASK = "50108010101"


def req(path, payload, userid):
    body = jm_crypto.encrypt(json.dumps(payload))
    request = urllib.request.Request(
        "http://127.0.0.1:%d/%s%s" % (PORT, config.API_PREFIX, path),
        data=body.encode("utf-8"),
        method="POST",
        headers={
            "Content-Type": "text/plain; charset=utf-8",
            "userid": str(userid),
        },
    )
    with urllib.request.urlopen(request, timeout=10) as response:
        text = response.read().decode("utf-8")
        headers = {k.lower(): v for k, v in response.headers.items()}
    signature = hashlib.md5("&".join([
        headers["time"], headers["nonce"], text, config.T_TOKEN,
    ]).encode("utf-8")).hexdigest()
    assert signature == headers["signature"], "响应签名不匹配"
    return json.loads(jm_crypto.decrypt(text).decode("utf-8"))


def main():
    with open(os.path.join(ROOT, "so", "har_decrypt_99", "entries",
                           "010_get_fist_info.json"), encoding="utf-8") as handle:
        capture = json.loads(json.load(handle)["response_plain"])["data"]

    tmp = tempfile.mkdtemp(prefix="fist-e2e-")
    state = StateStore(json_path=os.path.join(tmp, "state.json"),
                       archives_dir=os.path.join(tmp, "archives"))
    state.ensure_account(UNLOCKED)
    state.put_archive(UNLOCKED, {
        "name": "拳脚验证", "lv": 460,
        "_inherit_flags": {"fistsfeetmapwc": 1},
        "serverActionSystem": {"dataVersion": 7}, "dataVer": 7,
    })
    state.ensure_account(LOCKED)
    state.put_archive(LOCKED, {
        "name": "未解锁验证", "lv": 550,
        "_inherit_flags": {"fistsfeetmapwc": 0},
        "serverActionSystem": {"dataVersion": 2}, "dataVer": 2,
    })

    server = create_server("127.0.0.1", PORT, state)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    try:
        print("== 1. 未解锁账号 ==")
        locked = req("get_fist_info", {"dataVer": 2, "codeVer": 1}, LOCKED)
        assert locked["errcode"] == 2 and locked["errmsg"] == "拳脚系统未解锁", locked
        assert req("get_fist_tasks", {"dataVer": 2, "codeVer": 1}, LOCKED)["errcode"] == 2
        print("   errcode=2 errmsg=%s" % locked["errmsg"])

        print("== 2. get_fist_info vs 抓包 ==")
        info = req("get_fist_info", {"dataVer": 7, "codeVer": 1}, UNLOCKED)
        assert info["errcode"] == 0, info
        data = info["data"]
        assert set(data) == set(capture), (sorted(data), sorted(capture))
        assert set(data["branchInfo"]) == set(capture["branchInfo"])
        for branch_id, branch in capture["branchInfo"].items():
            assert set(data["branchInfo"][branch_id]) == set(branch)
        assert data["guajiInfo"] == {}
        print("   字段与抓包一致; accpoint=%s characterPoint=%s"
              % (data["accpoint"], data["characterPoint"]))

        print("== 3. get_fist_tasks ==")
        listed = req("get_fist_tasks", {"dataVer": 7, "codeVer": 1}, UNLOCKED)
        tasks = {entry["taskId"]: entry for entry in listed["data"]["list"]}
        assert tasks, listed
        assert WEEKLY_TASK in tasks
        assert "108010101" not in tasks, "过期活动任务不应下发"
        assert all(set(entry) == {"taskId", "state", "cdTime"}
                   for entry in tasks.values())
        assert tasks[WEEKLY_TASK]["state"] == 0, tasks[WEEKLY_TASK]
        print("   任务数=%d, %s 未满足锻境条件时 state=0" % (len(tasks), WEEKLY_TASK))

        print("== 4. 修行链路 ==")
        grant = req("addItemCount", {"itemId": "accpoint", "count": 5, "dataVer": 7},
                    UNLOCKED)
        assert grant["errcode"] == 0, grant
        info = req("get_fist_info", {"dataVer": grant["data"]["dataVer"]}, UNLOCKED)
        assert info["data"]["accpoint"] == grant["data"]["count"], info["data"]
        print("   固身元气与服务器物品同源: accpoint=%d" % info["data"]["accpoint"])

        started = req("start_fist_task",
                      {"taskId": WEEKLY_TASK, "dataVer": 7, "codeVer": 1}, UNLOCKED)
        assert started["errcode"] == 0, started
        info = req("get_fist_info", {"dataVer": started["data"]["dataVer"]}, UNLOCKED)
        assert info["data"]["guajiInfo"]["taskId"] == WEEKLY_TASK
        print("   开始修行 startTime=%d" % info["data"]["guajiInfo"]["startTime"])

        sped = req("expedite_fist_task",
                   {"taskId": WEEKLY_TASK, "cost": 3, "dataVer": 7, "codeVer": 1},
                   UNLOCKED)
        assert sped["errcode"] == 0, sped
        assert sped["data"]["speedUpTime"] == 3 * 3600, sped
        info = req("get_fist_info", {"dataVer": sped["data"]["dataVer"]}, UNLOCKED)
        assert info["data"]["accpoint"] == grant["data"]["count"] - 3, info["data"]
        assert info["data"]["guajiInfo"]["speedUpTime"] == 3 * 3600
        print("   加速 3 点 -> accpoint=%d speedUpTime=%d"
              % (info["data"]["accpoint"], info["data"]["guajiInfo"]["speedUpTime"]))

        finished = req("finish_fist_task",
                       {"taskId": WEEKLY_TASK, "bagEnough": 1, "dataVer": 7, "codeVer": 1},
                       UNLOCKED)
        assert finished["errcode"] == 0, finished
        info = req("get_fist_info", {"dataVer": finished["data"]["dataVer"]}, UNLOCKED)
        assert info["data"]["guajiInfo"] == {}, info["data"]
        assert info["data"]["branchInfo"]["10010"]["exp"] == 1 + finished["data"]["reward"][0][2]
        print("   完成修行 reward=%s -> 10010 exp=%d"
              % (finished["data"]["reward"], info["data"]["branchInfo"]["10010"]["exp"]))

        tasks = {entry["taskId"]: entry for entry in
                 req("get_fist_tasks", {"dataVer": 7}, UNLOCKED)["data"]["list"]}
        assert tasks[WEEKLY_TASK]["state"] == 2, tasks[WEEKLY_TASK]
        assert 0 < tasks[WEEKLY_TASK]["cdTime"] <= 7 * 24 * 3600
        print("   周冷却 state=2 cdTime=%d 秒" % tasks[WEEKLY_TASK]["cdTime"])

        print("\nALL OK")
    finally:
        server.graceful_close(2.0)
        shutil.rmtree(tmp, ignore_errors=True)


if __name__ == "__main__":
    main()
