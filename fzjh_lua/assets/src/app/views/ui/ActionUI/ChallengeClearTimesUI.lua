local ChallengeClearTimesUI = class("ChallengeClearTimesUI", LayerEx)

function ChallengeClearTimesUI:create()
    local p = ChallengeClearTimesUI:new()
    p:init()
    return p
end

function ChallengeClearTimesUI:init()
    self._UI = require("Layer/ActionUI/ChallengeClearTimesUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function ChallengeClearTimesUI:showUI()
    self:show()
end

function ChallengeClearTimesUI:hideUI()
    self:hide()
end

function ChallengeClearTimesUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function ChallengeClearTimesUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function ChallengeClearTimesUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function ChallengeClearTimesUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for __, itemInfo in pairs(listData) do
        local itemUI = self:__cloneListViewItem()
        itemUI.Text_name:setString(itemInfo.name)
		itemUI.Text_desc:setString(itemInfo.desc)
		itemUI.Text_rewardInfo:setString(itemInfo.rewardText)
        itemUI.Text_rewardInfo:releaseFunc(function()
            if itemInfo.itemFunc then
                itemInfo.itemFunc()
            end
        end)
		itemUI.Text_taskInfo:setString(itemInfo.conditionText)
		itemUI.Text_taskInfo:setTouchEnabled(itemInfo.textEnable)
		itemUI.Text_taskInfo:releaseFunc(function()
			itemUI.Image_Bg:setVisible(true)
			itemUI.Image_Bg.Text_1:setString(itemInfo.conditionInfoText)
            if itemInfo.conditionFunc then
                itemInfo.conditionFunc()
            end
        end)
        itemUI.Image_complete:loadTexture(itemInfo.loadTexture,0)

		itemUI.Image_hongdian:setVisible(itemInfo.hongdianVisible)

        self:__addItemToListView(itemUI)
    end
end

function ChallengeClearTimesUI:hideImageBg()
	local items = self.ListView_item:getItems()

	for index = 1, #items do
		local itemUI = self.ListView_item:getItem(index - 1)
		if itemUI ~= nil then
			itemUI.Image_Bg:setVisible(false)
		end
	end
end

function ChallengeClearTimesUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function ChallengeClearTimesUI:setButtonFunc(func)
    self.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ChallengeClearTimesUI:setButtonName(name)
    self.Button_1.Text_buttonName:setString(name)
end

function ChallengeClearTimesUI:setButtonHongDian(visible)
	visible = Helper:getDef(visible,false)
    self.Button_1.Image_hongdian:setVisible(visible)
end

function ChallengeClearTimesUI:setPanelInfoVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_infoBg:setVisible(visible)
end

function ChallengeClearTimesUI:setPanelInfoFunc(func)
    self.Panel_infoBg:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ChallengeClearTimesUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ChallengeClearTimesUI:__cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function ChallengeClearTimesUI:__addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return ChallengeClearTimesUI
00000000000000