local newClass = require("third.class.NewClass")

local ABtnCtrl = require("app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARATER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
local ChangeWeaponBtnCtrl = {
    __type = CHARATER_CMD_TYPE.CHANGE_WEAPON
}

function ChangeWeaponBtnCtrl:create(id)
    local p = ChangeWeaponBtnCtrl:new()
    p:__init(id)
    return p
end

function ChangeWeaponBtnCtrl:__init(id)
    self:setId(id)
end

function ChangeWeaponBtnCtrl:beganFunc()
end

function ChangeWeaponBtnCtrl:releaseFunc()
    self.__fightUICtrl:sendPlayerCommand(FightCommons.FIGHT_CMD_TYPE.CHANGE_WEAPON, {})
end

function ChangeWeaponBtnCtrl:canceledFunc()
end

function ChangeWeaponBtnCtrl:update(ft)
end

return newClass("ChangeWeaponBtnCtrl", {ABtnCtrl}, ChangeWeaponBtnCtrl)
000000000000000