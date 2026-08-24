local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")

--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local AutoAttackEndState = {
    __state_type = CHARACTER_STATE.AUTO_SKILL_ATTACK_END
}

function AutoAttackEndState:initTriggerMap()
    self.__transitionDicts = {
        ["NEXT_AUTO_ATTACK"] = function()
            self.__character:changeState(CHARACTER_STATE.AUTO_SKILL_ATTACK, nil)
        end,
        ["NEXT_AUTOCOMB_ATTACK"] = function()
            self.__autoSkillAttack:startCombAttack()
            self.__character:changeState(CHARACTER_STATE.AUTO_SKILL_ATTACK, nil)
        end,
        ["RELEASE_ACTIVE_ATTACK"] = function()
            --@desc 被动结束接主动技能
            self.__autoSkillAttack:finishAttack()
            local activeSkillAttack = self.__character:getActiveSkillAttack()
            activeSkillAttack:startAttack()
            activeSkillAttack:startCombAttack()
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_READY, nil)
        end,
        ["ATTACK_JUMPBACK"] = function()
            self.__character:changeState(CHARACTER_STATE.AUTO_SKILL_JUMPBACK, nil)
        end
    }
end

function AutoAttackEndState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name"), "进入攻击结束状态")

    self.__autoSkillAttack = self.__character:getAutoSkillAttack()

    self.__autoSkillAttack:finishZhaoAttack()

    --@desc 目标未死亡 拥有下一段攻击
    local target = self.__character:getTarget()
    if not self.__character:isDead() and not target:isDead() and self.__autoSkillAttack:hasNextZhaoAttack() then
        self.__autoSkillAttack:setNextZhaoAttack()
        self.__character:triggerEvent("NEXT_AUTO_ATTACK")
        return
    end

    --@desc 结束当前招式组合攻击
    self.__autoSkillAttack:finishCombAttack()
end

function AutoAttackEndState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name"), "退出攻击结束状态")
end

function AutoAttackEndState:onUpdate(ft)
end

return class("AutoAttackEndState", {ACharacterState}, AutoAttackEndState)
0000000000000000