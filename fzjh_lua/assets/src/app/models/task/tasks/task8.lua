local task =
{
	id = "task8",

	-- 显示
	buttonA = "taskButton8a",
	buttonB = "taskButton8b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "林家护镖", -- 任务名称

	minExp = 500000, -- 最小经验值
	maxExp = 1000000, -- 最大经验值

	interval = 5,
	coolDown = 16 * 60 * 60, -- 冷却时间
	workReward = -- 打工奖励(手点)
	{
		exp = 0,
		pot = 0
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 6000,
		pot = 6000
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	-- 实际值
			-- return 10498*((sklv-55)^2/24336+1)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 10498*(9*sklv+211)/(Lv+sklv+633)*(2*fy+115)/(fy+130)*math.random(85,115)/100 / 3600
		end,
		pot = function(sklv, fy)
			return 5249*((sklv-55)^2/24336+1)*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
			return 4800/3600*math.random(80,108+math.floor(0.5*fy))/100
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 10498*(9*sklv+211)/(Lv+sklv+633)*(2*fy+115)/(fy+130)/3600
		end,
		avgPot = function(sklv, fy)
			return 5249*((sklv-55)^2/24336+1)*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
			return 4800*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxExp = function(sklv, fy)	-- 最大值
			return 24145*(2*fy+115)/(fy+130)/ 3600
		end,
		maxPot = function(sklv, fy)
			return 10500*math.min(1.2,0.9375+fy/400) / 3600
		end,
		maxMoney = function(sklv, fy)
			return 4800*math.min(1.2,0.9375+fy/400) / 3600*1.5
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
			"镖头说道：这点小事怎敢劳你大驾，不过上次多亏了你，帮我们打跑了不少劫匪。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"镖头说道：就你现在这水平，还是别来护镖，省得没了性命！"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"镖头说道：之前不是才来过吗？怎么又来了？"
		},
		startGuaji = -- 开始挂机
		{
			"CYN镖局的镖头说道：我们有几趟镖要护送，正好缺几个人手。\nHIY你开始了护镖。"
		},
		guajiing = -- 挂机中
		{
			{"你跟着镖局的人，护送着镖车慢慢上路。", 2, "前面道路险峻，两边树林茂盛，突然发现前面有一块大石横在路上挡住了去路。",2,"你和几个押镖的人费了好大的劲才把石头挪开，镖车得以继续前行。"},
			{"你跟着镖局的人，护送着镖车慢慢上路。",2,"行至一人烟稀少，树林茂盛之处，忽然冒出几个蒙面劫匪来拦住去路。",2,"你大喝一声，毫无惧色地杀了上去，几个回合下来就把劫匪们全部打跑了。"},
			{"你跟着镖局的人，护送着镖车慢慢上路。", 2, "行至半路，忽的发现镖车的车轱辘被卡住了。",2,"你暗骂一声晦气，经过一番修正之后把车才重新上路。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，停止了护镖。\nCYN镖头说道：来去自由，随便你了！不过这一次多亏了你，帮了我们不少的忙。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思，停止了护镖。\nCYN镖头说道：走吧走吧，这里已经留不住你了。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
0000000000000