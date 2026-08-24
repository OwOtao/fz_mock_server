--[[
    author:Seven
    time:2023-10-19 15:56:40
    desc: 当前客户端玩家角色目标信息UI类
]]
local PlayerInfoViewUI = require("app.FightSystem.Veiws.CharacterInfoViews.UI.PlayerInfoViewUI")

local NewClass = require("third.class.NewClass")

local PlayerTargetInfoViewUI = {}

function PlayerTargetInfoViewUI:showNeiliCost(value)
end

return NewClass("PlayerTargetInfoViewUI", {PlayerInfoViewUI}, PlayerTargetInfoViewUI)
0000000000000