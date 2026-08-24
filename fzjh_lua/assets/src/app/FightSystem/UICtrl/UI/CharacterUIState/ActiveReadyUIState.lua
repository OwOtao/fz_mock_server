--[[
    动画站立状态
]]
local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
local FightCommons = require("app.FightSystem.FightCommons")

local AudioResManager = require("app.FightSystem.ResourceManager.AudioResManager")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local ActiveReadyUIState = {
    __stateType = CHARACTER_UI_STATE.ACTIVEREADY
}

function ActiveReadyUIState:onInit()
end

function ActiveReadyUIState:onEnter(params)
    self.__ctrl:playAnim(self.__animName, false)

    self.__ctrl:playSound(AudioResManager:getSoundNameByRandom(params.soundId))
end

function ActiveReadyUIState:onLeave()
end

function ActiveReadyUIState:onUpdate(ft)
end

return class("ActiveReadyUIState", {BaseCharacterUIState}, ActiveReadyUIState)
0