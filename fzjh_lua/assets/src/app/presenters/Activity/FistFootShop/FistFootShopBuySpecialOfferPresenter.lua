local FistFootShopBuySpecialOfferPresenter = class("FistFootShopBuySpecialOfferPresenter", cc.Layer)

local GoodsHelper = require("app.models.Store.GoodsHelper")

function FistFootShopBuySpecialOfferPresenter:create()
    local p = FistFootShopBuySpecialOfferPresenter:new()
    p:init()
    return p
end

function FistFootShopBuySpecialOfferPresenter:init()
    self.__ui = require("app.views.ui.ActionUI.FistFoot.FistFootShopPaySelectUI"):create()

    self.__ui:addTo(self)
end

function FistFootShopBuySpecialOfferPresenter:showLayer()
    self.__daySelectCost = self.__interactor:getDaySelectCost()

    self.__specialOfferCostMaxLimit = self.__daySelectCost * self.__interactor:getDayCostMultiple()

    self.__currSelectSpecialOfferCost = self.__specialOfferCostMaxLimit

    self.__ui:setTextTitle("请确定选择数量")

    self.__ui:setTextMinLimit("元宝支付范围下限:"..tostring(self.__interactor:getDayCostMinLimit()))

    self.__ui:setTextMaxLimit("元宝支付范围上限:"..tostring(self.__specialOfferCostMaxLimit))

    self.__ui:setTextTitle2("当前使用")

    self.__ui:setText1(self.__interactor:getDiscountRate().."%特惠基数")

    self:setTextCurrSelectSpecialOfferCost()

    self:setTextSpecialOfferReward()
    
    self.__ui:setTextTip("")

    self:setButton1()

    self:setButton2()

    self:setButton3()

    self:setButton4()

    self:setButtonConfirm()

    self:setButtonCancel()

    self.__ui:showUI()
end

function FistFootShopBuySpecialOfferPresenter:setInteractor(interactor)
    self.__interactor = interactor
end

function FistFootShopBuySpecialOfferPresenter:setCallBack(callBack)
    self.__callBack = callBack
end

function FistFootShopBuySpecialOfferPresenter:setTextCurrSelectSpecialOfferCost()
    self.__ui:setText2("支付元宝:"..tostring(self.__currSelectSpecialOfferCost))
end

function FistFootShopBuySpecialOfferPresenter:setTextSpecialOfferReward()
    local rewardText1 = self:getTextSpecialOfferReward(1)

    local rewardText2 = self:getTextSpecialOfferReward(2)
    
    self.__ui:setText3(rewardText1)
    
    self.__ui:setText4(rewardText2)
end

function FistFootShopBuySpecialOfferPresenter:setButton1()
    self.__ui:setButton1(function()
        if self.__currSelectSpecialOfferCost < self.__specialOfferCostMaxLimit then
            self.__currSelectSpecialOfferCost = math.min(self.__currSelectSpecialOfferCost + 500,self.__specialOfferCostMaxLimit)
            
            self:setTextCurrSelectSpecialOfferCost()

            self:setTextSpecialOfferReward()
        end
    end)
end

function FistFootShopBuySpecialOfferPresenter:setButton2()
    self.__ui:setButton2(function()
        if self.__currSelectSpecialOfferCost < self.__specialOfferCostMaxLimit then
            self.__currSelectSpecialOfferCost = math.min(self.__currSelectSpecialOfferCost + 100,self.__specialOfferCostMaxLimit)

            self:setTextCurrSelectSpecialOfferCost()

            self:setTextSpecialOfferReward()
        end
    end)
end

function FistFootShopBuySpecialOfferPresenter:setButton3()
    self.__ui:setButton3(function()
        if self.__currSelectSpecialOfferCost > self.__interactor:getDayCostMinLimit() then
            self.__currSelectSpecialOfferCost = math.max(self.__currSelectSpecialOfferCost - 100,self.__interactor:getDayCostMinLimit())

            self:setTextCurrSelectSpecialOfferCost()

            self:setTextSpecialOfferReward()
        end
    end)
end

function FistFootShopBuySpecialOfferPresenter:setButton4()
    self.__ui:setButton4(function()
        if self.__currSelectSpecialOfferCost > self.__interactor:getDayCostMinLimit() then
            self.__currSelectSpecialOfferCost = math.max(self.__currSelectSpecialOfferCost - 500,self.__interactor:getDayCostMinLimit())

            self:setTextCurrSelectSpecialOfferCost()

            self:setTextSpecialOfferReward()
        end
    end)
end

function FistFootShopBuySpecialOfferPresenter:setButtonConfirm()
    self.__ui:setButtonConfirm(function()
        PopupLayerController:showLayer("FistFootShopBuySpecialOfferConfirmPresenter",function(layer)
            local rewardText1 = self:getTextSpecialOfferReward(1)

            local rewardText2 = self:getTextSpecialOfferReward(2)

            layer:setText1("是否确认以"..self.__interactor:getDiscountRate().."%特惠基数支付"..self.__currSelectSpecialOfferCost.."元宝？")
            
            layer:setText2(rewardText1)

            layer:setText3(rewardText2)

            layer:setButtonConfirm(function()
                self.__interactor:buyFistFootShopSpecialOffer(self.__currSelectSpecialOfferCost,function(rewards)
                    if self.__callBack then
                        self.__callBack()
                    end
                    
                    for i,rewardData in ipairs(rewards) do
                        local goodsId = rewardData.goodsId
                
                        local goods = GoodsHelper:getGoodsResClass(goodsId)
        
                        local name = goods:getName()
        
                        local num = rewardData.number
        
                        PopText("获得"..name.."*"..num)
                    end
        
                    self:hideLayer()
                end)
            end)
            layer:showLayer()
        end)
    end)
end

function FistFootShopBuySpecialOfferPresenter:getTextSpecialOfferReward(itemIndex)
    local rewards = self.__interactor:getSpecialOfferRewards()

    local rewardId = rewards[itemIndex][1]

    local rewardQuota = rewards[itemIndex][2]/100

    local name = self.__interactor:getItemName(rewardId)

    local discountRate = self.__interactor:getDiscountRate()/100

    local num = self.__interactor:ceilSpecialOfferItemNum(rewardId,discountRate,self.__currSelectSpecialOfferCost,rewardQuota)

    return "可获得"..name..":"..num
end

function FistFootShopBuySpecialOfferPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function FistFootShopBuySpecialOfferPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FistFootShopBuySpecialOfferPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(FistFootShopBuySpecialOfferPresenter)

return FistFootShopBuySpecialOfferPresenter
0000