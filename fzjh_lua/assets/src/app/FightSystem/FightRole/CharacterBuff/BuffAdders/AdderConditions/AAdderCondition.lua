--[[
    author:Seven
    time:2023-03-08 14:27:34
    desc: buff添加器条件判断抽象类

    判断目标类型：0=自身、1=我方队友、2=我方全体、10=敌目标、11=敌方队友、12=敌方全体
               主动招式使用者是我方、主动招式使用者正在锁定的攻击目标为敌目标

]]
local IConditionMatch = {}

function IConditionMatch:matchCondititon()
end

IConditionMatch = require("third.class.interface")("IConditionMatch", IConditionMatch)

local abstract = require("third.class.abstract")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.AdderConditions.AAdderCondition#IConditionMatch]
local AAdderCondition = {}

--@desc: 设置添加器所有者
--@author:Seven
--@time:2023-03-08 14:55:16
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function AAdderCondition:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

--@desc: 设置战场
--@author:Seven
--@time:2023-03-08 14:55:03
function AAdderCondition:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.BattleSystem#Fight]
    self.__fight = fight
end

function AAdderCondition:setBuffAdder(adder)
    --@RefType [src.app.FightSystem.FightRole.CharacterBuff.BuffAdders.BasicFightCharacterBuffAdder#BasicFightCharacterBuffAdder]
    self.__adder = adder
end

function AAdderCondition:__analysisTargetArray(conditionTarget)
    self.__targetArray = {}

    local conditionTarget = tonumber(conditionTarget)

    -- 0=自身
    if conditionTarget == 0 then
        table.insert(self.__targetArray, self.__character)
        return self.__targetArray
    end

    -- 1=我方队友
    if conditionTarget == 1 then
        self.__targetArray = self.__fight:getTeammates(self.__character:getId())

        return self.__targetArray
    end

    --2=我方全体
    if conditionTarget == 2 then
        self.__targetArray = self.__fight:getTeamCharacters(self.__character:getTeamId())

        return self.__targetArray
    end

    -- 10=敌目标
    if conditionTarget == 10 then
        table.insert(self.__targetArray, self.__fight:getAttackTarget(self.__character:getId()))
        return self.__targetArray
    end

    -- 11=敌方队友
    if conditionTarget == 11 then
        local attackTarget = self.__fight:getAttackTarget(self.__character:getId())
        self.__targetArray = self.__fight:getTeammates(attackTarget:getTeamId())

        return self.__targetArray
    end

    -- 12=敌方全体
    if conditionTarget == 12 then
        local attackTarget = self.__fight:getAttackTarget(self.__character:getId())
        self.__targetArray = self.__fight:getTeamCharacters(attackTarget:getTeamId())
        return self.__targetArray
    end

    error("AAdderCondition:__analysisTargetArray buff添加器条件判断目标类型未知：" .. tostring(conditionTarget))
end

return abstract("AAdderCondition", {IConditionMatch}, AAdderCondition)
0000000000