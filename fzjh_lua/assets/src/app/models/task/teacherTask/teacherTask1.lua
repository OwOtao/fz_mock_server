local TeacherTask = {
	
}
local teacherjob = require("script.others.teacherjob")
--获取今日师门任务获得的贡献点
function TeacherTask:getContributionPoint()
	return User:getRole():getTeacherTask().ContributionPoint
end

--检测玩家的某个属性是否达到要求(等待扩展)
function TeacherTask:checkRoleByAttrNumber(attr,number)
	local result = false
	if type(attr) ~= "string" or type(tonumber(number)) ~= "number" then
		return result
	end
	local roleAttr = User:getRole():getAttr(attr)
	if tonumber(roleAttr) >= tonumber(number) then
		result = true
	end
	return result
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
--检测是否可以接取任务，未接取任务、没有达到当日可做任务上限方可接取
function TeacherTask:checkCanReceiveTask()
	local receiveTask = self:getTeacherTaskAttr("receiveTask")
	if receiveTask ~= 0 then
		return false
	end
	local count = Helper:getDef(self:getTeacherTaskAttr("dCount"),0)
	local maxCount = self:getTeacherTaskMaxNum()
	if count < maxCount then
		return true
	else
		return false
	end
	-- body
end

--随机任务并随机改任务的品质
function TeacherTask:getRandomTaskId(tab)
	if type(tab) == "table" then
		local qualityWeightList = { 55,25,15,5}
		local taskId = math.random(1,#tab)--任务id
		local taskQuality  = Helper:RandomByWeight(qualityWeightList)--任务品质
		return taskId,taskQuality
	end
end


--计算任务有效时长,已经接取的任务每天凌晨5点刷新
function TeacherTask:getTaskOverTime()
	local cuurTime = GetTime()
	local nowDate = tonumber(Helper:date("%Y%m%d", tonumber(cuurTime)))

	--获取当前日期的凌晨5点的时间戳
	local time = Helper:getTimeStampWithStringDate(tostring(nowDate),5)
	if cuurTime > time then
		local tomorrowTime = Helper:getTimeStampWithStringDate(tostring(nowDate+1), 5)
		return tomorrowTime-cuurTime
	else
		return time - cuurTime
	end
end

--
function TeacherTask:addRoleAttr(name,value)
	if name and value and type(value) == "number" then
		User:getRole():addAttr(name,value)
	end
end

--完成任务获取的贡献点
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
--[[
	taskId = 1, -- 任务Id
	taskName = "收集物资",--任务名
	taskType = 0, -- 任务类型Id 0/1/2/3/4
	canAppoint = 0, -- 是否可以指派给同门 0不可以 1 可以
	taskDsc = "收集木剑10把", -- 任务详情描述
	target = "findnpc001,10", -- 任务目标npc的baseId
	Collectjobroom = "fb02; fb02_04", -- 收集物资类型任务的目的副本Id已经房间Id
	NPCName = "元三", -- 目标NPC名称
	itemId = "jian106", --任务相关道具
	awardRate = "0; 0; 0; 0, 0; 0; 0; 0, 10; 10; 5; 0, 20; 20; 10; 2", -- 任务额外奖励概率
	award = "kongtong1; kongtong2; kongtong3; kongtong4" -- 额外奖励
]]

--从list中不放回抽取
local function getTaskFromTaskListByNumber(list,num)
	if type(list) ~= "table" then
		return
	end
	num = Helper:getDef(num , 3)
	local rlt = {}
	for i =1 , num  do 
		local random = math.random(1,#list)
		table.insert(rlt , list[random])
		table.remove(list,random)
	end
	return rlt
end
--初始化任务信息1,从师门任务表中找出所有玩家所在门派的任务 并随机获取三个，返回任务的Id和品质,任务名
function TeacherTask:initTeacherTask()
	local role = User:getRole()
	local taskTab = teacherjob["Sheet1"]
	local familyName = role:getFamilyName()
	local list = {}

	local qualityWeightList = { 55,25,15,5}
	for k,v in pairs(taskTab) do 
		if v.family == familyName then
			local tab = {
				taskId = v.id,
				taskName = v.name,
				taskQuality = Helper:RandomByWeight(qualityWeightList)
			}
			table.insert(list,#list+1,tab)
		end
	end
	local taskList = getTaskFromTaskListByNumber(list,3)
	role:setTeacherTaskTab(taskList)
	return taskList
end

--根据任务Id 从任务表中获取配置信息
function TeacherTask:getTeacherTaskFromTasksByTaskId(taskId)
	if type(taskId) ~= "number" then
		assert(nil,"任务的taskId必须是数字")
	end
	local familyName = role:getFamilyName()
	for k,v in pairs(Helper:getDef(teacherjob["Sheet1"],{})) do 
		if v.family == familyName and v.id == taskId then
			return v
		end
	end
	assert(nil,"没有查找到Id为"..taskId.."的任务信息")
end
-- 收集物资类任务 遁地符直接飞到小贩所在的房间；0
-- 门派寻访类任务 遁地符飞到目标NPC所在房间的附近2格；1
-- 护送重宝类任务 遁地符飞到目标NPC所在房间的附近3格；2
-- 门派切磋类任务 遁地符飞到目标NPC所在房间；3
-- 特殊类任务   遁地符直接飞到目标NPC所在房间。4
local function setTaskDsc(list)
	if type(list) ~= "table" then
		assert(nil,"传入的数据非法")
	end
	
end
--根据任务Id，初始化任务信息
function TeacherTask:getTeacherTaskDscById(taskId)
	if type(taskId) ~= "number" then
		assert(nil,"任务的taskId必须是数字")
	end
	return setTaskDsc(self:getTeacherTaskFromTasksByTaskId(taskId))
end


000000000000