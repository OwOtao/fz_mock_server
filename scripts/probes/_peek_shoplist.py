# -*- coding: utf-8 -*-
"""临时查找: shoplist.lua 中 400030 / 600000 商品定义。用完即删。"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import io
import re

t = io.open(r'fzjh_lua/assets/res/script/store/shoplist.lua', encoding='utf-8').read()
for gid in ('400030', '600000', '600001'):
    for pat in ('[%s]=' % gid, '"%s"' % gid):
        k = t.find(pat)
        if k >= 0:
            print(gid, pat, '@', k)
            print('   ', t[k:k+320].replace('\n', ' '))
            break
    else:
        print(gid, 'NOT FOUND')

# Sheet1 结构
m = re.search(r'return \{\["Sheet1"\]=', t)
print('Sheet1 at', m.start() if m else None)
