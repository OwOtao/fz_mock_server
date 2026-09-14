# -*- coding: utf-8 -*-

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import json

d = json.load(open("data/har_analysis/0013_api_v5_get_rank_list_4.json", encoding="utf-8"))
for b in d["data"]:
    item = (b.get("body", {}).get("list") or [{}])[0]
    print("== %s (%s)" % (b.get("title"), b.get("type")))
    print("   keys:", sorted(item.keys()))
    print("   mine keys:", sorted((b.get("body", {}).get("mine") or {}).keys()))
