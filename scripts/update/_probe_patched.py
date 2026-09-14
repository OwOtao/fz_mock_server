# -*- coding: utf-8 -*-
"""分析 patched/MainLayer.lua 的尾部补 0，以及各种 md5 变体。"""
import hashlib
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(ROOT))
sys.stdout.reconfigure(encoding="utf-8")

from handlers import service  # noqa: E402

path = ROOT / "patched" / "MainLayer.lua"
data = path.read_bytes()
core = data.rstrip(b"0")
pad = len(data) - len(core)
print("patched/MainLayer.lua: %d 字节" % len(data))
print("  尾部 ASCII '0' 个数 : %d" % pad)
print("  去补0后长度         : %d (mod 16 = %d)" % (len(core), len(core) % 16))
print("  原始长度 mod 16     : %d" % (len(data) % 16))
print("  去补0后结尾         : %r" % core[-40:])
print()

print("%-16s %-34s %s" % ("形式", "md5", "长度"))
for label, blob in (("原始(含补0)", data), ("去补0", core)):
    print("%-16s %-34s %d" % (label, hashlib.md5(blob).hexdigest(), len(blob)))
for magic in (b"JHHU01", b"JHHU02"):
    for label, blob in (("原始", data), ("去补0", core)):
        enc = service._update_cipher(blob, "enc", magic)
        print("%-16s %-34s %d" % ("%s+%s" % (magic.decode(), label), hashlib.md5(enc).hexdigest(), len(enc)))

print()
print("上游 originalMd5List[src/app/views/layer/MainLayer.lua] = a03eb5c674eea521520d2e7976d42f5f")

# 与仓库里客户端自带的 MainLayer 对比
for candidate in (
    ROOT / "fzjh_lua" / "assets" / "src" / "app" / "views" / "layer" / "MainLayer.lua",
    ROOT / ".." / "clean_DebugLayer" / "DebugLayer.lua",
):
    if candidate.is_file():
        other = candidate.read_bytes()
        print()
        print("对比 %s (%d 字节)" % (candidate.resolve(), len(other)))
        print("  头部: %r" % other[:24])
        print("  尾部: %r" % other[-24:])
        if other[:12].lower() in (b"4a4848553031", b"4a4848553032"):
            try:
                plain = service._update_cipher(other, "dec")
                print("  是密文, 解密后 %d 字节, 尾部 %r" % (len(plain), plain[-24:]))
                print("  解密去掉尾部 '0' 后 %d 字节, 与 patched 去补0 是否一致: %s"
                      % (len(plain.rstrip(b"0")), plain.rstrip(b"0") == core))
            except Exception as error:  # noqa: BLE001
                print("  解密失败: %s" % error)
        else:
            print("  是明文, 去尾部 '0' 后 %d 字节, 与 patched 去补0 一致: %s"
                  % (len(other.rstrip(b"0")), other.rstrip(b"0") == core))
