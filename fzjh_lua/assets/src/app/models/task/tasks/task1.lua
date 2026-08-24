local task =
{
	id = "task1",
	-- 显示
	buttonA = "taskButton2a",
	buttonB = "taskButton2b",
	aaaaaaaaaaaa = "防作弊",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "树林打鸟", -- 任务名称

	minExp = 0, -- 最小经验值
	maxExp = 1000, -- 最大经验值

	coolDown = 1, -- 冷却时间

	zCount = 0,	-- 完成总次数
	dCount = 0,	-- 当天完成次数
	cCount = 1000,	-- 每日完成次数限制

	workReward = -- 打工奖励(手点)
	{
		exp = 200,
		pot = 200,
		money = 200
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 5,
		pot = 5
	},
	guajiReward = -- 挂机奖励
	{
		exp = 1,   -- 同上
		pot = 1    -- 同上
	},
	printText = -- 输出显示的文本
	{
		startWork = -- 开始打工
		{
			"你拿出弹弓，对着天空一阵乱射，打下了几片树叶。",
			"你拿出弹弓，歪头眯眼瞄准天空，一发出去，打下了几分寂寞。"
		},
		startWorkGreaterThan = -- 开始打工, 且超出条件
		{
			"你经验太高，打鸟对于你来说收效甚微。",
			"你都这么厉害了，还玩这种小孩子的玩意干嘛呢。",
			"你经验太高，打了一会发现并没有什么卵用。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"111"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"你弹射速度太快，手臂有点乏力了。"
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

-- 状态 -----------------------------------------------------------------
function task:getUIState()
	local task = self
	local roleTask = self:getRoleTask(self.id)
	local roleData = self:getRole():getData()

	if roleTask.state == TASK_STATE_IDLE then
		if roleData.exp >= task.minExp and roleData.exp < task.maxExp then
			return "可工作"
		elseif roleData.exp >= task.maxExp then
			return "可工作"
		else
			return "不可用"
		end
	elseif roleTask.state == TASK_STATE_COOLDOWN then
		return "冷却中"
	elseif roleTask.state == TASK_STATE_GUAJI then
		return "挂机中"
	elseif roleTask.state == TASK_STATE_DISPATCH then
		return "已派遣"
	elseif roleTask.state == TASK_STATE_DISABLE then
		return "不可用"
	end
	assert(false, "function Task:getRoleTask(taskId)")
end

-- 加密版本
task.isEncrypted = true
return task
000