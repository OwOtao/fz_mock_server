local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")

--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local ActiveAttackEndState = {
    __state_type = CHARACTER_STATE.ACTIVE_SKILL_ATTACK_END
}

function ActiveAttackEndState:initTriggerMap()
    self.__transitionDicts = {
        ["ATTACKER_DEAD"] = function()
            self.__character:getActiveSkillAttack():finishAttack()
            self.__character:finishAction()
        end,
        ["NEXT_ACTIVE_ATTACK"] = function()
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_ATTACK, nil)
        end,
        ["RELEASE_ACTIVE_ATTACK"] = function()
            --@desc 主动技能接主动技能
            local activeSkillAttack = self.__character:getActiveSkillAttack()
            activeSkillAttack:startAttack()
            activeSkillAttack:startCombAttack()
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_READY, nil)
        end,
        ["NEXT_AUTOCOMB_ATTACK"] = function()
            --@desc 主动技能接被动技能
            self.__character:getAutoSkillAttack():startAttack()
            self.__character:getAutoSkillAttack():startCombAttack()
            self.__character:changeState(CHARACTER_STATE.AUTO_SKILL_ATTACK, nil)
        end,
        ["ATTACK_JUMPBACK"] = function()
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_JUMPBACK, nil)
        end
    }
end

function ActiveAttackEndState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入主动攻击结束状态")

    self.__skillAttack = self.__character:getActiveSkillAttack()

    self.__skillAttack:finishZhaoAttack()

    local target = self.__character:getTarget()
    if not self.__character:isDead() and not target:isDead() and self.__skillAttack:hasNextZhaoAttack() then
        self.__skillAttack:setNextZhaoAttack()
        self.__character:triggerEvent("NEXT_ACTIVE_ATTACK")
        return
    end

    self.__skillAttack:finishCombAttack()
end

function ActiveAttackEndState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出主动攻击结束状态")
end

function ActiveAttackEndState:onUpdate(ft)
end

return class("ActiveAttackEndState", {ACharacterState}, ActiveAttackEndState)
000000