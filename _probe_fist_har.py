# -*- coding: utf-8 -*-
"""按 HAR 自带的 exchange_publickey 会话密钥解密 so/*.har, 汇总拳脚系统相关接口。

用法:
    python _probe_fist_har.py [关键字 ...]      # 默认抓 fist/technique/talent
输出每个命中的 请求明文 / 响应明文, 便于比对 mock 实现。
"""
import binascii
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)
import jm_crypto  # noqa: E402

STATIC_KEYS = {
    b"JHHU01": (b"9B5A96B0F4A1EC60DB88349E3B926765", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
    b"JHHU02": (b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF", [b"PcIQIZifRalhZ88n", b"34857d973953e44a"]),
}

DEFAULT_KEYWORDS = ("fist", "technique", "talent", "characterPool", "feel_point", "updataFist")


def score(text):
    if not text:
        return 0.0
    return sum(1 for c in text if c.isprintable() or c.isspace()) / len(text)


def try_keys(text, keys):
    t = (text or "").strip().lower()
    if not t or len(t) < 16 or re.fullmatch(r"[0-9a-f]+", t) is None:
        return None, None
    raw = binascii.unhexlify(t)
    for magic, (key, ivs) in keys.items():
        if not raw.startswith(magic):
            continue
        enc = raw[len(magic):]
        enc = enc[: len(enc) - (len(enc) % 16)]
        if not enc:
            return None, magic
        best, best_score = None, -1.0
        for iv in ivs:
            plain = jm_crypto._aes_cbc(enc, key, iv, "dec").rstrip(b"0")
            text_out = plain.decode("utf-8", "replace")
            s = score(text_out)
            if s > best_score:
                best, best_score = text_out, s
        if best_score > 0.9:
            return best, magic
        return None, magic
    return None, None


def session_keys(entries):
    """从 HAR 里解出本次会话的 FZJH02/03/FXXF03 密钥。"""
    keys = dict(STATIC_KEYS)
    for e in entries:
        url = e.get("request", {}).get("url", "")
        if "exchange_publickey" not in url and "get_game_config" not in url:
            continue
        body = e.get("response", {}).get("content", {}).get("text", "")
        plain, _magic = try_keys(body, STATIC_KEYS)
        if not plain:
            continue
        try:
            obj = json.loads(plain)
        except ValueError:
            continue
        data = obj.get("data")
        if isinstance(data, str):
            try:
                data = json.loads(data)
            except ValueError:
                continue
        if not isinstance(data, list):
            continue
        for item in data:
            if not isinstance(item, dict) or not item.get("k") or not item.get("h"):
                continue
            magic = str(item["h"]).encode()
            key = str(item["k"]).encode()
            iv = str(item.get("i") or "34857d973953e44a").encode()
            keys.setdefault(magic, (key, [iv, b"34857d973953e44a", b"PcIQIZifRalhZ88n"]))
        break
    return keys


def pretty(text):
    try:
        return json.dumps(json.loads(text), ensure_ascii=False)
    except Exception:
        return text


def main(argv):
    keywords = tuple(argv[1:]) or DEFAULT_KEYWORDS
    for har_path in sorted(glob.glob(os.path.join(ROOT, "so", "*.har"))):
        with open(har_path, "r", encoding="utf-8") as fh:
            har = json.load(fh)
        entries = har.get("log", {}).get("entries", [])
        keys = session_keys(entries)
        print("\n" + "=" * 100)
        print(os.path.basename(har_path), "entries=%d" % len(entries),
              "groups=%s" % ",".join(sorted(k.decode() for k in keys)))
        for idx, e in enumerate(entries):
            url = e.get("request", {}).get("url", "")
            api = url.split("?")[0].rstrip("/").rsplit("/", 1)[-1]
            if not any(k.lower() in api.lower() for k in keywords):
                continue
            req = e.get("request", {}).get("postData", {}).get("text", "")
            resp = e.get("response", {}).get("content", {}).get("text", "")
            req_plain, _ = try_keys(req, keys)
            resp_plain, _ = try_keys(resp, keys)
            print("-" * 100)
            print("[%03d] %s  %s" % (idx, api, e.get("startedDateTime", "")))
            print("  req :", pretty(req_plain or req)[:1500])
            print("  resp:", pretty(resp_plain or resp)[:2500])


if __name__ == "__main__":
    main(sys.argv)
