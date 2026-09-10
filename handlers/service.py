# -*- coding: utf-8 -*-

import binascii
import hashlib
import json
import logging
import pathlib
import time
import urllib.error
import urllib.parse
import urllib.request

import config
import jm_crypto
from protocol import build_raw_response, build_response_body, make_nonce, sign_response
from server import route

log = logging.getLogger("mock_server")


def _short_headers(headers, limit=600):
    result = {}
    for key, value in dict(headers or {}).items():
        text = str(value)
        result[str(key)] = text if len(text) <= limit else text[:limit] + "..."
    return result


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
# 上游按请求 ver 决定响应加密组: 2.1.01 -> JHHU01(4a4848553031), 2.1.02 -> JHHU02(4a4848553032)
UPDATE_RESPONSE_PREFIXES = (b"4a4848553032", b"4a4848553031")


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
    response = _proxy_update_response(ctx, "getMd5List")
    if getattr(config, "MD5_OVERRIDE_ENABLED", False):
        response = _apply_md5_override(response)
    return response


# ---------------------------------------------------------------------------
# getMd5List 覆盖: 用本地 debug 目录的文件 md5 替换上游清单里的同名项
# ---------------------------------------------------------------------------
# 2.1.01 的上游响应用 JHHU01, 2.1.02 用 JHHU02(见 config.UPDATE_CIPHER_GROUPS);
# 覆盖时按响应体自己的魔数选组, 并用同一组算 md5 / 重新加密。


def _update_cipher_groups():
    groups = {}
    for magic, value in (getattr(config, "UPDATE_CIPHER_GROUPS", None) or {}).items():
        try:
            key, iv = value
        except (TypeError, ValueError):
            log.warning("update cipher: bad group for %r", magic)
            continue
        groups[magic] = (key, iv)
    return groups


def _detect_update_magic(body):
    """按魔数识别响应/文件属于哪个版本的加密组(最长匹配)。

    body 可以是原始字节, 也可以是 hex 文本(设备上的热更文件就是 hex 文本)。
    """
    if not isinstance(body, (bytes, bytearray)):
        return None
    lowered = bytes(body).lower()
    for magic in sorted(_update_cipher_groups(), key=len, reverse=True):
        if bytes(body)[:len(magic)] == magic:
            return magic
        if lowered[:len(magic) * 2] == binascii.hexlify(magic):
            return magic
    return None


def _update_cipher(body, op, magic=None):
    """上游更新组: magic + AES-256-CBC(明文用 '0' 补齐到 16 字节倍数)。

    op="dec" 时按 body 的魔数自动选组并返回明文;
    op="enc" 时必须给出 magic(或明文前已带魔数), 返回 hex 文本。
    """
    groups = _update_cipher_groups()
    if op == "dec":
        raw = binascii.unhexlify(body.decode("ascii").strip().lower())
        detected = _detect_update_magic(raw)
        if detected is None:
            raise ValueError("unexpected magic %r" % raw[:6])
        key, iv = groups[detected]
        payload = raw[len(detected):]
        payload = payload[: len(payload) - (len(payload) % 16)]
        plain = jm_crypto._aes_cbc(payload, key, iv, "dec")
        return plain.rstrip(b"0")
    if magic is None:
        magic = _detect_update_magic(body)
    if magic not in groups:
        raise ValueError("unknown update magic %r" % magic)
    key, iv = groups[magic]
    pad = (16 - len(body) % 16) % 16
    return (magic + jm_crypto._aes_cbc(body + b"0" * pad, key, iv, "enc")).hex().encode("ascii")


def _file_md5(path, magic):
    """清单里的 md5 = 热更文件(加密后 hex 文本)的 md5; 已加密的文件按原样取 md5。"""
    data = path.read_bytes()
    if _detect_update_magic(data) is None:
        data = _update_cipher(data, "enc", magic)
    return hashlib.md5(data).hexdigest()


def _md5_overrides(magic):
    """{清单键名: md5} —— debug 目录 + config.MD5_OVERRIDE_EXTRA_FILES。

    键名 = MD5_OVERRIDE_KEY_PREFIX + debug 目录相对路径; 额外文件按 config 里的键名。
    md5 用当前响应所属版本的加密组(magic)计算。
    """
    overrides = {}
    root = pathlib.Path(str(getattr(config, "MD5_OVERRIDE_DIR", "") or ""))
    prefix = str(getattr(config, "MD5_OVERRIDE_KEY_PREFIX", "") or "").strip("/")
    if root.is_dir():
        for path in sorted(root.rglob("*")):
            if not path.is_file():
                continue
            rel = path.relative_to(root).as_posix()
            key = "%s/%s" % (prefix, rel) if prefix else rel
            try:
                overrides[key] = _file_md5(path, magic)
            except (OSError, ValueError) as error:
                log.warning("md5 override: read failed %s: %s", path, error)
    else:
        log.warning("md5 override: dir not found: %s", root)

    extra = getattr(config, "MD5_OVERRIDE_EXTRA_FILES", None) or {}
    base = pathlib.Path(config.__file__).resolve().parent
    version = _version_for_magic(magic)
    if isinstance(extra, dict):
        for key, value in extra.items():
            rel = value
            if isinstance(value, dict):  # {版本: 路径}
                rel = value.get(version) or value.get(magic.decode())
            if not rel:
                continue
            path = base / str(rel)
            if not path.is_file():
                log.warning("md5 override: extra file not found: %s (版本 %s)", path, version)
                continue
            try:
                overrides[str(key)] = _file_md5(path, magic)
            except (OSError, ValueError) as error:
                log.warning("md5 override: read failed %s: %s", path, error)
    return overrides


def _version_for_magic(magic):
    """魔数 -> 客户端版本(如 JHHU01 -> 2.1.01), 用于按版本挑额外文件。"""
    for version, value in (getattr(config, "UPDATE_VERSION_MAGIC", None) or {}).items():
        if value == magic:
            return version
    return None


def _apply_md5_override(response):
    """解密上游清单 -> 替换同名 md5 -> 用同一版本的组重新加密返回。失败时原样返回。"""
    body = response.get("body") if isinstance(response, dict) else None
    if not isinstance(body, bytes) or not body:
        return response
    magic = _detect_update_magic(body)
    if magic is None:
        log.warning("md5 override: 未知魔数 %r, 原样返回", body[:6])
        return response
    try:
        plain = _update_cipher(body, "dec", magic)
        payload = json.loads(plain.decode("utf-8"))
    except (ValueError, TypeError, binascii.Error, UnicodeDecodeError) as error:
        log.warning("md5 override: decrypt failed: %s: %s", type(error).__name__, error)
        return response

    overrides = _md5_overrides(magic)
    if not overrides:
        return response

    replaced = []
    data = payload.get("data") if isinstance(payload, dict) else None
    if isinstance(data, dict):
        for name in ("originalMd5List", "deployMd5List"):
            table = data.get(name)
            if not isinstance(table, dict):
                continue
            for key, value in overrides.items():
                if key in table and table[key] != value:
                    table[key] = value
                    replaced.append("%s:%s" % (name, key))
    if not replaced:
        log.info("md5 override: 清单里没有匹配的本地文件 (本地 %d 个, 组=%s)",
                 len(overrides), magic.decode())
        return response

    log.info("md5 override: 组=%s 替换 %d 项 %s",
             magic.decode(), len(replaced), replaced[:10])
    new_body = _update_cipher(
        json.dumps(payload, separators=(",", ":"), ensure_ascii=False).encode("utf-8"),
        "enc", magic)
    headers = dict(response.get("headers") or {})
    headers["Content-Length"] = str(len(new_body))
    return build_raw_response(new_body, response.get("status_code", 200), headers)


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
    if response.status == 200 and not body.lower().startswith(UPDATE_RESPONSE_PREFIXES):
        log.warning("update upstream invalid body: status=%s len=%s head=%r accepted=%s resp_headers=%s",
                    response.status, len(body), body[:200],
                    [p.decode() for p in UPDATE_RESPONSE_PREFIXES],
                    _short_headers(response.headers.items()))
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
        forwarded = {}
        for key, value in (ctx.get("headers") or {}).items():
            if str(key).lower() in UPDATE_REQUEST_HEADERS:
                request.add_header(key, value)
                forwarded[key] = value
        log.info("update proxy %s url=%s query=%r forwarded=%s incoming=%s",
                 endpoint, url, ctx.get("query_string"),
                 _short_headers(forwarded), _short_headers(ctx.get("headers")))
        opener = urllib.request.build_opener(_SameHostRedirectHandler(parsed_base.hostname))
        try:
            with opener.open(request, timeout=timeout) as response:
                return _read_update_response(response)
        except urllib.error.HTTPError as error:
            log.warning("update upstream HTTPError %s endpoint=%s location=%s resp_headers=%s",
                        error.code, endpoint, error.headers.get("Location"),
                        _short_headers(error.headers.items()))
            return _read_update_response(error)
    except (AttributeError, OSError, TypeError, ValueError, urllib.error.URLError) as e:
        log.warning("update proxy failed: endpoint=%s error=%s: %s incoming=%s",
                    endpoint, type(e).__name__, e, _short_headers(ctx.get("headers")))
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
