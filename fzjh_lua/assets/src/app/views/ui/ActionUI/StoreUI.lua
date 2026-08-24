local StoreUI = class("StoreUI", LayerEx)

function StoreUI:create()
    local p = StoreUI:new()
    p:init()
    return p
end

function StoreUI:init()
    self._UI = require("Layer/MapUI/MapBagUI.lua").create()["root"]

    self._UI:addTo(self)

    -- 获取所有子节点，并设置localzorder为1
    local allChildren = self._UI:getChildren()
    for _, child in ipairs(allChildren) do
        child:setLocalZOrder(1)
    end

    Helper:convertUIByParent(self)

    self:initButtons()

    self:setVisible(false)

    self.Panel_CurrencyPop:setVisible(false)
    self.Panel_CurrencyPop:setSwallowTouches(true)
    self.Panel_CurrencyPop:setLocalZOrder(2)
    self.Panel_CurrencyPop:addTouchEventListener(
        function(_, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.Panel_CurrencyPop:setVisible(false)
            end
        end
    )
end

function StoreUI:showUI()
    self:show()
end

function StoreUI:hideUI()
    self:hide()
end

--按钮初始化
function StoreUI:initButtons()
    local button1 = self:createButton() --关闭按钮
    local button2 = self:createButton() --确定按钮
    self._UI:addChild(button1)
    self._UI:addChild(button2)
    button1:move(cc.p(270, 200))
    button2:move(cc.p(810, 200))
    self.Button_1 = button1
    self.Button_2 = button2
end

-- @desc 创建按钮
function StoreUI:createButton()
    local btn = Resource:getUIByName("Button_4")
    Helper:convertUI(btn)
    btn.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
    btn:setLocalZOrder(1)
    return btn
end

function StoreUI:addButton3()
    local button = self:createButton()
    self._UI:addChild(button)
    button:move(cc.p(540, 200))
    self.Button_3 = button
end

function StoreUI:initButtonPos()
    self.Button_1:move(cc.p(180, 100))
    self.Button_3:move(cc.p(540, 100))
    self.Button_2:move(cc.p(900, 100))
end

function StoreUI:setButton1Name(name)
    self.Button_1.Text_buttonName:setString(name)
end

function StoreUI:setButton2Name(name)
    self.Button_2.Text_buttonName:setString(name)
end

function StoreUI:setButton3Name(name)
    self.Button_3.Text_buttonName:setString(name)
end

function StoreUI:setButton3Texture(texture)
    self.Button_3:loadTextureNormal(texture)
end

function StoreUI:setButton1Pos(x, y)
    self.Button_1:move(cc.p(x, y))
end

function StoreUI:setButton2Pos(x, y)
    self.Button_2:move(cc.p(x, y))
end

function StoreUI:setButton3Pos(x, y)
    self.Button_3:move(cc.p(x, y))
end

-- @desc 设置按钮1
function StoreUI:setButton1Func(func)
    self.Button_1:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

-- @desc 设置按钮2
function StoreUI:setButton2Func(func)
    self.Button_2:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

-- @desc 设置按钮3
function StoreUI:setButton3Func(func)
    self.Button_3:releaseFunc(
        function()
            if func then
                func()
            end
        end
    )
end

function StoreUI:setButton1Visible(visible)
    self.Button_1:setVisible(Helper:getDef(visible, false))
end

function StoreUI:setButton2Visible(visible)
    self.Button_2:setVisible(Helper:getDef(visible, false))
end

function StoreUI:setButton3Visible(visible)
    self.Button_3:setVisible(Helper:getDef(visible, false))
end

function StoreUI:setWeightText(text)
    self.Text_weight:setString(Helper:getDef(text, ""))
end

function StoreUI:setDesc(desc)
    self.Text_desc1:setString(Helper:getDef(desc, ""))
end

function StoreUI:setTips(tips)
    self.Text_desc:setString(Helper:getDef(tips, ""))
end

function StoreUI:setTipsPos(x, y)
    self.Text_desc:move(cc.p(x, y))
end

function StoreUI:setTipsVisible(visible)
    self.Text_desc:setVisible(Helper:getDef(visible, false))
end

function StoreUI:setLeftTitle(title)
    self.Image_title.Text_title1:setString(Helper:getDef(title, ""))
end

function StoreUI:setRightTitle(title)
    self.Image_title.Text_title2:setString(Helper:getDef(title, ""))
end

function StoreUI:setStoreTextVisible(visible)
    self.Panel_storeText:setVisible(Helper:getDef(visible, false))
end

function StoreUI:setStoreText(index, text)
    self.Panel_storeText["Text_" .. tostring(index)]:setString(Helper:getDef(text, ""))
end

function StoreUI:setCurrencyText(text)
    self.Text_money:setVisible(true)
    self.Text_money:setString(Helper:getDef(text, ""))
end

function StoreUI:setLeftList(list)
    for i = 1, #list do
        local panel = self.ListView_1:getItem(i - 1)
        if panel == nil then
            local panel = self:__createPanelItem1()
            self:__initPanelItem1(panel, list[i])
            self.ListView_1:pushBackCustomItem(panel)
        else
            self:__initPanelItem1(panel, list[i])
        end
    end

    if #list < #self.ListView_1:getItems() then
        for i = #list + 1, #self.ListView_1:getItems() do
            self.ListView_1:removeLastItem()
        end
    end
end

function StoreUI:setRightList(list)
    for i = 1, #list do
        local panel = self.ListView_2:getItem(i - 1)
        if panel == nil then
            local panel = self:__createPanelItem2()
            self:__initPanelItem2(panel, list[i])
            self.ListView_2:pushBackCustomItem(panel)
        else
            self:__initPanelItem2(panel, list[i])
        end
    end

    if #list < #self.ListView_2:getItems() then
        for i = #list + 1, #self.ListView_2:getItems() do
            self.ListView_2:removeLastItem()
        end
    end
end

function StoreUI:__createPanelItem1()
    local panel = self.Panel_item1:clone()
    Helper:convertUIByParent(panel)

    panel.Image_1:move(cc.p(140, 50))
    panel.Image_tiao:move(cc.p(0, 50))
    panel.Text_name:move(cc.p(20, 50))
    panel.Panel_dian:move(cc.p(-30, 60))

    return panel
end

function StoreUI:__createPanelItem2()
    local panel = self.Panel_item2:clone()
    Helper:convertUIByParent(panel)
    return panel
end

function StoreUI:__initPanelItem1(item, itemInfo)
    if MapIsEmpty(itemInfo) == false then
        item.Text_name:setTextColor({r = 255, g = 255, b = 255})
        item.Text_name:setString(itemInfo.name)
        if itemInfo.showBg then
            item.Image_tiao:setVisible(false)
            item.Image_1:setVisible(true)
        else
            item.Image_tiao:setVisible(true)
            item.Image_1:setVisible(false)
        end

        item.Panel_dian:setVisible(Helper:getDef(itemInfo.isEquip, false))
        item:releaseFunc(
            function()
                if itemInfo.func then
                    itemInfo.func()
                end
            end
        )
    end
end

function StoreUI:__initPanelItem2(item, itemInfo)
    if MapIsEmpty(itemInfo) == false then
        item.Text_name:setTextColor({r = 255, g = 255, b = 255})
        item.Text_name:setString(itemInfo.name)
        item.Text_num:setString(itemInfo.price)
        item.Text_status:setVisible(itemInfo.status)
        item.Image_DaZhe:setVisible(itemInfo.isDazhe)

        item.Image_kuang:loadTexture(Helper:getDef(itemInfo.texture1, "Image/UI/MapUI/4.png"))

        if itemInfo.texture1 then
            item.Image_kuang:setScale9Enabled(true)
            item.Image_kuang:setCapInsets({x = 14, y = 46, width = 17, height = 39})
        end

        if itemInfo.isDazhe then
            item.Image_DaZhe:loadTexture(itemInfo.texture2)
        end

        item:releaseFunc(
            function()
                if itemInfo.func then
                    itemInfo.func()
                end
            end
        )
    end
end

local POP_POSITION = {
    [2] = cc.p(95.36, 1707.75),
    [3] = cc.p(50, 1808.65),
    [4] = cc.p(50, 1719.71)
}

function StoreUI:popTextDetail(index, textName, context, tips)
    if index < 2 or index > 4 then
        assert(false, "StoreUI:popTextDetail 不支持的index" .. tostring(index))
    end

    local popPanel = self.Panel_CurrencyPop
    local contextPanel = popPanel.Img_CurrencyPop
    contextPanel.Text_Name:setString(Helper:getDef(textName, ""))
    contextPanel.Text_Context:setString(Helper:getDef(context, ""))
    contextPanel.Text_Tips:setString(Helper:getDef(tips, ""))
    contextPanel:setPosition(POP_POSITION[index])

    popPanel:setVisible(true)
end

function StoreUI:setStoreTextClickFunc(index, func)
    local textNode = self.Panel_storeText["Text_" .. tostring(index)]
    if textNode then
        if func then
            textNode:setTouchEnabled(true)
            textNode:addClickEventListener(
                function()
                    if func then
                        func()
                    end
                end
            )
        else
            textNode:setTouchEnabled(false)
        end
    end
end

return StoreUI
0000000