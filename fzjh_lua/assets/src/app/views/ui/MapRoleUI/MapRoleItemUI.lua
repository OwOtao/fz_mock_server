--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-07 17:33:33
--]]
local MapRoleItemUI = class("MapRoleItemUI", LayerEx)

function MapRoleItemUI:create()
    local p = MapRoleItemUI:new()
    p:init()
    return p
end

function MapRoleItemUI:init()
    self.__ui = require("Layer/MapRoleUI/MapRoleItemUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUI(self)
    
    self:setVisible(false)
end

function MapRoleItemUI:showUI()
    self:setVisible(true)
end

function MapRoleItemUI:hideUI()
    self:setVisible(false)
end

function MapRoleItemUI:getPanelItemInfo()
    return self.Panel_itemDesc
end

function MapRoleItemUI:setPanelItemFunc(func)
    self.Panel_itemDesc:setTouchEnabled(true)
    self.Panel_itemDesc:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MapRoleItemUI:setTextItemName(text)
    self.Text_item_name_desc:setColor(cc.c3b(208,208,208))---设置默认颜色
    self.Text_item_name_desc:setString(text)
end

function MapRoleItemUI:setTextItemType(text)
    self.Text_item_zhuanbei_desc:setString(text)
end

function MapRoleItemUI:setTextItemDesc(text)
    self.TextField_item_desc:setString(text)
end

function MapRoleItemUI:setTextItemTimeDesc(text)
    self.TextField_item_time:setString(text)
end

function MapRoleItemUI:setItemTimeDescVisible(visible)
    visible = Helper:getDef(visible,false)
    self.TextField_item_time:setVisible(visible)
end

function MapRoleItemUI:setRightButtonName(name)
    self.Text_item_chuan_desc:setString(name)
end

function MapRoleItemUI:setRightButtonVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_item_button_desc:setVisible(visible)
end

function MapRoleItemUI:setRightButtonFunc(func)
    self.Image_item_button_desc:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MapRoleItemUI:setLeftButtonName(name)
    self.Text_cangku:setString(name)
end

function MapRoleItemUI:setLeftButtonVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_button_cangku:setVisible(visible)
end

function MapRoleItemUI:setLeftButtonFunc(func)
    self.Image_button_cangku:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MapRoleItemUI:setLoadingBarVisible(visible)
    visible = Helper:getDef(visible,false)
    self.LoadingBar_CD:setVisible(visible)
end

function MapRoleItemUI:setLoadingBarPercent(percent)
    self.LoadingBar_CD:setPercent(percent)
end

Helper:classDefNodeGetInstance(MapRoleItemUI)
return MapRoleItemUI
000000000