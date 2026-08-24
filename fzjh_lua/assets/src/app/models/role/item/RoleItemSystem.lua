local AddItemCountExecutorFactory = require("app.models.role.item.AddItem.AddItemCountExecutorFactory")
local RoleUseItemFactory = require("app.models.role.item.UseItem.RoleUseItemFactory")

local NewClass = require("third.class.NewClass")

local RoleItemSystem = {}

function RoleItemSystem:create(role)
    local p = RoleItemSystem.new()
    p.__isNotSerializable = true
    p:setRole(role)
    return p
end

function RoleItemSystem:useItem(itemId, onUseAft, specialType, useItemNum)

    local item = self._role:getOneItemByKey(itemId)

    assert(item ~= nil, "can not find " .. itemId)

    if not onUseAft then
		onUseAft = EMPTY_FUNC
    end

    local roleUseItem = RoleUseItemFactory:create(item.id, item.type, item.tag, specialType)

    roleUseItem:setRole(self._role)
    roleUseItem:setItem(item)
    roleUseItem:setAtfUseFunc(onUseAft)
    roleUseItem:setUseItemNum(useItemNum)
    return roleUseItem:useItem()
end



function RoleItemSystem:setRole(role)
    self._role = role
end

return NewClass("RoleItemSystem", nil, RoleItemSystem)
000000000000