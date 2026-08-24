local newClass = require("third.class.NewClass")
local BaseBag = require("app.models.Store.StoreBag.BaseBag")
local RoleBagLocalItem = require("app.models.Store.StoreItem.RoleBagLocalItem")
local Bag = {}

function Bag:create(role)
    local p = Bag.new()
    p:init(role)
    return p
end

function Bag:initList()
    local items = self.__role:getItems()

    for i, v in ipairs(items) do
        table.insert(self.__sellList, {count = v.count, index = self.__index})

        local canSell, sellMsg = self:__checkItemCanSell({id = v.id, wanhaodu = v.wanhaodu, itemId = v.itemId})

        local itemData = {
            onlyId = v.id,
            canSell = canSell,
            wanhaodu = v.wanhaodu,
            sellMsg = sellMsg,
        }

        self.__listData[tostring(self.__index)] = RoleBagLocalItem:create(v.itemId, itemData)

        self.__index = self.__index + 1
    end
end

function Bag:__checkItemCanSell(itemInfo)
    local can_sell, msg = true, ""

    local itemAttr = self.__role:getOneItemByKey(itemInfo.itemId)

    if can_sell and itemAttr.itemCanSale ~= 1 and itemAttr.itemCanSale ~= true then
        can_sell = false
        msg = itemAttr.name .. "不能出售!"
    end

    if can_sell and itemAttr.priceUnit == "yuanbao" then
        can_sell = false
        msg = "此物太过珍贵,不能出售!"
    end

    if can_sell and itemAttr.wpType == "神兵" then
        can_sell = false
        msg = "商人可不敢收购神兵啊！"
    end

    if can_sell and itemInfo.wanhaodu and itemInfo.wanhaodu == 0 then
        can_sell = false
        msg = "此兵器已经损坏，无法出售!"
    end

    if can_sell and self.__role:checkItemIsEquip(itemInfo.id) == true then
        can_sell = false
        msg = "装备中的物品无法出售"
    end

    if can_sell and self.__role:checkIsPrepareWeapon(itemInfo.id) == true then
        can_sell = false
        msg = "准备中的武器无法出售"
    end

    if can_sell then
        return true, itemInfo.count
    end

    return false, msg
end

return newClass("Bag", {BaseBag}, Bag)
000000000000000