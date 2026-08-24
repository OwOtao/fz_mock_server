local DrinkMoreUI = class("DrinkMoreUI", LayerEx)

function DrinkMoreUI:create()
    local p = DrinkMoreUI:new()
    p:init()
    return p
end

function DrinkMoreUI:init()
    self._UI = require("Layer/ActionUI/DrinkMoreUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function DrinkMoreUI:showUI()
    self:setVisible(true)
    self:show()
end

function DrinkMoreUI:showLayer(func)
    PopupLayerController:showLayer("DrinkMoreUI",function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:hideUI()
    self:setVisible(false)
    self:hide()
end

function DrinkMoreUI:hideLayer(func)
    PopupLayerController:hideLayer("DrinkMoreUI",function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function DrinkMoreUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function DrinkMoreUI:setTextDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function DrinkMoreUI:setText1Str(str)
    self.Text_1:setString(Helper:getDef(str, ""))
end

function DrinkMoreUI:showListView(listData)
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

function DrinkMoreUI:__createItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function DrinkMoreUI:__initItem(item,itemInfo)
    item.Text_1:setString(itemInfo.text1)
    item.Text_2:setString(itemInfo.text2)
    item.Button_1.Text_buttonName:setString(itemInfo.btnName)
    item.Button_1:setTouchEnabled(itemInfo.enable)
    item.Button_1:loadTextureNormal(itemInfo.loadTexture)
    item.Button_1:releaseFunc(function()
        if itemInfo.func1 then
            itemInfo.func1()
        end
    end)

    item.Text_2:releaseFunc(function()
        if itemInfo.func2 then
            itemInfo.func2()
        end
    end)
end

function DrinkMoreUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

function DrinkMoreUI:setButton_1Func(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setButton_1Name(name)
    self.Button_1.Text_buttonName:setString(name)
end

function DrinkMoreUI:setButton_2Func(func)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setButton_2Name(name)
    self.Button_2.Text_buttonName:setString(name)
end

function DrinkMoreUI:setTitle_1Func(func)
    self.Panel_title_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setTitle_1Name(name)
    self.Panel_title_1.Text_1:setString(name)
end

function DrinkMoreUI:setTitle_1Visible(visible)
    self.Panel_title_1.Image_bg:setVisible(Helper:getDef(visible,false))
end

function DrinkMoreUI:setTitle_1Enable(enable)
    self.Panel_title_1:setTouchEnabled(Helper:getDef(enable,false))
end

function DrinkMoreUI:setTitle_1BackGroundColorOpacity(opacity)
    self.Panel_title_1:setBackGroundColorOpacity(opacity)
end

function DrinkMoreUI:setTitle_2Func(func)
    self.Panel_title_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setTitle_2Name(name)
    self.Panel_title_2.Text_1:setString(name)
end

function DrinkMoreUI:setTitle_2Visible(visible)
    self.Panel_title_2.Image_bg:setVisible(Helper:getDef(visible,false))
end

function DrinkMoreUI:setTitle_2Enable(enable)
    self.Panel_title_2:setTouchEnabled(Helper:getDef(enable,false))
end

function DrinkMoreUI:setTitle_2BackGroundColorOpacity(opacity)
    self.Panel_title_2:setBackGroundColorOpacity(opacity)
end

function DrinkMoreUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setPanelDriveAwayVisible(visible)
    self.Panel_driveAway:setVisible(Helper:getDef(visible,false))
end

function DrinkMoreUI:setPanelDriveAwayFunc(func)
    self.Panel_driveAway:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setPanelDriveAwayButton1Name(name)
    self.Panel_driveAway.Button_1.Text_buttonName:setString(name)
end

function DrinkMoreUI:setPanelDriveAwayButton2Name(name)
    self.Panel_driveAway.Button_2.Text_buttonName:setString(name)
end

function DrinkMoreUI:setPanelDriveAwayButton3Name(name)
    self.Panel_driveAway.Button_3.Text_buttonName:setString(name)
end

function DrinkMoreUI:setPanelDriveAwayButton1Func(func)
    self.Panel_driveAway.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setPanelDriveAwayButton2Func(func)
    self.Panel_driveAway.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setPanelDriveAwayButton3Func(func)
    self.Panel_driveAway.Button_3:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DrinkMoreUI:setPanelDriveAwayText1(str)
    self.Panel_driveAway.Text_1:setString(str)
end

function DrinkMoreUI:setPanelDriveAwayText2(str)
    self.Panel_driveAway.Text_2:setString(str)
end

function DrinkMoreUI:setPanelDriveAwayText3(str)
    self.Panel_driveAway.Text_3:setString(str)
end

function DrinkMoreUI:setPanelDriveAwayText4(str)
    self.Panel_driveAway.Text_4:setString(str)
end

Helper:classDefNodeGetInstance(DrinkMoreUI)
return DrinkMoreUI
0000000