--[[
    author:Seven
    time:2023-03-08 15:06:28
    desc: 
        判断条件ID：11；判断条件：是否持有武器；
               判断结果类型：0=每个目标都符合条件、1=任意一个目标符合条件
               判断条件参数：0=不持有武器(空手)，1=持有武器


]]
local AAdderCondition = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition")

--@RefType [Constants]
local BUFF_CONST = require("app.FightSystem.FightBuff.Constants")
local ADDER_CONDITION_TYPE = BUFF_CONST.ADDER_CONDITION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#AAdderCondition]
local AdderCondition11 = {
    __type = ADDER_CONDITION_TYPE.HAS_WEAPON
}

function AdderCondition11:create(conditonTarget, conditionResultType, conditionParams)
    return AdderCondition11.new():__init(conditonTarget, conditionResultType, conditionParams)
end

function AdderCondition11:__init(conditonTarget, conditionResultType, conditionParams)
    self.__conditionTarget = conditonTarget

    self.__conditionResultType = tonumber(conditionResultType)

    self.__conditionParams = tonumber(conditionParams)

    return self
end

--@desc: 判断是否成立
--@author:Seven
--@time:2023-03-08 16:37:35
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AdderCondition11:__checkOneTargetConditions(target, conditionValue)
    if conditionValue == 0 then
        return target:weaponIsEmptyHand()
    elseif conditionValue == 1 then
        return not target:weaponIsEmptyHand()
    end

    error("AdderCondition11:__checkOneTargetConditions 添加器类型11，判断条件参数 未知类型：" .. tostring(conditionValue))
end

function AdderCondition11:matchCondititon()
    local targetArray = self:__analysisTargetArray(self.__conditionTarget)

    local targetResults = {}
    for _, character in ipairs(self.__targetArray) do
        table.insert(targetResults, self:__checkOneTargetConditions(character, self.__conditionParams))
    end

    -- 0=每个目标都符合条件
    if self.__conditionResultType == 0 then
        return table.all(targetResults)
    end

    --1=任意一个目标符合条件
    if self.__conditionResultType == 1 then
        return table.any(targetResults)
    end

    error("AdderCondition11:matchCondititon 未知判断类型：" .. tostring(self.__conditionResultType))
end

return newClass("AdderCondition11", {AAdderCondition}, AdderCondition11)
0000000000000