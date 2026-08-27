# -*- coding: utf-8 -*-

import json
import time
import urllib.error
import urllib.parse
import urllib.request

import config
from protocol import build_raw_response, build_response_body, make_nonce, sign_response
from server import route


PUBLIC_KEYS = [
    {"k": "0228482afef78be8b948ad8b08b24da7", "h": "FZJH02"},
    {"k": "880e42c8075b8f400cd72f21451c0866", "h": "FZJH03", "i": "PcIQIZifRalhZ88n"},
    {"k": "0228482afef78be8b948ad8b08b24da7", "h": "FXXF03"},
]

HOP_BY_HOP_HEADERS = {
    "connection",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "proxy-connection",
    "te",
    "trailer",
    "transfer-encoding",
    "upgrade",
}
UPDATE_REQUEST_HEADERS = {
    "accept-encoding",
    "channel",
    "device",
    "hotver",
    "nouce",
    "package",
    "platform",
    "sig",
    "time",
    "user-agent",
    "userid",
    "uuid",
    "ver",
}
UPDATE_RESPONSE_LIMIT = 8 * 1024 * 1024
UPDATE_RESPONSE_PREFIX = b"4a4848553032"


class _SameHostRedirectHandler(urllib.request.HTTPRedirectHandler):
    def __init__(self, hostname):
        self.hostname = hostname

    def redirect_request(self, req, fp, code, msg, headers, newurl):
        parsed = urllib.parse.urlparse(newurl)
        if parsed.scheme not in {"http", "https"} or parsed.hostname != self.hostname:
            raise urllib.error.URLError("cross-host redirect blocked")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def _filter_proxy_headers(headers, exclude=()):
    values = dict(headers or {})
    connection_headers = {
        item.strip().lower()
        for key, value in values.items()
        if str(key).lower() == "connection"
        for item in str(value).split(",")
        if item.strip()
    }
    blocked = HOP_BY_HOP_HEADERS | connection_headers | {item.lower() for item in exclude}
    return {
        key: value
        for key, value in values.items()
        if str(key).lower() not in blocked
    }

# get_game_config 的 data 字段: 客户端 createGetResponseFunction 会对
# responseData.data (string) 做 json.decode(JMForLua:decrypt(...)),
# 所以 data 必须是 JSON 字符串。serverList 指向 mock 服务器自身。
GAME_CONFIG_DATA = {
    "_common": {
        "TEXT_BXYGX": "不需要更新",
        "TEXT_JCGX": "检测更新",
        "TEXT_JYSB": "解压失败",
        "TEXT_JYWC": "解压完成",
        "TEXT_KSJY": "开始解压更新文件",
        "TEXT_WZCW": "更新失败",
        "TEXT_XZSB": "下载失败",
        "TEXT_XZWC": "下载完成",
        "TEXT_ZRYX": "载入游戏",
        "api": {
            "getPayStatusApi": config.DOMAIN + "/v1/queryOrder",
            "payBaseApi": config.DOMAIN + "/v1/createOrder",
            "payDataCallBackApi": "",
            "postCheatSoftware": config.DOMAIN + "/" + config.API_PREFIX + "count_multi_record",
        },
        "notice": {"msg": "如果无法进入游戏，请尝试去应用市场更新游戏", "type": 1},
        "serverList": [{"host": config.DOMAIN + "/"}],
        "socketList": [{"host": "127.0.0.1:9529"}],
        "updateList": [{"host": config.DOMAIN + "/"}],
    },
    "huawei": {
        "api": {
            "getPayStatusApi": config.DOMAIN + "/v1/queryOrder",
            "payBaseApi": config.DOMAIN + "/v1/createOrder",
            "payDataCallBackApi": config.DOMAIN + "/v1/verifyOrder/huawei",
            "postCheatSoftware": config.DOMAIN + "/" + config.API_PREFIX + "count_multi_record",
        },
        "notice": {"msg": "如果无法进入游戏，请尝试去应用市场更新游戏", "type": 1},
        "serverList": [{"host": config.DOMAIN + "/"}],
        "socketList": [{"host": "127.0.0.1:9529"}],
        "updateList": [{"host": config.DOMAIN + "/"}],
    },
}


@route(["GET"], "getWebConfig")
def get_web_config(ctx):
    return build_response_body({
        "PackageChecklist": {},
        "UPLAdsList": {},
        "WeiXinSHareList": {},
        "FenXiangList": {},
        "ShiMingList": {},
        "IsAesEncrypt": False,
    })


@route(["GET"], "service/get_game_config")
def get_game_config(ctx):
    # data 必须是 JSON 字符串 (客户端会 json.decode 它)
    data_str = json.dumps(GAME_CONFIG_DATA, ensure_ascii=False, separators=(",", ":"))
    return build_response_body(data_str)


@route(["GET", "POST"], "service/exchange_publickey")
def exchange_publickey(ctx):
    # data 也是 JSON 字符串
    return build_response_body(json.dumps(PUBLIC_KEYS, ensure_ascii=False, separators=(",", ":")))


@route(["GET", "POST"], "service_android/get_version_info")
def get_version_info(ctx):
    """与 HAR 真实响应对齐: 含 lowestVersionCode/versionCode/versionName/desc/url/md5/isOpen/fzbUrl + sig."""
    cur_time = str(time.time())
    nonce = make_nonce()
    return build_response_body({
        "lowestVersionCode": 3,
        "versionCode": 10,
        "versionName": "2.1.02",
        "desc": "当前版本",
        "url": "",
        "md5": "",
        "isOpen": "no",
        "fzbUrl": "",
    })


@route(["GET", "POST"], "service_android/report_ads_info")
def report_ads_info(ctx):
    return build_response_body({"ok": True})


@route(["GET"], "service_android/get_uuid")
def get_uuid(ctx):
    uuid = ctx["state"].get_or_create_device_uuid(config.MOCK_DEVICE_UUID)
    return {"errcode": 0, "data": {"uuid": uuid}}


@route(["POST"], "service_android/update_uuid")
def update_uuid(ctx):
    new_uuid = str(ctx.get("body", {}).get("new_uuid") or "").strip()
    current_uuid = ctx["state"].get_or_create_device_uuid(config.MOCK_DEVICE_UUID)
    if not ctx.get("encrypted") or new_uuid != current_uuid:
        return {"errcode": 1}
    return {"errcode": 0}


@route(["GET"], "v1/get_time")
def update_time(ctx):
    return {"data": [{"time": int(time.time())}]}


@route(["GET"], "v1/get_game_version/MUD")
def update_game_version(ctx):
    return {"data": [{"canUpdate": "N", "version": "mock"}]}


@route(["GET"], "v1/checkUpdate")
def check_update(ctx):
    return _proxy_update_response(ctx, "checkUpdate")


@route(["GET"], "v1/getMd5List")
def get_md5_list(ctx):
    return _proxy_update_response(ctx, "getMd5List")


def _proxy_failure():
    return build_raw_response(
        b"upstream request failed", 502,
        {"Content-Type": "text/plain; charset=utf-8"})


def _read_update_response(response):
    content_length = response.headers.get("Content-Length")
    if content_length is not None and int(content_length) > UPDATE_RESPONSE_LIMIT:
        raise ValueError("upstream response too large")
    body = response.read(UPDATE_RESPONSE_LIMIT + 1)
    if len(body) > UPDATE_RESPONSE_LIMIT:
        raise ValueError("upstream response too large")
    if response.status == 200 and not body.lower().startswith(UPDATE_RESPONSE_PREFIX):
        raise ValueError("invalid upstream response")
    headers = _filter_proxy_headers(response.headers.items(), exclude={"content-length"})
    headers["Content-Length"] = str(len(body))
    return build_raw_response(body, response.status, headers)


def _proxy_update_response(ctx, endpoint):
    try:
        base = str(getattr(config, "UPDATE_UPSTREAM_BASE", "") or "").strip()
        parsed_base = urllib.parse.urlparse(base)
        if parsed_base.scheme not in {"http", "https"} or not parsed_base.hostname:
            raise ValueError("invalid upstream URL")
        timeout = float(config.UPDATE_UPSTREAM_TIMEOUT)
        if timeout <= 0:
            raise ValueError("invalid upstream timeout")
        url = base.rstrip("/") + "/" + endpoint
        if ctx.get("query_string"):
            url += "?" + ctx["query_string"]
        request = urllib.request.Request(url, method="GET")
        for key, value in (ctx.get("headers") or {}).items():
            if str(key).lower() in UPDATE_REQUEST_HEADERS:
                request.add_header(key, value)
        opener = urllib.request.build_opener(_SameHostRedirectHandler(parsed_base.hostname))
        try:
            with opener.open(request, timeout=timeout) as response:
                return _read_update_response(response)
        except urllib.error.HTTPError as error:
            return _read_update_response(error)
    except (AttributeError, OSError, TypeError, ValueError, urllib.error.URLError):
        return _proxy_failure()


# ---------------------------------------------------------------------------
# 启动链路必需接口 (Lua 源码 HttpManager.lua)
# ---------------------------------------------------------------------------

@route(["GET"], "get_partition_list")
def get_partition_list(ctx):
    """分区列表。客户端 SwitchServerController 用它渲染服务器选择。"""
    return build_response_body([{
        "id": 1,
        "name": "测试服",
        "host": config.DOMAIN + "/",
        "socket": "127.0.0.1:9529",
        "status": 1,
        "isNew": True,
        "recommend": True,
    }])


@route(["GET"], "get_partition_list2")
def get_partition_list2(ctx):
    return get_partition_list(ctx)


@route(["POST"], "report_cheat")
def report_cheat(ctx):
    """防作弊上报 (签名白名单接口)。"""
    return build_response_body({"ok": True})


@route(["POST"], "count_multi_record")
def count_multi_record(ctx):
    """多开/作弊计数上报。"""
    return build_response_body({"ok": True})


@route(["POST"], "count_single_record")
def count_single_record(ctx):
    return build_response_body({"ok": True})


@route(["GET", "POST"], "get_login_reward_info")
def get_login_reward_info(ctx):
    return build_response_body({"days": 0, "list": []})


@route(["GET", "POST"], "get_login_reward_list")
def get_login_reward_list(ctx):
    return build_response_body([])


@route(["GET", "POST"], "get_activity_calendar")
def get_activity_calendar(ctx):
    return build_response_body([])


@route(["GET", "POST"], "get_server_resource_count")
def get_server_resource_count(ctx):
    return build_response_body({"count": 0})


@route(["POST"], "upload_fzjh_stat")
def upload_fzjh_stat(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "upload_weapon_repair_log")
def upload_weapon_repair_log(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "upload_client_error_message")
def upload_client_error_message(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "upload_acquisition_log")
def upload_acquisition_log(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "report_gain_log")
def report_gain_log(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "upload_event_record")
def upload_event_record(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "submit_event_record")
def submit_event_record(ctx):
    return build_response_body({"ok": True})


@route(["GET", "POST"], "get_share_link")
def get_share_link(ctx):
    return build_response_body({"url": ""})


@route(["POST"], "do_share")
def do_share(ctx):
    return build_response_body({"ok": True})


@route(["GET", "POST"], "contains_blocked_word")
def contains_blocked_word(ctx):
    """敏感词检测。返回 false 表示不含敏感词。"""
    return build_response_body({"contains": False})


@route(["GET", "POST"], "check_email_white")
def check_email_white(ctx):
    return build_response_body({"white": True})


@route(["POST"], "migrate_to_new_package")
def migrate_to_new_package(ctx):
    return build_response_body({"ok": True})


@route(["POST"], "migrate_to_new_package2")
def migrate_to_new_package2(ctx):
    return build_response_body({"ok": True})


@route(["GET", "POST"], "get_manage_payment")
def get_manage_payment(ctx):
    return build_response_body({"list": []})


@route(["GET", "POST"], "get_limit_package")
def get_limit_package(ctx):
    from handlers.basic import get_limit_package as get_limit_package_handler
    return get_limit_package_handler(ctx)


@route(["GET", "POST"], "get_discount_coupon")
def get_discount_coupon(ctx):
    return build_response_body({"list": []})


@route(["GET", "POST"], "get_recharge_benefits_info")
def get_recharge_benefits_info(ctx):
    return build_response_body({"list": []})


@route(["POST"], "get_recharge_benefits_reward")
def get_recharge_benefits_reward(ctx):
    return build_response_body({"received": True})
