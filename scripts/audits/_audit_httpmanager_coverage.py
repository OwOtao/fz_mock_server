# -*- coding: utf-8 -*-
"""客户端 Http 层接口清单 vs mock_server 路由表 覆盖审计。

审查对象: fzjh_lua/assets/src/app/extends/Http/ (接口清单全部位于 HttpManager.lua)
对照对象: server.ROUTES (由 handlers/*.py 的 @route 装饰器注册)

口径要点 (详见 docs/httpmanager_coverage_audit.md):
  * 先剥离 Lua 注释, 只统计真实生效的请求 (注释里的旧接口不算);
  * DOMAIN .. <expr> 扫描覆盖任意参数位置与跨行写法, 支持局部变量与动态尾巴;
  * 覆盖判定与 server.match_route 完全一致: 先精确匹配, 再最长前缀匹配;
  * 近名路由 (add_currency vs add_currency_number) 只提示人工复核, 不折算为已实现。

用法:
    python _audit_httpmanager_coverage.py
    python _audit_httpmanager_coverage.py --json out.json
    python _audit_httpmanager_coverage.py --appendix-md appendix.md
"""

import argparse
import collections
import datetime
import glob
import io
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

CLIENT_APP = os.path.join(ROOT, "fzjh_lua", "assets", "src", "app")
HTTP_DIR = os.path.join(CLIENT_APP, "extends", "Http")
HTTP_FILES = ("HttpManager.lua", "BaseHttp.lua", "Http.lua", "HttpListManager.lua")

HAR_DIRS = ("har_decrypt_91", "har_decrypt_99", "har_decrypt_910_temp")

API_PREFIXES = ("api/v5/", "api/service_android/", "api/service/")

# 家族规则: 顺序敏感, 先匹配先归属
FAMILY_RULES = (
    ("crontab/后台任务", r"^crontab|^cala"),
    ("test/调试接口", r"^test|^init_test|^clean_test"),
    ("fight/比武PVP副本", r"fight|watch|biwu|pvp|challenge|fuben|bidding|egg|characterPool|chanllenge"),
    ("zhao/参悟", r"zhao|insight|fuse"),
    ("talent/天赋", r"talent"),
    ("dream/梦想世界", r"dream"),
    ("lottery/抽奖", r"lottery"),
    ("treasury/宝库", r"treasury|warehouse"),
    ("sutra/藏经阁", r"sutra"),
    ("meridian/经脉破境", r"meridian|acupoint|thoroughfare|break_through_realm"),
    ("mask/面谱", r"mask"),
    ("ui_theme/主题皮肤", r"ui_theme"),
    ("viewing/观战大厅", r"viewing"),
    ("anniversary/周年庆", r"anniversary|zhounian"),
    ("qixi/七夕", r"qixi"),
    ("boat/龙舟端午", r"boat|duanwu"),
    ("exam/科举考试", r"exam"),
    ("activity/活动玩法", r"activity|festival|equinox|newdaily|daily|spring|toast|menu|yuandan|seventh|xianshilibao"),
    ("trial/历练奇遇", r"wumen|expel_nian|trial|incident"),
    ("book/书籍武学", r"book|technique|skill|affix|martial|practice"),
    ("intelligence/情报", r"intelligence"),
    ("spend/消费回馈", r"spend|voucher"),
    ("sachet/香囊", r"sachet"),
    ("inheritance/传承转世", r"chuanchen|inherit|nextRole"),
    ("official/官职功勋", r"guanzhi|official|zhengji|fenlu|prestige|devote"),
    ("record/记录上报", r"record|log|incident"),
    ("order/订单交易", r"^get_order_id|rollback_order|roll_back_exchange|set_product_mark"),
    ("merchant/商人交易", r"merchant|trader|chapman|diy_|detection_goods|npc_"),
    ("land/家园地皮", r"land|homeland|home_|homebw|room|affair|furniture|homegate"),
    ("menpai/门派帮派", r"menpai|family|sect"),
    ("teacher/师门任务", r"teacher|zhipai|respect|guidance"),
    ("reward/奖励领取", r"reward|^receive_|^claim_|^roll_|^give_|^get_gift$|^gift_"),
    ("attribute/属性加点", r"attribute|config_times|config_point|successRate"),
    ("currency/货币元宝", r"currency|mingbi|yinpiao|yuanbao|yueka|mingtie|money_ceiling"),
    ("wish/心愿", r"wish"),
    ("gift/社交赠礼", r"gift|intimacy|jhsanyou|friend|single|answer|vote"),
    ("task/任务链", r"task|guide|type_point|numrsper"),
    ("ckitems/仓库", r"ckitems"),
    ("shop/商城道具", r"^buy_|^use_|^exchange_|store|shop|goods|item|prop|box|storage|special_item|danqing|smithy"),
    ("weapon/装备神兵", r"weapon|shenbing"),
    ("user/角色存档", r"^get_user|^upload_user|^save_user|^update_user|userdata|partition|archive|^upload_|api_data|data_state|map|logout|^delete_|^del_|^clear_|^set_|^add_|^finish_|^start_|^cancel_|^refresh_|^check_|^get_|^up_|^upgrade_|^update_"),
)

REVERB_STEM = (
    (re.compile(r"_\d+$"), ""),
    (re.compile(r"_number$"), ""),
    (re.compile(r"2$"), ""),
    (re.compile(r"_2$"), ""),
)


def read_text(path):
    with io.open(path, encoding="utf-8", errors="replace") as handle:
        return handle.read()


def strip_lua_comments(text):
    """去掉 --[[ ... ]] 块注释与 -- 行注释尾巴(引号感知, 不误伤字符串)。"""
    out = []
    i = 0
    n = len(text)
    while i < n:
        ch = text[i]
        if ch in "\"'":
            quote = ch
            j = i + 1
            while j < n:
                if text[j] == "\\":
                    j += 2
                    continue
                if text[j] == quote or text[j] == "\n":
                    break
                j += 1
            out.append(text[i:j])
            i = j
            continue
        if text.startswith("--[[", i):
            end = text.find("]]", i + 4)
            i = n if end < 0 else end + 2
            continue
        if text.startswith("--", i):
            end = text.find("\n", i)
            i = n if end < 0 else end
            continue
        out.append(ch)
        i += 1
    return "".join(out)


FUNC_RE = re.compile(r"^function\s+HttpManager:([A-Za-z_][A-Za-z0-9_]*)\s*\(", re.M)
DOMAIN_RE = re.compile(r"DOMAIN\s*\.\.\s*(\"(?:[^\"\\]|\\.)*\"|[A-Za-z_][A-Za-z0-9_]*)")
LOCAL_STR_RE = re.compile(r"(?:local\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*\"([^\"\n]*)\"")
VERB_RE = re.compile(r"retry(Get|Post)WithHeader")


def split_functions(text):
    """按函数定义切块, 返回 [(name, body)]; 重名定义各自成块。"""
    marks = [(m.start(), m.group(1)) for m in FUNC_RE.finditer(text)]
    blocks = []
    for idx, (start, name) in enumerate(marks):
        end = marks[idx + 1][0] if idx + 1 < len(marks) else len(text)
        blocks.append((name, text[start:end]))
    return blocks


def verb_before(body, position):
    """取 DOMAIN .. 表达式之前最近一次 retryGet/PostWithHeader 的动词。"""
    verb = None
    for match in VERB_RE.finditer(body):
        if match.start() > position:
            break
        verb = match.group(1).upper()
    return verb


def parse_endpoints(text):
    """解析 HttpManager.lua, 返回 (rows, local_methods, unresolved)。

    rows: [{"method","endpoint","verb"}] —— 同一函数多分支请求会产出多行。
    """
    rows = []
    local_methods = []
    unresolved = []
    for name, body in split_functions(text):
        locals_ = dict(LOCAL_STR_RE.findall(body))
        found = False
        for match in DOMAIN_RE.finditer(body):
            token = match.group(1)
            if token.startswith('"'):
                endpoint = token[1:-1]
            elif token in locals_:
                endpoint = locals_[token]
            else:
                unresolved.append((name, token))
                continue
            endpoint = endpoint.strip()
            if not endpoint:
                continue
            found = True
            rows.append({
                "method": name,
                "endpoint": endpoint,
                "verb": verb_before(body, match.start()),
            })
        if not found:
            local_methods.append(name)
    return rows, local_methods, unresolved


def normalize(endpoint):
    value = endpoint.strip().strip("/")
    for prefix in API_PREFIXES:
        if prefix in value:
            value = value.split(prefix)[-1]
    return value.strip("/")


def load_routes():
    if ROOT not in sys.path:
        sys.path.insert(0, ROOT)
    import handlers  # noqa: F401  导入即注册全部 @route
    from server import ROUTES
    return ROUTES


def match_coverage(endpoint, routes):
    """与 server.match_route 同语义: 精确 -> 最长前缀。"""
    key = normalize(endpoint)
    if key in routes:
        return key, "exact"
    parts = key.split("/")
    for i in range(len(parts) - 1, 0, -1):
        candidate = "/".join(parts[:i])
        if candidate in routes:
            return candidate, "prefix"
    return None, None


DEF_LINE_RE = re.compile(r"^\s*function\s+HttpManager(?:Ex)?\s*[:.]")
CALL_RE = re.compile(r"HttpManager(?:Ex)?:([A-Za-z_][A-Za-z0-9_]*)\s*\(")


def collect_call_sites(src_root=None):
    """统计 Http 层以外对 HttpManager/HttpManagerEx 方法的调用点数量与文件。"""
    src_root = src_root or CLIENT_APP
    http_dir = os.path.normpath(HTTP_DIR)
    calls = collections.Counter()
    files = collections.defaultdict(set)
    for base, dirs, names in os.walk(src_root):
        norm_base = os.path.normpath(base)
        if norm_base == http_dir or norm_base.startswith(http_dir + os.sep):
            continue
        for filename in names:
            if not filename.endswith(".lua"):
                continue
            path = os.path.join(base, filename)
            text = read_text(path)
            text = "\n".join(
                line for line in text.split("\n") if not DEF_LINE_RE.match(line))
            rel = os.path.relpath(path, src_root).replace("\\", "/")
            for match in CALL_RE.finditer(text):
                calls[match.group(1)] += 1
                files[match.group(1)].add(rel)
    return {name: (calls[name], sorted(files[name])) for name in calls}


HAR_URL_RE = re.compile(r"^[a-zA-Z]+://([^/]+)(/.*)$")


def har_presence(har_dirs=None):
    """返回 {"segments": {首段: 次数}, "paths": {路径: 次数}, "sources": {目录: 条数}}。"""
    segments = collections.Counter()
    paths = collections.Counter()
    sources = {}
    dirs = har_dirs if har_dirs is not None else [os.path.join(ROOT, "so", d) for d in HAR_DIRS]
    for har_dir in dirs:
        entries = sorted(glob.glob(os.path.join(har_dir, "entries", "*.json")))
        sources[os.path.basename(os.path.normpath(har_dir))] = len(entries)
        for entry_path in entries:
            try:
                entry = json.loads(read_text(entry_path))
            except ValueError:
                continue
            match = HAR_URL_RE.match(entry.get("url") or "")
            if not match or "android.fzjh" not in match.group(1):
                continue
            full = match.group(2).split("?")[0]
            key = normalize(full)
            if not key:
                continue
            paths[key] += 1
            segments[key.split("/")[0]] += 1
    return {"segments": segments, "paths": paths, "sources": sources}


def har_hit(endpoint, har):
    key = normalize(endpoint)
    if key in har["paths"]:
        return har["paths"][key]
    return har["segments"].get(key.split("/")[0], 0)


def classify_family(endpoint):
    key = normalize(endpoint)
    for family, pattern in FAMILY_RULES:
        if re.search(pattern, key):
            return family
    return "other/其它"


def stem(endpoint):
    key = normalize(endpoint).split("/")[0]
    for pattern, repl in REVERB_STEM:
        new = pattern.sub(repl, key)
        if new != key:
            key = new
            break
    return key


def find_alias_candidates(missing_endpoints, routes):
    """近名路由提示: 缺失接口与已注册路由共享词干/前缀, 但语义未必相同。"""
    out = []
    for endpoint in missing_endpoints:
        key = normalize(endpoint)
        head = key.split("/")[0]
        head_stem = stem(key)
        for route in routes:
            if route == key:
                continue
            route_head = route.split("/")[0]
            if route_head == head:
                continue
            if stem(route) == head_stem or route_head.startswith(head + "_") \
                    or head.startswith(route_head + "_"):
                out.append((key, route))
    return out


def collect_comment_only(raw_text, cleaned_text):
    """只在注释里出现、剥离后消失的接口, 供人工复核。"""
    def endpoints(text):
        found = set()
        for match in re.finditer(r"DOMAIN\s*\.\.\s*\"([^\"]+)\"", text):
            found.add(match.group(1).strip("/"))
        return found
    return sorted(endpoints(raw_text) - endpoints(cleaned_text))


def build_report():
    routes = load_routes()
    calls = collect_call_sites()
    har = har_presence()

    per_file = {}
    raw_texts = {}
    rows = []
    local_methods = []
    unresolved = []
    for filename in HTTP_FILES:
        path = os.path.join(HTTP_DIR, filename)
        if not os.path.isfile(path):
            per_file[filename] = {"exists": False, "functions": 0, "endpoints": 0}
            continue
        raw = read_text(path)
        raw_texts[filename] = raw
        cleaned = strip_lua_comments(raw)
        file_rows, file_local, file_unresolved = parse_endpoints(cleaned)
        per_file[filename] = {
            "exists": True,
            "functions": len(split_functions(cleaned)),
            "endpoints": len({normalize(r["endpoint"]) for r in file_rows}),
        }
        rows.extend(file_rows)
        local_methods.extend(file_local)
        unresolved.extend(file_unresolved)

    methods = {}
    for row in rows:
        methods.setdefault(row["method"], []).append(normalize(row["endpoint"]))

    endpoint_map = {}
    verb_map = collections.defaultdict(set)
    for row in rows:
        key = normalize(row["endpoint"])
        endpoint_map.setdefault(key, set()).add(row["method"])
        verb_map[key].add(row["verb"] or "?")

    def verb_of(key):
        return "/".join(sorted(verb_map.get(key) or {"?"}))

    exact, prefix, missing = [], [], []
    for endpoint in sorted(endpoint_map):
        hit, kind = match_coverage(endpoint, routes)
        entry = {
            "endpoint": endpoint,
            "verb": verb_of(endpoint),
            "hit": hit,
            "methods": sorted(endpoint_map[endpoint]),
            "family": classify_family(endpoint),
            "har": har_hit(endpoint, har),
        }
        if kind == "exact":
            exact.append(entry)
        elif kind == "prefix":
            prefix.append(entry)
        else:
            methods_hit = sorted(endpoint_map[endpoint])
            calls_total = sum(calls.get(name, (0, []))[0] for name in methods_hit)
            call_files = set()
            for name in methods_hit:
                call_files.update(calls.get(name, (0, []))[1])
            entry["calls"] = calls_total
            entry["files"] = sorted(call_files)
            missing.append(entry)

    hit_routes = {entry["hit"] for entry in exact + prefix}
    reverse = sorted(route for route in routes if route not in hit_routes)

    families = collections.defaultdict(list)
    for entry in missing:
        families[entry["family"]].append(entry)

    family_rows = []
    for family, items in sorted(families.items(), key=lambda kv: (-len(kv[1]), kv[0])):
        family_rows.append({
            "family": family,
            "count": len(items),
            "endpoints": [item["endpoint"] for item in sorted(items, key=lambda x: x["endpoint"])],
        })

    aliases = find_alias_candidates([entry["endpoint"] for entry in missing], routes)
    comment_only = collect_comment_only(
        raw_texts.get("HttpManager.lua", ""),
        strip_lua_comments(raw_texts.get("HttpManager.lua", "")),
    )

    return {
        "generated_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "client_files": per_file,
        "routes_total": len(routes),
        "methods_total": len(split_functions(strip_lua_comments(raw_texts.get("HttpManager.lua", "")))),
        "methods_with_endpoint": len(methods),
        "endpoints_total": len(endpoint_map),
        "exact": exact,
        "prefix": prefix,
        "missing": missing,
        "families": family_rows,
        "reverse": reverse,
        "aliases": aliases,
        "comment_only": comment_only,
        "local_methods": sorted(set(local_methods)),
        "unresolved": sorted(set(unresolved)),
        "har_sources": har["sources"],
        "har_endpoints": sorted(har["segments"]),
        "reachable_missing": [entry for entry in missing if entry["calls"] > 0],
        "unreachable_missing": [entry for entry in missing if entry["calls"] == 0],
    }


def render_stdout(report):
    """默认口径的结论放在最前面, 供报告直接引用。"""
    lines = []
    add = lines.append
    add("客户端 Http 层接口覆盖审计")
    add("生成时间: %s" % report["generated_at"])
    add("")
    add("== 扫描文件 ==")
    for filename, info in sorted(report["client_files"].items()):
        if not info["exists"]:
            add("  %-22s 缺失" % filename)
        else:
            add("  %-22s 函数 %-5d 接口 %d" % (filename, info["functions"], info["endpoints"]))
    add("")
    add("== 总量 ==")
    add("  HttpManager 函数总数        : %d" % report["methods_total"])
    add("  含接口的函数数              : %d" % report["methods_with_endpoint"])
    add("  客户端唯一接口              : %d" % report["endpoints_total"])
    add("  mock 路由表                 : %d" % report["routes_total"])
    add("  精确命中                    : %d" % len(report["exact"]))
    add("  前缀命中                    : %d" % len(report["prefix"]))
    add("  未实现                      : %d" % len(report["missing"]))
    add("    其中客户端有调用点        : %d" % len(report["reachable_missing"]))
    add("    其中客户端无调用点        : %d" % len(report["unreachable_missing"]))
    add("  未实现且在抓包中出现        : %d" % len([e for e in report["missing"] if e["har"]]))
    add("")
    add("== 抓包来源 ==")
    for name, count in sorted(report["har_sources"].items()):
        add("  %-22s %d 条" % (name, count))
    add("  抓包中的游戏接口            : %d" % len(report["har_endpoints"]))
    add("")
    add("== 家族分布(未实现降序) ==")
    add("  %-4s %-20s %s" % ("数量", "家族", "代表接口"))
    add("  " + "-" * 100)
    for row in report["families"]:
        add("  %-4d %-20s %s" % (row["count"], row["family"],
                               ", ".join(row["endpoints"][:4])))
    add("")
    add("== 前缀命中(需人工确认参数级实现) ==")
    for entry in report["prefix"]:
        add("  %-42s -> %s" % (entry["endpoint"], entry["hit"]))
    add("")
    add("== 反方向: 路由表中无客户端入口 ==")
    for route in report["reverse"]:
        add("  %s" % route)
    add("")
    add("== 别名复核候选(不折算为已实现) ==")
    for endpoint, route in report["aliases"]:
        add("  %-42s ~ %s" % (endpoint, route))
    add("")
    add("== 仅存在于注释中的旧接口 ==")
    for endpoint in report["comment_only"]:
        add("  %s" % endpoint)
    add("")
    add("== 无 URL 的客户端本地方法 ==")
    add("  " + ", ".join(report["local_methods"]))
    add("")
    add("== 未实现清单 ==")
    add("  %-44s %-5s %-30s %-6s %-4s" % ("接口", "方法", "客户端方法", "调用点", "HAR"))
    add("  " + "-" * 96)
    for entry in sorted(report["missing"], key=lambda x: x["endpoint"]):
        add("  %-44s %-5s %-30s %-6d %-4d" % (
            entry["endpoint"], entry["verb"], ",".join(entry["methods"])[:30],
            entry["calls"], entry["har"]))
    if report["unresolved"]:
        add("")
        add("== 未能解析的 DOMAIN 表达式(需人工确认) ==")
        for name, token in report["unresolved"]:
            add("  %s -> %s" % (name, token))
    return "\n".join(lines)


def render_appendix_md(report):
    lines = []
    add = lines.append
    add("> 本附录由 `_audit_httpmanager_coverage.py --appendix-md` 于 %s 生成, 请勿手改。"
        % report["generated_at"])
    add("")
    add("### A.1 总量")
    add("")
    add("| 项 | 值 |")
    add("| --- | --- |")
    add("| HttpManager 函数总数 | %d |" % report["methods_total"])
    add("| 含接口的函数数 | %d |" % report["methods_with_endpoint"])
    add("| 客户端唯一接口 | %d |" % report["endpoints_total"])
    add("| mock 路由表 | %d |" % report["routes_total"])
    add("| 精确命中 | %d |" % len(report["exact"]))
    add("| 前缀命中 | %d |" % len(report["prefix"]))
    add("| **未实现** | **%d** |" % len(report["missing"]))
    add("| 未实现且在抓包中出现 | %d |" % len([e for e in report["missing"] if e["har"]]))
    add("")
    add("### A.2 家族分布")
    add("")
    add("| 家族 | 未实现 | 代表接口 |")
    add("| --- | --- | --- |")
    for row in report["families"]:
        add("| %s | %d | %s |" % (row["family"], row["count"],
                                  ", ".join("`%s`" % e for e in row["endpoints"][:4])))
    add("")
    add("### A.3 全量未实现清单(按家族)")
    add("")
    add("| 接口 | HTTP | 客户端方法 | 调用点 | 抓包 |")
    add("| --- | --- | --- | --- | --- |")
    for row in report["families"]:
        for entry in sorted(row["endpoints"]):
            item = next(e for e in report["missing"] if e["endpoint"] == entry)
            add("| `%s` | %s | %s | %d | %s |" % (
                entry,
                item["verb"],
                ", ".join(item["methods"]),
                item["calls"],
                item["har"] if item["har"] else "-"))
    add("")
    add("### A.4 前缀命中清单(参数级实现需人工确认)")
    add("")
    add("| 客户端接口 | 命中路由 |")
    add("| --- | --- |")
    for entry in report["prefix"]:
        add("| `%s` | `%s` |" % (entry["endpoint"], entry["hit"]))
    add("")
    add("### A.5 反方向: 路由表中无客户端入口")
    add("")
    for route in report["reverse"]:
        add("- `%s`" % route)
    add("")
    add("### A.6 别名复核候选")
    add("")
    add("| 客户端缺失接口 | 近名已注册路由 |")
    add("| --- | --- |")
    for endpoint, route in report["aliases"]:
        add("| `%s` | `%s` |" % (endpoint, route))
    add("")
    add("### A.7 仅存在于注释中的旧接口")
    add("")
    for endpoint in report["comment_only"]:
        add("- `%s`" % endpoint)
    add("")
    add("### A.8 未被任何其它客户端 Lua 调用的缺失接口")
    add("")
    add("| 接口 | 客户端方法 |")
    add("| --- | --- |")
    for entry in sorted(report["unreachable_missing"], key=lambda x: x["endpoint"]):
        add("| `%s` | %s |" % (entry["endpoint"], ", ".join(entry["methods"])))
    return "\n".join(lines)


def main(argv=None):
    parser = argparse.ArgumentParser(description="HttpManager 覆盖审计")
    parser.add_argument("--json", dest="json_path", help="写出机器可读结果")
    parser.add_argument("--appendix-md", dest="appendix_path", help="写出 markdown 附录")
    args = parser.parse_args(argv)

    for filename in ("HttpManager.lua",):
        if not os.path.isfile(os.path.join(HTTP_DIR, filename)):
            sys.stderr.write("缺少客户端源码: %s\n" % os.path.join(HTTP_DIR, filename))
            return 2

    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8")

    report = build_report()
    print(render_stdout(report))

    if args.json_path:
        with io.open(args.json_path, "w", encoding="utf-8") as handle:
            json.dump(report, handle, ensure_ascii=False, indent=2, default=list)
        print("\n[json] %s" % args.json_path)

    if args.appendix_path:
        with io.open(args.appendix_path, "w", encoding="utf-8") as handle:
            handle.write(render_appendix_md(report))
        print("[appendix] %s" % args.appendix_path)

    return 0


if __name__ == "__main__":
    sys.exit(main())
