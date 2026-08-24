# -*- coding: utf-8 -*-

import copy
import time

from protocol import build_response_body
from server import route


BRANCH_IDS = ("10010", "10020", "10030", "10040", "10050")


def _userid(ctx):
    try:
        return int(ctx.get("headers", {}).get("userid") or 0)
    except (TypeError, ValueError):
        return 0


def _data_ver(ctx, userid):
    role = ctx["state"].get_archive(userid)
    if isinstance(role, dict):
        system = role.get("serverActionSystem")
        if isinstance(system, dict):
            try:
                return int(system.get("dataVersion") or 0)
            except (TypeError, ValueError):
                pass
        try:
            return int(role.get("dataVer") or 0)
        except (TypeError, ValueError):
            pass
    return 0


def _persist_data_ver(ctx, userid, data_ver):
    role = ctx["state"].get_archive(userid)
    if not isinstance(role, dict):
        return
    role["dataVer"] = int(data_ver)
    system = role.get("serverActionSystem")
    if not isinstance(system, dict):
        system = {}
        role["serverActionSystem"] = system
    system["dataVersion"] = int(data_ver)
    ctx["state"].put_archive(userid, role, data_ver=int(data_ver))


def _default_branch():
    return {
        "exp": 0,
        "costTechnique": 0,
        "techniqueList": {},
        "characterInUse": [],
        "characterUnused": [],
    }


def _bucket(ctx, userid):
    with ctx["state"]._lock:
        root = ctx["state"]._state.setdefault("fist", {})
        key = str(userid)
        changed = not isinstance(root.get(key), dict)
        bucket = root.setdefault(key, {})
        for field, value in (
            ("accpoint", 0),
            ("reflectExp", 0),
            ("feelPoint", 0),
            ("characterPoint", 0),
            ("guajiInfo", {}),
            ("branchInfo", {}),
            ("updated_at", int(time.time())),
        ):
            if field not in bucket:
                bucket[field] = copy.deepcopy(value)
                changed = True
        branch_info = bucket["branchInfo"]
        for branch_id in BRANCH_IDS:
            if not isinstance(branch_info.get(branch_id), dict):
                branch_info[branch_id] = _default_branch()
                changed = True
            else:
                branch = branch_info[branch_id]
                for field, value in _default_branch().items():
                    if field not in branch:
                        branch[field] = copy.deepcopy(value)
                        changed = True
        if changed:
            ctx["state"]._changed()
        return bucket


def _payload(bucket, data_ver):
    result = {
        "dataVer": int(data_ver),
        "accpoint": int(bucket.get("accpoint") or 0),
        "guajiInfo": copy.deepcopy(bucket.get("guajiInfo") or {}),
        "reflectExp": int(bucket.get("reflectExp") or 0),
        "feelPoint": int(bucket.get("feelPoint") or 0),
        "characterPoint": int(bucket.get("characterPoint") or 0),
        "branchInfo": copy.deepcopy(bucket.get("branchInfo") or {}),
    }
    return result


@route(["POST"], "get_fist_info")
def get_fist_info(ctx):
    userid = _userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    bucket = _bucket(ctx, userid)
    return build_response_body(_payload(bucket, _data_ver(ctx, userid)))


@route(["POST"], "create_fist_info")
def create_fist_info(ctx):
    return get_fist_info(ctx)
