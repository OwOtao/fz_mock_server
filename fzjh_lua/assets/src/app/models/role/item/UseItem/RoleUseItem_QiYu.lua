local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local Item = require("app.models.item.Item")

-- @desc 奇遇道具使用
local RoleUseItem_QiYu = {}

function RoleUseItem_QiYu:__canUseItem()
    local role = self._role
    local item = self._item

    local currMap = role:getCurrMap()
    local mapLayer = MainControllLayer:getLayerWithoutCreate("MapLayer")

    local canUse = false

    if currMap and mapLayer then
        -- print("mapLayer._currRoom.id", mapLayer._currRoom.id)
        -- print("item.id", item.id)

        --触发条件 使用背包物品 判断是否在可使用的房间内
        canUse = currMap:doRoomConditions(
            mapLayer._currRoom.id,
            {
                operation = "使用背包物品",
                useItemId = item.id,
                currRoomId = mapLayer._currRoom.id,
                mapLayer = mapLayer,
                useDsc = item.useDsc,
                func = function()
                end
            }
        )
    end
    if canUse ~= true then
        self:__richPrint(item.useDsc)
    end
    return canUse
end

function RoleUseItem_QiYu:__doUseItem()
    local item = self._item
    local role = self._role

    local currMap = role:getCurrMap()
    local mapLayer = MainControllLayer:getLayerWithoutCreate("MapLayer")

    if currMap and mapLayer then
        --触发条件 使用背包物品 判断是否在可使用的房间内
        currMap:doRoomConditionAndResult(
            mapLayer._currRoom.id,
            {
                operation = "使用背包物品",
                useItemId = item.id,
                currRoomId = mapLayer._currRoom.id,
                mapLayer = mapLayer,
                useDsc = item.useDsc,
                func = function()
                    self:__onUseAft()
                end
            }
        )
    else
        self:__richPrint(item.useDsc)
    end

    return true
end

return NewClass("RoleUseItem_QiYu", {AbstractUseItem}, RoleUseItem_QiYu)
0000000