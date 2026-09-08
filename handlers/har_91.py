# -*- coding: utf-8 -*-
"""2026-09-01 抓包所覆盖的游戏接口。

配置型活动直接以 ``so/har_decrypt_91/entries`` 中的已解密响应作为字段基线，
避免手抄大型奖池时丢字段；仓储、历练、登录奖励、货币等已实现的可变字段
由本地 StateStore 覆盖。
"""

from __future__ import annotations

import copy
import hashlib
import json
import os
import time

from handlers.basic import (
    _currency_balance,
    _get_yuanbao_balance,
    _set_currency_balance,
    _training_bucket,
    get_game_activity as _fallback_game_activity,
    get_spring_festival_status as _fallback_spring_festival_status,
)
from handlers.homeland import _owned_bucket
from handlers.service import get_login_reward_list as _fallback_login_reward_list
from protocol import build_response_body
from server import route


_CAPTURE_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "so",
    "har_decrypt_91",
    "entries",
)
_CAPTURE_CACHE = {}


def _capture_data(filename):
    """读取一份已解密抓包的 data，并返回隔离的深拷贝。"""
    cached = _CAPTURE_CACHE.get(filename)
    if cached is None:
        path = os.path.join(_CAPTURE_DIR, filename)
        with open(path, "r", encoding="utf-8") as stream:
            entry = json.load(stream)
        response = json.loads(entry.get("response_plain") or "{}")
        cached = response.get("data")
        _CAPTURE_CACHE[filename] = cached
    return copy.deepcopy(cached)


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


def _ok(data=None):
    return build_response_body({} if data is None else data)


def _require_user(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return 0, build_response_body({}, errcode=552, errmsg="userid not found")
    ctx["state"].ensure_account(userid)
    return userid, None


def _feature_bucket(ctx, feature, userid):
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("har_91_features", {})
        feature_root = root.setdefault(feature, {})
        bucket = feature_root.get(str(userid))
        if not isinstance(bucket, dict):
            bucket = {}
            feature_root[str(userid)] = bucket
            ctx["state"]._changed()
        return bucket


def _data_version(ctx, userid, requested=0):
    role = ctx["state"].get_archive(userid) or {}
    system = role.get("serverActionSystem")
    system_version = system.get("dataVersion") if isinstance(system, dict) else 0
    return max(
        _as_int(requested),
        _as_int(role.get("dataVer")),
        _as_int(system_version),
    )


def _currency_version(ctx, userid, requested=0):
    role = ctx["state"].get_archive(userid) or {}
    account = ctx["state"].get_account(userid) or {}
    return max(
        _as_int(requested),
        _as_int(role.get("currencyVersion")),
        _as_int(account.get("currency_version")),
    )


# ---------------------------------------------------------------------------
# 远端仓库 / 客户端数据 / 神兵淬炼


def _storage_version(items):
    raw = json.dumps(items, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.md5(raw.encode("utf-8")).hexdigest()


def _normalize_storage_item(value):
    if not isinstance(value, dict):
        return None
    item_id = str(value.get("itemId") or value.get("id") or "").strip()
    if not item_id:
        return None
    return {
        "itemId": item_id,
        "info": copy.deepcopy(value.get("info", "")),
        "total": max(_as_int(value.get("total", value.get("count", 0))), 0),
        "dsc": value.get("dsc"),
        "update_time": _as_int(value.get("update_time"), int(time.time())),
    }


def _storage_bucket(ctx, userid, name):
    name = str(name or "default").strip() or "default"
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("remote_storages", {})
        user_root = root.setdefault(str(userid), {})
        bucket = user_root.get(name)
        if not isinstance(bucket, dict):
            items = {}
            role = ctx["state"].get_archive(userid) or {}
            seed = role.get("ckitems")
            if isinstance(seed, list):
                for source in seed:
                    item = _normalize_storage_item(source)
                    if item is not None and item["total"] > 0:
                        items[item["itemId"]] = item
            bucket = {"items": items, "version": _storage_version(items)}
            user_root[name] = bucket
            ctx["state"]._changed()
        if not isinstance(bucket.get("items"), dict):
            bucket["items"] = {}
        if not isinstance(bucket.get("version"), str) or not bucket["version"]:
            bucket["version"] = _storage_version(bucket["items"])
        return bucket


def _storage_payload(bucket, legacy=False, legacy_version=0, size=1000):
    values = {
        key: copy.deepcopy(value)
        for key, value in bucket.get("items", {}).items()
        if isinstance(value, dict) and _as_int(value.get("total")) > 0
    }
    if legacy:
        return {
            "ver": max(_as_int(legacy_version), 1),
            "list": list(values.values()),
            "size": size,
        }
    return {"ver": bucket["version"], "list": values, "size": size}


@route(["POST"], "get_ckitems_list")
def get_ckitems_list(ctx):
    """2.1.01 返回 object/md5；数字 ver 请求仍兼容旧 array/number。"""
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    bucket = _storage_bucket(ctx, userid, body.get("ckname"))
    role = ctx["state"].get_archive(userid) or {}
    size = max(_as_int(role.get("ckLimit"), 1000), 0)
    requested_version = body.get("ver")
    legacy = isinstance(requested_version, (int, float)) or (
        isinstance(requested_version, str) and requested_version.isdigit()
    )
    return _ok(_storage_payload(bucket, legacy, requested_version, size))


@route(["POST"], "get_client_data")
def get_client_data(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    bucket = _storage_bucket(ctx, userid, body.get("type"))
    offset = max(_as_int(body.get("offset")), 0)
    count = min(max(_as_int(body.get("count"), 200), 1), 1000)
    values = list(bucket["items"].items())[offset:offset + count]
    return _ok({
        "list": {key: copy.deepcopy(value) for key, value in values},
        "ver": bucket["version"],
        "flag": 1,
    })


@route(["POST"], "upload_client_data")
def upload_client_data(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    data = body.get("data")
    if not isinstance(data, (list, dict)):
        return build_response_body({}, errcode=400, errmsg="invalid client data")
    bucket = _storage_bucket(ctx, userid, body.get("type"))
    sources = data.values() if isinstance(data, dict) else data
    with ctx["state"]._lock:
        for source in sources:
            item = _normalize_storage_item(source)
            if item is not None:
                bucket["items"][item["itemId"]] = item
        bucket["version"] = _storage_version(bucket["items"])
        ctx["state"]._changed()
    return _ok({"ver": bucket["version"]})


@route(["POST"], "beput_ckitems")
def beput_ckitems(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    item_id = str(body.get("itemId") or "").strip()
    total = max(_as_int(body.get("total", body.get("count", 1))), 0)
    if not item_id or total <= 0:
        return build_response_body({}, errcode=400, errmsg="invalid storage item")
    bucket = _storage_bucket(ctx, userid, body.get("ckname"))
    with ctx["state"]._lock:
        current = bucket["items"].get(item_id) or {
            "itemId": item_id, "info": "", "total": 0, "dsc": None,
        }
        current["info"] = copy.deepcopy(body.get("info", current.get("info", "")))
        current["total"] = _as_int(current.get("total")) + total
        current["update_time"] = int(time.time())
        bucket["items"][item_id] = current
        bucket["version"] = _storage_version(bucket["items"])
        ctx["state"]._changed()
    result = copy.deepcopy(current)
    result["ver"] = bucket["version"]
    return _ok(result)


@route(["POST"], "outgoing_ckitems")
def outgoing_ckitems(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    item_id = str(body.get("itemId") or "").strip()
    count = max(_as_int(body.get("count"), 1), 0)
    if not item_id or count <= 0:
        return build_response_body({}, errcode=400, errmsg="invalid storage item")
    bucket = _storage_bucket(ctx, userid, body.get("ckname"))
    requested_version = str(body.get("ver") or "")
    if requested_version and requested_version != bucket["version"]:
        return build_response_body(
            {"ver": bucket["version"]}, errcode=2, errmsg="仓库数据已更新，请刷新后重试"
        )
    with ctx["state"]._lock:
        current = bucket["items"].get(item_id)
        if not isinstance(current, dict) or _as_int(current.get("total")) < count:
            return build_response_body({}, errcode=1, errmsg="仓库物品数量不足")
        current["total"] = _as_int(current.get("total")) - count
        current["update_time"] = int(time.time())
        result = copy.deepcopy(current)
        if current["total"] <= 0:
            bucket["items"].pop(item_id, None)
        bucket["version"] = _storage_version(bucket["items"])
        ctx["state"]._changed()
    result["ver"] = bucket["version"]
    return _ok(result)


@route(["POST"], "del_all_data")
def del_all_data(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    bucket = _storage_bucket(ctx, userid, _body(ctx).get("type"))
    with ctx["state"]._lock:
        bucket["items"] = {}
        bucket["version"] = _storage_version({})
        ctx["state"]._changed()
    return _ok({"ver": bucket["version"]})


@route(["POST"], "incr_weapon_cuilian_num")
def incr_weapon_cuilian_num(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    wid = str(body.get("wid") or "").strip()
    results = body.get("results")
    total = _as_int(body.get("sum"), -1)
    if not wid or not isinstance(results, dict) or total < 0:
        return build_response_body({}, errcode=400, errmsg="invalid cuilian result")
    normalized = {}
    for item_id, value in results.items():
        if not isinstance(value, dict):
            return build_response_body({}, errcode=400, errmsg="invalid cuilian result")
        success = _as_int(value.get("sucNum"), -1)
        failed = _as_int(value.get("defNum"), -1)
        if success < 0 or failed < 0:
            return build_response_body({}, errcode=400, errmsg="invalid cuilian result")
        normalized[str(item_id)] = {"sucNum": success, "defNum": failed}
    bucket = _feature_bucket(ctx, "weapon_cuilian", userid)
    with ctx["state"]._lock:
        weapon = bucket.get(wid)
        if not isinstance(weapon, dict):
            weapon = {"sum": 0, "results": {}}
            bucket[wid] = weapon
        # sum 是累计淬炼次数；相同 sum 是网络重放，不重复累计。
        if total > _as_int(weapon.get("sum")):
            for item_id, value in normalized.items():
                aggregate = weapon.setdefault("results", {}).setdefault(
                    item_id, {"sucNum": 0, "defNum": 0}
                )
                aggregate["sucNum"] = _as_int(aggregate.get("sucNum")) + value["sucNum"]
                aggregate["defNum"] = _as_int(aggregate.get("defNum")) + value["defNum"]
            weapon["sum"] = total
            weapon["updated_at"] = int(time.time())
            ctx["state"]._changed()
    return _ok()


@route(["POST"], "get_weapon_cuilian_num")
def get_weapon_cuilian_num(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    wid = str(body.get("wid") or "").strip()
    item_id = str(body.get("itemId") or "").strip()
    bucket = _feature_bucket(ctx, "weapon_cuilian", userid)
    weapon = bucket.get(wid) if isinstance(bucket.get(wid), dict) else {}
    result = (weapon.get("results") or {}).get(item_id) or {"sucNum": 0, "defNum": 0}
    return _ok({
        "wid": wid,
        "itemId": item_id,
        "sum": _as_int(weapon.get("sum")),
        "sucNum": _as_int(result.get("sucNum")),
        "defNum": _as_int(result.get("defNum")),
    })


# ---------------------------------------------------------------------------
# 家园额外属性与成长信息


@route(["POST"], "upload_map_extra")
def upload_map_extra(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    attr = body.get("attr")
    point = _as_int(body.get("point"), -1)
    if not isinstance(attr, dict) or point < 0:
        return build_response_body({}, errcode=400, errmsg="invalid map extra")
    bucket, message = _owned_bucket(ctx, userid, body.get("mid"))
    if message:
        return build_response_body({}, errcode=403, errmsg=message)
    balance = _currency_balance(ctx, userid, "yinpiao")
    if point > balance:
        return build_response_body({"number": balance}, errcode=1, errmsg="银票不足")
    with ctx["state"]._lock:
        house = bucket.setdefault("house", {})
        extra = house.get("extra")
        if not isinstance(extra, dict):
            extra = {}
            house["extra"] = extra
        extra.update(copy.deepcopy(attr))
        bucket["version"] = _as_int(bucket.get("version"), 0) + 1
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
    if point:
        _set_currency_balance(ctx, userid, "yinpiao", balance - point)
    return _ok({"remove_point": point, "attr": copy.deepcopy(attr)})


@route(["POST"], "get_growth_info")
def get_growth_info(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    requirements = _body(ctx).get("requirement")
    if not isinstance(requirements, list):
        return build_response_body({}, errcode=400, errmsg="invalid requirement")
    result = {}
    role = ctx["state"].get_archive(userid) or {}
    snapshot = ctx["state"].snapshot()
    homeland = snapshot.get("homeland") or {}
    user_home = (homeland.get("users") or {}).get(str(userid)) or {}
    employees = user_home.get("employees") or {}
    for requirement in requirements:
        key = str(requirement)
        if key == "homeland":
            counts = {}
            for employee in employees.values():
                if not isinstance(employee, dict):
                    continue
                job = str(employee.get("job") or employee.get("jobType") or "")
                if job:
                    counts[job] = counts.get(job, 0) + 1
            result[key] = (
                {"servants": [{"job": job, "num": num} for job, num in counts.items()]}
                if counts else []
            )
        elif key == "lunjian":
            result[key] = max(_as_int(role.get("lunjianRank"), 999999), 1)
        else:
            result[key] = []
    return _ok(result)


# ---------------------------------------------------------------------------
# 限时历练


_TRAINING_TASKS = {
    "yiwen": {"id": 1, "name": "完成一次江湖轶闻", "desc": "成功进入江湖轶闻内的任意副本。", "score": 2},
    "tiaoxi": {"id": 2, "name": "完成一次调息", "desc": "进入经脉，并点击调息一次。", "score": 1},
    "chuangmen": {"id": 3, "name": "完成一次闯门切磋", "desc": "进入其他玩家家园内，对管家成功发起闯门切磋，不论成败。", "score": 2},
    "dream": {"id": 4, "name": "完成一次梦境", "desc": "成功进入梦境。", "score": 2},
    "jina": {"id": 5, "name": "完成一次缉拿恶徒", "desc": "进入历练后，成功完成一次缉拿恶徒。", "score": 1},
    "feizei": {"id": 6, "name": "完成一次飞贼横行", "desc": "进入历练后，成功完成一次飞贼横行。", "score": 1},
    "nanyang": {"id": 7, "name": "完成一次南阳匪乱", "desc": "进入历练后，成功完成一次南阳匪乱。", "score": 2},
    "gusi": {"id": 8, "name": "完成一次古寺失窃", "desc": "进入历练后，成功完成一次古寺失窃。", "score": 2},
    "songxin": {"id": 9, "name": "完成一次江湖送信", "desc": "进入历练后，成功完成一次江湖送信。", "score": 1},
    "guaji": {"id": 10, "name": "成功领取挂机任务收益", "desc": "停止挂机任务后，成功领取一次挂机收益即算完成任务", "score": 1},
    "smketou": {"id": 11, "name": "向师傅磕头三次", "desc": "在师门内向师傅磕头三次", "score": 1},
    "smjyshuaxin": {"id": 12, "name": "刷新一次门派残页交易", "desc": "在师门内成功刷新一次门派残页交易", "score": 1},
    "paihangbang": {"id": 13, "name": "查看一次排行榜", "desc": "在主界面成功进入排行榜界面一次。", "score": 1},
    "meirijifen": {"id": 14, "name": "每日任务达到60积分", "desc": "获得60分每日任务积分。", "score": 1},
    "qjduantixiuxing": {"id": 15, "name": "完成一次锻体修行任务", "desc": "本日内成功领取一次锻体修行收益。", "score": 2},
    "qjjiqiaoxiuxing": {"id": 16, "name": "完成一次技巧修行任务", "desc": "本日内成功领取一次技巧修行收益。", "score": 2},
    "ymchongmai": {"id": 17, "name": "完成一次隐脉冲脉", "desc": "本日内成功完成一次冲脉。", "score": 3},
}
_TRAINING_INITIAL = ("tiaoxi", "jina", "smketou")
_TRAINING_REFRESHED = ("nanyang", "paihangbang", "meirijifen")

# 天缘奇盒的第一档残页来自玩家当前门派的顶级残页固定奖励（Items.lua
# 中各门派 ``*4`` 宝箱的 rwId1）。未列出的门派沿用抓包中的默认残页。
_LUCK_BOX_TOP_FRAGMENT = {
    "huashan": (852, "pozhaocanye"),
    "xingxiu": (2602, "xingxiu_gaoji_canye"),
    "shaolin": (801, "shaolin_gaoji_canye"),
    "wudang": (802, "wudang_gaoji_canye"),
    "emei": (803, "emei_gaoji_canye"),
    "gaibang": (804, "gaibang_gaoji_canye"),
}


def _choose_training_tasks(pool, preferred):
    allowed = [str(value) for value in pool if str(value) in _TRAINING_TASKS]
    selected = [value for value in preferred if value in allowed]
    for value in allowed:
        if value not in selected:
            selected.append(value)
        if len(selected) >= 3:
            break
    return selected[:3]


def _training_task_payload(bucket, selected):
    values = []
    for task_type in selected:
        config = _TRAINING_TASKS[task_type]
        state = bucket.get("tasks", {}).get(task_type) or {}
        value = copy.deepcopy(config)
        value["state"] = 1 if state.get("completed") else 0
        values.append(value)
    return values


def _training_full_payload(ctx, userid, bucket):
    template = _capture_data("157_get_training_task_list.json")
    selected = bucket.get("selected") or list(_TRAINING_INITIAL)
    template["task_list"] = _training_task_payload(bucket, selected)
    template["completion_times"] = _as_int(bucket.get("completion_times"))
    template["point"] = _as_int(bucket.get("point"))
    claimed = bucket.get("claimed") or {}
    for reward in template.get("reward_list") or []:
        rid = str(reward.get("rid"))
        if claimed.get(rid):
            reward["state"] = 2
        elif template["point"] >= _as_int(reward.get("grade")):
            reward["state"] = 1
        else:
            reward["state"] = 0
    return template


@route(["POST"], "get_training_task_list")
def get_training_task_list(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    pool = _body(ctx).get("taskList")
    if not isinstance(pool, list):
        return build_response_body({}, errcode=400, errmsg="invalid training task pool")
    with ctx["state"]._lock:
        bucket = _training_bucket(ctx, userid)
        if not isinstance(bucket.get("selected"), list):
            bucket["selected"] = _choose_training_tasks(pool, _TRAINING_INITIAL)
            bucket.setdefault("claimed", {})
            ctx["state"]._changed()
        return _ok(_training_full_payload(ctx, userid, bucket))


@route(["POST"], "refresh_training_task_list")
def refresh_training_task_list(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    pool = _body(ctx).get("taskList")
    if not isinstance(pool, list):
        return build_response_body({}, errcode=400, errmsg="invalid training task pool")
    with ctx["state"]._lock:
        bucket = _training_bucket(ctx, userid)
        bucket["selected"] = _choose_training_tasks(pool, _TRAINING_REFRESHED)
        bucket["refresh_count"] = _as_int(bucket.get("refresh_count")) + 1
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
        return _ok({
            "task_list": _training_task_payload(bucket, bucket["selected"]),
            "completion_times": _as_int(bucket.get("completion_times")),
        })


@route(["POST"], "get_training_task_reward")
def get_training_task_reward(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    rid = _as_int(body.get("rid"))
    gift_id = str(body.get("giftId") or "")
    template = _capture_data("157_get_training_task_list.json")
    reward_config = next(
        (value for value in template.get("reward_list") or [] if _as_int(value.get("rid")) == rid),
        None,
    )
    if reward_config is None:
        return build_response_body({}, errcode=404, errmsg="reward not found")
    allowed = {str(value) for value in reward_config.get("reward_ids") or []}
    if gift_id not in allowed:
        return build_response_body({}, errcode=400, errmsg="invalid giftId")
    with ctx["state"]._lock:
        bucket = _training_bucket(ctx, userid)
        if _as_int(bucket.get("point")) < _as_int(reward_config.get("grade")):
            return build_response_body({}, errcode=1, errmsg="历练分不足，不可领取")
        claimed = bucket.setdefault("claimed", {})
        if claimed.get(str(rid)):
            return build_response_body({}, errcode=1, errmsg="此奖励已领取")
        claimed[str(rid)] = True
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
    reward = copy.deepcopy((template.get("reward_pool_list") or {}).get(gift_id) or [])
    return _ok({
        "reward": reward,
        "dataVer": _data_version(ctx, userid, body.get("dataVer")),
        "currencyVersion": _currency_version(ctx, userid, body.get("currencyVersion")),
        "msg": "奖励已通过邮件发放" if _as_int(body.get("isEmail")) else "领取成功",
    })


# ---------------------------------------------------------------------------
# 新登录奖励、拳脚商店以及大型配置活动


def _login_reward_bucket(ctx, userid):
    bucket = _feature_bucket(ctx, "new_login_reward", userid)
    with ctx["state"]._lock:
        changed = False
        if "login_day_count" not in bucket:
            # 抓包发生在活动第 5 个登录日；作为本次离线活动的种子进度。
            bucket["login_day_count"] = 5
            changed = True
        if not isinstance(bucket.get("claimed_types"), list):
            bucket["claimed_types"] = []
            changed = True
        if changed:
            ctx["state"]._changed()
    return bucket


def _login_reward_payload(ctx, userid):
    data = _capture_data("059_get_new_login_reward_Info.json")
    bucket = _login_reward_bucket(ctx, userid)
    claimed_types = {str(value) for value in bucket.get("claimed_types") or []}
    data["loginDayCount"] = _as_int(bucket.get("login_day_count"), 1)
    cyclic = data.get("cyclic_pools") or {}
    if "1" in claimed_types:
        cyclic["receivedCount"] = _as_int(cyclic.get("receivedCount")) + _as_int(cyclic.get("availableCount"))
        cyclic["availableCount"] = 0
    if "2" in claimed_types:
        for pool in data.get("cumulative_pools") or []:
            for reward in pool.get("rewards") or []:
                if _as_int(reward.get("state")) == 1:
                    reward["state"] = 2
    return data


@route(["POST"], "get_new_login_reward_Info")
def get_new_login_reward_info(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    return _ok(_login_reward_payload(ctx, userid))


@route(["POST"], "claim_all_new_login_reward")
def claim_all_new_login_reward(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    pool_type = str(_as_int(body.get("type")))
    if pool_type not in ("1", "2"):
        return build_response_body({}, errcode=400, errmsg="invalid reward type")
    bucket = _login_reward_bucket(ctx, userid)
    with ctx["state"]._lock:
        if pool_type in {str(value) for value in bucket.get("claimed_types") or []}:
            return build_response_body({}, errcode=1, errmsg="当前没有可领取奖励")
        data = _login_reward_payload(ctx, userid)
        rewards = []
        if pool_type == "1":
            cyclic = data.get("cyclic_pools") or {}
            available = _as_int(cyclic.get("availableCount"))
            for value in cyclic.get("rewards") or []:
                rewards.append({
                    "id": str(value.get("goodsId")),
                    "num": _as_int(value.get("num")) * available,
                })
            received_count = _as_int(cyclic.get("receivedCount")) + available
            extra = {"receivedCount": received_count, "availableCount": 0}
        else:
            totals = {}
            for pool in data.get("cumulative_pools") or []:
                for value in pool.get("rewards") or []:
                    if _as_int(value.get("state")) == 1:
                        item_id = str(value.get("goodsId"))
                        totals[item_id] = totals.get(item_id, 0) + _as_int(value.get("num"))
            rewards = [{"id": key, "num": value} for key, value in totals.items()]
            extra = {}
        if not rewards:
            return build_response_body({}, errcode=1, errmsg="当前没有可领取奖励")
        bucket.setdefault("claimed_types", []).append(pool_type)
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
    result = {
        "reward": rewards,
        "dataVer": _data_version(ctx, userid, body.get("dataVer")),
        "currencyVersion": _currency_version(ctx, userid, body.get("currencyVersion")),
    }
    result.update(extra)
    return _ok(result)


def _fist_shop_bucket(ctx, userid):
    bucket = _feature_bucket(ctx, "fist_foot_shop", userid)
    with ctx["state"]._lock:
        if "dailySelectCost" not in bucket:
            bucket.update({"dailySelectCost": 0, "dailySelectList": []})
            ctx["state"]._changed()
    return bucket


@route(["GET"], "get_fistFootShop_info")
def get_fist_foot_shop_info(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    data = _capture_data("079_get_fistFootShop_info.json")
    bucket = _fist_shop_bucket(ctx, userid)
    data["dailySelectCost"] = _as_int(bucket.get("dailySelectCost"))
    data["dailySelectList"] = copy.deepcopy(bucket.get("dailySelectList") or [])
    return _ok(data)


@route(["POST"], "set_fistFootShop_dailyCost")
def set_fist_foot_shop_daily_cost(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    cost = _as_int(_body(ctx).get("dailySelectCost"), -1)
    # costConf.lua: 200~2000；选择界面每次增减 100。
    if cost < 200 or cost > 2000 or cost % 100 != 0:
        return build_response_body({}, errcode=400, errmsg="dailySelectCost out of range")
    bucket = _fist_shop_bucket(ctx, userid)
    with ctx["state"]._lock:
        bucket["dailySelectCost"] = cost
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
    return build_response_body(None)


@route(["POST"], "get_cuiLianCaiLiao_store_list")
def get_cuilian_material_store_list(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    data = _capture_data("081_get_cuiLianCaiLiao_store_list.json")
    bucket = _feature_bucket(ctx, "cuilian_material_store", userid)
    data["integral_number"] = _as_int(bucket.get("integral_number"))
    data["currencyVersion"] = _currency_version(ctx, userid, body.get("currencyVersion"))
    for currency in data.get("currency_list") or []:
        currency_id = str(currency.get("id") or "")
        if currency_id == "yuanbao":
            currency["number"] = _get_yuanbao_balance(ctx, userid)
        elif currency_id:
            currency["number"] = _currency_balance(ctx, userid, currency_id)
    return _ok(data)


@route(["POST"], "get_luck_box_list")
def get_luck_box_list(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    bucket = _feature_bucket(ctx, "luck_box", userid)
    refresh = str(body.get("is_refresh") or "N").upper() == "Y"
    with ctx["state"]._lock:
        if refresh:
            bucket["refresh_index"] = (_as_int(bucket.get("refresh_index"), -1) + 1) % 5
            bucket["updated_at"] = int(time.time())
            ctx["state"]._changed()
        index = _as_int(bucket.get("refresh_index"), -1)
    filename = "%03d_get_luck_box_list.json" % (146 + index) if index >= 0 else "151_get_luck_box_list.json"
    data = _capture_data(filename)
    menpai = str(body.get("menpai") or "").strip().lower()
    fragment = _LUCK_BOX_TOP_FRAGMENT.get(menpai)
    if fragment:
        for item in data.get("list") or []:
            if _as_int(item.get("rtype"), 0) == 1:
                item["rid"] = fragment[0]
                item["id"] = fragment[1]
                item["state"] = 0
                break
    data["buy_times"] = _as_int(bucket.get("buy_times"))
    return _ok(data)


def _luck_box_current_list(ctx, userid):
    bucket = _feature_bucket(ctx, "luck_box", userid)
    index = _as_int(bucket.get("refresh_index"), -1)
    filename = "%03d_get_luck_box_list.json" % (146 + index) if index >= 0 else "151_get_luck_box_list.json"
    return bucket, _capture_data(filename)


@route(["POST"], "buy_luck_box_good")
def buy_luck_box_good(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    body = _body(ctx)
    rid = _as_int(body.get("rid"), -1)
    activity_id = str(body.get("activity_id") or "tianyuanqihe")
    if activity_id != "tianyuanqihe" or rid < 0:
        return build_response_body({}, errcode=400, errmsg="invalid luck box request")
    with ctx["state"] ._lock:
        bucket, data = _luck_box_current_list(ctx, userid)
        limit = max(_as_int(data.get("buy_limit"), 30), 0)
        times = max(_as_int(bucket.get("buy_times"), 0), 0)
        if times >= limit:
            return build_response_body({}, errcode=1, errmsg="buy limit reached")
        goods = next((item for item in data.get("list") or [] if _as_int(item.get("rid"), -1) == rid), None)
        if goods is None:
            return build_response_body({}, errcode=404, errmsg="luck box good not found")
        cost = max(_as_int(goods.get("dis_cost"), _as_int(goods.get("buy_cost"), 0)), 0)
        balance = _get_yuanbao_balance(ctx, userid)
        if balance < cost:
            return build_response_body({}, errcode=1, errmsg="元宝不足")
        _set_currency_balance(ctx, userid, "yuanbao", balance - cost)
        bucket["buy_times"] = times + 1
        bucket.setdefault("purchased", {})[str(rid)] = bucket["purchased"].get(str(rid), 0) + 1
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
        reward = {"id": str(goods.get("id") or ""), "num": max(_as_int(goods.get("number"), 1), 1)}
        return _ok({
            "rid": rid,
            "reward": [reward],
            "buy_times": bucket["buy_times"],
            "remove_yuanbao": cost,
            "yuanbao": balance - cost,
            "dataVer": _data_version(ctx, userid, body.get("dataVer")),
            "currencyVersion": _currency_version(ctx, userid, body.get("currencyVersion")),
        })


@route(["POST"], "get_luck_box_good")
def get_luck_box_good(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    rid = _as_int(_body(ctx).get("rid"), -1)
    _bucket, data = _luck_box_current_list(ctx, userid)
    goods = next((item for item in data.get("list") or [] if _as_int(item.get("rid"), -1) == rid), None)
    if goods is None:
        return build_response_body({}, errcode=404, errmsg="luck box good not found")
    return _ok(copy.deepcopy(goods))


@route(["GET"], "get_payMask_gift_info")
def get_pay_mask_gift_info(ctx):
    _userid_value, error = _require_user(ctx)
    return error or _ok(_capture_data("063_get_payMask_gift_info.json"))


@route(["GET"], "get_xianshilibao_gift_list_2")
def get_limited_package_reward_list(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    data = _capture_data("068_get_xianshilibao_gift_list_2.json")
    bucket = _feature_bucket(ctx, "limited_package_reward", userid)
    data["total"] = _as_int(bucket.get("total"))
    return _ok(data)


@route(["GET"], "get_spring_new_reward")
def get_spring_new_reward(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    data = _capture_data("071_get_spring_new_reward.json")
    bucket = _feature_bucket(ctx, "first_charge", userid)
    data["hasup"] = 1 if bucket.get("charged") else _as_int(data.get("hasup"))
    claimed = {str(value) for value in bucket.get("claimed") or []}
    for reward in data.get("base") or []:
        if str(reward.get("day")) in claimed:
            reward["status"] = 2
    return _ok(data)


@route(["GET"], "get_sachet_attic_new_list")
def get_sachet_attic_new_list(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    data = _capture_data("083_scachetAttic.json")
    data["currency_number"] = _currency_balance(ctx, userid, "xiangnang")
    return _ok(data)


@route(["GET"], "get_spend_reward_list")
def get_spend_reward_list(ctx):
    _userid_value, error = _require_user(ctx)
    return error or _ok(_capture_data("085_jianghumibao1.json"))


@route(["GET"], "get_zhenpinge_lottery_list")
def get_zhenpinge_lottery_list(ctx):
    userid, error = _require_user(ctx)
    if error:
        return error
    data = _capture_data("144_jianghuzhenpinge1.json")
    bucket = _feature_bucket(ctx, "zhenpinge", userid)
    data["lottery_times"] = _as_int(bucket.get("lottery_times"))
    if isinstance(data.get("currency"), dict):
        data["currency"]["count"] = _currency_balance(ctx, userid, data["currency"].get("id"))
    if isinstance(data.get("exchange_currency"), dict):
        data["exchange_currency"]["count"] = _currency_balance(
            ctx, userid, data["exchange_currency"].get("id")
        )
    return _ok(data)


# ---------------------------------------------------------------------------
# 抓包中虽已有旧路由、但旧实现仍为占位数据的活动入口


@route(["POST"], "get_game_activity")
def get_game_activity(ctx):
    activity_id = str((ctx.get("route_tail") or [""])[0] or "")
    if activity_id == "dailypaynew":
        _userid_value, error = _require_user(ctx)
        return error or _ok(_capture_data("088_dailypaynew.json"))
    return _fallback_game_activity(ctx)


@route(["GET", "POST"], "get_login_reward_list")
def get_login_reward_list(ctx):
    activity_id = str((ctx.get("route_tail") or [""])[0] or "")
    if activity_id == "mingshidenglu1":
        _userid_value, error = _require_user(ctx)
        return error or _ok(_capture_data("061_mingshidenglu1.json"))
    return _fallback_login_reward_list(ctx)


_SPRING_STATUS_CAPTURE = {
    1: "072_1.json",
    8: "069_8.json",
    14: "091_14.json",
    19: "099_19.json",
    58: "074_58.json",
    70: "073_70.json",
    84: "067_84.json",
    86: "066_86.json",
    90: "062_90.json",
    94: "086_94.json",
    100: "152_100.json",
    103: "076_103.json",
    112: "084_112.json",
    121: "145_121.json",
    128: "082_128.json",
    140: "080_140.json",
    141: "064_141.json",
    149: "089_149.json",
    157: "060_157.json",
}


def _captured_spring_list():
    values = _capture_data("101_get_spring_festival_list.json")
    # 保留旧客户端和既有自动化所依赖的“签到、充值积分”优先顺序。
    priorities = {14: 0, 19: 1}
    indexed = list(enumerate(values))
    indexed.sort(key=lambda pair: (priorities.get(_as_int(pair[1].get("id")), 2), pair[0]))
    return [value for _index, value in indexed]


@route(["GET"], "get_spring_festival_list")
def get_spring_festival_list(ctx):
    _userid_value, error = _require_user(ctx)
    return error or _ok(_captured_spring_list())


@route(["GET"], "get_spring_festival_status")
def get_spring_festival_status(ctx):
    action_id = _as_int((ctx.get("route_tail") or [None])[0], 0)
    filename = _SPRING_STATUS_CAPTURE.get(action_id)
    if filename:
        _userid_value, error = _require_user(ctx)
        return error or _ok(_capture_data(filename))
    # id=32 没有独立请求样本，但总表包含完整状态；其余交给旧实现报 404。
    action = next(
        (value for value in _captured_spring_list() if _as_int(value.get("id")) == action_id),
        None,
    )
    if action is not None:
        return _ok(action)
    return _fallback_spring_festival_status(ctx)
