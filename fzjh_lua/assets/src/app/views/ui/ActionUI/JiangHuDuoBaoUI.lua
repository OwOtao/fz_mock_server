local JiangHuDuoBaoUI = class("JiangHuDuoBaoUI", LayerEx)

function JiangHuDuoBaoUI:create()
    local p = JiangHuDuoBaoUI:new()
    p:init()
    return p
end

function JiangHuDuoBaoUI:init()
    self._UI = require("Layer/ActionUI/JiangHuDuoBaoUI.lua").create()["root"]

    self._UI:addTo(self)

    Helper:convertUIByParent(self)

    self.ListView_item:setScrollBarEnabled(false)

    self:setVisible(false)
end

function JiangHuDuoBaoUI:showUI()
    self:show()
end

function JiangHuDuoBaoUI:hideUI()
    self:hide()
end

function JiangHuDuoBaoUI:setButtonBack(func)
    self.Button_back:releaseFunc(
        function()
            func()
        end
    )
end

function JiangHuDuoBaoUI:setTextTitle(title)
    self.Text_title:setString(Helper:getDef(title, ""))
end

function JiangHuDuoBaoUI:setDesc(desc)
    self.Text_desc:setString(Helper:getDef(desc, ""))
end

function JiangHuDuoBaoUI:showListView(listData)
    self.ListView_item:removeAllItems()

    if MapIsEmpty(listData) == true then
        return
    end

    for k,info in pairs(listData) do
        local typePanel = self:__cloneLevelPanel()
        self:__initLevelPanelItem(typePanel,info.name)
        
        self.ListView_item:pushBackCustomItem(typePanel)

        if MapIsEmpty(info.data) == false then
            for k,v in pairs(info.data) do
                if math.mod(k, 2) == 0 then
                    local panel = self.ListView_item:getItem(#self.ListView_item:getItems() - 1)
                    local item = self:__cloneItem()
                    self:__initItem(item,v)
                    panel:addChild(item)
                    item:setPosition(512,0)
                else
                    local panel = self:__cloneItemPanel()
                    self.ListView_item:pushBackCustomItem(panel)
                    local item = self:__cloneItem()
                    self:__initItem(item,v)
                    panel:addChild(item)
                    item:setPosition(10,0)
                end
            end
        end
    end
end

function JiangHuDuoBaoUI:setText1(text)
    text = Helper:getDef(text,"")
    self.Text_1:setString(text)
end

function JiangHuDuoBaoUI:setText2(text)
    text = Helper:getDef(text,"")
    self.Text_2:setString(text)
end

function JiangHuDuoBaoUI:setText3(text)
    text = Helper:getDef(text,"")
    self.Panel_reward.Text_3:setString(text)
end

function JiangHuDuoBaoUI:setText4(text)
    text = Helper:getDef(text,"")
    self.Panel_choujiang.Text_4:setString(text)
end

function JiangHuDuoBaoUI:setChouJiangPanelVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_choujiang:setVisible(visible)
end

function JiangHuDuoBaoUI:setRewardPanelVisible(visible)
    visible = Helper:getDef(visible,false)
    self.Panel_reward:setVisible(visible)
end

function JiangHuDuoBaoUI:setChouJiangBtnFunc(func)
    self.Panel_choujiang.Button_1:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function JiangHuDuoBaoUI:setRewardBtnFunc(func)
    self.Panel_reward.Button_2:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function JiangHuDuoBaoUI:setButtonRuleFunc(func)
    self.Image_rule:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function JiangHuDuoBaoUI:__initItem(item,itemInfo)
    if MapIsEmpty(itemInfo) == false then
        item.Image_icon:loadTexture(itemInfo.icon)
        item.Text_name:setString(itemInfo.text)
        item.Text_num:setString("剩余："..tostring(itemInfo.num))
        if itemInfo.num == 0 then
            item.Panel_rewardBg:setVisible(true)
            item.Image_reward:setVisible(true)
        else
            item.Panel_rewardBg:setVisible(false)
            item.Image_reward:setVisible(false)
        end

        item:releaseFunc(
            function()
                if itemInfo.func then
                    itemInfo.func()
                end
            end
        )
    end
end

function JiangHuDuoBaoUI:__initLevelPanelItem(item,text)
    item.Text_typeName:setString(text)
end

function JiangHuDuoBaoUI:initRewardItem(itemInfo)
    if MapIsEmpty(itemInfo) == false then
        self.Panel_reward.Panel_rewardItem.Image_item:loadTexture(itemInfo.icon)
        self.Panel_reward.Panel_rewardItem.Text_name:setString(itemInfo.text)
        self.Panel_reward.Button_2.Text_buttonName:setString("领取")
        self.Panel_reward.Panel_rewardItem.Text_num:setVisible(false)
    end
end

function JiangHuDuoBaoUI:__cloneItemPanel()
    local itemUI = self.Panel_itemPanel:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function JiangHuDuoBaoUI:__cloneLevelPanel()
    local itemUI = self.Panel_type:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

function JiangHuDuoBaoUI:__cloneItem()
    local itemUI = self.Panel_item:clone()
    Helper:convertUIByParent(itemUI)
    return itemUI
end

return JiangHuDuoBaoUI
00000000000