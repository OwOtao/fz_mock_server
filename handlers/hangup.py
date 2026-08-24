# -*- coding: utf-8 -*-
"""挂机任务相关接口。

客户端 HangUpTaskSystem:
  record_click_task      -> 点击任务成功即可(奖励客户端本地加)
  start_hang_up_task     -> 需要 data.start_time / data.version
  stop_hang_up_task      -> 成功即可(收益客户端本地结算)
  get_hangUp_yashi_time  -> data 为数组 [{start_time,end_time}, ...]
  check_has_yashi        -> 兼容补齐, 返回 create_time/expired_time
"""

from __future__ import annotations

import copy
import time

from protocol import build_response_body
from server import route


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


def _bucket(ctx, userid):
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("hang_up", {})
        key = str(userid)
        bucket = root.get(key)
        if not isinstance(bucket, dict):
            bucket = {
                "version": 1,
                "current": None,
                "clicks": [],
                "yashi": {
                    "create_time": 0,
                    "expired_time": 0,
                },
            }
            root[key] = bucket
            ctx["state"]._changed()
        bucket.setdefault("version", 1)
        bucket.setdefault("current", None)
        bucket.setdefault("clicks", [])
        bucket.setdefault("yashi", {"create_time": 0, "expired_time": 0})
        return bucket


def _save_bucket(ctx, userid, bucket):
    with ctx["state"]._lock:
        ctx["state"]._state.setdefault("hang_up", {})[str(userid)] = copy.deepcopy(bucket)
        ctx["state"]._changed()


def _next_version(bucket):
    version = _as_int(bucket.get("version"), 1) + 1
    bucket["version"] = version
    return version


@route(["POST"], "record_click_task")
def record_click_task(ctx):
    """点击型挂机任务上报。
    请求: {task_id, reward={attr:value}, extra={...}}
    成功: {}
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    bucket = _bucket(ctx, userid)
    bucket.setdefault("clicks", []).append({
        "task_id": body.get("task_id"),
        "reward": body.get("reward") if isinstance(body.get("reward"), dict) else {},
        "extra": body.get("extra") if isinstance(body.get("extra"), dict) else {},
        "ts": int(time.time()),
    })
    # 仅保留最近 50 条
    if len(bucket["clicks"]) > 50:
        bucket["clicks"] = bucket["clicks"][-50:]
    _save_bucket(ctx, userid, bucket)
    return build_response_body({})


@route(["POST"], "start_hang_up_task")
def start_hang_up_task(ctx):
    """开始挂机。
    请求: {version, task_id, extra={...}}
    成功: {start_time, version}
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    bucket = _bucket(ctx, userid)
    now = int(time.time())
    version = _next_version(bucket)
    bucket["current"] = {
        "task_id": body.get("task_id"),
        "start_time": now,
        "version": version,
        "extra": body.get("extra") if isinstance(body.get("extra"), dict) else {},
        "client_version": _as_int(body.get("version"), 0),
    }
    _save_bucket(ctx, userid, bucket)
    return build_response_body({
        "start_time": now,
        "version": version,
    })


@route(["POST"], "stop_hang_up_task")
def stop_hang_up_task(ctx):
    """停止挂机。
    请求: {version, task_id, extra={...}, reward={...}}
    成功: {version}
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    bucket = _bucket(ctx, userid)
    version = _next_version(bucket)
    current = bucket.get("current") if isinstance(bucket.get("current"), dict) else {}
    bucket["last_stop"] = {
        "task_id": body.get("task_id") or current.get("task_id"),
        "reward": body.get("reward") if isinstance(body.get("reward"), dict) else {},
        "extra": body.get("extra") if isinstance(body.get("extra"), dict) else {},
        "stopped_at": int(time.time()),
        "version": version,
    }
    bucket["current"] = None
    _save_bucket(ctx, userid, bucket)
    return build_response_body({"version": version})


@route(["POST"], "get_hangUp_yashi_time")
def get_hang_up_yashi_time(ctx):
    """挂机期间雅士生效时间段。
    成功 data: [{start_time, end_time}, ...]
    无雅士时返回空数组即可。
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body([], errcode=552, errmsg="userid not found")
    bucket = _bucket(ctx, userid)
    yashi = bucket.get("yashi") or {}
    now = int(time.time())
    create_time = _as_int(yashi.get("create_time"), 0)
    expired_time = _as_int(yashi.get("expired_time"), 0)
    values = []
    current = bucket.get("current") if isinstance(bucket.get("current"), dict) else None
    if current and expired_time > now and create_time > 0:
        start_time = max(_as_int(current.get("start_time"), now), create_time)
        end_time = min(now, expired_time)
        if end_time > start_time:
            values.append({"start_time": start_time, "end_time": end_time})
    return build_response_body(values)


@route(["GET", "POST"], "check_has_yashi")
def check_has_yashi(ctx):
    """检查是否拥有雅士。
    兼容返回 create_time/expired_time; 默认无雅士。
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _bucket(ctx, userid)
    yashi = bucket.get("yashi") or {"create_time": 0, "expired_time": 0}
    return build_response_body({
        "create_time": _as_int(yashi.get("create_time"), 0),
        "expired_time": _as_int(yashi.get("expired_time"), 0),
        "yashi": 1 if _as_int(yashi.get("expired_time"), 0) > int(time.time()) else 0,
    })
