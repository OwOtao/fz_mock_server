local items =
{

}

local function converJuHuaJiu()
	local juHuaJiuList =
	{
		juhuajiu100_da =
		{
			id = "juhuajiu100_da",
			name = "菊花酒_01大",
			itemList = "juhuajiu103",
			probability = 1
		},
		juhuajiu102_da =
		{
			id = "juhuajiu102_da",
			name = "菊花酒_02大",
			itemList = "juhuajiu104",
			probability = 1
		},
		juhuajiu103_da =
		{
			id = "juhuajiu103_da",
			name = "菊花酒_03大",
			itemList = "juhuajiu105",
			probability = 1
		},
		juhuajiu104_da =
		{
			id = "juhuajiu104_da",
			name = "菊花酒_04大",
			itemList = "juhuajiu106",
			probability = 1
		},
		juhuajiu105_da =
		{
			id = "juhuajiu105_da",
			name = "菊花酒_05大",
			itemList = ""
		},
		juhuajiu100_xiao =
		{
			id = "juhuajiu100_xiao",
			name = "菊花酒_01小",
			itemList = "juhuajiu102",
			probability = 1
		},
		juhuajiu102_xiao =
		{
			id = "juhuajiu102_xiao",
			name = "菊花酒_02小",
			itemList = "juhuajiu103",
			probability = 1
		},
		juhuajiu103_xiao =
		{
			id = "juhuajiu103_xiao",
			name = "菊花酒_03小",
			itemList = "juhuajiu104",
			probability = 1
		},
		juhuajiu104_xiao =
		{
			id = "juhuajiu104_xiao",
			name = "菊花酒_04小",
			itemList = "juhuajiu105",
			probability = 1
		},
		juhuajiu105_xiao =
		{
			id = "juhuajiu105_xiao",
			name = "菊花酒_05小",
			itemList = "juhuajiu106",
			probability = 1
		},
		juhuajiu100 =
		{
			id = "juhuajiu100",
			name = "一坛菊花酒",
			dsc = "这是一坛菊花酿制的烈酒，只见酒坛上赫然写着一个大大的“酒”字，酒坛还没有开封过。",
			itemList = ""
		},
		juhuajiu102 =
		{
			id = "juhuajiu102",
			name = "喝过的菊花酒",
			dsc = "这是一坛菊花酿制的烈酒，坛口已经被打开过了，酒香四溢。",
			itemList = ""
		},
		juhuajiu103 =
		{
			id = "juhuajiu103",
			name = "大半坛菊花酒",
			dsc = "这是一坛菊花酿制的烈酒，还剩下大半坛子。",
			itemList = ""
		},
		juhuajiu104 =
		{
			id = "juhuajiu104",
			name = "半坛菊花酒",
			dsc = "这是一坛菊花酿制的烈酒，还剩下半坛子。",
			itemList = ""
		},
		juhuajiu105 =
		{
			id = "juhuajiu105",
			name = "小半坛菊花酒",
			dsc = "这是一坛菊花酿制的烈酒，只剩下小半坛子了。",
			itemList = ""
		},
		juhuajiu106 =
		{
			id = "juhuajiu106",
			name = "几滴菊花酒",
			dsc = "这是一坛菊花酒酿制的烈酒，摇晃酒坛几乎听不到声音了，估计只剩下几滴了。",
			itemList = ""
		}
	}

	-- -- add by XiaoZhiWei 2017/10/21 12:21:22 2016年重阳节菊花酒属性
	-- for id,item in pairs(juHuaJiuList) do
	-- 	local baseItem =
	-- 	{
	-- 		type = "节日酒",
	-- 		unit = "瓶",
	-- 		dsc = "这是一瓶菊花酒。",
	-- 		att = "chufa100,chufa101,exp,pot,money",
	-- 		value = 3000,
	-- 		canFold = 1,
	-- 		canUse = 1,
	-- 		canEquip = 0,
	-- 		combo = 0,
	-- 		canSell = 0,
	-- 		canDrop = 0,
	-- 		effectDsc_1 = "HIB你喝了一口酒，只觉浑身有使不完的劲，恰逢听到有人喊抓贼，你心中暗道哪个不长眼的飞贼撞到本大侠手里了，随即纵身而起直奔飞贼逃跑的方向而去。（下一次飞贼横行任务奖励翻倍）#suijiGRN你刚喝了一口酒，正在细细品味，不想那飞贼突然出现，趁你不备夺了你的腰坠就走，等你回过神来，那贼已跑出数丈之远。（下一次飞贼横行任务奖励翻倍）",
	-- 		effectDsc_2 = "HIG喝了一口酒，只觉浑身周身气血通畅，于是趁着酒兴打起拳来，一套打完还不过瘾，心想若此时能与人切磋一二方能尽兴了。（下一次参加论剑奖励翻倍）#suijiBLU喝了一口酒，只觉此时有使不完的劲，兴致勃勃地想与人比武切磋，想起近日里正在办论剑大会，何不去瞧他一瞧。（下一次参加论剑奖励翻倍）",
	-- 		effectDsc_3 = "YEL一口酒下肚，只觉这酒不仅有菊花的香味儿，更有温润的口感。不由想起曾经跟师傅对饮的画面，回想起师傅的教导，似乎又领悟了一些人生道理。#suijiHIB一口酒下肚，你忽觉诗兴大发，想起正值重阳佳节，便即兴赋诗一首，亦感悟了一些人生道理。",
	-- 		effectDsc_4 = "HIY你喝了一口酒，只觉周身气血通畅，于是趁着酒兴打起拳来，打完之后感觉自己的修为又增长了不少。#suijiHIG你喝了一口酒，觉得浑身燥热难耐，便静下心来打坐运功，一个小周天走完之后，不仅不再燥热，且因吸收了酒力使得武功更加精进了。",
	-- 		effectDsc_5 = "GRN你喝了一口酒，不由兴致大发，当街打起拳来，引得众人纷纷喝彩，还有人慷慨解囊以资鼓励。#suijiBLU你才喝了一口酒，只觉酒中有何异物，吐出一瞧，居然是一锭碎银。。。",
	-- 		effectDsc_6 = "HIG你猛地喝了一大口酒，想起前日里腰坠被那不长眼的飞贼给盗走了，越想心中越是憋闷，于是趁着酒劲直捣那飞贼的老巢。（下一次飞贼横行任务奖励为六倍）",
	-- 		effectDsc_7 = "HIY猛地喝了一大口酒，一时竟胡言乱语起来，狂言道此次论剑若不夺下魁首誓不为人。（下一次参加论剑并获胜奖励为六倍）",
	-- 		effectDsc_8 = "YEL一大口菊花酒下肚，这酒中浓浓的菊花香味儿加上又正值重阳佳节，想起自己独身闯荡江湖已久，多日未曾与家人团聚，你感叹亲情的可贵，对人生又有了新的领悟。",
	-- 		effectDsc_9 = "HIB你抱起酒坛喝了一口大酒，顿时只觉大脑异常兴奋，想起前几日未能领悟的招式，一下便顿悟了。",
	-- 		effectDsc_10 = "BLU你抱着酒坛咕隆隆地喝了一大口，顿时便觉天旋地转，随即便醉醺醺地倒在路边，醒来时却发现酒盏里不知何时多了一叠铜板。。。"
	-- 	}
	-- 	item = Helper:tableCover(baseItem, item)
	-- 	items[item.id] = item
	-- end

	-- add by XiaoZhiWei 2017/10/21 12:21:44 2017年重阳节菊花酒属性
	for id,item in pairs(juHuaJiuList) do
		local baseItem =
		{
			type = "节日酒",
			unit = "瓶",
			dsc = "这是一瓶菊花酒。",
			tag = "2017菊花酒",
			att = "exp,pot,money,yueli",
			value = "3000,5000,10000,10;8,42,27,23",
			canFold = 1,
			canUse = 1,
			canEquip = 0,
			combo = 0,
			canSell = 0,
			canDrop = 0,
			timeend = "$S20171111",
			-- add by XiaoZhiWei 2017/10/21 15:53:07 小口文本
			effectDsc_1 = "YEL一口酒下肚，只觉这酒不仅有菊花的香味儿，更有温润的口感。不由想起曾经跟师傅对饮的画面，回想起师傅的教导，似乎又领悟了一些人生道理。#suijiHIB一口酒下肚，你忽觉诗兴大发，想起正值重阳佳节，便即兴赋诗一首，亦感悟了一些人生道理。",
			effectDsc_2 = "HIY你喝了一口酒，只觉周身气血通畅，于是趁着酒兴打起拳来，打完之后感觉自己的修为又增长了不少。#suijiHIG你喝了一口酒，觉得浑身燥热难耐，便静下心来打坐运功，一个小周天走完之后，不仅不再燥热，且因吸收了酒力使得武功更加精进了。",
			effectDsc_3 = "GRN你喝了一口酒，不由兴致大发，当街打起拳来，引得众人纷纷喝彩，还有人慷慨解囊以资鼓励。#suijiBLU你才喝了一口酒，只觉酒中有何异物，吐出一瞧，居然是一锭碎银。。。",
			effectDsc_4 = "YEL你抿了一口菊花酒，清醇的香气在你口中回荡，让你不由得想起了江湖游历中的点点滴滴，不由得感触良多。",

			-- add by XiaoZhiWei 2017/10/21 15:53:15 大口文本
			effectDsc_5 = "YEL一大口菊花酒下肚，这酒中浓浓的菊花香味儿加上又正值重阳佳节，想起自己独身闯荡江湖已久，多日未曾与家人团聚，你感叹亲情的可贵，对人生又有了新的领悟。",
			effectDsc_6 = "HIB你抱起酒坛喝了一口大酒，顿时只觉大脑异常兴奋，想起前几日未能领悟的招式，一下便顿悟了。",
			effectDsc_7 = "BLU你抱着酒坛咕隆隆地喝了一大口，顿时便觉天旋地转，随即便醉醺醺地倒在路边，醒来时却发现酒盏里不知何时多了一叠铜板。。。",
			effectDsc_8 = "HIY你大饮了一口菊花酒，脑中竟然浮现出当年的往事，让你唏嘘不已，感慨万分。",
		}
		item = Helper:tableCover(baseItem, item)
		items[item.id] = item
	end
end

-- 面具
local function listForMianJu()
	local list =
	{
		-- mianju1002 =
		-- {
		-- 	id = "mianju1002",
		-- 	name = "戏曲面具（童姥）",
		-- 	type = "面具",
		-- 	unit = "张",
		-- 	dsc = "这是一张天山童姥的戏曲面具，在重阳节人们会戴着它参加聚会，其质地光滑细腻，也不知是由什么制作而成的。",
		-- 	equipText = "HIG你对着镜子缓缓地将天山童姥面具戴在脸上，一张天真女童的面容出现在了镜中，你痴痴地看着镜中的自己，心中惊诧万分！",
		-- 	unwieldText = "HIG你缓缓地将天山童姥面具摘下，恢复了你原来的面貌。",
		-- 	salePrice = 10,
		-- 	buyPrice = 1000000,
		-- 	deposit = 0,
		-- 	itemCanSale = 0
		-- },
		-- mianju1003 =
		-- {
		-- 	id = "mianju1003",
		-- 	name = "戏曲面具（王维）",
		-- 	type = "面具",
		-- 	unit = "张",
		-- 	dsc = "这是一张王维的戏曲面具，在重阳节人们会戴着它参加聚会，其质地光滑细腻，也不知是由什么制作而成的。",
		-- 	equipText = "HIG你对着镜子缓缓地将王维面具戴在脸上，一张儒雅文士的面容出现在了镜中，你几乎认不出自己了！",
		-- 	unwieldText = "HIG你缓缓地将王维面具摘下，恢复了你原来的面貌。",
		-- 	salePrice = 10,
		-- 	buyPrice = 1000000,
		-- 	deposit = 0,
		-- 	itemCanSale = 0
		-- }
	}

	for id,item in pairs(list) do
		items[item.id] = item
	end
end

local function listForNormalItem()
	local list =
	{
		shuxiang =
		{
			id = "shuxiang",
			name = "书箱",
			type = "书箱",
			dsc = "这是书箱",
		},
		decorativeBox =
		{
			id = "decorativeBox",
			name = "装饰箱",
			type = "装饰箱",
			dsc = "这是装饰箱",
		},
		literaryBox =
		{
			id = "literaryBox",
			name = "书匣",
			type = "书匣",
			dsc = "这是书匣",
		},
		equipsBox =
		{
			id = "equipsBox",
			name = "装备箱",
			type = "装备箱",
			dsc = "这是装备箱",
		},
		medicinalBox =
		{
			id = "medicinalBox",
			name = "药囊",
			type = "药囊",
			dsc = "这是药囊",
		},
		smeltBox =
		{
			id = "smeltBox",
			name = "冶炼箱",
			type = "冶炼箱",
			dsc = "这是冶炼箱",
		},
		bookRack =
		{
			id = "bookRack",
			name = "书架",
			type = "书架",
			dsc = "这是书架",
		},
		volumeBox = {
			id = "volumeBox",
			name = "续卷箱",
			type = "续卷箱",
			dsc = "这是续卷箱",
		}
	}

	for id,item in pairs(list) do
		items[item.id] = item
	end
end

local function initItems()
	converJuHuaJiu()
	listForMianJu()
	listForNormalItem()
end

initItems()
return items000000000