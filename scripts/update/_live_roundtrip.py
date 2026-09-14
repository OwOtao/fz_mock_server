# -*- coding: utf-8 -*-
"""通过运行中的 mock 服务发送 checkUpdate, 验证全链路 (http.server 解析 + 代理转发)"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import socket
import sys
import time

sys.stdout.reconfigure(encoding="utf-8")

# 游戏发给 mock 的原始请求字节 (与 HAR 一致, device 为 UTF-8)
app_name = "放置江湖".encode("utf-8")
raw = (
    b"GET /v1/checkUpdate HTTP/1.1\r\n"
    b"Accept-Encoding: identity\r\n"
    b"uuid: guanfangd0b80cf7aa09ea3538329b0d\r\n"
    b"ver: 2.1.02\r\n"
    b"hotver: 14317\r\n"
    b'device: {"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC","dev_systemName":"android 34","dev_systemVersion":"14","dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN","app_name":"' + app_name + b'","app_version":"2.1.02","app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}\r\n'
    b"platform: android\r\n"
    b"channel: guanfang\r\n"
    b"package: com.xhtt.app.fzjh\r\n"
    b"userid: \r\n"
    b"time: 0.000200\r\n"
    b"sig: cee2d43383bd1dab9688de2a25bc7512\r\n"
    b"nouce: kjcTou\r\n"
    b"User-Agent: Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC Build/UQ1A.240205.04271925)\r\n"
    b"Host: 127.0.0.1:8080\r\n"
    b"Connection: close\r\n"
    b"\r\n"
)

s = socket.create_connection(("127.0.0.1", 8080), timeout=30)
s.sendall(raw)
t0 = time.time()
chunks = []
while True:
    data = s.recv(65536)
    if not data:
        break
    chunks.append(data)
body = b"".join(chunks)
head, _, rest = body.partition(b"\r\n\r\n")
print("耗时 %.2fs, 响应 %d 字节" % (time.time() - t0, len(body)))
print("状态行: %r" % head.split(b"\r\n")[0])
print("响应头: %s" % head.decode("latin-1", "replace").replace("\r\n", " | "))
print("响应体 head: %r" % rest[:80])
