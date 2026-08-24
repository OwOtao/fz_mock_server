local MapActivePracticeUI = class("MapActivePracticeUI", LayerEx)

function MapActivePracticeUI:create()
	local p = MapActivePracticeUI:new()
	p:init()
	return p
end

function MapActivePracticeUI:init()
    self.__round = require("Layer/SkillUI/MapActivePracticeUI.lua").create()['root']
    self.__round:addTo(self)

    Helper:convertUIByParent(self)
end

function MapActivePracticeUI:setTextAttr1(text)
    self.Text_attr1:setString(text)
end

function MapActivePracticeUI:setTextAttr2(text)
    self.Text_attr2:setString(text)
end

function MapActivePracticeUI:hideTitle()
	self.Text_title:setVisible(false)
end

function MapActivePracticeUI:showTitle()
	self.Text_title:setVisible(true)
end

function MapActivePracticeUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function MapActivePracticeUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function MapActivePracticeUI:setTabListView(array)
    self.Image_tab.ListView_tab:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:__createPanelTitle(v) 
        self.Image_tab.ListView_tab:pushBackCustomItem(panel)
    end
end

function MapActivePracticeUI:lightTab(titleName)
	local items = self.Image_tab.ListView_tab:getItems()
	for k, item in pairs(items) do
		if item.titleName == titleName then
			item.Image_back:setVisible(true)
		else
			item.Image_back:setVisible(false)
		end
	end
end

function MapActivePracticeUI:__createPanelTitle(data)
    local panel = self.Panel_tab:clone()
    Helper:convertUIByParent(panel)

    panel.Text_title:setString(data["title"])
    panel.Image_back:setVisible(false)
    panel.titleName = data["title"]
    panel:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return panel
end

function MapActivePracticeUI:setSkillListView(array)
    self.ListView_skillListArea:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:__createPanelSkill(v) 
        self.ListView_skillListArea:pushBackCustomItem(panel)
    end
end

function MapActivePracticeUI:insertActive(insetPos,data)
    local panel = self:__createPanelActive(data) 
    self.ListView_skillListArea:insertCustomItem(panel,insetPos)
end

function MapActivePracticeUI:jumpToItem(insetPos)
    self.ListView_skillListArea:jumpToItem(insetPos,cc.p(0,0.5),cc.p(0.5,0.5))
end

function MapActivePracticeUI:refreshPanelActive(index,data)
	local panel = self.ListView_skillListArea:getItem(index)

    panel.Text_num:setString(data["exp"])
end

function MapActivePracticeUI:__createPanelSkill(data)
    local panel = self.Panel_skill:clone()

    Helper:convertUIByParent(panel)

	panel.Text_skillName:setString(data["name"])
	
    panel.Image_flod:loadTexture(data["image"],0)
	
	panel:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return panel
end

function MapActivePracticeUI:__createPanelActive(data)
    local panel = self.Panel_zhao:clone()

    Helper:convertUIByParent(panel)

    panel.Text_zhaoName:setString(data["name"])
    panel.Text_num:setString(data["exp"])
    
    panel:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
    
    return panel
end

function MapActivePracticeUI:hideZhaoDesc()
    self.Panel_itemDesc:setVisible(false)
end

function MapActivePracticeUI:showZhaoDesc(data)
	self.Panel_itemDesc:setVisible(true)
	self.Panel_itemDesc.Text_name:setString(data.name)
	self.Panel_itemDesc.Text_level:setString(data.level)
	self.Panel_itemDesc.Text_desc:setString(data.desc)
	self.Panel_itemDesc.Text_exp:setString(data.exp)
	self.Panel_itemDesc.Text_needExp:setString(data.needExp)
	self.Panel_itemDesc:releaseFunc(function()
		self.Panel_itemDesc:setVisible(false)
	end)
	if data.leftButtonName then
		self.Panel_itemDesc.Button_left:setVisible(true)
		self.Panel_itemDesc.Button_left.Text_name:setString(data.leftButtonName)
		self.Panel_itemDesc.Button_left:releaseFunc(function()
			if data["leftFunc"] then
				data["leftFunc"]()
			end
		end)
	else
		self.Panel_itemDesc.Button_left:setVisible(false)
	end
	
	if data.rightButtonName then
		self.Panel_itemDesc.Button_right:setVisible(true)
		self.Panel_itemDesc.Button_right.Text_name:setString(data.rightButtonName)
		self.Panel_itemDesc.Button_right:releaseFunc(function()
			if data["rightFunc"] then
				data["rightFunc"]()
			end
		end)
	else
		self.Panel_itemDesc.Button_right:setVisible(false)
	end
end

function MapActivePracticeUI:hidePanelTip()
	self.Panel_tips:setVisible(false)
end

function MapActivePracticeUI:showPanelTip(text)
	self.Panel_tips:setVisible(true)
    local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Panel_tips.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			dialog:show(text)
			dialog:setPanelBack(function()
				self.Panel_tips.Image_7:setVisible(true)
			end)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Panel_tips.Image_7:setVisible(true)
		end
	end)
end

return MapActivePracticeUI000