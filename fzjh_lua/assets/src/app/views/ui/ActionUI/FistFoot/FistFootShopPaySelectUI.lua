local FistFootShopPaySelectUI = class("FistFootShopPaySelectUI", LayerEx)

function FistFootShopPaySelectUI:create()
    local p = FistFootShopPaySelectUI:new()
    p:init()
    return p
end

function FistFootShopPaySelectUI:init()
    self.__ui = require("Layer/ActionUI/FistFoot/FistFootShopPaySelectUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function FistFootShopPaySelectUI:showUI()
    self:show()
end

function FistFootShopPaySelectUI:hideUI()
    self:hide()
end

function FistFootShopPaySelectUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function FistFootShopPaySelectUI:setTextMinLimit(text)
    self.Text_minLimit:setString(text)
end

function FistFootShopPaySelectUI:setTextMaxLimit(text)
    self.Text_maxLimit:setString(text)
end

function FistFootShopPaySelectUI:setTextTitle2(text)
    self.Text_title2:setString(text)
end

function FistFootShopPaySelectUI:setText1(text)
    self.Text_1:setString(text)
end

function FistFootShopPaySelectUI:setText2(text)
    self.Text_2:setString(text)
end

function FistFootShopPaySelectUI:setText3(text)
    self.Text_3:setString(text)
end

function FistFootShopPaySelectUI:setText4(text)
    self.Text_4:setString(text)
end

function FistFootShopPaySelectUI:setTextTip(text)
    self.Text_tip:setString(text)
end

function FistFootShopPaySelectUI:setButton1(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopPaySelectUI:setButton2(func)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopPaySelectUI:setButton3(func)
    self.Button_3:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopPaySelectUI:setButton4(func)
    self.Button_4:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopPaySelectUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopPaySelectUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return FistFootShopPaySelectUI
000000000