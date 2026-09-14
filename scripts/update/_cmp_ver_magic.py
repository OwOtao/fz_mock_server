# -*- coding: utf-8 -*-
"""对比 ver=2.1.01 / 2.1.02 时上游 checkUpdate 响应魔数, 确认 mock 前缀校验缺口"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import sys
import urllib.request

sys.stdout.reconfigure(encoding="utf-8")

app_name = "放置江湖".encode("utf-8").decode("latin-1")
base_device = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
               '"dev_systemName":"android 34","dev_systemVersion":"14",'
               '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN",'
               '"app_name":"' + app_name + '","app_version":"%s",'
               '"app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}')

for ver, hotver in [("2.1.01", "14317"), ("2.1.01", "0"),
                    ("2.1.02", "14317"), ("2.1.02", "0")]:
    device = base_device % ver
    req = urllib.request.Request("http://update.xiaohoutiaotiao.com/v1/checkUpdate", method="GET")
    for k, v in {
        "accept-encoding": "identity", "channel": "guanfang", "device": device,
        "hotver": hotver, "nouce": "kjcTou", "package": "com.xhtt.app.fzjh",
        "platform": "android", "sig": "cee2d43383bd1dab9688de2a25bc7512",
        "time": "0.000200", "user-agent": "Dalvik/2.1.0", "userid": "",
        "uuid": "guanfangd0b80cf7aa09ea3538329b0d", "ver": ver,
    }.items():
        req.add_header(k, v)
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            body = resp.read()
            magic_hex = body[:12].decode("ascii", "replace")
            magic_ascii = bytes.fromhex(magic_hex).decode("ascii", "replace") if len(magic_hex) == 12 else "?"
            print("ver=%s hotver=%-6s -> HTTP %s len=%-5d magic_hex=%s (%s)" % (
                ver, hotver, resp.status, len(body), magic_hex, magic_ascii))
    except Exception as e:
        print("ver=%s hotver=%-6s -> %s: %s" % (ver, hotver, type(e).__name__, e))
