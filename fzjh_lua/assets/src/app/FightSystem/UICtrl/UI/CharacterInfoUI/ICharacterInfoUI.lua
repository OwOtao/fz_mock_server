local interface = require("third.class.interface")

local ICharacterInfoUI = {}

function ICharacterInfoUI:addBuffIcon(iconUI, index)
end

function ICharacterInfoUI:addBuffBigIcon(iconUI,index)
end

function ICharacterInfoUI:setVisible(bool)
end

function ICharacterInfoUI:setRoleQiProgress(value)
end

function ICharacterInfoUI:setRoleQiMaxProgress(value)
end

function ICharacterInfoUI:setRoleQiAndQiMaxValue(qiValue, qiMaxValue)
end

function ICharacterInfoUI:setRoleNeiLiProgress(value)
end

function ICharacterInfoUI:setRoleNeiLiMaxProgress(value)
end

function ICharacterInfoUI:setRoleNeiLiAndNeiLiMaxValue(neiLiValue, neiLiMaxValue)
end

function ICharacterInfoUI:setTiliMaxProgress(percent)
end

function ICharacterInfoUI:setTiliProgress(percent)
end

function ICharacterInfoUI:setRoleName(name)
end

function ICharacterInfoUI:showOperationName(name)
end

function ICharacterInfoUI:hideOperationName()
end

function ICharacterInfoUI:removeAllOperationName()
end

function ICharacterInfoUI:updateBuffIcon(buffInfos)
end

function ICharacterInfoUI:showNeiliCost(value)
end

function ICharacterInfoUI:registerClickFunc(beganFunc, endedFunc, cancelFunc)
end

function ICharacterInfoUI:showAllBuffPanel()
end

function ICharacterInfoUI:hideAllBuffPanel()
end

return interface("ICharacterInfoUI", ICharacterInfoUI)
000000000