local FightUtil = {}
local Random = require("third.Random.Random")

local LogSystem = require("app.models.LogSystem.LogSystem")

local randomSeed = math.ceil(GetTime())
local random = Random:create(randomSeed)
function FightUtil:setRandomSeed(num)
    random:setSeed(num)
end

function FightUtil:random(min, max)
    local ret = random:randomInt(min, max)
    return ret
end

local pack = function(...)
    return {n = select("#", ...), ...}
end

function FightUtil:printLog(...)
    local arg = {...}
    table.insert(arg, "】")
    LogSystem:log("【FightLog:", unpack(arg))
end

function FightUtil:printFormatLog(str, ...)
    local arg = {...}
    str = string.format(str, unpack(arg))
    str = str .. "】"
    self:printLog(str)
end

local FightPrintTextTemplate = require("app.FightSystem.FightPrintTextTemplate")
function FightUtil:printTemplateLog(template, ...)
    local str = FightPrintTextTemplate(template, unpack({...}))
    self:printLog(str)
end

local ch_name = {
    ["str"] = "臂力",
    ["dex"] = "身法",
    ["con"] = "根骨",
    ["int"] = "悟性",
    ["qi"] = "气血",
    ["qiMax"] = "气血上限",
    ["neiliMax"] = "内力上限",
    ["qiLimit"] = "最大气血上限",
    ["neiliLimit"] = "最大内力上限",
    ["atk"] = "攻击力",
    ["def"] = "防御力",
    ["damage"] = "伤害力",
    ["protect"] = "防护力",
    ["hitForce"] = "命中力",
    ["dodgeForce"] = "闪躲力",
    ["parryForce"] = "招架力",
    ["tiliSpeed"] = "体力恢复速度",
    ["qiLimitBattle"] = "最大气血上限",
    ["neiliLimitBattle"] = "最大内力上限",
    ["atkBattle"] = "攻击力",
    ["defBattle"] = "防御力",
    ["damageBattle"] = "伤害力",
    ["protectBattle"] = "防护力",
    ["hitForceBattle"] = "命中力",
    ["dodgeForceBattle"] = "闪躲力",
    ["parryForceBattle"] = "招架力",
    ["tiliSpeedBattle"] = "体力恢复速度",
    ["plusPoint"] = "加力值",
    ["plusPointBattle"] = "加力值",
    ["strCondSkill"] = "臂力",
    ["dexCondSkill"] = "身法",
    ["conCondSkill"] = "根骨",
    ["intCondSkill"] = "悟性",
    ["strCondGWeapon"] = "臂力",
    ["dexCondGWeapon"] = "身法",
    ["conCondGWeapon"] = "根骨",
    ["intCondGWeapon"] = "悟性",
    ["avgqiatk"] = "平均气血伤害",
    ["age"] = "年龄",
    ["zhengqi"] = "侠义正气",
    ["looks"] = "颜值",
    ["jingMax"] = "最大精力",
    ["lv"] = "角色等级",
    ["dssklv"] = "毒术技能等级",
    ["szjLv"] = "神照经技能等级",
    ["CSJYIN"] = "长生诀阴技能等级",
    ["zgxjLv"] = "振搞玄经技能等级",
    ["dkxgLv"] = "丹匮玄功技能等级",
    ["buffNum"] = "角色身上正面buff数量",
    ["deBuffNum"] = "角色身上负面buff数量",
    ["wdamage"] = "武器伤害力",
    ["CNCondGWeapon"] = "淬炼成功次数",
    ["weightCondGWeapon"] = "武器重量",
    ["tiliCost"] = "主动体力消耗",
    ["neiliCost"] = "主动内力消耗",
    ["sex"] = "性别",
    ["luck"] = "福缘",
    ["jing"] = "精力",
    ["exp"] = "经验",
    ["pot"] = "潜能",
    ["tili"] = "体力",
    ["neili"] = "内力"
}

function FightUtil:getCharacterAttrCHName(attrName)
    return ch_name[attrName]
end

return FightUtil
0000