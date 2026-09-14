# -*- coding: utf-8 -*-
"""最终体检: 用 deployMd5List(客户端落地表) 判定设备热更目录的"损坏/被改动"名单,
并列出覆盖清单没盖住的那些键。只读设备。
"""
import hashlib
import json
import pathlib
import subprocess
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT))
sys.stdout.reconfigure(encoding="utf-8")
from handlers import service  # noqa: E402
import config  # noqa: E402

DEV = "/data/data/com.xhtt.app.fzjh/files/updatePath_android_2.1.02"
STUB = hashlib.md5(b"return {}").hexdigest()


def sh(cmd, timeout=600):
    out = subprocess.run(["adb", "shell", "su -c '%s'" % cmd], capture_output=True, timeout=timeout)
    return out.stdout.decode("utf-8", "replace")


har = json.load(open(ROOT / "so" / "ProxyPin9-10_18_00_08.har", encoding="utf-8"))
body = next((e["response"]["content"]["text"] or "").strip().encode()
            for e in har["log"]["entries"] if "getMd5List" in e["request"]["url"])
lists = json.loads(service._update_cipher(body, "dec").decode())["data"]
dep = lists["deployMd5List"]
ov = service._md5_overrides(service._update_magic_of(body))

listing = sh("cd %s && find src res -type f -exec md5sum {} + 2>/dev/null" % DEV)
device = {}
for line in listing.splitlines():
    parts = line.split(None, 1)
    if len(parts) == 2:
        device[parts[1].strip()] = parts[0]

hdr = subprocess.run(["adb", "shell", "su -c 'cat %s/app.lst'" % DEV], capture_output=True)
print("设备 app.lst = %s" % hdr.stdout.decode("utf-8", "replace").strip())
print("设备热更文件 %d 个; 上游 deployMd5List %d 条; 本地覆盖项 %d 个\n" % (len(device), len(dep), len(ov)))

print("### A. 官方 deployMd5List 说这些文件应该是 9 字节存根(return {}), 设备上却是完整源码:")
stub_rows = [k for k, v in dep.items() if v == STUB]
for k in sorted(stub_rows):
    got = device.get(k, "(缺失)")
    mark = "被覆盖清单盖住" if k in ov else "**没盖住**"
    print("  %-72s 设备=%s %s" % (k, got[:10], mark))

print("\n### B. deployMd5List 与设备字节不一致的全部键:")
bad = [(k, v, device.get(k)) for k, v in dep.items() if device.get(k) != v]
for k, want, got in sorted(bad):
    print("  %-72s 清单=%s 设备=%s %s" % (k, want[:10], (got or "(缺失)")[:10],
                                          "已覆盖" if k in ov else "**未覆盖**"))

print("\n### C. 覆盖清单没盖住的设备文件 (客户端按清单看就是'被改动'):")
uncov = sorted(k for k in device if k not in dep and k not in ov)
print("  共 %d 个 (表里没有, 客户端不校验/不下载):" % len(uncov))
for k in uncov[:30]:
    print("   ", k)
