--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-08-01 18:03:08
--]]
local SkillInfoUI = class("SkillInfoUI", LayerEx)

function SkillInfoUI:create()
    local p = SkillInfoUI:new()
    p:init()
    return p
end

function SkillInfoUI:init()
    self._round = require("Layer/SkillUI/SkillInfoUI.lua").create()["root"]
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SkillInfoUI:updateSkinUI(skin_config)
    if skin_config == nil then
        return
    end

    if skin_config.AttrTabpic then
        self.Image_tab:loadTexture(skin_config.AttrTabpic, 0)
    end

    self.__clickpic = skin_config.Attrclickpic

    if skin_config.Basicbtnpic then
        self.Button_tab:loadTextureNormal(skin_config.Basicbtnpic, 0)
        self.Button_skillBreak:loadTextureNormal(skin_config.Basicbtnpic, 0)
        self.Button_lianGong:loadTextureNormal(skin_config.Basicbtnpic, 0)
        self.Button_prepare:loadTextureNormal(skin_config.Basicbtnpic, 0)
    end
end

function SkillInfoUI:showUI()
    self:show()
end

function SkillInfoUI:hideUI()
    self:hide()
end

function SkillInfoUI:setTextExp(text)
    self.Text_exp:setString(text)
end

function SkillInfoUI:setTextPot(text)
    self.Text_pot:setString(text)
end

function SkillInfoUI:setPanelDi(callback)
    self.Panel_di:releaseFunc(
        function()
            callback()
        end
    )
end

function SkillInfoUI:setButton2(isVisible, buttonName, callback)
    self.Button_prepare:setVisible(isVisible)
    if isVisible then
        self.Button_prepare.Text_buttonName:setString(buttonName)
        self.Button_prepare:releaseFunc(
            function()
                callback()
            end
        )
    end
end

function SkillInfoUI:setButton1(isVisible, buttonName, callback)
    self.Button_tab:setVisible(isVisible)
    if isVisible then
        self.Button_tab.Text_buttonName:setString(buttonName)
        self.Button_tab:releaseFunc(
            function()
                callback()
            end
        )
    end
end

function SkillInfoUI:setButton3(isVisible, buttonName, callback)
    self.Button_skillBreak:setVisible(isVisible)
    if isVisible then
        self.Button_skillBreak.Text_buttonName:setString(buttonName)
        self.Button_skillBreak:releaseFunc(
            function()
                callback()
            end
        )
    end
end

function SkillInfoUI:setButtonSkillBreakTexture(imgPath)
    self.Button_skillBreak:loadTextureNormal(imgPath, 0)
end

function SkillInfoUI:setButton4(isVisible, buttonName, callback)
    self.Button_lianGong:setVisible(isVisible)
    if isVisible then
        self.Button_lianGong.Text_buttonName:setString(buttonName)
        self.Button_lianGong:releaseFunc(
            function()
                callback()
            end
        )
    end
end

function SkillInfoUI:removeTitleTabListViewAllItems()
    self.Image_tab.ListView_tab:removeAllItems()
end

function SkillInfoUI:insertPanelToTitleTabListView(panel)
    if self.__clickpic and panel.loadTexture then
        panel:loadTexture(self.__clickpic, 0)
    end
    self.Image_tab.ListView_tab:pushBackCustomItem(panel)
end

function SkillInfoUI:getListViewTabItems()
    return self.Image_tab.ListView_tab:getItems()
end

function SkillInfoUI:setTitleTabListViewScrollBarEnabled(bool)
    return self.Image_tab.ListView_tab:setScrollBarEnabled(bool)
end

function SkillInfoUI:getSkillListView()
    return self.ListView_skillListArea
end

function SkillInfoUI:removeSkillListViewAllItems()
    self.ListView_skillListArea:removeAllItems()
end

return SkillInfoUI
000000