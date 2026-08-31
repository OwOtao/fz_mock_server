# -*- coding: utf-8 -*-
"""Patch SO 中的 bootstrap URL, 指向我们的 mock server."""
import os
import shutil

from _paths import FRIDA_DIR, SO_PATH

SO_SRC = SO_PATH
SO_DST = os.path.join(FRIDA_DIR, "libcocos2dlua_arm64_patched.so")

OLD_URL = b"https://android.fzjh.xiaohoutiaotiao.com/api/service/get_game_config"
NEW_URL = b"http://10.10.16.55:8080/api/service/get_game_config"

assert len(NEW_URL) <= len(OLD_URL), f"新 URL ({len(NEW_URL)}B) 不能超过旧 URL ({len(OLD_URL)}B)"

# 复制原文件
shutil.copy2(SO_SRC, SO_DST)

# 读取并 patch
data = bytearray(open(SO_DST, "rb").read())
offset = data.find(OLD_URL)
assert offset >= 0, "未找到目标 URL"

# 写入新 URL + null 填充
patched = NEW_URL + b"\x00" * (len(OLD_URL) - len(NEW_URL))
data[offset:offset + len(OLD_URL)] = patched

with open(SO_DST, "wb") as f:
    f.write(data)

print(f"Patch 完成:")
print(f"  偏移: 0x{offset:08x}")
print(f"  旧: {OLD_URL.decode()}")
print(f"  新: {NEW_URL.decode()}")
print(f"  输出: {SO_DST}")

# 验证
verify = open(SO_DST, "rb").read()
assert verify[offset:offset + len(NEW_URL)] == NEW_URL
assert verify[offset + len(NEW_URL)] == 0
print("  验证: OK")
