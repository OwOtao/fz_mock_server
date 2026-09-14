# -*- coding: utf-8 -*-
"""XXTEA 尝试解密 FZJH03 blob, 验证密钥假设。"""


# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import binascii
import struct
import zipfile

APK = r"E:\Leidian14\Picutres\leidian9Picutres\product_fangzhijianghu_guanfang_2.1.02.apk"
z = zipfile.ZipFile(APK)
b = z.read("lib/arm64-v8a/libcocos2dlua.so")

# blob 文本 -> 字节
e = b.find(b"\0", 0x1183b20)
raw = binascii.unhexlify(b[0x1183b20:e].decode())
blob = raw[6:]  # 去掉 "FZJH03"
print("blob bytes:", len(blob))


def str_at(addr):
    e = b.find(b"\0", addr)
    return b[addr:e]


def xtea_decrypt(data, key):
    """标准 XXTEA 解密 (uint32 大端存储, 与多数实现一致)。"""
    if len(data) % 4:
        return None
    n = len(data) // 4
    v = list(struct.unpack(">%dI" % n, data))
    k = list(struct.unpack(">4I", key[:16]))
    delta = 0x9E3779B9
    q = 6 + 52 // n
    total = (q * delta) & 0xFFFFFFFF
    while total:
        e = (total >> 2) & 3
        for p in range(n - 1, -1, -1):
            z = v[(p + n - 1) % n]
            y = v[p]
            mx = (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ \
                 ((total ^ y) + (k[(p & 3) ^ e] ^ z))
            v[p] = (y - mx) & 0xFFFFFFFF
        total = (total - delta) & 0xFFFFFFFF
    return struct.pack(">%dI" % n, *v)


def xtea_decrypt_le(data, key):
    """little-endian 变体。"""
    if len(data) % 4:
        return None
    n = len(data) // 4
    v = list(struct.unpack("<%dI" % n, data))
    k = list(struct.unpack("<4I", key[:16]))
    delta = 0x9E3779B9
    q = 6 + 52 // n
    total = (q * delta) & 0xFFFFFFFF
    while total:
        e = (total >> 2) & 3
        for p in range(n - 1, -1, -1):
            z = v[(p + n - 1) % n]
            y = v[p]
            mx = (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ \
                 ((total ^ y) + (k[(p & 3) ^ e] ^ z))
            v[p] = (y - mx) & 0xFFFFFFFF
        total = (total - delta) & 0xFFFFFFFF
    return struct.pack("<%dI" % n, *v)


candidates = {
    "rodata_1183a20_head16": b[0x1183a20:0x1183a30],
    "rodata_11839a0_head16": b[0x11839a0:0x11839b0],
    "SKMl_str16": b"SKMl^0SmirQ6Hcnh",
    "cbIh_head16": b"cbIhHHuYQIJ1Jkwl",
    "hex8_decoded": binascii.unhexlify(b"9B5A96B0F4A1EC60DB88349E3B926765"),
}
# 再补 0x1183a80 附近
candidates["rodata_1183a80_head16"] = b[0x1183a80:0x1183a90]
candidates["rodata_1183a40_head16"] = b[0x1183a40:0x1183a50]

for name, key in candidates.items():
    for label, fn in [("BE", xtea_decrypt), ("LE", xtea_decrypt_le)]:
        out = fn(blob, key)
        if out is None:
            continue
        pr = sum(1 for x in out if 32 <= x < 127 or x in (9, 10, 13)) / len(out)
        mark = "***" if pr > 0.7 else ""
        print("%-28s %-3s pr=%.2f head=%r %s" % (name, label, pr, out[:32], mark))
