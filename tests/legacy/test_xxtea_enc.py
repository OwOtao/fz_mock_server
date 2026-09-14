# -*- coding: utf-8 -*-
"""0x818120 加密方向处理完整 102B blob, 验证 key16 候选。"""


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
blob = binascii.unhexlify(b[0x1183b20:e].decode())  # 102 bytes 含 "FZJH03"
print("blob:", len(blob), "head:", blob[:8])

DELTA = 0x9E3779B9
C_EXTRA = 0xB54CDA56


def pack_v(data):
    nw = (len(data) + 3) // 4
    if len(data) % 4:
        data = data + b"\0" * (4 - len(data) % 4)
    return list(struct.unpack("<%dI" % nw, data)) + [len(data)]


def variant_encrypt(data, key16):
    v = pack_v(data)
    n = len(v)
    k = list(struct.unpack("<4I", key16))
    total = ((52 // n) * DELTA + C_EXTRA) & 0xFFFFFFFF
    s = 0
    y = v[n - 1]
    while True:
        s = (s + DELTA) & 0xFFFFFFFF
        e2 = (s >> 2) & 3
        for p in range(n - 1):
            z = v[p + 1]
            mx = ((((y << 4) ^ (z >> 3)) + ((y >> 5) ^ (z << 2))) ^
                  ((y ^ k[(p ^ e2) & 3]) + (z ^ s))) & 0xFFFFFFFF
            y = (v[p] + mx) & 0xFFFFFFFF
            v[p] = y
        z = v[0]
        mx = ((((y << 4) ^ (z >> 3)) + ((y >> 5) ^ (z << 2))) ^
              ((y ^ k[((n - 1) ^ e2) & 3]) + (z ^ s))) & 0xFFFFFFFF
        v[n - 1] = (v[n - 1] + mx) & 0xFFFFFFFF
        y = v[n - 1]
        if s == total:
            break
    return struct.pack("<%dI" % n, *v)


cands = {
    "ascii_93a503_16": b"93a503f7cfaa1156",
    "raw_93a503_16": binascii.unhexlify(b"93a503f7cfaa11563a3ee36544f47430"),
    "raw_hex16ab_32": binascii.unhexlify(
        b"93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"),
    "iv_PcIQ": b"PcIQIZifRalhZ88n",
    "cbIh16": b"cbIhHHuYQIJ1Jkwl",
    "a20_16": b[0x1183a20:0x1183a30],
    "SKMl16": b"SKMl^0SmirQ6Hcnh",
    "eird16": b"eirdOhIycKhV18r$",
    "3980_hex16": binascii.unhexlify(b"ae9b363b80d5cc594973ecce1f4d546d"),
}
print("== 加密方向输出检查 (102B blob) ==")
for name, k in cands.items():
    out = variant_encrypt(blob, k)
    pr = sum(1 for x in out if 32 <= x < 127 or x in (9, 10, 13)) / len(out)
    # 检查输出里是否含可打印密钥模式
    printable_blocks = sum(1 for x in out if 32 <= x < 127)
    print("%-18s len=%d pr=%.2f head=%r tail=%r" % (name, len(out), pr, out[:32], out[-16:]))
