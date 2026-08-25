local XiangNangMiGePresenters = class("XiangNangMiGePresenters", cc.Layer)
local GoodsHelper = require("app.models.Store.GoodsHelper")

function XiangNangMiGePresenters:create()
    local p = XiangNangMiGePresenters:new()
    p:init()
    return p
end

function XiangNangMiGePresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.XiangNangMiGeUI"):create()

    self._actionUI:addTo(self)

    self._selectRewardUI = require("app.views.ui.ActionUI.RewardSelectUI"):create()

    self._selectRewardUI:addTo(self)

    self._selectRewardUI:hideUI()

    self:__setRuleFunc()

    local XiangNangMiGe = require("app.models.Action.XiangNangMiGe")

    self._actionUI:setButtonBack(
        function()
            self:hideLayer()
        end
    )

    self._selectRewardUI:setButtonBack(
        function()
            self._selectRewardUI:hideUI()
        end
    )

    self._interactor = XiangNangMiGe:create()
end

function XiangNangMiGePresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    
    self:__initData()
end

function XiangNangMiGePresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function XiangNangMiGePresenters:__initData()
    self._interactor:init(
        function()
            self:__initUI()

            self._actionUI:showUI()
        end
    )
end

function XiangNangMiGePresenters:__initUI()
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setText1("目前拥有"..self._interactor:getCurrencyName().."数量："..self._interactor:getCurrencyNum())

    self._actionUI:setButtonInfoFunc(function()
        self._actionUI:setPanelInfoVisible(true)
        self._actionUI:setPanelInfoFunc(function()
            self._actionUI:setPanelInfoVisible(false)
        end)
    end)

    local listData = self._interactor:getRewardLevelList()
    Helper:print_lua_table(listData)
    for __,itemInfo in pairs(listData) do
        itemInfo.loadTexture = "Image/UI/TaskUI/anniu.png"

        if self._interactor:checkStateIsRewarded(itemInfo.state) then
            itemInfo.btnName = "已兑换"
            itemInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end

        if self._interactor:checkStateIsUnlock(itemInfo.state) then
            itemInfo.btnName = "未解锁"
            itemInfo.loadTexture = "Image/UI/TaskUI/anniuhui.png"
        end

        if not self._interactor:checkRewardLevelIsSelect(itemInfo.rewardLevelType) then
            itemInfo.textEnable = true
            itemInfo.itemFunc = function()
                self:__showGoodsInfoUI(self._interactor:getRewardById(itemInfo.rewardIds[1]))
            end
        elseif self._interactor:checkStateIsRewarded(itemInfo.state) then
            itemInfo.textEnable = true
            itemInfo.itemFunc = function()
                self:__showGoodsInfoUI(self._interactor:getRewardById(itemInfo.exchangeId))
            end
        else
            itemInfo.textEnable = false
        end

        if self._interactor:checkStateIsReward(itemInfo.state) then
            if self._interactor:checkRewardLevelIsSelect(itemInfo.rewardLevelType) then
                itemInfo.btnName = "进入"
            else
                assert(itemInfo.rewardIds,"当前奖励为空")
                local currReward = self._interactor:getRewardById(itemInfo.rewardIds[1])
                itemInfo.btnName = currReward.price .. self._interactor:getCurrencyName()
            end
        end

        itemInfo.func = function()
            if self._interactor:checkStateIsRewarded(itemInfo.state) then
                PopText("物品已兑换成功，请勿重复兑换")
                return
            end

            if self._interactor:checkRewardLevelIsSelect(itemInfo.rewardLevelType) then
                self._selectRewardUI:setText2("目前拥有"..self._interactor:getCurrencyName().."数量："..self._interactor:getCurrencyNum())
                local rewardIds = itemInfo.rewardIds
                if MapIsEmpty(rewardIds) == false then
                    local rewards = {}
                    for i = 1, #rewardIds do
                        local reward = self._interactor:getRewardById(rewardIds[i])
                        if self._interactor:checkStateIsUnlock(itemInfo.state) then
                            reward.btnName = "未解锁"
                            reward.loadTexture = "Image/UI/MapUI/anniu04.png"
                        else
                            reward.btnName = reward.price .. self._interactor:getCurrencyName()
                            reward.loadTexture = "Image/UI/MapUI/anniu05.png"
                        end

                        reward.func1 = function()
                            self:__showGoodsInfoUI(reward)
                        end
                        
                        reward.func = function()
                            if self._interactor:checkStateIsUnlock(itemInfo.state) then
                                PopText("请先兑换上一档次奖励")
                                return
                            end

                            self:__doReward(reward)
                        end

                        table.insert(rewards, reward)
                    end
                    self._selectRewardUI:showListView(rewards)
                    self._selectRewardUI:showUI()
                else
                    error("当前档位奖励错误！ 档位id:"..tostring(itemInfo.rewardLevel))
                end
            else
                local currReward = self._interactor:getRewardById(itemInfo.rewardIds[1])
                if currReward then
                    if self._interactor:checkStateIsUnlock(itemInfo.state) then
                        PopText("请先兑换上一档次奖励")
                        return
                    end

                    self:__doReward(currReward)
                else
                    error("当前档位奖励错误！ 档位id:"..tostring(itemInfo.rewardLevel))
                end
            end
        end
    end

    self._actionUI:showListView(listData)

    self._actionUI:setPanelInfoText(self._interactor:getHelpText())
end

function XiangNangMiGePresenters:__showExchangeConfirmDialog(reward)
    local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
    local dialog = DialogALayer:getInstance()
    dialog:show("是否消耗"..reward.price..self._interactor:getCurrencyName().."兑换当前奖励?")
    dialog:setButton1("确定", function()
        if self._interactor:checkCurrencyIsEnough(reward.price) == false then
            PopText(self._interactor:getCurrencyName().."不足无法兑换")
            return
        end

        local rewards = reward.rewards

        local isEmail = self._interactor:checkBagIsEnough(rewards)
        self._interactor:doReward(reward.id, isEmail,function()
            self._selectRewardUI:hideUI()
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

function XiangNangMiGePresenters:__doReward(reward)
    if MapIsEmpty(reward) == false then
        local isTrue, searchInfo = self._interactor:checkCanBuy(reward.rewards)

        if isTrue == false then
            GoodsHelper:handleDuplicatePurchaseSearchInfo(
                searchInfo,
                {
                    flowType = GoodsHelper.DUPLICATE_PURCHASE_FLOW_TYPE.CONTINUE,
                    onConfirm = function()
                        self:__showExchangeConfirmDialog(reward)
                    end
                }
            )

            return
        end

        self:__showExchangeConfirmDialog(reward)
    else
        error("当前奖励为空")
    end
end

function XiangNangMiGePresenters:hideLayer()
    PopupLayerController:hideLayer(
        "XiangNangMiGePresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function XiangNangMiGePresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function XiangNangMiGePresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function XiangNangMiGePresenters:__showRule()
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

function XiangNangMiGePresenters:__showGoodsInfoUI(reward)
    local goodsList = reward.rewards

    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
        layer:showLayer(goodsList)
    end)
end

Helper:classDefNodeGetInstance(XiangNangMiGePresenters)

return XiangNangMiGePresenters
00