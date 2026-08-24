local NianBeastUI = class("NianBeastUI", LayerEx)

function NianBeastUI:create()
    local p = NianBeastUI:new()
    p:init()
    return p
end

function NianBeastUI:init()
    self._UI = require("Layer/ActionUI/NianBeastUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function NianBeastUI:showUI()
    self:setVisible(true)
    self:show()
end

function NianBeastUI:hideUI()
    self:setVisible(false)
    self:hide()
end

function NianBeastUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function NianBeastUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function NianBeastUI:setTextDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function NianBeastUI:setText1Str(str)
    self.Text_1:setString(Helper:getDef(str, ""))
end

function NianBeastUI:setButtonText(index, text)
    if self["Button_"..tostring(index)] then
        self["Button_"..tostring(index)].Text_buttonName:setString(text)
    end
end

function NianBeastUI:setButtonFunc(index, func)
    if self["Button_"..tostring(index)] then
        self["Button_"..tostring(index)]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function NianBeastUI:setTitleFunc(index, func)
    if self["Panel_title_"..tostring(index)] then
        self["Panel_title_"..tostring(index)]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function NianBeastUI:setTitleText(index, text)
    if self["Panel_title_"..tostring(index)] then
        self["Panel_title_"..tostring(index)].Text_1:setString(text)
    end
end

function NianBeastUI:setTitleVisible(index, visible)
    if self["Panel_title_"..tostring(index)] then
        self["Panel_title_"..tostring(index)].Image_bg:setVisible(Helper:getDef(visible,false))
    end
end

function NianBeastUI:setTitleEnable(index, enable)
    if self["Panel_title_"..tostring(index)] then
        self["Panel_title_"..tostring(index)]:setTouchEnabled(Helper:getDef(enable,false))
    end
end

function NianBeastUI:setTitleBackGroundColorOpacity(index, opacity)
    if self["Panel_title_"..tostring(index)] then
        self["Panel_title_"..tostring(index)]:setBackGroundColorOpacity(opacity)
    end
end

function NianBeastUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function NianBeastUI:setPanelDriveAwayVisible(visible)
    self.Panel_driveAway:setVisible(Helper:getDef(visible,false))
end

function NianBeastUI:setPanelDriveAwayFunc(func)
    self.Panel_driveAway:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function NianBeastUI:setPanelDriveAwayButtonText(index, text)
    if self.Panel_driveAway["Button_"..tostring(index)] then
        self.Panel_driveAway["Button_"..tostring(index)].Text_buttonName:setString(text)
    end
end

function NianBeastUI:setPanelDriveAwayButtonFunc(index, func)
    if self.Panel_driveAway["Button_"..tostring(index)] then
        self.Panel_driveAway["Button_"..tostring(index)]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function NianBeastUI:setPanelDriveAwayText3(str)
    self.Panel_driveAway.Text_3:setString(str)
end

function NianBeastUI:setPanelDriveAwayText4(str)
    self.Panel_driveAway.Text_4:setString(str)
end

function NianBeastUI:showListView(listData)
    if MapIsEmpty(listData) == true then
        return
    end

    for i =1,#listData do
        local panel = self.ListView_item:getItem(i - 1)
        if panel == nil then
            local panel = self:__createItem()
            self:__initItem(panel,listData[i])
            self.ListView_item:pushBackCustomItem(panel)
        else
            self:__initItem(panel,listData[i])
        end
    end

    if #listData < #self.ListView_item:getItems() then
        for i = #listData + 1, #self.ListView_item:getItems() do
            self.ListView_item:removeLastItem()
        end
    end

    self.ListView_item:jumpToTop()
end

function NianBeastUI:__createItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function NianBeastUI:__initItem(item,itemInfo)
    item.Text_1:setString(itemInfo.text1)
    item.Text_2:setString(itemInfo.text2)
    item.Text_2:setTextColor(Helper:getDef(itemInfo.textColor, cc.c3b(208, 208, 208)))
    item.Text_2:setTouchEnabled(itemInfo.textEnabled)
    item.Text_3:setVisible(itemInfo.textVisible)
    item.Button_1.Text_buttonName:setString(itemInfo.btnName)
    item.Button_1:setTouchEnabled(itemInfo.enable)
    item.Button_1:loadTextureNormal(itemInfo.loadTexture)
    item.Button_1:releaseFunc(function()
        if itemInfo.func then
            itemInfo.func()
        end
    end)

    item.Text_2:releaseFunc(function()
        if itemInfo.func1 then
            itemInfo.func1()
        end
    end)
end

function NianBeastUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end


return NianBeastUI
0000000