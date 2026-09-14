# -*- coding: utf-8 -*-
"""探测真实 /v1/updateFileList：不同方法/体的响应差异。

只发最小请求（空体/一个空表），用于判断该接口的语义与响应形态。
"""
import json
import os
import sys
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

from handlers import service  # noqa: E402

BASE = "http://update.xiaohoutiaotiao.com/v1/updateFileList"

device = None
for entry in json.load(open(os.path.join(ROOT, "so", "ProxyPin9-9_09_12_12.har"), encoding="utf-8"))["log"]["entries"]:
    if "getMd5List" in entry.get("request", {}).get("url", ""):
        for header in entry["request"].get("headers", []):
            if header["name"].lower() == "device":
                device = header["value"]
        break

HEADERS = {
    "accept-encoding": "identity",
    "uuid": "guanfangd0b80cf7aa09ea3538329b0d",
    "ver": "2.1.02",
    "hotver": "15427",
    "device": device,
    "platform": "android",
    "channel": "guanfang",
    "package": "com.xhtt.app.fzjh",
    "userid": "",
    "time": "0.000300",
    "nouce": "SxNyyk",
    "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC Build/UQ1A.240205.04271925)",
}


def show(label, request):
    try:
        with urllib.request.urlopen(request, timeout=20) as response:
            status, body, headers = response.status, response.read(), dict(response.headers.items())
    except urllib.error.HTTPError as error:
        status, body, headers = error.code, error.read(), dict(error.headers.items())
    except Exception as error:  # noqa: BLE001
        print("%-34s 失败: %s: %s" % (label, type(error).__name__, str(error)[:90]))
        return
    magic = service._update_magic_of(body)
    text = ""
    if magic:
        try:
            text = service._update_cipher(body, "dec").decode("utf-8")
        except Exception as error:  # noqa: BLE001
            text = "<解密失败 %s>" % error
    else:
        text = repr(body[:200])
    print("%-34s HTTP %s  %d 字节  magic=%r" % (label, status, len(body), magic))
    print("      %s" % text[:300])


def build(method, body=None, content_type="application/x-www-form-urlencoded"):
    request = urllib.request.Request(BASE, method=method, data=body)
    for key, value in HEADERS.items():
        request.add_header(key, value)
    if body is not None:
        request.add_header("Content-Type", content_type)
    return request


show("GET  (无体)", build("GET"))
show("POST (空体)", build("POST", b""))
show("POST {}", build("POST", b"{}"))
show("POST {\"fileList\":{}}", build("POST", json.dumps({"fileList": {}}).encode()))
show("POST 明文 md5 映射", build("POST", json.dumps({
    "src/app/views/layer/MainLayer.lua": "0" * 32,
}).encode()))
