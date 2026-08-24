--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-13 14:43:35
--]]
--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-01-07 17:38:21
--]]
local MapRoleBagUI = class("MapRoleBagUI", LayerEx)

function MapRoleBagUI:create()
    local p = MapRoleBagUI:new()
    p:init()
    return p
end

function MapRoleBagUI:init()
    self.__ui = require("Layer/MapRoleUI/MapRoleBagUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUI(self)
    
    self:setVisible(false)
end

function MapRoleBagUI:showUI()
    self:setVisible(true)
end

function MapRoleBagUI:hideUI()
    self:setVisible(false)
end

function MapRoleBagUI:getItem(index)
    return self.ListView_bag:getItem(index)
end

function MapRoleBagUI:getItems()
    return self.ListView_bag:getItems()
end

function MapRoleBagUI:removeLastItem()
    self.ListView_bag:removeLastItem()
end

function MapRoleBagUI:insertItemToListView(item)
    self.ListView_bag:pushBackCustomItem(item)
end

function MapRoleBagUI:createItemPanel()
	local row = self.Panel_item:clone()
	Helper:convertUIByParent(row)
	return row
end

Helper:classDefNodeGetInstance(MapRoleBagUI)
return MapRoleBagUI
0000000