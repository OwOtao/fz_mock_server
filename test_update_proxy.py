import hashlib
import json
import os
import pathlib
import secrets
import shutil
import threading
import time
import unittest
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from unittest import mock

import config
import jm_crypto
from handlers import service
from server import create_server
from state import StateStore


class UpstreamHandler(BaseHTTPRequestHandler):
    request_path = None
    request_headers = None
    body = b"\x00\xffupdate\x80payload"
    valid_body = b"4a4848553032abcdef"
    md5_body = None

    def do_GET(self):
        type(self).request_path = self.path
        type(self).request_headers = {key.lower(): value for key, value in self.headers.items()}
        serve_md5 = bool(type(self).md5_body) and "md5list" in self.path.lower()
        status = 200 if ("valid200" in self.path or serve_md5) else 418
        if status == 200 and serve_md5:
            body = type(self).md5_body
        else:
            body = self.valid_body if status == 200 else self.body
        self.send_response(status)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("X-Upstream", "preserved")
        self.send_header("Connection", "X-Response-Hop")
        self.send_header("X-Response-Hop", "removed")
        self.send_header("Upgrade", "test")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass


class UpdateProxyTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.upstream = ThreadingHTTPServer(("127.0.0.1", 0), UpstreamHandler)
        cls.upstream_thread = threading.Thread(target=cls.upstream.serve_forever, daemon=True)
        cls.upstream_thread.start()
        cls.original_base = config.UPDATE_UPSTREAM_BASE
        config.UPDATE_UPSTREAM_BASE = "http://127.0.0.1:%d/v1" % cls.upstream.server_port
        cls.state = StateStore(autosave=False)
        cls.server = create_server("127.0.0.1", 0, state=cls.state)
        cls.server_thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.server_thread.start()
        cls.base_url = "http://127.0.0.1:%d/api/v1/" % cls.server.server_port

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.server_thread.join()
        cls.upstream.shutdown()
        cls.upstream.server_close()
        cls.upstream_thread.join()
        config.UPDATE_UPSTREAM_BASE = cls.original_base

    def fetch(self, path, headers=None):
        request = urllib.request.Request(self.base_url + path, headers=headers or {})
        try:
            return urllib.request.urlopen(request, timeout=3)
        except urllib.error.HTTPError as error:
            return error

    def test_preserves_status_bytes_headers_and_raw_query(self):
        captured_ctx = {}
        original_proxy = service._proxy_update_response

        def capture_proxy(ctx, endpoint):
            captured_ctx.update(ctx)
            return original_proxy(ctx, endpoint)

        with mock.patch.object(service, "_proxy_update_response", capture_proxy):
            response = self.fetch(
                "checkUpdate?x=a%2Fb&x=second&blank=&plus=a+b",
                {
                    "X-End-To-End": "removed",
                    "uuid": "device-id",
                    "Connection": "X-Request-Hop",
                    "X-Request-Hop": "removed",
                    "TE": "trailers",
                },
            )
        try:
            self.assertEqual(response.status, 418)
            self.assertEqual(response.read(), UpstreamHandler.body)
            self.assertEqual(response.headers["Content-Type"], "application/octet-stream")
            self.assertEqual(response.headers["X-Upstream"], "preserved")
            self.assertIsNone(response.headers.get("Connection"))
            self.assertIsNone(response.headers.get("X-Response-Hop"))
            self.assertIsNone(response.headers.get("Upgrade"))
        finally:
            response.close()
        self.assertEqual(
            captured_ctx["query_string"],
            "x=a%2Fb&x=second&blank=&plus=a+b",
        )
        self.assertEqual(
            UpstreamHandler.request_path,
            "/v1/checkUpdate?x=a%2Fb&x=second&blank=&plus=a+b",
        )
        self.assertEqual(UpstreamHandler.request_headers["uuid"], "device-id")
        self.assertNotIn("x-end-to-end", UpstreamHandler.request_headers)
        self.assertNotIn("x-request-hop", UpstreamHandler.request_headers)
        self.assertNotIn("te", UpstreamHandler.request_headers)

    def test_get_uuid_uses_bootstrap_encryption_group(self):
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/service_android/get_uuid"
            % self.server.server_port,
            headers={"uuid": "client-empty-value"},
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        self.assertTrue(body.startswith(jm_crypto.magic_hex("default")))
        payload = json.loads(
            jm_crypto.decrypt(body, group_name="default").decode("utf-8")
        )
        self.assertEqual(set(payload), {"errcode", "data"})
        self.assertEqual(payload["errcode"], 0)
        self.assertEqual(payload["data"]["uuid"], config.MOCK_DEVICE_UUID)
        self.assertNotIn("id", payload["data"])
        self.assertNotEqual(payload["data"]["uuid"], "client-empty-value")

    def test_get_activity_list_matches_har_payload(self):
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_activity_list" % self.server.server_port,
            data=jm_crypto.encrypt(
                json.dumps({"type": "all", "currencyVersion": 0}, separators=(",", ":")).encode("utf-8"),
                group_name="FZJH03",
            ).encode("utf-8"),
            headers={"Content-Type": "application/x-www-form-urlencoded"},
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8"))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["isClick"], "Y")
        self.assertEqual(result["data"]["isSign"], "N")
        self.assertEqual(len(result["data"]["list"]), 11)
        self.assertEqual(result["rand_t"], 1787731490.8493)

        userid = 778899
        expected = [{"id": "xuantiejian", "typeDesc": "长剑", "wanhaodu": 100}]
        self.state.put_archive(userid, {"shenBingItems": expected})
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_user_shenbings" % self.server.server_port,
            headers={"userid": str(userid)},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8"))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["shenBingItems"], expected)

        userid = 778899
        self.state.put_archive(userid, {
            "ckLimit": 66,
            "ckitems": [
                {"itemId": "menpaicanye4", "count": 2, "info": ""},
                {"itemId": "jingxinwan", "total": 3, "update_time": 9},
            ],
        })
        payload = jm_crypto.encrypt(
            json.dumps({"ckname": "xuanbingdong", "ver": 4}, separators=(",", ":")).encode("utf-8"),
            group_name="default",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_ckitems_list" % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "userid": str(userid),
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8"))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["ver"], 4)
        self.assertEqual(result["data"]["size"], 66)
        self.assertEqual(result["data"]["list"][0]["total"], 2)
        self.assertEqual(result["data"]["list"][1]["itemId"], "jingxinwan")

        payload = jm_crypto.encrypt(
            json.dumps(
                {"new_uuid": config.MOCK_DEVICE_UUID},
                separators=(",", ":"),
            ).encode("utf-8"),
            group_name="default",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/service_android/update_uuid"
            % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "uuid": "0000000055ce41f0ffffffffef05ac4a",
                "userid": "",
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        self.assertTrue(body.startswith(jm_crypto.magic_hex("default")))
        result = json.loads(
            jm_crypto.decrypt(body, group_name="default").decode("utf-8")
        )
        self.assertEqual(result, {"errcode": 0})

    def test_update_uuid_rejects_missing_or_wrong_uuid(self):
        for payload in ({}, {"new_uuid": "wrong"}):
            with self.subTest(payload=payload):
                encrypted = jm_crypto.encrypt(
                    json.dumps(payload, separators=(",", ":")).encode("utf-8"),
                    group_name="default",
                ).encode("utf-8")
                request = urllib.request.Request(
                    "http://127.0.0.1:%d/api/service_android/update_uuid"
                    % self.server.server_port,
                    data=encrypted,
                    headers={"Content-Type": "application/x-www-form-urlencoded"},
                    method="POST",
                )
                response = urllib.request.urlopen(request, timeout=3)
                try:
                    body = response.read().decode("utf-8")
                finally:
                    response.close()
                result = json.loads(
                    jm_crypto.decrypt(body, group_name="default").decode("utf-8")
                )
                self.assertEqual(result, {"errcode": 1})

    def test_upload_weapon_repair_log_returns_success(self):
        payload = jm_crypto.encrypt(
            json.dumps({
                "prev_local": [],
                "aft_local": [],
                "fix_local": [],
                "prev_xbd": [],
                "aft_xbd": [],
                "fix_xbd": [],
            }, separators=(",", ":")).encode("utf-8"),
            group_name="FZJH03",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/upload_weapon_repair_log" % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "userid": "778899",
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8"))
        self.assertEqual(result["errcode"], 0)
        self.assertTrue(result["data"]["ok"])

    def test_add_training_task_point_route_accepts_inactive_activity(self):
        userid = 778899
        payload = jm_crypto.encrypt(
            json.dumps(
                {"tid": "guaji", "taskList": []},
                separators=(",", ":"),
            ).encode("utf-8"),
            group_name="FZJH03",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/add_training_task_point"
            % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "userid": str(userid),
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["tid"], "guaji")
        self.assertFalse(result["data"]["accepted"])
        self.assertEqual(result["data"]["added_point"], 0)

    def test_store_main_tab_matches_capture_and_purchase_flow(self):
        userid = 779004
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_store_list_4"
            % self.server.server_port,
            headers={"userid": str(userid)},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        category = result["data"]["list"][1]
        self.assertEqual(category["classId"], "store_goods")
        self.assertEqual(category["name"], "商城")
        self.assertEqual(len(category["items"]), 11)
        self.assertEqual(category["items"][0]["itemId"], "xiyanshui")
        self.assertEqual(category["items"][0]["price"], 50)
        self.assertEqual(category["items"][-1]["itemId"], "diligent")
        self.assertEqual(category["items"][-1]["price"], 250)

        payload = jm_crypto.encrypt(
            json.dumps({
                "id": 3,
                "itemId": "xiyanshui",
                "quantity": 1,
                "client_trans_id": "http-buy-xiyanshui",
                "discount": 0,
            }, separators=(",", ":")).encode("utf-8"),
            group_name="FZJH03",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/buy_goods_3/xiyanshui"
            % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "userid": str(userid),
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["itemId"], "xiyanshui")
        self.assertEqual(result["data"]["remove_yuanbao"], 50)
        self.assertEqual(result["data"]["total_yuanbao"], 9949)

    def test_store_level_tab_and_purchase_flow(self):
        userid = 779001
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_store_list_4"
            % self.server.server_port,
            headers={"userid": str(userid)},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        level_category = result["data"]["list"][2]
        self.assertEqual(level_category["classId"], "fuben_goods")
        self.assertEqual(level_category["name"], "关卡")
        self.assertEqual(len(level_category["items"]), 6)
        self.assertEqual(level_category["items"][0]["itemId"], "volume_2")
        self.assertEqual(level_category["items"][0]["price"], 100)

        payload = jm_crypto.encrypt(
            json.dumps({
                "id": 4135,
                "itemId": "volume_2",
                "quantity": 1,
                "client_trans_id": "http-buy-volume-2",
                "discount": 0,
            }, separators=(",", ":")).encode("utf-8"),
            group_name="FZJH03",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/buy_goods_3/volume_2"
            % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "userid": str(userid),
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["itemId"], "volume_2")
        self.assertEqual(result["data"]["remove_yuanbao"], 100)
        self.assertEqual(result["data"]["total_yuanbao"], 9899)

    def test_store_limited_tab_package_and_purchase_flow(self):
        userid = 779002
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_store_list_4"
            % self.server.server_port,
            headers={"userid": str(userid)},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        limited_category = result["data"]["list"][0]
        self.assertEqual(limited_category["classId"], "xianshi_goods")
        self.assertEqual(limited_category["name"], "限时")
        self.assertEqual(len(limited_category["items"]), 17)
        self.assertEqual(limited_category["items"][0]["itemId"], "libao1425")
        self.assertEqual(limited_category["items"][0]["price"], 588)

        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_limit_package/libao1425"
            % self.server.server_port,
            headers={"userid": str(userid)},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["price"], 588)
        self.assertEqual(result["data"]["list"][0]["itemId"], "2021bingqicanpian1")
        self.assertEqual(result["data"]["list"][0]["number"], 1)
        self.assertEqual(result["data"]["limit_num"], 15)
        self.assertGreater(result["data"]["end_time"], int(time.time()))

        payload = jm_crypto.encrypt(
            json.dumps({
                "id": 8495,
                "itemId": "libao1436",
                "quantity": 1,
                "client_trans_id": "http-buy-libao-1436",
                "discount": 0,
            }, separators=(",", ":")).encode("utf-8"),
            group_name="FZJH03",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/buy_goods_3/libao1436"
            % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "userid": str(userid),
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["itemId"], "libao1436")
        self.assertEqual(result["data"]["remove_yuanbao"], 100)
        self.assertEqual(result["data"]["total_yuanbao"], 9899)

    def test_get_goods_2_fenshenfu_encrypted_http_flow(self):
        userid = 779003
        payload = jm_crypto.encrypt(
            json.dumps({
                "mark": {"isFreeSingle": False},
            }, separators=(",", ":")).encode("utf-8"),
            group_name="FZJH03",
        ).encode("utf-8")
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_goods_2/fenshenfu"
            % self.server.server_port,
            data=payload,
            headers={
                "Content-Type": "application/x-www-form-urlencoded",
                "userid": str(userid),
            },
            method="POST",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(
            jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8")
        )
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["itemId"], "fenshenfu")
        self.assertEqual(result["data"]["name"], "分身符")
        self.assertEqual(result["data"]["price"], 10)
        self.assertEqual(
            result["data"]["others"],
            {"mark": {"isFreeSingle": False}},
        )

    def test_spring_festival_list_returns_lua_compatible_actions(self):
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_spring_festival_list" % self.server.server_port,
            headers={"userid": "778899"},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8"))
        self.assertEqual(result["errcode"], 0)
        self.assertIsInstance(result["data"], list)
        self.assertEqual(result["data"][0]["name"], "签到活动")
        self.assertEqual(result["data"][0]["id"], 14)
        self.assertEqual(result["data"][0]["activity_id"], "qiandao")
        self.assertEqual(result["data"][0]["status"], 1)
        self.assertEqual(result["data"][0]["is_open"], 1)

    def test_sign_list_returns_client_required_mark_data(self):
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_sign_list" % self.server.server_port,
            headers={"userid": "778899"},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8"))
        self.assertEqual(result["errcode"], 0)
        self.assertIsInstance(result["data"], dict)
        self.assertEqual(len(result["data"]["beginDate"]), 8)
        self.assertEqual(len(result["data"]["endDate"]), 8)
        self.assertIsInstance(result["data"]["signedList"], list)
        self.assertEqual(result["data"]["yuanbao"], 20)
        self.assertEqual(result["data"]["prizeId"], 15)

    def test_spring_festival_status_returns_clickable_action_state(self):
        request = urllib.request.Request(
            "http://127.0.0.1:%d/api/v5/get_spring_festival_status/14" % self.server.server_port,
            headers={"userid": "778899"},
            method="GET",
        )
        response = urllib.request.urlopen(request, timeout=3)
        try:
            body = response.read().decode("utf-8")
        finally:
            response.close()
        result = json.loads(jm_crypto.decrypt(body, group_name="FZJH03").decode("utf-8"))
        self.assertEqual(result["errcode"], 0)
        self.assertEqual(result["data"]["id"], 14)
        self.assertEqual(result["data"]["is_open"], 1)
        self.assertEqual(result["data"]["status"], 1)
        self.assertIsInstance(result["data"]["rule_desc"], list)

    def test_returns_502_when_upstream_request_fails(self):
        original_base = config.UPDATE_UPSTREAM_BASE
        config.UPDATE_UPSTREAM_BASE = "http://127.0.0.1:1/v1"
        try:
            response = self.fetch("getMd5List?version=1")
        finally:
            config.UPDATE_UPSTREAM_BASE = original_base
        try:
            self.assertEqual(response.status, 502)
            self.assertEqual(response.read(), b"upstream request failed")
            self.assertEqual(response.headers.get_content_type(), "text/plain")
            self.assertEqual(int(response.headers["Content-Length"]), len(b"upstream request failed"))
        finally:
            response.close()

    def test_accepts_valid_200_response_prefix(self):
        base = "http://127.0.0.1:%d/valid200" % self.upstream.server_port
        with mock.patch.object(config, "UPDATE_UPSTREAM_BASE", base):
            response = self.fetch("checkUpdate")
        try:
            self.assertEqual(response.status, 200)
            self.assertEqual(response.read(), UpstreamHandler.valid_body)
            self.assertEqual(int(response.headers["Content-Length"]), len(UpstreamHandler.valid_body))
        finally:
            response.close()

    def test_rejects_invalid_200_response_prefix(self):
        fake_response = mock.MagicMock()
        fake_response.status = 200
        fake_response.headers = {"Content-Length": "7"}
        fake_response.read.return_value = b"invalid"
        fake_response.__enter__.return_value = fake_response
        with mock.patch.object(urllib.request.OpenerDirector, "open", return_value=fake_response):
            result = service._proxy_update_response({}, "checkUpdate")
        self.assertEqual(result["status_code"], 502)

    def test_rejects_oversized_response(self):
        fake_response = mock.MagicMock()
        fake_response.status = 200
        fake_response.headers = {"Content-Length": str(service.UPDATE_RESPONSE_LIMIT + 1)}
        fake_response.__enter__.return_value = fake_response
        with mock.patch.object(urllib.request.OpenerDirector, "open", return_value=fake_response):
            result = service._proxy_update_response({}, "checkUpdate")
        self.assertEqual(result["status_code"], 502)
        fake_response.read.assert_not_called()

    def test_rejects_invalid_upstream_configuration(self):
        for value in ("", "ftp://example.com/v1", "http:///v1"):
            with self.subTest(value=value), mock.patch.object(config, "UPDATE_UPSTREAM_BASE", value):
                result = service._proxy_update_response({}, "checkUpdate")
                self.assertEqual(result["status_code"], 502)

    def test_blocks_cross_host_redirect(self):
        handler = service._SameHostRedirectHandler("example.com")
        request = urllib.request.Request("http://example.com/v1/checkUpdate")
        with self.assertRaises(urllib.error.URLError):
            handler.redirect_request(
                request, None, 302, "Found",
                {"Location": "https://other.example/v1/checkUpdate"},
                "https://other.example/v1/checkUpdate")

    def test_converts_timeout_oserror_and_config_errors_to_502(self):
        errors = (TimeoutError(), OSError(), ValueError())
        for error in errors:
            with self.subTest(error=type(error).__name__), mock.patch.object(
                    urllib.request.OpenerDirector, "open", side_effect=error):
                result = service._proxy_update_response({}, "checkUpdate")
                self.assertEqual(result["status_code"], 502)

    # --- getMd5List 覆盖开关 -------------------------------------------------

    def _md5_temp_dir(self):
        """工作区内的临时目录。

        不用 tempfile.mkdtemp/TemporaryDirectory: 它们以 0700 创建目录, 在受限
        沙箱里该目录不可写; 用默认权限的 mkdir 就没问题。
        """
        base = pathlib.Path(__file__).resolve().parent
        for _ in range(50):
            candidate = base / (".tmp_md5_override_%s" % secrets.token_hex(4))
            try:
                candidate.mkdir()
            except FileExistsError:
                continue
            return str(candidate)
        raise RuntimeError("cannot create temp dir")

    def _md5_payload(self):
        return {"errcode": 0, "data": {
            "originalMd5List": {
                "src/app/views/layer/DebugLayer/DebugLayer.lua": "0" * 32,
                "src/app/views/layer/DebugLayer/DebugHelper.lua": "1" * 32,
                "src/app/views/layer/MainLayer.lua": "4" * 32,
                "res/Anim/1.png": "2" * 32,
            },
            "deployMd5List": {
                "src/app/views/layer/DebugLayer/DebugLayer.lua": "3" * 32,
                "src/app/views/layer/MainLayer.lua": "5" * 32,
            },
        }}

    def _encrypted_md5_body(self):
        return service._jhhu01_cipher(
            json.dumps(self._md5_payload(), separators=(",", ":")).encode("utf-8"), "enc")

    def test_md5_override_disabled_passes_upstream_body_through(self):
        body = self._encrypted_md5_body()
        with mock.patch.object(config, "MD5_OVERRIDE_ENABLED", False), \
                mock.patch.object(UpstreamHandler, "md5_body", body):
            response = self.fetch("getMd5List")
            try:
                got = response.read()
            finally:
                response.close()
        self.assertEqual(got, body)

    def test_md5_override_replaces_matching_debug_files_only(self):
        body = self._encrypted_md5_body()
        directory = self._md5_temp_dir()
        try:
            root = pathlib.Path(directory)
            (root / "DebugLayer.lua").write_bytes(b"local DebugLayer = 1\n")
            (root / "NotInList.lua").write_bytes(b"local X = 2\n")
            expected = {
                name: hashlib.md5(
                    service._jhhu01_cipher((root / name).read_bytes(), "enc")).hexdigest()
                for name in ("DebugLayer.lua", "NotInList.lua")
            }
            with mock.patch.object(config, "MD5_OVERRIDE_ENABLED", True), \
                    mock.patch.object(config, "MD5_OVERRIDE_DIR", directory), \
                    mock.patch.object(UpstreamHandler, "md5_body", body):
                response = self.fetch("getMd5List")
                try:
                    got = response.read()
                finally:
                    response.close()
        finally:
            shutil.rmtree(directory, ignore_errors=True)

        self.assertNotEqual(got, body)  # 重新加密过
        payload = json.loads(service._jhhu01_cipher(got, "dec").decode("utf-8"))
        original = payload["data"]["originalMd5List"]
        deploy = payload["data"]["deployMd5List"]
        key = "src/app/views/layer/DebugLayer/DebugLayer.lua"
        self.assertEqual(original[key], expected["DebugLayer.lua"])
        self.assertEqual(deploy[key], expected["DebugLayer.lua"])
        # 清单里没有的键不新增
        self.assertNotIn("src/app/views/layer/DebugLayer/NotInList.lua", original)
        self.assertNotIn("src/app/views/layer/DebugLayer/NotInList.lua", deploy)
        # 不相关的键保持原样
        self.assertEqual(original["res/Anim/1.png"], "2" * 32)
        self.assertEqual(
            original["src/app/views/layer/DebugLayer/DebugHelper.lua"], "1" * 32)

    def test_md5_override_includes_extra_files(self):
        """MD5_OVERRIDE_EXTRA_FILES 里的文件(如打过补丁的 MainLayer.lua)也要替换。"""
        directory = self._md5_temp_dir()
        try:
            extra = pathlib.Path(directory) / "MainLayer.lua"
            extra.write_bytes(b"local MainLayer = class('MainLayer')\n")
            expected = hashlib.md5(
                service._jhhu01_cipher(extra.read_bytes(), "enc")).hexdigest()
            rel = os.path.relpath(extra, pathlib.Path(config.__file__).resolve().parent)
            with mock.patch.object(config, "MD5_OVERRIDE_ENABLED", True), \
                    mock.patch.object(config, "MD5_OVERRIDE_DIR", directory), \
                    mock.patch.object(config, "MD5_OVERRIDE_EXTRA_FILES",
                                      {"src/app/views/layer/MainLayer.lua": rel}), \
                    mock.patch.object(UpstreamHandler, "md5_body", self._encrypted_md5_body()):
                response = self.fetch("getMd5List")
                try:
                    got = response.read()
                finally:
                    response.close()
        finally:
            shutil.rmtree(directory, ignore_errors=True)

        payload = json.loads(service._jhhu01_cipher(got, "dec").decode("utf-8"))
        self.assertEqual(
            payload["data"]["deployMd5List"]["src/app/views/layer/MainLayer.lua"], expected)
        self.assertEqual(
            payload["data"]["originalMd5List"]["src/app/views/layer/MainLayer.lua"], expected)

    def test_md5_override_keeps_original_body_when_decrypt_fails(self):
        body = b"4a4848553031" + b"00" * 16  # 魔数对但内容不是 JSON
        directory = self._md5_temp_dir()
        try:
            (pathlib.Path(directory) / "DebugLayer.lua").write_bytes(b"local DebugLayer = 1\n")
            with mock.patch.object(config, "MD5_OVERRIDE_ENABLED", True), \
                    mock.patch.object(config, "MD5_OVERRIDE_DIR", directory), \
                    mock.patch.object(UpstreamHandler, "md5_body", body):
                response = self.fetch("getMd5List")
                try:
                    got = response.read()
                finally:
                    response.close()
        finally:
            shutil.rmtree(directory, ignore_errors=True)
        self.assertEqual(got, body)


if __name__ == "__main__":
    unittest.main()
