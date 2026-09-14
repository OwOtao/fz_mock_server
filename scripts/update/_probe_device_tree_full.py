# -*- coding: utf-8 -*-
"""设备热更目录全量体检: 每个文件属于哪一类。

分类依据 (三份参照):
  A. 覆盖后服务端会下发的清单 (9-10 getMd5List + 本地 debug/patched 覆盖)
  B. 官方 2.1.02 热更包 research/updatePath_android_2.1.02
  C. 本地参考副本 (mock_server/debug, mock_server/patched, APK 解出的 fzjh_lua)

输出:
  - 自注入/被改过 (不在官方包, 或与官方包字节不同)
  - 与"服务端下发的 md5"不一致的条目  <- 客户端按清单校验时就是"损坏/被改动"
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
import config  # noqa: E402
from handlers import service  # noqa: E402

DEV = "/data/data/com.xhtt.app.fzjh/files/updatePath_android_2.1.02"
SKIP_DIRS = ("__pycache__",)
LOCAL_REFS = [ROOT / "debug", ROOT / "patched", ROOT / "fzjh_lua" / "assets"]


def sh(cmd, timeout=300):
    try:
        out = subprocess.run(["adb", "shell", "su -c '%s'" % cmd], capture_output=True, timeout=timeout)
        return out.stdout.decode("utf-8", "replace")
    except subprocess.TimeoutExpired:
        return ""


def local_index():
    """本地参考: {相对 src/app/... 的路径: md5}，用于解释设备上的自注入文件来源。"""
    index = {}
    for base in LOCAL_REFS:
        if not base.is_dir():
            continue
        for p in base.rglob("*"):
            if not p.is_file() or any(s in p.parts for s in SKIP_DIRS):
                continue
            try:
                index.setdefault(p.name, set()).add(hashlib.md5(p.read_bytes()).hexdigest())
            except OSError:
                pass
    return index


har = json.load(open(ROOT / "so" / "ProxyPin9-10_18_00_08.har", encoding="utf-8"))
for entry in har["log"]["entries"]:
    if "getMd5List" in entry["request"]["url"]:
        body = (entry["response"]["content"]["text"] or "").strip().encode()
        break
result = service._apply_md5_override({"body": body, "status_code": 200,
                                     "headers": {"Content-Length": str(len(body))}})
served = json.loads(service._update_cipher(result["body"], "dec").decode())["data"]["originalMd5List"]
official = ROOT / "research" / "updatePath_android_2.1.02"
refs = local_index()

print("### 设备热更目录全量体检 (%s)" % DEV)
# 一次 adb 调用把整个 src/ 的 md5 取回来(避免几千次 shell 往返)
listing = sh("cd %s && find src -type f -exec md5sum {} + 2>/dev/null" % DEV, timeout=600)
digests = {}
for line in listing.splitlines():
    parts = line.split(None, 1)
    if len(parts) == 2:
        digests[parts[1].strip()] = parts[0]
print("  文件数: %d\n" % len(digests))

mismatch, injected, extra_local, unlisted = [], [], [], []
for rel, dev_md5 in sorted(digests.items()):
    want = served.get(rel)
    off = official / rel
    off_md5 = hashlib.md5(off.read_bytes()).hexdigest() if off.is_file() else None
    name = os.path.basename(rel)
    src = []
    if name in refs and dev_md5 in refs[name]:
        src.append("本地副本一致")
    if off_md5 != dev_md5:
        injected.append(rel)
    if off_md5 is None and want is None:
        extra_local.append(rel)
    elif want is None:
        unlisted.append(rel)
    if want is not None and want != dev_md5:
        mismatch.append((rel, dev_md5, want, off_md5, src))

print("### 1. 与官方 2.1.02 包字节不同的文件 (自注入/被改过): %d" % len(injected))
for rel in injected[:40]:
    print("   ", rel)

print("\n### 2. 不在官方包、也不在服务端清单里的文件: %d" % len(extra_local))
for rel in extra_local[:40]:
    print("   ", rel)

print("\n### 3. 在清单里但设备字节 != 服务端下发 md5 (客户端会判为损坏/被改): %d" % len(mismatch))
for rel, dev_md5, want, off_md5, src in mismatch[:60]:
    print("    %-70s 设备=%s 下发=%s 官方包=%s %s"
          % (rel, dev_md5[:10], want[:10], (off_md5 or "-")[:10], ",".join(src)))

print("\n### 4. 清单里有、但设备热更目录没有的键(可能来自 APK 内置 assets): %d"
      % len([k for k in served]))
