local CuiLianCaiLiaoStoreUI = class("CuiLianCaiLiaoStoreUI", LayerEx)

function CuiLianCaiLiaoStoreUI:create()
    local p = CuiLianCaiLiaoStoreUI:new()
    p:init()
    return p
end

function CuiLianCaiLiaoStoreUI:init()
    self._UI = require("Layer/ActionUI/CuiLianCaiLiaoStoreUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item_1:setScrollBarEnabled(false)

    self.ListView_item_2:setScrollBarEnabled(false)

    self:setVisible(false)
end

function CuiLianCaiLiaoStoreUI:showUI()
    self:show()
end

function CuiLianCaiLiaoStoreUI:hideUI()
    self:hide()
end

function CuiLianCaiLiaoStoreUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function CuiLianCaiLiaoStoreUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function CuiLianCaiLiaoStoreUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function CuiLianCaiLiaoStoreUI:setListViewVisible(index, visible)
    if self["ListView_item_"..index] then
        visible = Helper:getDef(visible,false)
        self["ListView_item_"..index]:setVisible(visible)
    end
end

function CuiLianCaiLiaoStoreUI:setImage2Visible(visible)
    visible = Helper:getDef(visible,false)
    self.Image_2:setVisible(visible)
end

function CuiLianCaiLiaoStoreUI:setPanelSelectVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_select:setVisible(visible)
end

function CuiLianCaiLiaoStoreUI:setPanelSelectBtnNameAndFunc(index, name, func)
    if self.Panel_select["Image_"..index] then
        self.Panel_select["Image_"..index].Text_name:setString(name)
        self.Panel_select["Image_"..index]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function CuiLianCaiLiaoStoreUI:setPanelSelectBtnTexture(index, texture)
    if self.Panel_select["Image_"..index] then
        self.Panel_select["Image_"..index]:loadTexture(texture)
        self.Panel_select["Image_"..index]:setCapInsets({x = 14, y = 14, width = 4, height = 14})
    end
end

function CuiLianCaiLiaoStoreUI:showListView_1(listData)
    if MapIsEmpty(listData) == true then
        return
    end

    for i =1,#listData do
        local panel = self.ListView_item_1:getItem(i - 1)
        if panel == nil then
            panel = self:__cloneItemPanel_1()
            self.ListView_item_1:pushBackCustomItem(panel)
        end

        local info = listData[i]
        panel.Text_1:setString(info.text1)
        panel.Text_2:setString(info.text2)
        panel.Text_3:setString(info.text3)
        panel.Text_4:setString(info.text4)
        panel.Button_1.Text_buttonName:setString(info.btnName)
        panel.Button_1:loadTextureNormal(info.loadTexture)
        panel.Button_1:setTouchEnabled(info.enable)
        panel.Button_1:releaseFunc(function()
            if info.func then
                info.func()
            end
        end)

    end

    if #listData < #self.ListView_item_1:getItems() then
        for i = #listData + 1, #self.ListView_item_1:getItems() do
            self.ListView_item_1:removeLastItem()
        end
    end
end

function CuiLianCaiLiaoStoreUI:showListView_2(listData)
    if MapIsEmpty(listData) == true then
        return
    end

    for i =1,#listData do
        local panel = self.ListView_item_2:getItem(i - 1)
        if panel == nil then
            panel = self:__cloneItemPanel_2()
            self.ListView_item_2:pushBackCustomItem(panel)
        end

        local info = listData[i]

        panel.Text_1:setString(info.text1)
        panel.Text_2:setString(info.text2)
        panel.Text_3:setString(info.text3)

        panel.Button_1.Text_buttonName:setString(info.btnName)
        panel.Button_1:loadTextureNormal(info.loadTexture)
        panel.Button_1:setTouchEnabled(info.enable)
        panel.Button_1:releaseFunc(function()
            if info.func then
                info.func()
            end
        end)
    end

    if #listData < #self.ListView_item_2:getItems() then
        for i = #listData + 1, #self.ListView_item_2:getItems() do
            self.ListView_item_2:removeLastItem()
        end
    end 
end

function CuiLianCaiLiaoStoreUI:setTitie1Func(func)
    self.Panel_title_1.Text_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CuiLianCaiLiaoStoreUI:setTitie2Func(func)
    self.Panel_title_2.Text_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CuiLianCaiLiaoStoreUI:setTitie1Visible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_title_1.Image_bg:setVisible(visible)
    self.Panel_title_1.Panel_bg:setVisible(visible)
end 

function CuiLianCaiLiaoStoreUI:setTitie2Visible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_title_2.Image_bg:setVisible(visible)
    self.Panel_title_2.Panel_bg:setVisible(visible)
end

function CuiLianCaiLiaoStoreUI:setPanelSelectPositionY(posY)
    self.Panel_select:setPositionY(posY)
end

function CuiLianCaiLiaoStoreUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function CuiLianCaiLiaoStoreUI:setText2(text)
    text = Helper:getDef(text,"")
    self.Text_2:setString(text)
end

function CuiLianCaiLiaoStoreUI:setText3(text)
    text = Helper:getDef(text,"")
    self.Image_2.Text_1:setString(text)
end

function CuiLianCaiLiaoStoreUI:setBuyPanelVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_buy:setVisible(visible)
end

function CuiLianCaiLiaoStoreUI:setBuyPanelText1Visible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_buy.Text_1:setVisible(visible)
end

function CuiLianCaiLiaoStoreUI:setBuyPanelText1(text)
    text = Helper:getDef(text,"")
    self.Panel_buy.Text_1:setString(text)
end

function CuiLianCaiLiaoStoreUI:setBuyPanelText2(text)
    text = Helper:getDef(text,"")
    self.Panel_buy.Text_2:setString(text)
end

function CuiLianCaiLiaoStoreUI:setBuyPanelText3(text)
    text = Helper:getDef(text,"")
    self.Panel_buy.Text_3:setString(text)
end

function CuiLianCaiLiaoStoreUI:setBuyPanelText4(text)
    text = Helper:getDef(text,"")
    self.Panel_buy.Text_4:setString(text)
end

function CuiLianCaiLiaoStoreUI:setBuyPanelBtnNameAndFunc(index, name, func)
    if self.Panel_buy["Button_"..index] then
        self.Panel_buy["Button_"..index].Text_buttonName:setString(name)
        self.Panel_buy["Button_"..index]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function CuiLianCaiLiaoStoreUI:setBuyPanelBtnVisible(index, visible)
    if self.Panel_buy["Button_"..index] then
        visible = Helper:getDef(visible,false)
        self.Panel_buy["Button_"..index]:setVisible(visible)
    end
end

function CuiLianCaiLiaoStoreUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CuiLianCaiLiaoStoreUI:__cloneItemPanel_1()
    local itemUI = self.Panel_item_1:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function CuiLianCaiLiaoStoreUI:__cloneItemPanel_2()
    local itemUI = self.Panel_item_2:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

return CuiLianCaiLiaoStoreUI
000000000