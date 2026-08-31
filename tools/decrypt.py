# -*- coding: utf-8 -*-
"""JM 密文解密脚本。

直接传入文件路径或密文 hex，在控制台输出明文。
未传参数时默认解密 research/samples/test.md。

用法:
    python decrypt.py
    python tools/decrypt.py research/samples/test.md
    python decrypt.py 465a4a483033...
"""

from __future__ import print_function

import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, ROOT)

import jm_crypto  # noqa: E402


def load_hex(arg):
    if os.path.isfile(arg):
        with open(arg, "rb") as f:
            data = f.read()
        text = data.decode("ascii", errors="ignore")
    else:
        text = arg
    return "".join(text.split()).lower()


def format_plain(plain):
    text = plain.decode("utf-8")
    try:
        return json.dumps(json.loads(text), ensure_ascii=False, indent=2)
    except Exception:
        return text


def main(argv):
    if len(argv) >= 2:
        source = argv[1]
    else:
        source = os.path.join(ROOT, "research", "samples", "test.md")
        if not os.path.isfile(source):
            print("用法: python decrypt.py <文件路径|密文hex>")
            return 1

    hex_text = load_hex(source)
    if not hex_text:
        print("空输入")
        return 1
    if len(hex_text) % 2:
        print("密文 hex 长度为奇数: %d" % len(hex_text))
        return 1

    try:
        plain = jm_crypto.decrypt(hex_text)
    except Exception as e:
        print("解密失败:", e)
        return 1

    print(format_plain(plain))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
