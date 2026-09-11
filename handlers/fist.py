# -*- coding: utf-8 -*-
"""拳脚系统 (FistFootSystem / ServerActionSystem) 接口。

抓包依据 (可用 `python _probe_fist_har.py` 复现, 数据在 so/*.har):
  * get_fist_info   请求 {"dataVer": n, "codeVer": 1}
      - 已解锁: data = {
            accpoint, reflectExp, feelPoint, characterPoint,
            branchInfo{ "10010".."10050": {exp, costTechnique,
                        techniqueList{ "10001": {branchId, id, lv} },
                        characterInUse[], characterUnused[]} },
            guajiInfo{} 或 {taskId, startTime, speedUpTime},
            dataVer }
      - 未解锁: errcode=2, errmsg="拳脚系统未解锁" (无 data)
        见 har_decrypt_99/entries/054,114 与 har_decrypt_91/entries/203
        (dataVer=2 的新号 / 未过前置任务的号)。
      - 刚解锁的号: 五个分支 exp=1, 每个分支自带默认技巧 10001/20001/30001/
        40001/50001 (lv=1); 见 har_decrypt_99/010 与 8-24/8-26/8-27 HAR。

  * get_fist_tasks 抓包里没有命中 (抓包时角色都在修行中, 客户端走 FistFootGuaJi
    分支, 见 FistFootMenuPresenter:setButtonGuaJi)。这里按客户端
    FistFootSystem/FistFootTaskPresenter 的消费字段 + script.fistFoot.tasks /
    branchLevel / baseLevel 资源还原:
        data.list = [{taskId, state, cdTime}, ...]
        state  = FistFootConst.TaskStateType: 0=Lock(条件不足) 1=Unlock 2=Cd
        cdTime = 冷却剩余秒数 (Interval 型用; Fixed 型的文案由客户端按 cd 自己拼)
    开启条件取自 tasks.lua 的 opentext 对应字段:
        conblevel = [分支id, 锻境等级]   (branchLevel.exp 换算出的等级)
        dive      = 技巧潜思等级          (baseLevel.exp 换算出的等级)
    冷却类型取自 FistFootConst.TaskCdType (cd[1]): 1=无需冷却(做完立即刷新)
    2=间隔刷新(完成后 N 小时) 3=固定时间点刷新(每周, cd[3]=周几 cd[4]=几点)。
    现有 tasks.lua 只有 1 和 3 两种。只返回当前时间窗内的任务。

  * 修行链路 (客户端 FistFootSystem):
        start_fist_task    -> data {startTime, dataVer}; 本地 speedUpTime=0
        stop_fist_task     -> 清空 guajiInfo
        finish_fist_task   -> data {reward=[[type,id,num],...], feelPoint, dataVer}
                              type: 1=分支阅历 2=潜思经验 3=剧情道具 4=服务器资源
        expedite_fist_task -> data {cost, speedUpTime(=cost*3600), dataVer}
        updata_fist_flag   -> 增删存档 _inherit_flags (解锁/修复标记)

解锁判定与客户端 FistFootSystem:isOpenSystem 一致: 存档 _inherit_flags 里
"fistsfeetmapwc" == 1 (等级门槛 unlockLevel=306 由客户端 UI 自己把关)。

固身元气 accpoint / 特性见解 characterPoint 属于"服务器资源"(AwardType.Net),
客户端调试层的增加按钮走的是通用 XinShenSystem:addItemCount -> addItemCount 接口,
再把返回的 count 塞回 setAccpoint/setCharacterPoint, 所以这两个值和
practice.itemMap(即 practice.getItemCount/addItemCount 维护的那份)是同一个计数:
读时以物品表为准(没有记录才回退到拳脚数据), 修行奖励/加速时两边一起落。
"""

from __future__ import annotations

import copy
import datetime
import logging
import time
from functools import lru_cache
from pathlib import Path

from lua_to_json import parse_lua_file
from protocol import build_response_body
from server import route

log = logging.getLogger("mock_server")

BRANCH_IDS = ("10010", "10020", "10030", "10040", "10050")
DEFAULT_TECHNIQUE_BY_BRANCH = {
    "10010": 10001,
    "10020": 20001,
    "10030": 30001,
    "10040": 40001,
    "10050": 50001,
}
DEFAULT_BRANCH_EXP = 1
UNLOCK_FLAG = "fistsfeetmapwc"
UNLOCK_LEVEL = 306

ERR_NOT_UNLOCKED = 2          # 抓包: 拳脚系统未解锁
ERRMSG_NOT_UNLOCKED = "拳脚系统未解锁"
ERR_BAD_REQUEST = 400

TASK_STATE_LOCK = 0
TASK_STATE_UNLOCK = 1
TASK_STATE_CD = 2
# FistFootConst.TaskCdType: 1=无需冷却 2=间隔刷新 3=固定时间点刷新
TASK_CD_NONE = 1
TASK_CD_INTERVAL = 2
TASK_CD_FIXED = 3
DEFAULT_INTERVAL_HOURS = 24   # 间隔型任务的兜底时长 (现有 tasks.lua 里没有该类型)
WEEK_SECONDS = 7 * 24 * 3600
SPEED_UP_SECONDS_PER_COST = 3600   # SpeedUpGuaJiPresenter: cost*3600

AWARD_BRANCH_EXP = 1
AWARD_REFLECT_EXP = 2
AWARD_ITEM = 3
AWARD_NET = 4

_RES_ROOT = (Path(__file__).resolve().parents[1]
             / "fzjh_lua" / "assets" / "res" / "script" / "fistFoot")


# ---------------------------------------------------------------------------
# 基础工具


def _userid(ctx):
    try:
        return int(ctx.get("headers", {}).get("userid") or 0)
    except (TypeError, ValueError):
        return 0


def _body(ctx):
    value = ctx.get("body")
    return value if isinstance(value, dict) else {}


def _as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return int(default)


def _is_number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool)


def _archive(ctx, userid):
    role = ctx["state"].get_archive(userid)
    return role if isinstance(role, dict) else None


def _inherit_flag(role, name):
    flags = (role or {}).get("_inherit_flags")
    if not isinstance(flags, dict):
        return 0
    value = flags.get(name)
    if isinstance(value, bool):
        return 1 if value else 0
    return _as_int(value, 0)


def _is_unlocked(ctx, userid):
    """与客户端 FistFootSystem:isOpenSystem 一致: 存档标记 fistsfeetmapwc==1。

    客户端还要求等级 >= unlockLevel(306), 存档没写等级时不拦。
    """
    role = _archive(ctx, userid)
    if _inherit_flag(role, UNLOCK_FLAG) != 1:
        return False
    level = _as_int((role or {}).get("lv"), 0)
    return level <= 0 or level >= UNLOCK_LEVEL


def _server_data_ver(ctx, userid):
    role = _archive(ctx, userid)
    if isinstance(role, dict):
        system = role.get("serverActionSystem")
        if isinstance(system, dict):
            value = _as_int(system.get("dataVersion"), -1)
            if value >= 0:
                return value
        value = _as_int(role.get("dataVer"), -1)
        if value >= 0:
            return value
    return 1


def _request_data_ver(ctx):
    return max(_as_int(_body(ctx).get("dataVer"), 0), 0)


def _read_data_ver(ctx, userid):
    """只读接口: 取服务端与请求两者的较大值 (与 practice/har_91 一致)。"""
    return max(_server_data_ver(ctx, userid), _request_data_ver(ctx))


def _put_role(ctx, userid, role, data_ver=None):
    """写回存档, 保留 doc 级 record/upload 元数据。"""
    store = ctx["state"]
    doc = store.get_archive_document(userid)
    record = doc.get("record") if isinstance(doc, dict) else None
    upload = doc.get("upload") if isinstance(doc, dict) else None
    return store.put_archive(userid, role, record=record, upload=upload, data_ver=data_ver)


def _bump_data_ver(ctx, userid, role):
    """写接口: dataVer = max(服务端, 请求) + 1, 同时落到存档两个字段上。"""
    data_ver = max(_server_data_ver(ctx, userid), _request_data_ver(ctx)) + 1
    if isinstance(role, dict):
        role["dataVer"] = data_ver
        system = role.get("serverActionSystem")
        if not isinstance(system, dict):
            system = {}
            role["serverActionSystem"] = system
        system["dataVersion"] = data_ver
    return data_ver


def _set_unlock_flag(ctx, userid):
    role = _archive(ctx, userid)
    if not isinstance(role, dict):
        role = {}
    flags = role.get("_inherit_flags")
    if not isinstance(flags, dict):
        flags = {}
        role["_inherit_flags"] = flags
    flags[UNLOCK_FLAG] = 1
    data_ver = _bump_data_ver(ctx, userid, role)
    _put_role(ctx, userid, role, data_ver=data_ver)
    return data_ver


# ---------------------------------------------------------------------------
# 客户端资源表 (script/fistFoot/*)


def _load_lua(path):
    try:
        data = parse_lua_file(str(path))
    except Exception as exc:   # 资源缺失/解析失败不应让接口 500
        log.warning("fist resource load failed: %s (%s)", path, exc)
        return {}
    if isinstance(data, dict):
        value = data.get("1")
        if isinstance(value, dict):
            return value
    return data if isinstance(data, dict) else {}


@lru_cache(maxsize=1)
def _task_table():
    """script.fistFoot.tasks: {taskId: {type, name, conblevel, dive, cd, time, awards...}}"""
    return _load_lua(_RES_ROOT / "tasks.lua")


@lru_cache(maxsize=1)
def _branch_level_table():
    """script.fistFoot.branchLevel: 分支等级 -> 所需阅历 [(level, exp), ...]"""
    table = {}
    for row in _load_lua(_RES_ROOT / "branchLevel.lua").values():
        if not isinstance(row, dict):
            continue
        branch = str(row.get("type") or "")
        level = _as_int(row.get("level"), 0)
        if not branch or level <= 0:
            continue
        table.setdefault(branch, []).append((level, _as_int(row.get("exp"), 0)))
    for values in table.values():
        values.sort()
    return table


@lru_cache(maxsize=1)
def _reflect_level_table():
    """script.fistFoot.baseLevel: 潜思等级 -> 所需经验 [(basislv, exp), ...]"""
    values = []
    for row in _load_lua(_RES_ROOT / "baseLevel.lua").values():
        if not isinstance(row, dict):
            continue
        values.append((_as_int(row.get("basislv"), 0), _as_int(row.get("exp"), 0)))
    values.sort()
    return values


def _level_from_exp(table, exp):
    level = 0
    for value, need in table:
        if exp >= need:
            level = value
    return level


def _branch_level(bucket, branch_id):
    table = _branch_level_table().get(str(branch_id)) or []
    branch = (bucket.get("branchInfo") or {}).get(str(branch_id))
    exp = _as_int((branch or {}).get("exp"), 0) if isinstance(branch, dict) else 0
    return _level_from_exp(table, exp)


def _reflect_level(bucket):
    return _level_from_exp(_reflect_level_table(), _as_int(bucket.get("reflectExp"), 0))


def _timestamp(parts):
    """tasks 里的时间窗 {Y, M, D, h, m, s} -> unix 秒。"""
    if not isinstance(parts, list) or len(parts) < 3:
        return None
    values = [_as_int(v, 0) for v in list(parts)[:6]]
    while len(values) < 6:
        values.append(0)
    try:
        return int(datetime.datetime(*values).timestamp())
    except (TypeError, ValueError):
        return None


def _in_window(task, now):
    start = _timestamp(task.get("starttime"))
    end = _timestamp(task.get("endtime"))
    if start is not None and now < start:
        return False
    if end is not None and now > end:
        return False
    return True


def _refresh_point(now, cd, forward=False):
    """每周固定刷新点 (FistFootTaskPresenter: Lua cd[3]=周几, cd[4]=几点)。

    参数 cd 是资源表里的原始数组 (Lua 1 基), 因此这里用 0 基的 cd[2]/cd[3]。
    """
    week = _as_int(cd[2], 1) if len(cd) > 2 else 1
    hour = _as_int(cd[3], 0) if len(cd) > 3 else 0
    week = week if 1 <= week <= 7 else 1
    hour = hour if 0 <= hour <= 23 else 0
    moment = datetime.datetime.fromtimestamp(now)
    point = (moment.replace(hour=0, minute=0, second=0, microsecond=0)
             - datetime.timedelta(days=(moment.weekday() - ((week - 1) % 7)) % 7)
             + datetime.timedelta(hours=hour))
    if forward:
        if point.timestamp() <= now:
            point += datetime.timedelta(seconds=WEEK_SECONDS)
    elif point.timestamp() > now:
        point -= datetime.timedelta(seconds=WEEK_SECONDS)
    return int(point.timestamp())


def _cd_kind(task):
    cd = task.get("cd")
    if not isinstance(cd, list) or not cd:
        return TASK_CD_NONE
    return _as_int(cd[0], TASK_CD_NONE)


def _interval_seconds(task):
    """间隔型任务的刷新间隔 (小时); 资源表里没有该类型, 按 cd[2] 推断并兜底 24 小时。"""
    cd = task.get("cd")
    hours = _as_int(cd[1], 0) if isinstance(cd, list) and len(cd) > 1 else 0
    if hours <= 0 or hours > 24 * 7:
        hours = DEFAULT_INTERVAL_HOURS
    return hours * 3600


def _task_state(bucket, task_id, task, now):
    state = TASK_STATE_UNLOCK

    condition = task.get("conblevel")
    if isinstance(condition, list) and len(condition) >= 2:
        need = _as_int(condition[1], 0)
        if need > 0 and _branch_level(bucket, condition[0]) < need:
            state = TASK_STATE_LOCK

    dive = _as_int(task.get("dive"), 0)
    if state == TASK_STATE_UNLOCK and dive > 0 and _reflect_level(bucket) < dive:
        state = TASK_STATE_LOCK

    cd_time = 0
    if state == TASK_STATE_UNLOCK:
        kind = _cd_kind(task)
        finished = _as_int((bucket.get("taskLastFinish") or {}).get(str(task_id)), 0)
        if kind == TASK_CD_FIXED:
            if finished >= _refresh_point(now, task.get("cd") or []):
                state = TASK_STATE_CD
                cd_time = max(_refresh_point(now, task.get("cd") or [], forward=True) - now, 0)
        elif kind == TASK_CD_INTERVAL and finished > 0:
            left = finished + _interval_seconds(task) - now
            if left > 0:
                state = TASK_STATE_CD
                cd_time = left

    return {"taskId": str(task_id), "state": state, "cdTime": int(cd_time)}


def _task_list(bucket, now=None):
    now = int(time.time()) if now is None else int(now)
    entries = []
    for task_id, task in _task_table().items():
        if not isinstance(task, dict):
            continue
        if not _in_window(task, now):
            continue
        entries.append(_task_state(bucket, task_id, task, now))
    entries.sort(key=lambda item: item["taskId"])
    return entries


# ---------------------------------------------------------------------------
# 拳脚数据存储


def _default_technique(branch_id):
    technique_id = DEFAULT_TECHNIQUE_BY_BRANCH[branch_id]
    return {
        str(technique_id): {
            "branchId": int(branch_id),
            "id": technique_id,
            "lv": 1,
        }
    }


def _new_branch(branch_id):
    return {
        "exp": DEFAULT_BRANCH_EXP,
        "costTechnique": 0,
        "techniqueList": _default_technique(branch_id),
        "characterInUse": [],
        "characterUnused": [],
    }


def _ensure_branch(bucket, branch_id):
    """取出分支数据; 未知/缺失的分支按空分支补齐 (不写死默认技巧)。"""
    branch_id = str(branch_id)
    branch_info = bucket.setdefault("branchInfo", {})
    branch = branch_info.get(branch_id)
    if isinstance(branch, dict):
        return branch
    if branch_id in DEFAULT_TECHNIQUE_BY_BRANCH:
        branch = _new_branch(branch_id)
    else:
        branch = {
            "exp": 0,
            "costTechnique": 0,
            "techniqueList": {},
            "characterInUse": [],
            "characterUnused": [],
        }
    branch_info[branch_id] = branch
    return branch


def _new_bucket():
    return {
        "accpoint": 0,
        "reflectExp": 0,
        "feelPoint": 0,
        "characterPoint": 0,
        "guajiInfo": {},
        "branchInfo": {branch_id: _new_branch(branch_id) for branch_id in BRANCH_IDS},
        "taskLastFinish": {},
        "created_at": int(time.time()),
    }


def _normalize_branch(branch, branch_id):
    changed = False
    if not isinstance(branch.get("techniqueList"), dict):
        branch["techniqueList"] = {}
        changed = True
    for field in ("characterInUse", "characterUnused"):
        if not isinstance(branch.get(field), list):
            branch[field] = []
            changed = True
    for field in ("exp", "costTechnique"):
        if not _is_number(branch.get(field)):
            branch[field] = 0
            changed = True
    # 老版本 mock 建出来的空分支 (exp=0 且没有技巧) 按抓包默认值补齐
    if not branch["techniqueList"] and branch["exp"] <= 0:
        branch["exp"] = DEFAULT_BRANCH_EXP
        branch["techniqueList"] = _default_technique(branch_id)
        changed = True
    return changed


def _normalize_bucket(bucket):
    changed = False
    for field in ("accpoint", "reflectExp", "feelPoint", "characterPoint"):
        if not _is_number(bucket.get(field)):
            bucket[field] = 0
            changed = True
    if not isinstance(bucket.get("taskLastFinish"), dict):
        bucket["taskLastFinish"] = {}
        changed = True

    guaji = bucket.get("guajiInfo")
    if not isinstance(guaji, dict):
        guaji = {}
        bucket["guajiInfo"] = guaji
        changed = True
    if guaji and not guaji.get("taskId"):
        guaji.clear()
        changed = True
    elif guaji:
        for field in ("startTime", "speedUpTime"):
            if not _is_number(guaji.get(field)):
                guaji[field] = 0
                changed = True
        guaji["taskId"] = str(guaji.get("taskId"))

    branch_info = bucket.get("branchInfo")
    if not isinstance(branch_info, dict):
        branch_info = {}
        bucket["branchInfo"] = branch_info
        changed = True
    for branch_id in BRANCH_IDS:
        branch = branch_info.get(branch_id)
        if not isinstance(branch, dict):
            branch_info[branch_id] = _new_branch(branch_id)
            changed = True
            continue
        changed = _normalize_branch(branch, branch_id) or changed
    return changed


def _bucket(ctx, userid):
    """取出 (必要时创建) 拳脚数据; 与 state 里的其他 feature bucket 一样原地修改。"""
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("fist", {})
        key = str(userid)
        bucket = root.get(key)
        if not isinstance(bucket, dict):
            bucket = _new_bucket()
            root[key] = bucket
            ctx["state"]._changed()
            return bucket
        if _normalize_bucket(bucket):
            ctx["state"]._changed()
        return bucket


def _save_bucket(ctx, userid, bucket):
    with ctx["state"]._lock:
        ctx["state"]._state.setdefault("fist", {})[str(userid)] = bucket
        ctx["state"]._changed()


# 固身元气 / 特性见解 = 服务器物品 (AwardType.Net)。客户端调试层的
# "增加固身元气点数" 走的是通用的 XinShenSystem:addItemCount -> addItemCount 接口,
# 再用返回的 count 调 setAccpoint/setCharacterPoint, 所以这两个资源和
# practice.itemMap (practice.getItemCount/addItemCount 用的那份) 是同一个计数。
# 这里读的时候以物品表为准, 写的时候两边一起落, 老存档只写了 fist 的也照样能读。


def _resource_entry(ctx, userid, item_id):
    with ctx["state"]._lock:
        practice = (ctx["state"]._state.get("practice") or {}).get(str(userid))
        item_map = practice.get("itemMap") if isinstance(practice, dict) else None
        item = item_map.get(item_id) if isinstance(item_map, dict) else None
        if isinstance(item, dict):
            return _as_int(item.get("count"), 0), True
    return 0, False


def _current_resource(ctx, userid, item_id, bucket):
    count, exists = _resource_entry(ctx, userid, item_id)
    return count if exists else _as_int(bucket.get(item_id), 0)


def _apply_resource(ctx, userid, item_id, bucket, delta):
    """按 delta 调整服务器资源, 同时写 practice.itemMap 与拳脚数据。"""
    with ctx["state"]._lock:
        value = max(_current_resource(ctx, userid, item_id, bucket) + int(delta), 0)
        bucket[item_id] = value
        practice = ctx["state"]._state.setdefault("practice", {}).setdefault(str(userid), {})
        item_map = practice.setdefault("itemMap", {})
        item = item_map.get(item_id)
        if not isinstance(item, dict):
            item = {}
            item_map[item_id] = item
        item["count"] = value
        ctx["state"]._changed()
    return value


def _payload(ctx, userid, bucket, data_ver):
    return {
        "dataVer": int(data_ver),
        "accpoint": _current_resource(ctx, userid, "accpoint", bucket),
        "guajiInfo": copy.deepcopy(bucket.get("guajiInfo") or {}),
        "reflectExp": _as_int(bucket.get("reflectExp"), 0),
        "feelPoint": _as_int(bucket.get("feelPoint"), 0),
        "characterPoint": _current_resource(ctx, userid, "characterPoint", bucket),
        "branchInfo": copy.deepcopy(bucket.get("branchInfo") or {}),
    }


def _require_unlocked(ctx):
    """返回 (userid, bucket, error_response)。"""
    userid = _userid(ctx)
    if userid <= 0:
        return 0, None, build_response_body({}, errcode=552, errmsg="userid not found")
    if not _is_unlocked(ctx, userid):
        return userid, None, build_response_body(
            {}, errcode=ERR_NOT_UNLOCKED, errmsg=ERRMSG_NOT_UNLOCKED)
    return userid, _bucket(ctx, userid), None


def _find_technique(bucket, technique_id):
    """返回 (branchId, technique)；找不到返回 (None, None)。"""
    key = str(technique_id)
    for branch_id, branch in (bucket.get("branchInfo") or {}).items():
        if not isinstance(branch, dict):
            continue
        technique = (branch.get("techniqueList") or {}).get(key)
        if isinstance(technique, dict):
            return branch_id, technique
    return None, None


def _technique_branch_id(technique_id):
    """10001->10010, 20001->10020 ... 由技巧 id 反推分支 (用于新增技巧)。"""
    value = _as_int(technique_id, 0)
    index = value // 10000
    branch_id = str(10000 + index * 10)
    return branch_id if branch_id in BRANCH_IDS else None


def _add_inventory_item(ctx, userid, item_id, count):
    """剧情道具走 mock 的服务器物品表 (与 practice.getItemCount 同一份)。"""
    if not item_id or count == 0:
        return
    with ctx["state"]._lock:
        inventory = ctx["state"]._state.setdefault("inventory_items", {}).setdefault(str(userid), {})
        inventory[item_id] = max(_as_int(inventory.get(item_id), 0), 0) + int(count)
        ctx["state"]._changed()


# ---------------------------------------------------------------------------
# 接口


@route(["POST"], "get_fist_info")
def get_fist_info(ctx):
    """拉取拳脚数据; 未解锁按抓包返回 errcode=2。"""
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    return build_response_body(_payload(ctx, userid, bucket, _read_data_ver(ctx, userid)))


@route(["POST"], "create_fist_info")
def create_fist_info(ctx):
    """前置任务完成后的创建: 建数据 + 置解锁标记。

    创建时的默认值与抓包一致 (五分支 exp=1 + 默认技巧 lv1)。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _bucket(ctx, userid)
    data_ver = _set_unlock_flag(ctx, userid)
    return build_response_body(_payload(ctx, userid, bucket, data_ver))


@route(["POST"], "get_fist_tasks")
def get_fist_tasks(ctx):
    """修行任务列表: data.list = [{taskId, state, cdTime}]。"""
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    data_ver = _read_data_ver(ctx, userid)
    return build_response_body({
        "dataVer": data_ver,
        "list": _task_list(bucket),
    })


@route(["POST"], "start_fist_task")
def start_fist_task(ctx):
    """开始修行: 客户端只取 data.startTime, 并在本地把 speedUpTime 置 0。

    同一时刻只允许一条修行 (客户端有进行中的修行时直接进 FistFootGuaJi 界面,
    要换任务必须先 stop_fist_task), 所以这里挡掉并发开始。
    """
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    task_id = str(_body(ctx).get("taskId") or "")
    if task_id not in _task_table():
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="未知修行任务")
    if (bucket.get("guajiInfo") or {}).get("taskId"):
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="已有进行中的修行")
    now = int(time.time())
    with ctx["state"]._lock:
        bucket["guajiInfo"] = {"taskId": task_id, "startTime": now, "speedUpTime": 0}
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"startTime": now, "dataVer": data_ver})


@route(["POST"], "stop_fist_task")
def stop_fist_task(ctx):
    """终止修行: 客户端直接清空 guajiInfo, 不发奖励。"""
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    with ctx["state"]._lock:
        bucket["guajiInfo"] = {}
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"dataVer": data_ver})


@route(["POST"], "finish_fist_task")
def finish_fist_task(ctx):
    """完成修行: 返回任务奖励表 (客户端按奖励表在本地加属性/道具)。

    奖励格式与 script.fistFoot.tasks 的 awards 一致, 见 FistFootSystem:getFistTaskReward:
        [1, branchId, exp] / [2, exp] / [3, itemId, num] / [4, "accpoint"|"characterPoint", num]
    客户端只取 data.reward / data.feelPoint / data.msg:
      * 背包道具奖励在 bagEnough==1 时由客户端本地 addItemCount, 这里同步入账;
        bagEnough==0 时客户端显示"背包空间不足", 物品改走江湖邮驿 (challenge_rewards 同款)。
      * 服务端同步记账, 这样下一次 get_fist_info 与客户端本地值一致。
    """
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    body = _body(ctx)
    guaji = bucket.get("guajiInfo") or {}
    running = str(guaji.get("taskId") or "")
    task_id = str(body.get("taskId") or running)
    if not running or task_id != running:
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="当前没有进行中的修行")
    task = _task_table().get(task_id)
    if not isinstance(task, dict):
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="未知修行任务")
    bag_enough = _as_int(body.get("bagEnough"), 0)
    now = int(time.time())
    rewards = copy.deepcopy(task.get("awards") or [])
    messages = []
    mail_items = []
    with ctx["state"]._lock:
        for reward in rewards:
            if not isinstance(reward, list) or len(reward) < 2:
                continue
            kind = _as_int(reward[0], 0)
            if kind == AWARD_BRANCH_EXP and len(reward) >= 3:
                branch = _ensure_branch(bucket, reward[1])
                branch["exp"] = _as_int(branch.get("exp"), 0) + _as_int(reward[2], 0)
            elif kind == AWARD_REFLECT_EXP:
                bucket["reflectExp"] = _as_int(bucket.get("reflectExp"), 0) + _as_int(reward[1], 0)
            elif kind == AWARD_ITEM and len(reward) >= 3:
                item_id = str(reward[1])
                num = _as_int(reward[2], 0)
                if bag_enough == 1:
                    _add_inventory_item(ctx, userid, item_id, num)
                elif num > 0:
                    mail_items.append({"id": item_id, "num": num, "state": 0})
            elif kind == AWARD_NET and len(reward) >= 3:
                if reward[1] in ("accpoint", "characterPoint"):
                    _apply_resource(ctx, userid, str(reward[1]), bucket, _as_int(reward[2], 0))
        if _in_cd_task(task):
            bucket.setdefault("taskLastFinish", {})[task_id] = now
        bucket["guajiInfo"] = {}
        if mail_items:
            ctx["state"].add_mail(userid, {
                "title": "拳脚修行奖励",
                "content": "背包不足，拳脚修行物品奖励已通过邮驿发放。",
                "rewards": {"loc_items": mail_items},
            })
            messages.append("物品奖励已发送至江湖邮驿")
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({
        "reward": rewards,
        "feelPoint": _as_int(bucket.get("feelPoint"), 0),
        "dataVer": data_ver,
        "msg": "；".join(messages),
    })


def _in_cd_task(task):
    return _cd_kind(task) in (TASK_CD_INTERVAL, TASK_CD_FIXED)


@route(["POST"], "expedite_fist_task")
def expedite_fist_task(ctx):
    """加速修行: 消耗 cost 点固身元气换 cost 小时修行时间。"""
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    body = _body(ctx)
    cost = _as_int(body.get("cost"), 0)
    if cost <= 0:
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="加速消耗无效")
    guaji = bucket.get("guajiInfo") or {}
    if not guaji.get("taskId"):
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="当前没有进行中的修行")
    if _current_resource(ctx, userid, "accpoint", bucket) < cost:
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="固身元气不足")
    speed_up = cost * SPEED_UP_SECONDS_PER_COST
    with ctx["state"]._lock:
        _apply_resource(ctx, userid, "accpoint", bucket, -cost)
        guaji["speedUpTime"] = _as_int(guaji.get("speedUpTime"), 0) + speed_up
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"cost": cost, "speedUpTime": speed_up, "dataVer": data_ver})


@route(["POST"], "updata_fist_flag")
def updata_fist_flag(ctx):
    """增删拳脚系统标记 (地图结果 "更新拳脚系统标记" 调用)。"""
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    role = _archive(ctx, userid)
    if not isinstance(role, dict):
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="存档不存在")
    flags = role.get("_inherit_flags")
    if not isinstance(flags, dict):
        flags = {}
        role["_inherit_flags"] = flags
    for value in _flag_list(body.get("addFlags")):
        flags[value] = 1
    for value in _flag_list(body.get("deleteFlags")):
        flags.pop(value, None)
    data_ver = _bump_data_ver(ctx, userid, role)
    _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"dataVer": data_ver})


def _flag_list(value):
    if isinstance(value, list):
        return [str(item) for item in value if str(item or "").strip()]
    if isinstance(value, str):
        return [item for item in (part.strip() for part in value.split(";")) if item]
    return []


# ---------------------------------------------------------------------------
# 调试层 (DebugLayer/TestLayer) 用的调整接口


@route(["POST"], "test_set_fist_branch_level")
def test_set_fist_branch_level(ctx):
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    body = _body(ctx)
    branch_id = str(body.get("branchId") or "")
    if branch_id not in BRANCH_IDS:
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="分支id无效")
    exp = max(_as_int(body.get("branchExp"), 0), 0)
    with ctx["state"]._lock:
        branch = bucket.setdefault("branchInfo", {}).setdefault(branch_id, _new_branch(branch_id))
        branch["exp"] = exp
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"dataVer": data_ver, "branchId": branch_id, "exp": exp})


@route(["POST"], "test_set_fist_reflect_level")
def test_set_fist_reflect_level(ctx):
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    exp = max(_as_int(_body(ctx).get("exp"), 0), 0)
    with ctx["state"]._lock:
        bucket["reflectExp"] = exp
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"dataVer": data_ver, "reflectExp": exp})


@route(["POST"], "test_set_fist_technique_level")
def test_set_fist_technique_level(ctx):
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    body = _body(ctx)
    technique_id = _as_int(body.get("techniqueId"), 0)
    level = max(_as_int(body.get("level"), 1), 1)
    if technique_id <= 0:
        return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="技巧id无效")
    with ctx["state"]._lock:
        branch_id, technique = _find_technique(bucket, technique_id)
        if technique is None:
            branch_id = _technique_branch_id(technique_id)
            if branch_id is None:
                return build_response_body({}, errcode=ERR_BAD_REQUEST, errmsg="技巧id无效")
            branch = bucket.setdefault("branchInfo", {}).setdefault(branch_id, _new_branch(branch_id))
            technique = {"branchId": int(branch_id), "id": technique_id, "lv": level}
            branch.setdefault("techniqueList", {})[str(technique_id)] = technique
        else:
            technique["lv"] = level
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"dataVer": data_ver, "techniqueId": technique_id, "lv": level})


@route(["POST"], "test_add_fist_feel_point")
def test_add_fist_feel_point(ctx):
    userid, bucket, error = _require_unlocked(ctx)
    if error is not None:
        return error
    number = max(_as_int(_body(ctx).get("number"), 0), 0)
    with ctx["state"]._lock:
        bucket["feelPoint"] = _as_int(bucket.get("feelPoint"), 0) + number
        role = _archive(ctx, userid) or {}
        data_ver = _bump_data_ver(ctx, userid, role)
        _save_bucket(ctx, userid, bucket)
        _put_role(ctx, userid, role, data_ver=data_ver)
    return build_response_body({"dataVer": data_ver, "feelPoint": bucket.get("feelPoint", 0)})
