# -*- coding: utf-8 -*-
"""md5 覆盖修复的验证。

分两部分:
A. 复刻 test_update_integrity 里两个受沙箱 tempfile 限制而无法运行的用例
   (改用工作区内目录)。
B. 用 9-9 抓包的真实 JHHU02 上游 body 端到端验证:
   完整性校验 / 覆盖生效 / 加密组不变 / 截断能被识别 / 502 兜底体不再触发 hex 报错。
"""

# --- 归类后补充: encrypt_debug 位于 tools/ ---
import os as _reorg_os, sys as _reorg_sys
import binascii
import hashlib
import json
import os
import pathlib
import shutil
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

_reorg_tools = _reorg_os.path.join(ROOT, "tools")
if _reorg_tools not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _reorg_tools)

import config  # noqa: E402
import jm_crypto  # noqa: E402
from encrypt_debug import encrypt_content  # noqa: E402
from handlers import service  # noqa: E402

FAILED = []


def check(label, condition, detail=""):
    print("  [%s] %s %s" % ("OK " if condition else "FAIL", label, detail))
    if not condition:
        FAILED.append(label)


class FakeResponse:
    def __init__(self, body, declared=None, status=200):
        self.status = status
        self.headers = {"Content-Length": str(len(body) if declared is None else declared)}
        self._body = body
        self.read_called = False

    def read(self, _n=None):
        self.read_called = True
        return self._body

    def __enter__(self):
        return self

    def __exit__(self, *exc):
        return False


def temp_dir(name):
    """工作区内临时目录(不用 tempfile: 沙箱里 0700 目录不可写)。"""
    path = pathlib.Path(ROOT) / ".diagnostics" / name
    shutil.rmtree(path, ignore_errors=True)
    path.mkdir(parents=True, exist_ok=True)
    return path


print("=== A1. 已加密文件不重复加密(不同清单组) ===")
tmp = temp_dir("md5_no_double_encrypt")
try:
    path = tmp / "test.lua"
    for magic in (b"JHHU01", b"JHHU02"):
        encrypted = service._update_cipher(b"return {}", "enc", magic)
        path.write_bytes(encrypted)
        expect = hashlib.md5(encrypted).hexdigest()
        other = b"JHHU01" if magic == b"JHHU02" else b"JHHU02"
        check("%s 用同组算 md5" % magic.decode(),
              service._debug_file_md5(path, magic) == expect)
        check("%s 文件用异组参数也不重复加密" % magic.decode(),
              service._debug_file_md5(path, other) == expect)
finally:
    shutil.rmtree(tmp, ignore_errors=True)

print("\n=== A2. JHHU02 清单用本地文件真实哈希 ===")
tmp = temp_dir("md5_jhhu02_hash")
try:
    key = "src/app/views/layer/DebugLayer/test.lua"
    payload = {"data": {"originalMd5List": {key: "0" * 32}, "deployMd5List": {key: "0" * 32}}}
    path = tmp / "test.lua"
    encrypted = jm_crypto.encrypt(b"return {}", "default").encode()
    path.write_bytes(encrypted)
    body = jm_crypto.encrypt(json.dumps(payload), "default").encode()
    response = {"body": body, "status_code": 200,
                "headers": {"content-length": str(len(body)), "ETag": "old"}}
    with_config = (config, "MD5_OVERRIDE_DIR", str(tmp)), (config, "MD5_OVERRIDE_EXTRA_FILES", {})
    saved = [(obj, name, getattr(obj, name)) for obj, name, _ in with_config]
    try:
        for obj, name, value in with_config:
            setattr(obj, name, value)
        result = service._apply_md5_override(response)
    finally:
        for obj, name, value in saved:
            setattr(obj, name, value)
    decoded = json.loads(jm_crypto.decrypt(result["body"].decode(), "default"))
    for index, (name, table) in enumerate(decoded["data"].items()):
        check("清单 %s 用文件密文 md5" % name,
              table[key] == hashlib.md5(encrypted).hexdigest())
    check("Content-Length 已更新", result["headers"]["Content-Length"] == str(len(result["body"])),
          result["headers"]["Content-Length"])
    check("ETag 已移除", "ETag" not in result["headers"])
    check("小写 content-length 已移除", "content-length" not in result["headers"])
finally:
    shutil.rmtree(tmp, ignore_errors=True)

print("\n=== A3. 加密与 encrypt_debug 导出器一致 ===")
for magic in (b"JHHU01", b"JHHU02"):
    for size in (0, 15, 16, 17, 32, 64):
        plain = b"a" * size
        got = service._update_cipher(plain, "enc", magic)
        want = encrypt_content(plain, magic.decode())
        check("%s size=%d 与导出器一致" % (magic.decode(), size), got == want)
        check("%s size=%d 可解回" % (magic.decode(), size),
              service._update_cipher(got, "dec") == plain)

print("\n=== B1. 真实 9-9 抓包 body 通过完整性校验 ===")
har = json.load(open(os.path.join(ROOT, "so", "ProxyPin9-9_09_12_12.har"), encoding="utf-8"))
real = None
for entry in har["log"]["entries"]:
    if "getMd5List" in entry.get("request", {}).get("url", ""):
        text = ((entry.get("response", {}).get("content") or {}).get("text") or "").strip()
        if text:
            real = text.encode()
            break
check("找到真实 getMd5List 响应", real is not None)
if real:
    raw = service._decode_update_raw(real)
    print("     hexlen=%d rawlen=%d magic=%r" % (len(real), len(raw), raw[:6]))
    check("魔数为 JHHU02", raw[:6] == b"JHHU02")
    check("密文块对齐", (len(raw) - 6) % 16 == 0)
    out = service._read_update_response(FakeResponse(real))
    check("完整性校验通过", out["body"] == real)
    payload = json.loads(service._update_cipher(real, "dec").decode("utf-8"))
    check("解密得到清单", isinstance(payload.get("data"), dict)
          and len(payload["data"].get("originalMd5List") or {}) > 1000,
          "条目数=%d" % len(payload["data"].get("originalMd5List") or {}))

print("\n=== B2. 覆盖在真实 body 上生效且保持 JHHU02 ===")
if real:
    tmp = temp_dir("md5_real_body")
    try:
        key = "src/app/views/layer/DebugLayer/DebugLayer.lua"
        f = tmp / "DebugLayer.lua"
        f.write_bytes(b"local DebugLayer = 1\n")
        saved_dir = config.MD5_OVERRIDE_DIR
        saved_extra = config.MD5_OVERRIDE_EXTRA_FILES
        try:
            config.MD5_OVERRIDE_DIR = str(tmp)
            config.MD5_OVERRIDE_EXTRA_FILES = {}
            result = service._apply_md5_override(
                {"body": real, "status_code": 200, "headers": {"Content-Length": str(len(real))}})
        finally:
            config.MD5_OVERRIDE_DIR = saved_dir
            config.MD5_OVERRIDE_EXTRA_FILES = saved_extra
        check("body 被重写", result["body"] != real)
        new_raw = service._decode_update_raw(result["body"])
        check("加密组仍为 JHHU02", new_raw[:6] == b"JHHU02", repr(new_raw[:6]))
        decoded = json.loads(service._update_cipher(result["body"], "dec").decode("utf-8"))
        for name in ("originalMd5List", "deployMd5List"):
            check("%s 已替换" % name,
                  decoded["data"][name].get(key) == hashlib.md5(f.read_bytes()).hexdigest())
        check("条目数未丢", len(decoded["data"]["originalMd5List"]) >= len(payload["data"]["originalMd5List"]))
        check("Content-Length 一致", result["headers"]["Content-Length"] == str(len(result["body"])))
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

print("\n=== B3. 截断/异常 body 被明确识别（不再报 Odd-length string）===")
if real:
    cases = {
        "截断 1 字符(奇)": (real[:-1], None),
        "截断 2 字符(偶, 非整块)": (real[:-2], None),
        "截断 5 字节": (real[:-10], len(real)),
        "Content-Length 大于实际": (real[:-200], len(real)),
        "混入非 hex": (real[:100] + b"gg" + real[102:], None),
    }
    for label, (body, declared) in cases.items():
        try:
            service._read_update_response(FakeResponse(body, declared=declared))
            check(label, False, "竟然通过了校验")
        except service.UpdateResponseError as error:
            check(label, True, "-> %s" % str(error)[:70])
        except Exception as error:  # noqa: BLE001
            check(label, False, "抛出了意外异常 %s: %s" % (type(error).__name__, error))

print("\n=== B4. 502 兜底体不再被当成密文 ===")
failure = service._proxy_failure()
import logging  # noqa: E402
records = []


class Capture(logging.Handler):
    def emit(self, record):
        records.append(record.getMessage())


handler = Capture()
logging.getLogger("mock_server").addHandler(handler)
try:
    out = service._apply_md5_override(failure)
finally:
    logging.getLogger("mock_server").removeHandler(handler)
check("原样返回", out is failure)
check("没有 decrypt failed 记录", not any("decrypt failed" in m for m in records), str(records[-1:]))
check("没有 Odd-length string", not any("Odd-length" in m for m in records))

print("\n=== B5. 旧接口 _jhhu01_cipher 保持兼容 ===")
body = service._jhhu01_cipher(b"hello", "enc")
check("加密以 JHHU01 开头", body[:12] == b"4a4848553031", repr(body[:12]))
check("可解回", service._jhhu01_cipher(body, "dec") == b"hello")

print("\n=== 结果: %s ===" % ("全部通过" if not FAILED else "失败 %d 项: %s" % (len(FAILED), FAILED)))
sys.exit(1 if FAILED else 0)
