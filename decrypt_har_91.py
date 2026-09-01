# -*- coding: utf-8 -*-
"""
解密 ProxyPin9-1_22_57_26.har 全部密文, 输出到工作目录 f:\\AI\\fzjh\\har_decrypt_91\\
- 会话密钥来自 har 内 exchange_publickey 响应 (JHHU01 魔数, 静态密钥解密)
- 产出: decrypted.har / entries/*.json / summary.md
"""
import sys, os, json, binascii, re
from collections import Counter

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)
import jm_crypto

HAR_PATH = os.path.join(ROOT, "so", "ProxyPin9-1_22_57_26.har")
OUT_DIR = os.path.join(os.path.dirname(ROOT), "har_decrypt_91")
ENTRIES_DIR = os.path.join(OUT_DIR, "entries")
os.makedirs(ENTRIES_DIR, exist_ok=True)

sys.stdout.reconfigure(encoding="utf-8")

# ---------------------------------------------------------------------------
# 密钥表: 魔数 -> (key, [候选IV 按优先级])
# JHHU01: so 内静态密钥(2.1.01), 用于本 HAR 的 exchange_publickey/get_game_config/
#         update 服务器 checkUpdate/getMd5List
# FZJH03/FZJH02/FXXF03: 从本 HAR exchange_publickey 解密提取的本次会话密钥
# JHHU02: default 组静态密钥(2.1.02)
# ---------------------------------------------------------------------------
KEYS = {
    b"JHHU01": (b"9B5A96B0F4A1EC60DB88349E3B926765", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
    b"JHHU02": (b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF", [b"PcIQIZifRalhZ88n", b"34857d973953e44a"]),
    b"FZJH03": (b"56611ad7cd284ae04c1432748fa5c761", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
    b"FZJH02": (b"3541a91c710ecd1e70fdff9a60c909c6", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
    b"FXXF03": (b"3541a91c710ecd1e70fdff9a60c909c6", [b"34857d973953e44a", b"PcIQIZifRalhZ88n"]),
}

GAME_HOSTS = ("xiaohoutiaotiao.com",)


def printable_score(text):
    if not text:
        return 0.0
    # \xa0 等空白 (游戏活动文案大量使用全角空格) 也算可打印
    return sum(1 for c in text if c.isprintable() or c.isspace()) / len(text)


def try_decrypt(text):
    """按魔数解密, 返回 (明文str或None, 魔数名, 用途说明)"""
    t = text.strip().lower()
    if not t or len(t) < 16:
        return None, None, "too_short"
    # hex 校验
    if re.fullmatch(r"[0-9a-f]+", t) is None:
        return None, None, "not_hex"
    for magic, (key, ivs) in KEYS.items():
        mh = binascii.hexlify(magic).decode()
        if not t.startswith(mh):
            continue
        try:
            raw = binascii.unhexlify(t)
        except binascii.Error:
            return None, None, "hex_error"
        enc = raw[len(magic):]
        enc = enc[:len(enc) - (len(enc) % 16)]
        if not enc:
            return None, magic.decode(), "empty_body"
        best, best_score = None, -1.0
        for iv in ivs:
            plain = jm_crypto._aes_cbc(enc, key, iv, "dec").rstrip(b"0")
            ptext = plain.decode("utf-8", "replace")
            s = printable_score(ptext)
            if s > best_score:
                best, best_score = ptext, s
        if best_score > 0.9:
            return best, magic.decode(), "ok"
        return None, magic.decode(), "decrypt_fail(score=%.2f)" % best_score
    return None, None, "unknown_magic"


def pretty(text):
    """尝试 JSON 美化, 失败原样返回"""
    if not text:
        return text
    try:
        return json.dumps(json.loads(text), ensure_ascii=False, indent=2)
    except Exception:
        return text


def entry_name(idx, url):
    path = url.split("?")[0].rstrip("/")
    api = path.rsplit("/", 1)[-1] if "/" in path else path or "root"
    api = re.sub(r"[^0-9A-Za-z_.-]+", "_", api)[:60] or "entry"
    return f"{idx:03d}_{api}"


with open(HAR_PATH, "r", encoding="utf-8") as f:
    har = json.load(f)
entries = har["log"]["entries"]
print(f"HAR 条目总数: {len(entries)}")

stats = Counter()
summary_rows = []  # (idx, time, method, status, host, path, req_state, resp_state, note)

for idx, e in enumerate(entries):
    req = e.get("request", {})
    resp = e.get("response", {})
    url = req.get("url", "")
    host = url.split("/")[2] if "://" in url else ""
    path = url.split(host, 1)[-1].split("?")[0] if host else url
    method = req.get("method", "")
    status = resp.get("status", "")
    started = e.get("startedDateTime", "")

    is_game = any(h in host for h in GAME_HOSTS)
    note = ""

    # ---- 请求体 ----
    pd = req.get("postData")
    req_state = "-"
    if pd and pd.get("text"):
        raw = pd["text"]
        plain, magic, why = try_decrypt(raw)
        if plain is not None:
            pd["text"] = plain
            pd["mimeType"] = "text/plain"
            req_state = f"已解({magic})"
            stats[f"req:{magic}"] += 1
        elif not is_game:
            req_state = "第三方"
            stats["req:3rd_party"] += 1
        else:
            if why in ("not_hex", "too_short"):
                req_state = "明文" if raw.lstrip()[:1] in "{[<n" else "二进制"
                if req_state == "明文":
                    stats["req:plain"] += 1
                else:
                    stats["req:binary"] += 1
            else:
                req_state = f"失败({why})"
                stats[f"req:fail:{why}"] += 1
    # ---- 响应体 ----
    content = resp.get("content", {})
    resp_state = "-"
    if content.get("text"):
        raw = content["text"]
        plain, magic, why = try_decrypt(raw)
        if plain is not None:
            content["text"] = plain
            content["mimeType"] = "text/plain"
            content["size"] = len(plain.encode("utf-8"))
            resp_state = f"已解({magic})"
            stats[f"resp:{magic}"] += 1
        elif is_game:
            if why == "unknown_magic":
                resp_state = "明文"
                stats["resp:plain"] += 1
            elif why == "not_hex":
                resp_state = "明文/二进制"
                stats["resp:plain_or_bin"] += 1
            else:
                resp_state = f"失败({why})"
                stats[f"resp:fail:{why}"] += 1
        else:
            resp_state = "第三方"
            stats["resp:3rd_party"] += 1

    if not is_game:
        note = "第三方SDK"
    summary_rows.append((idx, started, method, status, host, path, req_state, resp_state, note))

    # ---- 单条目文件 (仅游戏域名) ----
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
        name = entry_name(idx, url)
        with open(os.path.join(ENTRIES_DIR, name + ".json"), "w", encoding="utf-8") as f:
            json.dump(out, f, ensure_ascii=False, indent=2)

# ---- 解密版 HAR ----
har_out = os.path.join(OUT_DIR, "ProxyPin9-1_22_57_26_decrypted.har")
with open(har_out, "w", encoding="utf-8") as f:
    json.dump(har, f, ensure_ascii=False, indent=1)
print(f"已输出解密版 HAR: {har_out}")

# ---- 汇总 ----
lines = [
    "# ProxyPin9-1_22_57_26.har 解密汇总",
    "",
    f"- 条目总数: {len(entries)}",
    f"- 输出目录: `{OUT_DIR}`",
    "",
    "## 本次会话密钥 (来自 har 内 exchange_publickey, JHHU01 静态密钥解出)",
    "",
    "```json",
    json.dumps([
        {"k": "3541a91c710ecd1e70fdff9a60c909c6", "h": "FZJH02"},
        {"k": "56611ad7cd284ae04c1432748fa5c761", "h": "FZJH03"},
        {"k": "3541a91c710ecd1e70fdff9a60c909c6", "h": "FXXF03"},
    ], indent=2),
    "```",
    "",
    "- IV: `34857d973953e44a` (默认 IV, 本 HAR 的 FZJH03 组未下发 `i` 字段, 实测默认 IV 正确)",
    "- exchange_publickey / get_game_config / update 服务器响应使用 `JHHU01` 静态组 (2.1.01 客户端)",
    "",
    "## 解密统计",
    "",
    "```",
]
for k, v in sorted(stats.items()):
    lines.append(f"{k:40s} {v}")
lines += ["```", "", "## 条目明细", "",
          "| # | 时间 | 方法 | 状态 | 路径 | 请求体 | 响应体 | 备注 |",
          "|---|------|------|------|------|--------|--------|------|"]
for idx, started, method, status, host, path, req_state, resp_state, note in summary_rows:
    t = started[11:19] if len(started) >= 19 else started
    host_short = host.split(".")[0] if host else ""
    lines.append(f"| {idx} | {t} | {method} | {status} | `{host_short}{path}` | {req_state} | {resp_state} | {note} |")
lines.append("")

with open(os.path.join(OUT_DIR, "summary.md"), "w", encoding="utf-8") as f:
    f.write("\n".join(lines))
print(f"已输出汇总: {os.path.join(OUT_DIR, 'summary.md')}")
print(f"已输出条目文件: {len(os.listdir(ENTRIES_DIR))} 个 -> {ENTRIES_DIR}")
print("\n--- 统计 ---")
for k, v in sorted(stats.items()):
    print(f"{k:40s} {v}")
