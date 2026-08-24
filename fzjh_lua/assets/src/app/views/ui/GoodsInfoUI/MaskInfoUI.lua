--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-10-28 16:01:02
--]]
local MaskInfoUI = class("MaskInfoUI", LayerEx)

function MaskInfoUI:create()
    local p = MaskInfoUI:new()
    p:init()
    return p
end

function MaskInfoUI:init()
    self._UI = require("Layer/GoodsInfo/MaskInfoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function MaskInfoUI:showUI()
    self:show()
end

function MaskInfoUI:hideUI()
    self:hide()
end

function MaskInfoUI:setTextTital(text)
    self.Text_Tital:setString(text)
end

function MaskInfoUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function MaskInfoUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function MaskInfoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function MaskInfoUI:setButtonLeftVisible(bool)
    self.Button_left:setVisible(bool)
end

function MaskInfoUI:setButtonRightVisible(bool)
    self.Button_right:setVisible(bool)
end

function MaskInfoUI:setButtonLeft(func)
    self.Button_left:releaseFunc(
        function()
            func()
        end
    )
end

function MaskInfoUI:setButtonRight(func)
    self.Button_right:releaseFunc(
        function()
            func()
        end
    )
end

function MaskInfoUI:getPageUI(pageIndex)
    return self.PageView_1:getPageByIndex(pageIndex)
end

function MaskInfoUI:getPageNum()
    return #self.PageView_1:getItems()
end

function MaskInfoUI:addPage(layout)
    self.PageView_1:addPage(layout)
end

function MaskInfoUI:clearPage()
    self.PageView_1:removeAllPages()
end

function MaskInfoUI:scrollToPage(pageIndex)
    self.PageView_1:scrollToPage(pageIndex)
end

function MaskInfoUI:getCurrentPageIndex()
    return self.PageView_1:getCurrentPageIndex()
end

function MaskInfoUI:createMaskInfoPage()
    local panel = self.Panel_mask:clone()
    Helper:convertUIByParent(panel)
    panel:setVisible(true)
    return panel
end

function MaskInfoUI:createMaskUpgradePage()
    local panel = self.Panel_maskUpgrade:clone()
    Helper:convertUIByParent(panel)
    panel:setVisible(true)
    return panel
end

return MaskInfoUI
0000000000