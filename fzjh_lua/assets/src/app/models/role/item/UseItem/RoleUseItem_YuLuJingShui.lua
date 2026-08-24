-- 实物兑换

local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_YuLuJingShui = {}

function RoleUseItem_YuLuJingShui:__canUseItem()
    local role = self._role

    if role:getAttr("qi") >= role:getCurrQiMax() then
        role._iOutput:richPrint("你当前气血状态良好，无需饮用！")
        return false
    end

    return true
end

function RoleUseItem_YuLuJingShui:__doUseItem()
    local role = self._role
    local item = self._item

    role._iOutput:showUseItemConfirm(
        item,
        function()
            role:setAttr("qi", role:getCurrQiMax())
            role:addItemCount(item.id, -1)
            role._iOutput:richPrint("你回复了所有气血。")
            if self._onAtrUse then
                self:__onUseAft()
            end
        end,
        function()
        end
    )

    return true
end

return NewClass("RoleUseItem_YuLuJingShui", {AbstractUseItem}, RoleUseItem_YuLuJingShui)
000000000000