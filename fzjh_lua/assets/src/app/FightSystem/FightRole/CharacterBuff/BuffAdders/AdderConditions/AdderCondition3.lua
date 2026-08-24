--[[
    author:Seven
    time:2023-03-08 15:06:28
    desc: 
            -- 0=每个目标指定Buff数量判断通过
            -- 1=每个目标指定Buff数量判断不通过
            -- 2=任意目标指定Buff数量判断通过
            -- 3=任意目标指定Buff数量判断不通过

            -- 判断条件参数（多个用@间隔）：BuffID@判断方式@判断值；

            -- BuffID：需要判断持有数量的BuffID
            -- 判断方式：1=小于等于/2=大于等于/3=等于/4=小于/5=大于
            -- 判断值：判断数值，填整数

            1. BuffID@判断方式@判断值
            2. 判断方式：1=小于等于/2=大于等于/3=等于/4=小于/5=大于
            3. 判断值：填整数或者支持动态参数`dynamicLaun`，动态参数来自Buff效果18的`argsParam`值传递
]]
local AAdderCondition = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition")

--@RefType [Constants]
local BUFF_CONST = require("app.FightSystem.FightBuff.Constants")
local ADDER_CONDITION_TYPE = BUFF_CONST.ADDER_CONDITION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#AAdderCondition]
local AdderCondition3 = {
    __type = ADDER_CONDITION_TYPE.HAS_BUFF_LAYER
}

function AdderCondition3:create(conditonTarget, conditionResultType, conditionParams)
    return AdderCondition3.new():__init(conditonTarget, conditionResultType, conditionParams)
end

function AdderCondition3:__init(conditonTarget, conditionResultType, conditionParams)
    self.__conditionTarget = conditonTarget

    self.__conditionResultType = tonumber(conditionResultType)

    self.__conditionParams = conditionParams

    return self
end

--@desc: 判断是否成立
--@author:Seven
--@time:2023-03-08 16:37:35
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AdderCondition3:__checkOneTargetConditions(target, conditionArray)
    local results = {}

    -- BuffID@判断方式@判断值
    local condBuffId = conditionArray[1]

    local logicalSymbol = tonumber(conditionArray[2])

    local condValue = tonumber(conditionArray[3])

    if condValue == nil then
        condValue = self.__adder:getAdderOtherDynamicArg(conditionArray[3])
    end

    local count = target:getBuffLayerCountByBuffId(condBuffId)

    -- 1=小于等于/2=大于等于/3=等于/4=小于/5=大于
    if logicalSymbol == 1 then
        return count <= condValue
    elseif logicalSymbol == 2 then
        return count >= condValue
    elseif logicalSymbol == 3 then
        return count == condValue
    elseif logicalSymbol == 4 then
        return count < condValue
    elseif logicalSymbol == 5 then
        return count > condValue
    end

    error(" AdderCondition3:__checkOneTargetConditions buff层数判断方式未知 :" .. tostring(logicalSymbol))
end

function AdderCondition3:matchCondititon()
    local targetArray = self:__analysisTargetArray(self.__conditionTarget)

    local buffCountConditionArray = string.split(self.__conditionParams, "@")

    local targetResults = {}
    for _, character in ipairs(self.__targetArray) do
        table.insert(targetResults, self:__checkOneTargetConditions(character, buffCountConditionArray))
    end

    -- 0=每个目标指定Buff数量判断通过
    if self.__conditionResultType == 0 then
        return table.all(targetResults)
    end

    -- 1=每个目标指定Buff数量判断不通过
    if self.__conditionResultType == 1 then
        return not table.any(targetResults)
    end

    -- 2=任意目标指定Buff数量判断通过
    if self.__conditionResultType == 2 then
        return table.any(targetResults)
    end

    -- 3=任意目标指定Buff数量判断不通过
    if self.__conditionResultType == 3 then
        return not table.all(targetResults)
    end

    error("AdderCondition3:matchCondititon 未知判断类型：" .. tostring(self.__conditionResultType))
end

return newClass("AdderCondition3", {AAdderCondition}, AdderCondition3)
00000000000000