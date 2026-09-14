# -*- coding: utf-8 -*-

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import json
import sys

sys.path.insert(0, ".")
import jm_crypto

for name in ("ProxyPin8-24_14_40_30.har",
             "ProxyPin8-26_16_56_27_activity_techBuild_rank_shop.har",
             "ProxyPin8-27_14_33_32.har"):
    h = json.load(open("so/" + name, encoding="utf-8"))
    print("=" * 20, name)
    for e in h["log"]["entries"]:
        if "exchange_publickey" in e["request"]["url"]:
            plain = jm_crypto.decrypt(e["response"]["content"]["text"])
            print(plain.decode("utf-8", "replace"))
