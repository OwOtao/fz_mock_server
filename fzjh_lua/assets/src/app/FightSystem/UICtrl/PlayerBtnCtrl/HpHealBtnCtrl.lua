local newClass = require("third.class.NewClass")

local ABtnCtrl = require("app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARATER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
local HpHealBtnCtrl = {
    __type = CHARATER_CMD_TYPE.QI_RECOEVE
}

function HpHealBtnCtrl:create(id)
    local p = HpHealBtnCtrl:new()
    p:__init(id)
    return p
end

function HpHealBtnCtrl:__init(id)
    self:setId(id)
end

function HpHealBtnCtrl:beganFunc()
end

function HpHealBtnCtrl:releaseFunc()
    self.__fightUICtrl:sendPlayerCommand(FightCommons.FIGHT_CMD_TYPE.RECOVER_QI, {})
end

function HpHealBtnCtrl:canceledFunc()
end

function HpHealBtnCtrl:update(ft)
end

return newClass("HpHealBtnCtrl", {ABtnCtrl}, HpHealBtnCtrl)
0