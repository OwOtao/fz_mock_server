# -*- coding: utf-8 -*-
"""终极复现: 构造与游戏客户端完全一致的 ctx, 直接调用 mock 的 check_update handler"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import http.client
import io
import sys
import time

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

from handlers.service import check_update

# 模拟游戏发给 mock 的原始请求字节 (与 HAR 抓包一致, device 为 UTF-8)
RAW_HEADERS = (
    b"Accept-Encoding: identity\r\n"
    b"uuid: guanfangd0b80cf7aa09ea3538329b0d\r\n"
    b"ver: 2.1.02\r\n"
    b"hotver: 0\r\n"
    b'device: {"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC","dev_systemName":"android 34","dev_systemVersion":"14","dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN","app_name":"\xe6\x94\xbe\xe7\xbd\xae\xe6\xb1\x9f\xe6\xb9\x96","app_version":"2.1.02","app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}\r\n'
    b"platform: android\r\n"
    b"channel: guanfang\r\n"
    b"package: com.xhtt.app.fzjh\r\n"
    b"userid: \r\n"
    b"time: 0.000200\r\n"
    b"sig: cee2d43383bd1dab9688de2a25bc7512\r\n"
    b"nouce: kjcTou\r\n"
    b"User-Agent: Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC Build/UQ1A.240205.04271925)\r\n"
    b"Host: 192.168.5.10:8080\r\n"
    b"Connection: Keep-Alive\r\n"
    b"\r\n"
)

# 与 server.py _dispatch 相同的解析方式
msg = http.client.parse_headers(io.BytesIO(RAW_HEADERS))
headers = {k.lower(): v for k, v in msg.items()}

ctx = {
    "method": "GET",
    "path": "/v1/checkUpdate",
    "query": {},
    "query_string": "",
    "headers": headers,
    "body": {},
    "raw_body": "",
    "encrypted": False,
    "raw_bytes": b"",
    "content_length": 0,
    "state": None,
    "route": "v1/checkUpdate",
    "route_tail": [],
}

print("调用 check_update(ctx), 模拟游戏请求...")
t0 = time.time()
result = check_update(ctx)
elapsed = time.time() - t0
print("耗时: %.2fs" % elapsed)
print("结果类型: %s" % type(result).__name__)
if isinstance(result, dict):
    print("status_code:", result.get("status_code"))
    body = result.get("body", b"")
    if isinstance(body, bytes):
        print("body 长度:", len(body))
        print("body 开头:", body[:80])
        print("body 开头(hex):", body[:40].hex() if body else "")
    else:
        print("body:", str(body)[:200])
    print("headers:", result.get("headers"))
