local YaShiBenefitUI = class("YaShiBenefitUI", LayerEx)

function YaShiBenefitUI:create()
	local p = YaShiBenefitUI:new()
	p:init()
	return p
end

function YaShiBenefitUI:init()
    self.__round = require("Layer/SkillUI/MapActivePracticeUI.lua").create()['root']
    self.__round:addTo(self)

    Helper:convertUIByParent(self)
    self.Text_desc:setVisible(false)
	self.Button_1:setVisible(true)
    self.Panel_back:setBackGroundColorOpacity(130)
end

function YaShiBenefitUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function YaShiBenefitUI:setTipVisible(visible)
    self.Text_notSkillTip:setVisible(visible)
end

function YaShiBenefitUI:setTextAttr1(text)
    self.Text_attr1:setString(text)
end

function YaShiBenefitUI:setTextAttr2(text)
    self.Text_attr2:setString(text)
end

function YaShiBenefitUI:setTabListView(array)
    self.Image_tab.ListView_tab:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:__createPanelTitle(v) 
        self.Image_tab.ListView_tab:pushBackCustomItem(panel)
    end
end

function YaShiBenefitUI:lightTab(titleName)
	local items = self.Image_tab.ListView_tab:getItems()
	for k, item in pairs(items) do
		if item.titleName == titleName then
			item.Image_back:setVisible(true)
		else
			item.Image_back:setVisible(false)
		end
	end
end

function YaShiBenefitUI:__createPanelTitle(data)
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

function YaShiBenefitUI:setSkillListView(array)
    self.ListView_skillListArea:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self:__createPanelSkill(v) 
        self.ListView_skillListArea:pushBackCustomItem(panel)
    end
end

function YaShiBenefitUI:insertActive(insetPos,data)
    local panel = self:__createPanelActive(data) 
    self.ListView_skillListArea:insertCustomItem(panel,insetPos)
end

function YaShiBenefitUI:jumpToItem(insetPos)
    self.ListView_skillListArea:jumpToItem(insetPos,cc.p(0,0.5),cc.p(0.5,0.5))
end

function YaShiBenefitUI:__createPanelSkill(data)
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

function YaShiBenefitUI:__createPanelActive(data)
    local panel = self.Panel_zhao:clone()

    Helper:convertUIByParent(panel)

    panel.Text_zhaoName:setString(data.text1)
    panel.Text_num:setString(data.text2)
    
    panel:releaseFunc(function()
		if data.func then
			data.func()
		end
    end)
    
    return panel
end

function YaShiBenefitUI:setButtonFunc(func)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return YaShiBenefitUI0000000000000000