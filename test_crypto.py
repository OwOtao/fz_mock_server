# -*- coding: utf-8 -*-
"""jm_crypto 自测: round-trip + APK 真实 lua 密文交叉验证。"""

import os
import sys
import zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, ROOT)
sys.path.insert(0, os.path.dirname(ROOT))   # d:/DTest/ds (decrypt_fzjh_lua.py)

import jm_crypto  # noqa: E402

fail = 0

def check(name, ok, extra=""):
    global fail
    print(("PASS" if ok else "FAIL"), name, extra)
    if not ok:
        fail += 1


# 1. round-trip
plain = '{"status":0,"errcode":0,"errmsg":"","data":{"time":1722854400}}'
enc = jm_crypto.encrypt(plain, "default")
dec = jm_crypto.decrypt(enc, "default").decode("utf-8")
check("roundtrip default", dec == plain, "prefix=%s" % enc[:16])

plain_zh = '{"data":{"msg":"江湖再见"}}'
enc_zh = jm_crypto.encrypt(plain_zh, "default")
dec_zh = jm_crypto.decrypt(enc_zh, "default").decode("utf-8")
check("roundtrip utf8", dec_zh == plain_zh)

# 2. APK 真实 lua 密文交叉验证
APK = r"E:\Leidian14\Picutres\leidian9Picutres\product_fangzhijianghu_guanfang_2.1.02.apk"
LUA_OUT = r"d:\DTest\ds\lua_out"
z = zipfile.ZipFile(APK)
for name in ["assets/src/main.lua", "assets/src/res_path.lua",
             "assets/res/MainScene.lua", "assets/src/config.lua"]:
    raw = z.read(name).decode("ascii")
    dec2 = jm_crypto.decrypt(raw, "default").rstrip(b"0")
    rel = name.replace("/", os.sep)
    ref = open(os.path.join(LUA_OUT, rel), "rb").read().rstrip(b"0")
    check("apk cross %s" % name, dec2 == ref, "len=%d" % len(dec2))

# 3. 与既有解密脚本的兼容性(我方加密 -> 脚本解密)
from decrypt_fzjh_lua import decrypt_lua_data  # noqa: E402
enc2 = jm_crypto.encrypt("local x=1", "default")
out = decrypt_lua_data(enc2.encode("ascii"))
check("cross decrypt_fzjh_lua", out.rstrip(b"0").decode("utf-8") == "local x=1")

# 4. 16 字节边界(块满补整块)
for n in (15, 16, 17, 31, 32):
    p = "A" * n
    e = jm_crypto.encrypt(p, "default")
    d = jm_crypto.decrypt(e, "default").decode("utf-8")
    check("boundary n=%d" % n, d == p)

print("----")
print("FAILED" if fail else "ALL PASS", fail)
sys.exit(1 if fail else 0)
