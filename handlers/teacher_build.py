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


def _default_state(family_id):
    return {
        "familyId": family_id,
        "day": _today(),
        "diligent": 0,
        "gbpoint": 0,
        "sgbpoint": 0,
        "renown": 0,
        "renownLimit": 0,
        "donate": 0,
        "reputation": 0,
        "reputationLv": 0,
        "taskNumDay": 0,
        "taskNumLimit": 0,
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
            bucket["donate"] = 0
            bucket["speedUp"] = 0
            bucket["updated_at"] = int(time.time())
            changed = True
        if changed:
            ctx["state"]._changed()
        return bucket


def _info_payload(bucket):
    keys = (
        "familyId", "diligent", "gbpoint", "sgbpoint", "renown",
        "renownLimit", "donate", "reputation", "reputationLv",
        "taskNumDay", "taskNumLimit", "speedUp", "speedUpLimit",
        "buildState", "guajiInfo", "familyStates", "featscount",
        "prepareSkillLimit",
    )
    payload = {key: copy.deepcopy(bucket.get(key)) for key in keys}
    guaji_info = payload.get("guajiInfo")
    if not isinstance(guaji_info, dict) or not guaji_info.get("taskId"):
        payload["guajiInfo"] = {}
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
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    _bucket(ctx, userid, _family_id(ctx))
    return build_response_body([])
