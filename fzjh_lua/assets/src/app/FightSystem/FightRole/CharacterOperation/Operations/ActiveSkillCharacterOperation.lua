--[[
    author:Seven
    time:2023-12-19 21:14:15
    desc:
]]
local newClass = require("third.class.NewClass")

local ACharacterOperation = require("app.FightSystem.FightRole.CharacterOperation.ACharacterOperation")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightRole.CharacterOperation.ACharacterOperation#ACharacterOperation]
local ActiveSkillCharacterOperation = {}

function ActiveSkillCharacterOperation:create(activeSkill)
    return ActiveSkillCharacterOperation.new():__init(activeSkill)
end

function ActiveSkillCharacterOperation:ctor()
    self:setCharacterOperationType(FightCommons.CHARACTER_OPERATION_TYPE.OPERATION_ACTIVE_SKILL)
end

function ActiveSkillCharacterOperation:__init(activeSkill)
    --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
    self.__activeSkill = activeSkill

    self:setOperationId(self.__activeSkill:getId())

    self:setCdMax(self.__activeSkill:getCoolDownTime())

    return self
end

function ActiveSkillCharacterOperation:canDoOperation()
    return self.__activeSkill:releaseAreMet()
end

function ActiveSkillCharacterOperation:doOperation()
end

return newClass("ActiveSkillCharacterOperation", {ACharacterOperation}, ActiveSkillCharacterOperation)
000000000