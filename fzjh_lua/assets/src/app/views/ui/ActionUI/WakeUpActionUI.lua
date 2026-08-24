local WakeUpActionUI = class("WakeUpActionUI", LayerEx)

function WakeUpActionUI:create()
    local p = WakeUpActionUI:new()
    p:init()
    return p
end

function WakeUpActionUI:init()
    self._UI = require("Layer/ActionUI/WakeUpActionUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function WakeUpActionUI:showUI()
    self:show()
end

function WakeUpActionUI:hideUI()
    self:hide()
end

function WakeUpActionUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function WakeUpActionUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function WakeUpActionUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function WakeUpActionUI:showListView(listData)
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

function WakeUpActionUI:setText_1Str(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function WakeUpActionUI:setText_2Str(text)
    text = Helper:getDef(text,"")
    self.Text_2:setString(text)
end


function WakeUpActionUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function WakeUpActionUI:setButton_1Func(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function WakeUpActionUI:setButton_1Enable(enable)
    self.Button_1:setTouchEnabled(Helper:getDef(enable,false))
end

function WakeUpActionUI:setButton_1Texture(texture)
    self.Button_1:loadTextureNormal(Helper:getDef(texture,"Image/UI/TaskUI/anniu.png"))
end

function WakeUpActionUI:setButton_1Name(name)
    name = Helper:getDef(name,"")
    self.Button_1.Text_buttonName:setString(name)
end 

function WakeUpActionUI:setTitle_1Func(func)
    self.Panel_title_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function WakeUpActionUI:setTitle_1Name(name)
    self.Panel_title_1.Text_1:setString(name)
end

function WakeUpActionUI:setTitle_1Visible(visible)
    self.Panel_title_1.Image_bg:setVisible(Helper:getDef(visible,false))
end

function WakeUpActionUI:setTitle_1Enable(enable)
    self.Panel_title_1:setTouchEnabled(Helper:getDef(enable,false))
end

function WakeUpActionUI:setTitle_1BackGroundColorOpacity(opacity)
    self.Panel_title_1:setBackGroundColorOpacity(opacity)
end

function WakeUpActionUI:setTitle_2Func(func)
    self.Panel_title_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function WakeUpActionUI:setTitle_2Name(name)
    self.Panel_title_2.Text_1:setString(name)
end

function WakeUpActionUI:setTitle_2Visible(visible)
    self.Panel_title_2.Image_bg:setVisible(Helper:getDef(visible,false))
end

function WakeUpActionUI:setTitle_2Enable(enable)
    self.Panel_title_2:setTouchEnabled(Helper:getDef(enable,false))
end

function WakeUpActionUI:setTitle_2BackGroundColorOpacity(opacity)
    self.Panel_title_2:setBackGroundColorOpacity(opacity)
end

function WakeUpActionUI:setTitle_1TextColor(color)
    color = Helper:getDef(color,cc.c3b(255, 255, 255))
    self.Panel_title_1.Text_1:setTextColor(color)
end

function WakeUpActionUI:setTitle_2TextColor(color)
    color = Helper:getDef(color,cc.c3b(255, 255, 255))
    self.Panel_title_2.Text_1:setTextColor(color)
end

function WakeUpActionUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function WakeUpActionUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return WakeUpActionUI
00000000