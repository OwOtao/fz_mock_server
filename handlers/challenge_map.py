# -*- coding: utf-8 -*-
"""Challenge entry, paid sessions and anecdote recovery.

Map costs/requirements are read from the client's Lua tables. Recovery cadence
and session lifetime are explicit mock settings, not verified upstream rules.
The client reentry contract rebuilds map_id; it does not upload room/NPC state.
"""
import copy
from datetime import datetime, timedelta, timezone
from functools import lru_cache
import os
from pathlib import Path
import time
import uuid
from collections import Counter

from lua_to_json import parse_lua_file
from protocol import build_response_body as response
from server import route
from handlers.challenge_rewards import roll_rewards, grant_rewards

# One point per 10 minutes, 100-point cap, 24-hour paid session by default.
ANECDOTE_MAX = max(1, int(os.getenv("MOCK_ANECDOTE_MAX", "100")))
RECOVER_SECONDS = max(1, int(os.getenv("MOCK_ANECDOTE_RECOVER_SECONDS", "600")))
SESSION_SECONDS = max(1, int(os.getenv("MOCK_CHALLENGE_SESSION_SECONDS", "86400")))
PREVIEW_SECONDS = 300
GAME_TZ = timezone(timedelta(hours=8))


def integer(value, default=0):
    try:
        return int(value)
    except (ValueError, TypeError, OverflowError):
        return default


def userid(ctx):
    return integer(ctx.get("headers", {}).get("userid"))


def body(ctx):
    value = ctx.get("body")
    return value if isinstance(value, dict) else {}


@lru_cache(maxsize=1)
def map_configs():
    path = Path(__file__).resolve().parents[1] / "fzjh_lua/assets/res/script/challengeMap/mapInfo.lua"
    return parse_lua_file(path)["map"]


def _account(state, uid):
    if state.get_account(uid) is None:
        state.ensure_account(uid)
    return state._state["accounts"][str(uid)]


def _progress(account):
    value = account.get("challenge_map")
    return value if isinstance(value, dict) else {}


def _recovered(state, uid, account, now):
    before = copy.deepcopy(account)
    currencies = account.get("currencies")
    if not isinstance(currencies, dict):
        currencies = account["currencies"] = {}
    if "anecdote" not in currencies:
        archive = state.get_archive(uid) or {}
        currencies["anecdote"] = max(integer(archive.get("anecdote", ANECDOTE_MAX)), 0)
    number = max(integer(currencies["anecdote"]), 0)
    last = integer(account.get("anecdote_recovered_at"), now)
    if number >= ANECDOTE_MAX:
        # Full balances cannot bank elapsed time for a later consumption.
        last = max(last, now)
    else:
        ticks = max(0, now - last) // RECOVER_SECONDS
        if ticks:
            number = min(ANECDOTE_MAX, number + ticks)
            last = now if number == ANECDOTE_MAX else last + ticks * RECOVER_SECONDS
    currencies["anecdote"] = number
    account["anecdote_recovered_at"] = last
    if account != before:
        state._changed()
    return {"number": number, "max_number": ANECDOTE_MAX}


def _session_status(progress, now):
    active = progress.get("active")
    if not isinstance(active, dict):
        return 0
    if active.get("settlement"):
        return 1  # An earned, unclaimed reward must not expire with the map.
    return 2 if now >= active["expires_at"] else 1


@route(["GET"], "get_user_anecdote")
def get_user_anecdote(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    state = ctx["state"]
    with state.defer_saves():
        return response(_recovered(state, uid, _account(state, uid), int(time.time())))


@route(["GET"], "challengemap_unfinished")
def challengemap_unfinished(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    state = ctx["state"]
    with state._lock:
        progress = _progress(state.get_account(uid) or {})
        return response({"status": _session_status(progress, int(time.time()))})


@route(["GET"], "reenter_challengemap")
def reenter_challengemap(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    state = ctx["state"]
    with state._lock:
        progress = _progress(state.get_account(uid) or {})
        status = _session_status(progress, int(time.time()))
        if status != 1:
            return response({}, errcode=410 if status == 2 else 404,
                            errmsg="调查时间已结束，请先离开" if status == 2 else "没有未完成的挑战副本")
        return response({"challengemap": copy.deepcopy(progress["active"])})


def _date_timestamp(value):
    return int(datetime.strptime(str(value), "%Y%m%d%H").replace(tzinfo=GAME_TZ).timestamp())


def _eligibility(spec, archive, progress, now):
    if integer(archive.get("lv")) < integer(spec.get("level")):
        return "角色等级不足"
    if spec.get("startTime") and now < _date_timestamp(spec["startTime"]):
        return "副本尚未开放"
    if spec.get("endTime") and now >= _date_timestamp(spec["endTime"]):
        return "副本已结束"
    sign = spec.get("sign") or []
    flags = archive.get("_flags") or {}
    if sign and (not isinstance(flags, dict) or flags.get(sign[0], 0) != sign[1]):
        return "未满足副本标记条件"
    count = progress.get("counts", {}).get(spec["id"], {})
    today = datetime.fromtimestamp(now, GAME_TZ).date().isoformat()
    daily = count.get("day_count", 0) if count.get("day") == today else 0
    for limit, used in ((spec.get("daily", -1), daily), (spec.get("activity", -1), count.get("total", 0))):
        if limit >= 0 and used >= limit:
            return "副本挑战次数已用尽"
    return ""


def _consume_items(spec, supplied, archive):
    """One configured alternative per requirement; never trust client quantities."""
    if supplied == {}:  # Lua's empty table may be encoded as {} or [].
        supplied = []
    required = spec.get("ExpendItem") or []
    if not isinstance(supplied, list) or len(supplied) != len(required):
        return None
    consume = Counter()
    for options, item in zip(required, supplied):
        if not isinstance(item, dict) or type(item.get("num")) is not int:
            return None
        if [item.get("id"), item["num"]] not in options or item["num"] <= 0:
            return None
        consume[item["id"]] += item["num"]
    items = archive.get("items") or []
    if not isinstance(items, list):
        return None
    inventory = Counter()
    for item in items:
        if isinstance(item, dict):
            inventory[str(item.get("itemId"))] += max(integer(item.get("count")), 0)
    if any(inventory[k] < n for k, n in consume.items()):
        return None
    return consume


@route(["POST"], "challengemap_enter")
def challengemap_enter(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    spec = map_configs().get(str(body(ctx).get("map_id") or ""))
    if spec is None:
        return response({}, errcode=404, errmsg="副本不存在")
    state, now = ctx["state"], int(time.time())
    with state.defer_saves():
        account = _account(state, uid)
        progress = _progress(account)
        if _session_status(progress, now):
            return response({}, errcode=409, errmsg="请先继续或离开未完成的副本")
        error = _eligibility(spec, state.get_archive(uid) or {}, progress, now)
        if error:
            return response({}, errcode=1, errmsg=error)
        balance = _recovered(state, uid, account, now)
        if balance["number"] < spec["strain"]:
            return response(balance, errcode=1, errmsg="轶闻值不足")
        progress["pending"] = {"map_id": spec["id"], "expires_at": now + PREVIEW_SECONDS}
        progress.pop("sweep_pending", None)
        account["challenge_map"] = progress
        state._changed()
        return response({"map_id": spec["id"], "level": spec["level"],
                         "sign": copy.deepcopy(spec.get("sign") or []), "strain": spec["strain"],
                         "number": balance["number"], "max_number": ANECDOTE_MAX})


@route(["POST"], "challengemap_confirm_consume")
def challengemap_confirm_consume(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    request = body(ctx)
    map_id = str(request.get("map_id") or "")
    spec = map_configs().get(map_id)
    if spec is None:
        return response({}, errcode=404, errmsg="副本不存在")
    supplied = request.get("consume_map", [])
    if supplied == {}:
        supplied = []
    state, now = ctx["state"], int(time.time())
    with state.defer_saves():
        account = _account(state, uid)
        progress = _progress(account)
        active = progress.get("active")
        if active:
            if _session_status(progress, now) == 1 and active["map_id"] == map_id and active["consume_map"] == supplied:
                return response(copy.deepcopy(active["consume_response"]))
            return response({}, errcode=409, errmsg="已有未完成副本，请先继续或离开")
        pending = progress.get("pending") or {}
        if pending.get("map_id") != map_id or now >= pending.get("expires_at", 0):
            return response({}, errcode=409, errmsg="请重新查看副本进入条件")
        archive = state.get_archive(uid) or {}
        error = _eligibility(spec, archive, progress, now)
        if error:
            return response({}, errcode=1, errmsg=error)
        consume = _consume_items(spec, supplied, archive)
        if consume is None:
            return response({}, errcode=1, errmsg="门票不足或消耗参数不匹配")
        balance = _recovered(state, uid, account, now)
        cost = integer(spec["strain"])
        if balance["number"] < cost:
            return response(balance, errcode=1, errmsg="轶闻值不足")
        expires = now + SESSION_SECONDS
        if spec.get("endTime"):
            expires = min(expires, _date_timestamp(spec["endTime"]))
        session_id = uuid.uuid4().hex
        result = {"map_id": map_id, "session_id": session_id,
                  "number": balance["number"] - cost, "max_number": ANECDOTE_MAX,
                  "cost": cost, "expires_at": expires}
        # Prepare the archive copy first; clients also remove these items locally.
        remaining_items = []
        for item in archive.get("items") or []:
            if not isinstance(item, dict):
                remaining_items.append(item)
                continue
            item_id = item.get("itemId")
            take = min(max(integer(item.get("count")), 0), consume[item_id])
            if take:
                item["count"] = integer(item["count"]) - take
                consume[item_id] -= take
                if item["count"] == 0:
                    continue
            remaining_items.append(item)
        archive["items"] = remaining_items
        archive["anecdote"] = result["number"]
        state.put_archive(uid, archive)
        account["currencies"]["anecdote"] = result["number"]
        today = datetime.fromtimestamp(now, GAME_TZ).date().isoformat()
        counts = progress.setdefault("counts", {}).setdefault(map_id, {})
        counts["day_count"] = (counts.get("day_count", 0) if counts.get("day") == today else 0) + 1
        counts["day"], counts["total"] = today, counts.get("total", 0) + 1
        progress["active"] = {"session_id": session_id, "map_id": map_id,
                              "started_at": now, "expires_at": expires,
                              "consume_map": copy.deepcopy(supplied), "consume_response": result}
        progress.pop("pending", None)
        account["challenge_map"] = progress
        state._changed()
        return response(copy.deepcopy(result))


@route(["POST"], "challengemap_leave")
def challengemap_leave(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    leave_type = body(ctx).get("type")
    if type(leave_type) is not int or leave_type not in (1, 2, 3):
        return response({}, errcode=400, errmsg="invalid leave type")
    state = ctx["state"]
    with state.defer_saves():
        account = _account(state, uid)
        progress = _progress(account)
        if (progress.get("active") or {}).get("settlement"):
            return response({}, errcode=409, errmsg="请先领取已完成副本的奖励")
        if progress.get("active") or progress.get("pending") or progress.get("sweep_pending"):
            active = progress.pop("active", None)
            progress.pop("pending", None)
            progress.pop("sweep_pending", None)
            if active:
                progress["last_left"] = {"session_id": active["session_id"],
                                         "map_id": active["map_id"], "type": leave_type,
                                         "left_at": int(time.time())}
            account["challenge_map"] = progress
            state._changed()
        return response({"status": 0})


def _sweep_items(spec, archive):
    """The sweep protocol omits tickets; use the client's first-affordable option."""
    items = archive.get("items") or []
    if not isinstance(items, list):
        return None
    inventory = Counter()
    for item in items:
        if isinstance(item, dict):
            inventory[item.get("itemId")] += max(integer(item.get("count")), 0)
    selected = []
    for options in spec.get("ExpendItem") or []:
        option = next(((k, n) for k, n in options if inventory[k] >= n), None)
        if option is None:
            return None
        item_id, amount = option
        inventory[item_id] -= amount
        selected.append({"id": item_id, "num": amount})
    return selected


def _sweep_error(spec, archive, progress, now):
    if not spec.get("cleanId"):
        return "该副本不支持扫荡"
    # Conservative mock eligibility: one rewarded normal completion first.
    if spec["id"] not in progress.get("completed", {}):
        return "请先正常通关该副本并领取奖励"
    window = spec.get("notcleaningtime") or []
    if len(window) == 2:
        start, end = (datetime.strptime(v, "%Y-%m-%d %H:%M:%S").replace(tzinfo=GAME_TZ).timestamp() for v in window)
        if start <= now <= end:
            return "当前时段不能扫荡"
    return _eligibility(spec, archive, progress, now)


@route(["POST"], "challengemap_is_customs")
def challengemap_is_customs(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    spec = map_configs().get(str(body(ctx).get("map_id") or ""))
    if spec is None:
        return response({}, errcode=404, errmsg="副本不存在")
    state, now = ctx["state"], int(time.time())
    with state.defer_saves():
        account = _account(state, uid)
        progress = _progress(account)
        if progress.get("active"):
            return response({}, errcode=409, errmsg="请先处理未完成副本或待领取奖励")
        archive = state.get_archive(uid) or {}
        error = _sweep_error(spec, archive, progress, now)
        if error:
            return response({}, errcode=1, errmsg=error)
        if _sweep_items(spec, archive) is None:
            return response({}, errcode=1, errmsg="门票不足")
        balance = _recovered(state, uid, account, now)
        if balance["number"] < spec["strain"]:
            return response(balance, errcode=1, errmsg="轶闻值不足")
        progress["sweep_pending"] = {"map_id": spec["id"], "expires_at": now + PREVIEW_SECONDS}
        progress.pop("pending", None)
        account["challenge_map"] = progress
        state._changed()
        return response({"map_id": spec["id"], "can_customs": True, **balance})


@route(["POST"], "challengemap_finish")
def challengemap_finish(ctx):
    uid, request = userid(ctx), body(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    map_id, kind = str(request.get("map_id") or ""), request.get("finish_type")
    if type(kind) is not int or kind not in (1, 2):
        return response({}, errcode=400, errmsg="invalid finish type")
    spec = map_configs().get(map_id)
    if spec is None:
        return response({}, errcode=404, errmsg="副本不存在")
    state, now = ctx["state"], int(time.time())
    with state.defer_saves():
        account = _account(state, uid)
        progress = _progress(account)
        active = progress.get("active")
        existing = (active or {}).get("settlement")
        if not active and not progress.get("pending") and not progress.get("sweep_pending"):
            existing = progress.get("last_settlement")
        if existing and existing["map_id"] == map_id and existing["finish_type"] == kind:
            return response(copy.deepcopy(existing["finish_response"]))
        if active and (active["map_id"] != map_id or existing or kind == 2):
            return response({}, errcode=409, errmsg="副本会话与结算请求不匹配")
        archive = state.get_archive(uid) or {}
        if kind == 1:
            if not active or _session_status(progress, now) != 1:
                return response({}, errcode=409, errmsg="没有可结算的已付费副本")
        else:
            pending = progress.get("sweep_pending") or {}
            if pending.get("map_id") != map_id or now >= pending.get("expires_at", 0):
                return response({}, errcode=409, errmsg="请重新检查扫荡条件")
            error = _sweep_error(spec, archive, progress, now)
            if error:
                return response({}, errcode=1, errmsg=error)
            supplied = _sweep_items(spec, archive)
            if supplied is None:
                return response({}, errcode=1, errmsg="门票不足")
        award_id = spec.get("awardId" if kind == 1 else "cleanId") or ""
        try:
            rewards = roll_rewards(award_id, spec.get("rsesources"))
        except (KeyError, ValueError, TypeError, RecursionError):
            return response({}, errcode=500, errmsg="奖励配置无法解析，未结算或扣除扫荡费用")
        if kind == 2:
            # Reuse the paid-entry validation and accounting under the same lock.
            progress["pending"] = dict(progress["sweep_pending"])
            paid = challengemap_confirm_consume({**ctx, "body": {"map_id": map_id, "consume_map": supplied}})
            progress.pop("pending", None)
            if paid["errcode"] != 0:
                return paid
            active = progress["active"]
            progress.pop("sweep_pending", None)
        result = {"award_id": award_id, "session_id": active["session_id"]}
        active["settlement"] = {"map_id": map_id, "finish_type": kind,
                                "session_id": active["session_id"], "finished_at": now,
                                "finish_response": result, "rewards": rewards}
        state._changed()
        return response(copy.deepcopy(result))


@route(["POST"], "challengemap_award")
def challengemap_award(ctx):
    uid, request = userid(ctx), body(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    map_id, kind, delivery = str(request.get("map_id") or ""), request.get("finish_type"), request.get("type")
    if type(kind) is not int or kind not in (1, 2) or type(delivery) is not int or delivery not in (1, 2):
        return response({}, errcode=400, errmsg="invalid award type")
    # Client rolls are advisory only: never use their ids or quantities to grant.
    uploaded = request.get("award_list", [])
    if uploaded == {}:
        uploaded = []
    if not isinstance(uploaded, list) or len(uploaded) > 100 or any(not isinstance(v, dict) for v in uploaded):
        return response({}, errcode=400, errmsg="invalid award list")
    if "currencyVersion" in request and (type(request["currencyVersion"]) is not int or request["currencyVersion"] < 0):
        return response({}, errcode=400, errmsg="invalid currency version")
    state = ctx["state"]
    with state.defer_saves():
        account = _account(state, uid)
        progress = _progress(account)
        active = progress.get("active")
        settlement = active.get("settlement") if active else progress.get("last_settlement")
        if not settlement or settlement["map_id"] != map_id or settlement["finish_type"] != kind:
            return response({}, errcode=409, errmsg="没有匹配的待领取奖励")
        if settlement.get("award_response"):
            if settlement["delivery"] != delivery:
                return response({}, errcode=409, errmsg="奖励已按另一方式领取")
            return response(copy.deepcopy(settlement["award_response"]))
        account_copy = copy.deepcopy(account)
        try:
            result = grant_rewards(state, uid, account_copy, state.get_archive(uid) or {}, settlement["rewards"], delivery)
        except (ValueError, TypeError, KeyError):
            return response({}, errcode=409, errmsg="角色存档结构异常，奖励保留待领取")
        account["currencies"] = account_copy["currencies"]
        account["currency_version"] = account_copy["currency_version"]
        result["session_id"] = settlement["session_id"]
        settlement["award_response"], settlement["delivery"] = result, delivery
        if kind == 1:
            progress.setdefault("completed", {})[map_id] = settlement["finished_at"]
        progress["last_settlement"] = settlement
        progress.pop("active", None)
        state._changed()
        return response(copy.deepcopy(result))


@route(["GET"], "test_revert_anecdote")
def test_revert_anecdote(ctx):
    """Existing client debug endpoint; explicit refill, never an automatic refund."""
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    state, now = ctx["state"], int(time.time())
    with state.defer_saves():
        account = _account(state, uid)
        balance = _recovered(state, uid, account, now)
        account["currencies"]["anecdote"] = max(balance["number"], ANECDOTE_MAX)
        account["anecdote_recovered_at"] = max(now, account["anecdote_recovered_at"])
        state._changed()
        return response({"number": account["currencies"]["anecdote"], "max_number": ANECDOTE_MAX})


@route(["POST"], "get_festivalmap_info")
def get_festivalmap_info(ctx):
    uid = userid(ctx)
    if uid <= 0:
        return response({}, errcode=552, errmsg="userid not found")
    group = integer(body(ctx).get("groupId"), -1)
    maps = sorted((m for m in map_configs().values()
                   if m.get("type") == 2 and m["section"][0] == group),
                  key=lambda m: m["section"][1])
    if not maps:
        return response({}, errcode=404, errmsg="节日副本组不存在")
    state = ctx["state"]
    with state._lock:
        counts = _progress(state.get_account(uid) or {}).get("counts", {})
        today = datetime.fromtimestamp(time.time(), GAME_TZ).date().isoformat()
        return response([{"map_id": m["id"],
                          "dayTime": counts.get(m["id"], {}).get("day_count", 0)
                          if counts.get(m["id"], {}).get("day") == today else 0,
                          "finalTime": counts.get(m["id"], {}).get("total", 0)}
                         for m in maps])
