local recordAndLearnSKillsUI = class("recordAndLearnSKillsUI", cc.Layer)

function recordAndLearnSKillsUI:create()
    local p = recordAndLearnSKillsUI:new()
    p:init()
    return p
end

function recordAndLearnSKillsUI:init()
	local UI = require("Layer/recordAndLearnSKillsUI/recordAndLearnSKillsUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	
    self:hide()
end

function recordAndLearnSKillsUI:showUI()
	self:show()
end

function recordAndLearnSKillsUI:hideUI()
	self:hide()
end

function recordAndLearnSKillsUI:showItemInfos(infos)
    if MapIsEmpty(infos) then
        self.ListView_item_1:removeAllItems()
        return 
    end

	local isJumpToTop = false
	if #self.ListView_item_1:getItems() == 0 then
		isJumpToTop = true
	end

    for i =1,#infos do
        local panel = self.ListView_item_1:getItem(i - 1)
        if panel == nil then
            local panel = self:__cloneItemPanel()
            self:__initItemPanel(panel,infos[i])
            self.ListView_item_1:pushBackCustomItem(panel)
        else
            self:__initItemPanel(panel,infos[i])
        end
    end

    for i = #infos + 1, #self.ListView_item_1:getItems() do
        self.ListView_item_1:removeLastItem()
    end

	if isJumpToTop then
		self.ListView_item_1:jumpToTop()
	end
end

function recordAndLearnSKillsUI:showBagItemInfos(infos)
    if MapIsEmpty(infos) then
        self.Panel_bag.ListView_item_2:removeAllItems()
        return 
    end

	local isJumpToTop = false
	if #self.Panel_bag.ListView_item_2:getItems() == 0 then
		isJumpToTop = true
	end

    for i =1,#infos do
        local panel = self.Panel_bag.ListView_item_2:getItem(i - 1)
        if panel == nil then
            local panel = self:__cloneBagItemPanel()
            self:__initBagItemPanel(panel,infos[i])
            self.Panel_bag.ListView_item_2:pushBackCustomItem(panel)
        else
            self:__initBagItemPanel(panel,infos[i])
        end
    end

    for i = #infos + 1, #self.Panel_bag.ListView_item_2:getItems() do
        self.Panel_bag.ListView_item_2:removeLastItem()
    end

	if isJumpToTop then
		self.Panel_bag.ListView_item_2:jumpToTop()
	end
end

function recordAndLearnSKillsUI:setTitleName(name)
    name = Helper:getDef(name,"")
	self.Text_title:setString(name)
end

function recordAndLearnSKillsUI:seTipsText(text)
    text = Helper:getDef(text,"")
	self.Text_tips:setString(text)
end

function recordAndLearnSKillsUI:setTipsVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Text_tips:setVisible(visible)
end

function recordAndLearnSKillsUI:setTitle_1Func(func)
	self.Panel_title_1:releaseFunc(function()
		self:setTtitleBgLight(1)
		if func then
			func()
		end
	end)
end

function recordAndLearnSKillsUI:setTitle_2Func(func)
	self.Panel_title_2:releaseFunc(function()
		self:setTtitleBgLight(2)
		if func then
			func()
		end
	end)
end

function recordAndLearnSKillsUI:setTitle_3Func(func)
	self.Panel_title_3:releaseFunc(function()
		self:setTtitleBgLight(3)
		if func then
			func()
		end
	end)
end

function recordAndLearnSKillsUI:setTitle_4Func(func)
	self.Panel_title_4:releaseFunc(function()
        self:setTtitleBgLight(4)
		if func then
			func()
		end
	end)
end

function recordAndLearnSKillsUI:setTtitleBgLight(index)
    for i =1 ,4 do
        if i == index then
            self["Panel_title_"..tostring(i)].Image_back:setVisible(true)
        else
            self["Panel_title_"..tostring(i)].Image_back:setVisible(false)
        end
    end
end

function recordAndLearnSKillsUI:setTtitleText(textList)
	for i = 1,4 do
		local text = Helper:getDef(textList[i],"")
    	self["Panel_title_"..tostring(i)].Text_title:setString(text)
	end
end

function recordAndLearnSKillsUI:setButtonBackFunc(func)
	self.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function recordAndLearnSKillsUI:setPanelInfoVisible(visible)
	visible = Helper:getDef(visible,false)
	self.Panel_infoBg:setVisible(visible)
    self.Panel_info:setVisible(visible)
end

function recordAndLearnSKillsUI:setPanelInfoDescText(text)
	self.Panel_info.Text_desc:setString(text)
	self.Panel_info.Text_desc:setColor(cc.c3b(255,255,255))
end

function recordAndLearnSKillsUI:setPanelInfoNameText(text)
	self.Panel_info.Text_name:setString(text)
end

function recordAndLearnSKillsUI:setPanelInfoCloseFunc()
	self.Panel_info.Button_close:releaseFunc(function()
		self:setPanelInfoVisible(false)
	end)
end

function recordAndLearnSKillsUI:setPanelInfoConfirmFunc(func)
	self.Panel_info.Button_confirm:releaseFunc(function()
		self:setPanelInfoVisible(false)
        if func then
            func()
        end
	end)
end

function recordAndLearnSKillsUI:__cloneItemPanel()
	local panel = self.Panel_item_1:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function recordAndLearnSKillsUI:__cloneBagItemPanel()
	local panel = self.Panel_item_2:clone()
	Helper:convertUIByParent(panel)
	return panel
end

function recordAndLearnSKillsUI:__initItemPanel(panel,panelInfo)
	panel.Text_name:setString(panelInfo.name)
	panel.Image_1:loadTexture("Image/UI/recordAndLearnSKillsUI/kongdi.png")
	panel.Image_1.Text_name:setString(panelInfo.btnName)
	panel.Image_1:setVisible(true)

	if panelInfo.state and panelInfo.state == 1 then
		panel.Image_1:setVisible(false)
	end
    
	panel.Text_1:setVisible(panelInfo.state == 1)
    
	panel.Text_1:setString("已学习")

	panel.Image_1:releaseFunc(function()
		if panelInfo.func then
			panelInfo.func()
		end
	end)
end

function recordAndLearnSKillsUI:__initBagItemPanel(panel,panelInfo)
    panel.Image_tiao.Text_name:setString(panelInfo.name)
end

Helper:classDefNodeGetInstance(recordAndLearnSKillsUI)

return recordAndLearnSKillsUI


0000000