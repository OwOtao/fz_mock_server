local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")
local abstract = require("third.class.abstract")

local IBuffEffectDamageCalclator = {
    getDamage = function(self)
    end
}

--@SuperType [src.app.FightSystem.FightBuff.BuffEffectDamageCalculator.AbsBuffEffectDamageCalclator#IBuffEffectDamageCalclator]
local AbsBuffEffectDamageCalclator = {}

function AbsBuffEffectDamageCalclator:init(data, buffNeeded)
    self.__data = data
    self.__buffNeeded = buffNeeded
end

function AbsBuffEffectDamageCalclator:setBuffNeeded(buffNeeded)
    self.__buffNeeded = buffNeeded
end

function AbsBuffEffectDamageCalclator:getHurtDegreeID()
    return self.__data.hurtDegreeID
end

function AbsBuffEffectDamageCalclator:getAvgQiAtk()
    return self.__buffNeeded:getAutoAvgAtk()
end

function AbsBuffEffectDamageCalclator:getHurtGrow()
    return self.__buffNeeded:getDynamicArg(self.__data.hurtGrow)
end

function AbsBuffEffectDamageCalclator:getHurtBase()
    return self.__buffNeeded:getDynamicArg(self.__data.hurtBase)
end

function AbsBuffEffectDamageCalclator:getHurtTimes()
    return self.__buffNeeded:getDynamicArg(self.__data.hurtTimes)
end

function AbsBuffEffectDamageCalclator:getHealReduceqiValid()
    return self.__data.healReduceqiValid or ""
end

function AbsBuffEffectDamageCalclator:getHealReduceneiliValid()
    return self.__data.healReduceneiliValid or ""
end

function AbsBuffEffectDamageCalclator:getHealReduceqi()
    local validConfig = self:getHealReduceqiValid()

    if validConfig == "" or validConfig == "-" then
        return 0
    end

    local attrIds = string.split(validConfig, "#")
    local totalValue = 0
    for _, attrId in ipairs(attrIds) do
        totalValue = totalValue + self.__buffNeeded:getAttr(attrId)
    end

    return totalValue
end

function AbsBuffEffectDamageCalclator:getHealReduceqiCan()
    return self.__buffNeeded:getDynamicArg(self.__data.healReduceqiCan)
end

function AbsBuffEffectDamageCalclator:getHealReduceneili()
    local validConfig = self:getHealReduceneiliValid()

    if validConfig == "" or validConfig == "-" then
        return 0
    end

    local attrIds = string.split(validConfig, "#")
    local totalValue = 0
    for _, attrId in ipairs(attrIds) do
        totalValue = totalValue + self.__buffNeeded:getAttr(attrId)
    end

    return totalValue
end

function AbsBuffEffectDamageCalclator:getHealReduceneiliCan()
    return self.__buffNeeded:getDynamicArg(self.__data.healReduceneiliCan)
end

function AbsBuffEffectDamageCalclator:getQiatkFactor()
    return self.__buffNeeded:getAttr("qiatkFactor")
end

function AbsBuffEffectDamageCalclator:getQiatkFactorCan()
    return self.__buffNeeded:getDynamicArg(self.__data.qiatkFactorCan)
end

--@desc: 角色综合抗性系数
--@author:Seven
--@time:2026-01-10
function AbsBuffEffectDamageCalclator:getComprehensiveResistanceFactor()
    local factor = 1
        - self:getHealReduceqi() * self:getHealReduceqiCan()
        - self:getHealReduceneili() * self:getHealReduceneiliCan()
        + self:getQiatkFactor() * self:getQiatkFactorCan()

    return factor
end

function AbsBuffEffectDamageCalclator:setHurtDegreeVars(hurtDegree)
    local variables = hurtDegree:getVariables()
    local var1 = nil
    local var2 = nil
    local var3 = nil

    if #variables > 0 then
        if variables[1] ~= nil then
            var1 = self.__buffNeeded:getAttr(variables[1])
        end

        if variables[2] ~= nil then
            var2 = self.__buffNeeded:getAttr(variables[2])
        end

        if variables[3] ~= nil then
            var3 = self.__buffNeeded:getAttr(variables[3])
        end
        hurtDegree:setDynamicVars({var1, var2, var3})
    end

    if #hurtDegree:getTargetVariables() > 0 then
        variables = hurtDegree:getTargetVariables()

        if variables[1] ~= nil then
            var1 = self.__buffNeeded:getTargetAttr(variables[1])
        end

        if variables[2] ~= nil then
            var2 = self.__buffNeeded:getTargetAttr(variables[2])
        end

        if variables[3] ~= nil then
            var3 = self.__buffNeeded:getTargetAttr(variables[3])
        end
        hurtDegree:setTargetDynamicVars({var1, var2, var3})
    end

    self:setWeaponHurtDegreeVars(hurtDegree)
end

function AbsBuffEffectDamageCalclator:setWeaponHurtDegreeVars(hurtDegree)
    if #hurtDegree:getVariablesW() > 0 then
        local variables = hurtDegree:getVariablesW()
        BuffSystemUtil:log("hurtDegree:getVariablesW()", hurtDegree:getVariablesW())
        local finalVars = {}
        for i, var in ipairs(variables) do
            table.insert(finalVars, self.__buffNeeded:getSelfWeaponAttr(var))
        end
        hurtDegree:setWDynamicVars(finalVars)
    end

    if #hurtDegree:getVariablesWTarget() > 0 then
        local variables = hurtDegree:getVariablesWTarget()
        BuffSystemUtil:log("hurtDegree:getVariablesWTarget()", hurtDegree:getVariablesWTarget())
        local finalVars = {}
        for i, var in ipairs(variables) do
            table.insert(finalVars, self.__buffNeeded:getTargetWeaponAttr(var))
        end
        hurtDegree:setTargetWDynamicVars(finalVars)
    end
end

return abstract("AbsBuffEffectDamageCalclator", {IBuffEffectDamageCalclator}, AbsBuffEffectDamageCalclator)
00000000000