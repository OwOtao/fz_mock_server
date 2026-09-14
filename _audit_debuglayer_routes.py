# -*- coding: utf-8 -*-
"""审查 DebugLayer(调试按钮)调用的所有接口在 mock_server 里的实现情况。

用法: python _audit_debuglayer_routes.py
"""
import json
import os
import re
import sys
from collections import defaultdict

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

import handlers  # noqa: F401,E402
from server import ROUTES  # noqa: E402

DEBUG_DIR = os.path.join(ROOT, "fzjh_lua", "assets", "src", "app", "views", "layer", "DebugLayer")
INVENTORY = os.path.join(ROOT, "fzjh_lua", "protocol_inventory.json")

inventory = json.load(open(INVENTORY, encoding="utf-8"))
by_name = {}
for item in inventory:
    name = item.get("name")
    urls = [u for u in (item.get("urls") or []) if isinstance(u, str) and u.strip()]
    if not name or not urls:
        continue
    # 形如 ["api/v5/", "api/service/", "test_homeland/"] 需要拼接
    joined = "".join(urls)
    for prefix in ("api/v5/", "api/service_android/", "api/service/"):
        if prefix in joined:
            joined = joined.split(prefix)[-1]
            break
    by_name.setdefault(name, set()).add(joined.strip("/"))
    by_name[name].add(urls[-1].strip("/"))

CALL_RE = re.compile(r"HttpManager(?:Ex)?:([A-Za-z_][A-Za-z0-9_]*)\s*\(")
calls = defaultdict(int)
files = defaultdict(set)
for base, _dirs, names in os.walk(DEBUG_DIR):
    for name in names:
        if not name.endswith(".lua"):
            continue
        path = os.path.join(base, name)
        with open(path, encoding="utf-8", errors="replace") as handle:
            text = handle.read()
        for match in CALL_RE.finditer(text):
            func = match.group(1)
            calls[func] += 1
            files[func].add(os.path.relpath(path, DEBUG_DIR))

SKIP = {"getTime", "getToken", "createGetResponseFunction"}


def covered(url):
    key = url.strip("/")
    if key in ROUTES:
        return key
    parts = key.split("/")
    for index in range(len(parts) - 1, 0, -1):
        candidate = "/".join(parts[:index])
        if candidate in ROUTES:
            return candidate
    return None


rows = []
for func in sorted(calls):
    if func in SKIP:
        continue
    urls = by_name.get(func)
    if not urls:
        rows.append((calls[func], func, "?", False, "-", sorted(files[func])[:2]))
        continue
    for url in sorted(urls):
        hit = covered(url)
        rows.append((calls[func], func, url, bool(hit), hit or "-", sorted(files[func])[:2]))

print("DebugLayer 调用的接口共 %d 个（去重后 %d 个 URL）"
      % (len([f for f in calls if f not in SKIP]), len(rows)))
print()
print("%-4s %-26s %-30s %-10s %s" % ("次数", "客户端函数", "URL", "状态", "实现为"))
print("-" * 108)
missing = []
for count, func, url, ok, hit, where in sorted(rows, key=lambda r: (r[3], r[1])):
    status = "OK" if ok else "未实现"
    if not ok:
        missing.append((count, func, url, where))
    print("%-4d %-26s %-30s %-10s %s" % (count, func, url, status, hit))

print()
print("=== 未实现清单（共 %d 个 URL）===" % len(missing))
for count, func, url, where in missing:
    print("  %-26s %-30s x%-3d  例: %s" % (func, url, count, ", ".join(where)))
