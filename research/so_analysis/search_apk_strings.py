# -*- coding: utf-8 -*-
"""在 APK 的 dex/resources 中搜索更新提示文本."""
import zipfile

from _paths import APK_PATH

APK = APK_PATH
TARGETS = ["版本更新", "两分钟", "再重试", "请稍等两分钟", "更新中，请稍等", "checkUpdate", "UpdateManager"]

apk = zipfile.ZipFile(APK, "r")
dex_files = [n for n in apk.namelist() if n.endswith(".dex")]
print("DEX files:", dex_files)

# resources.arsc
try:
    arsc = apk.read("resources.arsc")
    for t in TARGETS:
        tb = t.encode("utf-8")
        idx = arsc.find(tb)
        if idx >= 0:
            start = max(0, idx - 20)
            end = min(len(arsc), idx + 120)
            chunk = arsc[start:end]
            printable = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
            print(f"resources.arsc [{t}] @0x{idx:x}: {printable}")
except Exception as e:
    print("resources.arsc error:", e)

# dex files
for dex_name in dex_files:
    data = apk.read(dex_name)
    for t in TARGETS:
        tb = t.encode("utf-8")
        idx = data.find(tb)
        count = 0
        while idx >= 0 and count < 5:
            start = max(0, idx - 30)
            end = min(len(data), idx + 150)
            chunk = data[start:end]
            printable = "".join(chr(b) if 32 <= b < 127 else "." for b in chunk)
            print(f"{dex_name} [{t}] @0x{idx:x}: {printable}")
            idx = data.find(tb, idx + 1)
            count += 1
