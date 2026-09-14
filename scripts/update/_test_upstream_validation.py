# -*- coding: utf-8 -*-
"""测试上游对无效 sig / 缺失头 / 新 time 的响应格式"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import sys
import time
import urllib.error
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")

PREFIX = b"4a4848553032"


def build(hotver=14317, sig="cee2d43383bd1dab9688de2a25bc7512", nouce="kjcTou",
          t="0.000200", drop=()):
    app_name = "放置江湖".encode("utf-8").decode("latin-1")
    device = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
              '"dev_systemName":"android 34","dev_systemVersion":"14",'
              '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN",'
              '"app_name":"' + app_name + '","app_version":"2.1.02",'
              '"app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}')
    h = {
        "accept-encoding": "identity",
        "channel": "guanfang",
        "device": device,
        "hotver": str(hotver),
        "nouce": nouce,
        "package": "com.xhtt.app.fzjh",
        "platform": "android",
        "sig": sig,
        "time": t,
        "user-agent": "Dalvik/2.1.0 (Linux; U; Android 14; 2512BPNDAC)",
        "userid": "",
        "uuid": "guanfangd0b80cf7aa09ea3538329b0d",
        "ver": "2.1.02",
    }
    for k in drop:
        h.pop(k, None)
    return h


def test(name, **kw):
    req = urllib.request.Request("http://update.xiaohoutiaotiao.com/v1/checkUpdate", method="GET")
    for k, v in build(**kw).items():
        req.add_header(k, v)
    t0 = time.time()
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read()
            ok = body.lower().startswith(PREFIX)
            print("%-46s -> %s len=%-6d %.2fs 前缀OK=%-5s head=%s" % (
                name, resp.status, len(body), time.time() - t0, ok,
                body[:60].hex() if body else "(empty)"))
            if not ok:
                print("    !! 非 密文体: %r" % body[:200])
    except urllib.error.HTTPError as e:
        print("%-46s -> HTTP %s %.2fs body=%r" % (name, e.code, time.time() - t0, e.read()[:150]))
    except Exception as e:
        print("%-46s -> %s: %s (%.2fs)" % (name, type(e).__name__, e, time.time() - t0))


test("对照组: HAR sig/nouce/time (有效)", hotver=14317)
test("sig 全 0 (无效签名)", sig="0" * 32)
test("sig 缺失", drop=("sig",))
test("nouce 换新值但 sig 不变 (不匹配)", nouce="AbCd12")
test("time 为当前时间戳", t=str(time.time()))
test("time 为整数时间戳", t=str(int(time.time())))
test("time 缺失", drop=("time",))
test("nouce 缺失", drop=("nouce",))
test("device 缺失", drop=("device",))
test("uuid 缺失", drop=("uuid",))
test("package 缺失", drop=("package",))
test("ver 缺失", drop=("ver",))
test("channel 缺失", drop=("channel",))
test("platform 缺失", drop=("platform",))
