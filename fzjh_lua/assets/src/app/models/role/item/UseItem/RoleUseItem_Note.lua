local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_Note = {}

function RoleUseItem_Note:__doUseItem()
	local role = self._role
	local item = self._item

	if not role  then
		role = User:getRole()
	end

	local currSkillLv = role:getSkillLv(item.skillid)

	local addExp = 0
	if type(item.value) == "string" then
		addExp = Helper:GetValueFromScript(item.value,{skillLevel = currSkillLv})
	elseif type(item.value) == "number" then
		addExp = item.value
	end

	if role:addSkillExp(item.skillid,addExp) then
		role:addItemCount(item.id,-1)
		self:__richPrint(item.useDsc)
	end

	self:__onUseAft()

    return true
end

return NewClass("RoleUseItem_Note", {AbstractUseItem}, RoleUseItem_Note)
00000000000