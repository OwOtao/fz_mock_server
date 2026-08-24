local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_JueJinChan = {}

function RoleUseItem_JueJinChan:__doUseItem()
    local item = self._item
    local itemId = item.id
    local role = self._role

	local currLayer = MainControllLayer:getCurrLayer()

    if currLayer ~= "MapLayer" then
		self:__popText("掘金铲只能在副本中使用")
    else
        if role:getNumAttr("jing") >= 30 then
			local Treasure = require("app.models.treasure.treasure")
			local mapLayer = MainControllLayer:getLayer("MapLayer")
			local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
			Treasure:CanZi(MainControllLayer, mapLayer, function()
				MapRoleLayer:showPanelBag()
				MapRoleLayer:changeTab(0)
				MapRoleLayer:hide()
				if self._onAtrUse then
					role:addItemCount("juejinchan", - 1)
					print("使用前精力:", role:getNumAttr("jing"))
					role:addAttr("jing", - 30)
					print("使用后精力:", role:getNumAttr("jing"))
					self:__onUseAft()
				end
			end)
		else
			self:__popText("您的精力不足")
		end
    end

    return true
end

return NewClass("RoleUseItem_JueJinChan", {AbstractUseItem}, RoleUseItem_JueJinChan)
000000000