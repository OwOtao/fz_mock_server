local ChangeHouseSkinUI = class("ChangeHouseSkinUI", LayerEx)

local SWITCH_ANIM_TIME = 0.5

local SHOW_PANEL_POS = cc.p(540, 330)

local RIGHT_HIDE_PANEL_POS = cc.p(1680, 330)

local LEFT_HIDE_PANEL_POS = cc.p(-600, 330)

function ChangeHouseSkinUI:create()
    local p = ChangeHouseSkinUI:new()
    p:init()
    return p
end

function ChangeHouseSkinUI:init()
    self.__UI = require("Layer/ChangeHouseSkinUI/ChangeHouseSkinUI.lua").create()["root"]

    self.__UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function ChangeHouseSkinUI:showUI()
    self:show()
    self:setVisible(true)
end

function ChangeHouseSkinUI:hideUI()
    self:hide()
    self:setVisible(false)
end

function ChangeHouseSkinUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function ChangeHouseSkinUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function ChangeHouseSkinUI:setText1Str(str)
    self.Text_1:setString(Helper:getDef(str, ""))
end

function ChangeHouseSkinUI:setText2Str(str)
    self.Text_2:setString(Helper:getDef(str, ""))
end

function ChangeHouseSkinUI:setText2Visible(visible)
    self.Text_2:setVisible(Helper:getDef(visible, false))
end

function ChangeHouseSkinUI:showListView(listData)
    if MapIsEmpty(listData) == true then
        self.ListView_item:removeAllItems()
        return
    end

    for i = 1, #listData do
        local panel = self.ListView_item:getItem(i - 1)
        if panel == nil then
            local panel = self:__createItem()
            self:__initItem(panel, listData[i])
            self.ListView_item:pushBackCustomItem(panel)
        else
            self:__initItem(panel, listData[i])
        end
    end

    if #listData < #self.ListView_item:getItems() then
        for i = #listData + 1, #self.ListView_item:getItems() do
            self.ListView_item:removeLastItem()
        end
    end
end

function ChangeHouseSkinUI:setTitle_1Func(func)
    self.Panel_title_1:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function ChangeHouseSkinUI:setTitle_1Name(name)
    self.Panel_title_1.Text_1:setString(name)
end

function ChangeHouseSkinUI:setTitle_1Visible(visible)
    self.Panel_title_1.Image_bg:setVisible(Helper:getDef(visible, false))
end

function ChangeHouseSkinUI:setTitle_1Enable(enable)
    self.Panel_title_1:setTouchEnabled(Helper:getDef(enable, false))
end

function ChangeHouseSkinUI:setTitle_1BackGroundColorOpacity(opacity)
    self.Panel_title_1:setBackGroundColorOpacity(opacity)
end

function ChangeHouseSkinUI:setTitle_2Func(func)
    self.Panel_title_2:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function ChangeHouseSkinUI:setTitle_2Name(name)
    self.Panel_title_2.Text_1:setString(name)
end

function ChangeHouseSkinUI:setTitle_2Visible(visible)
    self.Panel_title_2.Image_bg:setVisible(Helper:getDef(visible, false))
end

function ChangeHouseSkinUI:setTitle_2Enable(enable)
    self.Panel_title_2:setTouchEnabled(Helper:getDef(enable, false))
end

function ChangeHouseSkinUI:setTitle_2BackGroundColorOpacity(opacity)
    self.Panel_title_2:setBackGroundColorOpacity(opacity)
end

function ChangeHouseSkinUI:__createItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)

    return itemUI
end

function ChangeHouseSkinUI:__initItem(item, itemInfo)
    item.Text_1:setString(itemInfo.text1)
    item.Text_2:setVisible(not itemInfo.isBuy)
    item.Text_2:setString(itemInfo.text2)
    item.Text_3:setVisible(itemInfo.isLimit)
    item.Image_2:setVisible(itemInfo.isLimit)
    item.Text_4:setVisible(itemInfo.isUsed)
    item.Image_1:loadTexture(itemInfo.bgTexture)
    item.Button_1:setVisible(not itemInfo.isUsed)
    item.Button_1:setTouchEnabled(not itemInfo.isUsed)
    item.Button_1.Text_buttonName:setString(itemInfo.btnName)
    item.Button_1:loadTextureNormal(itemInfo.btnTexture)
    item.Button_1:releaseFunc(
        function()
            if itemInfo.func then
                itemInfo.func()
            end
        end
    )
end

function ChangeHouseSkinUI:getItemByIndex(index)
    local item = self.ListView_item:getItem(index - 1)
    if item == nil then
        item = self:__createItem()
        self.ListView_item:pushBackCustomItem(item)
    end

    return item
end

function ChangeHouseSkinUI:getItemsCount()
    return #self.ListView_item:getItems()
end

function ChangeHouseSkinUI:removeLastItem()
    self.ListView_item:removeLastItem()
end

function ChangeHouseSkinUI:removeAllItems()
    self.ListView_item:removeAllItems()
end

return ChangeHouseSkinUI
00000