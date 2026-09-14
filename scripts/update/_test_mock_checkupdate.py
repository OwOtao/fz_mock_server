# -*- coding: utf-8 -*-
"""端到端验证: 经 mock 代理的 checkUpdate 对 2.1.01(JHHU01) 客户端不再 502"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import binascii
import sys
import time
import urllib.request

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

import jm_crypto

MOCK = "http://127.0.0.1:8080"
JHHU01_KEY = b"9B5A96B0F4A1EC60DB88349E3B926765"
JHHU01_IV = b"34857d973953e44a"

app_name = "放置江湖".encode("utf-8").decode("latin-1")
base_device = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
               '"dev_systemName":"android 34","dev_systemVersion":"14",'
               '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN",'
               '"app_name":"' + app_name + '","app_version":"%s",'
               '"app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}')


def request_mock(path, ver, hotver):
    req = urllib.request.Request(MOCK + path, method="GET")
    for k, v in {
        "accept-encoding": "identity", "channel": "guanfang",
        "device": base_device % ver,
        "hotver": str(hotver), "nouce": "kjcTou", "package": "com.xhtt.app.fzjh",
        "platform": "android", "sig": "cee2d43383bd1dab9688de2a25bc7512",
        "time": "0.000200", "user-agent": "Dalvik/2.1.0", "userid": "",
        "uuid": "guanfangd0b80cf7aa09ea3538329b0d", "ver": ver,
    }.items():
        req.add_header(k, v)
    with urllib.request.urlopen(req, timeout=15) as resp:
        return resp.status, resp.read()


for _ in range(20):
    try:
        request_mock("/v1/get_time", "2.1.02", 0)
        break
    except Exception:
        time.sleep(0.5)

for ver in ("2.1.01", "2.1.02"):
    status, body = request_mock("/v1/checkUpdate", ver, 14317)
    magic = body[:12].decode("ascii", "replace")
    print("checkUpdate ver=%s -> HTTP %s len=%d magic=%s" % (ver, status, len(body), magic))

status, body = request_mock("/v1/checkUpdate", "2.1.01", 14317)
if body.startswith(b"4a4848553031"):
    enc = binascii.unhexlify(body.decode("ascii"))[6:]
    plain = jm_crypto._aes_cbc(enc, JHHU01_KEY, JHHU01_IV, "dec").rstrip(b"0")
    print("JHHU01 解密成功, 热更信息:")
    print(plain.decode("utf-8", "replace"))
else:
    print("JHHU01 解密跳过: 响应魔数非 4a4848553031")

status, body = request_mock("/v1/getMd5List", "2.1.01", 14317)
print("getMd5List ver=2.1.01 -> HTTP %s len=%d magic=%s" % (status, len(body), body[:12].decode("ascii", "replace")))
