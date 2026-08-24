local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_ZhouHuoDong = {}

function RoleUseItem_ZhouHuoDong:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    HttpManagerEx:detectionGoods(itemId,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if data and tonumber(data.numbers) > 0 then
                    local ActivityCalendarUtils = require("app.models.Action.ActivityCalendarUtils")
                    ActivityCalendarUtils:getSpecialTitle(itemId)
                    role:addItemCount(itemId, -1)
                    self:__onUseAft()
                else
                    self:__popText(errmsg)
                end
            else
                self:__popText(errmsg)
            end
        end,
    IS_SHOW_WAITING)

    return true
end

return NewClass("RoleUseItem_ZhouHuoDong", {AbstractUseItem}, RoleUseItem_ZhouHuoDong)
00