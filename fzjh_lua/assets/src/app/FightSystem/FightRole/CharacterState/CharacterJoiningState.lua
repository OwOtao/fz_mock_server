local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ACharacterState = require("app.FightSystem.FightRole.CharacterState.ACharacterState")
--@SuperType [src.app.FightSystem.FightRole.CharacterState.ACharacterState#ACharacterState]
local CharacterJoiningState = {
    __state_type = CHARACTER_STATE.JOINING
}

function CharacterJoiningState:initTriggerMap()
    self.__transitionDicts = {
        ["FIGHT_START"] = function()
            self.__character:changeState(CHARACTER_STATE.IDLE, nil)
        end
    }
end

function CharacterJoiningState:onEnter(params)
    FightUtil:printLog(self.__character:getAttr("name") , "进入加入战场状态")

    self.__elapsed = 0
    self.__duration = 0

    local joinAnimName = self.__character:getJoinAnimName()
    if joinAnimName ~= nil then
        self.__duration = AnimResManager:getAnimTime(joinAnimName)
    end
    self.__character:enterFight()
end

function CharacterJoiningState:onLeave()
    FightUtil:printLog(self.__character:getAttr("name") , "退出加入战场状态")
end

function CharacterJoiningState:onUpdate(ft)
    if self.__elapsed >= self.__duration then
        return self.__character:triggerEvent("FIGHT_START")
    end

    self.__elapsed = self.__elapsed + ft
    FightUtil:printLog(self.__character:getAttr("name"), "播放进入动画中 , 用时: ", self.__elapsed, "/" , self.__duration)
end

return class("CharacterJoiningState", {ACharacterState}, CharacterJoiningState)
00000000