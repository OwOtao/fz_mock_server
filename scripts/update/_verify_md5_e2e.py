# -*- coding: utf-8 -*-
"""端到端验证 md5 覆盖修复（真实 HTTP）。

上游第一次返回被截断的 getMd5List（模拟线上 expected=2281164 received=2041617），
第二次返回 9-9 抓包里的完整 JHHU02 响应。验证：
  1. 客户端最终拿到 200，且响应是完整的 JHHU02 清单（重试生效）
  2. 本地 debug 文件的 md5 已被覆盖进清单（JHHU02 组现在能解了）
  3. 日志里不再出现 "Odd-length string"，而是明确的截断告警
"""
import hashlib
import json
import logging
import os
import pathlib
import shutil
import socket
import sys
import threading
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, ROOT)
sys.stdout.reconfigure(encoding="utf-8")

import config  # noqa: E402
import jm_crypto  # noqa: E402
from handlers import service  # noqa: E402
from server import create_server  # noqa: E402
from state import StateStore  # noqa: E402

FAILED = []


def check(label, condition, detail=""):
    print("  [%s] %s %s" % ("OK " if condition else "FAIL", label, detail))
    if not condition:
        FAILED.append(label)


# ---- 取真实 body + 一个真实清单键 ----
har = json.load(open(os.path.join(ROOT, "so", "ProxyPin9-9_09_12_12.har"), encoding="utf-8"))
real_body = None
for entry in har["log"]["entries"]:
    if "getMd5List" in entry.get("request", {}).get("url", ""):
        text = ((entry.get("response", {}).get("content") or {}).get("text") or "").strip()
        if text:
            real_body = text.encode()
            break
payload = json.loads(service._update_cipher(real_body, "dec").decode("utf-8"))
prefix = config.MD5_OVERRIDE_KEY_PREFIX
list_key = None
for key in payload["data"]["originalMd5List"]:
    if key.startswith(prefix + "/"):
        list_key = key
        break
check("真实清单里找到可覆盖的键", list_key is not None, list_key)
rel = list_key[len(prefix) + 1:]


class UpstreamHandler(BaseHTTPRequestHandler):
    bodies = []          # 依次返回; 用完后重复最后一个
    served = 0

    def do_GET(self):
        index = min(type(self).served, len(type(self).bodies) - 1)
        body = type(self).bodies[index]
        type(self).served += 1
        self.send_response(200)
        self.send_header("Content-Type", "application/octet-stream")
        self.send_header("Content-Length", str(len(real_body)))   # 故意的: 声明完整长度
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, fmt, *args):
        pass


records = []


class Capture(logging.Handler):
    def emit(self, record):
        records.append(record.getMessage())


logging.getLogger("mock_server").addHandler(Capture())
logging.getLogger("mock_server").setLevel(logging.INFO)

tmp = pathlib.Path(ROOT) / ".diagnostics" / "md5_e2e"
shutil.rmtree(tmp, ignore_errors=True)
(tmp / pathlib.PurePosixPath(rel)).parent.mkdir(parents=True, exist_ok=True)
(tmp / pathlib.PurePosixPath(rel)).write_bytes(b"local patch\n")

upstream = ThreadingHTTPServer(("127.0.0.1", 0), UpstreamHandler)
UpstreamHandler.bodies = [real_body[:-1], real_body]   # 第一次截断 1 字符(奇)
threading.Thread(target=upstream.serve_forever, daemon=True).start()

saved_base = config.UPDATE_UPSTREAM_BASE
saved_dir = config.MD5_OVERRIDE_DIR
saved_extra = config.MD5_OVERRIDE_EXTRA_FILES
config.UPDATE_UPSTREAM_BASE = "http://127.0.0.1:%d/v1" % upstream.server_port
config.MD5_OVERRIDE_DIR = str(tmp)
config.MD5_OVERRIDE_EXTRA_FILES = {}

def free_port():
    """避开 config.PORT(8080): create_server 里 `port or config.PORT` 会把 0 当成默认端口。"""
    sock = socket.socket()
    try:
        sock.bind(("127.0.0.1", 0))
        return sock.getsockname()[1]
    finally:
        sock.close()


mock = create_server("127.0.0.1", free_port(), state=StateStore(autosave=False))
threading.Thread(target=mock.serve_forever, daemon=True).start()

try:
    url = "http://127.0.0.1:%d/api/v1/getMd5List" % mock.server_port
    print("\n=== 请求 %s ===" % url)
    with urllib.request.urlopen(url, timeout=30) as response:
        status = response.status
        body = response.read()
    check("HTTP 200", status == 200, str(status))
    check("上游被请求了 2 次(重试生效)", UpstreamHandler.served == 2, "served=%d" % UpstreamHandler.served)
    check("返回的是完整 JHHU02 清单", body[:12] == b"4a4848553032", repr(body[:12]))
    decoded = json.loads(service._update_cipher(body, "dec").decode("utf-8"))
    expected_md5 = hashlib.md5((tmp / pathlib.PurePosixPath(rel)).read_bytes()).hexdigest()
    check("本地文件 md5 已写入 originalMd5List",
          decoded["data"]["originalMd5List"].get(list_key) == expected_md5)
    check("本地文件 md5 已写入 deployMd5List",
          decoded["data"]["deployMd5List"].get(list_key) == expected_md5)
    check("清单条数未减少",
          len(decoded["data"]["originalMd5List"]) >= len(payload["data"]["originalMd5List"]))
finally:
    mock.shutdown()
    mock.server_close()
    upstream.shutdown()
    upstream.server_close()
    config.UPDATE_UPSTREAM_BASE = saved_base
    config.MD5_OVERRIDE_DIR = saved_dir
    config.MD5_OVERRIDE_EXTRA_FILES = saved_extra
    shutil.rmtree(tmp, ignore_errors=True)

print("\n=== 日志检查 ===")
check("有明确的截断告警", any("truncated" in m for m in records),
      next((m for m in records if "truncated" in m), "-")[:110])
check("不再出现 Odd-length string", not any("Odd-length" in m for m in records))
check("覆盖成功日志", any("替换" in m or "md5 override" in m for m in records),
      next((m for m in records if "md5 override" in m), "-")[:110])

print("\n=== 结果: %s ===" % ("全部通过" if not FAILED else "失败 %d 项: %s" % (len(FAILED), FAILED)))
sys.exit(1 if FAILED else 0)
