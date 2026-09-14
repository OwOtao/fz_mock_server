# -*- coding: utf-8 -*-
"""
解密 mock_server/value.md
========================
读取 config.KEY_GROUPS 中的密钥, 并对 value.md 中的 JM 密文尝试解密。

密文格式 (与 jm_crypto 一致):
    hex( magic(6B) + AES-CBC(plain) )
    明文用 ASCII '0' 补齐到 16 字节块

用法:
    python decrypt_value_md.py
    python decrypt_value_md.py --input value.md --output value_plain.txt
    python decrypt_value_md.py --group FZJH03
"""

from __future__ import print_function

import argparse
import binascii
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)

import config  # noqa: E402
import jm_crypto  # noqa: E402


# value.md 实测魔数为 FXXF01, 不在 KEY_GROUPS 中。
# 以下为 key.md / exchange_publickey / initLocalKey 中的补充候选, 仅用于爆破。
EXTRA_CANDIDATES = [
    # (name, key_bytes, iv_bytes)
    ("extra_FZJH01_ascii32", b"ae9b363b80d5cc594973ecce1f4d546d", b"PcIQIZifRalhZ88n"),
    ("extra_FZJH01_ascii32_defIV", b"ae9b363b80d5cc594973ecce1f4d546d", b"34857d973953e44a"),
    ("extra_FZJH01_hex16", binascii.unhexlify("ae9b363b80d5cc594973ecce1f4d546d"), b"PcIQIZifRalhZ88n"),
    ("extra_FZJH01_hex16_defIV", binascii.unhexlify("ae9b363b80d5cc594973ecce1f4d546d"), b"34857d973953e44a"),
    ("extra_JHHU01_ascii32", b"9B5A96B0F4A1EC60DB88349E3B926765", b"PcIQIZifRalhZ88n"),
    ("extra_JHHU01_hex16", binascii.unhexlify("9B5A96B0F4A1EC60DB88349E3B926765"), b"PcIQIZifRalhZ88n"),
    ("extra_JHHU01_hex16_defIV", binascii.unhexlify("9B5A96B0F4A1EC60DB88349E3B926765"), b"34857d973953e44a"),
    ("extra_pub_FZJH02_ascii", b"07818f3a34e8165227b0dc6b7e69ea57", b"PcIQIZifRalhZ88n"),
    ("extra_pub_FZJH02_defIV", b"07818f3a34e8165227b0dc6b7e69ea57", b"34857d973953e44a"),
    ("extra_pub_FZJH03_ascii", b"26549f871287ba9e838a057a7ffac1bc", b"PcIQIZifRalhZ88n"),
    ("extra_pub_FZJH03_defIV", b"26549f871287ba9e838a057a7ffac1bc", b"34857d973953e44a"),
    ("extra_test_key1_defIV", b"93a503f7cfaa11563a3ee36544f47430", b"34857d973953e44a"),
    ("extra_test_key2_defIV", b"a3374f473ed08213a285e7090196a93d", b"34857d973953e44a"),
    ("extra_rodata_39a0", b"eirdOhIycKhV18r$3iqszOfgKTPUcEmj", b"PcIQIZifRalhZ88n"),
    ("extra_rodata_39c0", b"jX4SM#xx4cMBZR!txR0ghhI&cq*P36Ih", b"PcIQIZifRalhZ88n"),
    ("extra_rodata_3a00", b"SKMl^0SmirQ6Hcnh^1VwP1UBBzVz*M6Y", b"PcIQIZifRalhZ88n"),
]


def load_hex_text(path):
    with open(path, "rb") as f:
        data = f.read().strip()
    # 允许带空白/换行
    text = data.decode("ascii", errors="ignore")
    text = "".join(text.split()).lower()
    if len(text) % 2:
        raise ValueError("密文 hex 长度为奇数: %d" % len(text))
    return text


def detect_magic(raw):
    if len(raw) < 6:
        return b""
    return raw[:6]


def printable_ratio(buf):
    if not buf:
        return 0.0
    good = sum(1 for b in buf if 32 <= b < 127 or b in (9, 10, 13))
    return good / float(len(buf))


def try_unpad_variants(dec):
    """返回 [(tag, plain_bytes), ...]"""
    out = [("rstrip0", dec.rstrip(b"0")), ("raw", dec)]
    pad = dec[-1] if dec else 0
    if 1 <= pad <= 16 and all(x == pad for x in dec[-pad:]):
        out.append(("pkcs7", dec[:-pad]))
    return out


def looks_like_json(plain):
    s = plain.lstrip()
    if not s or s[:1] not in (b"{", b"["):
        return False
    try:
        json.loads(plain.decode("utf-8"))
        return True
    except Exception:
        return False


def decrypt_with_key(enc, key, iv):
    if len(key) not in (16, 24, 32) or len(iv) != 16:
        raise ValueError("key/iv 长度非法 key=%d iv=%d" % (len(key), len(iv)))
    if len(enc) < 16 or len(enc) % 16:
        enc = enc[: len(enc) - (len(enc) % 16)]
    return jm_crypto._aes_cbc(enc, key, iv, "dec")


def iter_config_groups():
    for name, g in config.KEY_GROUPS.items():
        key = g.get("key")
        iv = g.get("iv")
        magic = g.get("magic")
        if not key or not iv:
            continue
        yield name, magic, key, iv


def main():
    ap = argparse.ArgumentParser(description="解密 value.md (JM AES 密文)")
    ap.add_argument(
        "--input", "-i",
        default=os.path.join(ROOT, "research", "samples", "value.md"),
        help="输入密文 hex 文件 (默认 research/samples/value.md)",
    )
    ap.add_argument(
        "--output", "-o",
        default=os.path.join(ROOT, "value_plain.txt"),
        help="解密成功时写入的明文文件",
    )
    ap.add_argument(
        "--group", "-g",
        default=None,
        help="仅使用 config.KEY_GROUPS 中指定组 (默认尝试全部)",
    )
    ap.add_argument(
        "--extra",
        action="store_true",
        default=True,
        help="同时尝试 key.md 补充候选 (默认开启)",
    )
    ap.add_argument(
        "--no-extra",
        action="store_true",
        help="不尝试补充候选密钥",
    )
    args = ap.parse_args()
    use_extra = args.extra and not args.no_extra

    print("=== 读取 config.KEY_GROUPS ===")
    for name, magic, key, iv in iter_config_groups():
        print("  %-10s magic=%r key=%r iv=%r" % (
            name, magic, key[:16] + b"...", iv))

    hex_text = load_hex_text(args.input)
    raw = binascii.unhexlify(hex_text)
    magic = detect_magic(raw)
    enc = raw[6:]
    enc = enc[: len(enc) - (len(enc) % 16)]

    print("\n=== 密文信息 ===")
    print("  file   :", args.input)
    print("  hexlen :", len(hex_text))
    print("  magic  :", magic, "(%s)" % magic.decode("latin-1", "replace"))
    print("  enc    :", len(enc), "bytes,", len(enc) // 16, "blocks")

    # 1) 优先走 jm_crypto 自动识别 (仅能匹配 KEY_GROUPS 内已知魔数)
    print("\n=== 尝试 jm_crypto.decrypt (自动魔数) ===")
    try:
        plain = jm_crypto.decrypt(hex_text)
        text = plain.decode("utf-8")
        print("  成功! 明文长度=%d" % len(text))
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(text)
        print("  已写入:", args.output)
        print("  预览:", text[:300])
        return 0
    except Exception as e:
        print("  失败:", e)

    # 2) 遍历 config 全部密钥组 (忽略魔数匹配, 直接 AES 解密)
    print("\n=== 遍历 config.KEY_GROUPS (忽略魔数, 直接 AES) ===")
    hits = []
    groups = list(iter_config_groups())
    if args.group:
        groups = [g for g in groups if g[0] == args.group]
        if not groups:
            print("  未找到密钥组:", args.group)
            return 2

    for name, gmagic, key, iv in groups:
        try:
            dec = decrypt_with_key(enc, key, iv)
        except Exception as e:
            print("  [%s] ERR %s" % (name, e))
            continue
        for tag, plain in try_unpad_variants(dec):
            pr = printable_ratio(plain)
            is_json = looks_like_json(plain)
            if is_json:
                text = plain.decode("utf-8")
                print("  *** JSON HIT group=%s unpad=%s ***" % (name, tag))
                print("      ", text[:200])
                hits.append((name, tag, text))
            elif pr >= 0.85:
                try:
                    preview = plain[:60].decode("utf-8", "replace")
                except Exception:
                    preview = repr(plain[:60])
                print("  [%-10s/%-7s] pr=%.2f preview=%r" % (name, tag, pr, preview))

    # 3) 补充候选
    if use_extra:
        print("\n=== 补充候选 (key.md / exchange_publickey / initLocalKey) ===")
        for name, key, iv in EXTRA_CANDIDATES:
            try:
                dec = decrypt_with_key(enc, key, iv)
            except Exception:
                continue
            for tag, plain in try_unpad_variants(dec):
                if looks_like_json(plain):
                    text = plain.decode("utf-8")
                    print("  *** JSON HIT %s/%s ***" % (name, tag))
                    print("      ", text[:200])
                    hits.append((name, tag, text))
                else:
                    pr = printable_ratio(plain)
                    if pr >= 0.9:
                        print("  [%-28s/%-7s] pr=%.2f head=%r" % (
                            name, tag, pr, plain[:40]))

    if hits:
        name, tag, text = hits[0]
        with open(args.output, "w", encoding="utf-8") as f:
            f.write(text)
        # 同时写一份 pretty json (若可解析)
        try:
            obj = json.loads(text)
            pretty_path = os.path.splitext(args.output)[0] + ".json"
            with open(pretty_path, "w", encoding="utf-8") as f:
                json.dump(obj, f, ensure_ascii=False, indent=2)
            print("\n已写入明文:", args.output)
            print("已写入 JSON :", pretty_path)
        except Exception:
            print("\n已写入明文:", args.output)
        print("命中密钥:", name, "unpad=", tag)
        return 0

    print("\n=== 结果 ===")
    print("未能用 config.KEY_GROUPS / 补充候选解密 value.md。")
    print("密文魔数为 FXXF01, 而 config.py 当前仅有:")
    for name, g in config.KEY_GROUPS.items():
        print("  - %s magic=%r" % (name, g.get("magic")))
    print("按 key.md 第 8 节: FXXF01 是 native 引导密钥, 需 Frida hook createAes 提取后")
    print("填入 config.KEY_GROUPS 再解密。建议:")
    print("  1) 运行 frida_getkeys.js / frida_fzjh03_hook.js 抓 createAes.key/iv")
    print("  2) 将抓到的 key/iv 写入 config.KEY_GROUPS['FXXF01']")
    print("  3) 重新执行本脚本")
    return 1


if __name__ == "__main__":
    sys.exit(main())
