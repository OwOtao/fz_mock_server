local JiangHuMingWuLuActionPresenters = class("JiangHuMingWuLuActionPresenters", cc.Layer)

function JiangHuMingWuLuActionPresenters:create()
    local p = JiangHuMingWuLuActionPresenters:new()
    p:init()
    return p
end

function JiangHuMingWuLuActionPresenters:init()
    --@RefType[JiangHuYiRenLuAction2UI]
    self._actionUI = require("app.views.ui.ActionUI.JiangHuYiRenLuAction2UI"):create()

    self._actionUI:addTo(self)

    --@RefType[JiangHuYiRenLuExchangeUI]
    self._exchangeUI = require("app.views.ui.ActionUI.JiangHuYiRenLuExchangeUI"):create()

    self._exchangeUI:addTo(self)

    self._exchangeUI:setPresenters(self)


    local JiangHuMingWuLuAction = require("app.models.Action.JiangHuMingWuLuAction")

    self._actionUI:setPanelBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    --@RefType[src.app.models.Action.JiangHuMingWuLuAction#JiangHuMingWuLuAction]
    self._interactor = JiangHuMingWuLuAction:create()
end

function JiangHuMingWuLuActionPresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    self._interactor:init(
        function()
            self:__initUI(function()
                self._actionUI:showUI()
            end)
        end
    )
end

function JiangHuMingWuLuActionPresenters:__initUI(func)
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setTextCurrency("当前拥有" .. self._interactor:getCurrencyCount() .. "份" .. self._interactor:getCurrecnyName())
    
    self._actionUI:setTextExchangeCurrency("当前拥有" .. self._interactor:getExchangeCurrencyCount() .. "张" .. self._interactor:getExchangeCurrencyName())

    self:__initRewardPanel(self._interactor:getShowRewards())

    self:__initButton(self._interactor:getButtonInfo())

    self._actionUI:setButtonClickFunc3(
        "前往兑换",
        function()
            HttpManagerEx:getTime(function(status, errcode, errmsg, data, isEncrypted)
                if status == 200 and errcode == 0 and data.time ~= nil then
                    SetTime(tonumber(data.time))
                    local endTime = self._interactor:getActionEndTime()

                    if endTime and endTime < tonumber(data.time) then
                        self._interactor:init(
                            function()
                                self:__initUI(function()
                                    self:__showExchangeUI()
                                end)
                            end
                        )
                    else
                        self:__showExchangeUI()
                    end
                end
            end,IS_SHOW_WAITING)
        end
    )
    
    if func then
        func()
    end
end

function JiangHuMingWuLuActionPresenters:__showExchangeUI()
    self.__currExchangeIndex = 1

    self._exchangeUI:setActionTitle(self._interactor:getActionName())

    self._exchangeUI:setActionDesc(self._interactor:getActionDesc())

    self._exchangeUI:setImageVisible(false)

    local reward = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)

    self:__refreshExchangeUI()

    self._exchangeUI:initNowPanelInfo(reward)

    self:__updateExchangeUI(reward)

    self._exchangeUI:showUI()
end

--@desc 根据当前的兑换处理兑换界面刷新UI
function JiangHuMingWuLuActionPresenters:__updateExchangeUI(reward)
    if reward.rewardType == 1 then
        self._exchangeUI:setNeedDescAndNum("需要" .. self._interactor:getExchangeCurrencyName(), reward.need)
        self._exchangeUI:setNeedNumTextVisible(true)
        self._exchangeUI:setExchangeBtn(
            "兑换",
            function()
                self:exchangeReward()
            end
        )
    elseif reward.rewardType == 2 then
        self._exchangeUI:setNeedNumTextVisible(false)
        self._exchangeUI:setExchangeBtn(
            "兑换",
            function()
                self:exchangeReward()
            end
        )
    else
        assert(false, "兑换奖励类型错误")
    end
end

function JiangHuMingWuLuActionPresenters:__initRewardPanel(list)
    for i = 1, #list do
        local itemInfo = list[i]
        self._actionUI["initPanel" .. i](self._actionUI, itemInfo)
    end
end

function JiangHuMingWuLuActionPresenters:__initButton(btnInfo)
    for i = 1, 2 do
        local info = btnInfo[i]

        self._actionUI["setPanelCostText" .. i](self._actionUI, info.removeCurrency)

        self._actionUI["setPanelCostImage" .. i](self._actionUI, info.imagePath)

        self._actionUI["setButtonClickFunc" .. i](
            self._actionUI,
            info.name,
            function()
                self._interactor:doLottery(
                    i,
                    function(msgCode,data)
                        if msgCode == 2 then
                            YuanBaoPayLayer.buyStoreItem(self._interactor:getBuyGoodId(), self._interactor:getBuyGoodItemId(), function(eventType)
                                if eventType == "success" then
                                    self._interactor:setCurrencyCount(self._interactor:getCurrencyCount() + info.removeCurrency)
                                    self:__refreshActionUI()
                                    PopText("购买成功")
                                end
                            end,info.removeCurrency,{isOpenPay = true})
                            return 
                        elseif msgCode == 1 then
                            local rewards = data.prize

                            if MapIsEmpty(rewards) == false then
                                for i = 1, #rewards do
                                    local reward = rewards[i]
    
                                    PopText("您获得了 " .. reward.name .. " X" .. reward.number)
                                end
                            end
                            self:__refreshActionUI()
                        end
                    end
                )
            end
        )
    end
end

function JiangHuMingWuLuActionPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "JiangHuMingWuLuActionPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function JiangHuMingWuLuActionPresenters:nextExchangeReward()
    local maxIndex = #self._interactor:getExchageRewardList()

    local nextIndex = self.__currExchangeIndex + 1

    if nextIndex > maxIndex then
        nextIndex = 1
    end

    self.__currExchangeIndex = nextIndex

    local exchangeRewardInfo = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)
    self._exchangeUI:initNextPanelInfo(exchangeRewardInfo)

    self:__updateExchangeUI(exchangeRewardInfo)
end

function JiangHuMingWuLuActionPresenters:prevExchangeReward()
    local maxIndex = #self._interactor:getExchageRewardList()

    local preIndex = self.__currExchangeIndex - 1

    if preIndex <= 0 then
        preIndex = maxIndex
    end

    self.__currExchangeIndex = preIndex

    local exchangeRewardInfo = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)
    self._exchangeUI:initNextPanelInfo(exchangeRewardInfo)

    self:__updateExchangeUI(exchangeRewardInfo)
end

function JiangHuMingWuLuActionPresenters:exchangeReward()
    local endTime = self._interactor:getActionEndTime()
    
    if endTime and endTime < GetTime() then
        PopText("活动已结束，无法兑换")
        return
    end

    return self._interactor:exchangeReward(
        self.__currExchangeIndex,
        function(rewardType, reward)
            if rewardType == 1 then
                PopupLayerController:showLayer(
                    "TextAnimLayer",
                    function(layer)
                        layer:setAfterAnimCallback(
                            function()
                                PopText("消耗".. self._interactor:getExchangeCurrencyName() .." x " .. reward.need)
                                PopText("获得 " .. self._role:getOneItemByKey(reward.itemId).name .. " x " .. 1)
                            end
                        )
                        layer:showLayer(reward.thankText)
                    end
                )
            else
                -- PopText("消耗名帖 x " .. reward.removebfmt)
                -- PopText("获得饰品材料 x " .. reward.addspcl)
            end

            self:__refreshActionUI()
            self:__refreshExchangeUI()
        end
    )
end

function JiangHuMingWuLuActionPresenters:__refreshActionUI()
    local str_1 = "当前拥有" .. self._interactor:getCurrencyCount() .. "份" .. self._interactor:getCurrecnyName()
    local str_2 = "当前拥有" .. self._interactor:getExchangeCurrencyCount() .. "张" .. self._interactor:getExchangeCurrencyName()
    self._actionUI:setTextCurrency(str_1)
    self._actionUI:setTextExchangeCurrency(str_2)
end

function JiangHuMingWuLuActionPresenters:__refreshExchangeUI()
    self._exchangeUI:setCurrentDescAndNum("当前拥有" .. self._interactor:getExchangeCurrencyName(), self._interactor:getExchangeCurrencyCount())
end

function JiangHuMingWuLuActionPresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function JiangHuMingWuLuActionPresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function JiangHuMingWuLuActionPresenters:__showRule()
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

Helper:classDefNodeGetInstance(JiangHuMingWuLuActionPresenters)

return JiangHuMingWuLuActionPresenters
000