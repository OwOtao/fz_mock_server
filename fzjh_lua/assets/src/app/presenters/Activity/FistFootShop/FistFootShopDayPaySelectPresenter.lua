local FistFootShopDayPaySelectPresenter = class("FistFootShopDayPaySelectPresenter", cc.Layer)

function FistFootShopDayPaySelectPresenter:create()
    local p = FistFootShopDayPaySelectPresenter:new()
    p:init()
    return p
end

function FistFootShopDayPaySelectPresenter:init()
    self.__ui = require("app.views.ui.ActionUI.FistFoot.FistFootShopPaySelectUI"):create()

    self.__ui:addTo(self)
end

function FistFootShopDayPaySelectPresenter:showLayer()
    self.__daySelectCost = self.__interactor:getDaySelectCost()

    if self.__daySelectCost == 0 then
        self.__daySelectCost = self.__interactor:getDailyDefaultCost()
    end

    self.__ui:setTextTitle("请确定选择数量")

    self.__ui:setTextMinLimit("元宝支付范围下限:"..tostring(self.__interactor:getDayCostMinLimit()))

    self.__ui:setTextMaxLimit("元宝支付范围上限:"..tostring(self.__interactor:getDayCostMaxLimit()))

    self.__ui:setTextTitle2("当前选择")

    self:setTextCurrSelectCost()

    self:setTextSpecialOfferCostLimit()

    self.__ui:setText3("")
    
    self.__ui:setText4("")
    
    self:setTextTip()

    self:setButton1()

    self:setButton2()

    self:setButton3()

    self:setButton4()

    self:setButtonConfirm()

    self:setButtonCancel()

    self.__ui:showUI()
end

function FistFootShopDayPaySelectPresenter:setInteractor(interactor)
    self.__interactor = interactor
end

function FistFootShopDayPaySelectPresenter:setCallBack(callBack)
    self.__callBack = callBack
end

function FistFootShopDayPaySelectPresenter:setTextCurrSelectCost()
    self.__ui:setText1("每日支付元宝:"..tostring(self.__daySelectCost))
end

function FistFootShopDayPaySelectPresenter:setTextSpecialOfferCostLimit()
    self.__ui:setText2("特惠购买支付上限:"..tostring(self.__daySelectCost * self.__interactor:getDayCostMultiple()))
end

function FistFootShopDayPaySelectPresenter:setTextTip()
    local text1 = "提示：该特惠购买支付上限为"..tostring(self.__daySelectCost * self.__interactor:getDayCostMultiple())..",在最高特惠基数"..self.__interactor:getLastDayDiscount().."%的情况下，支付该元宝数可获得"

    local rewards = self.__interactor:getSpecialOfferRewards()
    
    local text2 = ""

    for i,rewardData in ipairs(rewards) do
        local rewardId = rewardData[1]

        local rewardQuota = rewardData[2]/100

        local name = self.__interactor:getItemName(rewardId)

        local discountRate = self.__interactor:getLastDayDiscount()/100

        local num = self.__interactor:ceilSpecialOfferItemNum(rewardId,discountRate,self.__daySelectCost * self.__interactor:getDayCostMultiple(),rewardQuota)

        if i == 1 then
            text2 = name..":"..num
        else
            text2 = text2..";"..name..":"..num
        end
    end

    self.__ui:setTextTip(text1..text2)
end

function FistFootShopDayPaySelectPresenter:setButton1()
    self.__ui:setButton1(function()
        if self.__daySelectCost < self.__interactor:getDayCostMaxLimit() then
            self.__daySelectCost = math.min(self.__daySelectCost + 500,self.__interactor:getDayCostMaxLimit())

            self:setTextCurrSelectCost()

            self:setTextSpecialOfferCostLimit()

            self:setTextTip()
        end
    end)
end

function FistFootShopDayPaySelectPresenter:setButton2()
    self.__ui:setButton2(function()
        if self.__daySelectCost < self.__interactor:getDayCostMaxLimit() then
            self.__daySelectCost = math.min(self.__daySelectCost + 100,self.__interactor:getDayCostMaxLimit())

            self:setTextCurrSelectCost()

            self:setTextSpecialOfferCostLimit()

            self:setTextTip()
        end
    end)
end

function FistFootShopDayPaySelectPresenter:setButton3()
    self.__ui:setButton3(function()
        if self.__daySelectCost > self.__interactor:getDayCostMinLimit() then
            self.__daySelectCost = math.max(self.__daySelectCost - 100,self.__interactor:getDayCostMinLimit())

            self:setTextCurrSelectCost()

            self:setTextSpecialOfferCostLimit()

            self:setTextTip()
        end
    end)
end

function FistFootShopDayPaySelectPresenter:setButton4()
    self.__ui:setButton4(function()
        if self.__daySelectCost > self.__interactor:getDayCostMinLimit() then
            self.__daySelectCost = math.max(self.__daySelectCost - 500,self.__interactor:getDayCostMinLimit())

            self:setTextCurrSelectCost()

            self:setTextSpecialOfferCostLimit()

            self:setTextTip()
        end
    end)
end

function FistFootShopDayPaySelectPresenter:setButtonConfirm()
    self.__ui:setButtonConfirm(function()
        self.__interactor:setFistFootShopDailyCost(self.__daySelectCost,function()
            if self.__callBack then
                self.__callBack()
            end
            self:hideLayer()
        end)
    end)
end

function FistFootShopDayPaySelectPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function FistFootShopDayPaySelectPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FistFootShopDayPaySelectPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end


Helper:classDefNodeGetInstance(FistFootShopDayPaySelectPresenter)

return FistFootShopDayPaySelectPresenter
000000000