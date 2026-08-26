# -*- coding: utf-8 -*-

import time
import hmac

import config

from protocol import build_response_body
from server import route


ACTIVITY_LIST_RAND_T = 1787731490.8493
def _userid(ctx):
    try:
        return int(ctx.get("headers", {}).get("userid", 0))
    except (TypeError, ValueError):
        return 0


def _body(ctx):
    value = ctx.get("body")
    return value if isinstance(value, dict) else {}


def _first_present(source, keys):
    for key in keys:
        if key in source and source.get(key) not in (None, ""):
            return source.get(key)
    return None


def _admin_mail_body(ctx):
    body = dict(_body(ctx))
    raw = ctx.get("raw_body")
    if not body and isinstance(raw, str) and raw.strip():
        from protocol import parse_request_json
        parsed = parse_request_json(raw, content_type=str(ctx.get("headers", {}).get("content-type") or ""))
        if isinstance(parsed, dict):
            body = dict(parsed)
    for key in ("data", "payload", "params", "mail"):
        inner = body.get(key)
        if isinstance(inner, str) and inner.strip():
            from protocol import parse_request_json
            inner = parse_request_json(inner)
        if isinstance(inner, dict):
            merged = dict(body)
            merged.update(inner)
            body = merged
            break
    query = ctx.get("query")
    if isinstance(query, dict):
        for key, value in query.items():
            body.setdefault(key, value)
    return body


def _tail(ctx, index=0, default=""):
    values = ctx.get("route_tail", [])
    return values[index] if len(values) > index else default


def _ok(data=None):
    return build_response_body({} if data is None else data)


def _fight_user(ctx):
    userid = _userid(ctx)
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return 0
    return userid


def _fight_body(ctx):
    body = _body(ctx)
    try:
        body["fid"] = str(body.get("fid", ""))
    except AttributeError:
        return {}
    return body


def _fight_result(userid, fight, result, current_cnt):
    win = str(result).lower() == "win"
    lose = str(result).lower() == "lose"
    status = "finished" if result in ("win", "lose") else "cancelled"
    state = {
        "stage": "on_stage" if result in ("win", "lose", "run") else "idle",
        "current_match_id": None,
        "last_result": result,
        "current_cnt": current_cnt,
        "renqi": int(fight.get("win_points", 0)) if win else 0,
        "week_renqi": int(fight.get("week_renqi", 0)) + (int(fight.get("win_points", 0)) if win else 0),
        "today_max_point": int(fight.get("today_max_point", 0)),
    }
    fight.update({
        "status": status,
        "result": result,
        "finished_at": int(time.time()),
    })
    return state, {
        "current_time": int(time.time()),
        "expired_time": int(time.time()) + 86400,
        "lose_points": int(fight.get("lose_points", 0)) if lose else 0,
        "current_cnt": current_cnt,
        "renqi": state["renqi"],
        "win_points": int(fight.get("win_points", 0)) if win else 0,
        "win_times": 1 if win else 0,
        "stage_renqi": state["renqi"],
        "today_max_point": state["today_max_point"],
    }


# shoplist.lua 测试商品: 醉梦生 / 鲁班奇偶 / 门派顶级残页, 各 1 元宝
DEFAULT_YUANBAO = 9999
_BAG_UPGRADE_COSTS = (
    0, 12000, 48000, 84000, 120000, 156000, 192000, 228000,
    264000, 300000, 336000, 372000, 408000, 444000, 480000,
    768000, 1227000, 1964000, 3123000, 4962000, 7859000,
    12412000, 19542000, 30702000, 48151000, 55284000, 63362000,
    72500000, 82821000, 94484000, 107660000,
)
_WAREHOUSE_UPGRADE_COSTS = (
    0, 6000, 42000, 78000, 114000, 150000, 186000, 222000,
    258000, 294000, 330000, 366000, 402000, 438000, 474000,
    720000, 1086000, 1622000, 2420000, 3588000, 5307000,
    7826000, 11514000, 16902000, 24754000, 28422000, 32581000,
    37290000, 42612000, 48614000, 55396000,
)
_STORE_TEST_ITEMS = [
    {
        "id": "300003",
        "itemId": "jiu106",
        "itype": 10,
        "name": "醉梦生",
        "dsc": "这是一坛醉梦生，相传此酒可以让人忘却烦恼，醉生梦死。",
        "icon": "Image/UI/StoreUI/juhuajiu100.png",
        "price": 1,
        "number": 1,
        "Inventory": -1,
        "quota": -1,
        "viewtype": 0,
        "extra": {},
    },
    {
        "id": "300257",
        "itemId": "jiaren005",
        "itype": 10,
        "name": "鲁班奇偶",
        "dsc": "传闻此物乃天工巧匠鲁班所传至宝，形态栩栩如生，全身各处布有精密机关，构造巧妙。年代久远，却不见丝毫锈迹和腐坏！",
        "icon": "Image/UI/StoreUI/muren2_1.png",
        "price": 1,
        "number": 1,
        "Inventory": -1,
        "quota": -1,
        "viewtype": 0,
        "extra": {},
    },
    {
        "id": "500579",
        "itemId": "menpaicanye4",
        "itype": 10,
        "name": "门派顶级残页",
        "dsc": "这是门派顶级残页，打开可获得对应门派的顶级技能残页宝箱。",
        "icon": "Image/UI/StoreUI/canye.png",
        "price": 1,
        "number": 1,
        "Inventory": -1,
        "quota": -1,
        "viewtype": 0,
        "extra": {},
    },
]


def _as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return int(default)


def _find_store_item(item_key):
    key = str(item_key or "")
    if not key:
        return None
    for item in _STORE_TEST_ITEMS:
        if str(item.get("itemId")) == key or str(item.get("id")) == key:
            return dict(item)
    return None


def _goods_detail(item):
    dsc = str(item.get("dsc") or "")
    mid = max(1, len(dsc) // 2)
    return {
        "id": str(item.get("id") or ""),
        "itemId": str(item.get("itemId") or ""),
        "name": str(item.get("name") or ""),
        "price": _as_int(item.get("price"), 1),
        "dsc1": dsc[:mid] if dsc else "",
        "dsc2": dsc[mid:] if dsc else "",
        "icon": str(item.get("icon") or ""),
        "discount": 0,
        "share": "",
        "available": True,
        "itype": item.get("itype"),
        "number": _as_int(item.get("number"), 1),
        "Inventory": _as_int(item.get("Inventory"), -1),
        "quota": _as_int(item.get("quota"), -1),
        "viewtype": _as_int(item.get("viewtype"), 0),
        "extra": item.get("extra") if isinstance(item.get("extra"), dict) else {},
    }


def _get_yuanbao_balance(ctx, userid):
    if userid <= 0:
        return DEFAULT_YUANBAO
    ctx["state"].ensure_account(userid)
    with ctx["state"]._lock:
        account = ctx["state"]._state.setdefault("accounts", {}).setdefault(str(userid), {})
        if "yuanbao" not in account:
            account["yuanbao"] = DEFAULT_YUANBAO
            ctx["state"]._changed()
        return _as_int(account.get("yuanbao"), DEFAULT_YUANBAO)


def _set_yuanbao_balance(ctx, userid, value):
    value = max(_as_int(value, 0), 0)
    ctx["state"].ensure_account(userid)
    with ctx["state"]._lock:
        account = ctx["state"]._state.setdefault("accounts", {}).setdefault(str(userid), {})
        account["yuanbao"] = value
        account["updated_at"] = int(time.time())
        ctx["state"]._changed()
    return value


def _store_list_payload(yuanbao=DEFAULT_YUANBAO):
    # StoreLayer 默认 goodsType=2 -> list[2] 名称必须是“商城”
    return {
        "status": "OPEN",
        "list": [
            {"name": "限时", "items": []},
            {"name": "商城", "items": [dict(x) for x in _STORE_TEST_ITEMS]},
            {"name": "关卡", "items": []},
            {"name": "神功", "items": []},
        ],
        "yuanbao": int(yuanbao),
        "eleven": 0,
        "yueka_expired_time": 0,
        "yashi_expired_time": 0,
        "yashi_welfare_point": 0,
        "privilege_expired_time": 0,
        "privilege_remaining_watches": 0,
    }


def _upgrade_bag(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    upgrade_type = _as_int(body.get("type"), 0)
    target_level = _as_int(body.get("level"), 0)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    if upgrade_type not in (1, 2):
        return build_response_body({}, errcode=400, errmsg="unsupported bag type")
    costs = _BAG_UPGRADE_COSTS if upgrade_type == 1 else _WAREHOUSE_UPGRADE_COSTS
    level_index = target_level - 1000
    if level_index <= 0 or level_index >= len(costs):
        return build_response_body({}, errcode=1, errmsg="背包或仓库已达最大容量")
    with ctx["state"]._lock:
        role = ctx["state"].get_archive(userid)
        if not isinstance(role, dict):
            return build_response_body({}, errcode=404, errmsg="archive not found")
        count_key = "wUpCount" if upgrade_type == 1 else "ckUpCount"
        current_level = 1000 + max(_as_int(role.get(count_key), 0), 0)
        if target_level != current_level + 1:
            return build_response_body(
                {"current_level": current_level},
                errcode=409,
                errmsg="bag level conflict",
            )
        cost = costs[level_index]
        money = float(role.get("money", 0) or 0)
        if money < cost:
            return build_response_body(
                {"currency": 1, "count": cost},
                errcode=1,
                errmsg="碎银不足",
            )
        target_capacity = 30 + level_index * 5
        role["money"] = money - cost
        role[count_key] = level_index
        if upgrade_type == 1:
            role["weight"] = target_capacity
        else:
            old_base = max(_as_int(role.get("baseCkLimit"), 30), 0)
            old_total = max(_as_int(role.get("ckLimit"), old_base), old_base)
            role["baseCkLimit"] = target_capacity
            role["ckLimit"] = max(old_total + target_capacity - old_base, target_capacity)
        data_ver = max(_as_int(role.get("dataVer"), 0), 0) + 1
        ctx["state"].put_archive(userid, role, data_ver=data_ver)
    return _ok({
        "type": upgrade_type,
        "level": target_level,
        "currency": 1,
        "count": cost,
        "bagcount": target_capacity,
        "dataVer": data_ver,
    })


@route(["POST"], "upgrade_user_bag")
def upgrade_user_bag(ctx):
    return _upgrade_bag(ctx)


@route(["POST"], "vupgrade_user_bag")
def vupgrade_user_bag(ctx):
    return _upgrade_bag(ctx)


@route(["POST"], "get_config_fuben")
def get_config_fuben(ctx):
    return _ok({"status": 1})


@route(["GET", "POST"], "get_store_list_4")
def get_store_list(ctx):
    userid = _userid(ctx)
    yuanbao = _get_yuanbao_balance(ctx, userid) if userid > 0 else DEFAULT_YUANBAO
    return _ok(_store_list_payload(yuanbao))


@route(["GET"], "get_applestore_list")
def get_app_store_list(ctx):
    return _ok([])


@route(["GET", "POST"], "get_yuanbao")
def get_yuanbao(ctx):
    userid = _userid(ctx)
    yuanbao = _get_yuanbao_balance(ctx, userid) if userid > 0 else DEFAULT_YUANBAO
    return _ok({"yuanbao": yuanbao})


_CURRENCY_LIMITS = {
    "zongheng": 9999,
}
_YINPIAO_EXCHANGE_COST_YB = 10


def _currency_balance(ctx, userid, currency_type):
    currency_type = str(currency_type or "").strip()
    if not currency_type:
        return 0
    if currency_type == "yuanbao":
        return _get_yuanbao_balance(ctx, userid) if userid > 0 else DEFAULT_YUANBAO
    archive_value = 0
    account_value = 0
    if userid > 0:
        archive = ctx["state"].get_archive(userid)
        if isinstance(archive, dict):
            archive_value = max(_as_int(archive.get(currency_type), 0), 0)
        account = ctx["state"].get_account(userid) or {}
        currencies = account.get("currencies")
        if isinstance(currencies, dict):
            account_value = max(_as_int(currencies.get(currency_type), 0), 0)
    return max(archive_value, account_value)


def _set_currency_balance(ctx, userid, currency_type, value):
    currency_type = str(currency_type or "").strip()
    value = max(_as_int(value, 0), 0)
    if not currency_type or userid <= 0:
        return value
    if currency_type == "yuanbao":
        return _set_yuanbao_balance(ctx, userid, value)
    ctx["state"].ensure_account(userid)
    with ctx["state"]._lock:
        account = ctx["state"]._state.setdefault("accounts", {}).setdefault(str(userid), {})
        currencies = account.get("currencies")
        if not isinstance(currencies, dict):
            currencies = {}
            account["currencies"] = currencies
        currencies[currency_type] = value
        account["updated_at"] = int(time.time())
        ctx["state"]._changed()
    archive = ctx["state"].get_archive(userid)
    if isinstance(archive, dict):
        archive[currency_type] = value
        ctx["state"].put_archive(userid, archive)
    return value


@route(["POST"], "view_currency_by_type")
def view_currency_by_type(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    currency_type = str(body.get("currency_type") or body.get("cType") or "").strip()
    number = _currency_balance(ctx, userid, currency_type)
    data = {"number": number, "currency_type": currency_type}
    if currency_type in _CURRENCY_LIMITS:
        data["limitNumber"] = _CURRENCY_LIMITS[currency_type]
    if currency_type == "yinpiao":
        data["costYb"] = _YINPIAO_EXCHANGE_COST_YB
    return _ok(data)


@route(["GET", "POST"], "get_goods")
def get_goods(ctx):
    item_key = _tail(ctx)
    item = _find_store_item(item_key)
    if item is None:
        return build_response_body({}, errcode=404, errmsg="goods not found")
    return _ok(_goods_detail(item))


@route(["GET", "POST"], "get_user_shenbings")
def get_user_shenbings(ctx):
    userid = _userid(ctx)
    role = ctx["state"].get_archive(userid) if userid > 0 else None
    role = role if isinstance(role, dict) else {}
    shen_bing_items = role.get("shenBingItems")
    if not isinstance(shen_bing_items, list):
        shen_bing_items = []
    return _ok({"shenBingItems": shen_bing_items})


@route(["POST"], "get_ckitems_list")
def get_ckitems_list(ctx):
    body = _body(ctx)
    userid = _userid(ctx)
    role = ctx["state"].get_archive(userid) if userid > 0 else None
    role = role if isinstance(role, dict) else {}
    source = role.get("ckitems")
    values = source if isinstance(source, list) else []
    items = []
    for value in values:
        if not isinstance(value, dict):
            continue
        item_id = value.get("itemId") or value.get("id")
        if not item_id:
            continue
        items.append({
            "itemId": item_id,
            "total": _as_int(value.get("total", value.get("count", 0)), 0),
            "info": value.get("info", ""),
            "update_time": value.get("update_time", 0),
        })
    try:
        local_ver = int(body.get("ver", 0) or 0)
    except (TypeError, ValueError):
        local_ver = 0
    size = max(_as_int(role.get("ckLimit"), 55), 0)
    return _ok({"ver": max(local_ver, 1), "list": items, "size": size})


@route(["GET"], "get_buy_order_id")
def get_buy_order_id(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    order = ctx["state"].create_order(userid)
    return _ok({"order_id": order.get("order_id") or order.get("trans_id")})


@route(["POST"], "buy_goods_3")
def buy_goods(ctx):
    """购买成功回包:
    {
      total_yuanbao, remove_yuanbao, special_reward, activity
    }
    物品发放由客户端本地处理。
    """
    userid = _userid(ctx)
    body = _body(ctx)
    item_key = _tail(ctx) or body.get("itemId") or body.get("id")
    client_trans_id = body.get("client_trans_id")
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    if not client_trans_id:
        return build_response_body({}, errcode=400, errmsg="client_trans_id is required")
    item = _find_store_item(item_key)
    if item is None:
        # 兜底: 用请求里的 id/itemId 构造最小商品, 价格按 1
        item = {
            "id": str(body.get("id") or item_key or ""),
            "itemId": str(body.get("itemId") or item_key or ""),
            "name": str(item_key or "goods"),
            "price": 1,
        }
    quantity = max(_as_int(body.get("quantity"), 1), 1)
    unit_price = _as_int(item.get("price"), 1)
    discount = _as_int(body.get("discount"), 0)
    # discount=1 时按半价兜底, 其余按原价
    if discount == 1:
        cost = max(int(unit_price * quantity * 0.5), 0)
    else:
        cost = unit_price * quantity
    balance = _get_yuanbao_balance(ctx, userid)
    if balance < cost:
        return build_response_body(
            {"total_yuanbao": balance, "remove_yuanbao": 0},
            errcode=1,
            errmsg="元宝不足，购买失败！",
        )
    total = _set_yuanbao_balance(ctx, userid, balance - cost)
    order = ctx["state"].create_order(userid, body)
    ctx["state"].update_order(order["trans_id"], {
        "status": "success",
        "item_id": item.get("itemId"),
        "shop_id": item.get("id"),
        "quantity": quantity,
        "remove_yuanbao": cost,
        "total_yuanbao": total,
        "client_trans_id": client_trans_id,
    })
    return build_response_body({
        "total_yuanbao": total,
        "remove_yuanbao": cost,
        "special_reward": {},
        "activity": {},
        "client_trans_id": client_trans_id,
        "itemId": item.get("itemId"),
        "id": item.get("id"),
        "quantity": quantity,
    }, errcode=0, errmsg="", status=200)


@route(["POST"], "check_fail_transaction_2")
def check_transaction(ctx):
    body = _body(ctx)
    order = ctx["state"].get_order(body.get("trans_id"))
    return _ok(order or {"status": "not_found"})


@route(["GET"], "remove_yuanbao")
def remove_yuanbao(ctx):
    return _ok({"yuanbao": 0, "num": _tail(ctx), "trans_id": _tail(ctx, 1)})


@route(["GET"], "get_reward")
def get_reward(ctx):
    return _ok([])


@route(["POST"], "get_reward_2")
def get_reward_2(ctx):
    return _ok({"received": True, "type": _tail(ctx)})


@route(["GET"], "get_jhms_desc")
def get_jhms_desc(ctx):
    return _ok({"yueka": False, "expired_time": 0})


@route(["POST"], "get_jhms_reward")
def get_jhms_reward(ctx):
    return _ok({"received": True})


@route(["POST"], "check_pay_sign")
def check_pay_sign(ctx):
    return _ok({"valid": True})


@route(["POST"], "update_order_state")
def update_order_state(ctx):
    return _ok({"updated": True})


def _mail_rewards(item):
    rewards = item.get("rewards") if isinstance(item.get("rewards"), dict) else {}
    result = {}
    for key in ("loc_items", "net_items", "loc_attrs", "net_attrs", "new_currencys", "title_items"):
        values = rewards.get(key)
        normalized = []
        if isinstance(values, list):
            for index, value in enumerate(values):
                if not isinstance(value, dict):
                    continue
                reward = dict(value)
                reward["id"] = str(reward.get("id") or "")
                reward["num"] = _as_int(reward.get("num"), 0)
                reward["state"] = _as_int(reward.get("state"), 0)
                reward.setdefault("onlyId", "%s-%d" % (key, index + 1))
                if key == "net_items":
                    reward.setdefault("name", reward["id"])
                normalized.append(reward)
        result[key] = normalized
    return result


def _mail_payload(item):
    value = dict(item)
    rewards = _mail_rewards(value)
    for reward in rewards["net_items"]:
        reward.setdefault("name", reward.get("id", ""))
    value["id"] = value.get("mail_id")
    value["contents"] = value.get("content", "")
    value["is_read"] = 1 if value.get("read") else 0
    value["is_get"] = 2 if value.get("claimed") else (1 if any(rewards.values()) else 0)
    value["state"] = value["is_get"]
    expired_at = _as_int(value.get("expired_time"), 0)
    value["expired_time"] = max(expired_at - int(time.time()), 0) if expired_at else 0
    value.update(rewards)
    return value


def _valid_reward_list(values):
    if values is None:
        return []
    if not isinstance(values, list) or len(values) > 100:
        raise ValueError("reward list is invalid")
    result = []
    for value in values:
        if not isinstance(value, dict):
            raise ValueError("reward is invalid")
        reward_id = str(value.get("id") or "").strip()
        num = _as_int(value.get("num"), 0)
        if not reward_id or num <= 0 or num > 100000000:
            raise ValueError("reward is invalid")
        reward = {"id": reward_id, "num": num, "state": 0}
        if value.get("name"):
            reward["name"] = str(value["name"])
        result.append(reward)
    return result


def _normalize_mail_rewards(body):
    source = body.get("rewards") if isinstance(body.get("rewards"), dict) else body
    rewards = {
        key: _valid_reward_list(source.get(key))
        for key in ("loc_items", "net_items", "loc_attrs", "net_attrs", "new_currencys", "title_items")
    }
    for key, values in rewards.items():
        for index, value in enumerate(values):
            value["onlyId"] = "%s-%d" % (key, index + 1)
    return rewards


def _mail_admin_authorized(ctx):
    expected = str(getattr(config, "ADMIN_API_TOKEN", "") or "")
    if not expected:
        return True
    provided = str(ctx.get("headers", {}).get("x-admin-token") or "")
    return hmac.compare_digest(provided, expected)


@route(["GET"], "get_email_info")
def get_email_info(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    email_list = [
        _mail_payload(item)
        for item in ctx["state"].list_mail(userid)
        if not item.get("deleted")
    ]
    return _ok({
        "emailList": email_list,
        "emailMaxNum": 50,
    })


@route(["POST"], "read_email")
def read_email(ctx):
    userid = _userid(ctx)
    email_id = _body(ctx).get("email_id") or _body(ctx).get("id")
    if userid <= 0 or not email_id:
        return build_response_body({}, errcode=550, errmsg="invalid email")
    item = ctx["state"].get_mail(userid, email_id)
    if item is None:
        return build_response_body({}, errcode=404, errmsg="email not found")
    ctx["state"].update_mail(userid, email_id, {"read": True})
    item["read"] = True
    return _ok(_mail_payload(item))


@route(["GET"], "delete_email")
def delete_email(ctx):
    userid = _userid(ctx)
    email_id = _tail(ctx)
    if userid <= 0 or not email_id:
        return build_response_body({}, errcode=550, errmsg="invalid email")
    item = ctx["state"].get_mail(userid, email_id)
    if item is None or item.get("deleted"):
        return build_response_body({}, errcode=404, errmsg="mail not found")
    ctx["state"].update_mail(userid, email_id, {"deleted": True})
    return _ok({"email_id": email_id, "deleted": True})


def _apply_archive_rewards(state, userid, rewards, data_ver, currency_version):
    archive = state.get_archive(userid) or {}
    role = archive
    items = role.setdefault("items", [])

    for value in rewards["net_items"]:
        item_id = str(value.get("id") or "")
        amount = _as_int(value.get("num"), 0)
        if not item_id or amount <= 0:
            continue
        found = None
        for item in items:
            if str(item.get("itemId")) == item_id:
                found = item
                break
        if found is None:
            next_id = max(
                [_as_int(item.get("id"), 0) for item in items if isinstance(item, dict)]
                or [0]
            ) + 1
            items.append({"id": next_id, "itemId": item_id, "count": amount})
        else:
            found["count"] = max(_as_int(found.get("count"), 0), 0) + amount

    for value in rewards["net_attrs"] + rewards["new_currencys"]:
        currency_id = str(value.get("id") or "")
        amount = _as_int(value.get("num"), 0)
        if not currency_id or amount <= 0:
            continue
        if currency_id in ("yuanbao", "yinpiao", "money", "gold"):
            role[currency_id] = max(_as_int(role.get(currency_id), 0), 0) + amount
        else:
            role[currency_id] = max(_as_int(role.get(currency_id), 0), 0) + amount

    role["currencyVersion"] = currency_version
    role["dataVer"] = data_ver
    return state.put_archive(userid, role, data_ver=data_ver)


@route(["POST"], "get_email_reward")
def get_email_reward(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    email_id = body.get("email_id") or body.get("id")
    if userid <= 0 or not email_id:
        return build_response_body({}, errcode=550, errmsg="invalid email")
    with ctx["state"]._lock:
        item = ctx["state"].get_mail(userid, email_id)
        if item is None:
            return build_response_body({}, errcode=404, errmsg="email not found")
        if item.get("claimed"):
            return _ok({"email_id": email_id, "claimed": True, "replayed": True})
        expired_at = _as_int(item.get("expired_time"), 0)
        if expired_at and expired_at <= int(time.time()):
            return build_response_body({"expired_ids": [email_id]}, errcode=2, errmsg="email expired")
        rewards = _mail_rewards(item)
        requested = body.get("retrievables")
        if isinstance(requested, list) and requested:
            selected = {str(value) for value in requested}
            for key in ("loc_items", "loc_attrs"):
                rewards[key] = [
                    value
                    for value in rewards[key]
                    if str(value.get("onlyId")) in selected
                ]
        inventory = ctx["state"]._state.setdefault("inventory_items", {}).setdefault(str(userid), {})
        for value in rewards["net_items"]:
            item_id = str(value["id"])
            inventory[item_id] = max(_as_int(inventory.get(item_id), 0), 0) + value["num"]
        account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
        currencies = account.setdefault("currencies", {})
        for value in rewards["net_attrs"] + rewards["new_currencys"]:
            currency_id = str(value["id"])
            if currency_id == "yuanbao":
                account["yuanbao"] = max(_as_int(account.get("yuanbao"), 0), 0) + value["num"]
            else:
                currencies[currency_id] = max(_as_int(currencies.get(currency_id), 0), 0) + value["num"]
        account["currency_version"] = max(
            _as_int(account.get("currency_version"), 0),
            _as_int(body.get("currencyVersion"), 0),
        ) + 1
        archive = ctx["state"].get_archive(userid) or {}
        data_ver = max(
            _as_int(archive.get("dataVer"), 0),
            _as_int(body.get("dataVer"), 0),
        ) + 1
        currency_version = max(
            _as_int(archive.get("currencyVersion"), 0),
            _as_int(body.get("currencyVersion"), 0),
            _as_int(account.get("currency_version"), 0),
        )
        _apply_archive_rewards(
            ctx["state"],
            userid,
            rewards,
            data_ver,
            currency_version,
        )
        ctx["state"].update_mail(userid, email_id, {"read": True, "claimed": True, "state": 2})
        ctx["state"]._changed()
    result = {
        "email_id": email_id,
        "claimed": True,
        "is_get": 2,
        "expired_time": 0,
        "dataVer": data_ver,
        "currencyVersion": account["currency_version"],
    }
    result.update(rewards)
    return _ok(result)


@route(["POST"], "admin_send_email")
def admin_send_email(ctx):
    if not _mail_admin_authorized(ctx):
        return build_response_body({}, errcode=403, errmsg="forbidden")
    body = _admin_mail_body(ctx)
    request_id = str(_first_present(body, ("request_id", "requestId", "requestid", "req_id", "reqId")) or "").strip()
    userid = _as_int(_first_present(body, ("userid", "user_id", "userId", "uid", "user")), 0)
    title = str(_first_present(body, ("title", "subject", "mail_title")) or "").strip()
    content = str(_first_present(body, ("content", "contents", "text", "message", "desc", "description")) or "").strip()
    if not request_id or userid <= 0 or not title or not content:
        return build_response_body({}, errcode=400, errmsg="request_id, userid, title and content are required")
    with ctx["state"]._lock:
        existing = ctx["state"].get_mail_delivery(request_id)
        if existing is not None:
            if existing.get("userid") != userid:
                return build_response_body({}, errcode=409, errmsg="request_id conflict")
            return _ok(dict(existing, replayed=True))
        if ctx["state"].get_account(userid) is None:
            return build_response_body({}, errcode=404, errmsg="userid not found")
        try:
            rewards = _normalize_mail_rewards(body)
        except ValueError as exc:
            return build_response_body({}, errcode=400, errmsg=str(exc))
        now = int(time.time())
        expire_days = min(max(_as_int(body.get("expire_days"), 30), 1), 365)
        mail = ctx["state"].add_mail(userid, {
            "title": title[:100],
            "content": content[:2000],
            "sender": str(body.get("sender") or "江湖邮驿")[:50],
            "send_time": now,
            "expired_time": now + expire_days * 86400,
            "state": 1 if any(rewards.values()) else 0,
            "rewards": rewards,
            "request_id": request_id,
        })
        delivery = {
            "request_id": request_id,
            "userid": userid,
            "mail_id": mail["mail_id"],
            "created_at": now,
        }
        ctx["state"].record_mail_delivery(request_id, delivery)
    return _ok(delivery)


@route(["GET"], "get_email_rewards_list")
def get_email_rewards_list(ctx):
    return _ok([item for item in ctx["state"].list_mail(_userid(ctx)) if not item.get("claimed")])


@route(["POST"], "get_all_email_rewards")
def get_all_email_rewards(ctx):
    values = ctx["state"].list_mail(_userid(ctx))
    for item in values:
        if not item.get("claimed"):
            try:
                ctx["state"].update_mail(_userid(ctx), item.get("mail_id"), {"claimed": True})
            except (KeyError, ValueError):
                pass
    return _ok(values)


@route(["GET"], "delete_processed_emails")
def delete_processed_emails(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    delete_ids = []
    for item in ctx["state"].list_mail(userid):
        if item.get("deleted"):
            continue
        rewards = _mail_rewards(item)
        has_rewards = any(rewards.values())
        if item.get("claimed") or not has_rewards:
            email_id = str(item.get("mail_id") or "")
            if email_id:
                ctx["state"].update_mail(userid, email_id, {"deleted": True})
                delete_ids.append(email_id)
    return _ok({"delete_ids": delete_ids})


@route(["POST"], "get_rank_list_4")
def get_rank_list(ctx):
    return _ok(ctx["state"].get_rankings("default", _body(ctx).get("page", 1)))


@route(["POST"], "get_board")
def get_board(ctx):
    return _ok(ctx["state"].get_rankings(_tail(ctx), _body(ctx).get("page", 1)))


@route(["POST"], "get_user_info")
def get_user_info(ctx):
    body = _body(ctx)
    return _ok({"userid": body.get("userid", 0), "type": body.get("type", 0)})


@route(["GET"], "is_changed_name")
def is_changed_name(ctx):
    return _ok({"changed": False})


@route(["POST"], "update_username")
def update_username(ctx):
    name = _body(ctx).get("name", "")
    if not isinstance(name, str) or not name.strip():
        return build_response_body({}, errcode=400, errmsg="name is required")
    ctx["state"].update_account(_userid(ctx), {"name": name})
    return _ok({"name": name})


def _designation_payload(ctx, userid):
    """getChenHao / get_user_designation 期望结构。
    AttrLayer 读取:
      data.exam.guanzhi / data.exam.zhengji
      data.jiaren.is_list
      data.gongzi.is_list
    """
    role = ctx["state"].get_archive(userid) if userid > 0 else None
    official_type = 0
    zhengji = 0
    if isinstance(role, dict):
        try:
            official_type = int(role.get("officialType") or 0)
        except (TypeError, ValueError):
            official_type = 0
        try:
            zhengji = int(role.get("officialAchievement") or 0)
        except (TypeError, ValueError):
            zhengji = 0
    return {
        "exam": {
            "guanzhi": official_type,
            "zhengji": zhengji,
        },
        "jiaren": {"is_list": 0},
        "gongzi": {"is_list": 0},
    }


def _prestige_bucket(ctx, userid):
    with ctx["state"]._lock:
        prestige = ctx["state"]._state.setdefault("prestige", {})
        key = str(userid)
        bucket = prestige.setdefault(key, {
            "total": 0,
            "today": 0,
            "title": [],
            "upper": False,
        })
        # 若角色档里已有声望字段, 用作初值
        role = ctx["state"].get_archive(userid) if userid > 0 else None
        if isinstance(role, dict) and int(bucket.get("total") or 0) == 0:
            for field in ("prestige", "shengwang", "familyPrestige"):
                if role.get(field) is not None:
                    try:
                        bucket["total"] = int(role.get(field) or 0)
                        break
                    except (TypeError, ValueError):
                        pass
        ctx["state"]._changed()
        return bucket


@route(["GET", "POST"], "get_user_guanzhi")
def get_user_guanzhi(ctx):
    userid = _userid(ctx)
    payload = _designation_payload(ctx, userid)
    return build_response_body({
        "title": "",
        "gongzi": 0,
        "is_list": 0,
        "officialType": payload["exam"]["guanzhi"],
        "guanzhi": payload["exam"]["guanzhi"],
        "exam": payload["exam"],
        "jiaren": payload["jiaren"],
    })


@route(["GET", "POST"], "get_user_designation")
def get_user_designation(ctx):
    """称号/官职同步: HttpManagerEx:getChenHao -> get_user_designation"""
    userid = _userid(ctx)
    if userid > 0:
        ctx["state"].ensure_account(userid)
    return build_response_body(_designation_payload(ctx, userid))


@route(["GET", "POST"], "get_user_prestige")
def get_user_prestige(ctx):
    """师门声望: FamilyPrestige:getUserPrestige
    成功 data 至少含:
      total: 当前声望
      title: 唯一称号列表(可空数组)
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    ctx["state"].ensure_account(userid)
    bucket = _prestige_bucket(ctx, userid)
    return build_response_body({
        "total": int(bucket.get("total") or 0),
        "today": int(bucket.get("today") or 0),
        "title": list(bucket.get("title") or []),
        "upper": bool(bucket.get("upper")),
        "num": int(bucket.get("total") or 0),
        "prestige": int(bucket.get("total") or 0),
    })


@route(["POST"], "add_user_prestige")
def add_user_prestige(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = ctx.get("body") if isinstance(ctx.get("body"), dict) else {}
    try:
        add_value = int(body.get("addPrestige") or body.get("prestige") or body.get("num") or 0)
    except (TypeError, ValueError):
        add_value = 0
    bucket = _prestige_bucket(ctx, userid)
    daily_limit = 200
    today = int(bucket.get("today") or 0)
    remain = max(daily_limit - today, 0)
    applied = min(max(add_value, 0), remain)
    upper = applied < max(add_value, 0) or remain == 0
    bucket["today"] = today + applied
    bucket["total"] = int(bucket.get("total") or 0) + applied
    bucket["upper"] = upper
    with ctx["state"]._lock:
        ctx["state"]._state.setdefault("prestige", {})[str(userid)] = bucket
        ctx["state"]._changed()
    return build_response_body({
        "total": int(bucket["total"]),
        "today": int(bucket["today"]),
        "title": list(bucket.get("title") or []),
        "upper": upper,
        "num": int(bucket["total"]),
        "prestige": int(bucket["total"]),
        "add": applied,
    })


@route(["POST"], "get_activity_list")
def get_activity_list(ctx):
    response = _ok({
        "isClick": "Y",
        "isSign": "N",
        "list": [
            "江湖秘宝",
            "江湖夺宝",
            "香囊密阁",
            "藏经阁",
            "江湖珍品阁",
            "签到活动",
            "秘境探险",
            "首充活动",
            "限时礼包累计奖励",
            "地宫古迹",
            "每日任务",
        ],
    })
    response["rand_t"] = ACTIVITY_LIST_RAND_T
    return response


@route(["GET"], "del_activity_cache")
def del_activity_cache(ctx):
    return _ok({"deleted": True})


@route(["POST"], "get_game_activity")
def get_game_activity(ctx):
    return _ok({"id": _tail(ctx), "enabled": False})


@route(["GET"], "get_sign_list")
def get_sign_list(ctx):
    return _ok([])


@route(["POST"], "get_sign_prize")
def get_sign_prize(ctx):
    return _ok({"received": True})


@route(["POST"], "get_sign_history_prize")
def get_sign_history_prize(ctx):
    return _ok({"received": True})


@route(["POST"], "check_failed_normal_sign")
def check_failed_normal_sign(ctx):
    return _ok({"recovered": True})


@route(["GET"], "get_daily_point")
def get_daily_point(ctx):
    return _ok({"point": 0})


@route(["POST"], "update_daily_point")
def update_daily_point(ctx):
    return _ok({"point": _body(ctx).get("point", 0), "id": _tail(ctx)})


@route(["GET"], "get_daily_board")
def get_daily_board(ctx):
    return _ok(ctx["state"].get_rankings("daily"))


@route(["GET"], "get_daily_reward_list")
def get_daily_reward_list(ctx):
    return _ok([])


@route(["POST"], "get_daily_reward")
def get_daily_reward(ctx):
    return _ok({"received": True})


@route(["GET"], "get_history_notice")
def get_history_notice_basic(ctx):
    return _ok([])


DEVOTE_DAILY_LIMIT = 10000
DEVOTE_STORE_ITEMS = [
    {
        "id": "jiu106",
        "itemId": "jiu106",
        "price": 100,
        "status": 0,
    }
]


def _devote_bucket(ctx, userid):
    today = time.strftime("%Y-%m-%d", time.localtime())
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("devote", {})
        bucket = root.setdefault(str(userid), {
            "dev_point": 0,
            "day": today,
            "today_point": 0,
        })
        changed = False
        if bucket.get("day") != today:
            bucket["day"] = today
            bucket["today_point"] = 0
            changed = True
        for key in ("dev_point", "today_point"):
            value = max(_as_int(bucket.get(key), 0), 0)
            if bucket.get(key) != value:
                bucket[key] = value
                changed = True
        if changed:
            ctx["state"]._changed()
        return bucket


@route(["GET"], "get_devote_point")
def get_devote_point(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _devote_bucket(ctx, userid)
    return _ok({"dev_point": bucket["dev_point"]})


@route(["POST"], "add_devote_point")
def add_devote_point(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    devote_type = _as_int(body.get("type"), 0)
    point = _as_int(body.get("point"), 0)
    if devote_type not in (1, 2, 3, 4, 5) or point <= 0:
        return build_response_body({}, errcode=3, errmsg="type or point is invalid")
    with ctx["state"]._lock:
        bucket = _devote_bucket(ctx, userid)
        remaining = max(DEVOTE_DAILY_LIMIT - bucket["today_point"], 0)
        if remaining <= 0:
            return build_response_body({
                "get_point": 0,
                "dev_point": bucket["dev_point"],
                "msg": "当日师门贡献点已达上限",
            }, errcode=2, errmsg="daily devote point limit reached")
        actual_point = min(point, remaining)
        bucket["dev_point"] += actual_point
        bucket["today_point"] += actual_point
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
        total_point = bucket["dev_point"]
    return _ok({
        "get_point": actual_point,
        "dev_point": total_point,
        "msg": "师门贡献点 +%s" % actual_point,
    })


@route(["POST"], "get_devote_list")
def get_devote_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    _devote_bucket(ctx, userid)
    return _ok({
        "yuanbao": 20,
        "list": [dict(item) for item in DEVOTE_STORE_ITEMS],
    })


@route(["GET"], "challengemap_unfinished")
def challengemap_unfinished(ctx):
    return _ok({"status": 0})


SPRING_FESTIVAL_ACTIONS = [
    {
        "id": 1,
        "activity_id": "sign_in",
        "name": "签到活动",
        "status": 1,
        "is_open": 1,
        "remain_time": 0,
        "time": "长期开放",
        "desc": "每日签到可领取奖励",
        "gift": "签到奖励",
    },
]


@route(["GET"], "get_spring_festival_list")
def get_spring_festival_list(ctx):
    return _ok([dict(action) for action in SPRING_FESTIVAL_ACTIONS])


@route(["GET"], "get_spring_festival_status")
def get_spring_festival_status(ctx):
    return _ok({
        "id": (ctx.get("route_tail") or [None])[0],
        "is_open": 1,
        "status": 1,
        "rule_desc": [],
        "detail_desc": [],
        "start": 0,
        "end": 0,
    })


@route(["POST"], "get_user_group")
def get_user_group(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    try:
        requested_userid = int(body.get("userid") or userid)
    except (TypeError, ValueError):
        requested_userid = 0
    if userid <= 0 or requested_userid != userid:
        return build_response_body([], errcode=552, errmsg="userid not found")
    role = ctx["state"].get_archive(userid) or {}
    name = role.get("name") or "玩家%s" % userid
    return _ok([{
        "userid": userid,
        "name": name,
    }])


@route(["GET"], "get_group_rank")
def get_group_rank(ctx):
    userid = _userid(ctx)
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return build_response_body([], errcode=552, errmsg="userid not found")
    role = ctx["state"].get_archive(userid) or {}
    devote = _devote_bucket(ctx, userid)
    try:
        kongfu = int(float(role.get("exp", 0) or 0) / 100000)
    except (TypeError, ValueError):
        kongfu = 0
    prestige = max(_as_int(role.get("prestige"), 0), devote["dev_point"])
    return _ok([{
        "userid": userid,
        "kongfu": max(kongfu, 0),
        "prestige": prestige,
    }])


@route(["GET"], "get_help_document")
def get_help_document(ctx):
    return _ok([])


@route(["GET"], "get_random_weapon_desc")
def get_random_weapon_desc(ctx):
    return _ok({"type": _tail(ctx), "list": []})


@route(["POST"], "make_weapon")
def make_weapon(ctx):
    return _ok({"created": True})


@route(["POST"], "upgrade_weapon")
def upgrade_weapon(ctx):
    return _ok({"upgraded": True})


@route(["GET"], "get_history_weapon")
def get_history_weapon(ctx):
    return _ok([])


@route(["POST"], "throw_weapon")
def throw_weapon(ctx):
    return _ok({"discarded": True, "type": _tail(ctx), "index": _tail(ctx, 1)})


@route(["GET"], "get_fight_board")
def get_fight_board(ctx):
    board_type = _tail(ctx, default="1")
    if board_type == "3":
        values = ctx["state"].list_biwu_fights()
        return _ok({str(index): value for index, value in enumerate(values)})
    board_name = "fight_week" if board_type == "2" else "fight_history"
    ranking = ctx["state"].get_rankings(board_name, 1, 100)
    values = {str(index): value for index, value in enumerate(ranking["list"])}
    if board_type == "2":
        userid = _userid(ctx)
        mine = next((item for item in ranking["list"] if int(item.get("userid", 0)) == userid), None)
        values["body"] = {"mine": {"dsc": str((mine or {}).get("score", 0))}}
    return _ok(values)


@route(["POST"], "watch_fight")
def watch_fight(ctx):
    userid = _fight_user(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    state = ctx["state"].get_biwu(userid)
    if state.get("watching") and state.get("watch_fid"):
        return build_response_body({
            "fid": state["watch_fid"],
            "current_time": state.get("watch_started_at", int(time.time())),
            "expired_time": state.get("watch_expired_at", int(time.time()) + 3600),
        }, errcode=2, errmsg="already watching")
    now = int(time.time())
    fid = "watch-%s-%d" % (userid, now)
    ctx["state"].update_biwu(userid, {
        "watching": True,
        "watch_fid": fid,
        "watch_started_at": now,
        "watch_expired_at": now + 3600,
    })
    return _ok({"fid": fid, "current_time": now, "expired_time": now + 3600})


@route(["POST"], "unwatch_fight")
def unwatch_fight(ctx):
    userid = _fight_user(ctx)
    body = _fight_body(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    state = ctx["state"].get_biwu(userid)
    if not state.get("watching"):
        return build_response_body({}, errcode=1, errmsg="watch not found")
    fid = body.get("fid")
    if fid and str(fid) != str(state.get("watch_fid")):
        return build_response_body({}, errcode=1, errmsg="watch fid mismatch")
    ctx["state"].update_biwu(userid, {
        "watching": False,
        "watch_fid": None,
        "watch_started_at": None,
        "watch_expired_at": None,
    })
    return _ok({"fid": fid or state.get("watch_fid"), "watching": False})


@route(["POST"], "join_fight2")
def join_fight(ctx):
    userid = _fight_user(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    state = ctx["state"].get_biwu(userid)
    if state.get("stage") == "in_fight":
        return build_response_body({
            "id": state.get("current_match_id"),
            "fid": state.get("current_fight_id"),
        }, errcode=2, errmsg="fight in progress")
    fid = state.get("current_fight_id") or "stage-%s-%d" % (userid, int(time.time()))
    ctx["state"].update_biwu(userid, {
        "stage": "on_stage",
        "current_fight_id": fid,
        "current_cnt": int(state.get("current_cnt", 0)),
        "renqi": int(state.get("renqi", 0)),
        "stage_renqi": int(state.get("stage_renqi", 0)),
    })
    return _ok({
        "fid": fid,
        "renqi": int(state.get("renqi", 0)),
        "current_cnt": int(state.get("current_cnt", 0)),
        "today_max_point": int(state.get("today_max_point", 0)),
        "stage_renqi": int(state.get("stage_renqi", 0)),
    })


@route(["POST"], "fight2")
def fight(ctx):
    userid = _fight_user(ctx)
    body = _fight_body(ctx)
    fight_type = _tail(ctx, default="4")
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    state = ctx["state"].get_biwu(userid)
    fid = str(body.get("fid") or state.get("current_fight_id") or "")
    if not fid or str(state.get("current_fight_id")) != fid:
        return build_response_body({}, errcode=4, errmsg="fight not found")
    if fight_type == "3":
        ctx["state"].update_biwu(userid, {"stage": "idle", "current_fight_id": None, "current_match_id": None})
        return _ok({"week_renqi": int(state.get("week_renqi", 0))})
    if state.get("stage") == "in_fight":
        return build_response_body({
            "id": state.get("current_match_id"),
            "fid": fid,
        }, errcode=2, errmsg="fight in progress")
    now = int(time.time())
    match_id = "match-%s-%d" % (userid, now)
    opponent = {
        "userid": 9000000001,
        "name": "模拟对手",
        "level": 1,
        "fight_type": fight_type,
    }
    record = ctx["state"].add_biwu_fight(userid, {
        "fid": fid,
        "id": match_id,
        "fight_type": fight_type,
        "status": "running",
        "opponent": opponent,
        "win_points": 10,
        "lose_points": 5,
        "today_max_point": int(state.get("today_max_point", 0)),
        "week_renqi": int(state.get("week_renqi", 0)),
        "used_cards": [],
        "started_at": now,
    })
    ctx["state"].update_biwu(userid, {
        "stage": "in_fight",
        "current_match_id": match_id,
        "last_result": None,
    })
    return _ok({
        "id": record["id"],
        "fid": fid,
        "user": opponent,
        "win_points": record["win_points"],
        "today_max_point": record["today_max_point"],
        "current_cnt": int(state.get("current_cnt", 0)),
    })


@route(["POST"], "use_fight_card")
def use_fight_card(ctx):
    userid = _fight_user(ctx)
    body = _fight_body(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    fights = ctx["state"].list_biwu_fights(userid)
    match = next((item for item in fights if str(item.get("id")) == str(body.get("id")) and str(item.get("fid")) == str(body.get("fid"))), None)
    if match is None or match.get("status") != "running":
        return build_response_body({}, errcode=4, errmsg="fight not found")
    card_id = body.get("card_id", 0)
    match.setdefault("used_cards", []).append(card_id)
    ctx["state"].mutate(lambda current: current["biwu_fights"].update({str(match["fight_id"]): match}) or match)
    return _ok({"fid": body.get("fid"), "id": body.get("id"), "card_id": card_id, "used": True})


@route(["POST"], "report_fight_result2")
def report_fight_result(ctx):
    userid = _fight_user(ctx)
    body = _fight_body(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    fights = ctx["state"].list_biwu_fights(userid)
    match = next((item for item in fights if str(item.get("id")) == str(body.get("id")) and str(item.get("fid")) == str(body.get("fid"))), None)
    if match is None:
        return build_response_body({}, errcode=1, errmsg="fight not found")
    if match.get("status") != "running":
        if match.get("result") == body.get("result"):
            return _ok(match.get("result_data", {}))
        return build_response_body({}, errcode=2, errmsg="fight already settled")
    state = ctx["state"].get_biwu(userid)
    result = str(body.get("result", "cancel")).lower()
    current_cnt = int(state.get("current_cnt", 0)) + 1
    state_patch, response = _fight_result(userid, match, result, current_cnt)
    match["result_data"] = response
    ctx["state"].mutate(lambda current: (
        current["biwu_fights"].update({str(match["fight_id"]): match}),
        current["biwu"].setdefault(str(userid), {}).update(state_patch),
    ) and response)
    return _ok(response)


@route(["GET"], "get_fight_times2")
def get_fight_times(ctx):
    userid = _fight_user(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    state = ctx["state"].get_biwu(userid)
    return _ok({"fight_times": int(state.get("fight_times_left", 0)), "current_cnt": int(state.get("current_cnt", 0))})


@route(["GET"], "get_fight_reward_list")
def get_fight_reward_list(ctx):
    userid = _fight_user(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    return _ok({"rewards": ctx["state"].get_biwu(userid).get("rewards", [])})


@route(["POST"], "get_fight_reward")
def get_fight_reward(ctx):
    userid = _fight_user(ctx)
    body = _fight_body(ctx)
    if not userid:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    trans_id = str(body.get("trans_id", ""))
    state = ctx["state"].get_biwu(userid)
    rewards = state.get("rewards", [])
    for reward in rewards:
        if str(reward.get("trans_id", "")) == trans_id:
            if reward.get("claimed"):
                return _ok(reward.get("result", {}))
            result = {
                "reward_list": reward.get("reward_list", []),
                "renqi": reward.get("renqi", 0),
                "danyao": reward.get("danyao", 0),
            }
            reward["claimed"] = True
            reward["result"] = result
            ctx["state"].update_biwu(userid, {"rewards": rewards})
            return _ok(result)
    return build_response_body({}, errcode=1, errmsg="reward not found")
