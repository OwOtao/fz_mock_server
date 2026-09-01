# -*- coding: utf-8 -*-

import copy
import datetime
import time

from protocol import build_response_body
from server import route


DEFAULT_BUILD_LIST = [
    {
        "buildTypeId": "100",
        "buildLv": 0,
        "buildTeacherExp": 0,
        "state": 0,
    }
]


def _userid(ctx):
    try:
        return int(ctx.get("headers", {}).get("userid") or 0)
    except (TypeError, ValueError):
        return 0


def _body(ctx):
    value = ctx.get("body")
    return value if isinstance(value, dict) else {}


def _family_id(ctx):
    return str(_body(ctx).get("familyId") or "default")


def _today():
    return datetime.date.today().isoformat()


# 勤建之志(加速资源)上限
_DILIGENT_LIMIT = 9999


def _default_state(family_id):
    return {
        "familyId": family_id,
        "day": _today(),
        "diligent": 100,
        "diligentLimit": _DILIGENT_LIMIT,
        "gbpoint": 0,
        "sgbpoint": 0,
        "renown": 0,
        "renownLimit": 0,
        "donate": 0,
        "reputation": 0,
        "reputationLv": 0,
        "taskNumDay": 0,
        "taskNumLimit": 0,
        "donateNum": 0,
        "speedUp": 0,
        "speedUpLimit": 0,
        "buildState": 0,
        "guajiInfo": {},
        "familyStates": [],
        "featscount": 0,
        "prepareSkillLimit": 0,
        "buildList": copy.deepcopy(DEFAULT_BUILD_LIST),
        "updated_at": int(time.time()),
    }


def _bucket(ctx, userid, family_id):
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("teacher_build", {})
        user = root.setdefault(str(userid), {"families": {}})
        families = user.setdefault("families", {})
        bucket = families.get(family_id)
        changed = False
        if not isinstance(bucket, dict):
            bucket = _default_state(family_id)
            families[family_id] = bucket
            changed = True
        defaults = _default_state(family_id)
        for key, value in defaults.items():
            if key not in bucket:
                bucket[key] = copy.deepcopy(value)
                changed = True
        if bucket.get("buildState") not in (0, 1):
            bucket["buildState"] = 0
            changed = True
        guaji_info = bucket.get("guajiInfo")
        if not isinstance(guaji_info, dict) or not guaji_info.get("taskId"):
            if guaji_info != {}:
                bucket["guajiInfo"] = {}
                changed = True
        build_list = bucket.get("buildList")
        if not isinstance(build_list, list):
            bucket["buildList"] = copy.deepcopy(DEFAULT_BUILD_LIST)
            changed = True
        else:
            for build in build_list:
                if isinstance(build, dict) and build.get("state") not in (0, 1):
                    build["state"] = 0
                    changed = True
        if bucket.get("day") != _today():
            bucket["day"] = _today()
            bucket["taskNumDay"] = 0
            bucket["donateNum"] = 0
            bucket["donate"] = 0
            bucket["speedUp"] = 0
            bucket["updated_at"] = int(time.time())
            changed = True
        # 一次性迁移: 旧 bucket 的勤建之志(加速资源)为 0 且无获取途径, 补 100 便于加速功能可用
        if not bucket.get("mockDiligentSeeded"):
            bucket["diligent"] = max(_as_int(bucket.get("diligent"), 0), 100)
            bucket["mockDiligentSeeded"] = True
            changed = True
        # 勤建之志上限统一校正为 9999(含曾被 mock 误写为 100 的存量 bucket)
        if _as_int(bucket.get("diligentLimit"), 0) != _DILIGENT_LIMIT:
            bucket["diligentLimit"] = _DILIGENT_LIMIT
            changed = True
        if changed:
            ctx["state"]._changed()
        return bucket


def _info_payload(bucket):
    keys = (
        "familyId", "diligent", "diligentLimit", "gbpoint", "sgbpoint",
        "renown", "renownLimit", "donate", "reputation", "reputationLv",
        "taskNumDay", "taskNumLimit", "speedUp", "speedUpLimit",
        "buildState", "guajiInfo", "familyStates", "featscount",
        "prepareSkillLimit",
    )
    payload = {key: copy.deepcopy(bucket.get(key)) for key in keys}
    guaji_info = payload.get("guajiInfo")
    if not isinstance(guaji_info, dict) or not guaji_info.get("taskId"):
        payload["guajiInfo"] = {}
    payload["taskNumLimit"] = _task_num_limit(bucket)
    return payload


@route(["POST"], "get_teacherBuild_info")
def get_teacher_build_info(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    family_id = _family_id(ctx)
    return build_response_body(_info_payload(_bucket(ctx, userid, family_id)))


@route(["POST"], "get_teacherBuild_list")
def get_teacher_build_list(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    family_id = _family_id(ctx)
    bucket = _bucket(ctx, userid, family_id)
    return build_response_body(copy.deepcopy(bucket.get("buildList") or []))


@route(["POST"], "get_teacherBuild_items")
def get_teacher_build_items(ctx):
    """师门建筑材料信息(TeacherBuildItemPresenter): [{itemId, count, countLimit}]。

    材料为服务端货币(存档+货币账户双写, 客户端上传存档时以较大者为准);
    countLimit 为储存上限: 基础 300, 储宝库名位 1/2/3 级提升到 360/420/510。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _bucket(ctx, userid, _family_id(ctx))
    limit = 300
    for build in bucket.get("buildList") or []:
        if isinstance(build, dict) and str(build.get("buildTypeId")) == "101":
            limit = (300, 360, 420, 510)[min(_as_int(build.get("buildLv"), 0), 3)]
            break
    items = [
        {"itemId": item_id, "count": _material_balance(ctx, userid, item_id), "countLimit": limit}
        for item_id in ("bmaterials1", "bmaterials2", "bmaterials3")
    ]
    return build_response_body(items)


# ---------------------------------------------------------------------------
# 师门日常任务 / 师门建筑兴建
# 数据来源(从 Lua 资源表提取核对):
#   - family.lua familys[].camp           -> 门派阵营(1正派 2邪派 3中立; 0 散人/归隐)
#   - tasks.lua ["1"]                     -> 师门日常任务表, 按任务 camp 分组
#   - sectBuildInfo.lua ["1"] buildingid  -> 师门建筑类型 id(100~116)
# ---------------------------------------------------------------------------
_FAMILY_CAMP = {
    "seclusion": 0, "youxia": 0,
    "dali": 1, "emei": 1, "gaibang": 1, "guanfu": 1, "huashan": 1,
    "kongtong": 1, "kunlun": 1, "luoyue": 1, "quanzhen": 1, "shaolin": 1,
    "wudang": 1,
    "baituoshan": 2, "mizong": 2, "riyueshenjiao": 2, "tiezhang": 2,
    "wudu": 2, "xingxiu": 2, "youming": 2,
    "gumu": 3, "haijing": 3, "jinqianbang": 3, "mingjiao": 3, "murong": 3,
    "tangmen": 3, "taohuadao": 3, "tianjingmen": 3, "tianshan": 3,
    "yongyelou": 3,
}

# 客户端 TeacherBuildResManager 只加载 tasks.lua["1"], 任务按阵营分组:
#   camp 0: 通用旧任务集; camp 1/2/3: 各阵营任务集(前缀 3x/4x/5x, 资历任务前缀 23/24/25)
_CAMP_TASK_IDS = {
    0: (
        "100001", "100002", "100003", "100004", "100005", "100006", "100007",
        "110000", "110001", "110002", "110003", "110004", "110007", "110008",
        "110009", "110040", "110041", "110042", "110050", "110051", "110052",
        "120000", "120001", "120002", "120005", "120006", "120030", "120031",
        "120032", "120040", "120041", "120042",
        "130000", "130001", "130002", "130003", "130004", "130005", "130006",
        "130007", "130008", "130009", "130030", "130031", "130032", "130040",
        "130041", "130042", "130050", "130060", "130061", "130070", "130100",
        "130101", "130110", "130111", "130120", "130121",
        "200000",
    ),
    1: (
        "230001",
        "310001", "310002", "310003", "310004", "310005", "310006",
        "320001", "320002", "320003", "320004",
        "331001", "331002", "331003", "331004", "331005", "331006", "331007",
        "331008", "331009", "331010", "331011", "331012", "331013", "331014",
        "331015", "331016", "331017", "331018", "331019", "331020",
        "332001", "332002", "332003", "332004", "332005", "332006", "332007",
        "332008", "332009", "332010", "332011", "332012", "332013",
        "333001", "333002", "333003", "333004", "333005", "333006", "333007",
        "333008", "333009", "333010", "333011", "333012", "333013", "333014",
    ),
    2: (
        "240001",
        "410001", "410002", "410003", "410004", "410005", "410006",
        "420001", "420002", "420003", "420004",
        "431001", "431002", "431003", "431004", "431005", "431006", "431007",
        "431008", "431009", "431010", "431011", "431012", "431013", "431014",
        "431015", "431016", "431017", "431018", "431019", "431020",
        "432001", "432002", "432003", "432004", "432005", "432006", "432007",
        "432008", "432009", "432010", "432011", "432012", "432013",
        "433001", "433002", "433003", "433004", "433005", "433006", "433007",
        "433008", "433009", "433010", "433011", "433012", "433013", "433014",
    ),
    3: (
        "250001",
        "510001", "510002", "510003", "510004", "510005", "510006",
        "520001", "520002", "520003", "520004",
        "531001", "531002", "531003", "531004", "531005", "531006", "531007",
        "531008", "531009", "531010", "531011", "531012", "531013", "531014",
        "531015", "531016", "531017", "531018", "531019", "531020",
        "532001", "532002", "532003", "532004", "532005", "532006", "532007",
        "532008", "532009", "532010", "532011", "532012", "532013",
        "533001", "533002", "533003", "533004", "533005", "533006", "533007",
        "533008", "533009", "533010", "533011", "533012", "533013", "533014",
    ),
}

_BUILDING_IDS = frozenset(
    "%d" % i for i in range(100, 117)
)  # sectBuildInfo.lua buildingid: 100 勤务阁 ... 116

# 勤务阁未兴建时的基础日常次数上限(1/2级勤务阁效果分别提升到 4/5, 见 sectBuildInfo)
def _task_num_limit(bucket):
    qinwu_lv = 0
    for build in bucket.get("buildList") or []:
        if isinstance(build, dict) and str(build.get("buildTypeId")) == "100":
            qinwu_lv = min(_as_int(build.get("buildLv"), 0), 2)
            break
    return 3 + qinwu_lv


@route(["POST"], "get_teacherBuild_tasks")
def get_teacher_build_tasks(ctx):
    """师门日常任务列表(TeacherBuildSystem:getTeacherBuildTasks)。

    请求: {familyId}
    成功: {taskNumDay, taskNumLimit, list: [{taskId, state, cdTime}, ...]}
    任务按门派阵营过滤(客户端 getTask 断言 taskId 必须存在于 tasks.lua["1"]);
    state: 0未解锁/1解锁/2冷却中。mock 不做解锁条件/冷却判定, 统一返回解锁(state=1),
    所有任务 cd 均为 None 型(做完立即刷新), cdTime 恒为 0。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    family_id = _family_id(ctx)
    bucket = _bucket(ctx, userid, family_id)
    camp = _FAMILY_CAMP.get(family_id, 0)
    task_list = [
        {"taskId": task_id, "state": 1, "cdTime": 0}
        for task_id in _CAMP_TASK_IDS.get(camp, ())
    ]
    return build_response_body({
        "taskNumDay": _as_int(bucket.get("taskNumDay"), 0),
        "taskNumLimit": _task_num_limit(bucket),
        "list": task_list,
    })


@route(["POST"], "build_teacherBuild")
def build_teacher_build(ctx):
    """兴建师门建筑(TeacherBuildSystem:buildTeacherBuild)。

    请求: {buildTypeId, familyId}
    成功: {buildTypeId, state}
    与客户端 setBuildIngState 对齐: 目标建筑置为兴建中(state=1), 其余复位 0;
    客户端回调不读响应数据。建筑完成(名位/经验提升)由捐献/升级接口驱动, 未在 mock 范围内。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    build_type_id = str(body.get("buildTypeId") or "").strip()
    if build_type_id not in _BUILDING_IDS:
        return build_response_body({}, errcode=1, errmsg="建筑不存在: %s" % build_type_id)

    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        build_list = bucket.setdefault("buildList", copy.deepcopy(DEFAULT_BUILD_LIST))
        if not isinstance(build_list, list):
            build_list = copy.deepcopy(DEFAULT_BUILD_LIST)
            bucket["buildList"] = build_list
        target = None
        for build in build_list:
            if not isinstance(build, dict):
                continue
            if str(build.get("buildTypeId")) == build_type_id:
                target = build
                build["state"] = 1
            else:
                build["state"] = 0
        if target is None:
            target = {
                "buildTypeId": build_type_id,
                "buildLv": 0,
                "buildTeacherExp": 0,
                "state": 1,
            }
            build_list.append(target)
        bucket["buildState"] = 1
        ctx["state"]._changed()
    return build_response_body({"buildTypeId": build_type_id, "state": 1})


# ---------------------------------------------------------------------------
# 师门日常任务流转 / 建筑捐献 / 名位升级
# 数据来源(从 Lua 资源表提取核对):
#   - tasks.lua ["1"]          -> taskid: (时长小时, 奖励对)
#   - sectBuildInfo.lua ["1"]  -> buildingid: [(名位lv, 修筑度需求, 资历消耗, 昌盛度需求, 捐献id...)]
#   - sectBuildDonate.lua ["1"]-> donateid: (材料id, 数量, 修筑度, 资历, 佳绩, 有解锁条件)
# ---------------------------------------------------------------------------
_TASK_TABLE = {
    "100001": (1, (("reputation", 2),)), "100002": (2, (("reputation", 4),)),
    "100003": (3, (("reputation", 6),)), "100004": (4, (("reputation", 8),)),
    "310001": (1, (("reputation", 2),)), "310002": (2, (("reputation", 4),)),
    "310003": (3, (("reputation", 6),)), "310004": (4, (("reputation", 8),)),
    "310005": (4, (("reputation", 9),)), "310006": (999, (("reputation", 10),)),
    "410001": (1, (("reputation", 2),)), "410002": (2, (("reputation", 4),)),
    "410003": (3, (("reputation", 6),)), "410004": (4, (("reputation", 8),)),
    "410005": (4, (("reputation", 9),)), "410006": (999, (("reputation", 10),)),
    "510001": (1, (("reputation", 2),)), "510002": (2, (("reputation", 4),)),
    "510003": (3, (("reputation", 6),)), "510004": (4, (("reputation", 8),)),
    "510005": (4, (("reputation", 9),)), "510006": (999, (("reputation", 10),)),
    "100005": (1, (("sgbpoint", 1),)), "100006": (2, (("sgbpoint", 2),)),
    "100007": (2, (("sgbpoint", 4),)),
    "320001": (1, (("sgbpoint", 1),)), "320002": (2, (("sgbpoint", 2),)),
    "320003": (2, (("sgbpoint", 4),)), "320004": (3, (("sgbpoint", 5),)),
    "420001": (1, (("sgbpoint", 1),)), "420002": (2, (("sgbpoint", 2),)),
    "420003": (2, (("sgbpoint", 4),)), "420004": (3, (("sgbpoint", 5),)),
    "520001": (1, (("sgbpoint", 1),)), "520002": (2, (("sgbpoint", 2),)),
    "520003": (2, (("sgbpoint", 4),)), "520004": (3, (("sgbpoint", 5),)),
    "110000": (1, (("bmaterials1", 5),)), "110001": (1, (("bmaterials1", 6),)),
    "110002": (1, (("bmaterials1", 5),)), "110003": (1, (("bmaterials1", 6),)),
    "110004": (1, (("bmaterials1", 7),)), "110007": (1, (("bmaterials1", 5),)),
    "110008": (1, (("bmaterials1", 6),)), "110009": (1, (("bmaterials1", 7),)),
    "110040": (1, (("bmaterials1", 5),)), "110041": (1, (("bmaterials1", 6),)),
    "110042": (1, (("bmaterials1", 7),)), "110050": (1, (("bmaterials1", 5),)),
    "110051": (1, (("bmaterials1", 6),)), "110052": (1, (("bmaterials1", 7),)),
    "331001": (1, (("bmaterials1", 5),)), "331002": (1, (("bmaterials1", 6),)),
    "331003": (1, (("bmaterials1", 5),)), "331004": (1, (("bmaterials1", 6),)),
    "331005": (1, (("bmaterials1", 7),)), "331006": (1, (("bmaterials1", 5),)),
    "331007": (1, (("bmaterials1", 6),)), "331008": (1, (("bmaterials1", 7),)),
    "331009": (1, (("bmaterials1", 5),)), "331010": (1, (("bmaterials1", 6),)),
    "331011": (1, (("bmaterials1", 7),)), "331012": (1, (("bmaterials1", 5),)),
    "331013": (1, (("bmaterials1", 6),)), "331014": (1, (("bmaterials1", 7),)),
    "331015": (1, (("bmaterials1", 5),)), "331016": (1, (("bmaterials1", 6),)),
    "331017": (1, (("bmaterials1", 7),)), "331018": (1, (("bmaterials1", 5),)),
    "331019": (1, (("bmaterials1", 6),)), "331020": (1, (("bmaterials1", 7),)),
    "431001": (1, (("bmaterials1", 5),)), "431002": (1, (("bmaterials1", 6),)),
    "431003": (1, (("bmaterials1", 5),)), "431004": (1, (("bmaterials1", 6),)),
    "431005": (1, (("bmaterials1", 7),)), "431006": (1, (("bmaterials1", 5),)),
    "431007": (1, (("bmaterials1", 6),)), "431008": (1, (("bmaterials1", 7),)),
    "431009": (1, (("bmaterials1", 5),)), "431010": (1, (("bmaterials1", 6),)),
    "431011": (1, (("bmaterials1", 7),)), "431012": (1, (("bmaterials1", 5),)),
    "431013": (1, (("bmaterials1", 6),)), "431014": (1, (("bmaterials1", 7),)),
    "431015": (1, (("bmaterials1", 5),)), "431016": (1, (("bmaterials1", 6),)),
    "431017": (1, (("bmaterials1", 7),)), "431018": (1, (("bmaterials1", 5),)),
    "431019": (1, (("bmaterials1", 6),)), "431020": (1, (("bmaterials1", 7),)),
    "531001": (1, (("bmaterials1", 5),)), "531002": (1, (("bmaterials1", 6),)),
    "531003": (1, (("bmaterials1", 5),)), "531004": (1, (("bmaterials1", 6),)),
    "531005": (1, (("bmaterials1", 7),)), "531006": (1, (("bmaterials1", 5),)),
    "531007": (1, (("bmaterials1", 6),)), "531008": (1, (("bmaterials1", 7),)),
    "531009": (1, (("bmaterials1", 5),)), "531010": (1, (("bmaterials1", 6),)),
    "531011": (1, (("bmaterials1", 7),)), "531012": (1, (("bmaterials1", 5),)),
    "531013": (1, (("bmaterials1", 6),)), "531014": (1, (("bmaterials1", 7),)),
    "531015": (1, (("bmaterials1", 5),)), "531016": (1, (("bmaterials1", 6),)),
    "531017": (1, (("bmaterials1", 7),)), "531018": (1, (("bmaterials1", 5),)),
    "531019": (1, (("bmaterials1", 6),)), "531020": (1, (("bmaterials1", 7),)),
    "120000": (1, (("bmaterials2", 5),)), "120001": (1, (("bmaterials2", 6),)),
    "120002": (1, (("bmaterials2", 5),)), "120005": (1, (("bmaterials2", 6),)),
    "120006": (1, (("bmaterials2", 7),)), "120030": (1, (("bmaterials2", 5),)),
    "120031": (1, (("bmaterials2", 6),)), "120032": (1, (("bmaterials2", 7),)),
    "120040": (1, (("bmaterials2", 5),)), "120041": (1, (("bmaterials2", 6),)),
    "120042": (1, (("bmaterials2", 7),)),
    "332001": (1, (("bmaterials2", 5),)), "332002": (1, (("bmaterials2", 6),)),
    "332003": (1, (("bmaterials2", 5),)), "332004": (1, (("bmaterials2", 6),)),
    "332005": (1, (("bmaterials2", 7),)), "332006": (1, (("bmaterials2", 5),)),
    "332007": (1, (("bmaterials2", 6),)), "332008": (1, (("bmaterials2", 7),)),
    "332009": (1, (("bmaterials2", 5),)), "332010": (1, (("bmaterials2", 6),)),
    "332011": (1, (("bmaterials2", 7),)), "332012": (1, (("bmaterials2", 6),)),
    "332013": (1, (("bmaterials2", 7),)),
    "432001": (1, (("bmaterials2", 5),)), "432002": (1, (("bmaterials2", 6),)),
    "432003": (1, (("bmaterials2", 5),)), "432004": (1, (("bmaterials2", 6),)),
    "432005": (1, (("bmaterials2", 7),)), "432006": (1, (("bmaterials2", 5),)),
    "432007": (1, (("bmaterials2", 6),)), "432008": (1, (("bmaterials2", 7),)),
    "432009": (1, (("bmaterials2", 5),)), "432010": (1, (("bmaterials2", 6),)),
    "432011": (1, (("bmaterials2", 7),)), "432012": (1, (("bmaterials2", 6),)),
    "432013": (1, (("bmaterials2", 7),)),
    "532001": (1, (("bmaterials2", 5),)), "532002": (1, (("bmaterials2", 6),)),
    "532003": (1, (("bmaterials2", 5),)), "532004": (1, (("bmaterials2", 6),)),
    "532005": (1, (("bmaterials2", 7),)), "532006": (1, (("bmaterials2", 5),)),
    "532007": (1, (("bmaterials2", 6),)), "532008": (1, (("bmaterials2", 7),)),
    "532009": (1, (("bmaterials2", 5),)), "532010": (1, (("bmaterials2", 6),)),
    "532011": (1, (("bmaterials2", 7),)), "532012": (1, (("bmaterials2", 6),)),
    "532013": (1, (("bmaterials2", 7),)),
    "130000": (1, (("bmaterials3", 5),)), "130001": (1, (("bmaterials3", 6),)),
    "130002": (1, (("bmaterials3", 7),)), "130003": (1, (("bmaterials3", 5),)),
    "130004": (1, (("bmaterials3", 6),)), "130005": (1, (("bmaterials3", 7),)),
    "130030": (1, (("bmaterials3", 5),)), "130031": (1, (("bmaterials3", 6),)),
    "130032": (1, (("bmaterials3", 7),)), "130040": (1, (("bmaterials3", 5),)),
    "130041": (1, (("bmaterials3", 6),)), "130042": (1, (("bmaterials3", 7),)),
    "333001": (1, (("bmaterials3", 5),)), "333002": (1, (("bmaterials3", 6),)),
    "333003": (1, (("bmaterials3", 7),)), "333004": (1, (("bmaterials3", 5),)),
    "333005": (1, (("bmaterials3", 6),)), "333006": (1, (("bmaterials3", 7),)),
    "333007": (1, (("bmaterials3", 5),)), "333008": (1, (("bmaterials3", 6),)),
    "333009": (1, (("bmaterials3", 7),)), "333010": (1, (("bmaterials3", 5),)),
    "333011": (1, (("bmaterials3", 6),)), "333012": (1, (("bmaterials3", 7),)),
    "333013": (1, (("bmaterials3", 6),)), "333014": (1, (("bmaterials3", 7),)),
    "433001": (1, (("bmaterials3", 5),)), "433002": (1, (("bmaterials3", 6),)),
    "433003": (1, (("bmaterials3", 7),)), "433004": (1, (("bmaterials3", 5),)),
    "433005": (1, (("bmaterials3", 6),)), "433006": (1, (("bmaterials3", 7),)),
    "433007": (1, (("bmaterials3", 5),)), "433008": (1, (("bmaterials3", 6),)),
    "433009": (1, (("bmaterials3", 7),)), "433010": (1, (("bmaterials3", 5),)),
    "433011": (1, (("bmaterials3", 6),)), "433012": (1, (("bmaterials3", 7),)),
    "433013": (1, (("bmaterials3", 6),)), "433014": (1, (("bmaterials3", 7),)),
    "533001": (1, (("bmaterials3", 5),)), "533002": (1, (("bmaterials3", 6),)),
    "533003": (1, (("bmaterials3", 7),)), "533004": (1, (("bmaterials3", 5),)),
    "533005": (1, (("bmaterials3", 6),)), "533006": (1, (("bmaterials3", 7),)),
    "533007": (1, (("bmaterials3", 5),)), "533008": (1, (("bmaterials3", 6),)),
    "533009": (1, (("bmaterials3", 7),)), "533010": (1, (("bmaterials3", 5),)),
    "533011": (1, (("bmaterials3", 6),)), "533012": (1, (("bmaterials3", 7),)),
    "533013": (1, (("bmaterials3", 6),)), "533014": (1, (("bmaterials3", 7),)),
    "130050": (1, (("bmaterials1", 5),)), "130060": (1, (("bmaterials1", 6),)),
    "130061": (1, (("bmaterials1", 7),)), "130070": (1, (("bmaterials1", 5),)),
    "130006": (99, (("bmaterials3", 0),)), "130007": (99, (("bmaterials3", 0),)),
    "130008": (99, (("bmaterials3", 0),)), "130009": (99, (("bmaterials3", 0),)),
    "130100": (1, (("bmaterials1", 6),)), "130110": (1, (("bmaterials2", 6),)),
    "130120": (1, (("bmaterials3", 6),)), "130101": (1, (("bmaterials1", 7),)),
    "130111": (1, (("bmaterials2", 7),)), "130121": (1, (("bmaterials3", 7),)),
    "200000": (1, (("renown", 10),)), "230001": (1, (("renown", 10),)),
    "240001": (1, (("renown", 10),)), "250001": (1, (("renown", 10),)),
}

# buildingid -> [(名位lv, 该级修筑度需求, 升本级资历消耗, 升级需累计昌盛度, (该级捐献id...)), ...] 按 lv 升序
_BUILD_LEVELS = {
    "100": [(0, 0, 0, 0, ("10000", "40001", "40004", "50000", "50100")),
            (1, 4500, 150, 51, ("10001", "40001", "40004", "50000", "50100")),
            (2, 10500, 384, 815, ())],
    "101": [(0, 0, 0, 0, ("10000", "40001", "40004", "50000", "50100")),
            (1, 1500, 40, 87, ("10001", "40001", "40004", "50000", "50100")),
            (2, 3000, 132, 191, ("10001", "40001", "40004", "50000", "50100")),
            (3, 6000, 176, 479, ("10001", "40001", "40004", "50000", "50100")),
            (4, 9000, 325, 1559, ("10001", "40001", "40004", "50000", "50100")),
            (5, 13500, 520, 2349, ())],
    "102": [(0, 0, 0, 0, ("30000", "50002", "50102")),
            (1, 150, 48, 12, ("30001", "50002", "50102")),
            (2, 1650, 51, 33, ("30001", "50002", "50102")),
            (3, 3150, 54, 75, ("30001", "50002", "50102")),
            (4, 4650, 57, 105, ("30001", "50002", "50102")),
            (5, 6150, 60, 141, ("30002", "50002", "50102")),
            (6, 51150, 63, 189, ("30003", "50002", "50102")),
            (7, 123150, 66, 237, ())],
    "103": [(0, 0, 0, 0, ("20000", "40000", "50001", "50101")),
            (1, 150, 30, 27, ("20001", "40000", "50001", "50101")),
            (2, 300, 60, 39, ())],
    "104": [(0, 0, 0, 0, ("20000", "40000", "50001", "50101")),
            (1, 1500, 40, 63, ("20001", "40000", "50001", "50101")),
            (2, 3000, 44, 143, ("20001", "40000", "50001", "50101")),
            (3, 4500, 88, 383, ("20001", "40000", "50001", "50101")),
            (4, 7500, 288, 623, ("20001", "40000", "50001", "50101")),
            (5, 10500, 432, 943, ("20002", "40009", "50003", "50103")),
            (6, 16500, 975, 1494, ())],
    "105": [(0, 0, 0, 0, ("30000", "40000", "50002", "50102")),
            (1, 1500, 40, 63, ("30001", "40000", "50002", "50102")),
            (2, 3000, 44, 143, ("30001", "40000", "50002", "50102")),
            (3, 4500, 88, 383, ("30001", "40000", "50002", "50102")),
            (4, 7500, 288, 623, ("30001", "40000", "50002", "50102")),
            (5, 10500, 432, 943, ("30007", "40010", "50004", "50104")),
            (6, 16500, 975, 1494, ())],
    "106": [(0, 0, 0, 0, ("10000", "40000", "50000", "50100")),
            (1, 1500, 40, 63, ("10001", "40000", "50000", "50100")),
            (2, 3000, 44, 143, ("10001", "40000", "50000", "50100")),
            (3, 4500, 88, 383, ("10001", "40000", "50000", "50100")),
            (4, 7500, 288, 623, ("10001", "40000", "50000", "50100")),
            (5, 10500, 432, 943, ("10005", "40011", "50005", "50105")),
            (6, 16500, 975, 1494, ())],
    "107": [(0, 0, 0, 0, ("30000", "40002", "40005", "40007", "50002", "50102")),
            (1, 7200, 88, 303, ("30001", "40002", "40005", "40007", "50002", "50102")),
            (2, 30600, 180, 927, ("30001", "40002", "40005", "40007", "50002", "50102")),
            (3, 64800, 208, 2023, ())],
    "108": [(0, 0, 0, 0, ("10000", "40002", "40005", "40007", "50000", "50100")),
            (1, 5400, 80, 111, ("10001", "40002", "40005", "40007", "50000", "50100")),
            (2, 27000, 132, 567, ("10001", "40002", "40005", "40007", "50000", "50100")),
            (3, 59400, 192, 1303, ())],
    "109": [(0, 0, 0, 0, ("20000", "40003", "40006", "40008", "50001", "50101")),
            (1, 10800, 60, 45, ("20001", "40003", "40006", "40008", "50001", "50101")),
            (2, 27000, 176, 351, ("20001", "40003", "40006", "40008", "50001", "50101")),
            (3, 52200, 288, 831, ("20001", "40003", "40006", "40008", "50001", "50101")),
            (4, 90000, 480, 1263, ("20001", "40003", "40006", "40008", "50001", "50101")),
            (5, 144000, 624, 2483, ())],
    "110": [(0, 0, 0, 0, ("30005", "40003", "40006", "40008", "50002", "50102")),
            (1, 7200, 30, 57, ("30005", "40003", "40006", "40008", "50002", "50102")),
            (2, 19800, 132, 383, ("30005", "40003", "40006", "40008", "50002", "50102")),
            (3, 41400, 240, 703, ("30005", "40003", "40006", "40008", "50002", "50102")),
            (4, 75600, 420, 927, ("30005", "40003", "40006", "40008", "50002", "50102")),
            (5, 126000, 572, 1407, ())],
    "111": [(0, 0, 0, 0, ("10002", "40002", "40005", "40007", "50000", "50100")),
            (1, 3600, 30, 33, ("10002", "40002", "40005", "40007", "50000", "50100")),
            (2, 11880, 120, 95, ("10002", "40002", "40005", "40007", "50000", "50100")),
            (3, 24840, 176, 255, ("10002", "40002", "40005", "40007", "50000", "50100")),
            (4, 42480, 220, 463, ("10002", "40002", "40005", "40007", "50000", "50100")),
            (5, 64800, 384, 719, ())],
    "112": [(0, 0, 0, 0, ("20000", "50001", "50101")),
            (1, 1500, 30, 21, ("20001", "50001", "50101")),
            (2, 3750, 80, 69, ("20001", "50001", "50101")),
            (3, 6750, 200, 119, ("20001", "50001", "50101")),
            (4, 10500, 264, 239, ())],
    "113": [(0, 0, 0, 0, ("10000", "50000", "50100")),
            (1, 150, 120, 15, ())],
    "114": [(0, 0, 0, 0, ("10000", "40001", "40004", "50000", "50100")),
            (1, 3000, 80, 83, ("10001", "40001", "40004", "50000", "50100")),
            (2, 6750, 97, 160, ("10001", "40001", "40004", "50000", "50100")),
            (3, 11250, 106, 312, ("10001", "40001", "40004", "50000", "50100")),
            (4, 16500, 115, 512, ("10001", "40001", "40004", "50000", "50100")),
            (5, 22500, 140, 800, ("10001", "40001", "40004", "50000", "50100")),
            (6, 29250, 192, 983, ("10001", "40001", "40004", "50000", "50100")),
            (7, 36750, 210, 1254, ("10001", "40001", "40004", "50000", "50100"))],
    "115": [(0, 0, 0, 0, ("20000", "50001", "50101")),
            (1, 90, 90, 18, ())],
    "116": [(0, 0, 0, 0, ("60005", "60105", "60205")),
            (1, 6000, 88, 440, ("60306", "60406", "60506")),
            (2, 14250, 144, 656, ("60307", "60407", "60507")),
            (3, 24750, 192, 904, ("60308", "60408", "60508")),
            (4, 37500, 204, 1134, ("60309", "60409", "60509")),
            (5, 52500, 241, 1374, ("60310", "60410", "60510")),
            (6, 70500, 286, 1694, ())],
}

# donateid -> (材料id, 数量, 修筑度, 资历, 佳绩, 有解锁条件)
_DONATE_TABLE = {
    "10000": ("bmaterials1", 5, 10, 10, 0, 0),
    "10001": ("bmaterials1", 10, 20, 10, 8, 0),
    "10002": ("bmaterials1", 10, 20, 10, 8, 1),
    "10005": ("bmaterials1", 10, 20, 10, 8, 1),
    "20000": ("bmaterials2", 5, 10, 10, 0, 0),
    "20001": ("bmaterials2", 10, 20, 10, 8, 0),
    "20002": ("bmaterials2", 10, 20, 10, 8, 1),
    "30000": ("bmaterials3", 5, 10, 10, 0, 0),
    "30001": ("bmaterials3", 10, 20, 10, 8, 0),
    "30002": ("bmaterials3", 20, 20, 10, 24, 1),
    "30003": ("bmaterials3", 30, 20, 10, 40, 1),
    "30004": ("bmaterials3", 30, 20, 10, 40, 1),
    "30005": ("bmaterials3", 10, 20, 10, 8, 1),
    "30007": ("bmaterials3", 10, 20, 10, 8, 1),
    "40000": ("amartial", 720, 10, 0, 0, 1),
    "40001": ("amartial", 720, 10, 0, 0, 1),
    "40002": ("amartial", 720, 10, 0, 0, 1),
    "40003": ("amartial", 720, 10, 0, 0, 1),
    "40004": ("dmartial", 32, 10, 0, 0, 1),
    "40005": ("dmartial", 32, 10, 0, 0, 1),
    "40006": ("dmartial", 32, 10, 0, 0, 1),
    "40007": ("bmartial", 80, 10, 0, 0, 1),
    "40008": ("bmartial", 80, 10, 0, 0, 1),
    "40009": ("amartial", 720, 10, 0, 0, 1),
    "40010": ("amartial", 720, 10, 0, 0, 1),
    "40011": ("amartial", 720, 10, 0, 0, 1),
    "50000": ("bmaterials1", 5, 20, 10, 0, 1),
    "50001": ("bmaterials2", 5, 20, 10, 0, 1),
    "50002": ("bmaterials3", 5, 20, 10, 0, 1),
    "50003": ("bmaterials2", 5, 20, 10, 0, 1),
    "50004": ("bmaterials3", 5, 20, 10, 0, 1),
    "50005": ("bmaterials1", 5, 20, 10, 0, 1),
    "50100": ("bmaterials1", 10, 40, 10, 8, 1),
    "50101": ("bmaterials2", 10, 40, 10, 8, 1),
    "50102": ("bmaterials3", 10, 40, 10, 8, 1),
    "50103": ("bmaterials2", 10, 40, 10, 8, 1),
    "50104": ("bmaterials3", 10, 40, 10, 8, 1),
    "50105": ("bmaterials1", 10, 40, 10, 8, 1),
    "60005": ("bmaterials1", 5, 10, 10, 0, 1),
    "60105": ("bmaterials2", 5, 10, 10, 0, 1),
    "60205": ("bmaterials3", 5, 10, 10, 0, 1),
    "60306": ("bmaterials1", 10, 20, 10, 8, 1),
    "60307": ("bmaterials1", 10, 20, 10, 8, 1),
    "60308": ("bmaterials1", 10, 20, 10, 8, 1),
    "60309": ("bmaterials1", 10, 20, 10, 8, 1),
    "60310": ("bmaterials1", 10, 20, 10, 8, 1),
    "60311": ("bmaterials1", 10, 20, 10, 8, 1),
    "60312": ("bmaterials1", 10, 20, 10, 8, 1),
    "60313": ("bmaterials1", 10, 20, 10, 8, 1),
    "60315": ("bmaterials1", 10, 20, 10, 8, 1),
    "60406": ("bmaterials2", 10, 20, 10, 8, 1),
    "60407": ("bmaterials2", 10, 20, 10, 8, 1),
    "60408": ("bmaterials2", 10, 20, 10, 8, 1),
    "60409": ("bmaterials2", 10, 20, 10, 8, 1),
    "60410": ("bmaterials2", 10, 20, 10, 8, 1),
    "60411": ("bmaterials2", 10, 20, 10, 8, 1),
    "60412": ("bmaterials2", 10, 20, 10, 8, 1),
    "60413": ("bmaterials2", 10, 20, 10, 8, 1),
    "60415": ("bmaterials2", 10, 20, 10, 8, 1),
    "60506": ("bmaterials3", 10, 20, 10, 8, 1),
    "60507": ("bmaterials3", 10, 20, 10, 8, 1),
    "60508": ("bmaterials3", 10, 20, 10, 8, 1),
    "60509": ("bmaterials3", 10, 20, 10, 8, 1),
    "60510": ("bmaterials3", 10, 20, 10, 8, 1),
    "60511": ("bmaterials3", 10, 20, 10, 8, 1),
    "60512": ("bmaterials3", 10, 20, 10, 8, 1),
    "60513": ("bmaterials3", 10, 20, 10, 8, 1),
    "60515": ("bmaterials3", 10, 20, 10, 8, 1),
}

_DONATE_NUM_MAX = 10        # 每日捐献次数上限(上游无抓包, mock 设定)
_SPEEDUP_SEC_PER_POINT = 300  # 每点勤建之志加速 5 分钟(对齐客户端"可加速时间 cost*5 分钟"文案)

# 任务完成奖励落在 bucket 的字段(其余视为材料/学识货币)
_BUCKET_AWARD_FIELDS = frozenset(("reputation", "sgbpoint", "renown", "donate", "gbpoint"))


def _material_balance(ctx, userid, item_id):
    account = ctx["state"]._state.get("accounts", {}).get(str(userid)) or {}
    currencies = account.get("currencies") if isinstance(account, dict) else {}
    archive = ctx["state"].get_archive(userid) or {}
    return max(_as_int(archive.get(item_id), 0),
               _as_int((currencies or {}).get(item_id), 0))


def _material_set(ctx, userid, item_id, value):
    """材料余额双写: 货币账户为准, 存档同步(客户端上传 RoleData 会覆盖存档)。"""
    account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
    currencies = account.setdefault("currencies", {})
    currencies[item_id] = value
    archive = ctx["state"].get_archive(userid)
    if isinstance(archive, dict) and archive:
        archive[item_id] = value
        ctx["state"].put_archive(userid, archive)


def _build_entry(bucket, build_type_id):
    """buildList 中该建筑条目(不存在则按 lv0 补建)。"""
    build_list = bucket.setdefault("buildList", copy.deepcopy(DEFAULT_BUILD_LIST))
    if not isinstance(build_list, list):
        build_list = copy.deepcopy(DEFAULT_BUILD_LIST)
        bucket["buildList"] = build_list
    for build in build_list:
        if isinstance(build, dict) and str(build.get("buildTypeId")) == build_type_id:
            return build
    entry = {"buildTypeId": build_type_id, "buildLv": 0, "buildTeacherExp": 0, "state": 0}
    build_list.append(entry)
    return entry


def _build_level_row(build_type_id, lv):
    levels = _BUILD_LEVELS.get(build_type_id) or []
    for row in levels:
        if row[0] == lv:
            return row
    return None


@route(["POST"], "start_teacherBuild_task")
def start_teacher_build_task(ctx):
    """开始师门日常挂机任务(TeacherBuildSystem:startTeacherBuildTask)。

    请求: {taskId, familyId}; 成功: {startTime}
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    task_id = str(body.get("taskId") or "")
    task = _TASK_TABLE.get(task_id)
    if task is None:
        return build_response_body({}, errcode=1, errmsg="任务不存在: %s" % task_id)
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        guaji = bucket.get("guajiInfo")
        if isinstance(guaji, dict) and guaji.get("taskId"):
            return build_response_body({}, errcode=2, errmsg="已有进行中的师门日常")
        if _as_int(bucket.get("taskNumDay"), 0) >= _task_num_limit(bucket):
            return build_response_body({}, errcode=3, errmsg="今日师门日常次数已用完")
        start_time = int(time.time())
        bucket["guajiInfo"] = {"taskId": task_id, "startTime": start_time, "speedUpTime": 0}
        ctx["state"]._changed()
    return build_response_body({"startTime": start_time})


@route(["POST"], "stop_teacherBuild_task")
def stop_teacher_build_task(ctx):
    """终止师门日常挂机任务(TeacherBuildSystem:stopTeacherBuildTask)。

    请求: {taskId, familyId}; 成功: 无数据消费, 清空挂机状态。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    task_id = str(body.get("taskId") or "")
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        guaji = bucket.get("guajiInfo")
        if not isinstance(guaji, dict) or guaji.get("taskId") != task_id:
            return build_response_body({}, errcode=1, errmsg="当前没有进行中的师门日常")
        bucket["guajiInfo"] = {}
        ctx["state"]._changed()
    return build_response_body({})


@route(["POST"], "speedUp_teacherBuild_task")
def speed_up_teacher_build_task(ctx):
    """加速师门日常任务(TeacherBuildSystem:speedUpTeacherBuildTask)。

    请求: {taskId, cost, familyId}; 成功: {cost, speedUpTime}
    客户端回调: diligent -= cost; guajiInfo.speedUpTime += speedUpTime。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    task_id = str(body.get("taskId") or "")
    cost = _as_int(body.get("cost"), 0)
    if cost <= 0:
        return build_response_body({}, errcode=1, errmsg="加速数量无效")
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        guaji = bucket.get("guajiInfo")
        if not isinstance(guaji, dict) or guaji.get("taskId") != task_id:
            return build_response_body({}, errcode=1, errmsg="当前没有进行中的师门日常")
        diligent = _as_int(bucket.get("diligent"), 0)
        if diligent < cost:
            return build_response_body({}, errcode=2, errmsg="勤建之志不足")
        speed_up_time = cost * _SPEEDUP_SEC_PER_POINT
        bucket["diligent"] = diligent - cost
        guaji["speedUpTime"] = _as_int(guaji.get("speedUpTime"), 0) + speed_up_time
        ctx["state"]._changed()
    return build_response_body({"cost": cost, "speedUpTime": speed_up_time})


@route(["POST"], "finish_teacherBuild_task")
def finish_teacher_build_task(ctx):
    """完成师门日常任务并发放奖励(TeacherBuildSystem:finishTeacherBuildTask)。

    请求: {taskId, familyId}
    成功: {taskNumDay, reputation, sgbpoint, renown, reward: [[id, num], ...]}
    校验: 挂机任务匹配 + 已到完成时间(startTime+时长*3600-加速) + 当日次数未满。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    task_id = str(body.get("taskId") or "")
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        guaji = bucket.get("guajiInfo")
        if not isinstance(guaji, dict) or guaji.get("taskId") != task_id:
            return build_response_body({}, errcode=1, errmsg="当前没有进行中的师门日常")
        task = _TASK_TABLE.get(task_id)
        if task is None:
            return build_response_body({}, errcode=1, errmsg="任务不存在: %s" % task_id)
        end_time = (_as_int(guaji.get("startTime"), 0) + task[0] * 3600
                    - _as_int(guaji.get("speedUpTime"), 0))
        if int(time.time()) < end_time:
            return build_response_body({}, errcode=2, errmsg="任务尚未完成")
        if _as_int(bucket.get("taskNumDay"), 0) >= _task_num_limit(bucket):
            return build_response_body({}, errcode=3, errmsg="今日师门日常次数已用完")

        reward = []
        for award_id, num in task[1]:
            reward.append([award_id, num])
            if award_id in _BUCKET_AWARD_FIELDS:
                bucket[award_id] = _as_int(bucket.get(award_id), 0) + num
                if award_id == "renown":
                    # 累计获取资历(建树条件 srenown), 与当前余额分开统计
                    bucket["srenown"] = _as_int(bucket.get("srenown"), 0) + num
            else:
                _material_set(ctx, userid, award_id,
                              _material_balance(ctx, userid, award_id) + num)
        bucket["taskNumDay"] = _as_int(bucket.get("taskNumDay"), 0) + 1
        bucket["guajiInfo"] = {}
        ctx["state"]._changed()
    return build_response_body({
        "taskNumDay": bucket["taskNumDay"],
        "reputation": bucket["reputation"],
        "sgbpoint": bucket["sgbpoint"],
        "renown": bucket["renown"],
        "reward": reward,
    })


@route(["POST"], "updata_teacherBuild_flag")
def updata_teacher_build_flag(ctx):
    """更新师门建设标记(TeacherBuildSystem:updataTeacherBuildFlag, 地图事件结果调用)。

    请求: {addFlags, deleteFlags, familyId}; 成功: {} (客户端不消费数据)。
    标记存入 bucket.flags; mock 的任务列表不做 sign 解锁判定, 仅存储。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        flags = bucket.setdefault("flags", [])
        if not isinstance(flags, list):
            flags = []
            bucket["flags"] = flags
        for flag in body.get("addFlags") or []:
            flag = str(flag)
            if flag and flag not in flags:
                flags.append(flag)
        for flag in body.get("deleteFlags") or []:
            flag = str(flag)
            while flag in flags:
                flags.remove(flag)
        ctx["state"]._changed()
    return build_response_body({})


@route(["POST"], "get_teacherBuild_donateInfo")
def get_teacher_build_donate_info(ctx):
    """获取建筑捐献信息(TeacherBuildSystem:getTeacherBuildDonateInfo)。

    请求: {buildTypeId, familyId}
    成功: {buildTeacherExp, donateNum, donateMax, donateList: [{donateId, state}]}
    donateList 取当前名位等级对应的捐献项(sectBuildInfo donateid);
    state: 0 无条件(简按钮) / 1 有解锁条件(带需求文案按钮), 仅影响客户端展示。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    build_type_id = str(body.get("buildTypeId") or "")
    if build_type_id not in _BUILDING_IDS:
        return build_response_body({}, errcode=1, errmsg="建筑不存在: %s" % build_type_id)
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        entry = _build_entry(bucket, build_type_id)
        lv = min(_as_int(entry.get("buildLv"), 0), len(_BUILD_LEVELS[build_type_id]) - 1)
        row = _build_level_row(build_type_id, lv) or _BUILD_LEVELS[build_type_id][-1]
        donate_list = [
            {"donateId": donate_id, "state": _DONATE_TABLE.get(donate_id, (0,) * 6)[5]}
            for donate_id in row[4]
        ]
        result = {
            "buildTeacherExp": _as_int(entry.get("buildTeacherExp"), 0),
            "donateNum": _as_int(bucket.get("donateNum"), 0),
            "donateMax": _DONATE_NUM_MAX,
            "donateList": donate_list,
        }
    return build_response_body(result)


@route(["POST"], "donate_teacherBuild")
def donate_teacher_build(ctx):
    """捐献建筑材料(TeacherBuildSystem:donateTeacherBuild)。

    请求: {buildTypeId, familyId, donateId, donateState, currencyVersion}
    成功: {renown, donate, buildTeacherExp, currencyVersion, reward: {upresources, addRenown, addDonate}}
    errcode: 2 材料不足 / 3 每日次数用完 / 4 建筑修筑度已满。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    build_type_id = str(body.get("buildTypeId") or "")
    donate_id = str(body.get("donateId") or "")
    if build_type_id not in _BUILDING_IDS:
        return build_response_body({}, errcode=1, errmsg="建筑不存在: %s" % build_type_id)
    donate = _DONATE_TABLE.get(donate_id)
    if donate is None:
        return build_response_body({}, errcode=1, errmsg="捐献项不存在: %s" % donate_id)
    item_id, item_num, up_res, add_renown, add_donate, _locked = donate
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        entry = _build_entry(bucket, build_type_id)
        exp = _as_int(entry.get("buildTeacherExp"), 0)
        top_max = _BUILD_LEVELS[build_type_id][-1][1]
        if exp >= top_max:
            return build_response_body(
                {"buildTeacherExp": exp}, errcode=4, errmsg="建筑修筑度已满")
        if _as_int(bucket.get("donateNum"), 0) >= _DONATE_NUM_MAX:
            return build_response_body({}, errcode=3, errmsg="今日捐献次数已用完")
        balance = _material_balance(ctx, userid, item_id)
        if balance < item_num:
            return build_response_body(
                {}, errcode=2, errmsg="%s不足, 需要%d" % (item_id, item_num))

        _material_set(ctx, userid, item_id, balance - item_num)
        granted = min(up_res, top_max - exp)
        entry["buildTeacherExp"] = exp + granted
        bucket["renown"] = _as_int(bucket.get("renown"), 0) + add_renown
        if add_renown:
            bucket["srenown"] = _as_int(bucket.get("srenown"), 0) + add_renown
        bucket["donate"] = _as_int(bucket.get("donate"), 0) + add_donate
        bucket["donateNum"] = _as_int(bucket.get("donateNum"), 0) + 1

        account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
        archive = ctx["state"].get_archive(userid) or {}
        currency_version = max(
            _as_int(archive.get("currencyVersion"), 0),
            _as_int(body.get("currencyVersion"), 0),
            _as_int(account.get("currency_version"), 0),
        ) + 1
        account["currency_version"] = currency_version
        if isinstance(archive, dict) and archive:
            archive["currencyVersion"] = currency_version
            ctx["state"].put_archive(userid, archive)
        ctx["state"]._changed()
    return build_response_body({
        "renown": bucket["renown"],
        "donate": bucket["donate"],
        "buildTeacherExp": entry["buildTeacherExp"],
        "currencyVersion": currency_version,
        "reward": {"upresources": granted, "addRenown": add_renown, "addDonate": add_donate},
    })


@route(["POST"], "upgrade_teacherBuild")
def upgrade_teacher_build(ctx):
    """师门建筑名位升级(TeacherBuildSystem:upgradeTeacherBuild)。

    请求: {buildTypeId, familyId}
    成功: {buildLv, renown}
    校验(对齐 sectBuildInfo condition/cescalation 与客户端名位<=建筑等级判定):
      修筑度达到下一级 + 累计昌盛度达标 + 资历足够(升级消耗资历)。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    build_type_id = str(body.get("buildTypeId") or "")
    if build_type_id not in _BUILDING_IDS:
        return build_response_body({}, errcode=1, errmsg="建筑不存在: %s" % build_type_id)
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        entry = _build_entry(bucket, build_type_id)
        curr_lv = _as_int(entry.get("buildLv"), 0)
        levels = _BUILD_LEVELS[build_type_id]
        next_row = _build_level_row(build_type_id, curr_lv + 1)
        if next_row is None:
            return build_response_body({}, errcode=1, errmsg="当前名位等级已是最高级")
        _lv, need_exp, cost_renown, need_sgbpoint, _ids = next_row
        exp = _as_int(entry.get("buildTeacherExp"), 0)
        if exp < need_exp:
            return build_response_body(
                {}, errcode=2, errmsg="建筑修筑度不足, 需达到%d" % need_exp)
        if _as_int(bucket.get("sgbpoint"), 0) < need_sgbpoint:
            return build_response_body(
                {}, errcode=3, errmsg="累计贡献昌盛度不足, 需达到%d" % need_sgbpoint)
        renown = _as_int(bucket.get("renown"), 0)
        if renown < cost_renown:
            return build_response_body(
                {}, errcode=4, errmsg="资历不足, 升级需消耗%d" % cost_renown)

        entry["buildLv"] = curr_lv + 1
        bucket["renown"] = renown - cost_renown
        ctx["state"]._changed()
        new_lv = entry["buildLv"]
        new_renown = bucket["renown"]
    return build_response_body({"buildLv": new_lv, "renown": new_renown})


# ---------------------------------------------------------------------------
# 师门指点(玄络破境/冲脉加速, TeacherGuidance + HiddenMeridianSystem)
# 客户端契约:
#   get_sectGuidance_info  请求{familyId}    -> {guidanceCount, speedUpTime}
#   execute_sectGuidance   请求{familyId, id, version}
#                                          -> {guidanceCount, speedUpTime, version}
# 规则(客户端规则文案): 每周一0点按师门名衔刷新次数; 名衔越高次数越多/效果越好;
#   次数耗尽时客户端仍会请求(触发回档返还), 服务端拒绝并回 errmsg。
# mock 未实现师门建树名衔, 次数/效果取基础值; version 由客户端存档携带、
#   服务端不校验只回递增值(与隐脉其他接口未实现的状态自洽)。
# ---------------------------------------------------------------------------
_GUIDANCE_WEEKLY_COUNT = 2   # 每周基础指点次数(TeacherGuidance.lua 默认值)
_GUIDANCE_SPEEDUP_TIME = 3600  # 单次指点减少 1 小时修炼时间


def _iso_week():
    year, week, _weekday = datetime.date.today().isocalendar()
    return "%d-W%02d" % (year, week)


def _guidance_state(ctx, userid, family_id):
    """指点状态(用户级, 与门派无关): 跨周(周一0点)自动重置为满次数。

    存 user 级而非 family 级: test_reset_sect_guidance 为 GET 无 body,
    familyId 只能取默认值, 存 family 桶会导致重置与读取错位。
    """
    root = ctx["state"]._state.setdefault("teacher_build", {})
    user = root.setdefault(str(userid), {"families": {}})
    guidance = user.get("guidance")
    if not isinstance(guidance, dict) or guidance.get("week") != _iso_week():
        guidance = {"week": _iso_week(), "count": _GUIDANCE_WEEKLY_COUNT}
        user["guidance"] = guidance
        ctx["state"]._changed()
    return guidance


@route(["POST"], "get_sectGuidance_info")
def get_sect_guidance_info(ctx):
    """获取师门指点信息(TeacherGuidance:init)。

    请求: {familyId}; 成功: {guidanceCount, speedUpTime}
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        guidance = _guidance_state(ctx, userid, family_id)
        count = _as_int(guidance.get("count"), 0)
    return build_response_body({
        "guidanceCount": count,
        "speedUpTime": _GUIDANCE_SPEEDUP_TIME,
    })


@route(["POST"], "execute_sectGuidance")
def execute_sect_guidance(ctx):
    """师门指点(TeacherGuidance:giveAdvice): 加速玄络破境/冲脉。

    请求: {familyId, id=隐脉图/窍关id, version=隐脉数据版本}
    成功: {guidanceCount, speedUpTime, version}
    客户端回调: finishTime -= speedUpTime; __version = data.version。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        guidance = _guidance_state(ctx, userid, family_id)
        count = _as_int(guidance.get("count"), 0)
        if count <= 0:
            return build_response_body(
                {}, errcode=1, errmsg="本周师门指点次数已耗尽，无法指点解惑")
        guidance["count"] = count - 1
        ctx["state"]._changed()
        version = _as_int(body.get("version"), 0) + 1
    return build_response_body({
        "guidanceCount": guidance["count"],
        "speedUpTime": _GUIDANCE_SPEEDUP_TIME,
        "version": version,
    })


@route(["GET"], "test_reset_sect_guidance")
def test_reset_sect_guidance(ctx):
    """师门指点刷新测试接口(HttpManager:testResetSectGuidance): 重置本周次数。"""
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    with ctx["state"]._lock:
        guidance = _guidance_state(ctx, userid, None)
        guidance["count"] = _GUIDANCE_WEEKLY_COUNT
        ctx["state"]._changed()
    return build_response_body({"guidanceCount": _GUIDANCE_WEEKLY_COUNT})


# ---------------------------------------------------------------------------
# 师门建树(名绩, TeacherFeat)
# 客户端契约:
#   get_teacherFeat_info    请求{familyId}                    -> {list, featscount}
#   get_teacherFeat_reward  请求{familyId, featId, dataVer}   -> {featscount, reward, dataVer, msg}
#     reward 为商品列表 [{id, num}](GoodsHelper:fromNetworkGrantGoods 客户端本地发货):
#       400030=名绩点(itype4 属性), 600000/600001/600002=称号(itype9, 按阵营)
#     客户端同时 setFeatScount(data.featscount) 与 setDataVersion(data.dataVer)。
#   名衔/职阶名称由客户端按 featscount + featClassLevel.lua 自行计算, 服务端无需下发。
# 建树条件(featInfo.lua Completion): sgbpoint/reputation/srenown/sdonate 为累计值,
#   noloyalsect=从未离开师门(mock 未实现叛师, 恒为达成); label 2 称号建树按阵营三选一。
# ---------------------------------------------------------------------------
# featsid -> (label, camp, (条件类型, 阈值), (奖励商品id, 数量))
_FEAT_TABLE = {
    "10000": (1, 0, ("sgbpoint", 190), ("400030", 35)),
    "10001": (1, 0, ("sgbpoint", 770), ("400030", 55)),
    "10002": (1, 0, ("sgbpoint", 1730), ("400030", 80)),
    "10003": (1, 0, ("sgbpoint", 4040), ("400030", 105)),
    "10004": (1, 0, ("sgbpoint", 7340), ("400030", 130)),
    "10005": (1, 0, ("sgbpoint", 11480), ("400030", 158)),
    "11000": (1, 0, ("reputation", 370), ("400030", 35)),
    "11001": (1, 0, ("reputation", 1040), ("400030", 55)),
    "11002": (1, 0, ("reputation", 2660), ("400030", 80)),
    "11003": (1, 0, ("reputation", 6990), ("400030", 105)),
    "11004": (1, 0, ("reputation", 16290), ("400030", 130)),
    "11005": (1, 0, ("reputation", 35810), ("400030", 158)),
    "12000": (1, 0, ("srenown", 1200), ("400030", 18)),
    "12001": (1, 0, ("srenown", 2400), ("400030", 28)),
    "12002": (1, 0, ("srenown", 4400), ("400030", 40)),
    "12003": (1, 0, ("srenown", 6900), ("400030", 53)),
    "12004": (1, 0, ("srenown", 9900), ("400030", 65)),
    "12005": (1, 0, ("srenown", 17500), ("400030", 79)),
    "13000": (1, 0, ("sdonate", 960), ("400030", 18)),
    "13001": (1, 0, ("sdonate", 1920), ("400030", 28)),
    "13002": (1, 0, ("sdonate", 3520), ("400030", 40)),
    "13003": (1, 0, ("sdonate", 5520), ("400030", 53)),
    "13004": (1, 0, ("sdonate", 7920), ("400030", 65)),
    "13005": (1, 0, ("sdonate", 14000), ("400030", 79)),
    "100001": (2, 1, ("noloyalsect", 1), ("600000", 1)),
    "100002": (2, 2, ("noloyalsect", 1), ("600001", 1)),
    "100003": (2, 3, ("noloyalsect", 1), ("600002", 1)),
}

_FEAT_GOODS_NAME = {
    "400030": "名绩点",
    "600000": "称号丹心赤忱",
    "600001": "称号肝胆相照",
    "600002": "称号义薄云天",
}


def _feat_stat_value(bucket, stat):
    """建树条件对应的累计统计值。"""
    if stat == "sgbpoint":
        return _as_int(bucket.get("sgbpoint"), 0)
    if stat == "reputation":
        return _as_int(bucket.get("reputation"), 0)
    if stat == "srenown":
        # 累计获取资历: 取累计计数与当前余额的较大值(兼容旧 bucket 无累计字段)
        return max(_as_int(bucket.get("srenown"), 0), _as_int(bucket.get("renown"), 0))
    if stat == "sdonate":
        return _as_int(bucket.get("donate"), 0)
    if stat == "noloyalsect":
        return 1  # mock 未实现叛师, 视为从未离开师门
    return 0


def _feat_list(bucket, family_id):
    """按门派阵营过滤建树条目并计算状态: 0未达成/1可领取/2已领取。"""
    camp = _FAMILY_CAMP.get(family_id, 0)
    claimed = bucket.setdefault("featClaimed", [])
    if not isinstance(claimed, list):
        claimed = []
        bucket["featClaimed"] = claimed
    result = []
    for feat_id in sorted(_FEAT_TABLE, key=int):
        _label, feat_camp, (stat, threshold), _award = _FEAT_TABLE[feat_id]
        if feat_camp != 0 and feat_camp != camp:
            continue
        if feat_id in claimed:
            state = 2
        elif _feat_stat_value(bucket, stat) >= threshold:
            state = 1
        else:
            state = 0
        result.append({"id": feat_id, "state": state})
    return result


@route(["POST"], "get_teacherFeat_info")
def get_teacher_feat_info(ctx):
    """获取师门名绩数据(TeacherBuildSystem:getTeacherFeatData)。

    请求: {familyId}; 成功: {list: [{id, state}], featscount}
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        result = {
            "list": _feat_list(bucket, family_id),
            "featscount": _as_int(bucket.get("featscount"), 0),
        }
    return build_response_body(result)


@route(["POST"], "get_teacherFeat_reward")
def get_teacher_feat_reward(ctx):
    """领取师门名绩奖励(TeacherBuildSystem:getTeacherFeatReward)。

    请求: {familyId, featId, dataVer}
    成功: {featscount, reward: [{id, num}], dataVer, msg}
    奖励按商品列表返回, 客户端 GoodsHelper 本地发放(名绩点加属性/称号入称号栏);
    服务端同步 bucket.featscount 并提升存档 dataVer。
    errcode: 1 建树不存在 / 2 已领取 / 3 条件未达成。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    feat_id = str(body.get("featId") or "")
    feat = _FEAT_TABLE.get(feat_id)
    if feat is None:
        return build_response_body({}, errcode=1, errmsg="师门建树不存在 featId = %s" % feat_id)
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        claimed = bucket.setdefault("featClaimed", [])
        if not isinstance(claimed, list):
            claimed = []
            bucket["featClaimed"] = claimed
        if feat_id in claimed:
            return build_response_body({}, errcode=2, errmsg="该名绩奖励已领取")
        _label, feat_camp, (stat, threshold), (goods_id, goods_num) = feat
        camp = _FAMILY_CAMP.get(family_id, 0)
        if feat_camp != 0 and feat_camp != camp:
            return build_response_body({}, errcode=1, errmsg="师门建树不存在 featId = %s" % feat_id)
        if _feat_stat_value(bucket, stat) < threshold:
            return build_response_body({}, errcode=3, errmsg="名绩达成条件尚未满足")

        claimed.append(feat_id)
        featscount = _as_int(bucket.get("featscount"), 0) + goods_num
        bucket["featscount"] = featscount
        archive = ctx["state"].get_archive(userid) or {}
        data_ver = max(_as_int(archive.get("dataVer"), 0),
                       _as_int(body.get("dataVer"), 0)) + 1
        if isinstance(archive, dict) and archive:
            archive["dataVer"] = data_ver
            ctx["state"].put_archive(userid, archive)
        ctx["state"]._changed()
    return build_response_body({
        "featscount": featscount,
        "reward": [{"id": goods_id, "num": goods_num}],
        "dataVer": data_ver,
        "msg": "获得%d%s" % (goods_num, _FEAT_GOODS_NAME.get(goods_id, goods_id)),
    })


# 客户端自带的师门建设测试接口 HttpManager:testTeacherBuildAction(未被 UI 调用, 仅存根)。
# 上游语义未知, mock 定义为统计种子注入便于验证: type 1=昌盛度 2=功绩 3=资历(含累计)
# 4=佳绩 5=勤建之志; number 为增量。返回注入后的师门建设数据。
_TEST_ACTION_FIELDS = {1: "sgbpoint", 2: "reputation", 3: "renown", 4: "donate", 5: "diligent"}


@route(["POST"], "test_sect_build_action")
def test_sect_build_action(ctx):
    """师门建设测试接口(mock 统计种子注入, 语义见 _TEST_ACTION_FIELDS)。"""
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    action_type = _as_int(body.get("type"), 0)
    field = _TEST_ACTION_FIELDS.get(action_type)
    number = _as_int(body.get("number"), 0)
    if field is None or number == 0:
        return build_response_body({}, errcode=1, errmsg="无效的测试参数 type=%s number=%s"
                                   % (action_type, number))
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        bucket[field] = _as_int(bucket.get(field), 0) + number
        if field == "renown":
            bucket["srenown"] = _as_int(bucket.get("srenown"), 0) + number
        ctx["state"]._changed()
        result = _info_payload(bucket)
    return build_response_body(result)


# ---------------------------------------------------------------------------
# 振兴门派(撷英阁建筑效果, TeacherBuildPromote)
# 客户端契约:
#   get_sectRevitalization_info   请求{familyId}
#     -> {buildReward: [{id, number} x2], buildConditionText, buildingList}
#        buildReward[0]=玩家资源(资历) buildReward[1]=建筑资源(修筑度, id 固定 upresources);
#        buildingList: {buildTypeId, state(0可分配/1已满级), buildName, buildLv,
#                       buildCurrentExp, buildMaxExp}, buildLv/满级按修筑度推导,
#        buildMaxExp 为下一级累计修筑度阈值(与捐献界面进度口径一致)。
#   get_sectRevitalization_reward 请求{familyId, buildTypeId}
#     -> errcode 0 即可(客户端不读 data)。
# 每日 0 点刷新分配次数(mock 每日 1 次); 分配后建筑修筑度与玩家资历同增,
# 修筑度超出建筑顶级上限的部分丢弃(对齐客户端弹窗文案)。
# ---------------------------------------------------------------------------
_BUILD_NAMES = {
    "100": "勤务阁", "101": "储宝库", "102": "恩义祠", "103": "论武堂",
    "104": "土窑", "105": "砖窑", "106": "木坊", "107": "泰安阁",
    "108": "擢升阁", "109": "天宝斋", "110": "盈宝斋", "111": "集物堂",
    "112": "弘物堂", "113": "叙功堂", "114": "奉功堂", "115": "撷英阁",
    "116": "易物堂",
}

_PROMOTE_DAILY_RENOWN = 10       # 每日可分配资历(玩家获得)
_PROMOTE_DAILY_UPRESOURCES = 100  # 每日可分配修筑度(注入建筑)


@route(["POST"], "get_sectRevitalization_info")
def get_sect_revitalization_info(ctx):
    """振兴门派信息(TeacherBuildPromote:init)。

    请求: {familyId}; 成功: {buildReward, buildConditionText, buildingList}
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        building_list = []
        for build_type_id in sorted(_BUILD_LEVELS, key=int):
            levels = _BUILD_LEVELS[build_type_id]
            entry = _build_entry(bucket, build_type_id)
            exp = _as_int(entry.get("buildTeacherExp"), 0)
            # 建筑等级按修筑度推导(与客户端 getBuildByExp 口径一致)
            lv = 0
            for row in levels:
                if exp >= row[1]:
                    lv = row[0]
            next_row = _build_level_row(build_type_id, lv + 1)
            building_list.append({
                "buildTypeId": build_type_id,
                "state": 1 if next_row is None else 0,
                "buildName": _BUILD_NAMES.get(build_type_id, build_type_id),
                "buildLv": lv,
                "buildCurrentExp": exp,
                "buildMaxExp": next_row[1] if next_row else levels[-1][1],
            })
        result = {
            "buildReward": [
                {"id": "renown", "number": _PROMOTE_DAILY_RENOWN},
                {"id": "upresources", "number": _PROMOTE_DAILY_UPRESOURCES},
            ],
            "buildConditionText": "无",
            "buildingList": building_list,
        }
    return build_response_body(result)


@route(["POST"], "get_sectRevitalization_reward")
def get_sect_revitalization_reward(ctx):
    """振兴门派分配(TeacherBuildPromote:doReward)。

    请求: {familyId, buildTypeId}; 成功: {} (客户端只看 errcode)。
    errcode: 1 建筑不存在 / 2 今日已分配 / 3 建筑已满级。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    build_type_id = str(body.get("buildTypeId") or "")
    if build_type_id not in _BUILDING_IDS:
        return build_response_body({}, errcode=1, errmsg="建筑不存在: %s" % build_type_id)
    family_id = _family_id(ctx)
    with ctx["state"]._lock:
        bucket = _bucket(ctx, userid, family_id)
        promote = bucket.get("promote")
        if not isinstance(promote, dict) or promote.get("day") != _today():
            promote = {"day": _today(), "done": False}
            bucket["promote"] = promote
        if promote.get("done"):
            return build_response_body({}, errcode=2, errmsg="今日已分配过，请明日再来")
        entry = _build_entry(bucket, build_type_id)
        exp = _as_int(entry.get("buildTeacherExp"), 0)
        top_max = _BUILD_LEVELS[build_type_id][-1][1]
        if exp >= top_max:
            return build_response_body({}, errcode=3, errmsg="该建筑已达到满级，无法分配")
        entry["buildTeacherExp"] = min(exp + _PROMOTE_DAILY_UPRESOURCES, top_max)
        bucket["renown"] = _as_int(bucket.get("renown"), 0) + _PROMOTE_DAILY_RENOWN
        bucket["srenown"] = _as_int(bucket.get("srenown"), 0) + _PROMOTE_DAILY_RENOWN
        promote["done"] = True
        ctx["state"]._changed()
    return build_response_body({})


# 可拜师门派表: fzjh_lua/assets/res/script/family/family.lua ["familys"] 中 familytype=1 的 id
# (含不显示在"门派类型"选择列表中的隐藏门派: 问情宫/财神帮/落月山庄/燕氏皇族/拜日教/
#  蓬莱岛/天竞门/永夜楼/幽冥教/万灵谷/虚渺宫/明教/海鲸帮/伏龙山/鸩羽山/雪山寺/天龙寺...)
# youxia(散人)/seclusion(归隐) 为 familytype=2, 不可通过 join_family 拜入。
_JOINABLE_FAMILY_IDS = frozenset({
    "baituoshan", "dali", "emei", "gaibang", "guanfu", "gumu", "haijing",
    "huashan", "jinqianbang", "kongtong", "kunlun", "luoyue", "mingjiao",
    "mizong", "murong", "quanzhen", "riyueshenjiao", "shaolin", "tangmen",
    "taohuadao", "tianjingmen", "tianshan", "tiezhang", "wudang", "wudu",
    "xingxiu", "yongyelou", "youming",
})

# 客户端 Family.lua changeFamilyNameMap: 老存档门派id -> 新id
_LEGACY_FAMILY_MAP = {
    "xiaoyao": "tianshan",
    "lingjiugong": "tianshan",
}


def _as_int(value, default=0):
    try:
        return int(value)
    except (TypeError, ValueError):
        return default


@route(["POST"], "join_family")
def join_family(ctx):
    """拜师加入门派(Role_Family:__joinFamily): 无门派(散人/归隐)状态下拜师时调用。

    请求: {familyId, currencyVersion}
    成功: {familyId, currencyVersion}
    客户端回调仅消费 data.currencyVersion; 角色门派数据以客户端上传
    (upload_user_file_3)为准, 服务端只在存档里同步镜像 family/isSeclusion,
    供 get_board/get_rank_list_4 等只读接口在客户端下次存档前也能读到新门派。
    """
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    body = _body(ctx)
    family_id = str(body.get("familyId") or "").strip()
    family_id = _LEGACY_FAMILY_MAP.get(family_id, family_id)
    if family_id not in _JOINABLE_FAMILY_IDS:
        return build_response_body({}, errcode=1, errmsg="门派不存在: %s" % family_id)

    with ctx["state"]._lock:
        account = ctx["state"]._state["accounts"].setdefault(str(userid), {"userid": userid})
        archive = ctx["state"].get_archive(userid)
        currency_version = max(
            _as_int((archive or {}).get("currencyVersion")),
            _as_int(body.get("currencyVersion")),
            _as_int(account.get("currency_version")),
        ) + 1
        account["currency_version"] = currency_version
        if isinstance(archive, dict) and archive:
            # 客户端 __apprenticeSuc: family = {name=门派id, level=师傅辈分+1}
            # 服务端不感知师傅辈分: 同门派重拜沿用原辈分, 否则回到第1代,
            # 稍后客户端上传 RoleData 会覆盖为真实辈分。
            old_family = archive.get("family")
            same_family = isinstance(old_family, dict) and old_family.get("name") == family_id
            old_level = _as_int(old_family.get("level"), 1) if same_family else 1
            archive["family"] = {"name": family_id, "level": old_level}
            archive.pop("isSeclusion", None)  # 客户端 setAttr("isSeclusion", nil)
            archive["currencyVersion"] = currency_version
            ctx["state"].put_archive(userid, archive)
        ctx["state"]._changed()
    return build_response_body({
        "familyId": family_id,
        "currencyVersion": currency_version,
    })
