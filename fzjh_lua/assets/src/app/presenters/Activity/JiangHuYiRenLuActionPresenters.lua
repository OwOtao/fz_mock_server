local JiangHuYiRenLuActionPresenters = class("JiangHuYiRenLuActionPresenters", cc.Layer)

function JiangHuYiRenLuActionPresenters:create()
    local p = JiangHuYiRenLuActionPresenters:new()
    p:init()
    return p
end

function JiangHuYiRenLuActionPresenters:init()
    --@RefType[JiangHuYiRenLuAction2UI]
    self._actionUI = require("app.views.ui.ActionUI.JiangHuYiRenLuAction2UI"):create()

    self._actionUI:addTo(self)

    --@RefType[JiangHuYiRenLuExchangeUI]
    self._exchangeUI = require("app.views.ui.ActionUI.JiangHuYiRenLuExchangeUI"):create()

    self._exchangeUI:addTo(self)

    self._exchangeUI:setPresenters(self)

    local JiangHuYiRenLuAction = require("app.models.Action.JiangHuYiRenLuAction")

    self._actionUI:setPanelBack(
        function()
            self:hideLayer()
        end
    )

    --@RefType[src.app.models.Action.JiangHuYiRenLuAction#JiangHuYiRenLuAction]
    self._interactor = JiangHuYiRenLuAction:create()
end

function JiangHuYiRenLuActionPresenters:showLayer()
    self._role = User:getRole()

    self._interactor:setRole(self._role)
    self._interactor:init(
        function()
            self._actionUI:setTextTitle(self._interactor:getActionName())

            self._actionUI:setDesc(self._interactor:getActionDesc())

            self._actionUI:setTextCurrency("当前拥有" .. self._interactor:getCurrYuanBaoNum() .. "元宝")
            
            self._actionUI:setTextExchangeCurrency("当前拥有" .. self._interactor:getCurrBaiFangMingTie() .. "张名帖")

            self:__initRewardPanel(self._interactor:getShowRewards())

            self:__initButton(self._interactor:getButtonInfo())

            self._actionUI:setButtonClickFunc3(
                "前往兑换",
                function()
                    self:__showExchangeUI()
                end
            )

            self._actionUI:setTextRewardClickFunc(
                function()
                    self._actionUI:showAllRewardsDialog(self._interactor:getAllRewards())
                end
            )

            self._actionUI:showUI()
        end
    )
end

function JiangHuYiRenLuActionPresenters:__showExchangeUI()
    self.__currExchangeIndex = 1

    self._exchangeUI:setActionTitle(self._interactor:getActionName())

    self._exchangeUI:setActionDesc(self._interactor:getActionDesc())

    self._exchangeUI:setImageUrl("Image/UI/JiangHuYiRenLuUI/minrendangan.png")

    local reward = self._interactor:getExchangeRewardInfo(self.__currExchangeIndex)

    self:__refreshExchangeUI()

    self._exchangeUI:initNowPanelInfo(reward)

    self:__updateExchangeUI(reward)

    self._exchangeUI:showUI()
end

--@desc 根据当前的兑换处理兑换界面刷新UI
function JiangHuYiRenLuActionPresenters:__updateExchangeUI(reward)
    if reward.rewardType == 1 then
        self._exchangeUI:setNeedNum(reward.need)
        self._exchangeUI:setNeedNumTextVisible(true)
        self._exchangeUI:setExchangeBtn(
            "拜会",
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

function JiangHuYiRenLuActionPresenters:__initRewardPanel(list)
    for i = 1, #list do
        local itemInfo = list[i]
        self._actionUI["initPanel" .. i](self._actionUI, itemInfo)
    end
end

function JiangHuYiRenLuActionPresenters:__initButton(btnInfo)
    for i = 1, 2 do
        local info = btnInfo[i]

        self._actionUI["setPanelCostText" .. i](self._actionUI, info.removeYb)

        self._actionUI["setButtonClickFunc" .. i](
            self._actionUI,
            info.name,
            function()
                self._interactor:doLottery(
                    i,
                    function(data)
                        local rewards = data.prize

                        if MapIsEmpty(rewards) == false then
                            for i = 1, #rewards do
                                local reward = rewards[i]

                                PopText("您获得了 " .. reward.name .. " X" .. reward.number)
                            end
                        end
                        self:__refreshActionUI()
                    end
                )
            end
        )
    end
end

function JiangHuYiRenLuActionPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "JiangHuYiRenLuActionPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

function JiangHuYiRenLuActionPresenters:nextExchangeReward()
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

function JiangHuYiRenLuActionPresenters:prevExchangeReward()
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

function JiangHuYiRenLuActionPresenters:exchangeReward()
    return self._interactor:exchangeReward(
        self.__currExchangeIndex,
        function(rewardType, reward)
            if rewardType == 1 then
                PopupLayerController:showLayer(
                    "TextAnimLayer",
                    function(layer)
                        layer:setAfterAnimCallback(
                            function()
                                PopText("消耗名帖 x " .. reward.need)
                                PopText("获得 " .. self._role:getOneItemByKey(reward.mianju).name .. " x " .. 1)
                            end
                        )
                        layer:showLayer(reward.thankText)
                    end
                )
            else
                PopText("消耗名帖 x " .. reward.removebfmt)
                PopText("获得饰品材料 x " .. reward.addspcl)
            end

            self:__refreshActionUI()
            self:__refreshExchangeUI()
        end
    )
end

function JiangHuYiRenLuActionPresenters:__refreshActionUI()
    local str_1 = "当前拥有" .. self._interactor:getCurrYuanBaoNum() .. "元宝"
    local str_2 = "当前拥有" .. self._interactor:getCurrBaiFangMingTie() .. "张名帖"
    self._actionUI:setTextCurrency(str_1)
    self._actionUI:setTextExchangeCurrency(str_2)
end

function JiangHuYiRenLuActionPresenters:__refreshExchangeUI()
    self._exchangeUI:setCurrentNum(self._interactor:getCurrBaiFangMingTie())
end

Helper:classDefNodeGetInstance(JiangHuYiRenLuActionPresenters)

return JiangHuYiRenLuActionPresenters
00000000000000