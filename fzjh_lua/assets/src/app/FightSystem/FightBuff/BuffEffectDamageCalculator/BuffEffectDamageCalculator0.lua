local class = require("third.class.NewClass")
local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local AbsBuffEffectDamageCalclator = require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.AbsBuffEffectDamageCalclator")

local BuffEffectDamageCalclator0 = {}

-- # computingType= 0
-- Buff效果值 = (攻击伤害强度系数 * 伤害增长倍率 + 效果基础伤害) / 生效次数 * (1-角色气血恢复抗性*气血恢复抗性系数-角色内力恢复抗性*内力恢复抗性系数+角色被动普通气血伤害系数*被动普通气血伤害修正系数)
function BuffEffectDamageCalclator0:getDamage()
    local hurtValue = ZhaoHurtDegreeFactory:createHurtDegreeGroup(self:getHurtDegreeID(), self.__buffNeeded:getAttacker()):getHurtValue()
    local comprehensiveResistanceFactor = self:getComprehensiveResistanceFactor()
    local retValue = (hurtValue * self:getHurtGrow() + self:getHurtBase()) / self:getHurtTimes() * comprehensiveResistanceFactor
    
    retValue = tonumber(string.format("%." .. tostring(self.__data.computingRound) .. "f", retValue))

    print(
        "BuffEffectDamageCalculator0.buff效果计算:",
        "(",
        hurtValue,
        "*",
        self:getHurtGrow(),
        "+",
        self:getHurtBase(),
        ")",
        "/",
        self:getHurtTimes(),
        "*",
        comprehensiveResistanceFactor,
        "=",
        retValue
    )

    return retValue
end

return class("BuffEffectDamageCalclator0", {AbsBuffEffectDamageCalclator}, BuffEffectDamageCalclator0)
00000000000