# -*- coding: utf-8 -*-
"""尝试用 hex 解码后的密钥解密服务器 FXXF01 配置响应.

FXXF03 组使用 128-bit (16字节) AES 密钥 -> FXXF01 可能也是.
initLocalKey 中的密钥都是 32 字符 hex 串 -> hex 解码 = 16 字节 = AES-128.
"""
import sys, os, binascii
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..")))
import jm_crypto

with open(os.path.join(HERE, "server_config_raw.bin"), "rb") as f:
    resp_hex = f.read().strip()

raw = binascii.unhexlify(resp_hex)
magic = raw[:6]  # b"FXXF01"
enc = raw[6:]
print("magic:", magic, "enc len:", len(enc), "(%d blocks)" % (len(enc) // 16))

# initLocalKey 密钥 (32 字符 hex 串)
STATIC_KEYS = {
    "FZJH01": "ae9b363b80d5cc594973ecce1f4d546d",
    "JHHU01": "9B5A96B0F4A1EC60DB88349E3B926765",
    "JHHU02": "cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF",  # 非 hex, 无法解码
}

# FZJH03 test keys
FZJH03_KEYS = [
    "93a503f7cfaa11563a3ee36544f47430",
    "a3374f473ed08213a285e7090196a93d",
]

# IV 候选
IVS = {
    "default": b"34857d973953e44a",
    "PcIQ": b"PcIQIZifRalhZ88n",
    "zero": b"\x00" * 16,
    "empty_str": b"                ",  # 16 spaces
}

# 也试试 IV 的 hex 解码版本
IV_HEX_CANDIDATES = {
    "defIV-hexdec": binascii.unhexlify("34857d973953e44a") + b"\x00" * 8,  # 8+8=16
}

print("\n=== AES-128 (hex 解码 16 字节 key) ===")
for kname, khex in {**STATIC_KEYS, **{k: k for k in FZJH03_KEYS}}.items():
    try:
        key16 = binascii.unhexlify(khex)  # 16 bytes
    except binascii.Error:
        print("  %s: 非 hex, 跳过" % kname)
        continue
    for iname, iv in {**IVS, **IV_HEX_CANDIDATES}.items():
        try:
            dec = jm_crypto._aes_cbc(enc, key16, iv, "dec")
            stripped = dec.rstrip(b"0")
            try:
                text = stripped.decode("utf-8", errors="strict")
                print("\n*** HIT! [%s/%s] AES-128 ***" % (kname, iname))
                print("    key(hex): %s" % khex)
                print("    key(bytes): %s" % key16.hex())
                print("    iv: %s" % iv.hex())
                print("    text: %r" % text[:500])
            except:
                printable = sum(1 for b in dec if 32 <= b < 127 or b in (10, 13, 0, 9))
                ratio = printable / len(dec)
                if ratio > 0.5:
                    print("  [%s/%s] ratio=%.0f%% preview=%r" % (kname, iname, ratio*100, dec[:80]))
        except Exception as e:
            pass

print("\n=== AES-256 (ASCII 32 字节 key) ===")
for kname, khex in {**STATIC_KEYS, **{k: k for k in FZJH03_KEYS}}.items():
    key32 = khex.encode("ascii")  # 32 bytes
    for iname, iv in IVS.items():
        try:
            dec = jm_crypto._aes_cbc(enc, key32, iv, "dec")
            stripped = dec.rstrip(b"0")
            try:
                text = stripped.decode("utf-8", errors="strict")
                print("\n*** HIT! [%s/%s] AES-256 ***" % (kname, iname))
                print("    text: %r" % text[:500])
            except:
                printable = sum(1 for b in dec if 32 <= b < 127 or b in (10, 13, 0, 9))
                ratio = printable / len(dec)
                if ratio > 0.5:
                    print("  [%s/%s] ratio=%.0f%% preview=%r" % (kname, iname, ratio*100, dec[:80]))
        except:
            pass

# 也试试 FZJH03 full key hex-decoded (32 bytes AES-256)
print("\n=== AES-256 (FZJH03 full hex-decoded 32 字节) ===")
full_key = binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d")
for iname, iv in {**IVS, **IV_HEX_CANDIDATES}.items():
    try:
        dec = jm_crypto._aes_cbc(enc, full_key, iv, "dec")
        stripped = dec.rstrip(b"0")
        try:
            text = stripped.decode("utf-8", errors="strict")
            print("\n*** HIT! [FZJH03-full/%s] ***" % iname)
            print("    text: %r" % text[:500])
        except:
            printable = sum(1 for b in dec if 32 <= b < 127 or b in (10, 13, 0, 9))
            ratio = printable / len(dec)
            if ratio > 0.5:
                print("  [FZJH03-full/%s] ratio=%.0f%%" % (iname, ratio*100))
    except:
        pass

# 试试 PKCS7 unpad 而不是 '0' strip
print("\n=== PKCS7 unpad 测试 (AES-128) ===")
for kname, khex in {**STATIC_KEYS, **{k: k for k in FZJH03_KEYS}}.items():
    try:
        key16 = binascii.unhexlify(khex)
    except:
        continue
    for iname, iv in IVS.items():
        try:
            dec = jm_crypto._aes_cbc(enc, key16, iv, "dec")
            # PKCS7 unpad
            pad_len = dec[-1]
            if 1 <= pad_len <= 16 and all(b == pad_len for b in dec[-pad_len:]):
                unpadded = dec[:-pad_len]
                try:
                    text = unpadded.decode("utf-8", errors="strict")
                    print("\n*** PKCS7 HIT! [%s/%s] ***" % (kname, iname))
                    print("    text: %r" % text[:500])
                except:
                    printable = sum(1 for b in unpadded if 32 <= b < 127 or b in (10, 13, 0, 9))
                    ratio = printable / len(unpadded) if len(unpadded) > 0 else 0
                    if ratio > 0.5:
                        print("  [%s/%s] PKCS7 ratio=%.0f%% preview=%r" % (kname, iname, ratio*100, unpadded[:80]))
        except:
            pass

print("\n=== 完成 ===")
