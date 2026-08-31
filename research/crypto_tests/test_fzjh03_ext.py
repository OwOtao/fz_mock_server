# -*- coding: utf-8 -*-
"""穷举 FZJH03 key/iv/mode 组合 - 扩展版.

覆盖:
  - AES-CBC + ECB
  - key 变换: hex-decode, nibble-swap, half-swap, MD5, SHA256, raw ASCII
  - iv 变换: default, zero, PcIQ, hex-decode
  - ciphertext 变换: raw, pair-swap, reversed
"""
import sys, os, binascii, hashlib, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mock_server"))
import jm_crypto

# --- 测试密文 (来自 JM::test() 反编译) ---
TEST_HEX = ("465a4a483033912dfe73c67ef3cffeeb512e7d2e3d772ec2d19ccce6b10623a05"
            "b1459487055800d0d917b38c848e66f176b26676302bc0eef68546fd563acdcf"
            "a94002dc1d55a42f444a2b746069e73b0b7a1570c5c868744e447d6d03fe27ce"
            "562a2b0da13")
raw = binascii.unhexlify(TEST_HEX)
magic = raw[:6]  # b"FZJH03"
enc_raw = raw[6:]  # 96 bytes

KEY_STR = "93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"
KEY_H1  = "93a503f7cfaa11563a3ee36544f47430"
KEY_H2  = "a3374f473ed08213a285e7090196a93d"

def nibble_swap(b):
    """Swap nibbles in each byte: 0x93 -> 0x39."""
    return bytes(((x >> 4) | ((x & 0xf) << 4)) & 0xff for x in b)

def pair_swap(b):
    """Swap each pair of bytes: [a,b,c,d] -> [b,a,d,c]."""
    out = bytearray()
    for i in range(0, len(b), 2):
        out.append(b[i+1] if i+1 < len(b) else 0)
        out.append(b[i])
    return bytes(out)

def word_rev(b):
    """Reverse each 4-byte word."""
    return b"".join(b[i:i+4][::-1] for i in range(0, len(b), 4))

def dword_rev(b):
    """Reverse each 8-byte doubleword."""
    return b"".join(b[i:i+8][::-1] for i in range(0, len(b), 8))

# --- key 候选 (扩展) ---
key_full_hex = binascii.unhexlify(KEY_STR)
key_h1_hex = binascii.unhexlify(KEY_H1)
key_h2_hex = binascii.unhexlify(KEY_H2)

key_candidates = [
    # 标准变换
    ("hex_full", key_full_hex, 256),
    ("hex_full_rev", key_full_hex[::-1], 256),
    ("hex_full_nibble", nibble_swap(key_full_hex), 256),
    ("hex_full_pairswap", pair_swap(key_full_hex), 256),
    ("hex_full_wordrev", word_rev(key_full_hex), 256),
    ("hex_full_dwordrev", dword_rev(key_full_hex), 256),
    # 半key
    ("hex_h1", key_h1_hex, 128),
    ("hex_h2", key_h2_hex, 128),
    ("hex_h1_nibble", nibble_swap(key_h1_hex), 128),
    ("hex_h2_nibble", nibble_swap(key_h2_hex), 128),
    # ASCII
    ("ascii_full_32", KEY_STR[:32].encode(), 256),
    ("ascii_h1", KEY_H1.encode(), 256),
    ("ascii_h2", KEY_H2.encode(), 256),
    # Hash
    ("md5_full", hashlib.md5(KEY_STR.encode()).digest(), 128),
    ("md5_h1", hashlib.md5(KEY_H1.encode()).digest(), 128),
    ("md5_h2", hashlib.md5(KEY_H2.encode()).digest(), 128),
    ("sha256_full", hashlib.sha256(KEY_STR.encode()).digest(), 256),
    ("sha256_h1", hashlib.sha256(KEY_H1.encode()).digest(), 256),
    ("sha256_h2", hashlib.sha256(KEY_H2.encode()).digest(), 256),
    # 半key拼接(交换顺序)
    ("hex_h2+h1", key_h2_hex + key_h1_hex, 256),
    ("hex_h2+h1_nibble", nibble_swap(key_h2_hex + key_h1_hex), 256),
]

# --- iv 候选 ---
iv_candidates = [
    ("def_ascii", b"34857d973953e44a"),
    ("zero", b"\x00" * 16),
    ("PcIQ", b"PcIQIZifRalhZ88n"),
    ("def_hex_pad", binascii.unhexlify("34857d973953e44a") + b"\x00" * 8),
    ("def_nibble", nibble_swap(binascii.unhexlify("34857d973953e44a") + b"\x00" * 8)),
    ("FZJH03_pad", b"FZJH03" + b"\x00" * 10),
    ("def_hex_rev", binascii.unhexlify("34857d973953e44a")[::-1] + b"\x00" * 8),
]

# --- ciphertext 变换 ---
enc_variants = [
    ("raw", enc_raw),
    ("pairswap", pair_swap(enc_raw)),
    ("reversed", enc_raw[::-1]),
    ("wordrev", word_rev(enc_raw)),
    ("nibble", nibble_swap(enc_raw)),
]

print("magic:", magic, "enc_len:", len(enc_raw))

hits = []
total = 0
for ename, enc in enc_variants:
    for kname, key, bits in key_candidates:
        klen = len(key)
        if klen not in (16, 24, 32):
            continue
        # CBC mode
        for iname, iv in iv_candidates:
            if len(iv) != 16:
                continue
            total += 1
            try:
                dec = jm_crypto._aes_cbc(enc, key, iv, "dec")
                stripped = dec.rstrip(b"0")
                try:
                    text = stripped.decode("utf-8", errors="strict")
                    is_utf8 = True
                except:
                    is_utf8 = False
                    text = None
                printable = sum(1 for b in dec if 32 <= b < 127 or b in (10, 13, 0))
                ratio = printable / len(dec)
                if ratio > 0.7 or is_utf8:
                    tag = "CBC <<<<< HIT"
                    hits.append(("CBC", ename, kname, iname, key, iv, dec, text, ratio, is_utf8))
                    print("  enc=%-10s key=%-18s iv=%-12s %s ratio=%.0f%%" %
                          (ename, kname, iname, tag, ratio * 100))
                    if is_utf8:
                        print("    TEXT: %r" % text[:120])
                    else:
                        print("    hex: %s" % dec[:48].hex())
            except Exception:
                pass

        # ECB mode (no IV)
        total += 1
        try:
            # ECB = CBC with zero IV, but each block independent
            # Implement ECB manually
            rk, nr = jm_crypto._key_expansion(key)
            dec = b""
            for i in range(0, len(enc) - 15, 16):
                blk = enc[i:i+16]
                dec += jm_crypto._aes_decrypt_block(blk, rk, nr)
            stripped = dec.rstrip(b"0")
            try:
                text = stripped.decode("utf-8", errors="strict")
                is_utf8 = True
            except:
                is_utf8 = False
                text = None
            printable = sum(1 for b in dec if 32 <= b < 127 or b in (10, 13, 0))
            ratio = printable / len(dec)
            if ratio > 0.7 or is_utf8:
                tag = "ECB <<<<< HIT"
                hits.append(("ECB", ename, kname, "N/A", key, b"", dec, text, ratio, is_utf8))
                print("  enc=%-10s key=%-18s ECB %s ratio=%.0f%%" %
                      (ename, kname, tag, ratio * 100))
                if is_utf8:
                    print("    TEXT: %r" % text[:120])
                else:
                    print("    hex: %s" % dec[:48].hex())
        except Exception:
            pass

print("\n=== 总尝试: %d 组合 ===" % total)
if hits:
    print("\n=== 命中 %d 个 ===" % len(hits))
    for mode, ename, kname, iname, key, iv, dec, text, ratio, is_utf8 in hits:
        print("\n[%s] enc=%s key=%s iv=%s" % (mode, ename, kname, iname))
        print("  key hex: %s" % key.hex())
        if iv:
            print("  iv hex:  %s" % iv.hex())
        if is_utf8:
            print("  解密文本: %r" % text)
        else:
            print("  解密hex: %s" % dec.hex())
        print("  可读率: %.0f%%" % (ratio * 100))
else:
    print("\n没有命中!")
