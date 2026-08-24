local JiangHuMiBaoUI = class("JiangHuMiBaoUI", LayerEx)

function JiangHuMiBaoUI:create()
    local p = JiangHuMiBaoUI:new()
    p:init()
    return p
end

function JiangHuMiBaoUI:init()
    self._UI = require("Layer/ActionUI/JiangHuMiBaoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function JiangHuMiBaoUI:showUI()
    self:show()
end

function JiangHuMiBaoUI:hideUI()
    self:hide()
end

function JiangHuMiBaoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function JiangHuMiBaoUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function JiangHuMiBaoUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function JiangHuMiBaoUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewItem()

        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Text_2:setString(itemInfo.text2)
        itemUI.Text_3:setString(itemInfo.text3)
        
        itemUI.Button_1:setVisible(itemInfo.btnVisible)
        itemUI.Button_1.Text_buttonName:setString(itemInfo.btnName)
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.btnFunc then
                itemInfo.btnFunc()
            end
        end)

        itemUI.Image_2:setVisible(not itemInfo.btnVisible)

        self:__addItemToListView(itemUI)
    end
end

function JiangHuMiBaoUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function JiangHuMiBaoUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function JiangHuMiBaoUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return JiangHuMiBaoUI
0000