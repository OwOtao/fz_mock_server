local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_Furniture = {}

function RoleUseItem_Furniture:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

    local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")
    local currMap = User:getRole():getCurrMap()

    local callback = function()
        self:__onUseAft()
    end
    
    FurnitureModel:place(currMap,itemId,callback)

    return true
end

return NewClass("RoleUseItem_Furniture", {AbstractUseItem}, RoleUseItem_Furniture)
0000000000000000