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

	interval = 3,
	coolDown = 4 * 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 2000,
		pot = 2000
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	-- 实际值
			-- return 16000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 16000*(2*fy+115)/(fy+130)*math.random(85,115)/100/ 3600
		end,
		pot = function(sklv, fy)
			return 8000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
			return 3000/3600*math.random(80,108+math.floor(0.5*fy))/100
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 16000*(2*fy+115)/(fy+130)/ 3600
		end,
		avgPot = function(sklv, fy)
			return 8000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
			return 3000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 18400*(2*fy+115)/(fy+130)/ 3600
		end,
		maxPot = function(sklv, fy)
			return 8000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
			return 3000*math.min(1.2,0.9375+fy/400) / 3600*1.5
		end
	},

	printText = -- 输出显示的文本
	{
		startWork = -- 开始打工
		{
			"你从池子里勺起水，开始慢慢的洗盘子。"
		},
		startWorkGreaterThan = -- 开始打工, 且超出条件
		{
			"你已经很厉害了，这种工作不合适你做了。",
			"这点小事怎么敢劳您的大驾。",
			"药铺老板说道：以你的本事已经不用在我这工作了！"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"药铺老板说道：我的工作你现在还做不了吧！"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"药铺老板说道：之前不是才来过吗？怎么又来了。"
		},
		startGuaji = -- 开始挂机
		{
			"CYN药铺老板说道：好吧，你就帮我磨药吧！\nHIY你开始磨药。"
		},
		guajiing = -- 挂机中
		{
			{"你擦了擦脸上的汗水，蹲在一边拿着药锤开始磨药了！！", 2, "忽然看到药柜下有一些碎银，便趁没人注意偷偷藏进了怀了！！"},
			{"你擦了擦脸上的汗水，蹲在一边拿着药锤开始磨药了！！", 2, "你突然一个喷嚏，刚磨好的药粉喷了你一脸。"},
			{"你擦了擦脸上的汗水，蹲在一边拿着药锤开始磨药了！！", 2, "你仔细的将药材磨成粉，包扎好放在一边。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，停止了磨药。\nCYN药铺老板说道：来去自由，随便你了！不过就是有点儿可惜了这么认真的好劳力。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思，停止了磨药。\nCYN药铺老板说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
0000