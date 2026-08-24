--[[
    author:Seven
    time:2023-11-28 10:32:11
    desc: 角色信息UI接口
]]
local interface = require("third.class.interface")
local IInfoPanelViewUI = {}

function IInfoPanelViewUI:setVisible(bool)
end

function IInfoPanelViewUI:addBuffIcon(iconUi, index)
end

function IInfoPanelViewUI:addBuffBigIcon(iconUi, index)
end

function IInfoPanelViewUI:setRoleQiProgress(value)
end

function IInfoPanelViewUI:setRoleQiMaxProgress(value)
end

function IInfoPanelViewUI:setRoleQiAndQiMaxValue(qiValue, qiMaxValue)
end

function IInfoPanelViewUI:setRoleNeiLiProgress(value)
end

function IInfoPanelViewUI:setRoleNeiLiMaxProgress(value)
end

function IInfoPanelViewUI:setRoleNeiLiAndNeiLiMaxValue(neiLiValue, neiLiMaxValue)
end

function IInfoPanelViewUI:setTiliMaxProgress(percent)
end

function IInfoPanelViewUI:setTiliProgress(percent)
end

function IInfoPanelViewUI:setRoleName(name)
end

function IInfoPanelViewUI:showOperationName(name)
end

function IInfoPanelViewUI:hideOperationName(hideAnimStyle)
end

function IInfoPanelViewUI:removeAllOperationName()
end

function IInfoPanelViewUI:__moveNextOperationName()
end

function IInfoPanelViewUI:getBigIconNode(index)
end

function IInfoPanelViewUI:getIconNode(index)
end

function IInfoPanelViewUI:showNeiliCost(value)
end

function IInfoPanelViewUI:__cloneActiveName()
end

function IInfoPanelViewUI:registerClickFunc(beganFunc, releaseFunc, canceledFunc, pressingUpdateFunc)
end

function IInfoPanelViewUI:showAllBuffPanel()
end

function IInfoPanelViewUI:hideAllBuffPanel()
end

return interface("IInfoPanelViewUI", IInfoPanelViewUI)
00000000