# -*- coding: utf-8 -*-
"""测试 ver=2.1.01 / 空 header 值 / 重定向 场景的上游响应"""
import sys
import time
import urllib.error
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")

PREFIX = b"4a4848553032"


def build(**overrides):
    app_name = "放置江湖".encode("utf-8").decode("latin-1")
    device = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
              '"dev_systemName":"android 34","dev_systemVersion":"14",'
              '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN",'
              '"app_name":"' + app_name + '","app_version":"2.1.02",'
              '"app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}')
    h = {
        "accept-encoding": "identity",
        "channel": "guanfang",
        "device": device,
        "hotver": "14317",
        "nouce": "kjcTou",
        "package": "com.xhtt.app.fzjh",
        "platform": "android",
        "sig": "cee2d43383bd1dab9688de2a25bc7512",
        "time": "0.000200",
        "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC)",
        "userid": "",
        "uuid": "guanfangd0b80cf7aa09ea3538329b0d",
        "ver": "2.1.02",
    }
    h.update(overrides)
    return h


def test(name, **kw):
    device_override = kw.pop("device_version", None)
    headers = build(**kw)
    if device_override:
        headers["device"] = headers["device"].replace('"app_version":"2.1.02"', '"app_version":"%s"' % device_override)
    req = urllib.request.Request("http://update.xiaohoutiaotiao.com/v1/checkUpdate", method="GET")
    for k, v in headers.items():
        req.add_header(k, v)
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read()
            ok = body.lower().startswith(PREFIX)
            print("%-50s -> %s len=%-6d %.2fs 前缀OK=%-5s head=%s" % (
                name, resp.status, len(body), time.time() - t0, ok,
                body[:48].hex() if body else "(empty)"))
            if not ok:
                print("    !! 非密文: %r" % body[:150])
    except urllib.error.HTTPError as e:
        print("%-50s -> HTTP %s %.2fs location=%s body=%r" % (
            name, e.code, time.time() - t0, e.headers.get("Location"), e.read()[:120]))
    except Exception as e:
        print("%-50s -> %s: %s (%.2fs)" % (name, type(e).__name__, e, time.time() - t0))


print("== ver 变量 ==")
test("ver=2.1.02 (HAR 对照)", ver="2.1.02")
test("ver=2.1.01 (工作区 APK 版本)", ver="2.1.01")
test("ver=2.1.01 + device app_version=2.1.01", ver="2.1.01", device_version="2.1.01")
test("ver 为空字符串", ver="")
test("ver=2.1.00", ver="2.1.00")

print("\n== 空 header 值 ==")
test("platform 为空字符串", platform="")
test("package 为空字符串", package="")
test("hotver 为空字符串", hotver="")
test("uuid 为空字符串", uuid="")
test("channel 为空字符串", channel="")

print("\n== device 中 app_version 变体 ==")
test("device app_version=2.1.01 (ver 仍 2.1.02)", device_version="2.1.01")
