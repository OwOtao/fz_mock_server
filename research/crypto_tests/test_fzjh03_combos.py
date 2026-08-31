# -*- coding: utf-8 -*-
"""用 JM::test() 中的测试密文暴力验证 FZJH03 key/iv 格式.

JM::test() 反编译显示:
  1. 测试密文 = "465a4a483033..." (hex), hex 解码后前 6 字节 = "FZJH03" (magic)
  2. addInfo("FZJH03", "93a503f7cfaa11563a3ee36544f47430", "", 0)  -- 前半 key
  3. stringDecrypt(hexStringToBytes(密文))
  4. addInfo("FZJH03", "a3374f473ed08213a285e7090196a93d", "", 0)  -- 后半 key
  5. stringDecrypt(hexStringToBytes(密文))

getIv(): IV 为空时返回 "34857d973953e44a"
"""
import sys, os, binascii, struct
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mock_server"))
import jm_crypto

# --- 测试密文 (来自 JM::test() 反编译) ---
TEST_HEX = ("465a4a483033912dfe73c67ef3cffeeb512e7d2e3d772ec2d19ccce6b10623a05"
            "b1459487055800d0d917b38c848e66f176b26676302bc0eef68546fd563acdcf"
            "a94002dc1d55a42f444a2b746069e73b0b7a1570c5c868744e447d6d03fe27ce"
            "562a2b0da13")
raw = binascii.unhexlify(TEST_HEX)
magic = raw[:6]  # b"FZJH03"
enc = raw[6:]     # 96 bytes AES ciphertext
print("magic:", magic)
print("enc len:", len(enc), "(%d blocks)" % (len(enc) // 16))

# --- key 候选 ---
KEY_HEX_FULL = "93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"
KEY_HEX_1 = "93a503f7cfaa11563a3ee36544f47430"
KEY_HEX_2 = "a3374f473ed08213a285e7090196a93d"

key_candidates = [
    # (名称, key_bytes, aes_bits)
    ("full hex-decoded (32B AES-256)", binascii.unhexlify(KEY_HEX_FULL), 256),
    ("full hex-decoded reversed (32B)", binascii.unhexlify(KEY_HEX_FULL)[::-1], 256),
    ("half1 ASCII (32B AES-256)", KEY_HEX_1.encode("ascii"), 256),
    ("half2 ASCII (32B AES-256)", KEY_HEX_2.encode("ascii"), 256),
    ("full ASCII first 32 (32B)", KEY_HEX_FULL[:32].encode("ascii"), 256),
    ("full ASCII last 32 (32B)", KEY_HEX_FULL[32:].encode("ascii"), 256),
    ("full ASCII (64B, trunc 32)", KEY_HEX_FULL.encode("ascii")[:32], 256),
    ("half1 hex-decoded (16B AES-128)", binascii.unhexlify(KEY_HEX_1), 128),
    ("half2 hex-decoded (16B AES-128)", binascii.unhexlify(KEY_HEX_2), 128),
    # byte-pair swap variants
    ("full hex-decoded pair-swap", bytes(sum(zip(binascii.unhexlify(KEY_HEX_FULL)[1::2],
                                                   binascii.unhexlify(KEY_HEX_FULL)[::2]), ()), ), 256),
    # 4-byte word swap (endianness)
    ("full hex-decoded word-rev", b"".join(binascii.unhexlify(KEY_HEX_FULL)[i:i+4][::-1]
                                            for i in range(0, 32, 4)), 256),
]

# --- iv 候选 ---
iv_candidates = [
    ("default '34857d973953e44a' ASCII", b"34857d973953e44a"),
    ("zero IV", b"\x00" * 16),
    ("PcIQIZifRalhZ88n", b"PcIQIZifRalhZ88n"),
    ("default hex-decoded (8B pad16)", binascii.unhexlify("34857d973953e44a") + b"\x00" * 8),
    ("FZJH03+pad", b"FZJH03" + b"\x00" * 10),
]

print("\n=== 暴力验证: 尝试所有 key/iv 组合 ===")
hits = []
for kname, key, bits in key_candidates:
    klen = len(key)
    for iname, iv in iv_candidates:
        if klen not in (16, 24, 32) or len(iv) != 16:
            continue
        try:
            dec = jm_crypto._aes_cbc(enc, key, iv, "dec")
            # 检查是否为可读文本 (ASCII printable or valid UTF-8)
            printable = sum(1 for b in dec if 32 <= b < 127 or b in (10, 13, 0))
            ratio = printable / len(dec)
            # 去掉尾部 '0' 填充后检查
            stripped = dec.rstrip(b"0")
            try:
                text = stripped.decode("utf-8", errors="strict")
                is_utf8 = True
            except:
                is_utf8 = False
                text = None

            tag = ""
            if ratio > 0.7 or is_utf8:
                tag = " <<<<< HIT"
                hits.append((kname, iname, key, iv, dec, text, ratio, is_utf8))

            if ratio > 0.3 or is_utf8:
                preview = dec[:48].hex()
                try:
                    ascii_preview = dec[:48].decode("ascii", errors="replace")
                except:
                    ascii_preview = ""
                print("  [%d-bit] %-38s + %-30s ratio=%.0f%% %s%s" %
                      (bits, kname, iname, ratio * 100, tag, ""))
                if is_utf8:
                    print("       UTF-8 text: %r" % text[:80])
                else:
                    print("       hex: %s" % preview)
                    print("       ascii: %r" % ascii_preview)
        except Exception as e:
            pass

print("\n=== 汇总 ===")
if hits:
    for kname, iname, key, iv, dec, text, ratio, is_utf8 in hits:
        print("KEY: %s" % kname)
        print("  key hex: %s" % key.hex())
        print("  IV:  %s" % iname)
        print("  iv hex:  %s" % iv.hex())
        if is_utf8:
            print("  解密文本: %r" % text)
        else:
            print("  解密hex: %s" % dec.hex())
        print("  可读率: %.0f%%" % (ratio * 100))
        print()
else:
    print("没有命中! 所有组合都产生不可读结果.")
    print("可能需要检查:")
    print("  1. key 是否经过其他变换")
    print("  2. 密文是否需要额外处理")
    print("  3. dwh 函数中的 magic 验证逻辑")
