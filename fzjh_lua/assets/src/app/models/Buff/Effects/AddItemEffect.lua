local BaseBuffEffect = require("app.models.Buff.Effects.BaseBuffEffect")

--@SuperType [BaseBuffEffect]
local AddItemEffect = class("AddItemEffect", BaseBuffEffect)

function AddItemEffect:create()
    local p = AddItemEffect:new()
    p:init()
    return p
end

function AddItemEffect:onInit()
    self.effectType = 3
end

function AddItemEffect:trigger(context)
    local role = context.role

    local addCount = self:analysisValue(context)

    local itemId = self.attrType

    local item = Item:getOneItemByKey(itemId)

    local ret = {}
    ret[itemId] = addCount

    if role:checkCanBuyTwoOrMoreThings(ret) then
        local result = role:addItemCount(itemId, addCount)
        if result == true then
            PopText("获得 " .. item.name .. " X " .. addCount)
        end
    end
end

function AddItemEffect:remove()
end

return AddItemEffect
0000000000000