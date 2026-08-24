local DanQingGePresenter = class("DanQingGePresenter", cc.Layer)
local MaskResManager = require("app.models.mask.MaskResManager")

function DanQingGePresenter:create()
    local p = DanQingGePresenter:new()
    p:init()
    return p
end

function DanQingGePresenter:init()
    self._actionUI = require("app.views.ui.ActionUI.DanQingGeUI"):create()

    self._actionUI:addTo(self)

    self._selectRewardUI = require("app.views.ui.ActionUI.RewardSelectUI"):create()

    self._selectRewardUI:addTo(self)

    self._selectRewardUI:hideUI()

    self._selectRewardUI:setButtonBack(
        function()
            self._selectRewardUI:hideUI()
        end
    )

    self:__setRuleFunc()

    local DanQingGe = require("app.models.Action.DanQingGe")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._interactor = DanQingGe:create()
end

function DanQingGePresenter:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()
end

function DanQingGePresenter:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function DanQingGePresenter:__initData()
    self._interactor:init(
        function()
            self:__initUI()

            self._actionUI:showUI()
        end
    )
end

function DanQingGePresenter:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setText1("目前拥有"..self._interactor:getCurrencyName().."数量："..self._interactor:getCurrencyNum())

    local listData = self._interactor:getList()

    for __,itemInfo in pairs(listData) do
        itemInfo.text1 = itemInfo.text
        itemInfo.text2 = itemInfo.buyTimes.."/"..itemInfo.totalTimes
        
        itemInfo.loadTexture = "Image/UI/TaskUI/anniu.png"
        itemInfo.btnName = "领取"
        itemInfo.enable = true

        if self._interactor:checkStateIsUnlock(itemInfo.state) then
            itemInfo.btnName = itemInfo.price..self._interactor:getCurrencyName()

            if self._interactor:checkRewardIsSelect(itemInfo.type) then
                itemInfo.btnName = "进入"
            end
        end

        if self._interactor:checkStateIsReward(itemInfo.state) and self._interactor:checkRewardIsSelect(itemInfo.type) then
            local str = ""
            for k, v in pairs(itemInfo.reward) do
                str = str..v.name.."X"..v.number.."、"
            end
            str = string.sub(str, 1, -4)

            itemInfo.text1 = str
        end

        if self._interactor:checkStateIsRewarded(itemInfo.state) then
            itemInfo.btnName = "已售罄"
            itemInfo.enable = false
            itemInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end

        itemInfo.func1 = function()
            if self._interactor:checkRewardIsSelect(itemInfo.type) == false then
                local showList = {}

                for __, rewardId in ipairs(itemInfo.rewardIdList) do
                    local rewards = self._interactor:getRewardById(rewardId)
                    local info = {id = rewards[1].goodsId}

                    table.insert(showList, info)
                end

                PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                    layer:showLayer(showList)
                end)
            end
        end 

        itemInfo.func2 = function()
            if self._interactor:checkRewardIsSelect(itemInfo.type) and self._interactor:checkStateIsUnlock(itemInfo.state) then
                self._selectRewardUI:setText2("目前拥有"..self._interactor:getCurrencyName().."数量："..self._interactor:getCurrencyNum())
                local rewardIds = itemInfo.rewardIdList
                if MapIsEmpty(rewardIds) == false then
                    local rewards = {}
                    for i = 1, #rewardIds do
                        local reward = {}
                        local showList = {}
                        local info = self._interactor:getRewardById(rewardIds[i])
                        local text = ""
                        for i, v in ipairs(info) do
                            text = text .. v.name .. "X" .. v.num .."、"
                            local info = {id = v.goodsId}

                            table.insert(showList, info)
                        end

                        text = string.sub(text, 1, -4)
                        reward.text = text
                        reward.loadTexture = "Image/UI/TaskUI/anniu.png"
                        reward.btnName = "领取"

                        if self._interactor:checkStateIsUnlock(itemInfo.state) then
                            reward.btnName = itemInfo.price..self._interactor:getCurrencyName()
                        end


                        reward.func = function()
                            local reward = inherit({rewardId = rewardIds[i]},itemInfo)
                            self:__doReward(reward)
                            self._selectRewardUI:hideUI()
                        end

                        reward.func1 = function()
                            PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
                                layer:showLayer(showList)
                            end)
                        end 

                        table.insert(rewards, reward)
                    end
                    self._selectRewardUI:showListView(rewards)
                    self._selectRewardUI:showUI()
                end
            else
                self:__doReward(itemInfo)
            end 
            
        end
    end

    self._actionUI:showListView(listData)
end

function DanQingGePresenter:hideLayer()
    PopupLayerController:hideLayer(
        "DanQingGePresenter",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function DanQingGePresenter:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function DanQingGePresenter:__doReward(itemInfo)
    if self._interactor:checkStateIsReward(itemInfo.state) then
        local rewards = itemInfo.reward

        if self._interactor:checkBagIsEnough(rewards) then
            PopText("背包空间不足，无法领取奖励。")
            return
        end

        self._interactor:doReward(itemInfo.id,function()
            self._interactor:init(
                function()
                    self:__initUI()
                end
            )
        end)

        return
    end

    if self._interactor:checkStateIsUnlock(itemInfo.state) and 
    self._interactor:checkCurrencyIsEnough(itemInfo.price) == false then
        PopText(self._interactor:getCurrencyName().."数量不足，兑换失败")
        return
    end

    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show("是否消耗"..itemInfo.price..self._interactor:getCurrencyName().."兑换"..itemInfo.text)
    dialog:setButton1("确定", function()
        self._interactor:exchangeReward(itemInfo.id, itemInfo.rewardId, function()
            self._interactor:init(
                function()
                    self:__initUI()
                end
            )
        end)
    end)

    dialog:setButton2("取消", function()
        dialog:hide()
    end)

    dialog:setWeChatVisible(false)
end


function DanQingGePresenter:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function DanQingGePresenter:__showRule()
	PopupLayerController:showLayer("ActionRuleUI",function(layer)
        layer:showUI()
        layer:setTextTitle("活动规则")
        layer:showPanel_1(self.__ruleInfo)
        layer:setButtonBack(function()
            PopupLayerController:hideLayer("ActionRuleUI",function(layer)
                layer:hideUI()
            end)
        end)
    end)
end

Helper:classDefNodeGetInstance(DanQingGePresenter)

return DanQingGePresenter
0000000000000000