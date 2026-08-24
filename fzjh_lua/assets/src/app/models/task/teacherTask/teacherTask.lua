local TeacherTask = {
	-- id = 1,
	-- taskName = "RAN收集物资",
	-- qualityId = 1,
	-- taskType = 1,
	-- canAppoint = 0, 
	-- item = {
	-- }
	count = 2,
	date = 20170518,
	receiveTask = {},
	ContributionPoint = 100,
	taskTab = {},--本次的三个任务
	items = {},--任务需要使用的物品
}
local teacherjob = require("script.others.teacherjob")
local taskNpc = require("script.npc.taskNpc")
-- local ControllLayer = require("app.views.layer.ControllLayer")
function TeacherTask:getRoleTeacherTasks()

end
--获取今日师门任务获得的贡献点
function TeacherTask:getContributionPoint()
	return User:getRole():getTeacherTask().ContributionPoint
end
--检测是否加入门派
function TeacherTask:checkRoleFamily()
	local role = User:getRole()
	local family = role:getAttr("family")
	if family == nil then
		return false
	else
		if family.name == nil then
			return false
		else
			return true
		end
	end
end
--获取门派
function TeacherTask:getRoleFamily()
	return User:getRole():getAttr("family")
end
--检测等级是否达到要求
function TeacherTask:checkRoleLevel(level)
	if level then
		if User:getRole():getAttr("lv") >= level then
			return true
		else
			return false
		end
	else
		print("没有等级限制")
		return true
	end
end
function TeacherTask:checkRoleProgress(progress)
	if not progress then
		progress = 1
	end
	if User:getRole():getAttr("jindu") >= progress then
		return true
	else
		return false
	end
end
--获取人物等级
function TeacherTask:getRoleLevel()
	return User:getRole():getAttr("lv")
end
--检测江湖进度时候都达到要求
function TeacherTask:cheackRoleRiverLakeProgress(progress)
	if progress then
		if User:getRole():getAttr("jindu") >= progress then
			return true
		else
			return false
		end
	else
		print("江湖进度没有限制")
		return true
	end
end
--获取每日可接取师门任务的最大值
function TeacherTask:getTeacherTaskMaxNum()
	local count = nil
	print(self:getRoleLevel())
	if self:getRoleLevel() >= 100 and self:getRoleLevel() <= 200 then
		count = 7
	elseif self:getRoleLevel() >= 201 and self:getRoleLevel() <= 400 then
		count = 8
	elseif self:getRoleLevel() >= 401 and self:getRoleLevel() <= 600 then
		count = 9
	elseif self:getRoleLevel() >= 601 then
		count = 10
	end
	print("每日最大接取任务个数",count)
	return count
end
function TeacherTask:checkCanReceiveTask()
	local count = Helper:getDef(self:getTeacherTaskAttr("dCount"),0)
	local maxCount = self:getTeacherTaskMaxNum()
	if count < maxCount then
		return true
	else
		return false
	end
	-- body
end
function TeacherTask:getRandomTaskId(tab)
	if tab then
		local qualityWeightList = { 55,25,15,5}
		local taskId = math.random(1,#tab)--任务id
		local taskQuality  = Helper:RandomByWeight(qualityWeightList)--任务品质
		return taskId,taskQuality
	end
end
--计算任务有效时长
function TeacherTask:getTaskOverTime()
	local cuurTime = GetTime()
	local nowDate = tonumber(Helper:date("%Y%m%d", tonumber(cuurTime)))
	local tomorrowTime = Helper:getTimeStampWithStringDate(tostring(nowDate+1), 5)
	return tomorrowTime-cuurTime
end
function TeacherTask:addRoleAttr(name,value)
	if name and value and type(value) == "number" then
		User:getRole():addAttr(name,value)
	end
end
--删除任务相关的物品
function TeacherTask:deleteTeacherTaskItem()
	local role = User:getRole()
	if role:getTeacherTask().item then
		for k, v in pairs(role:getTeacherTask().item) do 
			role:addItemCount(v.itemId,0-v.count)
		end
		role:getTeacherTask().item = {}
	end
end
--a放弃任务
function TeacherTask:GiveUpTeacherTask()
	local role = User:getRole()
	role:getTeacherTask().receiveTask = {}
	self:addRoleAttr("money",-100)
end
--获取任务应获得的贡献点
function TeacherTask:getTeacherTaskGongXianReward(taskQuality,ContributionPoint)
	if not taskQuality then
		return nil 
	end
	local max,min
	if taskQuality == 1 then
		max = 400
		min = 100
	elseif taskQuality == 2 then
		max = 600
		min = 300
	elseif taskQuality == 3 then
		max = 1000
		min = 500
	elseif taskQuality == 4 then
		max = 1200
		min = 900
	end
	if 4000 - ContributionPoint <= min then
		return 4000 - ContributionPoint
	elseif 4000 - ContributionPoint >= max then
		return math.random(min,max)
	elseif 4000 - ContributionPoint > min and 4000 - ContributionPoint < max then
		return math,random(minx,4000 - ContributionPoint)
	end
end
--检测是否可以指派任务给同门
function TeacherTask:checkAppointTeacherTaskToFamily()

end

function TeacherTask:initTeacherTask()
	local role = User:getRole()
	local taskTab = teacherjob["Sheet1"]
	local familyId = self:getRoleFamily()
	local familyName = role:getFamilyName()
	local list = {}
	for k,v in pairs(taskTab) do 
		if v.family == familyName then
			local tab = {
				taskId = v.id,
				taskName = v.name,
				taskDsc = v.decri,
				taskType = v.type ,
				target = v.target,
				canAppoint = v.zhipai,
				award = v.award,
				awardRate = v.rate,
				itemId = v.item,
				NPCName = v.npcname
			}
			if v.type == 0 then
				tab.Collectjobroom = v.Collectjobroom
			end
			-- Helper:print_lua_table(v)
			local text = self:setTeskDsc(tab)
			for k,v in pairs(text) do 
				tab[tostring(k)] = v 
			end
			-- if tab.taskType == 4 then
			-- 	Helper:print_lua_table(tab)
			-- end
			table.insert(list,#list+1,tab)
		end
	end
	local taskList = self:refreshTeacherTask(list,3)
	role:setTeacherTaskTab(taskList)
	return taskList
end
function TeacherTask:setTeacherTeskReward(task)

end
-- 收集物资类任务 遁地符直接飞到小贩所在的房间；0
-- 门派寻访类任务 遁地符飞到目标NPC所在房间的附近2格；1
-- 护送重宝类任务 遁地符飞到目标NPC所在房间的附近3格；2
-- 门派切磋类任务 遁地符飞到目标NPC所在房间；3
-- 特殊类任务   遁地符直接飞到目标NPC所在房间。4
function TeacherTask:setTeskDsc(task)
	local dsc,tYpe,target,item,npcname = task.taskDsc,task.taskType,task.target,task.itemId,task.NPCName
	if not tYpe then
		return nil
	end
	print(dsc,tYpe,target,item,npcname)
	local role = User:getRole()
	local jindu = role:getAttr("jindu")
	local mapList = string.split(teacherjob["江湖进度"][tostring(jindu-1)].list,",")
	local tab = {} 

	if tYpe == 1 or tYpe == 3 then
		print("tYpe=======================================1")
		target = string.split(target,",")
		tab.npcBaseId = target[math.random(1,#target)]
		tab.npcId = tab.npcBaseId..tostring(Helper:getOnlyId())
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.roomId = self:getPossibleRoom(tab.mapId)
		dsc = self:spliceTaskDsc(dsc,"$N",npcname)
		local roomName
		tab.randomRoom = self:getRandomRoomList(tab.mapId,tab.roomId,2,1)[1]
		-- if tYpe == 1 then
		-- 	tab.randomRoom = self:getRandomRoomList(tab.mapId,tab.roomId,2,1)[1]
		-- 	-- Helper:print_lua_table(tab.randomRoom)
		-- elseif tYpe == 3 then
		-- 	tab.randomRoom = tab.roomId
		-- end
		roomName = self:getRoomName(tab.randomRoom,tab.mapId)
		local map = User:getRole():getMapById(tab.mapId)
		dsc = self:spliceTaskDsc(dsc,"$D",map.name..roomName)
		tab.taskDsc = dsc		
	elseif tYpe == 0 then
		local Collectjobroom = string.split(task.Collectjobroom,";")
		if #Collectjobroom ~= 2 then
			return {}
		end
		tab.mapId = Collectjobroom[1]
		tab.roomId = Collectjobroom[2]
		local roomName = self:getRoomName(tab.roomId,tab.mapId)
		tab.randomRoom = tab.roomId
		-- roomName,tab.randomRoom = self:getNearRoomIdAndRoomName(tab.roomId,tab.mapId)
		local map = User:getRole():getMapById(tab.mapId)
		dsc = self:spliceTaskDsc(dsc,"$D",map.name..roomName)
		tab.taskDsc = dsc
	elseif tYpe == 2 then
		print("tYpe==================6666666666666666666666=====================2")
		target = string.split(target,",")
		tab.npcBaseId = target[math.random(1,#target)]
		tab.npcId = tab.npcBaseId..tostring(Helper:getOnlyId())
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.roomId = self:getPossibleRoom(tab.mapId)
		dsc = self:spliceTaskDsc(dsc,"$N",npcname)
		local roomName
		tab.randomRoom = self:getRandomRoomList(tab.mapId,tab.roomId,3,1)[1]
		roomName = self:getRoomName(tab.roomId,tab.mapId)
		local map = User:getRole():getMapById(tab.mapId)
		dsc = self:spliceTaskDsc(dsc,"$D",map.name..roomName)
		tab.taskDsc = dsc
	elseif tYpe == 4 then
		print("tYpe==================6666666666666666666666=====================4")
		tab = self:dealFamilySpecialTeacherTask(dsc)
	end
	print("task.taskType:",task.taskType,"roomId:",rab,roomId,"randomRoom:",tab.randomRoom)
	return tab
end
function TeacherTask:spliceTaskDsc(str,char,name)
	if not str or not char or not name then
		return
	end
	local str = string.split(str,char)
	local rStr = ""
	for k,v  in pairs(str) do 
		rStr = rStr..v
		if k ~= #str then
			rStr = rStr .. name
		end
	end
	return rStr
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 16:14:15
-- @desc 从配置表中的NPC可能出现的地方随机抽取一个房间
function TeacherTask:getPossibleRoom(mapid)
	if not mapid then
		return
	end
	for k,v in pairs(teacherjob["NPC可能出现的地方"]) do 
		if v.copyiD == mapid then
			local roomList = string.split(v.possibleRoom,",")
			return roomList[math.random(1,#roomList)]
		end
	end
end
function TeacherTask:getPossibleRoomList(mapId,num)
	if not mapId then
		return
	end 
	if not num then
		return 
	end
	local tab = clone(teacherjob["NPC可能出现的地方"])
	local list = {}
	for k,v in pairs(tab) do
		if v.copyiD == mapId then
			local roomList = string.split(v.possibleRoom,",")
			for i=1,num do 
				local random = math.random(1,#roomList)
				table.insert(list,#list+1,roomList[random])
				table.remove(list,random)
			end
			return list
		end
	end
end
function TeacherTask:getRandomRoomList(mapId,roomId,step,num)
	local rewList = {}
	if mapId and roomId then
		local currMap = User:getRole():getMapById(tostring(mapId))
		if step then
			local list = currMap:getNearRooms(roomId,step) 
			for i=1,num do 
				table.insert(rewList,#rewList+1,list[math.random(1,#list)])
			end
		end
	end	
	return rewList
end
function TeacherTask:getNearRoomIdAndRoomName(roomId,mapId)
	if not roomId or not mapId then
		return
	end
	local currMap = User:getRole():getMapById(tostring(mapId))
	local roomList = currMap:getNearRoomsExceptSelf(roomId,1)

	for i=#roomList,1,-1 do
		if roomList[i] == roomId then
			table.remove(roomList,i)
		end
	end
	local room
	if #roomList == 0 then
		room = roomId
	else
		room = roomList[math.random(1,#roomList)]
	end
	for k,v in pairs(currMap["room"]) do 
		if k == room then
			return v.name,room
		end
	end
	print("没有搜索到附近房间:",roomId,#roomList)
	Helper:print_lua_table(roomList)
	assert(nil)
end
function TeacherTask:getRoomName(roomId,mapId)
	if not roomId or not mapId then
		return
	end
	local currMap = User:getRole():getMapById(tostring(mapId))
	for k,v in pairs(currMap["room"]) do 
		if k == roomId then
			return v.name
		end
	end
end
--刷新任务
function TeacherTask:refreshTeacherTask(taskTab,num)
	if taskTab == nil or taskTab == {} then
		PopText("出错")
		return
	end
	local tab = clone(taskTab)
	local rewards = {}
	for i=1,num do 
		local taskId,taskQuality = self:getRandomTaskId(tab)
		if tab[taskId].taskType == 0 then
			local targetList = string.split(tab[taskId].target,",")
			if #targetList == 2 then
				tab[taskId].target = targetList[1]
				tab[taskId].targetNum = targetList[2]
			end
		end
		tab[taskId].taskQuality = taskQuality
		local ward = string.split(tab[taskId].award,";")
		local rate = string.split(tab[taskId].awardRate,",")[taskQuality]
		rate = string.split(rate,";")
		tab[taskId].reward = {}
		for k,v in pairs(ward) do 
			local weight = {
				[1] = tonumber(rate[k]),
				[2] = 100 - tonumber(rate[k])
			}
			local randomWeight = Helper:RandomByWeight(weight)
			if randomWeight == 1 then
				tab[taskId].reward[v] = 1
			end
		end
		tab[taskId].award = nil
		tab[taskId].awardRate = nil
		table.insert(rewards,#rewards+1,tab[taskId])
		table.remove(tab,taskId)
	end
	return rewards
end

--接任务
function TeacherTask:receiveTaskByTaskId(taskId)
	local role = User:getRole()
	local receiveTask = role:getReceiveTask()
	if receiveTask ~= 0 then
		PopText("当前还有任务未完成"..receiveTask.taskName)
		print("11111111111111111111111111111111111111111111111111111111111")
		return
	end
	local count = self:getTeacherTaskMaxNum()
	if count == nil then
		print("2222222222222222222222222222222222222222222222222222222222222222")

		return 
	end
	if count - self:getTeacherTaskNum() >= 0 then
		--接取任务

		print("3333333333333333333333333333333333333333333333333333333333")

		local tab = self:getTaskById(taskId)
		tab.taskOId = Helper:getOnlyId()
		tab.overTime = self:getTaskOverTime()
		role:setReceiveTask(tab)
		role:removeTaskFromTeacherTaskTab(taskId)
		PopText("您已成功接取任务")
	else
		--已经达到当日任务数量上限，不可接取
		PopText("今日任务已经达到上限,明日再来吧")
	end
end
--获取任务
function TeacherTask:getTaskById(taskId)
	if taskId then
		Helper:print_lua_table(self:getTeacherTaskAttr("taskTab"))
		for k,v in pairs(self:getTeacherTaskAttr("taskTab")) do 
			if v.taskId == taskId then
				return v
			end
		end
	end
end
function TeacherTask:initTaskTable()
	return {}
end
--获取当天已接取师门任务个数
function TeacherTask:getTeacherTaskNum()
	local role = User:getRole()
	local dateStr = tonumber(Helper:date("%Y%m%d", tonumber(GetTime())))
	if role:getTeacherTask().date ~= dateStr then
		role:getTeacherTask().date = dateStr
		role:getTeacherTask().count = 0
		return role:getTeacherTask().count
	else 
		return role:getTeacherTask().count
	end
end
function TeacherTask:setTeacherTaskNum(num)
	if num then
		local role = User:getRole()
		local dateStr = tonumber(Helper:date("%Y%m%d", tonumber(GetTime())))
		if role:getTeacherTask().date ~= dateStr then
			role:getTeacherTask().count = 0
		end
		role:getTeacherTask().count = role:getTeacherTask().count + num
	end
end
--获取师门任务信息并判断信息是否过期
function TeacherTask:getTeacherTaskAttr(name)
	local role = User:getRole()
	local date = role:getTeacherTaskAttr("date")
	local currTime = GetTime()
	local currDate  = tonumber(Helper:date("%Y%m%d", tonumber(currTime)))
	local refreTime 
	if date == nil or date == 0 then
		self:refreshTeacherTaskList()
		return role:getTeacherTaskAttr(name)
	end
	if name ~= "taskTab" then
		if date ~= currDate then
			if currDate - date  == 1 then
				refreTime = Helper:getTimeStampWithStringDate(tostring(currDate), 5)
				if refreTime <= currTime then
					self:refreshTeacherTaskList()
					return role:getTeacherTaskAttr(name)
				else
					return role:getTeacherTaskAttr(name)
				end
			else
				self:refreshTeacherTaskList()
				return role:getTeacherTaskAttr(name)
			end
		else
			return role:getTeacherTaskAttr(name)
		end
	else
		if role:getTeacherTaskAttr(name) then
			return role:getTeacherTaskAttr(name)
		else
			return 0
		end
	end
end

function TeacherTask:setTeacherTaskAttr(name,value)
	local role = User:getRole()
	local date = role:getTeacherTaskAttr("date")
	local currTime = GetTime()
	local currDate  = tonumber(Helper:date("%Y%m%d", tonumber(currTime)))
	local refreTime 
	if date == nil or date == 0 then
		self:refreshTeacherTaskList()
		role:setTeacherTaskAttr(name,value)
	end
	if name ~= "taskTab" then
		if date ~= currDate then
			if currDate - date  == 1 then
				refreTime = Helper:getTimeStampWithStringDate(tostring(currDate), 5)
				if refreTime >= currTime then
					self:refreshTeacherTaskList()
					role:setTeacherTaskAttr(name,value)
				else
					role:setTeacherTaskAttr(name,value)
				end
			else
				self:refreshTeacherTaskList()
				role:setTeacherTaskAttr(name,value)
			end
		else
			role:setTeacherTaskAttr(name,value)
		end
		if name == "isComplete" and value == "Y" then
			local receiveTask = role:getTeacherTaskAttr("receiveTask")
			local color = self:getTaskNameStrColor(receiveTask)
			RichPrint("main","【师门任务:"..color..receiveTask.taskName.."NOR】任务完成，快回去复命吧。")
		end
	else
		local tab = role:getTeacherTaskAttr("taskTab")--只可以一个一个任务的插入
		local insert = false
		for k,v in pairs(tab) do 
			if taskId ~= value.taskId then
				insert = true
			else
				v = value
			end
		end
		if insert == true then
			table.insert(tab,#tab+1,value)
		end
		role:setTeacherTaskAttr("taskTab",tab)
	end
end
function TeacherTask:refreshTeacherTaskList()
	local role = User:getRole()
	local receiveTask = role:getTeacherTaskAttr("receiveTask")
	receiveTask = Helper:getDef(receiveTask,{})
	if receiveTask and receiveTask.itemId and receiveTask.taskType ==2 then
		local item = role:getItem(receiveTask.itemId)
		print("扣除任务物品")
		if item then
			role:addItemCount(receiveTask.itemId,0-item.count)
		end
	elseif receiveTask and receiveTask.itemId and receiveTask.taskType == 4 then
		if receiveTask.itemId ~= nil and receiveTask.itemId ~= 0 then
			local item = role:getItem(receiveTask.itemId)
			print("扣除任务物品")
			if item then
				role:addItemCount(receiveTask.itemId,0-item.count)
			end	
		end
		if receiveTask.itemgift ~= nil and receiveTask.itemgift ~=0 then
			local item = role:getItem(receiveTask.itemgift)
			print("扣除任务物品")
			if item then
				role:addItemCount(receiveTask.itemgift,0-item.count)	
			end
		end
		local item = role:getItem("shimenwupin30")
		if item then
			role:addItemCount("shimenwupin30",0-item.count)
		end
		if role:getItem("shimenwupin36") then
			role:addItemCount("shimenwupin36",role:getItem("shimenwupin36").count)
		end
		if role:getItem("shimenwupin35") then
			role:addItemCount("shimenwupin35",role:getItem("shimenwupin35").count)
		end
	end
	role:setTeacherTaskAttr("count",0)
	role:setTeacherTaskAttr("dCount",0)
	role:setTeacherTaskAttr("refreshCount",0)
	role:setTeacherTaskAttr("appointRefreshCount",0)
	role:setTeacherTaskAttr("appointCount",0)
	role:setTeacherTaskAttr("receiveTask",0)
	role:setTeacherTaskAttr("ContributionPoint",0)
	role:setTeacherTaskAttr("date",tonumber(Helper:date("%Y%m%d", tonumber(GetTime()))))
	role:setTeacherTaskAttr("isAppoint","N")
	role:setTeacherTaskAttr("giveUpTime",GetTime()-5*60)
	role:setTeacherTaskAttr("isComplete","N")
	User:getRole():removeRoleCurrState(ROLE_CURR_STATE_SHIMEN)
end
--根据任务的稀有度获取任务名称颜色
function TeacherTask:getTaskNameColor(task)
	if not task then
		return {r = 0,g = 0,b = 0}
	end
	if not task.taskQuality then 
		return {r = 0,g = 0,b = 0}
	end
	if task.taskQuality == 1 then
		return {r = 57, g = 219, b = 92}
	elseif task.taskQuality == 2 then
		return {r = 11, g = 128, b = 246}
	elseif task.taskQuality == 3 then
		return {r = 204, g = 51, b = 204}
	elseif task.taskQuality == 4 then
		return {r = 236, g = 101, b = 26}
	else
		return {r = 0,g = 0,b = 0}
	end
end
function TeacherTask:getTaskNameStrColor(task)
	if not task then
		return ""
	end
	if not task.taskQuality then 
		return ""
	end
	if task.taskQuality == 1 then
		return "GRN"
	elseif task.taskQuality == 2 then
		return "BLU"
	elseif task.taskQuality == 3 then
		return "HIM"
	elseif task.taskQuality == 4 then
		return "ORN"
	else
		return ""
	end
end
--完成任务领取奖励
function TeacherTask:getTeacherTaskReward()
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local point = 0
	if receiveTask.taskQuality == 1 then
		point = math.random(100,400)
	elseif receiveTask.taskQuality == 2 then
		point = math.random(300,600)
	elseif receiveTask.taskQuality == 3 then
		point = math.random(500,1000)
	elseif receiveTask.taskQuality == 4 then
		point = math.random(900,1200)
	end
	local ContributionPoint = self:getTeacherTaskAttr("ContributionPoint")
	point = math.min(4000 - ContributionPoint,point)
	--增加师门贡献点
	return point
end
--进入副本生成任务相关的NPC
function TeacherTask:createTeacherTaskPNC(map,mapId)
	local roomList = User:getRole():getMapById(mapId)["room"]--map:getRoom
	if roomList then
		for k,v in pairs(roomList) do 
			self:createFamilySpecialNPC(map,k)
		end
	end
end
function TeacherTask:setReceiveTaskComplete()
	self:setTeacherTaskAttr("isComplete","Y")
end
--刷新任务列表需要的元宝数量
function TeacherTask:getRefreshTeacherTaskGoldCount()
	local count  = self:getTeacherTaskAttr("refreshCount")
	local number = (count -3+1)*10
	if number >100 then
		number = 100
	end
	return number
end
function TeacherTask:getAppointRefreshTeacherTaskGoldCount()
	local count  = self:getTeacherTaskAttr("appointRefreshCount")
	local number = (count -3+1)*10
	if number >100 then
		number = 100
	end
	return number
end
function TeacherTask:getFamilyDsc()
	local role = User:getRole()
	local family = teacherjob["jiequ"]
	local Family = require("app.models.family.Family")
	local familyName = Family:getFamily(role:getAttr("family").name)
	for k,v in pairs(family) do 
		if v.name == familyName.name then
			return v
		end
	end
	return nil
end
function TeacherTask:getSpecialTaskList(list,familyId)
	if not list or type(list) ~= "table" or not familyId then
		return nil 
	end
	for k, v in pairs(list) do
		if v.familyId == familyId then
			Helper:print_lua_table(v)
			return v
		end
	end
end

--[[

local list = 
{
	mengpai = 
	{
		
	},
	{
		
	}
}

local tab = 
{
	mapId = nil,
	roomId = {},
	randomRoom = nil,
	npcBaseId = {},
	npcId = {},
	name = {},
	attackNPC = {},
	itemgift = {},
	giftNPC = {},
	meet = {},
	jietouName = {},
	jietouMapId = {},
	jietouRoomId = {},
	jietouNpcBaseId = {},
	jietouNpcId = {},
	taskDsc = {}
}

]]



--处理门派特殊任务
function TeacherTask:dealFamilySpecialTeacherTask(dsc)
	local familySpecialTask = teacherjob["特殊任务"]
	local role = User:getRole()
	local familyId = User:getRole():getAttr("family").name
	local list = self:getSpecialTaskList(familySpecialTask,familyId)
	local jindu = role:getAttr("jindu")
	local mapList = string.split(teacherjob["江湖进度"][tostring(jindu-1)].list,",")
	local tab = {}
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.roomId = self:getPossibleRoom(tab.mapId)
		tab.randomRoom = tab.roomId
		tab.npcBaseId = list.NPCId
	if familyId == "gumu" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = list.NPCId
		tab.npcId = tab.npcBaseId..tostring(Helper:getOnlyId())
	elseif familyId == "huashan" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,3)
		tab.randomRoom = tab.roomId[1]
		tab.npcBaseId = list.NPCId
		tab.npcId = {}
		tab.name = Helper:getRandomName("男")
		tab.attackNPC = ""
		for k , v in pairs(tab.roomId) do 
			tab.npcId[k] = tab.npcBaseId..tostring(Helper:getOnlyId())
		end		
	elseif familyId == "gaibang" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(list.mapId,";")
		local randomMap = math.random(1,#mapList)
		local mapRoom = string.split(mapList[randomMap],",")
		tab.mapId = mapRoom[1] 
		tab.randomRoom = mapRoom[2]
		tab.roomId = tab.randomRoom
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.npcId = tab.npcBaseId[1]..tostring(Helper:getOnlyId())
		tab.money = 0
	elseif familyId == "quanzhen" then
		mapList = string.split(list.mapId,";")
		local randomMap = math.random(1,#mapList)
		tab.mapId = mapList[randomMap]
		tab.maplist = mapList
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.itemgift = "shimenwupin32"
		tab.giftNPC = "NPCshimenwupin32"..tostring(Helper:getOnlyId())
		tab.giftNPCBaseId = "NPCshimenwupin32"
		local npc = string.split(list.NPCId,";")
		tab.npcBaseId = npc[1]
		tab.npcId = npc[1]..tostring(Helper:getOnlyId())
		tab.meet = {
			[1] = 10,
			[2] = 90 ,
		}
		table.remove(mapList,randomMap)
		tab.name = Helper:getRandomName("男")
		tab.jietouName = "接头人"
		tab.jietouMapId = mapList[math.random(1,#mapList)]
		tab.jietouRoomId = self:getPossibleRoom(tab.jietouMapId)
		tab.jietouNpcBaseId = npc[2]
		tab.jietouNpcId = npc[2]..tostring(Helper:getOnlyId())
		--领取军情密函信息
		local roomName = self:getRoomName(tab.roomId,tab.mapId)
		dsc = self:spliceTaskDsc(dsc,"$N1",tab.name)
		local map = User:getRole():getMapById(tab.mapId)
		dsc = self:spliceTaskDsc(dsc,"$D1",map.name..roomName)
		--接头人信息
		roomName = self:getRoomName(tab.jietouRoomId,tab.jietouMapId)
		dsc = self:spliceTaskDsc(dsc,"$N2",tab.jietouName)
		map = User:getRole():getMapById(tab.jietouMapId)
		dsc = self:spliceTaskDsc(dsc,"$D2",map.name..roomName)
		tab.taskDsc = dsc

	elseif familyId == "baituoshan" then--baituoshan ,--日常牧蛇
		print("==============================================================")
		print("list.mapId:",list.mapId)
		tab.mapId = self:getRandomFromTable(self:stringSplit(list.mapId,";"))
		print(tab.mapId)
		tab.roomId = self:getPossibleRoom(tab.mapId)
		tab.randomRoom = tab.roomId
		tab.npcBaseId = list.NPCId
		tab.itemId = "shimenwupin29"
		tab.npcId = tab.npcBaseId ..tostring(Helper:getOnlyId())

	elseif familyId == "riyueshenjiao" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,3)
		-- tab.randomRoom = tab.roomId[1]
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.success = tab.npcBaseId[math.random(1,#tab.npcBaseId)] 
		tab.npcId = {}
		for k,v in pairs(tab.roomId) do 
			tab.npcId[k] = tab.npcBaseId[k]..tostring(Helper:getOnlyId())
		end
		tab.itemId = "shimenwupin33"
		-- tab.npcId = tab.npcBaseId..tostring(Helper:getOnlyId())
	elseif familyId == "dali" then
		tab.words = {
			[1] = "檀香袅袅，你心中一片澄明，恍惚间，你似乎看到佛祖坐在高台上说法，迦叶尊者站在一旁拈花微笑，天众、龙众也在一旁凝神谛听。",
			[2] = "檀香袅袅，你心中一片澄明，恍惚间，你似乎看到佛祖坐在高台上说法，迦叶尊者站在一旁拈花微笑，夜叉、乾达婆也在一旁凝神谛听。",
			[3] = "檀香袅袅，你心中一片澄明，恍惚间，你似乎看到佛祖坐在高台上说法，迦叶尊者站在一旁拈花微笑，阿修罗、迦楼罗也在一旁凝神谛听。",
			[4] = "檀香袅袅，你心中一片澄明，恍惚间，你似乎看到佛祖坐在高台上说法，迦叶尊者站在一旁拈花微笑，紧那罗、摩喉罗伽也在一旁凝神谛听。",
		}
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(list.mapId,";")
		local randomMap = math.random(1,#mapList)
		local mapRoom = string.split(mapList[randomMap],",")
		tab.mapId = mapRoom[1] 
		tab.randomRoom = mapRoom[2]

		-- tab.mapId = mapList[math.random(1,#mapList)]
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.roomId = tab.randomRoom
		-- tab.randomRoom = tab.roomId
		tab.npcId = {}
		for k,v in pairs(tab.npcBaseId) do 
			tab.npcId[k] = v..tostring(Helper:getOnlyId())
		end
		tab.success = {
			[1] = false,
			[2] = false,
			[3] = false,
			[4] = false,
			["阿修罗"] = false,
		}
		list.npcName = "壁画"
	elseif familyId == "youming" then
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,2)
		tab.randomRoom = tab.roomId[1]
		tab.npcBaseId = list.NPCId
		tab.npcId = {}
		tab.words = {}
		tab.types = {}
		tab.name = {}
		tab.successWord = {}
		local types = {
			[1] = "吊死鬼",
			[2] = "淹死鬼",
			[3] = "无头鬼",
		}
		local words = {
			[1] = "$N出身大富之家，钟鸣鼎食；\n$N年轻时风流成性，相貌英俊，祸害了不少良家妇女；\n$N曾与一匠户女子相恋，之后始乱终弃，女子自缢身亡；\n$N生财有道，左右逢源，四处打点，竟渐渐有善人之名。",
			[2] = "$N出身于书香门第，虽不大富大贵，也是衣食无忧；\n$N年轻时与一青楼女子相恋，几乎到了谈婚论嫁的地步；\n$N后来省试及第，并被一贵人相中，将女儿许配与他；为了与青楼女子撇清关系，他亲手将其推入河中；\n$N与贵人女儿成亲后，顺风顺水，在有心人鼓吹下，才子之名更是传了开来。",
			[3] = "$N武举人出身，孔武有力，在地方上小有威名；\n$N年轻时家境窘迫，曾与匪盗勾结，做过一些没本钱的买卖；\n$N曾劫杀过一个商贾，并丢弃尸荒野，尸首分离；\n$N掩盖得很好，加上多年来沽名钓誉，在坊间还渐有急公好义之名。",
		}
		local successWord = {
			["吊死鬼"] = "RED翠儿，我是对不起你，但我可没有害死你呀，是你自己……啊我错了、是、我的错是我的错……这些财物你拿去吧，以后你别来找我了，求你……（$N整个人晕了过去）",
			["淹死鬼"] = "RED霜儿，我也不想的，这些年来我日夜思念你，无奈阴阳两隔……你这是向我索命来的吗……我愿意补偿你，这是我的全部身家，你拿去吧，放过我……（$N整个人晕了过去）",
			["无头鬼"] = "RED别、杀我、别杀我……你是刘掌柜？……小弟我当年是鬼迷心窍，才动了歹念……这些年来我已经痛改前非了……补偿？好，我愿意补偿！……这些财宝你拿去吧……啊！（$N整个人晕了过去）",
		}
		tab.daoju = {
			[1] = "shimenwupin34",
		}
		for i=1,2 do 
			tab.name[i] = Helper:getRandomName("男")
			tab.npcId[i] = tab.npcBaseId..tostring(Helper:getOnlyId())
			local random = math.random(1,#types)
			tab.types[i] = types[random]
			tab.words[i] = self:spliceTaskDsc(words[random],"$N",tab.name[i])
			tab.successWord[types[random]] = self:spliceTaskDsc(successWord[tab.types[i]],"$N",tab.name[i])
			table.remove(types,random)
			table.remove(words,random)
			local roomName = self:getRoomName(tab.roomId[i],tab.mapId)
			dsc = self:spliceTaskDsc(dsc,"$N"..tostring(i),tab.name[i])
			local map = User:getRole():getMapById(tab.mapId)
			dsc = self:spliceTaskDsc(dsc,"$D"..tostring(i),map.name..roomName)
			tab.taskDsc = dsc
		end
	elseif familyId == "shaolin" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,5)
		tab.randomRoom = tab.roomId[1]
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.npcId = {}
		tab.sex = {}
		tab.success = {}
		local successList = {
			[1] = 1,
			[2] = 2,
			[3] = 1,
			[4] = 2,
			[5] = 1,
		}
		for i=1,5 do 
			if math.random(1,2) == 1 then
				tab.npcId[i] = tab.npcBaseId[1]..tostring(Helper:getOnlyId())
				tab.sex[i] = 1
			else 
				tab.npcId[i] = tab.npcBaseId[2]..tostring(Helper:getOnlyId())
				tab.sex[i] = 2
			end
			local successRandom = math.random(1,#successList)
			tab.success[i] = successList[successRandom]
			table.remove(successList,successRandom)
		end
		print(2)
	elseif familyId == "emei" then
		tab.mapId = "fb11"
		tab.roomId = "fb11_02"
		tab.randomRoom = tab.roomId
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.npcId = {}
		for k,v in pairs(tab.npcBaseId) do 
			tab.npcId[k] = v..tostring(Helper:getOnlyId())
		end
		list.npcName = "大铁锅"
		tab.itemId = "shimenwupin31"
	elseif familyId == "wudang" then --杀死或者切磋 wudang
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,3)
		tab.randomRoom = tab.roomId[1]
		tab.npcBaseId = list.NPCId
		tab.npcId = {}
		for k,v in pairs(tab.roomId) do 
			tab.npcId[k] = tab.npcBaseId..tostring(Helper:getOnlyId())
		end
	elseif familyId == "wudu" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		local randomNum = math.random(2,4)
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,randomNum)
		tab.randomRoom = tab.roomId[1]	
		tab.npcBaseId = list.NPCId
		tab.npcId = {}
		tab.success = {}
		for k,v in pairs(tab.roomId) do 
			tab.npcId[k] = list.NPCId..tostring(Helper:getOnlyId())
			tab.success[k] = math.random(1,2)
		end
	elseif familyId == "tiezhang" then
		mapList = string.split(list.mapId,";")
		local randomMap = mapList[math.random(1,#mapList)]
		local mapRoom = string.split(randomMap,",")
		tab.mapId = mapRoom[1]
		if mapRoom[2] ~= nil then
			tab.randomRoom = mapRoom[2]
		else
			tab.randomRoom = self:getPossibleRoom(tab.mapId)
		end
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,5)
		tab.npcBaseId = list.NPCId
		tab.npcId = {}
		tab.success = {}
		tab.name = list.npcName
		for i =1,#tab.roomId do 
			tab.npcId[i] = tab.npcBaseId..tostring(Helper:getOnlyId())
			tab.success[i] = math.random(1,2)
		end
		tab.hasAsk = {}
	elseif familyId == "mizong" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.npcId = {}
		tab.npcId[1] =tab.npcBaseId[1]..tostring(Helper:getOnlyId())
		tab.success = Helper:RandomByWeight({[1] = list.probability , [2] = 100 - list.probability})
		if tab.success == 1 then
			tab.npcId[2] =tab.npcBaseId[2]..tostring(Helper:getOnlyId())
			tab.npcId[3] =tab.npcBaseId[2]..tostring(Helper:getOnlyId())
		end
		tab.name = {[1] = "美女", [2] = "无名侠客"}
	elseif familyId == "murong" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = list.NPCId
		tab.npcId = tab.npcBaseId ..tostring(Helper:getOnlyId())
	elseif familyId == "mingjiao" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = list.NPCId
		tab.npcId = tab.npcBaseId ..tostring(Helper:getOnlyId())

	elseif familyId == "taohuadao" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = list.NPCId
		tab.npcId = tab.npcBaseId ..tostring(Helper:getOnlyId())
	elseif familyId == "tianshan" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.npcBaseId = list.NPCId
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,1,5)--getRandomRoomList(mapId,roomId,step,num)
		tab.npcId = {}
		tab.success = {}
		for k, v in ipairs(tab.roomId) do 
			tab.success[k] = math.random(1,2)
			tab.npcId[k] = list.NPCId..tostring(Helper:getOnlyId())
		end
		-- tab.itemId = "shimenwupin36"
		tab.hasAsk = {}
	elseif familyId == "luoyue" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.roomId = self:getPossibleRoom(tab.mapId)
		tab.randomRoom = tab.roomId
		tab.npcBaseId = list.NPCId
		tab.npcId = list.NPCId..tostring(Helper:getOnlyId())
	elseif familyId == "haijing" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(list.mapId,";")
		local randomMap = mapList[math.random(1,#mapList)]
		local mapRoom = string.split(randomMap,",")
		tab.mapId = mapRoom[1]
		if mapRoom[2] ~= nil then
			tab.randomRoom = mapRoom[2]
		else
			tab.randomRoom = self:getPossibleRoom(tab.mapId)
		end
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,3,5)
		if DEBUG_MODE == 1 then
			tab.randomRoom = tab.roomId[1]
		end
		-- tab.randomRoom = tab.roomId[1]
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.success = {}
		tab.npcId = {}
		for k,v in pairs(tab.roomId) do 
			tab.success[k] = math.random(1,2)
			if tab.success[k] == 1 then
				tab.npcId[k] = tab.npcBaseId[1]..tostring(Helper:getOnlyId())
			else
				tab.npcId[k] = tab.npcBaseId[2]..tostring(Helper:getOnlyId())
			end
		end
	elseif familyId == "kunlun" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = list.NPCId
		tab.npcId = tab.npcBaseId..tostring(Helper:getOnlyId())
	elseif familyId == "kongtong" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)	
		tab.roomId = self:getRandomRoomList(tab.mapId,tab.randomRoom,1,3)
		tab.randomRoom = tab.roomId[1]
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.types = {}
		tab.npcId = {}
		tab.success = {}
		for k,v in pairs(tab.roomId) do 
			local ranNum = math.random(1,2)
			print("ranNum = ", ranNum)
			tab.types[k] = ranNum
			if tab.types[k] == 1 then
				tab.npcId[k] = tab.npcBaseId[1]..tostring(Helper:getOnlyId())
				tab.success[k] = 1
			else
				tab.npcId[k] = {}
				for i=1,2 do 
					tab.npcId[k][i] = tab.npcBaseId[i+1]..tostring(Helper:getOnlyId())
				end
				local randomNum = math.random(1, 2)
				print("randomNum = ", randomNum)
				tab.success[k] = randomNum
			end
		end
	elseif familyId == "guanfu" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(list.mapId,";")
		local randomMap = math.random(1,#mapList)
		local mapRoom = string.split(mapList[randomMap],",")
		tab.mapId = mapRoom[1] 
		tab.randomRoom = mapRoom[2]
		print(tab.mapId,tab.randomRoom)
		-- tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.npcId = {}
		tab.npcId[1] = tab.npcBaseId[1]..tostring(Helper:getOnlyId())
		-- tab.npc = {}
		for i=1,2 do
			tab.npcId[i+1] = tab.npcBaseId[2]..tostring(Helper:getOnlyId())
		end
		list.npcName = string.split(list.npcName,";")[1]
	elseif familyId == "tangmen" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom
		tab.npcBaseId = string.split(list.NPCId,";")
		tab.npcId = tab.npcBaseId[1]..tostring(Helper:getOnlyId())	
	elseif familyId == "xingxiu" then
		local num = 1
		if tonumber(jindu) >= 21 then
			num = 21
		else
			num = tonumber(jindu)
		end
		num = num - 1
		mapList = string.split(teacherjob["江湖进度"][tostring(num)].list,",")
		tab.mapId = mapList[math.random(1,#mapList)]
		tab.randomRoom = self:getPossibleRoom(tab.mapId)
		tab.roomId = tab.randomRoom	
		tab.npcBaseId = list.NPCId
		tab.npcId = list.NPCId..tostring(Helper:getOnlyId())
		tab.name = Helper:getRandomName("男")
		list.npcName = tab.name
	else
		tab.npcId = list.NPCId..tostring(Helper:getOnlyId())
	end
	local roomName = self:getRoomName(tab.randomRoom,tab.mapId)
	dsc = self:spliceTaskDsc(dsc,"$N",list.npcName)
	local map = User:getRole():getMapById(tab.mapId)
	dsc = self:spliceTaskDsc(dsc,"$D",map.name..roomName)
	tab.taskDsc = dsc
	return tab
end
function TeacherTask:stringSplit(str,char)
	if not str or not char then
		return
	end
	local list = string.split(str,char)
	return list
end
function TeacherTask:getRandomFromTable(tab)
	if not tab or type(tab) ~= "table" then
		return
	end
	return tab[math.random(1,#tab)]
end
--判断房间内是否已经有需要常见的人物
function TeacherTask:checkRoleIsInRoom(map,roomId,roleId)
	-- if not map and not roomId then
	-- 	return
	-- end
	-- local roleList = map:getRoomRoleList(roomId)
	-- if roleList then
	-- 	for k,v in pairs(roleList) do 
	-- 		local item = map:getRole(v)
	-- 		if item.type == "item" and item.subType == "尸体" then
	-- 			if item.aliveId == roleId then
	-- 				return true
	-- 			end
	-- 			print("item.subType,",item.subType,item.type,aliveName,item.aliveId)
	-- 		elseif item.type == "role" then
	-- 			if item.id == roleId then
	-- 				return true
	-- 			end
	-- 		end
	-- 	end
	-- 	return false
	-- end
	return false
end
function TeacherTask:checkRoleOrCorpseIsInRoom(map,roomId,roleId)

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 15:43:46
-- @desc 创建门派特殊任务NPC
function TeacherTask:createFamilySpecialNPC(map,roomId)

	if not map or not roomId then
		if  not map then
			print("map is nil")
		end
		if not roomId then
			print("roomId is nil")
		end
		print("*****************返回************************")
		return
	end
	print("roomId:",roomId)
	local familyId = User:getRole():getAttr("family").name
	if familyId == "baituoshan" then	-- 白驼山	 baituoshan
		-- self:createBaiTuoShanSpecialNPC(map,map.id,roomId )

	elseif familyId == "dali" then-- 天龙寺	 dali
		self:createTianLongSpecialNPC(map,map.id,roomId)

	elseif familyId == "emei" then-- 峨眉派	 emei
		self:createEMeiSpecialNPC(map,map.id,roomId)

	elseif familyId == "gaibang" then-- 丐帮	 gaibang
		self:createGaiBangSpecialNPC(map,map.id,roomId)

	elseif familyId == "gumu" then-- 古墓派	 gumu
		self:createGuMuSpecialNPC(map,map.id,roomId)

	elseif familyId == "huashan" then-- 华山宗	 huashan
		self:createHuaShanSpecialNPC(map,map.id,roomId)

	elseif familyId == "kunlun" then-- 昆仑派	 kunlun
		self:createKunLunSpecialNPC(map,map.id,roomId)

	elseif familyId == "mingjiao" then-- 明教	 mingjiao
		self:createMingJiaoSpecialNPC(map,map.id,roomId)

	elseif familyId == "mizong" then-- 雪山寺	 mizong
		self:createMiZongSpecialNPC(map,map.id,roomId)

	elseif familyId == "murong" then-- 慕容山庄	 murong
		self:createMuRongSpecialNPC(map,map.id,roomId)

	elseif familyId == "quanzhen" then-- 全真教	 quanzhen
		self:createQuanZhenSpecialNPC(map,map.id,roomId)

	elseif familyId == "riyueshenjiao" then-- 日月神教	 riyueshenjiao
		self:createRiYueSpecialNPC(map,map.id,roomId)

	elseif familyId == "shaolin" then-- 少林派	 shaolin
		self:createShaoLinSpecialNPC(map,map.id,roomId)

	elseif familyId == "tangmen" then-- 唐门	 tangmen
		self:createTangMenSpecialNPC(map,map.id,roomId)

	elseif familyId == "taohuadao" then-- 桃花岛	 taohuadao
		self:createTaoHuaDaoSpecialNPC(map,map.id,roomId)

	elseif familyId == "tiezhang" then-- 铁掌帮	 tiezhang
		self:createTieZhangSpecialNPC(map,map.id,roomId)

	elseif familyId == "wudang" then-- 武当派	 wudang
		self:createWuDangSpecialNPC(map,map.id,roomId)

	elseif familyId == "wudu" then-- 五毒教	 wudu
		self:createWuDuSpecialNPC(map,map.id,roomId)

	elseif familyId == "tianshan" then-- 天山派	 tianshan
		self:createTianShanSpecialNPC(map,map.id,roomId)

	elseif familyId == "xingxiu" then-- 星宿派	 xingxiu
		self:createXingXiuSpecialNPC(map,map.id,roomId)

	elseif familyId == "kongtong" then-- 崆峒派	 kongtong
		self:createKongTongSpecialNPC(map,map.id,roomId)

	elseif familyId == "haijing" then-- 海鲸帮	 haijing
		self:createHaiJingSpecialNPC(map,map.id,roomId)

	elseif familyId == "youming" then-- 幽冥教	 youming
		self:createYouMingSpecialNPC(map,map.id,roomId)

	elseif familyId == "guanfu" then-- 官府	 guanfu
		self:createGuanFuSpecialNPC(map,map.id,roomId)

	elseif familyId == "luoyue" then--落月山庄
		self:createLuoYueSpecialNPC(map,map.id,roomId)
	end
end
--生成特殊任务NPC方法
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 16:16:55
-- @desc 白驼山
function TeacherTask:createBaiTuoShanSpecialNPC(map,mapId,roomId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	if roomId == receiveTask.roomId then
		local role = {}
		local basenpc = self:getNPCBaseList(receiveTask.npcBaseId)
		for k ,v in pairs(basenpc) do
			role[k] = v
		end
		role.id = receiveTask.npcId
		role.baseId = receiveTask.npcBaseId
		role.canKill = false
		role.type = "role"
		role.id = receiveTask.npcId
		map:createRole(role)
		map:addRoomRole(roomId,role.id,true)
		self:removeTeacherTaskNPC(map,roomId,role.id)
		role = map:getRole(receiveTask.npcId)--roomId,roleId
		local currRole = role
		local role = currRole
		local currMap = map
		self.mapLayer = map.__MapLayer
		local player = User:getRole()
		map:doConditionAndResult(role.conditionAndResults,
            {
                operation = "切磋",
                currRole = role,
                currRoomId = roomId,
                mapLayer = self.mapLayer
            })

		role:initNpcAttr() -- NPC状态初始化

        map:afterFightWithQieCuo(player, role, function(winTeamId)
            -- 战斗胜利条件结果
            if winTeamId == 1 then
                -- PopText("你战胜了" .. role:getName())
                map:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "成功",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })

                self.mapLayer:delayRefreshMap()
                -- 刷新房间条件结果
				map:doRoomConditionAndResult(receiveTask.roomId)
				player:addItemCount("shimenwupin30",-1)
				map:removeRoomRole(receiveTask.roomId,receiveTask.npcId)
				receiveTask.roomId = {}
				receiveTask.mapId = {}
				receiveTask.jiangli = 2
				TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
				RichPrint("main","你将正派人士击败，成功收回了幼蛇，RED正气值-10NOR。")
				TeacherTask:setTeacherTaskAttr("isComplete","Y")
				User:getRole():addAttr("zhengqi",-10)
				map.__MapLayer:setNeedRefreshMap()
            else
                -- PopText("你被" .. role:getName() .. "打趴在地")
                currMap:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "失败",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })
				player:addItemCount("shimenwupin30",-1)
				local _roomId = receiveTask.roomId
				map:removeRoomRole(receiveTask.roomId,receiveTask.npcId)
				receiveTask.roomId = {}
				receiveTask.mapId = {}
				receiveTask.jiangli = 1
				TeacherTask:setTeacherTaskAttr("receiveTask",receiveTask)
				RichPrint("main","你被正派人士打败，部分幼蛇没法收回。")
				TeacherTask:setTeacherTaskAttr("isComplete","Y")
                -- self.mapLayer:delayRefreshMap()
                -- 刷新房间条件结果
                map.__MapLayer:setNeedRefreshMap()
                map:doRoomConditionAndResult(_roomId)
               
            end
        end)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/14 10:28:17
-- @desc 天龙寺
function TeacherTask:createTianLongSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			self:createTianLongNPC(receiveTask.npcId[2],receiveTask.npcBaseId[2],roomId,map)
		end
	end	
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/13 14:59:03
-- @desc 星宿
function TeacherTask:createXingXiuSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			self:createXingXiuNPC(receiveTask.npcId,receiveTask.npcBaseId,roomId,map,receiveTask.name)
		end
	end	
end
function TeacherTask:createXingXiuNPC(roleId,baseId,roomId,map,name)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		canKill = false,
		caozuoName = "歌功颂德",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "歌功颂德",
						arg1 = "歌功颂德",
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)--Helper:tableCover(npc,role)
	role.id= roleId
	role.name = name
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,roleId)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/11 16:48:57
-- @desc 官府
function TeacherTask:createGuanFuSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			self:createGuanFuNPC(receiveTask.npcId[1],receiveTask.npcBaseId[1],roomId,map)
		end
	end
end
function TeacherTask:createGuanFuNPC(roleId,baseId,roomId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		canKill = false,
		caozuoName = "官府缉凶",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "官府缉凶",
						arg1 = "官府缉凶",
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id= roleId
	print("role.id:=======================================",role.id)
	-- Helper:print_lua_table(role)
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,roleId)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/10 11:26:33
-- @desc 唐门
function TeacherTask:createTangMenSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			self:createTangMenNPC(receiveTask.npcId,receiveTask.npcBaseId[1],roomId,map)
		end
	end
end
function TeacherTask:createTangMenNPC(roleId,baseId,roomId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		canKill = false,
		caozuoName = "炼器",
		caozuo1 = false,
		caozuoName1 = "正在炼器",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "炼器",
						arg1 = "炼器",
					},
				}
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作1",
					}
				},
				results =
				{
					{
						type = "正在炼器",
						arg1 = "正在炼器",
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id= roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,roleId)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 15:05:00
-- @desc 峨眉
function TeacherTask:createEMeiSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	-- Helper:print_lua_table(receiveTask.roomId)
	-- Helper:print_lua_table(receiveTask.name)
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[1]) then
			self:createEMeiNPC(receiveTask.npcId[1],receiveTask.npcBaseId[1],roomId,map)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 10:06:42
-- @desc 丐帮
function TeacherTask:createGaiBangSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	print("____________",receiveTask.roomId)
	if receiveTask.roomId == roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
			self:createGaiBangNPC(receiveTask.npcId,receiveTask.npcBaseId[1],roomId,map)--roleId,baseId,roomId,map
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 16:20:57
-- @desc 古墓
function TeacherTask:createGuMuSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			self:createGuMuNPC(receiveTask.npcId,roomId,receiveTask.npcBaseId,map)
		end
	end
end
function TeacherTask:createGuMuNPC(roleId,roomId,baseId,map)
	local MapInfo = require("app.models.map.MapInfo")
	print("TeacherTask:createGuMuNPC(roleId,roomId,baseId,map)----------------------",roleId,roomId,baseId)
	local npc = Helper:getDef(self:getNPCBaseList(baseId),{})
	local role = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		caozuoName = "修炼",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "修炼",
						arg1 = "捕雀功",
					},
				},
			}
		}

	}
	role = table.mergeMap(role,npc)
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	print(role.id,"_______________________________________________")
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,roleId)	
end
--华山
function TeacherTask:createHuaShanSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	for k,v in ipairs(receiveTask.roomId) do 
		if v == roomId then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
				local role = {}
				local basenpc = self:getNPCBaseList(receiveTask.npcBaseId)
				for k ,v in pairs(basenpc) do
					role[k] = v
				end
				role.id = receiveTask.npcId[k]
				role.baseId = receiveTask.npcBaseId
				role.canKill = false
				role.type = "role"
				map:createRole(role)
				map:addRoomRole(roomId,receiveTask.npcId[k],true)
				self:removeTeacherTaskNPC(map,roomId,role.id)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 16:22:45
-- @desc 昆仑
function TeacherTask:createKunLunSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	print(receiveTask.roomId)
	if receiveTask.roomId == roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			self:createKunLunNPC(receiveTask.npcId,receiveTask.npcBaseId,roomId,map)
		end
	end
end
function TeacherTask:createQuanZhenDuoBaoNPC(map,mapId,roomId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if type(receiveTask) ~= "table" then
		return
	end
	if User:getRole():getItem("shimenwupin32") then
		for k,v in pairs(receiveTask.maplist) do 
			if mapId == v and roomId ~= receiveTask.jietouRoomId then
				if Helper:RandomByWeight(receiveTask.meet) == 1 then
					local npcId = roomId.."quanzhenshimenrenwu1"
					if not self:checkRoleIsInRoom(map,roomId,npcId) and roomId ~= receiveTask.jietouRoomId then
					-- if not self:<checkRoleIsInRoom></checkRoleIsInRoom>(map,roomId,receiveTask.npcId) then
						local npc = clone(map:getRole("quanzhenshimenrenwu1"))
						if npc ~= nil then
							npc.id = npcId
							npc.withCorpse = -1
							map:createRole(npc)
							map:addRoomRole(roomId,npcId,true)
							self:removeTeacherTaskNPC(map,roomId,npc.id)
						end
					-- end
					end
				end
			end
		end
	end
end
--全真
function TeacherTask:createQuanZhenSpecialNPC(map,mapId,roomId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local familyId = User:getRole():getAttr("family").name
	if receiveTask == 0 or receiveTask.taskType ~=4 then
		return false
	end
	if User:getRole():getAttr("family").name ~= familyId then
		return false
	end 
		-- tab.jietouMapId = mapList[math.random(1,#mapList)]
		-- tab.jietouRoomId = self:getPossibleRoom(tab.jietouMapId)
		-- tab.jietouNpcBaseId = npc[2]
		-- tab.jietouNpcId
	if mapId == receiveTask.jietouMapId then
		if roomId == receiveTask.jietouRoomId then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.jietouNpcId) then
				self:createQuanZhenJieTouRen(map,roomId)
			end
		end
	end
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	if not receiveTask.meet then
		return
	end
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.giftNPC) then
			self:createQuanZhenNPC(receiveTask.name,map,roomId,receiveTask.giftNPC,receiveTask.giftNPCBaseId,receiveTask.itemgift)
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/04 17:01:50
-- @desc 创建全真密函NPC
function TeacherTask:createQuanZhenNPC(name,map,roomId,roleId,baseId,itemId)
	print(name,map,roomId,roleId,itemId)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = Helper:getDef(self:getNPCBaseList(baseId),{})
	local role = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "交谈",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "抓取",
						arg1 = "获得道具",
						arg2 = itemId,
					},
				},
			}
		}

	}
	role = table.mergeMap(role,npc)
	role.id = roleId
	role.name = name
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,roleId)	
end
function TeacherTask:createQuanZhenJieTouRen(map,roomId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local MapInfo = require("app.models.map.MapInfo")
	local npc = Helper:getDef(self:getNPCBaseList(receiveTask.jietouNpcBaseId),{})
	local role = {
		id= receiveTask.jietouNpcId,
		baseId = receiveTask.jietouNpcBaseId,
		sex = "男",
		type = "role",
		name = "接头人",
		canSee = true,
		caozuo = true,
		caozuoName = "交谈",
		caozuo1 = true,
		caozuoName1 = "送礼",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "师门交谈",
						arg1 = "师门交谈",				
					},
				},
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作1",
					}
				},
				results =
				{
					{
						type = "师门送礼",
						arg1 = "师门送礼",				
					},
				},
			}
		}

	}
	role = table.mergeMap(role,npc)
	role.id = receiveTask.jietouNpcId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end
--日月
function TeacherTask:createRiYueSpecialNPC(map,mapId,roomId)--map,map.id,roomId
	local receiveTask = self:getTeacherTaskAttr("receiveTask")

	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	Helper:print_lua_table(receiveTask.roomId)
	for k,v in pairs(receiveTask.roomId) do 
		if roomId == v then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
					local role = {}
					local basenpc = self:getNPCBaseList(receiveTask.npcBaseId[k])
					Helper:print_lua_table(basenpc)
					for k ,v in pairs(basenpc) do
						role[k] = v
					end
					role.id = receiveTask.npcId[k]
					role.baseId = receiveTask.npcBaseId[k]
					role.canKill = true
					role.withCorpse = -1
					role.canTalk = false
					role.type = "role"
					map:createRole(role)
					map:addRoomRole(roomId,receiveTask.npcId[k],true)
					self:removeTeacherTaskNPC(map,roomId,role.id)
			end
		end
	end
end
--幽冥 需要修改
function TeacherTask:createYouMingSpecialNPC(map,mapId,roomId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask") 
	if receiveTask == 0 or receiveTask.taskType ~=4 then
		return
	end
	if User:getRole():getAttr("family").name ~= "youming" then
		return
	end	
	for k,v in pairs(receiveTask.roomId) do 
		if roomId == v then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
				print("创建人物")
				self:createYouMingNPC(receiveTask.npcId[k],receiveTask.npcBaseId,roomId,receiveTask.name[k],map)
				-- createYouMingNPC(roleId,baseId,roomId,name,map)
			end
		end
	end
end
--少林
function TeacherTask:createShaoLinSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask") 
	Helper:print_lua_table(receiveTask.roomId)
	for k,v in ipairs(receiveTask.roomId) do 
		if v == roomId then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
				local name = "施主"
				local baseId = receiveTask.npcBaseId[1]
				if receiveTask.sex[k] == 2 then
					name = "女施主"
					baseId = receiveTask.npcBaseId[2]
				end
				self:createShaoLinNPC(baseId,receiveTask.npcId[k],v,map,name,receiveTask.success[k],k)
			end
		end
	end
end
--武当
function TeacherTask:createWuDangSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask") 
	print("**************************************************************")
	Helper:print_lua_table(receiveTask.roomId)
	for k,v in ipairs(receiveTask.roomId) do 
		if v == roomId then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
					local role = {}
					local basenpc = self:getNPCBaseList(receiveTask.npcBaseId)
					for k ,v in pairs(basenpc) do
						role[k] = v
					end
					role.id = receiveTask.npcId[k]
					role.baseId = receiveTask.npcBaseId
					role.canKill = false
					role.type = "role"
					map:createRole(role)
					map:addRoomRole(roomId,receiveTask.npcId[k],true)
					self:removeTeacherTaskNPC(map,roomId,role.id)
			end
		end
	end
end
--五毒
function TeacherTask:createWuDuSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask") 
	Helper:print_lua_table(receiveTask.roomId)
	for k,v in ipairs(receiveTask.roomId) do 
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
			self:createWuDuNPC(receiveTask.npcId[k],receiveTask.roomId[k],receiveTask.npcBaseId,map,receiveTask.success[k])
		end
	end	
end
--铁掌
function TeacherTask:createTieZhangSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local ask = Helper:getDef(receiveTask.hasAsk,{})
	for k,v in ipairs(receiveTask.roomId) do 
		if roomId == v then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) and ask[k] == nil then
				self:createTieZhangNPC(receiveTask.npcId[k],roomId,receiveTask.npcBaseId,map,receiveTask.success[k])
				-- createTieZhangNPC(roleId,roomId,map,name,isSuccess)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:18:54
-- @desc 密宗
function TeacherTask:createMiZongSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask.roomId == roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[1]) then
			print(receiveTask.npcBaseId[1],receiveTask.npcId[1])
			self:createMiZongNPC(receiveTask.npcId[1],receiveTask.npcBaseId[1],roomId,map,receiveTask.success)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:41:33
-- @desc 慕容山庄
function TeacherTask:createMuRongSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			local role = {}
			local basenpc = self:getNPCBaseList(receiveTask.npcBaseId)
			for k ,v in pairs(basenpc) do
				role[k] = v
			end
			role.id = receiveTask.npcId
			role.baseId = receiveTask.npcBaseId
			role.canKill = true
			role.canTalk = false
			role.type = "role"
			map:createRole(role)
			map:addRoomRole(roomId,receiveTask.npcId,true)
			self:removeTeacherTaskNPC(map,roomId,role.id)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:50:27
-- @desc 明教
function TeacherTask:createMingJiaoSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			local role = {}
			local basenpc = self:getNPCBaseList(receiveTask.npcBaseId)
			for k ,v in pairs(basenpc) do
				role[k] = v
			end
			role.id = receiveTask.npcId
			role.baseId = receiveTask.npcBaseId
			role.canKill = true
			role.canTalk = false
			role.type = "role"
			map:createRole(role)
			map:addRoomRole(roomId,receiveTask.npcId,true)
			self:removeTeacherTaskNPC(map,roomId,role.id)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:54:57
-- @desc 桃花岛
function TeacherTask:createTaoHuaDaoSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			-- local npc = clone(map:getRole(receiveTask.npcBaseId))
			-- npc.id = receiveTask.npcId
			-- map:createRole(npc)
			-- map:addRoomRole(roomId,receiveTask.npcId,true)
			local role = {}
			local basenpc = self:getNPCBaseList(receiveTask.npcBaseId)
			for k ,v in pairs(basenpc) do
				role[k] = v
			end
			role.id = receiveTask.npcId
			role.baseId = receiveTask.npcBaseId
			role.canKill = true
			role.canTalk = false
			role.type = "role"
			map:createRole(role)
			map:addRoomRole(roomId,receiveTask.npcId,true)
			self:removeTeacherTaskNPC(map,roomId,role.id)
		end	
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 16:20:27
-- @desc 天山
function TeacherTask:createTianShanSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	Helper:print_lua_table(receiveTask.roomId)
	for k,v in ipairs(receiveTask.roomId) do 
		if v == roomId then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) and receiveTask.hasAsk[k] == nil then
				print("获得物品方式:",receiveTask.success[k])
				self:createTianShanNPC(receiveTask.npcId[k],receiveTask.npcBaseId,roomId,map,receiveTask.success[k])
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 18:28:24
-- @desc 落月
function TeacherTask:createLuoYueSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if roomId == receiveTask.roomId then
		if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
			self:createLuoYueNPC(receiveTask.npcId,roomId,receiveTask.npcBaseId,map)
		end
	end
end
function TeacherTask:createLuoYueNPC(roleId,roomId,baseId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = Helper:getDef(self:getNPCBaseList(baseId),{})
	local role = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = "",
		canSee = true,
		caozuo = true,
		caozuoName = "学剑",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "学剑",
						arg1 = "学剑",				
					},
				},
			}
		}

	}
	role = table.mergeMap(role,npc)
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 10:56:16
-- @desc 海鲸帮
function TeacherTask:createHaiJingSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	-- Helper:print_lua_table(receiveTask.roomId)
	-- print(map:getRoomById("fb17_37").name)
	for k,v in pairs(receiveTask.roomId) do 
		if roomId == v then
			if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
				if receiveTask.success[k] == 1 then
					print("渔民")
					self:createHaiJingYuMinNPC(receiveTask.npcId[k],receiveTask.npcBaseId[1],roomId,map)
				else
					print("海鲸帮弟子")
						local role = {}
						local basenpc = self:getNPCBaseList(receiveTask.npcBaseId[2])
						for k ,v in pairs(basenpc) do
							role[k] = v
						end
						role.id = receiveTask.npcId[k]
						role.baseId = receiveTask.npcBaseId[2]
						role.canKill = true
						role.canTalk = false
						role.type = "role"
						role.withCorpse = -1
						map:createRole(role)
						map:addRoomRole(roomId,receiveTask.npcId[k],true)
						self:removeTeacherTaskNPC(map,roomId,role.id)

				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/19 10:29:19
-- @desc 崆峒
function TeacherTask:createKongTongSpecialNPC(map,mapId,roomId)
	if not self:checkSpecialTask(User:getRole():getAttr("family").name,mapId) then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local isSolve = Helper:getDef(receiveTask.isSolve,{})
	for k,v in pairs(receiveTask.roomId) do 
		if v == roomId and isSolve[k] == nil then
			if receiveTask.types[k] == 1 then
				if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId[k]) then
					print("类型一",k)
					self:createKongTongKunRaoNPC(receiveTask.npcId[k],receiveTask.npcBaseId[1],roomId,map,k)
				end
			else
				for m,j in pairs(receiveTask.npcId[k]) do 
					if not self:checkRoleIsInRoom(map,roomId,j) then
						self:createKongTongTiaoJieNPC(j,receiveTask.npcBaseId[m+1],roomId,map,k,receiveTask.success[k])
					end
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/27 16:08:05
-- @desc 五毒
function TeacherTask:createWuDuNPC(roleId,roomId,baseId,map,success)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = Helper:getDef(self:getNPCBaseList(baseId),{})
	local role = {
		id= roleId,
		baseId = baseId,
		sex = "野兽",
		type = "role",
		animType = "spider",
		name = "",
		canSee = true,
		caozuo = true,
		caozuoName = "抓取",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "抓取",
						arg1 = "抓取",
						arg2 = success,
					},
				},
			}
		}

	}
	role = table.mergeMap(role,npc)
	role.withCorpse = -1
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)	
	self:removeTeacherTaskNPC(map,roomId,role.id)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/19 10:31:54
-- @desc 崆峒困扰NPC
function TeacherTask:createKongTongKunRaoNPC(roleId,baseId,roomId,map,num)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId  = baseId,
		sex = "男",
		type = "role",
		name = "",
		canSee = true,
		caozuo = true,
		-- canTalk = true,
		canCompete = false,
		caozuoName = "开解",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "开解",
						arg1 = "开解",
						arg2 = num,
					},
				},
			}
		}

	}	
	role = table.mergeMap(role,npc)
	role.id = roleId

	MapInfo:addRoleToRoomByRoomId(map,roomId,role)	
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/19 10:36:12
-- @desc 崆峒调解NPC
function TeacherTask:createKongTongTiaoJieNPC(roleId,baseId,roomId,map,num,isSuccess)
	print("*******************创建崆峒调解NPC**************************roleId:",roleId,"baseId:",baseId)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = "",
		canSee = true,
		caozuo = true,
		canCompete = false,
		caozuoName = "调解",
	}
	if isSuccess == 1 then
		role.conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "调解",
						arg1 = "调解",
						arg2 = num,
					},
				},
			}
		}
	else
		role.conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "主动切磋",
						arg1 = "主动切磋",
						arg2 = num,
					},
				},
			}
		}
	end	
	role = table.mergeMap(role,npc)
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 11:01:15
-- @desc 海鲸帮NPC渔民
function TeacherTask:createHaiJingYuMinNPC(roleId,baseId,roomId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = "",
		canSee = true,
		caozuo = true,
		-- canTalk = true,
		caozuoName = "交谈",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "文本输出",
						arg1 = "交谈奖励",
						arg2 = "是海鲸帮的贵客啊，失礼失礼，这是这个月的孝敬，请收下。",
						arg3 = "shimenwupin35,1"
					},
				},
			}
		}

	}
	role = table.mergeMap(role,npc)
	role.id= roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)	
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)	
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/16 14:22:12
-- @desc 昆仑条件结果NPC
function TeacherTask:createKunLunNPC(roleId,baseId,roomId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "学琴",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "学琴",
						arg1 = "学琴",
					},

				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id= roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)		
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 15:07:36
-- @desc 峨眉条件结果NPC
function TeacherTask:createEMeiNPC(roleId,baseId,roomId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "item",
		name = name,
		canSee = true,
		canUse1 = true,
		canTalk = false,
		useName1 = "架起",
		canUse2 = false,
		canUse3 = false,
		canUse4 = false,
		useName2 = "注入",
		useName3 = "煮粥",
		useName4 = "正在煮粥",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "使用1",
					}
				},
				results =
				{
					{
						type = "架起",
						arg1 = "架起",
					},
				}
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "使用2",
					}
				},
				results =
				{
					{
						type = "注入",
						arg1 = "注入",
					},
				}
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "使用3",
					}
				},
				results =
				{
					{
						type = "煮粥",
						arg1 = "煮粥",
					},
				}
			},
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "使用4",
					}
				},
				results =
				{
					{
						type = "正在煮粥",
						arg1 = "正在煮粥",
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id= roleId
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask.isdo == "架起" then
		role.canUse1 = false
		role.canUse2 = true
		role.canUse3 = false
		role.canUse4 = false
	elseif receiveTask.isdo == "注入" then
		role.canUse1 = false
		role.canUse2 = false
		role.canUse3 = true	
		role.canUse4 = false
	end
	role.dsc = "这是一口大铁锅，用于煮粥，煮上一锅，每次几可让上百人都可以喝上一碗热粥果腹。在灾年，它就是灾民心中的图腾，有锅有米，就有活下去的希望。"
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 10:08:26
-- @desc 丐帮的条件npc
function TeacherTask:createGaiBangNPC(roleId,baseId,roomId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "item",
		name = name,
		canSee = true,
		canUse1 = true,
		canTalk = false,
		useName1 = "开始行乞",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "使用1",
					}
				},
				results =
				{
					{
						type = "莲花落",
						arg1 = "莲花落",
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id = roleId
	role.dsc = "这是一个看起来破破烂烂的碗，但却是很多乞丐心中的圣物，用于行乞可谓无往而不利。"
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)	
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end

function TeacherTask:checkSpecialTask(familyId,mapId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask == nil then
		return false
	end 
	if receiveTask == 0 or receiveTask.taskType ~=4 then
		return false
	end
	if User:getRole():getAttr("family").name ~= familyId then
		return false
	end
	if mapId ~= receiveTask.mapId then
		return false
	end
	return true
end
--创建条件结果NPC

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/14 10:32:01
-- @desc 天龙寺条件结果NPC
function TeacherTask:createTianLongNPC(roleId,baseId,roomId,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		-- sex = "男",
		type = "item",
		name = name,
		canSee = true,
		canUse1 = true,
		canTalk = false,
		useName1 = "参禅",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "使用1",
					}
				},
				results =
				{
					{
						type = "参禅",
						arg1 = "参禅",
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id = roleId
	role.dsc = "这是一幅巨大的壁画，画的内容是佛经里的天龙八部众，画师的技术炉火纯青，将八部众画得惟妙惟肖、呼之欲出。"
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 16:39:04
-- @desc 天山条件结果NPC
function TeacherTask:createTianShanNPC(roleId,baseId,roomId,map,isSuccess)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		sex = "男",
		type = "role",
		name = name,
		baseId = baseId,
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "收贡",
	}
	if isSuccess == 2 then
		role.conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						arg1 = "文本输出",
						arg2 = "YEL天山附属：想要贡品？那自是可以，不过在下想领教一下天山弟子的武艺，还请赐教！"
					},
					{
						type = "收贡",
						arg1 = "主动切磋",
					},
				}
			},
		}
	else
		role.conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "收贡",
						arg1 = "收贡",
						arg3 = isSuccess,
					},
				}
			},
		}
	end
	-- for k,v in pairs(npc) do 
	-- 	local value = v
	-- 	role[k] = value 
	-- end
	role = table.mergeMap(role,npc)
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)	
end

-- 初始化创建信息
-- 获取NPC生成房间ID
-- 生成NPC
-- 操作结果

function TeacherTask:createNpcRole()
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "敲诈",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "敲诈",
						arg1 = "敲诈",
						arg2 = roomId
					},
				}
			},
		}

	}
	for k,v in pairs(npc) do 
		local value = v
		role[k] = value 
	end
	role.name = name
	role.id = roleId
	role.withCorpse = -1
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
	local result, text = User:getRole():setCurrMap(map)
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:19:29
-- @desc 幽冥条件结果NPC
function TeacherTask:createYouMingNPC(roleId,baseId,roomId,name,map)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role  = {
		id= roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "敲诈",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "敲诈",
						arg1 = "敲诈",
						arg2 = roomId
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.name = name
	role.id = roleId
	role.withCorpse = -1
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
	-- local result, text = User:getRole():setCurrMap(map)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:20:08
-- @desc 少林条件结果NPC
function TeacherTask:createShaoLinNPC(baseId,roleId,roomId,map,name,isSuccess,num)
	local role = User:getRole()
	local MapInfo = require("app.models.map.MapInfo")
	-- local roomId
	MapInfo:addRoleToRoomByRoomId(map,roomId,Helper:tableCover(require("app.models.npc.BaseNpc"):create(),{
		id = roleId,
		baseId = baseId,
		sex = _sex,
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "化缘",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "化缘",
						arg1 = "化缘",
						arg2 = isSuccess,
						arg3 = num,
						arg4 = roomId,
					},
				}
			},
		}
	}))
	role.id = roleId
	self:removeTeacherTaskNPC(map,roomId,role.id)
	-- local result, text = role:setCurrMap(map)
	-- if result == true then
	-- else
	-- 	PopText(text)
	-- end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:20:32
-- @desc 铁掌条件结果NPC
function TeacherTask:createTieZhangNPC(roleId,roomId,baseId,map,isSuccess)
	local role = User:getRole()
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	print("")
	local role = {
		id = roleId,
		baseId = baseId,
		sex = "男",
		type = "role",
		name = "",
		canSee = true,
		caozuo = true,
		canTalk = false,
		canCompete = false,
		caozuoName = "询问",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "询问",
						arg1 = "询问",
						arg2 = isSuccess,
					},
				}
			},
		}
	}
	role = table.mergeMap(role,npc)
	role.withCorpse = -1
	role.name = npc.name
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/13 15:21:04
-- @desc 密宗条件结果NPC
function TeacherTask:createMiZongNPC(roleId,baseId,roomId,map,isSuccess)
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(baseId)
	local role = {
		id= roleId,
		baseId = baseId,
		sex = "女",
		type = "role",
		name = name,
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "拐走",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "拐走",
						arg1 = "拐走",
						arg2 = isSuccess,
					},
				}
			},
		}
	}
	role = table.mergeMap(role,npc)
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)
end

--获取全副本NPC的基本属性
function TeacherTask:getNPCBaseList(npcId)
	local list = taskNpc.npc
	for k,v in pairs(list) do 
		if k == npcId then
			return v
		end
	end
end
-- 
function TeacherTask:testFun(map,roomId)
	print(map.id)
		local roleId = "riyueshimenrenwu1"..tostring(Helper:getOnlyId())

	if User:getRole():getItem("shimenwupin32") then
		if Helper:RandomByWeight({[1] = 50,[2] = 50}) == 1 then
			-- if not self:checkRoleIsInRoom(map,roomId,receiveTask.npcId) then
				local npc = clone(map:getRole("quanzhenshimenrenwu1"))
				local npcId = "quanzhenshimenrenwu1"..tostring(Helper:getOnlyId())
				npc.id = npcId
				map:createRole(npc)
				map:addRoomRole(roomId,npcId,true)
				self:removeTeacherTaskNPC(map,roomId,role.id)
			-- end
		end
	end


	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList("riyueshimenrenwu1")
	local role  = {
		id= roleId,
		sex = "男",
		type = "role",
		name = "张三",
		canSee = true,
		caozuo = true,
		canKill = true,
		canTalk = false,
		caozuoName = "莲花落",

		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "莲花落",
						arg1 = "莲花落",
					},
				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id = roleId
	MapInfo:addRoleToRoomByRoomId(map,roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,roomId,role.id)

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/14 16:19:01
-- @desc 幽冥教装神扮鬼玩家选择结果处理
function TeacherTask:getYouMingSpecialTaskResult(role,result)
	if not role  then
		return false
	end
   	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask == 0 or receiveTask.taskType ~= 4 then
		return false
	end
   	local answer = 0
	for k,v in ipairs(receiveTask.npcId) do 
		print(role.id,v)
		if v == role.id then
			if result == nil then
				result = receiveTask.types[tonumber(k)]
			end
			if result == receiveTask.types[tonumber(k)] then
				answer = tonumber(k)
			end 
		end
	end
    if answer ~= 0 then
    	RichPrint("main",receiveTask.successWord[result])
    	if #receiveTask.npcId > 0 then
	    	for k,v in pairs(receiveTask.daoju) do 
	    		self:getTeacherTaskItem(v,1)
	    	end  
    	end
    	table.remove(receiveTask.npcId,answer)
    	table.remove(receiveTask.roomId,answer)
    	receiveTask.successWord[result] = nil 
    	table.remove(receiveTask.name,answer)
    	table.remove(receiveTask.words,answer)
    	table.remove(receiveTask.types,answer)
    	self:setTeacherTaskAttr("receiveTask",receiveTask)
    	if #receiveTask.npcId == 0 then
    		self:setTeacherTaskAttr("isComplete","Y")
    	end
    	return true
    else
    	return false
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/14 16:29:02
-- @desc 获得道具
function TeacherTask:getTeacherTaskItem(itemId,num)
	local Item = require("app.models.item.Item")
	if not itemId then
		return
	end
	if not num then
		num = 0
	end
	local itemAttr = Item:getOneItemByKey(itemId)
	if not itemAttr then
		PopText("物品"..itemId.."不存在")
		return
	else 
		User:getRole():addItemCount(itemId,num)
		PopText("获得物品 "..tostring(itemAttr.name).. " X "..tostring(num))
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/14 17:31:55
-- @desc 莲花落文本
function TeacherTask:showText(func)
    local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
    local teacherAnimationLayer = TeacherAnimationLayer:getInstance()
    teacherAnimationLayer:setVisible(false)
    local str = {
        [1] = "莲花落 #####",
        [2] = "人道光阴急如梭，我说光阴两样过。",
        -- [3] = "昔日繁华人羡我，一年一度易蹉跎。",
        -- [4] = "可怜今日我无钱，一时一刻如长年。",
        -- [5] = "我也曾裘肥马载高轩，指麾万众驱山前。",
        -- [6] = "一声围合魑魅惊，百姓邀迎如神明。",
        -- [7] = "今日黄金散尽谁复矜，朋友离群猎狗烹。",
        -- [8] = "昼无擅夜无眠，落得接头唱哩莲。",
        -- [9] = "一生两载谁能堪，不怨爷娘不怨天。",
        -- [10] = "早知如此遭坎坷，悔教当日结妖魔。",
        -- [11] = "而今无计可奈何，殷勤劝人休似我！",
    }
    if not MapIsEmpty(str) then
        teacherAnimationLayer:createTextFromArray(str)
        teacherAnimationLayer:setHideWithCallFunc(function()
            if func then
            	func()
            end
        end)
        teacherAnimationLayer:show()
    else
        PopText("你没有加入门派")
    end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 10:12:19
-- @desc 行乞路人文本
function TeacherTask:getGaiBangLuRenWords(tag)
	local function getRandomMoney(num1,num2)
		local random = 0
		if num1 and not num2 then
			random = num1
		end
		if num1 and num2 then
			random = math.random(num1,num2)
		end
		return random
	end
	local tab = {
		[1] = {
			word = "一个衣着华丽的中年贵妇被你的歌声吸引，停下了脚步。",
			said = "贵妇叹道“也是个苦命人”，扔下一笔赏钱走了。",
			money = getRandomMoney(2000,4000) ,
			type = "路人",
			time = 0,
		},
		[2] = {
			word = "一个身形佝偻的老人被你的歌声吸引，停下了脚步。",
			said = "老人叹道“可怜的孩子，好好活着吧”，掏出一笔赏钱然后走开了",
			money = getRandomMoney(1000,2000),
			type = "路人",
			time = 0,
		},
		[3] = {
			word = "一个脑满肠肥的中年富商被你的歌声吸引，停下了脚步。",
			said = "富商鄙夷道：“叫花子，拿去！”扔下一笔赏钱后快步掩鼻走开。",
			money = 50 ,
			type = "路人",
			time = 0,
		},
		[4] = {
			word = "一个意气风发的年轻书生被你的歌声吸引，停下了脚步。",
			said = "书生摇头晃脑说道：“还是要多读圣贤书啊！”然后丢下一笔赏钱后走了。",
			money = getRandomMoney(300,500),
			type = "路人"
			,
			time = 0,
		},
		[5] = {
			word = "一个嬉皮笑脸的泼皮被你的歌声吸引，停下了脚步。",
			said = "泼皮：“这位朋友的莲花落唱得真好，今天真遇到高人了。”然后悻悻走开了。",
			money =  getRandomMoney(-100,-200),
			type = "路人",
			time = 0,
		},
		[6] = {
			word = "一个顽童被你的歌声吸引，停下了脚步。",
			said = "顽童往破碗里扔了一颗石头，然后笑嘻嘻地跑开了。",
			money = 0,
			type = "路人",
			time = 0,
		},
	}
	local yayi = {
		word = "一个满脸横肉的衙役走了过来，直勾勾地打量着你，嘴角噙着冷笑。",
		said_success = "哼，不识抬举！",
		said_defeat = "哼，你给我等着！",
		money = getRandomMoney(-100,-500),
		type = "衙役",
		time = 0,
	}
	if tag == 1 then
		return tab[math.random(1,#tab)]
	else
		return  yayi
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 11:04:13
-- @desc 行乞路人文本时间间隔处理
function TeacherTask:getGaiBangLuRenWordsTime(isStart,time)
	local tab = {}
	local isRefresh = false
	if not time then
		return tab,isRefresh
	end
	print("传入的时间为:",time)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if isStart == true then
		receiveTask.time = 0
	end
	-- time = receiveTask.time + time 
	if receiveTask.time == 0 then
		tab = self:getGaiBangLuRenWords(1)
		tab.time = tab.time + time
		isRefresh = true
		print("开始乞讨刷出路人",receiveTask.time,tab.time)
	else 
		if receiveTask.luren.time >= 2 and receiveTask.luren.time < 4 then
			tab = receiveTask.luren
			tab.word = ""
			tab.time = tab.time + time
			isRefresh = true
			print("文本存在超过两秒，消失",tab.time)
		elseif receiveTask.luren.time < 2 then
			tab = receiveTask.luren
			tab.time = tab.time + time
			isRefresh = false
			print("文本存在时间低于2秒，不改变",tab.time)
		else
			tab = self:getGaiBangLuRenWords(1)
			tab.time = tab.time + time
			print("文本存在4秒，刷出新的文本",tab.time)
			isRefresh = true
		end
	end
	receiveTask.luren = tab
	receiveTask.time = receiveTask.time + time 
	self:setTeacherTaskAttr("receiveTask",receiveTask)
	return tab,isRefresh
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 11:44:56
-- @desc 行乞衙役文本时间间隔处理
function TeacherTask:getGaiBangYaYiWordsTime(time)
	local tab = {}
	if not time  then
		return tab
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask.time ~= 0 and (receiveTask.time + time) % 9 == 0 then
		print("(receiveTask.time + time)",receiveTask.time + time)
		tab = self:getGaiBangLuRenWords(2)
		print("衙役文本改变")
		tab.time = time + tab.time
	else
		if receiveTask.yayi and receiveTask.yayi ~= {} then
			if receiveTask.yayi.time and receiveTask.yayi.time >= 2 then
				tab = {}
			else
				tab = receiveTask.yayi
				if tab.time then
					tab.time = time + tab.time
				else
					tab.time = time
				end
			end
		end
	end
	receiveTask.yayi = tab
	self:setTeacherTaskAttr("receiveTask",receiveTask)
	return tab
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 11:54:44
-- @desc 获取丐帮乞讨文本
function TeacherTask:getGaiBangWords(isStart,time)
	local luren,isRefresh
	luren,isRefresh = self:getGaiBangLuRenWordsTime(isStart,time)
	-- local yayi = self:getGaiBangYaYiWordsTime(time)
	local str = ""
	if luren and luren ~= {} then
		str = luren.word
	end
	-- if yayi and yayi ~= {} then
	-- 	if yayi.word then
	-- 		str = str .. "\n" ..yayi.word
	-- 	end
	-- end
	return str,isRefresh
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/15 16:40:47
-- @desc 天龙寺条件结果处理
function TeacherTask:dealTianLongConditionAndResult(map,role)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
	local maplayer = controllLayer:getLayer("MapLayer")
	MapRoleLayer:statusButtonFunc(false,function()
		 RichPrint("main","你正在参禅打坐，请不要被外物所迷。")
	end)
	MapRoleLayer:exitButtonFunc(false,function()
		 RichPrint("main","你正在参禅打坐，请不要被外物所迷。")
	end)
	maplayer:setUnmoveRoom(true,function()
		RichPrint("main","你正在参禅打坐，请不要被外物所迷。")
	end)
	map:setCanLeave(false)
	map.__MapLayer:setNPCTouchEnabled(true,function()
		RichPrint("main","你正在参禅打坐，请不要被外物所迷。")
	end)
	self._handle = map.__MapLayer:schedule(function()
		local num = math.random(1,#receiveTask.words)
		RichPrint("main",receiveTask.words[num])
		receiveTask.success[num] = true
		Helper:print_lua_table(receiveTask.success)
		if num == 3 then
		--创建阿修罗
			self:createTianLongAXiuLuo(map,receiveTask.npcId[1],receiveTask.npcBaseId[1],receiveTask.roomId)
		end
		local isComplete = "Y"
		for k,v in pairs(receiveTask.success) do 
			if v == false then
				isComplete = "N"
			end
		end
		if isComplete == "Y" then
			map:removeRoomRole(receiveTask.roomId,receiveTask.npcId[2])
			receiveTask.roomId = {}
			MapRoleLayer:exitButtonFunc(true)
			MapRoleLayer:statusButtonFunc(true)
			maplayer:setUnmoveRoom(false)
			map:setCanLeave(true)
			map.__MapLayer:setNPCTouchEnabled(false)
			map.__MapLayer:unschedule(self._handle)
			map.__MapLayer:setNeedRefreshMap()
		end
		self:setTeacherTaskAttr("isComplete",isComplete)
		self:setTeacherTaskAttr("receiveTask",receiveTask)
	end,2.0)
end
function TeacherTask:createTianLongAXiuLuo(map,roleId,baseId,roomId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local role = {}
	local basenpc = self:getNPCBaseList(baseId)
	for k ,v in pairs(basenpc) do
		role[k] = v
	end
	role.id = roleId
	role.baseId = baseId
	role.canCompete = false
	role.canTalk = false
	role.canKill = false
	role.type = "role"
	map:createRole(role)
	map:addRoomRole(receiveTask.roomId,roleId,true)--addRoomRole(roomId, roleId, isRefresh)
	self:removeTeacherTaskNPC(map,roomId,role.id)
	map.__MapLayer:pauseSchedulerAndActions(self._handle)
	map.__MapLayer:setNeedRefreshMap()
	-- print(receiveTask.roomId,roleId,"******************************************")	
	role = map:getRole(roleId)--roomId,roleId
	-- print("_____________________________________________________________________________")
	-- print("_____________________________________________________________________________")
	-- print("_____________________________________________________________________________")
	-- print("阿修罗的最大血量"..tostring(role:getFinalAttr("qiMax")))
	-- print("_____________________________________________________________________________")
	-- print("_____________________________________________________________________________")
	-- print("_____________________________________________________________________________")
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
	local maplayer = controllLayer:getLayer("MapLayer")
		local currRole = role
		local role = currRole
		local currMap = map
		self.mapLayer = map.__MapLayer
		local player = User:getRole()
		map:doConditionAndResult(role.conditionAndResults,
            {
                operation = "切磋",
                currRole = role,
                currRoomId = self.mapLayer._currRoom.id,
                mapLayer = self.mapLayer
            })

		role:initNpcAttr() -- NPC状态初始化

        map:afterFightWithQieCuo(player, role, function(winTeamId)
            -- 战斗胜利条件结果
            if winTeamId == 1 then
                -- PopText("你战胜了" .. role:getName())
                map:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "成功",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })

                self.mapLayer:delayRefreshMap()
                -- 刷新房间条件结果
				map:doRoomConditionAndResult(receiveTask.roomId)
				local isComplete = "Y"
				receiveTask.success["阿修罗"] = true
				for k,v in pairs(receiveTask.success) do 
					if v == false then
						isComplete = "N"
					end
				end

				RichPrint("main","YEL你战胜了自己的心魔，修为有所精进。")
				map:removeRoomRole(receiveTask.roomId,role.id)
				if isComplete == "Y" then
					map:removeRoomRole(receiveTask.roomId,receiveTask.npcId[2])
					receiveTask.roomId = {}
					MapRoleLayer:exitButtonFunc(true)
					MapRoleLayer:statusButtonFunc(true)
					maplayer:setUnmoveRoom(false)
					map:setCanLeave(true)
					map.__MapLayer:setNPCTouchEnabled(false)
					map.__MapLayer:unschedule(self._handle)
				else
					map.__MapLayer:resumeSchedulerAndActions(self._handle)
				end
				self:setTeacherTaskAttr("isComplete",isComplete)
				self:setTeacherTaskAttr("receiveTask",receiveTask)
				map.__MapLayer:setNeedRefreshMap()
            else
                -- PopText("你被" .. role:getName() .. "打趴在地")
                currMap:doConditionAndResult(role.conditionAndResults,
                    {
                        conditionType = "切磋",
                        result = "失败",
                        currRole = role,
                        currRoomId = self.mapLayer._currRoom.id,
                        mapLayer = self.mapLayer
                    })
                RichPrint("main","你没有战胜自己的心魔，修为难有寸进。")
                map.__MapLayer:resumeSchedulerAndActions(self._handle)
                map:removeRoomRole(receiveTask.roomId,role.id)
                self.mapLayer:delayRefreshMap()
                map.__MapLayer:setNeedRefreshMap()
                -- 刷新房间条件结果
                map:doRoomConditionAndResult(receiveTask.roomId)
            end
        end)
       map.__MapLayer:setNeedRefreshMap()
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/19 11:07:49
-- @desc 崆峒条件结果处理
function TeacherTask:dealKongTongConditionAndResult(resultType,num,npcrole,mapLayer)
	if  not resultType and not num then
		return 
	end
	local receiveTask = Helper:getDef(self:getTeacherTaskAttr("receiveTask"),{})
	local isSolve = Helper:getDef(receiveTask.isSolve,{})
	if resultType == "开解" then
		mapLayer:removeRoomRole(receiveTask.roomId[num],npcrole.id)
		isSolve[num] = 1
		RichPrint("main","你走上前去开解这名侠客的烦恼，在你的开解之下，这名侠客终于不再困恼，对你道谢了一番便离开了。")
		mapLayer.__MapLayer:setNeedRefreshMap()
	elseif resultType == "调解" then
		receiveTask.isCompare = Helper:getDef(receiveTask.isCompare,{})
		-- tmp = Helper:gtDef(tmp[num],{})
		if receiveTask.isCompare[num] == nil then
			receiveTask.isCompare[num] = {}
		end
		if receiveTask.isCompare[num][1] == nil or(receiveTask.isCompare[num][1] and receiveTask.isCompare[num][1] ~= npcrole.id) then
			table.insert(receiveTask.isCompare[num],npcrole.id)
			RichPrint("main","只要那小子不计较，我倒是可以和他和解。")
		end
		print("*+++++++++++++++++++++++++++++++++++++++++++++++++*")
		print(npcrole.id,#receiveTask.isCompare[num], num)
		if #receiveTask.isCompare[num] >= 2 then
			print("removeRoomRole:",receiveTask.roomId[num],receiveTask.npcId[num][1])
			mapLayer:removeRoomRole(receiveTask.roomId[num],receiveTask.npcId[num][1])
			print("removeRoomRole:",receiveTask.roomId[num],receiveTask.npcId[num][2])
			mapLayer:removeRoomRole(receiveTask.roomId[num],receiveTask.npcId[num][2])
			isSolve[num] = 1
			RichPrint("main","你走上前去调解两名侠客的恩怨，在你的努力之下，两名侠客终于达成了和解。")
		end
		npcrole.caozuo = false
		mapLayer.__MapLayer:setNeedRefreshMap()
	end
	receiveTask.isSolve = isSolve
	self:setTeacherTaskAttr("receiveTask",receiveTask)
	local solveCount = 0
	for k,v in pairs(receiveTask.isSolve) do 
		solveCount = solveCount+1
	end
	if solveCount >= 3 then
		self:setTeacherTaskAttr("isComplete","Y")
	end
	Helper:print_lua_table(receiveTask)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/19 15:01:31
-- @desc 少林化缘条件结果处理
function TeacherTask:dealShaoLinConditionAndResult(resultType,num,role,map)
	if  not resultType and not num then
		print("化缘处理结果失败")
		return 
	end
	local receiveTask = Helper:getDef(self:getTeacherTaskAttr("receiveTask"),{})
	local hasAsk = Helper:getDef(receiveTask.hasAsk,{})
	for k,v in pairs(receiveTask.npcId) do
		if v == role.id and resultType == 1 then
			hasAsk[k] = 1
		elseif v == role.id and resultType == 2 then
			hasAsk[k] = 2
		end
	end
	receiveTask.hasAsk = hasAsk
	local count = 0
	for k,v in pairs(hasAsk) do 
		if v == 1 then
			count = count + 1
		end
	end
	if count == 3 then
		self:setTeacherTaskAttr("isComplete","Y")
		for k,v in pairs(receiveTask.roomId) do
			if hasAsk[k] ~= 1 and hasAsk[k] ~= 2 then
				map:removeRoomRole(v,receiveTask.npcId[k])
			end
		end
		receiveTask.roomId = {}
	end
	self:setTeacherTaskAttr("receiveTask",receiveTask)
	-- if #receiveTask.roomId == 1 then
	-- 	self:setTeacherTaskAttr("isComplete","Y")
	-- 	receiveTask.roomId = {}
	-- 	receiveTask.npcId = {}
	-- 	receiveTask.success = {}
	-- else 
	-- 	receiveTask.roomId[num] = 0
	-- 	table.remove(receiveTask.npcId,num)
	-- 	-- table.remove(receiveTask.success,num)
	-- 	receiveTask.success[num] = 2
	-- 	local isComplete = "Y"
	-- 	for k,v in pairs(receiveTask.success) do 
	-- 		if v == 1 then
	-- 			isComplete = "N"
	-- 		end
	-- 	end
	-- 	if isComplete == "Y" then
	-- 		self:deleteRoleByBaseId()
	-- 	end
	-- 	self:setTeacherTaskAttr("isComplete",isComplete)
	-- end
	-- self:setTeacherTaskAttr("receiveTask",receiveTask)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/19 16:50:50
-- @desc 处理切磋胜利结果
function TeacherTask:dealCompeteWinResult(maplayer,role,isWin)
	local receiveTask = Helper:getDef(self:getTeacherTaskAttr("receiveTask"),{})
	print("*******************************峨眉切磋结果处理阶段一*****************************************")
	local familyId = User:getRole():getAttr("family").name
	if familyId == "huashan" and receiveTask.taskType == 4 then
		self:dealHuaShanCompeteResult(maplayer,role,isWin)
	elseif familyId == "wudang" and receiveTask.taskType == 4 then
		self:dealWuDangCompeteResult(maplayer,role,isWin)
	elseif familyId == "tiezhang" and receiveTask.taskType == 4 then
		self:dealTieZhangCompeteResult(maplayer,role,isWin)
	elseif familyId == "tangmen" and receiveTask.taskType == 4 then
		self:dealTangMenCompeteResult(maplayer,role,isWin)
	elseif familyId == "emei" then
		print("*******************************峨眉切磋结果处理阶段二*****************************************")
		self:dealDuelEMeiConditionAndResult(maplayer,role,isWin)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/20 10:03:32
-- @desc 武当特殊任务切磋胜利结果处理
function TeacherTask:dealWuDangCompeteResult(maplayer,role,isWin)
	local receiveTask = Helper:getDef(self:getTeacherTaskAttr("receiveTask"),{})
	local roomId = maplayer._currRoom.id
	if isWin == true then
		for k,v in pairs(receiveTask.roomId) do 
			if v == roomId and role.id ==receiveTask.npcId[k] then
				table.remove(receiveTask.roomId,k)
				table.remove(receiveTask.npcId,k)
				self:setTeacherTaskAttr("receiveTask",receiveTask)
				maplayer._currMap:removeRoomRole(roomId,role.id)
				RichPrint("main","YEL"..role.name.."：道爷饶命，我这就滚！")
				break				
			end
		end
		if #receiveTask.roomId == 0 then
			self:setTeacherTaskAttr("isComplete","Y")
			-- PopText(receiveTask.taskName.."已经完成，快去师门领取奖励吧")
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/19 17:24:22
-- @desc 华山特殊任务切磋梳理
function TeacherTask:dealHuaShanCompeteResult(maplayer,role,isWin)
	local receiveTask = Helper:getDef(self:getTeacherTaskAttr("receiveTask"),{})
	local roomId = maplayer._currRoom.id
	if isWin == true then
		for k,v in pairs(receiveTask.roomId) do
			if v == roomId and role.id ==receiveTask.npcId[k] then
				table.remove(receiveTask.roomId,k)
				table.remove(receiveTask.npcId,k)
				self:setTeacherTaskAttr("receiveTask",receiveTask)
				maplayer._currMap:removeRoomRole(roomId,role.id)
				RichPrint("main","YEL"..role.name.."：多谢赐教！")
				break
			end
		end
		if #receiveTask.roomId == 0 then
			self:setTeacherTaskAttr("isComplete","Y")
			PopText(receiveTask.taskName.."已经完成，快去师门领取奖励吧")
		end
	else
		for k,v in pairs(receiveTask.roomId) do 
			if v == roomId and role.id ==receiveTask.npcId[k] then
				RichPrint("main","YEL"..role.name.."：多谢赐教！")
				break
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/27 10:38:57
-- @desc 铁掌切磋结果处理
function TeacherTask:dealTieZhangCompeteResult(maplayer,role,isWin)
	local receiveTask = Helper:getDef(self:getTeacherTaskAttr("receiveTask"),{})
	local roomId = maplayer._currRoom.id
	print("isWin:^^^^^^^^^^^^^^^^^^",isWin)
	print("******************************************")
	if isWin == true then
		for k,v in pairs(receiveTask.npcId) do 
			print("receiveTask.npcId:",v)
			if v == role.id then
				receiveTask.hasAsk[k] = 1
				maplayer._currMap:removeRoomRole(roomId,role.id)
				local count = 0
				for i,j in pairs(receiveTask.hasAsk) do
					count = count + 1
				end
				if count >= 3 then
					self:setTeacherTaskAttr("isComplete","Y")
					for i,j in pairs(receiveTask.npcId) do 
						if receiveTask.hasAsk[i] ~= 1 then
							maplayer._currMap:removeRoomRole(receiveTask.roomId[i],j)--maplayer.__currMap
						end
					end
					receiveTask.roomId = {}
				end
				self:setTeacherTaskAttr("receiveTask",receiveTask)
				RichPrint("main","你三招两式便击败了这名年轻人，这让他对你推崇不已，当即决定加入铁掌帮，你成功地收入了一名弟子")
				maplayer:setNeedRefreshMap()
			end
		end
	else
		RichPrint("main","切磋失败")
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 11:04:34
-- @desc 海鲸帮交谈获得任务道具
function TeacherTask:dealHaiJingTalkResult(arg1,arg2,mapLayer,role,roomId)
		local itemList = string.split(arg1,";")
		for k, v in ipairs(itemList) do 
			itemList[k] = string.split(v,",")
			if #itemList[k] ~= 2 then --设置奖励物品默认数量
				itemList[k][2] = 1
			end
		end
		print("交谈奖励物品")
		Helper:print_lua_table(itemList)
		for k,v in ipairs(itemList) do --判断奖励列表中的物品是否存在,领取全部物品后要移除NPC，防止只获取部分物品
			local item = Item:getOneItemByKey(v[1])
			if item == nil then
				PopText("物品"..tostring(v[1]).."不存在")
				return
			end
		end
		local reWard = {}
		for k,v in pairs(itemList) do 
			reWard[v[1]] = tonumber(v[2])
		end
		if User:getRole():checkCanBuyTwoOrMoreThings(reWard) ~= true then
			PopText("背包空间不足")
			return
		end
		for k,v in ipairs(itemList) do --获得物品
			User:getRole():addItemCount(v[1],tonumber(v[2]))
			local item = Item:getOneItemByKey(v[1])
			PopText("获得物品"..item.name.."X"..tostring(v[2]))
		end
		RichPrint("main",role.name..":"..arg2)
		local receiveTask = self:getTeacherTaskAttr("receiveTask")
		for k,v in pairs(receiveTask.npcId) do 
			if v ==role.id then
				table.remove(receiveTask.npcId,k)
				table.remove(receiveTask.roomId,k)
				table.remove(receiveTask.success,k)
				self:setTeacherTaskAttr("receiveTask",receiveTask)
				if #receiveTask.roomId == 0 and User:getRole():getItem("shimenwupin35").count >= 5 then
					self:setTeacherTaskAttr("isComplete","Y")
					User:getRole():addItemCount("shimenwupin35",0-User:getRole():getItem("shimenwupin35").count)
				end
			end
		end
		mapLayer:removeRoomRole(roomId,role.id)--获取奖励物品，移除NPC
		mapLayer.__MapLayer:setNeedRefreshMap()
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 12:05:03
-- @desc 决斗条件结果处理
function TeacherTask:dealDuelConditionAndResult(isWin,role,map)
	local familyId = User:getRole():getFamilyId()
	print(familyId)
	if familyId == "haijing" then
		self:dealDuelHaiJingConditionAndResult(isWin,role)
	elseif familyId == "taohuadao" or familyId == "mingjiao" then
		self:dealDuelTaoHuaDaoConditionAndResult(isWin,role)
	elseif familyId == "murong" then
		self:dealDuelMuRongConditionAndResult(isWin,role)
	elseif familyId == "mizong" then
		self:dealDuelMiZongConditionAndResult(isWin,role)
	elseif familyId == "wudu" then
		self:dealDuelWuDuConditionAndResult(isWin,role)
	elseif familyId == "riyueshenjiao" then
		self:dealDuelRiYueShenJiaoConditionAndResult(isWin,role,map)
	elseif familyId == quanzhen then
		self:dealDuelQuanZhenConditionAndResult(isWin,role)
	end
end

function TeacherTask:dealDuelQuanZhenConditionAndResult(isWin,role) 
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if isWin == true then

	else
		PopText("你被元军高手打败了，在密函落入敌手之前，你将其销毁了。")
		User:getRole():addItemCount("shimenwupin32",-1)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/01 17:15:55
-- @desc 日月神教决斗条件结果
function TeacherTask:dealDuelRiYueShenJiaoConditionAndResult(isWin,role,map)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	for k,v in pairs(receiveTask.npcId) do 
		if role.id == v then
			if isWin == true then
				print(receiveTask.success)
				if receiveTask.success == role.baseId then
					RichPrint("main","你查看此人面容，恰是黑木崖令上所述，你已经完成了任务，可以回去复命了。")
					for k,v in pairs(receiveTask.npcId) do 
						map:removeRoomRole(receiveTask.roomId[k],v)
					end
					map.__MapLayer:setNeedRefreshMap()
					receiveTask.roomId = {}
					self:setTeacherTaskAttr("receiveTask",receiveTask)
					self:setTeacherTaskAttr("isComplete","Y")
					User:getRole():addItemCount("shimenwupin33",-1)
				else
					RichPrint("main","你仔细查看这个人的面容，发现与目标相去甚远，应该是杀错了人。")
				end
			else
				RichPrint("main","YEL"..role.name.."：就这点本事也敢来杀我？")
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 12:08:13
-- @desc 海鲸帮决斗结果处理
function TeacherTask:dealDuelHaiJingConditionAndResult(isWin,role)
	print("isWin,role",isWin,role)
	if isWin == false then
		return
	end
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	for k,v in pairs(receiveTask.npcId) do 
		if v ==role.id then
			local item = Item:getOneItemByKey("shimenwupin35")
			if User:getRole():checkCanBuyThings("shimenwupin35",1) ~= true then
				-- PopText("背包空间不足")
				local ControllLayer = require("app.views.layer.ControllLayer")
				local controllLayer = ControllLayer:getInstance()
				local mapLayer = controllLayer:getLayer("MapLayer")
				mapLayer._currMap:dropItem(mapLayer._currRoom.id,"shimenwupin35")
			else
				User:getRole():addItemCount("shimenwupin35",1)
				PopText("获得物品"..item.name.."X"..tostring(1))
			end
			table.remove(receiveTask.npcId,k)
			table.remove(receiveTask.roomId,k)
			table.remove(receiveTask.success,k)
			self:setTeacherTaskAttr("receiveTask",receiveTask)
			RichPrint("main","你从海鲨帮弟子的身上搜得了一份"..item.name)
			if #receiveTask.roomId == 0 and User:getRole():getItem("shimenwupin35").count >= 5 then
				self:setTeacherTaskAttr("isComplete","Y")
				User:getRole():addItemCount("shimenwupin35",0-User:getRole():getItem("shimenwupin35").count)
			end
		end
	end

end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 16:15:01
-- @desc 桃花岛决斗结果处理
function TeacherTask:dealDuelTaoHuaDaoConditionAndResult(isWin,role)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if role.id == receiveTask.npcId then
		receiveTask.roomId = {}
		receiveTask.npcId = {}
		self:setTeacherTaskAttr("receiveTask",receiveTask)
		self:setTeacherTaskAttr("isComplete","Y")
		PopText("任务已经完成")
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 16:38:23
-- @desc 慕容山庄决斗结果处理
function TeacherTask:dealDuelMuRongConditionAndResult(isWin,role)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if role.id == receiveTask.npcId then
		receiveTask.roomId = {}
		receiveTask.npcId = {}
		self:setTeacherTaskAttr("receiveTask",receiveTask)
		self:setTeacherTaskAttr("isComplete","Y")
		PopText("任务已经完成")
		RichPrint("main","你将叛徒杀死，从他身上搜出一个黄布包，里面正是慕容家的玉玺，快快回去复命吧。")
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 15:14:14
-- @desc 天山条件结果处理
function TeacherTask:dealTianShanConditionAndResult(role,getType,maplayer,isWin)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if (getType == "QieCuo" and isWin == true) or getType ~= "QieCuo" then
		for k,v in pairs(receiveTask.npcId) do 
			print("——————————————进行判断:",receiveTask.roomId[k],role.id)
			if v == role.id then
				maplayer:removeRoomRole(receiveTask.roomId[k],role.id)--removeRoomRole
				print("——————————————删除师门任务NPC————————————————————",receiveTask.roomId[k],role.id)
				receiveTask.hasAsk[k] = 1
				if User:getRole():checkCanBuyTwoOrMoreThings({["shimenwupin36"] = 1}) == true then
					User:getRole():addItemCount("shimenwupin36",1)
					local item = Item:getOneItemByKey("shimenwupin36")
					PopText("获得物品"..item.name.."X"..tostring(1))
				else
					maplayer:dropItem(receiveTask.roomId[k],"shimenwupin36")
				end
				if getType == "QieCuo" then
					RichPrint("main","YEL天山附属：不愧是天山派弟子，这是说好的贡品还望笑纳。")
				else
					RichPrint("main","YEL天山附属：原来是天山弟子，这是说好的贡品，还请笑纳。")
				end
				local count = 0
				for i,j in pairs(receiveTask.hasAsk) do
					count = count + 1 
				end
				if count >= 3 and Helper:getDef(Helper:getDef(User:getRole():getItem("shimenwupin36"),{}).count,0) >= 3 then--
					self:setTeacherTaskAttr("isComplete","Y")
					for i,j in pairs(receiveTask.npcId) do
						if receiveTask.hasAsk[i] ~= 1 then
							maplayer:removeRoomRole(receiveTask.roomId[i],j)
						end
					end
					receiveTask.roomId = {}
					User:getRole():addItemCount("shimenwupin36",0-User:getRole():getItem("shimenwupin36").count)
				end
				self:setTeacherTaskAttr("receiveTask",receiveTask)
			end
		end
	else
		RichPrint("main","YEL切磋失败了")
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 17:45:39
-- @desc 雪山寺拐走条件结果处理
function TeacherTask:dealMiZongConditionAndResult(role,maplayer,resultType)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask.success == 2 then
		RichPrint("main","你走上前去一手制住美女，一手将早已准备好的蒙汗巾蒙住了美女的口鼻，美女一下子便晕厥了过去，你连忙将其扛起。")
		self:setTeacherTaskAttr("isComplete","Y")
		maplayer:removeRoomRole(receiveTask.roomId,receiveTask.npcId[1])
		receiveTask.roomId = {}
		receiveTask.npcId = {}
		self:setTeacherTaskAttr("receiveTask",receiveTask)		
		maplayer.__MapLayer:setNeedRefreshMap()
	else
		local result = true
		for i=1,2 do 
			if receiveTask.npcId[i+1] then
				-- self:dealMiZongConditionToAddNPC(maplayer,receiveTask.npcId[i+1],receiveTask.npcBaseId[2],receiveTask.roomId)
				local role = {}
				if not self:checkRoleIsInRoom(maplayer,receiveTask.roomId,receiveTask.npcId[i+1]) then
					PopText("出现侠客")
					local basenpc = self:getNPCBaseList(receiveTask.npcBaseId[2])
					for k,v in pairs(basenpc) do 
						role[k] = v
					end
					role.id = receiveTask.npcId[i+1]
					role.baseId = receiveTask.npcBaseId[2]
					role.canKill = true
					role.canTalk = false
					role.type = "role"
					role.withCorpse = -1
					maplayer:createRole(role)
					maplayer:addRoomRole(receiveTask.roomId,receiveTask.npcId[i+1],true)
					self:removeTeacherTaskNPC(maplayer,receiveTask.roomId,role.id)
					maplayer.__MapLayer:setNeedRefreshMap()
				end
				result = false
			end
		end

		if result == true then
			RichPrint("main","你走上前去一手制住美女，一手将早已准备好的蒙汗巾蒙住了美女的口鼻，美女一下子便晕厥了过去，你连忙将其扛起。")
			self:setTeacherTaskAttr("receiveTask",receiveTask)
			self:setTeacherTaskAttr("isComplete","Y")
			maplayer:removeRoomRole(receiveTask.roomId,receiveTask.npcId[1])
			receiveTask.roomId = {}
			receiveTask.npcId = {}	
			maplayer.__MapLayer:setNeedRefreshMap()
		else
			RichPrint("main","你正准备将美女拐走，却没想到一旁跳出两个侠客，口中大喊你为淫贼，护住了美女。")
		end
	end
end
function TeacherTask:dealMiZongConditionToAddNPC(mapLayer,roleId,baseId,roomId)
	local role = {}
	if not self:checkRoleIsInRoom(mapLayer,roomId,roleId) then
		local basenpc = self:getNPCBaseList(baseId)
		for k,v in pairs(basenpc) do 
			role[k] = v
		end
		role.id = roleId
		role.baseId = baseId
		role.canKill = true
		role.canTalk = false
		role.type = "role"
		role.name = basenpc.name
		mapLayer:createRole(role)
		mapLayer:addRoomRole(roomId,roleId,true)
		self:removeTeacherTaskNPC(mapLayer,roomId,role.id)
	end
end	
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/22 18:12:03
-- @desc 密宗的决斗条件结果
function TeacherTask:dealDuelMiZongConditionAndResult(isWin,role)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask.taskType == 4 then
		for k,v in pairs(receiveTask.npcId) do
			if v == role.id then
				table.remove(receiveTask.npcId,k)
				self:setTeacherTaskAttr("receiveTask",receiveTask)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/27 17:49:01
-- @desc 五毒决斗条件结果
function TeacherTask:dealDuelWuDuConditionAndResult(isWin,role)
	print("杀死毒物后的处理")
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask.taskType == 4 then
		for k,v in pairs(receiveTask.npcId) do
			if v == role.id then
				table.remove(receiveTask.npcId,k)
				table.remove(receiveTask.roomId,k)
				if #receiveTask.roomId == 0 then
					self:setTeacherTaskAttr("isComplete","Y")
				end
				self:setTeacherTaskAttr("receiveTask",receiveTask)
			end
		end
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/27 16:15:22
-- @desc 铁掌帮招收帮众的条件结果
function TeacherTask:dealTieZhangConditionAndResult(role,isSuccess,mapLayer)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local _handle = nil 
	role.caozuo = false
	mapLayer.__MapLayer:setNeedRefreshMap()
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
	local maplayer = controllLayer:getLayer("MapLayer")
	MapRoleLayer:exitButtonFunc(false,function()
		 RichPrint("main","正在等待对方的答复，有点耐心吧")
	end)
	MapRoleLayer:statusButtonFunc(false,function()
		 RichPrint("main","正在等待对方的答复，有点耐心吧")
	end)
	maplayer:setUnmoveRoom(true,function()
		RichPrint("main","正在等待对方的答复，有点耐心吧")
	end)
	mapLayer:setCanLeave(false)
	mapLayer.__MapLayer:setNPCTouchEnabled(true,function()
		RichPrint("main","正在等待对方的答复，有点耐心吧")
	end)
	if isSuccess == 1 then
		local text = {
			[1] = "你一看这年轻人便觉得他根骨不错，上前与他搭话。",
			[2] = "一番寒暄之后，你向他提出了加入铁掌帮的要求。",
			[3] = "他听了之后思考了一会，点了点头。",			
			[4] = "你成功地收入了一名弟子。"
		}
		_handle = mapLayer.__MapLayer:schedule(function()
			if #text > 0 then
				RichPrint("main",text[1])
				table.remove(text,1)
			else
				for k,v in pairs(receiveTask.npcId) do 
					if v == role.id then
						mapLayer:removeRoomRole(receiveTask.roomId[k],receiveTask.npcId[k])
						receiveTask.hasAsk[k] = 1
						local count = 0
						for k,v in pairs(receiveTask.hasAsk) do
							count = count + 1
						end
						if count >= 3 then
							self:setTeacherTaskAttr("isComplete","Y")
							for i,j in pairs(receiveTask.npcId) do 
								if receiveTask.hasAsk[i] ~= 1 then
									mapLayer:removeRoomRole(receiveTask.roomId[i],j)
								end
							end
							receiveTask.roomId = {}
						end
						self:setTeacherTaskAttr("receiveTask",receiveTask)
						mapLayer.__MapLayer:setNeedRefreshMap()
					end
				end
				MapRoleLayer:exitButtonFunc(true)
				MapRoleLayer:statusButtonFunc(true)
				maplayer:setUnmoveRoom(false)
				mapLayer:setCanLeave(true)
				mapLayer.__MapLayer:setNPCTouchEnabled(false)
				mapLayer.__MapLayer:unschedule(_handle)
			end
		end,1.0)
	else
		local text = {
			[1] = "你一看这年轻人便觉得他根骨不错，上前与他搭话。",
			[2] = "一番寒暄之后，你向他提出了加入铁掌帮的要求。",
			[3] = "他思考一会，说想见识一下铁掌帮武功，若是能击败他，他便加入铁掌帮。",
		}
		_handle = mapLayer.__MapLayer:schedule(function()
			if #text > 0 then
				RichPrint("main",text[1])
				table.remove(text,1)
			else
				role.caozuo = false
				role.canCompete = true
				mapLayer.__MapLayer:setNeedRefreshMap()
				MapRoleLayer:exitButtonFunc(true)
				MapRoleLayer:statusButtonFunc(true)
				maplayer:setUnmoveRoom(false)
				mapLayer:setCanLeave(true)
				mapLayer.__MapLayer:setNPCTouchEnabled(false)
				mapLayer.__MapLayer:unschedule(_handle)
			end
		end,1.0)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/27 16:15:55
-- @desc z五毒抓取毒物的条件结果处理
function TeacherTask:dealWuDuConditionAndResult(role,isSuccess,mapLayer)
	local text = {
		[1] = "你左手拿着五毒教专门抓取毒物五毒钩，右手拿着吸引毒物的奇香小瓶，小心翼翼地靠近毒物…",
		[2] = "毒物似乎被奇香小瓶内的气味吸引住了，一动不动..",
		[3] = "你抓住机会将五毒钩探出，伸向毒物！",
	}
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if isSuccess == 1 then
		local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
		local maplayer = controllLayer:getLayer("MapLayer")
		MapRoleLayer:exitButtonFunc(false,function()
			 PopText("专心捕捉毒物")
		end)
		MapRoleLayer:statusButtonFunc(false,function()
			 PopText("专心捕捉毒物")
		end)
		maplayer:setUnmoveRoom(true,function()
			PopText("专心捕捉毒物")
		end)
		mapLayer:setCanLeave(false)
		mapLayer.__MapLayer:setNPCTouchEnabled(true,function()
				PopText("专心捕捉毒物")
			end)
		self._handle = mapLayer.__MapLayer:schedule(function()
			if #text > 0 then
				RichPrint("main",text[1])
				table.remove(text,1)
			else
				for k,v in pairs(receiveTask.npcId) do 
					print(v,role.id)
					if v == role.id then
						print("删除毒物")
						mapLayer:removeRoomRole(receiveTask.roomId[k],receiveTask.npcId[k])
						table.remove(receiveTask.npcId,k)
						table.remove(receiveTask.roomId,k)
						RichPrint("main","毒物被奇香所引，来不及反应，被你勾中收入袋中。")
						if #receiveTask.roomId == 0 then
							receiveTask.roomId = {}
							self:setTeacherTaskAttr("isComplete","Y")
						end
						self:setTeacherTaskAttr("receiveTask",receiveTask)
						mapLayer.__MapLayer:setNeedRefreshMap()
						mapLayer.__MapLayer:unschedule(self._handle)
						MapRoleLayer:exitButtonFunc(true)
						MapRoleLayer:statusButtonFunc(true)
						maplayer:setUnmoveRoom(false)
						mapLayer:setCanLeave(true)
						mapLayer.__MapLayer:setNPCTouchEnabled(false)
					end
				end
			end
		end,1.0)
	else
	end
end

-----------------------------------------------------------------------------------------------------------
-- -- @author GaoHanZheng
-- -- @time 2017/07/05 11:23:42
-- -- @desc 全真接头NPC结果处理
-- function TeacherTask:dealQuanZhenJieTouConditionAndResult(mapLayer,role)
-- 	local receiveTask = self:getTeacherTaskAttr("receiveTask")
-- 	local item = User:getRole():getItem("shimenwupin32")
-- -- receiveTask.name,map,roomId,receiveTask.giftNPC,receiveTask.itemgift

-- 	if item == nil then
-- 		RichPrint("main",role.name.."：毁掉就毁掉吧，人平安就好，近来元兵调动频繁，有南下之势，我辈当早作准备。")
-- 	else
-- 		RichPrint("main",role.name.."：既然提前知晓元兵如此计划，定不能让他们得逞。这次真是有劳你了。")
-- 	end
-- 	receiveTask.roomId = {}
-- 	mapLayer:removeRoomRole(receiveTask.roomId,receiveTask.giftNPC)
-- 	self:setTeacherTaskAttr("receiveTask",receiveTask)
-- 	self:setTeacherTaskAttr("isComplete","Y")
-- 	mapLayer.__MapLayer:setNeedRefreshMap()

-- end
function TeacherTask:dealQuanZhenJieTouJiaoTan(map,role)
	local item = User:getRole():getItem("shimenwupin32")
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask.isGet == true then
		if item == nil then
			RichPrint("main","YEL"..role.name.."：唉，此事也怪不得你，你回去复命吧。")
			receiveTask.roomId = {}
			map:removeRoomRole(receiveTask.jietouRoomId,role.id)
			receiveTask.jiangli = 1
			self:setTeacherTaskAttr("receiveTask",receiveTask)
			self:setTeacherTaskAttr("isComplete","Y")
			map.__MapLayer:setNeedRefreshMap()
		else
			RichPrint("main","YEL"..role.name.."：军情密函你带来了没？快交给我。")
		end
	else
		RichPrint("main","你是何人？我并不认识你。")
	end
end
function TeacherTask:dealQuanZhenJieTouSongLi(map,role)
	local item = User:getRole():getItem("shimenwupin32")
	if item == nil then
		RichPrint("main",role.name.."：我不接受你的物品。")
	else
		RichPrint("main",role.name.."：既然提前知晓元兵如此计划，定不能让他们得逞。这次真是有劳你了。")
		local receiveTask = self:getTeacherTaskAttr("receiveTask")
		-- receiveTask.roomId = {}
		User:getRole():addItemCount("shimenwupin32",-1)
		map:removeRoomRole(receiveTask.jietouRoomId,role.id)
		receiveTask.jiangli = 2
		self:setTeacherTaskAttr("receiveTask",receiveTask)
		self:setTeacherTaskAttr("isComplete","Y")
		map.__MapLayer:setNeedRefreshMap()
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/05 12:11:30
-- @desc 昆仑学琴
function TeacherTask:dealKunLunXueQinConditionAndResult(mapLayer,role)
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local text = {
		[1] = "RAN琴道大家指点了你的琴技，这让你受益匪浅。",
		[2] = "RAN琴道大家向你灌输着琴道的知识，许多之前困恼你的问题都迎刃而解。",
		[3] = "RAN你弹着琴，有琴道大家在旁指点，你感觉弹出的曲子也比平时好了不少。",
		[4] = "RAN弦音缭绕，在琴道大家指点之下，你不由得进入了物我两忘的境地，这让你的琴技收益良多。"
	}
	self.time = 0
	if self.isLearnning == nil then
		Audio:playMusic("LunJian",true)
		self.isLearnning = true
		local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
		local maplayer = controllLayer:getLayer("MapLayer")
		MapRoleLayer:exitButtonFunc(false,function()
			 RichPrint("main","你沉浸于琴道大家的琴乐之中，不能自拔。")
		end)
		MapRoleLayer:statusButtonFunc(false,function()
			 RichPrint("main","你沉浸于琴道大家的琴乐之中，不能自拔。")
		end)
		maplayer:setUnmoveRoom(true,function()
			RichPrint("main","你沉浸于琴道大家的琴乐之中，不能自拔。")
		end)
		mapLayer:setCanLeave(false)
		mapLayer.__MapLayer:setNPCTouchEnabled(true,function()
			RichPrint("main","你沉浸于琴道大家的琴乐之中，不能自拔。")
		end)
		self._handle = mapLayer.__MapLayer:schedule(function()
			if self.time >= 30 then
				MapRoleLayer:exitButtonFunc(true)
				MapRoleLayer:statusButtonFunc(true)
				maplayer:setUnmoveRoom(false)
				mapLayer:setCanLeave(true)
				mapLayer:removeRoomRole(receiveTask.roomId,receiveTask.npcId)
				receiveTask.roomId = {}
				self:setTeacherTaskAttr("receiveTask",receiveTask)
				self:setTeacherTaskAttr("isComplete","Y")
				RichPrint("main","学习结束")
				mapLayer.__MapLayer:unschedule(self._handle)
				self._handle = nil
				self.isLearnning = nil
				Audio:stopMusic("LunJian")
				mapLayer.__MapLayer:setNPCTouchEnabled(false)
				mapLayer.__MapLayer:setNeedRefreshMap()
			else
				local random = math.random(1,#text)
				RichPrint("main",text[random])
				self.time = self.time + 1
			end
		end,1.0)
	else

	end
end
function TeacherTask:dealTangMenLainQiConditionAndResult(mapLayer,role)
	local text1  = {
		[1] = "你找到炼器大师，恭敬地提出了炼制暗器的要求。",
		[2] = "炼器大师表示在炼器途中不能收到任何干扰，你欣然允诺。",
		[3] = "炼器开始了，请保护炼器大师不受干扰。"
	}
	local text2  = {
		[1] = "大师专心致志地制作着暗器，你看着他专心的样子，不由得心生向往。",
		[2] = "大师拿起工具敲炼着暗器，时不时发出叮当之声，声音沁人心脾，令人动容。",
		[3] = "却见大师双手上下翻飞，一动一行皆贴合自然，不由得感慨其技艺高超。"
	}
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
	local maplayer = controllLayer:getLayer("MapLayer")
	MapRoleLayer:exitButtonFunc(false,function()
		 RichPrint("main","正在炼器，请保护炼器大师不受干扰~")
	end)
	MapRoleLayer:statusButtonFunc(false,function()
		 RichPrint("main","正在炼器，请保护炼器大师不受干扰~")
	end)
	maplayer:setUnmoveRoom(true,function()
		RichPrint("main","正在炼器，请保护炼器大师不受干扰~")
	end)
	mapLayer:setCanLeave(false)
	maplayer:setNPCTouchEnabled(true,function()
		RichPrint("main","正在炼器，请保护炼器大师不受干扰~")
	end)
	role.caozuo = false
	role.caozuo1 = true
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local totalCount,count = 0,0
	self._handle = mapLayer.__MapLayer:schedule(function()
		if #text1 ~= 0 then
			RichPrint("main",text1[1])
			table.remove(text1,1)
		else
			if totalCount >= 30 then
				mapLayer:removeRoomRole(receiveTask.roomId,role.id)
				receiveTask.roomId = {}
				self:setTeacherTaskAttr("receiveTask",receiveTask)
				self:setTeacherTaskAttr("isComplete","Y")
				RichPrint("main","HIY炼器已完成，炼器大师将打造好的暗器交给了你便离开了。")
				MapRoleLayer:exitButtonFunc(true)
				MapRoleLayer:statusButtonFunc(true)
				maplayer:setUnmoveRoom(false)
				mapLayer:setCanLeave(true)
				maplayer:setNPCTouchEnabled(false)
				mapLayer.__MapLayer:setNeedRefreshMap()
				mapLayer.__MapLayer:unschedule(self._handle)
			else
				if count >= 8 then
					count = 0
					local random = math.random(1,2)
					if random == 2 then
						random = 1
						for i=1,random do 
							local basenpc = self:getNPCBaseList(receiveTask.npcBaseId[2])
							local role = {}
							role = basenpc
							local roleId = receiveTask.npcBaseId[2]..tostring(Helper:getOnlyId())
							role.id = roleId
							role.baseId = receiveTask.npcBaseId[2]
							role.canKill = false
							role.canCompete = true
							role.canTalk = false
							role.type = "role"
							mapLayer:createRole(role)
							mapLayer:addRoomRole(receiveTask.roomId,roleId,true)
							self:removeTeacherTaskNPC(mapLayer,receiveTask.roomId,role.id)
						end
						maplayer:setNPCTouchEnabled(false)
						RichPrint("main","RED正在此时，远处走来一些恶匪，快去赶开他们，不要让其打扰大师炼器！")
						mapLayer.__MapLayer:setNeedRefreshMap()
						mapLayer.__MapLayer:pauseSchedulerAndActions(self._handle)
					end
				else
					local random = math.random(1,#text2)
					RichPrint("main",text2[random])
					totalCount = totalCount + 1
					count = count + 1
				end
			end
		end
	end,1.0)
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/07/11 11:05:38
-- @desc 唐门恶贼切磋结果
function TeacherTask:dealTangMenCompeteResult(maplayer,role,isWin)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if isWin == true then
		local roleList = maplayer._currMap:getRoomRoleList(receiveTask.roomId)
		for k,v in pairs(roleList) do 
			local item = maplayer._currMap:getRole(v) 
			if item.type == "role" then
				if item.id == role.id and role.baseId == receiveTask.npcBaseId[2] then
					RichPrint("main",role.name..":YEL饶命啊，小的有眼不识泰山……再也不敢了……")
					maplayer._currMap:removeRoomRole(receiveTask.roomId,role.id)
					maplayer:setNPCTouchEnabled(true,function()
						RichPrint("main","正在炼器，请保护炼器大师不受干扰~")
					end)
				end
			end
		end
		roleList = maplayer._currMap:getRoomRoleList(receiveTask.roomId)
		local canContinue = true
		for k,v in pairs(roleList) do 
			local item = maplayer._currMap:getRole(v)
			if item.type == "role" then
				print("*************",item.baseId)
				if item.baseId == receiveTask.npcBaseId[2] then
					canContinue = false
				end
			end
		end
		if canContinue == true then
			maplayer:resumeSchedulerAndActions(self._handle)
		end
	else
		RichPrint("main","就这点水平还想在这里造次！")
	end
end
--峨眉煮粥
function TeacherTask:dealEMeiZhuZhouConditionAndResult(map,role)
		local text = {
			[1] = "鼓捣了一阵，终于可以开始煮粥了；",
			[2] = "米粒和清水在大铁锅里慢慢煮开了，发出滋滋的声音；",
			[3] = "大米的清香被热力催发出来，随风飘散，让人食指大动；",
			[4] = "粥熟了。",
		}
		self.epu = nil
		self.count = 1
		local MapRoleLayer = map.__MapLayer.ControllLayer:getLayer("MapRoleLayer")
		local maplayer = map.__MapLayer.ControllLayer:getLayer("MapLayer")

		MapRoleLayer:exitButtonFunc(false,function()
			 RichPrint("main","煮粥之时切不可分心")
		end)
		MapRoleLayer:statusButtonFunc(false,function()
			 RichPrint("main","煮粥之时切不可分心")
		end)
		map.__MapLayer:setUnmoveRoom(true,function()
			RichPrint("main","煮粥之时切不可分心")
		end)
		map:setCanLeave(false)
		map.__MapLayer:setNPCTouchEnabled(true,function()
			RichPrint("main","煮粥之时切不可分心")
		end)
		self.zaimin = 0
		self._handle = map.__MapLayer:schedule(function()
			if #text ~= 0 then
				RichPrint("main",text[1])
				table.remove(text,1)
				map.__MapLayer:setNPCTouchEnabled(false)
			else
				if self.epu ~= true then
					if 	self.count % 5 == 0 and self.epu ~= true then
						if self.zaimin < 4 then
							self:createEmeiZaiMin(map)
							self.zaimin = self.zaimin + 1
						end
					end
					if 	self.count % 10 == 0 and self.epu ~= true then
						self.epu = true
						self:createEMeiEPu(map)
					end
					self.count = self.count + 1
				end
			end
			map.__MapLayer:setNeedRefreshMap()
		end,1.0)
			

end
--峨眉 灾民
function TeacherTask:createEmeiZaiMin(map)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local MapInfo = require("app.models.map.MapInfo")
	local npc = self:getNPCBaseList(receiveTask.npcBaseId[2])
	local roleId = receiveTask.npcBaseId[2]..tostring(Helper:getOnlyId())
	local role  = {
		id= roleId,
		baseId = receiveTask.npcBaseId[2],
		sex = "男",
		type = "role",
		name = "",
		canSee = true,
		caozuo = true,
		canTalk = false,
		caozuoName = "赠粥",
		conditionAndResults =
		{
			{
				conditionRelation = "and",
				conditions =
				{
					{
						type = "玩家操作",
						arg1 = "玩家操作",
						arg2 = "操作",
					}
				},
				results =
				{
					{
						type = "赠粥",
						arg1 = "赠粥",
					},

				}
			},
		}

	}
	role = table.mergeMap(role,npc)
	role.id= roleId
	print("灾民",role.id,role.baseId)
	MapInfo:addRoleToRoomByRoomId(map,receiveTask.roomId,role)
	role = map:getRole(role.id)
	self:removeTeacherTaskNPC(map,receiveTask.roomId,role.id)
end
--峨眉 豪门恶仆
function TeacherTask:createEMeiEPu(map)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	local role = {}
	local basenpc = self:getNPCBaseList(receiveTask.npcBaseId[3])
	for k ,v in pairs(basenpc) do
		role[k] = v
	end
	role.id = receiveTask.npcBaseId[3]..tostring(Helper:getOnlyId())
	role.baseId = receiveTask.npcBaseId[3]
	role.canCompete = true
	role.canTalk = true
	role.canKill = false
	role.type = "role"
	role.words = "你是什么人，来这多管闲事、装大尾巴狼？我家主人说了，这些泥腿子再饿几天，就会卖身给我家主人，胆敢坏我家主人好事！"
	role.words = string.split(role.words,",")
	map:createRole(role)
	map:addRoomRole(receiveTask.roomId,role.id,true)
	self:removeTeacherTaskNPC(map,receiveTask.roomId,role.id)
end
--
function TeacherTask:deleteRoleByBaseId(map,roomId,baseId)
	if map == nil or type(roomId) ~= "string" and type(baseId) ~= "string" then
		return
	end
	local list = Helper:getDef(map:getRoomRoleList(roomId),{})
	for i = #list,1,-1 do 
		local role = map:getRole(list[i])
		if role.type == "role" then
			if role.baseId == baseId then
				map:removeRoomRole(roomId,role.id)
			end
		end
	end
	map.__MapLayer:setNeedRefreshMap()
end
--峨眉赠粥
function TeacherTask:dealEMeiZengZhou(map,role)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	receiveTask.isTalk = Helper:getDef(receiveTask.isTalk,0)
	if type(receiveTask) ~= "table" then
		map:removeRoomRole(receiveTask.roomId,role.id)
	end
	if self.epu == true then
		PopText("豪门恶仆正在捣乱，灾民不敢上前领取你赠送的粥")
	else
		receiveTask.isTalk = receiveTask.isTalk + 1
		RichPrint("main",role.name..":多谢菩萨一饭之恩！")
		map:removeRoomRole(receiveTask.roomId,role.id)
		self.zaimin = self.zaimin - 1
		if receiveTask.isTalk >= 4 then
			map:removeRoomRole(receiveTask.roomId,receiveTask.npcId[1])
			self:setTeacherTaskAttr("isComplete","Y")
			self:deleteRoleByBaseId(map,receiveTask.roomId,receiveTask.npcBaseId[2])
			receiveTask.roomId = {}
			RichPrint("main","今天的粥已经被灾民领光了，你只好收拾收拾回师门交接任务。")
			local MapRoleLayer = map.__MapLayer.ControllLayer:getLayer("MapRoleLayer")
			local maplayer = map.__MapLayer.ControllLayer:getLayer("MapLayer")

			MapRoleLayer:exitButtonFunc(true)
			MapRoleLayer:statusButtonFunc(true)
			map.__MapLayer:setUnmoveRoom(false)
			map:setCanLeave(true)
			map.__MapLayer:unschedule(self._handle)

		end
		self:setTeacherTaskAttr("receiveTask",receiveTask)
		map.__MapLayer:setNeedRefreshMap()
	end 
end
function TeacherTask:dealDuelEMeiConditionAndResult(maplayer,role,isWin)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if type(receiveTask) == "table" and maplayer._currRoom.id == receiveTask.roomId and TeacherTask:getTeacherTaskAttr("isComplete") == "N" and receiveTask.taskType == 4 and self.epu == true then
		if isWin == true then
			RichPrint("main","豪门恶仆连滚带爬地逃走了，边跑边回头叫嚣：“我家主人不会放过你的！”")
			self.epu = false
			maplayer._currMap:removeRoomRole(receiveTask.roomId,role.id)
			maplayer:setNeedRefreshMap()
			-- self:remoceRoleByBaseId(maplayer,receiveTask)
			maplayer:resumeSchedulerAndActions(self._handle)
		else
			RichPrint("main","豪门恶仆：就你这点微末本事，也学别人多管闲事！")
		end
	end
end
function TeacherTask:remoceRoleByBaseId(mapLayer,receiveTask)
	local list = mapLayer._currMap:getRoomRoleList(receiveTask.roomId)
	for k,v in pairs(list) do 
		local role = mapLayer._currMap:getRole(v)
		if role.type == "role" then
			if role.baseId == receiveTask.npcBaseId[2] then
				mapLayer._currMap:removeRoomRole(receiveTask.roomId,role.id)
			end
		end
	end
end
function TeacherTask:dealLuoYueXueJianConditionAndResult(map,role)
	local text = {
		[1] = "HIY萧子远当面向你演示了落月剑法的精要，这让你受益颇多。",
		[2] = "HIC你持剑演练，萧子远在一旁指点，这让你对落月山庄的剑法又多了几分感悟。",
		[3] = "RAN萧子远向你灌输着剑道的知识，许多之前困恼你的问题都迎刃而解。",
		[4] = "RAN你持剑舞练，在萧子远的指点之下，你全然忘记周遭的事物，仿佛世间唯有一人一剑。"
	}
	local ControllLayer = require("app.views.layer.ControllLayer")
	local controllLayer = ControllLayer:getInstance()
	local MapRoleLayer = controllLayer:getLayer("MapRoleLayer")
	local maplayer = controllLayer:getLayer("MapLayer")
	MapRoleLayer:statusButtonFunc(false,function()
		 RichPrint("main","你沉醉于萧子远的精妙剑法中，无法自拔。")
	end)
	MapRoleLayer:exitButtonFunc(false,function()
		 RichPrint("main","你沉醉于萧子远的精妙剑法中，无法自拔。")
	end)
	maplayer:setUnmoveRoom(true,function()
		RichPrint("main","你沉醉于萧子远的精妙剑法中，无法自拔。")
	end)
	map:setCanLeave(false)
	map.__MapLayer:setNPCTouchEnabled(true,function()
		RichPrint("main","你沉醉于萧子远的精妙剑法中，无法自拔。")
	end)
	local count = 1
	Audio:playMusic("LunJian",true)
	self._handle = map.__MapLayer:schedule(function()
		RichPrint("main",text[math.random(1,#text)])
		count = count + 1
		if count >= 30 then
			Audio:stopMusic("LunJian")
			map.__MapLayer:unschedule(self._handle)
			MapRoleLayer:exitButtonFunc(true)
			MapRoleLayer:statusButtonFunc(true)
			maplayer:setUnmoveRoom(false)
			map:setCanLeave(true)
			map.__MapLayer:setNPCTouchEnabled(false)
			local receiveTask = self:getTeacherTaskAttr("receiveTask")
			map:removeRoomRole(receiveTask.roomId,role.id)
			receiveTask.roomId = {}
			self:setTeacherTaskAttr("receiveTask",receiveTask)
			self:setTeacherTaskAttr("isComplete","Y")
			map.__MapLayer:setNeedRefreshMap()
		end
	end,1.0)
end


function TeacherTask:removeTeacherTaskNPC(map,roomId,roleId)
	local overTime = self:getTaskOverTime()
	map:InSertTaskToDelayTasks(value,overTime+GetTime(),function()
		map:removeRoomRole(roomId,roleId)--任务过期，或者指派任务，放弃任务删除生成的
	end,"师门任务",self:getTeacherTaskAttr("receiveTask").taskOId)
end

--本地计算是否可以指派
function TeacherTask:checkCanAppoint()
	local count = Helper:getDef(self:getTeacherTaskAttr("appointCount"),0)
	if count < self:getMaxAppointCount() then
		return true
	else
		return false
	end
end
--当日最大指派次数
function TeacherTask:getMaxAppointCount()
	local lv = User:getRole():getAttr("lv")
	if tonumber(lv) >= 100 and tonumber(lv) <= 200 then
		return 2
	elseif tonumber(lv) >= 201 and tonumber(lv) <= 400 then
		return 3
	elseif tonumber(lv) >= 401 and tonumber(lv) <= 600 then
		return 4
	elseif tonumber(lv) >= 601  then
		return 5
	end
end
function TeacherTask:createTeacherTaskNPCWithTypeTwo(mapLayer,mapId,roomId)
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if type(self:getTeacherTaskAttr("isAppoint")) ~= "table" then
		if type(receiveTask) == "table" then
			if receiveTask.taskType == 2 and receiveTask.hasDefeat == nil  then
				if User:getRole():getItem(receiveTask.itemId) ~= nil and mapLayer._currMap.id == receiveTask.mapId then
					if Helper:RandomByWeight({[1] = 30 , [2] = 70}) == 1 then
						local role = {}
						local basenpc = self:getNPCBaseList("husongzhongbao1")
						role = basenpc
						role.baseId = "husongzhongbao1"
						role.type = "role"
						role.id = "husongzhongbao1"..tostring(Helper:getOnlyId())
						mapLayer._currMap:createRole(role)
						mapLayer._currMap:addRoomRole(roomId,role.id,true)
						mapLayer:setNeedRefreshMap()
						role = mapLayer._currMap:getRole(role.id)--roomId,roleId)
						local currRole = role
						local role = currRole
						local currMap = mapLayer._currMap
						self.mapLayer = mapLayer
						local player = User:getRole()
						currMap:doConditionAndResult(role.conditionAndResults,
				            {
				                operation = "切磋",
				                currRole = role,
				                currRoomId = self.mapLayer._currRoom.id,
				                mapLayer = self.mapLayer
				            })

						role:initNpcAttr() -- NPC状态初始化

				        currMap:afterFightWithQieCuo(player, role, function(winTeamId)
				            -- 战斗胜利条件结果
				            if winTeamId == 1 then
				                -- PopText("你战胜了" .. role:getName())
				                currMap:doConditionAndResult(role.conditionAndResults,
				                    {
				                        conditionType = "切磋",
				                        result = "成功",
				                        currRole = role,
				                        currRoomId = self.mapLayer._currRoom.id,
				                        mapLayer = self.mapLayer
				                    })

				                self.mapLayer:delayRefreshMap()
				                -- 刷新房间条件结果
								currMap:doRoomConditionAndResult(roomId)
								RichPrint("main","经过一番苦战，你击退了出手抢夺重宝、意图不轨的神秘人。")
								receiveTask.hasDefeat = true
								self:setTeacherTaskAttr("receiveTask",receiveTask)
								currMap:removeRoomRole(roomId,role.id)
								currMap.__MapLayer:setNeedRefreshMap()
				            else
				                -- PopText("你被" .. role:getName() .. "打趴在地")
				                currMap:doConditionAndResult(role.conditionAndResults,
				                    {
				                        conditionType = "切磋",
				                        result = "失败",
				                        currRole = role,
				                        currRoomId = self.mapLayer._currRoom.id,
				                        mapLayer = self.mapLayer
				                    })
				                -- RichPrint("main","你没有战胜自己的心魔，修为难有寸进。")
				                self.mapLayer:delayRefreshMap()
				                -- 刷新房间条件结果
				                currMap:doRoomConditionAndResult(roomId)
				                RichPrint("main","经过一番苦战，你从夺宝人手下败退，好在宝物没有被抢走。")
				                currMap:removeRoomRole(roomId,role.id)
				                currMap.__MapLayer:setNeedRefreshMap()
				            end
				        end)
				       currMap.__MapLayer:setNeedRefreshMap()
					end
				end
			end
		end
	end
end

--副本中购买物品，判断是否达到收集物资类任务的要求
function TeacherTask:checkTaskTypeZeroIsConplete(items)
	if type(items) ~= "table" then
		return
	end
	local receiveTask = Helper:getDef(self:getTeacherTaskAttr("receiveTask"),{})
	if receiveTask.taskType == 0 then
		for k,v in ipairs(items) do 
			if v.itemId == receiveTask.target then
				print(v.count,receiveTask.targetNum)
				if tonumber(v.count) >= tonumber(receiveTask.targetNum) then
					TeacherTask:setTeacherTaskAttr("isComplete","Y")
				end
			end
		end
	end
end
function TeacherTask:dealPickUpTeacherTaskItem(itemId,func)
	if type(itemId) ~= "string" then
		return
	end
	local familyId = User:getRole():getFamilyId()
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if familyId == "tianshan" and itemId == "shimenwupin36" then
		if User:getRole():getItem("shimenwupin36").count >= 3 then
			self:setTeacherTaskAttr("isComplete","Y")
			for i,j in pairs(receiveTask.npcId) do
				if receiveTask.hasAsk[k] ~= 1 then
					if func then
						func(j,receiveTask.roomId[i])
					end
				end
			end
			receiveTask.roomId = {}
			User:getRole():addItemCount("shimenwupin36",0-User:getRole():getItem("shimenwupin36").count)
			self:setTeacherTaskAttr("receiveTask",receiveTask)
		end
	elseif familyId == "haijing" and itemId == "shimenwupin35" then
		if User:getRole():getItem("shimenwupin35").count >= 5 then
			self:setTeacherTaskAttr("isComplete","Y")
			User:getRole():addItemCount("shimenwupin35",0-User:getRole():getItem("shimenwupin35").count)
		end
	end
end
function TeacherTask:dealTypeZero()
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if type(receiveTask) == "table" and self:getTeacherTaskAttr("isComplete") ~= "Y" and receiveTask.taskType == 0 then
		local item = User:getRole():getItem(receiveTask.target)
		if item and item.count >= tonumber(receiveTask.targetNum) then
			if TeacherTask:getTeacherTaskAttr("isComplete") == "N" then
				TeacherTask:setTeacherTaskAttr("isComplete","Y")
				User:getRole():addItemCount(receiveTask.target,0-tonumber(receiveTask.targetNum))
			end
		end
	end
end
--任务简述
function TeacherTask:getTeacherSimpleDsc(taskId)
	if type(tonumber(taskId)) ~= "number" then
		assert(nil)
	end
	local taskList = Helper:getDef(teacherjob["Sheet1"],{})
	if taskList[tostring(taskId)] then
		return assert(taskList[tostring(taskId)].gaishu)
	else
		assert(nil)
	end
end
--获取任务可能获得额外奖励,用于任务详情描述界面
function TeacherTask:getTeacherTaskExtraReward(taskId)
	if type(tonumber(taskId)) ~= "number" then
		assert(nil)
	end
	local taskList = Helper:getDef(teacherjob["Sheet1"],{})
	if taskList[tostring(taskId)] then
		return assert(taskList[tostring(taskId)].mayget)
	else
		assert(nil)
	end
end
--任务可能获得的奖励，用于背包空间判断，并不是最终的奖励
function TeacherTask:getTeacherTaskExtraRewardByTaskId(taskId)
	if type(tonumber(taskId)) ~= "number" then
		assert(nil)
	end
	local taskList = Helper:getDef(teacherjob["Sheet1"],{})
	local extReward = {}
	if taskList[tostring(taskId)] then
		if type(taskList[tostring(taskId)].extraaward) == "string" then
			local list = string.split(taskList[tostring(taskId)].extraaward,";")
			if list[1] then
				extReward[list[1]] = 1
			end
		end
		if type(taskList[tostring(taskId)].extraaward) == "string" then
			local list = string.split(taskList[tostring(taskId)].festivaextra,";")
			if list[1] then
				extReward[list[1]] = 1
			end
		end
		return extReward
	else
		assert(nil)
	end
end
--获取任务额外随机奖励,为该任务最终获得的额外奖励(不包含节日奖励)
function TeacherTask:getExtraReward(taskId,taskQuality)
	if type(tonumber(taskId)) ~= "number" then
		assert(nil)
	end
	local taskList = Helper:getDef(teacherjob["Sheet1"],{})
	local reward = {}
	if taskList[tostring(taskId)] then
		if type(taskList[tostring(taskId)].extraaward) == "string" then
			local list = string.split(taskList[tostring(taskId)].extraaward,";")
			table.insert(reward,list[taskQuality])
		end
		Helper:print_lua_table(reward)
		return reward
	else
		assert(nil)
	end
end

function TeacherTask:getFestivaExtraReward(taskId,taskQuality)
	if type(tonumber(taskId)) ~= "number" then
		assert(nil)
	end
	local taskList = Helper:getDef(teacherjob["Sheet1"],{})
	local reward = {}
	if taskList[tostring(taskId)] then
		local fRateList
		if taskList[tostring(taskId)].festivarate then--当前任务品质的节日奖励概率
			fRateList = Helper:getDef(string.split(taskList[tostring(taskId)].festivarate,",")[taskQuality],"0;0;0;0")
		else
			return reward
		end
		local fExtrsaList
		if taskList[tostring(taskId)].festivaextra then--节日奖励
			print(taskList[tostring(taskId)].festivaextra)
			fExtrsaList = string.split(taskList[tostring(taskId)].festivaextra,";")
		else
			return reward
		end
		local festivarate = string.split(fRateList,";")

		local random = Helper:RandomByWeight(festivarate)
		table.insert(reward,fExtrsaList[random])
		return reward
	else
		assert(nil)
	end
end
return TeacherTask000000