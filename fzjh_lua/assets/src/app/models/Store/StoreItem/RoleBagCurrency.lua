local newClass = require("third.class.NewClass")
local BaseStoreItem = require("app.models.Store.StoreItem.BaseStoreItem")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")
local RoleBagCurrency = {}

function RoleBagCurrency:create(id, data)
    local p = RoleBagCurrency.new()
    p:init(id, data)
    return p
end

function RoleBagCurrency:init(id, data)
    self.__currencyId = id
    self.__data = data
end

function RoleBagCurrency:getId()
    return self.__currencyId
end

function RoleBagCurrency:getItemId()
    return self.__currencyId
end

function RoleBagCurrency:getDsc()
    return CurrencyUtil:getCurrencyDesc(self.__currencyId)
end

function RoleBagCurrency:getPrice()
    return CurrencyUtil:getCurrencySalePrice(self.__currencyId)
end

function RoleBagCurrency:getPriceUnit()
    return "money"
end

function RoleBagCurrency:getPriceName()
    return "碎银" 
end

function RoleBagCurrency:getName()
    return CurrencyUtil:getCurrencyName(self.__currencyId) 
end

function RoleBagCurrency:getUIName(count)
    return self:getName().."X"..tostring(count)
end

function RoleBagCurrency:getUnitCount()
    return 1
end

return newClass("RoleBagCurrency", {BaseStoreItem}, RoleBagCurrency)
000000