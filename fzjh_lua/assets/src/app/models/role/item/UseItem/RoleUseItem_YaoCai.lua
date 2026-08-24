local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")
local RoleUseItem_Confirm = require("app.models.role.item.UseItem.RoleUseItem_Confirm")

local RoleUseItem_YaoCai = {}

function RoleUseItem_YaoCai:__doUseItem()
	local role = self._role
	local item = self._item
	if role == nil then
		role = User:getRole()
	end

	-- add by XiaoZhiWei 2017/05/05 10:29:58 玩家角色使用只有文本,没有效果
	if role:getAttr("onlyId") == User:getRoleAttr("onlyId") then
		item:itemDescShow()
		role:addItemCount(item.id, - 1)
		self:__onUseAft()
	else
		item:itemDescShow()
		RoleUseItem_Confirm.__doUseItem(self)
	end

    return true
end

return NewClass("RoleUseItem_YaoCai", {AbstractUseItem}, RoleUseItem_YaoCai)
0000000000000