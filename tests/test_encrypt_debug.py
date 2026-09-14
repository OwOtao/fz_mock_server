"""Tests for the DebugLayer encryption exporter."""


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
from pathlib import Path
import tempfile
import unittest

import config
import jm_crypto
from encrypt_debug import encrypt_content, encrypt_directory


class EncryptDebugTests(unittest.TestCase):
    def test_formats_and_padding_preserve_source_bytes(self):
        for format_name in ("JHHU02", "JHHU01"):
            if format_name == "JHHU02":
                group = config.KEY_GROUPS["default"]
                magic, key, iv = group["magic"], group["key"], group["iv"]
            else:
                magic = config.UPDATE_JHHU01_MAGIC
                key, iv = config.UPDATE_JHHU01_KEY, config.UPDATE_JHHU01_IV
            for plain in (b"", b"a" * 15, b"a" * 16, b"a" * 17,
                          b"return 100", "-- 中文\r\nreturn {}\r\n".encode("utf-8")):
                with self.subTest(format=format_name, plain=plain):
                    encrypted = encrypt_content(plain, format_name)
                    raw = binascii.unhexlify(encrypted)
                    self.assertTrue(raw.startswith(magic))
                    decrypted = jm_crypto._aes_cbc(raw[len(magic):], key, iv, "dec")
                    self.assertEqual(decrypted, plain + b"0" * (16 - len(plain) % 16))

    def test_tree_and_overwrite(self):
        with tempfile.TemporaryDirectory() as tmp:
            source, output = Path(tmp) / "DebugLayer", Path(tmp) / "debug"
            (source / "nested" / "empty").mkdir(parents=True)
            originals = {"root.lua": b"return {}\r\n", "nested/test.lua": b"return 100"}
            for name, data in originals.items():
                (source / name).write_bytes(data)
            output.mkdir()
            (output / "unrelated.txt").write_bytes(b"keep")
            for _ in range(2):
                self.assertEqual(encrypt_directory(source, output), 2)
                for name, data in originals.items():
                    self.assertEqual((source / name).read_bytes(), data)
                    self.assertEqual((output / name).read_bytes(), encrypt_content(data))
                self.assertTrue((output / "nested/empty").is_dir())
                self.assertEqual((output / "unrelated.txt").read_bytes(), b"keep")

    def test_reject_overlapping_directories(self):
        with tempfile.TemporaryDirectory() as tmp:
            source = Path(tmp) / "src"
            source.mkdir()
            for output in (source, source / "out", Path(tmp)):
                with self.subTest(output=output), self.assertRaises(ValueError):
                    encrypt_directory(source, output)

    def test_missing_source(self):
        with tempfile.TemporaryDirectory() as tmp:
            output = Path(tmp) / "output"
            with self.assertRaises(ValueError):
                encrypt_directory(Path(tmp) / "missing", output)
            self.assertFalse(output.exists())


if __name__ == "__main__":
    unittest.main()
