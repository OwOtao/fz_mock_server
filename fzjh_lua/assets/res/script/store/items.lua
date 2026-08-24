local items = 
{
	fuyuandan = 
	{
		name = "HIY福缘丹",
		attr = "luck",
		value = 1,
		desc = "一颗圆圆的福缘丹，据说吃了可以增强运气。",
		useDesc = "你一仰脖，吞下了一粒HIY福缘丹NOR。",
		afterDesc = 
		{
			"HIG你开始觉得你的运气开始不错起来，你的福缘指数提升了。"
		}
	},
	xiyanshui = 
	{
		name = "HIY洗颜水",
		attr = "looks",
		value = 1,
		desc = "一瓶金灿灿的泥水，散发着难闻的味道，据说可以养血美颜。",
		useDesc = "你将YEL洗颜水NOR倒在手上，稍加揉搓，犹豫了一下，便往脸上抹去，不一会儿便涂抹均匀。",
		afterDesc = 
		{
			"你似乎感觉自己的面容渐渐模糊起来，不由吓了一大跳！",
			"HIY你周身的皮肤痒痒的似乎要崩裂开来，好在一会儿就停了下来，浑身上下轻松很多。",
			"HIG你开始发觉你的容貌开始改变，变的漂亮多了。"
		}
	},
	shenlisan = 
	{
		name = "HIR神力散",
		attr = "str",
		value = function()
			return math.random(1, 2)
		end,
		desc = "一包红色的药粉，据说吃了可以增强力量 。",
		useDesc = "你按住一边鼻孔，对着药粉用鼻子一顿狂吸 。",
		afterDesc = 
		{
			"HIR好像用力过猛，药粉刺激得你直翻白眼。",
			"HIR你觉得双臂几乎爆裂，充满了力量。"
		}
	},
	qingshenyao = 
	{
		name = "HIG轻身药",
		attr = "looks",
		value = function()
			return math.random(1, 2)
		end,
		desc = "一粒绿绿的小药丸，据说吃了可以提高身法 。",
		useDesc = "你一仰脖，吞下了一颗HIG轻身药NOR 。",
		afterDesc = 
		{
			"HIM霎时间你觉得腿骨欲裂，一时疼痛难忍，几乎晕了过去。",
			"HIM不一会儿，痛楚尽消，你觉得自己身体更加轻盈了。"
		}
	}
}

return items000000000000