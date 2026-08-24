local CommercialTimeUI = class("CommercialTimeUI", LayerEx)

function CommercialTimeUI:create()
	local p = CommercialTimeUI:new()
	p:init()
	return p
end

function CommercialTimeUI:init()
    self._round = require("Layer/CommercialTimeUI/CommercialTimeUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function CommercialTimeUI:showUI()
    self:show()
end

function CommercialTimeUI:hideUI()
    self:hide()
end

function CommercialTimeUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function CommercialTimeUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function CommercialTimeUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function CommercialTimeUI:setText1Color(color)
    self.Text_1:setTextColor(color)
end

function CommercialTimeUI:setText2(text)
    text = Helper:getDef(text,"")
    self.Text_2:setString(text)
end

function CommercialTimeUI:setText3(text)
    text = Helper:getDef(text,"")
    self.Text_3:setString(text)
end

function CommercialTimeUI:setTextRemainingWatches(text)
    self.Text_remainingWatches:setString(text)
end

function CommercialTimeUI:setTextPrivilegeTime(text)
    self.Text_privilegeTime:setString(text)
end

function CommercialTimeUI:setTextPrivilegeDesc(text)
    self.Text_privilegeDesc:setString(text)
end

function CommercialTimeUI:setPrivilegeDescPosX(posX)
    self.Text_privilegeDesc:setPositionX(posX)
end

function CommercialTimeUI:setButtonActivityVisible(bool)
    self.Button_1:setVisible(bool)
end

function CommercialTimeUI:setButtonActivityFunc(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CommercialTimeUI:setButtonPrivilegePosX(posX)
    self.Button_2:setPositionX(posX)
end

function CommercialTimeUI:setButtonPrivilegeFunc(func)
    self.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CommercialTimeUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CommercialTimeUI:initItem_1(item,itemInfo)
    if MapIsEmpty(itemInfo) == false then
        item.Image_icon:loadTexture(itemInfo.icon)
        item.Text_name:setString(itemInfo.textName)
        item.Text_num:setString(itemInfo.times)
        item.Text_time:setVisible(itemInfo.state == true)
        item.Panel_rewardBg:setVisible(itemInfo.state == false)
    end
end

function CommercialTimeUI:initItem(item,itemInfo)
    if MapIsEmpty(itemInfo) == false then
        item.Image_icon:loadTexture(itemInfo.icon)
        item.Text_name:setString(itemInfo.textName)
        item.Text_num:setString(itemInfo.times)
        item.Panel_rewardBg:setVisible(itemInfo.state == false)
    end
end

function CommercialTimeUI:setItemRemainingTime(item, time)
    if item.Text_time then
        item.Text_time:setString(time)
    end
end

function CommercialTimeUI:setItemSchedule(item, scheduleFunc, interval)
    item:schedule(scheduleFunc,interval)
end

function CommercialTimeUI:stopItemAllSchedule(item)
    item:unscheduleAll()
end

function CommercialTimeUI:setItemFunc(item, func)
    item:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CommercialTimeUI:setItemBgFunc(item, func)
    item.Panel_rewardBg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function CommercialTimeUI:clearListView()
    self.ListView_item:removeAllItems()
end

function CommercialTimeUI:addListViewItem(panel)
    self.ListView_item:pushBackCustomItem(panel)
end

function CommercialTimeUI:getListViewLastItem()
    local panel = self.ListView_item:getItem(#self.ListView_item:getItems() - 1)
    return panel
end

function CommercialTimeUI:addPanelItem(panel, item)
    panel:addChild(item)
end

function CommercialTimeUI:cloneItemPanel()
    local itemUI = self.Panel_itemPanel:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function CommercialTimeUI:createItem_1(posX)
    local itemUI = self.Panel_item_1:clone()
    Helper:convertUIByParent(itemUI)
    itemUI:setPosition(posX,0)
    return itemUI
end

function CommercialTimeUI:createItem(posX)
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    itemUI:setPosition(posX,0)
    return itemUI
end

function CommercialTimeUI:__cloneItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function CommercialTimeUI:__cloneItem_1()
    local itemUI = self.Panel_item_1:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end


return CommercialTimeUI00000