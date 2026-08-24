local newClass = require("third.class.NewClass")
local BaseStoreItem = require("app.models.Store.StoreItem.BaseStoreItem")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")
local StoreGoods = {}

function StoreGoods:create(id, data)
    local p = StoreGoods.new()
    p:init(id, data)
    return p
end

function StoreGoods:init(id, data)
    self.__goodsId = id
    self.__data = data
end

function StoreGoods:getId()
    return self.__goodsId
end

function StoreGoods:getItemId()
    local goods = GoodsHelper:getGoodsResClass(self.__goodsId)
    return goods:getItemId()
end

function StoreGoods:getDsc()
    local goods = GoodsHelper:getGoodsResClass(self.__goodsId)
    return goods:getDsc()
end

function StoreGoods:getPrice()
    return self:getDataAttr("price")
end

function StoreGoods:getPriceUnit()
    return self:getDataAttr("priceUnit")
end

function StoreGoods:getPriceName()
    return CurrencyUtil:getCurrencyName(self:getPriceUnit())
end

function StoreGoods:getName()
    local goods = GoodsHelper:getGoodsResClass(self.__goodsId)
    return goods:getName()
end

function StoreGoods:getUIName(count)
    return self:getName().."X"..tostring(count)
end

return newClass("StoreGoods", {BaseStoreItem}, StoreGoods)
00