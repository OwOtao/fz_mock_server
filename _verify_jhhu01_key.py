# -*- coding: utf-8 -*-
"""用 9B5A96B0... 候选 key 解密 JHHU01 响应, 确定密钥用法 (32B ASCII 或 hex16)"""
import binascii
import sys
import urllib.request

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

import jm_crypto

# 重新请求 ver=2.1.01 的 JHHU01 响应
app_name = "放置江湖".encode("utf-8").decode("latin-1")
device = ('{"dev_name":"ld_generic_x86_64","dev_model":"2512BPNDAC",'
          '"dev_systemName":"android 34","dev_systemVersion":"14",'
          '"dev_idfv":"guanfangd0b80cf7aa09ea3538329b0d","dev_net":"WWAN",'
          '"app_name":"' + app_name + '","app_version":"2.1.01",'
          '"app_build":"android-25","app_channel":"guanfang","imei":"","oaid":""}')
req = urllib.request.Request("http://update.xiaohoutiaotiao.com/v1/checkUpdate", method="GET")
for k, v in {
    "accept-encoding": "identity", "channel": "guanfang", "device": device,
    "hotver": "14317", "nouce": "kjcTou", "package": "com.xhtt.app.fzjh",
    "platform": "android", "sig": "cee2d43383bd1dab9688de2a25bc7512",
    "time": "0.000200", "user-agent": "Dalvik/2.1.0", "userid": "",
    "uuid": "guanfangd0b80cf7aa09ea3538329b0d", "ver": "2.1.01",
}.items():
    req.add_header(k, v)
with urllib.request.urlopen(req, timeout=10) as resp:
    body = resp.read()

raw = binascii.unhexlify(body.decode("ascii"))
enc = raw[6:]
enc = enc[:len(enc) - (len(enc) % 16)]
print("JHHU01 密文 %d 字节 (魔数后)" % len(enc))

KEY_HEX = "9B5A96B0F4A1EC60DB88349E3B926765"
IVS = {
    "PcIQIZifRalhZ88n": b"PcIQIZifRalhZ88n",
    "34857d973953e44a": b"34857d973953e44a",
}
KEYS = {
    "ASCII32(AES-256)": KEY_HEX.encode("ascii"),
    "hex解码16B(AES-128)": binascii.unhexlify(KEY_HEX),
}

for kn, key in KEYS.items():
    for ivn, iv in IVS.items():
        try:
            plain = jm_crypto._aes_cbc(enc, key, iv, "dec")
            plain = plain.rstrip(b"0")
            text = plain.decode("utf-8", "replace")
            score = sum(1 for c in text if c.isprintable()) / max(len(text), 1)
            mark = " <<<< 命中!" if score > 0.9 else ""
            print("%-22s + iv=%s => 可打印率 %.2f %s" % (kn, ivn, score, mark))
            if score > 0.5:
                print("    %r" % text[:250])
        except Exception as e:
            print("%-22s + iv=%s => 失败: %s" % (kn, ivn, e))
