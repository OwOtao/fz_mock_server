# -*- coding: utf-8 -*-
"""
示例/基础接口: 登录链路三件套
==============================
覆盖客户端启动的核心请求。其余业务接口按需逐个补齐
(协议字典见 fzjh_lua/protocol_inventory.json)。
"""

import logging
import time

import config
from protocol import build_response_body
from server import route

log = logging.getLogger("mock_server")

def _first_dict(value):
    if isinstance(value, dict):
        return value
    if isinstance(value, list) and value and isinstance(value[0], dict):
        return value[0]
    return {}


def _requested_userid(ctx):
    body = ctx.get("body")
    item = _first_dict(body)
    value = item.get("userid")
    if value is None:
        value = ctx.get("headers", {}).get("userid")
    try:
        return int(value)
    except (TypeError, ValueError):
        return 0


def _header_userid(ctx):
    try:
        return int(ctx.get("headers", {}).get("userid", 0))
    except (TypeError, ValueError):
        return 0


def _seed_userid(state):
    """无本地档启动时回落到 source=seed 的 RoleData, 避免空 userid 新开号。"""
    snapshot = state.snapshot()
    accounts = snapshot.get("accounts") or {}
    for key, account in accounts.items():
        if not isinstance(account, dict):
            continue
        if account.get("source") != "seed":
            continue
        try:
            userid = int(account.get("userid") or key)
        except (TypeError, ValueError):
            continue
        try:
            if state.get_archive(userid) is not None:
                return userid
        except ValueError:
            continue
    return None


def _bind_active_archive(ctx, userid):
    device_uuid = ctx.get("headers", {}).get("uuid")
    if not device_uuid or userid is None:
        return
    try:
        ctx["state"].set_active_archive(device_uuid, userid)
    except (KeyError, ValueError):
        pass


def _fallback_archive_userid(ctx, userid):
    device_uuid = ctx.get("headers", {}).get("uuid")
    active = ctx["state"].get_active_archive(device_uuid) if device_uuid else None
    if active:
        try:
            mapped = int(active.get("userid") or 0)
        except (TypeError, ValueError):
            mapped = 0
        if mapped > 0:
            try:
                if ctx["state"].get_archive(mapped) is not None:
                    return mapped
            except ValueError:
                pass
    if userid is not None and userid > 0:
        try:
            if ctx["state"].get_archive(userid) is not None:
                return userid
        except ValueError:
            pass
    seed = _seed_userid(ctx["state"])
    if seed:
        return seed
    if userid is not None and userid > 0:
        return userid
    return None


def _body_dict(ctx):
    body = ctx.get("body")
    return body if isinstance(body, dict) else {}


def _route_tail(ctx, index=0, default=""):
    tail = ctx.get("route_tail", [])
    return tail[index] if len(tail) > index else default


@route(["POST"], "create_account")
def create_account(ctx):
    """errcode=0 开始游戏; 1 上传并删除; 2 覆盖档案; 201 公告。
    无本地档时客户端会带 userid=0/-1, 回落到种子档; 带 email 的注册仍开新号。"""
    requested = _requested_userid(ctx)
    userid = requested if requested > 0 else None
    body = ctx.get("body")
    item = _first_dict(body)
    email = item.get("email")
    if email is None:
        userid = _fallback_archive_userid(ctx, userid)
        account = ctx["state"].ensure_account(userid)
    else:
        try:
            account = ctx["state"].register_account(userid=userid, email=email)
        except ValueError as error:
            if str(error) == "email already bound":
                return build_response_body({}, errcode=409, errmsg="email already bound")
            raise
    userid = account["userid"]
    archive, _record = _extract_archive(body)
    if archive is not None and ctx["state"].get_archive(userid) is None:
        archive["userid"] = userid
        archive.setdefault("dataVer", 1)
        ctx["state"].put_archive(userid, archive)
    _bind_active_archive(ctx, userid)
    return build_response_body({"userid": userid})


@route(["POST"], "create_role")
def create_role(ctx):
    requested = _requested_userid(ctx)
    archive, record = _extract_archive(ctx.get("body"))
    embedded = 0
    if isinstance(archive, dict):
        try:
            embedded = int(archive.get("userid") or archive.get("userId") or 0)
        except (TypeError, ValueError):
            embedded = 0
    userid = requested if requested > 0 else (embedded or None)
    userid = ctx["state"].ensure_account(userid)["userid"]
    archive = dict(archive) if isinstance(archive, dict) else {"userid": userid}
    archive["userid"] = userid
    if ctx["state"].get_archive(userid) is None:
        ctx["state"].put_archive(userid, archive, record=record)
    _bind_active_archive(ctx, userid)
    return build_response_body({"userid": userid})


@route(["GET"], "download_user_file_2")
def download_user_file_2(ctx):
    userid = _fallback_archive_userid(ctx, _header_userid(ctx))
    archive = ctx["state"].get_archive(userid) if userid and userid > 0 else None
    if archive is None:
        return build_response_body([], errcode=404, errmsg="user archive not found")
    _bind_active_archive(ctx, userid)
    return build_response_body([dict(archive)])


def _extract_archive(body):
    """兼容 [{role}, {record}] / {role} / 解密失败后的空对象。"""
    if isinstance(body, list) and body and isinstance(body[0], dict):
        record = body[1] if len(body) > 1 and isinstance(body[1], dict) else {}
        return dict(body[0]), dict(record)
    if isinstance(body, dict) and body:
        # 少数旧路径可能直接发 role 表
        if any(k in body for k in ("userid", "name", "exp", "id")):
            return dict(body), {}
    return None, None


def _resolve_userid(ctx, archive):
    userid = _header_userid(ctx)
    if userid <= 0 and isinstance(archive, dict):
        try:
            userid = int(archive.get("userid", 0))
        except (TypeError, ValueError):
            userid = 0
    if userid <= 0:
        userid = ctx["state"].ensure_account(None)["userid"]
    else:
        ctx["state"].ensure_account(userid)
    return userid


def _save_upload(ctx, archive, record=None, u_type="", cheat_type=""):
    userid = _resolve_userid(ctx, archive)
    upload = {
        "uType": u_type,
        "cheatType": cheat_type,
        "updated_at": int(time.time()),
    }
    saved = ctx["state"].put_archive(userid, archive, record=record, upload=upload)
    data_ver = int(saved.get("dataVer") or 0)
    primery_key = saved.get("primeryKey") or str(userid)
    return userid, data_ver, primery_key


def _upload_success_from_existing(ctx, userid=None):
    """实机偶发 POST body 为空时, 用已有种子/落盘档回放成功。
    客户端成功条件: status=200 && errcode=0 && data.primeryKey/dataVer。"""
    if userid is None or userid <= 0:
        userid = _header_userid(ctx)
    if userid <= 0:
        active = ctx["state"].get_active_archive(ctx.get("headers", {}).get("uuid"))
        if active:
            try:
                userid = int(active.get("userid") or 0)
            except (TypeError, ValueError):
                userid = 0
    if userid <= 0:
        return None
    role = ctx["state"].get_archive(userid)
    if not isinstance(role, dict):
        return None
    data_ver = int(role.get("dataVer") or 0)
    if data_ver <= 0:
        system = role.get("serverActionSystem") if isinstance(role.get("serverActionSystem"), dict) else {}
        try:
            data_ver = int(system.get("dataVersion") or 1)
        except (TypeError, ValueError):
            data_ver = 1
    primery_key = role.get("primeryKey") or str(userid)
    return build_response_body({
        "primeryKey": primery_key,
        "dataVer": data_ver,
        "userid": userid,
    })


@route(["POST", "GET"], "upload_user_file_3")
def upload_user_file_3(ctx):
    """开始游戏上传: body=[{userAttr},{recordInfo}], URL 尾缀 /{uType}/{cheatType}。
    成功需返回 primeryKey + dataVer。
    实机日志出现 encrypted=False body={} 时, 回放已有落盘档。"""
    body = ctx.get("body")
    archive, record = _extract_archive(body)
    if archive is None:
        fallback = _upload_success_from_existing(ctx)
        if fallback is not None:
            log.warning(
                "upload_user_file_3 empty body, replay existing archive userid=%s raw_len=%s",
                _header_userid(ctx),
                len(ctx.get("raw_body") or ""),
            )
            return fallback
        return build_response_body(
            {},
            errcode=400,
            errmsg="invalid archive payload encrypted=%s raw=%s"
            % (ctx.get("encrypted"), (ctx.get("raw_body") or "")[:80]),
        )
    u_type = _route_tail(ctx, 0, "")
    cheat_type = _route_tail(ctx, 1, "")
    userid, data_ver, primery_key = _save_upload(ctx, archive, record=record, u_type=u_type, cheat_type=cheat_type)
    return build_response_body({"primeryKey": primery_key, "dataVer": data_ver, "userid": userid})


@route(["POST"], "upload_user_file_4")
def upload_user_file_4(ctx):
    body = ctx.get("body")
    archive, record = _extract_archive(body)
    if archive is None:
        return build_response_body({}, errcode=400, errmsg="invalid archive payload")
    try:
        userid = int(archive.get("userid", 0))
    except (TypeError, ValueError):
        userid = 0
    if userid > 0:
        userid, data_ver, primery_key = _save_upload(
            ctx, archive, record=record, u_type=_route_tail(ctx, 0, ""), cheat_type=_route_tail(ctx, 1, "")
        )
    else:
        data_ver = 0
        primery_key = ""
    return build_response_body({"primeryKey": primery_key, "dataVer": data_ver})


@route(["POST"], "upload_user_file_5")
def upload_user_file_5(ctx):
    body = ctx.get("body")
    archive, record = _extract_archive(body)
    if archive is None:
        return build_response_body({}, errcode=400, errmsg="invalid archive payload")
    userid, data_ver, primery_key = _save_upload(
        ctx, archive, record=record, u_type=_route_tail(ctx, 0, ""), cheat_type=_route_tail(ctx, 1, "")
    )
    return build_response_body({"primeryKey": primery_key, "dataVer": data_ver, "userid": userid})


def _default_guanqialimit():
    # ControllLayer:startGame 会对 account.guanqialimit 做 pairs()
    # 必须是表, 不能是数字/nil, 否则 xpcall 失败后弹出“网络错误, 请重试”
    return {
        "volume_1": 1,
        "volume_2": 1,
        "volume_3": 1,
        "volume_4": 1,
        "volume_5": 1,
        "fuben11-20": 1,
        "fuben21-30": 1,
        "fuben31-35": 1,
        "fuben36-40": 1,
    }


def _game_user_info_payload(ctx, userid):
    role = ctx["state"].get_archive(userid) or {}
    account = ctx["state"].get_account(userid) or {}
    create_time = role.get("createTime")
    if not isinstance(create_time, (int, float)):
        create_time = int(account.get("created_at") or time.time())
    return {
        "idauth": {
            "isbind": True,
            "isadult": True,
        },
        "account": {
            "cid": int(role.get("accountId") or userid),
            "guanqialimit": _default_guanqialimit(),
            "duocundang": 0,
            "createTime": int(create_time),
        },
        "role": {
            "yueka": 0,
            "yueka_reward": 0,
            "baoyuefengshenfu": 0,
            "yashi": 0,
            "yashiWelfarePoint": 0,
            "privilege_expired_time": 0,
            "privilege_remaining_watches": 0,
        },
        "notice": {},
        "is_cheat": 0,
        "jiayuantch": True,
        "hometch": {"switchs": 0},
        "task": {},
        "challengeMapCompleted": sorted((account.get("challenge_map") or {}).get("completed", {})),
    }


@route(["POST"], "login")
def login(ctx):
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=550, errmsg="invalid userid")
    if ctx["state"].get_account(userid) is None:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    if not ctx.get("headers", {}).get("uuid"):
        return build_response_body({}, errcode=551, errmsg="invalid uuid")
    return build_response_body(_game_user_info_payload(ctx, userid))


@route(["GET"], "get_archive_list")
def get_archive_list(ctx):
    """存档列表(客户端 ArchiveLayer)。

    ArchiveLayer:createOneArchiveItem 会无条件读这些字段, 少一个就会让整行渲染
    报错 -> 界面空白/点不动:
      Text_name  <- name         Text_menpai <- menpai
      Text_exp   <- math.floor(exp)  (必须是数字, nil 会抛错)
      Text_year  <- year("YYYY-MM")   Text_time <- time("HH:MM:SS")
      HeadDataHeadViewPresenter <- head/looks/sex/portrait/polymorph
      panel:releaseFunc -> changeArchive(params.index, params.userid)
                           -> switch_archive/<index>
    """
    return build_response_body(_archive_list_entries(ctx))


def _archive_list_entries(ctx):
    from handlers.basic import _ranking_family  # 延迟导入, 避免与 basic 形成循环依赖

    values = ctx["state"].list_archives()
    entries = []
    for index, item in enumerate(values, start=1):
        userid = item.get("userid")
        role = ctx["state"].get_archive(userid) or {}
        created = role.get("createTime")
        if not isinstance(created, (int, float)) or created <= 0:
            created = item.get("updated_at")
        year, clock = "", ""
        if isinstance(created, (int, float)) and created > 0:
            stamp = time.localtime(created)
            year = time.strftime("%Y-%m", stamp)
            clock = time.strftime("%H:%M:%S", stamp)
        entry = dict(item)
        entry["index"] = index
        entry["name"] = item.get("name") or ("存档%s" % userid)
        entry["menpai"] = _ranking_family(role)
        entry["exp"] = _num_or_zero(role.get("exp", item.get("exp")))
        entry["lv"] = _num_or_zero(role.get("lv", item.get("lv")))
        entry["year"] = year
        entry["time"] = clock
        for key in ("head", "looks", "sex", "portrait", "polymorph"):
            entry[key] = role.get(key)
        entries.append(entry)
    return entries


def _num_or_zero(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


@route(["GET"], "switch_archive")
def switch_archive(ctx):
    target = _route_tail(ctx)
    try:
        value = int(target)
    except (TypeError, ValueError):
        value = 0
    values = ctx["state"].list_archives()
    userid = 0
    if 1 <= value <= len(values):
        try:
            userid = int(values[value - 1].get("userid") or 0)
        except (TypeError, ValueError):
            userid = 0
    if userid <= 0:
        userid = value
    if userid <= 0 or ctx["state"].get_archive(userid) is None:
        # 客户端传的是存档位序号: ArchiveLayer:changeArchive(params.index, userid)
        # -> switch_archive/<index>; 这里按列表顺序回查, 同时保留按 userid 切换的旧用法。
        if 1 <= value <= len(values):
            try:
                userid = int(values[value - 1].get("userid") or 0)
            except (TypeError, ValueError):
                userid = 0
    if userid <= 0 or ctx["state"].get_archive(userid) is None:
        return build_response_body({}, errcode=404, errmsg="archive not found")
    device_uuid = ctx.get("headers", {}).get("uuid") or ""
    ctx["state"].set_active_archive(device_uuid, userid)
    role = ctx["state"].get_archive(userid)
    return build_response_body({
        "id": str(userid),
        "userid": userid,
        "name": role.get("name"),
        "dataVer": role.get("dataVer"),
        "switched": True,
    })


@route(["POST"], "get_game_user_info_2")
def get_game_user_info_2(ctx):
    """开始游戏后 ControllLayer:startGame -> Account:getGameUserInfo。
    成功条件: status=200 && errcode=0, 且回调返回 true。
    若 data.account.guanqialimit 不是表, 客户端 pairs(nil/number) 抛错,
    BaseHttp xpcall 返回 false, Http.lua 弹出“网络错误, 请重试”。"""
    userid = _header_userid(ctx)
    if userid <= 0:
        return build_response_body({}, errcode=552, errmsg="userid not found")
    if ctx["state"].get_account(userid) is None:
        if ctx["state"].get_archive(userid) is None:
            return build_response_body({}, errcode=552, errmsg="userid not found")
        ctx["state"].ensure_account(userid)
    return build_response_body(_game_user_info_payload(ctx, userid))


@route(["GET"], "get_history_notice")
def get_history_notice(ctx):
    return build_response_body([])


@route(["GET"], "get_email")
def get_email(ctx):
    userid = _header_userid(ctx)
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return build_response_body({}, errcode=1, errmsg="account not found")
    return build_response_body(ctx["state"].get_email(userid))


@route(["POST"], "send_email")
def send_email(ctx):
    userid = _header_userid(ctx)
    body = _body_dict(ctx)
    email = body.get("email", "")
    if userid <= 0 or not email:
        return build_response_body({}, errcode=400, errmsg="email is required")
    expires = int(time.time()) + 1800
    ctx["state"].set_email_code(userid, email, "123456", body.get("event_type"), expires)
    return build_response_body({"expired_time": expires})


def _device_action(ctx, action):
    requested_userid = _header_userid(ctx)
    body = _body_dict(ctx)
    email = body.get("email") or body.get("phone")
    userid = requested_userid
    email_owner = None
    if action == "login" and email:
        email_owner = ctx["state"].get_userid_by_email(email)
        userid = email_owner or userid
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return build_response_body({}, errcode=552, errmsg="account not found")
    if ctx.get("headers", {}).get("isbind") == "0" or ctx.get("headers", {}).get("isBind") == "0":
        ctx["state"].unbind_device(userid)
        return build_response_body({})
    code = str(body.get("verify_code", ""))
    try:
        # The legacy transfer UI can submit the mock code directly without
        # calling send_email first. Initialize only an empty verification
        # session; an existing target must still match exactly.
        device = ctx["state"].get_device(requested_userid)
        if (
            email
            and code == "123456"
            and not device.get("verify_target")
            and not device.get("verify_code")
        ):
            ctx["state"].set_email_code(
                requested_userid,
                email,
                "123456",
                "login" if action == "login" else action,
                int(time.time()) + 1800,
            )
        ctx["state"].validate_email_code(requested_userid, email, code)
        if action == "bind":
            ctx["state"].bind_device(userid, email, code)
        elif action == "login":
            # On old clients this is the only visible email action. If the
            # address has no owner, bind the current archive before switching.
            if email_owner is None:
                if ctx["state"].get_archive(requested_userid) is None:
                    raise ValueError("archive not found")
                ctx["state"].bind_device(requested_userid, email, code)
                userid = requested_userid
            device_uuid = ctx.get("headers", {}).get("uuid") or ""
            ctx["state"].set_active_archive(device_uuid, userid)
        else:
            ctx["state"].unbind_device(userid)
    except (KeyError, ValueError) as error:
        messages = {
            "email already bound": (409, "email already bound"),
            "invalid verify target": (400, "invalid verify target"),
            "invalid verify code": (400, "invalid verify code"),
            "verify code expired": (400, "verify code expired"),
            "archive not found": (404, "user archive not found"),
        }
        errcode, errmsg = messages.get(str(error), (400, str(error)))
        return build_response_body({}, errcode=errcode, errmsg=errmsg)
    return build_response_body({"userid": userid})


@route(["GET"], "get_bind_info")
def get_bind_info(ctx):
    userid = _header_userid(ctx)
    if userid <= 0 or ctx["state"].get_account(userid) is None:
        return build_response_body({}, errcode=1, errmsg="account not found")
    return build_response_body(ctx["state"].get_email(userid))


@route(["POST"], "send_verify_code")
def send_verify_code(ctx):
    userid = _header_userid(ctx)
    body = _body_dict(ctx)
    send_type = body.get("send_type", "email")
    target = body.get(send_type, "")
    if userid <= 0 or not target:
        return build_response_body({}, errcode=400, errmsg="verify target is required")
    expires = int(time.time()) + 1800
    ctx["state"].set_email_code(userid, target, "123456", body.get("event_type"), expires)
    return build_response_body({"expired_time": expires})


@route(["POST"], "bind_device")
def bind_device(ctx):
    return _device_action(ctx, "bind")


@route(["POST"], "login_device")
def login_device(ctx):
    return _device_action(ctx, "login")


@route(["POST"], "logout_device")
def logout_device(ctx):
    return _device_action(ctx, "logout")


@route(["POST"], "bind_device_2")
def bind_device_2(ctx):
    return _device_action(ctx, "bind")


@route(["POST"], "login_device_2")
def login_device_2(ctx):
    return _device_action(ctx, "login")


@route(["POST"], "logout_device_2")
def logout_device_2(ctx):
    return _device_action(ctx, "logout")


@route(["POST"], "realname_send")
def realname_send(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "realname_auth")
def realname_auth(ctx):
    return build_response_body({"auth": True})


@route(["GET", "POST"], "get_time")
def get_time(ctx):
    """服务器时间。客户端用它校准 WEB_TIME / BACKGROUND_TIME。"""
    return build_response_body({"time": int(time.time())})


@route(["GET", "POST"], "get_token")
def get_token(ctx):
    """下发签名 token。客户端收到后用于校验后续响应签名。"""
    return build_response_body({
        "token": config.T_TOKEN,
        "t_token": config.T_TOKEN,
    })


@route(["GET", "POST"], "hello")
def hello(ctx):
    """连通性自测。"""
    return build_response_body({"msg": "pong", "echo": ctx.get("body")})
