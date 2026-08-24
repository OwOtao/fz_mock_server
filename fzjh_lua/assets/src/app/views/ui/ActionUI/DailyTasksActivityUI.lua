local DailyTasksActivityUI = class("DailyTasksActivityUI", LayerEx)

function DailyTasksActivityUI:create()
    local p = DailyTasksActivityUI:new()
    p:init()
    return p
end

function DailyTasksActivityUI:init()
    self._UI = require("Layer/ActionUI/DailyTasksActivityUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_1:setScrollBarEnabled(false)

    self:setVisible(false)
end

function DailyTasksActivityUI:showUI()
    self:show()
    self:setVisible(true)
end

function DailyTasksActivityUI:hideUI()
    self:hide()
    self:setVisible(false)
end

function DailyTasksActivityUI:setButtonBack(func)
    self.Button_back:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DailyTasksActivityUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DailyTasksActivityUI:setTextDesc(desc)
    self.Text_desc:setString(desc)
end

function DailyTasksActivityUI:setTextStr(index,str)
    if self["Text_"..tostring(index)] then
        self["Text_"..tostring(index)]:setString(str)
    end
end

function DailyTasksActivityUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function DailyTasksActivityUI:setTitle_1Func(func)
    self.Panel_title_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DailyTasksActivityUI:setTitle_2Func(func)
    self.Panel_title_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DailyTasksActivityUI:setTitle_1Name(name)
    self.Panel_title_1.Text_1:setString(name)
end

function DailyTasksActivityUI:setTitle_1Visible(visible)
    self.Panel_title_1.Image_bg:setVisible(Helper:getDef(visible,false))
end

function DailyTasksActivityUI:setTitle_1Enable(enable)
    self.Panel_title_1:setTouchEnabled(Helper:getDef(enable,false))
end

function DailyTasksActivityUI:setTitle_1BackGroundColorOpacity(opacity)
    self.Panel_title_1:setBackGroundColorOpacity(opacity)
end

function DailyTasksActivityUI:setTitle_2Name(name)
    self.Panel_title_2.Text_1:setString(name)
end

function DailyTasksActivityUI:setTitle_2Visible(visible)
    self.Panel_title_2.Image_bg:setVisible(Helper:getDef(visible,false))
end

function DailyTasksActivityUI:setTitle_2Enable(enable)
    self.Panel_title_2:setTouchEnabled(Helper:getDef(enable,false))
end

function DailyTasksActivityUI:setTitle_2BackGroundColorOpacity(opacity)
    self.Panel_title_2:setBackGroundColorOpacity(opacity)
end

function DailyTasksActivityUI:setHongDianVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_hongdian:setVisible(visible)
end

function DailyTasksActivityUI:showPanelItemList(list)
    self.ListView_1:removeAllItems()

    for i, v in ipairs(list) do
        local panel = self:__getPanelItem()
        self:__initPanelItem(panel,v)
        self.ListView_1:pushBackCustomItem(panel)
    end
end

function DailyTasksActivityUI:showPanelItem_1List(list)
    self.ListView_1:removeAllItems()

    for i, v in ipairs(list) do
        local panel = self:__getPanelItem_1()
        self:__initPanelItem_1(panel,v)
        self.ListView_1:pushBackCustomItem(panel)
    end
end

function DailyTasksActivityUI:__getPanelItem()
    local panel = self.Panel_item:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function DailyTasksActivityUI:__initPanelItem(panel,panelInfo)
    panel.Text_1:setString(panelInfo.text1)
    panel.Text_2:setString(panelInfo.text2)
    panel.Button_1:loadTextureNormal(panelInfo.loadTexture)
    panel.Button_1.Text_buttonName:setString(panelInfo.btnName)
    panel.Button_1:releaseFunc(function()
        if panelInfo.func then
            panelInfo.func()
        end
    end)
    panel.Image_iconBg:releaseFunc(function()
        if panelInfo.func1 then
            panelInfo.func1()
        end
    end)
end

function DailyTasksActivityUI:__getPanelItem_1()
    local panel = self.Panel_item_1:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function DailyTasksActivityUI:__initPanelItem_1(panel,panelInfo)
    panel.Text_1:setString(panelInfo.text1)
    panel.Text_2:setString(panelInfo.text2)
    panel.Text_3:setString(panelInfo.text3)
    panel.Image_1:loadTexture(panelInfo.loadTexture)
end

return DailyTasksActivityUI
00000