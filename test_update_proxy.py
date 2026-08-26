import json
import threading
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

    def do_GET(self):
        type(self).request_path = self.path
        type(self).request_headers = {key.lower(): value for key, value in self.headers.items()}
        status = 200 if "valid200" in self.path else 418
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


if __name__ == "__main__":
    unittest.main()
