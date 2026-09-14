# -*- coding: utf-8 -*-
"""用客户端 HttpManager 全量接口清单(protocol_inventory.json)对比 mock_server 覆盖情况。

用于回答“har_decrypt_91 抓包之外还有哪些接口没实现”，
并标注本次 9-1 抓包是否覆盖到这些接口。
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
import handlers  # noqa: F401,E402
from server import ROUTES  # noqa: E402

HAR_DIR = os.path.join(ROOT, "so", "har_decrypt_91", "entries")


def har_paths():
    paths = set()
    for path in glob.glob(os.path.join(HAR_DIR, "*.json")):
        with open(path, encoding="utf-8") as handle:
            entry = json.load(handle)
        url = entry.get("url") or ""
        m = re.match(r"^[a-zA-Z]+://([^/]+)(/.*)$", url)
        if not m:
            continue
        host, full = m.group(1), m.group(2).split("?")[0]
        if "android.fzjh" not in host:
            continue
        key = re.sub(r"^/api/v5/", "", full).strip("/")
        paths.add(key.split("/")[0])
    return paths


def covered(url, routes):
    key = url.strip("/")
    if key in routes:
        return key
    parts = key.split("/")
    for i in range(len(parts) - 1, 0, -1):
        cand = "/".join(parts[:i])
        if cand in routes:
            return cand
    return None


def main():
    inventory = json.load(open(os.path.join(ROOT, "fzjh_lua", "protocol_inventory.json"), encoding="utf-8"))
    captured = har_paths()

    rows = []
    for item in inventory:
        raw_urls = [u for u in (item.get("urls") or []) if isinstance(u, str) and u.strip()]
        if not raw_urls:
            continue
        # 形如 ["api/v5/", "api/service/", "update_order_state"] 表示
        # DOMAIN..API_PREFIX..name，需要拼接；单元素时直接用。
        urls = ["".join(raw_urls).split("api/v5/")[-1].split("api/service_android/")[-1]
                .split("api/service/")[-1]] if len(raw_urls) > 1 else raw_urls
        for url in urls:
            key = url.strip("/")
            hit = covered(key, ROUTES)
            rows.append({
                "api": item.get("name"),
                "url": key,
                "method": (item.get("method") or "").upper(),
                "hit": hit,
                "in_har": key.split("/")[0] in captured,
            })

    total = len(rows)
    ok = [r for r in rows if r["hit"]]
    miss = [r for r in rows if not r["hit"]]
    print("客户端接口总数(含多 URL): %d, 已实现: %d, 未实现: %d" % (total, len(ok), len(miss)))
    print("其中本次 9-1 抓包出现过: %d" % len([r for r in rows if r["in_har"]]))

    print("\n=== 未实现且 9-1 抓包出现过（需重点关注）===")
    for r in sorted([x for x in miss if x["in_har"]], key=lambda x: x["url"]):
        print("  MISSING-HAR %-6s %-42s api=%s" % (r["method"], r["url"], r["api"]))
    print("\n=== 未实现且 9-1 抓包未出现（本次无法验证）===")
    for r in sorted([x for x in miss if not x["in_har"]], key=lambda x: x["url"]):
        print("  MISSING     %-6s %-42s api=%s" % (r["method"], r["url"], r["api"]))
    print("\n=== 已实现且 9-1 抓包出现过 ===")
    for r in sorted([x for x in ok if x["in_har"]], key=lambda x: x["url"]):
        print("  OK          %-6s %-42s -> %s" % (r["method"], r["url"], r["hit"]))


if __name__ == "__main__":
    main()
