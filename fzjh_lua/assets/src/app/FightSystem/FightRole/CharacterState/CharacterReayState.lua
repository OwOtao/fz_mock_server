local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local CharacterReayState = {
    __state_type = CHARACTER_STATE.READY
}

function CharacterReayState:initTriggerMap()
    self.__transitionDicts = {
        ["FIGHT_ENTER"] = function ()
            self.__character:changeState(CHARACTER_STATE.JOINING,nil)
        end
    }
end

function CharacterReayState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入准备状态")
end

function CharacterReayState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出准备状态")
end

function CharacterReayState:onUpdate(ft)
end

return class("CharacterReayState", {ACharacterState}, CharacterReayState)
00000