# -*- coding: utf-8 -*-
"""按 0x818120 汇编精确实现的 XXTEA 变体解密, 穷举候选 key 解 FZJH03 blob。"""


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

e = b.find(b"\0", 0x1183b20)
raw = binascii.unhexlify(b[0x1183b20:e].decode())
blob = raw[6:]  # 96 bytes, 去掉 "FZJH03"
print("blob:", len(blob), "bytes")

DELTA = 0x9E3779B9


def variant_decrypt(data, key):
    """0x818120 变体(加密方向 sum 递增; 这里做反向解密)。
    MX = ((y<<4 ^ z>>3) + (y>>5 ^ z<<2)) ^ ((y ^ k[(p^e)&3]) + (z ^ sum))
    遍历: 解密按 p = n-1 .. 0, y = v[(p-1)%n], z = v[(p+1)%n]。
    """
    n = len(data) // 4
    v = list(struct.unpack("<%dI" % n, data))
    k = list(struct.unpack("<4I", key[:16]))
    q = 52 // n
    total = ((q * DELTA) + 0xB54CDA56) & 0xFFFFFFFF
    first = True
    while True:
        e = (total >> 2) & 3
        for p in range(n - 1, -1, -1):
            y = v[(p - 1) % n]
            z = v[(p + 1) % n]
            mx = (((y << 4) ^ (z >> 3)) + ((y >> 5) ^ (z << 2))) ^ \
                 ((y ^ k[(p ^ e) & 3]) + (z ^ total))
            v[p] = (v[p] - mx) & 0xFFFFFFFF
        if total == DELTA:
            break
        total = (total - DELTA) & 0xFFFFFFFF
    return struct.pack("<%dI" % n, *v)


def str_at(addr):
    e2 = b.find(b"\0", addr)
    return b[addr:e2]


candidates = {
    "FZJH03hex16_a": binascii.unhexlify(b"93a503f7cfaa11563a3ee36544f47430"),
    "hex16_a+hex16_b(32B头16)": binascii.unhexlify(
        b"93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d")[:16],
    "hex16_b": binascii.unhexlify(b"a3374f473ed08213a285e7090196a93d"),
    "iv_PcIQ": b"PcIQIZifRalhZ88n",
    "cbIh_head16": b"cbIhHHuYQIJ1Jkwl",
    "hex8_1+hex8_2": binascii.unhexlify(b"9B5A96B0F4A1EC60DB88349E3B926765"),
    "SKMl_str16": b"SKMl^0SmirQ6Hcnh",
    "eird_str16": b"eirdOhIycKhV18r$",
    "jX4SM_str16": b"jX4SM#xx4cMBZR!t",
    "LRH_str16": b"LRH@tTYnmussgjGd",
    "rodata_a20_head16": b[0x1183a20:0x1183a30],
    "rodata_3980_hex16": binascii.unhexlify(b"ae9b363b80d5cc594973ecce1f4d546d"),
}
# 补: 从 FZJH03 字符串往后找的 16 字节(hex16_a 后面紧跟 hex16_b, 已含)
# 再补: default 组完整 key 前16B 已含; 以及 0x1183aa0 起 hex 文本解码
candidates["hex8_1"] = binascii.unhexlify(b"9B5A96B0F4A1EC60")
# ASCII 形式(注册表存 hex 文本, key16 可能是文本前16字节)
candidates["ascii_93a503_16"] = b"93a503f7cfaa1156"
candidates["ascii_93a503_32前16"] = b"93a503f7cfaa11563a3ee36544f47430"[:16]
candidates["ascii_a3374f_16"] = b"a3374f473ed08213"
candidates["ascii_hex16ab_32"] = b"93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"[:16]

found = False
for name, key in candidates.items():
    out = variant_decrypt(blob, key)
    pr = sum(1 for x in out if 32 <= x < 127 or x in (9, 10, 13)) / len(out)
    mark = " *** HIT ***" if pr > 0.75 else ""
    print("%-28s pr=%.2f head=%r tail=%r%s" % (name, pr, out[:40], out[-16:], mark))
    if pr > 0.75:
        found = True
        print("  完整输出:", out)
print("----", "FOUND" if found else "NOT FOUND")
