# -*- coding: utf-8 -*-
"""_audit_httpmanager_coverage.py 的提取/判定口径测试。

只断言不变量与固定锚点, 不断言易随客户端热更漂移的总数。
"""

import os
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

# 审计脚本已归入 scripts/audits/
_AUDITS_DIR = os.path.join(ROOT, "scripts", "audits")
if _AUDITS_DIR not in sys.path:
    sys.path.insert(0, _AUDITS_DIR)

import _audit_httpmanager_coverage as audit  # noqa: E402


FIXTURE = '''
function HttpManager:demoGet(callback)
    self:retryGetWithHeader(DOMAIN .. "demo_get/1", nil, nil, callback)
end

-- function HttpManager:demoOld(callback)
--     self:retryGetWithHeader(DOMAIN .. "demo_old", nil, nil, callback)
-- end

function HttpManager:demoComment(callback)
    -- self:retryPostWithHeader(DOMAIN .. "demo_comment", nil, nil, callback)
    self:retryPostWithHeader(DOMAIN .. "demo_real", nil, nil, callback)
end

--[[
function HttpManager:demoBlock(callback)
    self:retryGetWithHeader(DOMAIN .. "demo_block", nil, nil, callback)
end
]]

function HttpManager:demoLocalVar(callback)
    local url = "upload_user_file_3"
    url = url .. "/" .. tostring(1)
    self:retryPostWithHeaderAndWaitText(waitText, DOMAIN .. url, {table}, nil, callback)
end

function HttpManager:demoDynamic(ptype, callback)
    self:retryPostWithHeader(DOMAIN .. "get_board/" .. tostring(ptype), {}, nil, callback)
end

function HttpManager:demoLocalOnly()
    return 1
end

function HttpManager:demoTwoBranches(flag, callback)
    if flag then
        self:retryPostWithHeader(DOMAIN .. "get_reward_2/1", {}, nil, callback)
    else
        self:retryPostWithHeader(DOMAIN .. "get_reward_2/2", {}, nil, callback)
    end
    -- 字符串里的注释符号不应截断
    local note = "a -- b"
    return note
end

function HttpManager:demoNoisyPrint(callback)
    local cheatType = getCheatType()
    if PRINT_MODE == 1 then
        print("cheatType = " .. tostring(cheatType))
    end
    local url = "demo_noisy_target"
    self:retryPostWithHeader(DOMAIN .. url, {}, nil, callback)
end
'''


class StripCommentsTest(unittest.TestCase):
    def test_removes_line_and_block_comments(self):
        cleaned = audit.strip_lua_comments(FIXTURE)
        self.assertNotIn("demo_old", cleaned)
        self.assertNotIn("demo_comment", cleaned)
        self.assertNotIn("demo_block", cleaned)

    def test_keeps_real_calls(self):
        cleaned = audit.strip_lua_comments(FIXTURE)
        for endpoint in ("demo_get/1", "demo_real", "upload_user_file_3",
                         "get_board/", "get_reward_2/1", "get_reward_2/2"):
            self.assertIn(endpoint, cleaned)

    def test_does_not_cut_string_literal_content(self):
        cleaned = audit.strip_lua_comments('local note = "a -- b"\nprint(note)\n')
        self.assertIn('"a -- b"', cleaned)


class ParseEndpointsTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cleaned = audit.strip_lua_comments(FIXTURE)
        cls.rows, cls.local_methods, cls.unresolved = audit.parse_endpoints(cleaned)
        cls.by_method = {}
        for row in cls.rows:
            cls.by_method.setdefault(row["method"], []).append(row)

    def test_ignores_endpoints_only_present_in_comments(self):
        endpoints = {row["endpoint"] for row in self.rows}
        self.assertNotIn("demo_old", endpoints)
        self.assertNotIn("demo_comment", endpoints)
        self.assertNotIn("demo_block", endpoints)
        self.assertIn("demo_real", endpoints)

    def test_resolves_local_variable_with_trailing_arguments(self):
        rows = self.by_method["demoLocalVar"]
        self.assertEqual(["upload_user_file_3"], [row["endpoint"] for row in rows])
        self.assertEqual("POST", rows[0]["verb"])

    def test_keeps_literal_prefix_of_dynamic_tail(self):
        rows = self.by_method["demoDynamic"]
        self.assertEqual(["get_board/"], [row["endpoint"] for row in rows])
        self.assertEqual("POST", rows[0]["verb"])

    def test_records_verb_from_call(self):
        self.assertEqual("GET", self.by_method["demoGet"][0]["verb"])

    def test_collects_all_branches(self):
        endpoints = sorted(row["endpoint"] for row in self.by_method["demoTwoBranches"])
        self.assertEqual(["get_reward_2/1", "get_reward_2/2"], endpoints)

    def test_local_variable_survives_earlier_string_assignments(self):
        # 回归: print("cheatType = " .. x) 里的 `name = "` 曾让变量表跨行串味
        rows = self.by_method["demoNoisyPrint"]
        self.assertEqual(["demo_noisy_target"], [row["endpoint"] for row in rows])

    def test_methods_without_request_are_listed_separately(self):
        self.assertNotIn("demoLocalOnly", self.by_method)
        self.assertIn("demoLocalOnly", self.local_methods)

    def test_no_unresolved_expressions(self):
        self.assertEqual([], self.unresolved)


class NormalizeAndMatchTest(unittest.TestCase):
    def test_normalize_strips_api_prefixes_and_slashes(self):
        self.assertEqual("login", audit.normalize("/api/v5/login"))
        self.assertEqual("get_uuid", audit.normalize("api/service_android/get_uuid"))
        self.assertEqual("exchange_publickey", audit.normalize("api/service/exchange_publickey/"))

    def test_exact_match(self):
        routes = {"login": object()}
        self.assertEqual(("login", "exact"), audit.match_coverage("login", routes))

    def test_longest_prefix_match(self):
        routes = {"get_board": object()}
        self.assertEqual(("get_board", "prefix"), audit.match_coverage("get_board/1", routes))

    def test_longest_prefix_wins(self):
        routes = {"buy_goods": object(), "buy_goods_3": object()}
        self.assertEqual(("buy_goods_3", "exact"), audit.match_coverage("buy_goods_3", routes))

    def test_missing_endpoint_returns_none(self):
        self.assertEqual((None, None), audit.match_coverage("accept_task", {"login": object()}))


class FamilyTest(unittest.TestCase):
    def test_known_families(self):
        self.assertEqual("zhao/参悟", audit.classify_family("zhao_practice"))
        self.assertEqual("test/调试接口", audit.classify_family("test_wish"))
        self.assertEqual("qixi/七夕", audit.classify_family("get_qixi_board"))
        self.assertEqual("land/家园地皮", audit.classify_family("move_home_land"))

    def test_unknown_endpoint_falls_back(self):
        self.assertEqual("other/其它", audit.classify_family("zzz_unknown_zzz"))


class AliasCandidateTest(unittest.TestCase):
    def test_flags_near_name_route(self):
        pairs = audit.find_alias_candidates(["add_currency"], {"add_currency_number": object()})
        self.assertIn(("add_currency", "add_currency_number"), pairs)

    def test_does_not_flag_unrelated_route(self):
        pairs = audit.find_alias_candidates(["accept_task"], {"login": object()})
        self.assertEqual([], pairs)


class HarPresenceTest(unittest.TestCase):
    def test_missing_directory_degrades(self):
        har = audit.har_presence([os.path.join(ROOT, "so", "no_such_har_dir")])
        self.assertEqual({}, dict(har["segments"]))
        self.assertEqual(0, audit.har_hit("accept_task", har))


class RealFileTest(unittest.TestCase):
    """锚点断言: 客户端文件结构或路由表大改时才应失败。"""

    @classmethod
    def setUpClass(cls):
        cls.report = audit.build_report()

    def test_http_layer_endpoints_live_in_httpmanager_only(self):
        for filename in ("BaseHttp.lua", "Http.lua", "HttpListManager.lua"):
            self.assertEqual(0, self.report["client_files"][filename]["endpoints"], filename)

    def test_partition_invariant(self):
        report = self.report
        self.assertEqual(report["endpoints_total"],
                         len(report["exact"]) + len(report["prefix"]) + len(report["missing"]))

    def test_known_implemented_endpoints_are_covered(self):
        covered = {entry["endpoint"]: entry["hit"] for entry in
                   self.report["exact"] + self.report["prefix"]}
        for endpoint, route in (("login", "login"),
                                ("get_time", "get_time"),
                                ("create_role", "create_role"),
                                ("upload_user_file_3", "upload_user_file_3"),
                                ("download_user_file_2", "download_user_file_2")):
            self.assertIn(endpoint, covered)
            self.assertEqual(route, covered[endpoint])

    def test_known_missing_endpoints_are_reported(self):
        missing = {entry["endpoint"] for entry in self.report["missing"]}
        for endpoint in ("accept_task", "get_task_info", "send_gift",
                         "can_watch_fight", "get_mask_list"):
            self.assertIn(endpoint, missing)

    def test_local_url_variables_resolve_to_real_routes(self):
        # 回归: LOCAL_STR_RE 跨行串味曾让这两个接口从清单里消失
        covered = {entry["endpoint"] for entry in
                   self.report["exact"] + self.report["prefix"]}
        self.assertIn("upload_user_file_3", covered)
        self.assertIn("upload_user_file_5", covered)
    def test_missing_endpoints_have_client_methods(self):
        for entry in self.report["missing"]:
            self.assertTrue(entry["methods"], entry["endpoint"])
            self.assertIn(entry["verb"], ("GET", "POST", "GET/POST", "?"))

    def test_vast_majority_of_client_endpoints_still_unimplemented(self):
        self.assertGreater(self.report["endpoints_total"], 600)
        self.assertLess(len(self.report["exact"]) + len(self.report["prefix"]),
                        self.report["endpoints_total"])
        self.assertGreater(len(self.report["missing"]), 300)


if __name__ == "__main__":
    unittest.main(verbosity=2)
