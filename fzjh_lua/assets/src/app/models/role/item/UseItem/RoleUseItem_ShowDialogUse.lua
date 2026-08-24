local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleUseItem_Confirm = require("app.models.role.item.UseItem.RoleUseItem_Confirm")

local RoleUseItem_ShowDialogUse = {}

function RoleUseItem_ShowDialogUse:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role
    if role == nil then
        role = User:getRole()
    end

    role._iOutput:showUseItemConfirm(item, function()
        local callback = function()
            self:__onUseAft()
        end

        if not (item.canUse == 1 or item.canUse == true or item.canUseSpecial == 1) or
            item:__checkCanUse(callback) == false then
            return
        end

        if RoleUseItem_Confirm.__doUseItem(self) == false then
            return
        end

        -- 使用描述
        item:itemDescShow()

        -- 限制消耗品数量统计
        item:__updateRoleFlag(role)
    end, function()
    end)

    return true
end

return NewClass("RoleUseItem_ShowDialogUse", {AbstractUseItem}, RoleUseItem_ShowDialogUse)
0