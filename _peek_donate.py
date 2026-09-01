# -*- coding: utf-8 -*-
"""临时提取: sectBuildDonate 捐献条目(逐条 split 解析)。用完即删。"""
import io
import re

donate = io.open(r'fzjh_lua/assets/res/script/family/sectBuildDonate.lua', encoding='utf-8').read()

# 按条目切块: ["xxxx"]={...},
print('_DONATE_TABLE = {')
for chunk in donate.split('},['):
    m = re.match(r'"(\d+)"\]=\{donateid="(\d+)"', chunk)
    if not m:
        continue
    cond = re.search(r'donatecondition=\{\{("[a-z]+\d*"),(\d+)\}\}', chunk)
    up = re.search(r'upresources=(\d+)', chunk)
    rn = re.search(r',renown=(\d+),donate=(\d+)', chunk)
    unlock = re.search(r'unlockcondition=(\{\})', chunk)
    print('    "%s": {"item": %s, "num": %s, "up": %s, "renown": %s, "donate": %s},' % (
        m.group(1), cond.group(1) if cond else None, cond.group(2) if cond else None,
        up.group(1), rn.group(1), rn.group(2)))
print('}')

build = io.open(r'fzjh_lua/assets/res/script/family/sectBuildInfo.lua', encoding='utf-8').read()
print('\n# sectBuildInfo per building level:')
for chunk in build.split('},['):
    m = re.match(r'"(\d+)"\]=\{buildid="\d+",buildingid="(\d+)",buildname="([^"]*)",buildlv=(\d+)', chunk)
    if not m:
        continue
    dids = re.search(r'donateid=\{([^}]*)\}', chunk)
    mx = re.search(r'maxupresources=(\d+),cescalation=(\d+)', chunk)
    cond = re.search(r'condition=\{\{("sgbpoint"),(\d+)\}\}', chunk)
    ids = re.findall(r'"(\d+)"', dids.group(1)) if dids else []
    print('  b%s lv%s %-5s max=%s cesca=%s cond=%s donateids=%s' % (
        m.group(2), m.group(4), m.group(3), mx.group(1) if mx else '?',
        mx.group(2) if mx else '?',
        (cond.group(2) if cond else 'None'),
        ids))
