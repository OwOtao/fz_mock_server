local JiangHuZhenPinGePresenters = class("JiangHuZhenPinGePresenters", cc.Layer)
local GoodsHelper = require("app.models.Store.GoodsHelper")
local ActionRewardsHelper = require("app.models.Action.ActionRewardsHelper")

function JiangHuZhenPinGePresenters:create()
    local p = JiangHuZhenPinGePresenters:new()
    p:init()
    return p
end

function JiangHuZhenPinGePresenters:init()
    --@RefType[JiangHuYiRenLuAction2UI]
    self._actionUI = require("app.views.ui.ActionUI.JiangHuZhenPinGeUI"):create()

    self._actionUI:addTo(self)

    --@RefType[JiangHuYiRenLuExchangeUI]
    self._exchangeUI = require("app.views.ui.ActionUI.JiangHuYiRenLuExchangeUI"):create()

    self._exchangeUI:addTo(self)

    self._exchangeUI:setPresenters(self)


    local JiangHuZhenPinGe = require("app.models.Action.JiangHuZhenPinGe")

    self._actionUI:setPanelBack(
        function()
            self:hideLayer()
        end
    )

    self:__setRuleFunc()

    self._interactor = JiangHuZhenPinGe:create()
end

function JiangHuZhenPinGePresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function JiangHuZhenPinGePresenters:showLayer()
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

function JiangHuZhenPinGePresenters:__initUI(func)
    self._actionUI:setTextTitle(self._interactor:getActionName())

    self._actionUI:setDesc(self._interactor:getActionDesc())

    self._actionUI:setTextCurrency("当前拥有" .. self._interactor:getCurrencyCount() .. "份" .. self._interactor:getCurrecnyName())
    
    self._actionUI:setTextExchangeCurrency("当前拥有" .. self._interactor:getExchangeCurrencyCount() .. "张" .. self._interactor:getExchangeCurrencyName())

    local currTimes = self._interactor:getCurrRewardTimes()
    local totalTimes = self._interactor:getTotalRewardTimes()

    self._actionUI:setTextCountStr(tostring(currTimes) .. "/" .. tostring(totalTimes))
    self._actionUI:setLoadingBarPercent((currTimes/totalTimes) * 100)

    self:__initRewardPanel()

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

function JiangHuZhenPinGePresenters:__showExchangeUI()
    self.__currExchangeIndex = 1

    self._exchangeUI:setActionTitle(self._interactor:getActionName())

    self._exchangeUI:setActionDesc(self._interactor:getActionDesc())

    self._exchangeUI:setImageVisible(false)

    local reward = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)

    self:__refreshExchangeUI()

    local uiInfo = {
        icon = reward.icon,
        name = reward.name,
        title = reward.title,
        introText = reward.introText,
        viewText = reward.showView
    }

    uiInfo.func = function()
        if reward.showView then
            self:__showGoodsInfoUI({{id = reward.goodsId}})
        end
    end


    self._exchangeUI:initNowPanelInfo(uiInfo)

    self:__updateExchangeUI(reward)

    self._exchangeUI:showUI()
end

--@desc 根据当前的兑换处理兑换界面刷新UI
function JiangHuZhenPinGePresenters:__updateExchangeUI(reward)
    self._exchangeUI:setNeedDescAndNum("需要" .. self._interactor:getExchangeCurrencyName(), reward.need)
    self._exchangeUI:setNeedNumTextVisible(true)
    self._exchangeUI:setViewTipTextVisible(reward.showView)
    self._exchangeUI:setExchangeCount(reward.exchangeCount)
    self._exchangeUI:setExchangeBtn(
        "兑换",
        function()
            self:exchangeReward()
        end
    )
end

function JiangHuZhenPinGePresenters:__initRewardPanel()
    local list = self._interactor:getShowRewards()

    for i = 1, #list do
        local goods = GoodsHelper:getGoodsResClass(list[i].id)

        local uiList = {
            name = goods:getName(),
            icon = goods:getIcon(),
            number = list[i].num
        }

        uiList.func = function()
            self:__showGoodsInfoUI({{id = list[i].id}})
        end

        self._actionUI:initPanel(i, uiList)
    end
end

function JiangHuZhenPinGePresenters:__initButton(btnInfo)
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
                            self:__refreshActionUI()
                        end
                    end
                )
            end
        )
    end
end

function JiangHuZhenPinGePresenters:hideLayer()
    PopupLayerController:hideLayer(
        "JiangHuZhenPinGePresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function JiangHuZhenPinGePresenters:nextExchangeReward()
    local maxIndex = #self._interactor:getExchageRewardList()

    local nextIndex = self.__currExchangeIndex + 1

    if nextIndex > maxIndex then
        nextIndex = 1
    end

    self.__currExchangeIndex = nextIndex

    local exchangeRewardInfo = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)

    local uiInfo = {
        icon = exchangeRewardInfo.icon,
        name = exchangeRewardInfo.name,
        title = exchangeRewardInfo.title,
        introText = exchangeRewardInfo.introText,
        viewText = exchangeRewardInfo.showView
    }

    uiInfo.func = function()
        if exchangeRewardInfo.showView then
            self:__showGoodsInfoUI({{id = exchangeRewardInfo.goodsId}})
        end
    end

    self._exchangeUI:initNextPanelInfo(uiInfo)

    self:__updateExchangeUI(exchangeRewardInfo)
end

function JiangHuZhenPinGePresenters:prevExchangeReward()
    local maxIndex = #self._interactor:getExchageRewardList()

    local preIndex = self.__currExchangeIndex - 1

    if preIndex <= 0 then
        preIndex = maxIndex
    end

    self.__currExchangeIndex = preIndex

    local exchangeRewardInfo = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)

    local uiInfo = {
        icon = exchangeRewardInfo.icon,
        name = exchangeRewardInfo.name,
        title = exchangeRewardInfo.title,
        introText = exchangeRewardInfo.introText,
        viewText = exchangeRewardInfo.showView
    }

    uiInfo.func = function()
        if exchangeRewardInfo.showView then
            self:__showGoodsInfoUI({{id = exchangeRewardInfo.goodsId}})
        end
    end

    self._exchangeUI:initNextPanelInfo(uiInfo)

    self:__updateExchangeUI(exchangeRewardInfo)
end

function JiangHuZhenPinGePresenters:exchangeReward()
    local endTime = self._interactor:getActionEndTime()
    
    if endTime and endTime < GetTime() then
        PopText("活动已结束，无法兑换")
        return
    end

    local exchangeRewardInfo = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)
    if exchangeRewardInfo.exchangeCount <= 0 then
        PopText("已达兑换上限，兑换失败")
        return
    end

    local isTrue, searchInfo = self._interactor:checkCanBuy({{id = exchangeRewardInfo.goodsId, num = 1}})

    if isTrue == false then
        local msg = ""

        if searchInfo.searchType == "101" then
            msg = "已学习对应武学，无需再次兑换！"
        elseif searchInfo.searchType == "301" then
            msg = "您该主动技能即将/已经达到熟练度上限，无需兑换！"
        elseif searchInfo.searchType == "201" or searchInfo.searchType == "401" or searchInfo.searchType == "501" or searchInfo.searchType == "701" then
            msg = "已达到商品可持有数量的限制，不可兑换！"
        elseif searchInfo.searchType == "1001" or searchInfo.searchType == "1002" then
            msg = "不满足兑换条件，无法兑换!"
        elseif searchInfo.searchType == "701" then
            msg = "您的等级不符合该礼包道具的最低使用要求，目前不能兑换！"
        end

        PopText(msg)
        return
    end

    local function confirmExchange(reward, num)
        local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
        local dialog = DialogALayer:getInstance()
        dialog:hide()
        local str = "是否要花费YEL" .. tostring(reward.need * num) .. "NOR张" .. self._interactor:getExchangeCurrencyName() .. "兑换" .. tostring(Helper:getDef(reward.title,"")) .. "" .. tostring(reward.name) .. "X"..tostring(num * reward.number).."？"
        dialog:show(str)
        dialog:setRichText(str)
        dialog:setBack(false)
        dialog:setButton2("取消", EMPTY_FUNC)
        dialog:setButton1(
            "确定",
            function()
                self._interactor:exchangeItem(reward, num, function(rewardInfo)
                    PopupLayerController:showLayer(
                            "TextAnimLayer",
                            function(layer)
                                layer:setAfterAnimCallback(
                                    function()
                                        PopText("消耗".. self._interactor:getExchangeCurrencyName() .." x " .. rewardInfo.need)

                                        if rewardInfo.name then
                                            PopText("获得 " .. rewardInfo.name .. " x " .. rewardInfo.number)
                                        end
                                    end
                                )
                                layer:showLayer(rewardInfo.thankText)
                            end
                        )

                    self:__refreshActionUI()
                    self:__refreshExchangeUI()
                end)
            end
        )
    end

     if exchangeRewardInfo.exchangeCount <= 1 then
        if self._interactor:checkCanGetReward({{id = exchangeRewardInfo.goodsId, num = 1}}) == false then
            PopText("背包容量达到上限，无法将物品放入背包")
            return false
        end

        confirmExchange(exchangeRewardInfo, 1)
    else
        PopupLayerController:showLayer("JiangHuZhenPinGeSelectPresenter",function(layer)
            layer:setTitle("请确定兑换")
            layer:setTextDesc_1("    "..exchangeRewardInfo.introText)
            layer:setTextDesc_2("兑换可获得")
            layer:setTextDesc_3(exchangeRewardInfo.name,1 * exchangeRewardInfo.number)
            layer:setText_1Str("将花费：")
            layer:setPriceName(self._interactor:getExchangeCurrencyName())
            layer:setText_2Str(tostring(exchangeRewardInfo.need)..self._interactor:getExchangeCurrencyName())
            layer:setItemName(exchangeRewardInfo.name)

            layer:setUnitPrice(exchangeRewardInfo.need)

            layer:setBuyNumber(1)

            layer:setUnitGetNumber(exchangeRewardInfo.number)

            layer:setMaxBuyNumber(exchangeRewardInfo.exchangeCount)

            layer:setSelectText("1/"..tostring(exchangeRewardInfo.exchangeCount))

            layer:showLayer()

            layer:setButton_1Func(function(exchangeNum)
                if not exchangeNum then
                    exchangeNum = 1
                end

                if self._interactor:checkCanGetReward({{id = exchangeRewardInfo.goodsId, num = exchangeNum}}) == false then
                    PopText("背包容量达到上限，无法将物品放入背包")
                    return false
                end

                if exchangeNum > exchangeRewardInfo.exchangeCount then
                    PopText("当前兑换次数已超上限！")
                    return false
                end

                if self._interactor:getExchangeCurrencyCount() < exchangeRewardInfo.need * exchangeNum then
                    PopText("珍品劵不足")
                    return false
                end

                confirmExchange(exchangeRewardInfo, exchangeNum)
            end)
            layer:setButton_2Func(function()
                layer:hideLayer()
            end)
        end)
    end

end

function JiangHuZhenPinGePresenters:__refreshActionUI()
    local str_1 = "当前拥有" .. self._interactor:getCurrencyCount() .. "份" .. self._interactor:getCurrecnyName()
    local str_2 = "当前拥有" .. self._interactor:getExchangeCurrencyCount() .. "张" .. self._interactor:getExchangeCurrencyName()
    self._actionUI:setTextCurrency(str_1)
    self._actionUI:setTextExchangeCurrency(str_2)

    local currTimes = self._interactor:getCurrRewardTimes()
    local totalTimes = self._interactor:getTotalRewardTimes()

    self._actionUI:setTextCountStr(tostring(currTimes) .. "/" .. tostring(totalTimes))
    self._actionUI:setLoadingBarPercent((currTimes/totalTimes) * 100)
end

function JiangHuZhenPinGePresenters:__refreshExchangeUI()
    self._exchangeUI:setCurrentDescAndNum("当前拥有" .. self._interactor:getExchangeCurrencyName(), self._interactor:getExchangeCurrencyCount())
    self._exchangeUI:setExchangeCount(self._interactor:getExchangeRewardInfo(self.__currExchangeIndex).exchangeCount)
end

function JiangHuZhenPinGePresenters:initRule(ruleInfo)
	self.__ruleInfo = ruleInfo
end

function JiangHuZhenPinGePresenters:__setRuleFunc()
	self._actionUI:setButtonRuleFunc(function()
        self:__showRule()
    end)
end

function JiangHuZhenPinGePresenters:__showRule()
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

function JiangHuZhenPinGePresenters:__showGoodsInfoUI(goodsList)
    PopupLayerController:showLayer("GoodsInfoMainPresenter",function(layer)
        layer:showLayer(goodsList)
    end)
end

Helper:classDefNodeGetInstance(JiangHuZhenPinGePresenters)

return JiangHuZhenPinGePresenters
00000000000000