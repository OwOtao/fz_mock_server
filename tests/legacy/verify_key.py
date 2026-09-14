# -*- coding: utf-8 -*-
"""JM 密文密钥验证: 输入抓到的 HTTP 密文(hex 文本), 用候选密钥解密, 找合法 JSON。

用法:
    python verify_key.py <密文hex文本或文件>
    python verify_key.py --file captured.txt
"""

import binascii
import json
import sys

sys.path.insert(0, __import__("os").path.dirname(__import__("os").path.dirname(__import__("os").path.dirname(__file__))))
from jm_crypto import _aes_cbc  # noqa: E402

IV = b"PcIQIZifRalhZ88n"
MAGIC = b"JHHU02"

# 候选密钥组 (来自静态分析)
CANDIDATES = {
    "FZJH03_a+b(32B)": binascii.unhexlify(
        b"93a503f7cfaa11563a3ee36544f47430a3374f473ed08213a285e7090196a93d"),
    "FZJH03_a(16B)": binascii.unhexlify(b"93a503f7cfaa11563a3ee36544f47430"),
    "FZJH03_b(16B)": binascii.unhexlify(b"a3374f473ed08213a285e7090196a93d"),
    "default_cbIh(32B)": b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF",
    "rodata_39a0_1": b"eirdOhIycKhV18r$3iqszOfgKTPUcEmj",
    "rodata_39c0_2": b"jX4SM#xx4cMBZR!txR0ghhI&cq*P36Ih",
    "rodata_3a00_3": b"SKMl^0SmirQ6Hcnh^1VwP1UBBzVz*M6Y",
}
# 二进制候选从 so 直接取
import zipfile  # noqa: E402
APK = r"E:\Leidian14\Picutres\leidian9Picutres\product_fangzhijianghu_guanfang_2.1.02.apk"
_z = zipfile.ZipFile(APK)
_so = _z.read("lib/arm64-v8a/libcocos2dlua.so")
CANDIDATES["rodata_3a20_bin"] = _so[0x1183a20:0x1183a40]
CANDIDATES["rodata_39e0_bin"] = _so[0x11839e0:0x1183a00]


def decrypt_with(text, key, iv):
    raw = binascii.unhexlify(text.strip().lower())
    if not raw.startswith(MAGIC):
        return None
    enc = raw[len(MAGIC):]
    enc = enc[:len(enc) - (len(enc) % 16)]
    if not enc:
        return None
    p = _aes_cbc(enc, key, iv, "dec").rstrip(b"0")
    return p


def looks_json(p):
    try:
        json.loads(p.decode("utf-8"))
        return True
    except Exception:
        return False


def main():
    text = None
    if len(sys.argv) > 2 and sys.argv[1] == "--file":
        text = open(sys.argv[2], encoding="utf-8").read().strip()
    elif len(sys.argv) >= 2:
        text = sys.argv[1].strip()
    if not text:
        print("用法: python verify_key.py <密文hex> 或 --file <文件>")
        return

    # 多 IV 组合尝试
    ivs = {
        "iv=PcIQ": IV,
        "iv=key前16": binascii.unhexlify(b"93a503f7cfaa11563a3ee36544f47430"),
        "iv=zero": bytes(16),
    }
    for name, key in CANDIDATES.items():
        if not key:
            continue
        for ivn, iv in ivs.items():
            try:
                p = decrypt_with(text, key, iv)
            except Exception as e:
                print("  %-22s %s ERR %s" % (name, ivn, e))
                continue
            if p is None:
                continue
            pr = sum(1 for x in p if 32 <= x < 127 or x in (9, 10, 13)) / max(len(p), 1)
            isj = looks_json(p)
            mark = " *** JSON HIT ***" if isj else ""
            if isj or pr > 0.8:
                print("  %-22s %-12s pr=%.2f len=%d head=%r%s" % (name, ivn, pr, len(p), p[:48], mark))
            if isj:
                print("  >>> 明文:", p.decode("utf-8", "replace")[:500])


if __name__ == "__main__":
    main()
