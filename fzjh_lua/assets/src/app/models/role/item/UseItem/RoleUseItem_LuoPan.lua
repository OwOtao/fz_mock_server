local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_LuoPan = {}

function RoleUseItem_LuoPan:__canUseItem()
	local role = self._role

	local  currLayer =  MainControllLayer:getCurrLayer()
	if currLayer == "BiWuMainLayer" then
		self:__popText("你拿出寻龙罗盘，不料却发现罗盘指针四处飞转，完全停不下来，看来此地磁场异常，不宜使用！")
		return false
	end

	if role:getNumAttr("jing") < 3 then
		self:__popText("您的精力不足")
		return false
	end

    return true
end

function RoleUseItem_LuoPan:__doUseItem()
	local role = self._role

	local currLayer = MainControllLayer:getCurrLayer()
	if currLayer == "AttrLayer" then
		local Treasure = require("app.models.treasure.treasure")
		Treasure:BaoZang(1, nil, function()
			print("使用前精力:", role:getNumAttr("jing"))
			role:addAttr("jing", - 3)
			print("使用后精力:", role:getNumAttr("jing"))
		end)
	else
		local mapLayer = MainControllLayer:getLayer("MapLayer")
		local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
		local Treasure = require("app.models.treasure.treasure")
		Treasure:BaoZang(1, mapLayer, function()
			MapRoleLayer:showPanelBag()
			MapRoleLayer:changeTab(0)
			MapRoleLayer:hide()
			print("使用前精力:", role:getNumAttr("jing"))
			role:addAttr("jing", - 3)
			print("使用后精力:", role:getNumAttr("jing"))
			self:__onUseAft()
		end)
	end

    return true
end

return NewClass("RoleUseItem_LuoPan", {AbstractUseItem}, RoleUseItem_LuoPan)
00