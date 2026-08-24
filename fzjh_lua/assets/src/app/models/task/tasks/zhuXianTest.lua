local task =
{
	id = "taskzzz",

	-- 显示
	buttonA = "taskButton4a",
	buttonB = "taskButton4b",

	-- 数据
	type = "主线任务", -- 任务类型
	name = "飞贼横行", -- 任务名称
	desc = "最近 RED金牛武馆 HIW的 BLU大厅 HIW一带有飞贼出没，大侠可否前去一趟帮本官清理飞贼。",	--任务描述

	coolDown = 5, -- 冷却时间


	zhuXianCondition = -- 主线任务条件
	{
		time = 5,		-- 时间
		map = "fb01",		-- 地图
		roomId = "fb01_04",	-- 房间
		step = 2,		--房间刷怪范围
		buttonColor = {r = 28,g = 76,b = 163},	-- 按钮颜色
		npc = "feizei",		-- 人物
		totalCount = 5,	-- 总数
		zCount = 2,	-- 主线任务完成次数
		lastDate = "2016-03-00",--上次完成日期
		dCount = 1, -- 主线任务当天完成次数
		canAbandon = true,	-- 任务能否放弃（true 可以 false 不能）
	},
	-- 人物NPC属性
	npcAttr =
	{
		--可以拥有多个NPC
		["feizei"] =
			{
				type = "role",
				id = "feizei",
				baseId = "npc01_03",
				name = "飞贼",
				canTalk = true,
				canKill = true,
				talk =
				{
					"我是飞贼",
				},
			},
	},

	zhuXianReward = 	--奖励列表
	{
		{
			type = "属性",
			name = "exp",
			value = 10000
		},
		{
			type = "物品",
			name = "item01_03",
			value = 1
		}
	},
}

-- 加密版本
task.isEncrypted = true
return task
0000