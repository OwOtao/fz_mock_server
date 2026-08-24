local FistFootShopUI = class("FistFootShopUI", LayerEx)

function FistFootShopUI:create()
    local p = FistFootShopUI:new()
    p:init()
    return p
end

function FistFootShopUI:init()
    self.__ui = require("Layer/ActionUI/FistFoot/FistFootShopUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function FistFootShopUI:showUI()
    self:show()
end

function FistFootShopUI:hideUI()
    self:hide()
end

function FistFootShopUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function FistFootShopUI:setTextTitle(title)
    self.Text_title:setString(title)
end

function FistFootShopUI:setTextDesc1(text)
    self.Text_desc1:setString(text)
end

function FistFootShopUI:setTextDesc2(text)
    self.Text_desc2:setString(text)
end

function FistFootShopUI:setTextDesc3(text)
    self.Text_desc3:setString(text)
end

function FistFootShopUI:setTextDesc4(text)
    self.Text_desc4:setString(text)
end

function FistFootShopUI:setButton1(name,func)
    if name == nil then
        self.Button_1:setVisible(false)
    else
        self.Button_1:setVisible(true)
        self.Button_1.Text_name:setString(name)
        self.Button_1:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function FistFootShopUI:addItemToList(item)
    self.ListView_item:pushBackCustomItem(item)
end

function FistFootShopUI:removeAllItems()
    self.ListView_item:removeAllItems()
end

function FistFootShopUI:createPanelItem()
    local panel = self.Panel_item:clone()

    Helper:convertUIByParent(panel)

    return panel
end

function FistFootShopUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopUI:setButtonTip(func)
    self.Button_tip:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopUI:setPaneltipIsVisible(bool)
    self.Panel_tip:setVisible(bool)
end

function FistFootShopUI:setPaneltipTextDesc(text)
    self.Panel_tip.Text_desc:setString(text)
end

function FistFootShopUI:setPaneltipFunc(func)
    self.Panel_tip:releaseFunc(function()
        if func then
            func()
        end
    end)
end


return FistFootShopUI
000000000