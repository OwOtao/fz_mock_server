--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-08-05 15:18:04
--]]
local MaskUpgradeUI = class("MaskUpgradeUI", LayerEx)

function MaskUpgradeUI:create()
    local p = MaskUpgradeUI:new()
    p:init()
    return p
end

function MaskUpgradeUI:init()
    self._UI = require("Layer/DecorativeUI/MaskUpgradeUI.lua").create()["root"]
    self._UI:addTo(self)
    Helper:convertUIByParent(self)
    self:setVisible(false)
end

function MaskUpgradeUI:showUI()
    self:show()
end

function MaskUpgradeUI:hideUI()
    self:hide()
end

function MaskUpgradeUI:setTextTital(text)
    self.Text_Tital:setString(text)
end

function MaskUpgradeUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function MaskUpgradeUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function MaskUpgradeUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function MaskUpgradeUI:setButtonLeftVisible(bool)
    self.Button_left:setVisible(bool)
end

function MaskUpgradeUI:setButtonLeftTouchEnabled(bool)
    self.Button_left:setTouchEnabled(bool)
end

function MaskUpgradeUI:setButtonLeft(func)
    self.Button_left:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function MaskUpgradeUI:setButtonRightVisible(bool)
    self.Button_right:setVisible(bool)
end

function MaskUpgradeUI:setButtonRightTouchEnabled(bool)
    self.Button_right:setTouchEnabled(bool)
end

function MaskUpgradeUI:setButtonRight(func)
    self.Button_right:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function MaskUpgradeUI:getPageUI(pageIndex)
    return self.PageView_1:getPageByIndex(pageIndex)
end

function MaskUpgradeUI:getPageNum()
    return #self.PageView_1:getItems()
end

function MaskUpgradeUI:addPage(layout)
    self.PageView_1:addPage(layout)
end

function MaskUpgradeUI:clearPage()
    self.PageView_1:removeAllPages()
end

function MaskUpgradeUI:scrollToPage(pageIndex)
    self.PageView_1:scrollToPage(pageIndex)
end

function MaskUpgradeUI:getCurrentPageIndex()
    return self.PageView_1:getCurrentPageIndex()
end

function MaskUpgradeUI:createPage()
    local panel = self.Panel_mask:clone()
    Helper:convertUIByParent(panel)
    panel:setVisible(true)
    return panel
end


return MaskUpgradeUI
00000000000000