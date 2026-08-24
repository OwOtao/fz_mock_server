--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-09-04 18:00:39
--]]
local AppearanceInfoUI = class("AppearanceInfoUI", LayerEx)

function AppearanceInfoUI:create()
    local p = AppearanceInfoUI:new()
    p:init()
    return p
end

function AppearanceInfoUI:init()
    self._UI = require("Layer/GoodsInfo/AppearanceInfoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function AppearanceInfoUI:showUI()
    self:show()
end

function AppearanceInfoUI:hideUI()
    self:hide()
end

function AppearanceInfoUI:setTitle(text)
    self.Text_Tital:setString(text)
end

function AppearanceInfoUI:setItemName(text)
    self.Text_name:setString(text)
end

function AppearanceInfoUI:setItemDesc(text)
    self.Text_desc:setString(text)
end

function AppearanceInfoUI:setSubTitle(text)
    self.Text_subTitle:setString(text)
end

function AppearanceInfoUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function AppearanceInfoUI:panelAnimAddNode(node)
    return self.Panel_anim:addChild(node)
end

function AppearanceInfoUI:panelAnimRemoveAllChildren()
    return self.Panel_anim:removeAllChildren()
end

function AppearanceInfoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function AppearanceInfoUI:setButtonLeft(func)
    self.Button_left:releaseFunc(
        function()
            func()
        end
    )
end

function AppearanceInfoUI:setButtonRight(func)
    self.Button_right:releaseFunc(
        function()
            func()
        end
    )
end


Helper:classDefNodeGetInstance(AppearanceInfoUI)

return AppearanceInfoUI
000000000