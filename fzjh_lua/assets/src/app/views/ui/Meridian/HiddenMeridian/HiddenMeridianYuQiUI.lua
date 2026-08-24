local HiddenMeridianYuQiUI = class("HiddenMeridianYuQiUI", LayerEx)

function HiddenMeridianYuQiUI:create()
    local p = HiddenMeridianYuQiUI:new()
    p:init()
    return p
end

function HiddenMeridianYuQiUI:init()
    self.__ui = require("Layer/MeridianUI/HiddenMeridian/HiddenMeridianYuQiUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function HiddenMeridianYuQiUI:showUI()
    self:show()
end

function HiddenMeridianYuQiUI:hideUI()
    self:hide()
end

function HiddenMeridianYuQiUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function HiddenMeridianYuQiUI:setTextYuQi(text)
    self.Text_yuqiNum:setString(text)
end

function HiddenMeridianYuQiUI:removeListViewAllItems()
    self.ListView_attr:removeAllItems()
end

function HiddenMeridianYuQiUI:insertPanelToListView(panel)
    self.ListView_attr:pushBackCustomItem(panel)
end

function HiddenMeridianYuQiUI:createPanelAttr()
    local panel = self.Panel_attr:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianYuQiUI:createPanelEffectText()
    local panel = self.Panel_effect:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function HiddenMeridianYuQiUI:removeEffectListViewAllItems()
    self.ListView_effect:removeAllItems()
end

function HiddenMeridianYuQiUI:insertPanelToEffectListView(panel)
    self.ListView_effect:pushBackCustomItem(panel)
end

function HiddenMeridianYuQiUI:setButton1(name,func)
    self.Button_1.Text_ButtonName:setString(name)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function HiddenMeridianYuQiUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return HiddenMeridianYuQiUI
000000