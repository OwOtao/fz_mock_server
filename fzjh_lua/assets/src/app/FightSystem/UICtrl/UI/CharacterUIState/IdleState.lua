--[[
    动画站立状态
]]
local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local IdleState = {
    __stateType = CHARACTER_UI_STATE.IDLE
}

function IdleState:onInit()
end

function IdleState:onEnter(params)
    self.__ctrl:playAnim(self.__animName, false)
end

function IdleState:onLeave()
end

function IdleState:onUpdate(ft)
end

return class("IdleState", {BaseCharacterUIState}, IdleState)
000000