local class = require("third.class.NewClass")
local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local ABuffEffectDamageCalclator = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.ABuffEffectDamageCalclator")

local BuffEffectDamageCalclator10 = {}

function BuffEffectDamageCalclator10:getDamage()
    local hurtValue = ZhaoHurtDegreeFactory:createHurtDegreeGroup(self:getHurtDegreeID(), self.__character):getHurtValue()

    -- # computingType=0
    -- Buff效果值 = (攻击伤害强度系数 * 伤害增长倍率 + 效果基础伤害) / 生效次数 * (1-角色气血恢复抗性*气血恢复抗性系数-角色内力恢复抗性*内力恢复抗性系数)
    local retValue =
        (hurtValue * self:getHurtGrow() + self:getHurtBase()) / self:getHurtTimes() *
        (1 - self:getHealReduceqi() * self:getHealReduceqiCan() - self:getHealReduceneili() * self:getHealReduceneiliCan())

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
        "(",
        1,
        "-",
        self:getHealReduceqi(),
        "*",
        self:getHealReduceqiCan(),
        "-",
        self:getHealReduceneili(),
        "*",
        self:getHealReduceneiliCan(),
        ")",
        "=",
        retValue
    )

    return retValue
end

return class("BuffEffectDamageCalclator10", {ABuffEffectDamageCalclator}, BuffEffectDamageCalclator10)
000000