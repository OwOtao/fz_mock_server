# -*- coding: utf-8 -*-

import json
import time

import config
from protocol import build_response_body, make_nonce, sign_response
from server import route


PUBLIC_KEYS = [
    {"k": "07818f3a34e8165227b0dc6b7e69ea57", "h": "FZJH02"},
    {"k": "26549f871287ba9e838a057a7ffac1bc", "h": "FZJH03", "i": "PcIQIZifRalhZ88n"},
    {"k": "07818f3a34e8165227b0dc6b7e69ea57", "h": "FXXF03"},
]

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
    uuid = ctx.get("headers", {}).get("uuid") or "mock-device-uuid"
    return build_response_body({"uuid": uuid, "id": uuid})


@route(["GET"], "v1/get_time")
def update_time(ctx):
    return {"data": [{"time": int(time.time())}]}


@route(["GET"], "v1/get_game_version/MUD")
def update_game_version(ctx):
    return {"data": [{"canUpdate": "N", "version": "mock"}]}


@route(["GET"], "v1/checkUpdate")
def check_update(ctx):
    """Java/native 更新检查器调用。errcode=1 表示无需更新。
    真实响应格式: {"errcode":1,"errmsg":"opps"} (JHHU02 加密)"""
    return {"errcode": 1, "errmsg": "opps"}


@route(["GET"], "v1/getMd5List")
def get_md5_list(ctx):
    """资源 MD5 校验列表。checkUpdate 返回 errcode=1 时不会调用此接口,
    但作为兜底返回空列表。"""
    return {"errcode": 0, "data": {"originalMd5List": {}}}


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
    return build_response_body({"list": []})


@route(["GET", "POST"], "get_discount_coupon")
def get_discount_coupon(ctx):
    return build_response_body({"list": []})


@route(["GET", "POST"], "get_recharge_benefits_info")
def get_recharge_benefits_info(ctx):
    return build_response_body({"list": []})


@route(["POST"], "get_recharge_benefits_reward")
def get_recharge_benefits_reward(ctx):
    return build_response_body({"received": True})
