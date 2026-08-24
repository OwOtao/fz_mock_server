local task =
{
	id = "task7",

	-- 显示
	buttonA = "taskButton7a",
	buttonB = "taskButton7b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "平安巡城", -- 任务名称

	minExp = 300000, -- 最小经验值
	maxExp = 500000, -- 最大经验值

	interval = 5,
	coolDown = 12 * 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 5000,
		pot = 5000
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	-- 实际值
			-- return 9720*((sklv-46)^2/14400+1)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 9720*(10*sklv+166)/(Lv+sklv+581)*(2*fy+115)/(fy+130)*math.random(85,115)/100 / 3600
		end,
		pot = function(sklv, fy)
			return 4860*((sklv-46)^2/14400+1)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
			return 4000/3600*math.random(80,108+math.floor(0.5*fy))/100
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 9720*(10*sklv+166)/(Lv+sklv+581)*(2*fy+115)/(fy+130)/3600
		end,
		avgPot = function(sklv, fy)
			return 4860*((sklv-46)^2/14400+1)*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
			return 4000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 22356*(2*fy+115)/(fy+130)/ 3600
		end,
		maxPot = function(sklv, fy)
			return 9750*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
			return 4000*math.min(1.2,0.9375+fy/400) / 3600*1.5
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
			"巡捕说道：这点小事怎敢劳你大驾，不过上次多亏了你，这是一点心意，不成敬意。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"巡捕说道：我这活儿有点危险，你暂时接不了！"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"巡捕说道：之前不是才来过吗？怎么又来了？"
		},
		startGuaji = -- 开始挂机
		{
			"CYN平安城的巡捕说道：最近城内的治安状况不是很好，你来帮我巡逻一下吧！\nHIY你开始巡城。"
		},
		guajiing = -- 挂机中
		{
			{"你身着一身“临时”的巡捕衣服，开始了巡城。", 2, "走在熙熙攘攘的大街上，你觉得今天应该不会遇到什么特别的事。",2,"突然的，你看到了一个小偷在行窃，你赶紧使出一招擒拿手，瞬间把小偷擒住。"},
			{"你身着一身“临时”的巡捕衣服，开始了巡城。",2,"在一个小巷口，你看到几个人好像有点可疑，就跟了过去。",2,"跟了好大一圈后，你发现原来是几个文人在准备聚会赋诗。"},
			{"你身着一身“临时”的巡捕衣服，开始了巡城。", 2, "你巡至一处街口，看到一群人在围观一个卖艺的在耍刀，兴致一来也跟着多看了一下。",2,"你看那刀法，看似平淡无力却感觉并非那么简单，好似在哪见过。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，停止了巡逻。\nCYN巡捕说道：来去自由，随便你了！不过好像每次你一巡逻，街上的治安就好了很多。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思,停止了巡城。\nCYN巡捕说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
0000000000000