# -*- coding: utf-8 -*-
"""用官方 2.1.02 热更包目录(research/updatePath_android_2.1.02) 对照 9-10 抓包的 md5 清单,
判断本地修改过的 lua 是否已经被 2.1.02 覆盖。
"""
import binascii
import hashlib
import json
import os
import pathlib
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")
import config  # noqa: E402
from handlers import service  # noqa: E402

TREE = pathlib.Path(ROOT) / "research" / "updatePath_android_2.1.02"
har = json.load(open(os.path.join(ROOT, "so", "ProxyPin9-10_18_00_08.har"), encoding="utf-8"))
body = None
for entry in har["log"]["entries"]:
    if "getMd5List" in entry["request"]["url"]:
        body = (entry["response"]["content"]["text"] or "").strip().encode()
        break
payload = json.loads(service._update_cipher(body, "dec").decode("utf-8"))
orig = payload["data"]["originalMd5List"]
dep = payload["data"]["deployMd5List"]
STUB = hashlib.md5(b"return {}").hexdigest()

print("### 官方 2.1.02 热更包 vs 9-10 清单")
files = [p for p in TREE.rglob("*") if p.is_file()]
both = only_o = only_d = neither = 0
for path in files:
    rel = path.relative_to(TREE).as_posix()
    if rel == "updatePackage":
        continue
    got = hashlib.md5(path.read_bytes()).hexdigest()
    o, d = orig.get(rel), dep.get(rel)
    if o is None and d is None:
        continue
    if got == o and got == d:
        both += 1
    elif got == o:
        only_o += 1
    elif got == d:
        only_d += 1
    else:
        neither += 1
print("  包内文件 %d 个; 在清单里的: 命中 original=%d, 命中 deploy=%d, 两者都命中=%d, 都不命中=%d"
      % (len(files), only_o, only_d, both, neither))
print("  md5(b'return {}') = %s" % STUB)

print("\n### 本地 16 个覆盖键: 设备字节/官方包字节/上游清单 三方对照")
overrides = service._md5_overrides(service._update_magic_of(body))
for key in sorted(overrides):
    rel = key
    local = overrides[key]
    pkg = TREE / rel
    if pkg.is_file():
        pkg_md5 = hashlib.md5(pkg.read_bytes()).hexdigest()
        pkg_size = pkg.stat().st_size
    else:
        pkg_md5, pkg_size = "不在官方包", "-"
    print("  %-40s 本地=%s 官方包=%-34s(%s) 上游orig=%s 上游deploy=%s" % (
        key.split("/")[-1], local[:8], pkg_md5[:8] if pkg_md5 != "不在官方包" else pkg_md5,
        pkg_size, (orig.get(key) or "-")[:8], (dep.get(key) or "-")[:8]))

print("\n### 定位: 官方包里 DebugLayer 是什么")
dl = TREE / "src/app/views/layer/DebugLayer"
if dl.is_dir():
    entries = sorted(p for p in dl.rglob("*") if p.is_file())
    print("  官方包 DebugLayer 文件数=%d" % len(entries))
    for p in entries[:6]:
        rel = p.relative_to(TREE).as_posix()
        print("    %-70s %6d %s" % (rel, p.stat().st_size, hashlib.md5(p.read_bytes()).hexdigest()[:8]))
    stub_files = [p for p in entries if hashlib.md5(p.read_bytes()).hexdigest() == STUB]
    print("  其中内容为 b'return {}' 的存根: %d 个 %s"
          % (len(stub_files), [p.name for p in stub_files[:12]]))
else:
    print("  官方包内没有 DebugLayer 目录")
main = TREE / "src/app/views/layer/MainLayer.lua"
if main.is_file():
    print("  官方 MainLayer.lua: %d 字节 md5=%s (清单 orig=%s)"
          % (main.stat().st_size, hashlib.md5(main.read_bytes()).hexdigest(),
             orig.get("src/app/views/layer/MainLayer.lua")))

print("\n### app.lst / updatePackage 与清单的关系")
applst = TREE / "app.lst"
if applst.is_file():
    text = applst.read_bytes()
    print("  app.lst %d 字节 前 200: %r" % (len(text), text[:200]))
    print("  md5(app.lst)=%s 在 original: %s / deploy: %s"
          % (hashlib.md5(text).hexdigest(), hashlib.md5(text).hexdigest() in orig.values(),
             hashlib.md5(text).hexdigest() in dep.values()))
pkg = TREE / "updatePackage"
if pkg.is_file():
    data = pkg.read_bytes()
    print("  updatePackage %d 字节 md5=%s 在清单: original=%s deploy=%s"
          % (len(data), hashlib.md5(data).hexdigest(),
             orig.get("updatePackage"), dep.get("updatePackage")))
