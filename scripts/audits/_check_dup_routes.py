# -*- coding: utf-8 -*-
"""Check for duplicate @route patterns across handlers (last registration wins)."""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import collections
import glob
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")
pat = re.compile(r'@route\(\[[^\]]*\],\s*"([^"]+)"')
counter = collections.Counter()
where = collections.defaultdict(list)
for path in glob.glob("handlers/*.py"):
    for line in open(path, encoding="utf-8"):
        found = pat.search(line)
        if found:
            counter[found.group(1)] += 1
            where[found.group(1)].append(path)
for name, count in sorted(counter.items()):
    if count > 1:
        print("DUP", name, where[name])
print("total patterns", len(counter))
for name in ("test_homeland", "make_servant_change", "set_auction_time", "update_currency_by_type"):
    print(name, counter.get(name, 0), where.get(name, []))
