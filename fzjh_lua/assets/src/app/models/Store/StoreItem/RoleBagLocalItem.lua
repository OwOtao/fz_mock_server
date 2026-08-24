local newClass = require("third.class.NewClass")
local BaseStoreItem = require("app.models.Store.StoreItem.BaseStoreItem")
local RoleBagLocalItem = {}

function RoleBagLocalItem:create(id, data)
    local p = RoleBagLocalItem.new()
    p:init(id, data)
    return p
end

function RoleBagLocalItem:init(id, data)
    self.__itemId = id
    self.__data = data
end

function RoleBagLocalItem:getId()
    return self.__itemId
end

function RoleBagLocalItem:getItemId()
    return self.__itemId
end

function RoleBagLocalItem:getDsc()
    local itemAttr = Item:getOneItemByKey(self.__itemId)
    return itemAttr.dsc
end

function RoleBagLocalItem:getPrice()
    local itemAttr = Item:getOneItemByKey(self.__itemId)
    return itemAttr.salePrice
end

function RoleBagLocalItem:getPriceUnit()
    return "money"
end

function RoleBagLocalItem:getPriceName()
    return "碎银" 
end

function RoleBagLocalItem:getName()
    local itemAttr = Item:getOneItemByKey(self.__itemId)
    return itemAttr.name
end

function RoleBagLocalItem:getUIName(count)
    local itemAttr = Item:getOneItemByKey(self.__itemId)
    if itemAttr.wpType == "神兵" then
        return itemAttr.name
    else
        return itemAttr.name .. "X" .. tostring(count)
    end
end

function RoleBagLocalItem:getUnitCount()
    return 1
end

return newClass("RoleBagLocalItem", {BaseStoreItem}, RoleBagLocalItem)
0000