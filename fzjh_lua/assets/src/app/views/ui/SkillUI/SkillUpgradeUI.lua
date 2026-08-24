local SkillUpgradeUI = class("SkillUpgradeUI", LayerEx)

function SkillUpgradeUI:create()
	local p = SkillUpgradeUI:new()
	p:init()
	return p
end

function SkillUpgradeUI:init()
    self._round = require("Layer/SkillUI/SkillUpgradeUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SkillUpgradeUI:showUI()
	self:show()
end

function SkillUpgradeUI:hideUI()
	self:hide()
end

function SkillUpgradeUI:setBackFunc(callback)
    self.Panel_back:releaseFunc(function()
		callback()
	end)
end

function SkillUpgradeUI:setTextName(text)
    self.Text_name:setString(text)
end

function SkillUpgradeUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function SkillUpgradeUI:removeSkillListViewAllItems()
    self.Image_whiteKuang.ListView_skill:removeAllItems()
end

function SkillUpgradeUI:insertPanelToSkillListView(panel)
    self.Image_whiteKuang.ListView_skill:pushBackCustomItem(panel)
end

function SkillUpgradeUI:createPanel()
    local panel = self.Panel_skill:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function SkillUpgradeUI:setTextPanelName(panel,name,textColor)
    panel.Text_name:setString(name)

    panel.Text_name:setTextColor(textColor)
end

function SkillUpgradeUI:setTextCondition1(panel,text,textColor)
    panel.Text_con1:setString(text)

    panel.Text_con1:setTextColor(textColor)
end

function SkillUpgradeUI:setTextCondition2(panel,text,textColor)
    panel.Text_con2:setString(text)

    panel.Text_con2:setTextColor(textColor)
end

function SkillUpgradeUI:setTextCondition3(panel,text,textColor)
    panel.Text_con3:setString(text)

    panel.Text_con3:setTextColor(textColor)
end

function SkillUpgradeUI:setLearnTextVisible(panel,visible,textColor)
    panel.Text_learn:setVisible(visible)

    panel.Text_learn:setTextColor(textColor)
end

function SkillUpgradeUI:setLearnButtonVisible(panel,visible)
    panel.Button_learn:setVisible(visible)
end

function SkillUpgradeUI:setLearnButtonFunc(panel,callback)
    panel.Button_learn:releaseFunc(function()
		callback()
	end)
end

return SkillUpgradeUI000