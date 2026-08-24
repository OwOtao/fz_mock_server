local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local FIGHT_CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local CharacterDeadState = {
    __state_type = CHARACTER_STATE.DEAD
}

function CharacterDeadState:initTriggerMap()
    self.__transitionDicts = {}
end

function CharacterDeadState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入死亡状态")
    self.__character:setCanRecover(false)
end

function CharacterDeadState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出死亡状态")
end

function CharacterDeadState:onUpdate(ft)
end

return class("CharacterDeadState", {ACharacterState}, CharacterDeadState)
000000