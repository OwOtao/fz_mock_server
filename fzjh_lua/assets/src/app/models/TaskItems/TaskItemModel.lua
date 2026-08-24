local TaskItemModel = {
	taskItems = {}
}

function TaskItemModel:init()
	if MapIsEmpty(self.taskItems) == true then
		return
	end
	self:createTaskItems()
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/03/14 14:27:15
-- @desc 初始化资源列表
function TaskItemModel:createTaskItems()

end

local function checkCanUseLuoPan(mapId,listStr)
	if type(mapId) ~= "string" or type(listStr) ~= "string" then
		return true
	end
	local list = string.split(listStr,",")
	for k,v in pairs(list) do 
		if v == mapId then
			return false
		end
	end
	return true
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/03/14 14:46:21
-- @desc 使用历练任务道具
function TaskItemModel:useTaskItem(itemAttr)

	local  currLayer =  MainControllLayer:getCurrLayer()
	-- if currLayer == "BiWuMainLayer"   then
	-- 	PopText(" 你心想遁离此地，但不料遁地失败，看来此地无法遁离！")
	-- 	return
	-- end
	local  TreasureList = require("script.others.Treasure")
	local  checkListStr
	if checkListStr == nil then
		checkListStr = Helper:getDef(TreasureList["挖宝禁止"],{})
		checkListStr = Helper:getDef(checkListStr["1"],{})
		checkListStr = Helper:getDef(checkListStr["stopcopy"],"")
	end
	local role = User:getRole()
	local map = role:getCurrMap()
	if currLayer == "BiWuMainLayer" or ( role:getCurrMapId() ~= nil and map ~= nil and map:getRoleIsInMap() == true and checkCanUseLuoPan(User:getRole():getCurrMapId(),checkListStr) == false )then
		PopText("你心想遁离此地，但不料遁地失败，看来此地无法遁离！")
		return
	end
	
	if not itemAttr then
		return
	end
	if not itemAttr.roomId and not itemAttr.mapId then
		if DEBUG_MODE == 1 then
			print("使用历练任务道具:",itemAttr.id,",没有填写itemAttr.roomId:",itemAttr.roomId,",itemAttr.mapId:",itemAttr.mapId)
		end
		return
	end

	local Item = require("app.models.item.Item")
	local item = Item:getOneItemByKey("dundifu")
	if not item then
		return
	end
	local map = role:getMapById(itemAttr.mapId)
	if not map then
		return
	end

	local roomId = self:getRandomRoomByRoomId(map,itemAttr.roomId)
	if not roomId then
		return
	end
	item:useDunDiFu(User:getRole(), itemAttr.mapId, roomId, function()
		local layer = MainControllLayer:getCurrLayer()
		if layer == "MapLayer" then
			local mapLayer = MainControllLayer:getLayer("MapLayer")
			local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
			mapLayer._currMap:doRoomConditionAndResult(mapLayer._currRoom.id)
			MapRoleLayer:hide()
		end
	end,1)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/03/14 15:01:52
-- @desc 获取随机房间
function TaskItemModel:getRandomRoomByRoomId(map,roomId)
	if not map or not roomId then
		return
	end
	local roomList = map:getNearRoomsExceptSelf(roomId,2)

	local TransmitRoomModel = require("app.models.transmitRoom.TransmitRoomModel")
	local filterList = TransmitRoomModel:getLilianFilterRoomList()

	if MapIsEmpty(filterList) == false then
		for i = #roomList,1,-1 do 
			if filterList[roomList[i]] then
				table.remove(roomList,i)
			end
		end
	end

	if MapIsEmpty(roomList) == true then
		return
	end
	for i = #roomList,1,-1 do 
		if roomList[i] == roomId then
			table.remove(roomList,i)
		end
	end
	roomId = roomList[math.random(1,#roomList)]
	return roomId
end

return TaskItemModel0000000000000000