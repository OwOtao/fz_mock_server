# -*- coding: utf-8 -*-
"""0x818120 精确实现(含 0x818050 长度字细节) + round-trip 自测 + 穷举 key。"""


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
blob = raw[6:]  # 96 bytes
print("blob:", len(blob), "bytes")

DELTA = 0x9E3779B9
C_EXTRA = 0xB54CDA56


def _pack_v(data):
    """0x818050: 小端字 + 末尾存原始长度。"""
    nw = (len(data) + 3) // 4
    if len(data) % 4:
        data = data + b"\0" * (4 - len(data) % 4)
    v = list(struct.unpack("<%dI" % nw, data)) + [len(data)]
    return v


def variant_encrypt(data, key16):
    v = _pack_v(data)
    n = len(v)
    k = list(struct.unpack("<4I", key16))
    total = ((52 // n) * DELTA + C_EXTRA) & 0xFFFFFFFF
    s = 0
    y = v[n - 1]
    while True:
        s = (s + DELTA) & 0xFFFFFFFF
        e = (s >> 2) & 3
        for p in range(n - 1):
            z = v[p + 1]
            mx = ((((y << 4) ^ (z >> 3)) + ((y >> 5) ^ (z << 2))) ^
                  ((y ^ k[(p ^ e) & 3]) + (z ^ s))) & 0xFFFFFFFF
            y = (v[p] + mx) & 0xFFFFFFFF
            v[p] = y
        z = v[0]
        mx = ((((y << 4) ^ (z >> 3)) + ((y >> 5) ^ (z << 2))) ^
              ((y ^ k[((n - 1) ^ e) & 3]) + (z ^ s))) & 0xFFFFFFFF
        v[n - 1] = (v[n - 1] + mx) & 0xFFFFFFFF
        y = v[n - 1]
        if s == total:
            break
    return struct.pack("<%dI" % n, *v)


def variant_decrypt(data, key16):
    n = len(data) // 4
    v = list(struct.unpack("<%dI" % n, data))
    k = list(struct.unpack("<4I", key16))
    total = ((52 // n) * DELTA + C_EXTRA) & 0xFFFFFFFF
    s = total
    while True:
        e = (s >> 2) & 3
        for p in range(n - 1, -1, -1):
            y = v[(p - 1) % n]
            z = v[(p + 1) % n]
            mx = ((((y << 4) ^ (z >> 3)) + ((y >> 5) ^ (z << 2))) ^
                  ((y ^ k[(p ^ e) & 3]) + (z ^ s))) & 0xFFFFFFFF
            v[p] = (v[p] - mx) & 0xFFFFFFFF
        if s == DELTA:
            break
        s = (s - DELTA) & 0xFFFFFFFF
    return struct.pack("<%dI" % n, *v)


# ---- round-trip 自测 ----
print("== round-trip ==")
test = bytes(range(96))
key = b"93a503f7cfaa1156"  # 任意 key 先验证算法对偶
enc = variant_encrypt(test, key)
dec = variant_decrypt(enc, key)
# dec 是 n=25 字 = 100 字节, 前 96 是数据, 后 4 是长度字
body = dec[:96]
lenw = struct.unpack("<I", dec[96:100])[0]
print("roundtrip OK:", body == test, "| 长度字:", lenw, "(应=96)", "| enc len:", len(enc))

# ---- 用候选 key 解 blob ----
print("== 穷举 key 解密 blob ==")
cands = {
    "FZJH03hex16_a_raw": binascii.unhexlify(b"93a503f7cfaa11563a3ee36544f47430"),
    "FZJH03hex16_a_ascii": b"93a503f7cfaa1156",
    "hex16_b_raw": binascii.unhexlify(b"a3374f473ed08213a285e7090196a93d"),
    "hex16_b_ascii": b"a3374f473ed08213",
    "iv_PcIQ": b"PcIQIZifRalhZ88n",
    "cbIh_head16": b"cbIhHHuYQIJ1Jkwl",
    "hex8_decoded": binascii.unhexlify(b"9B5A96B0F4A1EC60DB88349E3B926765"),
    "SKMl": b"SKMl^0SmirQ6Hcnh",
    "eird": b"eirdOhIycKhV18r$",
    "jX4SM": b"jX4SM#xx4cMBZR!t",
    "LRH": b"LRH@tTYnmussgjGd",
    "a20_head16": b[0x1183a20:0x1183a30],
    "3980_hex16_raw": binascii.unhexlify(b"ae9b363b80d5cc594973ecce1f4d546d"),
    "3980_hex16_ascii": b"ae9b363b80d5cc59",
}
for name, key16 in cands.items():
    if len(key16) != 16:
        continue
    out = variant_decrypt(blob, key16)
    lenw = struct.unpack("<I", out[96:100])[0]
    body = out[:96]
    pr = sum(1 for x in body if 32 <= x < 127 or x in (9, 10, 13)) / len(body)
    mark = " *** LEN MATCH ***" if lenw == 96 else ""
    print("%-22s lenw=%5d pr=%.2f head=%r%s" % (name, lenw, pr, body[:32], mark))
