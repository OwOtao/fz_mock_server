# -*- coding: utf-8 -*-

import copy
import hashlib
import json
import os
import random
import re
import time
from itertools import chain, product

from handlers.basic import _currency_balance, _set_currency_balance
from handlers.familytype_data import HX_TABLE
from handlers.role_trait_data import TRAIT_NEED, USABLE_TRAIT_IDS
from protocol import build_response_body
from server import route

_GIVE_DAILY_LIMIT = 1
_HOME_OPEN_REWARD_YINPIAO = 1250
_HOUSE_STORE_SIZE = 6
_HOUSE_REFRESH_REPLAY_SECONDS = 3
_HOUSE_PURCHASE_REPLAY_SECONDS = 30
_NPC_STORE_TRANSACTION_LIMIT = 200


# 房契模板源自 familylist.lua["房契模板"]。客户端只消费商店项的 fqId/cost，
# 其余展示字段会按 fqId 从同一张本地表读取；服务端保留户型字段用于购房后建图。
_SPECIAL_HOUSE_TEMPLATES = {
    145: ("huxing005", "高山仰止"),
    146: ("huxing006", "高门大户"),
    148: ("huxing008", "山野逸趣"),
    149: ("huxing009", "一画开天"),
    150: ("huxing010", "清台乐歌"),
    151: ("huxing011", "湖光水色"),
    152: ("huxing012", "阳口悬钟"),
}


def _build_house_templates():
    templates = {}
    for index in list(range(1, 147)) + list(range(148, 154)):
        if index == 1:
            cost, hx_id, level, name = 1500, "huxing001", 0, "普通房屋"
        elif index <= 3:
            cost, hx_id, level, name = 6000, "huxing002", 1, "简屋"
        elif index <= 15:
            cost = 6000
            hx_id = "huxing003" if index <= 7 else "huxing004"
            level = 2 if index <= 7 else 3
            name = "秀筑" if index <= 7 else "豪宅"
        elif index <= 85:
            cost, hx_id, level, name = 16000, "huxing003", 2, "秀筑"
        elif index <= 144 or index == 153:
            cost, hx_id, level, name = 32000, "huxing004", 3, "豪宅"
        else:
            hx_id, name = _SPECIAL_HOUSE_TEMPLATES[index]
            cost, level = 50000, 4
        templates["yangzhou%03d" % index] = {
            "fqId": "yangzhou%03d" % index,
            "cost": cost,
            "hxId": hx_id,
            "level": level,
            "name": name,
            "roomnum": len(HX_TABLE[hx_id]["rooms"]),
        }
    return templates


_HOUSE_TEMPLATES = _build_house_templates()

# 四个公共家园城的购房 NPC，及特殊扬州房商。001 房商出售入门/中档房，
# 002 房商出售豪宅/特殊户型，正好覆盖 familylist.lua 的全部 152 张房契。
_HOUSE_SELLERS = {
    "yangzhou001": {"mapId": "fb10", "location": "扬州城", "tier": "basic"},
    "yangzhou002": {"mapId": "fb10", "location": "扬州城", "tier": "premium"},
    "yzmfnpc": {"mapId": "fb10", "location": "扬州城", "tier": "all"},
    "suzhou001": {"mapId": "fb15", "location": "苏州城", "tier": "basic"},
    "suzhou002": {"mapId": "fb15", "location": "苏州城", "tier": "premium"},
    "xiangyang001": {"mapId": "fb20", "location": "襄阳城", "tier": "basic"},
    "xiangyang002": {"mapId": "fb20", "location": "襄阳城", "tier": "premium"},
    "changan001": {"mapId": "fb25", "location": "长安城", "tier": "basic"},
    "changan002": {"mapId": "fb25", "location": "长安城", "tier": "premium"},
}


def _priced_series(prefix, prices):
    """Build the immutable (item id, price) rows used by NPC furniture stores."""
    return tuple(
        ("%s%03d" % (prefix, index), price)
        for index, price in enumerate(prices, 1)
    )


# Prices and grade ordering come from familylist.lua["家具"].  Keeping this
# compact table in the server avoids parsing the 1 MB Lua resource per request.
_FURNITURE_TABLES = _priced_series("zhuozi", (
    200, 240, 250, 300, 280, 360, 400, 420, 430, 450, 640, 680, 750, 800,
))
_FURNITURE_CHAIRS = _priced_series("yizi", (
    150, 100, 120, 160, 90, 110, 200, 240, 320, 340, 720, 750, 800, 850,
))
_FURNITURE_MIRRORS = _priced_series("jingtai", (
    180, 160, 240, 270, 180, 250, 300, 360, 320, 380, 540, 600, 680, 720,
))
_FURNITURE_SCREENS = _priced_series("pingfeng", (
    120, 130, 150, 100, 160, 200, 230, 250, 320, 400, 840, 920, 1000, 1200,
))
_FURNITURE_CABINETS = _priced_series("guizi", (
    140, 180, 170, 220, 230, 250, 270, 280, 300, 320, 720, 740, 800, 850,
))
_FURNITURE_PAINTINGS = _priced_series("zihua", (
    150, 240, 250, 260, 280, 290,
    1000, 1100, 1200, 1350, 1080, 1250, 1300, 1100, 1300, 1080, 1180,
    1250, 1400, 1500,
    5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 5000,
    1200, 1200, 1500, 1500, 1500, 1500,
))
_FURNITURE_STATUES = _priced_series("diaoxiang", (
    90, 120, 270, 240, 220, 300, 330, 400, 350, 370, 750, 780,
))
_FURNITURE_WEAPONS = _priced_series("bingqi", (
    360, 380, 320, 450, 360, 330, 750, 800, 850, 900, 2200, 3000,
))
_FURNITURE_TREASURES = _priced_series("zhenbao", (
    240, 400, 600, 1000, 1200, 1300, 1500, 2400, 2600, 2700, 3500,
    3600, 6000, 6800, 7500, 8000, 9000,
))
_FURNITURE_BEDS = _priced_series("chuang", (
    1600, 1800, 1800, 1800, 1500, 2000, 2700, 2700, 3100, 3500, 4500,
    4800, 8100, 8400,
))
_FURNITURE_DESKS = _priced_series("shuan", (
    150, 160, 180, 170, 160, 340, 360, 380, 420, 900, 950, 1080, 1200, 1400,
))
_FURNITURE_MEDICINE_FURNACES = _priced_series("yaolu", (
    1000, 1200, 1400, 2000, 2100, 2300, 2700, 2900, 5000, 5400, 7200, 8000,
))
_FURNITURE_MATS = _priced_series("putuan", (
    400, 450, 550, 640, 780, 850, 2200, 2600, 3200, 3600, 5600, 6000,
))
_FURNITURE_SMELTERS = _priced_series("ronglianlu", (
    1000, 1200, 1500, 1800, 1900, 3600, 4200, 4800, 5600, 9800, 11000, 12000,
))
_FURNITURE_BUILDINGS = tuple((item_id, 5000) for item_id in (
    "cangku001", "tudi01", "bagwooden001", "mapwooden001", "wooden001",
    "zhaotai001", "door001", "shipingxiang001", "caan001", "jing001",
    "desk001", "tingyuan001", "duanzaolu001", "qiangbi001", "yigui001",
    "jtai001", "shugui001", "xianglu001",
))

_GENERIC_FURNITURE = (
    _FURNITURE_TABLES,
    _FURNITURE_CHAIRS,
    _FURNITURE_MIRRORS,
    _FURNITURE_SCREENS,
    _FURNITURE_CABINETS,
)

# 004/005/006 follow the grade blocks shared by each normal furniture family:
# six grade-0 rows, four grade-1 rows, and four grade-2/3 rows.  The remaining
# sellers have explicit specialties described by their map NPC dialogue.
_FURNITURE_STOCK_BY_SUFFIX = {
    "004": tuple(row for family in _GENERIC_FURNITURE for row in family[:6]),
    "005": tuple(row for family in _GENERIC_FURNITURE for row in family[6:10]),
    "006": tuple(row for family in _GENERIC_FURNITURE for row in family[10:]),
    "007": _FURNITURE_PAINTINGS,
    "008": _FURNITURE_STATUES + _FURNITURE_TREASURES,
    "009": _FURNITURE_WEAPONS,
    "010": (
        _FURNITURE_BEDS
        + _FURNITURE_DESKS
        + _FURNITURE_MEDICINE_FURNACES
        + _FURNITURE_MATS
        + _FURNITURE_SMELTERS
        + _FURNITURE_BUILDINGS
    ),
}
_FURNITURE_STORE_CITY_PREFIXES = ("yangzhou", "suzhou", "xiangyang", "changan")

_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_FURNITURE_ITEMS_PATH = os.path.join(_ROOT, "item_json", "homeland.json")
_FURNITURE_CONFIG_PATH = os.path.join(
    _ROOT, "fzjh_lua", "assets", "res", "script", "others", "familylist.lua"
)
_FURNITURE_METADATA = None


def _load_furniture_metadata():
    """Load the client furniture ids without parsing the 1 MB Lua table.

    The response contract needs the numeric ``itype`` used by
    ``FurnitureModel:addFurTypeCount``. Those values only exist in
    familylist.lua, whose relevant fields have a stable ASCII shape even in
    older, mojibake resource dumps.
    """
    global _FURNITURE_METADATA
    if _FURNITURE_METADATA is not None:
        return _FURNITURE_METADATA

    names = {}
    try:
        with open(_FURNITURE_ITEMS_PATH, "r", encoding="utf-8") as handle:
            items = json.load(handle)
        if isinstance(items, dict):
            names = {
                str(item_id): str((value or {}).get("name") or item_id)
                for item_id, value in items.items()
                if isinstance(value, dict)
            }
    except (OSError, ValueError, TypeError):
        names = {}

    metadata = {}
    try:
        with open(_FURNITURE_CONFIG_PATH, "r", encoding="utf-8", errors="ignore") as handle:
            raw = handle.read()
        type_rows = list(re.finditer(
            r'\["itype"\]=(\d+),\["jjId"\]=\[\[([^\]]+)\]\]', raw
        ))
        for index, match in enumerate(type_rows):
            itype, item_id = match.groups()
            end = type_rows[index + 1].start() if index + 1 < len(type_rows) else len(raw)
            special_match = re.search(
                r'\["special"\]=\[\[([NY])\]\]', raw[match.end():end]
            )
            is_special = bool(special_match and special_match.group(1) == "Y")
            metadata[item_id] = {
                "itype": int(itype),
                "name": names.get(item_id, item_id),
                "special": 1 if is_special else 0,
            }
    except OSError:
        pass

    _FURNITURE_METADATA = metadata
    return _FURNITURE_METADATA


# 房间方向链接字段, 与真实服务端 get_user_map.maproom 一致(缺省用空串而非缺键)
_ROOM_LINK_KEYS = ("up", "down", "left", "right", "leftUp", "rightUp",
                   "leftDown", "rightDown")


def _normalize_room(room, mid, rid_base):
    """补齐客户端移动/渲染所需的全部房间字段。

    关键: stepMusic 必填, 否则 MapLayer:playStepSound 断言
    `fromSound and toSound` 失败, 玩家每次移动都会崩溃(表现为只能看到入口几格)。
    对齐真实服务端响应: 缺失的方向链接用空串 "" 表示。
    """
    out = copy.deepcopy(room) if isinstance(room, dict) else {}
    out.setdefault("fjId", "")
    out.setdefault("name", "")
    out.setdefault("desc", out.get("name", ""))
    out.setdefault("roomType", "")
    out.setdefault("mapHide", 0)
    for key in _ROOM_LINK_KEYS:
        out.setdefault(key, "")
    out.setdefault("rid", rid_base)
    out.setdefault("mid", mid)
    out.setdefault("permission", 1)
    out.setdefault("enterable", 1)
    out.setdefault("visible", 1)
    out.setdefault("BgmDown", 1)
    out.setdefault("roomBgm", "")
    out.setdefault("roomBgmRule", 0)
    out.setdefault("spaceTime", 0)
    # 脚步声资源, 缺失会导致移动崩溃
    out.setdefault("stepMusic", "jiaobu")
    out.setdefault("extra", "")
    return out


DEFAULT_HX_ID = "huxing002"

DEFAULT_HOUSE = {
    "fqId": "yangzhou002",
    "houseName": "普通房屋",
    "id": "fq100",
    "isDispose": True,
    "isRename": False,
    "location": "扬州城外西郊杏花村2号",
    "mapId": "fb10",
    "mid": 14750,
    "name": "HIY简屋(壹)NOR",
    "hxId": DEFAULT_HX_ID,
    "roomnum": 9,
    "status": 1,
    "type": "房契",
}

DEFAULT_STEWARD_ID = "guanjia1001"
DEFAULT_STEWARD = {
    "objId": DEFAULT_STEWARD_ID,
    "rwId": DEFAULT_STEWARD_ID,
    "job": "guanjia001",
    "jobType": "guanjia001",
    "name": "权令枫",
    "sex": "男",
    "age": 50,
    "looks": 20,
    "defaultZhongCheng": 691,
    "speedZhongCheng": 10,
    "factor": "",
    "trait1": "texing001",
    "trait2": "texing013",
    "trait3": "",
    "character": "xingge004",
    "flag": 0,
    "modal": "moban010",
    "leave_day": 0,
    "traitVal": 0,
    "shenShi": "",
    "mobanSkill": {
        "hanbingguizhua": 290,
        "jibenbianfa": 290,
        "jibendaofa": 290,
        "jibengunfa": 290,
        "jibenjianfa": 290,
        "jibenneigong": 290,
        "jibenqinggong": 290,
        "jibenquanjiao": 290,
        "jibenzhaojia": 290,
        "taijiquan": 290,
    },
    "extra": {
        "naoshi": 0,
        "shenshi_status": 0,
    },
}

# 全部户型 mapAppearance / mapAppearanceIndex / 房间图原样抠自
# familytype.lua ["户型总览"] 与 ["huxing00N"], 见 handlers/familytype_data.py。
DEFAULT_ROOMS = HX_TABLE[DEFAULT_HX_ID]["rooms"]
HX_MAP_APPEARANCE = HX_TABLE[DEFAULT_HX_ID]["mapAppearance"]
HX_MAP_APPEARANCE_INDEX = HX_TABLE[DEFAULT_HX_ID]["mapAppearanceIndex"]
HX_ENTRY_ROOM = HX_TABLE[DEFAULT_HX_ID]["entryRoom"]
_HX_ROOM_PREFIX = HX_TABLE[DEFAULT_HX_ID]["roomPrefix"]


def _hx_spec(hx_id):
    hx_id = str(hx_id or "") or DEFAULT_HX_ID
    return HX_TABLE.get(hx_id) or HX_TABLE[DEFAULT_HX_ID]


def _default_employee_fjid(spec):
    for room in spec.get("rooms") or []:
        if isinstance(room, dict) and room.get("name") == "卧室":
            return str(room.get("fjId") or "")
    return str(spec.get("entryRoom") or "")


def _is_steward(employee):
    if not isinstance(employee, dict):
        return False
    job = str(employee.get("job") or employee.get("jobType") or "")
    rw_id = str(employee.get("rwId") or employee.get("objId") or "")
    return job == "guanjia001" or rw_id == DEFAULT_STEWARD_ID


def _has_steward(bucket):
    employees = bucket.get("employees") if isinstance(bucket, dict) else None
    if not isinstance(employees, dict):
        return False
    return any(_is_steward(value) for value in employees.values())


def _seed_default_steward(bucket, spec):
    """已处理初始管家(isDispose)但未雇佣时, 客户端不会 createInitialGuanJia。
    此时必须在 roomperson 下发 rwId=guanjia1001, 否则地图上没有管家、呼唤管家也找不到。
    """
    employees = bucket.setdefault("employees", {})
    if not isinstance(employees, dict):
        employees = {}
        bucket["employees"] = employees
    if _has_steward(bucket):
        return False
    steward = copy.deepcopy(DEFAULT_STEWARD)
    steward["fjId"] = _default_employee_fjid(spec)
    steward["mid"] = _int((bucket.get("house") or {}).get("mid"), 0)
    employees[DEFAULT_STEWARD_ID] = steward
    return True


def _ensure_layout(bucket):
    """按 house.hxId 对齐官方户型; 房间前缀对不上则重置为该户型布局。"""
    house = bucket.setdefault("house", {})
    if not isinstance(house, dict):
        house = {}
        bucket["house"] = house
    hx_id = str(house.get("hxId") or "") or DEFAULT_HX_ID
    spec = _hx_spec(hx_id)
    house["hxId"] = spec["hxId"]
    prefix = spec["roomPrefix"]
    rooms = bucket.get("rooms")
    stale = not rooms or any(
        not isinstance(room, dict)
        or not str(room.get("fjId", "")).startswith(prefix)
        for room in rooms
    )
    changed = False
    if stale:
        bucket["rooms"] = copy.deepcopy(spec["rooms"])
        default_fj = _default_employee_fjid(spec)
        for employee in (bucket.get("employees") or {}).values():
            if isinstance(employee, dict) and not str(employee.get("fjId", "")).startswith(prefix):
                employee["fjId"] = default_fj
        changed = True
    # 新购房契由客户端走初始管家流程；只有已经处理过该流程的旧档案缺管家时补种。
    if house.get("isDispose") and _seed_default_steward(bucket, spec):
        changed = True
    if changed:
        bucket["updated_at"] = int(time.time())
    return spec, changed


def _userid(ctx):
    try:
        return int(ctx.get("headers", {}).get("userid") or 0)
    except (TypeError, ValueError):
        return 0


def _body(ctx):
    value = ctx.get("body")
    return value if isinstance(value, dict) else {}


def _int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


def _role_name(ctx, userid):
    role = ctx["state"].get_archive(userid) or {}
    return str(role.get("name") or "玩家")


def _seed_house(ctx, userid):
    state = ctx["state"]
    role = state.get_archive(userid) or {}
    homeland = role.get("Homeland") if isinstance(role, dict) else {}
    house = homeland.get("fq") if isinstance(homeland, dict) else None
    if not isinstance(house, dict) or not house.get("mid"):
        house = copy.deepcopy(DEFAULT_HOUSE)
    else:
        house = copy.deepcopy(house)
        for key, value in DEFAULT_HOUSE.items():
            house.setdefault(key, copy.deepcopy(value))
    house["mid"] = _int(house.get("mid"), DEFAULT_HOUSE["mid"])
    return house


def _allocate_mid(root, userid, preferred=0):
    """Claim a stable, unique homeland map id."""
    def owner_of(mid):
        owner = _int(root["mid_owners"].get(str(mid)), 0)
        if owner > 0:
            return owner
        for key, bucket in root["users"].items():
            house = bucket.get("house") if isinstance(bucket, dict) else None
            if isinstance(house, dict) and _int(house.get("mid"), 0) == mid:
                return _int(key, 0)
        return 0

    preferred = _int(preferred, 0)
    owners = root["mid_owners"]
    if preferred > 0:
        owner = owner_of(preferred)
        if owner in (0, userid):
            owners[str(preferred)] = userid
            root["next_mid"] = max(_int(root.get("next_mid"), 14751), preferred + 1)
            return preferred

    candidate = max(_int(root.get("next_mid"), 14751), 1)
    while owner_of(candidate) not in (0, userid):
        candidate += 1
    owners[str(candidate)] = userid
    root["next_mid"] = candidate + 1
    return candidate


def _seller_pool(npc_id):
    seller = _HOUSE_SELLERS.get(npc_id)
    if seller is None:
        return []
    if seller["tier"] == "basic":
        return [value for value in _HOUSE_TEMPLATES.values() if value["cost"] <= 16000]
    if seller["tier"] == "premium":
        return [value for value in _HOUSE_TEMPLATES.values() if value["cost"] >= 32000]
    return list(_HOUSE_TEMPLATES.values())


def _furniture_catalog(npc_id):
    npc_id = str(npc_id or "").strip()
    for prefix in _FURNITURE_STORE_CITY_PREFIXES:
        if not npc_id.startswith(prefix):
            continue
        suffix = npc_id[len(prefix):]
        return _FURNITURE_STOCK_BY_SUFFIX.get(suffix, ())
    return ()


def _house_offers(userid, npc_id, day, refresh_round):
    pool = _seller_pool(npc_id)
    if not pool:
        return []
    chosen = []
    # 引导使用 yangzhou001；始终保留最便宜房契，避免随机列表阻断新手流程。
    if _HOUSE_SELLERS[npc_id]["tier"] == "basic":
        chosen.append(_HOUSE_TEMPLATES["yangzhou001"])
    seed = "%s:%s:%s:%s" % (userid, npc_id, day, refresh_round)
    counter = 0
    while len(chosen) < min(_HOUSE_STORE_SIZE, len(pool)):
        digest = hashlib.sha256((seed + ":" + str(counter)).encode("utf-8")).digest()
        candidate = pool[int.from_bytes(digest[:8], "big") % len(pool)]
        if candidate["fqId"] not in {value["fqId"] for value in chosen}:
            chosen.append(candidate)
        counter += 1
    return [{"fqId": value["fqId"], "cost": value["cost"]} for value in chosen]


def _archive_house(state, userid):
    archive = state.get_archive(userid)
    homeland = archive.get("Homeland") if isinstance(archive, dict) else None
    house = homeland.get("fq") if isinstance(homeland, dict) else None
    if isinstance(house, dict) and house.get("fqId") and _int(house.get("mid"), 0) > 0:
        return copy.deepcopy(house)
    return None


def _sync_house_archive(state, userid, house, yinpiao):
    """Keep the downloaded RoleData consistent with server homeland/currency state."""
    archive = state.get_archive(userid)
    if not isinstance(archive, dict):
        return None
    archive["yinpiao"] = max(_int(yinpiao), 0)
    homeland = archive.get("Homeland")
    if not isinstance(homeland, dict):
        homeland = {}
        archive["Homeland"] = homeland
    homeland["fq"] = copy.deepcopy(house)

    items = archive.get("items")
    if not isinstance(items, list):
        items = []
        archive["items"] = items
    contract = next(
        (item for item in items if isinstance(item, dict) and item.get("itemId") == "fq100"),
        None,
    )
    if contract is None:
        next_id = max(
            [_int(item.get("id"), 0) for item in items if isinstance(item, dict)] or [0]
        ) + 1
        items.append({"id": next_id, "itemId": "fq100", "count": 1})
    else:
        contract["count"] = max(_int(contract.get("count"), 0), 1)
    return state.put_archive(userid, archive)


def _sync_npc_purchase_archive(state, userid, item_id, money):
    """Persist a furniture purchase alongside the local client inventory update."""
    archive = state.get_archive(userid)
    if not isinstance(archive, dict):
        return None
    archive["money"] = max(_int(money), 0)
    items = archive.get("items")
    if not isinstance(items, list):
        items = []
        archive["items"] = items
    item = next(
        (value for value in items
         if isinstance(value, dict) and value.get("itemId") == item_id),
        None,
    )
    if item is None:
        next_id = max(
            [_int(value.get("id"), 0) for value in items if isinstance(value, dict)]
            or [0]
        ) + 1
        items.append({"id": next_id, "itemId": item_id, "count": 1})
    else:
        item["count"] = max(_int(item.get("count"), 0), 0) + 1
    return state.put_archive(userid, archive)


def _user_bucket(ctx, userid, create=True):
    state = ctx["state"]
    with state._lock:
        root = state._normalize_homeland(state._state)
        key = str(userid)
        bucket = root["users"].get(key)
        if not isinstance(bucket, dict):
            if not create:
                return None
            house = _seed_house(ctx, userid)
            house["mid"] = _allocate_mid(root, userid, house.get("mid"))
            mid = str(house["mid"])
            bucket = {
                "house": house,
                "lands": {},
                "rooms": copy.deepcopy(DEFAULT_ROOMS),
                "employees": {},
                "employee_lists": {},
                "dispatch": {},
                "furniture": [],
                "version": 1,
                "updated_at": int(time.time()),
            }
            root["users"][key] = bucket
            root["mid_owners"][mid] = userid
            state._changed()
        _spec, changed = _ensure_layout(bucket)
        if changed:
            state._changed()
        _ensure_village_addresses(state, userid)
        return bucket


def _owned_bucket(ctx, userid, mid=None, create=True):
    bucket = _user_bucket(ctx, userid, create=create)
    if bucket is None:
        return None, "homeland not found"
    if mid not in (None, "", 0):
        expected = _int(mid, -1)
        actual = _int((bucket.get("house") or {}).get("mid"), -2)
        if expected != actual:
            return None, "homeland not owned"
    return bucket, ""


def _employee_payload(employee, default_fjid=None):
    value = copy.deepcopy(employee)
    value.setdefault("rwId", value.get("objId"))
    value.setdefault("objId", value.get("rwId"))
    value.setdefault("fjId", default_fjid or HX_ENTRY_ROOM)
    value.setdefault("job", value.get("jobType", "puren001"))
    value.setdefault("jobType", value.get("job", "puren001"))
    value.setdefault("modal", "moban001")
    value.setdefault("name", "小四")
    value.setdefault("sex", "男")
    value.setdefault("age", 0)
    value.setdefault("looks", 0)
    value.setdefault("defaultZhongCheng", 500)
    value.setdefault("speedZhongCheng", 0)
    value.setdefault("extra", {})
    if not isinstance(value["extra"], dict):
        value["extra"] = {}
    value.setdefault("state", 1)
    return value


def _homeland_version(bucket):
    value = str(bucket.get("version") or "1")
    if len(value) < 16:
        value = hashlib.md5(value.encode("utf-8")).hexdigest()
    return value


def _location_mark(value):
    """The client sends three 1-based indices, not a village template id."""
    if not isinstance(value, list) or len(value) != 3:
        return None
    if any(isinstance(v, bool) or not isinstance(v, (int, str)) for v in value):
        return None
    mark = [_int(v, 0) for v in value]
    return mark if all(1 <= v <= limit for v, limit in zip(mark, (16, 20, 26))) else None


def _ensure_village_addresses(state, preferred_userid=None):
    """Migrate village addresses under the state lock, reserving existing plots first.

    fb206-fb209 each have flag1 plots 1..14 (not 1..20). Legacy maps
    advertised [2, 2, 20]/2 without saving it; try that address first.
    Prioritize the caller among legacy houses so an already-open map can exit.
    """
    with state.defer_saves():
        root = state._normalize_homeland(state._state)
        occupied, pending = set(), []
        for key, bucket in sorted(root["users"].items()):
            house = bucket.get("house") if isinstance(bucket, dict) else None
            if not isinstance(house, dict) or _int(house.get("mid"), 0) <= 0:
                continue
            if str(house.get("dpId") or "").strip():
                continue
            mark = _location_mark(house.get("loc_mark"))
            slot = _int(house.get("loc_sort"), 0)
            address = tuple(mark or []) + (slot,)
            valid = mark is not None and 1 <= slot <= 14 and address not in occupied
            if valid:
                occupied.add(address)
            if not valid or house.get("loc_mark") != mark or type(house.get("loc_sort")) is not int:
                pending.append((key, bucket, mark, slot, valid))

        pending.sort(key=lambda row: (row[0] != str(preferred_userid), row[0]))
        for key, bucket, mark, slot, valid in pending:
            house = bucket["house"]
            if not valid:
                preferred_mark = mark or [2, 2, 20]
                preferred_slot = slot if 1 <= slot <= 14 else 2
                marks = chain([tuple(preferred_mark)], product(range(1, 17), range(1, 21), range(1, 27)))
                slots = [preferred_slot] + [n for n in range(1, 15) if n != preferred_slot]
                address = next(
                    m + (n,) for m in marks for n in slots if m + (n,) not in occupied
                )
                mark, slot = list(address[:3]), address[3]
                occupied.add(address)
            house["loc_mark"], house["loc_sort"] = mark, slot
            bucket["updated_at"] = int(time.time())
            # Update only address fields in the contract, without touching money/items.
            archive = state.get_archive(_int(key))
            homeland = archive.get("Homeland") if isinstance(archive, dict) else None
            contract = homeland.get("fq") if isinstance(homeland, dict) else None
            if isinstance(contract, dict) and _int(contract.get("mid")) == _int(house.get("mid")):
                contract["loc_mark"], contract["loc_sort"] = list(mark), slot
                state.put_archive(_int(key), archive)
            state._changed()


def _map_data(ctx, userid, bucket):
    spec, stale = _ensure_layout(bucket)
    if stale:
        with ctx["state"]._lock:
            ctx["state"]._changed()
    house = bucket["house"]
    mid = _int(house.get("mid"), 0)
    rooms = copy.deepcopy(bucket.get("rooms") or spec["rooms"])
    # 补齐客户端移动/渲染所需的全部房间字段(含 stepMusic)
    rooms = [_normalize_room(room, mid, 690000 + i)
             for i, room in enumerate(rooms)]
    employees = []
    now = int(time.time())
    default_fj = _default_employee_fjid(spec)
    for value in bucket.get("employees", {}).values():
        employee = _employee_payload(value, default_fj)
        stay_until = _int(employee.get("extra", {}).get("stay_room_time"), 0)
        if stay_until > now:
            continue
        employees.append(employee)
    # 屋外跳转定位: 客户端 HomelandRoomUtil:outDoorByNoDp 依赖 usermap.loc_mark / loc_sort。
    # 真实服务端下发 3 元素数组 {cityIdx, cityDirIdx, villageIdx}:
    #   loc_mark[1] -> UserMapRelation:getFbIdByCityDir  (扬州西郊=2 -> fb10)
    #   loc_mark[3] -> UserMapRelation:getVillageFbId    (杏花村=20 -> fb209)
    # loc_sort 必须是目标村庄副本(fb209)房间配置里存在的 flag1 值,
    # 客户端用它反查 room.dpRoomId。缺失这两个字段会导致
    # `map.loc_mark[3]` 触发 "attempt to index a nil value" 崩溃。
    loc_mark = house.get("loc_mark") or [2, 2, 20]
    loc_sort = _int(house.get("loc_sort"), 2)
    # ver 必须是字符串(真实服务端下发 md5), 客户端直接存入 sCk_ver.homeland
    ver = _homeland_version(bucket)
    return {
        "ver": ver,
        "owner": _role_name(ctx, userid),
        "usermap": {
            "mid": mid,
            "fbId": "",
            "hxId": spec["hxId"],
            "location": house.get("location") or "",
            "fqId": house.get("fqId") or "yangzhou002",
            "dpId": house.get("dpId") or "",
            "uid": userid,
            "name": house.get("name") or house.get("houseName") or "家园",
            "desc": house.get("desc") or "",
            "entryRoom": spec["entryRoom"],
            "BGM": spec.get("BGM") or "bgm001",
            "mapAppearance": spec["mapAppearance"],
            "mapAppearanceIndex": spec["mapAppearanceIndex"],
            "extra": copy.deepcopy(house.get("extra") or {}),
            "isChangeName": "N",
            "loc_mark": loc_mark,
            "loc_sort": loc_sort,
            "isbind": "N",
            "dirMark": 0,
            "payTime": 0,
            "affair_count": 0,
        },
        "maproom": rooms,
        "roomperson": employees,
        "roomfurniture": copy.deepcopy(bucket.get("furniture") or []),
    }


def _archive_furniture_item(archive, item_id):
    items = archive.get("items") if isinstance(archive, dict) else None
    if not isinstance(items, list):
        return None, None
    for index, item in enumerate(items):
        if (
            isinstance(item, dict)
            and str(item.get("itemId") or "") == item_id
            and _int(item.get("count"), 0) > 0
        ):
            return items, index
    return items, None


def _take_archive_furniture(state, userid, item_id):
    """Remove one placed furniture item from the persisted RoleData."""
    archive = state.get_archive(userid)
    items, index = _archive_furniture_item(archive, item_id)
    if index is None:
        return None
    item = items[index]
    count = _int(item.get("count"), 0)
    if count <= 1:
        items.pop(index)
    else:
        item["count"] = count - 1
    return state.put_archive(userid, archive)


@route(["GET", "POST"], "get_home_switch")
def get_home_switch(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")

    state = ctx["state"]
    reward = 0
    with state.defer_saves():
        state.ensure_account(userid)
        root = state._normalize_homeland(state._state)
        key = str(userid)
        record = root["home_switch"].get(key)
        if not isinstance(record, dict):
            # 升级前已经持有房契的旧档视为领过引导奖励，避免迁移后重复发放。
            reward = 0 if _archive_house(state, userid) else _HOME_OPEN_REWARD_YINPIAO
            if reward:
                balance = _currency_balance(ctx, userid, "yinpiao")
                _set_currency_balance(ctx, userid, "yinpiao", balance + reward)
            root["home_switch"][key] = {
                "opened_at": int(time.time()),
                "reward": reward,
            }
            state._changed()
    # yinpiao 是本次实际发放数，不是余额；重试必须返回 0，避免客户端重复提示。
    return build_response_body({"open": True, "yinpiao": reward})


@route(["POST"], "get_house_store_list")
def get_house_store_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    npc_id = str(body.get("npcId") or "").strip()
    if npc_id not in _HOUSE_SELLERS:
        return build_response_body({}, errcode=404, errmsg="house seller not found")
    is_refresh = str(body.get("is_refresh") or "N").strip().upper()
    if is_refresh not in ("Y", "N"):
        return build_response_body({}, errcode=400, errmsg="invalid refresh flag")

    state = ctx["state"]
    now = int(time.time())
    day = time.strftime("%Y-%m-%d", time.localtime(now))
    remove_yb = 0
    with state._lock:
        root = state._normalize_homeland(state._state)
        user_stores = root["house_stores"].setdefault(str(userid), {})
        entry = user_stores.get(npc_id)
        if not isinstance(entry, dict) or entry.get("day") != day:
            entry = {"day": day, "refresh_round": 0, "last_refresh_at": 0}
            user_stores[npc_id] = entry
        if (
            is_refresh == "Y"
            and now - _int(entry.get("last_refresh_at"), 0)
            >= _HOUSE_REFRESH_REPLAY_SECONDS
        ):
            entry["refresh_round"] = max(_int(entry.get("refresh_round"), 0), 0) + 1
            entry["last_refresh_at"] = now
        offers = _house_offers(userid, npc_id, day, entry.get("refresh_round", 0))
        entry["offers"] = [value["fqId"] for value in offers]
        entry["updated_at"] = now
        bucket = root["users"].get(str(userid))
        state_house = bucket.get("house") if isinstance(bucket, dict) else None
        is_buy = bool(
            isinstance(state_house, dict)
            and state_house.get("fqId")
            and _int(state_house.get("mid"), 0) > 0
        )
        if not is_buy:
            is_buy = _archive_house(state, userid) is not None
        state._changed()

    return build_response_body({
        "list": offers,
        "isBuy": is_buy,
        "point": _currency_balance(ctx, userid, "yinpiao"),
        # 当前版本免费刷新；仍返回客户端固定读取的两个元宝字段。
        "costYb": 0,
        "removeYb": remove_yb,
    })


@route(["GET"], "get_npc_store_list")
def get_npc_store_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    tail = ctx.get("route_tail") or []
    npc_id = str(tail[0] or "").strip() if len(tail) == 1 else ""
    catalog = _furniture_catalog(npc_id)
    if not catalog:
        return build_response_body({}, errcode=404, errmsg="furniture seller not found")
    return build_response_body({
        "list": [
            {"itemId": item_id, "price": price, "unit": "money"}
            for item_id, price in catalog
        ],
        "point": _currency_balance(ctx, userid, "money"),
        "unit": "money",
    })


@route(["POST"], "buy_npc_goods")
def buy_npc_goods(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    npc_id = str(body.get("npc_id") or "").strip()
    item_id = str(body.get("itemId") or "").strip()
    trans_id = str(body.get("client_trans_id") or "").strip()
    catalog = dict(_furniture_catalog(npc_id))
    if not catalog:
        return build_response_body({}, errcode=404, errmsg="furniture seller not found")
    if item_id not in catalog:
        return build_response_body({}, errcode=404, errmsg="item not sold by this seller")
    if not trans_id:
        return build_response_body({}, errcode=400, errmsg="client_trans_id required")
    coupons_id = str(body.get("couponsId") or "").strip()
    if coupons_id and coupons_id != "0":
        return build_response_body({}, errcode=400, errmsg="coupon not supported by this seller")

    state = ctx["state"]
    now = int(time.time())
    price = max(_int(catalog[item_id]), 0)
    with state.defer_saves():
        state.ensure_account(userid)
        account = state._state["accounts"].setdefault(str(userid), {"userid": userid})
        transactions = account.get("npc_store_transactions")
        if not isinstance(transactions, dict):
            transactions = {}
            account["npc_store_transactions"] = transactions
        receipt = transactions.get(trans_id)
        if isinstance(receipt, dict):
            if receipt.get("npc_id") == npc_id and receipt.get("itemId") == item_id:
                data = receipt.get("data")
                if isinstance(data, dict):
                    return build_response_body(copy.deepcopy(data))
            return build_response_body({}, errcode=409, errmsg="transaction id conflict")

        balance = _currency_balance(ctx, userid, "money")
        if balance < price:
            return build_response_body(
                {"point": balance, "cost": price, "unit": "money"},
                errcode=1,
                errmsg="\u788e\u94f6\u4e0d\u8db3",
            )

        new_balance = balance - price
        currencies = account.get("currencies")
        if not isinstance(currencies, dict):
            currencies = {}
            account["currencies"] = currencies
        currencies["money"] = new_balance
        account["updated_at"] = now
        saved_archive = _sync_npc_purchase_archive(
            state, userid, item_id, new_balance
        )
        data = {
            "itemId": item_id,
            "remove_point": price,
            "point": new_balance,
            "unit": "money",
        }
        if isinstance(saved_archive, dict) and "dataVer" in saved_archive:
            data["dataVer"] = _int(saved_archive.get("dataVer"), 0)
        transactions[trans_id] = {
            "npc_id": npc_id,
            "itemId": item_id,
            "created_at": now,
            "data": copy.deepcopy(data),
        }
        if len(transactions) > _NPC_STORE_TRANSACTION_LIMIT:
            ordered = sorted(
                transactions,
                key=lambda key: _int((transactions.get(key) or {}).get("created_at"), 0),
            )
            for old_trans_id in ordered[:-_NPC_STORE_TRANSACTION_LIMIT]:
                transactions.pop(old_trans_id, None)
        state._changed()
        return build_response_body(data)


@route(["POST"], "buy_homeland")
def buy_homeland(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    npc_id = str(body.get("npcId") or "").strip()
    fq_id = str(body.get("fqId") or "").strip()
    seller = _HOUSE_SELLERS.get(npc_id)
    template = _HOUSE_TEMPLATES.get(fq_id)
    allowed_ids = {value["fqId"] for value in _seller_pool(npc_id)}
    if seller is None:
        return build_response_body({}, errcode=404, errmsg="house seller not found")
    if template is None or fq_id not in allowed_ids:
        return build_response_body({}, errcode=404, errmsg="house contract not sold here")

    state = ctx["state"]
    now = int(time.time())
    with state.defer_saves():
        root = state._normalize_homeland(state._state)
        receipt = root["purchase_receipts"].get(str(userid))
        if (
            isinstance(receipt, dict)
            and receipt.get("npcId") == npc_id
            and receipt.get("fqId") == fq_id
            and now - _int(receipt.get("created_at"), 0) < _HOUSE_PURCHASE_REPLAY_SECONDS
            and isinstance(receipt.get("data"), dict)
        ):
            return build_response_body(copy.deepcopy(receipt["data"]))

        balance = _currency_balance(ctx, userid, "yinpiao")
        cost = max(_int(template.get("cost"), 0), 0)
        if balance < cost:
            return build_response_body(
                {"point": balance, "cost": cost},
                errcode=1,
                errmsg="银票不足",
            )

        state.ensure_account(userid)
        key = str(userid)
        bucket = root["users"].get(key)
        if not isinstance(bucket, dict):
            bucket = {
                "house": {},
                "lands": {},
                "rooms": [],
                "employees": {},
                "employee_lists": {},
                "dispatch": {},
                "furniture": [],
                "version": 0,
            }
            root["users"][key] = bucket
        old_house = bucket.get("house")
        if not isinstance(old_house, dict) or not old_house:
            old_house = _archive_house(state, userid) or {}

        mid = _allocate_mid(root, userid, old_house.get("mid"))
        placed = bool(str(old_house.get("dpId") or "").strip())
        house = {
            "id": "fq100",
            "fqId": fq_id,
            "name": template["name"],
            "houseName": old_house.get("houseName") or "普通房屋",
            "type": "房契",
            "mid": mid,
            "mapId": seller["mapId"],
            "location": (
                old_house.get("location") or seller["location"]
                if placed
                else seller["location"]
            ),
            "hxId": template["hxId"],
            "roomnum": template["roomnum"],
            "isDispose": bool(old_house.get("isDispose", False)),
            "isRename": bool(old_house.get("isRename", False)),
            "status": _int(old_house.get("status"), 0),
            "uid": userid,
        }
        # 已经安置的家园更换房屋时保留地皮和地址关系。
        for field in ("dpId", "dpRoomId", "fbId", "loc_mark", "loc_sort", "desc", "extra"):
            if field in old_house:
                house[field] = copy.deepcopy(old_house[field])

        bucket["house"] = house
        _ensure_village_addresses(state, userid)
        bucket["rooms"] = copy.deepcopy(_hx_spec(template["hxId"])["rooms"])
        employees = bucket.get("employees")
        if not isinstance(employees, dict):
            employees = {}
            bucket["employees"] = employees
        room_prefix = _hx_spec(template["hxId"])["roomPrefix"]
        default_fj = _default_employee_fjid(_hx_spec(template["hxId"]))
        for employee in employees.values():
            if not isinstance(employee, dict):
                continue
            employee["mid"] = mid
            if not str(employee.get("fjId") or "").startswith(room_prefix):
                employee["fjId"] = default_fj
        for field, default in (
            ("lands", {}),
            ("employee_lists", {}),
            ("dispatch", {}),
            ("furniture", []),
        ):
            if not isinstance(bucket.get(field), type(default)):
                bucket[field] = copy.deepcopy(default)
        bucket["version"] = max(_int(bucket.get("version"), 0), 0) + 1
        bucket["updated_at"] = now

        # 清理该玩家可能遗留的旧 mid 索引，再登记当前房屋。
        for value, owner in list(root["mid_owners"].items()):
            if _int(owner, 0) == userid and value != str(mid):
                root["mid_owners"].pop(value, None)
        root["mid_owners"][str(mid)] = userid

        new_balance = balance - cost
        account = state._state["accounts"].setdefault(key, {"userid": userid})
        currencies = account.get("currencies")
        if not isinstance(currencies, dict):
            currencies = {}
            account["currencies"] = currencies
        currencies["yinpiao"] = new_balance
        account["updated_at"] = now
        saved_archive = _sync_house_archive(state, userid, house, new_balance)

        response = {
            "mid": mid,
            "location": house["location"],
            "remove_point": cost,
            "point": new_balance,
            "fqId": fq_id,
            "mapId": seller["mapId"],
            "hxId": template["hxId"],
            "roomnum": template["roomnum"],
            "isBuy": True,
        }
        if isinstance(saved_archive, dict) and "dataVer" in saved_archive:
            response["dataVer"] = _int(saved_archive.get("dataVer"), 0)
        root["purchase_receipts"][key] = {
            "npcId": npc_id,
            "fqId": fq_id,
            "created_at": now,
            "data": copy.deepcopy(response),
        }
        state._changed()
        return build_response_body(response)


@route(["POST"], "get_house_info")
def get_house_info(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    ctx["state"].ensure_account(userid)
    bucket, error = _owned_bucket(ctx, userid)
    if error:
        return build_response_body({}, errcode=404, errmsg=error)
    house = copy.deepcopy(bucket["house"])
    house["person"] = _has_steward(bucket)
    return build_response_body(house)


@route(["POST"], "get_user_map")
def get_user_map(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    return build_response_body(_map_data(ctx, userid, bucket))


@route(["POST"], "get_common_fuben")
def get_common_fuben(ctx):
    """Return houses placed on a public homeland city map.

    The client calls this while entering fb301-fb304 and expects
    ``data.usermap`` even when no player has claimed a plot yet.
    """
    fb_id = str(_body(ctx).get("fbId") or "").strip()
    if not fb_id:
        return build_response_body({}, errcode=400, errmsg="fbId required")

    usermaps = []
    state = ctx["state"]
    with state._lock:
        root = state._normalize_homeland(state._state)
        for key, bucket in root["users"].items():
            if not isinstance(bucket, dict):
                continue
            house = bucket.get("house")
            if not isinstance(house, dict):
                continue
            dp_id = str(house.get("dpId") or "").strip()
            house_fb_id = str(
                house.get("fbId") or house.get("mapId") or ""
            ).strip()
            if not dp_id or house_fb_id != fb_id:
                continue

            spec = _hx_spec(house.get("hxId"))
            uid = _int(house.get("uid"), _int(key, 0))
            usermaps.append({
                "mid": _int(house.get("mid"), 0),
                "uid": uid,
                "name": house.get("name") or house.get("houseName") or "家园",
                "desc": house.get("desc") or "",
                "entryRoom": house.get("entryRoom") or spec["entryRoom"],
                "dpId": dp_id,
                "dpRoomId": house.get("dpRoomId") or "",
                "fqId": house.get("fqId") or "",
                "hxId": spec["hxId"],
            })

    usermaps.sort(key=lambda value: (value["dpId"], value["mid"], value["uid"]))
    return build_response_body({"usermap": usermaps})


@route(["POST"], "putin_furniture")
def putin_furniture(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")

    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)

    fj_id = str(body.get("fjId") or "").strip()
    item_id = str(body.get("jjId") or "").strip()
    if not fj_id:
        return build_response_body({}, errcode=400, errmsg="fjId required")
    if not item_id:
        return build_response_body({}, errcode=400, errmsg="jjId required")

    room_ids = {
        str(room.get("fjId") or "")
        for room in bucket.get("rooms") or []
        if isinstance(room, dict)
    }
    if fj_id not in room_ids:
        return build_response_body({}, errcode=404, errmsg="room not found")

    metadata = _load_furniture_metadata().get(item_id)
    if not isinstance(metadata, dict):
        return build_response_body({}, errcode=404, errmsg="furniture not found")

    requested_ver = str(body.get("ver") or "").strip()
    extra = copy.deepcopy(body.get("extra"))
    if extra is None:
        extra = ""
    signature = {
        "mid": _int(body.get("mid"), 0),
        "fjId": fj_id,
        "jjId": item_id,
        "extra": extra,
        "ver": requested_ver,
    }
    state = ctx["state"]
    with state.defer_saves():
        receipt = bucket.get("last_furniture_put")
        if (
            isinstance(receipt, dict)
            and receipt.get("signature") == signature
            and isinstance(receipt.get("data"), dict)
        ):
            return build_response_body(copy.deepcopy(receipt["data"]))

        current_ver = _homeland_version(bucket)
        if requested_ver and requested_ver != current_ver:
            return build_response_body(
                {"ver": current_ver}, errcode=409, errmsg="homeland version conflict"
            )
        if _take_archive_furniture(state, userid, item_id) is None:
            return build_response_body({}, errcode=404, errmsg="furniture item not found")

        furniture = bucket.setdefault("furniture", [])
        if not isinstance(furniture, list):
            furniture = []
            bucket["furniture"] = furniture
        fid = max(
            [_int(value.get("fid"), 0) for value in furniture if isinstance(value, dict)]
            + [500000]
        ) + 1
        furn_info = {
            "fid": fid,
            "jjId": item_id,
            "fjId": fj_id,
            "mid": _int((bucket.get("house") or {}).get("mid"), 0),
            "itype": _int(metadata.get("itype"), 0),
            "name": str(metadata.get("name") or item_id),
            "special": _int(metadata.get("special"), 0),
            "extra": extra,
            "isInit": 0,
        }
        furniture.append(furn_info)
        bucket["version"] = max(_int(bucket.get("version"), 0), 0) + 1
        bucket["updated_at"] = int(time.time())
        data = {
            "furn_info": copy.deepcopy(furn_info),
            "ver": _homeland_version(bucket),
        }
        bucket["last_furniture_put"] = {
            "signature": signature,
            "data": copy.deepcopy(data),
        }
        state._changed()
    return build_response_body(data)


@route(["POST"], "upload_furniture_extra")
def upload_furniture_extra(ctx):
    """Replace the persisted extra attributes of placed furniture.

    The client sends a batch shaped as ``[{fid, attr}, ...]`` for mutable
    special-furniture state such as training-dummy durability and incense.
    Validate the whole batch before applying it so a bad fid cannot leave a
    partially updated homeland.
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")

    body = _body(ctx)
    updates = body.get("attr")
    if not isinstance(updates, list):
        return build_response_body({}, errcode=400, errmsg="attr must be a list")

    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)

    state = ctx["state"]
    with state.defer_saves():
        furniture = bucket.get("furniture")
        if not isinstance(furniture, list):
            furniture = []

        by_fid = {
            str(value.get("fid")): value
            for value in furniture
            if isinstance(value, dict) and value.get("fid") not in (None, "")
        }
        pending = []
        for update in updates:
            if not isinstance(update, dict):
                return build_response_body(
                    {}, errcode=400, errmsg="invalid furniture extra"
                )
            fid = update.get("fid")
            attr = update.get("attr")
            if fid in (None, "") or isinstance(fid, bool) or not isinstance(attr, dict):
                return build_response_body(
                    {}, errcode=400, errmsg="invalid furniture extra"
                )
            target = by_fid.get(str(fid))
            if target is None:
                return build_response_body(
                    {"fid": fid}, errcode=404, errmsg="furniture not found"
                )
            pending.append((target, copy.deepcopy(attr)))

        for target, attr in pending:
            # This is replacement, not a merge: the incense client clears its
            # state by explicitly uploading an empty table.
            target["extra"] = attr
        if pending:
            bucket["updated_at"] = int(time.time())
            state._changed()

    return build_response_body({})


@route(["POST"], "rename_home")
def rename_home(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    name = str(body.get("name") or body.get("houseName") or "").strip()
    if not name:
        return build_response_body({}, errcode=400, errmsg="name required")
    bucket["house"]["name"] = name
    bucket["house"]["isRename"] = True
    bucket["updated_at"] = int(time.time())
    with ctx["state"]._lock:
        ctx["state"]._changed()
    return build_response_body(copy.deepcopy(bucket["house"]))


@route(["POST"], "get_location_map")
def get_location_map(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    mark = _location_mark(_body(ctx).get("loc_mark"))
    if mark is None:
        return build_response_body({}, errcode=400, errmsg="invalid loc_mark")
    state = ctx["state"]
    houses = []
    with state.defer_saves():
        _ensure_village_addresses(state, userid)
        root = state._normalize_homeland(state._state)
        for key, bucket in root["users"].items():
            house = bucket.get("house") if isinstance(bucket, dict) else None
            if not isinstance(house, dict) or _int(house.get("mid"), 0) <= 0:
                continue
            if str(house.get("dpId") or "").strip() or house.get("loc_mark") != mark:
                continue
            spec = _hx_spec(house.get("hxId"))
            houses.append({
                "mid": _int(house["mid"]),
                "uid": _int(key),
                "loc_mark": list(mark),
                "loc_sort": house["loc_sort"],
                "name": house.get("name") or house.get("houseName") or "家园",
                "desc": house.get("desc") or "",
                "dsc": house.get("desc") or "",
                "entryRoom": spec["entryRoom"],
                "fqId": house.get("fqId") or "",
                "hxId": spec["hxId"],
            })
    houses.sort(key=lambda house: (house["loc_sort"], house["mid"]))
    return build_response_body({"list": houses, "owner": _role_name(ctx, userid)})


@route(["GET", "POST"], "get_location_max")
def get_location_max(ctx):
    # 客户端 HomelandModule "询址" 要求 data.max 为 4 元素数组
    # {cityAreaMax, cityDirMax, villageMax, villageAreaMax}, 否则 #limitCache ~= 4 报"数据获取失败"。
    # 见 UserMapRelation: cityArea=16, cityDir=20, village=26, villageArea=20。
    return build_response_body({"max": [16, 20, 26, 20]})


@route(["GET", "POST"], "get_all_rooms")
def get_all_rooms(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket, error = _owned_bucket(ctx, userid)
    if error:
        return build_response_body({}, errcode=404, errmsg=error)
    spec, stale = _ensure_layout(bucket)
    if stale:
        with ctx["state"]._lock:
            ctx["state"]._changed()
    return build_response_body({"list": copy.deepcopy(bucket.get("rooms") or spec["rooms"])})


def _store_employee_list(bucket, npc_id, values):
    """保存客户端上传的招募列表, 并按官方契约补齐 hid/state 后返回。

    客户端 PuRenModel/MenKeModel/GuanJiaModel:refresh 拿到 save_employee_list 的响应后
    直接 `for i = 1, #data` 只保留 `data[i].state == 0` 的条目, 因此:
      * 响应 data 必须是"数组本身"——返回 {"list": [...]} 会让 `#data == 0`, 列表永远空白;
      * 每条要补服务端分配的 `hid`(客户端 employeeNpc 用 `npc.hid` 回调 add_employee)
        与 `state = 0`(0 可雇佣 / 1 已雇佣)。
    hid 用递增序号分配, 列表整批刷新后旧 hid 自然失效, 不会误命中新条目。
    """
    seq = max(_int(bucket.get("employee_hid_seq"), 0), 0)
    entries = []
    for value in values:
        if not isinstance(value, dict):
            continue
        entry = copy.deepcopy(value)
        seq += 1
        entry["hid"] = seq
        entry["state"] = 0
        entries.append(entry)
    bucket["employee_hid_seq"] = seq
    bucket.setdefault("employee_lists", {})[str(npc_id)] = entries
    return entries


def _find_list_entry(bucket, npc_id, hid):
    """按 hid 反查招募列表条目; 先查当前 npcId 的列表, 再兜底查其它列表。"""
    if hid <= 0:
        return None
    lists = bucket.get("employee_lists") or {}
    keys = [str(npc_id)]
    keys += [key for key in lists if str(key) != str(npc_id)]
    for key in keys:
        for entry in lists.get(key) or []:
            if isinstance(entry, dict) and _int(entry.get("hid"), 0) == hid:
                return entry
    return None


def _charge_employee_price(ctx, userid, price, unit):
    """雇佣扣费(银票/元宝); 返回 (是否成功, errcode, errmsg)。"""
    price = max(_int(price, 0), 0)
    currency_id = str(unit or "yinpiao")
    if price <= 0 or currency_id not in ("yinpiao", "yuanbao"):
        # 价格为 0 或单位未知时不扣费, 避免凭猜测写坏存档
        return True, 0, ""
    balance = _currency_balance(ctx, userid, currency_id)
    if balance < price:
        return False, 2, ("银票不足" if currency_id == "yinpiao" else "元宝不足")
    _set_currency_balance(ctx, userid, currency_id, balance - price)
    return True, 0, ""


@route(["POST"], "save_employee_list")
def save_employee_list(ctx):
    """雇佣列表保存(生成/刷新)。请求 {type, npcId, list}; type 1 普通生成 / 2 花元宝刷新。

    注意 body 里没有 mid, 所以只能按 userid 归属校验。本客户端(assets/src)里所有
    refresh 调用点都传 1, `needCost == 2` 的分支是死代码, 因此 type=2 的元宝消耗
    没有任何可依据的价格, 不在这里凭空扣费。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    npc_id = str(body.get("npcId") or "0")
    values = body.get("list") if isinstance(body.get("list"), list) else []
    entries = _store_employee_list(bucket, npc_id, values)
    bucket["updated_at"] = int(time.time())
    with ctx["state"]._lock:
        ctx["state"]._changed()
    # 客户端 refresh 直接遍历 data 数组, 不读 data.list
    return build_response_body(copy.deepcopy(entries))


@route(["GET"], "get_employee_list")
def get_employee_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    tail = ctx.get("route_tail") or []
    npc_id = str(tail[0]) if tail else "0"
    mid = tail[1] if len(tail) > 1 else None
    bucket, error = _owned_bucket(ctx, userid, mid)
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    values = bucket.setdefault("employee_lists", {}).get(npc_id, [])
    # 这里客户端读 data.list / data.shenshi(与 save_employee_list 的数组响应不同)
    return build_response_body({"list": copy.deepcopy(values), "shenshi": {}})


@route(["POST"], "add_employee")
def add_employee(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    npc_id = str(body.get("npcId") or "0")
    hid = _int(body.get("hid"), 0)
    pushed = body.get("push_data") if isinstance(body.get("push_data"), dict) else {}
    entry = _find_list_entry(bucket, npc_id, hid)
    if hid > 0 and entry is None:
        # 列表已被整批刷新或家园档被清空: 这条 errmsg 会直接弹给玩家
        return build_response_body({}, errcode=404, errmsg="招募列表已刷新，请重新打开招募界面")
    if entry is not None:
        # 商店雇佣(hid != 0)时客户端只传 hid: 管家固定传 {} (GuanJiaModel.lua:332),
        # 仆人/门客列表项也只回传 hid, 所以必须以服务端保存的条目为基准,
        # 否则雇到的人会变成默认的"小四/moban001", 玩家看到的名字职业全丢。
        source = copy.deepcopy(entry)
        source.pop("hid", None)
        source.pop("state", None)
        source.update(copy.deepcopy(pushed))
    else:
        # hid == 0: 初始管家(带完整 push_data)或副本产出的仆人/门客
        source = copy.deepcopy(pushed)
    charged, code, message = _charge_employee_price(
        ctx, userid, source.get("price"), source.get("price_unit"))
    if not charged:
        return build_response_body({}, errcode=code, errmsg=message)
    obj_id = str(body.get("objId") or source.get("objId") or "")
    if not obj_id:
        return build_response_body({}, errcode=400, errmsg="objId required")
    employee = source
    employee["objId"] = obj_id
    employee["rwId"] = obj_id
    employee["job"] = employee.get("job") or employee.get("jobType") or ("guanjia001" if _int(body.get("npcId"), 0) == 0 else "puren001")
    employee["jobType"] = employee.get("jobType") or employee["job"]
    spec, _stale = _ensure_layout(bucket)
    employee = _employee_payload(employee, _default_employee_fjid(spec))
    employees = bucket.setdefault("employees", {})
    if _is_steward(employee):
        for key, existing in list(employees.items()):
            if key != obj_id and _is_steward(existing):
                employees.pop(key, None)
    employees[obj_id] = employee
    if entry is not None:
        # 已雇佣的条目保留在列表里并置 state = 1: 客户端只取 state == 0,
        # 门客那边还会据此提示"你今天已经招募了一名门客"。
        entry["state"] = 1
    bucket["updated_at"] = int(time.time())
    with ctx["state"]._lock:
        ctx["state"]._changed()
    return build_response_body(employee)


@route(["POST"], "get_employee_data")
def get_employee_data(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    obj_id = str(body.get("objId") or "")
    employee = bucket.get("employees", {}).get(obj_id)
    if not isinstance(employee, dict):
        return build_response_body({}, errcode=404, errmsg="employee not found")
    return build_response_body(_employee_payload(employee))


@route(["POST"], "update_employee_extra")
def update_employee_extra(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    updates = body.get("up_data") if isinstance(body.get("up_data"), list) else []
    for update in updates:
        if not isinstance(update, dict):
            continue
        obj_id = str(update.get("rwId") or update.get("objId") or "")
        employee = bucket.get("employees", {}).get(obj_id)
        if not isinstance(employee, dict):
            return build_response_body({}, errcode=404, errmsg="employee not found")
        if update.get("fjId") is not None:
            spec, _stale = _ensure_layout(bucket)
            employee["fjId"] = str(update.get("fjId") or _default_employee_fjid(spec))
        extra = update.get("extra")
        if isinstance(extra, dict):
            employee.setdefault("extra", {}).update(copy.deepcopy(extra))
    bucket["updated_at"] = int(time.time())
    with ctx["state"]._lock:
        ctx["state"]._changed()
    return build_response_body({})


def _employee_extra(employee):
    extra = employee.get("extra")
    if not isinstance(extra, dict):
        extra = {}
        employee["extra"] = extra
    return extra


def _give_count_today(employee, today):
    extra = _employee_extra(employee)
    if str(extra.get("give_date") or "") != today:
        return 0
    return max(_int(extra.get("give_count"), 0), 0)


def _mark_give_today(employee, today):
    extra = _employee_extra(employee)
    if str(extra.get("give_date") or "") != today:
        extra["give_date"] = today
        extra["give_count"] = 1
        return
    extra["give_count"] = max(_int(extra.get("give_count"), 0), 0) + 1


@route(["POST"], "update_employee_data")
def update_employee_data(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    obj_id = str(body.get("objId") or "")
    employee = bucket.get("employees", {}).get(obj_id)
    if not isinstance(employee, dict):
        return build_response_body({}, errcode=404, errmsg="employee not found")
    zc_type = str(body.get("zc_type") or "").strip()
    zc_val = _int(body.get("zc_val"), 0)
    if zc_type == "give":
        today = time.strftime("%Y-%m-%d", time.localtime())
        if _give_count_today(employee, today) >= _GIVE_DAILY_LIMIT:
            return build_response_body({}, errcode=2, errmsg="你今日已经赏赐够多了，还是明日再说吧")
        cost = max(_int(body.get("currency"), 0), 0)
        balance = _currency_balance(ctx, userid, "yinpiao")
        if cost > balance:
            return build_response_body({"number": balance}, errcode=1, errmsg="银票不足")
        _set_currency_balance(ctx, userid, "yinpiao", balance - cost)
        _mark_give_today(employee, today)
    employee["defaultZhongCheng"] = max(0, _int(employee.get("defaultZhongCheng"), 0) + zc_val)
    with ctx["state"]._lock:
        ctx["state"]._changed()
    # Real-server capture contract. The client treats ``trait`` as a list,
    # ``level_up`` as a boolean, and always reads all six fields below.
    payload = {
        "level_up": False,
        "tip": "",
        "trait": [],
        "defaultZhongCheng": employee["defaultZhongCheng"],
        "activity": {
            "ssyjf": 0,
            "znqjf": 0,
            "daily_point": 0,
        },
        "day_limit": 0,
    }
    return build_response_body(payload)


@route(["POST"], "delete_employee")
def delete_employee(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    obj_id = str(body.get("objId") or "")
    if obj_id not in bucket.get("employees", {}):
        return build_response_body({}, errcode=404, errmsg="employee not found")
    bucket["employees"].pop(obj_id, None)
    bucket.get("dispatch", {}).pop(obj_id, None)
    with ctx["state"]._lock:
        ctx["state"]._changed()
    return build_response_body({"objId": obj_id})


@route(["POST"], "get_affair_list")
def get_affair_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body([], errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body([], errcode=403, errmsg=error)
    return build_response_body([])


@route(["GET", "POST"], "get_all_persons")
def get_all_persons(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket, error = _owned_bucket(ctx, userid)
    if error:
        return build_response_body({}, errcode=404, errmsg=error)
    spec, _stale = _ensure_layout(bucket)
    default_fj = _default_employee_fjid(spec)
    return build_response_body({"list": [_employee_payload(v, default_fj) for v in bucket.get("employees", {}).values()]})


_GUAIKE_YINPIAO = 200
_GUAIKE_GOLD = 100
_GUAIKE_ITEMS = (
    {"itemId": "qiannengdan", "num": 1},
    {"itemId": "jingmai102", "num": 1},
)


def _grant_guaike_archive(state, userid, yinpiao, gold, items):
    archive = state.get_archive(userid)
    archive = copy.deepcopy(archive) if isinstance(archive, dict) else {}
    archive["yinpiao"] = max(_int(archive.get("yinpiao"), 0), 0) + yinpiao
    archive["gold"] = max(_int(archive.get("gold"), 0), 0) + gold
    bag = archive.get("items")
    if not isinstance(bag, list):
        bag = []
        archive["items"] = bag
    for value in items:
        item_id = str(value.get("itemId") or "")
        amount = _int(value.get("num"), 0)
        if not item_id or amount <= 0:
            continue
        found = None
        for item in bag:
            if isinstance(item, dict) and str(item.get("itemId")) == item_id:
                found = item
                break
        if found is None:
            next_id = max(
                [_int(item.get("id"), 0) for item in bag if isinstance(item, dict)]
                or [0]
            ) + 1
            bag.append({"id": next_id, "itemId": item_id, "count": amount})
        else:
            found["count"] = max(_int(found.get("count"), 0), 0) + amount
    return state.put_archive(userid, archive)


@route(["POST"], "get_guaike_reward")
def get_guaike_reward(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)

    is_menke = _int(body.get("isMenKe"), 0)
    menke_id = str(body.get("menKeId") or "")
    default_zhongcheng = 0
    if is_menke == 1 and menke_id:
        employee = (bucket.get("employees") or {}).get(menke_id)
        if isinstance(employee, dict):
            default_zhongcheng = _int(employee.get("defaultZhongCheng"), 0)

    activity_items = [copy.deepcopy(item) for item in _GUAIKE_ITEMS]
    _grant_guaike_archive(
        ctx["state"], userid, _GUAIKE_YINPIAO, _GUAIKE_GOLD, activity_items
    )
    return build_response_body({
        "yinpiao": _GUAIKE_YINPIAO,
        "yueli": 0,
        "weiwang": 0,
        "gold": _GUAIKE_GOLD,
        "activityItems": activity_items,
        "defaultZhongCheng": default_zhongcheng,
        "level_up": False,
        "trait": {},
    })


# ---------------------------------------------------------------------------
# 调试/GM 接口: DebugLayer/TestLayer.lua「家园」面板
#
# 客户端(TestLayer.lua / DebugLayer)对这些按钮只判断 status==200 && errcode==0,
# 仅 test_homeland/5 会读 data(ipairs 数组, 每项需含 name/rwId/mid)。因此这里以
# "真实改动家园状态"为准, 不做数值合法性校验(本来就是作弊按钮), 状态改动后统一
# bump 版本号, 让客户端缓存的 user_fb_<mid> 地图失效并重新拉取。
# ---------------------------------------------------------------------------

# test_homeland/<type> 的 type 语义(逐条对照 TestLayer.lua 调用点):
#   1 所有仆人忠诚度 +loyal            body {mid, loyal}
#   2 删除所有仆人(含派遣)             body {mid}
#   3 随机解锁所有仆人特性(每人最多 3 个) body {mid, loyal}
#   4 删除家园相关数据(房契/仆人/地皮)   body {mid}
#   5 查看所有仆人 -> 返回数组          body {mid}
#   6 清除地皮缴费/回收状态(客户端未调用, 按 7/8 的反操作实现)
#   7 地皮进入缴费状态                  body {mid, datime}
#   8 地皮进入回收倒计时                body {mid, datime}
# 7/8 只是把官方"地皮到期时间"落到 house 上; mock 未模拟地皮副本与回收流程,
# 所以除 7 之后接 8 之外没有别的处理器读取它(客户端也只判断 errcode)。
_TEST_HOMELAND_TYPES = frozenset((1, 2, 3, 4, 5, 6, 7, 8))
# make_servant_change 的 type: naoshi 闹事 / leave 仆人离开 / wild 门客云游
# (leave 与 wild 都是"从府中消失", 差别只在官方推送的 Affair 文案, mock 统一按移除处理)
_SERVANT_CHANGE_TYPES = ("naoshi", "leave", "wild")
_SERVANT_EVENT_LOG_LIMIT = 20


def _touch_homeland(ctx, bucket):
    """状态改动后 bump 版本, 客户端据此丢弃 user_fb_<mid> 缓存并重新 get_user_map。"""
    bucket["version"] = max(_int(bucket.get("version"), 0), 0) + 1
    bucket["updated_at"] = int(time.time())
    with ctx["state"]._lock:
        ctx["state"]._changed()


def _find_employee_key(bucket, rw_id):
    """按 rwId/objId 定位仆人; add_employee 存的 key 就是 objId, 但旧档可能不一致。"""
    employees = bucket.get("employees") or {}
    if rw_id in employees:
        return rw_id
    for key, employee in employees.items():
        if not isinstance(employee, dict):
            continue
        if rw_id in (str(employee.get("rwId") or ""), str(employee.get("objId") or "")):
            return key
    return None


def _random_role_traits(employee):
    """随机挑 3 个互不相同的可用特性, 门槛与客户端 getTexingList 一致(特点值 traitVal)。"""
    value = max(_int(employee.get("traitVal"), 0), 0)
    pool = [trait_id for trait_id in USABLE_TRAIT_IDS
            if TRAIT_NEED.get(trait_id, 0) <= value]
    if not pool:
        pool = list(USABLE_TRAIT_IDS)
    chosen = random.sample(pool, min(3, len(pool)))
    while len(chosen) < 3:
        chosen.append("")
    return chosen


def _clear_archive_homeland(state, userid):
    """对齐客户端 test_homeland/4 成功后本地清空的字段(TestLayer.lua:531-551)。

    客户端会自行删掉背包里的房契/地契/邀请函道具, 服务端只需清掉家园档与镜像的
    房契道具, 否则下次下发 RoleData 时 fq 还在, 地图仍会打开。
    """
    archive = state.get_archive(userid)
    if not isinstance(archive, dict):
        return False
    homeland = archive.get("Homeland")
    if isinstance(homeland, dict):
        for key in ("fq", "dq", "yq", "dinner"):
            homeland.pop(key, None)
    items = archive.get("items")
    if isinstance(items, list):
        archive["items"] = [
            item for item in items
            if not (isinstance(item, dict) and str(item.get("itemId") or "") == "fq100")
        ]
    for key in ("homeLandRoleData", "DispatchTask"):
        archive.pop(key, None)
    state.put_archive(userid, archive)
    return True


def _reset_homeland(ctx, userid):
    """test_homeland/4: 删除该玩家的全部家园数据, 并释放 mid。

    mid 只做记录(客户端传的是本地房契的 mid); 官方这个按钮是"清档", 所以即使
    本地 mid 与服务端不一致也照删, 避免玩家卡在打不开又删不掉的状态。
    """
    state = ctx["state"]
    with state._lock:
        root = state._normalize_homeland(state._state)
        bucket = root["users"].pop(str(userid), None)
        mid = 0
        if isinstance(bucket, dict):
            mid = _int((bucket.get("house") or {}).get("mid"), 0)
        if mid <= 0:
            mid = next(
                (_int(key, 0) for key, owner in root["mid_owners"].items()
                 if _int(owner, 0) == userid),
                0,
            )
        if mid > 0 and _int(root["mid_owners"].get(str(mid)), 0) == userid:
            root["mid_owners"].pop(str(mid), None)
        state._changed()
    _clear_archive_homeland(state, userid)
    return {"mid": mid, "had_homeland": bool(bucket)}


@route(["POST"], "test_homeland")
def test_homeland(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    tail = ctx.get("route_tail") or []
    kind = _int(tail[0] if tail else 0, 0)
    if kind not in _TEST_HOMELAND_TYPES:
        return build_response_body({}, errcode=400, errmsg="unknown test type")
    body = _body(ctx)
    if kind == 4:
        return build_response_body(_reset_homeland(ctx, userid))

    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    house = bucket.get("house") or {}
    mid = _int(house.get("mid"), 0)

    if kind == 1:
        loyal = max(_int(body.get("loyal"), 0), 0)
        for employee in (bucket.get("employees") or {}).values():
            if isinstance(employee, dict):
                employee["defaultZhongCheng"] = (
                    max(_int(employee.get("defaultZhongCheng"), 0), 0) + loyal
                )
        _touch_homeland(ctx, bucket)
        return build_response_body({"mid": mid, "loyal": loyal})

    if kind == 2:
        removed = len(bucket.get("employees") or {})
        bucket["employees"] = {}
        bucket["dispatch"] = {}
        bucket["employee_lists"] = {}
        _touch_homeland(ctx, bucket)
        return build_response_body({"mid": mid, "deleted": removed})

    if kind == 3:
        changed = 0
        for employee in (bucket.get("employees") or {}).values():
            if not isinstance(employee, dict):
                continue
            trait1, trait2, trait3 = _random_role_traits(employee)
            employee["trait1"], employee["trait2"], employee["trait3"] = trait1, trait2, trait3
            changed += 1
        _touch_homeland(ctx, bucket)
        return build_response_body({"mid": mid, "changed": changed})

    if kind == 5:
        spec, _stale = _ensure_layout(bucket)
        default_fj = _default_employee_fjid(spec)
        npcs = []
        for employee in (bucket.get("employees") or {}).values():
            payload = _employee_payload(employee, default_fj)
            # 客户端 npcFunc 用 npc.rwId 调 updateEmployRoleData, 用 npc.mid 做归属校验,
            # npc.name 只用于按钮标题。
            payload["mid"] = mid
            payload["rwId"] = str(payload.get("rwId") or payload.get("objId") or "")
            payload["name"] = str(payload.get("name") or "仆人")
            npcs.append(payload)
        return build_response_body(npcs)

    if kind in (7, 8):
        datime = max(_int(body.get("datime"), 0), 0)
        house["land_state"] = "paying" if kind == 7 else "recycle"
        house["land_datime"] = datime
        house["land_change_at"] = int(time.time()) + datime
        _touch_homeland(ctx, bucket)
        return build_response_body({"mid": mid, "datime": datime})

    # kind == 6: 客户端没有按钮, 按 7/8 的反操作实现(清除缴费/回收状态)
    for key in ("land_state", "land_datime", "land_change_at"):
        house.pop(key, None)
    _touch_homeland(ctx, bucket)
    return build_response_body({"mid": mid})


@route(["POST"], "make_servant_change")
def make_servant_change(ctx):
    """setPuRenStatus: 设置单个仆人状态。

    请求 {mid, rwId, type, time}; type: naoshi 闹事 / leave 仆人离开 / wild 门客云游。
    - naoshi: extra.naoshi = 1(客户端 HomelandRoleUtil:getRoleCurrStatus 显示"闹事")。
    - leave/wild: 从府中移除该仆人(官方由 Affair「仆人离开」消息通知, mock 未做 event 推送),
      同时清掉其派遣记录。
    time 是官方用来延时生效的秒数, DebugLayer 三个按钮都传 0; mock 立即生效, 只把预期
    时间记进 extra/house 便于观察。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    change_type = str(body.get("type") or "").strip()
    if change_type not in _SERVANT_CHANGE_TYPES:
        return build_response_body({}, errcode=400, errmsg="unknown change type")
    rw_id = str(body.get("rwId") or body.get("objId") or "")
    key = _find_employee_key(bucket, rw_id)
    if key is None:
        return build_response_body({}, errcode=404, errmsg="employee not found")
    employee = bucket["employees"][key]
    delay = max(_int(body.get("time"), 0), 0)
    now = int(time.time())
    if change_type == "naoshi":
        extra = _employee_extra(employee)
        extra["naoshi"] = 1
        extra["naoshi_at"] = now + delay
    else:
        bucket["employees"].pop(key, None)
        bucket.get("dispatch", {}).pop(key, None)
        events = bucket.setdefault("servant_events", [])
        events.append({
            "rwId": str(employee.get("rwId") or key),
            "name": str(employee.get("name") or ""),
            "type": change_type,
            "at": now + delay,
        })
        del events[:-_SERVANT_EVENT_LOG_LIMIT]
    _touch_homeland(ctx, bucket)
    return build_response_body({"mid": _int((bucket.get("house") or {}).get("mid"), 0),
                                "rwId": rw_id, "type": change_type})


@route(["POST"], "set_auction_time")
def set_auction_time(ctx):
    """DebugLayer「竞拍过期时间为 0 / 3 分钟」: 请求 {time}(秒)。

    mock 没有实现地皮竞拍子系统(lands 恒为空, get_location_* 只回村落地址), 这里把
    官方要设置的剩余竞拍时间落到 homeland 根节点供后续实现读取; 客户端不读 data。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    seconds = max(_int(_body(ctx).get("time"), 0), 0)
    state = ctx["state"]
    with state._lock:
        root = state._normalize_homeland(state._state)
        root["auction_time"] = seconds
        root["auction_end"] = int(time.time()) + seconds
        state._changed()
    return build_response_body({"time": seconds})
