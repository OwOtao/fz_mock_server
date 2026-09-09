# -*- coding: utf-8 -*-
"""对 so/har_decrypt_91 抓包中的每个接口做“能跑通”验证。

对每个抓包 URL：
1. 用 server.match_route 找到路由；
2. 按 server._dispatch 的方式构造 ctx（headers/body/route_tail）；
3. 直接调用 handler，记录 errcode / 是否 404 / 响应是否为空。

第三方 SDK 请求已在 _audit_har91_coverage.py 中排除，本脚本只处理游戏后端。
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.abspath(__file__))
ENTRY_DIR = os.path.join(
    ROOT, sys.argv[1] if len(sys.argv) > 1 else os.path.join("so", "har_decrypt_91", "entries")
)
sys.path.insert(0, ROOT)

import handlers  # noqa: F401,E402
from server import ROUTES, match_route, route_parts, strip_prefix  # noqa: E402
from state import StateStore  # noqa: E402


def main():
    store = StateStore(autosave=False)
    userid = store.ensure_account()["userid"]

    rows = []
    for path in sorted(glob.glob(os.path.join(ENTRY_DIR, "*.json"))):
        with open(path, "r", encoding="utf-8") as handle:
            entry = json.load(handle)
        url = entry.get("url") or ""
        m = re.match(r"^[a-zA-Z]+://([^/]+)(/.*)$", url)
        if not m:
            continue
        host, full = m.group(1), m.group(2).split("?")[0]
        if "android.fzjh" not in host and "update.xiaohoutiaotiao" not in host:
            continue

        method = entry.get("method")
        try:
            body = json.loads(entry.get("request_plain") or "{}")
        except ValueError:
            body = {}
        if not isinstance(body, dict):
            body = {"_list": body}

        entry_route, matched, key = match_route(full)
        if entry_route is None:
            rows.append((full, method, "NO_ROUTE", "", os.path.basename(path)))
            continue
        allowed, fn = entry_route
        if method not in allowed:
            rows.append((full, method, "METHOD_MISMATCH(%s)" % ",".join(allowed), "", os.path.basename(path)))
            continue
        ctx = {
            "method": method,
            "path": full,
            "query": {},
            "headers": {"userid": str(userid)},
            "body": body,
            "raw_body": entry.get("request_plain") or "",
            "state": store,
            "route": matched,
            "route_tail": route_parts(strip_prefix(full), matched),
        }
        try:
            result = fn(ctx)
        except Exception as exc:  # noqa: BLE001
            rows.append((full, method, "EXC:%s" % type(exc).__name__, str(exc)[:120], os.path.basename(path)))
            continue
        if not isinstance(result, dict):
            rows.append((full, method, "NON_DICT", type(result).__name__, os.path.basename(path)))
            continue
        errcode = result.get("errcode")
        data = result.get("data")
        size = len(json.dumps(data, ensure_ascii=False)) if data is not None else 0
        rows.append((full, method, "errcode=%s" % errcode, "data_bytes=%d" % size, os.path.basename(path)))

    print("%-58s %-6s %-16s %-18s %s" % ("PATH", "METHOD", "RESULT", "DETAIL", "ENTRY"))
    bad = 0
    for full, method, status, detail, name in rows:
        flag = "" if status == "errcode=0" else "   <== "
        if flag:
            bad += 1
        print("%-58s %-6s %-16s %-18s %s%s" % (full, method, status, detail, name, flag))
    print("\n总条目 %d, 非 errcode=0 的 %d" % (len(rows), bad))


if __name__ == "__main__":
    main()
