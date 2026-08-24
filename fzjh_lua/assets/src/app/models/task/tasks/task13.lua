local task =
{
	id = "task13",

	-- 显示
	buttonA = "taskButton9a",
	buttonB = "taskButton9b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "护送军机", -- 任务名称

	minExp = 20000000, -- 最小经验值
	maxExp = 40000000, -- 最大经验值

	interval = 5,
	coolDown = 20 * 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 15000,
		pot = 15000
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy)	-- 实际值
			return 15424*((sklv-193)^2/290521+1)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		pot = function(sklv, fy)
			return 7712*((sklv-193)^2/290521+1)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
			return 9500/3600*math.random(80,108+math.floor(0.5*fy))/100
		end,
		avgExp = function(sklv, fy)	-- 平均值
			return 15424*((sklv-193)^2/290521+1)*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgPot = function(sklv, fy)
			return 7712*((sklv-193)^2/290521+1)*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
			return 9500*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 30900*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxPot = function(sklv, fy)
			return 15450*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
			return 9500*math.min(1.2,0.9375+fy/400) / 3600*1.3
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
			"军队神秘人说道：这种事情可不敢劳烦你这种高手出手。不过还是要多谢你上次的支援。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"军队神秘人说道：我这任务你暂时接不了！"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"军队神秘人说道：之前不是才来过吗？怎么又来了呢。"
		},
		startGuaji = -- 开始挂机
		{
			"CYN襄阳城总兵说道：你来得正好，正需要你这样的人，我这儿刚好有一批军机信件要送出去。\nHIY你开始护送军机。"
		},
		guajiing = -- 挂机中
		{
			{"你怀揣着军机信件开始护送任务。", 2, "行至半路，隐约发现远处好像发现有敌军小部队快马向你的方向赶来，你们赶紧找了个草丛躲了起来！",2,"在草丛里等候片刻后，你又继续上路了。"},
			{"你怀揣着军机信件开始护送任务。",2,"一路上你乔装打扮，竟然无人觉察到你的存在。",2,"你轻松的就把信件送到了目的地"},
			{"你怀揣着军机信件开始护送任务。",2,"一路上你乔装打扮，竟然无人觉察到你的存在。",2,"你轻松的就把信件送到了目的地"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，就停止了护送军机。\nCYN军队神秘人说道：江湖人士都喜欢潇洒自由！只可惜了你们拥有这么好的身手。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思，停止了护送军机。\nCYN军队神秘人说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
000000000