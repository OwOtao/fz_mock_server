local NewClass = require("third.class.NewClass")
local IGoodsPresenter = require("app.presenters.GoodsInfo.IGoodsPresenter")

local NormalGoodsInfoPresenter = {}

function NormalGoodsInfoPresenter:create(goods)
    local o = NormalGoodsInfoPresenter.new()
    o:init(goods)
    return o
end

function NormalGoodsInfoPresenter:init(goods)
    self.__ui = require("app.views.ui.GoodsInfoUI.NormalGoodsInfoUI"):create()
    self.__goods = goods
end

function NormalGoodsInfoPresenter:getUI()
    return self.__ui
end

function NormalGoodsInfoPresenter:showUI()
    self.__ui:setTitle("道具信息")
    self.__ui:setGoodsName(self.__goods:getName())
    self.__ui:setGoodsDesc(self.__goods:getDsc())
    self.__ui:setGoodsImageIcon(self.__goods:getIcon())
    self.__ui:showUI()
end

function NormalGoodsInfoPresenter:hide()
    self.__ui:hideUI()
end

function NormalGoodsInfoPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function NormalGoodsInfoPresenter:setButtonBack(func)
    self.__ui:setButtonBack(function()
        if func then
            func()
        end
    end)
end

return NewClass("NormalGoodsInfoPresenter", {IGoodsPresenter}, NormalGoodsInfoPresenter)000000000