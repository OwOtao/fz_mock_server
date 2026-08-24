local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleUseItem_Confirm = require("app.models.role.item.UseItem.RoleUseItem_Confirm")

local RoleUseItem_ZuoYouHuBo3 = {}

function RoleUseItem_ZuoYouHuBo3:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role
	self:__useLeftRightFightPill(role)
	item:itemDescShow()
	RoleUseItem_Confirm.__doUseItem(self)
    return true
end

-- 使用左右互搏速成丹
function RoleUseItem_ZuoYouHuBo3:__useLeftRightFightPill(role)
	if role == nil then
		role = User:getRole()
	end

	local Meridian = require("app.models.Meridian.Meridian")

	-- 如果没学会，直接学会左右互搏
	local sys = role:getMeridianSystem()
	if not sys:roleHasImpriting("zuoyouhuboyin") then
		self:__popText("互搏神通开启")
		sys:addMeridianImprinting("zuoyouhuboyin")
	end
end

return NewClass("RoleUseItem_ZuoYouHuBo3", {AbstractUseItem}, RoleUseItem_ZuoYouHuBo3)
0000000000000