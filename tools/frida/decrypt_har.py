# -*- coding: utf-8 -*-
"""解密 HAR 中 get_game_config / exchange_publickey 的响应体."""
import sys, os, json, binascii
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mock_server"))
import jm_crypto

HAR_PATH = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..", "so", "ProxyPin8-24_14_40_30.har")
)

with open(HAR_PATH, "r", encoding="utf-8") as f:
    har = json.load(f)

entries = har.get("log", {}).get("entries", [])

TARGETS = ["get_game_config", "exchange_publickey", "get_version_info"]

for e in entries:
    url = e.get("request", {}).get("url", "")
    if not any(t in url for t in TARGETS):
        continue

    body = e.get("response", {}).get("content", {}).get("text", "")
    if not body:
        continue

    print(f"\n{'='*70}")
    print(f"URL: {url}")
    print(f"body 前 12 字符 (magic hex): {body[:12]}")

    # 请求体也看一下
    post = e.get("request", {}).get("postData", {}).get("text", "")
    if post:
        print(f"request body: {post[:200]}")
        # 尝试解密请求体
        try:
            req_plain = jm_crypto.decrypt(post.strip())
            print(f"request 解密: {req_plain[:300]}")
        except Exception as ex:
            print(f"request 解密失败: {ex}")

    try:
        plain = jm_crypto.decrypt(body.strip())
        text = plain.decode("utf-8", errors="replace")
        print(f"\n--- 解密结果 ({len(text)} chars) ---")
        # 尝试格式化 JSON
        try:
            obj = json.loads(text)
            print(json.dumps(obj, ensure_ascii=False, indent=2)[:3000])
        except Exception:
            print(text[:3000])
    except Exception as ex:
        print(f"解密失败: {ex}")
