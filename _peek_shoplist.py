# -*- coding: utf-8 -*-
"""临时查找: shoplist.lua 中 400030 / 600000 商品定义。用完即删。"""
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
