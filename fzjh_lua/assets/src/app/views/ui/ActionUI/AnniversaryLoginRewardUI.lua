local AnniversaryLoginRewardUI = class("AnniversaryLoginRewardUI", LayerEx)

function AnniversaryLoginRewardUI:create()
    local p = AnniversaryLoginRewardUI:new()
    p:init()
    return p
end

function AnniversaryLoginRewardUI:init()
    self._UI = require("Layer/ActionUI/AnniversaryLoginRewardUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function AnniversaryLoginRewardUI:showUI()
    self:show()
end

function AnniversaryLoginRewardUI:hideUI()
    self:hide()
end

function AnniversaryLoginRewardUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function AnniversaryLoginRewardUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function AnniversaryLoginRewardUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function AnniversaryLoginRewardUI:setRewardButtonEnable(enable)
    enable = Helper:getDef(enable,false)
    self.Button_reward:setTouchEnabled(enable)
end

function AnniversaryLoginRewardUI:setRewardButtonName(name)
    name = Helper:getDef(name,"")
    self.Button_reward.Text_buttonName:setString(name)
end

function AnniversaryLoginRewardUI:setRewardButtonTexture(texture)
    texture = Helper:getDef(texture,"Image/BaseUI/btn-orangeRed.png")
    self.Button_reward:loadTextureNormal(texture)
end 

function AnniversaryLoginRewardUI:setButtonRewardFunc(func)
    self.Button_reward:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function AnniversaryLoginRewardUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function AnniversaryLoginRewardUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function AnniversaryLoginRewardUI:initListViewPanel(panel,panelInfo)
    if MapIsEmpty(panelInfo) == true then
        return
    end

    panel.Text_1:setString(panelInfo.text1)
    panel.Text_2:setString(panelInfo.text2)
    panel.Button_1:setTouchEnabled(panelInfo.enable)
    panel.Button_1:loadTextureNormal(panelInfo.loadTexture)
    panel.Button_1.Text_buttonName:setString(panelInfo.btnName)
    panel.Button_1:releaseFunc(function()
        if panelInfo.getReward then
            panelInfo.getReward()
        end
    end)
end

function AnniversaryLoginRewardUI:getListViewItemByIndex(index)
    return self.ListView_item:getItem(index)
end

function AnniversaryLoginRewardUI:cloneListViewItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function AnniversaryLoginRewardUI:clearListView()
    self.ListView_item:removeAllItems()
end

function AnniversaryLoginRewardUI:addItemToListView(itemUI)
    self.ListView_item:pushBackCustomItem(itemUI)
end

return AnniversaryLoginRewardUI
000000