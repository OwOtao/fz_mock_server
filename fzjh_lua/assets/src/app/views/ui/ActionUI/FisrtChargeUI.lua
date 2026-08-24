local FisrtChargeUI = class("FisrtChargeUI", LayerEx)

function FisrtChargeUI:create()
    local p = FisrtChargeUI:new()
    p:init()
    return p
end

function FisrtChargeUI:init()
    self._UI = require("Layer/ActionUI/FisrtChargeUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function FisrtChargeUI:showUI()
    self:show()
end

function FisrtChargeUI:hideUI()
    self:hide()
end

function FisrtChargeUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function FisrtChargeUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function FisrtChargeUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function FisrtChargeUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI
        if itemInfo.state ~= 2 and itemInfo.image then
            itemUI = self:__createItem_1()
            self:__initItem_1(itemUI,itemInfo)
        else
            itemUI = self:__createItem()
            self:__initItem(itemUI,itemInfo)
        end

        self:__addItemToListView(itemUI)
    end
end

function FisrtChargeUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FisrtChargeUI:__createItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function FisrtChargeUI:__initItem(item,itemInfo)
    item.Text_1_3:setString(itemInfo.text1)
    item.Text_2:setString(itemInfo.text2)
    item.Image_hongdian:setVisible(itemInfo.state == 1)
    item.Button_1:setVisible(itemInfo.state ~= 2)
    item.Image_2:setVisible(itemInfo.state == 2)
    item.Text_1_1:setTextColor(itemInfo.text1_color)
    item.Text_1_2:setTextColor(itemInfo.text1_color)
    item.Text_1_3:setTextColor(itemInfo.text1_color)
    item.Text_1_4:setTextColor(itemInfo.text1_color)
    item.Text_2:setTextColor(itemInfo.text2_color)

    item.Button_1:loadTextureNormal(itemInfo.btnImg)

    item.Button_1:releaseFunc(function()
        if itemInfo.getReward then
            itemInfo.getReward()
        end
    end)
end

function FisrtChargeUI:__createItem_1()
    local itemUI = self.Panel_item_1:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function FisrtChargeUI:__initItem_1(item,itemInfo)
    item.Text_1_3:setString(itemInfo.text1)
    item.Text_2:setString(itemInfo.text2)
    item.Image_hongdian:setVisible(itemInfo.state == 1)
    item.Text_1_1:setTextColor(itemInfo.text1_color)
    item.Text_1_2:setTextColor(itemInfo.text1_color)
    item.Text_1_3:setTextColor(itemInfo.text1_color)
    item.Text_1_4:setTextColor(itemInfo.text1_color)
    item.Text_2:setTextColor(itemInfo.text2_color)

    if itemInfo.image then
        item.Image_item:setVisible(true)
        item.Image_item:loadTexture(itemInfo.image)
        item.Image_di:setVisible(true)
    else
        item.Image_item:setVisible(false)
        item.Image_di:setVisible(false)
    end

    item.Button_1:loadTextureNormal(itemInfo.btnImg)
    
    item.Button_1:releaseFunc(function()
        if itemInfo.getReward then
            itemInfo.getReward()
        end
    end)
end

function FisrtChargeUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

function FisrtChargeUI:setButton_1Func(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function FisrtChargeUI:setButton_1Name(name)
    self.Button_1.Text_buttonName:setString(name)
end

function FisrtChargeUI:setButton_1Texture(texture)
    self.Button_1:loadTextureNormal(texture)
end

return FisrtChargeUI
00000000