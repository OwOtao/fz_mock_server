local newClass = require("third.class.NewClass")

local ACharacterCommand = require("app.FightSystem.FightRole.CharacterCommands.ACharacterCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.CharacterCommands.ACharacterCommand#ACharacterCommand]
local CharacterReleaseActiveSkillCommand = {
    __type = CHARACTER_CMD_TYPE.RELEASE_ACTIVE,
    __priority = 3
}

function CharacterReleaseActiveSkillCommand:create()
    return CharacterReleaseActiveSkillCommand.new()
end

function CharacterReleaseActiveSkillCommand:setActiveSkillId(id)
    self.__act_id = id
end

function CharacterReleaseActiveSkillCommand:getActiveSkillId()
    return self.__act_id
end

function CharacterReleaseActiveSkillCommand:isMatchCondition()
    local character = self.__characterSystem:getCharacter(self.__characterId)

    if character:isDead() then
        return false
    end

    local ActiveZhaoCombAttack = require("app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombAttack")

    local activeSkill = character:getActiveSkill(self.__act_id)

    local underBan, banTips = activeSkill:underBan()

    local isbool, failureText = activeSkill:releaseAreMet()
    if underBan then
        return false, banTips
    elseif not isbool then
        FightUtil:printLog(character:getAttr("name"), "CharacterReleaseActiveSkillCommand 释放主动技能： 主动技能释放条件不满足 false")

        return false, failureText
    end

    return true
end

function CharacterReleaseActiveSkillCommand:getCommandName()
    local owner = self.__characterSystem:getCharacter(self.__characterId)
    local activeSkill = owner:getActiveSkill(self.__act_id)
    return activeSkill:getName()
end

function CharacterReleaseActiveSkillCommand:executeResult()
    return self.__result, self.__failueText
end

function CharacterReleaseActiveSkillCommand:execute()
    local character = self.__characterSystem:getCharacter(self.__characterId)

    local ActiveZhaoCombAttack = require("app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombAttack")

    local activeSkill = character:getActiveSkill(self.__act_id)

    -- if character:isDead() then
    --     self.__result = false
    --     return
    -- end

    -- local underBan, banTips = activeSkill:underBan()
    -- local isbool, failureText = activeSkill:releaseAreMet()

    -- if underBan then
    --     FightUtil:printLog("CharacterReleaseActiveSkillCommand 释放主动技能： 主动技能被禁止 false")
    --     self.__result = false
    --     self.__failueText = banTips
    --     -- character:cancelReleaseActiveSkill(self.__act_id)
    --     return
    -- elseif not isbool then
    --     FightUtil:printLog(character:getAttr("name"), "CharacterReleaseActiveSkillCommand 释放主动技能： 主动技能释放条件不满足 false")
    --     if character:isPlayer() and failureText ~= nil then
    --         self.__fight:popMessage(failureText)
    --     end

    --     self.__result = false

    --     self.__failueText = failureText

    --     -- character:cancelReleaseActiveSkill(self.__act_id)
    --     return
    -- end

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombAttack#ActiveZhaoCombAttack]
    local zhaoCombAttack = ActiveZhaoCombAttack:create(activeSkill:getZhaoComb())

    local activeSkillAttack = character:getActiveSkillAttack()

    activeSkillAttack:setZhaoComb(zhaoCombAttack)

    activeSkillAttack:prepAttack()

    character:getActiveSkillAttack():setZhaoCombCanRelease(true)

    --@desc 该方法只会发送至空闲状态下的角色
    character:triggerEvent("RELEASE_ACTIVE_ATTACK")

    self.__result = true
end

return newClass("CharacterReleaseActiveSkillCommand", {ACharacterCommand}, CharacterReleaseActiveSkillCommand)
00000000