local FistFootShopBuySpecialOfferConfirmPresenter = class("FistFootShopBuySpecialOfferConfirmPresenter", cc.Layer)

local GoodsHelper = require("app.models.Store.GoodsHelper")

function FistFootShopBuySpecialOfferConfirmPresenter:create()
    local p = FistFootShopBuySpecialOfferConfirmPresenter:new()
    p:init()
    return p
end

function FistFootShopBuySpecialOfferConfirmPresenter:init()
    self.__ui = require("app.views.ui.ActionUI.FistFoot.FistFootShopBuyConfirmUI"):create()

    self.__ui:addTo(self)
end

function FistFootShopBuySpecialOfferConfirmPresenter:showLayer()
    self.__ui:setTextTip1("")
    
    self.__ui:setTextTip2("")

    self.__ui:setTextTip3("")
    
    self:setButtonCancel()

    self.__ui:showUI()
end

function FistFootShopBuySpecialOfferConfirmPresenter:setText1(text)
    self.__ui:setText1(text)
end

function FistFootShopBuySpecialOfferConfirmPresenter:setText2(text)
    self.__ui:setText2(text)
end

function FistFootShopBuySpecialOfferConfirmPresenter:setText3(text)
    self.__ui:setText3(text)
end

function FistFootShopBuySpecialOfferConfirmPresenter:setButtonConfirm(callback)
    self.__ui:setButtonConfirm(function()
        if callback then
            callback()
        end

        self:hideLayer()
    end)
end

function FistFootShopBuySpecialOfferConfirmPresenter:setButtonCancel()
    self.__ui:setButtonCancel(function()
        self:hideLayer()
    end)
end

function FistFootShopBuySpecialOfferConfirmPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "FistFootShopBuySpecialOfferConfirmPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(FistFootShopBuySpecialOfferConfirmPresenter)

return FistFootShopBuySpecialOfferConfirmPresenter
0000000