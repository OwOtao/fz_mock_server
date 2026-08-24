--[[
    武器切换功能
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local SWITCH_STATE = {
    PREP = 0,
    STATNDBY = 1
}

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local SwitchWeaponFunc = {}

function SwitchWeaponFunc:create()
    return SwitchWeaponFunc.new()
end

function SwitchWeaponFunc:onInit()
    self.__currState = SWITCH_STATE.STATNDBY
end

function SwitchWeaponFunc:onDestory()
    self.__currState = nil
end

function SwitchWeaponFunc:getState()
    return self.__currState
end

function SwitchWeaponFunc:judgeSwitchWeapon(switchType, switchConditionLogicalSymbol, switchConditionValue, switchFailTextId)
    local class = require("app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc.SwitchFunc" .. tostring(switchType))

    if class == nil then
        error("未知切换武器类型：" .. tostring(switchType))
    end

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc.ASwitchFunc#ASwitchFunc]
    local conditionClass = class:create(switchConditionLogicalSymbol, switchConditionValue, switchFailTextId)

    local isOk, failTextId = conditionClass:isMatchSwitch(self)
    if not isOk then
        return false, TextResManager:getText(tostring(failTextId))
    end

    return true
end

function SwitchWeaponFunc:switchWeapon()
    if self.__currState == SWITCH_STATE.PREP then
        return self:__switchToPrep()
    else
        return self:__switchToStandby()
    end
end

function SwitchWeaponFunc:getSwitchTargetWeapon()
    local weapon = nil

    if self.__currState == SWITCH_STATE.PREP then
        weapon = self.__character:getEquipment(FightCommons.EQUIP_PART.WEAPON)
    else
        weapon = self.__character:getStandbyEquipment(FightCommons.EQUIP_PART.WEAPON)
    end

    return weapon
end

function SwitchWeaponFunc:__switchToStandby()
    local standByWeapon = self.__character:getStandbyEquipment(FightCommons.EQUIP_PART.WEAPON)

    if standByWeapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.FLY then
        standByWeapon:updateFightState(FightCommons.FIGHT_WEAPON_STATE.NORMAL)
    end

    self.__currState = SWITCH_STATE.PREP

    self.__character:useWeapon(standByWeapon)

    return true
end

function SwitchWeaponFunc:__switchToPrep()
    local prepByWeapon = self.__character:getEquipment(FightCommons.EQUIP_PART.WEAPON)

    if prepByWeapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.FLY then
        prepByWeapon:updateFightState(FightCommons.FIGHT_WEAPON_STATE.NORMAL)
    end

    self.__currState = SWITCH_STATE.STATNDBY

    self.__character:useWeapon(prepByWeapon)

    return true
end

return newClass("SwitchWeaponFunc", {ABasicCharacterFuncSystem}, SwitchWeaponFunc)
000000