--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-11-07 15:57:03
--]]
local FistFootShopBuyConfirmUI = class("FistFootShopBuyConfirmUI", LayerEx)

function FistFootShopBuyConfirmUI:create()
    local p = FistFootShopBuyConfirmUI:new()
    p:init()
    return p
end

function FistFootShopBuyConfirmUI:init()
    self.__ui = require("Layer/ActionUI/FistFoot/FistFootShopBuyConfirmUI.lua").create()["root"]

    self.__ui:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function FistFootShopBuyConfirmUI:showUI()
    self:show()
end

function FistFootShopBuyConfirmUI:hideUI()
    self:hide()
end

function FistFootShopBuyConfirmUI:setText1(text)
    self.Text_1:setString(text)
end

function FistFootShopBuyConfirmUI:setText2(text)
    self.Text_2:setString(text)
end

function FistFootShopBuyConfirmUI:setText3(text)
    self.Text_3:setString(text)
end

function FistFootShopBuyConfirmUI:setTextTip1(text)
    self.Text_tip1:setString(text)
end

function FistFootShopBuyConfirmUI:setTextTip2(text)
    self.Text_tip2:setString(text)
end

function FistFootShopBuyConfirmUI:setTextTip3(text)
    self.Text_tip3:setString(text)
end

function FistFootShopBuyConfirmUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FistFootShopBuyConfirmUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return FistFootShopBuyConfirmUI
000000