# -*- coding: utf-8 -*-
"""厘清三个 md5 的关系:
   A. 服务端发布值 = md5(覆盖目录里的字节)
   B. 上游 originalMd5List[key]
   C. 上游 deployMd5List[key]

用真实数据验证几个假设:
   1. deploy 里的 DebugLayer 条目是否都等于 md5(b'return {}')  (官方用存根关掉调试层)
   2. original 是否等于"未修改源的加密形态"的 md5
   3. 两张表的规模/交集关系
"""
import hashlib
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT))
sys.stdout.reconfigure(encoding="utf-8")

import config  # noqa: E402
from handlers import service  # noqa: E402

payload = json.loads(
    service._update_cipher(open(ROOT / ".diagnostics" / "md5_upstream_latest.bin", "rb").read(),
                           "dec").decode("utf-8"))
orig = payload["data"]["originalMd5List"]
dep = payload["data"]["deployMd5List"]
prefix = config.MD5_OVERRIDE_KEY_PREFIX + "/"

print("表规模: original=%d, deploy=%d, 交集=%d, 仅original=%d, 仅deploy=%d"
      % (len(orig), len(dep), len(set(orig) & set(dep)),
         len(set(orig) - set(dep)), len(set(dep) - set(orig))))
shared = set(orig) & set(dep)
print("交集里两值相同的键数: %d" % sum(1 for k in shared if orig[k] == dep[k]))

stub_md5 = hashlib.md5(b"return {}").hexdigest()
print("\nmd5(b'return {}') = %s" % stub_md5)
dl_deploy = {k: v for k, v in dep.items() if k.startswith(prefix)}
print("deploy 里 %s 条目: %d 个, 值等于存根 md5 的: %d 个"
      % (config.MD5_OVERRIDE_KEY_PREFIX, len(dl_deploy), sum(1 for v in dl_deploy.values() if v == stub_md5)))
dl_orig = {k: v for k, v in orig.items() if k.startswith(prefix)}
print("original 里同前缀条目: %d 个" % len(dl_orig))

print("\n=== 用 clean_DebugLayer/ 验证 'original = 未修改源的加密形态' ===")
clean = ROOT.parent / "clean_DebugLayer"
prefix_bare = config.MD5_OVERRIDE_KEY_PREFIX.strip("/")
if clean.is_dir():
    hits = 0
    total = 0
    for path in sorted(p for p in clean.rglob("*.lua")):
        key = "%s/%s" % (prefix_bare, path.relative_to(clean).as_posix())
        if key not in orig and key not in dep:
            continue
        total += 1
        data = path.read_bytes()
        row = [path.relative_to(clean).as_posix()]
        matched = None
        for magic in (b"JHHU01", b"JHHU02"):
            digest = hashlib.md5(service._update_cipher(data, "enc", magic)).hexdigest()
            row.append(digest[:12])
            for label, table in (("original", orig), ("deploy", dep)):
                if table.get(key) == digest:
                    matched = "%s@%s" % (label, magic.decode())
        row.append((orig.get(key) or "-")[:12])
        row.append((dep.get(key) or "-")[:12])
        row.append(matched or "未命中(源已被改过?)")
        if matched:
            hits += 1
        if total <= 12 or matched:
            print("  %-30s JHHU01=%-12s JHHU02=%-12s original=%-12s deploy=%-12s %s" % tuple(row))
    print("  clean 源可对上上游表: %d / %d" % (hits, total))
else:
    print("  clean_DebugLayer/ 不存在")
