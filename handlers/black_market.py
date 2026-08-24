import copy
import datetime
import json
import time

from protocol import build_response_body
from server import route


BLACK_MARKET_GOODS = [
    {
        "itemId": "xiaoyaoyiguncanye",
        "name": "一棍逍遥残页",
        "price": 180000,
        "priceUnit": "money",
        "discount": "0.8",
    },
    {
        "itemId": "qiankungundingcanye",
        "name": "棍定乾坤残页",
        "price": 220000,
        "priceUnit": "money",
        "discount": "0.8",
    },
    {
        "itemId": "flysandwalkrockcanye",
        "name": "飞沙走石残页",
        "price": 240000,
        "priceUnit": "money",
        "discount": "0.9",
    },
    {
        "itemId": "windqicloudyongcanye",
        "name": "风起云涌残页",
        "price": 260000,
        "priceUnit": "money",
        "discount": "0.9",
    },
    {
        "itemId": "thunderAttackcanye",
        "name": "雷声贯耳残页",
        "price": 280000,
        "priceUnit": "money",
        "discount": "0.9",
    },
    {
        "itemId": "embattledSongcanye",
        "name": "四面楚歌残页",
        "price": 300000,
        "priceUnit": "money",
        "discount": "0.8",
    },
    {
        "itemId": "qiannengdan",
        "name": "潜能丹",
        "price": 80000,
        "priceUnit": "money",
    },
    {
        "itemId": "jingxinwan",
        "name": "静心丸",
        "price": 120000,
        "priceUnit": "money",
    },
    {
        "itemId": "putizi1",
        "name": "菩提子",
        "price": 160000,
        "priceUnit": "money",
    },
    {
        "itemId": "eq2020qm03",
        "name": "骤雨棒",
        "price": 450000,
        "priceUnit": "money",
        "discount": "0.9",
    },
    {
        "itemId": "eq2020qm04",
        "name": "裁柳细剑",
        "price": 450000,
        "priceUnit": "money",
        "discount": "0.9",
    },
    {
        "itemId": "eq2020qm05",
        "name": "寒铁冰锥",
        "price": 450000,
        "priceUnit": "money",
        "discount": "0.9",
    },
    {
        "itemId": "eq2020qm06",
        "name": "厉鬼长发",
        "price": 450000,
        "priceUnit": "money",
        "discount": "0.9",
    },
    {
        "itemId": "eq2020qm07",
        "name": "鬼门刃",
        "price": 500000,
        "priceUnit": "money",
        "discount": "0.8",
    },
]


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


def _today():
    return datetime.date.today().isoformat()


def _catalog():
    return {goods["itemId"]: goods for goods in BLACK_MARKET_GOODS}


def _bucket(ctx, userid):
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("black_market", {})
        bucket = root.get(str(userid))
        changed = False
        if not isinstance(bucket, dict):
            bucket = {}
            root[str(userid)] = bucket
            changed = True
        if not isinstance(bucket.get("sold"), dict):
            bucket["sold"] = {}
            changed = True
        if not isinstance(bucket.get("transactions"), dict):
            bucket["transactions"] = {}
            changed = True
        if bucket.get("day") != _today():
            bucket["day"] = _today()
            bucket["sold"] = {}
            bucket["updated_at"] = int(time.time())
            changed = True
        if changed:
            ctx["state"]._changed()
        return bucket


def _available_goods(bucket):
    sold = bucket.get("sold") or {}
    return [
        copy.deepcopy(goods)
        for goods in BLACK_MARKET_GOODS
        if _as_int(sold.get(goods["itemId"]), 0) < 1
    ]


def _request_signature(goods_info, mark):
    value = {"goodsInfo": goods_info, "mark": mark if isinstance(mark, dict) else {}}
    return json.dumps(value, ensure_ascii=False, sort_keys=True, separators=(",", ":"))


@route(["GET"], "black_market_store")
def black_market_store(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _bucket(ctx, userid)
    return build_response_body({
        "status": "OPEN",
        "list": _available_goods(bucket),
        "currencyList": [],
    })


@route(["POST"], "buy_black_goods")
def buy_black_goods(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")

    body = _body(ctx)
    client_trans_id = str(body.get("client_trans_id") or "")
    goods_info = body.get("goodsInfo")
    mark = body.get("mark")
    if not client_trans_id:
        return build_response_body({}, errcode=400, errmsg="client_trans_id is required")
    if not isinstance(goods_info, list) or not goods_info:
        return build_response_body({}, errcode=1, errmsg="invalid goods info")
    if len(goods_info) > len(BLACK_MARKET_GOODS):
        return build_response_body({}, errcode=1, errmsg="too many goods")

    signature = _request_signature(goods_info, mark)
    catalog = _catalog()

    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid)
        transactions = bucket["transactions"]
        previous = transactions.get(client_trans_id)
        if isinstance(previous, dict):
            if previous.get("signature") != signature:
                return build_response_body({}, errcode=409, errmsg="client_trans_id conflict")
            return copy.deepcopy(previous.get("response"))

        sold = bucket["sold"]
        requested = set()
        result = []
        for value in goods_info:
            if not isinstance(value, dict):
                return build_response_body({}, errcode=1, errmsg="invalid goods info")
            item_id = str(value.get("itemId") or "")
            goods = catalog.get(item_id)
            number = _as_int(value.get("number"), 0)
            if goods is None or item_id in requested or number != 1:
                return build_response_body({}, errcode=1, errmsg="invalid goods info")
            if _as_int(sold.get(item_id), 0) >= 1:
                return build_response_body({}, errcode=2, errmsg="goods list refreshed")
            if str(value.get("priceUnit") or "") != goods["priceUnit"]:
                return build_response_body({}, errcode=2, errmsg="goods list refreshed")
            if _as_int(value.get("price"), -1) != goods["price"]:
                return build_response_body({}, errcode=2, errmsg="goods list refreshed")
            requested.add(item_id)
            result.append({
                "itemId": item_id,
                "number": 1,
                "price": goods["price"],
                "priceUnit": goods["priceUnit"],
            })

        for value in result:
            sold[value["itemId"]] = 1
        response = build_response_body({"goodsList": result})
        transactions[client_trans_id] = {
            "signature": signature,
            "response": copy.deepcopy(response),
            "created_at": int(time.time()),
        }
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
        return response
