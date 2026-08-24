local HiddenMeridianBuffUI = class("HiddenMeridianBuffUI", LayerEx)

function HiddenMeridianBuffUI:create()
    local p = HiddenMeridianBuffUI:new()
    p:init()
    return p
end

function HiddenMeridianBuffUI:init()
    self.__ui = require("Layer/MeridianUI/HiddenMeridian/HiddenMeridianBuffUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function HiddenMeridianBuffUI:showUI()
    self:show()
end

function HiddenMeridianBuffUI:hideUI()
    self:hide()
end

function HiddenMeridianBuffUI:setTextTitle(text)
    self.Image_titleBack.Text_title:setString(text)
end

function HiddenMeridianBuffUI:setTextNotBuffVisible(bool)
    self.Text_notBuff:setVisible(bool)
end

function HiddenMeridianBuffUI:setPanelTitleName(index, name)
    self["Panel_title" .. index].Text_name:setString(name)
end

function HiddenMeridianBuffUI:setPanelTitleColor(index, color)
    self["Panel_title" .. index].Text_name:setTextColor(color)
end

function HiddenMeridianBuffUI:setPanelTitleFunc(index, func)
    self["Panel_title" .. index]:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function HiddenMeridianBuffUI:setButtonName(index, name)
    if self["Button_" .. index] == nil then
        return
    end

    self["Button_" .. index].Text_buttonName:setString(name)
end

function HiddenMeridianBuffUI:setButtonVisible(index, bool)
    if self["Button_" .. index] == nil then
        return
    end

    self["Button_" .. index]:setVisible(bool)
end

function HiddenMeridianBuffUI:setButtonFunc(index, func)
    if self["Button_" .. index] == nil then
        return
    end
    self["Button_" .. index]:releaseFunc(
        function()
            func()
        end
    )
end

function HiddenMeridianBuffUI:removeListViewAllItems()
    self.ListView_buff:removeAllItems()
end

function HiddenMeridianBuffUI:insertPanelToListView(panel)
    self.ListView_buff:pushBackCustomItem(panel)
end

function HiddenMeridianBuffUI:createPanel()
    local panel = self.Panel_buff:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianBuffUI:setPanelInfoVisible(bool)
    self.Panel_info:setVisible(bool)
end

function HiddenMeridianBuffUI:setPanelInfoFunc(func)
    self.Panel_info:releaseFunc(
        function()
            func()
        end
    )
end

function HiddenMeridianBuffUI:removeInfoListViewAllItems()
    self.Panel_info.ListView_info:removeAllItems()
end

function HiddenMeridianBuffUI:insertPanelToInfoListView(panel)
    self.Panel_info.ListView_info:pushBackCustomItem(panel)
end

function HiddenMeridianBuffUI:getInfoListViewItem(index)
    return self.Panel_info.ListView_info:getItem(index)
end

function HiddenMeridianBuffUI:createInfoTitlePanel()
    local panel = self.Panel_infoTitle:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianBuffUI:createInfoTextPanel()
    local panel = self.Panel_infoText:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianBuffUI:createInfoLongTextPanel()
    local panel = self.Panel_infoLongText:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianBuffUI:createInfoAttrPanel()
    local panel = self.Panel_infoAttr:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianBuffUI:setPanelInfoButton(name, func)
    self.Panel_info.Button_1.Text_ButtonName:setString(name)
    self.Panel_info.Button_1:releaseFunc(
        function()
            func()
        end
    )
end

return HiddenMeridianBuffUI
00000000000