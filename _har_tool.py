# -*- coding: utf-8 -*-
"""通用 HAR 解密 + 覆盖率审查工具。

用法:
    python _har_tool.py decrypt <har_path> <out_dir>
    python _har_tool.py audit <entries_dir>

decrypt:
    按魔数(JHHU01/JHHU02/FZJH03/FZJH02/FXXF03)解密请求体与响应体，
    先用 HAR 内 exchange_publickey 响应里的会话密钥覆盖密钥表，
    再输出 entries/*.json 与 summary.md。

audit:
    逐条把 entries 里的 URL 交给 server.match_route，统计已实现/未实现，
    并按域名排除第三方 SDK。
"""
import binascii
import glob
import json
import os
import re
import sys
from collections import Counter

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)
import jm_crypto  # noqa: E402
sys.stdout.reconfigure(encoding="utf-8")

GAME_HOSTS = ("xiaohoutiaotiao.com",)
THIRD_PARTY_HINTS = (
    "pangolin", "pglstatp", "douyin", "ctobsnssdk", "volces", "snssdk",
    "zijieapi", "umeng", "bytescm", "alisc1", "uop", "abtest",
)


def _key_table():
    """魔数 -> (key, [候选 IV 按优先级])。默认值与 decrypt_har_91.py 保持一致。"""
    return {
        b"JHHU01": (b"9B5A96B0F4A1EC60DB88349E3B926765", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
        b"JHHU02": (b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF", [b"PcIQIZifRalhZ88n", b"34857d973953e44a"]),
        b"FZJH03": (b"56611ad7cd284ae04c1432748fa5c761", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
        b"FZJH02": (b"3541a91c710ecd1e70fdff9a60c909c6", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
        b"FXXF03": (b"3541a91c710ecd1e70fdff9a60c909c6", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
    }


def printable_score(text):
    if not text:
        return 0.0
    return sum(1 for c in text if c.isprintable() or c.isspace()) / len(text)


def try_decrypt(text, keys):
    """按魔数解密。

    9-1(2.1.01) 格式: hex( magic(6) + AES-256-CBC 密文 )，IV 用协商/默认值。
    9-9(2.1.02) 格式: hex( magic(6) + iv(12) + AES-256-CBC 密文 )，
    即 magic 实际是 12 字节（6 字节魔数 + 12 字节 IV），密文长度必为 16 的倍数。
    这里按“魔数前缀 + 长度是否 16 对齐”自动识别两种格式。
    """
    t = (text or "").strip().lower()
    if not t or len(t) < 16:
        return None, None, "too_short"
    if re.fullmatch(r"[0-9a-f]+", t) is None:
        return None, None, "not_hex"
    try:
        raw = binascii.unhexlify(t)
    except binascii.Error:
        return None, None, "hex_error"
    for magic, (key, ivs) in keys.items():
        if not raw.startswith(magic):
            continue
        magic_len = len(magic)
        # 两种已知布局：
        #   2.1.01: magic(6) + 密文，IV 取协商值/默认值
        #   2.1.02: magic(6) + iv(12) + 密文（9-9 抓包 FZJH03 即此格式）
        # 无法只靠长度区分（去魔数后都可能 16 对齐），因此两种都试，取能解出 JSON 的。
        layouts = [(magic_len, list(ivs))]
        if magic_len == 6 and len(raw) >= 18 + 16:
            inline_iv = raw[6:18]
            layouts.append((18, [inline_iv] + [iv for iv in ivs if iv != inline_iv]))
        best, best_score, best_json = None, -1.0, None
        for offset, iv_list in layouts:
            enc = raw[offset:]
            enc = enc[: len(enc) - (len(enc) % 16)]
            if not enc:
                continue
            for iv in iv_list:
                if len(iv) != 16:
                    continue
                plain = jm_crypto._aes_cbc(enc, key, iv, "dec").rstrip(b"0")
                ptext = plain.decode("utf-8", "replace")
                score = printable_score(ptext)
                # 明文可能是压缩/二进制（如 getMd5List 大包），JSON 优先
                if best_json is None and ptext.lstrip()[:1] in "{[":
                    try:
                        json.loads(ptext)
                        best_json = ptext
                    except ValueError:
                        pass
                if score > best_score:
                    best, best_score = ptext, score
        if best_json is not None:
            return best_json, magic.decode(), "ok"
        if best_score > 0.9:
            return best, magic.decode(), "ok"
        return None, magic.decode(), "decrypt_fail(score=%.2f)" % best_score
    return None, None, "unknown_magic"


def pretty(text):
    if not text:
        return text
    try:
        return json.dumps(json.loads(text), ensure_ascii=False, indent=2)
    except Exception:
        return text


def load_session_keys(har, keys, log):
    """从 exchange_publickey 响应里取本次会话密钥，覆盖 FZJH02/03 等组。"""
    for entry in har.get("log", {}).get("entries", []):
        if "exchange_publickey" not in entry.get("request", {}).get("url", ""):
            continue
        text = entry.get("response", {}).get("content", {}).get("text", "")
        plain, magic, why = try_decrypt(text, keys)
        if plain is None:
            log("exchange_publickey 解密失败: %s" % why)
            continue
        try:
            outer = json.loads(plain)
            items = json.loads(outer["data"]) if isinstance(outer.get("data"), str) else outer.get("data")
        except Exception as exc:  # noqa: BLE001
            log("exchange_publickey 解析失败: %s" % exc)
            continue
        found = {}
        for item in items or []:
            name = item.get("h")
            if name and item.get("k"):
                magic_bytes = name.encode()
                iv_value = item.get("i")
                ivs = []
                if isinstance(iv_value, str) and iv_value:
                    ivs.append(iv_value.encode())
                ivs.append(b"PcIQIZifRalhZ88n")
                ivs.append(b"34857d973953e44a")
                keys[magic_bytes] = (item["k"].encode(), ivs)
                found[name] = "%s iv=%s" % (item["k"], iv_value or "(默认)")
        log("会话密钥: %s" % json.dumps(found, ensure_ascii=False))
        return found
    return {}


def entry_name(idx, url):
    path = url.split("?")[0].rstrip("/")
    api = path.rsplit("/", 1)[-1] if "/" in path else path or "root"
    api = re.sub(r"[^0-9A-Za-z_.-]+", "_", api)[:60] or "entry"
    return "%03d_%s" % (idx, api)


def do_decrypt(har_path, out_dir):
    keys = _key_table()
    with open(har_path, "r", encoding="utf-8") as handle:
        har = json.load(handle)
    entries = har["log"]["entries"]
    os.makedirs(os.path.join(out_dir, "entries"), exist_ok=True)
    entries_dir = os.path.join(out_dir, "entries")

    print("HAR: %s" % har_path)
    print("条目总数: %d" % len(entries))
    load_session_keys(har, keys, print)

    stats = Counter()
    rows = []
    for idx, entry in enumerate(entries):
        req = entry.get("request", {})
        resp = entry.get("response", {})
        url = req.get("url", "")
        host = url.split("/")[2] if "://" in url else ""
        path = url.split(host, 1)[-1].split("?")[0] if host else url
        method = req.get("method", "")
        status = resp.get("status", "")
        started = entry.get("startedDateTime", "")
        is_game = any(h in host for h in GAME_HOSTS)

        pd = req.get("postData")
        req_state = "-"
        if pd and pd.get("text"):
            plain, magic, why = try_decrypt(pd["text"], keys)
            if plain is not None:
                pd["text"] = plain
                pd["mimeType"] = "text/plain"
                req_state = "已解(%s)" % magic
                stats["req:%s" % magic] += 1
            elif not is_game:
                req_state = "第三方"
                stats["req:3rd_party"] += 1
            else:
                req_state = "明文" if pd["text"].lstrip()[:1] in "{[<n" else "二进制"
                stats["req:%s" % ("plain" if req_state == "明文" else "binary")] += 1

        content = resp.get("content", {})
        resp_state = "-"
        if content.get("text"):
            plain, magic, why = try_decrypt(content["text"], keys)
            if plain is not None:
                content["text"] = plain
                content["mimeType"] = "text/plain"
                content["size"] = len(plain.encode("utf-8"))
                resp_state = "已解(%s)" % magic
                stats["resp:%s" % magic] += 1
            elif is_game:
                resp_state = "明文" if why == "unknown_magic" else ("明文/二进制" if why == "not_hex" else "失败(%s)" % why)
                stats["resp:%s" % resp_state] += 1
            else:
                resp_state = "第三方"
                stats["resp:3rd_party"] += 1

        note = "" if is_game else "第三方SDK"
        rows.append((idx, started, method, status, host, path, req_state, resp_state, note))

        if is_game:
            out = {
                "index": idx,
                "startedDateTime": started,
                "url": url,
                "method": method,
                "status": status,
                "request_headers": {h.get("name", ""): h.get("value", "") for h in req.get("headers", [])},
                "request_plain": pd.get("text") if pd else "",
                "request_plain_pretty": pretty(pd.get("text")) if pd and pd.get("text") else "",
                "response_plain": content.get("text", ""),
                "response_plain_pretty": pretty(content.get("text", "")),
            }
            with open(os.path.join(entries_dir, entry_name(idx, url) + ".json"), "w", encoding="utf-8") as handle:
                json.dump(out, handle, ensure_ascii=False, indent=2)

    decrypted_har = os.path.join(out_dir, os.path.basename(har_path).replace(".har", "_decrypted.har"))
    with open(decrypted_har, "w", encoding="utf-8") as handle:
        json.dump(har, handle, ensure_ascii=False, indent=1)

    lines = [
        "# %s 解密汇总" % os.path.basename(har_path),
        "",
        "- 条目总数: %d" % len(entries),
        "- 输出目录: `%s`" % out_dir,
        "",
        "## 解密统计",
        "",
        "```",
    ]
    for key, value in sorted(stats.items()):
        lines.append("%-40s %d" % (key, value))
    lines += ["```", "", "## 条目明细", "",
              "| # | 时间 | 方法 | 状态 | 路径 | 请求体 | 响应体 | 备注 |",
              "|---|------|------|------|------|--------|--------|------|"]
    for idx, started, method, status, host, path, req_state, resp_state, note in rows:
        t = started[11:19] if len(started) >= 19 else started
        lines.append("| %d | %s | %s | %s | `%s%s` | %s | %s | %s |" % (
            idx, t, method, status, host, path, req_state, resp_state, note))
    lines.append("")
    with open(os.path.join(out_dir, "summary.md"), "w", encoding="utf-8") as handle:
        handle.write("\n".join(lines))

    print("已输出: %s" % decrypted_har)
    print("已输出条目: %d 个 -> %s" % (len(os.listdir(entries_dir)), entries_dir))
    for key, value in sorted(stats.items()):
        print("%-40s %d" % (key, value))


def do_audit(entries_dir):
    import handlers  # noqa: F401
    from server import ROUTES

    def match(path):
        key = path.strip("/")
        for prefix in ("api/v5/", "api/"):
            if key.startswith(prefix):
                key = key[len(prefix):]
                break
        key = key.strip("/")
        if key in ROUTES:
            return key
        parts = key.split("/")
        for i in range(len(parts) - 1, 0, -1):
            cand = "/".join(parts[:i])
            if cand in ROUTES:
                return cand
        return None

    files = sorted(glob.glob(os.path.join(entries_dir, "*.json")))
    game, third = [], []
    for path in files:
        with open(path, encoding="utf-8") as handle:
            entry = json.load(handle)
        url = entry.get("url") or ""
        m = re.match(r"^[a-zA-Z]+://([^/]+)(/.*)$", url)
        if not m:
            continue
        host, full = m.group(1), m.group(2).split("?")[0]
        rec = {"file": os.path.basename(path), "method": entry.get("method"),
               "status": entry.get("status"), "path": full, "host": host}
        if any(h in host for h in THIRD_PARTY_HINTS) or not (
            host.endswith("xiaohoutiaotiao.com")
        ):
            third.append(rec)
        else:
            game.append(rec)

    print("条目文件: %d, 游戏后端: %d, 第三方: %d" % (len(files), len(game), len(third)))

    seen = {}
    for rec in game:
        item = seen.setdefault(rec["path"], {"methods": set(), "count": 0, "file": rec["file"], "status": rec["status"]})
        item["methods"].add(rec["method"])
        item["count"] += 1

    ok, prefix, missing = [], [], []
    for path in sorted(seen):
        hit = match(path)
        if hit is None:
            missing.append((path, seen[path]))
        elif hit == path.strip("/").replace("api/v5/", ""):
            ok.append((path, hit, seen[path]))
        else:
            prefix.append((path, hit, seen[path]))

    print("\n=== 未实现 (%d) ===" % len(missing))
    for path, rec in missing:
        print("  MISSING %-6s x%-3d status=%s %s  [%s]" % (
            "/".join(sorted(rec["methods"])), rec["count"], rec["status"], path, rec["file"]))
    print("\n=== 前缀命中/带参数 (%d) ===" % len(prefix))
    for path, hit, rec in prefix:
        print("  PREFIX  %-6s x%-3d %s -> %s" % ("/".join(sorted(rec["methods"])), rec["count"], path, hit))
    print("\n=== 已实现 (%d) ===" % len(ok))
    for path, hit, rec in ok:
        print("  OK      %-6s x%-3d %s" % ("/".join(sorted(rec["methods"])), rec["count"], path))
    print("\n唯一路径: %d (OK %d + PREFIX %d + MISSING %d)" % (len(seen), len(ok), len(prefix), len(missing)))


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(__doc__)
        sys.exit(1)
    command = sys.argv[1]
    if command == "decrypt":
        do_decrypt(sys.argv[2], sys.argv[3])
    elif command == "audit":
        do_audit(sys.argv[2])
    else:
        print(__doc__)
        sys.exit(1)
