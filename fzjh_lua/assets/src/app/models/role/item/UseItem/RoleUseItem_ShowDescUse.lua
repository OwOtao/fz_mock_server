local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleUseItem_Confirm = require("app.models.role.item.UseItem.RoleUseItem_Confirm")

local RoleUseItem_ShowDescUse = {}

function RoleUseItem_ShowDescUse:__doUseItem()
    local item = self._item

	item:itemDescShow()
	RoleUseItem_Confirm.__doUseItem(self)
    return true
end

return NewClass("RoleUseItem_ShowDescUse", {AbstractUseItem}, RoleUseItem_ShowDescUse)
00000000000