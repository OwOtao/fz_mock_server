local abstract = require("third.class.abstract")

--@desc
local FightFormula = require("app.FightSystem.FightFormula")

local IBuffEffectDamageCalclator = {
    getDamage = function(self)
    end
}

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.ABuffEffectDamageCalclator#IBuffEffectDamageCalclator]
local ABuffEffectDamageCalclator = {}

--@desc:
--@author:Seven
--@time:2023-12-05 14:57:45
--@data:
--@buff: [src.app.FightSystem.FightRole.CharacterBuff.Buffs.IFightCharacterBuff#IFightCharacterBuff]
--@return:
function ABuffEffectDamageCalclator:initCalclator(data, buff)
    self.__data = data

    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BasicFightCharacterBuff#BasicFightCharacterBuff]
    self.__buff = buff

    self.__character = self.__buff:getBuffOwner()
end

function ABuffEffectDamageCalclator:getHurtDegreeID()
    return self.__data.hurtDegreeID
end

function ABuffEffectDamageCalclator:getAvgQiAtk()
    return FightFormula:calQiAvgDamage(self.__character, self.__character:getTarget())
end

function ABuffEffectDamageCalclator:getHurtGrow()
    return self:getDynamicArg(self.__data.hurtGrow)
end

function ABuffEffectDamageCalclator:getHurtBase()
    return self:getDynamicArg(self.__data.hurtBase)
end

function ABuffEffectDamageCalclator:getHurtTimes()
    return self:getDynamicArg(self.__data.hurtTimes)
end

function ABuffEffectDamageCalclator:getHealReduceqiValid()
    return self.__data.healReduceqiValid or ""
end

function ABuffEffectDamageCalclator:getHealReduceneiliValid()
    return self.__data.healReduceneiliValid or ""
end

function ABuffEffectDamageCalclator:getHealReduceqi()
    local validConfig = self:getHealReduceqiValid()

    if validConfig == "" or validConfig == "-" then
        return 0
    end

    local attrIds = string.split(validConfig, "#")
    local totalValue = 0
    for _, attrId in ipairs(attrIds) do
        totalValue = totalValue + self.__character:getAttr(attrId)
    end

    return totalValue
end

function ABuffEffectDamageCalclator:getHealReduceqiCan()
    return self:getDynamicArg(self.__data.healReduceqiCan)
end

function ABuffEffectDamageCalclator:getHealReduceneili()
    local validConfig = self:getHealReduceneiliValid()

    if validConfig == "" or validConfig == "-" then
        return 0
    end

    local attrIds = string.split(validConfig, "#")
    local totalValue = 0
    for _, attrId in ipairs(attrIds) do
        totalValue = totalValue + self.__character:getAttr(attrId)
    end

    return totalValue
end

function ABuffEffectDamageCalclator:getHealReduceneiliCan()
    return self:getDynamicArg(self.__data.healReduceneiliCan)
end

function ABuffEffectDamageCalclator:getQiatkFactor()
    return self.__character:getAttr("qiatkFactor")
end

function ABuffEffectDamageCalclator:getQiatkFactorCan()
    return self:getDynamicArg(self.__data.qiatkFactorCan)
end

--@desc: 角色综合抗性系数
--@author:Seven
--@time:2026-01-10
function ABuffEffectDamageCalclator:getComprehensiveResistanceFactor()
    local factor = 1
        - self:getHealReduceqi() * self:getHealReduceqiCan()
        - self:getHealReduceneili() * self:getHealReduceneiliCan()
        + self:getQiatkFactor() * self:getQiatkFactorCan()

    return factor
end

local Trie = require("third.tree.Trie")
local paramTrie = Trie:create()
paramTrie:add("-")

function ABuffEffectDamageCalclator:getDynamicArg(dynamicArgName)
    local retValue = dynamicArgName

    local array = paramTrie:partitionToArray(dynamicArgName)
    local isPositive = 1

    if #array == 2 then
        if array[1] == "-" then
            isPositive = -1
        end
        dynamicArgName = array[2]
    end

    if dynamicArgName == "dynamicArg1" then
        retValue = tonumber(self.__buff:getBuffDynamicArg("dynamicArg1")) * isPositive
    elseif dynamicArgName == "dynamicArg2" then
        retValue = tonumber(self.__buff:getBuffDynamicArg("dynamicArg2")) * isPositive
    elseif dynamicArgName == "dynamicArg3" then
        retValue = tonumber(self.__buff:getBuffDynamicArg("dynamicArg3")) * isPositive
    else
        retValue = tonumber(dynamicArgName) * isPositive
    end

    return retValue
end

return abstract("ABuffEffectDamageCalclator", {IBuffEffectDamageCalclator}, ABuffEffectDamageCalclator)
000000000