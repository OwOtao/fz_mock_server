local task =
{
	id = "task5",

	-- 显示
	buttonA = "taskButton5a",
	buttonB = "taskButton5b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "回春堂分药", -- 任务名称

	minExp = 15000, -- 最小经验值
	maxExp = 80000, -- 最大经验值

	coolDown = 4*60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 200,
		pot = 200
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 10000,
		pot = 10000
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv)
				return 9000*((sklv-29)^2/12321+1) / 3600
			end,   -- 同上
		pot = function(sklv)
				return 9000*((sklv-29)^2/12321) / 3600
			end,    -- 同上
		maxExp = 18000 / 3600,	--最大经验值，计算值超出最大值时用最大值计算
		maxPot = 9000 / 3600,	--最大潜能值，同上
		money = 5000 / 3600	--金钱
	},

	printText = -- 输出显示的文本
	{
		startWork = -- 开始打工
		{
			"你从池子里勺起水，开始慢慢的洗盘子。"
		},
		startWorkGreaterThan = -- 开始打工, 且超出条件
		{
			"你经验太高，洗盘子对于你来说收效甚微。",
			"这点小事怎么敢劳您的大驾。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"就你这点水平干不了我这活儿，去去去，我这没功夫陪你。"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"之前不是才孝敬过您吗？怎么又来了。"
		},
		startGuaji = -- 开始挂机
		{
			"你开始洗盘子。"
		},
		guajiing = -- 挂机中
		{
			{"你从池子里勺起水，开始慢慢的洗盘子。", 2, "你洗了良久，终于将盘子全部洗好了。"},
			{"你从池子里勺起水，开始慢慢的洗盘子。", 2, "你手一滑，盘子摔了个粉碎，你赶紧收拾感觉，装作什么也没发生。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"你觉得差不多了，停止了洗盘子。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"你觉得没啥意思，停止了洗盘子。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
0000