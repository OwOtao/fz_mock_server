--[[
    动画站立状态
]]
local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local JoinFightState = {
    __stateType = CHARACTER_UI_STATE.JOINING
}

function JoinFightState:onInit()
end

function JoinFightState:onEnter(params)
    self.__ctrl:setAnimVisible(true)
    if self.__animName then
        self.__ctrl:playAnim(self.__animName, false)
    end
end

function JoinFightState:onLeave()
end

function JoinFightState:onUpdate(ft)
end

return class("JoinFightState", {BaseCharacterUIState}, JoinFightState)
0000000000000000