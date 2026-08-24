local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local CharacterRunawayState = {
    __state_type = CHARACTER_STATE.RUNAWAY
}

function CharacterRunawayState:initTriggerMap()
    self.__transitionDicts = {}
end

function CharacterRunawayState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入逃跑状态")
    self.__character:setCanRecover(false)
    self.__character:stand()
    self.__character:runAway()
end

function CharacterRunawayState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出逃跑状态")
end

function CharacterRunawayState:onUpdate(ft)
end

return class("CharacterRunawayState", {ACharacterState}, CharacterRunawayState)
000000