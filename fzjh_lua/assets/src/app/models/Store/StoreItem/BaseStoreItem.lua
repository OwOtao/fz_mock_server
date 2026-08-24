local newClass = require("third.class.NewClass")

local BaseStoreItem = {}

function BaseStoreItem:create(id, data)
    local p = BaseStoreItem.new()
    p:init(id, data)
    return p
end

function BaseStoreItem:init(id, data)
end

function BaseStoreItem:getId()
end

function BaseStoreItem:getItemId()
end

function BaseStoreItem:getDsc()
end

function BaseStoreItem:getPrice()
end

function BaseStoreItem:getPriceUnit()
end

function BaseStoreItem:getPriceName()    
end

function BaseStoreItem:getName()
end

function BaseStoreItem:getUIName(count)    
end

function BaseStoreItem:getUnitCount()
end

function BaseStoreItem:getWanHaodu()
    return self:getDataAttr("wanhaodu")
end

function BaseStoreItem:getStoreId()
    return self:getDataAttr("storeId")
end

function BaseStoreItem:getDiscount()
    return self:getDataAttr("discount")
end

function BaseStoreItem:getLimitCount()
    return self:getDataAttr("limitCount")
end

function BaseStoreItem:getLimitBoughtCount()
    return self:getDataAttr("limitBoughtCount")
end

function BaseStoreItem:setLimitBoughtCount(value)
    self:setDataAttr("limitBoughtCount", value)
end

function BaseStoreItem:getLimitType()
    return self:getDataAttr("limitType")
end

function BaseStoreItem:getUnitCount()
    return self:getDataAttr("unitCount")
end

function BaseStoreItem:getCanSell()
    return self:getDataAttr("canSell")
end

function BaseStoreItem:getSellMsg()
    return self:getDataAttr("sellMsg")
end

function BaseStoreItem:isCurrency()
    return self:getDataAttr("isCurrency")
end

function BaseStoreItem:getDataAttr(attr)
    return self.__data[attr]
end

function BaseStoreItem:setDataAttr(attr, value)
    self.__data[attr] = value
end

return newClass("BaseStoreItem", {}, BaseStoreItem)
0000000