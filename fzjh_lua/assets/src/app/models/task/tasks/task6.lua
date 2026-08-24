local task =
{
	id = "task4",

	-- 显示
	buttonA = "taskButton3a",
	buttonB = "taskButton3b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "戏院唱戏", -- 任务名称

	minExp = 80000, -- 最小经验值
	maxExp = 300000, -- 最大经验值

	interval = 3,
	coolDown = 8 * 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 3000,
		pot = 3000
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy , Lv)	-- 实际值
			-- return 9000*2^(sklv/140)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 9000*(6*sklv+140)/(Lv+sklv+210)*(2*fy+115)/(fy+130)*math.random(85,115)/100 / 3600
		end,
		pot = function(sklv, fy)
			return 4500*2^(sklv/140)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
			return 3500/3600*math.random(80,108+math.floor(0.5*fy))/100
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 9000*(6*sklv+140)/(Lv+sklv+210)*(2*fy+115)/(fy+130)/3600
		end,
		avgPot = function(sklv, fy)
			return 4500*2^(sklv/140)*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
			return 3500*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 20700*(2*fy+115)/(fy+130)/ 3600
		end,
		maxPot = function(sklv, fy)
			return 9000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
			return 3500*math.min(1.2,0.9375+fy/400) / 3600*1.5
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
			"戏院老板说道：乖乖，你的经验太高了，去另谋生路吧。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"戏院老板说道：一边去，没见我正忙着呢，哪凉快哪呆着去！"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"戏院老板说道：之前不是才来过吗？怎么又来了。"
		},
		startGuaji = -- 开始挂机
		{
			"CYN戏院老板说道：我这里正缺人，你到大街上去表演一下吧。\nHIY你开始唱戏。"
		},
		guajiing = -- 挂机中
		{
			{"你清了清嗓子，悠悠的唱起曲儿来。", 2,"一曲唱毕，旁边的人鼓起了掌。"},
			{"你运功于臂，用力向一块砖头劈去。", 2, "只见好大的块砖头应声而碎，旁人看得张大口说不出话来。"},
			{"你跳上了一根横挂的绳索，从这头向那头走去。", 2, "你从绳索上轻轻的走了过去，晃也没晃一下，旁人都看得目瞪口呆。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，停止了唱戏。\nCYN戏院老板说道：来去自由，随便你了！不过就是有点儿可惜了你这副好把式。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思，停止了唱戏。\nCYN戏院老板说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
0000000