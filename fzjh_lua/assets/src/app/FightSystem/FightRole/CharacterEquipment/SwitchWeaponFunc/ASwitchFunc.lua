--[[
    author:Seven
    time:2023-01-10 16:13:27
    desc: 切换武器抽象类
]]
local abstract = require("third.class.abstract")

local ISwitchFunc = require("app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc.ISwitchFunc")

local FightCommons = require("app.FightSystem.FightCommons")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

--@SuperType [src.app.FightSystem.FightRole.CharacterEquipment.SwitchWeaponFunc.ISwitchFunc#ISwitchFunc]
local ASwitchFunc = {}

function ASwitchFunc:isMatchSwitch(sys)
    local targetWeapon = sys:getSwitchTargetWeapon()

    local weaponState = targetWeapon:getFightState()

    if weaponState == FightCommons.FIGHT_WEAPON_STATE.DESTROY then
        return false, TextResManager:getText("1042")
    end

    return self:canSwitch(sys)
end

return abstract("ASwitchFunc",{ISwitchFunc},ASwitchFunc)0000000000000000