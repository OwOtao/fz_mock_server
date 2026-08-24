--[[
    author:Seven
    time:2024-04-08 22:04:00
    desc: 字符串打印模板
]]
local stringTemplateConfig = {
    LOGIC_FRAME_START = "┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅ 逻辑帧【 %s 】开始 ┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅",
    LOGIC_FRAME_END = "┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅ 逻辑帧【 %s 】结束 ┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅┅",
    VIEW_FRAME_START = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 渲染帧【 %s 】开始 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    VIEW_FRAME_END = "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 渲染帧【 %s 】结束 ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    QI_ATTACK_REDUCE_PRINT = [[
        1类免伤值ID : %s
        2类免伤值ID : %s
        3类免伤值ID : %s
        1类免伤率ID : %s
        2类免伤率ID : %s
        3类免伤率ID : %s
        气血伤害免伤值穿透ID : %s
        初始伤害值 ：%s
        分摊比例 ：%s
        免伤值穿透率 : %s
        效果带来的影响值 ：%s
        实际减免值列表 ：%s
        1类免伤率.实际免伤值 : %s
        2类免伤率.实际免伤值 : %s
        3类免伤率.实际免伤值 : %s
        1类免伤率.预计效果值 : %s
        2类免伤率.预计效果值 : %s
        3类免伤率.预计效果值 : %s
        1类免伤值.预计效果值 : %s
        2类免伤值.预计效果值 : %s
        3类免伤值.预计效果值 : %s
        1类免伤值.实际效果值 : %s
        2类免伤值.实际效果值 : %s
        3类免伤值.实际效果值 : %s
        单次气血伤害(比例) : %s
        单次气血伤害(固值) : %s 
        ]],
    PLAYERATTR_HEALTHYNEILI = [[
        Player Attr __getHealthyNeili 角色打坐内力恢复力: %s
        │├ parmas 基本内功武学基础打坐内力恢复力 ：%s
        │├ parmas 准备内功武学品质打坐内力恢复力 ：%s
        │├ parmas 准备内功武学等级打坐内力恢复力修正系数 ：%s
        └─ value 角色打坐内力恢复力 ：%s
        ]],
    PLAYERATTR_GETHEALTHYQIMAX = [[
        Player Attr __getHealthyQiMax 角色疗伤恢复力: %s
        │├ parmas 基本内功武学基础疗伤恢复力 ：%s
        │├ parmas 准备内功武学品质疗伤恢复力 ：%s
        │├ parmas 准备内功武学等级疗伤恢复力修正系数 ：%s
        └─ value 角色疗伤恢复力 ：%s
    ]],
    PLAYERATTR_GETTILISPEED = [[
        Player Attr __getTiliSpeed 角色体力回复速度: "%s
        │├ parmas 角色体复力 ：%s
        │├ parmas 体复力转体力恢复速度 ：%s
        └─ value 角色体力回复速度 ：%s
    ]],
    PLAYERATTR_GETPLAYERDAMAGE = [[
        PlayerAttr:___getPlayerDamage 伤害力: %s
        │├parmas 实际加力值 ：%s
        │├parmas 准备攻击武学品质伤害力 ：%s
        │├parmas 准备攻击武学等级伤害力修正系数 ：%s
        │├parmas 武器伤害力 ：%s
        │└parmas 神兵完好度系数 ：%s
        │├ parmas 常态Buff比例加成 ：%s
        │├ parmas 常态Buff固值加成 ：%s
        │├ parmas 经脉穴位伤害力累计值 ：%s
        │├ parmas 经脉穴位伤害力修正 ：%s
        │├ parmas 拳脚伤害力 ：%s
        └─value  伤害力 ：%s
    ]],
    PLAYERATTR_GETTILIREGAIN = [[
        Player Attr ___getTiliRegain 角色体复力: %s
        │├ parmas 角色基础体复力 ：%s
        │├ parmas 基本轻功武学基础体复力 ：%s
        │├ parmas 准备轻功武学品质体复力 ：%s
        │├ parmas 准备轻功武学等级体复力比例修正系数 ：%s
        │├ parmas 先天身法体复力比例加成修正系数 ：%s
        │├ parmas 基本轻功武学体复力固值加成 ：%s
        │├ parmas 准备轻功武学等级体复力固值修正系数 ：%s
        │├ parmas 先天身法 ：%s
        │├ parmas 先天身法体复力固值加成 ：%s
        └─ value  角色体复力 ：%s
    ]],
    PLAYERATTR_GETDAMAGEBATTLE = [[
        Player Attr __getDamageBattle 伤害力: %s
        │├parmas 实际加力值 ：%s
        │├parmas 准备攻击武学品质伤害力 ：%s
        │├parmas 准备攻击武学等级伤害力修正系数 ：%s
        │├parmas 武器伤害力 ：%s
        │└parmas 神兵完好度系数 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值加成 ：%s
        │├ parmas 经脉穴位伤害力累计值 ：%s
        │├ parmas 经脉穴位伤害力修正 ：%s
        │├ parmas 拳脚伤害力 ：%s
        └─ value  伤害力 ：%s
    ]],
    PLAYERATTR_GETDAMAGE = [[
        Player Attr __getDamage 伤害力: %s
    ]],
    PLAYERATTR_GETPARRYFORCEBATTLE = [[
        Player Attr __getParryForceBattle 招架力: %s
        │├ parmas 角色命中力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值加成 ：%s
        └─ value  招架力 ：%s
    ]],
    PLAYERATTR_GETPARRYFORCE = [[
        Player Attr getParryForce 招架力: %s
        │├ parmas 基本招架武学招架力 ：%s
        │├ parmas 准备招架武学招架力 ：%s
        └─ value 招架力 ：%s
    ]],
    PLAYERATTR_GETDODGEFORCEBATTLE = [[
        Player Attr __getDodgeForceBattle 闪躲力: %s
        │├ parmas 角色战斗闪躲力 ：%s修改物品
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值闪躲力加成 ：%s
        └─ value  战斗闪躲力 ：%s
    ]],
    PLAYERATTR_GETDODGEFORCE = [[
        Player Attr getDodgeForce 闪躲力: %s
        │├ parmas 角色等级 ：%s
        │├ parmas 等级闪躲力修正系数 ：%s
        │├ parmas 基本轻功武学闪躲力 ：%s
        │├ parmas 先天身法 ：%s
        │├ parmas 先天身法闪躲力比例加成 ：%s
        │├ parmas 基本轻功等级 ：%s
        │├ parmas 基本轻功闪躲力比例加成 ：%s
        │├ parmas 经脉闪躲力比例加成 ：%s
        │├ parmas 准备轻功武学等级 ：%s
        │├ parmas 准备轻功武学等级闪躲力修正系数 ：%s
        │├ parmas 准备轻功武学品质闪躲力 ：%s
        │├ parmas 经脉固值闪躲力加成 ：%s
        └─ value  闪躲力 ：%s
    ]],
    PLAYERATTR_GETHITFORCEBATTLE = [[
        Player Attr getHitForceBattle 命中力: %s
        │├ parmas 角色命中力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值命中力加成 ：%s
        └─ value  命中力 ：%s
    ]],
    PLAYERATTR_GETHITFORCE = [[
        Player Attr getDodgeForce 命中力: %s
        │├ parmas 角色等级 ：%s
        │├ parmas 等级命中力修正系数 ：%s
        │├ parmas 基本攻击武学命中力 ：%s
        │├ parmas 先天臂力 ：%s
        │├ parmas 先天臂力命中力比例加成 ：%s
        │├ parmas 基本拳脚等级 ：%s
        │├ parmas 基本拳脚命中力比例加成 ：%s
        │├ parmas 经脉命中力比例加成 ：%s
        │├ parmas 准备攻击武学等级 ：%s
        │├ parmas 准备攻击武学等级命中力修正系数 ：%s
        │├ parmas 准备攻击武学品质命中力 ：%s
        │├ parmas 经脉固值命中力加成 ：%s
        └─ value  命中力 ：%s
    ]],
    PLAYERATTR_GETPROTECTBATTLE = [[
        Player Attr getProtectBattle 防护力: %s
        │├ parmas 角色防护力 ：%s
        │├ parmas buff比例防护加成 ：%s
        │├ parmas buff固值防护加成 ：%s
        └─ value 防御力 ：%s
    ]],
    PLAYERATTR_GETPROTECT = [[
        Player Attr getProtect 防护力: %s
        │├ parmas 先天根骨 ：%s
        │├ parmas 先天根骨防护力修正系数 ：%s
        │├ parmas 基本内功武学防护力 ：%s
        │├ parmas 装备防护力 ：%s
        │├ parmas 装备防护力修正系数 ：%s
        └─ value 防御力 ：%s
    ]],
    PLAYERATTR_GETDEFBATTLE = [[
        Player Attr GetDefBattle 防御力: %s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值防御加成 ：%s
        └─ value 防御力 ：%s
    ]],
    PLAYERATTR_GETDEF = [[
        Player Attr GetDef 防御力: %s
        │├ parmas 角色等级 ：%s
        │├ parmas 等级防御修正系数 ：%s
        │├ parmas 基本招架武学防御力 ：%s
        │├ parmas 先天身法 ：%s
        │├ parmas 先天身法防御比例加成 ：%s
        │├ parmas 基本轻功等级 ：%s
        │├ parmas 基本轻功防御比例加成 ：%s
        │├ parmas 经脉防御比例加成 ：%s
        │├ parmas 准备招架武学等级 ：%s
        │├ parmas 准备招架武学等级防御力修正系数 ：%s
        │├ parmas 准备招架武学品质防御力 ：%s
        │├ parmas 先天身法防御等级修正 ：%s
        │├ parmas 先天身法防御等级身法修正 ：%s
        │├ parmas 经脉固值防御加成 ：%s
        └─ value 防御力 ：%s
    ]],
    PLAYERATTR_GETATKBATTLE = [[
        Player Attr GetAtk 攻击力: %s
        │├ parmas 角色攻击力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值加成 ：%s
        └─ value  攻击力 ：%s
    ]],
    PLAYERATTR_GETATK = [[
       Player Attr GetAtk 攻击力: %s
       │├ parmas 角色等级 ：%s
       │├ parmas 等级攻击修正系数 ：%s
       │├ parmas 基本攻击武学攻击力 ：%s
       │├ parmas 基本内功武学攻击力 ：%s
       │├ parmas 先天臂力 ：%s
       │├ parmas 先天臂力攻击比例加成 ：%s
       │├ parmas 基本拳脚等级 ：%s
       │├ parmas 基本拳脚攻击比例加成 ：%s
       │├ parmas 经脉攻击比例加成 ：%s
       │├ parmas 准备攻击武学等级 ：%s
       │├ parmas 准备攻击武学等级攻击力修正系数 ：%s
       │├ parmas 准备攻击武学品质攻击力 ：%s
       │├ parmas 先天臂力攻击等级修正 ：%s
       │├ parmas 先天臂力攻击等级臂力修正 ：%s
       │├ parmas 经脉固值攻击加成 ：%s
       └─ value  攻击力 ：%s
    ]],
    NPCATTR_GETATK = [[
        Npc Attr GetAtk 【%s】 攻击力: %f
    ]],
    NPCATTR_GETATKBATTLE = [[
        Npc Attr GetAtkBattle 【%s】 攻击力: 
        │├ parmas 角色攻击力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值加成 ：%s
        └─ value  攻击力 ：%s
    ]],
    NPCATTR_GETDAMAGE = [[
        Npc Attr GetDamage 【%s】 伤害力: %f
    ]],
    NPCATTR_GETDAMAGEBATTLE = [[
        Npc Attr GetDamageBattle 【%s】 伤害力: 
        │├ parmas 角色伤害力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值加成 ：%s
        └─ value  伤害力 ：%s
    ]],
    NPCATTR_GETDEF = [[
        Npc Attr GetDef 【%s】 防御力: %f
    ]],
    NPCATTR_GETDEFBATTLE = [[
        Npc Attr GetDefBattle 【%s】 防御力: 
        │├ parmas 角色防御力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值防御加成 ：%s
        └─ value  防御力 ：%s
    ]],
    NPCATTR_GETPROTECT = [[
        Npc Attr GetProtect 【%s】 防护力: %f
    ]],
    NPCATTR_GETPROTECTBATTLE = [[
        Npc Attr GetProtectBattle 【%s】 防护力: 
        │├ parmas 角色防护力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值防护加成 ：%s
        └─ value  防御力 ：%s
    ]],
    NPCATTR_GETDODGEFORCE = [[
        Npc Attr GetDodgeForce 【%s】 闪躲力: %f
    ]],
    NPCATTR_GETDODGEFORCEBATTLE = [[
        Npc Attr GetDodgeForceBattle 【%s】 闪躲力: 
        │├ parmas 角色战斗闪躲力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值闪躲力加成 ：%s
        └─ value  战斗闪躲力 ：%s
    ]],
    NPCATTR_GETHITFORCE = [[
        Npc Attr GetHitForce 【%s】 命中力: %f
    ]],
    NPCATTR_GETHITFORCEBATTLE = [[
        Npc Attr GetHitForceBattle 【%s】 命中力: 
        │├ parmas 角色命中力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值命中力加成 ：%s
        └─ value  命中力 ：%s
    ]],
    NPCATTR_GETPARRYFORCE = [[
        Npc Attr GetParryForce 【%s】 招架力: %f
    ]],
    NPCATTR_GETPARRYFORCEBATTLE = [[
        Npc Attr GetParryForceBattle 【%s】 招架力: 
        │├ parmas 角色命中力 ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值加成 ：%s
        └─ value  招架力 ：%s
    ]],
    BASECHARACTERATTR_GETWEAPONWEIGHTBYSTRFACTOR = [[
        BaseCharacterAttr GetWeaponWeightByStrFactor 【%s】 武器重量臂力影响系数: 
        │├ parmas 武器重量 ：%s
        │├ parmas 先天臂力 ：%s
        │├ parmas 基本拳脚等级 ：%s
        │├ parmas 判断值 ：%s
        └─ value  武器重量臂力影响系数 ：%s
    ]],
    BASECHARACTERATTR_GETTILISPEEDBATTLE = [[
        BaseCharacterAttr TiliSpeedBattle 【%s】 战斗体力回复速度: 
        │├ parmas 角色体力回复速度 ：%s
        │├ parmas Buff比例加成 ：%s
        │├ parmas Buff固值加成 ：%s
        │├ parmas 角色负重影响值 ：%s
        └─ value  战斗体力回复速度 ：%s
    ]],
    BASECHARACTERATTR_GETPLUSPOINTBATTLE = [[
        BaseCharacterAttr GetPlusPointBattle 【%s】 战斗加力值: 
        │├ parmas 角色加力值（实际加力值） ：%s
        │├ parmas buff比例加成 ：%s
        │├ parmas buff固值加成 ：%s
        │├ parmas 当前内力 ：%s
        └─ value  战斗加力值 ：%s
    ]],
    BASECHARACTERATTR_GETWDAMAGE = [[
        BaseCharacterAttr WDamage 【%s】 武器伤害力:
        │├ parmas 手持武器伤害力 ：%s
        └─ value  武器伤害力 ：%s
    ]],
    BASECHARACTERATTR_GETWDAMAGEROLE = [[
        BaseCharacterAttr WDamageRole 【%s】 角色武器伤害力:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色武器伤害力 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCEQI = [[
        BaseCharacterAttr HealReduceQi 【%s】 角色气血恢复抗性:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色气血恢复抗性 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCEQISXBH = [[
        BaseCharacterAttr HealReduceQiSXBH 【%s】 角色气血恢复抗性-属性变化类:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色气血恢复抗性-属性变化类 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCEQISHZQX = [[
        BaseCharacterAttr HealReduceQiSHZQX 【%s】 角色气血恢复抗性-伤害转气血类:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色气血恢复抗性-伤害转气血类 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCEQISY = [[
        BaseCharacterAttr HealReduceQiSY 【%s】 角色气血恢复抗性-闪耀类:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色气血恢复抗性-闪耀类 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCEQIJY = [[
        BaseCharacterAttr HealReduceQiJY 【%s】 角色气血恢复抗性-架御类:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色气血恢复抗性-架御类 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCENEILI = [[
        BaseCharacterAttr HealReduceNeili 【%s】 角色内力恢复抗性:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色内力恢复抗性 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCENEILISXBH = [[
        BaseCharacterAttr HealReduceNeiliSXBH 【%s】 角色内力恢复抗性-属性变化类:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色内力恢复抗性-属性变化类 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCENEILISS = [[
        BaseCharacterAttr HealReduceNeiliSS 【%s】 角色内力恢复抗性-闪烁类:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色内力恢复抗性-闪烁类 ：%s
    ]],
    BASECHARACTERATTR_GETHEALREDUCENEILIJS = [[
        BaseCharacterAttr HealReduceNeiliJS 【%s】 角色内力恢复抗性-架势类:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色内力恢复抗性-架势类 ：%s
    ]],
    BASECHARACTERATTR_GETHEALTHYQI = [[
        BaseCharacterAttr HealthyQi 【%s】 角色气血恢复力:
        │├ parmas 基本内功武学基础气血恢复力 ：%s
        │├ parmas 准备内功武学品质气血恢复力 ：%s
        │├ parmas 准备内功武学等级气血恢复力修正系数 ：%s
        └─ value  角色气血恢复力 ：%s
    ]],
    BASECHARACTERATTR_GETFRAGILE1NUM = [[
        BaseCharacterAttr HealthyNeili 【%s】 角色易伤标记:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色易伤标记 ：%s
    ]],
    BASECHARACTERATTR_GETAUGMENT1NUM = [[
        BaseCharacterAttr HealthyNeili 【%s】 角色增伤标记:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  角色增伤标记 ：%s
    ]],
    BASECHARACTERATTR_GETFDAMAGE = [[
        BaseCharacterAttr FDamage 【%s】 角色武炼值:
        │├ parmas 角色拳脚武炼值 ：%s
        └─ value  角色武练值 ：%s
    ]],
    BASECHARACTERATTR_GETWSDAMAGE = [[
        BaseCharacterAttr WSDamage 【%s】 角色拳脚伤害力:
        │├ parmas 角色武练值 ：%s
        │├ parmas fdamage伤害力修正系数 ：%s
        └─ value  角色拳脚伤害力 ：%s
    ]],
    BASECHARACTERATTR_GETJQDAMAGE = [[
        BaseCharacterAttr JQDamage 【%s】 角色谙技值:
        │├ parmas 拳脚系统谙技值 ：%s
        └─ value  角色谙技值 ：%s
    ]],
    BASECHARACTERATTR_GETCURRJQDAMAGE = [[
        BaseCharacterAttr CurrJQDamage 【%s】 主手拳脚武学分支谙技值:
        │├ parmas 准备拳脚类型拳脚武学分支谙技值 ：%s
        └─ value  主手拳脚武学分支谙技值 ：%s
    ]],
    BASECHARACTERATTR_GETQIATKFACTOR = [[
        BaseCharacterAttr QiAtkFactor 【%s】 被动普通气血伤害系数:
        │├ parmas 角色被动普通气血伤害系数 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  被动普通气血伤害系数值 ：%s
    ]],
    BASECHARACTERATTR_GETPARRYHURTFIXRATEFACTOR = [[
        BaseCharacterAttr ParryHurtFixRateFactor 【%s】 普通招架免伤强化值:
        │├ parmas 角色基础值 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  普通招架免伤强化值 ：%s
    ]],
    BASECHARACTERATTR_GETPARRYQIHURTFACOTR = [[
        BaseCharacterAttr ParryQiHurtFacotr 【%s】 普通招架气血伤害减免值:
        │├ parmas 角色被动普通气血伤害系数 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value  普通招架气血伤害减免值 ：%s
    ]],
    BASECHARACTERATTR_GETRECORDDAMAGE = [[
        BaseCharacterAttr recordDamage 【%s】 实际承伤值:：%s
    ]],
    BASECHARACTERATTR_GETPLUSPOINTMAX = [[
        BaseCharacterAttr getPlusPointMax 加力最大值: %s
        │├ parmas 准备内功等级 ：%s
        │├ parmas 基础内功等级 ：%s
        └─ value 加力最大值 ：%s
    ]],
    BASECHARACTERATTR_GETQIACTIVEATKFACTOR = [[
        BaseCharacterAttr getQiActiveAtkFactor 主动气血直接伤害系数: %s
        │├ parmas 角色主动气血直接伤害系数 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value 主动气血直接伤害系数 ：%s
    ]],
    BASECHARACTERATTR_GETQIACTIVEDEFFACTOR = [[
        BaseCharacterAttr getQiActiveDefFactor 主动气血直接防御系数: %s
        │├ parmas 角色主动气血直接防御系数 ：%s
        │├ parmas 角色Buff固值加成 ：%s
        └─ value 主动气血直接防御系数 ：%s
    ]],
    FIGHTFORMULA_SKILL_DAMAGE_ATTR_CORRECTION_FACTOR = [[
        FightFormula calSkillDamageAttrCorrectionFactor 伤害属性修正系数:
        │├ parmas 攻击者 ：%s
        │├ parmas 受击者 ：%s
        │├ parmas 攻击者攻击属性类型 ：%s
        │├ parmas 受击者招架属性类型 ：%s
        │├ parmas 受击者招架武学.伤害防御属性值 ：%s
        │├ parmas 招架武学等效等级 ：%s
        │├ parmas 招架属性防御修正值 ：%s
        │├ parmas 受击者其它系统.伤害防御属性值 ：%s
        │├ parmas 攻击者其他系统.伤害攻击属性值 ：%s
        │├ parmas 气血属性伤害影响下限 ：%s
        │├ parmas 气血属性伤害影响上限 ：%s
        └─ value 伤害属性修正系数 ：%s
    ]]
}

return function(temlateName, ...)
    local arg = {...}

    local str = stringTemplateConfig[temlateName]

    if not str then
        error("Invalid template name: " .. tostring(temlateName))
        return
    end

    str = string.format(str, unpack(arg))

    return str
end
0000000