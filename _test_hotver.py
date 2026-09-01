# -*- coding: utf-8 -*-
"""测试上游对不同 hotver / accept-encoding 的响应格式 (寻找 mock 前缀校验失败的场景)"""
import sys
import time
import urllib.error
import urllib.request

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

PREFIX = b"4a4848553032"

# HAR 8/24 原始请求头 (已验证 hotver=0 时返回 200 + 密文)
def build_headers(hotver, accept_encoding="identity"):
    # UTF-8 原始字节按 latin-1 解码的形态 (与 mock 收到后一致, 可无损回编码)
    app_name = "放置江湖".encode("utf-8").decode("latin-1")
    device = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
              '"dev_systemName":"android 34","dev_systemVersion":"14",'
              '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN",'
              '"app_name":"' + app_name + '","app_version":"2.1.02",'
              '"app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}')
    return {
        "accept-encoding": accept_encoding,
        "channel": "guanfang",
        "device": device,
        "hotver": str(hotver),
        "nouce": "kjcTou",
        "package": "com.xhtt.app.fzjh",
        "platform": "android",
        "sig": "cee2d43383bd1dab9688de2a25bc7512",
        "time": "0.000200",
        "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC Build/UQ1A.240205.04271925)",
        "userid": "",
        "uuid": "guanfangd0b80cf7aa09ea3538329b0d",
        "ver": "2.1.02",
    }


def test(name, hotver, accept_encoding="identity"):
    url = "http://update.xiaohoutiaotiao.com/v1/checkUpdate"
    req = urllib.request.Request(url, method="GET")
    for k, v in build_headers(hotver, accept_encoding).items():
        req.add_header(k, v)
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read()
            ok = body.lower().startswith(PREFIX)
            print("%-38s -> %s len=%-7d %.2fs 前缀OK=%s head=%s" % (
                name, resp.status, len(body), time.time() - t0, ok,
                body[:50].hex() if body else "(empty)"))
            print("    Content-Encoding=%s" % resp.headers.get("Content-Encoding"))
            return body
    except urllib.error.HTTPError as e:
        body = e.read()
        print("%-38s -> HTTP %s len=%d %.2fs body=%r" % (
            name, e.code, len(body), time.time() - t0, body[:100]))
    except Exception as e:
        print("%-38s -> %s: %s (%.2fs)" % (name, type(e).__name__, e, time.time() - t0))


print("== hotver 变量测试 (其余头与 HAR 原始请求一致) ==")
test("hotver=0 (HAR原始, 对照组)", 0)
test("hotver=14087", 14087)
test("hotver=14317 (游戏当前可能值)", 14317)
test("hotver=14318 (当前最新)", 14318)
test("hotver=99999 (超新)", 99999)

print("\n== accept-encoding 变量测试 ==")
test("hotver=0 + accept-encoding:gzip", 0, "gzip")
test("hotver=14317 + accept-encoding:gzip", 14317, "gzip")
