local RewardSelectUI = class("RewardSelectUI", LayerEx)

function RewardSelectUI:create()
    local p = RewardSelectUI:new()
    p:init()
    return p
end

function RewardSelectUI:init()
    self._UI = require("Layer/ActionUI/RewardSelectUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function RewardSelectUI:showUI()
    self:show()
end

function RewardSelectUI:hideUI()
    self:hide()
end

function RewardSelectUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function RewardSelectUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewItem()
        itemUI.Text_1:setString(itemInfo.text)
        itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
        itemUI.Button_1.Text_buttonName:setString(itemInfo.btnName)
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.func then
                itemInfo.func()
            end
        end)

        itemUI.Text_1:setTouchEnabled(true)
        itemUI.Text_1:releaseFunc(function()
            if itemInfo.func1 then
                itemInfo.func1()
            end
        end)

        self:__addItemToListView(itemUI)
    end
end

function RewardSelectUI:showIconListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewIconItem()
        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Image_icon:loadTexture(itemInfo.icon)
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.func then
                itemInfo.func()
            end
        end)

        itemUI.Text_1:setTouchEnabled(true)
        itemUI.Text_1:releaseFunc(function()
            if itemInfo.func1 then
                itemInfo.func1()
            end
        end)

        self:__addItemToListView(itemUI)
    end
end

function RewardSelectUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function RewardSelectUI:setText2(text)
    text = Helper:getDef(text,"")
    self.Text_2:setString(text)
end

function RewardSelectUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function RewardSelectUI:__cloneListViewIconItem()
    local itemUI = self.Panel_iconItem:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function RewardSelectUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return RewardSelectUI
000000000000