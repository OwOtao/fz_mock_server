# -*- coding: utf-8 -*-
"""逐步复现 mock 的 _proxy_update_response, 定位 502 的确切原因"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

import config
from handlers.service import (
    UPDATE_REQUEST_HEADERS, _SameHostRedirectHandler,
    _filter_proxy_headers, _read_update_response,
)

BASE = str(getattr(config, "UPDATE_UPSTREAM_BASE", "") or "").strip()
print("UPDATE_UPSTREAM_BASE =", BASE)
print("UPDATE_UPSTREAM_TIMEOUT =", config.UPDATE_UPSTREAM_TIMEOUT)

# 模拟真实客户端头 (来自 HAR 抓包)
HAR_HEADERS = {
    "accept-encoding": "identity",
    "channel": "guanfang",
    "device": '{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC","dev_systemName":"android 34","dev_systemVersion":"14","dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN","app_name":"放置江湖","app_version":"2.1.02","app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}',
    "host": "update.xiaohoutiaotiao.com",
    "hotver": "0",
    "nouce": "kjcTou",
    "package": "com.xhtt.app.fzjh",
    "platform": "android",
    "sig": "cee2d43383bd1dab9688de2a25bc7512",
    "time": "0.000200",
    "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC)",
    "userid": "",
    "uuid": "guanfangd0b80cf7aa09ea3538329b0d",
    "ver": "2.1.02",
}


def run_case(name, ctx_headers):
    print("\n" + "=" * 90)
    print("CASE: %s" % name)
    url = BASE.rstrip("/") + "/checkUpdate"
    request = urllib.request.Request(url, method="GET")
    forwarded = {}
    for key, value in ctx_headers.items():
        if str(key).lower() in UPDATE_REQUEST_HEADERS:
            request.add_header(key, value)
            forwarded[key] = value
    print("转发的头: %s" % sorted(forwarded))
    parsed_base = urllib.parse.urlparse(BASE)
    opener = urllib.request.build_opener(_SameHostRedirectHandler(parsed_base.hostname))
    t0 = time.time()
    try:
        with opener.open(request, timeout=float(config.UPDATE_UPSTREAM_TIMEOUT)) as response:
            print("opener.open 成功(%.2fs) status=%s" % (time.time() - t0, response.status))
            t1 = time.time()
            try:
                result = _read_update_response(response)
                print("_read_update_response 成功(%.2fs): status_code=%s len=%s head=%r" % (
                    time.time() - t1, result.get("status_code"),
                    len(result.get("body", b"")), result.get("body", b"")[:60]))
            except Exception as e:
                print("_read_update_response 抛异常(%.2fs): %s: %s" % (
                    time.time() - t1, type(e).__name__, e))
    except urllib.error.HTTPError as error:
        print("opener.open 抛 HTTPError(%.2fs): code=%s" % (time.time() - t0, error.code))
        print("  响应头:")
        for k, v in error.headers.items():
            print("    %s: %s" % (k, v))
        t1 = time.time()
        try:
            result = _read_update_response(error)
            print("_read_update_response(error) 成功(%.2fs): status_code=%s body_len=%s body_head=%r" % (
                time.time() - t1, result.get("status_code"),
                len(result.get("body", b"")), result.get("body", b"")[:80]))
        except Exception as e:
            print("_read_update_response(error) 抛异常(%.2fs): %s: %s" % (
                time.time() - t1, type(e).__name__, e))
    except Exception as e:
        print("opener.open 抛异常(%.2fs): %s: %s" % (time.time() - t0, type(e).__name__, e))


# case 1: 只带 UA (模拟日志中 cl=0 ct= 的空请求, mock 只能转发它收到的头)
run_case("最小头(近似 mock 实际收到的情况)", {
    "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14)",
})

# case 2: 带 HAR 全部真实头
run_case("HAR 真实客户端头", HAR_HEADERS)
