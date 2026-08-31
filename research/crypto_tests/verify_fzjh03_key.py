# -*- coding: utf-8 -*-
"""解析 0x1183b18 处的 FXXF03 配置块, 推断 FZJH03 组 key/iv 结构.

配置块(hex 文本 204 字符, 解码 102 字节):
  "FZJH03"(6B magic) + 96B payload

96B payload 可能布局:
  - key(32B) + iv(16B) + reserved(48B)
  - 或 key(32B) + iv(16B) + tag(1B) + ...
"""
import sys, os, binascii
sys.path.insert(0, os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "mock_server"))
import jm_crypto

CFG_HEX = ("465a4a483033912dfe73c67ef3cffeeb512e7d2e3d772ec2d19ccce6b10623a05"
           "b1459487055800d0d917b38c848e66f176b26676302bc0eef68546fd563acdcf"
           "a94002dc1d55a42f444a2b746069e73b0b7a1570c5c868744e447d6d03fe27ce"
           "562a2b0da13")
cfg = binascii.unhexlify(CFG_HEX)
magic = cfg[:6]
payload = cfg[6:]
print("magic:", magic)
print("payload len:", len(payload), "hex:", payload.hex())

# 候选 key/iv 拆分
candidates = [
    ("key=payload[0:32] iv=payload[32:48]", payload[0:32], payload[32:48]),
    ("key=payload[0:32] iv=PcIQ", payload[0:32], b"PcIQIZifRalhZ88n"),
    ("key=93a5...(rodata) iv=payload[0:16]",
     binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"),
     payload[0:16]),
    ("key=93a5...(rodata) iv=payload[16:32]",
     binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"),
     payload[16:32]),
    ("key=93a5...(rodata) iv=payload[32:48]",
     binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"),
     payload[32:48]),
    ("key=93a5...(rodata) iv=PcIQ",
     binascii.unhexlify("93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"),
     b"PcIQIZifRalhZ88n"),
]

# 用默认组加密一段明文, 然后尝试用各候选 key/iv 解密, 看是否一致
# (注意: 不同 key 加密的密文无法互相解密, 所以这里只做 round-trip + 结构合理性判断)
plain = b'{"status":0,"errcode":0,"data":{"time":1722854400}}'
print("\n=== Round-trip + JM 格式封装测试 ===")
for name, key, iv in candidates:
    if len(key) != 32 or len(iv) != 16:
        print("  SKIP (尺寸不对):", name, "key", len(key), "iv", len(iv))
        continue
    try:
        enc = jm_crypto._aes_cbc(jm_crypto._pad(plain), key, iv, "enc")
        # 封装为 JM 格式: hex(magic + enc)
        jm_hex = binascii.hexlify(magic + enc).decode()
        # 解密回来
        dec = jm_crypto._aes_cbc(enc, key, iv, "dec").rstrip(b"0")
        ok = dec == plain
        print("  %-45s %s" % (name, "OK" if ok else "FAIL"))
        if ok:
            print("    key=%s" % key.hex())
            print("    iv =%s" % iv.hex())
            print("    sample enc(jm): %s..." % jm_hex[:48])
    except Exception as e:
        print("  %-45s ERR %s" % (name, e))

# 关键: 用默认组密钥解密 APK 内 Lua 文件已验证, 现在用 FZJH03 候选 key 解密
# 一段已知用 FZJH03 加密的 HTTP 密文(如果有). 没有抓包, 只能靠结构推断.
print("\n=== 结论 ===")
print("FZJH03 组 key (32B, 来自 rodata 0x1183bf8+0x1183c18):")
print("  93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d")
print("FZJH03 组 iv  (16B): 候选见上, 需运行时确认")
print("  最可能: PcIQIZifRalhZ88n (与 JHHU02 组复用, initLocalKey 中 IV 单独存储)")
