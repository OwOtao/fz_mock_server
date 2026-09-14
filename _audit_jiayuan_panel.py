# -*- coding: utf-8 -*-
"""聚焦审查 TestLayer.lua「家园」面板(setJiaYuanButton + npcFunc/checkAllHomelandNpc/
setDispatchTaskBtn 等)调用的接口在 mock_server 里的实现情况。

范围: TestLayer.lua 中 setJiaYuanButton 起, 到"返回"按钮(checkAllHomelandNpc 调用)结束。
用法: python -X utf8 _audit_jiayuan_panel.py
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

import handlers  # noqa: F401,E402
from server import ROUTES  # noqa: E402

LAYER = os.path.join(ROOT, "fzjh_lua", "assets", "src", "app", "views", "layer",
                     "DebugLayer", "TestLayer.lua")
INVENTORY = os.path.join(ROOT, "fzjh_lua", "protocol_inventory.json")

START_MARK = "function TestFuncLayer:setJiaYuanButton()"
END_MARK = "function TestFuncLayer:setDispatchTaskBtn()"

inventory = json.load(open(INVENTORY, encoding="utf-8"))
by_name = {}
for item in inventory:
    name = item.get("name")
    urls = [u for u in (item.get("urls") or []) if isinstance(u, str) and u.strip()]
    if not name or not urls:
        continue
    joined = "".join(urls)
    for prefix in ("api/v5/", "api/service_android/", "api/service/"):
        if prefix in joined:
            joined = joined.split(prefix)[-1]
            break
    by_name.setdefault(name, set()).add(joined.strip("/"))
    by_name[name].add(urls[-1].strip("/"))

text = open(LAYER, encoding="utf-8").read()
start = text.index(START_MARK)
end = text.index(END_MARK)
panel = text[start:end]
line_base = text[:start].count("\n") + 1

print("家园面板范围: TestLayer.lua 第 %d 行 ~ 第 %d 行（%d 字符）"
      % (line_base, text[:end].count("\n") + 1, len(panel)))
print()

# 面板里用到的客户端函数 -> 调用处行号
call_lines = {}
for match in re.finditer(r"HttpManager(?:Ex)?:([A-Za-z_][A-Za-z0-9_]*)\s*\(", panel):
    line_no = line_base + panel[:match.start()].count("\n")
    call_lines.setdefault(match.group(1), []).append(line_no)

# 面板内联的 HttpManager 调用(局部函数 addZc 等)也要覆盖, 直接扫调用名即可
missing = []
print("%-22s %-42s %-8s %s" % ("客户端函数", "URL", "状态", "调用行"))
print("-" * 100)
for func in sorted(call_lines):
    urls = by_name.get(func)
    if not urls:
        print("%-22s %-42s %-8s %s" % (func, "?", "未登记", sorted(set(call_lines[func]))))
        missing.append((func, "?", sorted(set(call_lines[func]))))
        continue
    for url in sorted(urls):
        key = url.strip("/")
        hit = None
        if key in ROUTES:
            hit = key
        else:
            parts = key.split("/")
            for index in range(len(parts) - 1, 0, -1):
                candidate = "/".join(parts[:index])
                if candidate in ROUTES:
                    hit = candidate
                    break
        status = "OK" if hit else "未实现"
        if not hit:
            missing.append((func, url, sorted(set(call_lines[func]))))
        print("%-22s %-42s %-8s %s" % (func, url, status, sorted(set(call_lines[func]))))

print()
print("=== 家园面板仍未实现（%d）===" % len(missing))
for func, url, lines in missing:
    print("  %-22s %-42s 行 %s" % (func, url, lines))
