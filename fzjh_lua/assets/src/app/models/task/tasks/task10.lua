local task =
{
	id = "task10",

	-- 显示
	buttonA = "taskButton11a",
	buttonB = "taskButton11b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "抗击元兵", -- 任务名称

	minExp = 5000000, -- 最小经验值
	maxExp = 15000000, -- 最大经验值

	interval = 5,
	coolDown = 16 * 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 10000,
		pot = 10000
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	-- 实际值
			-- return 12244*(2^(sklv/527))*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 12244*(6*sklv+527)/(Lv+sklv+790)*(2*fy+115)/(fy+130)*math.random(85,115)/100 / 3600
		end,
		pot = function(sklv, fy)
			return 6122*(2^(sklv/527))*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
			return 6000/3600*math.random(80,108+math.floor(0.5*fy))/100
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 12244*(6*sklv+527)/(Lv+sklv+790)*(2*fy+115)/(fy+130)/3600
		end,
		avgPot = function(sklv, fy)
			return 6122*(2^(sklv/527))*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
			return 6000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 28161*(2*fy+115)/(fy+130)/ 3600
		end,
		maxPot = function(sklv, fy)
			return 12250*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
			return 6000*math.min(1.2,0.9375+fy/400) / 3600*1.3
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
			"抗元总兵说道：这种事情可不敢劳烦你这种高手出手。不过还是要多谢你上次的支援。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"抗元总兵说道：我这任务你暂时接不了！"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"抗元总兵说道：之前不是才来过吗？怎么又来了呢。"
		},
		startGuaji = -- 开始挂机
		{
			"CYN抗元总兵说道：据探子来报，元兵最近动向可疑，意图对襄阳不利。\nHIY你开始抗击元兵。"
		},
		guajiing = -- 挂机中
		{
			{"你加入一只由江湖人士组成的小军队奉命前去偷袭元兵大军侧翼部队。", 2, "出行未久，你们的行踪就被敌军发现了！",2,"商量了片刻后，你们改变主意决定去偷袭元兵补给部队。"},
			{"你加入了一只由江湖人士组成的小军队前去骚扰敌军部队。",2,"结果一不小心遭遇敌方部队，落入敌方的包围。",2,"一阵血拼之后，你终于冲杀出来！"},
			{"你加入一个小队奉命突袭敌军的辎重部队。", 2, "在一片树林里埋伏半天后，终于看到敌军的部队。",2,"你冲杀上去，一阵激战后，放火烧掉了敌方不少粮食。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，就停止了抗击元兵。\nCYN抗元总兵说道：江湖人士都喜欢潇洒自由！只可惜了你们拥有这么好的身手。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思，停止了抗击元兵。\nCYN抗元总兵说道：走吧走吧，这里已经留不住你了。"
		}
	}

}

-- 加密版本
task.isEncrypted = true
return task
000000000000000