# -*- coding: utf-8 -*-

import copy
import json
import os
import time
import hmac
from datetime import date, datetime, timedelta

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


DEFAULT_YUANBAO = 9999
_TIMED_STORE_GOODS = {
    "byfenshenfu": 30 * 24 * 60 * 60,
}
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
        "id": 3,
        "itemId": "xiyanshui",
        "itype": 10,
        "inde": 4,
        "name": "RAN洗颜水",
        "price": 50,
        "number": 1,
        "dsc1": "一瓶金灿灿的泥水，散发着难闻的味道，据说可以养血美颜。",
        "dsc2": "使用后颜值+1",
        "share": None,
        "icon": "Image/UI/StoreUI/xiyanshui.png",
        "to": None,
        "from": None,
        "create_time": "2017-02-13 17:09:38",
        "update_time": None,
    },
    {
        "id": 4,
        "itemId": "dundifu",
        "itype": 10,
        "inde": 6,
        "name": "RAN遁地符",
        "price": 10,
        "number": 1,
        "dsc1": "一张画满咒文的纸符，可以用来施展奇门遁甲术。",
        "dsc2": "使用后可以快速回家或者到达任务地点。",
        "share": None,
        "icon": "Image/UI/StoreUI/dundifu.png",
        "to": None,
        "from": None,
        "create_time": "2017-02-13 17:09:38",
        "update_time": None,
    },
    {
        "id": 5,
        "itemId": "fenshenfu",
        "itype": 10,
        "inde": 7,
        "name": "分身符",
        "price": 10,
        "number": 1,
        "dsc1": "一张画满咒文的纸符，可以用来创造一个分身。",
        "dsc2": "使用后可以同时打工，练功或者打坐。",
        "share": None,
        "icon": "Image/UI/StoreUI/fenshenfu.png",
        "to": None,
        "from": None,
        "create_time": "2017-02-13 17:09:38",
        "update_time": None,
    },
    {
        "id": 8,
        "itemId": "guanfugongwen",
        "itype": 0,
        "inde": 8,
        "name": "官府公文",
        "price": 300,
        "number": 1,
        "dsc1": "拥有此公文者可交于扬州府尹处吊销户籍。",
        "dsc2": "购买者可持此公文按照提示改名。",
        "share": None,
        "icon": "Image/UI/StoreUI/guanfugongwen.png",
        "to": None,
        "from": None,
        "create_time": "2017-02-13 17:09:38",
        "update_time": None,
    },
    {
        "id": 11,
        "itemId": "byfenshenfu",
        "itype": 1,
        "inde": 5,
        "name": "包月分身符",
        "price": 1800,
        "number": 0,
        "dsc1": "一张画满咒文的纸符",
        "dsc2": "使用后可以同时打工，练功或者打坐。（限时30天）",
        "share": "(当前角色绑定)",
        "icon": "Image/UI/StoreUI/fenshenfu.png",
        "to": None,
        "from": None,
        "create_time": "2017-02-13 17:09:38",
        "update_time": None,
    },
    {
        "id": 12,
        "itemId": "jingxinwan",
        "itype": 10,
        "inde": 9,
        "name": "静心丸",
        "price": 50,
        "number": 1,
        "dsc1": "颗散发着淡淡香气的药丸，具有凝神静心的功效，可以提升闭关修炼成功率，并且不会走火入魔。",
        "dsc2": "使用后可以提升闭关修炼成功率，并且不会走火入魔。",
        "share": "",
        "icon": "Image/UI/StoreUI/jingxinwan.png",
        "to": None,
        "from": None,
        "create_time": "2017-02-13 17:09:38",
        "update_time": None,
    },
    {
        "id": 1629,
        "itemId": "jingmai105",
        "itype": 10,
        "inde": 11,
        "name": "渡元丹",
        "price": 100,
        "number": 1,
        "dsc1": "一种橙黄色的药丸，据说由名家所配制。",
        "dsc2": "服用后可以增加冲穴的成功率。",
        "share": None,
        "icon": "Image/UI/StoreUI/jiuzhuanjindan.png",
        "to": None,
        "from": None,
        "create_time": None,
        "update_time": None,
    },
    {
        "id": 4160,
        "itemId": "shimenbuff1",
        "itype": 1,
        "inde": 0,
        "name": "掌门令",
        "price": 1200,
        "number": 1,
        "dsc1": "一块精致的小铜牌。购买后，将在接下来的一个月里完成师门任务时获得10%的师门声望加成。",
        "dsc2": "",
        "share": None,
        "icon": "Image/UI/StoreUI/lingpai1.png",
        "to": None,
        "from": None,
        "create_time": "2019-05-13 20:18:20",
        "update_time": None,
    },
    {
        "id": 5057,
        "itemId": "yuhuiling",
        "itype": 1,
        "inde": 0,
        "name": "八方游侠",
        "price": 1800,
        "number": 1,
        "dsc1": "一块刻着“天御汇成”四字的金牌，可以加速获取游字令。使用后参与八方游历，单次获得游字令增加10%，但上限不变。经验和潜能增加25%，且每日增加的最高上限为2500。（限时14天）",
        "dsc2": "",
        "share": None,
        "icon": "Image/UI/StoreUI/tianyuhuicheng.png",
        "to": None,
        "from": None,
        "create_time": "2020-05-29 11:12:50",
        "update_time": None,
    },
    {
        "id": 5434,
        "itemId": "drxiang02",
        "itype": 10,
        "inde": 0,
        "name": "艾香",
        "price": 10,
        "number": 1,
        "dsc1": "以艾草粉为基压制成的香线。\n入梦概率：40%\n可用于暮铁炉、紫铜炉、银月炉。\n点燃后休息，似会有意想不到的效果。",
        "dsc2": "",
        "share": None,
        "icon": "Image/UI/StoreUI/xiang.png",
        "to": None,
        "from": None,
        "create_time": "2020-11-17 16:26:19",
        "update_time": None,
    },
    {
        "id": 7238,
        "itemId": "diligent",
        "itype": 13,
        "inde": 0,
        "name": "大量勤建之志",
        "price": 250,
        "number": 1,
        "dsc1": "勤谨鼓劲，做师门的日常任务时可以一气呵成。（购买成功后立刻获得100个勤建之志）",
        "dsc2": "",
        "share": "",
        "icon": "Image/UI/StoreUI/qinjianzhizhi.png",
        "to": "0",
        "from": "0",
        "create_time": "2023-10-30 14:38:36",
        "update_time": "2023-11-01 14:46:04",
    },
]
_STORE_LEVEL_ITEMS = [
    {
        "id": 4135,
        "itemId": "volume_2",
        "itype": 11,
        "inde": 0,
        "name": "声震武林卷",
        "price": 100,
        "number": 1,
        "dsc1": "购买后可开启【声震武林卷】第一章至第十章。",
        "dsc2": "",
        "share": None,
        "icon": "Image/UI/StoreUI/juanzhou1.png",
        "to": None,
        "from": None,
        "create_time": "2019-04-26 16:53:17",
        "update_time": None,
    },
    {
        "id": 4136,
        "itemId": "volume_3",
        "itype": 11,
        "inde": 0,
        "name": "柳玄风卷(上)",
        "price": 200,
        "number": 1,
        "dsc1": "购买后可开启【柳玄风卷上】第一章至第十章。",
        "dsc2": "",
        "share": None,
        "icon": "Image/UI/StoreUI/juanzhou1.png",
        "to": None,
        "from": None,
        "create_time": "2019-04-26 16:54:21",
        "update_time": None,
    },
    {
        "id": 4137,
        "itemId": "volume_4",
        "itype": 11,
        "inde": 0,
        "name": "柳玄风卷(下)",
        "price": 150,
        "number": 1,
        "dsc1": "购买后可开启【柳玄风卷下】第一章至第五章。",
        "dsc2": "",
        "share": None,
        "icon": "",
        "to": None,
        "from": None,
        "create_time": "2019-04-26 16:55:03",
        "update_time": None,
    },
    {
        "id": 4138,
        "itemId": "volume_5",
        "itype": 11,
        "inde": 0,
        "name": "章作之卷",
        "price": 150,
        "number": 1,
        "dsc1": "购买后可开启【章作之卷】第一章至第五章。",
        "dsc2": "",
        "share": None,
        "icon": "",
        "to": None,
        "from": None,
        "create_time": "2019-04-26 16:55:47",
        "update_time": None,
    },
    {
        "id": 4139,
        "itemId": "volume_6",
        "itype": 11,
        "inde": 0,
        "name": "折掌镇海卷",
        "price": 100,
        "number": 1,
        "dsc1": "购买后可开启【折掌镇海卷】第一章至第五章。",
        "dsc2": "",
        "share": None,
        "icon": "",
        "to": None,
        "from": None,
        "create_time": "2019-04-26 16:56:20",
        "update_time": None,
    },
    {
        "id": 4795,
        "itemId": "volume_7",
        "itype": 11,
        "inde": 0,
        "name": "藏锋破阵卷",
        "price": 100,
        "number": 1,
        "dsc1": "购买后可开启【藏锋破阵卷】第一章至第五章。",
        "dsc2": "",
        "share": None,
        "icon": "",
        "to": None,
        "from": None,
        "create_time": "2020-01-06 17:43:26",
        "update_time": None,
    },
]

_LIMITED_GIFT_DESCRIPTION = "这是一个古色古香的丝绸袋子，据说里面装着不少好东西。"


def _limited_gift(store_id, item_id, name, price, client_exp=None):
    return {
        "id": store_id,
        "itemId": item_id,
        "itype": 100,
        "inde": 0,
        "name": name,
        "price": price,
        "number": 1,
        "dsc1": _LIMITED_GIFT_DESCRIPTION,
        "dsc2": "",
        "share": "",
        "icon": "Image/UI/StoreUI/jinnang2.png",
        "to": 0,
        "from": 0,
        "client_exp": list(client_exp or []),
    }


_STORE_LIMITED_ITEMS = [
    _limited_gift(8484, "libao1425", "限时礼包(桂秋)", 588),
    _limited_gift(8485, "libao1426", "限时礼包(商吕)", 588),
    _limited_gift(8486, "libao1427", "限时礼包(竹春)", 488),
    _limited_gift(8487, "libao1428", "兵器秘籍礼包", 388),
    _limited_gift(8488, "libao1429", "拳脚秘籍礼包", 388),
    _limited_gift(8489, "libao1430", "轻内秘籍礼包", 388),
    _limited_gift(
        8490,
        "libao1431",
        "新秀礼包",
        258,
        [{
            "field": "age",
            "op": "<",
            "v1": "19",
            "v2": "",
            "dsc": "年龄不符合购买要求!",
        }],
    ),
    _limited_gift(8491, "libao1432", "每日礼包", 158),
    _limited_gift(8492, "libao1433", "名士礼包(中秋)", 588),
    _limited_gift(8493, "libao1434", "名士礼包(秋分)", 588),
    _limited_gift(8494, "libao1435", "悠悠入梦礼", 188),
    _limited_gift(8495, "libao1436", "九月幸运福袋", 100),
    _limited_gift(8496, "libao1437", "武学升级礼包", 200),
    _limited_gift(8497, "libao1438", "不醉不归礼包", 400),
    _limited_gift(8498, "libao1439", "经脉调息礼包", 200),
    _limited_gift(8499, "libao1440", "神兵淬炼礼包", 688),
    {
        "id": 7772884,
        "itemId": "xinshoulibao1",
        "itype": 0,
        "inde": 9999,
        "name": "新手礼包",
        "price": 0,
        "number": 1,
        "dsc1": "使用后可获得分身符3张、遁地符3张、洗颜水1个、潜能丹1个。",
        "dsc2": "新手豪华大礼，助你畅游江湖。",
        "share": "",
        "icon": "Image/UI/StoreUI/xinshoulibao1.png",
        "to": 0,
        "from": 0,
    },
]


def _pack_reward(name, price, image, number, item_id):
    return {"name": name, "price": price, "imagePath": image, "number": number, "itemId": item_id}


# 限时礼包明细: 抓包自 so/entries/*_libao*.json (get_limit_package/libaoXXXX)。
# libao1431(新秀礼包) 抓包中因年龄限制未打开, 明细为按同档礼包合成的兜底数据。
_LIMITED_PACKAGE_DETAILS = {
    "libao1425": {
        "id": 1529, "total_price": 1000, "price": 588, "limit_num": 15, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("兵器武学录", 0, "Image/UI/StoreUI/shujuan6.png", 1, "2021bingqicanpian1"),
            _pack_reward("行功散", 0, "Image/UI/StoreUI/shenlishan.png", 5, "xinggongsan"),
            _pack_reward("潜能丹", 0, "Image/UI/StoreUI/qiannengdan.png", 5, "qiannengdan"),
            _pack_reward("RED醉梦生NOR", 500, "Image/UI/StoreUI/juhuajiu100.png", 2, "jiu106"),
        ],
        "special_reward_itemId": "",
    },
    "libao1426": {
        "id": 1530, "total_price": 410, "price": 588, "limit_num": 15, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("拳脚武学录", 0, "Image/UI/StoreUI/shujuan5.png", 1, "2021quanjiaocanpian1"),
            _pack_reward("静心丸", 50, "Image/UI/StoreUI/jingxinwan.png", 5, "jingxinwan"),
            _pack_reward("流云甘露", 80, "Image/UI/StoreUI/liuyunganlu.png", 2, "liuyunganlu"),
            _pack_reward("行功散", 0, "Image/UI/StoreUI/shenlishan.png", 5, "xinggongsan"),
        ],
        "special_reward_itemId": "",
    },
    "libao1427": {
        "id": 1531, "total_price": 30, "price": 488, "limit_num": 15, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("门派顶级残页", 0, "Image/UI/StoreUI/canye.png", 1, "menpaicanye4"),
            _pack_reward("HIR散人顶级残页NOR", 10, "Image/UI/StoreUI/canye.png", 1, "sanren8"),
            _pack_reward("门派高级残页", 0, "Image/UI/StoreUI/canye.png", 2, "menpaicanye3"),
            _pack_reward("HIY散人高级残页NOR", 10, "Image/UI/StoreUI/canye.png", 2, "sanren7"),
        ],
        "special_reward_itemId": "",
    },
    "libao1428": {
        "id": 1532, "total_price": 1000, "price": 388, "limit_num": 20, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("兵器武学秘籍", 0, "Image/UI/StoreUI/shuxiang.png", 2, "21bqwuxuemiji"),
            _pack_reward("RED醉梦生NOR", 500, "Image/UI/StoreUI/juhuajiu100.png", 2, "jiu106"),
            _pack_reward("HIY三才丹NOR", 0, "Image/UI/StoreUI/sancaidan.png", 1, "sancaidan"),
        ],
        "special_reward_itemId": "",
    },
    "libao1429": {
        "id": 1533, "total_price": 1000, "price": 388, "limit_num": 20, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("拳脚武学秘籍", 0, "Image/UI/StoreUI/shuxiang.png", 2, "21qjwuxuemiji"),
            _pack_reward("RED醉梦生NOR", 500, "Image/UI/StoreUI/juhuajiu100.png", 2, "jiu106"),
            _pack_reward("HIY三才丹NOR", 0, "Image/UI/StoreUI/sancaidan.png", 1, "sancaidan"),
        ],
        "special_reward_itemId": "",
    },
    "libao1430": {
        "id": 1534, "total_price": 1000, "price": 388, "limit_num": 20, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("轻内武学秘籍", 0, "Image/UI/StoreUI/shuxiang.png", 2, "21qnwuxuemiji"),
            _pack_reward("RED醉梦生NOR", 500, "Image/UI/StoreUI/juhuajiu100.png", 2, "jiu106"),
            _pack_reward("HIY三才丹NOR", 0, "Image/UI/StoreUI/sancaidan.png", 1, "sancaidan"),
        ],
        "special_reward_itemId": "",
    },
    "libao1431": {
        "id": 1535, "total_price": 100, "price": 258, "limit_num": 15, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("行功散", 0, "Image/UI/StoreUI/shenlishan.png", 5, "xinggongsan"),
            _pack_reward("潜能丹", 0, "Image/UI/StoreUI/qiannengdan.png", 5, "qiannengdan"),
            _pack_reward("静心丸", 50, "Image/UI/StoreUI/jingxinwan.png", 3, "jingxinwan"),
            _pack_reward("银票票据(200)", 0, "Image/UI/StoreUI/yinpiao1.png", 1, "homemoney200"),
        ],
        "special_reward_itemId": "",
    },
    "libao1432": {
        "id": 1536, "total_price": 100, "price": 158, "limit_num": 31, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("静心丸", 50, "Image/UI/StoreUI/jingxinwan.png", 2, "jingxinwan"),
            _pack_reward("行功散", 0, "Image/UI/StoreUI/shenlishan.png", 2, "xinggongsan"),
            _pack_reward("银票票据(200)", 0, "Image/UI/StoreUI/yinpiao1.png", 1, "homemoney200"),
            _pack_reward("潜能丹", 0, "Image/UI/StoreUI/qiannengdan.png", 2, "qiannengdan"),
        ],
        "special_reward_itemId": "",
    },
    "libao1433": {
        "id": 1537, "total_price": 400, "price": 588, "limit_num": 15, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("江湖轻功录", 0, "Image/UI/StoreUI/miji.png", 1, "2021qinggongcanpian1"),
            _pack_reward("潜能丹", 0, "Image/UI/StoreUI/qiannengdan.png", 5, "qiannengdan"),
            _pack_reward("流云甘露", 80, "Image/UI/StoreUI/liuyunganlu.png", 5, "liuyunganlu"),
            _pack_reward("行功散", 0, "Image/UI/StoreUI/shenlishan.png", 5, "xinggongsan"),
        ],
        "special_reward_itemId": "",
    },
    "libao1434": {
        "id": 1538, "total_price": 400, "price": 588, "limit_num": 15, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("江湖内功录", 0, "Image/UI/StoreUI/miji.png", 1, "2021neigongcanpian1"),
            _pack_reward("潜能丹", 0, "Image/UI/StoreUI/qiannengdan.png", 5, "qiannengdan"),
            _pack_reward("流云甘露", 80, "Image/UI/StoreUI/liuyunganlu.png", 5, "liuyunganlu"),
            _pack_reward("行功散", 0, "Image/UI/StoreUI/shenlishan.png", 5, "xinggongsan"),
        ],
        "special_reward_itemId": "",
    },
    "libao1435": {
        "id": 1539, "total_price": 500050, "price": 188, "limit_num": 15, "beyond": 500,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("艾香", 10, "Image/UI/StoreUI/xiang.png", 5, "drxiang02"),
            _pack_reward("沉香", 0, "Image/UI/StoreUI/xiang.png", 5, "drxiang04"),
            _pack_reward("苏合香", 0, "Image/UI/StoreUI/xiang.png", 5, "drxiang03"),
            _pack_reward("HIM特制檀香NOR", 100000, "Image/UI/StoreUI/xiang.png", 5, "jingmai100"),
        ],
        "special_reward_itemId": "",
    },
    "libao1436": {
        "id": 1540, "total_price": 1, "price": 100, "limit_num": 155, "beyond": 300,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("未知", 1, "Image/UI/StoreUI/jinnang2.png", 1, "newfudai240"),
        ],
        "special_reward_itemId": "",
    },
    "libao1437": {
        "id": 1541, "total_price": 240, "price": 200, "limit_num": 62, "beyond": 300,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("行功散", 0, "Image/UI/StoreUI/shenlishan.png", 3, "xinggongsan"),
            _pack_reward("流云甘露", 80, "Image/UI/StoreUI/liuyunganlu.png", 3, "liuyunganlu"),
        ],
        "special_reward_itemId": "",
    },
    "libao1438": {
        "id": 1542, "total_price": 1500, "price": 400, "limit_num": 31, "beyond": 300,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("RED醉梦生NOR", 500, "Image/UI/StoreUI/juhuajiu100.png", 3, "jiu106"),
            _pack_reward("清风醉", 0, "Image/UI/StoreUI/juhuajiu100.png", 3, "jiu107"),
            _pack_reward("十里香", 0, "Image/UI/StoreUI/juhuajiu100.png", 3, "jiu108"),
        ],
        "special_reward_itemId": "",
    },
    "libao1439": {
        "id": 1543, "total_price": 200, "price": 200, "limit_num": 31, "beyond": 300,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("HIY经脉丹NOR", 10, "Image/UI/StoreUI/dabuwan.png", 5, "jingmai103"),
            _pack_reward("HIY真气丹NOR", 20, "Image/UI/StoreUI/zhuzi.png", 5, "jingmai101"),
            _pack_reward("HIC醒身丸NOR", 10, "Image/UI/StoreUI/dabuwan.png", 5, "jingmai102"),
        ],
        "special_reward_itemId": "",
    },
    "libao1440": {
        "id": 1544, "total_price": 400350, "price": 688, "limit_num": 62, "beyond": 300,
        "begin_time": 1788192001, "end_time": 1790783999,
        "list": [
            _pack_reward("如意", 0, "Image/UI/StoreUI/ruyi.png", 5, "cuilianruyi"),
            _pack_reward("HIW一盒黄金", 200, "Image/UI/StoreUI/yiheyuanbao.png", 1, "yidaigold2"),
            _pack_reward("HIM无烟煤NOR", 80000, "Image/UI/StoreUI/wuyanmei.png", 5, "duanzaoranliao3"),
            _pack_reward("HIM融铁煤NOR", 30, "Image/UI/StoreUI/wuyanmei.png", 5, "duanzaoranliao4"),
        ],
        "special_reward_itemId": "",
    },
}


def _as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return int(default)


def _find_store_item(item_key):
    key = str(item_key or "")
    if not key:
        return None
    for item in _STORE_TEST_ITEMS + _STORE_LEVEL_ITEMS + _STORE_LIMITED_ITEMS:
        if str(item.get("itemId")) == key or str(item.get("id")) == key:
            return dict(item)
    return None


def _timed_good_expired_at_values(account, orders, userid, item_id):
    item_id = str(item_id or "")
    duration = _TIMED_STORE_GOODS.get(item_id)
    if userid <= 0 or duration is None:
        return 0
    account = account if isinstance(account, dict) else {}
    expired_times = account.get("store_goods_expired_at")
    if isinstance(expired_times, dict) and item_id in expired_times:
        return max(_as_int(expired_times.get(item_id), 0), 0)

    purchases = []
    for order in (orders or {}).values():
        if not isinstance(order, dict):
            continue
        if _as_int(order.get("userid"), 0) != userid or order.get("status") != "success":
            continue
        order_item_id = order.get("item_id")
        if not order_item_id and isinstance(order.get("payload"), dict):
            order_item_id = order["payload"].get("itemId")
        if str(order_item_id or "") != item_id:
            continue
        purchases.append((
            max(_as_int(order.get("created_at"), 0), 0),
            max(_as_int(order.get("quantity"), 1), 1),
        ))
    expired_at = 0
    for created_at, quantity in sorted(purchases):
        expired_at = max(expired_at, created_at) + duration * quantity
    return expired_at


def _timed_good_expired_at(ctx, userid, item_id):
    """Return the entitlement, rebuilding purchases made by older versions."""
    state = ctx["state"]
    with state._lock:
        account = state._state.setdefault("accounts", {}).get(str(userid)) or {}
        orders = state._state.setdefault("orders", {})
        return _timed_good_expired_at_values(account, orders, userid, item_id)


def _goods_detail(item, expired_time=None):
    dsc = str(item.get("dsc") or "")
    mid = max(1, len(dsc) // 2)
    dsc1 = item.get("dsc1")
    dsc2 = item.get("dsc2")
    detail = {
        "id": str(item.get("id") or ""),
        "itemId": str(item.get("itemId") or ""),
        "name": str(item.get("name") or ""),
        "price": _as_int(item.get("price"), 1),
        "dsc1": str(dsc1) if dsc1 is not None else (dsc[:mid] if dsc else ""),
        "dsc2": str(dsc2) if dsc2 is not None else (dsc[mid:] if dsc else ""),
        "icon": str(item.get("icon") or ""),
        "discount": 0,
        "share": str(item.get("share") or ""),
        "available": True,
        "itype": item.get("itype"),
        "number": _as_int(item.get("number"), 1),
        "Inventory": _as_int(item.get("Inventory"), -1),
        "quota": _as_int(item.get("quota"), -1),
        "viewtype": _as_int(item.get("viewtype"), 0),
        "extra": item.get("extra") if isinstance(item.get("extra"), dict) else {},
    }
    if expired_time is not None:
        detail["expired_time"] = max(_as_int(expired_time, 0), 0)
    return detail


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


def _store_list_payload(yuanbao=DEFAULT_YUANBAO, timed_goods=None):
    # StoreLayer 默认 goodsType=2 -> list[2] 名称必须是“商城”
    timed_goods = timed_goods if isinstance(timed_goods, dict) else {}
    store_items = []
    for source in _STORE_TEST_ITEMS:
        item = dict(source)
        item_id = str(item.get("itemId") or "")
        if item_id in _TIMED_STORE_GOODS:
            item["expired_time"] = max(_as_int(timed_goods.get(item_id), 0), 0)
        store_items.append(item)
    return {
        "status": "OPEN",
        "list": [
            {
                "classId": "xianshi_goods",
                "name": "限时",
                "items": [dict(x) for x in _STORE_LIMITED_ITEMS],
            },
            {
                "classId": "store_goods",
                "name": "商城",
                "items": store_items,
            },
            {
                "classId": "fuben_goods",
                "name": "关卡",
                "items": [dict(x) for x in _STORE_LEVEL_ITEMS],
            },
            {"classId": "shengong_goods", "name": "神功", "items": []},
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
    timed_goods = {
        item_id: _timed_good_expired_at(ctx, userid, item_id)
        for item_id in _TIMED_STORE_GOODS
    }
    return _ok(_store_list_payload(yuanbao, timed_goods))


@route(["GET", "POST"], "get_limit_package")
def get_limit_package(ctx):
    """限时礼包明细 (get_limit_package/libaoXXXX)。数据抓包自上游。"""
    detail = _LIMITED_PACKAGE_DETAILS.get(_tail(ctx))
    if detail is None:
        return build_response_body({}, errcode=404, errmsg="limited package not found")
    payload = dict(detail)
    payload["list"] = [dict(reward) for reward in detail["list"]]
    now = int(time.time())
    if payload["end_time"] <= now:
        # 抓包活动窗口已过: 顺延 30 天, 保证礼包详情可打开
        payload["end_time"] = now + 30 * 86400
    payload.setdefault("buy_times", 0)
    return _ok(payload)


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


_MASK_SERVER_CURRENCIES = {
    6: "yinpiao",
    7: "spcl",
    8: "zongheng",
    11: "paymaskmake",
}
_MASK_CURRENCY_NAMES = {
    "yinpiao": "银票",
    "spcl": "饰品材料",
    "zongheng": "雪矾",
    "paymaskmake": "鹿胶",
}


def _mask_upgrade_params(value):
    """Normalize both current array conditions and the legacy object format."""
    if isinstance(value, str):
        try:
            value = json.loads(value)
        except (TypeError, ValueError):
            return None
    if not isinstance(value, list):
        return None

    normalized = []
    for condition in value:
        if isinstance(condition, (list, tuple)):
            if not condition:
                return None
            condition_type = _as_int(condition[0], -1)
            normalized.append(list(condition))
        elif isinstance(condition, dict):
            condition_type = _as_int(condition.get("type"), -1)
            normalized.append(dict(condition))
        else:
            return None
        if condition_type < 1 or condition_type > 11:
            return None
    return normalized


def _mask_condition_value(condition, index=1):
    if isinstance(condition, list):
        return condition[index] if len(condition) > index else None
    return condition.get("num")


def _mask_upgrade_requirements(params):
    currencies = {}
    prestige = 0
    for condition in params:
        condition_type = _as_int(
            condition[0] if isinstance(condition, list) else condition.get("type"),
            -1,
        )
        if condition_type in _MASK_SERVER_CURRENCIES:
            amount = _as_int(_mask_condition_value(condition), -1)
            if amount <= 0:
                return None, None
            currency_id = _MASK_SERVER_CURRENCIES[condition_type]
            currencies[currency_id] = currencies.get(currency_id, 0) + amount
        elif condition_type == 4:
            amount = _as_int(_mask_condition_value(condition), -1)
            if amount < 0:
                return None, None
            prestige = max(prestige, amount)
    return currencies, prestige


def _mask_upgrade_receipt_key(body, params):
    if "currencyVersion" not in body:
        return None
    version = _as_int(body.get("currencyVersion"), -1)
    if version < 0:
        return None
    canonical = json.dumps(params, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return "%d:%s" % (version, canonical)


@route(["POST"], "mask_upgrade")
def mask_upgrade(ctx):
    """Validate mask conditions and consume currencies owned by the server."""
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")

    body = _body(ctx)
    params = _mask_upgrade_params(body.get("params"))
    if params is None:
        return build_response_body({}, errcode=1, errmsg="面具升级条件无效")
    requirements, prestige_required = _mask_upgrade_requirements(params)
    if requirements is None:
        return build_response_body({}, errcode=1, errmsg="面具升级消耗无效")

    receipt_key = _mask_upgrade_receipt_key(body, params)
    with ctx["state"].defer_saves():
        archive = ctx["state"].get_archive(userid)
        if not isinstance(archive, dict) or not archive:
            return build_response_body({}, errcode=404, errmsg="archive not found")
        account = ctx["state"]._state.setdefault("accounts", {}).setdefault(
            str(userid), {"userid": userid}
        )
        receipts = account.setdefault("mask_upgrade_receipts", {})
        if receipt_key and receipt_key in receipts:
            receipt = receipts[receipt_key]
            return _ok({"currencyVersion": _as_int(receipt.get("currencyVersion"), 0)})

        if prestige_required:
            prestige_bucket = ctx["state"]._state.setdefault("prestige", {}).get(
                str(userid), {}
            )
            prestige_balance = max(
                _as_int(prestige_bucket.get("total"), 0),
                _as_int(archive.get("prestige"), 0),
                _as_int(archive.get("shengwang"), 0),
                _as_int(archive.get("familyPrestige"), 0),
            )
            if prestige_balance < prestige_required:
                return build_response_body({}, errcode=2, errmsg="师门声望不足")

        currencies = account.setdefault("currencies", {})

        def balance(currency_id):
            return max(
                _as_int(archive.get(currency_id), 0),
                _as_int(currencies.get(currency_id), 0),
            )

        for currency_id, amount in requirements.items():
            if balance(currency_id) < amount:
                name = _MASK_CURRENCY_NAMES.get(currency_id, currency_id)
                return build_response_body({}, errcode=2, errmsg=name + "不足")

        current_version = max(
            _as_int(archive.get("currencyVersion"), 0),
            _as_int(account.get("currency_version"), 0),
        )
        if not requirements:
            return _ok({"currencyVersion": current_version})

        remaining = {
            currency_id: balance(currency_id) - amount
            for currency_id, amount in requirements.items()
        }
        currency_version = max(
            current_version,
            _as_int(body.get("currencyVersion"), 0),
        ) + 1
        for currency_id, value in remaining.items():
            archive[currency_id] = value
        archive["currencyVersion"] = currency_version
        ctx["state"].put_archive(userid, archive)

        for currency_id, value in remaining.items():
            currencies[currency_id] = value
        account["currency_version"] = currency_version
        if receipt_key:
            receipts[receipt_key] = {"currencyVersion": currency_version}
            while len(receipts) > 64:
                del receipts[next(iter(receipts))]
        ctx["state"]._changed()

    return _ok({"currencyVersion": currency_version})


# 招式突破(续卷)道具表: skillUpItem01~24, 与客户端 breakThroughItems.lua 一一对应。
# 客户端 VolumeBoxPresent 会对每个 id 调 getBreakThroughItem(id) 并 assert,
# 因此只能返回表内 id, 且只返回持有数量 > 0 的道具。
_ZHAO_UPGRADE_MATTER_IDS = tuple("skillUpItem%02d" % i for i in range(1, 25))


@route(["GET", "POST"], "get_zhao_upgrade_matters")
def get_zhao_upgrade_matters(ctx):
    """续卷箱: 获取招式突破相关道具数量列表。

    请求: {currencyVersion}  响应: {matters_list: [{id, num}, ...]}
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    matters_list = [
        {"id": item_id, "num": _currency_balance(ctx, userid, item_id)}
        for item_id in _ZHAO_UPGRADE_MATTER_IDS
    ]
    matters_list = [item for item in matters_list if item["num"] > 0]
    return _ok({"matters_list": matters_list})


def _build_zhao_break_through_table():
    """按 zhaoBreakThrough.lua 规律生成招式突破配置表。

    每类主动技能(activeSkillType) 1~10 重:
      - 类型 1~8: id = 100000+(type-1)*10000+重数, 10 重消耗对应 skillUpItem01~08 x2
      - 类型 0:   id = 180000+重数, 最高 9 重(无消耗)
      - 武学等级要求: 1~8 重=1 级, 9 重=600 级, 10 重=1050 级
    客户端未突破时默认取 9 重配置(getZhaoDefaultBreId)。
    """
    table = {}
    for skill_type in range(0, 9):
        base = 180000 if skill_type == 0 else 100000 + (skill_type - 1) * 10000
        for level in range(1, 10 if skill_type == 0 else 11):
            table["%d" % (base + level)] = {
                "skill": 1 if level <= 8 else (600 if level == 9 else 1050),
                "activeSkillType": skill_type,
                "Blevel": level,
                "reitem": ([("skillUpItem%02d" % skill_type, 2)]
                           if level == 10 else []),
            }
    return table


_ZHAO_BREAK_THROUGH = _build_zhao_break_through_table()


@route(["POST"], "zhao_upgrade")
def zhao_upgrade(ctx):
    """招式突破: 消耗续卷将招式提升到下一重。

    请求: {id=目标突破配置id, zhao_id, currencyVersion}
    成功: {reitem_list=[{id,num}], currencyVersion}
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    body = _body(ctx)
    bre_id = str(body.get("id") or "")
    zhao_id = str(body.get("zhao_id") or "")
    if not bre_id or not zhao_id:
        return build_response_body({}, errcode=1, errmsg="invalid breakthrough request")
    bre = _ZHAO_BREAK_THROUGH.get(bre_id)
    if bre is None:
        return build_response_body({}, errcode=1, errmsg="unknown breakthrough id")

    with ctx["state"]._lock:
        archive = ctx["state"].get_archive(userid)
        if not isinstance(archive, dict) or not archive:
            return build_response_body({}, errcode=404, errmsg="archive not found")
        zhao_break_data = archive.setdefault("zhaoBreakData", {})
        current = _ZHAO_BREAK_THROUGH.get(str(zhao_break_data.get(zhao_id) or ""))
        current_level = current["Blevel"] if current else 9
        if bre["Blevel"] != current_level + 1:
            return build_response_body({}, errcode=1, errmsg="breakthrough level invalid")

        account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
        currencies = account.setdefault("currencies", {})

        def _balance(item_id):
            return max(_as_int(archive.get(item_id), 0),
                       _as_int(currencies.get(item_id), 0))

        for item_id, num in bre["reitem"]:
            if _balance(item_id) < num:
                return build_response_body({}, errcode=2, errmsg="所需续卷数量不足")

        reitem_list = []
        for item_id, num in bre["reitem"]:
            remaining = _balance(item_id) - num
            archive[item_id] = remaining
            currencies[item_id] = remaining
            reitem_list.append({"id": item_id, "num": num})

        zhao_break_data[zhao_id] = bre_id
        currency_version = max(
            _as_int(archive.get("currencyVersion"), 0),
            _as_int(body.get("currencyVersion"), 0),
            _as_int(account.get("currency_version"), 0),
        ) + 1
        archive["currencyVersion"] = currency_version
        account["currency_version"] = currency_version
        ctx["state"].put_archive(userid, archive)
        ctx["state"]._changed()
    return _ok({"reitem_list": reitem_list, "currencyVersion": currency_version})


# 续卷商人(天都峰 墨无锋)兑换表: 货币为 功法学识(dmartial)。
# 初卷(01-08)/通卷(09-16)/悟卷(17-24) 三档价格, 上游无抓包数据, 价格为 mock 设定。
_MATTERS_SHOP_CURRENCY = "dmartial"
_MATTERS_SHOP_GOODS = tuple(
    (item_id, 1, 20 if index < 8 else (40 if index < 16 else 80))
    for index, item_id in enumerate(_ZHAO_UPGRADE_MATTER_IDS)
)
_MATTERS_SHOP_CATALOG = {goods[0]: goods for goods in _MATTERS_SHOP_GOODS}


@route(["POST"], "matters_shop_info")
def matters_shop_info(ctx):
    """续卷商人: 获取/刷新兑换列表。type 1 获取 / 2 刷新。

    请求: {type, currencyVersion}
    成功: {matters_list, goods_list, yuanbao_num, currency_number,
           currency_name, isRefreshLimit, currencyVersion}
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    matters_list = [
        {"id": item_id, "num": _currency_balance(ctx, userid, item_id)}
        for item_id in _ZHAO_UPGRADE_MATTER_IDS
    ]
    matters_list = [item for item in matters_list if item["num"] > 0]
    goods_list = [
        {"key": item_id, "id": item_id, "num": num, "price": price}
        for item_id, num, price in _MATTERS_SHOP_GOODS
    ]
    archive = ctx["state"].get_archive(userid) or {}
    account = ctx["state"].get_account(userid) or {}
    currency_version = max(
        _as_int(archive.get("currencyVersion"), 0),
        _as_int(account.get("currency_version"), 0),
    )
    return _ok({
        "matters_list": matters_list,
        "goods_list": goods_list,
        "yuanbao_num": 0,  # 刷新免费
        "currency_number": _currency_balance(ctx, userid, _MATTERS_SHOP_CURRENCY),
        "currency_name": "功法学识",
        "isRefreshLimit": False,  # 刷新不限次
        "currencyVersion": currency_version,
    })


@route(["POST"], "buy_matters")
def buy_matters(ctx):
    """续卷商人: 功法学识兑换续卷。

    请求: {goodsKey, currencyVersion}
    成功: {reward={id,num}, currencyVersion}
    功法学识不足: errcode=2
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    body = _body(ctx)
    goods_key = str(body.get("goodsKey") or body.get("goods_key") or "")
    goods = _MATTERS_SHOP_CATALOG.get(goods_key)
    if goods is None:
        return build_response_body({}, errcode=1, errmsg="goods not found")
    item_id, num, price = goods

    with ctx["state"]._lock:
        archive = ctx["state"].get_archive(userid)
        if not isinstance(archive, dict) or not archive:
            return build_response_body({}, errcode=404, errmsg="archive not found")
        account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
        currencies = account.setdefault("currencies", {})

        def _balance(key):
            return max(_as_int(archive.get(key), 0),
                       _as_int(currencies.get(key), 0))

        currency_balance = _balance(_MATTERS_SHOP_CURRENCY)
        if currency_balance < price:
            return build_response_body({}, errcode=2, errmsg="功法学识不足")

        # 扣除功法学识, 发放续卷(archive 与 account 同步)
        remaining = currency_balance - price
        archive[_MATTERS_SHOP_CURRENCY] = remaining
        currencies[_MATTERS_SHOP_CURRENCY] = remaining
        item_balance = _balance(item_id) + num
        archive[item_id] = item_balance
        currencies[item_id] = item_balance

        currency_version = max(
            _as_int(archive.get("currencyVersion"), 0),
            _as_int(body.get("currencyVersion"), 0),
            _as_int(account.get("currency_version"), 0),
        ) + 1
        archive["currencyVersion"] = currency_version
        account["currency_version"] = currency_version
        ctx["state"].put_archive(userid, archive)
        ctx["state"]._changed()
    return _ok({"reward": {"id": item_id, "num": num}, "currencyVersion": currency_version})


# 活动积分商店(充值积分兑换): 数据抓包自 so/har_decrypt_91/entries/098_get_shop_info.json。
_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_POINT_SHOP_CURRENCY = "chongzhijifen"
_POINT_SHOP_FILES = {
    "zhounianqin_cz": os.path.join(_ROOT, "item_json", "shop_zhounianqin_cz.json"),
}
_POINT_SHOPS = {}


def _load_point_shop(shop_id):
    if shop_id not in _POINT_SHOPS:
        path = _POINT_SHOP_FILES.get(shop_id)
        if path is None:
            return None
        with open(path, encoding="utf-8") as f:
            _POINT_SHOPS[shop_id] = json.load(f)
    return _POINT_SHOPS[shop_id]


@route(["POST"], "get_shop_info")
def get_shop_info(ctx):
    """活动积分商店(AnniversaryCelebrationConversionLayer)。

    请求: {shop_id}  响应: {shop_info, total_points, isDis, disInfo}
    total_points 为用户当前活动积分(chongzhijifen)。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    shop_id = str(_body(ctx).get("shop_id") or "")
    shop_info = _load_point_shop(shop_id)
    if shop_info is None:
        return build_response_body({}, errcode=404, errmsg="shop not found")
    return _ok({
        "shop_info": shop_info,
        "total_points": _currency_balance(ctx, userid, _POINT_SHOP_CURRENCY),
        "isDis": False,
        "disInfo": False,
    })


def _find_point_shop_goods(shop_info, item_id):
    for items in (shop_info.get("goods") or {}).values():
        for goods in items:
            if str(goods.get("itemId")) == item_id:
                return goods
    return None


def _point_shop_bucket(state, userid):
    root = state._state.setdefault("point_shop", {})
    bucket = root.get(str(userid))
    if not isinstance(bucket, dict):
        bucket = {"transactions": {}, "counts": {}}
        root[str(userid)] = bucket
    if not isinstance(bucket.get("transactions"), dict):
        bucket["transactions"] = {}
    if not isinstance(bucket.get("counts"), dict):
        bucket["counts"] = {}
    return bucket


@route(["POST"], "shop_exchange_goods")
def shop_exchange_goods(ctx):
    """活动积分商店兑换。

    请求: {itemId, client_trans_id, shop_id, number, dataVer, currencyVersion}
    成功: {reward={itemId,number,itype,name}, romove_point, total_points,
           isDis, currencyVersion}
    奖励道具由客户端本地入包; 服务端负责扣积分、限购与幂等。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    body = _body(ctx)
    item_id = str(body.get("itemId") or "")
    shop_id = str(body.get("shop_id") or "")
    client_trans_id = str(body.get("client_trans_id") or "")
    number = max(_as_int(body.get("number"), 0), 0)
    if not item_id or not client_trans_id or number <= 0:
        return build_response_body({}, errcode=1, errmsg="invalid exchange request")
    shop_info = _load_point_shop(shop_id)
    if shop_info is None:
        return build_response_body({}, errcode=404, errmsg="shop not found")
    goods = _find_point_shop_goods(shop_info, item_id)
    if goods is None:
        return build_response_body({}, errcode=1, errmsg="goods not found")

    # 限购: is_again=N 时限购 times 次(与 extra.limit 一致), Y 不限
    limit = None
    if str(goods.get("is_again") or "N") == "N":
        limit = max(_as_int(goods.get("times"), 0), 0)
    unit_price = max(_as_int(goods.get("price"), 0), 0)
    total_cost = unit_price * number
    signature = json.dumps(
        {"itemId": item_id, "shop_id": shop_id, "number": number},
        ensure_ascii=False, sort_keys=True, separators=(",", ":"))

    with ctx["state"]._lock:
        bucket = _point_shop_bucket(ctx["state"], userid)
        previous = bucket["transactions"].get(client_trans_id)
        if isinstance(previous, dict):
            if previous.get("signature") != signature:
                return build_response_body({}, errcode=409, errmsg="client_trans_id conflict")
            return copy.deepcopy(previous.get("response"))

        count_key = "%s/%s" % (shop_id, item_id)
        if limit is not None and _as_int(bucket["counts"].get(count_key), 0) + number > limit:
            return build_response_body({}, errcode=1, errmsg="您已经达到购买上限")

        archive = ctx["state"].get_archive(userid)
        if not isinstance(archive, dict) or not archive:
            return build_response_body({}, errcode=404, errmsg="archive not found")
        account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
        currencies = account.setdefault("currencies", {})
        balance = max(_as_int(archive.get(_POINT_SHOP_CURRENCY), 0),
                      _as_int(currencies.get(_POINT_SHOP_CURRENCY), 0))
        if balance < total_cost:
            return build_response_body({}, errcode=1, errmsg="充值积分不足")

        remaining = balance - total_cost
        archive[_POINT_SHOP_CURRENCY] = remaining
        currencies[_POINT_SHOP_CURRENCY] = remaining
        currency_version = max(
            _as_int(archive.get("currencyVersion"), 0),
            _as_int(body.get("currencyVersion"), 0),
            _as_int(account.get("currency_version"), 0),
        ) + 1
        archive["currencyVersion"] = currency_version
        account["currency_version"] = currency_version
        ctx["state"].put_archive(userid, archive)

        bucket["counts"][count_key] = _as_int(bucket["counts"].get(count_key), 0) + number
        response = _ok({
            "reward": {
                "itemId": item_id,
                "number": max(_as_int(goods.get("number"), 1), 1) * number,
                "itype": _as_int(goods.get("itype"), 1),
                "name": goods.get("name") or item_id,
            },
            "romove_point": total_cost,
            "total_points": remaining,
            "isDis": False,
            "currencyVersion": currency_version,
        })
        bucket["transactions"][client_trans_id] = {
            "signature": signature,
            "response": copy.deepcopy(response),
        }
        ctx["state"]._changed()
    return response


@route(["GET", "POST"], "get_goods")
def get_goods(ctx):
    item_key = _tail(ctx)
    item = _find_store_item(item_key)
    if item is None:
        return build_response_body({}, errcode=404, errmsg="goods not found")
    expired_time = None
    item_id = str(item.get("itemId") or "")
    if item_id in _TIMED_STORE_GOODS:
        expired_time = _timed_good_expired_at(ctx, _userid(ctx), item_id)
    return _ok(_goods_detail(item, expired_time))


@route(["POST"], "get_goods_2")
def get_goods_2(ctx):
    item = _find_store_item(_tail(ctx))
    if item is None:
        return build_response_body({}, errcode=404, errmsg="goods not found")
    item_id = str(item.get("itemId") or "")
    expired_time = None
    if item_id in _TIMED_STORE_GOODS:
        expired_time = _timed_good_expired_at(ctx, _userid(ctx), item_id)
    detail = _goods_detail(item, expired_time)
    others = _body(ctx)
    if others:
        detail["others"] = others
    return _ok(detail)


@route(["POST"], "check_goods_valid")
def check_goods_valid(ctx):
    userid = _userid(ctx)
    item_ids = _body(ctx).get("itemIds")
    if not isinstance(item_ids, list):
        item_ids = []
    now = int(time.time())
    values = []
    for value in item_ids:
        item_id = str(value or "")
        expired_time = _timed_good_expired_at(ctx, userid, item_id)
        values.append({
            "itemId": item_id,
            "number": 1 if expired_time > now else 0,
            "expired_time": expired_time,
        })
    return _ok(values)


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
    state = ctx["state"]
    state.ensure_account(userid)
    now = int(time.time())
    item_id = str(item.get("itemId") or "")

    def apply_purchase(current):
        accounts = current.setdefault("accounts", {})
        account = accounts.setdefault(str(userid), {"userid": userid})
        orders = current.setdefault("orders", {})
        for existing in orders.values():
            if not isinstance(existing, dict):
                continue
            if _as_int(existing.get("userid"), 0) != userid:
                continue
            if str(existing.get("client_trans_id") or "") != str(client_trans_id):
                continue
            if existing.get("status") == "success":
                return {"duplicate": True, "order": existing}

        balance = max(_as_int(account.get("yuanbao"), DEFAULT_YUANBAO), 0)
        if balance < cost:
            return {"insufficient": True, "balance": balance}
        total = balance - cost
        account["yuanbao"] = total
        account["updated_at"] = now

        expired_time = None
        duration = _TIMED_STORE_GOODS.get(item_id)
        if duration is not None:
            current_expiry = _timed_good_expired_at_values(
                account, orders, userid, item_id,
            )
            expired_time = max(current_expiry, now) + duration * quantity
            expired_times = account.get("store_goods_expired_at")
            if not isinstance(expired_times, dict):
                expired_times = {}
                account["store_goods_expired_at"] = expired_times
            expired_times[item_id] = expired_time

        order_id = state._next("order_id", "order")
        trans_id = state._next("order_id", "trans")
        order = {
            "order_id": order_id,
            "trans_id": trans_id,
            "userid": userid,
            "status": "success",
            "payload": dict(body),
            "created_at": now,
            "updated_at": now,
            "item_id": item_id,
            "shop_id": item.get("id"),
            "quantity": quantity,
            "remove_yuanbao": cost,
            "total_yuanbao": total,
            "client_trans_id": client_trans_id,
        }
        if expired_time is not None:
            order["expired_time"] = expired_time
        orders[trans_id] = order
        return {"duplicate": False, "order": order}

    purchase = state.mutate(apply_purchase)
    if purchase.get("insufficient"):
        return build_response_body(
            {"total_yuanbao": purchase["balance"], "remove_yuanbao": 0},
            errcode=1,
            errmsg="元宝不足，购买失败！",
        )
    order = purchase["order"]
    expired_time = order.get("expired_time")
    if item_id in _TIMED_STORE_GOODS:
        expired_time = _timed_good_expired_at(ctx, userid, item_id)
    response = {
        "total_yuanbao": _as_int(order.get("total_yuanbao"), 0),
        "remove_yuanbao": _as_int(order.get("remove_yuanbao"), 0),
        "special_reward": {},
        "activity": {},
        "client_trans_id": client_trans_id,
        "itemId": item_id,
        "id": item.get("id"),
        "quantity": quantity,
    }
    if expired_time is not None:
        response["expired_time"] = expired_time
    return build_response_body(response, errcode=0, errmsg="", status=200)


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


_LOCAL_ROLE_ATTR_REWARD_IDS = frozenset(("money", "gold"))
_MAIL_REWARD_KEYS = (
    "loc_items",
    "net_items",
    "loc_attrs",
    "net_attrs",
    "new_currencys",
    "title_items",
)
_MAIL_CLIENT_SELECTED_REWARD_KEYS = frozenset(("loc_items", "loc_attrs"))
_SERVER_MANAGED_MAIL_ITEM_IDS = frozenset((
    "minditem1",
    "minditem2",
    "minditem3",
    "minditem4",
))


def _empty_mail_rewards():
    return {key: [] for key in _MAIL_REWARD_KEYS}


def _move_local_role_attr_rewards(rewards):
    """Lua only applies role attributes returned in loc_attrs."""
    local_attrs = rewards.setdefault("loc_attrs", [])
    for key in ("net_attrs", "new_currencys"):
        remote_values = []
        for value in rewards.get(key, []):
            if str(value.get("id") or "") in _LOCAL_ROLE_ATTR_REWARD_IDS:
                local_attrs.append(value)
            else:
                remote_values.append(value)
        rewards[key] = remote_values
    return rewards


def _mail_rewards(item):
    rewards = item.get("rewards") if isinstance(item.get("rewards"), dict) else {}
    result = {}
    for key in _MAIL_REWARD_KEYS:
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
    return _move_local_role_attr_rewards(result)


def _bulk_reward_only_id(mail_id, key, reward):
    """Return an opaque, mail-scoped id that the client can round-trip."""
    return "%s:%s:%s" % (mail_id, key, reward.get("onlyId", ""))


def _bulk_mail_rewards(item, include_claimed=False):
    """Flatten one mail's rewards for the bulk-preview/claim protocol."""
    mail_id = str(item.get("mail_id") or "")
    result = _empty_mail_rewards()
    for key, values in _mail_rewards(item).items():
        for value in values:
            if not include_claimed and _as_int(value.get("state"), 0) == 1:
                continue
            reward = dict(value)
            reward["onlyId"] = _bulk_reward_only_id(mail_id, key, value)
            result[key].append(reward)
    return result


def _extend_mail_rewards(target, source):
    for key in _MAIL_REWARD_KEYS:
        target[key].extend(source.get(key, []))
    return target


def _grant_mail_net_items(state, userid, values):
    """Grant normal server items and XinShen items to their owning stores."""
    inventory = state._state.setdefault("inventory_items", {}).setdefault(str(userid), {})
    for value in values:
        item_id = str(value.get("id") or "")
        amount = _as_int(value.get("num"), 0)
        if not item_id or amount <= 0:
            continue
        if item_id in _SERVER_MANAGED_MAIL_ITEM_IDS:
            practice = state._state.setdefault("practice", {}).setdefault(str(userid), {})
            item_map = practice.setdefault("itemMap", {})
            item = item_map.setdefault(item_id, {"count": 0})
            item["count"] = max(_as_int(item.get("count"), 0), 0) + amount
        else:
            inventory[item_id] = max(_as_int(inventory.get(item_id), 0), 0) + amount


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
        for key in _MAIL_REWARD_KEYS
    }
    _move_local_role_attr_rewards(rewards)
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
        if item_id in _SERVER_MANAGED_MAIL_ITEM_IDS:
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

    for value in rewards["loc_attrs"] + rewards["net_attrs"] + rewards["new_currencys"]:
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
    with ctx["state"].defer_saves():
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
        _grant_mail_net_items(ctx["state"], userid, rewards["net_items"])
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
    with ctx["state"].defer_saves():
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
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    rewards = _empty_mail_rewards()
    for item in ctx["state"].list_mail(userid):
        if item.get("claimed") or item.get("deleted"):
            continue
        _extend_mail_rewards(rewards, _bulk_mail_rewards(item))
    return _ok(rewards)


@route(["POST"], "get_all_email_rewards")
def get_all_email_rewards(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")

    requested = body.get("retrievables")
    selected = {str(value) for value in requested} if isinstance(requested, list) else set()
    now = int(time.time())

    with ctx["state"].defer_saves():
        values = [
            item
            for item in ctx["state"].list_mail(userid)
            if not item.get("claimed") and not item.get("deleted")
        ]
        expired_ids = [
            str(item.get("mail_id") or "")
            for item in values
            if _as_int(item.get("expired_time"), 0)
            and _as_int(item.get("expired_time"), 0) <= now
            and any(_mail_rewards(item).values())
        ]
        if expired_ids:
            return build_response_body(
                {"expired_ids": expired_ids},
                errcode=2,
                errmsg="email expired",
            )

        granted = _empty_mail_rewards()
        mail_updates = []
        is_get_list = []
        for item in values:
            mail_id = str(item.get("mail_id") or "")
            rewards = _mail_rewards(item)
            granted_from_mail = False
            for key, reward_list in rewards.items():
                for reward in reward_list:
                    if _as_int(reward.get("state"), 0) != 0:
                        continue
                    bulk_only_id = _bulk_reward_only_id(mail_id, key, reward)
                    if key in _MAIL_CLIENT_SELECTED_REWARD_KEYS and bulk_only_id not in selected:
                        continue
                    returned_reward = dict(reward)
                    returned_reward["onlyId"] = bulk_only_id
                    granted[key].append(returned_reward)
                    reward["state"] = 1
                    granted_from_mail = True

            if not granted_from_mail:
                continue
            fully_claimed = all(
                _as_int(reward.get("state"), 0) == 1
                for reward_list in rewards.values()
                for reward in reward_list
            )
            mail_updates.append((mail_id, rewards, fully_claimed))
            if fully_claimed:
                expired_at = _as_int(item.get("expired_time"), 0)
                is_get_list.append({
                    "id": mail_id,
                    "expired_time": max(expired_at - now, 0) if expired_at else 0,
                })

        account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
        if any(granted.values()):
            _grant_mail_net_items(ctx["state"], userid, granted["net_items"])

            currencies = account.setdefault("currencies", {})
            for value in granted["net_attrs"] + granted["new_currencys"]:
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
                granted,
                data_ver,
                currency_version,
            )
            for mail_id, rewards, fully_claimed in mail_updates:
                ctx["state"].update_mail(userid, mail_id, {
                    "read": True,
                    "claimed": fully_claimed,
                    "state": 2 if fully_claimed else 1,
                    "rewards": rewards,
                })
        else:
            archive = ctx["state"].get_archive(userid) or {}
            data_ver = _as_int(archive.get("dataVer"), _as_int(body.get("dataVer"), 0))

        result = {
            "is_getList": is_get_list,
            "dataVer": data_ver,
            "currencyVersion": _as_int(
                account.get("currency_version"),
                _as_int(body.get("currencyVersion"), 0),
            ),
        }
        result.update(granted)
        return _ok(result)


@route(["GET"], "delete_processed_emails")
def delete_processed_emails(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    delete_ids = []
    with ctx["state"].defer_saves():
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


_RANKING_PAGE_SIZE = 10

# Keep ranking labels in sync with the client resources:
#   assets/res/script/family/family.lua
#   assets/res/script/skill/kongfuDesc.lua
_RANKING_FAMILY_NAMES = {
    "baituoshan": "鸩羽山",
    "dali": "天龙寺",
    "emei": "峨眉派",
    "gaibang": "丐帮",
    "guanfu": "官府",
    "gumu": "问情宫",
    "haijing": "海鲸帮",
    "huashan": "华山",
    "jinqianbang": "财神帮",
    "kongtong": "崆峒派",
    "kunlun": "昆仑派",
    "luoyue": "落月山庄",
    "mingjiao": "明教",
    "mizong": "雪山寺",
    "murong": "燕氏皇族",
    "quanzhen": "全真教",
    "riyueshenjiao": "拜日教",
    "seclusion": "归隐",
    "shaolin": "少林派",
    "tangmen": "唐门",
    "taohuadao": "蓬莱岛",
    "tianjingmen": "天竞门",
    "tianshan": "虚渺宫",
    "tiezhang": "伏龙山",
    "wudang": "武当派",
    "wudu": "万灵谷",
    "xingxiu": "天狼教",
    "yongyelou": "永夜楼",
    "youming": "幽冥教",
}
_RANKING_WANDERER_FAMILIES = {"", "0", "none", "jianghu", "youxia", "散人", "游侠", "江湖"}
_KONGFU_DESCRIPTIONS = (
    (0, "ALS不堪一击"), (20, "ALS毫不足虑"), (30, "ALS不足挂齿"),
    (40, "ALS初学乍练"), (50, "ALS勉勉强强"), (60, "ALS初窥门径"),
    (70, "ALS初出茅庐"), (80, "ALS略知一二"), (90, "ALS普普通通"),
    (100, "ALS平平淡淡"), (110, "ALS平淡无奇"), (120, "ALS粗通皮毛"),
    (130, "ALS半生不熟"), (140, "ALS马马虎虎"), (150, "ALS略有小成"),
    (160, "ALS已有小成"), (170, "ALS鹤立鸡群"), (180, "ALS驾轻就熟"),
    (190, "ALS青出于蓝"), (200, "AQS融会贯通"), (210, "AQS心领神会"),
    (220, "AQS炉火纯青"), (230, "AQS了然于胸"), (240, "AQS略有大成"),
    (250, "AQS已有大成"), (270, "AQS豁然贯通"), (290, "AQS出类拔萃"),
    (300, "AQS无可匹敌"), (330, "AQS技冠群雄"), (350, "AQS神乎其技"),
    (370, "AQS出神入化"), (390, "AQS非同凡响"), (400, "ALSS傲视群雄"),
    (430, "ALSS登峰造极"), (450, "ALSS无与伦比"), (470, "ALSS所向披靡"),
    (500, "ALSS一代宗师"), (525, "ALSS精深奥妙"), (550, "ALSS神功盖世"),
    (575, "ALSS举世无双"), (600, "ASHS惊世骇俗"), (625, "ASHS撼天动地"),
    (650, "ASHS震古铄今"), (675, "ASHS超凡入圣"), (700, "ZHS威震寰宇"),
    (725, "ZHS空前绝后"), (750, "ZHS天人合一"), (775, "ZHS深藏不露"),
    (800, "XNS深不可测"), (850, "XNS返璞归真"), (900, "WHT罕有敌手"),
    (950, "WHT技艺超群"), (1000, "HIW冠绝一时"), (1050, "HIW万夫莫当"),
    (1100, "HIW盖世无双"),
)


def _ranking_number(value, default=0):
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _ranking_family(role):
    family = role.get("menpai") or role.get("real_menpai") or role.get("family") or role.get("familyId")
    if isinstance(family, dict):
        family = family.get("name") or family.get("id")
    family = str(family or "").strip()
    family_key = family.lower()
    if family_key in _RANKING_WANDERER_FAMILIES:
        return "江湖浪人"
    return _RANKING_FAMILY_NAMES.get(family_key, family)


def _ranking_kongfu_description(kongfu):
    description = "看不出武功强弱"
    for threshold, value in _KONGFU_DESCRIPTIONS:
        if kongfu < threshold:
            break
        description = value
    return description


def _ranking_user(ctx, userid):
    account = ctx["state"].get_account(userid) or {}
    role = ctx["state"].get_archive(userid) or {}
    exp = _ranking_number(role.get("exp"), 0)
    kongfu = _ranking_number(role.get("kongfu"), exp / 100000.0)
    name = account.get("name") or role.get("name") or "玩家%s" % userid
    portrait = role.get("portrait") or ""
    if isinstance(portrait, dict):
        portrait = portrait.get("itemId") or portrait.get("id") or ""
    entry = {
        "userid": userid,
        "name": name,
        "lv": int(_ranking_number(role.get("lv"), 1)),
        "exp": exp,
        "jingyan": exp,
        "kongfu": kongfu,
        "money": _ranking_number(role.get("money"), 0),
        "gold": _ranking_number(role.get("gold"), 0),
        "yueli": _ranking_number(role.get("yueli"), 0),
        "xiayi": _ranking_number(role.get("xiayi"), 0),
        "sex": role.get("sex") or "男",
        "looks": int(_ranking_number(role.get("looks"), 20)),
        "menpai": _ranking_family(role),
        "real_menpai": _ranking_family(role),
        "portrait": portrait,
        "head": role.get("head") or "",
        "inheritCount": int(_ranking_number(role.get("inheritCount"), 0)),
        "dsc": role.get("kongfuDsc") or _ranking_kongfu_description(kongfu),
        "score": kongfu,
        "yueka": "NO",
    }
    return entry


def _legacy_ranking_board(ctx, board_type="default", page=1):
    userid = _userid(ctx)
    if userid > 0 and ctx["state"].get_account(userid) is not None:
        ctx["state"].upsert_ranking(board_type, userid, _ranking_user(ctx, userid))
    ranking = ctx["state"].get_rankings(board_type, page, _RANKING_PAGE_SIZE)
    values = ranking["list"]
    for value in values:
        value["sort"] = value.pop("rank", 0)
    total = ranking["total"]
    total_page = max(1, (total + _RANKING_PAGE_SIZE - 1) // _RANKING_PAGE_SIZE)
    mine = next((value.copy() for value in values if int(value.get("userid", 0)) == userid), None)
    return {
        "title": "高手榜",
        "type": "total_board",
        "header": ["名次", "昵称", "武学造诣"],
        "body": {"list": values, "mine": mine},
        "total_nums": total,
        "board_type": str(board_type),
        "total_page": total_page,
        "nums": _RANKING_PAGE_SIZE,
    }


@route(["POST"], "get_rank_list_4")
def get_rank_list(ctx):
    userid = _userid(ctx)
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return build_response_body([], errcode=552, errmsg="userid not found")
    page = _body(ctx).get("page", 1)
    return _ok([_legacy_ranking_board(ctx, "default", page)])


@route(["POST"], "get_board")
def get_board(ctx):
    userid = _userid(ctx)
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    board_type = _tail(ctx, default="default")
    return _ok(_legacy_ranking_board(ctx, board_type, _body(ctx).get("page", 1)))


@route(["POST"], "get_user_info")
def get_user_info(ctx):
    body = _body(ctx)
    return _ok({"userid": body.get("userid", 0), "type": body.get("type", 0)})


@route(["GET"], "is_changed_name")
def is_changed_name(ctx):
    userid = _userid(ctx)
    account = ctx["state"].get_account(userid) if userid > 0 else None
    if account is None:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    name = str(account.get("name") or "").strip()
    changed = bool(account.get("ranking_name_changed")) or (
        bool(name) and name != "无名小辈" and name != "玩家%s" % userid
    )
    if changed:
        return build_response_body({"changed": True}, errcode=1, errmsg="name already changed")
    return _ok({"changed": False})


@route(["POST"], "update_username")
def update_username(ctx):
    name = _body(ctx).get("name", "")
    if not isinstance(name, str) or not name.strip():
        return build_response_body({}, errcode=400, errmsg="name is required")
    userid = _userid(ctx)
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    name = name.strip()
    ctx["state"].update_account(userid, {"name": name, "ranking_name_changed": True})
    ctx["state"].upsert_ranking("default", userid, _ranking_user(ctx, userid))
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


SIGN_IN_ACTIVITY_ID = "qiandao"
SIGN_IN_SEASON_DAYS = 49
SIGN_IN_SEASON_EPOCH = date(2026, 7, 15)
SIGN_IN_SEASON_EPOCH_ID = 73
SIGN_IN_MAKEUP_COST = 20


def _sign_today():
    return datetime.fromtimestamp(time.time()).date()


def _sign_season(today=None):
    today = today or _sign_today()
    cycle = (today - SIGN_IN_SEASON_EPOCH).days // SIGN_IN_SEASON_DAYS
    begin = SIGN_IN_SEASON_EPOCH + timedelta(days=cycle * SIGN_IN_SEASON_DAYS)
    return SIGN_IN_SEASON_EPOCH_ID + cycle, begin, begin + timedelta(days=SIGN_IN_SEASON_DAYS - 1)


def _sign_date(value):
    try:
        return datetime.strptime(str(value), "%Y%m%d").date()
    except (TypeError, ValueError):
        return None


def _next_sign_prize(history_count, claimed_prizes):
    claimed = {_as_int(value, 0) for value in claimed_prizes}
    milestone = 15
    while milestone in claimed:
        milestone = 30 if milestone == 15 else milestone + 30
    return milestone


def _sign_bucket(ctx, userid):
    account = ctx["state"].ensure_account(userid)
    season_id, begin, _ = _sign_season()
    with ctx["state"]._lock:
        user = ctx["state"]._state.setdefault("activity_users", {}).setdefault(str(userid), {})
        bucket = user.setdefault(SIGN_IN_ACTIVITY_ID, {})
        changed = False
        if _as_int(bucket.get("season_id"), 0) != season_id:
            bucket["season_id"] = season_id
            bucket["signed_list"] = []
            changed = True
        for key, default in (
            ("signed_list", []),
            ("claimed_prizes", []),
            ("transactions", {}),
        ):
            if not isinstance(bucket.get(key), type(default)):
                bucket[key] = default
                changed = True
        history_count = max(_as_int(bucket.get("history_sign_count"), 0), 0)
        if bucket.get("history_sign_count") != history_count:
            bucket["history_sign_count"] = history_count
            changed = True
        created_at = _as_int(account.get("created_at"), int(time.time()))
        create_date = datetime.fromtimestamp(created_at).date()
        if create_date < begin:
            create_date = begin
        create_value = create_date.strftime("%Y%m%d")
        if bucket.get("create_date") != create_value:
            bucket["create_date"] = create_value
            changed = True
        if changed:
            ctx["state"]._changed()
        return bucket


def _sign_payload(ctx, userid):
    season_id, begin, end = _sign_season()
    with ctx["state"]._lock:
        bucket = _sign_bucket(ctx, userid)
        signed_list = sorted({
            str(value) for value in bucket["signed_list"]
            if _sign_date(value) is not None
        })
        history_count = max(_as_int(bucket.get("history_sign_count"), 0), 0)
        return {
            "beginDate": begin.strftime("%Y%m%d"),
            "endDate": end.strftime("%Y%m%d"),
            "seasonId": season_id,
            "signedList": signed_list,
            "historySignCount": history_count,
            "prizeList": [],
            "prizeId": _next_sign_prize(history_count, bucket["claimed_prizes"]),
            "yuanbao": SIGN_IN_MAKEUP_COST,
            "createDate": bucket["create_date"],
        }


@route(["GET"], "get_sign_list")
def get_sign_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    return _ok(_sign_payload(ctx, userid))


@route(["POST"], "get_sign_prize")
def get_sign_prize(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    sign_date = _sign_date(body.get("date"))
    trans_id = str(body.get("trans_id") or "").strip()
    item_id = str(body.get("item_id") or "").strip()
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    if sign_date is None or not trans_id or not item_id:
        return build_response_body({}, errcode=400, errmsg="invalid sign request")

    today = _sign_today()
    _, begin, end = _sign_season(today)
    if sign_date < begin or sign_date > end or sign_date > today:
        return build_response_body({}, errcode=400, errmsg="invalid sign date")

    with ctx["state"]._lock:
        bucket = _sign_bucket(ctx, userid)
        transactions = bucket["transactions"]
        if trans_id in transactions:
            return _ok(dict(transactions[trans_id]))
        sign_value = sign_date.strftime("%Y%m%d")
        if sign_value < bucket["create_date"]:
            return build_response_body({}, errcode=400, errmsg="sign date predates account")
        if sign_value in bucket["signed_list"]:
            return build_response_body({}, errcode=2, errmsg="date already signed")

        if sign_date < today:
            account = ctx["state"]._state["accounts"][str(userid)]
            balance = max(_as_int(account.get("yuanbao"), DEFAULT_YUANBAO), 0)
            if balance < SIGN_IN_MAKEUP_COST:
                return build_response_body({}, errcode=1, errmsg="元宝不足")
            account["yuanbao"] = balance - SIGN_IN_MAKEUP_COST
            account["updated_at"] = int(time.time())

        result = {
            "yinpiao": 0,
            "yuanbao": 0,
            "daily_point": 10 if sign_date == today else 0,
        }
        bucket["signed_list"].append(sign_value)
        bucket["signed_list"].sort()
        bucket["history_sign_count"] = max(
            _as_int(bucket.get("history_sign_count"), 0), 0
        ) + 1
        transactions[trans_id] = dict(result)
        if len(transactions) > 200:
            transactions.pop(next(iter(transactions)))
        ctx["state"]._changed()
        return _ok(result)


@route(["POST"], "get_sign_history_prize")
def get_sign_history_prize(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    trans_id = str(body.get("trans_id") or "").strip()
    prize_id = _as_int(body.get("prize_id"), 0)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    if not trans_id or prize_id <= 0:
        return build_response_body({}, errcode=400, errmsg="invalid prize request")
    with ctx["state"]._lock:
        bucket = _sign_bucket(ctx, userid)
        transactions = bucket["transactions"]
        if trans_id in transactions:
            return _ok(dict(transactions[trans_id]))
        expected = _next_sign_prize(
            bucket["history_sign_count"], bucket["claimed_prizes"]
        )
        if prize_id != expected or bucket["history_sign_count"] < prize_id:
            return build_response_body({}, errcode=1, errmsg="sign count is not enough")
        bucket["claimed_prizes"].append(prize_id)
        result = {"received": True, "prize_id": prize_id}
        transactions[trans_id] = dict(result)
        ctx["state"]._changed()
        return _ok(result)


@route(["POST"], "check_failed_normal_sign")
def check_failed_normal_sign(ctx):
    userid = _userid(ctx)
    trans_id = str(_body(ctx).get("trans_id") or "").strip()
    if userid <= 0 or not trans_id:
        return build_response_body({}, errcode=400, errmsg="invalid transaction")
    with ctx["state"]._lock:
        bucket = _sign_bucket(ctx, userid)
        result = bucket["transactions"].get(trans_id)
        if result is None:
            return build_response_body({}, errcode=1, errmsg="transaction not found")
        return _ok(dict(result))


TRAINING_ACTIVITY_ID = "limited_time_experience"
TRAINING_TASK_RULES = {
    "yiwen": (1, 2),
    "tiaoxi": (1, 1),
    "chuangmen": (1, 2),
    "dream": (1, 2),
    "jina": (1, 1),
    "feizei": (1, 1),
    "nanyang": (1, 2),
    "gusi": (1, 2),
    "songxin": (1, 1),
    "guaji": (1, 1),
    "smketou": (3, 1),
    "smjyshuaxin": (1, 1),
    "paihangbang": (1, 1),
    "meirijifen": (60, 1),
    "qjduantixiuxing": (1, 2),
    "qjjiqiaoxiuxing": (1, 2),
    "ymchongmai": (1, 3),
}


def _training_bucket(ctx, userid):
    ctx["state"].ensure_account(userid)
    user = ctx["state"]._state.setdefault("activity_users", {}).setdefault(
        str(userid), {}
    )
    bucket = user.setdefault(TRAINING_ACTIVITY_ID, {})
    changed = False
    point = max(_as_int(bucket.get("point"), 0), 0)
    completion_times = max(_as_int(bucket.get("completion_times"), 0), 0)
    tasks = bucket.get("tasks")
    if not isinstance(tasks, dict):
        tasks = {}
        changed = True
    if bucket.get("point") != point:
        changed = True
    if bucket.get("completion_times") != completion_times:
        changed = True
    bucket.update({
        "point": point,
        "completion_times": completion_times,
        "tasks": tasks,
    })
    if changed:
        ctx["state"]._changed()
    return bucket


@route(["POST"], "add_training_task_point")
def add_training_task_point(ctx):
    userid = _userid(ctx)
    body = _body(ctx)
    tid = str(body.get("tid") or "").strip()
    task_list = body.get("taskList")
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    if not tid or len(tid) > 64 or not isinstance(task_list, list) or len(task_list) > 100:
        return build_response_body({}, errcode=400, errmsg="invalid training task request")
    if any(not isinstance(value, str) or not value.strip() for value in task_list):
        return build_response_body({}, errcode=400, errmsg="invalid training task pool")

    task_pool = {value.strip() for value in task_list}
    rule = TRAINING_TASK_RULES.get(tid)
    accepted = tid in task_pool and rule is not None
    with ctx["state"]._lock:
        bucket = _training_bucket(ctx, userid)
        task = bucket["tasks"].get(tid)
        if not isinstance(task, dict):
            task = {"count": 0, "completed": False}

        required, score = rule or (1, 0)
        count = min(max(_as_int(task.get("count"), 0), 0), required)
        completed = bool(task.get("completed"))
        added_point = 0
        if accepted and not completed:
            count = min(count + 1, required)
            if count >= required:
                completed = True
                added_point = score
                bucket["point"] += score
                bucket["completion_times"] += 1
            task = {"count": count, "completed": completed}
            bucket["tasks"][tid] = task
            bucket["updated_at"] = int(time.time())
            ctx["state"]._changed()

        return _ok({
            "tid": tid,
            "accepted": accepted,
            "completed": completed,
            "progress": count,
            "required": required,
            "added_point": added_point,
            "point": bucket["point"],
            "completion_times": bucket["completion_times"],
        })


# The client records completion of several activities through a legacy
# ``add_record/<event>`` GET endpoint.  Route matching supports a prefix, so
# keeping one handler here also covers newer event suffixes such as
# ``songxin_333_unInherit`` without requiring a release for every task id.
@route(["GET"], "add_record")
def add_record(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")

    tail = str((ctx.get("route_tail") or [""])[0] or "").strip()
    event = tail.split("_", 1)[0].lower()
    # lunjian is a historical battle record rather than a limited-time task.
    # It still needs an acknowledgement because the client does not inspect
    # the response body, only the protocol status.
    if event == "lunjian":
        return _ok({"recorded": True, "type": tail or event})

    if event in TRAINING_TASK_RULES:
        with ctx["state"]._lock:
            bucket = _training_bucket(ctx, userid)
            required, score = TRAINING_TASK_RULES[event]
            task = bucket["tasks"].get(event) or {"count": 0, "completed": False}
            count = min(max(_as_int(task.get("count"), 0), 0), required)
            if not task.get("completed"):
                count = min(count + 1, required)
                completed = count >= required
                bucket["tasks"][event] = {"count": count, "completed": completed}
                if completed:
                    bucket["point"] += score
                    bucket["completion_times"] += 1
                bucket["updated_at"] = int(time.time())
                ctx["state"]._changed()
        return _ok({"recorded": True, "type": tail or event})

    # Unknown record types are intentionally idempotent: older clients send
    # optional records that newer servers may not know yet.
    return _ok({"recorded": True, "type": tail or event})


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
            "qingan_count": 0,
        })
        changed = False
        if bucket.get("day") != today:
            bucket["day"] = today
            bucket["today_point"] = 0
            bucket["qingan_count"] = 0
            changed = True
        for key in ("dev_point", "today_point", "qingan_count"):
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
    return _ok({"dev_point": bucket["dev_point"], "has_reward": "N"})


# 请安(type=1)贡献点由服务端定额发放: 上游抓包为 500, 按需求调整为 1500/日。
QINGAN_DAILY_POINT = 1500


@route(["POST"], "add_devote_point")
def add_devote_point(ctx):
    """师门贡献点获取。

    type=1 请安(每日一次, 贡献点服务端定额, 客户端 point 传 0)
    type=2 每日挑战任务 / 3 飞贼任务 / 4,5 其他(贡献点由客户端上报)
    重复请安返回 errcode=3, 客户端提示"你今天已经请过安了！"。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    devote_type = _as_int(body.get("type"), 0)
    point = _as_int(body.get("point"), 0)
    if devote_type not in (1, 2, 3, 4, 5) or (devote_type != 1 and point <= 0):
        return build_response_body({}, errcode=4, errmsg="类型错误")
    with ctx["state"]._lock:
        bucket = _devote_bucket(ctx, userid)
        if devote_type == 1:
            if _as_int(bucket.get("qingan_count"), 0) >= 1:
                return build_response_body({}, errcode=3, errmsg="今日已请过安")
            point = QINGAN_DAILY_POINT
        remaining = max(DEVOTE_DAILY_LIMIT - bucket["today_point"], 0)
        if remaining <= 0:
            return build_response_body({
                "get_point": 0,
                "dev_point": bucket["dev_point"],
                "msg": "已达到当日贡献点获取上限",
            }, errcode=3, errmsg="已达到当日贡献点获取上限")
        actual_point = min(point, remaining)
        bucket["dev_point"] += actual_point
        bucket["today_point"] += actual_point
        if devote_type == 1:
            bucket["qingan_count"] = _as_int(bucket.get("qingan_count"), 0) + 1
        bucket["updated_at"] = int(time.time())
        ctx["state"]._changed()
        total_point = bucket["dev_point"]
    result = {
        "get_point": actual_point,
        "dev_point": total_point,
        "msg": "获得师门贡献点%s" % actual_point,
    }
    if devote_type == 1:
        result["special_time"] = False
    return _ok(result)


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
    from handlers.challenge_map import challengemap_unfinished as handle
    return handle(ctx)


@route(["GET"], "get_user_anecdote")
def get_user_anecdote(ctx):
    from handlers.challenge_map import get_user_anecdote as handle
    return handle(ctx)


SPRING_FESTIVAL_ACTIONS = [
    {
        "id": 14,
        "activity_id": "qiandao",
        "name": "签到活动",
        "status": 1,
        "is_open": 1,
        "is_show": 1,
        "remain_time": max(1798732799 - int(time.time()), 0),
        "time": "每日",
        "desc": "每日签到，即可获得丰厚奖励，每日必领",
        "gift": "丰厚的奖励",
        "start": "2016-01-20 00:00:00",
        "end": "2026-12-31 23:59:59",
        "sort": "1",
        "rule_desc": [
            "1.每日签到可获得奖励，漏签的天数可以花费20元宝补领，累计签到天数达到指定要求可领取随机面具。",
            "2.双存档共享签到进度。",
            "3.传承保留签到获得的奖励，保留活动进度。",
            "4.重置保留签到获得的元宝，不保留其他奖励，保留活动进度。",
        ],
    },
    {
        "id": 19,
        "activity_id": "chongzhijifenduihuan",
        "name": "充值积分兑换",
        "status": 1,
        "is_open": 1,
        "is_show": 1,
        "remain_time": max(1790783999 - int(time.time()), 0),
        "time": "2026-09-01 00:00:00 至 2026-09-30 23:59:59",
        "desc": "使用充值积分兑换物品",
        "gift": "珍稀道具，武功秘籍等丰厚奖励",
        "start": 1788192000,
        "end": 1790783999,
        "sort": 2,
        "detail_desc": [""],
    },
]


@route(["GET"], "get_spring_festival_list")
def get_spring_festival_list(ctx):
    return _ok([dict(action) for action in SPRING_FESTIVAL_ACTIONS])


@route(["GET"], "get_spring_festival_status")
def get_spring_festival_status(ctx):
    action_id = _as_int((ctx.get("route_tail") or [None])[0], 0)
    action = next(
        (dict(value) for value in SPRING_FESTIVAL_ACTIONS if value["id"] == action_id),
        None,
    )
    if action is None:
        return build_response_body({}, errcode=404, errmsg="activity not found")
    action["start"] = 1453219200
    action["end"] = 1798732799
    action["detail_desc"] = []
    return _ok(action)


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
