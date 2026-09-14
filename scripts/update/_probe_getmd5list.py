# -*- coding: utf-8 -*-
"""模拟 update proxy 的 getMd5List 请求 -> 解密 -> 汇总返回内容。

请求头取自 so/ProxyPin9-9_09_12_12.har 里 entry 165 的真实抓包(以及 server.log
里 update proxy 转发的那一份), 因此参数与线上一致。
沙箱/网络不可达时回退到 .diagnostics/md5_upstream_latest.bin(用户保存的真实响应)。
"""
import binascii
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

import config  # noqa: E402
from handlers import service  # noqa: E402

URL = "http://update.xiaohoutiaotiao.com/v1/getMd5List"
# device 头含中文(UTF-8 被按 latin-1 读出来的样子), 必须原样取抓包值:
# urllib 用 latin-1 编码 header, 自己拼 JSON 会抛 UnicodeEncodeError。
DEVICE = None
HAR = os.path.join(ROOT, "so", "ProxyPin9-9_09_12_12.har")
try:
    with open(HAR, encoding="utf-8") as handle:
        _har = json.load(handle)
    for _entry in _har["log"]["entries"]:
        if "getMd5List" not in _entry.get("request", {}).get("url", ""):
            continue
        for _header in _entry["request"].get("headers", []):
            if _header["name"].lower() == "device":
                DEVICE = _header["value"]
                break
        if DEVICE:
            break
except (OSError, ValueError, KeyError):
    DEVICE = None
if not DEVICE:
    DEVICE = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
              '"dev_systemName":"android 34","dev_systemVersion":"14",'
              '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WIFI",'
              '"app_name":"fzjh","app_version":"2.1.02","app_build":"android-25",'
              '"app_channel":"guanfang","imei":"","oaid":""}')
print("device 头来源: %s (%d 字符)" % ("抓包" if DEVICE and "app_name" in DEVICE else "兜底",
                                       len(DEVICE or "")))

# 抓包 entry 165 的原始参数
HEADERS = {
    "accept-encoding": "identity",
    "uuid": "guanfangd0b80cf7aa09ea3538329b0d",
    "ver": "2.1.02",
    "hotver": "14318",
    "device": DEVICE,
    "platform": "android",
    "channel": "guanfang",
    "package": "com.xhtt.app.fzjh",
    "userid": "",
    "time": "0.000300",
    "sig": "8ddf738270e0fcf6779570f485aedca7",
    "nouce": "SxNyyk",
    "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC Build/UQ1A.240205.04271925)",
}


def fetch(headers, timeout=12):
    request = urllib.request.Request(URL, method="GET")
    for key, value in headers.items():
        request.add_header(key, value)
    with urllib.request.urlopen(request, timeout=timeout) as response:
        return response.status, dict(response.headers.items()), response.read()


def summarize(body, label):
    print("\n=== %s ===" % label)
    print("  长度: %d 字节" % len(body))
    print("  开头: %r" % body[:48])
    magic = service._update_magic_of(body)
    print("  魔数: %r" % magic)
    if magic is None:
        try:
            print("  非密文(前 200 字符): %s" % body[:200].decode("utf-8", "replace"))
        except Exception:  # noqa: BLE001
            pass
        return None
    try:
        payload = json.loads(service._update_cipher(body, "dec").decode("utf-8"))
    except Exception as error:  # noqa: BLE001
        print("  解密/解析失败: %s: %s" % (type(error).__name__, str(error)[:160]))
        return None
    data = payload.get("data") if isinstance(payload, dict) else None
    print("  顶层字段: %s" % sorted(payload.keys()))
    if isinstance(data, dict):
        print("  data 字段: %s" % sorted(data.keys()))
        for name in ("originalMd5List", "deployMd5List"):
            table = data.get(name)
            if isinstance(table, dict):
                print("    %s: %d 条" % (name, len(table)))
        for key in ("hotver", "ver", "version", "updateType"):
            if key in data:
                print("    %s = %r" % (key, data[key]))
    return payload


print("### 1) 直接请求线上(使用抓包参数)")
live_body = None
try:
    status, headers, body = fetch(HEADERS)
    print("  HTTP %s, Content-Length=%s, 实际读回=%d 字节"
          % (status, headers.get("Content-Length"), len(body)))
    print("  响应头: %s" % {k: v for k, v in headers.items() if k.lower() not in ("date",)})
    live_body = body
    live = summarize(body, "线上响应解密结果")
except urllib.error.HTTPError as error:
    print("  HTTPError %s: %s" % (error.code, error.reason))
    print("  响应体(前 300 字节): %r" % error.read()[:300])
    live = None
except Exception as error:  # noqa: BLE001
    print("  请求失败: %s: %s" % (type(error).__name__, str(error)[:200]))
    live = None

print("\n### 2) 回退: .diagnostics/md5_upstream_latest.bin")
saved = os.path.join(ROOT, ".diagnostics", "md5_upstream_latest.bin")
payload = None
if os.path.isfile(saved):
    body = open(saved, "rb").read()
    payload = summarize(body, "已保存的真实响应")
    if live_body is not None:
        import hashlib
        print("\n  === 线上响应 vs 本地保存 ===")
        print("    线上 md5=%s (%d 字节)" % (hashlib.md5(live_body).hexdigest(), len(live_body)))
        print("    本地 md5=%s (%d 字节)" % (hashlib.md5(body).hexdigest(), len(body)))
        print("    完全一致: %s" % (live_body == body))
else:
    print("  文件不存在")

if payload:
    data = payload.get("data") or {}
    original = data.get("originalMd5List") or {}
    deploy = data.get("deployMd5List") or {}
    print("\n### 3) 清单内容抽样")
    keys = sorted(original)
    print("  originalMd5List 前 5 条:")
    for key in keys[:5]:
        print("    %-64s %s" % (key, original[key]))
    print("  deployMd5List 前 5 条:")
    for key in sorted(deploy)[:5]:
        print("    %-64s %s" % (key, deploy[key]))
    prefix = config.MD5_OVERRIDE_KEY_PREFIX + "/"
    debug_keys = [k for k in original if k.startswith(prefix)]
    print("\n  本地 debug 目录前缀(%s)命中: %d 条" % (config.MD5_OVERRIDE_KEY_PREFIX, len(debug_keys)))
    for key in debug_keys[:5]:
        print("    %s" % key)
    extra = "src/app/views/layer/MainLayer.lua"
    print("  补丁键 %s 存在: %s -> %s" % (extra, extra in original, original.get(extra)))
    kinds = {}
    for key in original:
        parts = key.split("/")
        kinds[parts[0]] = kinds.get(parts[0], 0) + 1
    print("\n  按顶层目录统计:")
    for name, count in sorted(kinds.items(), key=lambda kv: -kv[1]):
        print("    %-12s %d" % (name, count))

    print("\n### 4) 两张表的关系")
    both = sorted(set(original) & set(deploy))
    only_original = len(set(original) - set(deploy))
    only_deploy = len(set(deploy) - set(original))
    differ = [k for k in both if original[k] != deploy[k]]
    print("  originalMd5List=%d, deployMd5List=%d" % (len(original), len(deploy)))
    print("  两表都有: %d 条; 仅 original: %d; 仅 deploy: %d" % (len(both), only_original, only_deploy))
    print("  两表都有且 md5 不同: %d 条" % len(differ))
    for key in differ[:5]:
        print("    %-56s original=%s deploy=%s" % (key, original[key][:12], deploy[key][:12]))
    debug_in_deploy = [k for k in debug_keys if k in deploy]
    print("  DebugLayer 的 %d 条中, 同时出现在 deployMd5List 的: %d 条"
          % (len(debug_keys), len(debug_in_deploy)))
    print("  deployMd5List 覆盖的顶层目录: %s"
          % sorted({k.split("/")[0] for k in deploy}))
