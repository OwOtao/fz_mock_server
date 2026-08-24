local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_BaFangLiHe = {}

function RoleUseItem_BaFangLiHe:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    HttpManagerEx:checkItemIsCanUse(itemId,1,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local jiaoziNum = data.number
                if jiaoziNum then
                    role:addItemCount(itemId, -1)
                    self:__popText("获得游字令"..tonumber(jiaoziNum))
                end
                self:__onUseAft()
            else
                self:__popText(errmsg)
            end
        end,
    IS_SHOW_WAITING)

    return true
end

return NewClass("RoleUseItem_BaFangLiHe", {AbstractUseItem}, RoleUseItem_BaFangLiHe)
000000000000000