--[[
    author:Seven
    time:2022-10-09 14:58:01
    desc:
]]
local newClass = require("third.class.NewClass")

local ABtnCtrl = require("app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARATER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.UICtrl.PlayerBtnCtrl.ABtnCtrl#ABtnCtrl]
local PlaceholderBtnCtrl = {
    __type = CHARATER_CMD_TYPE.PLACEHOLDER
}

function PlaceholderBtnCtrl:create()
    return PlaceholderBtnCtrl:new()
end

function PlaceholderBtnCtrl:getId()
    return tostring(-1)
end

function PlaceholderBtnCtrl:beganFunc()
end

function PlaceholderBtnCtrl:releaseFunc()
    PopText("未准备主动技能")
end

function PlaceholderBtnCtrl:canceledFunc()
end

function PlaceholderBtnCtrl:update(ft)
end

return newClass("PlaceholderBtnCtrl", {ABtnCtrl}, PlaceholderBtnCtrl)
000000000000