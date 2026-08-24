local SkillBreakThroughUI = class("SkillBreakThroughUI", LayerEx)

function SkillBreakThroughUI:create()
	local p = SkillBreakThroughUI:new()
	p:init()
	return p
end

function SkillBreakThroughUI:init()
    self._round = require("Layer/SkillUI/SkillBreakThroughUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SkillBreakThroughUI:setWxxdCount1(text)
    self.Text_wxxdCount1:setString(text)
end

function SkillBreakThroughUI:setWxxdCount2(text)
    self.Text_wxxdCount2:setString(text)
end

function SkillBreakThroughUI:setWxxdCount3(text)
    self.Text_wxxdCount3:setString(text)
end

function SkillBreakThroughUI:setWxxdCount4(text)
    self.Text_wxxdCount4:setString(text)
end

function SkillBreakThroughUI:setTitleListView(array)
    self.Image_tab.ListView_tab:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:_createPanelTitle(v) 
        self.Image_tab.ListView_tab:pushBackCustomItem(panel)
    end
end

function SkillBreakThroughUI:lightTab(titleName)
	local items = self.Image_tab.ListView_tab:getItems()
	for k, item in pairs(items) do
		if item.titleName == titleName then
			item.Image_back:setVisible(true)
		else
			item.Image_back:setVisible(false)
		end
	end
end

function SkillBreakThroughUI:_createPanelTitle(data)
    local panel = self.Panel_title:clone()
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

function SkillBreakThroughUI:setSkillListView(array)
    self.ListView_skillListArea:removeAllItems()

    self.ListView_skillListArea:setSwallowTouches(false)

    local roleItemNum = #array
    local listSize = self.ListView_skillListArea:getContentSize()
    local itemSize = self.Panel_skill:getContentSize()
    local itemsMargin = self.ListView_skillListArea:getItemsMargin()
    local itemMaxCount = Helper:mathFloor(listSize.height/(itemSize.height + itemsMargin)) + 2
    local isSchedule = true

    if roleItemNum < itemMaxCount then
        itemMaxCount = roleItemNum
        isSchedule = false
    end

    self.ListView_skillListArea:setItemHeight(itemSize.height)

    self.ListView_skillListArea:setItemInitFunc(function(item,info)
        self:__initPanelSkill(item,info)
    end)

    self.ListView_skillListArea:setItemCreateFunc(function()
        return self:__createPanelSkill()
    end)

    self.ListView_skillListArea:showListView(array,itemMaxCount)

	if isSchedule then
        self.ListView_skillListArea:jumpToTop()

        local isTrue = self.ListView_skillListArea:refreshReuseItems()
		while isTrue do
			isTrue = self.ListView_skillListArea:refreshReuseItems()
		end

        if self.listViewSchedule then
            self:unschedule(self.listViewSchedule)
            self.listViewSchedule = nil
        end

        self.listViewSchedule = self:schedule(function()
            self.ListView_skillListArea:refreshReuseItems()
        end)
    end
end

function SkillBreakThroughUI:__createPanelSkill()
    local panel = self.Panel_skill:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function SkillBreakThroughUI:__initPanelSkill(item,data)
    item.Text_name:setString(data["name"])
    item.Text_lv:setString(data["lv"])
    
    item:releaseFunc(function()
		if data["func"] then
			data["func"]()
		end
    end)
end

return SkillBreakThroughUI000000000000000