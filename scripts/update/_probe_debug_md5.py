# -*- coding: utf-8 -*-
"""列出：本地覆盖目录的字节 -> 服务端现在会发布的 md5 -> 上游清单原值。

模型: 清单里的 md5 = 设备上那份字节的 md5（明文不加密）。
所以只要"目录里的文件字节 == 你复制到设备的字节", check 就会通过。
"""
import hashlib
import json
import os
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


def cipher_form(data):
    head = data[:12].lower()
    return {b"4a4848553031": "JHHU01密文", b"4a4848553032": "JHHU02密文"}.get(head, "明文")


print("MD5_OVERRIDE_DIR = %s" % config.MD5_OVERRIDE_DIR)
print()
print("%-30s %8s %-10s %-34s %-34s %s" % ("文件", "字节", "形态", "服务端发布的 md5", "上游 original", "上游 deploy"))
print("-" * 140)
root = pathlib.Path(config.MD5_OVERRIDE_DIR)
for path in sorted(p for p in root.rglob("*") if p.is_file()):
    key = prefix + path.relative_to(root).as_posix()
    data = path.read_bytes()
    print("%-30s %8d %-10s %-34s %-34s %s"
          % (path.relative_to(root).as_posix(), len(data), cipher_form(data),
             service._debug_file_md5(path), orig.get(key, "-"), dep.get(key, "-")))

print()
print("额外文件 MD5_OVERRIDE_EXTRA_FILES:")
for key, rel in (config.MD5_OVERRIDE_EXTRA_FILES or {}).items():
    path = pathlib.Path(config.__file__).resolve().parent / rel
    data = path.read_bytes()
    print("  %s" % key)
    print("    本地 %s: %d 字节, 形态=%s" % (rel, len(data), cipher_form(data)))
    print("    服务端发布 md5 = %s" % service._debug_file_md5(path))
    print("    上游 original   = %s" % orig.get(key, "-"))
    print("    上游 deploy     = %s  %s" % (dep.get(key, "-"),
                                            "(不在 deploy, 会被覆盖逻辑补建)" if key not in dep else ""))
