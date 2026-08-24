--[[
    动画站立状态
]]
local class = require("third.class.NewClass")

local BaseCharacterUIState = require("app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_UI_STATE = FightCommons.CHARACTER_UI_STATE

--@SuperType [src.app.FightSystem.UICtrl.UI.CharacterUIState.BaseCharacterUIState#BaseCharacterUIState]
local ChangeWeaponState = {
    __stateType = CHARACTER_UI_STATE.CHANGEWEAPON
}

function ChangeWeaponState:onInit()
end

function ChangeWeaponState:onEnter(params)
    self.__ctrl:playAnim(self.__animName, false)
    
    local weapon = params.weapon

    self.__ctrl:changeWeapon(weapon)

    self.__nextActSkills = params.nextActiveSkills

    self.__viewInfo = params.viewInfo

    self.__ctrl:setStandAnim(self.__viewInfo.stand_anim)
    
    self.__ctrl:setJoinAnim(self.__viewInfo.join_anim)
    
    self.__ctrl:setJumpForwardAnim(self.__viewInfo.jumpForwardAnim)
    
    self.__ctrl:setJumpBackAnim(self.__viewInfo.jumpbackAnim)
end

function ChangeWeaponState:onLeave()
    self.__ctrl:changeAllActiveSkills(self.__nextActSkills)
end

function ChangeWeaponState:onUpdate(ft)
end

return class("ChangeWeaponState", {BaseCharacterUIState}, ChangeWeaponState)
0000000000000000