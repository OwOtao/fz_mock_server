local class = require("third.class.NewClass")
local LimitConfig = require("script.others.godweaponCarry")["Sheet1"]
local ShenBingWareHouse = {}

local weaponTypeSort = {
    ["刀"] = 1,
    ["剑"] = 2,
    ["棍"] = 3,
    ["鞭"] = 4,
    ["双持"] = 5,
    ["暗器"] = 6,
    ["乐器"] = 7,
}

local currencyType = {
    ["0"] = "免费",
    ["1"] = "碎银",
    ["2"] = "元宝",
}

function ShenBingWareHouse:create()
    return ShenBingWareHouse:new()
end

function ShenBingWareHouse:ctor()
    self._list = {}
end

function ShenBingWareHouse:setRole(role)
    self._role = role
end

function ShenBingWareHouse:getOneItemByKey(itemId)
    return self._role:getOneItemByKey(itemId)
end

function ShenBingWareHouse:initShenBingItems()
    self._list = {}

    local items = self._role:getItems(function(item)
        if item.type == "神兵" then
            return true
        else
            return false
        end
    end)

    for i, v in ipairs(items) do
        table.insert(self._list, v)
    end
end

function ShenBingWareHouse:getShenBingItems()
    local shenBingItems = {}

    local list = self._list

    if MapIsEmpty(list) == false then
        for index, shenBing in ipairs(list) do
            local itemAttr = self._role:getOneItemByKey(shenBing.itemId)
            local item = {}
            item.itemId = shenBing.itemId
            item.name = itemAttr.nameColor .. itemAttr.name
            item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
            item.cuilianCount = itemAttr.cuilianCount
            item.type = itemAttr.type
            table.insert(shenBingItems,item)
        end
    end

    table.sort(shenBingItems,function(a,b)
        if self:checkShenBingIsDefault(a.itemId) then
            return true
        end

        if self:checkShenBingIsDefault(b.itemId) then
            return false
        end

        if a.damage == b.damage then
            if a.cuilianCount == b.cuilianCount then
                if weaponTypeSort[a.type] == weaponTypeSort[b.type] then
                    return a.itemId > b.itemId
                else
                    return weaponTypeSort[a.type] < weaponTypeSort[b.type]
                end
            else
                return a.cuilianCount > b.cuilianCount
            end
        else
            return a.damage > b.damage
        end
    end)

    return shenBingItems
end

function ShenBingWareHouse:getShenBingItemsByType(shenBingType)
    local shenBingItems = {}

    local list = self._list

    if MapIsEmpty(list) == false then
        for index, shenBing in ipairs(list) do
            local itemAttr = self._role:getOneItemByKey(shenBing.itemId)
            if itemAttr.type == shenBingType then
                local item = {}
                item.itemId = shenBing.itemId
                item.name = itemAttr.nameColor .. itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.cuilianCount = itemAttr.cuilianCount
                item.type = itemAttr.type
                table.insert(shenBingItems,item)
            end
        end
    end

    table.sort(shenBingItems,function(a,b)
        if self:checkShenBingIsDefault(a.itemId) then
            return true
        end

        if self:checkShenBingIsDefault(b.itemId) then
            return false
        end

        if a.damage == b.damage then
            if a.cuilianCount == b.cuilianCount then
                return a.itemId > b.itemId
            else
                return a.cuilianCount > b.cuilianCount
            end
        else
            return a.damage > b.damage
        end
    end)

    return shenBingItems
end 

function ShenBingWareHouse:checkShenBingIsDefault(itemId)
    local defaultShenBingItemId = self._role:getAttr("defaultShenBingItemId")
    if not defaultShenBingItemId then
        return false
    end
    return defaultShenBingItemId == itemId
end

function ShenBingWareHouse:setDefaultShenBing(itemId)
    self._role:setAttr("defaultShenBingItemId", itemId)
end

function ShenBingWareHouse:getShenBingLimit()
    return self._role:getAttr("bagShenBingNumLimit")
end

function ShenBingWareHouse:getLevelByLimit(limit)
    if MapIsEmpty(LimitConfig) == false then
        for i, v in pairs(LimitConfig) do
            if v.bagcount == limit then
                return tonumber(v.id)
            end
        end
        error("当前神兵携带上限异常："..tostring(limit))
    end
end

function ShenBingWareHouse:getLimitByLevel(level)
    if MapIsEmpty(LimitConfig) == false then
        for i, v in pairs(LimitConfig) do
            if tonumber(v.id) == level then
                return v.bagcount
            end
        end
        error("当前神兵携带上限等级异常："..tostring(level))
    end
end

function ShenBingWareHouse:getCostByLimit(limit)
    if MapIsEmpty(LimitConfig) == false then
        for i, v in pairs(LimitConfig) do
            if v.bagcount == limit then
                return v.count, currencyType[tostring(v.currency)]
            end
        end
        error("当前神兵携带上限异常："..tostring(limit))
    end
end

function ShenBingWareHouse:getMaxLevel()
    if MapIsEmpty(LimitConfig) == false then
        local level = 0
        for i, v in pairs(LimitConfig) do
            if tonumber(v.id) > level then
                level = tonumber(v.id)
            end
        end

        return level
    end
end


--升级神兵袋空间
function ShenBingWareHouse:upgrade(func)
    local currLevel = self:getLevelByLimit(self:getShenBingLimit())
    local maxLevel = self:getMaxLevel()
    if currLevel >= maxLevel then
        return
    end
    
    local afterLevel = currLevel + 1
    HttpManagerEx:upgradeUserBag(3,afterLevel,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if MapIsEmpty(data) == false then
                local afterSpace = self:getLimitByLevel(afterLevel)

                if data.count > 0 then
                    PopText("消耗"..tostring(data.count)..currencyType[tostring(data.currency)]..",背包神兵携带数量成功升级到"..afterSpace.."把")
                end

                --碎银
                if data.currency == 1 then
                    self._role:addAttr("money", -data.count)
                end

                self._role:setAttr("bagShenBingNumLimit", afterSpace)

                if func then
                    func()
                end
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

return class("ShenBingWareHouse", {}, ShenBingWareHouse)0000000000