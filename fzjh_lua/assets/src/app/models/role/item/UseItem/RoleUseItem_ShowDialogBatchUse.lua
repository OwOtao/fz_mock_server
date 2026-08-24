local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleUseItem_Confirm = require("app.models.role.item.UseItem.RoleUseItem_Confirm")

local RoleUseItem_ShowDialogBatchUse = {}
local itemBatchUseNumLimit = {
    ["tzmopupbox01"] = 10,
    ["tzmopupbox02"] = 10,
    ["tzmopupbox03"] = 10,
    ["tzmopupbox04"] = 10,
    ["tzmopupbox05"] = 10,
    ["tzmopupbox06"] = 10,
    ["tzbox01001"] = 10,
    ["tzbox01002"] = 10,
    ["tzbox01003"] = 10,
    ["tzbox01004"] = 10,
    ["tzbox01005"] = 10,
    ["tzbox01006"] = 10,
    ["tzbox02001"] = 10,
    ["tzbox02002"] = 10,
    ["tzbox02003"] = 10,
    ["tzbox02004"] = 10,
    ["tzbox02005"] = 10,
    ["tzbox02006"] = 10,
    ["tzbox03001"] = 10,
    ["tzbox03002"] = 10,
    ["tzbox03003"] = 10,
    ["tzbox03004"] = 10,
    ["tzbox03005"] = 10,
    ["tzbox03006"] = 10,
}

function RoleUseItem_ShowDialogBatchUse:__doUseItem()
    local item = self._item
    local role = self._role
    local itemCount = self._useNum

    if itemBatchUseNumLimit[item.id] and itemCount > itemBatchUseNumLimit[item.id] then
        itemCount = itemBatchUseNumLimit[item.id]
    end

    if role == nil then
        role = User:getRole()
    end

    role._iOutput:showBatchUseItem(item, itemCount, function(itemCount)
        role._iOutput:showBatchUseItemConfirm(item, itemCount, function()
            local callback = function()
                self:__onUseAft()
            end

            for i = 1, itemCount do
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
            end
        end, function()
        end)
    end)
    return true
end

return NewClass("RoleUseItem_ShowDialogBatchUse", {AbstractUseItem}, RoleUseItem_ShowDialogBatchUse)
000000