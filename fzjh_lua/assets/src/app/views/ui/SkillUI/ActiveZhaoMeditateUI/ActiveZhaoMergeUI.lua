--[[
Descripttion: 
version: 
Author: LvBin
Date: 2026-07-20 19:50:52
--]]
local ActiveZhaoMergeUI = class("ActiveZhaoMergeUI", LayerEx)

function ActiveZhaoMergeUI:create()
	local p = ActiveZhaoMergeUI:new()
	p:init()
	return p
end

function ActiveZhaoMergeUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoMergeUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoMergeUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoMergeUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoMergeUI:setTextTitle(text)
	self.Text_title:setString(text)
end

function ActiveZhaoMergeUI:setText1(text)
	self.Text_1:setString(text)
end


function ActiveZhaoMergeUI:setTitleListView(array)
    self.ListView_tab:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:__createPanelTitle(v) 
        self.ListView_tab:pushBackCustomItem(panel)
    end
end

function ActiveZhaoMergeUI:lightTab(titleName)
	local items = self.ListView_tab:getItems()
	for k, item in pairs(items) do
		if item.titleName == titleName then
			item.Text_title:setTextColor({r = 249, g = 249, b = 0})
		else
			item.Text_title:setTextColor({r = 255, g = 255, b = 255})
		end
	end
end

function ActiveZhaoMergeUI:__createPanelTitle(data)
    local panel = self.Panel_title:clone()
    Helper:convertUIByParent(panel)

    panel.Text_title:setString(data["title"])
    panel.titleName = data["title"]
    panel:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return panel
end

function ActiveZhaoMergeUI:setSkillListView(array)
    if MapIsEmpty(array) then
        self.ListView_1:removeAllItems()
        return 
    end

	local isJumpToTop = false
	if #self.ListView_1:getItems() == 0 then
		isJumpToTop = true
	end

    for i =1,#array do
        local panel = self.ListView_1:getItem(i - 1)
        if panel == nil then
            panel = self:__createPanelItem()
            self.ListView_1:pushBackCustomItem(panel)
        end
		self:__initPanelItem(panel,array[i])
    end

    for i = #array + 1, #self.ListView_1:getItems() do
        self.ListView_1:removeLastItem()
    end

	if isJumpToTop then
		self:skillListViewJumpToTop()
	end
end

function ActiveZhaoMergeUI:skillListViewJumpToTop()
	self.ListView_1:jumpToTop()
end

function ActiveZhaoMergeUI:lightCanyeItem(itemId)
	local items = self.ListView_1:getItems()
	for k, item in ipairs(items) do
		if item.itemId == itemId then
			item.Text_name:setTextColor({r = 249, g = 249, b = 0})
			item.Text_lv:setTextColor({r = 249, g = 249, b = 0})
		else
			item.Text_name:setTextColor({r = 255, g = 255, b = 255})
			item.Text_lv:setTextColor({r = 255, g = 255, b = 255})
		end
	end
end

function ActiveZhaoMergeUI:setTextPanelItemNum(itemId,text)
	local items = self.ListView_1:getItems()
	for k, item in ipairs(items) do
		if item.itemId == itemId then
			item.Text_lv:setString(text)
		end
	end	
end

function ActiveZhaoMergeUI:__createPanelItem()
    local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function ActiveZhaoMergeUI:__initPanelItem(item,data)
	item.itemId = data.itemId
    item.Text_name:setString(data.nameText)
    item.Text_lv:setString(data.lvText)
    item.Text_name:setTextColor(data.textColor)
    item.Text_lv:setTextColor(data.textColor)

    item:releaseFunc(function()
		if data.func then
			data.func()
		end
    end)
end

function ActiveZhaoMergeUI:setCanYePanel(data)
	self.Panel_attrInfo.Text_1:setVisible(data.visible)
	self.Panel_attrInfo.Image_1:setVisible(data.visible)
    self.Panel_attrInfo.Text_1:setString(data.text1)
    self.Panel_attrInfo.Text_2:setString(data.text2)
    self.Panel_attrInfo.Text_3:setString(data.text3)
    self.Panel_attrInfo.Text_4:setString(data.text4)
end

function ActiveZhaoMergeUI:setSelectText(text)
	self.Panel_attrInfo.Image_1.Text_selectNum:setString(text)
end

function ActiveZhaoMergeUI:setButtonMin(func)
	self.Panel_attrInfo.Image_1.Button_1:releaseFunc(
		function()
			if func then
				func()
			end
		end
	)
end

function ActiveZhaoMergeUI:setButtonMax(func)
	self.Panel_attrInfo.Image_1.Button_4:releaseFunc(
		function()
			if func then
				func()
			end
		end
	)
end

function ActiveZhaoMergeUI:setButtonChange(buttonName,data)
	self.Panel_attrInfo.Image_1[buttonName]:releaseFuncTotally(
		function()
			data.beganFunc()
		end,function()
			data.endedFunc()
		end,function()
			data.canceledFunc()
		end
	)
end

function ActiveZhaoMergeUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoMergeUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoMergeUI0