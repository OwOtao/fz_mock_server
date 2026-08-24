local BlackStoreResultUI = class("BlackStoreResultUI", LayerEx)

function BlackStoreResultUI:create()
    local p = BlackStoreResultUI:new()
    p:init()
    return p
end

function BlackStoreResultUI:init()
    self._UI = require("Layer/BlackStoreUI/BlackStoreResultUI.lua").create() ['root']

    self._UI:addTo(self)

    Helper:convertUIByParent(self)
end

function BlackStoreResultUI:showUI()
    self:show()
end

function BlackStoreResultUI:hideUI()
    self:hide()
end

function BlackStoreResultUI:setButton1Name(name)
    self.Button_1.Text_buttonName:setString(name)
end

function BlackStoreResultUI:setButton2Name(name)
    self.Button_2.Text_buttonName:setString(name)
end

-- @desc 设置按钮1
function BlackStoreResultUI:setButton1Func(func)
	self.Button_1:releaseFunc(function()
        if func then
			func()
		end
	end)
end

-- @desc 设置按钮2
function BlackStoreResultUI:setButton2Func(func)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function BlackStoreResultUI:setText2Str(str)
    self.Text_2:setString(Helper:getDef(str, ""))
end

function BlackStoreResultUI:setText3Str(str)
    self.Text_3:setString(Helper:getDef(str, ""))
end

function BlackStoreResultUI:setText4Str(str)
    self.Text_4:setString(Helper:getDef(str, ""))
end

function BlackStoreResultUI:setLeftList(list)
    for i =1,#list do
        local panel = self.ListView_1:getItem(i - 1)
        if panel == nil then
            local panel = self:__createPanelItem()
            self:__initPanelItem(panel,list[i])
            self.ListView_1:pushBackCustomItem(panel)
        else
            self:__initPanelItem(panel,list[i])
        end
    end

    if #list < #self.ListView_1:getItems() then
        for i = #list + 1, #self.ListView_1:getItems() do
            self.ListView_1:removeLastItem()
        end
    end
end

function BlackStoreResultUI:setRightList(list)
    for i =1,#list do
        local panel = self.ListView_2:getItem(i - 1)
        if panel == nil then
            local panel = self:__createPanelItem()
            self:__initPanelItem(panel,list[i])
            self.ListView_2:pushBackCustomItem(panel)
        else
            self:__initPanelItem(panel,list[i])
        end
    end

    if #list < #self.ListView_2:getItems() then
        for i = #list + 1, #self.ListView_2:getItems() do
            self.ListView_2:removeLastItem()
        end
    end
end

function BlackStoreResultUI:__createPanelItem()
    local panel = self.Panel_item1:clone()
    Helper:convertUIByParent(panel)

    return panel
end

function BlackStoreResultUI:__initPanelItem(item,itemInfo)
    if MapIsEmpty(itemInfo) == false then
        item.Text_name:setTextColor({r = 255, g = 255, b = 255})
        item.Text_name:setString(itemInfo.name)
    end
end


return BlackStoreResultUI
0000000