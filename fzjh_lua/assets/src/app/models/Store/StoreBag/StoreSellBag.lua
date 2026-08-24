--[[
商人售卖列表，商人背包
]]
local newClass = require("third.class.NewClass")
local BaseBag = require("app.models.Store.StoreBag.BaseBag")
local GoodsHelper = require("app.models.Store.GoodsHelper")
local CurrencyUtil = require("app.models.Currency.CurrencyUtil")
local StoreGoods = require("app.models.Store.StoreItem.StoreGoods")
local StoreSellBag = {}

--[[
    @desc: 
    author:tanqinjian
    time:2025-08-15 14:44:28
    --@list: 商人可出售列表
    @return:
]]
function StoreSellBag:create(list)
    local p = StoreSellBag.new()
    p:init(list)
    return p
end

function StoreSellBag:init(list)
    self:initList(list)
end

function StoreSellBag:initList(list)
    if not list then
        return
    end

    for k, v in ipairs(list) do
        local itemData = {
            storeId = v.storeId,
            price = v.price,
            priceUnit = v.priceUnit,
            unitCount = v.unitCount,
            discount = v.discount,
            limitType = v.limitType,
            limitCount = v.limitCount,
            limitBoughtCount = v.limitBoughtCount,
            canSell = true,
            sellMsg = ""
        }

        self.__listData[tostring(self.__index)] = StoreGoods:create(v.goodsId, itemData)

        table.insert(self.__sellList, {count = v.count, index = self.__index})

        self.__index = self.__index + 1
    end

end

function StoreSellBag:buy(index, count)
    for i, v in ipairs(self.__sellList) do
        if v.index == index then
            v.count = v.count - count

            if v.count == 0 then
                table.remove(self.__sellList, i)
            end

            local isTrue = false

            for i, v in ipairs(self.__soldList) do
                if v.index == index then
                    v.count = v.count + count
                    isTrue = true
                    break
                end
            end

            if isTrue == false then
                table.insert(self.__soldList, {count = count, index = index})
            end

            break
        end
    end
end

function StoreSellBag:sell(index, count)
    for i, v in ipairs(self.__soldList) do
        if v.index == index then
            v.count = v.count - count

            if v.count == 0 then
                table.remove(self.__soldList, i)
            end

            local isTrue = false

            for i, v in ipairs(self.__sellList) do
                if v.index == index then
                    v.count = v.count + count
                    isTrue = true
                    break
                end
            end

            if isTrue == false then
                table.insert(self.__sellList, {count = count, index = index})
            end

            break
        end
    end
end

return newClass("StoreSellBag", {BaseBag}, StoreSellBag)
000000000000000