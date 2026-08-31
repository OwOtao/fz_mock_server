# -*- coding: utf-8 -*-
"""Usage: python _show_har_entry.py <har> <substring-of-url> [req|resp|both]"""
import json
import sys

name, needle = sys.argv[1], sys.argv[2]
part = sys.argv[3] if len(sys.argv) > 3 else "both"
har = json.load(open("so/" + name, encoding="utf-8"))
for i, e in enumerate(har["log"]["entries"]):
    url = e["request"]["url"]
    if needle not in url:
        continue
    print("=" * 16, i, url)
    if part in ("req", "both"):
        print("METHOD:", e["request"]["method"])
        for h in e["request"]["headers"]:
            print("  H %s: %s" % (h["name"], h["value"]))
        pd = e["request"].get("postData", {})
        if pd:
            print("  BODY(%s): %s" % (pd.get("mimeType"), (pd.get("text") or "")[:2000]))
    if part in ("resp", "both"):
        print("STATUS:", e["response"]["status"])
        for h in e["response"]["headers"]:
            print("  H %s: %s" % (h["name"], h["value"]))
        text = e["response"].get("content", {}).get("text", "")
        print("  RESP:", (text or "")[:600])
