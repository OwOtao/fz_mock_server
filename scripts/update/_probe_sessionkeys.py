# -*- coding: utf-8 -*-
"""客户端到底用哪套密钥解 getMd5List? 看 2.1.02 抓包里 exchange_publickey 的会话密钥。"""
import binascii
import json
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")
import config  # noqa: E402
from handlers import service  # noqa: E402

for label, name in (("9-9(2.1.02)", "ProxyPin9-9_09_12_12.har"),
                    ("9-10(2.1.02)", "ProxyPin9-10_18_00_08.har")):
    har = json.load(open(os.path.join(ROOT, "so", name), encoding="utf-8"))
    print("=== %s" % label)
    for entry in har["log"]["entries"]:
        if "exchange_publickey" not in entry["request"]["url"]:
            continue
        text = (entry["response"]["content"].get("text") or "").strip()
        raw = binascii.unhexlify(text)
        print("    密文魔数=%r hexlen=%d" % (raw[:6], len(text)))
        for magic, (key, iv) in service._update_groups().items():
            payload = raw[len(magic):]
            payload = payload[: len(payload) - (len(payload) % 16)]
            plain = service._jm_dec(payload, key, iv) if hasattr(service, "_jm_dec") else None
            if plain is None:
                import jm_crypto
                plain = jm_crypto._aes_cbc(payload, key, iv, "dec").rstrip(b"0")
            if plain.lstrip()[:1] in (b"{", b"["):
                print("    用 %s 解出: %s" % (magic.decode(), plain.decode("utf-8", "replace")[:300]))
        # 关键: 响应里给出的 key/iv 与本机 KEY_GROUPS 是否一致
        break
    else:
        print("    没有 exchange_publickey 条目")
