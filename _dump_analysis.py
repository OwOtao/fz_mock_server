# -*- coding: utf-8 -*-
"""Dump decrypted HAR analysis files (skips very large ones)."""
import os
import sys

d = "data/har_analysis"
limit = int(sys.argv[1]) if len(sys.argv) > 1 else 2000
skip = ("get_rank_list_4", "get_user_map", "get_store_list_4", "getWebConfig")
for f in sorted(os.listdir(d)):
    if f.startswith("_") or any(s in f for s in skip):
        continue
    text = open(os.path.join(d, f), encoding="utf-8").read()
    if len(text) > limit:
        text = text[:limit] + "...<truncated %dB>" % len(text)
    print("=" * 16, f, "=" * 16)
    print(text)
    print()
