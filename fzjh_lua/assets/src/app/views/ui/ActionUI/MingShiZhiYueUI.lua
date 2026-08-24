local MingShiZhiYueUI = class("MingShiZhiYueUI", LayerEx)

function MingShiZhiYueUI:create()
    local p = MingShiZhiYueUI:new()
    p:init()
    return p
end

function MingShiZhiYueUI:init()
    self._UI = require("Layer/ActionUI/MingShiZhiYueUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function MingShiZhiYueUI:showUI()
    self:show()
end

function MingShiZhiYueUI:hideUI()
    self:hide()
end

function MingShiZhiYueUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function MingShiZhiYueUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function MingShiZhiYueUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function MingShiZhiYueUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewItem()

        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Text_2:setString(itemInfo.text2)
        itemUI.Image_2:setVisible(itemInfo.imgVisible)
        itemUI.Button_1:setTouchEnabled(itemInfo.isEnabled)
        itemUI.Button_1:setVisible(itemInfo.btnVisible)
        itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
        itemUI.Button_1.Text_buttonName:setString(itemInfo.btnName)
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.func then
                itemInfo.func()
            end
        end)

        itemUI.Text_2:releaseFunc(function()
            if itemInfo.func1 then
                itemInfo.func1()
            end
        end)

        self:__addItemToListView(itemUI)
    end
end

function MingShiZhiYueUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function MingShiZhiYueUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end


function MingShiZhiYueUI:setTextStr(index, str)
    if self["Text_"..tostring(index)] then
        str = Helper:getDef(str,"")
        self["Text_"..tostring(index)]:setString(str)
    end
end

function MingShiZhiYueUI:setTextColor(index, color)
    if self["Text_"..tostring(index)] then
        color = Helper:getDef(color,cc.c3b(255, 255, 255))
        self["Text_"..tostring(index)]:setTextColor(color)
    end
end

function MingShiZhiYueUI:setTextFunc(index, func)
    if self["Text_"..tostring(index)] then
        self["Text_"..tostring(index)]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function MingShiZhiYueUI:setTextPositionX(index, posX)
    if self["Text_"..tostring(index)] then
        posX = Helper:getDef(posX, 540)
        self["Text_"..tostring(index)]:setPositionX(posX)
    end
end

function MingShiZhiYueUI:setTextVisible(index, visible)
    if self["Text_"..tostring(index)] then
        visible = Helper:getDef(visible, false)
        self["Text_"..tostring(index)]:setVisible(visible)
    end
end

function MingShiZhiYueUI:setButtonFunc(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function MingShiZhiYueUI:setButtonVisible(visible)
    self.Button_1:setVisible(visible)
end

function MingShiZhiYueUI:setHongDianPosition(pos)
    self.Image_hongdian:setPosition(pos)
end

function MingShiZhiYueUI:setHongDianVisible(visible)
    self.Image_hongdian:setVisible(visible)
end

function MingShiZhiYueUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return MingShiZhiYueUI
00000000000