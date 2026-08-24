local FistFootShopBuyDayConfirmPresenter = class("FistFootShopBuyDayConfirmPresenter", cc.Layer)

local GoodsHelper = require("app.models.Store.GoodsHelper")

function FistFootShopBuyDayConfirmPresenter:create()
    local p = FistFootShopBuyDayConfirmPresenter:new()
    p:init()
    return p
end

function FistFootShopBuyDayConfirmPresenter:init()
    self.__ui = require("app.views.ui.ActionUI.FistFoot.FistFootShopBuyConfirmUI"):create()

    self.__ui:addTo(self)
end

function FistFootShopBuyDayConfirmPresenter:showLayer()
    self:setButtonConfirm()

    self:setButtonCancel()

    self.__ui:showUI()
end

function FistFootShopBuyDayConfirmPresenter:setDayId(dayId)
    self.__dayId = dayId
end

function FistFootShopBuyDayConfirmPresenter:setInteractor(interactor)
    self.__interactor = interactor
end

function FistFootShopBuyDayConfirmPresenter:setCallBack(callBack)
    self.__callBack = callBack
end

function FistFootShopBuyDayConfirmPresenter:setText1(text)
    self.__ui:setText1(text)
end

function FistFootShopBuyDayConfirmPresenter:setText2(text)
    self.__ui:setText2(text)
end

function FistFootShopBuyDayConfirmPresenter:setText3(text)
    self.__ui:setText3(text)
end

function FistFootShopBuyDayConfirmPresenter:setTextTip1(text)
    self.__ui:setTextTip1(text)
end

function FistFootShopBuyDayConfirmPresenter:setTextTip2(text)
    self.__ui:setTextTip2(text)
end

function FistFootShopBuyDayConfirmPresenter:setTextTip3(text)
    self.__ui:setTextTip3(text)
end

function FistFootShopBuyDayConfirmPresenter:setButtonConfirm()
    self.__ui:setButtonConfirm(function()
        self.__interactor:buyFistFootShopDailyGoods(
            self.__dayId,
            function(rewards)
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
            end
        )

        self:hideLayer()
    end)
end

function FistFootShopBuyDayConfirmPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function FistFootShopBuyDayConfirmPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FistFootShopBuyDayConfirmPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(FistFootShopBuyDayConfirmPresenter)

return FistFootShopBuyDayConfirmPresenter
0