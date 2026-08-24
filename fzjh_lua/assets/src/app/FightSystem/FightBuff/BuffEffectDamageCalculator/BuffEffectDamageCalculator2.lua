local class = require("third.class.NewClass")
local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local AbsBuffEffectDamageCalclator = require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.AbsBuffEffectDamageCalclator")

local BuffEffectDamageCalclator2 = {}

-- # computingType = 2
-- Buff效果值 = 效果基础伤害 * (1-角色气血恢复抗性*气血恢复抗性系数-角色内力恢复抗性*内力恢复抗性系数+角色被动普通气血伤害系数*被动普通气血伤害修正系数)
function BuffEffectDamageCalclator2:getDamage()
    local comprehensiveResistanceFactor = self:getComprehensiveResistanceFactor()
    local hurtValue = self:getHurtBase() * comprehensiveResistanceFactor

    hurtValue = tonumber(string.format("%." .. tostring(self.__data.computingRound) .. "f", hurtValue))

    print(
        "BuffEffectDamageCalculator2.buff效果计算:",
        self:getHurtBase(),
        "*",
        comprehensiveResistanceFactor,
        "=",
        hurtValue
    )
    return hurtValue
end

return class("BuffEffectDamageCalclator2", {AbsBuffEffectDamageCalclator}, BuffEffectDamageCalclator2)
00000