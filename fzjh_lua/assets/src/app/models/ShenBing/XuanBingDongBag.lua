local class = require("third.class.NewClass")
local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")

local weaponTypeSort = {
     ["刀"] = 1,
     ["剑"] = 2,
     ["棍"] = 3,
     ["鞭"] = 4,
     ["双持"] = 5,
     ["暗器"] = 6,
     ["乐器"] = 7,
}

local XuanBingDongBag = {}

function XuanBingDongBag:create()
    return XuanBingDongBag:new()
end

function XuanBingDongBag:ctor()
    self._normalList = {}
    self._shenBingList = {}
end

function XuanBingDongBag:setRole(role)
    self._role = role
end

function XuanBingDongBag:setInput(input)
    self._input = input
end

function XuanBingDongBag:initList()
    self._normalList = {}
    self._shenBingList = {}

    local bItems = self._role:getItems(function(item)
        local itemData = self._role:getOneItemByKey(item.itemId)
        if itemData ~= nil and itemData.equipPart == "weapon" then
            return true
        else
            return false
        end
    end)

    for i, v in ipairs(bItems) do
        if v.type and v.type == "神兵" then
            table.insert(self._shenBingList, v)
        else
            table.insert(self._normalList, v)
        end
    end
end

function XuanBingDongBag:getOneItemByKey(itemId)
    return self._role:getOneItemByKey(itemId)
end

function XuanBingDongBag:checkShenBingIsDefault(itemId)
    local defaultShenBingItemId = self._role:getAttr("defaultShenBingItemId")
    if not defaultShenBingItemId then
        return false
    end
    return defaultShenBingItemId == itemId
end

function XuanBingDongBag:getShenBingItems()
    local shenBingItems = {}

    if MapIsEmpty(self._shenBingList) == false then
        for index, itemData in ipairs(self._shenBingList) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr then
                local item = {}
                item.onlyid = itemData.id
                item.itemId = itemData.itemId
                item.wanhaodu = itemData.wanhaodu
                item.name = itemAttr.nameColor .. itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.cuilianCount = itemAttr.cuilianCount
                item.type = itemAttr.type
                local info = ShenBingDuanZao:getWeaponBaseInfo(itemData.itemId)
                item.info = info
                
                table.insert(shenBingItems,item)
            end
        end
    end

    table.sort(shenBingItems,function(a,b)
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

function XuanBingDongBag:getShenBingItemsByType(shenBingType)
    local shenBingItems = {}

    if MapIsEmpty(self._shenBingList) == false then
        for index, itemData in ipairs(self._shenBingList) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr and itemAttr.type == shenBingType then
                local item = {}
                item.onlyid = itemData.id
                item.itemId = itemData.itemId
                item.wanhaodu = itemData.wanhaodu
                item.name = itemAttr.nameColor .. itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.cuilianCount = itemAttr.cuilianCount
                item.type = itemAttr.type
                local info = ShenBingDuanZao:getWeaponBaseInfo(itemData.itemId)
                item.info = info

                table.insert(shenBingItems,item)
            end
        end
    end

    table.sort(shenBingItems,function(a,b)
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

function XuanBingDongBag:getNormalItems()
    local normalItems = {}

    if MapIsEmpty(self._normalList) == false then
        for index, itemData in ipairs(self._normalList) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr then
                local item = {}
                item.onlyid = itemData.id
                item.itemId = itemData.itemId
                item.wanhaodu = itemData.wanhaodu
                item.name = itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.type = itemAttr.type
                item.bType = itemAttr.bType
                table.insert(normalItems,item)
            end
        end
    end

    table.sort(normalItems,function(a,b)
        if a.damage == b.damage then
            if weaponTypeSort[a.type] == weaponTypeSort[b.type] then
                return a.itemId > b.itemId
            else
                return weaponTypeSort[a.type] < weaponTypeSort[b.type]
            end
        else
            return a.damage > b.damage
        end
    end)

    return normalItems
end

function XuanBingDongBag:getNormalItemsByType(itemType)
    local normalItems = {}

    if MapIsEmpty(self._normalList) == false then
        for index, itemData in ipairs(self._normalList) do
            local itemAttr = self._role:getOneItemByKey(itemData.itemId)
            if itemAttr and itemAttr.type == itemType then
                local item = {}
                item.onlyid = itemData.id
                item.itemId = itemData.itemId
                item.wanhaodu = itemData.wanhaodu
                item.name = itemAttr.name
                item.damage = Helper:mathFloor(itemAttr:getWeaponDamage(self._role))
                item.bType = itemAttr.bType
                table.insert(normalItems,item)
            end
        end
    end

    table.sort(normalItems,function(a,b)
        if a.damage == b.damage then
            return a.itemId > b.itemId
        else
            return a.damage > b.damage
        end
    end)

    return normalItems
end

return class("XuanBingDongBag", {}, XuanBingDongBag)
000000