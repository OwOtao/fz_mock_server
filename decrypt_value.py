# -*- coding: utf-8 -*-
"""对 value.md (FXXF01) 做彻底爆破."""
import sys, os, binascii, json, zipfile
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import jm_crypto

ROOT = os.path.dirname(os.path.abspath(__file__))
raw = open(os.path.join(ROOT, "research", "samples", "value.md"), "rb").read().strip()
b = binascii.unhexlify(raw)
assert b[:6] == b"FXXF01"
enc = b[6:]
enc = enc[:len(enc) - (len(enc) % 16)]

# 收集所有 key 原始字符串（32 字符）
keys = set()
for v in [
    "cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF",
    "07818f3a34e8165227b0dc6b7e69ea57",
    "26549f871287ba9e838a057a7ffac1bc",
    "93a503f7cfaa11563a3ee36544f47430",
    "a3374f473ed08213a285e7090196a93d",
    "ae9b363b80d5cc594973ecce1f4d546d",
    "9B5A96B0F4A1EC60DB88349E3B926765",
    "eirdOhIycKhV18r$3iqszOfgKTPUcEmj",
    "jX4SM#xx4cMBZR!txR0ghhI&cq*P36Ih",
    "SKMl^0SmirQ6Hcnh^1VwP1UBBzVz*M6Y",
    "34857d973953e44a", "PcIQIZifRalhZ88n",
]:
    keys.add(v)

# 从 APK 读 rodata 二进制 key
APK = os.path.join(ROOT, "tools", "frida", "fzjh_base.apk")
try:
    z = zipfile.ZipFile(APK)
    so = z.read("lib/arm64-v8a/libcocos2dlua.so")
    for off in (0x1183a20, 0x11839e0, 0x1183b20, 0x1183bf8, 0x1183c20, 0x120d3f0):
        seg = so[off:off+64]
        s = seg.split(b"\x00")[0]
        if s:
            keys.add(s.decode("latin1"))
except Exception as e:
    print("apk read err:", e)

IVS = {
    "PcIQ": b"PcIQIZifRalhZ88n",
    "def": b"34857d973953e44a",
    "zero": b"\x00"*16,
    "FZJH01hex": binascii.unhexlify("ae9b363b80d5cc594973ecce1f4d546d"),
    "FZJH03keyA": binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430"),
}

def looks_json(p):
    try:
        json.loads(p.decode("utf-8"))
        return True
    except Exception:
        return False

def pr(p):
    return sum(1 for x in p if 32 <= x < 127 or x in (9, 10, 13)) / max(len(p), 1)

results = []
def try_dec(key, klabel, mode, iname, iv):
    try:
        dec = jm_crypto._aes_cbc(enc, key, iv, "dec")
    except Exception:
        return
    for unpad_f in ("zero", "pkcs7"):
        p = dec.rstrip(b"0") if unpad_f == "zero" else (dec[:-dec[-1]] if dec and 1 <= dec[-1] <= 16 and all(x == dec[-1] for x in dec[-dec[-1]:]) else dec)
        if looks_json(p):
            print("\n*** JSON HIT [%s/%s %s/%s] ***" % (klabel, mode, iname, unpad_f))
            print(dec.decode("utf-8", "replace")[:1200])
            results.append((klabel, mode, iname, unpad_f, p[:200]))
        elif pr(p) > 0.55:
            print("[%s %s/%s/%s] pr=%.2f head=%r" % (klabel, mode, iname, unpad_f, pr(p), p[:48]))

for k in sorted(keys):
    kk = k.encode("latin1")
    # AES-256 ASCII
    for iname, iv in IVS.items():
        try_dec(kk, k[:20], "AES256", iname, iv)
    # AES-128 hex-decode (if key is hex)
    try:
        k16 = binascii.unhexlify(kk)
        if len(k16) == 16:
            for iname, iv in IVS.items():
                try_dec(k16, k[:20], "AES128", iname, iv)
    except binascii.Error:
        pass

print("\nDONE. hits:", len(results))
