local DieJinChongZhiUI = class("DieJinChongZhiUI", LayerEx)

function DieJinChongZhiUI:create()
    local p = DieJinChongZhiUI:new()
    p:init()
    return p
end

function DieJinChongZhiUI:init()
    self._UI = require("Layer/ActionUI/DieJinChongZhiUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function DieJinChongZhiUI:showUI()
    self:show()
end

function DieJinChongZhiUI:hideUI()
    self:hide()
end

function DieJinChongZhiUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function DieJinChongZhiUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function DieJinChongZhiUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function DieJinChongZhiUI:setText1(str)
    str = Helper:getDef(str,"")
    self.Text_1:setString(str)
end

function DieJinChongZhiUI:setText2(str)
    str = Helper:getDef(str,"")
    self.Text_2:setString(str)
end

function DieJinChongZhiUI:setButton1Func(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DieJinChongZhiUI:showItemInfo(info)
    if MapIsEmpty(info) == false then
        self.Panel_item.Text_1:setString(info.text1)
        self.Panel_item.Text_2:setString(info.text2)
        self.Panel_item.Button_1:loadTextureNormal(info.texture)
        self.Panel_item.Button_1.Text_buttonName:setString(info.btnName)
        self.Panel_item.Button_1:releaseFunc(function()
            if info.btnFunc then
                info.btnFunc()
            end
        end)
    end
end

function DieJinChongZhiUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewItem()

        itemUI.Text_1:setString(itemInfo.text1)
        itemUI.Text_2:setString(itemInfo.text2)
        itemUI.Button_1:loadTextureNormal(itemInfo.texture)
        itemUI.Button_1.Text_buttonName:setString(itemInfo.btnName)
        itemUI.Button_1:releaseFunc(function()
            if itemInfo.btnFunc then
                itemInfo.btnFunc()
            end
        end)

        self:__addItemToListView(itemUI)
    end
end

function DieJinChongZhiUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function DieJinChongZhiUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function DieJinChongZhiUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end



return DieJinChongZhiUI
0000000000