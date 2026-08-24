local XiangNangMiGeUI = class("XiangNangMiGeUI", LayerEx)

function XiangNangMiGeUI:create()
    local p = XiangNangMiGeUI:new()
    p:init()
    return p
end

function XiangNangMiGeUI:init()
    self._UI = require("Layer/ActionUI/XiangNangMiGeUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function XiangNangMiGeUI:showUI()
    self:show()
end

function XiangNangMiGeUI:hideUI()
    self:hide()
end

function XiangNangMiGeUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function XiangNangMiGeUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function XiangNangMiGeUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function XiangNangMiGeUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewItem()
        itemUI.Text_1:setString(itemInfo.text)
        itemUI.Text_1:setTouchEnabled(itemInfo.textEnable)
        itemUI.Text_1:releaseFunc(function()
            if itemInfo.itemFunc then
                itemInfo.itemFunc()
            end
        end)

        itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
        
        itemUI.Button_1.Text_buttonName:setString(itemInfo.btnName)
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.func then
                itemInfo.func()
            end
        end)

        self:__addItemToListView(itemUI)
    end
end

function XiangNangMiGeUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function XiangNangMiGeUI:setButtonInfoFunc(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XiangNangMiGeUI:setButtonName(name)
    self.Button_1.Text_buttonName:setString(name)
end

function XiangNangMiGeUI:setPanelInfoVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_infoBg:setVisible(visible)
end

function XiangNangMiGeUI:setPanelInfoFunc(func)
    self.Panel_infoBg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XiangNangMiGeUI:setPanelInfoText(text)
    text = Helper:getDef(text,"")
    self.Panel_infoBg.Text_1:setString(text)
end

function XiangNangMiGeUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function XiangNangMiGeUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function XiangNangMiGeUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return XiangNangMiGeUI
000000000