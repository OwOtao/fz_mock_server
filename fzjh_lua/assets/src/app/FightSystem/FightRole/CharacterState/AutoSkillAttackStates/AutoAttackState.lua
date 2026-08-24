local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightFormula = require("app.FightSystem.FightFormula")

local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")

local FightCommons = require("app.FightSystem.FightCommons")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")

--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local AutoAttackState = {
    __state_type = CHARACTER_STATE.AUTO_SKILL_ATTACK
}

function AutoAttackState:initTriggerMap()
    self.__transitionDicts = {
        ["AUTO_ATTACK_END"] = function()
            self.__character:changeState(CHARACTER_STATE.AUTO_SKILL_ATTACK_END, nil)
        end
    }
end

function AutoAttackState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入攻击状态")

    self.__character:setCanRecover(false)

    self.__autoSkillAttack = self.__character:getAutoSkillAttack()

    self.__autoSkillAttack:startZhaoAttack()

    self.__autoSkillAttack:doZhaoAttack()

    self.__duration = self.__autoSkillAttack:getAttackDuration()

    self.__elapsed = 0
end

function AutoAttackState:onLeave()
    self.__character:setCanRecover(true)
    self.__autoSkillAttack = nil
    FightUtil:printLog(self.__character:getAttr("name") , "退出攻击状态")
end

function AutoAttackState:onUpdate(ft)
    if self.__elapsed >= self.__duration then
        return self.__character:triggerEvent("AUTO_ATTACK_END")
    else
        FightUtil:printLog(self.__character:getAttr("name"), " 攻击动画播放中 ：", self.__elapsed, "/" , self.__duration)
    end
    self.__elapsed = self.__elapsed + ft
end

return class("AutoAttackState", {ACharacterState}, AutoAttackState)
0