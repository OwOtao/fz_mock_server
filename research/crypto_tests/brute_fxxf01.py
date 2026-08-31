# -*- coding: utf-8 -*-
"""FXXF01 密钥爆破: 用所有已知 rodata/initLocalKey/exchange 候选 key 尝试解密."""
import sys, os, binascii
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mock_server"))
import jm_crypto

raw = binascii.unhexlify(open(os.path.join(os.path.dirname(os.path.abspath(__file__)),
                                           "server_config_raw.bin"), "rb").read().strip())
magic, enc = raw[:6], raw[6:]
print(f"magic={magic} enc_len={len(enc)} blocks={len(enc)//16}")

# 所有 32B ASCII key 候选
KEYS_32 = {
    "JHHU02/default": b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF",
    "rodata_eird": b"eirdOhIycKhV18r$3iqszOfgKTPUcEmj",
    "rodata_jX4S": b"jX4SM#xx4cMBZR!txR0ghhI&cq*P36Ih",
    "rodata_LRH@": b"LRH@tTYnmussgjGdyHd775*4RGCMCoIL",
    "rodata_SKMl": b"SKMl^0SmirQ6Hcnh^1VwP1UBBzVz*M6Y",
    "FXXF03/FZJH02": b"07818f3a34e8165227b0dc6b7e69ea57",
    "FZJH03_prod": b"26549f871287ba9e838a057a7ffac1bc",
    "FZJH03_test1": b"93a503f7cfaa11563a3ee36544f47430",
    "FZJH03_test2": b"a3374f473ed08213a285e7090196a93d",
    "FZJH01_ascii": b"ae9b363b80d5cc594973ecce1f4d546d",
}

# 16B key 候选 (hex 解码)
KEYS_16 = {
    "FZJH01_hex": binascii.unhexlify("ae9b363b80d5cc594973ecce1f4d546d"),
    "JHHU01_hex": binascii.unhexlify("9B5A96B0F4A1EC60DB88349E3B926765"),
    "FXXF03_hex": binascii.unhexlify("07818f3a34e8165227b0dc6b7e69ea57"),
}

IVS = {
    "defIV": b"34857d973953e44a",
    "PcIQ": b"PcIQIZifRalhZ88n",
    "zero": b"\x00" * 16,
}

def try_decrypt(key, iv, label):
    try:
        dec = jm_crypto._aes_cbc(enc, key, iv, "dec")
    except Exception:
        return
    stripped = dec.rstrip(b"0")
    if not stripped:
        return
    # 检查是否为可读 JSON/文本
    printable = sum(1 for b in stripped if 32 <= b < 127 or b in (9, 10, 13)) / len(stripped)
    starts_json = stripped[:1] in (b"{", b"[")
    if starts_json or printable > 0.7:
        print(f"\n*** HIT [{label}] printable={printable:.0%} ***")
        print(f"    key={key!r}")
        print(f"    iv={iv!r}")
        try:
            print(f"    text={stripped[:300].decode('utf-8')}")
        except:
            print(f"    raw={stripped[:100]}")
        return True
    return False

print("\n=== AES-256 (32B ASCII key) ===")
found = False
for kname, key in KEYS_32.items():
    for iname, iv in IVS.items():
        if try_decrypt(key, iv, f"{kname}/{iname}"):
            found = True

print("\n=== AES-128 (16B hex-decoded key) ===")
for kname, key in KEYS_16.items():
    for iname, iv in IVS.items():
        if try_decrypt(key, iv, f"{kname}/{iname}"):
            found = True

# 也试试 key 的前 16 字节 (AES-128)
print("\n=== AES-128 (32B key 截断前 16B) ===")
for kname, key in KEYS_32.items():
    for iname, iv in IVS.items():
        if try_decrypt(key[:16], iv, f"{kname}[:16]/{iname}"):
            found = True

if not found:
    print("\n[!] 所有已知候选 key 均无法解密 FXXF01 密文")
    print("    FXXF01 密钥不在 SO 静态数据中, 需要运行时提取")
