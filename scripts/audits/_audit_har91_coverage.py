# -*- coding: utf-8 -*-
"""审查 so/har_decrypt_91 抓包中尚未在 mock_server 注册的接口（排除第三方 SDK）。

用法: python _audit_har91_coverage.py
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ENTRY_DIR = os.path.join(ROOT, "so", "har_decrypt_91", "entries")

sys.path.insert(0, ROOT)

# 第三方 SDK / 非游戏后端域名特征
THIRD_PARTY_HOSTS = (
    "log-api", "alog", "toblog", "apmplus", "api-access", "webcast-open",
    "mcs.zijieapi", "mssdk", "vcs", "abtest", "tnc0-alisc1", "uop",
    "sf6-fe-tos", "lf-cdn-tos", "snssdk", "log", "mon", "rtlog", "dig",
)

GAME_PATH_RE = re.compile(r"/api/(?:v5|service|service_android|service_ios)/")
UPDATE_PATH_RE = re.compile(r"/(?:update/v1|api/v5)/(?:checkUpdate|getMd5List|get_game_config|exchange_publickey|report_ads_info|get_version_info)")


def load_routes():
    import handlers  # noqa: F401  触发路由注册
    from server import ROUTES
    return ROUTES


def match(path, routes):
    """复刻 server.match_route：先精确再最长前缀。"""
    key = path.strip("/")
    for prefix in ("api/v5/", "api/"):
        if key.startswith(prefix):
            key = key[len(prefix):]
            break
    key = key.strip("/")
    if key in routes:
        return key
    parts = key.split("/")
    for i in range(len(parts) - 1, 0, -1):
        cand = "/".join(parts[:i])
        if cand in routes:
            return cand
    return None


def main():
    routes = load_routes()
    entries = []
    for path in sorted(glob.glob(os.path.join(ENTRY_DIR, "*.json"))):
        with open(path, "r", encoding="utf-8") as handle:
            data = json.load(handle)
        url = data.get("url") or ""
        m = re.match(r"^[a-zA-Z]+://([^/]+)(/.*)$", url)
        host = m.group(1) if m else ""
        full = (m.group(2) if m else url).split("?")[0]
        entries.append({
            "file": os.path.basename(path),
            "index": data.get("index"),
            "method": data.get("method"),
            "status": data.get("status"),
            "host": host,
            "path": full,
        })

    print("抓包条目: %d, 已注册路由: %d" % (len(entries), len(routes)))

    game, third = [], []
    for e in entries:
        is_third = any(t in e["host"] for t in THIRD_PARTY_HOSTS) or not GAME_PATH_RE.search(e["path"])
        (third if is_third else game).append(e)

    print("游戏后端条目: %d, 第三方/静态条目: %d" % (len(game), len(third)))

    # 按 path 去重，保留出现次数与方法集合
    seen = {}
    for e in game:
        rec = seen.setdefault(e["path"], {"methods": set(), "count": 0, "index": e["index"], "file": e["file"], "status": e["status"]})
        rec["methods"].add(e["method"])
        rec["count"] += 1

    covered, partial, missing = [], [], []
    for path in sorted(seen):
        name = re.sub(r"^/api/(?:v5|service_android|service)/", "", path)
        hit = match(path, routes)
        if hit is None:
            missing.append((path, seen[path]))
        elif hit == name.strip("/"):
            covered.append((path, hit, seen[path]))
        else:
            partial.append((path, hit, seen[path]))

    print("\n=== 已实现 (%d) ===" % len(covered))
    for path, hit, rec in covered:
        print("  OK      %-6s x%-3d %s" % ("/".join(sorted(rec["methods"])), rec["count"], path))

    print("\n=== 前缀命中但可能需参数处理 (%d) ===" % len(partial))
    for path, hit, rec in partial:
        print("  PREFIX  %-6s x%-3d %s  ->  %s" % ("/".join(sorted(rec["methods"])), rec["count"], path, hit))

    print("\n=== 未实现 (%d) ===" % len(missing))
    for path, rec in missing:
        print("  MISSING %-6s x%-3d status=%s  %s   [entry %s]" % (
            "/".join(sorted(rec["methods"])), rec["count"], rec["status"], path, rec["file"]))


if __name__ == "__main__":
    main()
