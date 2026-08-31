# -*- coding: utf-8 -*-
"""验证 FZJH03 密钥组 round-trip 加解密."""
import sys, os
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mock_server"))
import jm_crypto

plain = b'{"status":0,"errcode":0,"data":{"time":1722854400}}'

# 加密
enc = jm_crypto.encrypt(plain, "FZJH03")
print("encrypted:", enc[:80] + "...")

# 解密
dec = jm_crypto.decrypt(enc, "FZJH03")
print("decrypted:", dec)
print("round-trip OK:", dec == plain)

# 也测试自动检测密钥组
dec2 = jm_crypto.decrypt(enc)
print("auto-detect decrypted:", dec2)
print("auto-detect OK:", dec2 == plain)

# 测试用 JM::test() 的测试密文验证 (不期望产生可读文本, 只验证不崩溃)
import binascii
TEST_HEX = ("465a4a483033912dfe73c67ef3cffeeb512e7d2e3d772ec2d19ccce6b10623a05"
            "b1459487055800d0d917b38c848e66f176b26676302bc0eef68546fd563acdcf"
            "a94002dc1d55a42f444a2b746069e73b0b7a1570c5c868744e447d6d03fe27ce"
            "562a2b0da13")
print("\n--- JM::test() 密文解密 (不期望可读) ---")
try:
    dec_test = jm_crypto.decrypt(TEST_HEX, "FZJH03")
    print("decrypted bytes:", dec_test[:48])
    print("hex:", dec_test[:48].hex())
except Exception as e:
    print("error:", e)
