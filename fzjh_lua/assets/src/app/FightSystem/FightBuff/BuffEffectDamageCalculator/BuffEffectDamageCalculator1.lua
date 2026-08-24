local class = require("third.class.NewClass")
local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local AbsBuffEffectDamageCalclator = require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.AbsBuffEffectDamageCalclator")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
local BuffEffectDamageCalclator1 = {}

-- # computingType = 1
-- Buff效果值 = (avgqiatk * 攻击伤害强度系数 * 伤害增长倍率 + 效果基础伤害) / 生效次数 * (1-角色气血恢复抗性*气血恢复抗性系数-角色内力恢复抗性*内力恢复抗性系数+角色被动普通气血伤害系数*被动普通气血伤害修正系数)
function BuffEffectDamageCalclator1:getDamage()
    local hurtValue = ZhaoHurtDegreeFactory:createHurtDegreeGroup(self:getHurtDegreeID(), self.__buffNeeded:getAttacker()):getHurtValue()

    local comprehensiveResistanceFactor = self:getComprehensiveResistanceFactor()
    local retValue = (self:getAvgQiAtk() * hurtValue * self:getHurtGrow() + self:getHurtBase()) / self:getHurtTimes() * comprehensiveResistanceFactor

    retValue = tonumber(string.format("%." .. tostring(self.__data.computingRound) .. "f", retValue))

    FightUtil:printFormatLog(
        "BuffEffectDamageCalculator1.buff效果计算: (%s * %s * %s + %s) / %s * %s = %s",
        self:getAvgQiAtk(),
        hurtValue,
        self:getHurtGrow(),
        self:getHurtBase(),
        self:getHurtTimes(),
        comprehensiveResistanceFactor,
        retValue
    )

    -- print(
    --     "BuffEffectDamageCalculator1.buff效果计算:",
    --     "(",
    --     self:getAvgQiAtk(),
    --     "*",
    --     hurtValue,
    --     "*",
    --     self:getHurtGrow(),
    --     "+",
    --     self:getHurtBase(),
    --     ")",
    --     "/",
    --     self:getHurtTimes(),
    --     "*",
    --     "(",
    --     1,
    --     "-",
    --     self:getHealReduceqi(),
    --     "*",
    --     self:getHealReduceqiCan(),
    --     "-",
    --     self:getHealReduceneili(),
    --     "*",
    --     self:getHealReduceneiliCan(),
    --     "+",
    --     self:getQiatkFactor(),
    --     "*",
    --     self:getQiatkFactorCan(),
    --     ")",
    --     "=",
    --     retValue
    -- )

    return retValue
end

return class("BuffEffectDamageCalclator1", {AbsBuffEffectDamageCalclator}, BuffEffectDamageCalclator1)
0000000000000000