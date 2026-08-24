# -*- coding: utf-8 -*-
"""练功 / 修炼 / 成就解锁相关接口。

客户端进入 MainLayer 后会立刻:
  AchievementSystem:updateRecord -> update_unlock_record
  LianGongSystem:getLianGongState / pullLianGongData
  XiuLianSystem:getXiuLianState / pullXiuLianData

状态约定 (ServerActionSystem + LianGongSystem):
  state = 0 空闲
  state = 1 进行中
  get*Data:
    errcode=0 返回 startAction/useXgsCount
    errcode=1 表示无进行中数据(空闲)
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


def _data_ver(ctx, userid):
    role = ctx["state"].get_archive(userid) if userid > 0 else None
    if isinstance(role, dict):
        try:
            return int(role.get("dataVer") or 0)
        except (TypeError, ValueError):
            pass
        system = role.get("serverActionSystem")
        if isinstance(system, dict):
            try:
                return int(system.get("dataVersion") or 0)
            except (TypeError, ValueError):
                pass
    return 1


# 笃志上限取自 liangongParamsConf["21"]=100
DEFAULT_TILI_MAX = 100
DEFAULT_XINSHEN_MAX = 400
XINSHEN_RECOVER_INTERVAL = 300
XINSHEN_RECOVER_VALUE = 10
XINSHEN_LEVEL_MAX = {
    1: 400, 2: 666, 3: 670, 4: 1040, 5: 1044, 6: 1048, 7: 1052,
    8: 1225, 9: 1229, 10: 1232, 11: 1347, 12: 1351, 13: 1355,
    14: 1359, 15: 1451, 16: 1455, 17: 1459, 18: 1551, 19: 1555,
    20: 1559, 21: 1563, 22: 1656, 23: 1660, 24: 1663, 25: 1756,
    26: 1760, 27: 1764, 28: 1768, 29: 1860, 30: 1864, 31: 1868,
    32: 1960, 33: 1964, 34: 1968, 35: 1972, 36: 2065, 37: 2069, 38: 2073, 39: 2165, 40: 2169, 41: 2173,
    42: 2177, 43: 2269, 44: 2273, 45: 2277, 46: 2370, 47: 2373,
    48: 2377, 49: 2381, 50: 2385, 51: 2390,
}
XINSHEN_ITEM_EFFECTS = {
    "minditem1": 50,
    "minditem2": 100,
    "minditem3": 200,
    "minditem4": 500,
}


def _practice_bucket(ctx, userid):
    snapshot = ctx["state"].snapshot()
    practice = snapshot.setdefault("practice", {})
    key = str(userid)
    bucket = practice.setdefault(key, {
        "lianGong": {"state": 0, "startAction": None, "useXgsCount": 0},
        "xiuLian": {"state": 0, "startAction": None, "useXgsCount": 0},
        "xinShen": {"curr": DEFAULT_XINSHEN_MAX, "max": DEFAULT_XINSHEN_MAX, "level": 1},
        "itemMap": {
            "minditem1": {"count": 0},
            "minditem2": {"count": 0},
            "minditem3": {"count": 0},
            "minditem4": {"count": 0},
        },
        # 练功/修炼共用笃志体力池
        "tiLi": {"curr": DEFAULT_TILI_MAX, "max": DEFAULT_TILI_MAX},
        "unlock_records": [],
    })
    xin_shen = bucket.setdefault(
        "xinShen",
        {"curr": DEFAULT_XINSHEN_MAX, "max": DEFAULT_XINSHEN_MAX, "level": 1},
    )
    xin_shen.setdefault("level", 1)
    level = max(_as_int(xin_shen.get("level"), 1), 1)
    xin_shen["level"] = level
    xin_shen["max"] = XINSHEN_LEVEL_MAX.get(
        level,
        max(_as_int(xin_shen.get("max"), DEFAULT_XINSHEN_MAX), DEFAULT_XINSHEN_MAX),
    )
    xin_shen.setdefault("curr", DEFAULT_XINSHEN_MAX)
    xin_shen.setdefault("recoverStartTime", int(time.time()))
    item_map = bucket.setdefault("itemMap", {})
    for item_id in ("minditem1", "minditem2", "minditem3", "minditem4"):
        item = item_map.setdefault(item_id, {})
        item.setdefault("count", 0)
    bucket.setdefault("tiLi", {"curr": DEFAULT_TILI_MAX, "max": DEFAULT_TILI_MAX})
    bucket["tiLi"].setdefault("max", DEFAULT_TILI_MAX)
    if bucket["tiLi"].get("curr") is None:
        bucket["tiLi"]["curr"] = bucket["tiLi"]["max"]
    # 写回
    with ctx["state"]._lock:
        ctx["state"]._state.setdefault("practice", {})[key] = bucket
        ctx["state"]._changed()
    return bucket


def _save_bucket(ctx, userid, bucket):
    with ctx["state"]._lock:
        ctx["state"]._state.setdefault("practice", {})[str(userid)] = copy.deepcopy(bucket)
        ctx["state"]._changed()


def _as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return int(default)


def _tili_payload(bucket):
    ti_li = bucket.get("tiLi") or {}
    max_tili = max(_as_int(ti_li.get("max"), DEFAULT_TILI_MAX), 1)
    curr = max(0, min(_as_int(ti_li.get("curr"), max_tili), max_tili))
    return {"currTiLi": curr, "maxTiLi": max_tili}


def _cost_tili(bucket, cost):
    ti_li = bucket.setdefault("tiLi", {"curr": DEFAULT_TILI_MAX, "max": DEFAULT_TILI_MAX})
    max_tili = max(_as_int(ti_li.get("max"), DEFAULT_TILI_MAX), 1)
    curr = max(0, min(_as_int(ti_li.get("curr"), max_tili), max_tili))
    cost = max(_as_int(cost, 0), 0)
    if cost > curr:
        return False, curr, max_tili
    ti_li["curr"] = curr - cost
    ti_li["max"] = max_tili
    return True, ti_li["curr"], max_tili


def _restore_tili(bucket, restore):
    ti_li = bucket.setdefault("tiLi", {"curr": DEFAULT_TILI_MAX, "max": DEFAULT_TILI_MAX})
    max_tili = max(_as_int(ti_li.get("max"), DEFAULT_TILI_MAX), 1)
    curr = max(0, min(_as_int(ti_li.get("curr"), max_tili), max_tili))
    restore = max(_as_int(restore, 0), 0)
    ti_li["curr"] = min(curr + restore, max_tili)
    ti_li["max"] = max_tili
    return ti_li["curr"], max_tili


def _cost_xinshen(bucket, cost):
    curr, max_v, start_time = _settle_xinshen_recovery(bucket)
    cost = max(_as_int(cost, 0), 0)
    if cost > curr:
        return False, curr, max_v
    xin = bucket["xinShen"]
    xin["curr"] = curr - cost
    if curr >= max_v and cost > 0:
        xin["recoverStartTime"] = int(time.time())
    else:
        xin["recoverStartTime"] = start_time
    return True, xin["curr"], max_v


def _restore_xinshen(bucket, restore):
    curr, max_v, start_time = _settle_xinshen_recovery(bucket)
    restore = max(_as_int(restore, 0), 0)
    xin = bucket["xinShen"]
    xin["curr"] = min(curr + restore, max_v)
    xin["recoverStartTime"] = int(time.time()) if xin["curr"] >= max_v else start_time
    return xin["curr"], max_v


def _settle_xinshen_recovery(bucket, now=None):
    now = int(time.time()) if now is None else max(_as_int(now, 0), 0)
    xin = bucket.setdefault("xinShen", {"curr": DEFAULT_XINSHEN_MAX, "max": DEFAULT_XINSHEN_MAX})
    max_v = max(_as_int(xin.get("max"), DEFAULT_XINSHEN_MAX), 1)
    curr = max(0, min(_as_int(xin.get("curr"), max_v), max_v))
    start_time = max(_as_int(xin.get("recoverStartTime"), now), 0)
    if start_time > now:
        start_time = now
    if curr >= max_v:
        xin["curr"] = max_v
        xin["max"] = max_v
        xin["recoverStartTime"] = now
        return max_v, max_v, now
    periods = (now - start_time) // XINSHEN_RECOVER_INTERVAL
    if periods > 0:
        curr = min(curr + periods * XINSHEN_RECOVER_VALUE, max_v)
        start_time = now if curr >= max_v else start_time + periods * XINSHEN_RECOVER_INTERVAL
    xin["curr"] = curr
    xin["max"] = max_v
    xin["recoverStartTime"] = start_time
    return curr, max_v, start_time


def _resolve_csj_skill_id(role):
    skills = role.get("skills") if isinstance(role, dict) else None
    if not isinstance(skills, dict):
        return None
    if isinstance(skills.get("changshengjueyang"), dict):
        return "changshengjueyang"
    if isinstance(skills.get("changshengjueyin"), dict):
        return "changshengjueyin"
    return None


def _apply_finish_skill_exp(ctx, userid, action, fallback_skill_id=None):
    """按客户端本地结算结果同步落盘。
    原版: 客户端自己 addSkillExp, 服务端只确认 dataVer。
    mock 额外写 archives/<userid>.json 的 skills.exp, 便于下载覆盖校验。
    """
    skill_id = action.get("skillId") or fallback_skill_id
    add_exp = _as_int(action.get("addExp"), 0)
    csj_add_exp = _as_int(action.get("csjAddExp"), 0)
    gains = []
    if skill_id and add_exp > 0:
        gains.append((skill_id, add_exp))
    if csj_add_exp > 0:
        role = ctx["state"].get_archive(userid) or {}
        csj_id = _resolve_csj_skill_id(role)
        if csj_id:
            gains.append((csj_id, csj_add_exp))
    if not gains:
        data_ver = _data_ver(ctx, userid) + 1
        # 即使无经验, 也推进行为版本, 与原版 ServerActionSystem 一致
        role = ctx["state"].get_archive(userid)
        if isinstance(role, dict):
            ctx["state"].put_archive(userid, role, data_ver=data_ver)
        return {}, data_ver, True, ""
    role, applied, data_ver = ctx["state"].apply_skill_exp(userid, gains)
    if role is None:
        return {}, 0, False, "archive not found"
    # 简单校验: 回读 skills.exp 是否已写入
    check_role = ctx["state"].get_archive(userid) or {}
    check_skills = check_role.get("skills") if isinstance(check_role.get("skills"), dict) else {}
    for sid, info in applied.items():
        skill = check_skills.get(sid) if isinstance(check_skills.get(sid), dict) else {}
        if _as_int(skill.get("exp"), -1) != _as_int(info.get("new"), -2):
            return applied, data_ver, False, "skill exp write mismatch: %s" % sid
    return applied, data_ver, True, ""


def _normalize_record_list(events):
    """上传 events -> recordList[{jid, expired_time, values}]"""
    values = []
    if isinstance(events, dict):
        iterable = events.values()
    elif isinstance(events, list):
        iterable = events
    else:
        iterable = []
    for item in iterable:
        if not isinstance(item, dict):
            continue
        jid = item.get("jid", item.get("id"))
        if jid is None:
            continue
        try:
            count = int(item.get("values", item.get("value", 1)) or 1)
        except (TypeError, ValueError):
            count = 1
        try:
            expired = int(item.get("expired_time", 0) or 0)
        except (TypeError, ValueError):
            expired = 0
        values.append({
            "jid": jid,
            "expired_time": expired,
            "values": count,
        })
    return values


def _merge_records(existing, incoming):
    merged = {}
    for item in existing or []:
        if isinstance(item, dict) and item.get("jid") is not None:
            merged[str(item["jid"])] = dict(item)
    for item in incoming or []:
        key = str(item["jid"])
        old = merged.get(key)
        if old is None:
            merged[key] = dict(item)
        else:
            try:
                old_values = int(old.get("values") or 0)
            except (TypeError, ValueError):
                old_values = 0
            try:
                new_values = int(item.get("values") or 0)
            except (TypeError, ValueError):
                new_values = 0
            old["values"] = old_values + max(new_values, 1)
            if item.get("expired_time") is not None:
                old["expired_time"] = item.get("expired_time")
            merged[key] = old
    return list(merged.values())


@route(["POST"], "update_unlock_record")
def update_unlock_record(ctx):
    """成就解锁上报。
    请求: {events=[...]}
    成功: {recordList=[{jid, expired_time, values}, ...]}
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    ctx["state"].ensure_account(userid)
    body = _body_dict(ctx)
    incoming = _normalize_record_list(body.get("events"))
    bucket = _practice_bucket(ctx, userid)
    bucket["unlock_records"] = _merge_records(bucket.get("unlock_records"), incoming)
    _save_bucket(ctx, userid, bucket)
    return build_response_body({"recordList": copy.deepcopy(bucket["unlock_records"])})


@route(["GET", "POST"], "get_liangong_tili")
def get_liangong_tili(ctx):
    """练功/修炼笃志体力。
    客户端: HttpManagerEx:getLianGongTiLi
    成功 data: {currTiLi, maxTiLi}
    上限来自 liangongParamsConf["21"]=100
    """
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    return build_response_body(_tili_payload(bucket))


@route(["POST"], "test_add_liangong_tili")
def test_add_liangong_tili(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    add_value = _as_int(body.get("addTiLi") or body.get("num") or body.get("value") or 0, 0)
    bucket = _practice_bucket(ctx, userid)
    curr, max_tili = _restore_tili(bucket, add_value if add_value > 0 else DEFAULT_TILI_MAX)
    _save_bucket(ctx, userid, bucket)
    return build_response_body({"currTiLi": curr, "maxTiLi": max_tili})


@route(["POST"], "getLianGongState")
def get_lian_gong_state(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    state = int((bucket.get("lianGong") or {}).get("state") or 0)
    return build_response_body({"state": 1 if state == 1 else 0})


@route(["POST"], "getLianGongData")
def get_lian_gong_data(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    session = bucket.get("lianGong") or {}
    if int(session.get("state") or 0) != 1 or not session.get("startAction"):
        # 空闲: errcode=1, 客户端按无数据成功处理
        return build_response_body({}, errcode=1, errmsg="")
    return build_response_body({
        "startAction": copy.deepcopy(session.get("startAction")),
        "useXgsCount": int(session.get("useXgsCount") or 0),
    })


@route(["POST"], "lianGongStart")
def lian_gong_start(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    action = body.get("actionData") if isinstance(body.get("actionData"), dict) else {}
    bucket = _practice_bucket(ctx, userid)
    select_tili = _as_int(action.get("selectTiLi"), 0)
    xinshen_cost = _as_int(action.get("xinShenCost") or action.get("xinshen"), 0)
    ok_tili, curr_tili, max_tili = _cost_tili(bucket, select_tili)
    if not ok_tili:
        return build_response_body(
            {"currTiLi": curr_tili, "maxTiLi": max_tili},
            errcode=400,
            errmsg="tili not enough",
        )
    ok_xin, curr_xin, max_xin = _cost_xinshen(bucket, xinshen_cost)
    if not ok_xin:
        # 回滚体力
        _restore_tili(bucket, select_tili)
        return build_response_body(
            {"curr": curr_xin, "max": max_xin},
            errcode=400,
            errmsg="xinshen not enough",
        )
    data_ver = _data_ver(ctx, userid) + 1
    start_action = {
        "data": {
            "ver": 0,
            "skillId": action.get("skillId"),
            "xinshen": xinshen_cost,
            "startTime": action.get("startTime") or int(time.time()),
            "duration": action.get("duration") or 0,
            "selectJing": action.get("selectJing"),
            "selectLv": action.get("selectLv"),
            "selectTiLi": select_tili,
            "xinShenCost": xinshen_cost,
            "useXgsCount": 0,
            "variates": action.get("variates") or {},
            "skillPrepareType": action.get("skillPrepareType"),
            "startExp": action.get("startExp"),
            "startLvLimit": action.get("startLvLimit"),
            "playerLv": action.get("playerLv"),
        },
        "dataVer": data_ver,
        "codeVer": body.get("codeVer") or 1,
    }
    bucket["lianGong"] = {
        "state": 1,
        "startAction": start_action,
        "useXgsCount": 0,
        "updated_at": int(time.time()),
    }
    _save_bucket(ctx, userid, bucket)
    return build_response_body({
        "dataVer": data_ver,
        "currTiLi": curr_tili,
        "maxTiLi": max_tili,
    })


@route(["POST"], "lianGongFinish")
def lian_gong_finish(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    action = body.get("actionData") if isinstance(body.get("actionData"), dict) else {}
    bucket = _practice_bucket(ctx, userid)
    session = bucket.get("lianGong") or {}
    start_data = ((session.get("startAction") or {}).get("data") or {})
    # 客户端结束时回传 tiLiReture / xinShenReturn
    restore_tili = action.get("tiLiReture")
    if restore_tili is None:
        restore_tili = action.get("tiLiReturn")
    if restore_tili is None:
        restore_tili = start_data.get("selectTiLi") or 0
    restore_xin = action.get("xinShenReturn")
    if restore_xin is None:
        restore_xin = start_data.get("xinShenCost") or 0
    curr_tili, max_tili = _restore_tili(bucket, restore_tili)
    curr_xin, max_xin = _restore_xinshen(bucket, restore_xin)
    applied, data_ver, ok, errmsg = _apply_finish_skill_exp(
        ctx, userid, action, fallback_skill_id=start_data.get("skillId"))
    if not ok:
        return build_response_body({}, errcode=500, errmsg=errmsg or "apply skill exp failed")
    bucket["lianGong"] = {
        "state": 0,
        "startAction": None,
        "useXgsCount": int(session.get("useXgsCount") or 0),
        "updated_at": int(time.time()),
    }
    _save_bucket(ctx, userid, bucket)
    return build_response_body({
        "dataVer": data_ver,
        "msg": "",
        "currTiLi": curr_tili,
        "maxTiLi": max_tili,
        "curr": curr_xin,
        "max": max_xin,
        "applied": applied,
    })


@route(["POST"], "lianGongUseXingGongSan")
def lian_gong_use_xing_gong_san(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    session = bucket.setdefault("lianGong", {"state": 0, "startAction": None, "useXgsCount": 0})
    session["useXgsCount"] = int(session.get("useXgsCount") or 0) + 1
    if isinstance(session.get("startAction"), dict):
        data = session["startAction"].setdefault("data", {})
        if isinstance(data, dict):
            data["useXgsCount"] = session["useXgsCount"]
    data_ver = _data_ver(ctx, userid) + 1
    _save_bucket(ctx, userid, bucket)
    return build_response_body({"dataVer": data_ver, "useXgsCount": session["useXgsCount"]})


@route(["POST"], "getXiuLianState")
def get_xiu_lian_state(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    state = int((bucket.get("xiuLian") or {}).get("state") or 0)
    return build_response_body({"state": 1 if state == 1 else 0})


@route(["POST"], "getXiuLianData")
def get_xiu_lian_data(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    session = bucket.get("xiuLian") or {}
    if int(session.get("state") or 0) != 1 or not session.get("startAction"):
        return build_response_body({}, errcode=1, errmsg="")
    return build_response_body({
        "startAction": copy.deepcopy(session.get("startAction")),
        "useXgsCount": int(session.get("useXgsCount") or 0),
    })


@route(["POST"], "xiuLianStart")
def xiu_lian_start(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    action = body.get("actionData") if isinstance(body.get("actionData"), dict) else {}
    bucket = _practice_bucket(ctx, userid)
    select_tili = _as_int(action.get("selectTiLi"), 0)
    xinshen_cost = _as_int(action.get("xinShenCost") or action.get("xinshen"), 0)
    ok_tili, curr_tili, max_tili = _cost_tili(bucket, select_tili)
    if not ok_tili:
        return build_response_body(
            {"currTiLi": curr_tili, "maxTiLi": max_tili},
            errcode=400,
            errmsg="tili not enough",
        )
    ok_xin, curr_xin, max_xin = _cost_xinshen(bucket, xinshen_cost)
    if not ok_xin:
        _restore_tili(bucket, select_tili)
        return build_response_body(
            {"curr": curr_xin, "max": max_xin},
            errcode=400,
            errmsg="xinshen not enough",
        )
    data_ver = _data_ver(ctx, userid) + 1
    start_action = {
        "data": {
            "ver": 0,
            "skillId": action.get("skillId"),
            "xinshen": xinshen_cost,
            "startTime": action.get("startTime") or int(time.time()),
            "duration": action.get("duration") or 0,
            "selectJing": action.get("selectJing"),
            "selectLv": action.get("selectLv"),
            "selectTiLi": select_tili,
            "xinShenCost": xinshen_cost,
            "useXgsCount": 0,
            "variates": action.get("variates") or {},
            "dummy": action.get("dummy") or {},
            "skillPrepareType": action.get("skillPrepareType"),
            "startExp": action.get("startExp"),
            "startLvLimit": action.get("startLvLimit"),
            "playerLv": action.get("playerLv"),
        },
        "dataVer": data_ver,
        "codeVer": body.get("codeVer") or 1,
    }
    bucket["xiuLian"] = {
        "state": 1,
        "startAction": start_action,
        "useXgsCount": 0,
        "updated_at": int(time.time()),
    }
    _save_bucket(ctx, userid, bucket)
    return build_response_body({
        "dataVer": data_ver,
        "currTiLi": curr_tili,
        "maxTiLi": max_tili,
    })


@route(["POST"], "xiuLianFinish")
def xiu_lian_finish(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    action = body.get("actionData") if isinstance(body.get("actionData"), dict) else {}
    bucket = _practice_bucket(ctx, userid)
    session = bucket.get("xiuLian") or {}
    start_data = ((session.get("startAction") or {}).get("data") or {})
    restore_tili = action.get("tiLiReture")
    if restore_tili is None:
        restore_tili = action.get("tiLiReturn")
    if restore_tili is None:
        restore_tili = start_data.get("selectTiLi") or 0
    restore_xin = action.get("xinShenReturn")
    if restore_xin is None:
        restore_xin = start_data.get("xinShenCost") or 0
    curr_tili, max_tili = _restore_tili(bucket, restore_tili)
    curr_xin, max_xin = _restore_xinshen(bucket, restore_xin)
    applied, data_ver, ok, errmsg = _apply_finish_skill_exp(
        ctx, userid, action, fallback_skill_id=start_data.get("skillId"))
    if not ok:
        return build_response_body({}, errcode=500, errmsg=errmsg or "apply skill exp failed")
    bucket["xiuLian"] = {
        "state": 0,
        "startAction": None,
        "useXgsCount": int(session.get("useXgsCount") or 0),
        "updated_at": int(time.time()),
    }
    _save_bucket(ctx, userid, bucket)
    return build_response_body({
        "dataVer": data_ver,
        "msg": "",
        "currTiLi": curr_tili,
        "maxTiLi": max_tili,
        "curr": curr_xin,
        "max": max_xin,
        "applied": applied,
    })


@route(["POST"], "xiuLianUseXingGongSan")
def xiu_lian_use_xing_gong_san(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    session = bucket.setdefault("xiuLian", {"state": 0, "startAction": None, "useXgsCount": 0})
    session["useXgsCount"] = int(session.get("useXgsCount") or 0) + 1
    if isinstance(session.get("startAction"), dict):
        data = session["startAction"].setdefault("data", {})
        if isinstance(data, dict):
            data["useXgsCount"] = session["useXgsCount"]
    data_ver = _data_ver(ctx, userid) + 1
    _save_bucket(ctx, userid, bucket)
    return build_response_body({"dataVer": data_ver, "useXgsCount": session["useXgsCount"]})


@route(["POST"], "upgradeXinShenLevel")
def upgrade_xin_shen_level(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    bucket = _practice_bucket(ctx, userid)
    xin = bucket.get("xinShen") or {}
    request_id = str(body.get("requestId") or "")
    requests = xin.setdefault("upgradeRequests", {})
    if request_id and isinstance(requests.get(request_id), dict):
        return build_response_body(copy.deepcopy(requests[request_id]))
    level = max(_as_int(xin.get("level"), 1), 1)
    if level >= max(XINSHEN_LEVEL_MAX):
        return build_response_body({}, errcode=400, errmsg="xinshen level max")
    next_level = level + 1
    next_max = XINSHEN_LEVEL_MAX.get(next_level, DEFAULT_XINSHEN_MAX)
    curr = max(0, min(_as_int(xin.get("curr"), DEFAULT_XINSHEN_MAX), next_max))
    recover_start_time = max(_as_int(xin.get("recoverStartTime"), int(time.time())), 0)
    data_ver = max(_data_ver(ctx, userid), _as_int(body.get("dataVer"), 0)) + 1
    xin["level"] = next_level
    xin["max"] = next_max
    xin["curr"] = curr
    xin["recoverStartTime"] = recover_start_time
    result = {
        "dataVer": data_ver,
        "curr": curr,
        "max": next_max,
        "time": recover_start_time,
        "level": next_level,
    }
    if request_id:
        requests[request_id] = copy.deepcopy(result)
        while len(requests) > 20:
            requests.pop(next(iter(requests)))
    _save_bucket(ctx, userid, bucket)
    role = ctx["state"].get_archive(userid)
    if isinstance(role, dict):
        ctx["state"].put_archive(userid, role, data_ver=data_ver)
    return build_response_body(result)


@route(["POST"], "getXinShenLevel")
@route(["POST"], "get_XinShenLevel")
def get_xin_shen_level(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    xin = bucket.get("xinShen") or {}
    return build_response_body({"level": max(_as_int(xin.get("level"), 1), 1)})


@route(["POST"], "getItemMap")
def get_item_map(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    item_map = bucket.get("itemMap") or {}
    return build_response_body({"itemMap": copy.deepcopy(item_map)})


@route(["POST"], "refreshItemMapCache")
def refresh_item_map_cache(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    if _as_int(body.get("codeVer"), 0) != 1:
        return build_response_body({}, errcode=400, errmsg="invalid code version")
    bucket = _practice_bucket(ctx, userid)
    return build_response_body({
        "dataVer": max(_data_ver(ctx, userid), _as_int(body.get("dataVer"), 0)),
        "itemMap": copy.deepcopy(bucket.get("itemMap") or {}),
    })


@route(["POST"], "useItem")
def use_item(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")

    body = _body_dict(ctx)
    item_id = str(body.get("itemId") or "")
    effect = XINSHEN_ITEM_EFFECTS.get(item_id)
    if effect is None:
        return build_response_body({}, errcode=400, errmsg="invalid xinshen item")
    if _as_int(body.get("codeVer"), 0) != 1:
        return build_response_body({}, errcode=400, errmsg="invalid code version")

    state_store = ctx["state"]
    with state_store._lock:
        server_data_ver = _data_ver(ctx, userid)
        request_data_ver = max(_as_int(body.get("dataVer"), 0), 0)
        bucket = _practice_bucket(ctx, userid)
        xin = bucket.setdefault("xinShen", {})
        requests = xin.setdefault("useItemRequests", {})
        request_key = "%s:%s" % (request_data_ver, item_id)
        previous = requests.get(request_key)
        if isinstance(previous, dict):
            result = copy.deepcopy(previous)
            result["dataVer"] = max(_as_int(result.get("dataVer"), 0), server_data_ver)
            return build_response_body(result)

        item_map = bucket.setdefault("itemMap", {})
        item = item_map.setdefault(item_id, {"count": 0})
        count = max(_as_int(item.get("count"), 0), 0)
        curr = max(_as_int(xin.get("curr"), DEFAULT_XINSHEN_MAX), 0)
        max_xin = max(_as_int(xin.get("max"), DEFAULT_XINSHEN_MAX), 1)

        if count <= 0:
            return build_response_body({}, errcode=400, errmsg="item not enough")
        if curr >= max_xin:
            return build_response_body({}, errcode=400, errmsg="xinshen is full")

        next_curr = min(curr + effect, max_xin)
        recover_start_time = max(
            _as_int(xin.get("recoverStartTime"), int(time.time())),
            0,
        )
        data_ver = max(server_data_ver, request_data_ver) + 1
        item["count"] = count - 1
        xin["curr"] = next_curr
        xin["max"] = max_xin
        xin["recoverStartTime"] = recover_start_time
        result = {
            "dataVer": data_ver,
            "curr": next_curr,
            "max": max_xin,
            "time": recover_start_time,
            "count": count - 1,
        }
        requests[request_key] = copy.deepcopy(result)
        while len(requests) > 20:
            requests.pop(next(iter(requests)))
        _save_bucket(ctx, userid, bucket)

        role = state_store.get_archive(userid)
        if isinstance(role, dict):
            role["dataVer"] = data_ver
            system = role.get("serverActionSystem")
            if isinstance(system, dict):
                system["dataVersion"] = data_ver
            state_store.put_archive(userid, role, data_ver=data_ver)

    return build_response_body(result)


@route(["POST"], "getXinShenRecoverStartTime")
def get_xin_shen_recover_start_time(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    _, _, recover_start_time = _settle_xinshen_recovery(bucket)
    _save_bucket(ctx, userid, bucket)
    return build_response_body({"time": recover_start_time})


@route(["POST"], "recoverXinShenValue")
def recover_xin_shen_value(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body_dict(ctx)
    if _as_int(body.get("codeVer"), 0) != 1:
        return build_response_body({}, errcode=400, errmsg="invalid code version")
    value = _as_int(body.get("value"), -1)
    if value != XINSHEN_RECOVER_VALUE:
        return build_response_body({}, errcode=400, errmsg="invalid recover value")
    now = int(time.time())
    client_time = _as_int(body.get("time"), -1)
    if client_time < 0 or abs(client_time - now) > XINSHEN_RECOVER_INTERVAL:
        return build_response_body({}, errcode=400, errmsg="invalid recover time")
    bucket = _practice_bucket(ctx, userid)
    xin = bucket.get("xinShen") or {}
    max_xin = max(_as_int(xin.get("max"), DEFAULT_XINSHEN_MAX), 1)
    curr = max(0, min(_as_int(xin.get("curr"), max_xin), max_xin))
    recover_start_time = max(_as_int(xin.get("recoverStartTime"), now), 0)
    if curr >= max_xin or now - recover_start_time < XINSHEN_RECOVER_INTERVAL:
        return build_response_body({}, errcode=400, errmsg="xinshen cannot recover")
    curr, max_xin, recover_start_time = _settle_xinshen_recovery(bucket, now)
    data_ver = max(_data_ver(ctx, userid), _as_int(body.get("dataVer"), 0)) + 1
    _save_bucket(ctx, userid, bucket)
    role = ctx["state"].get_archive(userid)
    if isinstance(role, dict):
        ctx["state"].put_archive(userid, role, data_ver=data_ver)
    return build_response_body({
        "dataVer": data_ver,
        "curr": curr,
        "max": max_xin,
        "time": recover_start_time,
    })


@route(["POST"], "getXinShenValue")
def get_xin_shen_value(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _practice_bucket(ctx, userid)
    curr, max_xin, recover_start_time = _settle_xinshen_recovery(bucket)
    _save_bucket(ctx, userid, bucket)
    return build_response_body({
        "curr": curr,
        "max": max_xin,
        "time": recover_start_time,
    })
