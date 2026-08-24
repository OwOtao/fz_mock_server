--[[
    author:Seven
    time:2023-02-17 14:43:51
    desc: 易武功能
]]
local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem#ABasicCharacterFuncSystem]
local ChangeWeaponFunc = {}

function ChangeWeaponFunc:create()
    return ChangeWeaponFunc.new()
end

function ChangeWeaponFunc:onInit()
    if self.__character:standbyWeaponIsEmptyHand() then
        self:setChangeStandByWeaponOpen(false)
    else
        self:setChangeStandByWeaponOpen(true)
    end
end

function ChangeWeaponFunc:onDestory()
end

function ChangeWeaponFunc:onUpdate(ft)
end

function ChangeWeaponFunc:checkCanDoChangeWeapon()
    if self.__isOpen == false then
        return false
    end

    if self.__character:standbyWeaponIsEmptyHand() then
        return false
    end

    local standby_weapon = self.__character:getStandbyWeapon()

    if standby_weapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.DESTROY then
        return false, TextResManager:getText("1081")
    end

    if standby_weapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.FLY then
        return false, TextResManager:getText("1082")
    end

    if standby_weapon:getFightState() == FightCommons.FIGHT_WEAPON_STATE.GIVEUP then
        return false, TextResManager:getText("1083")
    end

    local isBan, banMsg = self.__character:isBanOperation(FightCommons.BAN_OPERATION_TYPE.BAN_CHANGE_WEAPON)
    if isBan then
        return false, banMsg
    end

    return true
end

function ChangeWeaponFunc:doChangeWeaponFunc()
    FightUtil:printLog("ChangeWeaponFunc:doChangeWeaponFunc() : [" .. self.__character:getAttr("name") .. "]执行易武。")

    self:setChangeStandByWeaponOpen(false)

    local weapon = self.__character:getStandbyWeapon()
    self.__character:useWeapon(weapon)
end

--@desc: 设置是否开启易武
--@author:Seven
--@time:2023-03-01 14:51:44
--@bool: true | false
function ChangeWeaponFunc:setChangeStandByWeaponOpen(bool)
    self.__isOpen = bool
end

--@desc: 易武
--@author:Seven
--@time:2023-03-01 14:52:03
function ChangeWeaponFunc:getChangeWeaponIsOpen()
    return self.__isOpen
end

function ChangeWeaponFunc:getCharacterOperationMap()
    return {
        ["8"] = {
            id = "changeStandbyWeapon",
            name = BattleConstConf:get("battleAction_changeWeapon_name"),
            value = 1,
            maxValue = 1,
            enable = true,
            visible = self:getChangeWeaponIsOpen()
        }
    }
end

return newClass("ChangeWeaponFunc", {ABasicCharacterFuncSystem}, ChangeWeaponFunc)
00000