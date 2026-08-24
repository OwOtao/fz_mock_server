local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")

--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local ActiveAttackReadyState = {
    __state_type = CHARACTER_STATE.ACTIVE_SKILL_READY
}

function ActiveAttackReadyState:initTriggerMap()
    self.__transitionDicts = {
        ["ACTIVE_JUMPFORWARD"] = function()
            --@desc 进入前跳
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_JUMPFORWARD, nil)
        end,
        ["ACTIVE_ATTACK"] = function()
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_ATTACK, nil)
        end
    }
end

function ActiveAttackReadyState:__doNext()
    if self.__activeSkillAttack:isNeedToJump() then
        return self.__character:triggerEvent("ACTIVE_JUMPFORWARD")
    else
        return self.__character:triggerEvent("ACTIVE_ATTACK")
    end
end

function ActiveAttackReadyState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入主动技能准备释放状态")

    self.__activeSkillAttack = self.__character:getActiveSkillAttack()

    self.__anim_time = self.__activeSkillAttack:getReadyDuration()

    self.__elapsed = 0

    self.__activeSkillAttack:doReadyZhao()
end

function ActiveAttackReadyState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出主动技能准备释放状态")
end

function ActiveAttackReadyState:onUpdate(ft)
    if self.__elapsed >= self.__anim_time then
        return self:__doNext()
    end

    self.__elapsed = self.__elapsed + ft

    FightUtil:printLog(self.__character:getAttr("name"), "主动技能准备释放动画播放中", self.__elapsed, "/" , self.__anim_time)
end

return class("ActiveAttackReadyState", {ACharacterState}, ActiveAttackReadyState)
000000000000