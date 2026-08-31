# -*- coding: utf-8 -*-
"""每日任务活动:
  GET  get_daily_task_list
  POST add_daily_task_point
  POST get_daily_task_reward

任务配置来自 fzjh_lua/assets/res/script/activity/dailyTask.lua
奖励商品元宝 id 来自 store/shoplist.lua: 400034 (itemId=yuanbao)
"""

from __future__ import annotations

import copy
import time
from datetime import datetime

from protocol import build_response_body
from server import route


# dailyTask.lua Sheet1
DAILY_TASKS = [
    {"id": 1, "taskid": "qiandao", "name": "每日首次签到", "points": 10},
    {"id": 2, "taskid": "mengjing", "name": "每日首次完成梦境", "points": 70},
    {"id": 3, "taskid": "paiqian", "name": "每日首次派遣门客", "points": 70},
    {"id": 4, "taskid": "xianshi", "name": "每日首次购买限时礼包", "points": 150},
    {"id": 5, "taskid": "shangci", "name": "每日首次使用银票赏赐", "points": 70},
    {"id": 6, "taskid": "tiaoxi", "name": "每日首次完成调息", "points": 70},
    {"id": 7, "taskid": "guaji", "name": "每日首次领取挂机收益", "points": 50},
    {"id": 8, "taskid": "liangong", "name": "每日首次领取练功收益", "points": 70},
    {"id": 9, "taskid": "qingan", "name": "每日首次进行师门请安", "points": 10},
    {"id": 10, "taskid": "guanggao", "name": "每日首次在观影堂观影", "points": 100},
    {"id": 11, "taskid": "yiwen", "name": "每日首次完成轶闻挑战", "points": 70},
]

# 积分档位 + 每档 100 元宝(商品 id=400034)
REWARD_GRADES = [10, 50, 100, 150, 300]
YUANBAO_GOODS_ID = "400034"
YUANBAO_REWARD = [{"id": YUANBAO_GOODS_ID, "num": 100}]


def _header_userid(ctx):
    try:
        return int(ctx.get("headers", {}).get("userid") or 0)
    except (TypeError, ValueError):
        return 0


def _body_dict(ctx):
    body = ctx.get("body")
    return body if isinstance(body, dict) else {}


def _as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return int(default)


def _today_key():
    return datetime.now().strftime("%Y-%m-%d")


def _task_by_key(task_key):
    key = str(task_key or "")
    for task in DAILY_TASKS:
        if str(task["id"]) == key or task["taskid"] == key:
            return task
    return None


def _bucket(ctx, userid):
    today = _today_key()
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("daily_tasks", {})
        key = str(userid)
        bucket = root.get(key)
        if not isinstance(bucket, dict) or bucket.get("day") != today:
            bucket = {
                "day": today,
                "daily_point": 0,
                "done": {},  # taskid -> True
                "claimed": {},  # rid -> True
                "updated_at": int(time.time()),
            }
            root[key] = bucket
            ctx["state"]._changed()
        return bucket


def _save_bucket(ctx, userid, bucket):
    with ctx["state"]._lock:
        ctx["state"]._state.setdefault("daily_tasks", {})[str(userid)] = copy.deepcopy(bucket)
        ctx["state"]._changed()


def _reward_state(bucket, rid, grade):
    if bucket.get("claimed", {}).get(str(rid)):
        return 2
    if int(bucket.get("daily_point") or 0) >= int(grade):
        return 1
    return 0


def _build_task_list(bucket):
    values = []
    done = bucket.get("done") or {}
    for task in DAILY_TASKS:
        values.append({
            "tid": task["id"],
            "state": 1 if done.get(task["taskid"]) else 0,
        })
    return values


def _build_reward_list(bucket):
    values = []
    for idx, grade in enumerate(REWARD_GRADES, start=1):
        rid = idx
        values.append({
            "rid": rid,
            "grade": grade,
            "state": _reward_state(bucket, rid, grade),
            "reward": copy.deepcopy(YUANBAO_REWARD),
        })
    return values


def _list_payload(bucket):
    return {
        "act_name": "每日任务",
        "detail_desc": [
            "完成每日任务可获得积分。",
            "积分达到对应档位后可领取奖励。",
            "奖励每日刷新，请及时领取。",
        ],
        "daily_point": int(bucket.get("daily_point") or 0),
        "task_list": _build_task_list(bucket),
        "reward_list": _build_reward_list(bucket),
    }


@route(["GET", "POST"], "get_daily_task_list")
def get_daily_task_list(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    ctx["state"].ensure_account(userid)
    bucket = _bucket(ctx, userid)
    return build_response_body(_list_payload(bucket))


@route(["POST"], "add_daily_task_point")
def add_daily_task_point(ctx):
    """请求: {task_id=taskType字符串或数字id}
    成功: {addPoint=N}
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    task_key = body.get("task_id")
    task = _task_by_key(task_key)
    if task is None:
        return build_response_body({"addPoint": 0}, errcode=404, errmsg="task not found")
    bucket = _bucket(ctx, userid)
    done = bucket.setdefault("done", {})
    if done.get(task["taskid"]):
        # 已完成: 成功但加 0 分, 避免弹错误
        return build_response_body({"addPoint": 0, "daily_point": int(bucket.get("daily_point") or 0)})
    add_point = int(task.get("points") or 0)
    done[task["taskid"]] = True
    bucket["daily_point"] = int(bucket.get("daily_point") or 0) + add_point
    bucket["updated_at"] = int(time.time())
    _save_bucket(ctx, userid, bucket)
    return build_response_body({
        "addPoint": add_point,
        "daily_point": int(bucket["daily_point"]),
    })


@route(["POST"], "get_daily_task_reward")
def get_daily_task_reward(ctx):
    """请求: {rid, isEmail, dataVer, currencyVersion}
    成功: {reward=[{id,num}], dataVer, currencyVersion, msg?}
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    rid = _as_int(body.get("rid"), 0)
    if rid <= 0 or rid > len(REWARD_GRADES):
        return build_response_body({}, errcode=404, errmsg="reward not found")
    grade = REWARD_GRADES[rid - 1]
    bucket = _bucket(ctx, userid)
    state = _reward_state(bucket, rid, grade)
    if state == 2:
        return build_response_body({}, errcode=1, errmsg="此奖励已领取")
    if state == 0:
        return build_response_body({}, errcode=1, errmsg="今日积分不足，不可领取")
    claimed = bucket.setdefault("claimed", {})
    claimed[str(rid)] = True
    bucket["updated_at"] = int(time.time())
    _save_bucket(ctx, userid, bucket)

    role = ctx["state"].get_archive(userid) or {}
    data_ver = _as_int(body.get("dataVer"), 0)
    if data_ver <= 0:
        try:
            data_ver = int(role.get("dataVer") or 0) + 1
        except (TypeError, ValueError):
            data_ver = 1
    else:
        data_ver = data_ver + 1
    currency_version = _as_int(body.get("currencyVersion"), 0) + 1
    return build_response_body({
        "reward": copy.deepcopy(YUANBAO_REWARD),
        "dataVer": data_ver,
        "currencyVersion": currency_version,
        "msg": "领取成功",
    })
