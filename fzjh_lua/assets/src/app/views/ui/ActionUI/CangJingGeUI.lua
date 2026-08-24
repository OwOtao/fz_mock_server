local CangJingGeUI = class("CangJingGeUI", LayerEx)

function CangJingGeUI:create()
    local p = CangJingGeUI:new()
    p:init()
    return p
end

function CangJingGeUI:init()
    self._UI = require("Layer/ActionUI/CangJingGeUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self:setVisible(false)
end

function CangJingGeUI:showUI()
    self:show()
end

function CangJingGeUI:hideUI()
    self:hide()
end

function CangJingGeUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function CangJingGeUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function CangJingGeUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function CangJingGeUI:showListView(listData)
    Helper:print_lua_table(listData)

    if MapIsEmpty(listData) == true then
        self.ListView_item:removeAllItems()
        return
    end

    local itemIndex = 0

    for __, itemInfo in pairs(listData) do
        local itemUI = self.ListView_item:getItem(itemIndex)
        itemIndex = itemIndex + 1
        if not itemUI then
            itemUI = self:__cloneListViewItem()
            self:__addItemToListView(itemUI)
        end
        itemUI.Text_1:setColor(cc.c3b(255,255,255))
        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Text_2:setString(itemInfo.text2)
        itemUI.Text_3:setString(itemInfo.text3)
        itemUI.Text_4:setString(itemInfo.text4)
        itemUI.Text_5:setString(itemInfo.text5)
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

    self.ListView_item:jumpToTop()
end

function CangJingGeUI:showInfoListView(listData)
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

function CangJingGeUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function CangJingGeUI:setText1PosX(x)
    self.Text_1:setPositionX(x)
end

function CangJingGeUI:setText1Color(color)
    self.Text_1:setTextColor(color)
end 

function CangJingGeUI:setText2(text)
    text = Helper:getDef(text,"")
    self.Text_2:setString(text)
end

function CangJingGeUI:setText3(text)
    text = Helper:getDef(text,"")
    self.Text_3:setString(text)
end

function CangJingGeUI:setText4(text)
    text = Helper:getDef(text,"")
    self.Text_4:setString(text)
end

function CangJingGeUI:setText5(text)
    text = Helper:getDef(text,"")
    self.Text_5:setString(text)
end

function CangJingGeUI:setPanelSelectBtnNameAndFunc(index, name, func)
    if self.Panel_select["Image_"..index] then
        self.Panel_select["Image_"..index].Text_name:setString(name)
        self.Panel_select["Image_"..index]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function CangJingGeUI:setPanelSelectBtnTexture(index, texture)
    if self.Panel_select["Image_"..index] then
        self.Panel_select["Image_"..index]:setCapInsets({x = 14, y = 14, width = 4, height = 14})
        self.Panel_select["Image_"..index]:loadTexture(texture)
    end
end

function CangJingGeUI:setPanelInfoFunc(func)
    self.Panel_infoBg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CangJingGeUI:setPanelInfoVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_infoBg:setVisible(visible)
end

function CangJingGeUI:setPanelInfoBtnFunc(func)
    self.Image_reward:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CangJingGeUI:setPanelInfoBtnVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_reward:setVisible(visible)
end

function CangJingGeUI:setLineVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_reward:setVisible(visible)
end

function CangJingGeUI:setButton1Func(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CangJingGeUI:setButton1Texture(texture)
    texture = Helper:getDef(texture,"Image/UI/TaskUI/anniu.png")
    self.Button_1:loadTextureNormal(texture)
end

function CangJingGeUI:setButton1Name(name)
    name = Helper:getDef(name,"")
    self.Button_1.Text_buttonName:setString(name)
end

function CangJingGeUI:setButton1TouchEnable(enable)
    enable = Helper:getDef(enable,false)
    self.Button_1:setTouchEnabled(enable)
end

function CangJingGeUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CangJingGeUI:setPanelInfoFunc(func)
    self.Panel_infoBg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CangJingGeUI:setPanelInfoVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_infoBg:setVisible(visible)
end

function CangJingGeUI:setPanelInfoBtnFunc(func)
    self.Image_reward:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CangJingGeUI:setPanelInfoBtnVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_reward:setVisible(visible)
end

function CangJingGeUI:showInfoListView(listData)
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

function CangJingGeUI:setLineVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_reward:setVisible(visible)
end

function CangJingGeUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function CangJingGeUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

function CangJingGeUI:__cloneInfoListViewTypeItem()
    local itemUI = self.Panel_type:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function CangJingGeUI:__cloneInfoListViewInfoItem()
    local itemUI = self.Panel_info:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function CangJingGeUI:__addItemToInfoListView(itemUI)
    self.Panel_infoBg.ListView_info:pushBackCustomItem(itemUI)
end

return CangJingGeUI
00000000000