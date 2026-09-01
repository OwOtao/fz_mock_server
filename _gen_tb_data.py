# -*- coding: utf-8 -*-
"""临时提取: tasks.lua 任务(time/awards) + sectBuildInfo 建筑等级表 + sectBuildDonate 捐献表。
输出 Python 字面量。用完即删。"""
import io
import re


def chunks(text, head_marker):
    """按 ["key"]={ 切块, 首块前缀补 '['。"""
    start = text.index(head_marker) + len(head_marker)
    body = text[start:text.rindex('}') - 0]
    for chunk in body.split('},['):
        if not chunk.startswith('['):
            chunk = '[' + chunk
        yield chunk


print('_TASK_TABLE = {')
for chunk in chunks(io.open(r'fzjh_lua/assets/res/script/family/tasks.lua', encoding='utf-8').read(),
                    'return {["1"]={'):
    m = re.match(r'\["(\d+)"\]=\{taskid="\d+",type=\d+,name="[^"]*",camp=\d+,sign=\{[^}]*\},'
                 r'unlockcondition=\{[^}]*\}', chunk)
    if not m:
        continue
    tid = m.group(1)
    time_h = re.search(r',time="(\d+)"', chunk)
    awards = re.findall(r'awards=\{\{"([a-z]\w*)","(\d+)"\}\}', chunk)
    multi = re.search(r'awards=\{\{"[a-z]\w*","\d+"\},\{', chunk)
    assert not multi, tid
    print('    "%s": (%s, [%s]),' % (tid, time_h.group(1) if time_h else '1',
                                     ', '.join('("%s", %s)' % a for a in awards)))
print('}')

print('\n_BUILD_LEVELS = {')
for chunk in chunks(io.open(r'fzjh_lua/assets/res/script/family/sectBuildInfo.lua', encoding='utf-8').read(),
                    'return {["1"]={'):
    m = re.match(r'\["(\d+)"\]=\{buildid="\d+",buildingid="(\d+)",buildname="[^"]*",buildlv=(\d+)', chunk)
    if not m:
        continue
    bid, lv = m.group(2), int(m.group(3))
    mx = re.search(r'maxupresources=(\d+),cescalation=(\d+)', chunk)
    cond = re.search(r'condition=\{\{("sgbpoint"),(\d+)\}\}', chunk)
    dids = re.search(r'donateid=\{([^}]*)\}', chunk)
    ids = re.findall(r'"(\d+)"', dids.group(1)) if dids else []
    print('    "%s": (%d, %d, %d, %d, (%s)),' % (
        bid, lv, int(mx.group(1)), int(mx.group(2)),
        int(cond.group(2)) if cond else 0,
        ', '.join('"%s"' % i for i in ids) or ''))
print('}')

print('\n_DONATE_TABLE = {')
for chunk in chunks(io.open(r'fzjh_lua/assets/res/script/family/sectBuildDonate.lua', encoding='utf-8').read(),
                    'return {["1"]={'):
    m = re.match(r'\["(\d+)"\]=\{donateid="\d+"', chunk)
    if not m:
        continue
    cond = re.search(r'donatecondition=\{\{("([a-z]\w*)"),(\d+)\}\}', chunk)
    up = re.search(r'upresources=(\d+)', chunk)
    rn = re.search(r',renown=(\d+),donate=(\d+)', chunk)
    unlock = re.search(r'unlockcondition=(\{\})', chunk)
    print('    "%s": ("%s", %s, %s, %s, %s, %d),' % (
        m.group(1), cond.group(2), cond.group(3), up.group(1),
        rn.group(1), rn.group(2), 0 if unlock else 1))
print('}')
