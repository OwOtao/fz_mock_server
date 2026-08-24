local task =
{
	id = "task6",

	-- 显示
	buttonA = "taskButton6a",
	buttonB = "taskButton6b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "武馆打杂", -- 任务名称

	minExp = 5000, -- 最小经验值
	maxExp = 15000, -- 最大经验值

	interval = 5,
	coolDown = 4 * 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 1500,
		pot = 1500
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	-- 实际值
			-- return 20000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 20000*(2*fy+115)/(fy+130)*math.random(85,115)/100/ 3600
		end,
		pot = function(sklv, fy)
			return 10000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
			return 2500/3600*math.random(80,108+math.floor(0.5*fy))/100
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 20000*(2*fy+115)/(fy+130)/ 3600
		end,
		avgPot = function(sklv, fy)
			return 10000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
			return 2500*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 23000*(2*fy+115)/(fy+130)/ 3600
		end,
		maxPot = function(sklv, fy)
			return 10000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
			return 2500*math.min(1.2,0.9375+fy/400) / 3600*1.5
		end
	},
	printText = -- 输出显示的文本
	{
		startWork = -- 开始打工
		{
			"你从池子里勺起水,开始慢慢的洗盘子。"
		},
		startWorkGreaterThan = -- 开始打工, 且超出条件
		{
			"你已经很厉害了,这种工作不适合你做了。",
			"这点小事怎么敢劳您的大驾。",
			"武馆管家说道：热爱劳动当然是美德,但是你现在好象不适合再干这些低档次的活了。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"武馆管家说道：我这边的活儿你暂时还接不了！"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"武馆管家说道：之前不是才来过了吗？怎么又来了？"
		},
		startGuaji = -- 开始挂机
		{
			"CYN武馆管家说道：这边后院正好缺人干活,你去做点杂活吧！\nHIY你开始打杂。"
		},
		guajiing = -- 挂机中
		{
			{"你拿起一把扫帚,在后院开始打扫起来。", 2, "你不停地挥舞着扫帚,看似很随意,却扬起阵阵小漩风！",2,"没经过多长时间,你就把后院打扫得干干净净。"},
			{"你拿起一把斧头,专心的劈起柴火来。",2,"你暗运内力,一斧子下去偌大的木桩如豆腐般被劈开了！",2,"片刻之后,你就把要劈的柴火都劈好了。"},
			{"你找了一对木桶,开始挑起水来。", 2, "你挑着满满一担水,飞快的穿行在后院,把几个盛水的水缸都装满了！",2,"你闲的无事,悄悄的找个角落打起盹来。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，停止了打杂。\nCYN武馆管家说道：来去自由，随便你了！不过就是有点可惜你这么能干的好劳力。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思,停止了打杂。\nCYN武馆管家说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
00000000