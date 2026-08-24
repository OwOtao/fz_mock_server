local newClass = require("third.class.NewClass")

local FightActionQueuesSystem = require("app.FightSystem.FightActions.FightActionQueuesSystem")

local FightCommons = require("app.FightSystem.FightCommons")
--  FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")
local ActiveSkillReleaseAI = {
    __rules = {}
}

function ActiveSkillReleaseAI:create(character)
    return ActiveSkillReleaseAI.new():__init(character)
end

function ActiveSkillReleaseAI:__init(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character

    self.__checkTime = 0

    return self
end

function ActiveSkillReleaseAI:onInit()
end

function ActiveSkillReleaseAI:addRule(rule)
    table.insert(self.__rules, rule)
end

--@desc:
--@author:Seven
--@time:2021-07-20 12:16:25
--@actId: 主动技能ID
--@return [src.app.FightSystem.FightRole.CharacterAI.IReleaseActiveAIRule#IReleaseActiveAIRule]
function ActiveSkillReleaseAI:__getRuleByAcitveSkillId(actId)
    if #self.__rules < 0 then
        return nil
    end
    for i = 1, #self.__rules do
        --@RefType [src.app.FightSystem.FightRole.CharacterAI.IReleaseActiveAIRule#IReleaseActiveAIRule]
        local rule = self.__rules[i]
        if rule:getActiveSkillId() == actId then
            return rule
        end
    end

    return nil
end

function ActiveSkillReleaseAI:getRule(actId)
    return self:__getRuleByAcitveSkillId(actId)
end

function ActiveSkillReleaseAI:checkReleaseRules()
    if #self.__rules <= 0 then
        return false
    end
    self.__checkTime = self.__checkTime + 1

    if self.__checkTime > 0 and self.__checkTime < 10 then
        return
    end

    if self.__character:isOutOfBattleState() then
        return false
    end

    local isSuccess = false

    for i = 1, #self.__rules do
        --@RefType [src.app.FightSystem.FightRole.CharacterAI.IReleaseActiveAIRule#IReleaseActiveAIRule]
        local rule = self.__rules[i]
        if rule:checkRealease(self.__character, self.__character:getTarget()) then
            self.__character:applyReleaseOperation(
                FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL,
                {
                    rule:getActiveSkillId()
                }
            )
            isSuccess = true
        end
    end

    self.__checkTime = 0

    return isSuccess
end

function ActiveSkillReleaseAI:onUpdate(ft)
    if #self.__rules <= 0 then
        return
    end

    for i = 1, #self.__rules do
        --@RefType [src.app.FightSystem.FightRole.CharacterAI.IReleaseActiveAIRule#IReleaseActiveAIRule]
        local rule = self.__rules[i]
        rule:onUpdate(ft)
    end
end

function ActiveSkillReleaseAI:onDestory()
    self.__rules = {}
end

return newClass("ActiveSkillReleaseAI", {ABasicCharacterFuncSystem}, ActiveSkillReleaseAI)
00000000000000