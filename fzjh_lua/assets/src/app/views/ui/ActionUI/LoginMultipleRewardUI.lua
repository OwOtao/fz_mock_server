local LoginMultipleRewardUI = class("LoginMultipleRewardUI", LayerEx)

function LoginMultipleRewardUI:create()
    local p = LoginMultipleRewardUI:new()
    p:init()
    return p
end

function LoginMultipleRewardUI:init()
    self._UI = require("Layer/ActionUI/LoginMultipleRewardUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item_1:setScrollBarEnabled(false)

    self.ListView_item_2:setScrollBarEnabled(false)

    self.ListView_item_1:removeAllItems()

    self.ListView_item_2:removeAllItems()

    self:setVisible(false)
end

function LoginMultipleRewardUI:showUI()
    self:show()
end

function LoginMultipleRewardUI:hideUI()
    self:hide()
end

function LoginMultipleRewardUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function LoginMultipleRewardUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function LoginMultipleRewardUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function LoginMultipleRewardUI:setCountText(index, text)
    if self["Text_count_"..tostring(index)] then
        self["Text_count_"..tostring(index)]:setString(Helper:getDef(text, ""))
    end
end

function LoginMultipleRewardUI:setText(index, text)
    if self["Text_"..tostring(index)] then
        self["Text_"..tostring(index)]:setString(Helper:getDef(text, ""))
    end
end

function LoginMultipleRewardUI:setTipText(index, text)
    if self["Text_tip_"..tostring(index)] then
        self["Text_tip_"..tostring(index)]:setString(Helper:getDef(text, ""))
    end
end

function LoginMultipleRewardUI:setTipTextVisible(index, visible)
    if self["Text_tip_"..tostring(index)] then
        self["Text_tip_"..tostring(index)]:setVisible(Helper:getDef(visible, false))
    end
end

function LoginMultipleRewardUI:setTipImageFunc(index, func)
    if self["Image_tip_"..tostring(index).."_hui"] then
        self["Image_tip_"..tostring(index).."_hui"]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function LoginMultipleRewardUI:setLightTipImageVisible(index, visible)
    if self["Image_tip_"..tostring(index).."_light"] then
        self["Image_tip_"..tostring(index).."_light"]:setVisible(Helper:getDef(visible, false))
    end
end

function LoginMultipleRewardUI:setButtonVisible(index, visible)
    if self["Button_"..tostring(index)] then
        self["Button_"..tostring(index)]:setVisible(Helper:getDef(visible, false))
    end
end

function LoginMultipleRewardUI:setButtonFunc(index, func)
    if self["Button_"..tostring(index)] then
        self["Button_"..tostring(index)]:releaseFunc(function()
            if func then
                func()
            end
        end)
    end
end

function LoginMultipleRewardUI:initListView_1(list)
    for i = 1, #list, 1 do
        local panel = self.ListView_item_1:getItem(i- 1)

        if not panel then
            panel = self:__cloneListView_1Item()
            self.ListView_item_1:pushBackCustomItem(panel)
        end

        panel.Image_icon:loadTexture(list[i].icon)
        panel.Text_1:setString(list[i].text)
        panel:releaseFunc(function()
            if list[i].func then
                list[i].func()
            end
        end)
    end
end

function LoginMultipleRewardUI:initListView_2(list)
    for i = 1, #list, 1 do
        local panel = self.ListView_item_2:getItem(i- 1)

        if not panel then
            panel = self:__cloneListView_2Item()
            self.ListView_item_2:pushBackCustomItem(panel)
        end
        
        self:__initPanelItem(panel, list[i])
    end
end


function LoginMultipleRewardUI:__initPanelItem(item, itemInfo)
    item.Text_1:setString(itemInfo.text)

    for i = 1, #itemInfo.list, 1 do
        item["Panel_"..tostring(i)].Image_icon:loadTexture(itemInfo.list[i].icon)
        item["Panel_"..tostring(i)].Image_state:setVisible(itemInfo.list[i].visible1)
        item["Panel_"..tostring(i)].Panel_di:setVisible(itemInfo.list[i].visible2)
        item["Panel_"..tostring(i)].Text_1:setVisible(itemInfo.list[i].visible3)
        item["Panel_"..tostring(i)].Text_1:setString(itemInfo.list[i].text)
        item["Panel_"..tostring(i)].Image_diKuang:loadTexture(itemInfo.list[i].bgImg)
        item["Panel_"..tostring(i)]:releaseFunc(function()
            if itemInfo.list[i].func then
                itemInfo.list[i].func()
            end
        end)
    end
end

function LoginMultipleRewardUI:__cloneListView_1Item()
    local itemUI = self.Panel_item_1:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function LoginMultipleRewardUI:__cloneListView_2Item()
    local itemUI = self.Panel_item_2:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function LoginMultipleRewardUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

return LoginMultipleRewardUI
0000000