
# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__)))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
# encrypt_debug 已归入 tools/
_REORG_TOOLS = _reorg_os.path.join(_REORG_ROOT, "tools")
if _REORG_TOOLS not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_TOOLS)
import binascii
import hashlib
import http.client
import json
from pathlib import Path
import tempfile
import unittest
from unittest import mock

import config
import jm_crypto
from handlers import service


class UpdateIntegrityTests(unittest.TestCase):
    def response(self, body, length=None):
        response = mock.MagicMock()
        response.status = 200
        response.headers = {"Content-Length": str(len(body) if length is None else length)}
        response.read.return_value = body
        response.__enter__.return_value = response
        return response

    def test_cipher_matches_exporter_padding_and_keys(self):
        from encrypt_debug import encrypt_content
        for magic in (b"JHHU01", b"JHHU02"):
            for size in (0, 15, 16, 17, 32):
                with self.subTest(magic=magic, size=size):
                    plain = b"a" * size
                    encrypted = service._update_cipher(plain, "enc", magic)
                    self.assertEqual(encrypted, encrypt_content(plain, magic.decode()))
                    self.assertEqual(service._update_cipher(encrypted, "dec"), plain)

    def test_no_double_encryption_even_with_different_manifest_version(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "test.lua"
            for magic in (b"JHHU01", b"JHHU02"):
                encrypted = service._update_cipher(b"return {}", "enc", magic)
                path.write_bytes(encrypted)
                self.assertEqual(service._debug_file_md5(path, magic), hashlib.md5(encrypted).hexdigest())
                other = b"JHHU01" if magic == b"JHHU02" else b"JHHU02"
                self.assertEqual(service._debug_file_md5(path, other), hashlib.md5(encrypted).hexdigest())

    def test_reject_truncated_response_and_retry(self):
        body = jm_crypto.encrypt('{"data":{}}', "default").encode()
        truncated = self.response(body[:-1], len(body))
        valid = self.response(body)
        with mock.patch.object(service.urllib.request.OpenerDirector, "open", side_effect=[truncated, valid]) as opener:
            result = service._proxy_update_response({}, "getMd5List")
        self.assertEqual(opener.call_count, 2)
        self.assertEqual(result["body"], body)
        self.assertEqual(result["status_code"], 200)

    def test_persistently_invalid_response_returns_502(self):
        body = jm_crypto.encrypt('{"data":{}}', "default").encode()
        for bad in (body[:-1], body[:-2], body[:14] + b"gg" + body[16:]):
            with self.subTest(body=bad):
                response = self.response(bad)
                with mock.patch.object(service.urllib.request.OpenerDirector, "open", return_value=response) as opener:
                    result = service._proxy_update_response({}, "getMd5List")
                self.assertEqual(opener.call_count, 2)
                self.assertEqual(result["status_code"], 502)

    def test_error_response_is_not_decrypted(self):
        response = {"body": b"upstream request failed", "status_code": 502}
        with mock.patch.object(service, "_decode_update_raw") as decode:
            self.assertIs(service._apply_md5_override(response), response)
        decode.assert_not_called()

    def test_incomplete_read_retries(self):
        broken = self.response(b"")
        broken.read.side_effect = http.client.IncompleteRead(b"123")
        with mock.patch.object(service.urllib.request.OpenerDirector, "open", return_value=broken) as opener:
            self.assertEqual(service._proxy_update_response({}, "getMd5List")["status_code"], 502)
        self.assertEqual(opener.call_count, 2)

    def test_manifest_upsert_and_idempotence(self):
        key = "src/app/views/layer/DebugLayer/nested/new.lua"
        digest = "a" * 32
        for magic in (b"JHHU01", b"JHHU02"):
            for tables in ({}, {"originalMd5List": {}, "deployMd5List": {}},
                           {"originalMd5List": {key: digest}, "deployMd5List": {"other.lua": "b" * 32}}):
                with self.subTest(magic=magic, tables=tables):
                    payload = {"errcode": 0, "data": dict(tables, hotver=15427)}
                    response = {"body": service._update_cipher(json.dumps(payload).encode(), "enc", magic),
                                "status_code": 200, "headers": {}}
                    with mock.patch.object(service, "_md5_overrides", return_value={key: digest}):
                        result = service._apply_md5_override(response)
                        self.assertIs(service._apply_md5_override(result), result)
                    self.assertEqual(service._decode_update_raw(result["body"])[:6], magic)
                    decoded = json.loads(service._update_cipher(result["body"], "dec"))
                    self.assertEqual(decoded["errcode"], 0)
                    self.assertEqual(decoded["data"]["hotver"], 15427)
                    for name in ("originalMd5List", "deployMd5List"):
                        self.assertEqual(decoded["data"][name][key], digest)
                        for old_key, old_value in tables.get(name, {}).items():
                            self.assertEqual(decoded["data"][name][old_key], old_value)

    def test_invalid_manifest_structure_is_preserved(self):
        for data in (None, [], {"originalMd5List": [], "deployMd5List": None}):
            with self.subTest(data=data):
                body = service._update_cipher(json.dumps({"data": data}).encode(), "enc")
                response = {"body": body, "status_code": 200}
                with mock.patch.object(service, "_md5_overrides", return_value={"new.lua": "a" * 32}):
                    self.assertIs(service._apply_md5_override(response), response)

    def test_jhhu02_manifest_uses_actual_file_hash(self):
        key = "src/app/views/layer/DebugLayer/test.lua"
        payload = {"data": {"originalMd5List": {key: "0" * 32}, "deployMd5List": {key: "0" * 32}}}
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / "test.lua"
            encrypted = jm_crypto.encrypt(b"return {}", "default").encode()
            path.write_bytes(encrypted)
            body = jm_crypto.encrypt(json.dumps(payload), "default").encode()
            response = {"body": body, "status_code": 200, "headers": {"content-length": str(len(body)), "ETag": "old"}}
            with mock.patch.object(config, "MD5_OVERRIDE_DIR", tmp), mock.patch.object(config, "MD5_OVERRIDE_EXTRA_FILES", {}):
                result = service._apply_md5_override(response)
        decoded = json.loads(jm_crypto.decrypt(result["body"].decode(), "default"))
        for table in decoded["data"].values():
            self.assertEqual(table[key], hashlib.md5(encrypted).hexdigest())
        self.assertEqual(result["headers"]["Content-Length"], str(len(result["body"])))
        self.assertNotIn("ETag", result["headers"])
        self.assertNotIn("content-length", result["headers"])


if __name__ == "__main__":
    unittest.main()
