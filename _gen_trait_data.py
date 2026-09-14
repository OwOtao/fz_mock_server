# -*- coding: utf-8 -*-
"""Generate handlers/role_trait_data.py from the client resource file.

Source: fzjh_lua/assets/res/script/others/familyspecial.lua  table ["trait"]
Used by the DebugLayer cheat endpoint ``test_homeland/3`` (随机解锁仆人特性),
which must hand the client trait ids that RoleTrait.lua can resolve.

``type`` values come from the resource file; type 20 is listed as unusable by
RoleTrait:checkTraitCanUsed, so those ids are excluded from the "usable" set.
"""
import collections
import json
import os
import re

SRC = os.path.join("fzjh_lua", "assets", "res", "script", "others", "familyspecial.lua")
OUT = os.path.join("handlers", "role_trait_data.py")

text = open(SRC, encoding="utf-8").read()
seg = text[text.find('trait"]={'):]

by_type = collections.defaultdict(list)
needs = {}
for match in re.finditer(r'\["(texing\d+)"\]=\{', seg):
    trait_id = match.group(1)
    body = seg[match.end():match.end() + 900]
    stop = body.find('},["texing')
    if stop == -1:
        stop = body.find('}}')
    body = body[:stop]
    found = re.search(r'\["type"\]=(\d+)', body)
    if not found:
        raise SystemExit("missing type for %s" % trait_id)
    by_type[int(found.group(1))].append(trait_id)
    need = re.search(r'\["CharacteristicNeed"\]=(-?\d+)', body)
    needs[trait_id] = int(need.group(1)) if need else 0

usable = sorted(
    trait_id for type_id, ids in by_type.items() if type_id != 20 for trait_id in ids
)

lines = [
    "# -*- coding: utf-8 -*-",
    '"""角色特性(特点)ID 表, 由脚本从客户端资源生成, 请勿手改.',
    "",
    "来源: fzjh_lua/assets/res/script/others/familyspecial.lua  [\"trait\"]",
    "用途: DebugLayer 调试接口 test_homeland/3(随机解锁仆人特性)下发 trait1/trait2/trait3,",
    "      客户端 RoleTrait.lua / HomelandRoleUtil.lua 按 id 查同一张表取名字与效果。",
    "",
    "TRAIT_IDS_BY_TYPE: {特性类型 -> (特性ID, ...)}; 类型编号语义见 RoleTrait.lua changeMap。",
    "TRAIT_NEED: {特性ID -> CharacteristicNeed}; 客户端按特点值(traitVal)筛选可用特性",
    "           (HomelandRoleUtil:getTexingList), 服务端下发特性时沿用同一门槛。",
    "USABLE_TRAIT_IDS: 排除 type=20(客户端 checkTraitCanUsed 判定不可用)后的全部特性ID。",
    '"""',
    "",
    "TRAIT_IDS_BY_TYPE = {",
]
for type_id in sorted(by_type):
    ids = ",\n        ".join('"%s"' % value for value in sorted(by_type[type_id]))
    lines.append("    %d: (\n        %s,\n    )," % (type_id, ids))
lines.append("}")
lines.append("")
lines.append("TRAIT_NEED = {")
for trait_id in sorted(needs):
    lines.append('    "%s": %d,' % (trait_id, needs[trait_id]))
lines.append("}")
lines.append("")
lines.append("USABLE_TRAIT_IDS = (")
for start in range(0, len(usable), 6):
    chunk = ", ".join('"%s"' % value for value in usable[start:start + 6])
    lines.append("    %s," % chunk)
lines.append(")")
lines.append("")
lines.append('__all__ = ["TRAIT_IDS_BY_TYPE", "TRAIT_NEED", "USABLE_TRAIT_IDS"]')
lines.append("")

open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(lines))

print("types:", len(by_type), "traits:", sum(len(v) for v in by_type.values()),
      "usable:", len(usable))
print(json.dumps({str(k): len(v) for k, v in sorted(by_type.items())}))
