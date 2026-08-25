# -*- coding: utf-8 -*-

import copy
import hashlib
import time

from protocol import build_response_body
from server import route


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
    "roomnum": 9,
    "status": 1,
    "type": "房契",
}

# huxing002(简屋小户) 官方户型布局, 与 assets/res/script/others/familytype.lua
# 的 ["huxing002"] 房间连接及 ["户型总览"][2] 的 mapAppearance/mapAppearanceIndex 一致。
# roomType 映射来自 familylist.lua: 屋外=tsfangjian002 门前=tsfangjian003
# 大门=tsfangjian004 卧室=tsfangjian011 仓库=tsfangjian005 练功房=tsfangjian009
# 长廊=ptfangjian001
DEFAULT_ROOMS = [
    {"fjId": "fb320_01", "name": "屋外", "desc": "这里是屋外，是一片小小的开阔地", "roomType": "tsfangjian002", "mapHide": 0, "up": "fb320_02"},
    {"fjId": "fb320_02", "name": "门前", "desc": "宅院门前", "roomType": "tsfangjian003", "mapHide": 0, "down": "fb320_01", "up": "fb320_03"},
    {"fjId": "fb320_03", "name": "大门", "desc": "宅院大门", "roomType": "tsfangjian004", "mapHide": 0, "down": "fb320_02", "up": "fb320_05"},
    {"fjId": "fb320_04", "name": "卧室", "desc": "卧室", "roomType": "tsfangjian011", "mapHide": 0, "right": "fb320_05"},
    {"fjId": "fb320_05", "name": "长廊", "desc": "这是一条普通的长廊，没有什么奇特之处。", "roomType": "ptfangjian001", "mapHide": 0, "down": "fb320_03", "left": "fb320_04", "up": "fb320_06"},
    {"fjId": "fb320_06", "name": "长廊", "desc": "这是一条普通的长廊，没有什么奇特之处。", "roomType": "ptfangjian001", "mapHide": 0, "down": "fb320_05", "up": "fb320_08"},
    {"fjId": "fb320_07", "name": "练功房", "desc": "练功房", "roomType": "tsfangjian009", "mapHide": 0, "right": "fb320_08"},
    {"fjId": "fb320_08", "name": "长廊", "desc": "这是一条普通的长廊，没有什么奇特之处。", "roomType": "ptfangjian001", "mapHide": 0, "down": "fb320_06", "left": "fb320_07", "right": "fb320_09"},
    {"fjId": "fb320_09", "name": "仓库", "desc": "仓库", "roomType": "tsfangjian005", "mapHide": 0, "left": "fb320_08"},
]

# 以下三个字段原样抠自 familytype.lua ["户型总览"]["2"] (huxing002 简屋小户),
# 已脚本逐字节比对一致, 与真实服务端行为相同(服务端即照抄该表下发)。勿手改。
HX_MAP_APPEARANCE = "\n".join([
    "房间—长廊—房间",
    "　　　　▏",
    "　　　长廊",
    "　　　　▏",
    "房间—长廊",
    "　　　　▏",
    "　　　大门",
    "　　　　▏",
    "　　　门前",
    "　　　　▏",
    "　　　屋外",
])
HX_MAP_APPEARANCE_INDEX = "\n".join([
    "fb320_07,fb320_08,fb320_09",
    "fb320_06",
    "fb320_04,fb320_05",
    "fb320_03",
    "fb320_02",
    "fb320_01",
])
HX_ENTRY_ROOM = "fb320_02"

# huxing002 布局下合法的房间 ID 前缀(含扩建生成的新房间)
_HX_ROOM_PREFIX = "fb320_"


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
            root["mid_owners"].setdefault(mid, userid)
            state._changed()
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


def _employee_payload(employee):
    value = copy.deepcopy(employee)
    value.setdefault("rwId", value.get("objId"))
    value.setdefault("objId", value.get("rwId"))
    value.setdefault("fjId", "fb320_04")
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


def _map_data(ctx, userid, bucket):
    house = bucket["house"]
    mid = _int(house.get("mid"), 0)
    rooms = copy.deepcopy(bucket.get("rooms") or DEFAULT_ROOMS)
    # 迁移: bucket 里持久化的房间若不是当前 huxing002 布局(旧版 room_* 等),
    # 与全图 mapAppearanceIndex 的 fb320_* ID 对不上, 直接重置为官方布局。
    stale = not rooms or any(
        not isinstance(room, dict)
        or not str(room.get("fjId", "")).startswith(_HX_ROOM_PREFIX)
        for room in rooms
    )
    if stale:
        rooms = copy.deepcopy(DEFAULT_ROOMS)
        bucket["rooms"] = copy.deepcopy(DEFAULT_ROOMS)
        # 雇员所在房间同步迁移到新布局(默认卧室 fb320_04)
        for employee in bucket.get("employees", {}).values():
            if isinstance(employee, dict) and not str(employee.get("fjId", "")).startswith(_HX_ROOM_PREFIX):
                employee["fjId"] = "fb320_04"
        bucket["updated_at"] = int(time.time())
        with ctx["state"]._lock:
            ctx["state"]._changed()
    # 补齐客户端移动/渲染所需的全部房间字段(含 stepMusic)
    rooms = [_normalize_room(room, mid, 690000 + i)
             for i, room in enumerate(rooms)]
    employees = []
    now = int(time.time())
    for value in bucket.get("employees", {}).values():
        employee = _employee_payload(value)
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
    ver = str(bucket.get("version") or "1")
    if len(ver) < 16:
        ver = hashlib.md5(ver.encode()).hexdigest()
    return {
        "ver": ver,
        "owner": _role_name(ctx, userid),
        "usermap": {
            "mid": mid,
            "fbId": "",
            "hxId": house.get("hxId") or "huxing002",
            "location": house.get("location") or "",
            "fqId": house.get("fqId") or "yangzhou002",
            "dpId": house.get("dpId") or "",
            "uid": userid,
            "name": house.get("name") or house.get("houseName") or "家园",
            "desc": house.get("desc") or "",
            "entryRoom": house.get("entryRoom") or HX_ENTRY_ROOM,
            "BGM": house.get("BGM") or "bgm001",
            "mapAppearance": house.get("mapAppearance") or HX_MAP_APPEARANCE,
            "mapAppearanceIndex": house.get("mapAppearanceIndex") or HX_MAP_APPEARANCE_INDEX,
            "extra": {},
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


@route(["GET", "POST"], "get_home_switch")
def get_home_switch(ctx):
    return build_response_body({"open": True, "yinpiao": 0})


@route(["POST"], "get_house_info")
def get_house_info(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    ctx["state"].ensure_account(userid)
    bucket, error = _owned_bucket(ctx, userid)
    if error:
        return build_response_body({}, errcode=404, errmsg=error)
    return build_response_body(copy.deepcopy(bucket["house"]))


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
    return build_response_body({"list": [], "owner": _role_name(ctx, userid)})


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
    return build_response_body({"list": copy.deepcopy(bucket.get("rooms") or DEFAULT_ROOMS)})


@route(["POST"], "save_employee_list")
def save_employee_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    bucket, error = _owned_bucket(ctx, userid, body.get("mid"))
    if error:
        return build_response_body({}, errcode=403, errmsg=error)
    npc_id = str(body.get("npcId") or "0")
    values = body.get("list") if isinstance(body.get("list"), list) else []
    bucket.setdefault("employee_lists", {})[npc_id] = copy.deepcopy(values)
    bucket["updated_at"] = int(time.time())
    with ctx["state"]._lock:
        ctx["state"]._changed()
    return build_response_body({"list": copy.deepcopy(values), "shenshi": {}})


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
    pushed = body.get("push_data") if isinstance(body.get("push_data"), dict) else {}
    obj_id = str(body.get("objId") or pushed.get("objId") or "")
    if not obj_id:
        return build_response_body({}, errcode=400, errmsg="objId required")
    employee = copy.deepcopy(pushed)
    employee["objId"] = obj_id
    employee["rwId"] = obj_id
    employee["job"] = employee.get("job") or employee.get("jobType") or ("guanjia001" if _int(body.get("npcId"), 0) == 0 else "puren001")
    employee["jobType"] = employee.get("jobType") or employee["job"]
    employee = _employee_payload(employee)
    bucket.setdefault("employees", {})[obj_id] = employee
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
            employee["fjId"] = str(update.get("fjId") or "fb320_04")
        extra = update.get("extra")
        if isinstance(extra, dict):
            employee.setdefault("extra", {}).update(copy.deepcopy(extra))
    bucket["updated_at"] = int(time.time())
    with ctx["state"]._lock:
        ctx["state"]._changed()
    return build_response_body({})


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
    employee["defaultZhongCheng"] = max(0, _int(employee.get("defaultZhongCheng"), 0) + _int(body.get("zc_val"), 0))
    with ctx["state"]._lock:
        ctx["state"]._changed()
    return build_response_body(_employee_payload(employee))


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
    return build_response_body({"list": [_employee_payload(v) for v in bucket.get("employees", {}).values()]})


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
