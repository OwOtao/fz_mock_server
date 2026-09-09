# -*- coding: utf-8 -*-
"""对比 9-1 与 9-9 两次抓包的接口集合，并统计 9-9 新增接口。"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.stdout.reconfigure(encoding="utf-8")


def paths(entries_dir):
    out = {}
    for path in glob.glob(os.path.join(entries_dir, "*.json")):
        with open(path, encoding="utf-8") as handle:
            entry = json.load(handle)
        url = entry.get("url") or ""
        m = re.match(r"^[a-zA-Z]+://([^/]+)(/.*)$", url)
        if not m:
            continue
        host, full = m.group(1), m.group(2).split("?")[0]
        if "xiaohoutiaotiao" not in host:
            continue
        key = re.sub(r"^/api/v5/", "", full).strip("/")
        out.setdefault(key, entry.get("method"))
    return out


p91 = paths(os.path.join(ROOT, "so", "har_decrypt_91", "entries"))
p99 = paths(os.path.join(ROOT, "so", "har_decrypt_99", "entries"))

print("9-1 唯一路径: %d, 9-9 唯一路径: %d" % (len(p91), len(p99)))
print("\n=== 9-9 新增(9-1 没有) ===")
for key in sorted(set(p99) - set(p91)):
    print("  %-6s %s" % (p99[key], key))
print("\n=== 9-1 有、9-9 没有 ===")
for key in sorted(set(p91) - set(p99)):
    print("  %-6s %s" % (p91[key], key))
