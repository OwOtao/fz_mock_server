local newClass = require("third.class.NewClass")

local ABtnCtrl = require("app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
local RunawayBtnCtrl = {
    __type = FightCommons.CHARATER_CMD_TYPE.RUNAWAY
}

function RunawayBtnCtrl:create(id)
    local p = RunawayBtnCtrl:new()
    p:__init(id)
    return p
end

function RunawayBtnCtrl:__init(id)
    self:setId(id)
end

function RunawayBtnCtrl:beganFunc()
end

function RunawayBtnCtrl:releaseFunc()
    self.__fightUICtrl:sendPlayerCommand(FightCommons.FIGHT_CMD_TYPE.CHARACTER_RUNAWAY, {})
end

function RunawayBtnCtrl:canceledFunc()
end

function RunawayBtnCtrl:update(ft)
end

return newClass("RunawayBtnCtrl", {ABtnCtrl}, RunawayBtnCtrl)
00