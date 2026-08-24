-- 实物兑换

local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_ShiWuDuiHuan = {}

function RoleUseItem_ShiWuDuiHuan:__doUseItem()
    local role = self._role
    local item = self._item

    role._iOutput:showShiWuDuiHuan(function()
        role:addItemCount(self._item.id, -1)
        item:itemDescShow()

        self:__onUseAft()
    end)


    return true
end

return NewClass("RoleUseItem_ShiWuDuiHuan", {AbstractUseItem}, RoleUseItem_ShiWuDuiHuan)
000000000