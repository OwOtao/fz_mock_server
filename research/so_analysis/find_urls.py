# -*- coding: utf-8 -*-
"""扫描 SO 中所有 http/https URL, 为 patch 做准备."""
import re

from _paths import SO_PATH

data = open(SO_PATH, "rb").read()
urls = [(m.start(), m.group()) for m in re.finditer(rb"https?://[a-zA-Z0-9._/:-]{10,120}", data)]

print(f"共 {len(urls)} 个 URL:")
for off, url in urls:
    print(f"  0x{off:08x} ({len(url):3d}B) {url.decode('ascii', errors='replace')}")
