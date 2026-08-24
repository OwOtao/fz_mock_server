--[[
    author:Seven
    time:2023-03-08 15:06:28
    desc: 
        判断条件ID：2；判断条件：持有特定BuffClass；
               判断结果类型：0=每个目标持有判断条件配置的每一个BuffClass、1=每个目标持有判断条件配置的任意一个BuffClass、
                             2=任意目标持有判断条件配置的每一个BuffClass、3=任意目标持有判断条件配置的任意一个BuffClass
               判断条件参数（多个用@间隔）：BuffClass@BuffClass；
]]
local AAdderCondition = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition")

--@RefType [Constants]
local BUFF_CONST = require("app.FightSystem.FightBuff.Constants")
local ADDER_CONDITION_TYPE = BUFF_CONST.ADDER_CONDITION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#AAdderCondition]
local AdderCondition2 = {
    __type = ADDER_CONDITION_TYPE.HAS_BUFF_CLASS
}

function AdderCondition2:create(conditonTarget, conditionResultType, conditionParams)
    return AdderCondition2.new():__init(conditonTarget, conditionResultType, conditionParams)
end

function AdderCondition2:__init(conditonTarget, conditionResultType, conditionParams)
    self.__conditionTarget = conditonTarget

    self.__conditionResultType = tonumber(conditionResultType)

    self.__conditionParams = conditionParams

    return self
end

--@desc: 判断是否成立
--@author:Seven
--@time:2023-03-08 16:37:35
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AdderCondition2:__checkOneTargetConditions(target, buffClasses)
    local results = {}

    for _, buffClass in ipairs(buffClasses) do
        table.insert(results, target:hasCharacterBuffByClass(buffClass))
    end

    return results
end

function AdderCondition2:matchCondititon()
    local targetArray = self:__analysisTargetArray(self.__conditionTarget)

    local conditionBuffClasses = string.split(self.__conditionParams, "@")

    local targetResults = {}
    for _, character in ipairs(self.__targetArray) do
        table.insert(targetResults, self:__checkOneTargetConditions(character, conditionBuffClasses))
    end

    -- 0=每个目标持有判断条件配置的每一个BuffClass
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

    --1=每个目标持有判断条件配置的任意一个BuffClass
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

    -- 2=任意目标持有判断条件配置的每一个BuffClass
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

    --3=任意目标持有判断条件配置的任意一个BuffClass
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

    error("AdderCondition2:matchCondititon 未知判断类型：" .. tostring(self.__conditionResultType))
end

return newClass("AdderCondition2", {AAdderCondition}, AdderCondition2)
000000