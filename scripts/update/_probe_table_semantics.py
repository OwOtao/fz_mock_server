# -*- coding: utf-8 -*-
"""判定 originalMd5List / deployMd5List 各存的是什么。

用真实解包目录 research/updatePath_android_2.1.02 逐文件比对:
  - md5(磁盘字节) 与哪张表相符
  - 官方 DebugLayer 存根 `return {}` 的明文/密文 md5 分别对应哪张表
"""
import hashlib
import json
import os
import pathlib
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

from handlers import service  # noqa: E402

TREE = pathlib.Path(ROOT) / "research" / "updatePath_android_2.1.02"
payload = json.loads(
    service._update_cipher(open(os.path.join(ROOT, ".diagnostics", "md5_upstream_latest.bin"), "rb").read(),
                           "dec").decode("utf-8"))
orig = payload["data"]["originalMd5List"]
dep = payload["data"]["deployMd5List"]

stub = b"return {}"
print("官方 DebugLayer 存根 = %r" % stub)
print("  md5(明文)              = %s" % hashlib.md5(stub).hexdigest())
for magic in (b"JHHU01", b"JHHU02"):
    enc = service._update_cipher(stub, "enc", magic)
    print("  md5(%s 密文, %d 字节) = %s" % (magic.decode(), len(enc), hashlib.md5(enc).hexdigest()))
key = "src/app/views/layer/DebugLayer/DebugLayer.lua"
print("  上游 originalMd5List   = %s" % orig.get(key))
print("  上游 deployMd5List     = %s" % dep.get(key))

both = only_o = only_d = 0
for path in TREE.rglob("*"):
    if not path.is_file():
        continue
    rel = path.relative_to(TREE).as_posix()
    if rel == "updatePackage":
        continue
    want_o, want_d = orig.get(rel), dep.get(rel)
    if want_o is None and want_d is None:
        continue
    got = hashlib.md5(path.read_bytes()).hexdigest()
    hit_o, hit_d = got == want_o, got == want_d
    if hit_o and hit_d:
        both += 1
    elif hit_o:
        only_o += 1
    elif hit_d:
        only_d += 1

print("\n磁盘字节 md5 与清单相符的文件:")
print("  同时等于两张表  : %d" % both)
print("  只等于 original : %d" % only_o)
print("  只等于 deploy   : %d" % only_d)
print("  original 表总键数 = %d, deploy 表总键数 = %d" % (len(orig), len(dep)))
print("  只有 original 有该键的文件数 = %d"
      % sum(1 for p in TREE.rglob("*") if p.is_file()
            and (lambda r: r in orig and r not in dep)(p.relative_to(TREE).as_posix())))
print("  只有 deploy 有该键的文件数   = %d"
      % sum(1 for p in TREE.rglob("*") if p.is_file()
            and (lambda r: r in dep and r not in orig)(p.relative_to(TREE).as_posix())))
