local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")
local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local CharacterInfoUI = {}

function CharacterInfoUI:onInit()
end

function CharacterInfoUI:onDestroy()
end

function CharacterInfoUI:onUpdate(ft)
end

function CharacterInfoUI:setRoleQiProgress(value)
    self.QiBar:setPercent(value)
end

function CharacterInfoUI:setRoleQiMaxProgress(value)
    self.QiMaxBar:setPercent(value)
end

function CharacterInfoUI:setRoleQiAndQiMaxValue(qiValue, qiMaxValue)
    self.QiValue:setString(tostring(qiValue) .. "/" .. tostring(qiMaxValue))
end

function CharacterInfoUI:setRoleNeiLiProgress(value)
    self.NeiliBar:setPercent(value)
end

function CharacterInfoUI:setRoleNeiLiMaxProgress(value)
    self.NeiliMaxBar:setPercent(value)
end

function CharacterInfoUI:setRoleNeiLiAndNeiLiMaxValue(neiLiValue, neiLiMaxValue)
    self.NeiliValue:setString(tostring(neiLiValue) .. "/" .. tostring(neiLiMaxValue))
end

function CharacterInfoUI:setRoleTiLiProgress(value)
    self.TiliBar:setPercent(value)
end

function CharacterInfoUI:setRoleName(name)
    self.Name:setString(name)
end

return NewClass("CharacterInfoUI", {BaseUI}, CharacterInfoUI)
000000000000000