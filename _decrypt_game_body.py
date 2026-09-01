# -*- coding: utf-8 -*-
"""解密 server.log 中游戏 23:24 发出的 JHHU01 加密请求体, 确认客户端版本"""
import binascii
import sys

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

import jm_crypto

# server.log 第 19 行: report_ads_info 的请求体 (游戏 2.1.01 客户端发出)
CIPHER = (
    "4a4848553031ef679944544028a82f0c5737ded6c53a88762b7bd09cbe61dfd5"
    "626f47b1f1f2f7364dbccdae7ef286492bee0b4028f8c9c88105dc237fd3dad"
    "cbd2d157271cc17309ce594b9a1dd623414d9711da07a0171866a04d4f65799"
    "ff69ad1b5ab7ea64e74d7b0a8be7d1c4b26256776008843435e532992ae0040"
    "fa0c9a6c7b63368fde15c73c18dd53e69ca68534b70d251f28ae54ce7b0bb11"
    "31ed76c6b338273ff8679ce3fcedf5739fee1a819229a88c66f6849a0acd874"
    "6130573a216427189180867b2f8f746798cec16344bb2e7b2b105b8470d86628"
    "2c7e30e15b24c1fc2"
)

KEY = b"9B5A96B0F4A1EC60DB88349E3B926765"
raw = binascii.unhexlify(CIPHER)
print("魔数: %r, 密文 %d 字节" % (raw[:6], len(raw) - 6))

for iv_name, iv in (("34857d973953e44a", b"34857d973953e44a"),
                    ("PcIQIZifRalhZ88n", b"PcIQIZifRalhZ88n")):
    enc = raw[6:]
    enc = enc[:len(enc) - (len(enc) % 16)]
    plain = jm_crypto._aes_cbc(enc, KEY, iv, "dec").rstrip(b"0")
    text = plain.decode("utf-8", "replace")
    score = sum(1 for c in text if c.isprintable()) / max(len(text), 1)
    print("\n[IV %s] 可打印率 %.2f%s" % (iv_name, score, " <<<< 命中" if score > 0.9 else ""))
    print("明文: %s" % text[:400])
