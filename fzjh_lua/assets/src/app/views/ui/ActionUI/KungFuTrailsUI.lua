local KungFuTrailsUI = class("KungFuTrailsUI", LayerEx)

function KungFuTrailsUI:create()
    local p = KungFuTrailsUI:new()
    p:init()
    return p
end

function KungFuTrailsUI:init()
    self._UI = require("Layer/ActionUI/KungFuTrailsUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function KungFuTrailsUI:showUI()
    self:show()
end

function KungFuTrailsUI:hideUI()
    self:hide()
end

function KungFuTrailsUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function KungFuTrailsUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function KungFuTrailsUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function KungFuTrailsUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewItem()
        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Text_2:setString(itemInfo.text2)
        itemUI.Button_1:loadTextureNormal(itemInfo.loadTexture)
        itemUI.Button_1:setTouchEnabled(itemInfo.enable)
        itemUI.Button_1.Text_buttonName:setString(itemInfo.btnName)
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.func then
                itemInfo.func()
            end
        end)

        self:__addItemToListView(itemUI)
    end
end

function KungFuTrailsUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end


function KungFuTrailsUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function KungFuTrailsUI:setTitle_1Func(func)
    self.Panel_title_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function KungFuTrailsUI:setTitle_1Name(name)
    self.Panel_title_1.Text_1:setString(name)
end

function KungFuTrailsUI:setTitle_1Visible(visible)
    self.Panel_title_1.Image_bg:setVisible(Helper:getDef(visible,false))
end

function KungFuTrailsUI:setTitle_1Enable(enable)
    self.Panel_title_1:setTouchEnabled(Helper:getDef(enable,false))
end

function KungFuTrailsUI:setTitle_1BackGroundColorOpacity(opacity)
    self.Panel_title_1:setBackGroundColorOpacity(opacity)
end

function KungFuTrailsUI:setTitle_2Func(func)
    self.Panel_title_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function KungFuTrailsUI:setTitle_2Name(name)
    self.Panel_title_2.Text_1:setString(name)
end

function KungFuTrailsUI:setTitle_2Visible(visible)
    self.Panel_title_2.Image_bg:setVisible(Helper:getDef(visible,false))
end

function KungFuTrailsUI:setTitle_2Enable(enable)
    self.Panel_title_2:setTouchEnabled(Helper:getDef(enable,false))
end

function KungFuTrailsUI:setTitle_2BackGroundColorOpacity(opacity)
    self.Panel_title_2:setBackGroundColorOpacity(opacity)
end

function KungFuTrailsUI:setTitle_1TextColor(color)
    color = Helper:getDef(color,cc.c3b(255, 255, 255))
    self.Panel_title_1.Text_1:setTextColor(color)
end

function KungFuTrailsUI:setTitle_2TextColor(color)
    color = Helper:getDef(color,cc.c3b(255, 255, 255))
    self.Panel_title_2.Text_1:setTextColor(color)
end

function KungFuTrailsUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function KungFuTrailsUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return KungFuTrailsUI
0000000000000000