# -*- coding: utf-8 -*-
"""决定性体检: 逐条比对 deployMd5List(客户端落地/校验用的那张表) 与设备热更目录实际字节。
输出三类: 一致 / 不一致(会被判"损坏"并触发重下) / 设备缺失。
另外统计 originalMd5List 与设备的差异, 说明两张表的口径。
"""
import hashlib
import json
import os
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT))
sys.stdout.reconfigure(encoding="utf-8")
from handlers import service  # noqa: E402

DEV = "/data/data/com.xhtt.app.fzjh/files/updatePath_android_2.1.02"


def sh(cmd, timeout=600):
    try:
        out = subprocess.run(["adb", "shell", "su -c '%s'" % cmd], capture_output=True, timeout=timeout)
        return out.stdout.decode("utf-8", "replace")
    except subprocess.TimeoutExpired:
        return ""


har = json.load(open(ROOT / "so" / "ProxyPin9-10_18_00_08.har", encoding="utf-8"))
for entry in har["log"]["entries"]:
    if "getMd5List" in entry["request"]["url"]:
        body = (entry["response"]["content"]["text"] or "").strip().encode()
        break
lists = json.loads(service._update_cipher(body, "dec").decode())["data"]
orig, dep = lists["originalMd5List"], lists["deployMd5List"]

listing = sh("cd %s && find src res -type f -exec md5sum {} + 2>/dev/null" % DEV)
device = {}
for line in listing.splitlines():
    parts = line.split(None, 1)
    if len(parts) == 2:
        device[parts[1].strip()] = parts[0]
print("设备热更目录文件数: %d" % len(device))

for label, table in (("deployMd5List", dep), ("originalMd5List", orig)):
    same = diff = absent = 0
    bad = []
    for key, want in table.items():
        got = device.get(key)
        if got is None:
            absent += 1
        elif got == want:
            same += 1
        else:
            diff += 1
            if len(bad) < 400:
                bad.append((key, got, want))
    print("\n### %s: 共 %d 条" % (label, len(table)))
    print("    与设备一致 %d, 不一致 %d, 设备(热更目录)没有 %d" % (same, diff, absent))
    if bad and label == "deployMd5List":
        print("    不一致明细(前 40):")
        for key, got, want in bad[:40]:
            print("      %-72s 设备=%s 清单=%s" % (key, got[:10], want[:10]))

# 只看本次覆盖的 16 个键
ov = service._md5_overrides(service._update_magic_of(body))
print("\n### 覆盖键在两张表里与设备的关系")
for key in sorted(ov):
    got = device.get(key)
    print("  %-46s 设备=%s orig=%s dep=%s 本地文件=%s"
          % (key.split("layer/")[-1], (got or "(缺失)")[:10], (orig.get(key) or "-")[:10],
             (dep.get(key) or "-")[:10], ov[key][:10]))
