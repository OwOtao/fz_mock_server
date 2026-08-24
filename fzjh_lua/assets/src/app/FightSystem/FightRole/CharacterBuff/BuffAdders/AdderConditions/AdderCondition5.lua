--[[
    author:Seven
    time: 2025-07-31 21:24
    desc: 不持有特定BuffClass
        0=每个目标判断条件配置的每一个BuffClass都通过、
        1=每个目标判断条件配置的任意一个BuffClass通过、
        2=任意目标判断条件配置的每一个BuffClass都通过、
        3=任意目标判断条件配置的任意一个BuffClass通过

            -- 判断条件参数（多个用@间隔）：BuffClass@BuffClass；
]]
local AAdderCondition = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition")

--@RefType [Constants]
local BUFF_CONST = require("app.FightSystem.FightBuff.Constants")
local ADDER_CONDITION_TYPE = BUFF_CONST.ADDER_CONDITION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#AAdderCondition]
local AdderCondition5 = {
    __type = ADDER_CONDITION_TYPE.HAS_NOT_BUFF_BY_CLASS
}

function AdderCondition5:create(conditonTarget, conditionResultType, conditionParams)
    return AdderCondition5.new():__init(conditonTarget, conditionResultType, conditionParams)
end

function AdderCondition5:__init(conditonTarget, conditionResultType, conditionParams)
    self.__conditionTarget = conditonTarget

    self.__conditionResultType = tonumber(conditionResultType)

    self.__conditionParams = conditionParams

    return self
end

--@desc: 判断是否成立
--@author:Seven
--@time:2025-07-31 21:27:07
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AdderCondition5:__checkOneTargetConditions(target, conditionArray)
    local results = {}

    -- BuffClass@BuffClass...
    for _, BuffClass in ipairs(conditionArray) do
        table.insert(results, target:hasCharacterBuffByClass(BuffClass) ~= true)
    end
    return results
end

function AdderCondition5:matchCondititon()
    self:__analysisTargetArray(self.__conditionTarget)

    local BuffClassConditionArray = string.split(self.__conditionParams, "@")

    local targetResults = {}
    for _, character in ipairs(self.__targetArray) do
        table.insert(targetResults, self:__checkOneTargetConditions(character, BuffClassConditionArray))
    end

    -- 0=每个目标判断条件配置的每一个BuffClass都通过
    if self.__conditionResultType == 0 then
        return table.all(
            table.getMap(
                targetResults,
                function(index, results)
                    return index, table.all(results)
                end
            )
        )
    end

    -- 1=每个目标判断条件配置的任意一个BuffClass通过
    if self.__conditionResultType == 1 then
        return table.all(
            table.getMap(
                targetResults,
                function(index, results)
                    return index, table.any(results)
                end
            )
        )
    end

    -- 2=任意目标判断条件配置的每一个BuffClass都通过
    if self.__conditionResultType == 2 then
        return table.any(
            table.getMap(
                targetResults,
                function(index, results)
                    return index, table.all(results)
                end
            )
        )
    end

    -- 3=任意目标判断条件配置的任意一个BuffClass通过
    if self.__conditionResultType == 3 then
        return table.any(
            table.getMap(
                targetResults,
                function(index, results)
                    return index, table.any(results)
                end
            )
        )
    end

    error("AdderCondition5:matchCondititon 未知判断类型：" .. tostring(self.__conditionResultType))
end

return newClass("AdderCondition5", {AAdderCondition}, AdderCondition5)
000000000000000