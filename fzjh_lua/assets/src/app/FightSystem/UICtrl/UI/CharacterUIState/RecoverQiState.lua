--[[
    动画站立状态
]]
local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local RecoverQiState = {
    __stateType = CHARACTER_UI_STATE.RECOVERQI
}

function RecoverQiState:onInit()
end

function RecoverQiState:onEnter(params)
    self.__ctrl:playAnim(self.__animName, false)
    local value = params.value
    self.__ctrl:popOverHeadText("HIG" .. tostring(Helper:mathFloor(value)))
end

function RecoverQiState:onLeave()
end

function RecoverQiState:onUpdate(ft)
end

return class("RecoverQiState", {BaseCharacterUIState}, RecoverQiState)
0