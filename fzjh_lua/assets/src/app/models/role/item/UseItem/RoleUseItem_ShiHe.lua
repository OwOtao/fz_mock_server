local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_ShiHe = {}

function RoleUseItem_ShiHe:__doUseItem()
    local item = self._item
	local role = self._role

	--@RefType [src.app.models.HomelandModel.FurnitureModel.FurnitureModel#FurnitureModel]
	local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")
	--@RefType [src.app.models.HomelandModel.HomelandDesc#HomelandDesc]
	local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")

	local dinnerResult = FurnitureModel:dinner()

	role:addItemCount(item.id, -1)
	self:__onUseAft()

	local text = HomelandDesc:getEatDesc(dinnerResult.rate)

	local dinnerName,dinnerValue

	if dinnerResult.name and dinnerResult.value then
		dinnerName = dinnerResult.name
		dinnerValue = dinnerResult.value
	end

	role._iOutput:showShiHeUse(dinnerName,dinnerValue,text)

    return true
end

return NewClass("RoleUseItem_ShiHe", {AbstractUseItem}, RoleUseItem_ShiHe)
0000000000