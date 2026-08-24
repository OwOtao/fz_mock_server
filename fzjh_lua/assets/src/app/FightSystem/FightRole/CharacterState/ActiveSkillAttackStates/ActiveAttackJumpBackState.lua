local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

--@RefType [src.app.FightSystem.Fight.BattleGlobalData#BattleGlobalData]
local BattleGlobalData = require("app.FightSystem.Fight.BattleGlobalData")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")

--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local ActiveAttackJumpBackState = {
    __state_type = CHARACTER_STATE.ACTIVE_SKILL_JUMPBACK
}

function ActiveAttackJumpBackState:initTriggerMap()
    self.__transitionDicts = {
        ["JUMPBACK_ORI"] = function()
            local skillAttack = self.__character:getActiveSkillAttack()
            --@desc 结束主动技能攻击
            skillAttack:finishAttack()
            self.__character:changeState(CHARACTER_STATE.IDLE, nil)
            self.__character:finishAction()
        end
    }
end

function ActiveAttackJumpBackState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入主动攻击跳回状态")
    local character_pos = self.__character:getPosition()

    self.__target_pos = self.__character:getOriginPos()

    self.__start_pos = {
        x = character_pos.x,
        y = character_pos.y,
        h = 0
    }

    self.__jumpHighest = math.abs((self.__target_pos.x - self.__start_pos.x)) / 1080 * 30

    self.__jumping_dt = 0

    self.__jump_time = 0.2

    self.__character:jump(
        self.__character:getJumpBackAnimName(),
        {
            dir = "back",
            target_pos = self.__target_pos,
            start_pos = self.__start_pos,
            highest = self.__jumpHighest,
            total_time = self.__jump_time
        }
    )

    FightUtil:printLog("【", self.__character:getAttr("name") , "】跳回开始：")
    FightUtil:printLog("    开始位置:{ x:", self.__start_pos.x, ", y:", self.__start_pos.y, "}; 目标位置:{x:", self.__target_pos.x, ", y:", self.__target_pos.y , "}")
    FightUtil:printLog("    跳跃高度: " , self.__jumpHighest)
end

function ActiveAttackJumpBackState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出主动攻击跳回状态")
end

function ActiveAttackJumpBackState:onUpdate(ft)
    if self.__jumping_dt > 0 then
        if self.__jumping_dt >= self.__jump_time then
            FightUtil:printLog(self.__character:getAttr("name") , "跳跃结束")
            self.__character:setPosition(self.__target_pos.x, self.__target_pos.y, self.__jumpHighest)
            self.__jumping_dt = 0
            return self.__stateMachine:trigger("JUMPBACK_ORI")
        end
        FightUtil:printLog(self.__character:getAttr("name"), "主动跳回中.,")
    end
    self.__jumping_dt = self.__jumping_dt + ft
end

return class("ActiveAttackJumpBackState", {ACharacterState}, ActiveAttackJumpBackState)
000000