local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_ShuXin = {}

function RoleUseItem_ShuXin:__doUseItem()
    local item = self._item

	item:itemDescShow()
    return true
end

return NewClass("RoleUseItem_ShuXin", {AbstractUseItem}, RoleUseItem_ShuXin)
0000000000000000