local socket = require("socket") -- 需要用到luasocket库
local function get_seed()
        local t = string.format("%f", socket.gettime())
        local st = string.sub(t, string.find(t, "%.") + 1, -1)
        return tonumber(string.reverse(st))
end
math.randomseed(get_seed())

local task =
{
	id = "task2",

	-- 显示
	buttonA = "taskButton1a",
	buttonB = "taskButton1b",

	-- 数据
	type = "挂机任务", -- 任务类型
	name = "酒馆洗盘子", -- 任务名称

	minExp = 1000, -- 最小经验值
	maxExp = 2000, -- 最大经验值

	coolDown = 4, -- 冷却时间
	interval = 3, -- 奖励间隔

	zCount = 0,	-- 完成总次数
	dCount = 0,	-- 当天完成次数
	cCount = 280,	-- 每日完成次数限制

	workReward = -- 打工奖励(手点)
	{
		exp = 200,
		pot = 200
	},
	workRewardGreaterThan = -- 经验超过后的打工奖励
	{
		exp = 10,
		pot = 10
	},
	guajiReward = -- 挂机奖励
	{
		exp = function(sklv, fy,Lv)	--实际值
			-- return 38000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
			return 38000*(2*fy+115)/(fy+130)*math.random(85,115)/100/ 3600
		end,   -- 同上
		pot = function(sklv, fy)
			return 18000*math.min(1.2,math.random(80,108+math.floor(0.5*fy))/100) / 3600
		end,
		money = function(sklv, fy)
		end,
		avgExp = function(sklv, fy,Lv)	-- 平均值
			return 38000*(2*fy+115)/(fy+130)/ 3600
		end,
		avgPot = function(sklv, fy)
			return 18000*math.min(1.2,0.9375+fy/400) / 3600
		end,
		avgMoney = function(sklv, fy)
		end,
		maxExp = function(sklv, fy)	-- 最大值
			-- return 38000*math.min(1.2,0.9375+fy/400) / 3600
			return 43700*(2*fy+115)/(fy+130)/ 3600
		end,

		maxPot = function(sklv, fy)
			return 18000*math.min(1.2,0.9375+fy/400) / 3600
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
			"你经验太高，洗盘子对于你来说收效甚微。",
			"这点小事怎么敢劳您的大驾。"
		},
		startWorkLessThen = -- 开始打工, 且低于条件
		{
			"就你这点水平干不了我这活儿，去去去，我这没功夫陪你。"
		},
		startWorkCoolDown = -- 任务未冷却
		{
			"之前不是才来过吗？怎么又来了。"
		},
		startGuaji = -- 开始挂机
		{
			"HIY你开始洗盘子。"
		},
		guajiing = -- 挂机中
		{
			{"你从池子里勺起水，开始慢慢的洗盘子。", 2, "你洗了良久，终于将盘子全部洗好了。"},
			{"你从池子里勺起水，开始慢慢的洗盘子。", 2, "你手一滑，盘子摔了个粉碎，你赶紧收拾干净，装作什么也没发生。"}
		},
		stopGuaji = -- 手动停止挂机
		{
			"HIY你觉得差不多了，停止了洗盘子。"
		},
		autoStopGuaji = -- 挂满, 自动停止
		{
			"HIY你觉得没啥意思，停止了洗盘子。"
		}
	}
}

-- 加密版本
task.isEncrypted = true
return task
0000000