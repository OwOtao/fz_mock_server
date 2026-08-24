local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleTitleResManager = require("app.models.role.titleSystem.RoleTitleResManager")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")

local RoleUseItem_AnniversaryTitle = {}

function RoleUseItem_AnniversaryTitle:__doUseItem()
    local role = self._role
    local item = self._item

    role:addItemCount(item.id, -1)
    
    local basicTitleId = RoleTitleConst.SpecialBasicTitleId.Anniversary5
	local title = RoleTitleResManager:getBasicTitleClassById(basicTitleId)
    local name = title:getColorName()

	if role:hasBasicTitle(basicTitleId) == false then
		role:addBasicTitle(basicTitleId)
	end

    self:__popText("获得"..name.."称号")

    self:__onUseAft()

    return true
end

return NewClass("RoleUseItem_AnniversaryTitle", {AbstractUseItem}, RoleUseItem_AnniversaryTitle)
000000000000