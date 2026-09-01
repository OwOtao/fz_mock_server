# -*- coding: utf-8 -*-
"""ver=2.1.01 + hotver=0 (全新安装) 的响应验证 + 连续请求观察缓存时序"""
import binascii
import sys
import time
import urllib.request

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

import jm_crypto

KEY = b"9B5A96B0F4A1EC60DB88349E3B926765"
IV = b"34857d973953e44a"


def request_once(hotver, ver="2.1.01"):
    app_name = "放置江湖".encode("utf-8").decode("latin-1")
    device = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
              '"dev_systemName":"android 34","dev_systemVersion":"14",'
              '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN",'
              '"app_name":"' + app_name + '","app_version":"%s",'
              '"app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}' % ver)
    req = urllib.request.Request("http://update.xiaohoutiaotiao.com/v1/checkUpdate", method="GET")
    for k, v in {
        "accept-encoding": "identity", "channel": "guanfang", "device": device,
        "hotver": str(hotver), "nouce": "kjcTou", "package": "com.xhtt.app.fzjh",
        "platform": "android", "sig": "cee2d43383bd1dab9688de2a25bc7512",
        "time": "0.000200", "user-agent": "Dalvik/2.1.0", "userid": "",
        "uuid": "guanfangd0b80cf7aa09ea3538329b0d", "ver": ver,
    }.items():
        req.add_header(k, v)
    t0 = time.time()
    with urllib.request.urlopen(req, timeout=10) as resp:
        body = resp.read()
    elapsed = time.time() - t0
    raw = binascii.unhexlify(body.decode("ascii"))
    magic = raw[:6]
    if magic == b"JHHU01":
        enc = raw[6:]
        enc = enc[:len(enc) - (len(enc) % 16)]
        plain = jm_crypto._aes_cbc(enc, KEY, IV, "dec").rstrip(b"0").decode("utf-8", "replace")
    else:
        plain = "(非 JHHU01, 魔数 %r)" % magic
    print("ver=%s hotver=%-6s -> %s len=%d %.0fms 魔数=%r" % (
        ver, hotver, resp.status, len(body), elapsed * 1000, magic))
    print("    明文: %s" % plain[:200])
    return elapsed


print("== ver=2.1.01 各 hotver (含全新安装 hotver=0) ==")
request_once(0)
request_once(0)
request_once(14317)
request_once(35903)
