local Module = require("third.module.Module")
local RoleModule_GetBaseAttr_GetDefault = class("RoleModule_GetBaseAttr_GetDefault", Module)

function RoleModule_GetBaseAttr_GetDefault:ctor()
    self._name = "RoleModule_GetBaseAttr_GetDefault"
end

--@desc 此处存放不进入不需进入存档的人物属性默认值
local defaultAttrValueMap = {
    ["atkScale"] = 1,
    ["damageScale"] = 1,
    ["protectScale"] = 1,
    ["defScale"] = 1,
    ["dodgeScale"] = 1,
    ["parryScale"] = 1,
    ["secStrScale"] = 1,
    ["secDexScale"] = 1,
    ["secConScale"] = 1,
    ["secIntScale"] = 1,
    ["strScale"] = 1,
    ["dexScale"] = 1,
    ["conScale"] = 1,
    ["intScale"] = 1,
    ["currStrScale"] = 1,
    ["currDexScale"] = 1,
    ["currConScale"] = 1,
    ["currIntScale"] = 1,
    ["neiliMaxScale"] = 1,
    ["effectStrScale"] = 1, 
    ["effectDexScale"] = 1, 
    ["effectConScale"] = 1, 
    ["effectIntScale"] = 1, 
    ["zhaoAtkScale"] = 1,
    ["neiLiLimitScale"] = 1,
    ["zhaoHitReduceRate"] = 0, -- 普通招式命中率（跟战斗原计算公式无关，单独计算，只有在原结果为命中时生效）
    ["zhaoIsHit"] = 0,
    
    
    ["qiRecover"] = 0, -- 气血恢复时的额外加成
    ["neiliRecover"] = 0, -- 内力恢复时的额外加成
    ["enterDreamRate"] = 0, -- 入梦概率的额外加成
    ["soberRecover"] = 0, -- 清醒值恢复时的额外加成
    ["activeNeiliCost"] = 0, -- 使用主动技能内力消耗加成
    ["activeNeiliCostPercent"] = 1, -- 使用主动技能内力消耗加成百分比
    ["jiaLiNeiliCost"] = 0, -- 普通技能加力内力消耗加成值
    ["jiaLiNeiliCostPercent"] = 1, -- 普通技能加力内力消耗加成值百分比
    ["useRestFailRate"] = 0, -- 休息使用失败概率(初始值为0)
    
    
    ["drEmgrAttackFailRate"] = 0, -- 情绪附带普通攻击攻击失败概率
    ["drEmotionAttackRate"] = 0, -- 情绪附带攻击加成概率
    ["drEmotionAttackPercent"] = 0, -- 情绪附带攻击加成倍率
    ["drEmgrTargetAttackFailRate"] = 0, -- 对方攻击失败
    ["drEmotionTargetAtkRate"] = 0, -- 情绪附带对方攻击加成概率
    ["drEmotionTargetAtkPercent"] = 0, -- 情绪附带对方攻击加成概率
    ["drTiliConsumeRate"] = 0, -- 情绪附带普攻体力消耗减少概率
    ["drTiliConsumePercent"] = 0, -- 情绪附带普攻体力消耗减少倍数
    ["drActiveZhaoUseFailRate"] = 0, -- 主动技能释放失败概率
    ["drFailRecoverQiRate"] = 0, -- 梦境恢复气血效果失败概率
    ["drSellItemMoneyAddPercent"] = 1, -- 梦境商人销售物品碎银价格变动百分比
    ["drAddDreamPointsEffectAdditionPercent"] = 1, -- 梦境中获得碎银效果加成百分比

    ["pijuanMax"] = 200, -- 疲倦值最大值

    ["drRoleMoneyAdd"] = 0,
    ["drRoleWeightAdd"] = 0,

    ["talkWeight1"] = 0,
    ["talkWeightPercent1"] = 0,
    ["talkWeight2"] = 0,
    ["talkWeightPercent2"] = 0,
    ["talkWeight3"] = 0,
    ["talkWeightPercent3"] = 0,
    ["talkWeight4"] = 0,
    ["talkWeightPercent4"] = 0,
    ["talkWeight5"] = 0,
    ["talkWeightPercent5"] = 0,
    ["talkWeight6"] = 0,
    ["talkWeightPercent6"] = 0,
    ["talkWeight7"] = 0,
    ["talkWeightPercent7"] = 0,
    ["randomEventWeight1"] = 0,
    ["randomEventWeightPercent1"] = 0,
    ["randomEventWeight2"] = 0,
    ["randomEventWeightPercent2"] = 0,
    ["randomEventWeight3"] = 0,
    ["randomEventWeightPercent3"] = 0,
    ["randomEventWeight4"] = 0,
    ["randomEventWeightPercent4"] = 0,
    ["randomEventWeight5"] = 0,
    ["randomEventWeightPercent5"] = 0,
    ["randomEventWeight6"] = 0,
    ["randomEventWeightPercent6"] = 0,
    ["randomEventWeight7"] = 0,
    ["randomEventWeightPercent7"] = 0,
    ["boxEventWeight1"] = 0,
    ["boxEventWeightPercent1"] = 0,
    ["boxEventWeight2"] = 0,
    ["boxEventWeightPercent2"] = 0,
    ["boxEventWeight3"] = 0,
    ["boxEventWeightPercent3"] = 0,
    ["boxEventWeight4"] = 0,
    ["boxEventWeightPercent4"] = 0,
    ["boxEventWeight5"] = 0,
    ["boxEventWeightPercent5"] = 0,
    ["boxEventWeight6"] = 0,
    ["boxEventWeightPercent6"] = 0,
    ["boxEventWeight7"] = 0,
    ["boxEventWeightPercent7"] = 0,
    ["newFloorRate"] = 0,
    ["newFloorRatePercent"] = 0,
    ["battleWinRate"] = 0,
    ["battleWinRatePercent"] = 0,
    ["battleLoseRate"] = 0,
    ["battleLoseRatePercent"] = 0,
    ["fightWinRate"] = 0,
    ["fightWinRatePercent"] = 0,
    ["fightLoseRate"] = 0,
    ["fightLoseRatePercent"] = 0,
    ["talkRate"] = 0,
    ["talkRatePercent"] = 0,
    ["randEventRate"] = 0,
    ["randEventRatePercent"] = 0,
}

function RoleModule_GetBaseAttr_GetDefault.getBaseAttr(module, self, attrName)
    local value = defaultAttrValueMap[attrName]
    if value == nil then
        return false
    end

    return true, value
end

return RoleModule_GetBaseAttr_GetDefault
000000000