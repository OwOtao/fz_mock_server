local JiangHuDuoBaoPresenters = class("JiangHuDuoBaoPresenters", cc.Layer)

function JiangHuDuoBaoPresenters:create()
    local p = JiangHuDuoBaoPresenters:new()
    p:init()
    return p
end

function JiangHuDuoBaoPresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.JiangHuDuoBaoUI"):create()

    self._actionUI:addTo(self)

    self._selectRewardUI = require("app.views.ui.ActionUI.RewardSelectUI"):create()

    self._selectRewardUI:addTo(self)

    self._selectRewardUI:hideUI()

    self._selectRewardUI:setButtonBack(
        function()
            self._selectRewardUI:hideUI()
        end
    )

    local JiangHuDuoBao = require("app.models.Action.JiangHuDuoBao")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = JiangHuDuoBao:create()
end

function JiangHuDuoBaoPresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)

    self:__initData()

    self._interactor:setRefreshFunc(function()
        self._interactor:init(
        function()
            self:__initUI()
        end)
    end)
end

function JiangHuDuoBaoPresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function JiangHuDuoBaoPresenters:__initData()
    self._interactor:init(
        function()
            self:__initUI()

            self._actionUI:showUI()
        end
    )
end

function JiangHuDuoBaoPresenters:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setText1(self._interactor:getPayCurrencyName().."：")

    self._actionUI:setText2(tostring(self._interactor:getPayCurrencyNum()).."/"..tostring(self._interactor:getPayCurrencyBuyLimit()))

    self._actionUI:setText4("本次抽奖所需"..tostring(self._interactor:getPayNum())..self._interactor:getPayCurrencyName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setChouJiangPanelVisible(self._interactor:getLotteryState() == 0)

    self._actionUI:setRewardPanelVisible(self._interactor:getLotteryState() == 1)

    self._actionUI:initRewardItem(self._interactor:getRewardInfo())

    self._actionUI:setChouJiangBtnFunc(function()
        self:__chouJiang()
    end)

    self:__showList()

    local isSelectReward = self._interactor:checkRewardTypeIsSelect()

    if isSelectReward then
        self._actionUI:setText3("点击右侧按钮进入界面选择一种奖品")
    else
        self._actionUI:setText3("本次抽奖获得：")
    end

    self._actionUI:setRewardBtnFunc(function()
        if isSelectReward then
            self:__showSelectUI()
        else
            local rewards = self._interactor:getRewardInfo()
            local reward = rewards.rewards[1]
            self:__doReward(reward)
        end
    end)
end

function JiangHuDuoBaoPresenters:__showList()
    local list = self._interactor:getShowItemInfo()
    for i = 1, #list, 1 do
        for __, info in ipairs(list[i].data) do
            local showList = {}
            for __, reward in ipairs(info.rewards) do
                table.insert(showList, {id = reward.rid})
            end

            info.func = function()
                self:__showGoodsInfoUI(showList)
            end
        end
    end
    self._actionUI:showListView(list)
end

function JiangHuDuoBaoPresenters:__chouJiang()
    if self._interactor:checkIsEmptyPool() then
        PopText("本次奖品已抽空，期待下次活动")
        return
    end
    
    if self._interactor:getPayCurrencyNum() >= self._interactor:getPayNum() then
        self._interactor:doLotterty()
    else
        local item = self._interactor:getPayCurrencyInfo()
        PopupLayerController:showLayer("BuyCurrencyPresenter",function(layer)
            layer:setTitle("请确定购买")
            layer:setTextDesc_1("    "..item.desc)
            layer:setTextDesc_2("购买可获得")
            layer:setTextDesc_3(item.name,1)
            layer:setText_1Str("需要花费：")
            layer:setImageGoodsTexture(item.icon)
            layer:setPriceName("元宝")
            layer:setText_2Str(tostring(item.price).."元宝")
            layer:setItemName(item.name)
            layer:setUnitPrice(item.price)
            layer:setBuyNumber(1)
            layer:setMaxBuyNumber(item.buyLimit)
            layer:setSelectText(tostring(1).."/"..tostring(item.buyLimit))

            layer:showLayer()

            layer:setButton_1Func(function(buyNumber)
                self._interactor:buyCurrency(buyNumber,function(eventType)
                    if eventType == 0 then
                        PopText("购买成功")
                        self._interactor:init(
                        function()
                            self:__initUI()
                        end)
                    elseif eventType == 1 then
                        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
                        local dialog = DialogALayer:getInstance()
                        dialog:hide()
                        dialog:show("你的元宝不足，前往充值后才可继续操作。", "HIY是否前往充值NOR")
                        dialog:setButton1(
                            "确定",
                            function()
                                Game:openPayLayer(function()
                                    PopupLayerController:showLayer("PayLayer", function(layer)
                                        layer:show()
                                    end)
                                end)
                            end
                        )

                        dialog:setButton2(
                            "取消",
                            function()
                            end
                        )

                    end
                end)
            end)
            
            layer:setButton_2Func(function()
                layer:hideLayer()
            end)
        end)
    end
end

function JiangHuDuoBaoPresenters:__showSelectUI()
    self._selectRewardUI:showUI()
    self._selectRewardUI:setText2("")

    local rewards = self._interactor:getRewardInfo()
    local rewardList = rewards.rewards

    local showList = {}
    for k, reward in pairs(rewardList) do
        local item = {}
        item.text1 = reward.name.."X"..tostring(reward.number)
        item.icon = reward.icon
        item.func = function()
            local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
            local dialog = DialogALayer:getInstance()
            dialog:show( "是否确认领取"..reward.name.."x"..reward.number.."？")
            dialog:setButton1("确定", function()
                self:__doReward(reward)
                self._selectRewardUI:hideUI()
            end)
            dialog:setButton2("取消", function()
                dialog:hide()
            end)
            dialog:setWeChatVisible(false)
        end

        item.func1 = function()
            self:__showGoodsInfoUI({{id = reward.rid}})
        end
        table.insert(showList, item)
    end

    self._selectRewardUI:showIconListView(showList)
end

function JiangHuDuoBaoPresenters:__doReward(reward)
    self._interactor:doReward(reward)
end

function JiangHuDuoBaoPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "JiangHuDuoBaoPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function JiangHuDuoBaoPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function JiangHuDuoBaoPresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function JiangHuDuoBaoPresenters:__showRule()
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

function JiangHuDuoBaoPresenters:__showGoodsInfoUI(showList)
    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
        layer:showLayer(showList)
    end)
end

Helper:classDefNodeGetInstance(JiangHuDuoBaoPresenters)

return JiangHuDuoBaoPresenters
0000000000000000