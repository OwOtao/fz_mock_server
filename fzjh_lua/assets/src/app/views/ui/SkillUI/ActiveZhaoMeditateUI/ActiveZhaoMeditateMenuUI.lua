local ActiveZhaoMeditateMenuUI = class("ActiveZhaoMeditateMenuUI", LayerEx)

function ActiveZhaoMeditateMenuUI:create()
	local p = ActiveZhaoMeditateMenuUI:new()
	p:init()
	return p
end

function ActiveZhaoMeditateMenuUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoMeditateMenuUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoMeditateMenuUI:setTextTitle(text)
	self.Text_title:setString(text)
end

function ActiveZhaoMeditateMenuUI:setText1(text)
    self.Text_1:setString(text)
end

function ActiveZhaoMeditateMenuUI:setText2(text)
    self.Text_2:setString(text)
end

function ActiveZhaoMeditateMenuUI:setNotSkillTextVisible(isVisible)
    self.Text_notSkill:setVisible(isVisible)
end

function ActiveZhaoMeditateMenuUI:setTitleListView(array)
    self.ListView_tab:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:createPanelTitle(v) 
        self.ListView_tab:pushBackCustomItem(panel)
    end
end

function ActiveZhaoMeditateMenuUI:lightTab(titleName)
	local items = self.ListView_tab:getItems()
	for k, item in pairs(items) do
		if item.titleName == titleName then
			item.Text_title:setTextColor({r = 249, g = 249, b = 0})
		else
			item.Text_title:setTextColor({r = 255, g = 255, b = 255})
		end
	end
end

function ActiveZhaoMeditateMenuUI:createPanelTitle(data)
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

function ActiveZhaoMeditateMenuUI:setSkillListView(array)
    if MapIsEmpty(array) then
        self.ListView_skillListArea:removeAllItems()
        return 
    end

	local isJumpToTop = false
	if #self.ListView_skillListArea:getItems() == 0 then
		isJumpToTop = true
	end

    for i =1,#array do
        local panel = self.ListView_skillListArea:getItem(i - 1)
        if panel == nil then
            local panel = self:createPanelSkill()
            self:initPanelSkill(panel,array[i])
            self.ListView_skillListArea:pushBackCustomItem(panel)
        else
            self:initPanelSkill(panel,array[i])
        end
    end

    for i = #array + 1, #self.ListView_skillListArea:getItems() do
        self.ListView_skillListArea:removeLastItem()
    end

	if isJumpToTop then
		self:skillListViewJumpToTop()
	end
end

function ActiveZhaoMeditateMenuUI:createActivePanel(data)
	local panel = self:createPanelSkill()
	self:initPanelSkill(panel,data)
	return panel
end

function ActiveZhaoMeditateMenuUI:refreshActivePanelTextColor(item,textColor)
	item.Text_name:setTextColor(textColor)
    item.Text_lv:setTextColor(textColor)
end

function ActiveZhaoMeditateMenuUI:insertActivePanel(insetPos,panel)
    self.ListView_skillListArea:insertCustomItem(panel,insetPos)
end

function ActiveZhaoMeditateMenuUI:skillListViewJumpToTop()
	self.ListView_skillListArea:jumpToTop()
end

function ActiveZhaoMeditateMenuUI:createPanelSkill()
    local panel = self.Panel_skill:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function ActiveZhaoMeditateMenuUI:initPanelSkill(item,data)
    item.Text_name:setString(data.name)
    item.Text_lv:setString(data.lvText)
    item.Text_name:setTextColor(data.textColor)
    item.Text_lv:setTextColor(data.textColor)
    item.Text_name:setPositionX(data.namePosX)
    
    item:releaseFunc(function()
		if data.func then
			data.func()
		end
    end)
end

function ActiveZhaoMeditateMenuUI:setMeditateText1(text)
    self.Panel_attrInfo.Text_1:setString(text)
end

function ActiveZhaoMeditateMenuUI:setMeditateText2(text)
    self.Panel_attrInfo.Text_2:setString(text)
end

function ActiveZhaoMeditateMenuUI:setMeditateText3(text)
    self.Panel_attrInfo.Text_3:setString(text)
end

function ActiveZhaoMeditateMenuUI:setMeditateText4(text)
    self.Panel_attrInfo.Text_4:setString(text)
end

function ActiveZhaoMeditateMenuUI:setMeditateButtonName(buttonName)
	self.Panel_attrInfo.Button_1.Text_ButtonName:setString(buttonName)
end

function ActiveZhaoMeditateMenuUI:setMeditateButtonVisible(visible)
	self.Panel_attrInfo.Button_1:setVisible(visible)
end

function ActiveZhaoMeditateMenuUI:setMeditateButtonFunc(func)
    self.Panel_attrInfo.Button_1:releaseFunc(function()
		if func then
			func()
		end
    end)
end

function ActiveZhaoMeditateMenuUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoMeditateMenuUI:setButtonBack(func)
	self.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ActiveZhaoMeditateMenuUI:setButton1(func)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ActiveZhaoMeditateMenuUI:setButton2(func)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoMeditateMenuUI000