local TeacherAnimationLayer = class("TeacherAnimationLayer", require("app.views.base.BaseLayer"))


function TeacherAnimationLayer:createInRunningScene()
	
	local layer = TeacherAnimationLayer:getInstance()
	
	return layer
end

function TeacherAnimationLayer:create()
	local p = TeacherAnimationLayer:new()
	p:init()
	return p
end

function TeacherAnimationLayer:init()
	self.UI = require("Layer/TeacherUI/TeacherAnimationUI.lua").create() ['root']
	self.UI:addTo(self)
	Helper:convertUI(self) -- 获得所有子节点
	
	self.duration = {} ----记录所有序言额外暂停的时间
	self.extra_space = {}   ---记录在一大段的地方 增加间距
	self.Panel_item_str = {} ---记录文本创建的panel
	self.Panel_item_str_ChuanCheng = {} ---记录文本创建的panel
	
	self.chuancheng = nil ---记录是传承播动画
	self.theLastPosition = nil --记录最后一条panel的位置
	
	self._currRow = 0
	
	self.Panel_hide:releaseFunc(function()
		self.Panel_hide:setVisible(false)
		self:hide()
	end)
end

function TeacherAnimationLayer:hide()
	self:setVisible(true)
	self.Panel_back:setVisible(true)
	local duration = 2
	local duration_Panel_back = 0.1
	----传承创建的加入隐藏动画的数组里
	if #self.Panel_item_str_ChuanCheng >= 1 then
		for j = 1, #self.Panel_item_str_ChuanCheng do
			self.Panel_item_str_ChuanCheng[j]:setOpacity(255 / 1.5)
			self.Panel_item_str[#self.Panel_item_str + 1] = self.Panel_item_str_ChuanCheng[j]
		end
	end
	-----action不能复用，第一个移除后，后面的就不能溢出，也不能正常运行
	for i = 1, #self.Panel_item_str do
		local action =
		cc.Sequence:create(
		cc.FadeOut:create(duration)
		)
		local action1 =
		cc.Sequence:create(
		cc.FadeOut:create(duration),
		cc.CallFunc:create(function()
			self:setVisible(false)
			self.Panel_back:setVisible(false)
			self:initActionData()
		end)
		)
		if i < #self.Panel_item_str then
			self.Panel_item_str[i]:runAction(action)
		else
			self.Panel_item_str[i]:runAction(action1)
		end
	end
	-----------------------------------------------------------------------------------------------------------
	-- @author GaoHanZheng
	-- @time 2017/06/14 17:20:32
	-- @desc 回调仅有效一次，执行后设置为空
	if self._callFunc then
		self._callFunc()
		self._callFunc = nil
	end
	self.func()
end

function TeacherAnimationLayer:show(Func)
	self:setVisible(true)
	self.Panel_hide:setVisible(false)
	self.Panel_back:setVisible(true)
	self.Panel_back:setOpacity(0)
	local action =
	cc.Sequence:create(
	cc.FadeIn:create(2),
	cc.CallFunc:create(function()
		self:showMenPaiStr()
	end)
	)
	self.Panel_back:stopAllActions()
	self.Panel_back:runAction(action)
	
	if Func == nil then
		Func = function()
		end
	end
	self.func = Func
end
function TeacherAnimationLayer:initActionData()
	for i, v in ipairs(self.Panel_item_str) do
		v:setVisible(false)
	end
	for i, v in ipairs(self.Panel_item_str_ChuanCheng) do
		v:setVisible(false)
	end
	self.duration = {} ----记录所有序言额外暂停的时间
	self.extra_space = {}
	self.Panel_item_str = {} ---记录文本创建的panel
	self.chuancheng = nil
	
end

local wuDangStr = {
	[1] = "雾罩云腾仙洞绕，",
	[2] = "飞流涧水曲歌谣。#####",
	[3] = "时光一晃已过数十载，张三丰一心向道，不再过问世事。宋远桥、俞莲舟一同跟随张三丰修道，不再管理武当事务。",
	[4] = "殷梨亭还俗成家，俞岱岩、张翠山、莫声谷三人仙逝。掌门一职由张松溪接任，在张松溪的励精图治下。#####",
	[5] = "武当如今已是正道巨擘，江湖之中无人不知，无人不晓。",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "风雨欲来，武当又将会如何呢？",
}
local eMeiStr = {
	[1] = "蜀中多仙山，",
	[2] = "峨眉邈难匹。#####",
	[3] = "数十年风云变换，一代新人换旧人，峨眉四代弟子均已仙逝。",
	[4] = "五代弟子中的宝相神尼继承了掌门之位，这几十年来，峨眉人才辈出，",
	[5] = "前有玄灵师太剑斩荆南九煞，名震武林，后有峨眉三剑行侠仗义，声名远播。#####",
	[6] = "这一代的峨眉已非昔日可比，隐有一夺武林至尊之势。",
	[7] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[8] = "时局动荡，山雨欲来，峨眉是否能在这混乱的江湖中一展拳脚？"
}
local huaShanStr = {
	[1] = "秀色横千里，",
	[2] = "归云积几重。#####",
	[3] = "数十年前，华山经历一场血战，人才凋零，日暮途穷，几乎灭绝。#####",
	[4] = "于此危难之际，莫天雄接过掌门之位。",
	[5] = "手腕过人的他以一己之力支撑起整个华山，华山终未破败，",
	[6] = "而其师兄百里云乃是百年难遇的武道天才，十七岁华山剑法便已大成，并自创四象天步以辅之，数十年的磨练，如今，他的武功已是深不可测。#####",
	[7] = "华山后辈子弟之中，亦有资质不凡者，华山中兴有望！",
	[8] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[9] = "四方豪强纷起，江湖愈发动荡不安，华山又将如何延续下去..",
	
}

local kunLunStr =
{
	[1] = "烟锁昆仑山顶上，",
	[2] = "月明娑竭海中心。#####",
	[3] = "一代江山一代人，时间已过数十载，现任昆仑掌门乃是上代掌门何天元之子何东来，因脾气暴躁，剑法卓绝。",
	[4] = "江湖人称“昆仑剑狮”，三山五岳之中无人不知其大名。#####",
	[5] = "如今的昆仑派人才济济，高手辈出，乃是正派之中一股不可忽视的力量。",
	[6] = "而新一代的昆仑派弟子，亦开始行走江湖。#####",
	[7] = "数月前，江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。",
	[8] = "面对动荡的江湖，昆仑，将走向何方？"
	
}

local xinXiuStr =
{
	[1] = "忽闻西北哀啸起，",
	[2] = "天狼烟下尸满地。#####",
	[3] = "自从西北毒师仙去之后，其座下弟子为争毒师之位，同脉相残，血流成河。",
	[4] = "数年的争斗，令西北毒师一脉元气大伤。",
	[5] = "直至一代毒师“魏师道”的崛起，诛杀异己，重建秩序，在西北大漠天狼山处开疆拓土，西北毒师一脉才终于走上正轨，取名“天狼教”。#####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。",
	[7] = "今面对动荡不安的江湖，天狼教能否一扫颓势，重新崛起呢？#####",
}

local baiTuoShanStr =
{
	[1] = "山魈吹火虫入碗，",
	[2] = "鸩鸟咒诅鲛吐涎。#####",
	[3] = "鸩羽山上常有鸩鸟蜈蚣、毒蛇臭鼬，寻常猎户也不敢上山围猎，恐有性命之忧。",
	[4] = "而“冷毒算士”欧阳泽起自毒泽，不仅通晓奇门算术，更通驱毒炼丹之道。",
	[5] = "为修炼毒丹之术，欧阳泽在鸩羽山上广收门徒，炼丹制毒，开创鸩羽山一门。#####",
	[6] = "自欧阳师祖闭关之后，鸩羽山日渐衰弱，大不如前，直至年轻一代欧阳博的出现。此人足智多谋，手段狠辣，经其数十年的整治，鸩羽山一扫颓势，尤胜当年欧阳泽之时。#####",
	[7] = "如今的武林，动荡不安，数十年前消失的“周天功”再现于江湖，欧阳博已派其徒欧阳啸下山一探真假。#####",
	
}

local tianShanStr =
{
	[1] = "白雪初下天山外，",
	[2] = "浮云直上五原间。#####",
	[3] = "虚渺宫在清竹子的领导之下逐渐壮大，门派现由其徒天枢子掌管。",
	[4] = "如今的虚渺宫精英辈出，其门下弟子， ",
	[5] = "落叶飞花秦断弦，长剑无语高歌，皆闻名于江湖。",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "天山新一代的弟子也已到了下山历练的时候,",
	[8] = "不知他们又将会有怎样的故事与传奇呢?"
}

local quanZhenJiaoStr =
{
	[1] = "处世自能心混沌，",
	[2] = "全真谁见德支离。#####",
	[3] = "全真教自重阳真人创立以来，以行侠仗义、救苦恤贫为己任，",
	[4] = "早在数十年前重阳真人辞去掌教一职，潜心修道，掌教之位由马钰继承。",
	[5] = "在其领导之下，如今的全真教人才辈出，高手如云，乃是当世数一数二的大派。#####",
	[6] = "数月前，江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "在这动荡的江湖之中，全真，想必定有一番作为.."
	
}

local tianLongShiStr =
{
	[1] = "崇圣尊佛居大理，",
	[2] = "神剑传说非妄言。#####",
	[3] = "数十年前，天龙寺历经一场浩劫，寺中住持重伤圆寂，本字辈大师身亡其二，天龙寺损失惨重，",
	[4] = "不过好在诸多秘籍并未遗失，天龙寺又是大理皇家寺院，",
	[5] = "数十年的休养生息，天龙寺已经恢复当年之势。#####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "江湖动荡不安，一场纷争在所难免，天龙寺又有何举措呢？"
	
}

local shaoLinStr =
{
	[1] = "禅老家风古少林，",
	[2] = "道场遗迹蔽烟岑。#####",
	[3] = "岁月倥偬，一晃数十载，青丝变白发，新人换旧人。",
	[4] = "自圆方大师继任方丈以来， 一直致力于找回当年少林遗失的”韦陀杵”秘籍，",
	[5] = "为此，圆方大师在此前多次下山寻觅，但都无功而返……#####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。",
	[7] = "当年偷窃少林秘籍之人，正是这”周天功”的修炼者，圆方大师能否完成遗愿？",
	[8] = "这一切都在继续……#####"
}

local gaiBangStr =
{
	[1] = "餐露饮风江湖尽，",
	[2] = "醉看人间烟雨行。#####",
	[3] = "丐帮乃是天下第一大帮，而自前任帮主失踪之后，丐帮一直群龙无首，至今已有数年之久。",
	[4] = "帮主无故失踪，丐帮派出多批人马追查此事，但都无功而返，无奈之下，",
	[5] = "丐帮帮主暂由九袋长老江上流出任，这才稍稍缓解了丐帮的窘迫。 #####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。",
	[7] = "此事莫非与老帮主失踪有什么关联？#####",
	[8] = "而丐帮又将如何应对...#####",
	
}


local xueShanStr =
{
	[1] = "白茫雪山有灵寺，",
	[2] = "绝尘缥缈俗世间。#####",
	[3] = "早在数十年前，密宗与西域喇嘛教合为雪山寺",
	[4] = "这些年来却无传人踏足中原，故此事极少人知，",
	[5] = "而数月之前，雅布陀罗受雪山寺方丈密令赶赴关外，也正在此时，周天功在关外出现的消息不胫而走。#####",
	[6] = "各大门派皆遣派弟子下山一探究竟，而雪山寺亦派出雅布陀罗之师，雪山寺四老之一的夜摩柯下山相助。#####",
	[7] = "江湖之上人人皆欲将此奇功收入囊中，",
	[8] = "而雪山寺也必将成为这其中最有力的竞争者之一。"
}


local wuDuStr =
{
	[1] = "云滇苗地有奇女，",
	[2] = "驾虫育蛊唤万灵。#####",
	[3] = "万灵谷乃是南疆一带的险地，人迹罕至。谷中四季如春，既有奇珍异兽，也不乏凶险毒物，其险美不足为外人道。",
	[4] = "相传，万灵祖师得盘王伊泽，带领众苗人迁移万灵谷内以避战祸，又传下育蛊、驭虫之法使苗人得以自保。是故，万灵谷之人不常过问江湖事，但江湖之上听万灵之名无不色变。",
	[5] = "如今的万灵谷主丁红蝶年仅十六，万灵心经已练至大成，其天赋堪称历代最强。#####",
	[6] = "数月前，江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。",
	[7] = "而万灵谷居然也参与其中，看来江湖又要多生是非了..."
	
}

local tieZhangBangStr =
{
	[1] = "伏龙欲夹太阳飞，",
	[2] = "独柱擎天力弗支。#####",
	[3] = "多年前，江浙一带洪水泛滥，民不聊生。有朝廷士兵落草为寇，在伏龙山安营扎寨，以江湖草莽之名，护江浙百姓安全。",
	[4] = "数十年来，伏龙山背靠天险，肩负美誉，可谓发展迅猛。渐渐的，伏龙山隐约要成为江南第一大帮派，而后继之人，也渐渐地忘记了创立者的初心......",
	[5] = "自海鲸帮出现后，江南再非伏龙山一家独大，这两帮之间摩擦不断，一直争锋相对，情势越演越烈。#####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "伏龙山自然也不甘落于人后，帮主任天南更是想通过此次机会一举铲除海鲸帮，",
	[8] = "不知他能否得偿所愿.."
	
}

local riYueShenJiaoStr =
{
	[1] = "飞瀑正拖千丈雨，",
	[2] = "斜阳先放一峰晴。#####",
	[3] = "自蔺阳昇继任拜日教以来，蔺阳昇大权在手，专断独行，拜日教上下皆怨声载道，教中形式愈发严峻…",
	[4] = "在教中众长老的声讨下，蔺阳昇不仅没有改变作风，反而变本加厉，接连诛杀教中长老，提拔亲信，结党营私，并肆意镇杀正派弟子，与中原武林为敌。#####",
	[5] = "而今江湖传闻，周天功再现于关外，各大门派皆派遣弟子下山一探究竟。",
	[6] = "在这动荡的江湖之中，拜日教又将何去何从呢？#####",
	
}


local mingJiaoStr =
{
	[1] = "日月交替星辰变，",
	[2] = "圣火焚尽天地间。#####",
	[3] = "自上一代明教教主退隐之后，数十年过去，明教迎来了新一任教主-苏伯然，",
	[4] = "此人天赋超绝，以残缺的明教秘典为本，创出属于自己的武学。",
	[5] = "明教如今上下一心，其势甚大，江湖之中少有相抗者。#####",
	[6] = "数月前，江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "而明教也已遣人手下山打探，江湖，愈加地混乱了……#####"
	
}


local muRongShiJiaStr =
{
	[1] = "斗转星移天下奇，",
	[2] = "燕皇世族复国心。#####",
	[3] = "慕容氏乃是燕国皇裔之后，历代慕容子弟无不以复燕为己任，",
	[4] = "龙城本是慕容燕国旧都，自燕国被灭之后，慕容家中无人不想重回龙城旧都。#####",
	[5] = "如今的燕氏皇族的家主，慕容燕，天赋绝伦，风华绝代，年仅二十，已习得燕氏皇族诸般绝学，并带领族人重回龙城。#####",
	[6] = "数月前，江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。",
	[7] = "这一次，他是否在这江湖乱流之中，实现自己的抱负呢？#####"
	
}


local taoHuaDaoStr =
{
	[1] = "花遮柳掩藏奇阵，",
	[2] = "云外仙岛奏玉笛。#####",
	[3] = "传说蓬莱岛乃是世外仙岛，岛上多神仙，但从来就无人得知蓬莱岛的真实下落。直到多年前，落难的江湖侠客俞建州无意中登上仙岛，发现岛上遗落的一本《阴符经》。",
	[4] = "初观经书时，俞建州只道是一本高深莫测的兵书，再观之，方察觉经文通篇隐喻养生之术，更涉猎气功、八卦、天文历法，令人大开眼界。",
	[5] = "俞建州以岛上鱼果为食，孤独一人在岛上钻研《阴符经》经文，终于数十年之后顿悟不世绝学，重返江湖，以蓬莱岛之名收纳门徒。#####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "而蓬莱岛又将以怎样的姿态，出现在众人的眼前呢？"
	
}


local tangMenStr =
{
	[1] = "闲来秋林拾落叶，",
	[2] = "逢敌飞花伴流星。#####",
	[3] = "唐氏一门乃蜀川大族，至今已历九代，",
	[4] = "唐家家主唐不平武功远超先辈，十年前被川蜀各门各派奉为宗师，蜀地之内，声望无人能出其右，",
	[5] = "如今的唐门更是如日中天，远非当年可比。#####",
	[6] = "数月前，江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "唐门，又会在其中扮演怎样的角色呢……",
	
}

local guMuStr =
{
	[1] = "问情三千染青丝，",
	[2] = "飞鸟双剑连理枝。#####",
	[3] = "自从第五代问情宫师祖仙去之后，第六代弟子杨无虑接任问情宫掌门之位，",
	[4] = "由于问情宫剩余门人年纪较轻，一番思量过后，杨无虑决定封宫避世，避免宫中门人，",
	[5] = "在江湖上惹出情仇，仅派寥寥数人在江湖上行走，不过这些亦无人知晓。……#####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "风云际会，问情宫传人又将留下怎样的故事与传奇…"
	
}

local kongTongStr =
{
	[1] = "惊回清风枕簟冷，",
	[2] = "赤霞夹日崆峒山。 #####",
	[3] = "崆峒派成立已有百年之久，但之前一直默默无闻，",
	[4] = "直到数十年前莫血衣接任崆峒派掌门，血战黄风匪，独擒翻江龙，崆峒之名也随之传遍三山五岳。",
	[5] = "这数十年来，崆峒派不断壮大，也正因如此，崆峒与江湖各派的纠纷不断，其势愈演愈烈，恐难善了…#####",
	[6] = "而今江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[7] = "势头正盛的崆峒派亦参与其中，看来这一场江湖浩劫在所难免…#####"
	
}

local haiJingBnagStr =
{
	"游龙灭踪角龙号，",
	"卧伏苍山待云出。#####",
	"自三大门派合力围剿海鲸寨后，海鲸帮元气大伤，帮主余志枭失踪多月，生死不知，",
	"万般无奈之下，海鲸帮余下的七位堂主商议齐聚聚义堂选出新任帮主。#####",
	"商议当日，忽有一队人马杀入聚义堂。仇穆仲身坐轮椅现身，以武力镇压众人惊雷堂堂主齐适昭顺势倒戈，助其夺得了帮主之位。",
	"自此，海鲸帮风云大变。#####",
	"初时，帮内多有不服之人，但随着仇穆仲铁血强治，数位堂主屈膝臣服，海鲸寨上下亦无人再敢发声。#####",
	"如今的海鲸帮，偃旗息鼓，恍若游龙卧伏，伺机而出。不知风云再起时，是否能惊天冲霄，重抗伏龙山? ",
}

local youMingJiaoStr =
{
	[1] = "无常善勾恶人命，",
	[2] = "七宝可避万般劫。#####",
	[3] = "幽冥教于南疆建教，对外人所施手段十分残忍，江湖中皆以为邪教，",
	[4] = "传言幽冥教教主武功奇高，其身法出神入化，形同鬼魅，",
	[5] = "曾与当今的唐家之主唐不平交手三百余合而不落下风，却也不知真假。",
	[6] = "数十年来幽冥教势力日益壮大，已独霸南疆。#####",
	[7] = "数月前，江湖传闻，周天功再现于关外，各大门派皆遣派弟子下山一探究竟。#####",
	[8] = "江湖风云变幻，幽冥教又将如何自居？",
	[9] = {
		[1] = "请选择隐退的地点：",
		[2] = {
			[1] = {"牛家村",
			"牛家村坐落于那那那那那那那那"
			},
			[2] = {"羊家村",
			"牛家村坐落于那那那那那那那那"},
			[3] = {"猪家村",
			"牛家村坐落于那那那那那那那那"},
			[4] = {"马家村",
			"牛家村坐落于那那那那那那那那"},
		}
	}
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 18:20:30
-- @desc 官府文本
local guanFuStr = {
	[1] = "缁衣冷面承天命，",
	[2] = "持刀奉法斩妖邪。#####",
	[3] = "上至朝野权贵，下至武林门派，天下之大，皆逃不开江湖的纷纷扰扰。",
	[4] = "周天功初世之时，朝廷恐江湖势力脱出掌控，遂命千军侯，京诸卫统领陆千侯成立捕风、崇武二卫，将官府势力注入江湖内部。#####",
	[5] = "经过多年发展，官府势力已经渗透每处角落，武林之中任何风吹草动，都在朝廷的掌握之下。",
	[6] = "而今官府活动频繁，是因为周天功再现，还是另有所求？",
	[7] = "天网恢恢，疏而不漏。 #####"
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 10:16:08
-- @desc 落月山庄文本
local luoyueStr =
{
	"泛舟独酌饮江风，",
	"落月剑影绕苏堤。#####",
	"二十年前，大侠萧逸龙以落月剑法独步武林，然其长子游历江湖之时，为拜日教朱雀堂堂主所害。 ",
	"是故萧逸龙与次子夜袭拜日教，火烧朱雀堂，为其报仇雪恨。#####",
	"拜日教主震怒，发出追杀令，尽出精锐高手一路围追堵截，无奈之下，萧逸龙携次子一路辗转至武当，求助三丰真人。",
	"作为正道巨擎，武当无法做视不理，遂与神教达成协议，若萧逸龙能战胜神教三位长老，仇怨便一笔勾销。",
	"岂知神教三位长老联手，亦败在萧逸龙剑下。此事过后，萧逸龙创立落月山庄，天下闻其名者甚众，加入山庄者络绎不绝，其势日益壮大。#####",
	"二十年后，落月山庄坐镇一方，实力超群，而今周天功再度出世。",
	"月出惊山鸟，江湖，愈发动荡了.."
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/07/04 08:05:16
-- @params 
-- @desc 金钱帮文本
local jinqianbangStr = {
	"铁树银花呼作雨，",
	"买君一笑散千金。#####",
	"财神帮渊源数百年，建立者复姓东方，白手从商寥寥数年，便已坐拥良田千亩，家产万贯。",
	"而后他自认商道一路进无可进，愿等武道巅峰，于是以万千财富收拢各地高手，建立财神帮，",
	"江湖与商海一同开拓，江湖人皆称其为“东方财神”。",
	"后历任会首逐渐统一各地商会，开办钱庄、酒楼，并成为皇商，与官府交好。",
	"数十年前，朝廷允许民间买卖田产，上任会首上官林看准商机，开始经营田产生意，并形成垄断。#####",
	"如今，同样擅长经商贸易的重光教进入中原，开始争夺财神帮生意。",
	"上官林之女上官瑶继承父业，率财神帮与之抗衡。",
	"从此，无论是在江湖还是在商会，都有财神帮与重光教明争暗斗的影子。",
}

-----------------------------------------------------------------------------------------------------------
-- @author HanTao
-- @time 2019-07-03 14:43:54
-- @params 
-- @desc 永夜楼文本
local yongyelouStr = {
	"尸横洪都将亡夜，",
	"骨恸青磷永未央。#####",
	"永夜，乃指将亡未死、永无天日之人。",
	"永夜楼传承至今已有百代，每一任楼主都以永夜自称。",
	"数十年前，前任永夜楼主为找寻合适的继位人曾精挑细选收养了十个婴孩，并不惜代价，倾囊相授。#####",
	"以至于这十个婴孩多年后自相残杀，最终只余一人，便是如今的永夜楼主。",
	"说起现任永夜楼主，无人见过其真容，只知是个女子。#####",
	"楼中曾有不少老人不甘臣服，但随着永夜楼日益做大，这些声音也渐渐消失于世......",
	"如今的永夜楼，依旧只是拿钱办事，但若想长盛不衰，尚需搅弄风云，立威江湖。",
}

--天竞门
local tianjingmenStr = {
	"饿殍饥骨说自在，",
	"何妨与天竞自由。#####",
	"天竞二字，只意在“与天竞，与地争。不怨不乞，唯凭自身立世存活”。",
	"天竞门下包容三教九流，是江湖中势力最为驳杂之地。门中弟子身份多样，混迹江湖，多有“同门而不相知”。",
	"且天竞门人向来低调行事，鲜少于江湖显露身份。或是贩夫走卒，或是台中戏子，或是医师术士，凡江湖所在皆有天竞门人。#####",
	"有道是：",
	"酒过寻常处，风流唱华年。宝马青骢少年时，当剑典衣暮色昏。老马虽识途，四海且为家。",
	"自先代门主杨儒光开宗立派，天竞门传承已有六代，如今的天竞门主，乃是戏中名角儿“百花杀”——杨秋白。上至王公贵胄，下至平头百姓，没有谁不知道她的声名。",
	"而在她的统领下，天竞门犹如一条攀伏于巨岩上的大蟒，眠觉知春秋，伺机而待伏......",
}

function TeacherAnimationLayer:initAllDuration()
	for i = 1, 10 do
		self.duration[i] = 0
		self.extra_space[i] = 0
	end
end
-- self.func1 = function ()
-- end
-- self.func2= function ()
-- end
-- self.fucn3= function ()
-- end
-- self.fucn4= function ()
-- end
-- self.sexFunc= function ()
-- 	self.Panel_Button:setVisible(false)
-- 	self:runTheThreeTextAction()
-- end
function TeacherAnimationLayer:showMenPaiStr()
	local duration = 1
	local hideTime = 3
	local sexFunc = function()
		self.Panel_Button:setVisible(false)
		self:runTheThreeTextAction()
	end
	if #self.Panel_item_str > 1 then
		for i = 1, #self.Panel_item_str do
			self:delayFunc(duration *(i - 1) + i + self.duration[i], function()
				self:runActionText(self.Panel_item_str[i], true)
			end)
			----最后一句显示完后，隔开  秒隐藏自己
			if i == #self.Panel_item_str then
				self:delayFunc(duration *(i - 1) + i + self.duration[i] + hideTime, function()
					if self.chuancheng == true then
						self:textFadeIn(self.Panel_Button.Text_6, true, function()
							self:setPanelShow(sexFunc)
						end)
					else
						self.Panel_hide:setVisible(true)
					end
				end)
			end
		end
	else
		if PRINT_MODE == 1 then
			PopText("出错了")
		end
	end
end

-----改变字符串并且设置额外停止的时间和位置
function TeacherAnimationLayer:changeStrAndSetDuration(str)
	self:initAllDuration()
	local extraDuration = 1------在#####的地方额外停止 3 秒的时间
	local addTime = 0
	
	for i = 1, #str do
		if type(str[i]) == "string" then
			if string.find(str[i], "#####") then
				addTime = addTime + extraDuration
				self.extra_space[i + 1] = extraDuration
			end
			self.duration[i + 1] = addTime
			str[i] = string.gsub(str[i], "#####", "")
		end
	end
	return str
end
function TeacherAnimationLayer:textFadeIn(item, anim, func)
	if not item then
		return
	end
	do
		self.Panel_Button:setVisible(true)
		self.Panel_Button.Button_1:setVisible(false)
		self.Panel_Button.Button_2:setVisible(false)
		self.Panel_Button.Button_3:setVisible(false)
		self.Panel_Button.Button_4:setVisible(false)
	end
	item:setVisible(true)
	item:setOpacity(0)
	-- item:setString(text)
	local x, y = item:getPosition()
	local actionTag = item:getActionTagByName("move")
	item:stopActionByTag(actionTag)
	if anim then
		item:move(cc.p(x, y - 30))
		local action = cc.Sequence:create(
		cc.Spawn:create(
		cc.MoveTo:create(0.5, cc.p(x, y)),
		cc.FadeIn:create(0.5)
		),
		cc.CallFunc:create(
		function()
			if func then
				self:delayFunc(1, function()
					func()
				end)
			end
		end))
		action:setTag(actionTag)
		item:runAction(action)
	else
		item:move(cc.p(0, 0))
		item:resumeSelfAndChildren()
	end
end

--创建文本ExtRichTextScroll 存入self.Panel_item_str中返回,要先执行这个，延时在显示出来这个界面
function TeacherAnimationLayer:createTextFromArray(text, isChuanCheng, distance)
	if isChuanCheng ~= nil then
		self.chuancheng = true
	end
	self.Panel_item_str = {}
	local viewsize = cc.Director:getInstance():getWinSize()
	
	-------防止描述一样，string,gsub会改变原来的字符串
	local textsClone = clone(text)
	textsClone = self:changeStrAndSetDuration(textsClone)
	
	
	local fontSize = 48  --字体大小
	if distance == nil then
		distance = 150 ----距离上边界的距离
	end
	local spaceDistance = 5 ---间隔距离
	local extraSpace = 60  --一大段额外曾加的间距
	local scrollWidth = 850   ----scroll的宽度
	
	local heightCount = 0 ----记录所有panel的高度
	local height = 0  -- 当个panel的高度
	for i = 1, #textsClone do
		-----传承需要创建button
		if type(textsClone[i]) == "string" then
			local Text = ExtRichTextScroll:create()
			local richText = Text:getRichText()
			self.Panel_back:addChild(Text)
			
			Text:setSize(cc.size(scrollWidth, 60))
			Text:setDirection(kCCScrollViewDirectionVertical)
			
			richText:setVerticalSpace(spaceDistance)
			Text:setAnchorPoint(0.5, 1)
			
			--随机提取文本
			local textColor = cc.c3b(190, 170, 130)--cc.c3b(208, 208, 208)
			
			Text:pushBackText(textsClone[i], textColor, 255, Resource:getFontPath("default"), fontSize)
			
			--设置透明度为0
			Text:setSelfAndChildrenCascadeOpacityEnabled(true)
			Text:setOpacity(0)
			Text:setBounceEnabled(false)
			
			self.Panel_item_str[#self.Panel_item_str + 1] = Text
			
			self:delayFunc(1, function()
				heightCount = heightCount + height
				height = richText:getNewContentSizeHeight()
				Text:setSize(cc.size(scrollWidth, height))
				
				----再一大段停止一秒并且间距增加60
				if self.extra_space[i] ~= 0 then
					heightCount = heightCount + extraSpace
				end
				self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
				Text:setPosition(self.theLastPosition)
			end)
			----传承的Buttonde 创建
		else
			self:delayFunc(1.5, function()
				local panel = self.Panel_Button
				Helper:convertUIByParent(panel)
				panel:setVisible(false)
				-- self.Panel_back:addChild(panel)
				----创建文本
				panel.Text_6:setString(textsClone[i] [1])
				panel.Button_1.Text_name:setString(textsClone[i] [2] [1] [1])
				panel.Button_2.Text_name:setString(textsClone[i] [2] [2] [1])
				panel.Button_3.Text_name:setString(textsClone[i] [2] [3] [1])
				panel.Button_4.Text_name:setString(textsClone[i] [2] [4] [1])
				self.button1Func = textsClone[i] [2] [1].clickFunc
				self.button2Func = textsClone[i] [2] [2].clickFunc
				self.button3Func = textsClone[i] [2] [3].clickFunc
				self.button4Func = textsClone[i] [2] [4].clickFunc
				panel:setPosition(self.theLastPosition.x, self.theLastPosition.y - 80)
				
				self.Text_last1:setString("可惜江湖上又少了一位大侠，")
				self.Text_last1:setPosition(self.theLastPosition.x - 112, self.theLastPosition.y - 100)
				self.Text_last2:setString("同时江湖又多了一名少侠。")
				self.Text_last2:setPosition(self.theLastPosition.x - 135, self.theLastPosition.y - 200)
				self.Panel_item_str_ChuanCheng[#self.Panel_item_str_ChuanCheng + 1] = self.Text_last1
				self.Panel_item_str_ChuanCheng[#self.Panel_item_str_ChuanCheng + 1] = self.Text_last2
				self.Panel_item_str_ChuanCheng[#self.Panel_item_str_ChuanCheng + 1] = self.Text_name_position
				
			end)
			
		end
		
	end
end
function TeacherAnimationLayer:setButton(name, func)
	if not name then
		return
	end
	self.Panel_Button[name]:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self.Text_name_position:setString(self.Panel_Button[name].Text_name:getString())
		self.Text_name_position:setPosition(770, self.theLastPosition.y - 5)
		if func then
			func()
		end
	end)
end
function TeacherAnimationLayer:runTheThreeTextAction()
	local duration = 1.5
	self:delayFunc(duration, function()
		self:runActionText(self.Text_name_position, true)
		self:delayFunc(duration, function()
			self:runActionText(self.Text_last1, true)
			self:delayFunc(duration, function()
				self:runActionText(self.Text_last2, true)
				self:delayFunc(1, function()
					self.Panel_hide:setVisible(true)
				end)
			end)
		end)
	end)
end
function TeacherAnimationLayer:setButton1(func)
	self:setButton("Button_1", function()
		if self.button1Func then
			self.button1Func()
		end
		func()
	end)
end

function TeacherAnimationLayer:setButton2(func)
	self:setButton("Button_2", function()
		if self.button2Func then
			self.button2Func()
		end
		func()
	end)
end

function TeacherAnimationLayer:setButton3(func)
	self:setButton("Button_3", function()
		if self.button3Func then
			self.button3Func()
		end
		func()
	end)
end

function TeacherAnimationLayer:setButton4(func)
	self:setButton("Button_4", function()
		if self.button4Func then
			self.button4Func()
		end
		func()
	end)
end

function TeacherAnimationLayer:setPanelShow(sexFunc)
	self.Panel_Button:setVisible(true)
	self.Panel_Button.Button_1:setVisible(true)
	self.Panel_Button.Button_2:setVisible(true)
	self.Panel_Button.Button_3:setVisible(true)
	self.Panel_Button.Button_4:setVisible(true)
	self:setButton1(sexFunc)
	self:setButton2(sexFunc)
	self:setButton3(sexFunc)
	self:setButton4(sexFunc)
end

function TeacherAnimationLayer:runActionText(Panel_item, anim)
	if not Panel_item then
		return
	end
	-----设置屏幕中间
	Panel_item:setVisible(true)
	Panel_item:setOpacity(0)
	
	local x, y = Panel_item:getPosition()
	local actionTag = Panel_item:getActionTagByName("move")
	Panel_item:stopActionByTag(actionTag)
	
	
	local Point = cc.p(Panel_item:getPosition())
	local Duration = 0.5
	
	if anim then
		Panel_item:move(cc.p(x, y - 30))
		local action =
		cc.Spawn:create(
		cc.MoveTo:create(Duration, cc.p(x, y)),
		cc.FadeIn:create(Duration)
		)
		action:setTag(actionTag)
		Panel_item:runAction(action)
	else
		Panel_item:move(cc.p(0, 0))
		Panel_item:resumeSelfAndChildren()
	end
end

------根据门派获取对应的门派描述
function TeacherAnimationLayer:getMenPaiStr(chineseStr)
	if type(chineseStr) ~= "string" then
		return nil
	end
	if chineseStr == "武当派" then
		return wuDangStr
	elseif chineseStr == "峨眉派" then
		return eMeiStr
	elseif chineseStr == "华山" then
		return huaShanStr
	elseif chineseStr == "昆仑派" then
		return kunLunStr
	elseif chineseStr == "天狼教" then
		return xinXiuStr
	elseif chineseStr == "白驼山庄" or chineseStr == "鸩羽山" then
		return baiTuoShanStr
	elseif chineseStr == "虚渺宫" then
		return tianShanStr
	elseif chineseStr == "全真教" then
		return quanZhenJiaoStr
	elseif chineseStr == "天龙寺" then
		return tianLongShiStr
	elseif chineseStr == "少林派" then
		return shaoLinStr
	elseif chineseStr == "丐帮" then
		return gaiBangStr
	elseif chineseStr == "雪山寺" then
		return xueShanStr
	elseif chineseStr == "万灵谷" then
		return wuDuStr
	elseif chineseStr == "伏龙山" then
		return tieZhangBangStr
	elseif chineseStr == "拜日教" then
		return riYueShenJiaoStr
	elseif chineseStr == "明教" then
		return mingJiaoStr
	elseif chineseStr == "燕氏皇族" or chineseStr == "慕容山庄" then
		return muRongShiJiaStr
	elseif chineseStr == "蓬莱岛" then
		return taoHuaDaoStr
	elseif chineseStr == "唐门" then
		return tangMenStr
	elseif chineseStr == "问情宫" then
		return guMuStr
	elseif chineseStr == "崆峒派" then
		return kongTongStr
	elseif chineseStr == "海鲸帮" then
		return haiJingBnagStr
	elseif chineseStr == "幽冥教" then
		return youMingJiaoStr
	elseif chineseStr == "官府" then
		return guanFuStr
	elseif chineseStr == "落月山庄" then
		return luoyueStr
	elseif chineseStr == "财神帮" then
		return jinqianbangStr
	elseif chineseStr == "永夜楼" then
		return yongyelouStr
	elseif chineseStr == "天竞门" then
		return tianjingmenStr
	else
		return nil
	end
end

---一个一个文字的显示出来---------------------------------------------------------------------------------一个一个文字的显示出来----------------------------------------------------------------------
function TeacherAnimationLayer:createOneText()
	local fontSize = 48
	local Text = ccui.Text:create()
	Text:setFontName("Font/default.ttf")
	Text:setFontSize(fontSize)
	Text:setString("")
	Text:enableOutline({r = 26, g = 26, b = 26, a = 255}, 5)
	Text:setTextColor({r = 190, g = 170, b = 130})
	Text:setAnchorPoint(1, 0.5)
	Text:setOpacity(0)
	self:addChild(Text)
	
	return Text
	
end

--用字符串，求出长度n，然后创建n个text控件。保存到数组
function TeacherAnimationLayer:createTextsWithString(str)
	local Texts_str = {}  ----保存创建的一个一个text
	local str2 = string.splitUTF8(str)
	
	for i, v in ipairs(str2) do
		local Text = self:createOneText()
		Text:setString(v)
		Texts_str[#Texts_str + 1] = Text
	end
	
	return Texts_str
end
----用数组里的text控件创建动画
function TeacherAnimationLayer:crateActionByTexts(str, position)
	local Texts_str = self:createTextsWithString(tostring(str))
	local count = #Texts_str
	local viewsize = cc.Director:getInstance():getWinSize()
	local fontSizeX = 48  ---字体的大小
	local fontSizeY = 60 ---字体的高度
	local spaceDistance = 30 ----上下两行的间距
	local duration = 0
	local DurationFideIn = 2  --淡入的时间
	local positionX = 0 ------单个text的横坐标
	local positionY = 0
	
	if not position then
		positionY = viewsize.height / 2
	else
		positionY = position
	end
	
	---设置位置，锚点是（1,0）
	for i = 1, count do
		local size = Texts_str[i]:getContentSize()
		positionX = fontSizeX * i ---记录横坐标位置
		-----如果在一行的最右边，换下一行
		local positionYY = positionY
		if positionX > viewsize.width - fontSizeX / 2 then
			local mark = math.floor(positionX / viewsize.width)
			positionYY = positionY -(fontSizeY + spaceDistance) * mark
			positionX = positionX % viewsize.width + fontSizeX / 2
			if PRINT_MODE == 1 then
				print("``````````````````")
				print("positionY =" .. positionYY .. "        positionX = " .. positionX .. "         mark =" .. mark)
			end
		end
		Texts_str[i]:setPosition(positionX, positionYY)
		Texts_str[i]:setVisible(false)
	end
	--淡入动画
	for i = 1, count do
		self:delayFunc(duration *(i - 1) + i, function()
			Texts_str[i]:setVisible(true)
			Texts_str[i]:runAction(
			cc.Sequence:create(
			cc.FadeIn:create(DurationFideIn)
			)
			)
		end)
	end
end
-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2017/06/14 17:17:14
-- @desc 添加一个退出回调
function TeacherAnimationLayer:setHideWithCallFunc(func)
	if func then
		self._callFunc = func
	end
end
--创建等间距文本
function TeacherAnimationLayer:createTextFromArrayWithIntervalDistance(text, dis)
	local isChuanCheng, distance
	if isChuanCheng ~= nil then
		self.chuancheng = true
	end
	self.Panel_item_str = {}
	local viewsize = cc.Director:getInstance():getWinSize()
	
	-------防止描述一样，string,gsub会改变原来的字符串
	local textsClone = clone(text)
	textsClone = self:changeStrAndSetDuration(textsClone)
	
	
	local fontSize = 48  --字体大小
	if distance == nil then
		distance = 150 ----距离上边界的距离
	end
	local spaceDistance = 5 ---间隔距离
	local extraSpace = 60  --一大段额外曾加的间距
	local scrollWidth = Helper:getDef(dis, 850)   ----scroll的宽度
	
	local heightCount = 0 ----记录所有panel的高度
	local height = 0  -- 当个panel的高度
	for i = 1, #textsClone do
		-----传承需要创建button
		if type(textsClone[i]) == "string" then
			local Text = ExtRichTextScroll:create()
			local richText = Text:getRichText()
			self.Panel_back:addChild(Text)
			
			Text:setSize(cc.size(scrollWidth, 60))
			Text:setDirection(kCCScrollViewDirectionVertical)
			
			-- richText:setVerticalSpace(spaceDistance)
			Text:setAnchorPoint(0.5, 1)
			
			--随机提取文本
			local textColor = cc.c3b(190, 170, 130)--cc.c3b(208, 208, 208)
			
			Text:pushBackText(textsClone[i], textColor, 255, Resource:getFontPath("default"), fontSize)
			
			--设置透明度为0
			Text:setSelfAndChildrenCascadeOpacityEnabled(true)
			Text:setOpacity(0)
			Text:setBounceEnabled(false)
			
			self.Panel_item_str[#self.Panel_item_str + 1] = Text
			
			self:delayFunc(1, function()
				heightCount = heightCount + height
				height = richText:getNewContentSizeHeight()
				Text:setSize(cc.size(scrollWidth, height))
				
				----再一大段停止一秒并且间距增加60
				-- if self.extra_space[i] ~= 0 then
				-- 	heightCount = heightCount +  extraSpace
				-- end
				--调整文本位置
				local posY = viewsize.height - distance - heightCount -(i - 1) * 15
				if i == 2 then
					posY = posY - 80
				elseif i > 2 then
					posY = posY - 100
				end
				if i >= 4 then
					posY = posY - 20 *(i - 3)
				end
				self.theLastPosition = cc.p(viewsize.width / 2, posY)
				Text:setPosition(self.theLastPosition)
			end)
		end
		
	end
end

local smHeight, lgHeight = 20, - 30
if device.platform == "android" then
	smHeight, lgHeight = 45, - 185
elseif Game:getChannelId() == "fzjh" then
	if device.platform == "ios" then
		-- smHeight, lgHeight = -40, -10
	end
else
	-- smHeight, lgHeight = -40, -10
end

-- add by XiaoZhiWei 2017/08/25 19:27:27 七夕专用 文本动画
function TeacherAnimationLayer:createTextFromArrayForQiXi(text, isChuanCheng, distance)
	if isChuanCheng ~= nil then
		self.chuancheng = true
	end
	self.Panel_item_str = {}
	local viewsize = cc.Director:getInstance():getWinSize()
	
	-------防止描述一样，string,gsub会改变原来的字符串
	local textsClone = clone(text)
	textsClone = self:changeStrAndSetDuration(textsClone)
	
	local TextList = {}
	local extraHeight = {}
	
	local fontSize = 48  --字体大小
	if distance == nil then
		distance = 150 ----距离上边界的距离
	end
	local spaceDistance = 5 ---间隔距离
	local extraSpace = 30  --一大段额外曾加的间距
	local scrollWidth = 850   ----scroll的宽度
	
	local heightCount = 0 ----记录所有panel的高度
	local height = 0  -- 当个panel的高度
	for i = 1, #textsClone do
		-----传承需要创建button
		if type(textsClone[i]) == "string" then
			local Text = ExtRichTextScroll:create()
			local richText = Text:getRichText()
			self.Panel_back:addChild(Text)
			
			Text:setSize(cc.size(scrollWidth, 60))
			Text:setDirection(kCCScrollViewDirectionVertical)
			
			-- richText:setVerticalSpace(spaceDistance)
			Text:setAnchorPoint(0.5, 1)
			
			--随机提取文本
			local textColor = cc.c3b(190, 170, 130)--cc.c3b(208, 208, 208)
			
			local str = textsClone[i]
			str = string.gsub(str, "#aaaa", "")
			
			Text:pushBackText(str, textColor, 255, Resource:getFontPath("default"), fontSize)
			
			--设置透明度为0
			Text:setSelfAndChildrenCascadeOpacityEnabled(true)
			Text:setOpacity(0)
			Text:setBounceEnabled(false)
			Text:setTouchEnabled(false)
			TextList[i] = Text
			
			if i <= 5 then
				local action = cc.Sequence:create(cc.FadeIn:create(2))
				Text:runAction(action)
			else
				self:delayFunc(i - 3, function()
					self:runActionText(Text, true)
					if i == #textsClone then
						self.Panel_hide:setVisible(true)
						self:setHideWithCallFunc(function()
							for j = 1, #TextList do
								local duration = 1
								local action =
								cc.Sequence:create(
								cc.FadeOut:create(duration)
								)
								local action1 =
								cc.Sequence:create(
								cc.FadeOut:create(duration),
								cc.CallFunc:create(function()
									self:setVisible(false)
									self.Panel_back:setVisible(false)
									self:initActionData()
								end)
								)
								if j < #TextList then
									TextList[j]:runAction(action)
								else
									TextList[j]:runAction(action1)
								end
							end
						end)
					end
				end)
			end
			
			if string.find(textsClone[i], "#aaaa") ~= nil then
				self:delayFunc(1, function()
					heightCount = heightCount + height + smHeight
					height = richText:getNewContentSizeHeight()
					Text:setSize(cc.size(scrollWidth, height))
					
					self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
					Text:setPosition(self.theLastPosition)
				end)
			else
				self:delayFunc(1, function()
					if textsClone[i] == " " then
						heightCount = heightCount + height + lgHeight
					else
						heightCount = heightCount + height
					end
					
					height = richText:getNewContentSizeHeight()
					Text:setSize(cc.size(scrollWidth, height))
					self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
					Text:setPosition(self.theLastPosition)
				end)
			end
		else
		end
	end
end

-- add by XiaoZhiWei 2017/08/25 19:27:27 七夕专用 文本动画
function TeacherAnimationLayer:createTextFromArrayForQiXi1(text, distance)
	self.Panel_item_str = {}
	local viewsize = cc.Director:getInstance():getWinSize()
	
	-------防止描述一样，string,gsub会改变原来的字符串
	local textsClone = clone(text)
	textsClone = self:changeStrAndSetDuration(textsClone)
	
	
	local fontSize = 48  --字体大小
	if distance == nil then
		distance = 150 ----距离上边界的距离
	end
	local spaceDistance = 5 ---间隔距离
	local extraSpace = 60  --一大段额外曾加的间距
	local scrollWidth = 850   ----scroll的宽度
	
	local heightCount = 0 ----记录所有panel的高度
	local height = 0  -- 当个panel的高度
	for i = 1, #textsClone do
		-----传承需要创建button
		if type(textsClone[i]) == "string" then
			local Text = ExtRichTextScroll:create()
			local richText = Text:getRichText()
			self.Panel_back:addChild(Text)
			
			Text:setSize(cc.size(scrollWidth, 60))
			Text:setDirection(kCCScrollViewDirectionVertical)
			
			richText:setVerticalSpace(spaceDistance)
			Text:setAnchorPoint(0.5, 1)
			
			--随机提取文本
			local textColor = cc.c3b(190, 170, 130)--cc.c3b(208, 208, 208)
			
			local str = textsClone[i]
			str = string.gsub(str, "#aaaa", "")
			
			Text:pushBackText(str, textColor, 255, Resource:getFontPath("default"), fontSize)
			
			--设置透明度为0
			Text:setSelfAndChildrenCascadeOpacityEnabled(true)
			Text:setOpacity(0)
			Text:setBounceEnabled(false)
			
			self.Panel_item_str[#self.Panel_item_str + 1] = Text
			
			if string.find(textsClone[i], "#aaaa") ~= nil then
				self:delayFunc(1, function()
					heightCount = heightCount + height + smHeight + 10
					height = richText:getNewContentSizeHeight()
					Text:setSize(cc.size(scrollWidth, height))
					
					self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
					Text:setPosition(self.theLastPosition)
				end)
			else
				self:delayFunc(1, function()
					if textsClone[i] == " " then
						heightCount = heightCount + height + lgHeight
					else
						heightCount = heightCount + height
					end
					
					height = richText:getNewContentSizeHeight()
					Text:setSize(cc.size(scrollWidth, height))
					self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
					Text:setPosition(self.theLastPosition)
				end)
			end
		else
		end
	end
end


local function calDisplacement(currText, preText)
	local currX, currY = currText:getPosition()
	local currHeight = currText:getContentSize().height
	print("------------------- % currText Pos : " .. currX .. "," .. currY .. " ; Height : " .. currHeight)
	
	local currBottom = currY - currHeight
	
	local preX, preY = preText:getPosition()
	local preHeight = preText:getContentSize().height
	
	local preBottomPos = preY - preHeight
	print("------------------- % preText Pos : " .. preX .. "," .. preY .. " ; Height : " .. preHeight)
	print("------------------- % currBottom : " .. currBottom .. " ; preBottomPos : " .. preBottomPos)
	
	local displacement = preBottomPos - currBottom
	return displacement
end

function TeacherAnimationLayer:createTextFromArrayForMidAutumn(text, func,musicName, distance)
	if Game:getPackageId() == "fzjh" then
		self:initWithText(text, func,musicName, distance)
	else
		self:initWithRichText(text, func,musicName, distance)
	end
	
	self.Panel_hide:releaseFunc(function()
		if DEBUG_MODE == 1 then
			PopText("点击背景")
		end
		self:pauseSelfAndChildren()
		local that = self
		local Dialog = require("app.views.layer.DialogLayer.DialogALayer")
		--@RefType [app.views.layer.DialogLayer.DialogALayer#DialogALayer]
		local dialog = Dialog:getInstance()
		dialog:show("你要取消听戏么？\n(今日将不可再听这场戏)")
		dialog:setBack(false)
		dialog:setButton1("确定", function()
			self:setVisible(false)
			func()
		end)
		dialog:setWeChatVisible(false)
		dialog:setButton2("取消", function()
			self:resumeSelfAndChildren()
		end)
		
	end)
end

-- add by XiaoZhiWei 2018/02/10 20:37:19 富文本框
function TeacherAnimationLayer:initWithRichText(text, func,musicName, distance)
	local viewsize = cc.Director:getInstance():getWinSize()
	
	if musicName then
		Audio:playMusic(musicName,true)
	end

	-------防止描述一样，string,gsub会改变原来的字符串
	local textsClone = clone(text)
	textsClone = self:changeStrAndSetDuration(textsClone)
	self.theLastPosition = cc.p(viewsize.width / 2, 1920)
	
	local TextList = {}
	local duration = 1.5
	
	local fontSize = 48  --字体大小
	if distance == nil then
		distance = 150 ----距离上边界的距离
	end
	
	local smHeight1, lgHeight1, nextPage = smHeight + 10, smHeight + 40, 200
	if device.platform == "android" then
		smHeight1, lgHeight1, distance, nextPage = smHeight1 + 10 - 60, lgHeight1 + 40 - 5, 100, 400
	end
	local spaceDistance = 30 ---间隔距离
	local extraSpace = 15  --一大段额外曾加的间距
	local scrollWidth = 850   ----scroll的宽度
	
	local heightCount = 0 ----记录所有panel的高度
	local height = 0  -- 单个panel的高度
	for i = 1, #textsClone do
		if type(textsClone[i]) == "string" then
			local Text = ExtRichTextScroll:create()
			local richText = Text:getRichText()
			self.Panel_back:addChild(Text)
			
			Text:setSize(cc.size(scrollWidth, 60))
			Text:setDirection(kCCScrollViewDirectionVertical)
			
			richText:setVerticalSpace(spaceDistance)
			Text:setAnchorPoint(0.5, 1)
			
			--随机提取文本
			local textColor = cc.c3b(190, 170, 130)--cc.c3b(208, 208, 208)
			
			local str = textsClone[i]
			str = string.gsub(str, "#aaaa", "")
			str = string.gsub(str, "#AAAA", "")
			
			Text:pushBackText(str, textColor, 255, Resource:getFontPath("default"), fontSize)
			
			--设置透明度为0
			Text:setSelfAndChildrenCascadeOpacityEnabled(true)
			Text:setOpacity(0)
			Text:setBounceEnabled(false)
			
			TextList[i] = Text
			
			self:delayFunc(duration *(i - 1) + i, function()
				self.Panel_hide:setVisible(true)
				-- for _, v in ipairs(self._currRow) do
				-- 	if v == i then
				-- 		for j = 1, v - 1 do
				-- 			TextList[j]:setVisible(false)
				-- 		end
				-- 	end
				-- end
				if i >= self._currRow and self._currRow ~= 0 then
					local displacement = calDisplacement(TextList[i], TextList[i - 1])
					for j = 1, i - 1 do
						local x, y = TextList[j]:getPosition()
						local action = cc.MoveTo:create(0.3, cc.p(x, y + displacement))
						print("------------------- % [" .. j .. "] :" .. x .. " , " .. y .. " % -----------------------------")
						TextList[j]:runAction(action)
					end
					
					self:delayFunc(0.3, function()
						self:runActionText(Text, true)
					end)
					
					for z = i, #TextList do
						local currPosX, currPosY = TextList[z]:getPosition()
						print("------------------- % currPos % -----------------------------")
						print("------------------- % Y: " .. currPosY .. " % -----------------------------")
						TextList[z]:setPosition(cc.p(currPosX, currPosY + displacement))
					end
				else
					self:runActionText(Text, true)
				end
				
				if i == #textsClone then
					self.Panel_hide:releaseFunc(function()
						self.Panel_hide:setVisible(false)
						self:hide()
					end)
					self:setHideWithCallFunc(function()
						for j = 1, #TextList do
							local duration = 1
							local action =
							cc.Sequence:create(
							cc.FadeOut:create(duration)
							)
							local action1 =
							cc.Sequence:create(
							cc.FadeOut:create(duration),
							cc.CallFunc:create(function()
								self:setVisible(false)
								self.Panel_back:setVisible(false)
								self:initActionData()
							end)
							)
							if j < #TextList then
								TextList[j]:runAction(action)
							else
								TextList[j]:runAction(action1)
							end
						end
					end)
				end
			end)
			
			
			if string.find(textsClone[i], "#aaaa") ~= nil then
				self:delayFunc(0.5, function()
					if self.theLastPosition.y < nextPage and self._currRow == 0 then
						self._currRow = i
					end
					-- heightCount = heightCount + height + smHeight + 10
					heightCount = heightCount + height + smHeight1
					
					height = richText:getNewContentSizeHeight()
					Text:setSize(cc.size(scrollWidth, height))
					
					self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
					Text:setPosition(self.theLastPosition)
					if DEBUG_MODE == 1 then
						print("------------------- % theLastPosition [" .. i .. "]：" .. self.theLastPosition.y .. " % -----------------------------")
						print("--- % heightCount [" .. i .. "]：" .. heightCount .. " % ---")
						print("--- % height [" .. i .. "]：" .. height .. " % ---")
						print("--- % lgHeight [" .. i .. "]：" .. lgHeight .. " % ---")
						print("--- % distance [" .. i .. "]：" .. distance .. " % ---")
						print("--- % viewsize.height [" .. i .. "]：" .. viewsize.height .. " % ---")
						print("--------- Text . isvisible = ", Text:isVisible(), Text:getOpacity())
						Helper:print_lua_table(Text:getAnchorPoint())
					end
				end)
			elseif string.find(textsClone[i], "#AAAA") ~= nil then
				self:delayFunc(0.5, function()
					if self.theLastPosition.y < nextPage and self._currRow == 0 then
						self._currRow = i
					end
					-- heightCount = heightCount + height + smHeight + 40
					heightCount = heightCount + height + lgHeight1
					height = richText:getNewContentSizeHeight()
					Text:setSize(cc.size(scrollWidth, height))
					
					self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
					Text:setPosition(self.theLastPosition)
					if DEBUG_MODE == 1 then
						print("------------------- % theLastPosition [" .. i .. "]：" .. self.theLastPosition.y .. " % -----------------------------")
						print("--- % heightCount [" .. i .. "]：" .. heightCount .. " % ---")
						print("--- % height [" .. i .. "]：" .. height .. " % ---")
						print("--- % lgHeight [" .. i .. "]：" .. lgHeight .. " % ---")
						print("--- % distance [" .. i .. "]：" .. distance .. " % ---")
						print("--- % viewsize.height [" .. i .. "]：" .. viewsize.height .. " % ---")
					end	
				end)
				
			else
				self:delayFunc(0.5, function()
					-- if textsClone[i] == " " then
					-- 	heightCount = heightCount + height + lgHeight
					-- else
					heightCount = heightCount + height
					-- end
					
					height = richText:getNewContentSizeHeight()
					Text:setSize(cc.size(scrollWidth, height))
					self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
					Text:setPosition(self.theLastPosition)
					if DEBUG_MODE == 1 then
						print("------------------- % theLastPosition [" .. i .. "]：" .. self.theLastPosition.y .. " % -----------------------------")
						print("--- % heightCount [" .. i .. "]：" .. heightCount .. " % ---")
						print("--- % height [" .. i .. "]：" .. height .. " % ---")
						print("--- % lgHeight [" .. i .. "]：" .. lgHeight .. " % ---")
						print("--- % distance [" .. i .. "]：" .. distance .. " % ---")
						print("--- % viewsize.height [" .. i .. "]：" .. viewsize.height .. " % ---")
						Helper:print_lua_table(Text:getAnchorPoint())
					end
				end)
			end
		else
		end
	end
end

function TeacherAnimationLayer:crateTextFromArrayForMoveHouse(text, func,musicName, distance)
	if Game:getPackageId() == "fzjh" then
		self:initWithText(text, func,musicName, distance)
	else
		self:initWithRichText(text, func,musicName, distance)
	end
end

-- add by XiaoZhiWei 2018/02/10 20:37:19 富文本框
function TeacherAnimationLayer:initWithText(text, func,musicName, distance)
	local viewsize = cc.Director:getInstance():getWinSize()
	
	if musicName then
		Audio:playMusic(musicName,true)
	end

	-------防止描述一样，string,gsub会改变原来的字符串
	local textsClone = clone(text)
	textsClone = self:changeStrAndSetDuration(textsClone)
	self.theLastPosition = cc.p(viewsize.width / 2, 1920)
	
	local TextList = {}
	local duration = 1.5
	
	local fontSize = 48  --字体大小
	if distance == nil then
		distance = 150 ----距离上边界的距离
	end
	
	local smHeight1, lgHeight1, nextPage = smHeight + 10, smHeight + 40, 200
	if device.platform == "android" then
		smHeight1, lgHeight1, distance, nextPage = smHeight1 + 10 - 60, lgHeight1 + 40 - 5, 100, 400
	end

	if Game:getChannelId() == "ios" then
		smHeight1, lgHeight1, nextPage = smHeight + 50, smHeight + 90, 200
	end

	local spaceDistance = 30 ---间隔距离
	local extraSpace = 15  --一大段额外曾加的间距
	local scrollWidth = 850   ----scroll的宽度
	
	local heightCount = 0 ----记录所有panel的高度
	local height = 0  -- 单个panel的高度
	for i = 1, #textsClone do
		if type(textsClone[i]) == "string" then
			local Text = ccui.Text:create()
			self.Panel_back:addChild(Text)
			
			local str = textsClone[i]
			str = string.gsub(str, "#aaaa", "")
			str = string.gsub(str, "#AAAA", "")
			
			local testHeight = math.ceil(string.len(str) / (17 * 3)) * 60

			Text:setSize(cc.size(scrollWidth, testHeight))
			Text:setTextAreaSize(cc.size(scrollWidth, testHeight))
			Text:setAnchorPoint(0.5, 1)
			
			--随机提取文本
			local textColor = cc.c3b(190, 170, 130)--cc.c3b(208, 208, 208)
			
			Text:setString(str)
			Text:setTextColor(textColor)
			--设置透明度为0
			Text:setSelfAndChildrenCascadeOpacityEnabled(true)
			Text:setOpacity(0)
			Text:setFontSize(fontSize)
			Text:setFontName(Resource:getFontPath("default"))
			Text:setLayoutComponentEnabled(true)
			Text:setTextHorizontalAlignment(0)
			
			TextList[i] = Text
			
			self:delayFunc(duration *(i - 1) + i, function()
				self.Panel_hide:setVisible(true)
				if i >= self._currRow and self._currRow ~= 0 then
					local displacement = calDisplacement(TextList[i], TextList[i - 1])
					for j = 1, i - 1 do
						local x, y = TextList[j]:getPosition()
						local action = cc.MoveTo:create(0.3, cc.p(x, y + displacement))
						print("------------------- % [" .. j .. "] :" .. x .. " , " .. y .. " % -----------------------------")
						TextList[j]:runAction(action)
					end
					
					self:delayFunc(0.3, function()
						self:runActionText(Text, true)
					end)
					
					for z = i, #TextList do
						local currPosX, currPosY = TextList[z]:getPosition()
						print("------------------- % currPos % -----------------------------")
						print("------------------- % Y: " .. currPosY .. " % -----------------------------")
						TextList[z]:setPosition(cc.p(currPosX, currPosY + displacement))
					end
				else
					self:runActionText(Text, true)
				end
				
				if i == #textsClone then
					self.Panel_hide:releaseFunc(function()
						self.Panel_hide:setVisible(false)
						self:hide()
					end)
					self:setHideWithCallFunc(function()
						for j = 1, #TextList do
							local duration = 1
							local action =
							cc.Sequence:create(
							cc.FadeOut:create(duration)
							)
							local action1 =
							cc.Sequence:create(
							cc.FadeOut:create(duration),
							cc.CallFunc:create(function()
								self:setVisible(false)
								self.Panel_back:setVisible(false)
								self:initActionData()
							end)
							)
							if j < #TextList then
								TextList[j]:runAction(action)
							else
								TextList[j]:runAction(action1)
							end
						end
					end)
				end
			end)
			
			if string.find(textsClone[i], "#aaaa") ~= nil then
				if self.theLastPosition.y < nextPage and self._currRow == 0 then
					self._currRow = i
				end
				heightCount = heightCount + height + smHeight1
				height = Text:getSize().height
				
				self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
				Text:setPosition(self.theLastPosition)
				if DEBUG_MODE == 1 then
					print("Text: = ", Text:getPositionY())
					print("------------------- % theLastPosition [" .. i .. "]：" .. self.theLastPosition.y .. " % -----------------------------")
					print("--- % heightCount [" .. i .. "]：" .. heightCount .. " % ---")
					print("--- % height [" .. i .. "]：" .. height .. " % ---")
					print("--- % lgHeight [" .. i .. "]：" .. lgHeight .. " % ---")
					print("--- % distance [" .. i .. "]：" .. distance .. " % ---")
					print("--- % viewsize.height [" .. i .. "]：" .. viewsize.height .. " % ---")
					print("--------- Text . isvisible = ", Text:isVisible(), Text:getOpacity())
					Helper:print_lua_table(Text:getAnchorPoint())
				end
			elseif string.find(textsClone[i], "#AAAA") ~= nil then
				if self.theLastPosition.y < nextPage and self._currRow == 0 then
					self._currRow = i
				end
				-- heightCount = heightCount + height + smHeight + 40
				heightCount = heightCount + height + lgHeight1
				-- height = richText:getNewContentSizeHeight()
				height = Text:getSize().height
				-- Text:setSize(cc.size(scrollWidth, height))
				
				self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
				Text:setPosition(self.theLastPosition)
				if DEBUG_MODE == 1 then
					print("Text: = ", Text:getPositionY())
					print("------------------- % theLastPosition [" .. i .. "]：" .. self.theLastPosition.y .. " % -----------------------------")
					print("--- % heightCount [" .. i .. "]：" .. heightCount .. " % ---")
					print("--- % height [" .. i .. "]：" .. height .. " % ---")
					print("--- % lgHeight [" .. i .. "]：" .. lgHeight .. " % ---")
					print("--- % distance [" .. i .. "]：" .. distance .. " % ---")
					print("--- % viewsize.height [" .. i .. "]：" .. viewsize.height .. " % ---")
					print("--------- Text . isvisible = ", Text:isVisible(), Text:getOpacity())
				end	
			else
				heightCount = heightCount + height
				height = Text:getSize().height
				self.theLastPosition = cc.p(viewsize.width / 2, viewsize.height - distance - heightCount)
				Text:setPosition(self.theLastPosition)
				if DEBUG_MODE == 1 then
					print("Text: = ", Text:getPositionY())
					print("------------------- % theLastPosition [" .. i .. "]：" .. self.theLastPosition.y .. " % -----------------------------")
					print("--- % heightCount [" .. i .. "]：" .. heightCount .. " % ---")
					print("--- % height [" .. i .. "]：" .. height .. " % ---")
					print("--- % lgHeight [" .. i .. "]：" .. lgHeight .. " % ---")
					print("--- % distance [" .. i .. "]：" .. distance .. " % ---")
					print("--- % viewsize.height [" .. i .. "]：" .. viewsize.height .. " % ---")
					print("--------- Text . isvisible = ", Text:isVisible(), Text:getOpacity())
					Helper:print_lua_table(Text:getAnchorPoint())
				end
			end
		else
		end
	end
end


------------------------传承播放动画---------------
Helper:classDefNodeGetInstance(TeacherAnimationLayer)
return TeacherAnimationLayer
00000000