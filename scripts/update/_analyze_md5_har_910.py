# -*- coding: utf-8 -*-
"""getMd5List 覆盖流程 vs ProxyPin9-10 抓包 的差异核查。

核查项:
  1. HAR 里 getMd5List 请求参数(ver/hotver) 与响应密文布局(魔数/偏移/IV/密钥)
  2. 当前 handlers/service.py 的覆盖链路在真实 9-10 body 上是否走通(解密->替换->重加密->自检)
  3. 本地 debug/ + patched/ 的 16 个文件 md5, 在上游 originalMd5List / deployMd5List 里的命中与替换情况
  4. 覆盖前后客户端会看到的 md5 对照(本地文件 md5 vs 上游值 vs 覆盖后值)
"""
import binascii
import hashlib
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

import config  # noqa: E402
import jm_crypto  # noqa: E402
from handlers import service  # noqa: E402

HAR = os.path.join(ROOT, "so", "ProxyPin9-10_18_00_08.har")


def entry_of(har, needle):
    for entry in har["log"]["entries"]:
        if needle in entry.get("request", {}).get("url", ""):
            text = ((entry.get("response", {}).get("content") or {}).get("text") or "").strip()
            if text:
                return entry, text
    return None, None


har = json.load(open(HAR, encoding="utf-8"))
entry, text = entry_of(har, "getMd5List")
req = entry["request"]
body = text.encode()
raw = binascii.unhexlify(body)

print("### 1. 9-10 抓包事实")
print("  ver=%s hotver=%s uuid=%s" % (next(h["value"] for h in req["headers"] if h["name"].lower() == "ver"),
                                     next(h["value"] for h in req["headers"] if h["name"].lower() == "hotver"),
                                     next(h["value"] for h in req["headers"] if h["name"].lower() == "uuid")))
print("  响应 hexlen=%d rawlen=%d 魔数=%r 密文块对齐=%s" % (
    len(body), len(raw), raw[:6], (len(raw) - 6) % 16 == 0))
print("  md5(响应体)=%s" % hashlib.md5(body).hexdigest())

print("\n  各密钥组尝试解密(偏移 6, 静态 IV):")
groups = service._update_groups()
for magic, (key, iv) in sorted(groups.items()):
    payload = raw[len(magic):]
    payload = payload[: len(payload) - (len(payload) % 16)]
    plain = jm_crypto._aes_cbc(payload, key, iv, "dec").rstrip(b"0")
    ok = plain.lstrip()[:1] in (b"{", b"[")
    print("    %-8s iv=%-18s 明文头=%-20r JSON=%s" % (
        magic.decode(), iv.decode("ascii", "replace"), plain[:18], ok))

print("\n### 2. 当前覆盖链路在真实 9-10 body 上跑一遍")
print("  _update_magic_of -> %r" % service._update_magic_of(body))
print("  _response_prefixes 命中 -> %s" % body.lower().startswith(service._response_prefixes()))
out = service._read_update_response(type("R", (), {
    "status": 200, "headers": {"Content-Length": str(len(body))}, "read": lambda self, n=None: body})())
print("  完整性校验 -> 通过, 回传 %d 字节" % len(out["body"]))

payload_before = json.loads(service._update_cipher(body, "dec").decode("utf-8"))
data_before = payload_before["data"]
orig = data_before["originalMd5List"]
dep = data_before["deployMd5List"]
print("  上游清单: original=%d deploy=%d 交集=%d 仅orig=%d 仅deploy=%d" % (
    len(orig), len(dep), len(set(orig) & set(dep)), len(set(orig) - set(dep)), len(set(dep) - set(orig))))
print("  交集内两表值相同条数=%d (deploy 的 DebugLayer 条目 = md5(b'return {}') 存根)" % (
    sum(1 for k in set(orig) & set(dep) if orig[k] == dep[k])))

result = service._apply_md5_override({"body": body, "status_code": 200, "headers": {
    "Content-Length": str(len(body)), "ETag": "x"}})
print("  覆盖后 body 变化: %s (len %d -> %d)" % (result["body"] != body, len(body), len(result["body"])))
after = json.loads(service._update_cipher(result["body"], "dec").decode("utf-8"))["data"]
new_raw = service._decode_update_raw(result["body"])
print("  覆盖后加密组: %r  (上游 %r)" % (new_raw[:6], raw[:6]))
print("  覆盖后条目数: original=%d deploy=%d" % (len(after["originalMd5List"]), len(after["deployMd5List"])))

print("\n### 3. 本地文件 md5 与上游/覆盖后对照")
overrides = service._md5_overrides(service._update_magic_of(body))
print("  本地覆盖项 %d 个 (debug/ %d 个文件 + extra %d 个)" % (
    len(overrides), sum(1 for _ in config.MD5_OVERRIDE_DIR and __import__("pathlib").Path(config.MD5_OVERRIDE_DIR).rglob("*") if _.is_file()),
    len(config.MD5_OVERRIDE_EXTRA_FILES)))
same = differ = miss = 0
print("  %-46s %-10s %-10s %-10s %-10s" % ("清单键名(尾)", "本地md5", "上游orig", "上游deploy", "覆盖后"))
for key in sorted(overrides):
    local = overrides[key]
    up_o = orig.get(key)
    up_d = dep.get(key)
    new_o = after["originalMd5List"].get(key)
    new_d = after["deployMd5List"].get(key)
    if up_o == local:
        same += 1
    elif up_o is None:
        miss += 1
    else:
        differ += 1
    print("  %-46s %-10s %-10s %-10s %-10s" % (
        key.split("/")[-1], local[:8], (up_o or "-")[:8], (up_d or "-")[:8],
        ((new_o or "-")[:4] + "/" + (new_d or "-")[:4])))
print("  与上游一致(无需改): %d, 上游值不同(需要改): %d, 上游缺失: %d" % (same, differ, miss))

bad = [k for k in overrides if after["originalMd5List"].get(k) != overrides[k]
       or after["deployMd5List"].get(k) != overrides[k]]
print("  覆盖后两表都等于本地 md5 的键: %d/%d, 不匹配: %s" % (
    len(overrides) - len(bad), len(overrides), bad))

print("\n### 4. 结论性检查")
print("  GET /v1/getMd5List 路由存在: %s" % ("v1/getMd5List" in __import__("server").ROUTES))
print("  响应加密组配置 RESPONSE_GROUP_BY_PATH: %r" % config.RESPONSE_GROUP_BY_PATH.get("v1/getMd5List"))
