# -*- coding: utf-8 -*-
"""跨抓包对比 getMd5List: 2.1.01(9-1) vs 2.1.02(9-9 / 9-10)，厘清两表语义与覆盖命中面。"""
import binascii
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")
import config  # noqa: E402
from handlers import service  # noqa: E402

STUB = hashlib.md5(b"return {}").hexdigest()


def md5list_body(path):
    har = json.load(open(path, encoding="utf-8"))
    for entry in har["log"]["entries"]:
        if "getMd5List" not in entry.get("request", {}).get("url", ""):
            continue
        text = ((entry.get("response", {}).get("content") or {}).get("text") or "").strip()
        if text:
            return entry, text.encode()
    return None, None


for label, path in (
    ("9-1(2.1.01)", os.path.join(ROOT, "so", "ProxyPin9-1_22_57_26.har")),
    ("9-9(2.1.02)", os.path.join(ROOT, "so", "ProxyPin9-9_09_12_12.har")),
    ("9-10(2.1.02)", os.path.join(ROOT, "so", "ProxyPin9-10_18_00_08.har")),
):
    if not os.path.isfile(path):
        print("%s 缺失" % label)
        continue
    entry, body = md5list_body(path)
    if body is None:
        print("%s 无 getMd5List 响应体" % label)
        continue
    hdr = {h["name"].lower(): h["value"] for h in entry["request"]["headers"]}
    raw = binascii.unhexlify(body)
    try:
        payload = json.loads(service._update_cipher(body, "dec").decode("utf-8"))
    except Exception as exc:  # noqa: BLE001
        print("%s 解密失败 %s: %s" % (label, type(exc).__name__, exc))
        continue
    data = payload.get("data") or {}
    print("=== %s ver=%s hotver=%s" % (label, hdr.get("ver"), hdr.get("hotver")))
    print("    魔数=%r hexlen=%d 顶层=%s" % (raw[:6], len(body), sorted(payload.keys())))
    for name in sorted(data):
        table = data[name]
        if isinstance(table, dict):
            stub = sum(1 for v in table.values() if v == STUB)
            print("    %-16s %6d 条, 其中存根 md5=%d" % (name, len(table), stub))
        else:
            print("    %-16s %r" % (name, table))
    if "originalMd5List" not in data:
        continue
    orig = data["originalMd5List"]
    dep = data.get("deployMd5List") or {}
    print("    original=%d deploy=%d 交集=%d 仅orig=%d 仅deploy=%d" % (
        len(orig), len(dep), len(set(orig) & set(dep)),
        len(set(orig) - set(dep)), len(set(dep) - set(orig))))
    overrides = service._md5_overrides(service._update_magic_of(body))
    hit_o = [k for k in overrides if k in orig]
    hit_d = [k for k in overrides if k in dep]
    same = [k for k in hit_o if orig[k] == overrides[k]]
    print("    本地 16 项: 在 original 命中 %d, 在 deploy 命中 %d, 与 upstream 原值相同 %d" % (
        len(hit_o), len(hit_d), len(same)))
    prefix = config.MD5_OVERRIDE_KEY_PREFIX + "/"
    print("    original 里该前缀条目: %d; 顶层目录: %s" % (
        sum(1 for k in orig if k.startswith(prefix)),
        sorted({k.split("/")[0] for k in orig})))
