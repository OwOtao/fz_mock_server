# -*- coding: utf-8 -*-
"""看线上 checkUpdate 现在返回什么（决定客户端会不会整包更新）。

复用 _probe_getmd5list.py 里从抓包取的请求头。
"""
import json
import os
import sys
import urllib.error
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

import importlib.util

spec = importlib.util.spec_from_file_location("_probe_headers", os.path.join(ROOT, "_probe_getmd5list.py"))
probe = importlib.util.module_from_spec(spec)
# 只取其 HEADERS 定义: 避免执行整个脚本, 手工解析那段配置
device = None
har_path = os.path.join(ROOT, "so", "ProxyPin9-9_09_12_12.har")
for entry in json.load(open(har_path, encoding="utf-8"))["log"]["entries"]:
    if "getMd5List" in entry.get("request", {}).get("url", ""):
        for header in entry["request"].get("headers", []):
            if header["name"].lower() == "device":
                device = header["value"]
        break

sys.path.insert(0, ROOT)
from handlers import service  # noqa: E402

HEADERS = {
    "accept-encoding": "identity",
    "uuid": "guanfangd0b80cf7aa09ea3538329b0d",
    "ver": "2.1.02",
    "hotver": "14318",
    "device": device,
    "platform": "android",
    "channel": "guanfang",
    "package": "com.xhtt.app.fzjh",
    "userid": "",
    "time": "0.000300",
    "nouce": "SxNyyk",
    "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC Build/UQ1A.240205.04271925)",
}

BASE = "http://update.xiaohoutiaotiao.com/v1"


def get(endpoint):
    request = urllib.request.Request(BASE + "/" + endpoint, method="GET")
    for key, value in HEADERS.items():
        request.add_header(key, value)
    try:
        with urllib.request.urlopen(request, timeout=30) as response:
            return response.status, response.read()
    except urllib.error.HTTPError as error:
        return error.code, error.read()


for endpoint in ("checkUpdate",):
    for hotver in ("14087", "14318", "15427", "99999"):
        HEADERS["hotver"] = hotver
        status, body = get(endpoint)
        magic = service._update_magic_of(body)
        text = ""
        if magic:
            try:
                text = service._update_cipher(body, "dec").decode("utf-8")
            except Exception as error:  # noqa: BLE001
                text = "解密失败: %s" % error
        else:
            text = repr(body[:200])
        print("hotver=%-6s -> HTTP %s  %s" % (hotver, status, text[:200]))

print()
for endpoint in ("getMd5List",):
    HEADERS["hotver"] = "15427"
    status, body = get(endpoint)
    print("=== %s -> HTTP %s, %d 字节, 魔数 %r" % (endpoint, status, len(body), service._update_magic_of(body)))
    if service._update_magic_of(body):
        try:
            print("    解密: %s" % service._update_cipher(body, "dec").decode("utf-8")[:200])
        except Exception as error:  # noqa: BLE001
            print("    解密失败: %s" % error)
    else:
        print("    非密文: %r" % body[:200])
