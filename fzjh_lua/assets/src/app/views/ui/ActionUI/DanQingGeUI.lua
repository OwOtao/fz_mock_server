local DanQingGeUI = class("DanQingGeUI", LayerEx)

function DanQingGeUI:create()
    local p = DanQingGeUI:new()
    p:init()
    return p
end

function DanQingGeUI:init()
    self._UI = require("Layer/ActionUI/DanQingGeUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function DanQingGeUI:showUI()
    self:show()
end

function DanQingGeUI:hideUI()
    self:hide()
end

function DanQingGeUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function DanQingGeUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function DanQingGeUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function DanQingGeUI:showListView(listData)
    if MapIsEmpty(listData) == true then
        return
    end

    for i = 1, #listData do
        local itemUI = self.ListView_item:getItem(i - 1)
        if not itemUI then
            itemUI = self:__cloneListViewItem()
            self:__addItemToListView(itemUI)
        end
        
        self:__initItem(itemUI, listData[i])
    end

    local itemCount = #self.ListView_item:getItems()
    if itemCount - #listData > 0  then
        for i = itemCount-1, #listData,-1 do
            self.ListView_item:removeItem(i)
        end
    end
end

function DanQingGeUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function DanQingGeUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DanQingGeUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function DanQingGeUI:__initItem(itemUI, itemInfo)
    itemUI.Text_1:setColor(cc.c3b(255, 255, 255))
    itemUI.Text_1:setString(itemInfo.text1)
    itemUI.Text_1:releaseFunc(function()
        if itemInfo.func1 then
            itemInfo.func1()
        end
    end)
    
    itemUI.Text_2:setString(itemInfo.text2)
    itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
    itemUI.Button_1:setTouchEnabled(itemInfo.enable)
    
    itemUI.Button_1.Text_buttonName:setString(itemInfo.btnName)
    itemUI.Button_1:releaseFunc(function()
        if itemInfo.func2 then
            itemInfo.func2()
        end
    end)
end

function DanQingGeUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return DanQingGeUI
00000000000000