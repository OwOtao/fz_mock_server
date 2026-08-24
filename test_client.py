# -*- coding: utf-8 -*-
"""端到端测试: 模拟客户端(对齐 BaseHttp.lua)请求 mock 服务端。

流程: 加密 JSON 请求 -> 服务端解密应答 -> 客户端解密响应 -> 校验响应签名。
"""

import hashlib
import json
import os
import sys
import urllib.request
import urllib.error

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)

import config  # noqa: E402
import jm_crypto  # noqa: E402

BASE = "http://%s:%d/%s" % (config.HOST, config.PORT, config.API_PREFIX)
SERVICE_BASE = "http://%s:%d/api/service_android/" % (config.HOST, config.PORT)
UPDATE_BASE = "http://%s:%d/api/v1/" % (config.HOST, config.PORT)


def req(path, post_data=None, verify_sign=True, force_method=None, headers=None, expect_errcode=0):
    body = jm_crypto.encrypt(json.dumps(post_data)) if post_data is not None else ""
    method = force_method or ("POST" if post_data is not None else "GET")
    request_headers = {"Content-Type": "text/plain; charset=utf-8"}
    if headers:
        request_headers.update(headers)
    r = urllib.request.Request(
        BASE + path, data=body.encode("utf-8"), method=method,
        headers=request_headers)
    try:
        resp = urllib.request.urlopen(r, timeout=10)
    except urllib.error.HTTPError as error:
        if expect_errcode == 0:
            raise
        resp = error
    resp_body = resp.read().decode("utf-8")
    rh = {k.lower(): v for k, v in resp.headers.items()}

    if verify_sign:
        assert "signature" in rh, "缺少 signature 响应头"
        calc = hashlib.md5(
            "&".join([rh["time"], rh["nonce"], resp_body, config.T_TOKEN])
            .encode("utf-8")).hexdigest()
        assert calc == rh["signature"], "响应签名不匹配"
        print("  [sign OK] path=%s" % path)
    else:
        print("  [sign skipped] path=%s" % path)

    payload = json.loads(jm_crypto.decrypt(resp_body).decode("utf-8"))
    assert payload["errcode"] == expect_errcode, "errcode=%s" % payload["errcode"]
    return payload


def main():
    print("== service_android/get_uuid ==")
    uuid_request = urllib.request.Request(
        SERVICE_BASE + "get_uuid",
        method="GET",
        headers={"Content-Type": "text/plain; charset=utf-8", "uuid": "test-device"},
    )
    uuid_response = urllib.request.urlopen(uuid_request, timeout=10)
    uuid_body = uuid_response.read().decode("utf-8")
    uuid_payload = json.loads(jm_crypto.decrypt(uuid_body).decode("utf-8"))
    assert uuid_payload["errcode"] == 0
    p = uuid_payload
    assert p["data"]["uuid"] == "test-device"
    print("  data =", p["data"])

    print("== 更新服务接口 ==")
    for update_path in ("get_time", "get_game_version/MUD"):
        r = urllib.request.urlopen(UPDATE_BASE + update_path, timeout=10)
        update_payload = json.loads(r.read().decode("utf-8"))
        assert update_payload["data"]
        print("  data =", update_payload["data"])

    print("== create_account (POST 加密请求体) ==")
    p = req("create_account", {"userid": 0}, verify_sign=True)
    assert p["data"]["userid"] > 0
    print("  data =", p["data"])

    print("== create_account (空请求体兼容) ==")
    p = req("create_account", None, verify_sign=True, force_method="POST")
    assert p["data"]["userid"] > 0
    print("  data =", p["data"])

    print("== getWebConfig (GET 加密响应) ==")
    p = req("getWebConfig", verify_sign=False)
    assert p["data"]["PackageChecklist"] == {}
    assert p["data"]["UPLAdsList"] == {}
    assert p["data"]["WeiXinSHareList"] == {}
    assert p["data"]["FenXiangList"] == {}
    assert p["data"]["ShiMingList"] == {}
    assert p["data"]["IsAesEncrypt"] is False
    print("  data =", p["data"])

    print("== create_role (POST 空请求体) ==")
    p = req("create_role", None, verify_sign=True, force_method="POST")
    assert p["data"]["userid"] > 0
    print("  data =", p["data"])

    print("== download_user_file_2 (GET 按 userid 返回存档) ==")
    p = req("download_user_file_2", verify_sign=True, headers={"userid": "1000000003"})
    assert isinstance(p["data"], list)
    assert p["data"][0]["userid"] == 1000000003
    print("  data[0] =", p["data"][0])

    print("== upload_user_file_3 (POST 上传并回读存档) ==")
    uploaded = {"userid": 1000000003, "name": "测试角色", "exp": 12345}
    p = req(
        "upload_user_file_3/Account/3",
        [uploaded, {"loginCount": 1}],
        verify_sign=True,
        headers={"userid": "1000000003"},
    )
    assert p["data"]["primeryKey"] == "1000000003"
    p = req("download_user_file_2", verify_sign=True, headers={"userid": "1000000003"})
    assert p["data"][0] == uploaded
    print("  data[0] =", p["data"][0])

    print("== login ==")
    p = req("login", {"exp": 1, "pot": 2, "money": 3}, headers={
        "userid": "1000000003", "uuid": "test-device"})
    assert p["data"]["account"]["guankaLimit"] == 0
    print("  data =", p["data"])

    print("== upload_user_file_4 ==")
    p = req("upload_user_file_4", [{"userid": 1000000003, "broken": True}, {}], headers={"userid": "-1"})
    assert p["data"]["primeryKey"] == "1000000003"

    print("== upload_user_file_5 ==")
    p = req("upload_user_file_5/fankui/3", [{"userid": 1000000003, "feedback": True}], headers={"userid": "1000000003"})
    assert p["data"]["primeryKey"] == "1000000003"

    print("== archive list/switch ==")
    p = req("get_archive_list")
    assert any(str(item["userid"]) == "1000000003" for item in p["data"])
    p = req("switch_archive/1000000003")
    assert p["data"]["switched"] is True

    print("== get_game_user_info_2 ==")
    p = req("get_game_user_info_2", {"notice_version": 0}, headers={"userid": "1000000003"})
    assert p["data"]["idauth"] == 0

    print("== device/email ==")
    p = req("send_email", {"email": "test@example.com", "event_type": 1}, headers={"userid": "1000000003"})
    assert p["data"]["expired_time"] > 0
    p = req("bind_device", {"email": "test@example.com", "verify_code": "123456"}, headers={"userid": "1000000003"})
    p = req("get_bind_info", headers={"userid": "1000000003"})
    assert p["data"]["is_bind"] is True
    p = req("logout_device", None, force_method="POST", headers={"userid": "1000000003", "isBind": "0"})
    assert p["errcode"] == 0

    print("== 比武 watch_fight/unwatch_fight ==")
    fight_headers = {"userid": "1000000003"}
    p = req("watch_fight", {}, headers=fight_headers)
    watch_fid = p["data"]["fid"]
    assert watch_fid
    p = req("watch_fight", {}, headers=fight_headers, expect_errcode=2)
    p = req("unwatch_fight", {"fid": watch_fid, "unwatch_time": 1}, headers=fight_headers)
    assert p["data"]["watching"] is False

    print("== 比武 join/fight2/card/result ==")
    p = req("join_fight2", {}, headers=fight_headers)
    fight_fid = p["data"]["fid"]
    p = req("fight2/4", {"fid": fight_fid}, headers=fight_headers)
    fight_id = p["data"]["id"]
    assert p["data"]["user"]["userid"] > 0
    p = req("use_fight_card", {"fid": fight_fid, "id": fight_id, "card_id": 1}, headers=fight_headers)
    assert p["data"]["used"] is True
    p = req("report_fight_result2", {
        "fid": fight_fid, "id": fight_id, "card_id": 1, "result": "win",
    }, headers=fight_headers)
    assert p["data"]["win_points"] == 10
    p = req("report_fight_result2", {
        "fid": fight_fid, "id": fight_id, "card_id": 1, "result": "win",
    }, headers=fight_headers)
    assert p["data"]["win_points"] == 10
    p = req("get_fight_times2", headers=fight_headers)
    assert "fight_times" in p["data"]
    p = req("get_fight_reward_list", headers=fight_headers)
    assert "rewards" in p["data"]
    p = req("get_fight_board/1", headers=fight_headers)
    assert isinstance(p["data"], dict)

    print("== get_time (SKIP_URL, 不校验签名) ==")
    p = req("get_time", verify_sign=False)
    print("  data.time =", p["data"]["time"])

    print("== get_token (SKIP_URL, 不校验签名) ==")
    p = req("get_token", verify_sign=False)
    print("  data =", p["data"])

    print("== hello (POST 加密请求体) ==")
    p = req("hello", {"echo": "hello mock", "n": 42})
    print("  data =", p["data"])

    print("== 404 接口 ==")
    try:
        req("not_exist_api")
        print("  FAIL: 期望 404")
    except Exception as e:
        print("  404 ok:", type(e).__name__)

    print("ALL PASS")


if __name__ == "__main__":
    main()
