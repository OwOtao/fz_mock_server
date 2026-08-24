--[[
    author:Seven
    time:2023-03-08 15:06:28
    desc: 
        判断条件ID：20；判断条件：角色[条件属性值]与[需求属性值*判断值]对比；
               判断结果类型：0=每个目标属性判断通过、1=每个目标属性判断不通过、
                             2=任意目标属性判断通过、3=任意目标属性判断不通过
               判断条件参数（多个用@间隔）：条件来源属性ID@判断方式@需求来源属性ID@判断值；
                     条件来源属性ID与需求来源属性ID：角色属性ID（表[角色属性管理]）
                     判断方式：1=小于等于/2=大于等于/3=等于/4=小于/5=大于；
                     判断值：填0~1之间小数。


]]
local AAdderCondition = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition")

--@RefType [Constants]
local BUFF_CONST = require("app.FightSystem.FightBuff.Constants")
local ADDER_CONDITION_TYPE = BUFF_CONST.ADDER_CONDITION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#AAdderCondition]
local AdderCondition20 = {
    __type = ADDER_CONDITION_TYPE.CHARACTER_ATTRS
}

function AdderCondition20:create(conditonTarget, conditionResultType, conditionParams)
    return AdderCondition20.new():__init(conditonTarget, conditionResultType, conditionParams)
end

function AdderCondition20:__init(conditonTarget, conditionResultType, conditionParams)
    self.__conditionTarget = conditonTarget

    self.__conditionResultType = tonumber(conditionResultType)

    self.__conditionParams = conditionParams

    return self
end

--@desc: 判断是否成立
--@author:Seven
--@time:2023-03-08 16:37:35
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AdderCondition20:__checkOneTargetConditions(target, attrsArray)
    local attrName = attrsArray[1]
    local logicalSymbol = tonumber(attrsArray[2])
    local needAttrName = attrsArray[3]
    local condValue = tonumber(attrsArray[4])

    local value = target:getAttr(attrName)

    local needValue = target:getAttr(needAttrName)

    if logicalSymbol == 1 then
        return value <= needValue * condValue
    end

    if logicalSymbol == 2 then
        return value >= needValue * condValue
    end

    if logicalSymbol == 3 then
        return value == needValue * condValue
    end

    if logicalSymbol == 4 then
        return value < needValue * condValue
    end

    if logicalSymbol == 5 then
        return value > needValue * condValue
    end

    error("AdderCondition20:__checkOneTargetConditions 添加器属性判断 条件参数中 判断类型 未知：" .. tostring(logicalSymbol))
end

function AdderCondition20:matchCondititon()
    local targetArray = self:__analysisTargetArray(self.__conditionTarget)

    local attrsArray = string.split(self.__conditionParams, "@")

    local targetResults = {}
    for _, character in ipairs(self.__targetArray) do
        table.insert(targetResults, self:__checkOneTargetConditions(character, attrsArray))
    end

    -- 0=每个目标属性判断通过
    if self.__conditionResultType == 0 then
        return table.all(targetResults)
    end

    --1=每个目标属性判断不通过
    if self.__conditionResultType == 1 then
        return not table.any(targetResults)
    end

    -- 2=任意目标属性判断通过
    if self.__conditionResultType == 2 then
        return table.any(targetResults)
    end

    --3=任意目标属性判断不通过
    if self.__conditionResultType == 3 then
        return not table.all(targetResults)
    end

    error("AdderCondition20:matchCondititon 未知判断类型：" .. tostring(self.__conditionResultType))
end

return newClass("AdderCondition20", {AAdderCondition}, AdderCondition20)
0000000000000