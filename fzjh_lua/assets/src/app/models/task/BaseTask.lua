-- local User = require("app.models.user.User")

local OfflineProfit = require("app.models.OfflineProfit.OfflineProfit")
local LiLianTaskHelper = require("app.models.task.LiLianTaskHelper")

local sklv = 140
local activeConfigTaskIds = {
	task16 = true,
	task17 = true,
	task18 = true,
	task19 = true,
	task20 = true,
	task21 = true
}

local BaseTask =
{
	id = "task",
	-- 显示
	buttonA = "taskButton1a",
	buttonB = "taskButton1b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "父任务", -- 任务名称

	minExp = 0, -- 最小经验值
	maxExp = 0, -- 最大经验值
	coolDown = 1, -- 冷却时间

	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 20,
		pot = 20
	},
	-- --------------------- 主线任务属性

	-- zhuXianCondition = -- 主线任务条件
	-- {
	-- 	mapRoom =
	-- 	{
	-- 		fb01={roomId = "fb01_27",step= 3},
	-- 	},
	-- 	buttonColor = {r = 28,g = 76,b = 163},	-- 按钮颜色
	-- 	npcList = 	-- 人物列表
	-- 	{
	-- 		feizei =
	-- 		{
	-- 			count = 5,	-- 任务添加数量
	-- 			action = "kill"	-- 动作  包含 （talk present consult apprentice compete kill）
	-- 		}
	-- 	},
	--  -----------------预留位置
	-- 	cCount = 10000000, -- 当天可完成次数
	-- 	canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	-- 	time = 5,		-- 任务时间
	-- },

	-------------------------------


	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	-- 实际值
		end,
		pot = function(sklv, fy)
		end,
		money = function(sklv, fy)
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
		end,
		avgPot = function(sklv, fy)
		end,
		avgMoney = function(sklv, fy)
		end,
		maxExp = function(sklv, fy)	-- 最大值
		end,
		maxPot = function(sklv, fy)
		end,
		maxMoney = function(sklv, fy)
		end
	},
	printText = -- 输出显示的文本
	{
		startWork = -- 开始打工
		{
			-- "你拿出弹弓，对着天空一阵乱射，打下了几片树叶。",
			-- "你拿出弹弓，歪头眯眼瞄准天空，一发出去，打下了几分寂寞。"
		},
		startWorkGreaterThan = -- 开始打工, 且超出条件
		{
			-- "你经验太高，打鸟对于你来说收效甚微。",
			-- "你都这么厉害了，还玩这种小孩子的玩意干嘛呢。",
			-- "你经验大高，打了一会发现并没有什么卵用。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			-- "采石场监工说道：就你这点水平干不了我这活儿，去去去，我这没功夫陪你。"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			-- "采石场监工说道：之前不是才孝敬过您吗？怎么又来了。"
		},
		startGuaji = -- 开始挂机
		{
			-- "你开始打鸟."
		},
		guajiing = -- 挂机中
		{
			-- {"你从池子里勺起水，开始慢慢的洗盘子。", 2, "你洗了良久，终于将盘子全部洗好了。"},
			-- {"你从池子里勺起水，开始慢慢的洗盘子。", 2, "你手一滑，盘子摔了个粉碎，你赶紧收拾感觉，装作什么也没发生。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			-- "你觉得差不多了，停止了洗盘子。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			-- "你觉得没啥意思，停止了砸石头。\n采石场监工说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 快捷接口 -----------------------------------------------------------------
function BaseTask:getRole()
	return User:getRole()
end

-- 提供统一的角色等级获取方法
function BaseTask:getRoleLv()
	return self:getRole():getLv()
end

-- 获取角色传承buff
function BaseTask:getRoleInheritBuff()
	return self:getRole():getInheritBuff()
end

function BaseTask:getRoleTasks()
	local tasks = User:getRoleAttr("tasks")
	return assert(tasks, "function BaseTask:getRoleTasks()")
end

function BaseTask:getRoleTask(id)
	local tasks = self:getRoleTasks()
	return assert(tasks[id], "function BaseTask:getRoleTask(id)")
end

function BaseTask:getRoleCurrTaskId()
	local currTaskId = User:getRoleAttr("currTaskId")
	return currTaskId
end

function BaseTask:setRoleCurrTaskId(id)
	return User:setRoleAttr("currTaskId", id)
end

function BaseTask:isActiveConfigTask()
	return activeConfigTaskIds[self.id] == true
end

function BaseTask:isActiveConfigState(state)
	return state == TASK_STATE_ACCEPT or state == TASK_STATE_TO_SUBMIT or state == TASK_STATE_DISPATCH
end

function BaseTask:getActiveConfigVersion(confVer)
	if confVer ~= nil then
		return confVer
	end

	return LiLianTaskHelper:getRoleTaskConfigVersion(self:getRoleTask(self.id))
end

function BaseTask:makeActiveConfigVersionByNow()
	return LiLianTaskHelper:getConfigVersionByTime(GetTime())
end

function BaseTask:setActiveConfigVersion(confVer)
	local roleTask = self:getRoleTask(self.id)
	if confVer == nil then
		confVer = self:makeActiveConfigVersionByNow()
	end
	roleTask.aConfVer = confVer
end

--初始化用户任务数据（主线任务备用）
function BaseTask:initRoleTask(id)
	local roleTaskTemplate =
	{
		state = TASK_STATE_DISABLE,
		startTime = nil
	}
	local tasks = self:getRoleTasks()
	tasks[id] = roleTaskTemplate

	User:setRoleAttr("tasks", tasks)
	if  User:getRole():getDayFlag("isUpdateTime") == 0 then
		User:getRole():setDayFlag("isUpdateTime",false)
	end
end


-- 状态 -----------------------------------------------------------------
function BaseTask:getUIState()
	local task = self
	local roleTask = self:getRoleTask(self.id)
	local roleData = User:getRole():getData()

	if roleTask.state == TASK_STATE_IDLE then
		if roleData.exp >= task.minExp and roleData.exp < task.maxExp then
			return "可挂机"
		elseif roleData.exp >= task.maxExp then
			return "可工作"
		else
			return "不可用"
		end
	elseif roleTask.state == TASK_STATE_COOLDOWN then
		return "冷却中"
	elseif roleTask.state == TASK_STATE_GUAJI then
		return "挂机中"
	elseif roleTask.state == TASK_STATE_DISABLE then
		return "不可用"
	elseif roleTask.state == TASK_STATE_ACCEPT then
		return "已接受"
	elseif roleTask.state == TASK_STATE_TO_SUBMIT then
		return "待提交"
	elseif roleTask.state == TASK_STATE_COMPLETE then
		return "已完成"
	elseif roleTask.state == TASK_STATE_DISPATCH then
		return "已派遣"
	end
	assert(false, "function Task:getRoleTask(taskId)")
end

function BaseTask:getConditionDsc()
	return "条件不足\n经验>"..tostring(self.minExp)
end

-- 打工 -----------------------------------------------------------------
function BaseTask:getWorkReward()
	local role = self:getRole()
	local roleExp = role:getAttr("exp")
	if roleExp >= self.minExp and roleExp < self.maxExp then
		return self.workReward
	end
	return self.workRewardGreaterThan
end

function BaseTask:getWorkRewardDsc()
	local reward = self:getWorkReward()
	local dsc = "奖励"
	if reward.exp and reward.exp ~= 0 then
		dsc = dsc.."\n"..tostring(reward.exp).."经验"
	end
	if reward.pot and reward.pot ~= 0 then
		dsc = dsc.."\n"..tostring(reward.pot).."潜能"
	end
	if reward.money and reward.money ~= 0 then
		dsc = dsc.."\n"..tostring(reward.money).."碎银"
	end
	return dsc
end

function BaseTask:canWork()
	local roleTask = self:getRoleTask(self.id)
	local roleTaksState = roleTask.state
	if roleTaksState == TASK_STATE_COOLDOWN then
		return false
	elseif roleTaksState == TASK_STATE_DISPATCH then
		return false
	end
	return true
end

--处理打鸟次数
function BaseTask:CanBird()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()

	local roleTask = role:getTask(self.id)

	if roleTask.dCount == nil then
		roleTask.dCount = tonumber(role:getFlag("打鸟次数"))
	end

	local startTime = Helper:getDef(roleTask.startTime,0)
	if Helper:diffWithDate(GetTime(),startTime) >= 1 then
		roleTask.dCount = 0
	end

	local role_dayCount = Helper:getDef(roleTask.dCount,0)

	if role_dayCount >= self.cCount  then
		PopText("鸟已经被你打光了，明天再来吧！")
		return false
	end

	if PRINT_MODE == 1 then
		print("*********************************************************%d",tonumber(role:getFlag("打鸟次数")))
	end
	return true
end

--处理洗盘子次数
function  BaseTask:CanDish()
	--@RefType [app.models.role.Role#Role]
	local role=User:getRole()
	local roleTask = role:getTask(self.id)

	if roleTask.dCount == nil then
		roleTask.dCount = tonumber(role:getFlag("洗盘子次数"))
	end

	local startTime = Helper:getDef(roleTask.startTime,0)
	if Helper:diffWithDate(GetTime(),startTime) >= 1 then
		roleTask.dCount = 0
	end
	
	local role_dayCount = Helper:getDef(roleTask.dCount,0)
	if role_dayCount >= self.cCount  then
		PopText("盘子已经被你洗完了，明天再来吧！")
		return false
	end

	if PRINT_MODE == 1 then
		print("*********************************************************%d",tonumber(role:getFlag("洗盘子次数")))
	end
	return true
end


function BaseTask:work()
	if not self:canWork() then
		if PRINT_MODE == 1 then
			print("不能打工")
		end
		return false
	end

	if self.id == "task1" then
		if not self:CanBird() then
			return false
		end
	end

	if self.id == "task2" then
		if not self:CanDish() then
			return false
		end
	end


	--@RefType [app.models.role.Role#Role]
	local role=User:getRole()
	
	local roleTask = role:getTask(self.id)
	
	local role_dayCount = Helper:getDef(roleTask.dCount,0)
	
	local startTime = Helper:getDef(roleTask.startTime,0)

	if Helper:diffWithDate(GetTime(),startTime) >= 1 then
		roleTask.dCount = 0
	end

	if PRINT_MODE == 1 then
		print("开始打工: "..tostring(self.name))
	end
	-- self:setRoleCurrTaskId(self.id)
	
	-- local roleTask = self:getRoleTask(self.id)

	roleTask.dCount = role_dayCount + 1
	roleTask.zCount = Helper:getDef(roleTask.zCount,0) + 1
	roleTask.state = TASK_STATE_COOLDOWN
	roleTask.startTime = GetTime()

	local reward = self:getWorkReward()
	for k,v in pairs(reward) do
		User:addRoleAttr(k, v)
	end
	return true, reward
end

function BaseTask:getPercent()
	local roleTask = self:getRoleTask(self.id)
	local task = self
	if roleTask.state == TASK_STATE_COOLDOWN then
		local coolDown = task.coolDown
		local currTime = GetTime()
		local startTime = roleTask.startTime
		local endTime = startTime + coolDown

		-- print("coolDown = "..tostring(coolDown))
		-- print("currTime = "..tostring(currTime))
		-- print("startTime = "..tostring(startTime))
		-- print("endTime = "..tostring(endTime))
		return ((currTime - startTime) / (endTime - startTime)) * 100
	end
	return 100
end

-- 挂机解析 -----------------------------------------------------------------
-- 只能获取最大值和平均值，当前值是变动的，所以需要使用方法调用
function BaseTask:getGuajiReward()
	local reward = self.guajiReward
	local kongfu = assert(User:getRole():getKongfu())
	local luck = assert(User:getRole():getFinalAttr("luck"))

	local retTab = {}
	if reward then
		for k,v in pairs(reward) do
			local name = k
			if name == "exp" or name == "pot" or name == "money" then
			else
				local val = self.guajiReward[name]
				if type(val) == "function" then
					val = val(kongfu, luck, self:getRoleLv())
				end
				if not val then
					val = 0
				end
				retTab[name] = val
			end
		end

		-- add by XiaoZhiWei 2017/04/11 17:02:29 如果平均的经验值比最大的还大,则取值最大的经验值
		if retTab["maxExp"] ~= nil and retTab["avgExp"] ~= nil and retTab["avgExp"] > retTab["maxExp"] then
			retTab["avgExp"] = retTab["maxExp"]
		end
	end

	return retTab
end

function BaseTask:getGuajiRewardDsc()
	local dsc = "挂机中..."
	local roleTask = self:getRoleTask(self.id)
	if roleTask and roleTask.exp and roleTask.exp ~= 0 then
		if User:getRole():getBuffAttr("xingzhenGuaJiSY") == 0 then 
			dsc = dsc.."\n"..tostring(math.floor(roleTask.exp/roleTask.times*3600)).."经验/小时"
		else
			dsc = dsc.."\n"..tostring(math.floor(roleTask.exp/roleTask.times*3600) + math.floor((roleTask.exp/roleTask.times*3600)* User:getRole():getBuffAttr("xingzhenGuaJiSY"))).."经验/小时"
		end
	end
	-- if reward.pot and reward.pot ~= 0 then
	-- 	dsc = dsc.."\n"..tostring(math.floor(reward.pot*3600)).."潜能/小时"
	-- end
	-- if reward.money and reward.money ~= 0 then
	-- 	dsc = dsc.."\n"..tostring(math.floor(reward.money*3600)).."碎银/小时"
	-- end

	return dsc
end

function BaseTask:canGuaji()
	local roleTask = self:getRoleTask(self.id)
	local roleTaksState = roleTask.state

	if roleTaksState == TASK_STATE_GUAJI then
		if PRINT_MODE == 1 then
			print("正在挂机")
		end
		return false
	end
	return true
end

function BaseTask:guaji()
	if not self:canGuaji() then
		if PRINT_MODE == 1 then
			print("不能挂机")
		end
		return false
	end
	local task = self
	if PRINT_MODE == 1 then
		print("开始挂机: "..tostring(task.name))
	end

	self:setRoleCurrTaskId(self.id)

	local role = User:getRole()
	local roleTask = self:getRoleTask(self.id)



	-- 挂机时记录属性
	-- roleTask =
	-- {
	-- 	state = TASK_STATE_GUAJI,
	-- 	startTime = GetTime(),
	-- 	kongfu = assert(role:getKongfu()),
	-- 	luck = assert(role:getNumAttr("luck"))
	-- }
	roleTask.state = TASK_STATE_GUAJI
	roleTask.startTime = GetTime()
	roleTask.kongfu = assert(role:getKongfu())
	
	roleTask.luck = assert(role:getFinalAttr("luck"))

	if DEBUG_MODE == 1 then
		print("kongfu"..role:getKongfu())
	end	

	self:getRole():setRoleCurrState(ROLE_CURR_STATE_GUAJI)
	-- 设置成长速度
	self:getRole():setAttr("currTaskId", self.id)

	-- 结束其他挂机
	local tasks = self:getRoleTasks()
	for k, l_roleTask in pairs(tasks) do
		if k ~= self.id then
			if l_roleTask.state == TASK_STATE_GUAJI then
				l_roleTask.state = TASK_STATE_IDLE
			end
		end
	end

	return true
end

function BaseTask:stopGuaji()
	local roleTask = self:getRoleTask(self.id)
	if roleTask.state == TASK_STATE_GUAJI then
		roleTask =
		{
			state = TASK_STATE_IDLE
		}

		-- 设置成长速度
		self:getRole():setTask(self.id, roleTask)
		self:getRole():setAttr("currTaskId", nil)
		self:getRole():removeRoleCurrState(ROLE_CURR_STATE_GUAJI)
	else
		if PRINT_MODE == 1 then
			print("该任务没有在挂机")
		end
	end
end

-- 文本 -----------------------------------------------------------------
function BaseTask:getRandPrintText(name)
    local texts = assert(self.printText[name])
	local length = table.getn(texts)
	print("----------------",length)
    return texts[math.random(1, length)]
end

function BaseTask:getStartWorkText()
	local roleData = self:getRole():getData()
	local roleTask = self:getRoleTask(self.id)
	if PRINT_MODE == 1 then
		print("roleTask.state = "..tostring(roleTask.state))
	end
	if roleTask.state == TASK_STATE_COOLDOWN then
		return self:getRandPrintText("startWorkCoolDown")
	elseif roleTask.state == TASK_STATE_DISPATCH then
		return "该任务正在派遣中。"
	else
		if roleData.exp >= self.minExp and roleData.exp < self.maxExp then
			return self:getRandPrintText("startWork")
		elseif roleData.exp >= self.maxExp then
			return self:getRandPrintText("startWorkGreaterThan")
		elseif roleData.exp < self.minExp then
			return self:getRandPrintText("startWorkLessThen")
		end
	end
	return self:getRandPrintText("startWorkLessThen")
end

function BaseTask:getCDLeft()
	local currTime = GetTime()
	local roleTask = self:getRoleTask(self.id)
	local startTime = roleTask.startTime
	local coolDown = self.coolDown
	local leftTime = (startTime + coolDown) - currTime
	return leftTime
end

function BaseTask:getCoolDownDsc()
	local hour, min, sec = Helper:sec2timeDsc(self:getCDLeft())
	local timeDsc = ""
	if hour and hour ~= 0 then
		timeDsc = timeDsc..tostring(hour).."小时"
	end
	if min and min ~= 0 then
		timeDsc = timeDsc..tostring(min).."分"
	end
	if sec and sec ~= 0 then
		timeDsc = timeDsc..tostring(sec).."秒"
	end
	if timeDsc ~= "" then
		return "冷却中...\n剩余"..timeDsc
	end
	return "冷却中..."
end

function BaseTask:getStartGuajiText()
	return self:getRandPrintText("startGuaji")
end

function BaseTask:getMainLayerGuajiDsc()
	local roleTask = self:getRoleTask(self.id)
	local dsc = tostring(self.name).."中..."
	if roleTask and roleTask.exp and roleTask.exp ~= 0 then
		if User:getRole():getBuffAttr("xingzhenGuaJiSY") == 0 then 
		    dsc = dsc.."\n"..tostring(math.floor(roleTask.exp / roleTask.times * 3600)).."经验/小时"
		else
			dsc = dsc.."\n"..tostring(math.floor((roleTask.exp / roleTask.times * 3600) + (User:getRole():getBuffAttr("xingzhenGuaJiSY")* math.floor(roleTask.exp / roleTask.times * 3600)))).."经验/小时"
		end
	end
	-- if reward.pot and reward.pot ~= 0 then
	-- 	dsc = dsc.."\n"..tostring(math.floor(reward.pot*3600)).."潜能/小时"
	-- end
	-- if reward.money and reward.money ~= 0 then
	-- 	dsc = dsc.."\n"..tostring(math.floor(reward.money*3600)).."碎银/小时"
	-- end

	return dsc
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/23 17:15:45
-- @desc 离线收益最多72小时,从热更新当前开始生效
local function calcOfflineProfit(startTime, currTime)
	-- 如果开始时间和当前时间都为空 则事件间隔返回0 (考虑起始时间和当前时间为0的情况)
	startTime = Helper:getDef(startTime, 0)
	currTime = Helper:getDef(currTime, 0)
	-- local updateTime = os.time({year = 2016,month = 11, day = 24}) -- 2016-11-24时间戳
	local updateTime = os.time({year = 2016,month = 11, day = 24, hour = 0}) -- 2016-11-24时间戳
	-- 开始时间或者当前时间初始化后如果为0 直接返回0
	if startTime == 0 or currTime == 0 then
		return 0
	end

	-- 如果当前时间小于更新时间 按老规则计算
	if currTime < updateTime then
		return Helper:getRange(currTime - startTime, 0)
	end


	-- 如果开始时间大于热更新时间  直接使用规则计算
	if startTime > updateTime then
		return Helper:getRange(currTime - startTime, 0, 72 * 3600)
	else
		local duration = updateTime - startTime
		-- 如果开始挂机的时间,小于热更新的事件,超出的部分用新规则计算,计算完后加上更新前的离线时间
		return duration + Helper:getRange(currTime - updateTime, 0, 72 * 3600)
	end
end


-- 刷新 -----------------------------------------------------------------
function BaseTask:update(ft)
	local currTime = GetTime()
	local role = User:getRole()
	local roleTask = self:getRoleTask(self.id)
	local roleTaskState = roleTask.state
	local task = self

	-- 及时 更新任务状态 在此处更新
	if role:getInheritFlag("腊八施粥") == 2 then
		if self.id == "task18" and roleTask.state  ==  TASK_STATE_ACCEPT then
			roleTask.state = TASK_STATE_TO_SUBMIT
		end
	end
	--修复 让超时任务取消掉
	if roleTask.state  ==  TASK_STATE_TO_SUBMIT and self.id == "task18" and GetTime() >= Helper:getTimeStampWithStringDate("20180206", 0) then  --GetTime() > Helper:getTimeStampWithStringDate("20180117", 0)  and
		roleTask.state = TASK_STATE_IDLE
	end
	
	if roleTaskState == TASK_STATE_COOLDOWN then
		local startTime = roleTask.startTime
		local endTime = startTime + task.coolDown
		-- print("startTime = "..startTime)
		-- print("endTime = "..endTime)
		if currTime >= endTime then
			if PRINT_MODE == 1 then
				print("任务cd结束")
			end
			roleTask.state = TASK_STATE_IDLE
		end
	elseif roleTaskState == TASK_STATE_GUAJI then
		local startTime = roleTask.startTime
		local duration = currTime - startTime
		if not task.interval then
			task.interval = 0.5
		end
		-- self:printGuajiText()

		if role:getExp() >= self.maxExp then
			RichPrint("main", self:getRandPrintText("autoStopGuaji"))
			self:stopGuaji()
			return
		end
		--走穴十四经效果，暂停挂机
		if User:getRole():getBuffAttr("xingzhenGuaJi") >= 1 then
			PopText("受行针走穴影响，你浑身乏力，想必一段时间内无法再行动了。")
			self:stopGuaji()
			return 
		end

		OfflineProfit:setBeforeStatus("exp", role:getAttr("exp"))
		OfflineProfit:setBeforeStatus("pot", role:getAttr("pot"))
		OfflineProfit:setBeforeStatus("money", role:getAttr("money"))


		local kongfu = roleTask.kongfu
		local luck = roleTask.luck
		if duration >= task.interval and duration * task:getCurrTaskExp(roleTask) >= 1 then
			duration = calcOfflineProfit(startTime, currTime) -- 计算离线时间

			-- add by XiaoZhiWei 2017/06/02 16:20:02 由一次性计算拆分为 分次计算
			-- local totalExp = task:getCurrTaskExp(roleTask)*duration	-- 离线经验总收益
			local totalExp = 0
			local totalPot = 0
			local totalMoney = 0
			local index = 0

			-- add by XiaoZhiWei 2017/07/24 17:59:30 由于游戏效率问题,循环次数不能过多, 超过2000次则不用循环
			if duration > task.interval * 2000 then
				totalExp = totalExp + task:getCurrTaskExp(roleTask)*duration
				totalPot = totalPot + task:getCurrTaskPot(roleTask)*duration
				totalMoney = totalMoney + task:getCurrTaskMoney(roleTask)*duration
			else
				for i=1,Helper:mathFloor(duration/task.interval) do
					totalExp = totalExp + task:getCurrTaskExp(roleTask)*task.interval
					totalPot = totalPot + task:getCurrTaskPot(roleTask)*task.interval
					totalMoney = totalMoney + task:getCurrTaskMoney(roleTask)*task.interval
					index = i
				end
				duration = index * task.interval
			end

			role:setGamingTime(startTime + duration) -- 更新角色年龄

			if PRINT_MODE == 1 then
				-- print("挂机任务奖励测试结果:")
				-- print("任务开始时间戳:"..tostring(startTime))
				-- print("当前时间戳:"..tostring(currTime))
				-- print("任务开始年月日:"..tostring(Helper:date("%x %X", startTime)))
				-- print("当前年月日:"..tostring(Helper:date("%x %X", currTime)))
				-- print("时间间隔:"..tostring(duration))
				-- print("时间间隔天数:"..tostring(Helper:diffWithDate(duration, 0)))
			end

			roleTask.startTime = currTime	-- add by XiaoZhiWei 2017/10/12 17:44:01 离线收益砍平未起到实际效果,已修复

			-- 新处理流程
			local addPercent = 1		-- 记录离线能获得的收益比例


			-- 离线收益超出的情况
			if (role:getNumAttr("exp")+totalExp) >= task.maxExp then
				-- 计算公式 (收益比 = 实际得到的收入/总收入)
				addPercent = (task.maxExp-role:getExp())/totalExp
			end
			addPercent = Helper:getRange(addPercent, 0, 1)
			for k,v in pairs(task.guajiReward) do
				if k == "exp" then
					local reward = task:getGuajiReward()
					local buff = self:getRoleInheritBuff()
					local maxExp = math.floor(reward.maxExp*3600 * buff)
					v = totalExp * addPercent

				elseif k == "pot" then
					-- v = totalPot * addPercent
					--周年庆活动挂机翻倍
					local startTime = os.time({day=5, month=8, year=2016, hour=0, min=0, sec=0})
    				local endTime = os.time({day=18, month=8, year=2016, hour=23, min=59, sec=59})
    				if self:isCreateChapmanByAction(currTime, startTime, endTime) then
    				    v = totalPot * addPercent*2
    				else
    					v = totalPot * addPercent
    				end
					
				elseif k == "money" then
					v = totalMoney * addPercent
				else
					v = 0
				end
				-- 实际值如果小于0  不做加减处理
				if v > 0 then
					--print(k, v)
					role:addAttr(k, v)

					-- 记录总收益,用于显示平均收益
					if roleTask[k] ~= nil then
						roleTask[k] = roleTask[k] + v
					else
						roleTask[k] = v
					end
				end
			end
			-- 计算记录总时间
			roleTask.times = roleTask.times == nil and (duration * addPercent) or roleTask.times + (duration * addPercent)
		end

		OfflineProfit:setAfterStatus("exp", role:getAttr("exp"), "经验")
		OfflineProfit:setAfterStatus("pot", role:getAttr("pot"), "潜能")
		OfflineProfit:setAfterStatus("money", role:getAttr("money"), "碎银")
	elseif roleTaskState == TASK_STATE_IDLE then
	elseif roleTaskState == TASK_STATE_DISABLE then
	end
	-- self:updateCount()
end

--周年庆活动时间挂机增加百分之百
function BaseTask:isCreateChapmanByAction(currTime, startTime, endTime)
    if currTime >= startTime and currTime <= endTime then
        return true
    end
    return false
end

--@desc 获取任务奖励中属性的buff
function BaseTask:getBuff(confVer)
	return 1
end

function BaseTask:getTaskDailyMaxCount(confVer)
	if self.getDynamicDailyMaxCount then
		return self:getDynamicDailyMaxCount(confVer)
	end

	if self.cCount then
		return self.cCount
	end

	if self.zhuXianCondition then
		return self.zhuXianCondition.cCount
	end
end

function BaseTask:getSpecialReward(confVer)
	return 1
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/30 11:47:04
-- @desc 获取任务奖励 (子类去实现)
function BaseTask:getTaskReward()

end

-- 设置特殊任务条件(子类去实现)
function BaseTask:setSpecialTask()
	return 1
end

--额外处理
function BaseTask:extraFunc()
end
------------------------------------------主动任务
--接受任务
function BaseTask:acceptTask()
	local roleTask = self:getRoleTask(self.id)
	local oldState = roleTask.state
	local isNewActiveTask = self:isActiveConfigTask() and not self:isActiveConfigState(oldState)
	local shouldKeepActiveStartTime = self:isActiveConfigTask() and self:isActiveConfigState(oldState)
	roleTask.state = TASK_STATE_ACCEPT

	roleTask.startTime = Helper:getDef(roleTask.startTime,0)
	roleTask.endTime = Helper:getDef(roleTask.endTime,0)
	
	roleTask.roleLv = self:getRoleLv()
	
	--历练任务特殊标记
	if self.id == "task15"then
		--每次点击查看 都更新一次历练任务startTime,现做限制: 在完成历练任务时设为 nil
		if roleTask.startTime == roleTask.endTime then
			roleTask.startTime = GetTime()
		end
		-- 对上线无法更新的玩家补救,将startTime设为上周(2017.12.6)完成endTime
		if   roleTask.startTime - roleTask.endTime < 3600*24*7  then
			roleTask.startTime = roleTask.endTime
		end
		User:getRole():setFlag("currLiLianTaskId",1)
		-- 限时任务修改 在点击接受时给予标记
	elseif  self.id == "task18" then
		User:getRole():setInheritFlag("腊八施粥",1)
		RichPrint("main" ,"施粥长老正在浮云寺寺门处等着少侠，快快前去吧。")
		if (self:getRoleCurrTaskId() ~= self.id and shouldKeepActiveStartTime == false) or isNewActiveTask then
			roleTask.startTime = GetTime()
		end
		if isNewActiveTask then
			self:setActiveConfigVersion()
		end
		self:getRole():setRoleCurrState(ROLE_CURR_STATE_ZHUDONG)
		self:setRoleCurrTaskId(self.id)

	else
		if (self:getRoleCurrTaskId() ~= self.id and shouldKeepActiveStartTime == false) or isNewActiveTask then
			roleTask.startTime = GetTime()
		end
		if isNewActiveTask then
			self:setActiveConfigVersion()
		end
		self:getRole():setRoleCurrState(ROLE_CURR_STATE_ZHUDONG)
		self:setRoleCurrTaskId(self.id)
	end


	--设置任务标记
	if self.flag then
		User:getRole():setFlag(self.flag,1)
	end
	-- Helper:tableCover(roleTask, self)
	-- self:setSpecialTask()
	self:updateCount()
end

--查看历练任务
function BaseTask:checkTask()
	local roleTask = self:getRoleTask(self.id)
	roleTask.state = TASK_STATE_ACCEPT
	if roleTask.startTime == nil then
		roleTask.startTime = GetTime()
	end
	self:updateCount()
end

--提交任务
function BaseTask:submitTask()
	local role = User:getRole()
	local roleTask = self:getRoleTask(self.id)
	local configVersion = self:getActiveConfigVersion()
	local taskCCount = self:getTaskDailyMaxCount(configVersion)
	local exp = role:getAttr("exp")
	local fy = role:getFinalAttr("luck")
	local sklv = role:getKongfu()
	local Lv = self:getRoleLv()

	-- 检查默认值
	roleTask.dCount = Helper:getDef(roleTask.dCount, 0)
	roleTask.zCount = Helper:getDef(roleTask.zCount, 0)
	roleTask.cCount = Helper:getDef(roleTask.cCount, taskCCount)
	if roleTask.cCount < taskCCount then
		roleTask.cCount = taskCCount
	end

	-- 任务的特殊处理
	local rewardBuff = self:getBuff(configVersion)

	-- 奖励无法领取的情况为nil
	if rewardBuff == nil then
		return false, configVersion
	end

	-- 传承加成
	rewardBuff = rewardBuff * self:getRoleInheritBuff()

	-- add by XiaoZhiWei 2017/12/02 11:14:02 经脉印记加成
	do
		local Meridian = require("app.models.Meridian.Meridian")
		if self.id == "task17" then
			if role:isHaveImprintingId("jieshayin") then
				print("完成南阳匪乱任务能获得更多收益，如果是男性，额外获得更多")
				local meridianBuffValue = Meridian:getMeridianBuffValue("jieshayin")
				meridianBuffValue = string.split(meridianBuffValue,";")
				local otherValue = tonumber(meridianBuffValue[1])
				local nanValue = tonumber(meridianBuffValue[2])
				if role:getAttr("sex") == "男" then
					rewardBuff = rewardBuff + nanValue
				else
					rewardBuff = rewardBuff + otherValue
				end
			end

			if role:isHaveImprintingId("jiemieyin") then
				print("完成南阳匪乱任务能获得更多收益，如果是女性，额外获得更多")
				local meridianBuffValue = Meridian:getMeridianBuffValue("jiemieyin")
				meridianBuffValue = string.split(meridianBuffValue,";")
				local otherValue = tonumber(meridianBuffValue[1])
				local nvValue = tonumber(meridianBuffValue[2])
				if role:getAttr("sex") == "女" then
					rewardBuff = rewardBuff + nvValue
				else
					rewardBuff = rewardBuff + otherValue
				end
			end
		end

		if self.id == "task16" then
			if role:isHaveImprintingId("jiedaoyin") then
				print("完成飞贼任务能获得更多收益，如果是男性，额外获得更多")
				local meridianBuffValue = Meridian:getMeridianBuffValue("jiedaoyin")
				meridianBuffValue = string.split(meridianBuffValue,";")
				local otherValue = tonumber(meridianBuffValue[1])
				local nanValue = tonumber(meridianBuffValue[2])
				if role:getAttr("sex") == "男" then
					rewardBuff = rewardBuff + nanValue
				else
					rewardBuff = rewardBuff + otherValue
				end
			end
			if role:isHaveImprintingId("jiekongyin") then
				print("完成飞贼任务能获得更多收益，如果是女性，额外获得更多")
				local meridianBuffValue = Meridian:getMeridianBuffValue("jiekongyin")
				meridianBuffValue = string.split(meridianBuffValue,";")
				local otherValue = tonumber(meridianBuffValue[1])
				local nvValue = tonumber(meridianBuffValue[2])
				if role:getAttr("sex") == "女" then
					rewardBuff = rewardBuff + nvValue
				else
					rewardBuff = rewardBuff + otherValue
				end
			end
		end
	end

	-- 每天记录更新
	if roleTask.endTime and Helper:diffWithDate(GetTime(), roleTask.endTime) >= 1 then
		--历练每天不更新，只会在周末更新
		if self.id == "task15" then
		else
			if self.id == "task16" and User:getRole():getDayFlag("isUpdateTime") == 0 then	
				User:getRole():setDayFlag("isUpdateTime",true)
				role:setDayFlag("飞贼人数",4) 
			end
			roleTask.dCount = 0
			roleTask.cCount = self:getTaskDailyMaxCount(configVersion)
		end
		
		local items  = User:getRole():getItemsWithItemId(User:getRole():getFlag("主动任务物品"))
		if MapIsEmpty(items) == true then
		else
			User:getRole():addItemCount(User:getRole():getFlag("主动任务物品"), -1)
			User:getRole():setFlag("主动任务物品","nil")
		end
	end
	if roleTask.startTime and Helper:diffWithDate(GetTime(), roleTask.startTime) >= 1 then
		if self.id == "task15" then
			local time  = GetTime()
			if DEBUG_MODE ==1 then
				 time = os.time({day=11, month=12, year=2017, hour=0, minute=0, second=0})
			end
			local currtime  = GetTime()
			local startTime  = roleTask.startTime
			local  currWeekdy = tonumber(Helper:date("%w",currtime))
			local startWeekdy = tonumber(Helper:date("%w",startTime))
			--间隔大于7天
			-- if currtime - startTime >= 3600*24*7 then
			if Helper:diffWithDate(currtime, startTime) >= 7 then
				roleTask.dCount = 0
				roleTask.cCount = self:getTaskDailyMaxCount(configVersion)
				if roleTask.state == TASK_STATE_COMPLETE then
					roleTask.state = TASK_STATE_IDLE
				end
			--间隔小于7天，并且startWeekdy不为周末
			elseif currWeekdy ~= 0 and startWeekdy > currWeekdy then
				roleTask.dCount = 0
				roleTask.cCount = self:getTaskDailyMaxCount(configVersion)
				if roleTask.state == TASK_STATE_COMPLETE then
					roleTask.state = TASK_STATE_IDLE
				end
			elseif startWeekdy == 0 and currWeekdy > 0 then
				roleTask.dCount = 0
				roleTask.cCount = self:getTaskDailyMaxCount(configVersion)
				if roleTask.state == TASK_STATE_COMPLETE then
					roleTask.state = TASK_STATE_IDLE
				end
			end
		end
	end

	-- 有物品奖励时，检测背包是否有剩余空间获取奖励物品
	local rewardItemCount = 0
	local rewards = self:getRewardsList(configVersion)
	for k, v in pairs(rewards) do
		if v.type == "物品" then
			rewardItemCount = rewardItemCount + 1
		end
	end

	local items = User:getRoleAttr("items")
	if User:getRoleAttr("weight") - #items < rewardItemCount then
		PopText("背包剩余容量不足" .. rewardItemCount .. "，无法获取奖励")
		return false, configVersion
	end


    -- 判断当前提交任务是否为 历练随机任务 ，如果是 增加次数
	if  User:getRole():getFlag("历练") == self.id then
		print("完成一次历练随机任务:"..self.id)
		User:getRole():setFlag("历练随机任务已完成次数",User:getRole():getFlag("历练随机任务已完成次数") + 1)
	end
	
	-- 提交或取消后都进入冷却时间
	roleTask.state = TASK_STATE_COOLDOWN
	roleTask.zCount = roleTask.zCount + 1
	roleTask.dCount = roleTask.dCount + 1
	-- roleTask.cCount = roleTask.cCount - 1
	if self.id ~= "task15" then -- 领取历练奖励不改变状态 add by Gao Hanzheng
		role:setRoleCurrState(ROLE_CURR_STATE_IDLE)
	end

	if self.id == "task15" then
		if roleTask.dCount >5 then
			roleTask.dCount = 5
		end
		
        for k, v in pairs(self.zhuXianReward) do
			if v.type == "物品" then
				v.name = "lilianbaoxiang"..roleTask.dCount
			end
		end
	end
	
	-- 计算并获取主线任务奖励
	for k, v in pairs(rewards) do
		if v.type == "属性" then
			local value = 0
			if type(v.value) == "number" then
				value = v.value
			elseif type(v.value) == "function" then
				local lv = Helper:getDef(roleTask.roleLv,Lv)
				value = v.value(lv, exp, fy, sklv, configVersion)
			end
			if v.name =="yueli"then
				role:addAttr(v.name, value)
				RichPrint("main" ,"获得奖励 :".. tostring(role:getCHAttrName(v.name)).." + "..tostring(math.floor(value)))
			elseif v.name =="exp" then
				local finalBuff = rewardBuff
				local buffName = self.addExpBuffName
				if buffName then
					finalBuff = finalBuff + role:getBuffAttr(buffName)
				end
				print("role:getBuffAttr(buffName) = ",role:getBuffAttr(buffName))
				print("buffName = ",buffName,"rewardBuff = ",rewardBuff,"finalBuff = ",finalBuff)
				role:addAttr(v.name, value * finalBuff)
				RichPrint("main" ,"获得奖励 :".. tostring(role:getCHAttrName(v.name)).." + "..tostring(math.floor(value * finalBuff)))
			else
				role:addAttr(v.name, value * rewardBuff)
				RichPrint("main" ,"获得奖励 :".. tostring(role:getCHAttrName(v.name)).." + "..tostring(math.floor(value * rewardBuff)))
			end
			
		elseif v.type == "物品" then
			role:addItemCount(v.name, v.value)

			local Item = require("app.models.item.Item")

			PopText("获得".. Item:getOneItemByKey(v.name).name .."X " .. v.value)

			-- RichPrint("main" ,"获得奖励 :".. Item:getOneItemByKey(v.name).name .." + "..tostring(math.floor(v.value)))

			if v.flagName ~= nil then
				role:setDayFlag(v.flagName,role:getDayFlag(v.flagName) + v.flagValue)
			end

			if v.dayFlagName ~= nil then
				role:setDayFlag(v.dayFlagName,role:getDayFlag(v.dayFlagName) + v.dayFlagValue)
			end

			if v.inheritFlag ~= nil then
				role:setInheritFlag(v.inheritFlag,role:getInheritFlag(v.inheritFlag) + v.inheritFlagValue)
			end
		end
	end

	self:isDoLiLian()

	--删除任务道具物品
	if self.id == "task19" or  self.id == "task20" then
		User:getRole():addItemCount(User:getRole():getFlag("主动任务物品"), -1)
		User:getRole():setFlag("主动任务物品","nil")
	end

	--清除任务标记
	if self.flag then
		User:getRole():setFlag(self.flag,0)
	end

	--清除当前任务ID
	if self.id ~= "task15" then--历练不是任务，不可删除任务Id
		self:setRoleCurrTaskId(nil)
	end

	--  清除多余的记录
	roleTask =
	{
		state = roleTask.state,
		dCount = roleTask.dCount,
		cCount = roleTask.cCount,
		zCount = roleTask.zCount,
		endTime = GetTime(),
		startTime = GetTime()
	}
	role:setTask(self.id, roleTask)
	-- self.isInit = false
	self.mapId = nil

	self:updateCount()

	return true, configVersion
end

function BaseTask:recordActiveCount()
	do
		-- 统计每日完成历练等任务人数
			local taskname
			local inherit
			if User:getRoleAttr("inheritCount") > 0 then
				inherit = "inherit"
			else
				inherit = "unInherit"
			end
			if self.id =="task15" then
				taskname ="lilian"
			elseif self.id =="task16" then
				taskname ="feizei"
			elseif self.id =="task17" then
				taskname ="nanyang"
			elseif self.id =="task18" then
				taskname ="xianshi"
			elseif self.id =="task19" then
				taskname ="songxin"
			elseif self.id =="task20" then
				taskname ="jina"
			elseif self.id =="task21" then
				taskname ="gusi"
			end
			local role_lv = taskname.."_"..User:getRole():getLv().."_"..inherit
			HttpManagerEx:resetActiveTask(role_lv, function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0 then
						if DEBUG_MODE == 1 then
						print("每日"..taskname.."玩家等级传承信息上传服务器成功！")
						end
					else
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)	
		end
end

--提交任务时判断是否完成完成历练
function BaseTask:isDoLiLian()
	local task = User:getRoleAttr("tasks")
	local task15 = task["task15"]
	local randTask = task[User:getRole():getFlag("历练")]
	if MapIsEmpty(randTask) == true then
	else
		local needtime = User:getRole():getFlag( User:getRole():getFlag("历练") )
		local dCount = Helper:getDef( randTask.dCount,0)
		if  User:getRole():getFlag("历练随机任务已完成次数")  >=  tonumber(needtime) then
			task15.state = TASK_STATE_TO_SUBMIT
			User:getRole():setFlag("历练","nil")
			User:getRole():setFlag("历练随机任务名","")
			User:getRole():setFlag("历练随机任务已完成次数",0)
			User:getRole():setFlag( User:getRole():getFlag("历练"),0)
		end	
	end
	
end
function BaseTask:changeTaskNPC()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	local roleTask
	-- role:setRoleCurrState(ROLE_CURR_STATE_IDLE)
	role:setFlag("更换人物刷新CD"..self.id,GetTime())
	roleTask = self:getRoleTask(self.id)
	-- end
	
	--删除任务道具物品
	if self.id == "task19" or self.id == "task20" then
		User:getRole():addItemCount(User:getRole():getFlag("主动任务物品"), -1)
		User:getRole():setFlag("主动任务物品","nil")
	end
	roleTask =
	{
		state = TASK_STATE_ACCEPT,
		dCount = roleTask.dCount,
		cCount = roleTask.cCount,
		zCount = roleTask.zCount,
		endTime = GetTime(),
		startTime = GetTime(),--roleTask.startTime
		aConfVer = self:isActiveConfigTask() and self:makeActiveConfigVersionByNow() or nil
	}
	role:setTask(self.id, roleTask)

	self:updateCount()
	self:setSpecialTask()

end

-- 取消任务
function BaseTask:cancelTask()
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()
	local roleTask
	-- role:setRoleCurrState(ROLE_CURR_STATE_IDLE)
	if self.id =="task15"then
		role:setFlag("历练更换刷新CD",GetTime())
		role:setFlag("currLiLianTaskId",0)
		roleTask = self:getRoleTask("task15")
		User:getRole():setFlag("历练","nil")
		User:getRole():setFlag("历练随机任务名","")
		User:getRole():setFlag("历练随机任务已完成次数",0)
		User:getRole():setFlag( User:getRole():getFlag("历练"),0)
		return true
	else
		roleTask = self:getRoleTask(self.id)
	end
	
	local role_money = role:getAttr("money")
	if role_money < 100 then
		PopText("您的碎银不足，无法取消任务")
		return
	end

	-- end
	--删除任务标记
	if self.id == "task18" then 
		User:getRole():setInheritFlag("腊八施粥",0)
	end
	--删除任务道具物品
	if self.id == "task19" or self.id == "task20" then
		User:getRole():addItemCount(User:getRole():getFlag("主动任务物品"), -1)
		User:getRole():setFlag("主动任务物品","nil")
	end

	role:removeRoleCurrState(ROLE_CURR_STATE_ZHUDONG)
	--  清除多余的记录
	roleTask =
	{
		state = TASK_STATE_COOLDOWN,
		dCount = roleTask.dCount,
		cCount = roleTask.cCount,
		zCount = roleTask.zCount,
		endTime = GetTime(),
		startTime = GetTime()--roleTask.startTime
	}
	role:setTask(self.id, roleTask)
	-- self.isInit = false
	self.mapId = nil

	--清除任务标记
	if self.flag then
		User:getRole():setFlag(self.flag,0)
	end
	
	role:setAttr("money",role_money - 100)
	PopText("扣除100碎银" )

	--清除当前任务ID
	self:setRoleCurrTaskId(nil)

	self:updateCount()

	return true
end

-- 更新主动任务次数 检测是否完成当日可完成上限次数
function BaseTask:updateCount(flag)
	local role = User:getRole()
	local roleTask = self:getRoleTask(self.id)
	local taskCCount = self:getTaskDailyMaxCount(self:getActiveConfigVersion())
	if roleTask.dCount == nil then
		roleTask.dCount = 0
	end

	print("baseTask updateCount",self.id,self.cCount,taskCCount,roleTask.cCount)

	if taskCCount and roleTask.cCount ~= taskCCount then
		roleTask.cCount = taskCCount
	end

	if not roleTask.state then
		roleTask.state = TASK_STATE_COMPLETE
	end

	-- 及时 更新任务状态 在此处更新
	if role:getInheritFlag("腊八施粥") == 2 then
               
		if roleTask.id == "task18" then
			roleTask.state = TASK_STATE_TO_SUBMIT
		end
	end
	--修复 让超时任务取消掉
	if roleTask.state  ==  TASK_STATE_TO_SUBMIT and self.id == "task18" and GetTime() >= Helper:getTimeStampWithStringDate("20180206", 0)  then  --GetTime() > Helper:getTimeStampWithStringDate("20180117", 0)  and
		roleTask.state = TASK_STATE_IDLE
	end

	-- 每天记录
	if roleTask.endTime and Helper:diffWithDate(GetTime(), roleTask.endTime) >= 1 then
		--历练每天不更新，只会在周末更新
		if self.id == "task15" then	
		else
			if self.id == "task16" and User:getRole():getDayFlag("isUpdateTime") == 0 then	
				User:getRole():setDayFlag("isUpdateTime",true)
				role:setDayFlag("飞贼人数",3) 
			end
			roleTask.dCount = 0
			-- roleTask.cCount = self.zhuXianCondition.cCount
			if roleTask.state == TASK_STATE_COMPLETE then
				roleTask.state = TASK_STATE_IDLE
			end
		end
		
	end
	--历练每天不更新，只会在周末更新
	
	if roleTask.startTime and Helper:diffWithDate(GetTime(), roleTask.startTime) >= 1 then
		if self.id == "task15" then	
				-- local time  = GetTime()
			if DEBUG_MODE ==1 then
					--  time = os.time({day=11, month=12, year=2017, hour=0, minute=0, second=0})
					
			end
			local currtime  = GetTime()
			local startTime  = roleTask.startTime
			local  currWeekdy = tonumber(Helper:date("%w",currtime))
			local startWeekdy = tonumber(Helper:date("%w",startTime))
			--间隔大于7天
			-- if currtime - startTime >= 3600*24*7 then -- add by XiaoZhiWei 2017/12/11 18:17:04 存在bug, 如果是周一23点开始的,那么,到了下周一23点之前,都不会刷新
			if Helper:diffWithDate(currtime, startTime) >= 7 then
				roleTask.dCount = 0
				-- roleTask.cCount = self.zhuXianCondition.cCount
				if roleTask.state == TASK_STATE_COMPLETE then
					roleTask.state = TASK_STATE_IDLE
				end
			--间隔小于7天，并且startWeekdy不为周末
			elseif currWeekdy ~= 0 and startWeekdy > currWeekdy then
				roleTask.dCount = 0
				-- roleTask.cCount = self.zhuXianCondition.cCount
				if roleTask.state == TASK_STATE_COMPLETE then
					roleTask.state = TASK_STATE_IDLE
				end
			elseif startWeekdy == 0 and currWeekdy > 0 then
				roleTask.dCount = 0
				-- roleTask.cCount = self.zhuXianCondition.cCount
				if roleTask.state == TASK_STATE_COMPLETE then
					roleTask.state = TASK_STATE_IDLE
				end
			end
		end
	end

	-- 今日完成次数达上限
	if self.zhuXianCondition ~= nil and taskCCount and roleTask.dCount >= taskCCount and roleTask.state ~= TASK_STATE_DISPATCH then
		roleTask.state = TASK_STATE_COMPLETE
	end
end
---------------------------------------------------------------------------
-- 获取当前任务的收益  收益项 功夫值 福缘
function BaseTask:getCurrTaskReward(rewardName, kongfu, luck)
	if rewardName == nil or kongfu == nil or luck == nil then
		return 0
	end
	-- 获取公式或者具体的值
	local value = self.guajiReward[rewardName]
	if type(value) == "function" then
		value = value(kongfu, luck)
	end

	-- 如果结果是非数字或者是空直接返回0
	if value == nil or type(value) ~= "number" then
		return 0
	end

	-- 字符串首首字母转大写
	local upperName = string.upper(string.sub(rewardName, 1, 1))..tostring(string.sub(rewardName, 2))
	local maxValue = self.guajiReward["max"..tostring(upperName)]
	if type(maxValue) == "function" then
		maxValue = maxValue(kongfu, luck)
	end

	-- maxValue 必须是非空,数字,且小于计算出来的实际值
	if maxValue ~= nil and type(maxValue) == "number" and value > maxValue then
		value = maxValue
	end
	return value
end


--获取当前任务挂机经验值
function BaseTask:getCurrTaskExp(roleTask)
	if not roleTask then
		assert(roleTask, "BaseTask:getCurrTaskExp(roleTask) -> 数据异常，roleTask不存在")
	end
	local role = User:getRole()
	local kongfu = assert(roleTask.kongfu)
	local luck = assert(roleTask.luck)
	local Lv = self:getRoleLv()
	-- NEEDTODO


	local exp = self.guajiReward.exp
	if type(exp) == "function" then
		exp = exp(kongfu, luck, Lv)
	end
	if not exp then
		exp = 0
	end

	local maxExp = self.guajiReward.maxExp
	if type(maxExp) == "function" then
		maxExp = maxExp(kongfu, luck, self:getRoleLv())
	end
	if maxExp and exp > maxExp then
		exp = maxExp
	end
	if User:getRole():getBuffAttr("xingzhenGuaJiSY") ~= 0 then
		exp = exp + exp * User:getRole():getBuffAttr("xingzhenGuaJiSY")
	end
	-- 传承次数加成

	local buff = self:getRoleInheritBuff()

	-- 春节活动 20%加成
	local SpringFestival = require("app.models.SpringFestival.SpringFestival")
	if SpringFestival:getProfitActivityState() == 1 then
		buff = buff + 0.20
	end

	--七夕活动+20% (2019.08.05-2019.08.18)
	local currTime=GetTime()
	local startTime = os.time({day=1, month=8, year=2019, hour=0, min=0, sec=0})
	local endTime = os.time({day=14, month=8, year=2019, hour=23, min=59, sec=59})
	if self:isCreateChapmanByAction(currTime, startTime, endTime) then
		buff = buff + 0.2
	end

	return exp * buff
end

--获取当前任务挂机潜能值
function BaseTask:getCurrTaskPot(roleTask)
	if not roleTask then
		assert(roleTask, "BaseTask:getCurrTaskPot(roleTask) -> 数据异常，roleTask不存在")
	end
	local kongfu = assert(roleTask.kongfu)
	local luck = assert(roleTask.luck)
	local pot = self.guajiReward.pot
	if type(pot) == "function" then
		pot = pot(kongfu, luck)
	end
	if not pot then
		pot = 0
	end

	local maxPot = self.guajiReward.maxPot
	if type(maxPot) == "function" then
		maxPot = maxPot(kongfu, luck)
	end
	if maxPot and pot > maxPot then
		pot = maxPot
	end

	-- 传承次数加成
	local role = User:getRole()
	local buff = self:getRoleInheritBuff()

	-- 春节活动 20%加成
	local SpringFestival = require("app.models.SpringFestival.SpringFestival")
	if SpringFestival:getProfitActivityState() == 1 then
		buff = buff + 0.20
	end

	--2018狗年春节活动加成
	local DogYearSpringFestival = require("app.models.SpringFestival.DogYearSpringFestival")
	buff = buff + DogYearSpringFestival:getDogYearSpringFestivalBuff()
	-- 周年庆加成
	local Anniversary = require("app.models.Anniversary.Anniversary")
	if Anniversary:checkIsProfitBuff() == true then
		buff = buff + 0.5
	end

	--七夕活动+20% (2019.08.05-2019.08.18)
	local currTime=GetTime()
	local startTime = os.time({day=1, month=8, year=2019, hour=0, min=0, sec=0})
	local endTime = os.time({day=14, month=8, year=2019, hour=23, min=59, sec=59})
	if self:isCreateChapmanByAction(currTime, startTime, endTime) then
		buff = buff + 0.2
	end

	return pot * buff
end

-- 获取当前任务挂机时机金钱值
function BaseTask:getCurrTaskMoney(roleTask)
	if not roleTask then
		assert(roleTask, "BaseTask:getCurrTaskMoney(roleTask) -> 数据异常，roleTask不存在")
	end
	local kongfu = assert(roleTask.kongfu)
	local luck = assert(roleTask.luck)
	local money = self.guajiReward.money
	if type(money) == "function" then
		money = money(kongfu, luck)
	end
	if not money then
		money = 0
	end

	local maxMoney = self.guajiReward.maxMoney
	if type(maxMoney) == "function" then
		maxMoney = maxMoney(kongfu, luck)
	end
	if maxMoney and money > maxMoney then
		money = maxMoney
	end

	local buff = 1

	-- 周年庆加成
	local Anniversary = require("app.models.Anniversary.Anniversary")
	if Anniversary:checkIsProfitBuff() == true then
		buff = buff + 0.5
	end

	--七夕活动+20% (2019.08.05-2019.08.18)
	local currTime=GetTime()
	local startTime = os.time({day=1, month=8, year=2019, hour=0, min=0, sec=0})
	local endTime = os.time({day=14, month=8, year=2019, hour=23, min=59, sec=59})
	if self:isCreateChapmanByAction(currTime, startTime, endTime) then
		buff = buff + 0.2
	end

	return money * buff
end


function BaseTask:getDayReward(confVer)
	if MapIsEmpty(self.dayReward) then
		return
	end

	for i,day_reward in ipairs(self.dayReward) do
		if day_reward.condi() then
			switch(day_reward._type,{
				["yinpiao"] = function ()
					local role = User:getRole()

					local bool = true
					local today_count = role:getDayFlag(day_reward._flag)
					if day_reward._flag ~= nil then
						if today_count >= day_reward._count then
							bool = false
						end
					end

					if bool then
						local value = 0
						if type(day_reward.value) == "function" then
							value = day_reward:value(today_count, nil, confVer)
						elseif type(day_reward.value) == "number" then
							value = day_reward.value
						else
							assert(false,"每日奖励银票数值配置出错："..self.id)
						end
						HttpManagerEx:updateCurrencyByType("add","yinpiao",value,self.id, function(status, errcode, errmsg, data)
							if status == 200 then
								if errcode == 0 then
									if day_reward._flag ~= nil then
										role:setDayFlag(day_reward._flag,role:getDayFlag(day_reward._flag) + 1)
									end

									RichPrint("main","获得奖励 :银票".."+"..tostring(value))
								else
									print(errcode,errmsg)
								end
							end
						end, IS_SHOW_WAITING)
					end
				end,
				["pijuan"] = function()
					local role = User:getRole()

					local bool = true
					local today_count = role:getDayFlag(day_reward._flag)
					if day_reward._flag ~= nil then
						if today_count >= day_reward._count then
							bool = false
						end
					end

					if bool then
						local value = 0
						if type(day_reward.value) == "function" then
							value = day_reward:value(today_count, nil, confVer)
						elseif type(day_reward.value) == "number" then
							value = day_reward.value
						else
							assert(false,"每日疲倦数值配置出错："..self.id)
						end
						if day_reward._flag ~= nil then
							role:setDayFlag(day_reward._flag,role:getDayFlag(day_reward._flag) + 1)
						end
						role:addAttr("pijuan",value)
					end
				end,
			})
		end
	end
end

--@desc: 获取主动任务奖励，增加活动类本地奖励配置。
--@author:Liang SongQiang
--@time:2019-01-17 10:57:30
function BaseTask:getRewardsList(confVer)
	local rewards = {}
	
	local tasks = User:getRoleAttr("tasks")
	local roleTask = tasks[self.id]

    if MapIsEmpty(self.zhuXianReward) == false then
        for _, reward in ipairs(self.zhuXianReward) do
            table.insert(rewards, reward)
        end
    end

    local lilian_rewards = self:getSpecialReward(confVer)

    if MapIsEmpty(lilian_rewards) == false then
        for _, reward in ipairs(lilian_rewards) do
            table.insert(rewards, reward)
        end
    end

    --@desc 活动配置奖励
    local ActivityTaskRewardConf = require("app.models.task.ActivityTaskRewardConf")
    local activity_rewards = ActivityTaskRewardConf:getTaskLocalReward(self.id,{dCount = roleTask.dCount})
    if MapIsEmpty(activity_rewards) == false then
        for _, reward in ipairs(activity_rewards) do
            table.insert(rewards, reward)
        end
    end

    print("--------------------------------------------------------------")
    Helper:print_lua_table(rewards)

    return rewards
end



-- 挂机任务文本输出
-- function BaseTask:printGuajiText()
-- 	--NEEDTODO
-- 	local GUAJI_TEXT_PRINT_STATE_START = 1
-- 	local GUAJI_TEXT_PRINT_STATE_WAIT = 2
-- 	local GUAJI_TEXT_PRINT_STATE_END = 3
-- 	if not self._printTextTb then
-- 		self._printTextTb =
-- 		{
-- 			taskId = "",
-- 			state = GUAJI_TEXT_PRINT_STATE_START,
-- 			startTime = 0
-- 		}
-- 	end
-- 	if self._printTextTb.taskId == self.id then
-- 		-- 正在挂机
-- 		print("self._printTextTb.state = "..self._printTextTb.state)
-- 		if self._printTextTb.state == GUAJI_TEXT_PRINT_STATE_START then
-- 			self._printTextTb.texts = self:getRandPrintText("guajiing")
-- 			self._printTextTb.currTextId = 1
-- 			self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_WAIT
-- 			-- self:print(self._printTextTb.text[self._printTextTb.currTextId])
-- 		elseif self._printTextTb.state == GUAJI_TEXT_PRINT_STATE_WAIT then
-- 			local text = self._printTextTb.texts[self._printTextTb.currTextId]
-- 			local textType = type(text)
-- 			if textType == "string" then
-- 				if self._printTextTb.currTextId == 1 then
-- 					self:print(text, cc.c3b(208, 208, 208))
-- 				elseif self._printTextTb.currTextId == 3 then
-- 					self:print(text, cc.c3b(102, 153, 153))
-- 				else
-- 					if math.random(0, 1) == 0 then
-- 						self:print(text, cc.c3b(102, 153, 153))
-- 					else
-- 						self:print(text, cc.c3b(208, 208, 208))
-- 					end
-- 				end
-- 				self._printTextTb.currTextId = self._printTextTb.currTextId + 1
-- 				self._printTextTb.startTime = GetTime()
-- 			elseif textType == "number" then
-- 				local currTime = GetTime()
-- 				local endTime = self._printTextTb.startTime + text
-- 				if currTime >= endTime then
-- 					self._printTextTb.currTextId = self._printTextTb.currTextId + 1
-- 				end
-- 			elseif textType == "nil" then
-- 				self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_END
-- 			end
-- 		elseif self._printTextTb.state == GUAJI_TEXT_PRINT_STATE_END then
-- 			self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_START
-- 		end
-- 	else
-- 		-- 启动挂机
-- 		self._printTextTb.taskId = self.id
-- 		self._printTextTb.state = GUAJI_TEXT_PRINT_STATE_START
-- 	end
-- end

--

-- 加密版本
BaseTask.isEncrypted = true
return BaseTask
000000000