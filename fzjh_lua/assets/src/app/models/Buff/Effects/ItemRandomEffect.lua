local BaseBuffEffect = require("app.models.Buff.Effects.BaseBuffEffect")

--@SuperType [BaseBuffEffect]
local ItemRandomEffect = class("ItemRandomEffect", BaseBuffEffect)

function ItemRandomEffect:create()
    local p = ItemRandomEffect:new()
    p:init()
    return p
end

function ItemRandomEffect:onInit()
    self.effectType = 4
end

function ItemRandomEffect:trigger(obj)
    local role = obj.role

    local count = self:analysisValue(obj)

    local itemIds = self.attrType

    local itemList = string.split(itemIds, ";")
    local randIndex = math.random(1, #itemList)
    local itemId = itemList[randIndex]

    local ret = {}
    ret[itemId] = count

    if role:checkCanBuyTwoOrMoreThings(ret) then
        local result = role:addItemCount(itemId, count)
        local itemAttr = role:getOneItemByKey(itemId)
        if result == true then
            PopText("获得 " .. itemAttr.name .. " X " .. count)
        end
    end
end

function ItemRandomEffect:remove()
end

return ItemRandomEffect
000000