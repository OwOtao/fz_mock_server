local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")
local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local AnimCharacterInfoUI = {}

function AnimCharacterInfoUI:onInit()
end

function AnimCharacterInfoUI:onDestroy()
end

function AnimCharacterInfoUI:onUpdate(ft)
end

function AnimCharacterInfoUI:setRoleQiProgress(value)
    self.QiBar:setPercent(value)
end

function AnimCharacterInfoUI:setRoleQiMaxProgress(value)
    self.QiMaxBar:setPercent(value)
end

function AnimCharacterInfoUI:setRoleNeiLiProgress(value)
    self.NeiliBar:setPercent(value)
end

function AnimCharacterInfoUI:setRoleNeiLiMaxProgress(value)
    self.NeiliMaxBar:setPercent(value)
end

function AnimCharacterInfoUI:setRoleTiLi_1Progress(value)
    self.TiliBar_1:setPercent(value)
end

function AnimCharacterInfoUI:setRoleTiLi_1ProgressVisible(visible)
    self.TiliBar_1:setVisible(visible)
end

function AnimCharacterInfoUI:setRoleTiLi_2Progress(value)
    self.TiliBar_2:setPercent(value)
end

function AnimCharacterInfoUI:setRoleTiLi_2ProgressVisible(visible)
    self.TiliBar_2:setVisible(visible)
end

return NewClass("AnimCharacterInfoUI", {BaseUI}, AnimCharacterInfoUI)
00000000000000