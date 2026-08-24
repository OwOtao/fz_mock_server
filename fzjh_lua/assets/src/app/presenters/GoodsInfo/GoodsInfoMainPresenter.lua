--[[
Descripttion: 
version: 
Author: LvBin
Date: 2024-09-02 16:06:22
--]]
local GoodsInfoMainPresenter = class("GoodsInfoMainPresenter", cc.Layer)

local GoodsHelper = require("app.models.Store.GoodsHelper")

local Goods = require("app.models.Store.Goods")

local GoodsPresenterFactory = require("app.presenters.GoodsInfo.GoodsPresenterFactory")

local VIEWTYPE = Goods.Const.VIEWTYPE

function GoodsInfoMainPresenter:create()
    local p = GoodsInfoMainPresenter:new()
    p:init()
    return p
end

function GoodsInfoMainPresenter:init()
    self.__ui = require("app.views.ui.GoodsInfoUI.GoodsInfoMainUI"):create()

    self.__ui:addTo(self)

    self.__ui:setButtonBack(
        function()
            self:hideLayer()
        end
    )
end

function GoodsInfoMainPresenter:showLayer(goodsList)
    self.__goodsList = goodsList

    self.__ui:clearPage()

    if #self.__goodsList > 1 then
        self.__ui:showSelectUI()

        self:setButtonLeft()

        self:setButtonRight()
    else
        self.__ui:hideSelectUI()
    end

    self:__initGoodsInfoPages()

    self.__ui:showUI()
end

function GoodsInfoMainPresenter:__initGoodsInfoPages()
    for i = 1,#self.__goodsList do
        local goodsId = self.__goodsList[i].id

        local goods = GoodsHelper:getGoodsResClass(goodsId)

        local goodsPresenter = GoodsPresenterFactory:createGoodsPrensenter(goods)

        local layout = ccui.Layout:create()
        layout:addChild(goodsPresenter:getUI())
        self.__ui:addPage(layout)

        if goods:getViewType() == VIEWTYPE.BOX then
            goodsPresenter:setParentUIPrensent(self)
        end
        goodsPresenter:setButtonBackVisible(false)
        goodsPresenter:showUI()
    end

    self.__ui:scrollToPage(0)
end

function GoodsInfoMainPresenter:setButtonLeft()
    self.__ui:setButtonLeft(function()
        if self.__ui:getCurrentPageIndex() > 0 then
            self.__ui:scrollToPage(self.__ui:getCurrentPageIndex() - 1)
        end
    end)
end

function GoodsInfoMainPresenter:setButtonRight()
    self.__ui:setButtonRight(function()
        if self.__ui:getCurrentPageIndex() < #self.__goodsList - 1 then
            self.__ui:scrollToPage(self.__ui:getCurrentPageIndex() + 1)
        end
    end)
end

function GoodsInfoMainPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function GoodsInfoMainPresenter:hideLayer()
    PopupLayerController:hideLayer("GoodsInfoMainPresenter",function(layer)
        self.__ui:hideUI()
    end)
end

Helper:classDefNodeGetInstance(GoodsInfoMainPresenter)

return GoodsInfoMainPresenter
00000000