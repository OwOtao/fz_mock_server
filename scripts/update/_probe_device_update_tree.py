# -*- coding: utf-8 -*-
"""只读探测: 设备上 2.1.02 热更目录的现状(解释为什么本地 lua 被还原)。

用 adb (root) 读取:
  1. 设备 updatePath 里 DebugLayer / MainLayer / DebugConfig 等文件的字节与 md5
  2. 与本地 mock_server/debug/*.lua、patched/MainLayer.lua、官方包 research/updatePath_android_2.1.02 对照
  3. 设备 app.lst 版本
不写入设备。
"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import hashlib
import os
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.stdout.reconfigure(encoding="utf-8")

DEV = "/data/data/com.xhtt.app.fzjh/files/updatePath_android_2.1.02"
STUB = hashlib.md5(b"return {}").hexdigest()
OFFICIAL = ROOT / "research" / "updatePath_android_2.1.02"

KEYS = [
    "src/app/views/layer/DebugLayer/DebugLayer.lua",
    "src/app/views/layer/DebugLayer/AnimOldFightTestLayer.lua",
    "src/app/views/layer/DebugLayer/DebugConfig.lua",
    "src/app/views/layer/DebugLayer/DebugHelper.lua",
    "src/app/views/layer/DebugLayer/GMLayer.lua",
    "src/app/views/layer/DebugLayer/TestLayer.lua",
    "src/app/views/layer/MainLayer.lua",
    "app.lst",
]


def adb(args):
    out = subprocess.run(["adb"] + args, capture_output=True)
    return out.returncode, out.stdout, out.stderr


def dev_md5(rel):
    code, out, err = adb(["shell", "su -c 'md5sum \"%s/%s\" 2>/dev/null; wc -c < \"%s/%s\" 2>/dev/null'" % (DEV, rel, DEV, rel)])
    text = out.decode("utf-8", "replace").strip().splitlines()
    digest = text[0].split()[0] if text and len(text[0].split()) else None
    size = text[1].strip() if len(text) > 1 else "?"
    return digest, size


def local(path):
    p = ROOT / "debug" / pathlib.Path(path).name if False else None
    return hashlib.md5(pathlib.Path(path).read_bytes()).hexdigest()


print("### 设备热更目录现状 (%s)" % DEV)
print("%-46s %-34s %-10s %s" % ("清单键名", "设备 md5", "设备字节", "本地对照"))
for rel in KEYS:
    digest, size = dev_md5(rel)
    local_txt = ""
    if rel.startswith("src/app/views/layer/DebugLayer/"):
        p = ROOT / "debug" / pathlib.Path(rel).name
        if p.is_file():
            local_txt = "debug/%s=%s" % (p.name, hashlib.md5(p.read_bytes()).hexdigest()[:8])
    elif rel.endswith("MainLayer.lua"):
        p = ROOT / "patched" / "MainLayer.lua"
        local_txt = "patched=%s" % hashlib.md5(p.read_bytes()).hexdigest()[:8]
    off = OFFICIAL / rel
    if off.is_file():
        local_txt += "  官方包=%s" % hashlib.md5(off.read_bytes()).hexdigest()[:8]
    print("%-46s %-34s %-10s %s" % (rel.split("layer/")[-1], digest or "(读不到)", size, local_txt))

print("\n  存根 md5(b'return {}') = %s" % STUB)
code, out, err = adb(["shell", "su -c 'cat %s/app.lst'" % DEV])
print("  设备 app.lst = %s" % out.decode("utf-8", "replace").strip())
