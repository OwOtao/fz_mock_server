# -*- coding: utf-8 -*-
"""Decrypt request bodies of selected HAR entries with session key."""
import json
import sys

sys.path.insert(0, ".")
from _analyze_har_gaps import extract_session_keys
import jm_crypto

name = sys.argv[1]
needle = sys.argv[2] if len(sys.argv) > 2 else ""
har = json.load(open("so/" + name, encoding="utf-8"))
print("session keys:", extract_session_keys(har))
for i, e in enumerate(har["log"]["entries"]):
    url = e["request"]["url"]
    if needle and needle not in url:
        continue
    body = (e["request"].get("postData") or {}).get("text") or ""
    if not body:
        continue
    try:
        plain = jm_crypto.decrypt(body).decode("utf-8", "replace")
    except Exception as ex:
        plain = "<fail: %s> %s" % (ex, body[:60])
    print("%3d %-70s %s" % (i, url.split("xiaohoutiaotiao.com")[-1], plain))
