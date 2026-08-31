# -*- coding: utf-8 -*-
"""解析 ProxyPin HAR, 找 get_game_config 的响应头 (FXXF01 key 来源)."""
import json
import os

HAR_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "so", "ProxyPin8-24_14_40_30.har")
)

with open(HAR_PATH, "r", encoding="utf-8") as f:
    har = json.load(f)

entries = har.get("log", {}).get("entries", [])
print(f"共 {len(entries)} 个请求\n")

for i, e in enumerate(entries):
    req = e.get("request", {})
    resp = e.get("response", {})
    url = req.get("url", "")
    method = req.get("method", "")
    status = resp.get("status", "")

    # 只关注游戏 API
    if "xiaohoutiaotiao" not in url and "xhtt" not in url and "fzjh" not in url:
        continue

    print(f"[{i}] {method} {status} {url}")

    # 打印所有响应头
    headers = resp.get("headers", [])
    for h in headers:
        name = h.get("name", "")
        value = h.get("value", "")
        # 高亮自定义头 (非标准 HTTP 头)
        std = {"content-type", "content-length", "date", "server", "connection",
               "set-cookie", "cache-control", "pragma", "expires", "vary",
               "transfer-encoding", "content-encoding", "keep-alive"}
        mark = " <<<" if name.lower() not in std else ""
        print(f"    {name}: {value}{mark}")

    # 响应体预览
    content = resp.get("content", {})
    text = content.get("text", "")
    if text:
        preview = text[:120].replace("\n", " ")
        print(f"    body[{content.get('size', '?')}B]: {preview}")
    print()
