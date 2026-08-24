local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleUseItem_Confirm = require("app.models.role.item.UseItem.RoleUseItem_Confirm")

local RoleUseItem_MeiRongWan = {}

function RoleUseItem_MeiRongWan:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    role._iOutput:showUseItemConfirm(
        item,
        function()
            HttpManagerEx:checkItemIsCanUse(itemId,1,
                function(status, errcode, errmsg, data)
                    if status == 200 and errcode == 0 then
                        local callback = function()
                            self:__onUseAft()
                        end

                        if not(item.canUse == 1 or item.canUse == true or item.canUseSpecial == 1) or item:__checkCanUse(callback) == false then
                            return
                        end
            
                        if RoleUseItem_Confirm.__doUseItem(self) == false then
                            return
                        end
            
                        -- 使用描述
                        item:itemDescShow()
            
                        -- 限制消耗品数量统计
                        item:__updateRoleFlag(role)
                    else
                        self:__popText(errmsg)
                    end
                end,
            IS_SHOW_WAITING)

        end,
        function()
        end
    )

    return true
end

return NewClass("RoleUseItem_MeiRongWan", {AbstractUseItem}, RoleUseItem_MeiRongWan)
000000000