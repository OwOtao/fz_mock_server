# -*- coding: utf-8 -*-
"""Check for duplicate @route patterns across handlers (last registration wins)."""
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
