# -*- coding: utf-8 -*-
"""尝试用已知密钥解密服务器 get_game_config 响应."""
import sys, os, binascii
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.abspath(os.path.join(HERE, "..", "..")))
import jm_crypto

# 从文件读取服务器响应
with open(os.path.join(HERE, "server_config_raw.bin"), "rb") as f:
    resp_hex = f.read().strip()

print("response len:", len(resp_hex))
raw = binascii.unhexlify(resp_hex)
magic = raw[:6]
enc = raw[6:]
print("magic:", magic)
print("enc len:", len(enc), "(%d blocks)" % (len(enc) // 16))

# --- 密钥候选 ---
keys = [
    # initLocalKey 已知组
    ("JHHU02-ASCII", b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF", b"PcIQIZifRalhZ88n"),
    # FZJH03 候选 (test 死代码)
    ("FZJH03-h1-ASCII+defIV", b"93a503f7cfaa11563a3ee36544f47430", b"34857d973953e44a"),
    ("FZJH03-h2-ASCII+defIV", b"a3374f473ed08213a285e7090196a93d", b"34857d973953e44a"),
    ("FZJH03-hex+defIV", binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"), b"34857d973953e44a"),
    # JHHU02 with default IV
    ("JHHU02+defIV", b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF", b"34857d973953e44a"),
    # zero IV variants
    ("FZJH03-h1+zeroIV", b"93a503f7cfaa11563a3ee36544f47430", b"\x00" * 16),
    ("FZJH03-h2+zeroIV", b"a3374f473ed08213a285e7090196a93d", b"\x00" * 16),
    ("FZJH03-hex+zeroIV", binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"), b"\x00" * 16),
    ("JHHU02+zeroIV", b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF", b"\x00" * 16),
    # FZJH03 hex with PcIQ IV
    ("FZJH03-hex+PcIQ", binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"), b"PcIQIZifRalhZ88n"),
]

print("\n=== 暴力尝试 ===")
for name, key, iv in keys:
    try:
        dec = jm_crypto._aes_cbc(enc, key, iv, "dec")
        stripped = dec.rstrip(b"0")
        try:
            text = stripped.decode("utf-8", errors="strict")
            print("\n*** [%s] UTF-8 成功! ***" % name)
            print("    %r" % text[:300])
        except:
            printable = sum(1 for b in dec if 32 <= b < 127 or b in (10, 13, 0, 9))
            ratio = printable / len(dec)
            if ratio > 0.5:
                print("  [%s] ratio=%.0f%% preview=%r" % (name, ratio * 100, dec[:80]))
            else:
                print("  [%s] ratio=%.0f%% (binary)" % (name, ratio * 100))
    except Exception as e:
        print("  [%s] ERR: %s" % (name, e))
