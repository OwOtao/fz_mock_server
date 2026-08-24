local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")

--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local ActiveAttackState = {
    __state_type = CHARACTER_STATE.ACTIVE_SKILL_ATTACK
}

function ActiveAttackState:initTriggerMap()
    self.__transitionDicts = {
        ["ACTIVE_ATTACK_END"] = function()
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_ATTACK_END, nil)
        end
    }
end

function ActiveAttackState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入主动攻击状态")

    self.__character:setCanRecover(false)

    self.__skillAttack = self.__character:getActiveSkillAttack()

    self.__skillAttack:startZhaoAttack()

    self.__skillAttack:doZhaoAttack()

    self.__duration = self.__skillAttack:getAttackDuration()
    
    self.__elapsed = 0
end

function ActiveAttackState:onLeave()
    self.__character:setCanRecover(true)
    self.__skillAttack = nil
    FightUtil:printLog(self.__character:getAttr("name") , "退出主动攻击状态")
end

function ActiveAttackState:onUpdate(ft)
    if self.__elapsed >= self.__duration then
        return self.__character:triggerEvent("ACTIVE_ATTACK_END")
    else
        FightUtil:printLog(self.__character:getAttr("name"), " 攻击动画播放中 ：", self.__elapsed, "/" , self.__duration)
    end
    self.__elapsed = self.__elapsed + ft
end

return class("ActiveAttackState", {ACharacterState}, ActiveAttackState)
00000000