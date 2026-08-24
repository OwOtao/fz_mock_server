local NewRandomGiftUI = class("NewRandomGiftUI", LayerEx)

function NewRandomGiftUI:create()
    local p = NewRandomGiftUI:new()
    p:init()
    return p
end

function NewRandomGiftUI:init()
    self._UI = require("Layer/ActionUI/NewRandomGiftUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function NewRandomGiftUI:showUI()
    self:show()
end

function NewRandomGiftUI:hideUI()
    self:hide()
end

function NewRandomGiftUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function NewRandomGiftUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function NewRandomGiftUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function NewRandomGiftUI:showListView(listData)
    if MapIsEmpty(listData) == true then
        return
    end

    local itemIndex = 0

    for __, itemInfo in pairs(listData) do
        local itemUI = self.ListView_item:getItem(itemIndex)
        itemIndex = itemIndex + 1
        if not itemUI then
            itemUI = self:__cloneListViewItem()
            self:addItemToListView(itemUI)
        end
        itemUI.Text_1:setColor(cc.c3b(255,255,255))
        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Text_2:setString(itemInfo.text2)
        
        if itemInfo.state ~= 0 then
            itemUI.Button_1.Text_1:setVisible(false)
            itemUI.Button_1.Text_2:setString(itemInfo.btnName)
            itemUI.Button_1.Text_2:setVisible(true)
        else
            itemUI.Button_1.Text_1:setString(itemInfo.btnName)
            itemUI.Button_1.Text_1:setVisible(true)
            itemUI.Button_1.Text_2:setVisible(false)
        end

        local loadTexture = itemInfo.state ~= 2 and "Image/UI/TaskUI/anniu.png" or "Image/UI/TaskUI/anniuhui.png"
        itemUI.Button_1:loadTextureNormal(loadTexture)

        itemUI.Image_icon:loadTexture(itemInfo.icon)
        
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.func then
                itemInfo.func()
            end
        end)
    end

    local itemNum = #self.ListView_item:getItems()
    if itemIndex < itemNum then
        for i = itemIndex + 1, itemNum do
            self.ListView_item:removeLastItem()
        end
    end
end

function NewRandomGiftUI:showNewListView(listData)
    if MapIsEmpty(listData) == true then
        return
    end

    local itemIndex = 0

    for __, itemInfo in pairs(listData) do
        local itemUI = self.ListView_item:getItem(itemIndex)
        itemIndex = itemIndex + 1
        if not itemUI then
            itemUI = self:__cloneListViewItem()
            self:addItemToListView(itemUI)
        end
        itemUI.Text_1:setColor(cc.c3b(255,255,255))
        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Text_2:setString(itemInfo.text2)
        itemUI.Button_1.Text_1:setVisible(Helper:getDef(itemInfo.btnName1Visible, false))
        itemUI.Button_1.Text_1:setString(Helper:getDef(itemInfo.btnName1, ""))
        itemUI.Button_1.Text_2:setVisible(Helper:getDef(itemInfo.btnName2Visible, false))
        itemUI.Button_1.Text_2:setString(Helper:getDef(itemInfo.btnName2, ""))
        itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
        itemUI.Image_icon:loadTexture(itemInfo.icon)
        itemUI.Image_line:setVisible(Helper:getDef(itemInfo.lineVisible, true))
        
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.func then
                itemInfo.func()
            end
        end)
    end

    local itemNum = #self.ListView_item:getItems()
    if itemIndex < itemNum then
        for i = itemIndex + 1, itemNum do
            self.ListView_item:removeLastItem()
        end
    end
end

function NewRandomGiftUI:showInfoListView(listData)
    self.Panel_infoBg.ListView_info:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in ipairs(listData) do

        local itemUI = self:__cloneInfoListViewTypeItem()
        
        itemUI.Text_1:setString(itemInfo.text)
        
        self:__addItemToInfoListView(itemUI)

        for index, info in ipairs(itemInfo.info) do
            local infoItemUI = self:__cloneInfoListViewInfoItem()
        
            infoItemUI.Text_1:setString(info)
            
            self:__addItemToInfoListView(infoItemUI)
        end
    end
end

function NewRandomGiftUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function NewRandomGiftUI:setText1PosX(x)
    self.Text_1:setPositionX(x)
end

function NewRandomGiftUI:setText2(text)
    text = Helper:getDef(text,"")
    self.Text_2:setString(text)
end

function NewRandomGiftUI:setText2Visible(visible)
    visible = Helper:getDef(visible,false)
    self.Text_2:setVisible(visible)
end

function NewRandomGiftUI:setText3(text)
    text = Helper:getDef(text,"")
    self.Text_3:setString(text)
end

function NewRandomGiftUI:setPanelCurrencyVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_currency:setVisible(visible)
end

function NewRandomGiftUI:setPanelCurrencyText(index, text)
    text = Helper:getDef(text,"")
    self.Panel_currency["Text_"..tostring(index)]:setString(text)
end

function NewRandomGiftUI:setPanelInfoFunc(func)
    self.Panel_infoBg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function NewRandomGiftUI:setPanelInfoVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_infoBg:setVisible(visible)
end

function NewRandomGiftUI:setPanelInfoBtnFunc(func)
    self.Image_reward:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function NewRandomGiftUI:setPanelInfoBtnVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_reward:setVisible(visible)
end

function NewRandomGiftUI:setLineVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_reward:setVisible(visible)
end

function NewRandomGiftUI:setButton1Func(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function NewRandomGiftUI:setButton1Texture(texture)
    texture = Helper:getDef(texture,"Image/UI/TaskUI/anniu.png")
    self.Button_1:loadTextureNormal(texture)
end

function NewRandomGiftUI:setButton1Name(name)
    name = Helper:getDef(name,"")
    self.Button_1.Text_buttonName:setString(name)
end

function NewRandomGiftUI:setButton1TouchEnable(enable)
    enable = Helper:getDef(enable,false)
    self.Button_1:setTouchEnabled(enable)
end

function NewRandomGiftUI:setButton1Visible(visible)
    self.Button_1:setVisible(visible)
end

function NewRandomGiftUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function NewRandomGiftUI:setButtonRuleVisible(visible)
    self.Image_rule:setVisible(visible)
end

function NewRandomGiftUI:setListViewSize(size)
    self.ListView_item:setSize(size)
end

function NewRandomGiftUI:clearListView()
    self.ListView_item:removeAllItems()
end

function NewRandomGiftUI:addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

function NewRandomGiftUI:cloneListViewPanelItem1()
    local itemUI = self.Panel_item_1:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function NewRandomGiftUI:initPanelItem1(itemUI, itemInfo)
    itemUI.Text_1:setColor(cc.c3b(255,255,255))
    itemUI.Text_1:setString(itemInfo.text1)
    itemUI.Text_2:setString(itemInfo.text2)
    itemUI.Text_3:setString(itemInfo.text3)
    itemUI.Text_4:setString(itemInfo.text4)
    itemUI.Button_1.Text_1:setString(Helper:getDef(itemInfo.btnName, ""))
    itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
    itemUI.Image_icon:loadTexture(itemInfo.icon)
    
    itemUI.Button_1:releaseFunc(function()
        if itemInfo.func then
            itemInfo.func()
        end
    end)
end

function NewRandomGiftUI:cloneListViewPanelItem2()
    local itemUI = self.Panel_item_2:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function NewRandomGiftUI:initPanelItem2(itemUI, itemInfo)
    itemUI.Text_1:setColor(cc.c3b(255,255,255))
    itemUI.Text_1:setString(itemInfo.text1)
    itemUI.Text_2:setString(itemInfo.text2)
    itemUI.Button_1.Text_1:setString(Helper:getDef(itemInfo.btnName, ""))
    itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
    itemUI.Button_1:setTouchEnabled(itemInfo.enable)
    itemUI.Button_1:releaseFunc(function()
        if itemInfo.func then
            itemInfo.func()
        end
    end)
end

function NewRandomGiftUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function NewRandomGiftUI:__cloneInfoListViewTypeItem()
    local itemUI = self.Panel_type:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function NewRandomGiftUI:__cloneInfoListViewInfoItem()
    local itemUI = self.Panel_info:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function NewRandomGiftUI:__addItemToInfoListView(itemUI)
    self.Panel_infoBg.ListView_info:pushBackCustomItem(itemUI)
end

return NewRandomGiftUI
0000000000