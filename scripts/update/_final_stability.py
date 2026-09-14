# -*- coding: utf-8 -*-
"""最终稳定性验证: 连续 3 次 checkUpdate + 1 次 getMd5List 走 mock 代理路径"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import sys
import time

sys.path.insert(0, r"F:\AI\fzjh\fz_mock_server")
sys.stdout.reconfigure(encoding="utf-8")

from handlers.service import check_update, get_md5_list
from _final_repro import ctx  # 复用完全一致的 ctx (游戏原始头)

print("== checkUpdate x3 ==")
for i in range(3):
    t0 = time.time()
    result = check_update(dict(ctx))
    body = result.get("body", b"")
    print("  #%d: status=%s len=%s 耗时=%.2fs head=%r" % (
        i + 1, result.get("status_code"), len(body), time.time() - t0, body[:40]))

print("\n== getMd5List x1 (真实响应约 2.2MB) ==")
t0 = time.time()
result = get_md5_list(dict(ctx))
body = result.get("body", b"")
print("  status=%s len=%s 耗时=%.2fs head=%r" % (
    result.get("status_code"), len(body), time.time() - t0, body[:40]))

# 解密看内容
import jm_crypto
print("\n== 解密最新 checkUpdate 响应 ==")
r = check_update(dict(ctx))
plain = jm_crypto.decrypt(r["body"].decode("ascii"), "default").decode("utf-8")
print(plain)
