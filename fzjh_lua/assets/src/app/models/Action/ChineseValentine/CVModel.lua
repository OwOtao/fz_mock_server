local CVModel = {}


local tape = {
	qixiqiyuan1 = "粗制纸带",
	qixiqiyuan2 = "精致红布带",
	qixiqiyuan3 = "特制红丝带"
}

local prayMap = {
	["caiyuanguangjin"] = "财源广进",
	["wugongyoucheng"] = "武功有成",
	["huarongyuemao"] = "花容月貌",
	["jinglichongpei"] = "精力充沛",
	["juexuezhaoshi"] = "绝学招式",
	["shangdenghaojiu"] = "上等好酒",
	["shenbingliqi"] =	"神兵利器",
	["meishijiayao"] =	"美食佳肴",
	["xuefuwuche"] =	"学富五车",
	["shimenxingwang"] = "师门兴旺",
	["jianghumeiyu"] =	"江湖美誉",
	["jingmaiyoucheng"] = "经脉有成",

}

local qiyuanMap = {
	{
		name = "财源广进",
		text = "我想成为全天下最有钱的人，娶三房小妾，盖八所大院。"
	},
	{
		name = "武功有成",
		text = "我想要闭关无阻，武功大进，超越我的同辈。"
	},
	{
		name = "花容月貌",
		text = "我希望我的颜值能够迷倒众人，成为江湖第一$N。"
	},
	{
		name = "精力充沛",
		text = "我想精力用不完，练一辈子功也不用停。"
	},
	{
		name = "绝学招式",
		text = "我想学到武功绝学，纵横天下！"
	},
	{
		name = "上等好酒",
		text = "我需要一瓶好酒，慰藉我现在脆弱的心灵。"
	},
	{
		name = "神兵利器",
		text = "我要神兵利器！能锻造的那种！"
	},
	{
		name = "美食佳肴",
		text = "我想吃春节最好的食物，让我不虚此行。"
	},
	{
		name = "学富五车",
		text = "我想增长学识，提升修养，成为国家栋梁之才。"
	},
	{
		name = "师门兴旺",
		text = "我希望师门贡献多到用不完，想换什么换什么。"
	},
	{
		name = "江湖美誉",
		text = "我希望得到用不完的江湖美誉，换取所有信物！"
	},
	{
		name = "经脉有成",
		text = "我想打通奇经八脉，独步武林！"
	},
}


local prayData = {
	["qixiqifu1"] = {name =  "纸带(财)", tape = "qixiqiyuan1", value = 5, type = "caiyuanguangjin"},
	["qixiqifu2"] = {name =  "纸带(武)", tape = "qixiqiyuan1", value = 5, type = "wugongyoucheng"},
	["qixiqifu3"] = {name =  "纸带(貌)", tape = "qixiqiyuan1", value = 5, type = "huarongyuemao"},
	["qixiqifu4"] = {name =  "纸带(精)", tape = "qixiqiyuan1", value = 5, type = "jinglichongpei"},
	["qixiqifu5"] = {name =  "纸带(招)", tape = "qixiqiyuan1", value = 5, type = "juexuezhaoshi"},
	["qixiqifu6"] = {name =  "纸带(酒)", tape = "qixiqiyuan1", value = 5, type = "shangdenghaojiu"},
	["qixiqifu7"] = {name =  "纸带(器)", tape = "qixiqiyuan1", value = 5, type = "shenbingliqi"},
	["qixiqifu8"] = {name =  "纸带(食)", tape = "qixiqiyuan1", value = 5, type = "meishijiayao"},
	["qixiqifu9"] = {name =  "纸带(学)", tape = "qixiqiyuan1", value = 5, type = "xuefuwuche"},
	["qixiqifu10"] = {name = "纸带(师)", tape = "qixiqiyuan1", value = 5, type = "shimenxingwang"},
	["qixiqifu11"] = {name = "纸带(誉)", tape = "qixiqiyuan1", value = 5, type = "jianghumeiyu"},
	["qixiqifu12"] = {name = "纸带(脉)", tape = "qixiqiyuan1", value = 5, type = "jingmaiyoucheng"},

	["qixiqifu13"] = {name = "RED布带(财)NOR", tape = "qixiqiyuan2", value = 10, type = "caiyuanguangjin"},
	["qixiqifu14"] = {name = "RED布带(武)NOR", tape = "qixiqiyuan2", value = 10, type = "wugongyoucheng"},
	["qixiqifu15"] = {name = "RED布带(貌)NOR", tape = "qixiqiyuan2", value = 10, type = "huarongyuemao"},
	["qixiqifu16"] = {name = "RED布带(精)NOR", tape = "qixiqiyuan2", value = 10, type = "jinglichongpei"},
	["qixiqifu17"] = {name = "RED布带(招)NOR", tape = "qixiqiyuan2", value = 10, type = "juexuezhaoshi"},
	["qixiqifu18"] = {name = "RED布带(酒)NOR", tape = "qixiqiyuan2", value = 10, type = "shangdenghaojiu"},
	["qixiqifu19"] = {name = "RED布带(器)NOR", tape = "qixiqiyuan2", value = 10, type = "shenbingliqi"},
	["qixiqifu20"] = {name = "RED布带(食)NOR", tape = "qixiqiyuan2", value = 10, type = "meishijiayao"},
	["qixiqifu21"] = {name = "RED布带(学)NOR", tape = "qixiqiyuan2", value = 10, type = "xuefuwuche"},
	["qixiqifu22"] = {name = "RED布带(师)NOR", tape = "qixiqiyuan2", value = 10, type = "shimenxingwang"},
	["qixiqifu23"] = {name = "RED布带(誉)NOR", tape = "qixiqiyuan2", value = 10, type = "jianghumeiyu"},
	["qixiqifu24"] = {name = "RED布带(脉)NOR", tape = "qixiqiyuan2", value = 10, type = "jingmaiyoucheng"},
	
	["qixiqifu25"] = {name = "HIR丝带(财)NOR", tape = "qixiqiyuan3", value = 20, type = "caiyuanguangjin"},
	["qixiqifu26"] = {name = "HIR丝带(武)NOR", tape = "qixiqiyuan3", value = 20, type = "wugongyoucheng"},
	["qixiqifu27"] = {name = "HIR丝带(貌)NOR", tape = "qixiqiyuan3", value = 20, type = "huarongyuemao"},
	["qixiqifu28"] = {name = "HIR丝带(精)NOR", tape = "qixiqiyuan3", value = 20, type = "jinglichongpei"},
	["qixiqifu29"] = {name = "HIR丝带(招)NOR", tape = "qixiqiyuan3", value = 20, type = "juexuezhaoshi"},
	["qixiqifu30"] = {name = "HIR丝带(酒)NOR", tape = "qixiqiyuan3", value = 20, type = "shangdenghaojiu"},
	["qixiqifu31"] = {name = "HIR丝带(器)NOR", tape = "qixiqiyuan3", value = 20, type = "shenbingliqi"},
	["qixiqifu32"] = {name = "HIR丝带(食)NOR", tape = "qixiqiyuan3", value = 20, type = "meishijiayao"},
	["qixiqifu33"] = {name = "HIR丝带(学)NOR", tape = "qixiqiyuan3", value = 20, type = "xuefuwuche"},
	["qixiqifu34"] = {name = "HIR丝带(师)NOR", tape = "qixiqiyuan3", value = 20, type = "shimenxingwang"},
	["qixiqifu35"] = {name = "HIR丝带(誉)NOR", tape = "qixiqiyuan3", value = 20, type = "jianghumeiyu"},
	["qixiqifu36"] = {name = "HIR丝带(脉)NOR", tape = "qixiqiyuan3", value = 20, type = "jingmaiyoucheng"},
}

function CVModel:getPrayItemMap()
	return prayMap
end
function CVModel:getQiyuanMap()
	return qiyuanMap
end
function CVModel:getTapeMap()
	return tape
end

function CVModel:getPrayData()
	return prayData
end

return CVModel 00000000