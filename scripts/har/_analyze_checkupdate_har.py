# -*- coding: utf-8 -*-
"""精确提取 so/*.har 中 checkUpdate / getMd5List 条目"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import json
import glob
import os
import sys
import base64

sys.stdout.reconfigure(encoding="utf-8")

HAR_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "so")


def summarize_entry(entry, har_name):
    req = entry.get("request", {})
    resp = entry.get("response", {})
    print("=" * 100)
    print("HAR: %s | %s | time=%sms" % (
        har_name, entry.get("startedDateTime"), entry.get("time")))
    print("REQUEST: %s %s" % (req.get("method"), req.get("url")))
    print("  httpVersion=%s remoteIP=%s remotePort=%s" % (
        req.get("httpVersion"), entry.get("serverIPAddress", ""),
        entry.get("_remotePort", entry.get("connection", ""))))
    qs = req.get("queryString") or []
    if qs:
        print("  queryString: %s" % json.dumps(qs, ensure_ascii=False))
    hdrs = {h.get("name", "").lower(): h.get("value", "") for h in req.get("headers", [])}
    for k in sorted(hdrs):
        v = hdrs[k]
        if k == "device" and len(v) > 200:
            v = v[:200] + "..."
        print("  req-header %s: %s" % (k, v))
    print("RESPONSE: status=%s %s" % (resp.get("status"), resp.get("statusText", "")))
    rhdrs = {h.get("name", "").lower(): h.get("value", "") for h in resp.get("headers", [])}
    for k in sorted(rhdrs):
        print("  resp-header %s: %s" % (k, rhdrs[k]))
    content = resp.get("content", {})
    text = content.get("text", "") or ""
    print("  resp content size=%s mimeType=%s encoding=%s" % (
        content.get("size"), content.get("mimeType"), content.get("encoding")))
    if content.get("encoding") == "base64" and text:
        try:
            decoded = base64.b64decode(text)
            print("  resp body len=%d head_hex=%s" % (len(decoded), decoded[:80].hex()))
            print("  resp body head_repr=%r" % decoded[:80])
        except Exception as e:
            print("  [base64 decode failed: %s] raw head=%r" % (e, text[:200]))
    else:
        print("  resp body preview: %r" % text[:1500])


def main():
    for har_path in sorted(glob.glob(os.path.join(HAR_DIR, "*.har"))):
        har_name = os.path.basename(har_path)
        with open(har_path, "r", encoding="utf-8") as f:
            har = json.load(f)
        entries = har.get("log", {}).get("entries", [])
        hits = []
        hosts = {}
        for entry in entries:
            url = entry.get("request", {}).get("url", "")
            path = url.split("?")[0]
            if path.rstrip("/").endswith("/checkUpdate") or path.rstrip("/").endswith("/getMd5List"):
                hits.append(entry)
                host = url.split("/")[2] if "://" in url else "?"
                hosts.setdefault(host, 0)
                hosts[host] += 1
        print("\n\n######## %s: %d/%d entries matched (hosts: %s)" % (
            har_name, len(hits), len(entries), hosts))
        for entry in hits:
            summarize_entry(entry, har_name)


if __name__ == "__main__":
    main()
