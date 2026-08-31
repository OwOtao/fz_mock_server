# -*- coding: utf-8 -*-
"""扫描 HAR: 找 FXXF01 响应体 + 所有自定义响应头."""
import json, os

HAR_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "so", "ProxyPin8-24_14_40_30.har")
)

with open(HAR_PATH, "r", encoding="utf-8") as f:
    har = json.load(f)

entries = har.get("log", {}).get("entries", [])

STD_HEADERS = {"content-type", "content-length", "date", "server", "connection",
               "set-cookie", "cache-control", "pragma", "expires", "vary",
               "transfer-encoding", "content-encoding", "keep-alive", "x-powered-by"}

print("=== 1. 查找 FXXF01 响应体 (465858463031 开头) ===")
found_fxxf = False
for i, e in enumerate(entries):
    body = e.get("response", {}).get("content", {}).get("text", "") or ""
    if body.lower().startswith("465858463031"):
        found_fxxf = True
        url = e.get("request", {}).get("url", "")
        print(f"  [{i}] {url}")
        print(f"      body_len={len(body)}")
if not found_fxxf:
    print("  (无 FXXF01 响应体)")

print("\n=== 2. 所有游戏域名的自定义响应头 ===")
for i, e in enumerate(entries):
    url = e.get("request", {}).get("url", "")
    if "xiaohoutiaotiao" not in url:
        continue
    headers = e.get("response", {}).get("headers", [])
    custom = [(h["name"], h["value"]) for h in headers
              if h.get("name", "").lower() not in STD_HEADERS]
    short_url = url.split("?")[0]
    print(f"  [{i}] {short_url}")
    if custom:
        for name, value in custom:
            print(f"      {name}: {value}")
    else:
        print(f"      (仅标准头)")

print("\n=== 3. 所有响应体 magic 统计 ===")
magic_map = {}
for i, e in enumerate(entries):
    body = e.get("response", {}).get("content", {}).get("text", "") or ""
    if len(body) >= 12 and all(c in "0123456789abcdefABCDEF" for c in body[:12]):
        magic_hex = body[:12].lower()
        try:
            magic = bytes.fromhex(magic_hex).decode("ascii")
        except Exception:
            magic = magic_hex
        magic_map.setdefault(magic, []).append(i)
for magic, idxs in sorted(magic_map.items()):
    print(f"  {magic}: {len(idxs)} 个响应 -> entries {idxs[:8]}")
