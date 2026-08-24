--[[
    author:Seven
    time:2023-03-08 15:06:28
    desc: 
        判断条件ID：10；判断条件：持有指定武器类型；
               判断结果类型：0=每个目标持有判断条件配置的每一个武器一级分类ID、1=每个目标持有判断条件配置的任意一个武器一级分类ID、
                             2=任意目标持有判断条件配置的每一个武器一级分类ID、3=任意目标持有判断条件配置的任意一个武器一级分类ID
               判断条件参数（多个用@间隔）：武器一级分类ID@武器一级分类ID；

]]
local AAdderCondition = require("app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition")

--@RefType [Constants]
local BUFF_CONST = require("app.FightSystem.FightBuff.Constants")
local ADDER_CONDITION_TYPE = BUFF_CONST.ADDER_CONDITION_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#AAdderCondition]
local AdderCondition10 = {
    __type = ADDER_CONDITION_TYPE.HAS_WEAPON_FIRST_TYPE
}

function AdderCondition10:create(conditonTarget, conditionResultType, conditionParams)
    return AdderCondition10.new():__init(conditonTarget, conditionResultType, conditionParams)
end

function AdderCondition10:__init(conditonTarget, conditionResultType, conditionParams)
    self.__conditionTarget = conditonTarget

    self.__conditionResultType = tonumber(conditionResultType)

    self.__conditionParams = conditionParams

    return self
end

--@desc: 判断是否成立
--@author:Seven
--@time:2023-03-08 16:37:35
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AdderCondition10:__checkOneTargetConditions(target, weaponFirstTypeArray)
    local results = {}
    
    local weapon = target:getWeapon()

    for _, weaponFirstType in ipairs(weaponFirstTypeArray) do
        if weapon:getFirstType() == weaponFirstType then
            table.insert(results, true)
        else
            table.insert(results, false)
        end
    end

    return results
end

function AdderCondition10:matchCondititon()
    local targetArray = self:__analysisTargetArray(self.__conditionTarget)

    local conditionWeaponFirstTypes = string.split(self.__conditionParams, "@")

    local targetResults = {}
    for _, character in ipairs(self.__targetArray) do
        table.insert(targetResults, self:__checkOneTargetConditions(character, conditionWeaponFirstTypes))
    end

    -- 0=每个目标持有判断条件配置的每一个武器一级分类ID
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

    --1=每个目标持有判断条件配置的任意一个武器一级分类ID
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

    -- 2=任意目标持有判断条件配置的每一个武器一级分类ID
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

    --3=任意目标持有判断条件配置的任意一个武器一级分类ID
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

    error("AdderCondition10:matchCondititon 未知判断类型：" .. tostring(self.__conditionResultType))
end

return newClass("AdderCondition10", {AAdderCondition}, AdderCondition10)
00000