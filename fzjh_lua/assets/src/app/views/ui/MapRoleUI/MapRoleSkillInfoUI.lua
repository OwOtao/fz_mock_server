local MapRoleSkillInfoUI = class("MapRoleSkillInfoUI", LayerEx)

function MapRoleSkillInfoUI:create()
    local p = MapRoleSkillInfoUI:new()
    p:init()
    return p
end

function MapRoleSkillInfoUI:init()
    self.__ui = require("Layer/MapRoleUI/MapRoleSkillInfoUI.lua").create()['root']

    self.__ui:addTo(self)
    
    Helper:convertUI(self)
    
    self:setVisible(false)
end

function MapRoleSkillInfoUI:showUI()
    self:setVisible(true)
end

function MapRoleSkillInfoUI:hideUI()
    self:setVisible(false)
end

function MapRoleSkillInfoUI:removeTitleTabListViewAllItems()
    self.ListView_skill_tab:removeAllItems()
end

function MapRoleSkillInfoUI:insertPanelToTitleTabListView(panel)
    self.ListView_skill_tab:pushBackCustomItem(panel)
end

function MapRoleSkillInfoUI:getListViewTabItems()
    return self.ListView_skill_tab:getItems()
end

function MapRoleSkillInfoUI:setTitleTabListViewScrollBarEnabled(bool)
    return self.ListView_skill_tab:setScrollBarEnabled(bool)
end

function MapRoleSkillInfoUI:setTitleTabListViewItemsMargin(num)
    return self.ListView_skill_tab:setItemsMargin(num)
end

function MapRoleSkillInfoUI:getSkillListView()
    return self.ListView_skill
end

function MapRoleSkillInfoUI:removeSkillListViewAllItems()
    self.ListView_skill:removeAllItems()
end

function MapRoleSkillInfoUI:setButtonPrepareVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Button_prepareSkill:setVisible(visible)
end

function MapRoleSkillInfoUI:setButtonPrepareSkill(func)
    self.Button_prepareSkill:releaseFunc(function()
		if func then
            func()
        end
	end)
end

Helper:classDefNodeGetInstance(MapRoleSkillInfoUI)
return MapRoleSkillInfoUI
0