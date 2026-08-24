--[[
    玩家上一次卖出的道具数据，赎回背包
]]
local newClass = require("third.class.NewClass")
local BaseBag = require("app.models.Store.StoreBag.BaseBag")
local RoleBagLocalItem = require("app.models.Store.StoreItem.RoleBagLocalItem")
local RoleSoldBag = {}

--[[
    @desc: 
    author:tanqinjian
    time:2025-08-15 14:42:06
    --@list: 商人赎回列表
    @return:
]]
function RoleSoldBag:create(list)
    local p = RoleSoldBag.new()
    p:init(list)
    return p
end

function RoleSoldBag:init(list)
    self:initList(list)
end

function RoleSoldBag:initList(list)
    if not list then
        return
    end

    for i, v in ipairs(list) do
        table.insert(self.__sellList, {count = v.count, index = self.__index})

        local itemData = {
            onlyId = v.id,
            canSell = true,
            wanhaodu = v.wanhaodu,
            sellMsg = "",
        }

        self.__listData[tostring(self.__index)] = RoleBagLocalItem:create(v.itemId, itemData)

        self.__index = self.__index + 1
    end
end

function RoleSoldBag:buy(index, count)
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

function RoleSoldBag:sell(index, count)
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

return newClass("RoleSoldBag", {BaseBag}, RoleSoldBag)
000000