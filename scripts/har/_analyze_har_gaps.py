# -*- coding: utf-8 -*-
"""Analyze HAR capture, extract valid response contents, compare with mock_server."""
import base64
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HAR_NAME = sys.argv[1] if len(sys.argv) > 1 else "ProxyPin8-27_14_33_32.har"
HAR_PATH = os.path.join(ROOT, "so", HAR_NAME)

sys.path.insert(0, ROOT)
import jm_crypto  # noqa: E402
from config import KEY_GROUPS  # noqa: E402


def extract_session_keys(har):
    """从 HAR 内 exchange_publickey 响应提取本会话协商的密钥, 覆盖 KEY_GROUPS.

    FZJH03 key 每次会话随机下发(config.py 中只是历史会话的快照),
    直接用固定 key 解密新抓包会得到乱码。
    """
    for e in har.get("log", {}).get("entries", []):
        if "exchange_publickey" not in e.get("request", {}).get("url", ""):
            continue
        text = e.get("response", {}).get("content", {}).get("text", "")
        try:
            plain = jm_crypto.decrypt(text).decode("utf-8", "replace")
            outer = json.loads(plain)
            items = json.loads(outer["data"])
        except Exception:
            continue
        for item in items:
            name = item.get("h")
            if name in KEY_GROUPS and item.get("k"):
                KEY_GROUPS[name] = {
                    "magic": KEY_GROUPS[name]["magic"],
                    "key": item["k"].encode("ascii"),
                    "iv": (item.get("i") or KEY_GROUPS[name]["iv"].decode("ascii")).encode("ascii"),
                }
        return {n: g["key"].decode("ascii", "replace") for n, g in KEY_GROUPS.items()}
    return None


def try_decrypt(text):
    if not text or len(text) < 16 or not re.fullmatch(r"[0-9a-fA-F]+", text):
        return None, None
    try:
        plain = jm_crypto.decrypt(text)
        magic = base64.b16decode(text[:12], casefold=True)
        return plain, magic.decode("ascii", "replace")
    except Exception:
        return None, None
    return None, None


def main():
    with open(HAR_PATH, "r", encoding="utf-8") as f:
        har = json.load(f)

    entries = har.get("log", {}).get("entries", [])
    print("total entries: %d" % len(entries))
    session_keys = extract_session_keys(har)
    if session_keys:
        print("session keys from exchange_publickey:")
        for n, k in session_keys.items():
            print("  %-8s key=%s" % (n, k))

    summary = {}
    for e in entries:
        req = e.get("request", {})
        resp = e.get("response", {})
        url = req.get("url", "")
        path = re.sub(r"^[a-zA-Z]+://[^/]+/", "/", url).split("?")[0]
        body = resp.get("content", {}).get("text", "") or ""
        key = (req.get("method", ""), path, resp.get("status", 0))
        info = summary.setdefault(key, {"count": 0, "resp_len": 0})
        info["count"] += 1
        info["resp_len"] = max(info["resp_len"], len(body))

    print("\n=== endpoint summary ===")
    for (method, path, status), info in sorted(summary.items(), key=lambda x: x[0][1]):
        print("%5d %-6s x%-3d %s  resp_len=%d" % (status, method, info["count"], path, info["resp_len"]))

    out_dir = os.path.join(ROOT, "data", "har_analysis")
    os.makedirs(out_dir, exist_ok=True)
    manifest = []
    for i, e in enumerate(entries):
        req = e.get("request", {})
        resp = e.get("response", {})
        url = req.get("url", "")
        path = re.sub(r"^[a-zA-Z]+://[^/]+/", "/", url).split("?")[0]
        if not path.startswith("/api/"):
            continue
        body = resp.get("content", {}).get("text", "") or ""
        if not body:
            continue
        plain, group = try_decrypt(body)
        if plain is None:
            if body.lstrip().startswith("{"):
                plain, group = body, "plain"
            else:
                continue
        if isinstance(plain, bytes):
            plain = plain.decode("utf-8", "replace")
        safe = re.sub(r"[^a-zA-Z0-9_]+", "_", path.strip("/"))
        fname = "%04d_%s.json" % (i, safe)
        with open(os.path.join(out_dir, fname), "w", encoding="utf-8") as f:
            f.write(plain)
        manifest.append({"index": i, "method": req.get("method"), "path": path,
                         "status": resp.get("status"), "group": group, "file": fname,
                         "plain_len": len(plain)})

    with open(os.path.join(out_dir, "_manifest.json"), "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
    print("\ndecrypted %d responses -> data/har_analysis/" % len(manifest))
    for m in manifest:
        print("  [%s] %s (%dB) -> %s" % (m["group"], m["path"], m["plain_len"], m["file"]))

    # ---- 与 mock_server 已注册路由对比 ----
    route_re = re.compile(r"@route\(\s*\[([^\]]*)\]\s*,\s*['\"]([^'\"]+)['\"]")
    registered = {}
    for hf in sorted(glob.glob(os.path.join(ROOT, "handlers", "*.py"))):
        with open(hf, "r", encoding="utf-8") as f:
            src = f.read()
        for methods, pattern in route_re.findall(src):
            for m in methods.split(","):
                registered.setdefault(m.strip().strip("'\""), set()).add(pattern)

    print("\n=== registered routes (%d GET / %d POST) ===" % (
        len(registered.get("GET", ())), len(registered.get("POST", ()))))
    for m in ("GET", "POST"):
        for p in sorted(registered.get(m, ())):
            print("  %-4s %s" % (m, p))

    print("\n=== HAR endpoints missing from mock_server ===")
    for (method, path, status) in sorted(summary, key=lambda x: x[1]):
        if status != 200 or not path.startswith("/api/v5/"):
            continue
        name = path[len("/api/v5/"):]
        if name in registered.get(method, ()):
            continue
        base = name.split("/")[0]
        if base in registered.get(method, ()):
            print("  PARTIAL %-4s %s (base=%s 已注册, 带参数路径)" % (method, name, base))
            continue
        print("  MISSING %-4s %s" % (method, name))


if __name__ == "__main__":
    main()
