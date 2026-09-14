# -*- coding: utf-8 -*-

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import glob
import re

TARGETS = [
    "get_partition_list2", "getWebConfig", "is_changed_name", "get_email",
    "get_employee_list", "get_affair_list", "get_limit_package",
    "upload_user_file_3", "process_pay_affairs", "get_user_map",
    "get_rank_list_4", "get_store_list_4", "get_teacherBuild_info",
    "get_teacherBuild_list", "get_user_designation", "get_user_prestige",
    "update_unlock_record", "get_guaike_reward", "get_activity_list",
]

route_re = re.compile(r"@route\(\s*\[([^\]]*)\]\s*,\s*['\"]([^'\"]+)['\"]")
found = {}
for hf in sorted(glob.glob("handlers/*.py")):
    with open(hf, encoding="utf-8") as f:
        src = f.read()
    for methods, pattern in route_re.findall(src):
        if pattern in TARGETS:
            found.setdefault(pattern, []).append((methods.strip(), hf))

for t in TARGETS:
    if t in found:
        for methods, hf in found[t]:
            print("FOUND   %-24s %-8s %s" % (t, methods, hf))
    else:
        print("MISSING %-24s" % t)
