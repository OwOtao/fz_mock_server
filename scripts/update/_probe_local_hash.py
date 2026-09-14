# -*- coding: utf-8 -*-
"""判定客户端到底对"什么"取 md5。

拿 research/updatePath_android_2.1.02(真实解包出来的热更目录)逐文件算 md5,
与上游 getMd5List 的 originalMd5List / deployMd5List 比对:
  A. md5(文件原始字节)                  <- 若命中, 说明清单存的就是磁盘字节的 md5
  B. md5(把明文按 JHHU01/JHHU02 加密后) <- 若命中, 说明清单存的是密文 hex 的 md5
  C. 文件本身就是 hex 密文时, md5(文件字节)

同时统计"文件是否为 hex 密文文本"。
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

TREE = os.path.join(ROOT, "research", "updatePath_android_2.1.02")
BODY = os.path.join(ROOT, ".diagnostics", "md5_upstream_latest.bin")

payload = json.loads(service._update_cipher(open(BODY, "rb").read(), "dec").decode("utf-8"))
original = payload["data"]["originalMd5List"]
deploy = payload["data"]["deployMd5List"]
print("上游清单: original=%d, deploy=%d" % (len(original), len(deploy)))

MD5_RE = set("0123456789abcdef")


def looks_like_hex_cipher(data):
    head = data[:12].lower()
    return head in (b"4a4848553031", b"4a4848553032")


stats = {"raw": 0, "cipher_jhhu02": 0, "cipher_jhhu01": 0, "hexnocipher": 0, "none": 0}
cipher_files = 0
checked = 0
examples = []
for path in sorted(pathlib.Path(TREE).rglob("*")):
    if not path.is_file():
        continue
    rel = path.relative_to(TREE).as_posix()
    want_o = original.get(rel)
    want_d = deploy.get(rel)
    if want_o is None and want_d is None:
        continue
    if rel == "updatePackage":
        continue
    data = path.read_bytes()
    checked += 1
    is_hex = looks_like_hex_cipher(data)
    if is_hex:
        cipher_files += 1
    got = hashlib.md5(data).hexdigest()
    if got == want_o or got == want_d:
        stats["raw"] += 1
        continue
    if is_hex:
        stats["hexnocipher"] += 1
        continue
    hit = None
    for magic in (b"JHHU02", b"JHHU01"):
        try:
            enc = service._update_cipher(data, "enc", magic)
        except Exception:  # noqa: BLE001
            continue
        if hashlib.md5(enc).hexdigest() in (want_o, want_d):
            hit = magic.decode()
            break
    if hit == "JHHU02":
        stats["cipher_jhhu02"] += 1
    elif hit == "JHHU01":
        stats["cipher_jhhu01"] += 1
    else:
        stats["none"] += 1
        if len(examples) < 6:
            examples.append((rel, want_o, want_d, got, len(data), data[:16]))

print("\n参与比对的文件: %d (其中磁盘上本身就是 hex 密文的: %d)" % (checked, cipher_files))
print("  A 原始字节 md5 命中        : %d" % stats["raw"])
print("  B 加密后 md5 命中 JHHU02   : %d" % stats["cipher_jhhu02"])
print("  B 加密后 md5 命中 JHHU01   : %d" % stats["cipher_jhhu01"])
print("  C 是 hex 密文但 md5 不匹配 : %d" % stats["hexnocipher"])
print("  都不匹配                   : %d" % stats["none"])

if examples:
    print("\n不匹配样例:")
    for rel, want_o, want_d, got, size, head in examples:
        print("  %s (size=%d)" % (rel, size))
        print("     original=%s" % want_o)
        print("     deploy  =%s" % want_d)
        print("     md5(文件)=%s  head=%r" % (got, head))

# 单独看 DebugLayer
print("\n=== DebugLayer 子树 ===")
for path in sorted(pathlib.Path(TREE).rglob("DebugLayer*")):
    if path.is_file():
        rel = path.relative_to(TREE).as_posix()
        data = path.read_bytes()
        print("  %s size=%d hex密文=%s" % (rel, len(data), looks_like_hex_cipher(data)))
