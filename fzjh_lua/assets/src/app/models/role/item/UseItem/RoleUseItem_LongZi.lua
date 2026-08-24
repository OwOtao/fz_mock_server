local NewClass = require("third.class.NewClass")
local AbstractUseItem = require("app.models.role.item.UseItem.AbstractRoleUseItem")

local RoleUseItem_LongZi = {}

function RoleUseItem_LongZi:__doUseItem()
	local role = self._role
	local item = self._item

	local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
	local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")

	if receiveTask.taskType ~= 4 or role:getFamilyId() ~= "baituoshan" then
		role:addItemCount("shimenwupin30",0-role:getItemCount("shimenwupin30"))
		return
	end

	local currLayer = MainControllLayer:getCurrLayer()
	if currLayer ~= "MapLayer" then
		self:__popText("请前往牧蛇的地方将蛇回收！")
	else
		local mapLayer = MainControllLayer:getLayer("MapLayer")
		if mapLayer._currMap.id ~= receiveTask.mapId then
			self:__popText("请前往牧蛇的地方将蛇回收！")
			return
		end
		if mapLayer._currRoom.id ~= receiveTask.roomId then
			self:__popText("请前往牧蛇的地方将蛇回收！")
			return
		end
		if GetTime() - receiveTask.itemUseTime < 120 then
			self:__popText("难得出来一趟，让蛇再放风一会吧!")
			return
		end
		if math.random(1,2) == 1 then--进入战斗，战斗胜利方可收回幼蛇
			TeacherTask:createBaiTuoShanSpecialNPC(mapLayer._currMap,mapLayer._currMap.id,mapLayer._currRoom.id)

			--战斗胜利后收回幼蛇
		else--收回幼蛇
			self:__richPrint("你小心翼翼地将幼蛇收回了笼中。")
			role:addItemCount("shimenwupin30",-1)
			local receiveTask = TeacherTask:getTeacherTaskAttr("receiveTask")
			receiveTask.roomId = {}
			receiveTask.mapId = {}
			receiveTask.jiangli = 2
			TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
			TeacherTask:setTeacherTaskAttr("isComplete","Y")
		end
		self:__onUseAft()
	end
    return true
end

return NewClass("RoleUseItem_LongZi", {AbstractUseItem}, RoleUseItem_LongZi)
000000000