# -*- coding: utf-8 -*-
"""实测上游 update.xiaohoutiaotiao.com 的连通性, 复现 _proxy_update_response 的行为"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import socket
import sys
import time
import urllib.error
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")

BASE = "http://update.xiaohoutiaotiao.com/v1"

print("== DNS 解析 ==")
try:
    infos = socket.getaddrinfo("update.xiaohoutiaotiao.com", 80)
    addrs = sorted({i[4][0] for i in infos})
    print("解析成功:", addrs)
except Exception as e:
    print("DNS 失败: %r" % e)

print("\n== TCP 连接 (120.24.37.41:80, 超时5s) ==")
s = socket.socket()
s.settimeout(5)
t0 = time.time()
try:
    s.connect(("120.24.37.41", 80))
    print("TCP 连接成功, 耗时 %.2fs" % (time.time() - t0))
    s.close()
except Exception as e:
    print("TCP 连接失败(%.2fs): %r" % (time.time() - t0, e))

print("\n== urllib GET checkUpdate (超时10s, 与 mock 相同) ==")
req = urllib.request.Request(BASE + "/checkUpdate", method="GET")
req.add_header("User-Agent", "Dalvik/2.1.0")
t0 = time.time()
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        body = resp.read()
        print("成功: status=%s len=%s 耗时=%.2fs head=%r" % (
            resp.status, len(body), time.time() - t0, body[:60]))
except urllib.error.HTTPError as e:
    print("HTTPError: %s 耗时=%.2fs body=%r" % (e.code, time.time() - t0, e.read()[:200]))
except Exception as e:
    print("失败: %s: %s 耗时=%.2fs" % (type(e).__name__, e, time.time() - t0))
