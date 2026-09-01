# -*- coding: utf-8 -*-
"""用 default 组密钥尝试解密 ver=2.1.01 的 JHHU01 响应 (只换魔数)"""
import binascii
import sys

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

import jm_crypto

# ver=2.1.01 时上游返回的响应 (364 hex 字符, 魔数 4a4848553031 = JHHU01)
JHHU01_BODY = (
    "4a4848553031b04c4ea7bbc963b81da0e1b737eb131582876a0ea2f0bc0f05f7"
    "dfdf58bd7c1267989784b345a5b1487ed87f414859d61d975e734582fe4b1475"
    "b6d57231fa24a1a3a51e51"
)
# 上面只是前 150 字符预览, 完整体需要重新抓; 先解已知的部分不够,
# 这里改为在线重新请求一次并完整解密
import urllib.request

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
print("ver=2.1.01 响应: status=%s len=%d" % (resp.status, len(body)))
print("完整密文:", body.decode("ascii"))

raw = binascii.unhexlify(body.decode("ascii"))
print("魔数: %r" % raw[:6])

# 尝试: JHHU01 魔数 + default 组 (JHHU02) 的 key/iv
for group_name in ("default", "FZJH02", "FZJH03", "FXXF03"):
    g = jm_crypto._groups()[group_name]
    enc = raw[6:]
    enc = enc[:len(enc) - (len(enc) % 16)]
    try:
        plain = jm_crypto._aes_cbc(enc, g["key"], g["iv"], "dec")
        plain = jm_crypto._unpad(plain)
        text = plain.decode("utf-8", "replace")
        printable = sum(1 for c in text if c.isprintable() or c in "\n\t") / max(len(text), 1)
        print("\n[%s 组 key=%r iv=%r] 可打印率 %.2f" % (group_name, g["key"], g["iv"], printable))
        print("  明文: %r" % text[:300])
    except Exception as e:
        print("\n[%s 组] 解密失败: %s" % (group_name, e))
