local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_JunQingMiHan = {}

function RoleUseItem_JunQingMiHan:__doUseItem()
	local role = self._role
	local item = self._item

	role._iOutput:showJunQingMiHanConfirm(function()
		local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
		role:addItemCount(item.id,-1)
		local ControllLayer = require("app.views.layer.ControllLayer")
		local controllLayer = ControllLayer:getInstance()
		local mapLayer = controllLayer:getLayer("MapLayer")
		TeacherTask:deleteRoleByBaseId(mapLayer._currMap,mapLayer._currRoom.id,"quanzhenshimenrenwu1")
		mapLayer:setNeedRefreshMap()
		self:__popText("元军高手见军情密函被你销毁,便放弃了对你的追杀")
		self:__onUseAft()
	end,function()
		self:__popText("此等重要的物品怎能随便销毁。")
	end)
    return true
end

return NewClass("RoleUseItem_JunQingMiHan", {AbstractUseItem}, RoleUseItem_JunQingMiHan)
00