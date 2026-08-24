--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-09-02 17:54:55
--]]
local GoodsInfoMainUI = class("GoodsInfoMainUI", LayerEx)

function GoodsInfoMainUI:create()
    local p = GoodsInfoMainUI:new()
    p:init()
    return p
end

function GoodsInfoMainUI:init()
    self._UI = require("Layer/GoodsInfo/GoodsInfoMainUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function GoodsInfoMainUI:showUI()
    self:show()
end

function GoodsInfoMainUI:hideUI()
    self:hide()
end

function GoodsInfoMainUI:setButtonBackVisible(bool)
    self.Button_back:setVisible(bool)
end

function GoodsInfoMainUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function GoodsInfoMainUI:setButtonLeft(func)
    self.Panel_left:releaseFunc(
        function()
            func()
        end
    )
end

function GoodsInfoMainUI:setButtonRight(func)
    self.Panel_right:releaseFunc(
        function()
            func()
        end
    )
end

function GoodsInfoMainUI:addPage(layout)
    self.PageView_1:addPage(layout)
end

function GoodsInfoMainUI:clearPage()
    self.PageView_1:removeAllPages()
end

function GoodsInfoMainUI:scrollToPage(pageIndex)
    self.PageView_1:scrollToPage(pageIndex)
end

function GoodsInfoMainUI:getCurrentPageIndex()
    return self.PageView_1:getCurrentPageIndex()
end

function GoodsInfoMainUI:showSelectUI()
    self.Panel_left:setVisible(true)
    self.Panel_right:setVisible(true)
    self.Text_changItem:setVisible(true)
end

function GoodsInfoMainUI:hideSelectUI()
    self.Panel_left:setVisible(false)
    self.Panel_right:setVisible(false)
    self.Text_changItem:setVisible(false)
end

return GoodsInfoMainUI
000000000