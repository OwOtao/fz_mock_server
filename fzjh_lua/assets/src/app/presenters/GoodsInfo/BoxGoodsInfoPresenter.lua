local NewClass = require("third.class.NewClass")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local GoodsPresenterFactory = require("app.presenters.GoodsInfo.GoodsPresenterFactory")
local Goods = require("app.models.Store.Goods")
local IGoodsPresenter = require("app.presenters.GoodsInfo.IGoodsPresenter")

local VIEWTYPE = Goods.Const.VIEWTYPE
local MAXLAYER = 2

local BoxGoodsInfoPresenter = {}

function BoxGoodsInfoPresenter:create(goods)
    local o = BoxGoodsInfoPresenter.new()
    o:init(goods)
    return o
end

function BoxGoodsInfoPresenter:init(goods)
    self.__ui = require("app.views.ui.GoodsInfoUI.BoxGoodsInfoUI"):create()
    self.__goods = goods
end

function BoxGoodsInfoPresenter:getUI()
    return self.__ui
end

function BoxGoodsInfoPresenter:setParentUIPrensent(p)
    self.__parentUIPrensent = p
end

function BoxGoodsInfoPresenter:setGoods(goods)
	self.__goods = goods
end

function BoxGoodsInfoPresenter:setShowBoxLayerNum(num)
    self.__showBoxLayerNum = num
end

function BoxGoodsInfoPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function BoxGoodsInfoPresenter:setButtonBack(func)
    self.__ui:setButtonBack(function()
        if func then
            func()
        end
    end)
end

function BoxGoodsInfoPresenter:showUI()
    self.__ui:setTitle("宝箱信息")

	self:__setName()
	self:__setDsc()
	self:__setList()

    self.__ui:showUI()
    self.__ui:setGoodsUIVisible(false)
end

function BoxGoodsInfoPresenter:hide()
    self.__ui:hideUI()
end

function BoxGoodsInfoPresenter:__setName()
    self.__ui:setTextName(self.__goods:getName())
end

function BoxGoodsInfoPresenter:__setDsc()
    self.__ui:setTextDesc(self.__goods:getDsc())
end

function BoxGoodsInfoPresenter:__setList()
	local goodsList = self.__goods:getViewInfo()

	local listInfo = {}
	for i = 1, #goodsList, 1 do
        local goods = GoodsHelper:getGoodsResClass(goodsList[i])
		local info = {
			name = goods:getName(),
			func = function()
                if goods:getViewType() == VIEWTYPE.BOX then
                    if not self.__showBoxLayerNum then
                        self.__showBoxLayerNum = 1
                    end
                
                    if self.__showBoxLayerNum >= MAXLAYER then
                        PopText("该道具已无法预览")
                        return
                    end
                end

                self.__ui:setGoodsUIVisible(true)

                if self.__parentUIPrensent then
                    self.__parentUIPrensent:setButtonBackVisible(false)
                end

				local goodsPresenter = GoodsPresenterFactory:createGoodsPrensenter(goods)
                goodsPresenter:setButtonBackVisible(true)
                goodsPresenter:setButtonBack(function()
                    self:__setGoodsUIBack()
                end)

                if goods:getViewType() == VIEWTYPE.BOX then
                    goodsPresenter:setShowBoxLayerNum(self.__showBoxLayerNum + 1)
                end

                self.__ui:addGoodsUI(goodsPresenter:getUI())

                goodsPresenter:showUI()
            end
		}

        table.insert(listInfo, info)
	end

    self.__ui:setGoodsList(listInfo)
end

function BoxGoodsInfoPresenter:__setGoodsUIBack()
    self.__ui:removeGoodsUI()
    self.__ui:setGoodsUIVisible(false)
    if self.__parentUIPrensent then
        self.__parentUIPrensent:setButtonBackVisible(true)
    end
end

return NewClass("BoxGoodsInfoPresenter", {IGoodsPresenter}, BoxGoodsInfoPresenter)000000000