import copy
import datetime
import json
import time

from handlers.basic import _currency_balance, _set_yuanbao_balance
from protocol import build_response_body
from server import route


# 黑市商品目录。
# 追加 item_json/Items.json 中 type == "锻造图谱" 的全部物品（duanzaotupu1 ~
# duanzaotupu44），price 取 Items.json 的 buyPrice，priceUnit 取 priceUnit（缺失时按
# "money" 处理，即碎银）。
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
    {
        "itemId": "duanzaotupu1",
        "name": "铸造入门",
        "price": 10000,
        "priceUnit": "money",
    },
    {
        "itemId": "duanzaotupu2",
        "name": "锻造实录",
        "price": 50,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu3",
        "name": "冶兵初解",
        "price": 50,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu4",
        "name": "基础锻兵",
        "price": 50,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu5",
        "name": "谢思工铸术",
        "price": 900000,
        "priceUnit": "money",
    },
    {
        "itemId": "duanzaotupu6",
        "name": "赵氏铸兵集",
        "price": 900000,
        "priceUnit": "money",
    },
    {
        "itemId": "duanzaotupu7",
        "name": "霍氏锻铁术",
        "price": 900000,
        "priceUnit": "money",
    },
    {
        "itemId": "duanzaotupu8",
        "name": "广寒冶兵术",
        "price": 900000,
        "priceUnit": "money",
    },
    {
        "itemId": "duanzaotupu9",
        "name": "百锻残篇.剑",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu10",
        "name": "百锻残篇.刀",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu11",
        "name": "百锻残篇.棍",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu12",
        "name": "百锻残篇.鞭",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu13",
        "name": "铸剑奇录",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu14",
        "name": "铸刀奇录",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu15",
        "name": "铸棍奇录",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu16",
        "name": "铸鞭奇录",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu17",
        "name": "轩辕铸造术",
        "price": 100000,
        "priceUnit": "money",
    },
    {
        "itemId": "duanzaotupu18",
        "name": "炼磁录",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu19",
        "name": "欧冶子手录(一)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu20",
        "name": "欧冶子手录(二)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu21",
        "name": "欧冶子手录(三)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu22",
        "name": "欧冶子手录(四)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu23",
        "name": "欧冶子手录(五)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu24",
        "name": "欧冶子手录(六)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu25",
        "name": "欧冶子手录(七)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu26",
        "name": "欧冶子手录(八)",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu27",
        "name": "HIC西洋兵录（一）NOR",
        "price": 100,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu28",
        "name": "HIC西洋兵录（二）NOR",
        "price": 100,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu29",
        "name": "GRN西洋兵录（三）NOR",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu30",
        "name": "GRN西洋兵录（四）NOR",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu31",
        "name": "YEL西洋兵录（五）NOR",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu32",
        "name": "YEL西洋兵录（六）NOR",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu33",
        "name": "HIC重光宝典（一）NOR",
        "price": 100,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu34",
        "name": "HIC重光宝典（二）NOR",
        "price": 100,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu35",
        "name": "GRN重光宝典（三）NOR",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu36",
        "name": "GRN重光宝典（四）NOR",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu37",
        "name": "YEL重光宝典（五）NOR",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu38",
        "name": "YEL重光宝典（六）NOR",
        "price": 400,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu39",
        "name": "百锻残篇.双兵",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu40",
        "name": "双兵铸造录",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu41",
        "name": "百锻残篇.乐器",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu42",
        "name": "乐器铸造录",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu43",
        "name": "百锻残篇.暗器",
        "price": 200,
        "priceUnit": "yuanbao",
    },
    {
        "itemId": "duanzaotupu44",
        "name": "暗器铸造录",
        "price": 200,
        "priceUnit": "yuanbao",
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


# 经脉印记 fuhuiyin(开源节流)：黑市元宝购买 9 折。
# 见 fzjh_lua/assets/res/script/meridian/meridianImprinting.lua id=71，客户端
# BlackStore:__initGoodsPrice 会把元宝价格乘上该系数，并按 mark.isDiscount 上报。
_FUHUIYIN_YUANBAO_RATE = 0.9


def _discounted_price(price, price_unit, mark):
    """按客户端 fuhuiyin 折扣算出折后价（仅元宝商品参与）。"""
    if price_unit != "yuanbao" or not isinstance(mark, dict):
        return price
    if mark.get("isDiscount") is not True:
        return price
    return int(price * _FUHUIYIN_YUANBAO_RATE + 0.5)


def _currency_list(ctx, userid):
    """黑市商品用到的货币余额。

    客户端 BlackStore:getCurrencyName 对未出现在 currencyList 里的 priceUnit 会抛
    “非法货币”，所以 priceUnit=yuanbao 的商品必须在这里下发元宝条目；碎银(money)
    由客户端用本地 role.money 补齐，不需要下发。
    """
    return [
        {
            "unit": "yuanbao",
            "name": "元宝",
            "num": _currency_balance(ctx, userid, "yuanbao"),
        },
    ]


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
        "currencyList": _currency_list(ctx, userid),
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
        yuanbao_cost = 0
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
            # 客户端在有 fuhuiyin 印记时会按 9 折上报元宝价格（见 __initGoodsPrice），
            # 所以原价和折后价都接受，服务端按客户端上报的 price 结算。
            allowed_prices = {goods["price"]}
            if goods["priceUnit"] == "yuanbao":
                allowed_prices.add(_discounted_price(goods["price"], "yuanbao", mark))
            price = _as_int(value.get("price"), -1)
            if price not in allowed_prices:
                return build_response_body({}, errcode=2, errmsg="goods list refreshed")
            requested.add(item_id)
            if goods["priceUnit"] == "yuanbao":
                yuanbao_cost += price * number
            result.append({
                "itemId": item_id,
                "number": number,
                "price": price,
                "priceUnit": goods["priceUnit"],
            })

        # 元宝在服务端结算：余额不足则整单失败，不改动已售记录。
        # 碎银由客户端本地 role.money 扣减，服务端不处理。
        yuanbao_before = _currency_balance(ctx, userid, "yuanbao")
        if yuanbao_before < yuanbao_cost:
            return build_response_body(
                {"total_yuanbao": yuanbao_before, "remove_yuanbao": 0},
                errcode=1,
                errmsg="元宝不足，购买失败！",
            )
        if yuanbao_cost > 0:
            _set_yuanbao_balance(ctx, userid, yuanbao_before - yuanbao_cost)
        yuanbao_after = yuanbao_before - yuanbao_cost

        for value in result:
            sold[value["itemId"]] = 1
        response = build_response_body({
            "goodsList": result,
            "remove_yuanbao": yuanbao_cost,
            "total_yuanbao": yuanbao_after,
        })
        transactions[client_trans_id] = {
            "signature": signature,
            "response": copy.deepcopy(response),
            "created_at": int(time.time()),
        }
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
        return response
