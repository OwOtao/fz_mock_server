# -*- coding: utf-8 -*-
"""只读: 在设备上找客户端的热更 md5 映射文件 / 被还原的 lua, 判定"文件损坏"的对象。

扫码位置:
  - /data/data/com.xhtt.app.fzjh/files 及其子目录 (排除第三方 SDK 目录)
  - 文件内容含 "app/views/layer" 或 "md5" 之类键名, 或大小 10KB~5MB 的文本
不写入设备。
"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import hashlib
import os
import re
import subprocess
import sys

sys.stdout.reconfigure(encoding="utf-8")
PKG = "com.xhtt.app.fzjh"
BASE = "/data/data/%s/files" % PKG
SKIP = ("pangle", "umeng", ".um", "app_webview", "bykv", "vlog", "apminsight", "cache")


def sh(cmd, timeout=60):
    try:
        out = subprocess.run(["adb", "shell", "su -c '%s'" % cmd], capture_output=True, timeout=timeout)
        return out.stdout.decode("utf-8", "replace"), out.stderr.decode("utf-8", "replace")
    except subprocess.TimeoutExpired:
        return "", "调用超时"


print("### 1. files 顶层之外的可疑文件 (排除第三方 SDK)")
out, err = sh("find %s -maxdepth 2 -type f 2>/dev/null | head -200" % BASE)
paths = [p for p in out.split() if p and not any(s in p for s in SKIP)]
for p in paths[:60]:
    print("  ", p)

print("\n### 2. 含 'app/views/layer' 或 'md5' 键的文件 (可能的映射表)")
out, _ = sh("grep -rl 'app/views/layer' %s --include=* 2>/dev/null | grep -v pangle | head -20" % BASE, timeout=120)
print(out.strip() or "  (无)")

print("\n### 3. 设备上是否还有被改过的 DebugLayer / MainLayer 全文")
for rel in ("DebugLayer/DebugLayer.lua", "MainLayer.lua", "DebugLayer/DebugConfig.lua"):
    out, _ = sh("find %s /sdcard -name '%s' -type f 2>/dev/null | head -10"
                % (BASE, os.path.basename(rel)))
    for line in out.split():
        h, _ = sh("md5sum '%s'" % line)
        sz, _ = sh("wc -c < '%s'" % line)
        print("  %-70s %s 字节  %s" % (line, sz.strip(), h.strip().split(" ")[0] if h.strip() else "?"))
