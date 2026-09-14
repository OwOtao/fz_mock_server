# -*- coding: utf-8 -*-
"""拳脚系统接口回归测试 (抓包契约 + 修行任务链路)。"""


# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__)))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import json
import os
import time
import unittest

import handlers  # noqa: F401 - 注册全部路由
from handlers import fist
from handlers.practice import add_item_count
from server import ROUTES
from state import StateStore

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CAPTURE_FIST_INFO = os.path.join(
    ROOT, "so", "har_decrypt_99", "entries", "010_get_fist_info.json")
CAPTURE_FIST_LOCKED = os.path.join(
    ROOT, "so", "har_decrypt_99", "entries", "054_get_fist_info.json")

# 抓包里带周冷却的任务 (cd={3,1,1,0,0,0}, 拳法锻境3级开启)
WEEKLY_TASK = "50108010101"


def _capture(path):
    with open(path, "r", encoding="utf-8") as handle:
        return json.load(handle)


class FistFootTest(unittest.TestCase):
    def setUp(self):
        self.state = StateStore(autosave=False)
        self.userid = self.state.ensure_account()["userid"]
        self.state.put_archive(self.userid, {
            "name": "测试角色",
            "lv": 550,
            "_inherit_flags": {"fistsfeetmapwc": 0},
            "serverActionSystem": {"dataVersion": 7},
            "dataVer": 7,
        })

    def ctx(self, body=None):
        return {
            "state": self.state,
            "headers": {"userid": str(self.userid)},
            "body": body or {},
            "route_tail": [],
        }

    def unlock(self):
        return fist.create_fist_info(self.ctx({"dataVer": 7, "codeVer": 1}))

    # -- 抓包契约 ---------------------------------------------------------

    def test_routes_registered(self):
        expected = {
            "get_fist_info", "create_fist_info", "get_fist_tasks",
            "start_fist_task", "stop_fist_task", "finish_fist_task",
            "expedite_fist_task", "updata_fist_flag",
        }
        self.assertTrue(expected.issubset(ROUTES))

    def test_locked_account_matches_capture(self):
        capture = json.loads(_capture(CAPTURE_FIST_LOCKED)["response_plain"])
        info = fist.get_fist_info(self.ctx({"dataVer": 2, "codeVer": 1}))
        self.assertEqual(info["errcode"], capture["errcode"])
        self.assertEqual(info["errmsg"], capture["errmsg"])
        self.assertEqual(info["errcode"], 2)
        self.assertEqual(fist.get_fist_tasks(self.ctx({"dataVer": 2}))["errcode"], 2)

    def test_payload_shape_matches_capture(self):
        capture = json.loads(_capture(CAPTURE_FIST_INFO)["response_plain"])["data"]
        created = self.unlock()
        self.assertEqual(created["errcode"], 0)
        data = created["data"]

        self.assertEqual(set(data), set(capture))
        self.assertEqual(set(data["branchInfo"]), set(capture["branchInfo"]))
        for branch_id, branch in capture["branchInfo"].items():
            self.assertEqual(set(data["branchInfo"][branch_id]), set(branch))
        # 新号的 guajiInfo 为空; 开始修行后字段与抓包一致
        self.assertEqual(data["guajiInfo"], {})
        fist.start_fist_task(self.ctx({"taskId": WEEKLY_TASK, "dataVer": 7}))
        guaji = fist.get_fist_info(self.ctx({"dataVer": 7}))["data"]["guajiInfo"]
        self.assertEqual(set(guaji), set(capture["guajiInfo"]))

        # 抓包里未培养的分支: exp=1 + 自带默认技巧 lv1 (与抓包逐字段一致)
        for branch_id, technique_id in fist.DEFAULT_TECHNIQUE_BY_BRANCH.items():
            branch = data["branchInfo"][branch_id]
            self.assertEqual(branch["exp"], 1)
            self.assertEqual(
                branch["techniqueList"][str(technique_id)],
                capture["branchInfo"][branch_id]["techniqueList"][str(technique_id)],
            )

    def test_create_fist_info_is_idempotent_and_sets_flag(self):
        first = self.unlock()
        second = self.unlock()
        self.assertEqual(first["data"]["branchInfo"], second["data"]["branchInfo"])
        role = self.state.get_archive(self.userid)
        self.assertEqual(role["_inherit_flags"][fist.UNLOCK_FLAG], 1)
        self.assertGreaterEqual(second["data"]["dataVer"], first["data"]["dataVer"])

    def test_updata_fist_flag_unlocks(self):
        result = fist.updata_fist_flag(self.ctx({
            "addFlags": [fist.UNLOCK_FLAG], "deleteFlags": [],
            "dataVer": 7, "codeVer": 1,
        }))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(fist.get_fist_info(self.ctx({"dataVer": 7}))["errcode"], 0)
        deleted = fist.updata_fist_flag(self.ctx({
            "addFlags": [], "deleteFlags": fist.UNLOCK_FLAG,
        }))
        self.assertEqual(deleted["errcode"], 0)
        self.assertEqual(fist.get_fist_info(self.ctx({"dataVer": 7}))["errcode"], 2)

    # -- 任务列表 ---------------------------------------------------------

    def test_task_list_contract_and_window(self):
        self.unlock()
        listed = fist.get_fist_tasks(self.ctx({"dataVer": 7}))
        self.assertEqual(listed["errcode"], 0)
        tasks = listed["data"]["list"]
        table = fist._task_table()
        self.assertTrue(tasks)
        for entry in tasks:
            self.assertEqual(set(entry), {"taskId", "state", "cdTime"})
            self.assertIn(entry["taskId"], table)
            self.assertIn(entry["state"], (0, 1, 2))
            self.assertGreaterEqual(entry["cdTime"], 0)
        ids = {entry["taskId"] for entry in tasks}
        # 时间窗已经结束的 2022 重阳活动任务不再下发
        self.assertNotIn("108010101", ids)
        self.assertIn(WEEKLY_TASK, ids)

    def test_cooldown_kinds_match_resource_table(self):
        # FistFootConst.TaskCdType: 1=无需冷却 2=间隔 3=固定时间点
        kinds = {}
        for task in fist._task_table().values():
            kinds[fist._cd_kind(task)] = kinds.get(fist._cd_kind(task), 0) + 1
        self.assertEqual(set(kinds), {fist.TASK_CD_NONE, fist.TASK_CD_FIXED})
        self.assertEqual(fist._cd_kind({"cd": [1]}), fist.TASK_CD_NONE)
        self.assertEqual(fist._cd_kind({"cd": [3, 1, 1, 0, 0, 0]}), fist.TASK_CD_FIXED)

        # 无需冷却的任务完成后立即可再修行 (state 不会变成 2)
        self.unlock()
        bucket = fist._bucket(self.ctx(), self.userid)
        task = next(t for t in fist._task_table().values()
                    if fist._cd_kind(t) == fist.TASK_CD_NONE
                    and not t.get("conblevel") and not t.get("dive")
                    and fist._in_window(t, int(time.time())))
        bucket["taskLastFinish"] = {str(task["taskid"]): int(time.time())}
        entry = fist._task_state(bucket, task["taskid"], task, int(time.time()))
        self.assertEqual(entry["state"], 1)
        self.assertEqual(entry["cdTime"], 0)

        # 固定时间点刷新的任务: 完成后进入冷却, cdTime 指向下一个刷新点
        fist.test_set_fist_branch_level(self.ctx({
            "branchId": "10010", "branchExp": 10 ** 7, "dataVer": 7, "codeVer": 1,
        }))
        fixed = fist._task_table()[WEEKLY_TASK]
        self.assertEqual(fist._cd_kind(fixed), fist.TASK_CD_FIXED)
        bucket["taskLastFinish"] = {WEEKLY_TASK: int(time.time())}
        entry = fist._task_state(bucket, WEEKLY_TASK, fixed, int(time.time()))
        self.assertEqual(entry["state"], 2)
        self.assertGreater(entry["cdTime"], 0)
        # 上周完成的不再冷却
        bucket["taskLastFinish"] = {WEEKLY_TASK: int(time.time()) - 8 * 24 * 3600}
        self.assertEqual(
            fist._task_state(bucket, WEEKLY_TASK, fixed, int(time.time()))["state"], 1)

    def test_task_state_follows_branch_level(self):
        self.unlock()
        before = {e["taskId"]: e["state"] for e in
                  fist.get_fist_tasks(self.ctx({"dataVer": 7}))["data"]["list"]}
        self.assertEqual(before[WEEKLY_TASK], 0)
        fist.test_set_fist_branch_level(self.ctx({
            "branchId": "10010", "branchExp": 10 ** 7, "dataVer": 7, "codeVer": 1,
        }))
        after = {e["taskId"]: e["state"] for e in
                 fist.get_fist_tasks(self.ctx({"dataVer": 7}))["data"]["list"]}
        self.assertEqual(after[WEEKLY_TASK], 1)

    def test_reflect_level_gates_dive_tasks(self):
        self.unlock()
        dive_task = next(
            task_id for task_id, task in fist._task_table().items()
            if task.get("dive") and not task.get("conblevel")
            and fist._in_window(task, int(time.time())))
        states = {e["taskId"]: e["state"] for e in
                  fist.get_fist_tasks(self.ctx({"dataVer": 7}))["data"]["list"]}
        self.assertEqual(states[dive_task], 0)
        fist.test_set_fist_reflect_level(self.ctx({"exp": 10 ** 7, "dataVer": 7}))
        states = {e["taskId"]: e["state"] for e in
                  fist.get_fist_tasks(self.ctx({"dataVer": 7}))["data"]["list"]}
        self.assertEqual(states[dive_task], 1)

    # -- 修行链路 ---------------------------------------------------------

    def test_guaji_lifecycle_and_weekly_cooldown(self):
        self.unlock()
        fist.test_set_fist_branch_level(self.ctx({
            "branchId": "10010", "branchExp": 10 ** 7, "dataVer": 7, "codeVer": 1,
        }))
        task = fist._task_table()[WEEKLY_TASK]

        started = fist.start_fist_task(self.ctx({
            "taskId": WEEKLY_TASK, "dataVer": 7, "codeVer": 1,
        }))
        self.assertEqual(started["errcode"], 0)
        self.assertAlmostEqual(started["data"]["startTime"], int(time.time()), delta=5)
        info = fist.get_fist_info(self.ctx({"dataVer": started["data"]["dataVer"]}))["data"]
        self.assertEqual(info["guajiInfo"]["taskId"], WEEKLY_TASK)
        self.assertEqual(info["guajiInfo"]["speedUpTime"], 0)

        # 抓包里 accpoint / characterPoint 与服务器物品计数同源
        granted = add_item_count(self.ctx({
            "itemId": "accpoint", "count": 5, "dataVer": 7, "codeVer": 1,
        }))
        self.assertEqual(granted["errcode"], 0)
        info = fist.get_fist_info(self.ctx({"dataVer": 7}))["data"]
        self.assertEqual(info["accpoint"], granted["data"]["count"])

        sped = fist.expedite_fist_task(self.ctx({
            "taskId": WEEKLY_TASK, "cost": 3, "dataVer": 7, "codeVer": 1,
        }))
        self.assertEqual(sped["errcode"], 0)
        self.assertEqual(sped["data"]["cost"], 3)
        self.assertEqual(sped["data"]["speedUpTime"], 3 * 3600)
        info = fist.get_fist_info(self.ctx({"dataVer": sped["data"]["dataVer"]}))["data"]
        self.assertEqual(info["accpoint"], granted["data"]["count"] - 3)
        self.assertEqual(info["guajiInfo"]["speedUpTime"], 3 * 3600)

        before_exp = info["branchInfo"]["10010"]["exp"]
        finished = fist.finish_fist_task(self.ctx({
            "taskId": WEEKLY_TASK, "bagEnough": 1, "dataVer": 7, "codeVer": 1,
        }))
        self.assertEqual(finished["errcode"], 0)
        self.assertEqual(finished["data"]["reward"], task["awards"])
        info = fist.get_fist_info(self.ctx({"dataVer": finished["data"]["dataVer"]}))["data"]
        self.assertEqual(info["guajiInfo"], {})
        self.assertEqual(info["branchInfo"]["10010"]["exp"], before_exp + task["awards"][0][2])

        # 周冷却: 完成后进入 state=2, cdTime 指向下一个刷新点
        entry = next(e for e in
                     fist.get_fist_tasks(self.ctx({"dataVer": 7}))["data"]["list"]
                     if e["taskId"] == WEEKLY_TASK)
        self.assertEqual(entry["state"], 2)
        self.assertGreater(entry["cdTime"], 0)
        self.assertLessEqual(entry["cdTime"], 7 * 24 * 3600)

    def test_stop_task_clears_guaji_without_cooldown(self):
        self.unlock()
        fist.start_fist_task(self.ctx({"taskId": WEEKLY_TASK, "dataVer": 7, "codeVer": 1}))
        self.assertEqual(fist.stop_fist_task(self.ctx({"dataVer": 7}))["errcode"], 0)
        info = fist.get_fist_info(self.ctx({"dataVer": 7}))["data"]
        self.assertEqual(info["guajiInfo"], {})
        entry = next(e for e in
                     fist.get_fist_tasks(self.ctx({"dataVer": 7}))["data"]["list"]
                     if e["taskId"] == WEEKLY_TASK)
        self.assertNotEqual(entry["state"], 2)

    def test_expedite_requires_resource_and_running_task(self):
        self.unlock()
        idle = fist.expedite_fist_task(self.ctx({
            "taskId": WEEKLY_TASK, "cost": 1, "dataVer": 7, "codeVer": 1,
        }))
        self.assertNotEqual(idle["errcode"], 0)
        fist.start_fist_task(self.ctx({"taskId": WEEKLY_TASK, "dataVer": 7, "codeVer": 1}))
        poor = fist.expedite_fist_task(self.ctx({
            "taskId": WEEKLY_TASK, "cost": 1, "dataVer": 7, "codeVer": 1,
        }))
        self.assertNotEqual(poor["errcode"], 0)
        self.assertIn("固身元气", poor["errmsg"])

    def test_unknown_task_rejected(self):
        self.unlock()
        self.assertNotEqual(
            fist.start_fist_task(self.ctx({"taskId": "nope", "dataVer": 7}))["errcode"], 0)
        self.assertNotEqual(
            fist.finish_fist_task(self.ctx({"taskId": "nope", "dataVer": 7}))["errcode"], 0)

    def test_finish_requires_running_task(self):
        self.unlock()
        # 没有开始修行时不能直接结算
        self.assertNotEqual(
            fist.finish_fist_task(self.ctx({
                "taskId": WEEKLY_TASK, "bagEnough": 1, "dataVer": 7,
            }))["errcode"], 0)
        fist.start_fist_task(self.ctx({"taskId": WEEKLY_TASK, "dataVer": 7}))
        # 开工后不能并发开始另一条
        other = next(task_id for task_id in fist._task_table() if task_id != WEEKLY_TASK)
        self.assertNotEqual(
            fist.start_fist_task(self.ctx({"taskId": other, "dataVer": 7}))["errcode"], 0)
        # 结算的 taskId 必须与进行中的一致
        self.assertNotEqual(
            fist.finish_fist_task(self.ctx({"taskId": other, "dataVer": 7}))["errcode"], 0)

    def test_item_reward_goes_to_mail_when_bag_full(self):
        self.unlock()
        task_id = next(
            task_id for task_id, task in fist._task_table().items()
            if any(isinstance(a, list) and a and a[0] == 3 for a in task.get("awards") or [])
            and fist._in_window(task, int(time.time())))
        task = fist._task_table()[task_id]
        item = next(a for a in task["awards"] if a[0] == 3)
        fist.start_fist_task(self.ctx({"taskId": task_id, "dataVer": 7}))

        self.state._state.setdefault("inventory_items", {}).setdefault(str(self.userid), {})
        finished = fist.finish_fist_task(self.ctx({
            "taskId": task_id, "bagEnough": 0, "dataVer": 7,
        }))
        self.assertEqual(finished["errcode"], 0)
        self.assertEqual(
            self.state.get_inventory_item_count(self.userid, str(item[1])), 0)
        mails = self.state.list_mail(self.userid)
        self.assertEqual(mails[-1]["rewards"]["loc_items"],
                         [{"id": str(item[1]), "num": item[2], "state": 0}])
        self.assertIn("邮驿", finished["data"]["msg"])
        self.assertIn("邮驿", mails[-1]["content"])

        # bagEnough=1 时直接进背包
        fist.start_fist_task(self.ctx({"taskId": task_id, "dataVer": 7}))
        finished = fist.finish_fist_task(self.ctx({
            "taskId": task_id, "bagEnough": 1, "dataVer": 7,
        }))
        self.assertEqual(finished["errcode"], 0)
        self.assertEqual(
            self.state.get_inventory_item_count(self.userid, str(item[1])), item[2])
        self.assertEqual(finished["data"]["msg"], "")

    # -- 调试层 -----------------------------------------------------------

    def test_debug_setters(self):
        self.unlock()
        self.assertEqual(fist.test_set_fist_branch_level(self.ctx({
            "branchId": "10010", "branchExp": 1234, "dataVer": 7,
        }))["errcode"], 0)
        self.assertEqual(fist.test_set_fist_reflect_level(self.ctx({
            "exp": 4321, "dataVer": 7,
        }))["errcode"], 0)
        self.assertEqual(fist.test_set_fist_technique_level(self.ctx({
            "techniqueId": 10001, "level": 5, "dataVer": 7,
        }))["errcode"], 0)
        self.assertEqual(fist.test_add_fist_feel_point(self.ctx({
            "number": 9, "dataVer": 7,
        }))["errcode"], 0)
        info = fist.get_fist_info(self.ctx({"dataVer": 7}))["data"]
        self.assertEqual(info["branchInfo"]["10010"]["exp"], 1234)
        self.assertEqual(info["branchInfo"]["10010"]["techniqueList"]["10001"]["lv"], 5)
        self.assertEqual(info["reflectExp"], 4321)
        self.assertEqual(info["feelPoint"], 9)
        # 新技巧按 id 反推分支写入
        self.assertEqual(fist.test_set_fist_technique_level(self.ctx({
            "techniqueId": 20002, "level": 3, "dataVer": 7,
        }))["errcode"], 0)
        info = fist.get_fist_info(self.ctx({"dataVer": 7}))["data"]
        self.assertEqual(info["branchInfo"]["10020"]["techniqueList"]["20002"]["lv"], 3)

    def test_legacy_empty_bucket_is_repaired(self):
        self.unlock()
        with self.state._lock:
            self.state._state["fist"][str(self.userid)] = {
                "accpoint": 0, "reflectExp": 0, "feelPoint": 0, "characterPoint": 0,
                "guajiInfo": {}, "branchInfo": {
                    branch_id: {"exp": 0, "costTechnique": 0, "techniqueList": {},
                                "characterInUse": [], "characterUnused": []}
                    for branch_id in fist.BRANCH_IDS
                },
            }
        info = fist.get_fist_info(self.ctx({"dataVer": 7}))["data"]
        for branch_id, technique_id in fist.DEFAULT_TECHNIQUE_BY_BRANCH.items():
            branch = info["branchInfo"][branch_id]
            self.assertEqual(branch["exp"], fist.DEFAULT_BRANCH_EXP)
            self.assertIn(str(technique_id), branch["techniqueList"])


if __name__ == "__main__":
    unittest.main()
