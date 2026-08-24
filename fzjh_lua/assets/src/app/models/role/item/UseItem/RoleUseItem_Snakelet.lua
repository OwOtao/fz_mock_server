local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_Snakelet = {}

function RoleUseItem_Snakelet:__doUseItem()
	local role = self._role
	local item = self._item

	local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")

	if receiveTask.taskType ~= 4 or role:getFamilyId() ~= "baituoshan" then
		role:addItemCount(item.id,0-role:getItemCount(item.id))
		return
	end

	local currLayer = MainControllLayer:getCurrLayer()
	if currLayer ~= "MapLayer" then
		self:__popText("请前往指定地点牧蛇！")
	else
		local mapLayer = layer.ControllLayer:getLayer("MapLayer")
		if mapLayer._currMap.id ~= receiveTask.mapId then
			self:__popText("请前往指定地点牧蛇！")
			return
		end
		if mapLayer._currRoom.id ~= receiveTask.roomId then
			self:__popText("请前往指定地点牧蛇！")
			return
		end
		role:addItemCount(item.id,-1)
		role:addItemCount("shimenwupin30",1)
		self:__richPrint("放出幼蛇,2分钟之后可以收回")
		receiveTask.itemUseTime = GetTime()
		TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
		self:__onUseAft()
	end
    return true
end

return NewClass("RoleUseItem_Snakelet", {AbstractUseItem}, RoleUseItem_Snakelet)
0