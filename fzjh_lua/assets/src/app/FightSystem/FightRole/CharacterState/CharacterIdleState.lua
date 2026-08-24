local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local CharacterIdleState = {
    __state_type = CHARACTER_STATE.IDLE
}

function CharacterIdleState:initTriggerMap()
    self.__transitionDicts = {
        ["RUNAWAY"] = function()
            self.__character:changeState(CHARACTER_STATE.RUNAWAY, nil)
        end,
        ["CHANGE_WEAPON"] = function()
            self.__character:changeState(CHARACTER_STATE.CHANGE_WEAPON, nil)
        end,
        ["RECOVER_QI"] = function()
            self.__character:changeState(CHARACTER_STATE.RECOVER_QI, nil)
        end,
        ["START_AUTO_ATTACK"] = function()
            self.__character:startAction()

            local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")
            --@RefType[AutoZhaoFactory]
            local AutoZhaoFactory = require("app.FightSystem.Factory.FightSkillFactory.AutoZhaoFactory")

            local autoSkillAttack = self.__character:getAutoSkillAttack()

            local zhaoComb = AutoZhaoFactory:createAttackAutoZhaoComb(self.__character)

            autoSkillAttack:setZhaoComb(zhaoComb)

            autoSkillAttack:startAttack()

            autoSkillAttack:startCombAttack()

            self.__character:changeState(CHARACTER_STATE.AUTO_SKILL_JUMPFORWAR, nil)
        end,
        ["RELEASE_ACTIVE_ATTACK"] = function()
            self.__character:startAction()

            local activeSkillAttack = self.__character:getActiveSkillAttack()

            activeSkillAttack:startAttack()

            activeSkillAttack:startCombAttack()

            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_READY, nil)
        end
    }
end

function CharacterIdleState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name"), "进入空闲状态")
    self.__character:setCanRecover(true)
    self.__character:stand()
end

function CharacterIdleState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name"), "退出空闲状态")
end

function CharacterIdleState:onUpdate(ft)
end

return class("CharacterIdleState", {ACharacterState}, CharacterIdleState)
0000000000000