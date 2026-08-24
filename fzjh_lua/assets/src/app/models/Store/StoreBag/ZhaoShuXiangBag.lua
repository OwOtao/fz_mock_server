local newClass = require("third.class.NewClass")
local BaseBag = require("app.models.Store.StoreBag.BaseBag")
local RoleBagLocalItem = require("app.models.Store.StoreItem.RoleBagLocalItem")
local ZhaoShuXiangBag = {}

function ZhaoShuXiangBag:create(role)
    local p = ZhaoShuXiangBag.new()
    p:init(role)
    return p
end

function ZhaoShuXiangBag:initList()
    local items = self.__role:getZhaoShuXiangItems()

    local list  = {}

    for i, v in ipairs(items) do
        if not list[v.itemId] then
            list[v.itemId] = 0
        end

        list[v.itemId] = list[v.itemId] + v.count
    end

    for itemId, count in pairs(list) do
        table.insert(self.__sellList, {count = count, index = self.__index})

        local itemData = {
            canSell = false,
            sellMsg = "",
        }

        self.__listData[tostring(self.__index)] = RoleBagLocalItem:create(itemId, itemData)

        self.__index = self.__index + 1
    end
end

return newClass("ZhaoShuXiangBag", {BaseBag}, ZhaoShuXiangBag)
000