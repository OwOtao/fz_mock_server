local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local ActiveAttackJumpForward = {
    __state_type = CHARACTER_STATE.ACTIVE_SKILL_JUMPFORWARD
}

function ActiveAttackJumpForward:initTriggerMap()
    self.__transitionDicts = {
        ["ACTIVE_ATTACK"] = function()
            self.__character:changeState(CHARACTER_STATE.ACTIVE_SKILL_ATTACK, nil)
        end
    }
end

function ActiveAttackJumpForward:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入主动跳跃状态")

    local character_pos = self.__character:getPosition()

    local target_character_pos = self.__character:getTarget():getPosition()

    local jump_dir
    if target_character_pos.x - character_pos.x >= 0 then
        jump_dir = 1
    else
        jump_dir = -1
    end

    self.__skillAttack = self.__character:getActiveSkillAttack()

    local offset_x = self.__skillAttack:getAttackOffset()

    local offset_pos = {x = (-offset_x) * jump_dir, y = 0}
    --@endregion

    self.__target_pos = {
        x = target_character_pos.x + offset_pos.x,
        y = target_character_pos.y + offset_pos.y,
        h = 0
    }

    self.__start_pos = {
        x = character_pos.x,
        y = character_pos.y,
        h = 0
    }

    self.__jumpHighest = math.abs((self.__target_pos.x - self.__start_pos.x)) / 1080 * 30

    self.__jumping_dt = 0

    self.__jump_time = 0.3

    self.__character:jump(
        self.__character:getJumpForwardAnimName(),
        {
            dir = "forward",
            target_pos = self.__target_pos,
            start_pos = self.__start_pos,
            highest = self.__jumpHighest,
            total_time = self.__jump_time
        }
    )

    FightUtil:printLog("【", self.__character:getAttr("name") , "】主动跳跃开始：")
    FightUtil:printLog("    开始位置:{ x:", self.__start_pos.x, ", y:", self.__start_pos.y, "}; 目标位置:{x:", self.__target_pos.x, ", y:", self.__target_pos.y , "}")
    FightUtil:printLog("    跳跃高度: " , self.__jumpHighest)
end

function ActiveAttackJumpForward:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出主动跳跃状态")
end

function ActiveAttackJumpForward:onUpdate(ft)
    if self.__jumping_dt > 0 then
        if self.__jumping_dt >= self.__jump_time then
            FightUtil:printLog(self.__character:getAttr("name") , "主动跳跃结束")
            self.__character:setPosition(self.__target_pos.x, self.__target_pos.y, self.__jumpHighest)
            self.__jumping_dt = 0
            return self.__stateMachine:trigger("ACTIVE_ATTACK")
        end
        FightUtil:printLog(self.__character:getAttr("name"), "跳跃中.,")
    end

    self.__jumping_dt = self.__jumping_dt + ft
end

return class("ActiveAttackJumpForward", {ACharacterState}, ActiveAttackJumpForward)
0