local task =
{
	id = "task3",

	-- 显示
	buttonA = "taskButton4a",
	buttonB = "taskButton4b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "采石场砸石头", -- 任务名称

	minExp = 2000, -- 最小经验值
	maxExp = 5000, -- 最大经验值

	interval = 3,
	coolDown = 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 500,
		pot = 500
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	--实际值
			-- return 24000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 24000*(2*fy+115)/(fy+130)*math.random(85,115)/100/ 3600
		end,   -- 同上
		pot = function(sklv, fy)
			return 12000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 24000*(2*fy+115)/(fy+130)/ 3600
		end,
		avgPot = function(sklv, fy)
			return 12000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 27600*(2*fy+115)/(fy+130)/ 3600
		end,
		maxPot = function(sklv, fy)
			return 12000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
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
			"采石场监工说道：这点小事怎么敢劳您的大驾。上次多亏了您，这是一点心意，不成敬意。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"采石场监工说道：就你这点水平干不了我这活儿，去去去，我这没功夫陪你。"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"采石场监工说道：之前不是才孝敬过您吗？怎么又来了。"
		},
		startGuaji = -- 开始挂机
		{
			"CYN采石场监工说道：我这里正缺人，拿着这把铁锤，去干活吧！\nHIY你开始砸石头。"
		},
		guajiing = -- 挂机中
		{
			{"只见你抡起巴掌狠狠的向巨石上击去，只听“喀嚓”一声，竟是骨碎的声音，这时你发现周围的人好象都在偷偷的乐！", 2},
			{"你举起铁锤，抡圆了胳膊对准石头狠狠地砸了起来。", 2, "铁锤一下子被反震起来，在空中划了一道美丽的弧线，然后结实的砸在了你的屁股上！"},
			{"你举起铁锤，抡圆了胳膊对准石头狠狠地砸了起来。", 2, "啪嗒一声，一块小碎石从巨石上掉了下来，看来你的工夫还是没有白费嘛！"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，停止了砸石头。\nCYN采石场监工说道：来去自由，随便你了！不过就是有点儿可惜了你这样的一个好劳力！"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思，停止了砸石头。\nCYN采石场监工说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
00000