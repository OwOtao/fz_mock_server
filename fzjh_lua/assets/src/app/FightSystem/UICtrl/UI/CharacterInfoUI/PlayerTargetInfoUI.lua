local PlayerInfoUI = require("app.FightSystem.UICtrl.UI.CharacterInfoUI.PlayerInfoUI")

local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local PlayerTargetInfoUI = {}

function PlayerTargetInfoUI:showNeiliCost(value)
end

return NewClass("PlayerTargetInfoUI", {PlayerInfoUI}, PlayerTargetInfoUI)
000