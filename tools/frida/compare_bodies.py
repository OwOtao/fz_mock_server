# -*- coding: utf-8 -*-
"""对比 server_config_raw.bin (FXXF01, 8-06) 与 HAR get_game_config (JHHU02, 8-07)."""
import json, os, binascii

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
RAW = os.path.join(ROOT, "research", "crypto_tests", "server_config_raw.bin")
HAR = os.path.join(ROOT, "so", "ProxyPin8-24_14_40_30.har")

raw = open(RAW, "rb").read().strip()
print(f"server_config_raw.bin: {len(raw)} hex chars = {len(raw)//2} bytes")
print(f"  magic: {bytes.fromhex(raw[:12].decode()).decode()}")

with open(HAR, "r", encoding="utf-8") as f:
    har = json.load(f)
for e in har["log"]["entries"]:
    if "get_game_config" in e.get("request", {}).get("url", ""):
        har_body = e["response"]["content"]["text"].strip()
        print(f"\nHAR get_game_config: {len(har_body)} hex chars = {len(har_body)//2} bytes")
        print(f"  magic: {bytes.fromhex(har_body[:12]).decode()}")
        print(f"\n  两 body 长度相同: {len(raw) == len(har_body)}")
        print(f"  两 body 完全相同: {raw.decode() == har_body}")
        # 对比密文部分 (去掉 12 字符 magic)
        raw_ct = raw[12:].decode()
        har_ct = har_body[12:]
        same_ct = raw_ct == har_ct
        print(f"  密文部分(去magic)相同: {same_ct}")
        if not same_ct:
            # 看前 64 字符差异
            print(f"  raw 密文前64: {raw_ct[:64]}")
            print(f"  har 密文前64: {har_ct[:64]}")
        break
