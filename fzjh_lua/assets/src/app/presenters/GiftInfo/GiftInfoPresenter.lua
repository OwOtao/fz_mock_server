local GiftInfoPresenter = class("GoodsInfoMainPresenter", cc.Layer)
local GoodsHelper = require("app.models.Store.GoodsHelper")
local GoodsPresenterFactory = require("app.presenters.GoodsInfo.GoodsPresenterFactory")
local Goods = require("app.models.Store.Goods")

local VIEWTYPE = Goods.Const.VIEWTYPE
local MAXLAYER = 2


function GiftInfoPresenter:create()
    local p = GiftInfoPresenter:new()
    p:init()
    return p
end

function GiftInfoPresenter:init()
    self.__ui = require("app.views.ui.GoodsInfoUI.BoxGoodsInfoUI"):create()
    self.__ui:addTo(self)
    self:setButtonBack()
end

function GiftInfoPresenter:setParentUIPrensent(p)
    self.__parentUIPrensent = p
end

function GiftInfoPresenter:setGift(gift)
	self.__gift = gift
end

function GiftInfoPresenter:setShowBoxLayerNum(num)
    self.__showBoxLayerNum = num
end

function GiftInfoPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function GiftInfoPresenter:setButtonBack()
    self.__ui:setButtonBack(function()
        PopupLayerController:hideLayer("GiftInfoPresenter",function(layer)
            layer:hide()
        end)
    end)
end

function GiftInfoPresenter:showUI()
    self.__ui:setTitle(self.__gift:getName())
	self:__setName()
	self:__setDsc()
	self:__setList()

    self.__ui:showUI()
    self.__ui:setGoodsUIVisible(false)
end

function GiftInfoPresenter:hide()
    self.__ui:hideUI()
end

function GiftInfoPresenter:__setName()
    self.__ui:setTextName("")
end

function GiftInfoPresenter:__setDsc()
    self.__ui:setTextDesc(self.__gift:getDsc())
end

function GiftInfoPresenter:__setList()
	local goodsIdList = self.__gift:getGoodsIdList()

	local listInfo = {}
	for i = 1, #goodsIdList, 1 do
        local goods = GoodsHelper:getGoodsResClass(goodsIdList[i])
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

function GiftInfoPresenter:__setGoodsUIBack()
    self.__ui:removeGoodsUI()

    self.__ui:setGoodsUIVisible(false)

    if self.__parentUIPrensent then
        self.__parentUIPrensent:setButtonBackVisible(true)
    end
end

Helper:classDefNodeGetInstance(GiftInfoPresenter)

return GiftInfoPresenter
00000000