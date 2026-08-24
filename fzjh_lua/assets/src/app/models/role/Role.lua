local OfflineProfit = require("app.models.OfflineProfit.OfflineProfit")
local RoleBuff = require("app.models.role.RoleBuff")
local SelfCreatedSkillSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillSystem")
local IRoleInput = require("app.models.role.interface.IRoleInput")
local IRoleOutput = require("app.models.role.interface.IRoleOutput")
local AbstractSerializable = require("third.serializable.AbstractSerializable")
local NewClass = require("third.class.NewClass")
local RoleTitleConst = require("app.models.role.titleSystem.RoleTitleConst")
local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")
local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")
local NaturalAttrAdjustmentConst = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrAdjustmentConst")
local SkillConst = require("app.models.skill.SkillConst")
local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")
local LogSystem = require("app.models.LogSystem.LogSystem")

-- local function print()
-- end

local RoleConstans = TableProxy:createEncryptedTableRecursive({
	theSecondOfOneHour = 3600,
	theFactorOfSkill = 200,
})

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/21 10:33:41
-- @desc 角色创建安全的列表table
local function roleCreateSafeTable(key, tab)
	key = Helper:getDef(key, tostring(User:getUserId()))
	return createSafeTable(key, tab, function(tab, valueName, valueFrom, valueTo)
		Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
	end)
end

local IGNORETABLE = {
	maps = {},
	monitorPool = {},
	_finalAttr = {
		jiaLiAtk = 0,
		atk = 0,
		dodge = 0,
		def = 0,
		powerDamage = 0,
		hitRate = 0,
		parry = 0,
		fangHu = 0,
	},
}


local Role =
{
	-- ignoreCloneTb = IGNORETABLE,

	---------------------
	isChangeName = false,

	---------------------
	name = "无名",
	-- --神兵列表，记录自己所有的神兵
	-- shenBingweapon =
	-- {
	-- 	id = nil, 	--"id"		-- 编号唯一
	-- 	onlyId = nil ,---区分唯一id
	--  	name = nil , -- "鱼肠剑"
	--  	colorname = nil,--"REB"
	--  	color = 0,--cc.c3b(80,246,244)
	--  	damage = nil ,-- 初始伤害值----------------
	--  	status = "0" ,--未打造为0，消耗材料了打造成功但没有取名字，没有领取1，打造完成为2
	--  	lv = 0,  --神兵等级
	--  	payYuanBao = 0,--记录神兵花费的元宝，
	--  	type = nil,
	--  	weapon_in = nil,--回鞘特效--------------
	--  	weapon_out = nil,--拔剑特效------------------
	--  	_isThrow = false ,--是否封藏

	--  	material = nil ,--神兵的材料

	--  	neili_level = 0,--实质上花费的内力（累计）发送服务器
	--  	neilicast = 0,--根据富源相当于消耗多少内力的达到的效果()

	--  	gold_level = 0,--花费的黄金（）发送服务器
	--  	goldcast = 0,--花费的黄金（）发送服务器

	--  	beginDazaoTime = nil, --开始打造时间---也是区分玩家自己受手上武器的唯一性
	--  	loadingBarPersent = 0, ---升级一级此时的状态

    -- 	unit = "" ,           -- 单位
    -- 	canFold = 0,          -- 可堆叠
    -- 	canUse = 0  ,         -- 可使用
    -- 	canEquip = 1 ,        -- 可装备
    -- 	combo = 0 ,           -- 可合成
    -- 	canSell = 0,      -- 可出售
    -- 	canDrop = 0 ,             -- 可丢弃
    -- 	equipPart = "", -- 装的时候用的属性
    -- 	strDesc = " " ,-- 武器描述
    -- 	strAppearance = "",-- 武器的外观描述
    -- 	colorid =nil,
    -- 	unwieldText = nil ,-- 回鞘特效
    -- 	equipText = nil,
	-- },
	shuxiang = {},---书箱

	sex = "男", -- 性别
	age = 14,   -- 年龄
	looks = 15, -- 长相
	luck = 20,  -- 福缘

	tili = 100, -- 体力
	tiliMax = 100, -- 体力最大值

	--先天属性
	str = 10,   -- 臂力
	int = 10,   -- 悟性
	con = 10,   -- 根骨
	dex = 10,   -- 身法
	--后天属性
	secStr = 0,	-- 臂力
	secInt = 0,	-- 悟性
	secCon = 0,	-- 根骨
	secDex = 0,	-- 身法
	--有效属性（先天加后天）
	currStr = 0,	-- 臂力
	currInt = 0,	-- 悟性
	currCon = 0,	-- 根骨
	currDex = 0,	-- 身法

	-- 内丹属性分配情况
	fenpei = 0,	-- 先天属性点
	fenpeiList = 	-- 分配列表
	{
		str = 0,   -- 臂力
		int = 0,   -- 悟性
		con = 0,   -- 根骨
		dex = 0    -- 身法
	},
	totalPoint = 0, --武藏总积分
	jing = 100,  -- 精力
	jingMax = 100, -- 最大精力
	qi = 100,      -- 气血
	qiMax = 100,   -- 最大气血
	qiPercent = 1, -- 气血百分比
	neili = 50,   -- 内力
	neiliMax = 50, -- 最大内力
	neiLiLimit = 50, --内力上限
	exp = 1,      -- 经验
	pot = 1,      -- 潜能
	money = 0,    -- 碎银
	gold = 0,    -- 金币
	lv = 1,       -- 等级
	-----
	yuanbao = 0,	--元宝
	totalYuanBao = 0,
	weight = 30,	-- 背包大小
	ckLimit = 30,     --实际仓库大小
	baseCkLimit = 30, --基础仓库大小（不包括家园储物箱仓库空间）
	kongfu = 0,
	jiaLi = 0,

	-- 装饰箱容量上限
	decorativeLimit = 20,

	--江湖属性
	zhengqi = 0,	--侠义正气
	kill = 0,		--杀死人数
	yueli = 0,		--江湖阅历
	killPlayer = 0,	--杀玩家数
	weiwang = 0,	--江湖威望
	dead = 0,		--死亡次数
	meili = 0,		--风度魅力
	deadReason = 0,	--上次死因
	jindu = 0,		--江湖进度
	lunhui = 0,		--轮回次数
	mengjing = 0,	--梦境层数
	panshi = 0,		--叛师次数
	guanqiaLimit = 10, -- 关卡上限



-----------------------------------------------------------------------
	species = "人", -- 物种
	dsc = "", -- 描述
-----------------------------------------------------------------------
	-- 补充属性  by xiaozhiwei
	yueKaValid = "N", --月卡是否有效 Y 有效 N 无效
	monthFenShenFu = "N", -- 包月分身符 Y 有效 N 无效
	yuekaTime = 0,		--购买月卡的时间
	atkRate = 1, 		--攻击倍率
	notice_version = 0,  -- 公告版本号
	notice_url = nil,	-- 公告链接地址
	sigMap = {}, -- url请求时间列表
	role_is_cheat = 0, -- add by XiaoZhiWei 2017/07/18 18:31:19 标记是否作弊,0 为作弊, 1 作弊
-----------------------------------------------------------------------

-----------------------------------------------------------------------
	-- 称号系统
	title_type = 2, --称号类型 1 门派称号 2 江湖称号(正气值) 3 月卡称号 4 官员称号
	title_id =0, --称号id
	-- 官员称号
	-- 官职类型 0 无官职 1翰林院编修 2庶吉士 3推官 4县令
	officialType = 0,

	-- 政绩
	officialAchievement = 0,
-----------------------------------------------------------------------

	letterTime = 0, --上一次送信任务开始时间

	wantedTime = 0, --上一次悬赏任务结束时间

	wantedInterval = 0, -- 悬赏任务间隔

	gamingTime = 0, -- 游戏总时间

	qiyujingCount = 0, -- 奇遇事件获得精力上限次数，上限13次

	saveDataTime = 999999999999, -- 自动存档的时间

-----------------------------------------------------------------------
	-- 拜访任务
	firstCompleteMap = false, -- 首次通关固定副本开启拜访任务 15 20 30

	openVisitTaskByMap = false, -- 每次离开副本时 是否开启拜访任务

	openVisitTaskTime = 0, --上次拜访任务时间，计算间隔
-----------------------------------------------------------------------
	--传承
	inherit =
	{
		name = "继承者",			-- 名字
		type = 1,				-- 对应4个类型
		sex = "男",				-- 性别
		age = 0,				-- 年龄
		intimacy = 0,			-- 亲密度
		zhengqi = 0, 			-- 正邪值
		endurance = 100,		-- 疲劳
		enduranceMax = 100,		-- 疲劳最大值
		physique = 0,			-- 体质
		physiqueMax = 100,		-- 体质最大值
		noema = 0,				-- 心智
		noemaMax = 100,			-- 心智最大值
		morality = 0,			-- 德行
		moralityMax = 100,		-- 德行最大值
		temperament = 0,		-- 气质
		temperamentMax = 100,	-- 气质最大值
		isSetName = false,		-- 是否已经取名
		isSetSex =false,		-- 是否设置性别
		addAttr = 0,			-- 培养增加的属性和
		eventCount = 1,			-- 当前传承事件进度 默认 1
		desc = "", 				-- 身世描述
		isFinish = false,		-- 是否完成传承剧情
	},
	inheritHistory = {},		-- 历任传承人
	isHaveOrphan = false,		-- 是否已有孤儿
	inheritCount = 0,			-- 传承次数
	inheritConsultCount = 0,	-- 传承请教次数
-----------------------------------------------------------------------

	blackMarket = {},			-- 黑市商人

	-- 元宵活动答题统计
	qaCollect =
	{
		-- totalCount = 0,
		-- successCount = 0,
		-- failedCount = 0
	},

	--idcode = 123456 	--用户ID代码（用户判断玩家是否第一次登录）

	---------------------------- 程序处理添加属性
	-- currWatchFid = 0, -- 当前观战编号
	-- roleCurrState = {ROLE_CURR_STATE_DAZUO,ROLE_CURR_STATE_BIGUAN},
	-- maxCount = 100     	--背包最大容量
	-- createTime = 0 -- 用户创建时间
	tempAttrList = {}, 	-- 存放玩家所有临时属性
	----------------------------------------

	family =
	{
		name = "youxia", -- 门派名
	-- 	level = 1, -- 辈分
	},
	tasks = {},
	teacherName = nil, -- 老师名字
	teacherId = nil, -- 老师ID

	skills = -- 技能
	{
	},
	skillPrepare =
	{

	},

	-- 主动招式
	activeZhaos =
	{
		-- liumaishenjian = {id = "liumaishenjian", lv = 999},
		-- leitingyiji = {id = "leitingyiji", lv = 999},
		-- sanhuantaoyue = {id = "sanhuantaoyue", lv = 999},

		-- liaoshang = {id = "liaoshang", lv = 999},
		-- huifu = {id = "huifu", lv = 999},
		-- zuowangwuwo = {id = "zuowangwuwo", lv = 999},
		-- xixingdafa = {id = "xixingdafa", lv = 999},

		-- test = {id = "test", lv = 999},
	},

	-- 准备的主动招式
	preparedActiveZhao = {
		bingqi = {},
		quanjiao = {}
	},

	-- 准备了的主动招式
	preparedZhaos =
	{
		-- "liumaishenjian",
		-- "liaoshang",
		-- "huifu",
		-- "zuowangwuwo",
		-- "xixingdafa",

		-- "test",
		-- "leitingyiji",
		-- "sanhuantaoyue"
	},

	-- 物品
	items =
	{

	},
	-- 仓库
	ckitems =
	{

	},

	-- 装备
	equips =
	{
		-- weapon = {id = onlyId, itemId = itemId},		-- 武器
		-- head = {id = onlyId, itemId = itemId},		-- 头帽
		-- cloth = {id = onlyId, itemId = itemId},		-- 上装
		-- belt = {id = onlyId, itemId = itemId},		-- 腰带
		-- hand = {id = onlyId, itemId = itemId},		-- 手部
		-- pants = {id = onlyId, itemId = itemId},		-- 下装
		-- shoes = {id = onlyId, itemId = itemId},		-- 鞋子
		-- ring = {id = onlyId, itemId = itemId},		-- 戒指
		-- yaozhui = {id = onlyId, itemId = itemId},	-- 腰坠
		-- necklace = {id = onlyId, itemId = itemId},	-- 项链
	},
	--装备箱
	equipsBox = {

	},
	-- 装饰箱 { {itemId, portraitType, count}... }
	decorative =
	{
	},

	zhaoShuXiang = {
	},

	-- 百家典籍书箱
	literaryBox = {},


	-- 当前使用头像id 就是道具ID 为空时使用容貌头像
	portrait = {id = "",lv = 1},

	-- 当前使用的外观id
	appearance = "waiguan0",

	-- 副本NPC 属性修改
	-- npcId
	-- buff
	-- equips
	mapNpcAttrModify = {},
--师门任务
	teacherTask = {},

	teacherGuaJiTask = {},

	teacherGuaJiTaskCount = {}, --任务挂机次数
------------------- 经脉 -----------------------
	-- 经脉
	meridian =
	{
		-- meridianCount 已经激活的经脉数量
		-- acupointCount 当前经脉已经激活的穴道数量
		-- alreadyDisease 当前穴道是否已经暗疾
		-- alreadyDisorder 当前穴道是否已经絮乱
		-- acupointState 0 未开启 1 待冲穴 2 待固本 3 完成 4 发现暗疾 5 真气紊乱 6 激活属性 7 培元
		meridianCount = 0,
		acupointCount = 0,
		acupointState = 1,
		alreadyDisease = 0,
		alreadyDisorder = 0,
		attrList = {},
		attrTotal =
		{
			["qiMax"] = 0, 			-- 气血上限
			["neiLiLimit"] = 0,		-- 内力上限
			["atk"] = 0,			-- 攻击力
			["dodge"] = 0,			-- 闪躲力
			["def"] = 0,			-- 防御力
			["damage"] = 0,			-- 伤害力
			["protect"] = 0,		-- 防护力
		},
	},

	-- 经脉经验
	meridianExp = 0,

	-- 真气值
	breathVal = 0,

	-- 经脉印记 20250121 废弃，不再使用
	-- meridianImprinting = {},

	m_meridianImprintings = {
		_MERIDATACOVERTVER_ = 0,
		mCurrPage = 1,
		mImprintingMap = {},
		--@desc 必须使用string索引，二维数组可能导致json转换出错
		mPageList = {
		 ["1"]={
				-- 该空对象不可删除
				-- 存放经脉印记id
			}
		}
	},

	-- 左右互搏熟练度
	leftRightFightExp = 0,
------------------- 经脉 -----------------------


	-- Begin add by TangJian 2016/11/29 18:15:10

	dropScheme = nil, -- "fubenxiangzi",

	-- End add by TangJian 2016/11/29 18:15:11

	
------------------- 任务次数记录 -------------------	
	taskTimes = {},
	
------------------- 七夕 -----------------------
	prayRoomId = "" ,--祈福分组ID
	openMark = "" , -- 应援开启标识

------------------- 神兵、毒药相关 -----------------------
	forgeCount = 0,--神兵锻造次数
	shenBingItems = {}, --存放所有神兵
	shenBingNumLimit = 10, --神兵拥有上限
	bagShenBingNumLimit = 1, --背包携带神兵上限
	defaultShenBingItemId = nil, --默认神兵itemId
	forgeSkill = {},
	--@desc 记录武器淬毒数据
	poison = {},
	--@desc 药囊
	medicinalBox = {},
	smeltBox = {}, --冶炼箱
	collectScore = 0,--收藏评分
	-- extraTitle = {}, -- 额外的称号
	-- 易容术记录表
	polymorph = 
	{
		endTime = 0, --结束时间
		cdTime = 0, -- 易容术Cd时间
		keepTime = 0, --易容术维持时间
		pLooks = 0,-- 易容之后的长相
		lastLooks = 0, -- 易容之前的长相
		age = 0,	-- 易容之后的年龄
		sex = "男",	-- 易容之后的性别
		qi = 100,	-- 易容之后的气血状况
		_yirongSelectList = {}, --易容详情信息
		-- status = 0, -- 易容的状态 0:未易容 1:正在易容 2:冷却中
	},
	candyData = {},
	weaponScore = 0 ,-- 兵器收藏评分
	armorScore = 0,--防具收藏评分

	sCk_ver = {
		xuanbingdong = 0,
		cangyige = 0,
		homeland = 0,
	},
	-----------------------------------------家园----------------------------------------		
	
	--家园数据，统一保存
	Homeland = {
		fq = {},
		dq = {},
		yq = {},
		prIdIndex = 0, -- 家园仆人计数器
		roomnum = 0, -- 房间数量
		prnum = 0, -- 仆人数量
		plant = {}, -- 种植数据
		dinner = {}, -- 食盒数据
	},
	
	DispatchTask = {}, --派遣任务
	cwItems = {}, -- 家园储物箱
	cwCount = 0, --家园储物箱容量

	xingzhen = {
		effectsCount = {}
	},

	--@desc 读书结构
	read_book = {
		
	},

	--@desc 仓库升级次数
	ckUpCount = 0,
	--@desc 背包升级次数
	wUpCount = 0,
	--准备武器
	prepareWeapon={},

	--@desc 副本章节故事线保存节点。
	mapStore = {},

	--@desc 节点奖励相关
	nodeRewards = {},

	--@desc 已购买的卷
	m_volume = {
		volume_1 = true,
		volume_8 = true,
		-- volume_6 = true,
		-- volume_0 = true,
		-- volume_00 = true,
	},

	--@desc 地图节点标记
	mapNodeFlag = {},
	--修炼数据
	xiuLianData={},
	--假人数据
	jiaRenData = {},
	--@desc 见闻武学（战斗中对方准备的武学，自己不会）
	seeSkills = {
		-- skillid,
		-- skillid2
	},
	--疲劳值
	pijuan =0,

	--入梦buff
	AsleepBuff = {
		-- {
		-- 	id = "",
		-- 	startTime = 0,
		-- }
	},

	--梦境天赋
	DreamTalent = {
		--talentId = true
		--talentId1 =true
	},

	--准备天赋
	PrepareTalent = {},

	--@desc buff数据
	buffs = {},
	--@desc buff带来的效果
	buffEffects = {},

	emotion = {},

	--@desc 梦境需要记录的值
	dr_params = {
		--@desc 进梦境时的疲倦值
		enterDreamPijuan = nil,
	
		--@desc 进梦境时床的特殊数值
		enterDreamBedValue = nil,
	},

	-- dreamWorld = {
	-- 	cFloor = 0, --@desc 当前楼层
	-- 	eFloor = 0  --@desc 结算楼层
	-- }

	--@desc 自创武学数据
	selfCreatedSkillData = {},

	yaShi = 0,

	--@desc 挂机改版数据
	hangUpTasks = {
		__ver = 0,
		__currHangUpTaskId = nil,
		__tasks = {}
	},

	titles = {
		extraTitle = {}
	},

	--@desc 边框数据版本
	borderVer = 0,
	--@desc 边框添加顺序 
	borderShowList = {},

	--@desc 武学突破数据
	skillBreakData = {
		-- skillId = breId
	},
	--@desc 招式突破数据
	zhaoBreakData = {
		-- zhaoId = breId
	},

	skillSysVer = 0,
	--白名单标记0 不是白名单  1 是白名单
	isWhiteList = 0,

	mSkillUseRecord= {
		firstUseTime = 0,--第一次使用时间
		time = 0 --次数
	},

	departFromFamilySign = nil,--叛师标记

	--新版头衔数据
	basicTitleData = {
		titleList = {}, --头衔列表
		titleId = nil, --当前使用头衔
	},


	--隐脉数据
	hiddenMeridianData = {
		version = 0, --隐脉版本
		currHiddenMeridianChartId = "minditem1",--当前隐脉图id
    	breakThroughState = false, --是否处于破境状态
		breakThroughFinishTime = 0, --破境结束时间
		currAcupointId = nil,--当前冲脉的窍关id
		acupointActivateState = false, --是否处于冲脉状态
		acupointActivateFinishTime = 0, --冲脉结束时间
    	yuQiState = false, --是否处于余炁状态
		yuQiBuffAttrs = {}, --余炁buff属性
		yuQiBuffActiveEffects = {}, --余炁buff主动效果
		yuQiBuffIds = {},  --余炁玄络id
		buffMap = {
			-- buffId = {}
		},
		acupointMap = {
			-- acupointId = {
			--     isActivated = false, --是否激活
			--     buffId = nil --窍关上安装的玄络id
			-- }
		},
	},

	--神书数据
	shenShuTask = {
		count = 0, --当前周期进行神书次数
		allCount = 0, --总共进行神书次数
		startTime = -1, --当前周期任务开始时间
		task = {
			startTime = -1,	--当前任务开始时间
			bookDropInfoList = {}, --神书掉落信息
		}
	},

	--神书送礼信息
	shenShuSongLiInfo = {
		startTime = -1,	--开始时间
		npcList = {}	--送礼npc
	},

	--货币版本
	currencyVersion = 1,

	--观影堂特权数据
	viewingHallInfo = {
		privilege_expired_time = 0, --特权过期时间
		privilege_remaining_watches = 0 --当日剩余观看次数
	}
}

--获得潜能奖励
function Role:getPotFromExp()
	local pot = 0
	local exp = self.exp
	local fy = self:getFinalAttr("luck")
	local sklv = self:getKongfu()

	--潜能奖励公式
	if exp > 1000 and exp < 2000 then
		pot = 18000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 2000 and exp < 5000 then
		pot = 12000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 5000 and exp < 15000 then
		pot = 10000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 15000 and exp < 80000 then
		pot = 8000 * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 80000 and exp < 300000 then
		pot = 4500 * 2 ^ (sklv / 140) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 300000 and exp < 500000 then
		pot = 4860 * ((sklv - 46) ^ 2 / 14400 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 500000 and exp < 1000000 then
		pot = 5249 * ((sklv - 55) ^ 2 / 24336 + 1) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 1000000 and exp < 5000000 then
		pot = 5668 * (2 ^ (sklv / 364)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 5000000 and exp < 15000000 then
		pot = 6122 * (2 ^ (sklv / 527)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 15000000 and exp < 30000000 then
		pot = 6612 * (2 ^ (sklv / 665)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	elseif exp > 30000000 then
		pot = 7141 * ( 2 ^ (sklv / 1200)) * math.min(1.2, math.random(80, 108 + math.floor(0.5 * fy)) / 100) / RoleConstans.theSecondOfOneHour * 360
	end
	return math.floor(pot)
end

--获得碎银奖励
function Role:getMoneyFromExp()
	local money = 0
	local exp = self.exp
	local fy = self:getFinalAttr("luck")
	local sklv = self:getKongfu()

	if 1000 < exp and exp < 2000 then
	elseif 2000 < exp and exp < 5000 then
	elseif 5000 < exp and exp <15000 then
		money = 2500 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 15000 < exp and exp < 80000 then
		money = 3000 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 80000 < exp and exp < 300000 then
		money = 3500 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 300000 < exp and exp < 500000 then
		money = 4000 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 500000 < exp and exp < 1000000 then
		money = 4800 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 1000000 < exp and exp < 5000000 then
		money = 5500 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 5000000 < exp and exp < 15000000 then
		money = 6000 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 15000000 < exp and exp < 30000000 then
		money = 6000 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	elseif 30000000 < exp then
		money = 6500 / RoleConstans.theSecondOfOneHour * math.random(80, 108 + math.floor(0.5 * fy)) / 100 * 360
	end
	return math.floor(money)
end

-- 合并其他模块的方法
table.mergeToLeft(Role, require("app.models.role.Role_Item")) -- 载入物品相关模块
table.mergeToLeft(Role, require("app.models.role.Role_ActiveZhao")) -- add by XiaoZhiWei 2019/02/27 15:52:43 载入招式相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Skill")) -- 载入技能相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Weapon")) -- 载入武器相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Attr")) -- 载入属性相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Family")) -- 载入师门相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Flag")) -- 载入标记相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Inherit")) -- 载入传承相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Task")) -- 载入任务相关模块
table.mergeToLeft(Role, require("app.models.role.Role_Map")) -- 载入副本相关模块
table.mergeToLeft(Role, require("app.models.role.Role_SmeltBox")) -- 冶炼箱模块
table.mergeToLeft(Role, require("app.models.role.Role_Title")) -- 载入称号相关模块

-- @desc 构造方法
function Role:ctor()
	self._iRoleOutput = nil

	
end

function Role:create(data)
	local p = Role.new(data)
	p:init()
	return p
end

--[[
    @desc: 获取角色Id
    author:TangJian
    time:2021-12-08 16:01:23
    @return:
]]
function Role:getId()
    return self.id
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/17 18:12:36
-- @desc 资源或程序错误引起的存档异常,在该方法内修复
function Role:repairUserData()
	--@desc 修改角色状态存储数据结构
	if self:getInheritFlag("roleStateChange") == 0 and self.roleCurrState and table.getn(self.roleCurrState) > 0 then
		local stateMap = {}
		for i, v in ipairs(self.roleCurrState) do
			if tonumber(v) then
				stateMap[tostring(v)] = true
			end
		end

		self.roleCurrState = stateMap

		self:setInheritFlag("roleStateChange",1)
	end

	--结束旧版练功
	self:getLianGongSystem():stopOldLianGong()

	--结束旧版修炼
	self:getXiuLianSystem():stopOldXiuLian()

	-- add by XiaoZhiWei 2017/02/17 18:14:41 角色创建时间如果为空,则记录一个创角色创建时间,并计算气血量
	if self:getAttr("createTime") == nil then
		-- self:setAttr("createTime", GetTime())
		local factor = self:getPrepareSkillFactor("neigong", "HpRate")

		if self:getAttr("age") <= 140 then
			self.qiMax = ((self.neiliMax - 50)*(factor+20)/700+self:getNeiLiLimit()*(factor-30)/1000)*(1+self:getEffectCon() *0.02)+self:getFinalAttr("con")*10+5*(self:getAttr("age")-14)^2+45*(self:getAttr("age")-14)
		else
			self.qiMax = ((self.neiliMax - 50)*(factor+20)/700+self:getNeiLiLimit()*(factor-30)/1000)*(1+self:getEffectCon() *0.02)+self:getFinalAttr("con")*10+85050 +(self:getAttr("age") - 140)* 50
		end
		self.qi = self.qiMax
	end

	--------------------------------------------------------------------------------------
	----- Author XiaoZhiWei
	----- Date 2016-11-04
	----- Desc 门派修改调整 逍遥派和灵鹫宫 改为天山派
	if MapIsEmpty(self.family) == false then
		local family = self.family
		if family.name == "xiaoyao" or family.name == "lingjiugong" then
			family =
			{
				name = "tianshan",
				level = family.level
			}
			self:setAttr("family", family)
		end
	end

	-- 修复传承历史BUG
	if MapIsEmpty(self.inheritHistory) == false then
		local inheritHistory = {}
		local flag = true
		for k,v in pairs(self.inheritHistory) do
			-- 如果key类型为number 不做处理
			if type(k) == "number" then
				flag = false
			else
				if v.inheritName ~= nil then
					table.insert(inheritHistory, v)
				end
			end
		end

		if flag == true then
			self.inheritHistory = inheritHistory
			-- 重新排序
			table.sort( self.inheritHistory, function(a,b)
				return a.inheritTime < b.inheritTime
			end )
		end
	end

	local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
	--修复重铸神兵特性
	local function repairShenBingEffect(shenbingweapon)
		if not shenbingweapon then 
			return 
		end
		local effectList=ShenBingEffct:getShenBingTypeEffect(shenbingweapon.bType)
		shenbingweapon.effct1=effectList[1]	 
		shenbingweapon.effct2=effectList[2]	
		shenbingweapon.effct3=effectList[3]
		if shenbingweapon.effctNum<100 then 
			shenbingweapon.effct2=""
			shenbingweapon.effct3=""
		elseif shenbingweapon.effctNum>=100 and shenbingweapon.effctNum<200  then 
			shenbingweapon.effct3=""
		end
	end

	for i,v in pairs(self.shenBingItems) do
		repairShenBingEffect(v)
	end 

	local function repairItems(key, items)
		if MapIsEmpty(items) == false then
			for i,item in ipairs(items) do
				if item.itemId == "tianxiangyulu" then
					item.itemId = "tianxiangyulu1"
				elseif item.itemId == "putizi" then
					item.itemId = "putizi1"
				else
				end
				local itemAttr = self:getOneItemByKey(item.itemId)
				-- print("-----------------------:",item.itemId)
				if MapIsEmpty(itemAttr) == false then
					if item.time == nil and (type(itemAttr.timeend) == "number" or type(itemAttr.timeend) == "string") then
						item.time = self:getItemTimeLimit(itemAttr)
					-- elseif item.time ~= nil and (itemAttr.timeend == nil or itemAttr.timeend == "") then
					-- 	item.time = nil
					end
				else
					-- 不存在的物品移除掉,索引需要减一
					table.remove(items, i)
					i = i -1
				end
			end
			self:setAttr(key, items)
		end
	end

	-- add by XiaoZhiWei 2017/02/17 18:16:20 tianxiangyulu 和 putizi 的资源缺失,转换为 tianxiangyulu1 和 putizi1
	repairItems("items", self:getItems())

	-- add by XiaoZhiWei 2017/06/06 17:13:44 修复仓库的 tianxiangyulu 和 putizi 的资源缺失,转换为 tianxiangyulu1 和 putizi1
	repairItems("ckitems", self:getckItems())

	-- add by XiaoZhiWei 2017/03/06 18:30:43 修复 准备技能出现空字符串的情况
	local prepareSkill = self:getSkillPrepare()
	if MapIsEmpty(prepareSkill) == false then
		for pType,skillId in pairs(prepareSkill) do
			if skillId == "" then
				prepareSkill[pType] = nil
			end
		end
		self:setAttr("skillPrepare", prepareSkill)
	end

	-- add by XiaoZhiWei 2017/03/30 18:03:27 修正 招式经验全部降低10倍
	local activeZhaos = self:getAttr("activeZhaos")
	if MapIsEmpty(activeZhaos) == false and self:getFlag("resetActiveZhaos") == 0 then
		for k,roleZhao in pairs(activeZhaos) do
			roleZhao.exp = roleZhao.exp/10
		end
		self:setFlag("resetActiveZhaos", 1) -- add by XiaoZhiWei 2017/03/30 18:09:43 标记,标识是否已做处理
	end
	-- 删除数量小于等于0的道具
	local flag = true
	while flag do
		flag = false
		local items = self:getItems()
		if MapIsEmpty(items) == false then
			for i,v in ipairs(items) do
				if v.count <= 0 then
					-- print(v.name .. " count <= 0 remove")
					table.remove(items, i)
					flag = true
					break
				end
			end
			self:setAttr("items", items)
		end
	end

	-- 七夕头像改为可传承
	if self:getInheritFlag("七夕情缘称号奖励") ~= 0 then
		self:setFlag("七夕情缘奖励", self:getInheritFlag("七夕情缘称号奖励"))
	end

	local mapNpcAttrModify = self:getAttr("mapNpcAttrModify")
	if #mapNpcAttrModify > 80 then
		mapNpcAttrModify = {mapNpcAttrModify[1]}
	else
		local v -- add by XiaoZhiWei 2017/09/06 15:40:29 移除空栏目
		local npcList = {}
		for i = #mapNpcAttrModify, 1, -1 do
			v = mapNpcAttrModify[i]
			if MapIsEmpty(v) == true then
				table.remove(mapNpcAttrModify, i)
			elseif npcList[v.npcId] == nil then  -- add by XiaoZhiWei 2017/09/06 18:09:07 如果数据未记录,则记录一个标记,如果数据已经有记录标记,则删除该数据
				npcList[v.npcId] = true
			elseif npcList[v.npcId] == true then
				table.remove(mapNpcAttrModify, i)
			else
			end
		end
	end
	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)

	local flag = self:getFlag("是否修复佣兵装备列表")
	local list = self:getFlag("佣兵异常的装备列表")
	if flag ~= true and MapIsEmpty(list) == false then
		local cList = {}
		for k,v in pairs(list) do
			cList[k] = 1 -- add by XiaoZhiWei 2017/09/06 15:35:30 同样的物品只给一个
		end
		if self:checkCanBuyTwoOrMoreThings(cList, false) == true then
			for itemId,count in pairs(cList) do
				self:addItemCount(itemId, count)
			end
			self:setFlag("是否修复佣兵装备列表", true)
		end
	end

	--修复 鬼差任务存档带“\n”
	local ghostInfo = self:getAttr("ghostInfo")
	if not MapIsEmpty(ghostInfo) then
		local str = ghostInfo.str
		local str1 = string.gsub(str,"\n","#@n#")
		self.ghostInfo.str = str1
	end

	self:setFlag("当前位置","离开副本")

	--@desc 修正学习长生诀阴阳后 又从上辈传承角色中学习到的长生诀
	if self:getSkill("changshengjue") and (self:getSkill("changshengjueyin") or self:getSkill("changshengjueyang"))then
		self.skills["changshengjue"] = nil		
	end

	--@desc 修特殊情况下同时拥有长生诀阴和长生诀阳，去除长生诀阴
	if self:getSkill("changshengjueyin") and self:getSkill("changshengjueyang") then
		self.skills["changshengjueyin"] = nil
	end

	--@desc 修复长生诀阴或者阳多次学习导致等级超过1000级的情况
	local cSkill = self.skills["changshengjueyin"] or self.skills["changshengjueyang"]
	if cSkill ~= nil and self:getSkillLv(cSkill.id) > 1010 then
		local exp = self:conversionSkillExpAndLv("exp",600)
		local roleSkill = {id = cSkill.id, exp = exp}
		self:setSkill(cSkill.id,roleSkill)
	end

	--@desc 在学习长生诀阴阳的过程中如果闪退造成无法再次学习的情况
	if self:getInheritFlag("item_changshengjueyinoryang") == true then
		if not self.skills["changshengjueyin"] and not self.skills["changshengjueyang"] then
			self:setInheritFlag("item_changshengjueyinoryang", false)
		end
	end

	-----------------------------------------------------------------------------------------------------------
	-- -- @author GaoHanZheng
	-- -- @time 2017/12/14 16:56:03
	-- -- @desc 修复历练造成的状态混乱问题
	if self:isInCurrState(ROLE_CURR_STATE_GUAJI) == false then--只需要修复挂机任务
		-- for k,task in pairs(self.tasks) do 
		-- 	if task.state == TASK_STATE_GUAJI then
		-- 		task:update(ft)
		-- 		task.state = TASK_STATE_IDLE --修复设置为
		-- 	end
		-- end
		local Task = require("app.models.task.Task")
		for taskId,task in pairs(Task:getGuaJiTasks()) do
			if self:getTask(taskId) ~= nil then
				task:update(ft)
				task:stopGuaji()
			end
		end
	end

	self:setFlag("锻造状态","空闲")

	--修复神兵锻造补领异常问题
	local flag = self:getInheritFlag("神兵锻造")
	
	if type(flag) == "table" and flag.name == "锻造神兵" then
		local weapen = ShenBingDuanZao:getShenBingWeapenUnreceive()
		if weapen == nil then
			self:setInheritFlag("神兵锻造",0)
		end
	end
 	if self.repairShenBing == nil or self.repairShenBing == 0 then
 		local num = 0
 		for k,shenbing in pairs(self.shenBingItems) do 
 			local id = tonumber(string.split(shenbing.id,"weapon_")[2])
 			if id ~= nil and id > num then
 				num = id 
 			end
		 end
		if self.forgeCount <= num then
			self.forgeCount = num + 1
		end
 		self.repairShenBing = 1
	 end
	 
	local items = self:getItems()
	if MapIsEmpty(items) == false then
		 for i,item in ipairs(items) do
			 if item.type == "神兵" and self:getOneItemByKey(item.itemId) == nil then
				 if self:getEquipByName("weapon") ~= nil and self:getEquipByName("weapon").itemId == item.itemId then
					self:setEquipByName("weapon",nil)
				 end
				 table.remove( items,i )
			 end
		 end
	end
	--@desc 修复背包中有神兵，但状态为未领取的情况
	for k,shenbing in ipairs(self.shenBingItems) do
		if shenbing.status == 2 then
			local num = self:getItemCount(shenbing.id)
			if num > 0 then
				local ShenBingDuanZao = require("app.models.ShenBing.DuanZao.ShenBingDuanZao")
				ShenBingDuanZao:setShenBingStateInShenBingItems(shenbing.id,3)
				local flag = self:getInheritFlag("神兵锻造")
				if flag ~= 0 then
					self:setInheritFlag("神兵锻造",0)
				end
			end
		end
	end

	--@desc 修复神兵结构中状态为未领取，但flag不对的情况
	for k,shenbing in ipairs(self.shenBingItems) do
		if shenbing.status == 2 then
			local flag = self:getInheritFlag("神兵锻造")
			if flag == 0 then
				self:setInheritFlag("神兵锻造",{name = "锻造神兵"})
				break
			else
				break
			end
		end
	end

	if self:getInheritFlag("可进入苏州水底") == 1 and not MapIsEmpty(self.shenBingweapon) then
		self.shenBingweapon = nil
	end

	do
		if self:getFlag("行针走穴Effects") ~= 0 then
			self.xingzhen["行针走穴Effects"] = self:getFlag("行针走穴Effects")
		end
		
		if self:getFlag("行针走穴EffectsCD") ~= 0 then
			self.xingzhen["行针走穴EffectsCD"] = self:getFlag("行针走穴EffectsCD")
		end
		if self:getFlag("行针走穴EffectsValues") ~= 0 then
			self.xingzhen["行针走穴EffectsValues"] = self:getFlag("行针走穴EffectsValues")
		end
		if self:getFlag("行针走穴CD时间") ~= 0 then
			self.xingzhen["行针走穴CD时间"] = self:getFlag("行针走穴CD时间")
		end
		if self:getFlag("针法数据") ~= 0 then
			self.xingzhen["针法数据"] = self:getFlag("针法数据")
		end

		if self:getFlag("行针走穴结束时间") ~= 0 then
			self.xingzhen["行针走穴结束时间"] = self:getFlag("行针走穴结束时间")
		end

		self:setFlag("行针走穴Effects",nil)
		self:setFlag("行针走穴EffectsCD",nil)
		self:setFlag("行针走穴EffectsValues",nil)
		self:setFlag("行针走穴CD时间",nil)
		self:setFlag("针法数据", nil)
		self:setFlag("行针走穴结束时间",nil)

		
		if self:getInheritFlag("bagCkCount") == 0 then
			local bagUpdateCount = (self.weight - 30) / 5

			self.wUpCount = bagUpdateCount

			local ckUpCount = (self.ckLimit - 30) / 5

			self.ckUpCount = ckUpCount

			self:setInheritFlag("bagCkCount",1)
		end
	end


	--@desc 阅读数据结构更改
	if self:isInCurrState(ROLE_CURR_STATE_READ) and MapIsEmpty(self.read_book) then
		local currId = self:getFlag("当前研读书籍")
		local currStartTime = self:getFlag("研读时间")

		if currId ~= 0 then
            self.read_book = {
                id = currId,
                startTime = currStartTime,
                isDuanZao = self:getFlag("可以提升锻造之术等级"),
                isPosison = self:getFlag("可以提升江湖毒术等级"),
                shuTong = 0,
                shuTongLv = 0,
                shuTongName = "",
                room = 0
			}
			
			self:setFlag("当前研读书籍",nil)
			self:setFlag("研读时间",nil)
			self:setFlag("可以提升锻造之术等级",nil)
			self:setFlag("可以提升江湖毒术等级",nil)
		end
	end


	if self:getFlag("taskRewardFlag") == 0 then
		for k,v in pairs(self.tasks) do
			v.exp = v.exp == nil and nil or 0
			v.pot = v.pot == nil and nil or 0
			v.money = v.money == nil and nil or 0
			v.times = v.times == nil and nil or 0
		end	
		self:setFlag("taskRewardFlag", 1)
	end

	--淬炼材料和锻造材料直接加到冶炼箱
	do
		local items = self:getItems()
		if items then
			for i = #items,1,-1 do 
				local itemAttr = self:getOneItemByKey(items[i].itemId)
				if itemAttr then
					if itemAttr.type == "锻造材料" or itemAttr.type == "淬炼材料" then
						self:addItemToSmeltBox(items[i].itemId,items[i].count) 
						table.remove(items, i)
					end
				else
					print("物品不存在  itemId = ",items[i].itemId)
				end
			end
		end
	end

	if self.teacherId == "yuzhixiao" then
		self.teacherId = "qiumuzhong"
	end

	if self.teacherId == "jiangshangyou" then
		self.teacherId = "jiangshangyou1"
	end

	if self.teacherName == "余志枭" then
		self.teacherName = "仇穆仲"
	end

	if type(self.title_type)=="string" then 
		self:setAttr("title_type",tonumber(self.title_type))
	end

	if not MapIsEmpty(self.prepareWeapon) then 
		if self:getItemCount(self.prepareWeapon.itemId)<1 then 
			self:setPrepareWeapon()
		end
	end

	local TeacherGuaJiTaskUtil = require("app.models.task.teacherGuaJiTask.TeacherGuaJiTaskUtil")
	TeacherGuaJiTaskUtil:repairTaskData()

	local UserRoleFlagClear = require("app.models.role.UserRoleFlagClear")
	local needClearRoleFlagList = UserRoleFlagClear:getNeedClearFlagList()
	local needClearRoleInheritFlagList = UserRoleFlagClear:getNeedClearInheritFlagList()
	if MapIsEmpty(self._flags) == false then
		for k,_ in pairs(self._flags) do 
			if needClearRoleFlagList[k] == true or string.find(k,"user_fb_") then
				self._flags[k] = nil
			end
		end
	end

	if MapIsEmpty(self._inherit_flags) == false then
		for k,_ in pairs(self._inherit_flags) do 
			if needClearRoleInheritFlagList[k] == true then 
				self._inherit_flags[k] = nil 
			end
		end
	end

	--@desc 昆仑-苍雪孤鹰势 技能传承修复
	if self:getInheritFlag("rep_cxgys") == 0 then
		if MapIsEmpty(self.inheritHistory) == false then
			for _,v in ipairs(self.inheritHistory) do
				if MapIsEmpty(v.parentSkills) == false then
					for i=#v.parentSkills,1,-1 do
						if v.parentSkills[i].id == "cangxueguyingshi" then
							table.remove(v.parentSkills,i)
						end
					end
				end
			end
		end
	
		if self.skills ~= nil and self.skills["cangxueguyingshi"] ~= nil and self:getFamilyId() ~= "kunlun" then
			self.skills["cangxueguyingshi"] = nil
			for k,v in pairs(self.skillPrepare) do
				if v == "cangxueguyingshi"  then
					self.skillPrepare[k] = nil
				end
			end
		end
		
		self:setInheritFlag("rep_cxgys",1)
	end

	--@desc 梦境天赋buff 传承修复
	if self:getInheritFlag("talent_buff_count") == 0 then
		local DreamTalentModel = require("app.models.DreamWorldModel.DreamTalentModel")
		local DreamTalentTab = self:getAttr("DreamTalent")
		local BuffDataTab = require("script.Buff.BuffAll")["buff"]
		for talentId ,v in pairs(DreamTalentTab) do
			local talent = DreamTalentModel:getTalentAttrById(talentId)
			if talent.drbuffid and talent.drbuffid ~= 0 and talent.talentType == 1 then
				local buff = self._buffManager:getBuff(talent.drbuffid)
				if buff then
				else
					self:addBuffV2(talent.drbuffid)
				end
			end
		end

		self:setInheritFlag("talent_buff_count",1)
	end

	--神照经技能删除问题修改
	if self:getSkill("shenzhaojing002") then
		if self:getSkill("shenzhaojing001") then
			self:removeSkill("shenzhaojing001")
		end
	end

	if self:getSkill("shenzhaojing003") then
		if self:getSkill("shenzhaojing001") then
			self:removeSkill("shenzhaojing001")
		end

		if self:getSkill("shenzhaojing002") then
			self:removeSkill("shenzhaojing002")
		end
	end

	local currTaskId = self:getAttr("currTaskId")
	if currTaskId then
		local Task = require("app.models.task.Task")
		local roleTask = Task:getRoleTask(currTaskId)
		local task = Task:getTask(currTaskId)
		if roleTask.state == TASK_STATE_GUAJI then
			task:update()
			task:stopGuaji()

			if self:getHangUpSystem():isHangUping() then
                --@TODO 其余系统判断关联,需加回
                self:setRoleCurrState(ROLE_CURR_STATE_GUAJI)
			end
		end
	end

	--基本仓库转化
	if self.baseCkLimit == 30 and self:getAttr("ckUpCount") > 0 then
		self.baseCkLimit = self:getAttr("ckUpCount") * 5 + 30  --旧版背包仓库公式（不包括家园储物箱空间）
	end

	do	
		if self:getInheritFlag("rep_czxf_dxxf") == 0 then
			--修复禅宗心法被其他门派拥有情况（禅宗心法 可被天龙、少林拥有）
			local familyId = self:getFamilyId()
			local skill = self:getSkill("chanzongxinfa")
			if familyId and familyId ~= "dali" and familyId ~= "shaolin" and MapIsEmpty(skill) == false then
				self:removeSkill("chanzongxinfa")
			end
	
			--修复道学心法被其他门派拥有情况（道学心法 可被武当、全真拥有）
			local skill = self:getSkill("daoxuexinfa")
			if familyId and familyId ~= "wudang" and familyId ~= "quanzhen" and MapIsEmpty(skill) == false then
				self:removeSkill("daoxuexinfa")
			end

			self:setInheritFlag("rep_czxf_dxxf",1)
		end
	end
	
	self:limitAttrZhengQiRange()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/23 21:35:48
-- @desc 初始化 忽略克隆表
function Role:initIgnoreCloneTb()
	self.ignoreCloneTb = clone(IGNORETABLE)
end

function Role:init()
	self.onlyId = Helper:getOnlyId()

	self.__hiddenMeridianSystem = nil

	-- 添加模块
	local ModuleManager = require("third.module.ModuleManager")
	ModuleManager:addModule(self, "app.models.role.module.RoleModule")

	self._mapIsInited = false

	-- 自创武学系统
	self._selfCreatedSkillSystem = SelfCreatedSkillSystem:create()
	local SelfCreatedSkillPropSystem = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillPropSystem")
	self._selfCreatedSkillSystem:setPropSystem(SelfCreatedSkillPropSystem:create())
	self._selfCreatedSkillSystem:init(self)
	self._selfCreatedSkillSystem:repairRoleSelfCreatedSkillId()

	self._roleSkillSystem = require("app.models.role.skillSystem.RoleSkillSystem"):create(self)

	-- 面具系统
	local MaskSystem = require("app.models.mask.MaskSystem")
	self._maskSystem = MaskSystem:create(self)

	local RoleTitleSystem = require("app.models.role.titleSystem.RoleTitleSystem")
	self._titleSystem = RoleTitleSystem:create(self)

	local RoleItemSystem = require("app.models.role.item.RoleItemSystem")
	self._roleItemSystem = RoleItemSystem:create(self)

	local BuffManager = require("app.models.Buff.BuffManager")
	self._buffManager = BuffManager:create()
	self._buffManager:registerUpdateFunc(function()
        self:dispatchEvent("roleBuffUpdate")
    end)
	self._buffManager:init(self)
	
	-- 角色增益 add by TangJian 2017/04/25 21:42:17
	self._roleBuff = RoleBuff:create()

	-- 初始化增益
	self:updateRoleBuff()

	self:initIgnoreCloneTb()
	
	--@desc 挂机系统
	local HangUpTaskSystem = require("app.models.Task2.HangUpTaskSystem")
	self:setHangUpSystem(HangUpTaskSystem:create(self))
	local LiLianTaskSystem = require("app.models.Task2.LiLianTaskSystem")
	self:setLiLianTaskSystem(LiLianTaskSystem:create(self))

	local RoleViewBorderSys = require("app.models.HeadViewSystem.RoleViewBorderSys")
	self._roleViewBorderSys = RoleViewBorderSys:create(self)
	
	--@desc 武学突破系统
	local SkillBreakThroughSystem = require("app.models.skill.skillBreakThrough.SkillBreakThroughSystem")
	self._skillBreakThroughSys = SkillBreakThroughSystem:create(self)
end


function Role:setData(data)
	Helper:tableCover(self, data)
	self:init()

	-- 初始化增益
	self:updateRoleBuff()
end

function Role:getData()
	return self
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得当前攻击手段
function Role:getAttackMethod()
	local skill = self:getPrepareAttackSkill()
	return skill:getAttackMethod()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/09 16:48:34
-- @desc 获取当前背包重量
function Role:getNowWeight()
	return Helper:getDef(#self:getItems(), 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/10 12:36:06
-- @desc 得到动画类型
function Role:getAnimType()
	return Helper:getDef(self.animType, "human")
end

-- 功能
function Role:getFunctions()
	return self.functions
end

function Role:doFunction(funcName, role)
	local func = self[funcName]
	if func then
		func(self, role)
	end
end

function Role:toTalk(str)
	if not str then
		return
	end
	RichPrint("main", tostring(self:getName())..": "..tostring(str))
end

	--新增师傅交谈内容
function Role:obTalk(role)
	--分割字符串
	if self.talkText and type(self.talkText) == "string" then
		self.talkText = string.split(self.talkText,";")
	end
	---如果有交谈内容，则输出交谈内容，否则输出固定的文本
	if self.talkText and type(self.talkText) == "table" and #self.talkText ~= 0 then
	    local talkText = self.talkText[math.random(1, #self.talkText)]
	    RichPrint("main", "YEL"..self.name .. "：" .. talkText)
	else
		if self:getAttr("id") == role:getAttr("teacherId") then
			self:toTalk("徒儿，找为师有何事！")
		else
			self:toTalk("你是？")
		end
	end
end

function Role:showTeacherAnimation( menPaiStr )
	local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
	local teacherAnimationLayer = TeacherAnimationLayer:getInstance()
	teacherAnimationLayer:setVisible(false)
	local str = teacherAnimationLayer:getMenPaiStr(menPaiStr)
	if not MapIsEmpty(str) then
		teacherAnimationLayer:createTextFromArray(str)
		teacherAnimationLayer:show()
	else
		PopText("你没有加入门派")
	end
end

function Role:obCompete(role,callback)
	callback = Helper:getDef(callback,EMPTY_FUNC)
	
	--@desc 恢复满血状态
	self:setAttr("qiPercent", 1.0)
	self:setAttr("qi", self:getCurrQiMax())
	self:setAttr("neili", self:getFinalAttr("neiliMax"))

	--@desc 切磋胜利文本
	local wintext = Helper:getDef(self:getAttr("wintext"), "您比武赢了" .. self:getAttr("name") .. "。")

	--@desc 切磋失败文本
	local losetext = Helper:getDef(self:getAttr("losetext"), "您比武输给了" .. self:getAttr("name") .. "。")

	local FightLayer = require("app.views.layer.FightLayer.FightLayer")
	FightLayer:startMapFight(
		{role},
		{self},
		function(fightLayer, eventType, ...)
			local fight = fightLayer:getFight()
			if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
				-- 暂停地图场景渲染
				MainControllLayer:pauseUpdate()

				-- 战斗开始的时候设置下玩家
				local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
				fight:setPlayer(role)

				-- fightLayer:printRolePrologue(1, "切磋")
			elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
				PopText("战斗开始!!!")
			elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
				local winTeamId, teams = ...

				-- 隐藏按钮区域
				fightLayer:callUIMemFunc("setButtonAreaVisble", false)
				-- 显示战斗结束文本区域
				fightLayer:callUIMemFunc("showFightEndTextArea")

				FubenClient:setValue("isFighting", false)
				User:getRole():updateFightStatus("战斗结束")
				User:getRole():addSeeSkillAfterFight(self) --战斗结束后添加见闻武学技能

				do --淬毒武器使用后需扣除淬毒效果次数
					local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
					local zhengqi = role:getRole():getAttr("zhengqi")
					local player = User:getRole()
					player:setAttr("zhengqi",zhengqi)
					if POISONSYS then
						local rolePoison = role._role:getAttr("poison")
						player.poison = rolePoison
					end
				end

				-- 战斗胜利条件结果
				if winTeamId == 1 then
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你战胜了" .. self:getName().."。")
					RichPrint("main",wintext)
				elseif winTeamId == 2 then
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
					fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. self:getName() .. "击败了。")
					RichPrint("main",losetext)
				end

				fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
					MainControllLayer:resumeUpdate()
	
					fightLayer:hide(function()
						fightLayer:destroyInstance()
						cleanTable(fightLayer)
					end)
				end)
				
				callback(fightLayer, eventType,...)
			elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
				FubenClient:setValue("isFighting", false)
				role:updateFightStatus("战斗结束")
				User:getRole():addSeeSkillAfterFight(self) --战斗结束后添加见闻武学技能

				do --淬毒武器使用后需扣除淬毒效果次数
					local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
					local zhengqi = role:getRole():getAttr("zhengqi")
					local player = User:getRole()
					player:setAttr("zhengqi",zhengqi)
					if POISONSYS then
						local rolePoison = role._role:getAttr("poison")
						player.poison = rolePoison
					end
				end

				-- 隐藏按钮区域
				fightLayer:callUIMemFunc("setButtonAreaVisble", false)
				-- 显示战斗结束文本区域
				fightLayer:callUIMemFunc("showFightEndTextArea")

				-- 设置战斗结束文本区域的文本
				fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
				fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, role.name .. "大喝一声：“三十六计，走为上计")

				fightLayer:callUIMemFunc(
					"setFightEndTextAreaReleaseFunc",
					function()
						fightLayer:hide(
							function()
								fightLayer:destroyInstance()
								cleanTable(fightLayer)
							end
						)
					end
				)
				RichPrint("main","或因准备不全，切磋时略感吃力，遂你们点到即止，结束了比试。")

				callback(fightLayer, eventType,...)
			end
		end
	)
end

function Role:obConsult(role)
	if self:getAttr("id") ~= role:getAttr("teacherId") then
		RichPrint("main", "["..self:getName().."]一惊，说道：请教？这怎么敢当？！")
	else
		local cloneTeacher = Helper:tableCover(Role:create(),self)
		cloneTeacher:setAttr("skills",cloneTeacher:getAttr("tSkills"))

		MainControllLayer:pushLayer("SkillInfoLayer")
		local skillInfoLayer = MainControllLayer:getLayer("SkillInfoLayer")
		skillInfoLayer:setTeacherRole(cloneTeacher)
		skillInfoLayer:showTeacherSkillInfoPresenter()
	end
end

function Role:obKill(role)
	self:toTalk("你的战斗力只有5, 我不想杀生.")
end

-- 战斗相关开场白
function Role:getFightPrologue(target, type)
	local mChengHu, tChengHu = self:getFightChengHu(target, type)

	if self.sex ~= "野兽" and target.sex ~= "野兽" then
		if type == "切磋" then
			return "$N对着$n说道："..tostring(mChengHu).."我想领教一下阁下的高招！"
		end


		if self.exp > target.exp then
			if target.zhengqi < -10000 then
				return "$N对着$n啐了一口："..tostring(tChengHu).."！怪你生不逢时，"..tostring(mChengHu).."今天看你极不顺眼，认命吧！"
			else
				return "HIY$N对着$n吼道："..tostring(tChengHu).."！你记好"..tostring(mChengHu).."的名字，死后到阴司去告我一状吧！！"
			end
		else
			if target.zhengqi < -10000 then
				return "HIW$N对着$n猛吼一声："..tostring(tChengHu).."！明年的今天就是你的祭日，让"..tostring(mChengHu).."送你上路吧！"
			else
				return "RED$N对着$n喝道："..tostring(tChengHu).."！你死期已到，今天就让"..tostring(mChengHu).."送你上西天吧！"
			end
		end
	else
		if type == "切磋" then
			return "$N大喝一声，开始对$n发动攻击！"
		end
		return "$N大吼一声，猛然扑向$n，看来是要将$p打败！"
	end
end

-- 战斗称呼
function Role:getFightChengHu(target, type)
	if not target or not type then
		assert(nil, "Role:getFightChengHu(target, type) -> nil value")
	end
	if not self.chengHuDesc then
		self.chengHuDesc = assert(require("script.role.chenghu"))
	end

	local mSex, tSex = self:getAttr("sex"), target:getAttr("sex")
	local mAge, tAge = self:getAttr("age"), target:getAttr("age")
	local mChengHu, tChengHu = self:getName(), target:getName()

	local mChengHuDesc, tChengHuDesc = self.chengHuDesc["自我称呼"], self.chengHuDesc["NPC称呼玩家"]
	for k,v in pairs(mChengHuDesc) do
		if mSex ~= "男" and mSex ~= "女" then
			mChengHu = "公公"
		elseif mSex == v.sex and string.find(v.menpai, self:getFamilyId()) ~= nil and ((v.logic == "大于" and mAge > v.age) or (v.logic == "小于" and mAge <= v.age)) then
			if type == "切磋" then
				mChengHu = v.modestName
			else
				mChengHu = v.myName
			end
		end
	end

	for k,v in pairs(tChengHuDesc) do
		if tSex ~= "男" and tSex ~= "女" then
			tChengHu = "公公"
		elseif tSex == v.sex and string.find(v.menpai, target:getFamilyId()) ~= nil and ((v.logic == "大于" and tAge > v.age) or (v.logic == "小于" and tAge <= v.age)) then
			if type == "切磋" then
				tChengHu = v.chenghu
			else
				tChengHu = v.scornName
			end
		end
	end
	return mChengHu, tChengHu
end

-- 获取准备内功等级以及系数
function Role:getNeiLiLvAndFactor()
	return self:getSkillLvAndFactor("neigong", "neili")
end

--获取打坐内力回复速度 (每秒)
function Role:getNeiLiSpeed()
	local dengJi, xiShu = self:getNeiLiLvAndFactor()
	local speed
	if not xiShu or not dengJi or type(xiShu) ~= "number" or type(dengJi) ~= "number" then
		speed = 0
	else
		local cLv =  self:getSkillLv("changshengjueyang")
		if cLv >= 600 then
			speed = (dengJi * xiShu * 0.0015 + 5) * (1 + 0.005 * self:getEffectCon()) * (1 +cLv/5000)
			if PRINT_MODE == 1 then
				print("长生诀.阳 打坐速度加快，每秒："..speed)
			end
		else
			speed = (dengJi * xiShu * 0.0015 + 5) * (1 + 0.005 * self:getEffectCon())
		end
	end
	if not speed or type(speed) ~= "number" then
		speed = 0
	end

	-- 当前内力大于内力最大值时速度提升
	local neili, neiliMax = self:getAttr("neili"), self:getFinalAttr("neiliMax")
	if neili < neiliMax then
		local addSpeed = (1 + dengJi/600)
		if addSpeed >= 2 then
			addSpeed = 2
		end
		speed = speed * addSpeed
	end

	-- 在副本内打坐时,速度提升50%
	if self:getFlag("地图打坐") == true then
		speed = speed * 1.5
	end

	speed = self:getHuiFuSpeedRate() * speed

	local pointSwitchSkillAddValue = self:getDazuoAddition()
	speed = speed * (1 + pointSwitchSkillAddValue/100)

	if PRINT_MODE == 1 then
		print("当前内力增加量 = ", speed)
	end

	speed = speed * (1 + self:getBuffAttr("xingzhenNeiLi"))
	return speed
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/11 17:00:05
-- @desc 恢复内的速度加成效果 (长生诀 内力打坐速度提升 10%)
function Role:getHuiFuSpeedRate()
	local result, retRate = self:getSpecialSkillEffect(SKILL_TYPE_HUIFU)
	return retRate
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/06 14:30:18
-- @desc 获取技能特殊类型的特殊效果
function Role:getSpecialSkillEffect(stype)
	local result = false
	local retRate = 1 -- 加成系数,默认百分之百
	local skillList = self:getSkills()
	if stype == nil or MapIsEmpty(skillList) == true then
		return result, retRate
	end
	for skillId, roleSkill in pairs(skillList) do
		local skill = Skill:getSkill(skillId)
		if skill == nil then
			-- 为空出现了错误
			if PRINT_MODE == 1 then
				print("这个技能出现了问题,请检查资源文件", skillId)
			end
		else
			if skill.type == stype then
				local ret = switch(stype,
				{
					[SKILL_TYPE_HUIFU] = function()-- -- add by XiaoZhiWei 2017/02/11 17:04:43 暂时只有长生诀一个技能  提速百分之10
						local skillLv = self:getSkillLv(skillId)
						if skillLv <= 0 then
							return 1
						elseif skillLv <= 100 then
							return 1.1
						elseif skillLv <= 200 then
							return 1.2
						elseif skillLv <= 300 then
							return 1.3
						elseif skillLv <= 400 then
							return 1.4
						elseif skillLv <= 500 then
							return 1.5
						elseif skillLv > 500 then
							return 1.5
						else
							return 1
						end
					end,
					default = 1
				})
				if retRate < ret then
					retRate = ret
				end
				result = true
			else
				-- 不做任何处理
			end
		end
	end

	return result, retRate
end

-- 获取打坐内力上限
function Role:getNeiLiLimit()
	-- add by XiaoZhiWei 2018/03/10 18:26:40 很久未上限的玩家内力上限需要计算一次
	if self:getFinalAttr("neiLiLimit") <= 50 then
		self:calcNeiLiLimit()
	end

	--检测内力上限是否超过打坐内力上限
	if self:getAttr("neiliMax") > self:getFinalAttr("neiLiLimit") then
		self:setAttr("neiliMax",self:getFinalAttr("neiLiLimit"))
	end
	
	return Helper:getDef(self:getFinalAttr("neiLiLimit"), 50)
end

-- 获取属性中文名
function Role:getCHAttrName(attr)
	if not attr then
		return ""
	end

	-- 如果是货币id，度货币表
	local CurrencyUtil = require("app.models.Currency.CurrencyUtil")
	if CurrencyUtil:isCurrencyId(attr) then
		return CurrencyUtil:getCurrencyName(attr)
	end

	local tabs =
	{
		age = "年龄",
		sex = "性别",
		exp = "经验",
		pot = "潜能",
		money = "碎银",
		gold = "黄金",
		looks = "容貌",
		luck = "福缘",
		str = "臂力",
		int = "悟性",
		con = "根骨",
		dex = "身法",
		currStr = "臂力",
		currInt = "悟性",
		currCon = "根骨",
		currDex = "身法",
		secStr = "臂力",
		secInt = "悟性",
		secCon = "根骨",
		secDex = "身法",
		jing = "精力",
		jingMax = "最大精力",
		qi = "气血",
		qiMax = "气血最大值",
		neili = "内力",
		neiliMax = "内力最大值",
		lv = "等级",
		yuanbao = "元宝",
		weight = "背包容量",
		zhengqi = "侠义正气",
		kill = "杀死人数",
		yueli = "江湖阅历",
		killPlayer = "杀玩家数",
		weiwang = "江湖威望",
		dead = "死亡次数",
		meili = "风度魅力",
		deadReason = "上次死因",
		jindu = "江湖进度",
		lunhui = "轮回次数",
		mengjing = "梦境层数",
		panshi = "判师次数",
		qiPercent = "气血上限",
		decorativeLimit = "装饰箱容量",
		meridianExp = "经脉经验",
		breathVal = "真气",
		leftRightFightExp = "左右互搏熟练度",
		meiyu = "江湖美誉",
		gongxiandian = "师门贡献点",
		yinpiao = "银票",
		zjjifen = "战绩积分",
		prestige = "师门声望",
		intimacy = "亲密度",
		dreamCoins = "梦境币",
		dreamPoints = "碎银",
		jiaozi = "游字令",
		emotion = "情绪",
		sober = "清醒值",
		pijuan = "疲倦值",
		zhounianqin_jf = "新春礼券",	--对应原礼券商人货币
		zhounianliquan = "七夕礼券",	--周年礼券商人货币（徐念祖）
		daily_point = "积分",
		mingbi = "冥币",
		baoyu = "宝玉",
		spcl = "饰品材料",
		yxjianghuling1 = "江湖令",
		dreamYiYu = "梦内呓语",
		xiangnang = "香囊",
		zongheng = "雪矾",
		molizhu = "墨璃珠",
		anecdote = "轶闻",
		amartial = "武学要领",
		bmartial = "武学心得",
		cmartial = "武学至极",
		dmartial = "功法学识",
		baiduo = "白堕",
		canghuangling = "苍黄令",
		xizhaoling = "昔朝令",
		minditem1 = "清心散",
		minditem2 = "谧心丸",
		minditem3 = "凝心露",
		minditem4 = "聚心丹",
		miyao = "密钥",
		guanyingquan = "观影券",
		zhounianjf = "丹青",
		accpoint = "固身元气",
		characterPoint = "特性见解",
		lianGongTiLi = "笃志",
		ningshendan = "凝神丹",
		reputation = "个人功绩",
		diligent = "勤建之志",
		sgbpoint = "贡献昌盛度",
		gbpoint = "师门昌盛度",
		renown = "资历",
		bmaterials1 = "三合土",
		bmaterials2 = "青石砖",
		bmaterials3 = "楠木",
		bmaterials4 = "汉白玉",
		bmaterials5 = "琉璃瓦",
		bmaterials6 = "生漆",
		donate = "佳绩",
		featscount = "名绩点",
		paymaskmake = "鹿胶",
		ygpill = "养真丹",
		guidancecount = "师门指点次数"
	}
	return Helper:getDef(tabs[attr], "")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/20 10:33:35
-- @desc 计算打坐内力上限 onlyBaseValue 只获取基础的数值
function Role:calcNeiLiLimit(onlyBaseValue)
	-- 只获取基础的数值，不添加其他加成
	if onlyBaseValue == nil then
		onlyBaseValue = false
	end

	local lv = self:getSkillLv("jibenneigong")

	local daZuoMax
	if not lv or type(lv) ~= "number" then
		daZuoMax = 50
	else
		--打坐内力上限 = (玩家基本内功等级 * 10) * (2 + 0.01 * 等效根骨 + 0.003 * 等效臂力 + 0.003 * 等效身法)
		daZuoMax = (lv * 10) * (2 + (0.01 * self:getEffectCon())+(0.003 * self:getEffectStr())+(0.003 * self:getEffectDex()))
	end
	if not daZuoMax or type(daZuoMax) ~= "number" or daZuoMax < 50 then
		daZuoMax = 50
	end

	if onlyBaseValue then
		return daZuoMax
	end
	self:setAttr("neiLiLimit", daZuoMax)
end

-- 判断是否能够打坐
function Role:canDaZuo()
	local neiliMax, neili = math.floor(self:getFinalAttr("neiliMax")), self:getNumAttr("neili")
	-- 判断内力最大值，上限，当前内力值
	if Helper:mathFloor(neiliMax) >= Helper:mathFloor(self:getNeiLiLimit()) and neili >= 2 * neiliMax then
		self:setAttr("neili", 2 * neiliMax)
		self:setAttr("neiliMax", self:getNeiLiLimit())
		self:stopDaZuo()
		RichPrint("main", "你运功完毕，站了起来。")
		return false
	end
	return true
end

-- 打坐
function Role:daZuo(func)
	local currTime = GetTime()
	local startTime = self:getFlag("打坐时间")
	local duration = currTime - startTime
	OfflineProfit:setBeforeStatus("neiliMax", self:getFinalAttr("neiliMax"))
	if startTime ~= 0 then
		-- 累加计算过程
		local neiLiRevSpeed = self:getNeiLiSpeed() * duration
		local neili, neiliMax = self:getAttr("neili"), math.floor(self:getFinalAttr("neiliMax"))
		neili = neili + neiLiRevSpeed
		-- 记录内力最大值的增加量
		local upNeiLiMax = 0
		-- 副本打坐，不能突破上限，只能恢复内力值
		if self:getFlag("地图打坐") == true and neili >= neiliMax * 2 + 1 then
			duration = ((neiliMax * 2) - self:getAttr("neili")) / self:getNeiLiSpeed() -- 重新计算时间差  内力最大值的两倍,减去当前内力值(该时刻内力值还未发生变化),再除以内力回复速度,得到时间差
			neili = neiliMax * 2
			self:setAttr("neili", neili)
			self:setAttr("neiliMax", neiliMax)
			self:setFlag("地图打坐", nil)
			self:stopDaZuo()
		elseif self:getBuffAttr("xingzhenDaZuo") >= 1 then
			PopText("受行针走穴影响，暂时无法打坐运功。")
			self:stopDaZuo()
		else
			-- 如果有超出则停止（方法内部已做停止处理）
			if self:canDaZuo() == true then
				-- 离线收益计算
				while neili >= neiliMax * 2 + 1 do
					neili = neili - neiliMax
					neiliMax = neiliMax + 1
					upNeiLiMax = upNeiLiMax + 1
				end

				-- 最大值增加量大于0时，代表内力有所提升
				if upNeiLiMax > 0 then
					RichPrint("main", "你的内力修为增加了！")
					if func then
						func(neili, neiliMax)
					else
					end
				else
				end

				-- 收益计算完后需再次判断内力最大值是否超出上限
				if self:getNeiLiLimit() < neiliMax then
					upNeiLiMax = upNeiLiMax - (neiliMax - self:getNeiLiLimit())

					local addNeiLi = ((upNeiLiMax + 2) * self:getNeiLiLimit())
					for i = upNeiLiMax - 1, 1, -1 do
						addNeiLi = addNeiLi - i * 2
					end
					addNeiLi = addNeiLi - self:getAttr("neili")
					duration = addNeiLi / self:getNeiLiSpeed()

					self:setAttr("neiliMax", self:getNeiLiLimit())
					self:setAttr("neili", Helper:mathFloor(self:getNeiLiLimit())* 2)
					RichPrint("main", "你运功完毕，站了起来。")
					self:stopDaZuo()
				else
					self:setAttr("neili", neili)
					self:setAttr("neiliMax", neiliMax)
					self:setFlag("打坐时间", GetTime())
					self:setRoleCurrState(ROLE_CURR_STATE_DAZUO)
				end
			else
			end
		end

		self:setGamingTime(startTime + duration)
	else
		-- 第一次调用，初始化状态
		self:setFlag("打坐时间", GetTime())
		self:setRoleCurrState(ROLE_CURR_STATE_DAZUO)

	    -- 数据记录
		-- self:saveInfo("DaZuo", "start",
		-- 	{
		-- 		["状态"] = "开始",
		-- 		["时间"] = GetTime()
		-- 	}
		-- )
	end
	OfflineProfit:setAfterStatus("neiliMax", self:getFinalAttr("neiliMax"), "内力上限")
end

function Role:stopDaZuo()
	self:setFlag("打坐时间", nil)
	self:removeRoleCurrState(ROLE_CURR_STATE_DAZUO)

    -- 数据记录
	-- self:saveInfo("DaZuo", "stop",
	-- 	{
	-- 		["状态"] = "结束",
	-- 		["时间"] = GetTime()
	-- 	}
	-- )
end

--判断是否服用静心丸
function Role:getStatusByName(jingxinwan)
	if not jingxinwan then
		return nil
	end
	local num = User:getRole():getFlag(jingxinwan)
	if num then
		return num
	end
	return nil
end

-- 闭关
function Role:biGuan()
	local currSkillId = self:getFlag("当前武功")
	if currSkillId == 0 then
		self:stopBiGuan()
		return
	end
	local currTime = GetTime()

	-- -- -- 网络判断
	-- -- if NETWORK_STATE == 0 then
	-- -- 	currTime = startTime + RoleConstans.theSecondOfOneHour -- 一小时数据
	-- -- end
	local startTime = self:getFlag("闭关时间")
	local duration = currTime - startTime
	local remainingTime = 60
	if self:getFlag("闭关时长") ~= 0 then
		remainingTime = self:getFlag("闭关时长") * RoleConstans.theSecondOfOneHour
	end

	if startTime ~= 0 and duration >= remainingTime then
		self:stopBiGuan()
	else
		self:setRoleCurrState(ROLE_CURR_STATE_BIGUAN)
	end
end

-- 闭关成功率计算
function Role:biGUanRate(skillLv,skillId)
	if skillLv == nil then
		return 0, 0, 100
	end
	
	local succRate, failRate, monsterRate = 0, 0, 100

	if skillLv <= 300 then
		succRate = (0.9 - skillLv/2000)*100
		failRate = (0.05 + skillLv/2000)*100
		monsterRate = 0.05*100
	elseif skillLv <=500 and skillLv > 300 then
		succRate = (0.75 - (skillLv - 300)/2000*3)*100
		failRate = (0.2 + (skillLv - 300)/2000*2.5)*100
		monsterRate = (0.05 + (skillLv - 300)/2000*0.5)*100
	elseif skillLv >500 and skillLv <= 700 then
		succRate = (0.45-(skillLv-500)/2000*1.5)*100
		failRate = (0.45+(skillLv-500)/2000*0.5)*100
		monsterRate = (0.1+(skillLv-500)/2000)*100
	elseif skillLv>700 and skillLv <= self:getSkillLvLimit(skillId) then
		succRate = (0.3-(skillLv-700)/2000)*100
		failRate = (0.5+(skillLv-700)/2000*2/3)*100
		monsterRate = (0.2+(skillLv-700)/2000/3)*100
	end
	
	local function mathData(data)
		if data - math.floor(data) > 0.5 then
			data = math.ceil(data)
		else
			data = math.floor(data)
		end
		return data
	end
	succRate = mathData(succRate)
	failRate = mathData(failRate)
	monsterRate = mathData(monsterRate)

	return succRate, failRate, monsterRate
end

-- 停止闭关
function Role:stopBiGuan()
	local Meridian = require("app.models.Meridian.Meridian")
	local currSkillId = self:getFlag("当前武功")
	if currSkillId == 0 then
		self:setFlag("jingxinwan",nil)
		self:setFlag("闭关时间", nil)
		self:setFlag("闭关加成", nil)
		self:removeRoleCurrState(ROLE_CURR_STATE_BIGUAN)
	    -- 数据记录
		-- self:saveInfo("BiGuan", "stop",
		-- 	{
		-- 		["状态"] = "结束",
		-- 		["时间"] = GetTime(),
		-- 		["武功"] = "空",
		-- 		["状况"] = "出现了异常"
		-- 	}
		-- )
		return
	end
	local roleSkill = self:getSkill(currSkillId)
	-- local skill, skillLv = Skill:getSkill(roleSkill.id), Skill:getLv(roleSkill.exp)
	local skill = Skill:getSkill(roleSkill.id)
	local skillLv 

	skillLv = self:getSkillLv(currSkillId)

	local currTime, startTime = GetTime(), self:getFlag("闭关时间")
	--NEEDTODO 状态Id
	local lv = 0

	RichPrint("main", "HIW只见你头上白雾腾腾、浑身\n如同笼罩在云中，看来已经到了三花聚顶、\n五气朝元、龙虎相济、天人交会的紧要关头！")

	--成功率、失败率、走火入魔率的计算
	local succRate, failRate, monsterRate = self:biGUanRate(skillLv,currSkillId)

	local duration = currTime - startTime
	local remainingTime = 60
	if self:getFlag("闭关时长") ~= 0 then
		remainingTime = self:getFlag("闭关时长") * RoleConstans.theSecondOfOneHour
	end
	if duration >= remainingTime then
		local addTb = switch(self:getFlag("闭关时长"),
		{
			[1] = {10, -7, -3},			--1小时 增加10%成功率 对应走火入魔-3% 失败-7%
			[4] = {20, -14, -6},		--4小时 增加20%成功率 对应走火入魔-6% 失败-14%
			[8] = {30, -21, -9}, 		--8小时 增加30%成功率 对应走火入魔-9% 失败-21%
			[12] = {40, -28, -12},		--12小时 增加40%成功率 对应走火入魔-12% 失败-28%
			[16] = {50, -35, -15}, 		--16小时 增加50%成功率 对应走火入魔-15% 失败-35%
			[24] = {60, -42, -18}, 		--24小时 增加60%成功率 对应走火入魔-18% 失败-42%
			[36] = {70, -49, -21}, 		--36小时 增加70%成功率 对应走火入魔-21% 失败-49%
			[48] = {80, -56, -24},  	--48小时 增加80%成功率 对应走火入魔-24% 失败-56%
			[72] = {90, -63, -27}, 		--72小时 增加90%成功率 对应走火入魔-27% 失败-63%
			default = {0, 0, 0},
		})
		succRate = succRate + addTb[1]
		failRate = Helper:getRange(failRate + addTb[2], 0, 100)
		monsterRate = Helper:getRange(monsterRate + addTb[3], 0, 100)

		duration = remainingTime -- 修正时间差
	end

	-- 基本内功特殊处理
	-- 记录当前武功是否是基本内功
	local list = switch(currSkillId,
	{
		jibenneigong = {success = 5, failed = 1, monster = -5}, -- 基本内功
		default = {success = 10, failed = 5, monster = -5}      -- 默认情况
	})

	local percent = math.random(1, 100)
	local function getAddLv(num)
		local addLv = 0
		if num ~= nil and num ~= 0 then
			succRate = Helper:getRange(succRate + tonumber(num), 0, 100)
			if percent <= succRate then
				addLv =  list.success
			else
				addLv =  list.failed
			end
		else
			if percent <= succRate then           --成功的
				addLv = list.success
			-- elseif 0 < (percent - succRate) and (percent - succRate) <= failRate then
			elseif percent > succRate + failRate  then -- 走火入魔的
				addLv = list.monster
			else                                  --失败的
				addLv =  list.failed
			end
		end

		--提前出关 直接失败
		if currTime - (startTime + remainingTime) < 0 then
			addLv = list.failed
		end
		return addLv
	end


	--是否服用静心丸的处理
	local num = self:getStatusByName("jingxinwan")
	lv = getAddLv(num)

	-- 完美出关 普通出关 走火入魔状态
	local status
	if lv == list.success then
		RichPrint("main", "HIG你顿时觉得浑身一阵轻松，一股清凉之意油然\n而起，心灵一片空明，内力没有丝毫阻滞，舒泰之极。\n恭喜你经过闭关苦修，自身修为又有所突破。\n你的["..skill.name.."]进步了！")
		status = "success"
	elseif lv == list.failed then
		RichPrint("main", "HIY你感觉丹田中的内力聚而复散，不论你如何集中心神，也难以控制。\nHIY最终你轻轻叹了一口气，缓缓的睁开眼。")
		RichPrint("main", "CYN你闭关结束，进展没有想象中的那么大。")
		status = "failed"
	else
		RichPrint("main", "HIR你觉得内力在丹田源源而生，不断\n冲击诸处大穴，浑身燥热难当，几欲大声呼喊。\n你把持不住，意念一松，顿时失去理智，已然走火入魔。")
		RichPrint("main" , "HIY你因为走火入魔了损伤了经脉，武学修为降低了！")
		status = "monster"
	end

	-- 判断是否能够升级
	do
		-- 1 不能超过角色自身等级
		local roleLv = self:getLv()
		if skillLv + lv > roleLv then
			lv = roleLv - skillLv
		end

		-- 2 不能超过基本内功等级
		if currSkillId ~= "jibenneigong" then
			local jbSkillLv = self:getSkillLv("jibenneigong")
			-- local jbSkillLv = Skill:getLv(self:getSkill("jibenneigong").exp)
			if skillLv + lv > jbSkillLv then
				lv = jbSkillLv - skillLv
			end
		else
			if skillLv + lv >= self:getSkillLvLimit(currSkillId) then
				lv = self:getSkillLvLimit(currSkillId) - skillLv
			end
		end

		local function getFailedLv()
			-- 1 不能超过角色自身等级
			local roleLv = self:getLv()
			local canAddLv = list.success
			if skillLv + list.success > roleLv then
				canAddLv = roleLv - skillLv
			end

			-- 2 不能超过基本内功等级
			if currSkillId ~= "jibenneigong" then
				local jbSkillLv = self:getSkillLv("jibenneigong")
				-- local jbSkillLv = Skill:getLv(self:getSkill("jibenneigong").exp)
				if skillLv + list.success > jbSkillLv then
					canAddLv = jbSkillLv - skillLv
				end
			else
				if skillLv + list.success >= self:getSkillLvLimit(currSkillId) then
					canAddLv = self:getSkillLvLimit(currSkillId) - skillLv
				end
			end
			return math.min(canAddLv, list.failed)
		end

		if status == "failed" then
			lv = getFailedLv()
		end
		
		-- 修复:防止超出限制范围
		lv = Helper:getRange(lv, list.monster, list.success)
	end

	self:addSkillLv(currSkillId, lv)

 --    -- 数据记录
	-- self:saveInfo("BiGuan", "stop",
	-- 	{
	-- 		["状态"] = "结束",
	-- 		["时间"] = GetTime(),
	-- 		["武功"] = currSkillId,
	-- 		["武功准备类型"] = self:getFlag("武功准备类型"),
	-- 		["时长"] = self:getFlag("闭关时长"),
	-- 		["闭关实际时长"] = remainingTime,
	-- 		["已用时长"] = duration,
	-- 		["静心丸"] = num,
	-- 		["增加等级"] = lv,
	-- 		["完美出关"] = succRate,
	-- 		["当前随机数"] = percent,
	-- 		["普通出关"] = failRate,
	-- 		["走火入魔"] = monsterRate,
	-- 		["当前等级"] = Skill:getLv(self:getSkill(currSkillId).exp)
	-- 	}
	-- )

	self:setFlag("闭关结果", status)
	self:setFlag("jingxinwan",nil)
	self:setFlag("闭关时间", nil)
	self:setFlag("闭关时长", nil)
	self:setFlag("闭关加成", nil)
	self:setFlag("当前武功", nil)
	self:setFlag("武功准备类型", nil)
	self:removeRoleCurrState(ROLE_CURR_STATE_BIGUAN)

	self:setGamingTime(startTime + duration) -- 更新玩家年龄

	-- 经脉印记效果
	-- 闭关练功时，有几率获得阅历
	if self:isHaveImprintingId("xiushenyijn") then
		if math.random(1, 10) == 1 then
			print("闭关练功时，有几率获得阅历")
			local meridianBuffValue = Meridian:getMeridianBuffValue("xiushenyijn")
			meridianBuffValue = string.split(meridianBuffValue,";")
			local minValue = tonumber(meridianBuffValue[1])
			local maxValue = tonumber(meridianBuffValue[2])
			local val = math.random(minValue, maxValue)
			PopText("阅历 + " .. val)
			self:addAttr("yueli", val)
			RichPrint("main", "HIC在幽深飘忽的闭关冥想中，你心游万仞、思接千载，不知不觉阅历也增加了一些。")
		end
	end

	-- 闭关练功时，有几率获得潜能
	if self:isHaveImprintingId("xiumingyin") then
		if math.random(1, 10) == 1 then
			print("闭关练功时，有几率获得潜能")
			local meridianBuffValue = Meridian:getMeridianBuffValue("xiumingyin")
			meridianBuffValue = string.split(meridianBuffValue,";")
			local minValue = tonumber(meridianBuffValue[1])
			local maxValue = tonumber(meridianBuffValue[2])
			local val = math.random(minValue, maxValue)
			PopText("潜能 + " .. val)
			self:addAttr("pot", val)
			RichPrint("main", "HIC在幽深飘忽的闭关冥想中，你动心忍性、闭气凝神，不知不觉间潜能也增加了一些。")
		end
	end

	-- 闭关练功时，有几率获得经验
	if self:isHaveImprintingId("xiutiyin") then
		if math.random(1, 10) == 1 then
			print("闭关练功时，有几率获得经验")
			local meridianBuffValue = Meridian:getMeridianBuffValue("xiutiyin")
			meridianBuffValue = string.split(meridianBuffValue,";")
			local minValue = tonumber(meridianBuffValue[1]) 
			local maxValue = tonumber(meridianBuffValue[2])
			local val = math.random(minValue, maxValue)
			PopText("经验 + " .. val)
			self:addAttr("exp", val)
			RichPrint("main", "HIC在幽深飘忽的闭关冥想中，你上下求索、搜肠刮肚，不知不觉间经验也增加了一些。")
		end
	end

end

-- -- 练功
function Role:lianGong()
	--NEEDTODO 练功时长暂为1小时  精力消耗，1分钟2点  练功经验增长 1小时 200*潜能转换率
	local currSkillId = self:getFlag("当前武功")
	local jing = self:getAttr("jing")

	-- 精力和当前武功条件不满足时 停止练功
	if currSkillId == 0 or jing < 1 then
		self:stopLianGong()
		return
	end

	-- 统计离线收益
	OfflineProfit:setBeforeStatus("skillLv", self:getSkillLv( currSkillId ))

	--　时间
	local currTime = GetTime()
	local startTime = self:getFlag("练功时间")
	local duration = currTime - startTime

	local num = User:getRole():getFlag("xinggongsan")
	local xTime = 0
	if num then
		duration = duration + num * RoleConstans.theSecondOfOneHour
		xTime = num
		User:getRole():setFlag("xinggongsan",0)
	end
	-- 初始化
	if startTime <= 0 then
		self:setFlag("练功时间", GetTime())
		self:setFlag("精力回复时间", GetTime())
		self:setRoleCurrState(ROLE_CURR_STATE_LIANGONG)
		duration = 0
	end

	-- NEEDTODO 判断技能限制条件
	local roleSkill = self:getSkill(currSkillId)
	local skill = Skill:getSkill(currSkillId)
	local subJing = 2/60*duration
	local addExp = RoleConstans.theFactorOfSkill * skill:getPotEfficiency(self)/RoleConstans.theSecondOfOneHour*duration
	local needStop = false

	--@desc 长生诀.阳 提高练功速率
	local cLvy =  self:getFlag("练功长生诀等级",0)
	local num1 = 0
	if cLvy >= 600 then
		num1=1 - math.pow(cLvy / 2000,2)
		num1 = num1 * 100
		if num1 % 1 >= 0.5 then 
			num1=math.ceil(num1)
		else
			num1=math.floor(num1)
		end
		addExp = addExp * (1 + (1- num1 * 0.01))
		subJing = subJing * (1 + (1- num1 * 0.01))
	end
	
	-- 修正离线收益超出问题
	if subJing > jing then
		subJing = jing
		duration = jing * 30
		addExp = RoleConstans.theFactorOfSkill * skill:getPotEfficiency(self)/RoleConstans.theSecondOfOneHour*duration
		if cLvy >= 600 then
			duration = duration * (1 - (1- num1 * 0.01))
			-- addExp = addExp * (1 + (1- num1 * 0.01))
		end
		needStop = true
	else
		-- 走基本处理逻辑
	end

	--学习长生诀后，练功可增长其经验
	local cLv = 0
	local addCSJExp = 0
	local csjSkillinfo =  self:getSkill("changshengjueyang") or self:getSkill("changshengjueyin")
	if csjSkillinfo ~= nil then
		--@RefType [app.models.skill.BaseSkill#BaseSkill]
		local csjSkill = Skill:getSkill(csjSkillinfo.id)

		cLv = self:getSkillLv(csjSkillinfo.id)
		local roleSkillExp = self:getSkillExp(csjSkillinfo.id)
		if cLv >= 600 then
			addCSJExp = RoleConstans.theFactorOfSkill * csjSkill:getPotEfficiency(self) * (cLv / 2000) / RoleConstans.theSecondOfOneHour * duration
			local maxExp = self:conversionSkillExpAndLv("exp", self:getSkillLvLimit(csjSkillinfo.id))
			if roleSkillExp + addCSJExp > maxExp then
				addCSJExp = maxExp - roleSkillExp
			end
			self:addSkillExp(csjSkillinfo.id, addCSJExp)
		end

		if PRINT_MODE == 1 then
			print("练功增加长生诀经验 ： " .. addCSJExp)
		end
	end

	-- 基本处理
	local state, totalExp = self:checkCanLevelUp(currSkillId, roleSkill.exp + addExp)
	-- 能正常升级
	local ret = true
	if state == true then
		addExp = totalExp - roleSkill.exp
		ret = self:addSkillExp(currSkillId, addExp)
		-- roleSkill.exp = totalExp
		-- self:setSkill(currSkillId, roleSkill)
	else
		-- 不能正常升级，并且当前技能等级小于基本功法等级
		if totalExp ~= nil and roleSkill.exp < totalExp then

			-- 情况处理
			--[[
				消耗 100 精力，由于升级限制，只能添加一半，另一半的精力需退还给玩家
				公式 ： 增加经验值 = （200 * 潜能转化率） / （RoleConstans.theSecondOfOneHour * duration)
				精力消耗 一分钟两点  30秒 一点
			]]
			do
				duration =  (RoleConstans.theFactorOfSkill * skill:getPotEfficiency(self)) / (RoleConstans.theSecondOfOneHour * math.ceil(totalExp - roleSkill.exp))  -- totalExp - roleSkill.exp 实际增加精力
				subJing = duration / 30
				if cLvy >= 600 then
					duration = duration * (1 - (1- num1 * 0.01))
				end
			end

			addExp = totalExp - roleSkill.exp

			ret = self:addSkillExp(currSkillId, addExp)
			
			RichPrint("main", "你的基本功法火候不足")
			-- roleSkill.exp = totalExp
			-- self:setSkill(currSkillId, roleSkill)
		else
			-- 武功未准备或当前武功不存在或者由于BUG经验已经超出
		end
		needStop = true
	end

	-- 经验加成失败 停止练功
	if ret == true then
	else
		self:stopLianGong()
		return
	end

	-- 计算实际消耗精力
	self:addAttr("jing", -subJing)


	-- 判断是否需要停止练功
	if needStop == true then
		self:stopLianGong()
	else
		-- 每次更新时间及状态
		self:setFlag("练功时间", GetTime())
		self:setRoleCurrState(ROLE_CURR_STATE_LIANGONG)
	end
	duration = Helper:getRange(duration - RoleConstans.theSecondOfOneHour * xTime, 0) 
	self:setFlag("精力回复时间", duration + startTime)

	self:setGamingTime(duration + startTime) -- 更新角色年龄

	-- 统计离线收益
	OfflineProfit:setAfterStatus("skillLv", self:getSkillLv( currSkillId ), tostring(skill.name).."武功等级")
end

function Role:stopLianGong()
	self:setFlag("练功长生诀等级", nil)
	self:setFlag("练功时间", nil)
	self:setFlag("当前武功", nil)
	self:setFlag("武功准备类型", nil)
	self:setFlag("精力回复时间", GetTime())
	self:setFlag("精力开始回复时间", GetTime())
	self:removeRoleCurrState(ROLE_CURR_STATE_LIANGONG)
end

--修炼
local xiulian_stop = false --判断是否停止修炼
function Role:xiuLian()
	if xiulian_stop == true then 
		return
	end
	--NEEDTODO 练功时长暂为1小时  精力消耗，1分钟2点  练功经验增长 1小时 200*潜能转换率
	local xiuLianData = self:getAttr("xiuLianData")
	if MapIsEmpty(xiuLianData) then 
		return
	end
	local currSkillId = xiuLianData.skillId
	
	local jing = self:getAttr("jing")
	local skillType = self:getFlag("武功修炼类型")
	-- 精力和当前武功条件不满足时 停止练功
	if not currSkillId  or jing < 1 then
		self:stopXiuLian()
		return
	end

	-- 统计离线收益
	OfflineProfit:setBeforeStatus("skillLv", self:getSkillLv( currSkillId ))

	--　时间
	local currTime = GetTime()
	local startTime = xiuLianData.startTime
	local duration = currTime - startTime
	local maxDuration = xiuLianData.endTime - startTime
	
	if maxDuration <= 0 then  --防止出现收益已结算状态未改变重复获得收益
		self:stopXiuLian()
		return
	end
	-- 初始化
	if duration <= 0 then
		self.xiuLianData["startTime"] = GetTime()
		self:setFlag("精力回复时间", GetTime())
		self:setRoleCurrState(ROLE_CURR_STATE_XIULIAN)
		duration = 0
	end
	
	if duration >= maxDuration then  --离线处理 控制时间不超过修炼时间
		duration = maxDuration
	end

	local SkillXiuLianUtil = require("app.models.skill.SkillXiuLianUtil")
	local expBuff = SkillXiuLianUtil:getRoleItemExpBuff(xiuLianData.jjId)
	local jingBuff = SkillXiuLianUtil:getRoleItemJingBuff(xiuLianData.jjId)

	-- NEEDTODO 判断技能限制条件
	local roleSkill = self:getSkill(currSkillId)
	local skill = Skill:getSkill(currSkillId)
	local subJing = 2/60  --速率
	local addExp = RoleConstans.theFactorOfSkill * skill:getPotEfficiency(self)/RoleConstans.theSecondOfOneHour --速率

	local csjExpBuff,csjJingBuff= 0,0
	--@desc 长生诀.阳 提高练功速率
	local cLvy =  self:getFlag("练功长生诀等级",0)
	local num1 = 0
	if cLvy >= 600 then
		num1=1 - math.pow(cLvy / 2000,2)
		num1 = num1 * 100
		if num1 % 1 >= 0.5 then 
			num1=math.ceil(num1)
		else
			num1=math.floor(num1)
		end
		csjExpBuff = 1- num1 * 0.01
		csjJingBuff = 1- num1 * 0.01

	end
	
	addExp = addExp * (1 + expBuff + csjExpBuff)
	subJing = subJing * (1 + jingBuff + csjJingBuff)

	local jingMaxTime = jing / subJing --精力可支持最大修炼时间

	if duration > jingMaxTime then 
		duration = jingMaxTime
	end
	-- 防止相关因素影响速率导致提前达到上限而时间未结束
	local state, totalExp = SkillXiuLianUtil:checkCanLevelUp(currSkillId,roleSkill.exp + addExp * duration,xiuLianData.jjId,skillType)
	if state == false then 
		local actualExp = totalExp - roleSkill.exp
		duration = actualExp/addExp
		if duration > jingMaxTime then 
			duration = jingMaxTime
		end
	end

	if PRINT_MODE == 1 then 
		print("csjExpBuff:",csjExpBuff,"csjJingBuff:",csjJingBuff,"expBuff:",expBuff,"jingBuff:",jingBuff,"PotEfficiency:",skill:getPotEfficiency(self))
	end
	

	--学习长生诀后，练功可增长其经验
	local cLv = 0
	local addCSJExp = 0
	local csjSkillinfo =  self:getSkill("changshengjueyang") or self:getSkill("changshengjueyin")
	if csjSkillinfo ~= nil then
		--@RefType [app.models.skill.BaseSkill#BaseSkill]
		local csjSkill = Skill:getSkill(csjSkillinfo.id)

		cLv = self:getSkillLv(csjSkillinfo.id)
		local roleSkillExp = self:getSkillExp(csjSkillinfo.id)
		if cLv >= 600 then
			addCSJExp = RoleConstans.theFactorOfSkill * csjSkill:getPotEfficiency(self) * (cLv / 2000 )/RoleConstans.theSecondOfOneHour * duration
			local maxExp = self:conversionSkillExpAndLv("exp", self:getSkillLvLimit(csjSkillinfo.id))
			if roleSkillExp + addCSJExp > maxExp then
				addCSJExp = maxExp - roleSkillExp
			end
			self:addSkillExp(csjSkillinfo.id, addCSJExp)
		end

		if PRINT_MODE == 1 then
			print("练功增加长生诀经验 ： "..addCSJExp)
		end
	end

	duration = Helper:getRange(duration, 0) 

	local isAddExp = self:addSkillExp(currSkillId, addExp * duration)

	if isAddExp then  --收益只在经验加成功的时候计算
		-- 计算实际收益
		subJing = Helper:getRange(subJing * duration, 0)  
		self:addAttr("jing", -subJing)

		self.xiuLianData["durable"] = math.max(self.xiuLianData["durable"] - SkillXiuLianUtil:getXiuLianNeedDurable() * duration,0)
		if self.xiuLianData["durable"] <= 0.017 then --不足一秒所需耐久算零
			self.xiuLianData["durable"] = 0
		end 
		
		self:setFlag("精力回复时间", duration + startTime)

		self:setGamingTime(duration + startTime) -- 更新角色年龄
		
		self.xiuLianData["startTime"] = GetTime() --刷新开始时间
		
		-- 统计离线收益
		OfflineProfit:setAfterStatus("skillLv", self:getSkillLv( currSkillId ), tostring(skill.name).."武功等级")
	else
		self:stopXiuLian()
		return
	end

	-- 经验达到上限要求
	if state == false then 
		self:stopXiuLian()
		return
	end
	--达到修炼时间
	if xiuLianData.endTime < GetTime() then 
		self:stopXiuLian()
	end
end

function Role:stopXiuLian()
	self.xiuLianData["startTime"] = GetTime()
	xiulian_stop = true
	local SkillXiuLianUtil = require("app.models.skill.SkillXiuLianUtil")
	SkillXiuLianUtil:updateRoleItemInfo(function()
			xiulian_stop = false
		end)
end

function Role:stopGuaji()
	local roleTask = self:getAttr("tasks")[(self:getAttr("currTaskId"))]
	if roleTask and roleTask.state == TASK_STATE_GUAJI then
		roleTask.state = TASK_STATE_IDLE

		-- 设置成长速度
		self:setAttr("expIncrementSpeed", 0)
		self:removeRoleCurrState(ROLE_CURR_STATE_GUAJI)
	else
		if PRINT_MODE == 1 then
			print("该任务没有在挂机")
		end
	end
end

-- 设置开始观战
function Role:startGuanZhan(fid, startTime, endTime)
	self:setAttr("currWatchFid", fid)
	self:setFlag("观战时间", startTime)
	self:setFlag("观战结束时间", endTime)
	self:setRoleCurrState(ROLE_CURR_STATE_GUANZHAN)
end

-- 设置结束观战
function Role:stopGuanZhan(func,failed_func)
	if self:getAttr("currWatchFid") ~= nil and self:getFlag("观战时间") ~= 0 then
		-- NEEDTODO 网络请求异常或失败情况没处理
		local BiWu = require("app.models.BiWu.BiWu")
		BiWu:stopWatch(self:getAttr("currWatchFid"), self:getFlag("观战时间"),func,failed_func)
	else
		if failed_func then
			failed_func()
		end
	end
	self:setFlag("观战时间", nil)
	self:setFlag("观战结束时间", nil)
	self:removeRoleCurrState(ROLE_CURR_STATE_GUANZHAN)
end

--观战刷新
function Role:updateGuanZhan()

	-- 能否观战
	local function canGuanZhan(needMoney)
		if self:getAttr("money") < needMoney then
			PopText("金钱不够,不能观战")
			return false
		end

		return true
	end

	-- 计算潜能倍数
	local function calcBeiShu(fuYuan)
		local beiShu = 0
		if fuYuan == nil or type(fuYuan) ~= "number" or fuYuan <= 0 then
			return 1
		end
		-- 福缘小于20的时候不回出现 倍率暴击
		if fuYuan <= 20 then
			return 1
		end

		-- 倍数计算公式
		local percent = math.random(1, 100000)/100000
		if percent <= 1-math.min(0.6*(fuYuan-20), 24)*66/5000 then
			beiShu = 1
		elseif percent <= math.min(0.6*(fuYuan-20), 24)/100 then
			beiShu = 2
		elseif percent <= math.min(0.6*(fuYuan-20), 24)/500 then
			beiShu = 3
		elseif percent <= math.min(0.6*(fuYuan-20), 24)/1000 then
			beiShu = 4
		elseif percent <= math.min(0.6*(fuYuan-20), 24)/5000 then
			beiShu = 5
		else
		end
		return beiShu
	end

	-- 计算潜能
	local function calcQianNeng(exp, fuYuan)
		local qianNeng = 0
		if exp == nil or type(exp) ~= "number" or exp <= 0 then
			return 0
		end
		local randomNum = math.random(1, 9)
		local randomRate = calcBeiShu(fuYuan)
		-- 潜能计算公式
		if exp < 500000 then
			qianNeng = randomRate*29+randomNum
		elseif exp < 1000000 then
			qianNeng = randomRate*31+randomNum
		elseif exp < 5000000 then
			qianNeng = randomRate*34+randomNum
		elseif exp < 15000000 then
			qianNeng = randomRate*36+randomNum
		elseif exp < 20000000 then
			qianNeng = randomRate*40+randomNum
		elseif exp < 40000000 then
			qianNeng = randomRate*46+randomNum
		elseif exp < 60000000 then
			qianNeng = randomRate*50+randomNum
		elseif exp >= 60000000 then
			qianNeng = randomRate*54+randomNum
		else
		end
		return qianNeng
	end

	-- 获取基本技能列表
	local function getJiBenList(skillList, roleLv)
		local retList = {}
		if MapIsEmpty(skillList) == true or roleLv == nil or type(roleLv) ~= "number" or roleLv <= 0 then
			return nil
		end
		-- 循环角色技能列表
		for id,roleSkill in pairs(skillList) do
			if MapIsEmpty(roleSkill) == false then
				local skill = Skill:getSkill(id)
				local skillLv = self:getSkillLv(id)
				-- local skillLv = Skill:getLv(roleSkill.exp)
				-- 技能等级不能大于角色等级   技能等级不能大于500级  类型必须是基本类型
				if skillLv < roleLv and skillLv < 500 and skill.type == SKILL_TYPE_BASE then
					table.insert(retList, id)
				end
			end
		end
		return retList
	end
	local pot = 0
	local money = 0
	-- 增加潜能
	local function addPot()
		local needMoney = 25+math.random(-9, 9)
		if canGuanZhan(needMoney) ~= true then
			return false
		end

		local addPot = calcQianNeng(self:getAttr("exp"), self:getFinalAttr("luck"))
		local list = getJiBenList(self:getSkills(), self:getLv())
		-- 如果不存在可升级的基本功,则直接加潜能点
		if MapIsEmpty(list) == true then
			self:addAttr("pot", addPot)
		else
			-- 各自百分之50的几率
			if math.random(0, 1) == 0 then
				self:addAttr("pot", addPot)
			else
				local id = list[math.random(1, #list)]
				local ret = self:addSkillExp(id, addPot)
				-- 技能由于条件限制不能升级,则直接加潜能点
				if ret == true then
				else
					self:addAttr("pot", addPot)
				end
			end
		end
		self:addAttr("money", -needMoney)
		-- PopText("获得收益潜能点 "..tostring(addPot))
		-- PopText("扣除金钱 "..tostring(needMoney))
		pot = addPot
		money = needMoney

		---------保存这次观战的潜能和碎银
		---------累计这次观战的收益
		local BiWu = require("app.models.BiWu.BiWu")
		local fightAllData = BiWu:getfightAllData()
		if fightAllData.watchTotalPot and fightAllData.watchTotalMoney then
			fightAllData.watchTotalPot = fightAllData.watchTotalPot + addPot
			fightAllData.watchTotalMoney = fightAllData.watchTotalMoney + needMoney
			BiWu:savefightAllData(fightAllData)
		end
		return true
	end

	OfflineProfit:setBeforeStatusWithType("GZ", "pot", self:getAttr("pot"))
	OfflineProfit:setBeforeStatusWithType("GZ", "money", self:getAttr("money"))

	-- 观战收益计算,计算在线和离线收益
	local startTime = self:getFlag("观战时间")
	local endTime = self:getFlag("观战结束时间")
	-- 如果没有开始或者结束时间 停止观战
	if startTime == 0 or endTime == 0 then
		self:stopGuanZhan()
	else
		local currTime = GetTime()
		local duration 	-- 记录观战的时间差
		-- 当前时间和结束时间做比较,使用小的时间
		duration = math.min(endTime, currTime) - startTime
		-- 如果时间差是30的N倍
		while duration/30 >= 1 do
			-- if PRINT_MODE == 1 then
			-- 	PopText("duration/30 = "..tostring(duration/30))
			-- end
			-- 计算一次收益,并且时间差减少30秒
			if addPot() == true then
				duration = duration - 30
				self:setFlag("观战时间", math.min(endTime, currTime) - duration) -- 每一次收益,更新一次收益的获得时间
			else
				-- 离线收益超出或者条件不足无法获取收益,结束观战
				self:stopGuanZhan()
				break
			end
		end

		-- 如果当前时间大于结束时间,直接停止观战
		if currTime > endTime then
			self:stopGuanZhan()
		end

		self:setGamingTime(startTime + duration) -- 更新角色年龄
	end

	OfflineProfit:setAfterStatusWithType("GZ", "pot", self:getAttr("pot"), "潜能")
	OfflineProfit:setAfterStatusWithType("GZ", "money", self:getAttr("money"), "金钱")
	return pot,money
end

-- 调息
function Role:pranayama()
	local Meridian = require("app.models.Meridian.Meridian")
	if self:isInCurrState(ROLE_CURR_STATE_TIAOXI) ~= true then
		local currTime = GetTime()
		local endTime = currTime + Meridian:getPranayamaTime(self.meridianExp)
		self:setFlag("调息完成时间", endTime)
		self:setRoleCurrState(ROLE_CURR_STATE_TIAOXI)
		-- 调息统计
		local Record = require("app.models.Record.Record")
		Record:addRecordCount("jingmai", "event", "tiaoxi")
	end

	if GetTime() > self:getFlag("调息完成时间") then
		self:stopPranayama()
	end
end

-- 停止调息
function Role:stopPranayama()
	local Meridian = require("app.models.Meridian.Meridian")

	if self:isInCurrState(ROLE_CURR_STATE_TIAOXI)  then
		if GetTime() < self:getFlag("调息完成时间") then
			print("使用醒身丸提前结束调息")
			if self:getDayFlag("使用醒身丸") >= 5 then
				PopText("醒身丸使用已达到每日上限！")
				return false
			end
			if self:addItemCount("jingmai102", -1) then
				PopText("消耗醒身丸，结束调息")
				self:setDayFlag("使用醒身丸", self:getDayFlag("使用醒身丸") + 1)
				self:setFlag("调息完成时间", GetTime())
			else
				PopText("醒身丸数量不足")
				return false
			end
		end

		local meridianExp, breathVal = Meridian:getPranayamaReward(self.meridianExp)
		self:addAttr("meridianExp", meridianExp)
		self:addAttr("breathVal", breathVal)

		RichPrint("main", "HIC随着一股暖流流过，你感到自己体内的真气增加了。")
		RichPrint("main", "HIW获得真气 " .. Helper:getRoundNumber(breathVal) .. "!")
		RichPrint("main", "HIW获得经脉经验 " .. Helper:getRoundNumber(meridianExp) .. "!")

				
		self:setFlag("经脉加成", nil)
		self:setFlag("真气加成", nil)
		self:setFlag("调息完成时间", nil)
		self:removeRoleCurrState(ROLE_CURR_STATE_TIAOXI)

		--@desc 调息影响长生诀经验
		do
			local csjSkillinfo =  self:getSkill("changshengjueyang") or self:getSkill("changshengjueyin")
			if csjSkillinfo ~= nil then
				local addCSJExp = self:getMeridianLevel() * 50
				--@RefType [app.models.skill.BaseSkill#BaseSkill]
				local csjSkill = Skill:getSkill(csjSkillinfo.id)

				local roleSkillExp = self:getSkillExp(csjSkillinfo.id)
				local maxExp = self:conversionSkillExpAndLv("exp", self:getSkillLvLimit(csjSkillinfo.id))
				if roleSkillExp + addCSJExp > maxExp then
					addCSJExp = maxExp - roleSkillExp
				end
				self:addSkillExp(csjSkillinfo.id, addCSJExp)
				if PRINT_MODE == 1 then
					print("调息增加长生诀经验",addCSJExp)
				end
			end

		end

		return true, meridianExp, breathVal
	end
	return false
end

-- 取消调息
function Role:cancelPranayama()
	if self:isInCurrState(ROLE_CURR_STATE_TIAOXI)  then
		PopText("取消调息")
		self:setFlag("调息完成时间", nil)
		self:removeRoleCurrState(ROLE_CURR_STATE_TIAOXI)
	end
end

----------------------------------------------------------------------------------------------------------------
------------ 主动任务，支线任务，打坐，练功，闭关之间状态控制---------------------------------------------------
--[[
	1.主动任务时不能拥有其他状态
	2.空闲状态时不存在其他状态
	3.在remove某个状态时，同时需停止对应的动作
	4.在set某个非空闲状态时，需把空闲状态去除
]]

-- 获取所有的状态集
function Role:getRoleCurrStateMap()
	local isLianGong = self:getLianGongSystem():isLianGonging()
	if isLianGong then
		self:setRoleCurrState(ROLE_CURR_STATE_LIANGONG)
	else
		self:removeRoleCurrState(ROLE_CURR_STATE_LIANGONG)
	end

	local isXiuLianing = self:getXiuLianSystem():isXiuLianing()
	if isXiuLianing then
		self:setRoleCurrState(ROLE_CURR_STATE_XIULIAN)
	else
		self:removeRoleCurrState(ROLE_CURR_STATE_XIULIAN)
	end
	
	return self.roleCurrState
end

--判断状态是否存在
function Role:isInCurrState(state)
    -- 练功状态判断支持
    if state == ROLE_CURR_STATE_LIANGONG then
        return self:getLianGongSystem():isLianGonging()
	end
	
	-- 修炼状态判断支持
    if state == ROLE_CURR_STATE_XIULIAN then
        return self:getXiuLianSystem():isXiuLianing()
    end

	if not state or self.roleCurrState == nil then
		return false
	end

	for k, v in pairs(self.roleCurrState) do
		if state == k then
			return true
		end
	end
	return false
end

-- 设置一个状态
function Role:setRoleCurrState(state)
	if not state then
		return
	end

	if self.roleCurrState == nil then
		self.roleCurrState = {}
	end

	if self.roleCurrState[state] == true then
		return
	end

	-- 主动任务或者空闲状态是唯一状态
	if state == ROLE_CURR_STATE_IDLE or state == ROLE_CURR_STATE_ZHUDONG then
		if state == ROLE_CURR_STATE_IDLE then
			self:setFlag("空闲时间", GetTime())
		end

		self.roleCurrState = {}
		self.roleCurrState[state] = true
		return
	end

	self.roleCurrState[state] = true
	
	-- 设置一个非空闲状态时，需要把空闲状态去掉
	if state ~= ROLE_CURR_STATE_IDLE and self:isInCurrState(ROLE_CURR_STATE_IDLE) then
		self:removeRoleCurrState(ROLE_CURR_STATE_IDLE)
		self:setFlag("空闲时间", nil)
	end
end

-- 移除某一个状态
function Role:removeRoleCurrState(state)
	if not state or self.roleCurrState == nil or self.roleCurrState[state] ~= true then
		return
	end

	self.roleCurrState[state] = nil

	-- 如果是主动任务时或者状态集为空时，状态改为空闲
	if state == ROLE_CURR_STATE_ZHUDONG or MapIsEmpty(self.roleCurrState) then
		self.roleCurrState[ROLE_CURR_STATE_IDLE] = true
		self:setFlag("空闲时间", GetTime())
	end
end

-- 获取部位系数值
function Role:getPartXiShu(partName)
	local FightConfig = require("app.models.fight.FightConfig")
	
	local partRate = FightConfig:getPartRate(partName)

	LogSystem:log("旧版战斗：部位名称 = ",partName," 部位系数 = ",partRate)

	return partRate/100
end

-- 获取血气上限伤害
function Role:getQiMaxAtk(zhao, target, partName,fightRole)
	local wpAtk = fightRole:getWeaponDamage()

	local jiaLiAtk = self:getPowerDamage(nil,fightRole)

	local partXiShu = self:getPartXiShu(partName)

	local zhaoAtk, protect = 0, 0

	if zhao and zhao.dam then
		zhaoAtk = zhao.dam
	end

	if target then
		protect = target:getProtect(partName)
	end

	local damageClassType = self:getPrepareAttackSkill():getAtkDamageClass()

	local damageAttrModifValueFactor = self:getDamageAttrModifValueFactor(damageClassType,target,fightRole)

	local qiMaxAtk = (wpAtk+jiaLiAtk+zhaoAtk-protect*0.3)/(1+protect/100)*partXiShu * damageAttrModifValueFactor

	qiMaxAtk = math.max(Helper:mathFloor(qiMaxAtk),0)

	--比武用全局系数加成
	if self.attackScaleFactor ~= nil then

		if type( self.attackScaleFactor ) ~= "number" or self.attackScaleFactor < 0 or self.attackScaleFactor > 100 then
			self.attackScaleFactor = 1.0
		end

		return self.attackScaleFactor * qiMaxAtk
	end

	if DEBUG_MODE == 1 then
		print("===============================================获取血气上限伤害====================================================================")
		print("Role:getQiMaxAtk(zhao, target, partName)")
		print(self:getName())
		print("wpAtk  ->  ", wpAtk)
		print("jiaLiAtk  ->  ", tostring(jiaLiAtk))
		print("zhaoAtk ->  ", tostring(zhaoAtk))
		print("攻击部位 ->  ", tostring(partName))
		print("protect  ->  ", tostring(protect))
		print("partXiShu  ->  ", tostring(partXiShu))
		print("伤害属性类型  ->  ", tostring(damageClassType))
		print("伤害属性修正系数  ->  ", tostring(damageAttrModifValueFactor))
		print("气血上限伤害  ->  ", tostring(qiMaxAtk))
	end

	return qiMaxAtk
end

-- 获取气血伤害值
function Role:getQiAtk(zhao, target, partName, fightRole)
	local zhaoJiaLv, zjXiShu = self:getSkillLvAndFactor("zhaojia", "def")

	local partXiShu = self:getPartXiShu(partName)

	local damageClassType = self:getPrepareAttackSkill():getAtkDamageClass()

	local damageAttrModifValueFactor = self:getDamageAttrModifValueFactor(damageClassType,target,fightRole)

	local qiAtk = self:getAtkDamage(zhao)*(1/(1 + target:getDef()/1000)) * partXiShu * damageAttrModifValueFactor 

	qiAtk = Helper:mathFloor(qiAtk)
	
	if DEBUG_MODE == 1 then
		print("===============================================获取气血伤害值====================================================================")
		print("当前角色   =   "..self:getName())
	
		print("Role:getQiAtk(zhao, target, partName)")
		print("self:getAtkDamage(zhao)  ->  "..self:getAtkDamage(zhao))
		print("target:getDef()  ->  "..target:getDef())
		print("partXiShu  ->  "..partXiShu)
		print("伤害属性类型  ->  ",damageClassType)
		print("伤害属性修正系数  ->  "..damageAttrModifValueFactor)
		print("气血伤害值  ->  "..qiAtk)
		-- print("target:getQiMaxAtk()  ->  "..target:getQiMaxAtk(zhao, target, partName))
	end

	
	--比武用全局系数加成
	if self.attackScaleFactor ~= nil then

		if type( self.attackScaleFactor ) ~= "number" or self.attackScaleFactor < 0 or self.attackScaleFactor > 100 then
			self.attackScaleFactor = 1.0
		end

		return self.attackScaleFactor * qiAtk
	end

	return qiAtk
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/03/09 17:31:39
-- @desc 当道当前的平均气血伤害
function Role:getAvgQiAtk(target)
	local attackSkill = self:getPrepareAttackSkill()
	local avgAtk = attackSkill:getAvgAtk(self:getSkillLv(attackSkill.id))
	if PRINT_MODE == 1 then
		print("avgAtk = ", avgAtk)
	end
	local zhao = {atk = avgAtk}
	-- if DEBUG_MODE == 1 then
	-- 	print(self.name.."当前的平均气血伤害 = ",math.floor(self:getAtkDamage(zhao)*(1/(1 + target:getDef()/1000))*1))
	-- end

	local avgQiAtk = self:getAtkDamage(zhao)*(1/(1 + target:getDef()/1000))
	
	avgQiAtk = Helper:mathFloor(avgQiAtk)

	return avgQiAtk
end

--@desc: 获取伤害属性修正系数
--@author:LvBin
--@time:2024-09-18 17:01:53
--@damageClassType: 伤害类型
--@target: 攻击目标
--@fightRole: 战斗角色
--@return
function Role:getDamageAttrModifValueFactor(damageClassType,target,fightRole)
	-- 伤害属性修正系数 = min(max( 1 - (招架武学.对应伤害属性防御系数*招架武学等效等级/招架属性防御修正值+隐脉系统.对应伤害属性防御系数+其他系统.对应伤害属性防御系数) + 隐脉系统.对应伤害属性攻击系数 + 其他系统.对应伤害属性攻击系数, 气血属性伤害影响下限), 气血属性伤害影响上限)
	if damageClassType == nil then
		return 1
	end 

	local parrySkill = target:getPrepareParrySkill()

	local zhaoJiaDefDamageClass = parrySkill:getDefDamageClass()

	local zhaoJiaDefDamageParam = parrySkill:getDefDamageParam()

	local parrySkillDamageDefFactor = 0

	if zhaoJiaDefDamageClass and zhaoJiaDefDamageParam and damageClassType == zhaoJiaDefDamageClass then
		local parrySkillRealLv = target:getRealZhaojia()
		
		local parryDefModifValue = BattleConstConf:get("damageClass_zhaoJiaDef")
	
		parrySkillDamageDefFactor = zhaoJiaDefDamageParam * parrySkillRealLv / parryDefModifValue 
	end 

	--隐脉系统.对应伤害属性防御系数
	local hMeridianSysDamageAttrDefFactor = target:getHiddenMeridianSysDamageAttrFactor(damageClassType,"defDamageClass")

	--隐脉系统.对应伤害属性攻击系数
	local hMeridianSysDamageAttrAtkFactor = self:getHiddenMeridianSysDamageAttrFactor(damageClassType,"atkDamageClass")

	--主动效果.对应伤害属性防御系数
	local activeDamageAttrDefFactor = 0

	--主动效果.对应伤害属性攻击系数
	local activeDamageAttrAtkFactor = 0

	if fightRole and fightRole:getTarget() then
		activeDamageAttrDefFactor = fightRole:getTarget():getActiveDamageFactorValue(damageClassType,"defDamageClass")

		activeDamageAttrAtkFactor = fightRole:getActiveDamageFactorValue(damageClassType,"atkDamageClass")
	end

	--增加伤害抗性pvp影响系数
	local damageClassPvpParam = 1

	if fightRole and fightRole._fight and fightRole._fight._isPVP == true then
		damageClassPvpParam = BattleConstConf:get("damageClass_PVPparam")
	end

	local value = 1 - (parrySkillDamageDefFactor + hMeridianSysDamageAttrDefFactor + activeDamageAttrDefFactor) * damageClassPvpParam + (hMeridianSysDamageAttrAtkFactor + activeDamageAttrAtkFactor) * damageClassPvpParam
	
	local minValue = BattleConstConf:get("damageClass_hurtMin")

	local maxValue = BattleConstConf:get("damageClass_hurtMax")

	value = Helper:getRange(value, minValue, maxValue)

	LogSystem:log("旧版战斗：","====================================获取伤害属性修正系数====================================")
	LogSystem:log("旧版战斗：","当前攻击角色   =   "..self:getName())
	LogSystem:log("旧版战斗：","招架武学防御系数   =   "..parrySkillDamageDefFactor)
	LogSystem:log("旧版战斗：","隐脉系统.对应伤害属性防御系数   =   "..hMeridianSysDamageAttrDefFactor)
	LogSystem:log("旧版战斗：","隐脉系统.对应伤害属性攻击系数   =   "..hMeridianSysDamageAttrAtkFactor)
	LogSystem:log("旧版战斗：","主动效果.对应伤害属性防御系数   =   "..activeDamageAttrDefFactor)
	LogSystem:log("旧版战斗：","主动效果.对应伤害属性攻击系数   =   "..activeDamageAttrAtkFactor)
	LogSystem:log("旧版战斗：","伤害抗性pvp影响系数   =   "..damageClassPvpParam)
	LogSystem:log("旧版战斗：","最终伤害属性修正系数   =   "..value)

	return value
end

-- 设置玩家游戏时间
function Role:setGamingTime(endTime)
	endTime = Helper:getDef(endTime, GetTime())
	local startTime = self:getFlag("游戏时间")
	-- add by XiaoZhiWei 2017/02/28 17:28:37 getFlag返回值没有nil nil的情况返回0
	if startTime == 0 then
		startTime = endTime
		self:setFlag("游戏时间", endTime)
	end
	local duration = Helper:getRange(endTime - startTime, 0)
	-- 离线年龄最多72小时  edit by xiaozhiwei 离线年龄上限改为72小时
	if duration > 72 * 60 * 60 then
		duration = 72 * 60 * 60
	end
	if startTime ~= 0 then
		self:addAttr("gamingTime", duration)
	end
	self:setFlag("游戏时间", GetTime())
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- 玩家自动回复
-- 精力回复 注: 精力回复存在一个bug, 离线时间越长,增加精力越多. bug原因: 公式直接用离线时间差进行收益计算,算法带有乘除算法,数值越大,收益倍数值越大
function Role:addJing()
	local currTime = GetTime()
	local useTime, startTime
	startTime = self:getFlag("精力回复时间")
	--PopText("当前精力回复时间 = "..tostring(startTime))
	-- print("当前精力回复时间 = "..tostring(startTime), currTime)
	if startTime == 0 then
		startTime = GetTime()
		self:setFlag("精力回复时间", currTime)
	end
	useTime = currTime - startTime

	if PRINT_MODE == 1 then
		print("addJing useTime == ", useTime, "=========================")
	end

	local interval = 180
	if DEBUG_MODE == 1 then
		interval = 10
	end
	if useTime >= interval then
		if self:getNumAttr("jing") < self:getJingMax() then
			local addJing = 0 
			local cLv =  self:getSkillLv("changshengjueyin")
			local function addByChangshengjue()
				addJing = (useTime/interval + self:getEffectCon()/100) * math.floor(useTime/interval) * (1+cLv/4000)
				if PRINT_MODE == 1 then
					print("长生诀.阴提高精力恢复速度"..addJing)
				end
			end
			local function addByNormal()
				addJing = (useTime/interval + self:getEffectCon()/100) * math.floor(useTime/interval)
			end
			
			if cLv >= 600 then
				addByChangshengjue()
			else
				addByNormal()
			end

			local factor = self:getBuffAttr("xingzhenJing")
			addJing = addJing * (1 + factor)

			self:addAttr("jing", addJing)
		end
		self:setFlag("精力回复时间", currTime)
	end
end

--气血回复
function Role:addQi()
	local currTime = GetTime()
	local useTime, startTime
	startTime = self:getFlag("气血回复时间")
	-- add by XiaoZhiWei 2017/02/28 17:27:09 getFlag的返回值没有nil nil的情况会返回0
	if startTime == 0 then
		startTime = GetTime()
		self:setFlag("气血回复时间", currTime)
	end
	useTime = currTime - startTime

	if useTime >= 10 then
		if self:getNumAttr("qi") < self:getCurrQiMax() then
			-- local num = ((1/120)*self:getNumAttr("neiliMax")+self:getEffectCon()*0.1) *  math.floor(useTime/10)
			local num = ((1/25) * math.floor(self:getFinalAttr("qiMax")) + self:getEffectCon()*0.2) *  math.floor(useTime/10)

			-- 受恢复类技能影响 提速
			num = self:getHuiFuSpeedRate() * num

			if PRINT_MODE == 1 then
				print("当前气血增加量 == ", num)
			end

			self:addAttr("qi", num)
		elseif self:getNumAttr("qi") > self:getCurrQiMax() then
			--@TODO 2020-09-12 10:03:15 临时解决气血大于当前气血上限
			self:checkAttr("qi")
		end
		self:setFlag("气血回复时间", currTime)
	end
end

-- 气血最大值回复
function Role:addQiMax()
	local currTime = GetTime()
	local useTime, startTime
	startTime = self:getFlag("气血最大值回复时间")
	-- add by XiaoZhiWei 2017/02/28 17:27:09 getFlag的返回值没有nil nil的情况会返回0
	if startTime == 0 then
		startTime = GetTime()
		self:setFlag("气血最大值回复时间", currTime)
	end
	useTime = currTime - startTime
	if useTime >= 10 then
		if self:getCurrQiMax() < self:getFinalAttr("qiMax") then
			local qiMaxAdd = ((1/2880)*self:getFinalAttr("qiMax")+0.5) * math.floor(useTime/10)

			-- 受恢复类技能影响 提速
			qiMaxAdd = self:getHuiFuSpeedRate() * qiMaxAdd

			if PRINT_MODE == 1 then
				print("当前气血最大值增加量 == ", qiMaxAdd)
			end

			local currQiMax = self:getCurrQiMax()
			local qiMax = self:getFinalAttr("qiMax")
			self:setAttr("qiPercent", (currQiMax + qiMaxAdd) / qiMax)
		end
		self:setFlag("气血最大值回复时间", currTime)
	end
end

-- 内力回复
function Role:addNeiLi()
	local currTime = GetTime()
	local useTime, startTime
	startTime = self:getFlag("内力回复时间")
	-- add by XiaoZhiWei 2017/02/28 17:27:09 getFlag的返回值没有nil nil的情况会返回0
	if startTime == 0 then
		startTime = GetTime()
		self:setFlag("内力回复时间", currTime)
	end
	useTime = currTime - startTime
	if useTime >= 10 then
		if self:getNumAttr("neili") < math.floor(self:getFinalAttr("neiliMax")) then
			local neiliSpeed = self:getNeiLiSpeed() * 2 * math.floor(useTime/10)
			self:addAttr("neili", neiliSpeed)
		end
		self:setFlag("内力回复时间", currTime)
	end
end


--  是否拥有月卡
function Role:yueKaIsValid()
	local state = self:getAttr("yueKaValid")
	if state == "Y" then
		return true
	end
	return false
end

-- 更新月卡状态
function Role:updateYueKaStatus(expiredTime)
	local status = "N"
	if tonumber(expiredTime) == nil or tonumber(expiredTime) <= 0 then
		status = "N"
	else
		if expiredTime <= GetTime() then
			status = "N"
		else
			status = "Y"
		end
	end

	self:setAttr("yueKaValid", status)
	self:updateYueKaChengHao()
end

function Role:isYaShi()
	local value = self:getAttr("yaShi")

	if value == 0 then
		return false
	elseif value == 1 then
		return true
	end

	error("雅士数据状态异常！！")
end

function Role:updateYaShiStatus(expiredTime)
	if type(expiredTime) ~= "number" or expiredTime <= 0 then
		self:setAttr("yaShi",0)
	end

	local currTime = GetTime()
	if expiredTime <= currTime then
		self:setAttr("yaShi", 0)
	else
		self:setAttr("yaShi", 1)
	end
end

-- 是否拥有包月分身符
function Role:monthFenShenFuIsValid()
	local state = self:getAttr("monthFenShenFu")
	if state == "Y" then
		return true
	end
	return false
end

-- 更新包月分身符状态
function Role:updateMonthFenShenFuStatus(expiredTime)
	if tonumber(expiredTime) == nil or tonumber(expiredTime) <= 0 then
		self:setAttr("monthFenShenFu", "N")
	else
		local currTime = GetTime()
		if expiredTime <= currTime then
			self:setAttr("monthFenShenFu", "N")
		else
			self:setAttr("monthFenShenFu", "Y")
		end
	end
end

--检测玩家是否穿戴了面具
function Role:checkHeadIsMask(equips)
	equips = Helper:getDef(equips, self.equips)

	local headItemId = nil
	if type(equips) == "table" then
		if type(equips.head) == "table" then
			headItemId = equips.head.itemId
		end
	end

	-- 判断是否佩戴面具
	if headItemId then
		local imagPath = switch(headItemId,
		{
			mianju1000 = "nv_head30",
			mianju1001 = "nan_head30",
			mianju1002 = "nv_head31",
			mianju1003 = "nan_head31",
			mianju1004 = "mianju1004",
			mianju1005 = "mianju1005",
			mianju1006 = "mianju1006",
			mianju1007 = "mianju1007",
			mianju1008 = "mianju1008",
			mianju1009 = "mianju1009",
			mianju1010 = "mianju1010",
			mianju1011 = "mianju1011",
			mianju1012 = "mianju1012",
			mianju1013 = "mianju1013",
			mianju1014 = "mianju1014",
			mianju1015 = "mianju1015",
			default = nil
		})

		if imagPath ~= nil then
			return true
		end
	end

	return false
end

-- 角色头像边框
function Role:getFaceFrame()
	-- 周年庆特殊边框
	if self:getAttr("title_type") == 5 then
		return Resource:getImgPath("anniversaryFrame")
	end
	if self:getAttr("title_type") == 12 then
		return Resource:getImgPath("anniversaryFrame2")
	end
	if self:getAttr("title_type") == 17 then
		return Resource:getImgPath("anniversaryFrame3")
	end
	if self:getAttr("title_type") == 20  then
		if self:getAttr("title_id") == 11 or self.title == "HIR【名藏五岳】" then 
			return Resource:getImgPath("mingcangwuyueFrame")
		end
	end

	if self:getAttr("title_type") == 21 then
		return Resource:getImgPath("anniversaryFrame4")
	end

	if self:getAttr("title_type") == 24 then
		return Resource:getImgPath("anniversaryFrame5")
	end

	-- 判断是否使用饰品
	local portraitId = self:getPortraitId()
	if portraitId and portraitId ~= "" then
		local portraitLv = self:getPortraitLv()
		local maskAttr = self:getMaskSystem():getMaskAttrByMaskIdAndLv(portraitId,portraitLv)
		if maskAttr and maskAttr:getFramePath() then
			return maskAttr:getFramePath()
		end
	end

	-- 是否月卡用户
	if self:yueKaIsValid() == true then
		return Resource:getImgPath("headFrame02")
	end

	return Resource:getImgPath("headFrame01")
end

-- 排行榜角色头像边框 flag 是否月卡用户
function Role:getFaceRankFrame(portrait, flag, title_type, title_id)
	-- 周年庆特殊边框
	if title_type == 5 then
		return Resource:getImgPath("anniversaryRankFrame")
	end
	if title_type == 12 then
		return Resource:getImgPath("anniversaryRankFrame2")
	end
	if title_type == 17 then
		return Resource:getImgPath("anniversaryRankFrame3")
	end
	if title_type == 20 and title_id == 11 then
		return Resource:getImgPath("mingcangwuyueRankFrame")
	end
	if title_type == 21 then
		return Resource:getImgPath("anniversaryRankFrame4")
	end
	if title_type == 24 then
		return Resource:getImgPath("anniversaryRankFrame5")
	end

	-- 判断是否使用饰品
	-- if portrait and portrait ~= "" then
	-- 	if type(portrait) == "string" then
	-- 		portrait = {id = portrait,lv = 1}
	-- 	end
	-- 	if portrait.id and portrait.id ~= "" then
	-- 		local maskAttr = self:getMaskSystem():getMaskAttrByMaskIdAndLv(portrait.id,portrait.lv)
	-- 		if maskAttr and maskAttr:getRankFramePath() then
	-- 			return maskAttr:getRankFramePath()
	-- 		end
	-- 	end
	-- end

	if flag ~= nil then
		if flag then
			return Resource:getImgPath("headFrame03")
		end
	end

	return Resource:getImgPath("headFrame04")
end

-- 角色信息边框
function Role:getFaceInfoFrame()
	return self:getRoleViewBorderSys():getInfoViewBorder()
	-- -- 周年庆特殊边框
	-- if self:getAttr("title_type") == 5 then
	-- 	return Resource:getImgPath("anniversaryInfoFrame")
	-- end

	-- if self:getAttr("title_type") == 12 then
	-- 	return Resource:getImgPath("anniversaryInfoFrame2")
	-- end
	
	-- if self:getAttr("title_type") == 17 then
	-- 	return Resource:getImgPath("anniversaryInfoFrame3")
	-- end

	-- if self:getAttr("title_type") == 21 then
	-- 	return Resource:getImgPath("anniversaryInfoFrame4")
	-- end

	-- if self:getAttr("title_type") == 24 then
	-- 	return Resource:getImgPath("anniversaryInfoFrame5")
	-- end

	-- -- 判断是否使用饰品
	-- local portraitId = self:getPortraitId()
	-- if portraitId and portraitId ~= "" then
	-- 	local portraitLv = self:getPortraitLv()
	-- 	local maskAttr = self:getMaskSystem():getMaskAttrByMaskIdAndLv(portraitId,portraitLv)
	-- 	if maskAttr and maskAttr:getBorderId() then
	-- 		local BorderConfigManager = require("app.models.HeadViewSystem.BorderConfigManager")
	-- 		local path = BorderConfigManager:getBorderConf(maskAttr:getBorderId()):getInfoFramePath()
	-- 		if path then
	-- 			return path
	-- 		end
	-- 	end
	-- end

	-- -- 是否月卡用户 -- "Image/UI/AttrUI/frame/mianju_InfoFrame1020.png"
	-- if self:yueKaIsValid() == true then
	-- 	return "Image/UI/RoleUI/11.png"
	-- end

	-- return "Image/UI/RoleUI/RoeBack.png"
end

---------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------
--  信息记录(仅供测试BUG阶段使用)
function Role:saveInfo(name, state, params)
	-- state "start" "stop"
	--[[
		info =
		{
			starTime = GetTime()
			start = {},
			stop = {}
		}
	]]
	if name == nil or state == nil or params == nil then
		return
	end

	if self.__INFO == nil then
		self.__INFO = {}
	end

	-- 不存在则初始化
	if self.__INFO["__"..tostring(name).."Info"] == nil then
		self.__INFO["__"..tostring(name).."Info"] = {}
	end
	local list = self.__INFO["__"..tostring(name).."Info"]

	-- 第一次记录
	if MapIsEmpty(list) then
		table.insert(list,
		{
			startTime = GetTime(),
			[state] = params
		})
	else
		-- 开始
		if state == "start" then
			--数组长度已满 暂定为3
			if #list >= 3 then
				-- 移除第一个元素
				table.remove(list, 1)
			end
			table.insert(list,
			{
				startTime = GetTime(),
				start = params
			})
		end

		-- 结束 并且 列表最后一个的stop为空
		if state == "stop" then
			if list[#list].stop == nil then
				list[#list].stop = params
			else
				-- 结束,但是最后一个stop不为空的情况
				if #list >= 3 then
					-- 移除第一个元素
					table.remove(list, 1)
				end
				table.insert(list,
				{
					startTime = GetTime(),
					start = {},
					stop = params
				})
			end
		end
	end

	self.__INFO["__"..tostring(name).."Info"] = list
end

local trimMap = {
	["kongfuDsc"] = true,
	["maps"] = true,
	["qiDsc"] = true,
	["looksDsc"] = true,
	["ageDsc"] = true,
	["chengHaoDesc"] = true,
	["attackSkill"] = true,
	["autoSkills"] = true,
	["fightQiDesc"] = true,
	["chengHuDesc"] = true,
	["sigMap"] = true,
	["__INFO"] = true,
	["currFamilyParams"] = true,
	["attrChanges"] = true,
	["_roleBuff"] = true,
	["ignoreCloneTb"] = true,
	["_shenbingCache"] = true,
	["_ItemCache"] = true,
	["_buffManager"] = true,
	["emotionMgr"] = true,
	["__module"] = true,
	["_skillFile"] = true,
	["_mailBoxState"] = true
}
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/08 20:16:29
-- @desc 修剪角色数据
function Role:trimRoleData(data)
	if MapIsEmpty(data) == true then
		data = self
	end

	local list = {}

    -- 如果不是table, 直接清除
	if not (type(data) == "table") then
		if PRINT_MODE == 1 then
			print("如果不是table, 直接清除")
		end
		data = {}
	end

	if data._buffManager ~= nil then
		data._buffManager:serialization()
	end

	if data.emotionMgr ~= nil then
		data.emotionMgr:serialization()
	end

	if data:getRoleViewBorderSys() then
		data:getRoleViewBorderSys():serialization()
	end

	for k,v in pairs(data) do
		if trimMap[k] == true then
			-- 排除一些描述性属性
		elseif (type(v) == "table" and v.__inherit) then
		elseif type(v) == "function" then
		else
			list[k] = v
		end
	end
	
	return list
end

function Role:getTrimData()
	return clone(self:trimRoleData(self))
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/08 14:39:46
-- @desc 副本战斗结束, 设置角色属性
function Role:acceptMapFightResult(role, fightType)
	return self:callModuleFunc("acceptMapFightResult", role, fightType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 14:21:46
-- @desc 保存上次请求时间, 保存到角色信息,以key value 的形式保存
function Role:setSigTime(url, time)
    if time == nil or time <= 0 then
        return false
    end
    -- url MD5一下,否则存档下载会报错
    url = md5:getMd5(url)
    local sigMap = self:getAttr("sigMap")
    if MapIsEmpty(sigMap) == true then
        sigMap = {}
    end

    if sigMap[url] == nil then
        sigMap[url] = {}
    end

    sigMap[url].time = time

    self:setAttr("sigMap", sigMap)
    return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 14:26:55
-- @desc 获取上次请求时间
function Role:getSigTime(url)
    if url == nil then
        return 0
    end
    url = md5:getMd5(url)
    local sigMap = self:getAttr("sigMap")
    if MapIsEmpty(sigMap) == true  or sigMap[url] == nil then
        return 0
    end

    return Helper:getDef(sigMap[url].time, 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/16 17:23:03
-- @desc 获取时间戳的年月 返回格式 201611 nil 则返回nil
-- @params time 当前时间戳  diffDay 间隔天数
local function getYearMonthDay(time, diffDay)
    if time == nil then
        return nil
    end
    if diffDay ~= nil and type(diffDay) == "number" then
    	time = time + diffDay * 24 * RoleConstans.theSecondOfOneHour
    end
    -- 默认用20160701  游戏正式上架时间
    return Helper:getDef(Helper:date("%Y%m%d", tonumber(time)), "20160701")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/16 18:20:16
-- @desc 记录url请求 历史 记录最多记录一周内容,超出一周删除最老的
function Role:addUrlResoponseInfo(url, time, status, errcode)
    if url == nil or time == nil or status == nil then
        return
    end
    -- Md5一下
    url = md5:getMd5(url)
    -- sigMap 数据
    local sigMap = self:getAttr("sigMap")
    if sigMap[url] == nil then
        sigMap[url] = {}
    end

    -- 获取时间的年月日
    local YM = getYearMonthDay(time)
    local oldYm = getYearMonthDay(time, -7) -- 一周前的年月日
    -- 如果7天前的记录不为空,则清空它
    if sigMap[url][oldYm] ~= nil then
    	sigMap[url][oldYm] = nil
    end

    -- 总数 + 1
    local ymList = Helper:getDef(sigMap[url][YM], {})
    ymList.totalCount = Helper:getDef(ymList.totalCount, 0) + 1

    -- http状态 + 1
    local httpCode = Helper:getDef(ymList.httpCode, {})
    httpCode["status_"..tostring(status)] = Helper:getDef(httpCode[status], 0) + 1

    -- response errcode + 1
    if errcode == nil then
        errcode = 1000
    end
    local errCode = Helper:getDef(ymList.errCode, {})
    errCode["code_"..tostring(errcode)] = Helper:getDef(errCode[errcode], 0) + 1

    -- 将数据保存
    ymList.errCode = errCode
    ymList.httpCode = httpCode

    sigMap[url][YM] = ymList
    self:setAttr("sigMap", sigMap)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/28 14:38:28
-- @desc NPC自动回血
function Role:initNpcAttr()
    -- 角色队伍为第二个队伍,并且战斗脱离时间
    if self:getFlag("战斗脱离时间") ~= 0 then
        local qiMax = self:getFinalAttr("qiMax")
        local qi = self:getAttr("qi")
        local neiliMax = self:getFinalAttr("neiliMax")
        local neili = self:getAttr("neili")
        local useTime = GetTime() - self:getFlag("战斗脱离时间")
		print("-----------useTime:",useTime)
        self:setAttr("qiPercent", math.min(qiMax,math.max(0.2,qi)+0.04*neiliMax+(useTime/2)*(18+0.018*neiliMax))/qiMax)
		self:setAttr("qi", math.min(qiMax,math.max(0.2,qi)+0.04*neiliMax+(useTime/2)*(18+0.018*neiliMax)))

        local currQi = self:getAttr("qi")
        self:setAttr("neili", math.min(neiliMax,neili+(useTime-2*(currQi-math.max(0.2,qi))/(18+0.018*neiliMax)*2)*(0.02*neiliMax+10)))
    end
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/02 15:38:01
-- @desc 判断师傅是否在调整范围内,()伴随更新内容控制)
function Role:checkTeacherIsChanged()
	return switch(self:getAttr("teacherId"),
	{
		["lijiaolian"] = true,
		["ouyangfeng"] = true,
		["ouyangke"] = true,
		["batianshi"] = true,
		["duanzhengchun"] = true,
		["kurongchanshi"] = true,
		["jingxuanshitai"] = true,
		["jixiaofu"] = true,
		["miejueshitai"] = true,
		["zhouzhiruo"] = true,
		["zhouzhiruo1"] = true,
		["xuanling"] = true,
		["jingzhaoshitai"] = true,
		["hongqigong"] = true,
		["qiaofeng"] = true,
		["liangzhanglao"] = true,
		["jiangshangyou"] = true,
		["limochou"] = true,
		["linchaoying"] = true,
		["luwushuang"] = true,
		["xiaolongnv"] = true,
		["yangguo"] = true,
		["yangguo1"] = true,
		["xiaolongnv1"] = true,
		["limochou1"] = true,
		["fengbuping"] = true,
		["fengqingyang"] = true,
		["gaogenming"] = true,
		["ningzhongze"] = true,
		["yuebuqun"] = true,
		["hezudao"] = true,
		["banshuxian"] = true,
		["hetaichong"] = true,
		["xihuazi"] = true,
		["gaozecheng"] = true,
		["liqiushui"] = true,
		["tianshantonglao"] = true,
		["xuzhu"] = true,
		["mejian"] = true,
		["zhangwuji"] = true,
		["weiyixiao"] = true,
		["xiexun"] = true,
		["yintianzheng"] = true,
		["zhoudian"] = true,
		["yanyuan"] = true,
		["jinlunfawang"] = true,
		["jiumozhi"] = true,
		["xuedaolaozu"] = true,
		["jiamuhuofo"] = true,
		["morongbo"] = true,
		["murongfu"] = true,
		["baobutong"] = true,
		["azhu"] = true,
		["xiangwentian"] = true,
		["xuanbeidashi"] = true,
		["xuancidashi"] = true,
		["xuannandashi"] = true,
		["xuantongdashi"] = true,
		["chengguan"] = true,
		["xutong"] = true,
		["tanglaotaitai"] = true,
		["tangliang"] = true,
		["tangbuping"] = true,
		["tangmeng"] = true,
		["huangyaoshi"] = true,
		["qulingfeng"] = true,
		["yapu"] = true,
		["suxinghe"] = true,
		["xiaoyaozi"] = true,
		["xuemuhua"] = true,
		["xuzhu1"] = true,
		["xuemuhua1"] = true,
		["shangguanjiannan"] = true,
		["qiuqianren"] = true,
		["qiuqianzhang"] = true,
		["songyuanqiao"] = true,
		["hetieshou"] = true,
		["qiyunao"] = true,
		["shaqianli"] = true,
		["tianshuzi"] = true,
		["dingchunqiu"] = true,
		["zaixingzi"] = true,
		["caihuazi"] = true,
		["default"] = false
	})
end

-- Begin add by TangJian 2016/11/29 18:16:27

function Role:getDropSchemeIdArray()
	if type(self.dropScheme) == "string" and #self.dropScheme > 0 then
		local dropSchemeIdArray = string.split(self.dropScheme, ";")

		--@desc 增加获取奖励时log，春节任务暂时无用，暂时屏蔽
		-- -- 春节活动收益加成
		-- local SpringFestival = require("app.models.SpringFestival.SpringFestival")
		-- if SpringFestival:getProfitActivityState() == 1 then
		-- 	local count = #dropSchemeIdArray
		-- 	for i = 1,count do
		-- 		if SpringFestival:checkIsAdditionSchemeId(dropSchemeIdArray[i]) then
		-- 			table.insert(dropSchemeIdArray, dropSchemeIdArray[i])
		-- 		end
		-- 	end
		-- end

		return dropSchemeIdArray
	else
		return {}
	end
end

-- End add by TangJian 2016/11/29 18:16:26
-------------------------------------------------------------

-- Decorator:beforeAll(Role,
-- 	function(funcName, ...)
-- 		print("funcName = "..tostring(funcName))
-- 	end)

-- Decorator:replaceAll(Role,
-- 	function(funcName, func, ...)
-- 		print("funcName = "..tostring(funcName))

-- 		local ret
-- 		local params = {...}
-- 		return PerformanceAnalysis(funcName, function()
-- 			return func(unpack(params))
-- 		end)
-- 	end)

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/17 15:13:32
-- @desc 存储测试信息便于调试问题
function Role:saveErrMsg(key, msg)
	if key == nil or msg == nil then
		return
	end
	self.__errMsgList = Helper:getDef(self.__errMsgList, {})
	self.__errMsgList[key] = Helper:getDef(self.__errMsgList[key], {})
	if #self.__errMsgList[key] >= 5 then
		table.remove(self.__errMsgList[key], 1)
	else
	end
	table.insert(self.__errMsgList[key], msg)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/20 10:54:52
-- @desc 角色内数据一定时间内更新,较少资源消耗
function Role:update()
	-- self:calcNeiLiLimit()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/11/29 02:56:30
-- @desc 角色自然恢复
function Role:spontaneousRecovery()
	if self:isInCurrState(ROLE_CURR_STATE_DAZUO) == false then
		self:addNeiLi()
	end

	if self:isInCurrState(ROLE_CURR_STATE_LIANGONG) == false and self:isInCurrState(ROLE_CURR_STATE_XIULIAN) == false and self:isInCurrState(ROLE_CURR_STATE_READ) == false then
		self:addJing()
	end

	self:addQi()
	self:addQiMax()
	self:spontaneousRecoveryPiJuan()
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/26 17:30:41
-- @desc 刷新角色buff
-- @desc target 战斗中对方角色
function Role:updateRoleBuff(target)
	self._roleBuff:update(self,target)
	self:update()

	-- 角色老的buff更新, 增加事件通知
	self:dispatchEvent("updateRoleBuff")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 12:15:53
-- @desc 更新玩家战斗状态
function Role:updateFightStatus(status)
	if status == nil then
		return
	end

	-- 被邀战等待中 主动邀战等待中 战斗开始 战斗中 战斗结束 免打扰模式 离线模式 (注 免打扰模式 和 离线模式 的状态只能通过 setFlag 直接修改)
	local oldStatus = self:getFlag("PVP战斗状态")
	if oldStatus == "免打扰模式" or oldStatus == "离线模式" then
		return
	end

	self:setFlag("PVP战斗状态", status)
end

-----------------------------------------------------------------------------------------------------------
-- 百家典籍相关

-- 研读
function Role:read()
    local read = self:getAttr("read_book")

    if MapIsEmpty(read) then
        self:removeRoleCurrState(ROLE_CURR_STATE_READ)
        return
    end

	-- 每秒增加经验
	local BookLiterary = require("app.models.book.BookLiterary")
	local EXP = BookLiterary:getReadSecExp(self:getFinalAttr("currInt"),read.shuTongLv)
	local JING = 30

    local currLiteraryId = read.id
	local jing = self:getAttr("jing")
	local needStop = false

    -- 精力不足停止研读
	if jing < 1 then
		self:stopRead()
		return
    end
    
    local currLiteraryExp = self:getLiteraryExp(currLiteraryId)
    
	-- 统计离线收益
	OfflineProfit:setBeforeStatus("skillLv", self:getLiteraryLv(currLiteraryId))

	local currTime = GetTime()
	local startTime = read.startTime
	local interval = currTime - startTime

	-- 书籍挂机收益算法修改为：
	-- 精力消耗转化为书籍经验公式 = （200*(潜能转换率)*角色当前精力/120）*6
	-- 潜能转换率 = 100 * (200+总悟性)/200
	-- 总悟性=先天悟性 + 后天悟性；
	local subJing = interval / JING
	local literary = self:getLiterary(currLiteraryId)
	local exp = interval * EXP

	-- 精力不足时
	if subJing > jing then
		subJing = jing
		interval = subJing * JING
		exp = interval * EXP
		needStop = true
	end

	local lv1 = self:getLiteraryLvByExp(currLiteraryExp)
	local lv2 = self:getLiteraryLvByExp(currLiteraryExp + exp)
	-- print("rate = " .. rate)
	-- 检测当前挂机收益能否升升级 limitExp 当前能提升到的最高等级
	local state, limitExp = self:checkLiteraryCanLevelUp(currLiteraryId, literary.exp + exp)

	-- 每秒提升读书识字的经验
	local addSkillExp = BookLiterary:getReadExpForSkill(currLiteraryId,read.shuTongLv)

	--每秒提升锻造之术的经验
	local addForgeSkillExp = BookLiterary:getReadExpForForgeSkill(currLiteraryId)
	--每秒提升江湖毒术的经验
	local addPoisonSkillExp = BookLiterary:getReadExpForPoisonSkill(currLiteraryId)
	--每秒提升振槁玄经经验
	local addZGXJSkillExp = BookLiterary:getReadExpForZhenGaoXuanJingSkill(currLiteraryId)
	
	if state == true then
		--提升读书识字经验
		if self:getSkillLv("dushushizi") < self:getDuShuShiZiLimitLevel() then
			if self:canLevelUp("dushushizi", interval * addSkillExp) == true then
				self:addSkillExp("dushushizi", interval * addSkillExp)
			elseif self:getSkillLv("dushushizi") < self:getLv() then
				local addExp = self:getSkillNeedExp("dushushizi",self:getLv() - self:getSkillLv("dushushizi"))
				self:addSkillExp("dushushizi", addExp)
			end
		end
		-----------------------------------------------------------------------------------------------------------
		-- @author GaoHanZheng
		-- @time 2018/01/05 15:04:32
		-- @desc 提升锻造之术经验
		if self:getSkillLv("duanzaozhishu") < self:getDuShuShiZiLimitLevel() and self:getSkill("duanzaozhishu") and read.isDuanZao == 1  then
			if self:canLevelUp("duanzaozhishu", interval * addForgeSkillExp) == true then
				self:addSkillExp("duanzaozhishu", interval * addForgeSkillExp)
			end
		end
		
		if self:getSkillLv("jianghudushu") < self:getDuShuShiZiLimitLevel() and self:getSkill("jianghudushu") and read.isPosison == 1 then
			if self:canLevelUp("jianghudushu", interval * addPoisonSkillExp) == true then
				self:addSkillExp("jianghudushu", interval * addPoisonSkillExp)
			end
		end
		
		--@desc 振槁玄经经验提升
		if addZGXJSkillExp > 0 and self:getSkillLv("zhengaoxuanjing") < self:getDuShuShiZiLimitLevel() and self:getSkill("zhengaoxuanjing") then
			if self:canLevelUp("zhengaoxuanjing", interval * addZGXJSkillExp) == true then
				self:addSkillExp("zhengaoxuanjing", interval * addZGXJSkillExp)
			end
		end
		
		if lv2 - lv1 > 0 then
			ForgeSkill:checkCanGetFoegeKnowledge(lv1,lv2,currLiteraryId)
			PoisonFormula:unlockPoisonFormulaByBookLvUp(lv1,lv2,currLiteraryId)
		end
		self:addLiteraryExp(currLiteraryId, exp)
	else

		-- 达到学习的限制
		if limitExp ~= nil and literary.exp < limitExp then
			exp = limitExp - literary.exp
			interval = exp / EXP
			subJing = interval / JING
			local lv1 = self:getLiteraryLvByExp(currLiteraryExp)
			local lv2 = self:getLiteraryLvByExp(currLiteraryExp + exp)
			--提升读书识字经验
			if self:getSkillLv("dushushizi") < self:getDuShuShiZiLimitLevel() then
				if self:canLevelUp("dushushizi", interval * addSkillExp) == true then
					self:addSkillExp("dushushizi", interval * addSkillExp)
				elseif self:getSkillLv("dushushizi") < self:getLv() then
					local addExp = self:getSkillNeedExp("dushushizi",self:getLv() - self:getSkillLv("dushushizi"))
					self:addSkillExp("dushushizi", addExp)
				end
			end
			-----------------------------------------------------------------------------------------------------------
			-- @author GaoHanZheng
			-- @time 2018/01/05 15:04:32
			-- @desc 提升锻造之术经验
			if self:getSkillLv("duanzaozhishu") < self:getDuShuShiZiLimitLevel() and self:getSkill("duanzaozhishu")  and read.isDuanZao == 1 then
				if self:canLevelUp("duanzaozhishu", interval * addForgeSkillExp) == true then
					self:addSkillExp("duanzaozhishu", interval * addForgeSkillExp)
					if lv2 - lv1 > 0 then
						ForgeSkill:checkCanGetFoegeKnowledge(lv1,lv2,currLiteraryId)
					end
				end
			end

			-- @desc 提升江湖毒术经验
			if self:getSkillLv("jianghudushu") < self:getDuShuShiZiLimitLevel() and self:getSkill("jianghudushu") and read.isPosison == 1 then
				if self:canLevelUp("jianghudushu", interval * addPoisonSkillExp) == true then
					self:addSkillExp("jianghudushu", interval * addPoisonSkillExp)
				end
				if lv2 - lv1 > 0 then
					PoisonFormula:unlockPoisonFormulaByBookLvUp(lv1,lv2,currLiteraryId)
				end
			end

			--@desc 振槁玄经经验提示
			if addZGXJSkillExp > 0 and self:getSkillLv("zhengaoxuanjing") < self:getDuShuShiZiLimitLevel() and self:getSkill("zhengaoxuanjing") then
				if self:canLevelUp("zhengaoxuanjing", interval * addZGXJSkillExp) == true then
					self:addSkillExp("zhengaoxuanjing", interval * addZGXJSkillExp)
				end
			end
		
			self:addLiteraryExp(currLiteraryId, exp)

			-- print("Fix exp = " .. exp)
			-- print("Fix interval = " .. interval)
			-- print("Fix subJing = " .. subJing)
		end
		needStop = true
	end

	-- 计算实际消耗精力
	self:addAttr("jing", -subJing)

	if needStop then
		self:stopRead()
	else
        -- self:setFlag("研读时间", GetTime())
		read.startTime = GetTime()
		self:setAttr("read_book",read)
	end

	-- print("GetTime() = " .. GetTime())
	-- print("startTime = " .. startTime)
	-- print("interval = " .. interval)
	-- print("interval + startTime = " .. interval + startTime)
	-- print("GetTime() - (interval + startTime)" .. GetTime() - (interval + startTime))

	self:setFlag("精力回复时间", interval + startTime)
	self:setFlag("精力开始回复时间", interval + startTime)

	self:setGamingTime(interval + startTime) -- 更新角色年龄

	-- 统计离线收益
	OfflineProfit:setAfterStatus("skillLv", self:getLiteraryLv(currLiteraryId), BookLiterary:getLiteraryById(currLiteraryId).name .."书籍等级")

end

-- 停止研读
function Role:stopRead()

    local read = self:getAttr("read_book")

	local booValue = false
	local literaryId = read.id
	local BookLiterary = require("app.models.book.BookLiterary")
	local name = BookLiterary:getLiteraryById(literaryId).name
	--@RefType [app.models.HomelandModel.HomelandDesc#HomelandDesc]
	local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
	local endDesc = HomelandDesc:getEndReadDesc(name,read.room,read.shuTong)

	RichPrint("main",endDesc)

	-- self:setFlag("当前研读书籍", nil)
    -- self:setFlag("研读时间", nil)
    self:setAttr("read_book",{})
	self:setFlag("精力回复时间", GetTime())
	self:setFlag("精力开始回复时间", GetTime())
	self:removeRoleCurrState(ROLE_CURR_STATE_READ)
end

-- 增加典籍经验
function Role:addLiteraryExp(literaryId, exp)
	if self:getSkill("dushushizi") == nil then
		print("未习得读书识字")
		return false
	end

	local literary = self:getLiterary(literaryId)

	if literary == nil then
		print("未拥有该典籍")
		return false
	end

	local beforeLv = self:getLiteraryLv(literaryId)
	self:setLiteraryExp(literaryId, exp + literary.exp)

	if PRINT_MODE == 1 then
        print("Role:addLiteraryExp : ",exp)
    end

	local currLv = self:getLiteraryLv(literaryId)

	local BookLiterary = require("app.models.book.BookLiterary")
	if beforeLv < currLv then
		RichPrint("main", "你的 【" ..  BookLiterary:getLiteraryById(literaryId).name .. "】 等级 + " .. currLv - beforeLv)
	end

	return state, spillExp
end

-- 设置典籍经验
function Role:setLiteraryExp(literaryId, exp)
	local literaryBox = self.literaryBox

	for i,v in ipairs(literaryBox) do
		if v.literaryId == literaryId then
			literaryBox[i].exp = exp
			-- print("setLiteraryExp literaryId = " .. literaryId .. " exp = " .. exp)
			self:setAttr("literaryBox", literaryBox)
			break
		end
	end
end

-- 检测典籍能否增加经验
-- state (true 可增加 false 不可增加)
function Role:checkLiteraryCanLevelUp(literaryId, exp)
	local dushushizi = self:getSkill("dushushizi")
	if dushushizi == nil then
		return false
	end
	-- 上限等级
	local limitlv = self:getSkillLv("dushushizi") + 1
	-- 上限经验
	local limitExp = self:getLiteraryExpByLv(limitlv)

	if exp > limitExp then
		return false, limitExp
	end

	return true, limitExp
end

-- 获取典籍
function Role:getLiterary(literaryId)
	for i,v in ipairs(self.literaryBox) do
		if literaryId == v.literaryId then
			return self.literaryBox[i]
		end
	end

	return nil
end

function Role:getLiteraryCount(literaryId)
	local count = 0
	for i,v in ipairs(self.literaryBox) do
		if literaryId == v.literaryId then
			return self.literaryBox[i].count
		end
	end

	return count
end

-- 获得典籍等级
function Role:getLiteraryLv(literaryId)
	local lv = 0
	local literary = self:getLiterary(literaryId)

	if not literary then
		return 0
	end

	lv = self:getLiteraryLvByExp(literary.exp)

	return lv
end

-- 获得典籍经验
function Role:getLiteraryExp(literaryId)
	local exp = 0
	local literary = self:getLiterary(literaryId)

	if not literary then
		return nil
	end

	exp = literary.exp
	return exp
end

-- 获得等级
function Role:getLiteraryLvByExp(exp)
	local BookLiterary = require("app.models.book.BookLiterary")
	return BookLiterary:getLv(exp)

end

-- 获得经验
function Role:getLiteraryExpByLv(lv)
	local BookLiterary = require("app.models.book.BookLiterary")
	return BookLiterary:getExp(lv)
end

-- 获得读书识字等级上限
function Role:getDuShuShiZiLimitLevel()
	local level = 400

	local literaryBox = self:getAttr("literaryBox")

	for i,v in ipairs(literaryBox) do
		local lv = self:getLiteraryLvByExp(v.exp)
		if lv / 100 > 0 then
			local BookLiterary = require("app.models.book.BookLiterary")
			local addLv = BookLiterary:getReadLvForSkill(v.literaryId) * math.floor(lv / 100)
			level = level + addLv
		end
	end
	if level >= 1000 then
		level = 1000
	end
	return level
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/05 17:28:37
-- @desc 学习心得锻造知识
function Role:addForgeKnowledge(forgeId,knowledgeList)
	self.forgeSkill = Helper:getDef(forgeSkill,{})
	if type(forgeId) ~= "string" or MapIsEmpty(knowledgeList) == true then
		if PRINT_MODE == 1 then
			print("-----------------------------------------",forgeId,knowledgeList)
			return
		end
	end
	self.forgeSkill[forgeId] = knowledgeList
end


-- @desc 清除走穴十四经的标记
function Role:clearXingZhenFlag()
	for k,v in pairs(self.xingzhen) do
		if k ~= "effectsCount" then
			self.xingzhen[k] = nil
		end
	end
	-- self:setFlag("行针针法Skills",nil)
end


--@desc 获取用户地图id
function Role:getHouseId()
    local mid = nil

    local fq = self:getHomelandAttr("fq")
    if MapIsEmpty(fq) then
        return mid
    end

    return fq.mid
end

--@desc 获取房屋状态，0为未搬入，1为已搬入
function Role:getHouseStatus()
    local fq = self:getHomelandAttr("fq")
    return fq.status
end

--@desc 获取地皮
function Role:getDpId()
    local fq = self:getHomelandAttr("fq")

    return fq.dpId
end

function Role:setHomelandAttr( attrName,value )
    self.Homeland[attrName] = value
end

function Role:getHomelandAttr(attrName)
    return self.Homeland[attrName]
end

--@desc: 保存副本支线节点
--@author:Liang SongQiang
--@time:2018-12-24 15:48:38
--@mapId:副本ID
--@branchId:支线ID
--@saveNodeId: 支线节点ID
function Role:saveMapNode(mapId,branchId,saveNodeId)
    local mapStore = self:getAttr("mapStore")

	if mapStore[mapId] == nil then
		mapStore[mapId] = {}
    end
    
	if mapStore[mapId][branchId] ~= saveNodeId then
		mapStore[mapId][branchId] = saveNodeId
	end

end

--@desc 新地图节点标记，重置副本，传承副本都会删除该标记
function Role:setNodeFlag(mapId,name,value)
    local flag = self:getAttr("mapNodeFlag")

    if flag[mapId] == nil then
        flag[mapId] = {}
    end

    flag[mapId][name] = value

    self:setAttr("mapNodeFlag",flag)
end

function Role:getNodeFlag(mapId,name,def)
    local flag = self:getAttr("mapNodeFlag")

    if def == nil then
        def = 0
    end

    if flag[mapId] == nil then
        return def
    end

    if flag[mapId][name] == nil then
        return def
    end

    return flag[mapId][name]
end

function Role:destory()
	if self._buffManager ~= nil then
		self._buffManager:destory()
	end

	if self.emotionMgr ~= nil then
		self.emotionMgr:destory()
	end

	MessageCenter:removeObjListener(self)
end


-- 模块相关接口 --
function Role:getObservable()
	return self:callModuleFunc("getObservable")
end

-- 分发事件
function Role:dispatchEvent(name, ...)
	self:callModuleFunc("dispatchEvent", name, ...)
end

-- 初始化角色属性监控器
function Role:initAttrMonitor()
	self:callModuleFunc("initAttrMonitor")
end

-- 监控角色属性变化
function Role:watchAttrChange(attrName, onChange)
	return self:callModuleFunc("watchAttrChange", attrName, onChange)
end

-- 监控角色属性最终值变化
function Role:watchFinalAttrChange(attrName, onChange)
	return self:callModuleFunc("watchFinalAttrChange", attrName, onChange)
end

--@desc 监控角色所有属性
function Role:watchAllFinalAttrChange(onChange)
	return self:callModuleFunc("watchAllFinalAttrChange", onChange)
end

--@desc 这个方法只用来处理角色自身属性之间的联动变化
function Role:watchFinalAttrChangeWithDependMap(attrDependMap, attrWatchMap)
	return self:callModuleFunc("watchFinalAttrChangeWithDependMap", attrDependMap, attrWatchMap)
end

function Role:getSelfCreatedSkillSystem()
	return self._selfCreatedSkillSystem
end

--@return [src.app.models.mask.MaskSystem#MaskSystem]
function Role:getMaskSystem()
	return self._maskSystem
end

function Role:wearMask(itemId,lv)
	return self:getMaskSystem():wearMask(itemId,lv)
end

function Role:unwearMask()
	return self:getMaskSystem():unwearMask()
end

function Role:getWearMask()
	return self:getMaskSystem():getWearMask()
end

function Role:getPortraitId()
	return self:getAttr("portrait").id
end

function Role:getPortraitLv()
	return self:getAttr("portrait").lv
end

function Role:setDreamSystem(dreamSystem)
	self._dreamSystem = dreamSystem
end

function Role:getDreamSystem()
	return self._dreamSystem
end

function Role:getSkillFile()
	--@desc 南柯梦境角色暂时用这种方式获取技能文件
	if self._isFondDrRole == true then
		return require("app.models.FondDream.Skill.FondSkill")
	end
	return require("app.models.skill.Skill")
end

--@desc: 设置邮箱是否有未处理邮件的状态 1，表示有，0表示没有
--@state: 1，表示有，0表示没有
function Role:setMailBoxState(state)
	self._mailBoxState = state
end

function Role:getMailBoxState()
	return self._mailBoxState or 0
end

--@return [src.app.models.HeadViewSystem.RoleViewBorderSys#RoleViewBorderSys]
function Role:getRoleViewBorderSys()
	return self._roleViewBorderSys
end

function Role:setBorderShowList(list)
	self.borderShowList = list
end

function Role:getBorderShowList()
	return self.borderShowList
end

--@desc: 
--@author:LvBin
--@time:2022-03-11 17:12:27
--@return [src.app.models.role.lianGong.lianGongSystem#LianGongSystem]
function Role:getLianGongSystem()
    --@desc 练功系统
    if self._lianGongSystem == nil then
        local LianGongSystem = require("src.app.models.role.lianGong.LianGongSystem")
	    self._lianGongSystem = LianGongSystem:create(self)
    end
	return self._lianGongSystem
end

--[[
    @desc: 获得服务器行为系统
    author:TangJian
    time:2022-04-07 18:27:39
    @return:
]]
function Role:getServerActionSystem()
    if self.__serverActionSystem == nil then
        local ServerActionSystem = require("app.models.ServerAction.ServerActionSystem")
        self.__serverActionSystem = ServerActionSystem:create()
        self.__serverActionSystem:setPlayer(self)
    end
    return self.__serverActionSystem
end

--@desc: 获得修炼系统
--@author:LvBin
--@time:2022-04-11 10:26:25
--@return
function Role:getXiuLianSystem()
    if self._xiuLianSystem == nil then
        local XiuLianSystem = require("src.app.models.role.lianGong.XiuLianSystem")
        self._xiuLianSystem = XiuLianSystem:create(self)
    end
	return self._xiuLianSystem
end

--@desc: 获得心神系统
--@author:LvBin
--@time:2022-04-11 10:26:53
--@return
function Role:getXinShenSystem()
	if self.__xinShenSystem == nil then
        local XinShenSystem = require("src.app.models.role.xinShen.XinShenSystem")
        self.__xinShenSystem = XinShenSystem:create()
        self.__xinShenSystem:setPlayer(self)
    end
    return self.__xinShenSystem
end

--@desc: 获取拳脚系统
--@author:LvBin
--@time:2022-09-16 14:56:17
--@return [src.app.models.FistFootSystem.FistFootSystem#FistFootSystem]
function Role:getFistFootSystem()
    if self.__fistFootSystem == nil then
        local FistFootSystem = require("src.app.models.FistFootSystem.FistFootSystem")
	    self.__fistFootSystem = FistFootSystem:create(self)
    end
	return self.__fistFootSystem
end

function Role:getFistFootEffects()
	local list = {}
	local quanjiao1SkillType = nil
	local quanjiao2SkillType = nil
	local quanjiao1 = self:getPrepareSkill("quanjiao1")
	local quanjiao2 = self:getPrepareSkill("quanjiao2")
	local RoleFistFootEffect = require("src.app.models.FistFootSystem.FistFootEffect.RoleFistFootEffect")

	if quanjiao1 then
		local skill = Skill:getSkill(quanjiao1)
		local skillTypes = skill:getSkillTypes()
		for _,skill_type_id in ipairs(skillTypes) do
			if BasicSkill.IsAttackType(skill_type_id) then
				quanjiao1SkillType = skill_type_id
			end
		end
	end

	if quanjiao2 then
		local skill = Skill:getSkill(quanjiao2)
		local skillTypes = skill:getSkillTypes()
		for _,skill_type_id in ipairs(skillTypes) do
			if BasicSkill.IsAttackType(skill_type_id) then
				quanjiao2SkillType = skill_type_id
			end
		end
	end

	if quanjiao1SkillType then
		local prepFistFootEffects = self:getPrepFistFootEffects()
		for i, effect in pairs(prepFistFootEffects) do
			local _effect = RoleFistFootEffect:create(effect)
			_effect:setSourceFromPrepSkill()
			table.insert(list, _effect)
		end
	end
	
	if quanjiao2SkillType then
		if quanjiao1SkillType ~= quanjiao2SkillType then
			local standByFistFootEffects = self:getStandByFistFootEffects()
			for i, effect in pairs(standByFistFootEffects) do
				local _effect = RoleFistFootEffect:create(effect)
				_effect:setSourceFromStandBySkill()
				table.insert(list, _effect)
			end
		else
			for i, effect in ipairs(list) do
				effect:setSourceFromPrepSkillAndStandBySkill()
			end
		end
	end

	return list
end

function Role:getPrepFistFootEffects()
	local list = {}
	
	local prepSkillId = self:getPrepareSkill("quanjiao1")
	if prepSkillId then
		local prep_skill = Skill:getSkill(prepSkillId)
		if prep_skill then
			local skillTypes = prep_skill:getSkillTypes()
			for _,skill_type_id in ipairs(skillTypes) do
				if BasicSkill.IsAttackType(skill_type_id) then
					local effects = self:getFistFootSystem():getFistFootEffects(skill_type_id)
					table.appendArray(list,effects)
				end
			end
		end
	end

	return list
end

function Role:getStandByFistFootEffects()
	local list = {}
	local standbyPrepSkillId = self:getPrepareSkill("quanjiao2")
	if standbyPrepSkillId then
		local standBy_skill = Skill:getSkill(standbyPrepSkillId)
		if standBy_skill then
			local skillTypes = standBy_skill:getSkillTypes()
			for _,skill_type_id in ipairs(skillTypes) do
				if BasicSkill.IsAttackType(skill_type_id) then
					local effects = self:getFistFootSystem():getFistFootEffects(skill_type_id)
					table.appendArray(list,effects)
				end
			end
		end
	end
	return list
end

function Role:getPrepFistFootTechniques()
	local list = {}
	local prepSkillId = self:getPrepareSkill("quanjiao1")
	if prepSkillId then
		local prep_skill = Skill:getSkill(prepSkillId)
		if prep_skill then
			local skillTypes = prep_skill:getSkillTypes()
			for _, skill_type_id in ipairs(skillTypes) do
				if BasicSkill.IsAttackType(skill_type_id) then
					local techniques = self:getFistFootSystem():getTechniquesByTypeFromClassMap(skill_type_id)
					table.appendArray(list, techniques)
				end
			end
		end
	end
	return list
end

function Role:getStandByFistFootTechniques()
	local list = {}
	local standbyPrepSkillId = self:getPrepareSkill("quanjiao2")
	if standbyPrepSkillId then
		local standBy_skill = Skill:getSkill(standbyPrepSkillId)
		if standBy_skill then
			local skillTypes = standBy_skill:getSkillTypes()
			for _, skill_type_id in ipairs(skillTypes) do
				if BasicSkill.IsAttackType(skill_type_id) then
					local techniques = self:getFistFootSystem():getTechniquesByTypeFromClassMap(skill_type_id)
					table.appendArray(list, techniques)
				end
			end
		end
	end

	return list
end

-- 获取主手技巧伤害
function Role:getPrepJqdamage()
    local jqdamage = 0

    local fistFootTechniques = self:getPrepFistFootTechniques()
    for i, t in ipairs(fistFootTechniques) do
        jqdamage = jqdamage + t:getJqdamage()
    end

    return jqdamage
end

-- 获取副手技巧伤害
function Role:getStandByJqdamage()
    local jqdamage = 0

    local fistFootTechniques = self:getStandByFistFootTechniques()
    for i, t in ipairs(fistFootTechniques) do
        jqdamage = jqdamage + t:getJqdamage()
    end

    return jqdamage
end

--@desc: 获取师门建设日常
--@author:LvBin
--@time:2023-08-18 14:43:07
--@return
function Role:getTeacherBuildSystem()
    if self.__teacherBuildSystem == nil then
        local TeacherBuildSystem = require("src.app.models.TeacherBuildSystem.TeacherBuildSystem")
        self.__teacherBuildSystem = TeacherBuildSystem:create(self)
    end

    return self.__teacherBuildSystem
end

function Role:resetTeacherBuildSystemData()
    self:getTeacherBuildSystem():resetData()
end

--@desc: 获取存档中先天分配方案数据
--@author:Seven
--@time:2024-01-08 18:29:26
function Role:getAndInitNaturalAttrAdjustmentPlanData()
    if User:getRole() ~= self then
        error("因无设计需求，该方法暂不提供非当前玩家角色调用")
        return nil
    end

    local NaturalAttrUtil = require("app.models.role.attr.NaturalAttributePlan.NaturalAttrUtil")
    if self.naturalAttrPlan == nil then
        self.naturalAttrPlan = NaturalAttrUtil:getPlayerInitNaturePlan(self)
    else
        local roleSkill = self:getSkill(SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch"))
        local hasSkill = roleSkill ~= nil and roleSkill.exp > 0

        if hasSkill then
            if self.naturalAttrPlan.planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] == nil then
                self.naturalAttrPlan.planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] = NaturalAttrUtil:initKonwledgePlanData(self)
            end
        else
			--@TODO 2024-01-18 14:55:14 如果没有武学且有数据，直接删除，只有GM工具直接删除武学会造成该情况出现
            if self.naturalAttrPlan.planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] ~= nil then
                self.naturalAttrPlan.planDict[NaturalAttrAdjustmentConst.PLAN_TYPE.KONWLEDGE_SKILL_PLAN] = nil
            end
        end
    end

    return self.naturalAttrPlan
end


--@desc: 
--@author:Seven
--@time:2024-01-10 20:21:22
--@attrPlan: [src.app.models.role.attr.NaturalAttributePlan.INaturalPlan#INaturalPlan]
function Role:updatePlayerNaturalAttrAdjustmentPlanData(attrPlan)
    if User:getRole() ~= self then
        error("因无设计需求，该方法暂不提供非当前玩家角色调用")
        return nil
    end
    local planType = attrPlan:getNaturalPlanType()

    if self.naturalAttrPlan.planDict[planType] == nil then
        error("updatePlayerNaturalAttrAdjustmentPlanData 方案类型未解锁或不存在 : " .. tostring(planType))
    end

    for k, v in pairs(attrPlan:getNaturalPlanAttrDict()) do
        self.naturalAttrPlan.planDict[planType][k] = v
    end
end


function Role:updatePlayerUsageNaturalAttrAdjustmentPlan(planType)
    if table.keyof(NaturalAttrAdjustmentConst.PLAN_TYPE,planType) == nil then
        error("planType is not error : " .. tostring(planType))
    end

    self.naturalAttrPlan.usage = planType
end

--@desc: 获取物品使用内力恢复加成
--@author:Seven
--@time:2024-01-12 12:02:19
--@return number
function Role:getNeiliItemRecoveryAddition()
    local value = 0

    local roleSkill = self:getSkill(SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch"))

    if roleSkill ~= nil then
        --@RefType [src.app.models.skill.skills.NaturalAttrAdjustmentSkill#NaturalAttrAdjustmentSkill]
        local skill = Skill:getSkill(roleSkill.id)
        value = skill:getSkillStageBySkillLv(skill:getLv(roleSkill.exp)):getStageParam("itemrecovery")
    end

    return value
end

--@desc: 打坐额外加成
--@author:Seven
--@time:2024-01-12 14:27:12
function Role:getDazuoAddition()
	local value = 0
    local roleSkill = self:getSkill(SkillConst:getZhiShiSkillParamContent("skillID_pointSwitch"))

    if roleSkill ~= nil then
        --@RefType [src.app.models.skill.skills.NaturalAttrAdjustmentSkill#NaturalAttrAdjustmentSkill]
        local skill = Skill:getSkill(roleSkill.id)
        value = skill:getSkillStageBySkillLv(skill:getLv(roleSkill.exp)):getStageParam("meditation")
    end

	print("skillID_pointSwitch:",value)

	return value
end

--------------------------------------------------------------------------------------------------------------------
--易容术相关接口
function Role:getYiRongShuSystem()
    if self.__yiRongShuSystem == nil then
	    self.__yiRongShuSystem = require("app.models.role.yirongshu.YiRongShuSystem"):create(self)
    end

	return self.__yiRongShuSystem
end

--@desc: 开始易容
--@author:LvBin
--@time:2024-07-09 10:40:23
--@list: 易容数据
--@return
function Role:doPolymorph(list)
	self:getYiRongShuSystem():doPolymorph(list)
end

--@desc: 结束易容
--@author:LvBin
--@time:2024-07-09 10:51:02
--@return
function Role:stopPolymorph()
	self:getYiRongShuSystem():stopPolymorph()
end

--@desc: 取消易容
--@author:LvBin
--@time:2024-07-09 11:17:32
--@return
function Role:cancelPolymorph()
	self:getYiRongShuSystem():cancelPolymorph()
end

--@desc: 检查角色是否易容
--@author:LvBin
--@time:2024-07-09 12:17:42
--@return
function Role:checkRoleIsPolymorph()
	return self:getYiRongShuSystem():checkRoleIsPolymorph()
end

--@desc: 检查角色是否易容
--@author:LvBin
--@time:2024-07-09 12:20:52
--@return
function Role:checkPolymorphIsCd()
	return self:getYiRongShuSystem():checkPolymorphIsCd()
end

--@desc: 易容期间，容貌发生改变
--@author:LvBin
--@time:2024-07-09 12:28:52
--@return
function Role:addPolymorphLastLooks()
	self:getYiRongShuSystem():addPolymorphLastLooks()
end

--@desc: 能否进行阴阳嬗变
--@author:LvBin
--@time:2024-07-09 12:07:45
--@return
function Role:isGenderTransition()
	return self:getYiRongShuSystem():isGenderTransition()
end

--@desc: 阴阳嬗变
--@author:LvBin
--@time:2024-07-09 12:08:17
--@return
function Role:genderTransition()
	self:getYiRongShuSystem():genderTransition()
end

--@desc: 阴阳嬗变提示文本
--@author:LvBin
--@time:2024-07-11 11:16:28
--@return
function Role:getGenderTransitionText()
	return self:getYiRongShuSystem():getGenderTransitionText()
end

--@desc: 获取角色经脉系统
--@author:Seven
--@time:2025-01-16 16:56:32
--@return [src.app.models.Meridian.System.IMeridianRoleSystem#IMeridianRoleSystem]
function Role:getMeridianSystem()
	if self.__meridianSystem == nil then
		local MeridianRoleSystem = require("src.app.models.Meridian.System.MeridianRoleSystemImpl")
		self.__meridianSystem = MeridianRoleSystem:create(self)
	end

	return self.__meridianSystem
end

function Role:reInitMeridianSystem()
	self.__meridianSystem = nil
end

--@desc: 获取角色隐脉系统
--@author:LvBin
--@time:2025-02-27 15:58:34
--@return [src.app.models.Meridian.HiddenMeridianSystem.HiddenMeridianSystem#HiddenMeridianSystem]
function Role:getHiddenMeridianSystem()
	if self.__hiddenMeridianSystem == nil then
		local HiddenMeridianSystem = require("app.models.Meridian.HiddenMeridianSystem.HiddenMeridianSystem")
		self.__hiddenMeridianSystem = HiddenMeridianSystem:create(self)
	end

	--@desc : 如果隐脉系统未解锁，则不初始化系统数据
	if self.__hiddenMeridianSystem:isUnlocked() and not self.__hiddenMeridianSystem:isInitSysData() then
		self.__hiddenMeridianSystem:initSysData()
	end
	
	return self.__hiddenMeridianSystem
end

--@author:Seven
--@time:2025-02-21 18:35:58
--@return [src.app.models.RoleStatusTags.RoleStatusTagsSystem#RoleStatusTagsSystem]
local function __getStatusTagsSystem(self)
	if self.__roleStatusTagsSystem == nil then
		local RoleStatusTagsSystem = require("app.models.RoleStatusTags.RoleStatusTagsSystem")
		self.__roleStatusTagsSystem = RoleStatusTagsSystem:create(self , "__player__")
	end

	return self.__roleStatusTagsSystem
end

function Role:setRoleStatusTags(tagId, tagValue)
    __getStatusTagsSystem(self):setStatusTags(tagId, tagValue)
end

function Role:getRoleStatusTags(tagId)
    return __getStatusTagsSystem(self):getStatusTagValue(tagId)
end

function Role:setInheritRoleStatusTags(tagId, tagValue)
    __getStatusTagsSystem(self):setInheritStatusTags(tagId, tagValue)
end

function Role:getInheritRoleStatusTags(tagId)
    return __getStatusTagsSystem(self):getInheritStatusTagValue(tagId)
end

function Role:setTimeStatusTags(tagId,tagValue)
	__getStatusTagsSystem(self):setTimeStatusTagValue(tagId,tagValue)
end

function Role:getTimeStatusTags(tagId)
	return __getStatusTagsSystem(self):getTimeStatusTagValue(tagId)
end

function Role:setInheritTimeStatusTags(tagId,tagValue)
	__getStatusTagsSystem(self):setInheritTimeStatusTagValue(tagId,tagValue)
end

function Role:getInheritTimeStatusTags(tagId)
	return __getStatusTagsSystem(self):getInheritTimeStatusTagValue(tagId)
end

function Role:deleteRoleStatusTags(tagId)
	return __getStatusTagsSystem(self):deleteStatusTags(tagId)
end

function Role:getAllInheritStatusTags()
	return __getStatusTagsSystem(self):getAllInheritStatusTags()
end

--@region 因NPC没有很好的统一创建接口，所以暂时使用这种方式区分NPC使用操作
--@TODO 2025-03-18 16:27:14 需抽离NPC相关方式
local function getNpcStatusTagSystem(self)
	if self.__npcStatusTagsSystem == nil then
		local RoleStatusTagsSystem = require("app.models.RoleStatusTags.RoleStatusTagsSystem")
		self.__npcStatusTagsSystem = RoleStatusTagsSystem:create(self, "__npc__")
	end

	return self.__npcStatusTagsSystem
end

function Role:setNpcStatusTags(tagId, tagValue)
    getNpcStatusTagSystem(self):setStatusTags(tagId, tagValue)
end

function Role:getNpcStatusTags(tagId)
    return getNpcStatusTagSystem(self):getStatusTagValue(tagId)
end

function Role:deleteNpcStatusTags(tagId)
	return getNpcStatusTagSystem(self):deleteStatusTags(tagId)
end
--@endregion


--@desc: 获取隐脉系统武学伤害属性加成
--@author:LvBin
--@time:2025-03-03 11:13:57
--@damageAttrTypeId:伤害类型id
--@damageAttrTypeStr: 属性类型
--@return
function Role:getHiddenMeridianSysDamageAttrFactor(damageAttrTypeId, damageAttrTypeStr)
	--@RefType [src.app.models.Meridian.HiddenMeridianSystem.IHiddenMeridianSystem#IHiddenMeridianSystem]
    local hiddenMeridianSystem = self:getHiddenMeridianSystem()

    local buffAttrMap = hiddenMeridianSystem:getHiddenMeridianBuffAttrs()

	local value = 0

	damageAttrTypeId = tostring(damageAttrTypeId)

	if buffAttrMap[damageAttrTypeId] then
		if buffAttrMap[damageAttrTypeId][damageAttrTypeStr] then
			value = buffAttrMap[damageAttrTypeId][damageAttrTypeStr]
		end
	end
    
	return value
end

--@desc: 获取隐脉系统玄络buff触发的主动效果
--@author:LvBin
--@time:2025-06-19 16:36:15
--@return
function Role:getHiddenMeridianSysActiveEffects()
	local activeEffects = {}

	--@RefType [src.app.models.Meridian.HiddenMeridianSystem.IHiddenMeridianSystem#IHiddenMeridianSystem]
    local hiddenMeridianSystem = self:getHiddenMeridianSystem()

	local activeEffectDataList = hiddenMeridianSystem:getHiddenMeridianActiveEffectDataList()

	local HiddenMeridianActiveEffect = require("app.models.Meridian.HiddenMeridianBuff.HiddenMeridianActiveEffect")

	if not MapIsEmpty(activeEffectDataList) then
		for i,effectData in pairs(activeEffectDataList) do
			local activeEffect = HiddenMeridianActiveEffect:create(effectData):getActiveEffect()

			table.insert(activeEffects,activeEffect)
		end
	end
	
	return activeEffects
end

function Role:getCurrencyVersion()
	return self.currencyVersion
end

function Role:setCurrencyVersion(currencyVersion)
	self.currencyVersion = currencyVersion
end

--@desc: 设置观影堂特权过期时间
--@author:LvBin
--@time:2025-08-11 16:53:03
--@expiredTime: 
--@return
function Role:setViewingHallPrivilegeExpiredTime(expiredTime)
	if type(expiredTime) == "number" then
		self.viewingHallInfo.privilege_expired_time = expiredTime
	end
end

function Role:getViewingHallPrivilegeExpiredTime()
	return self.viewingHallInfo.privilege_expired_time
end

--@desc: 设置观影堂特权剩余使用次数
--@author:LvBin
--@time:2025-08-11 16:53:26
--@count: 
--@return
function Role:setViewingHallPrivilegeRemainingWatches(count)
	if type(count) == "number" then
		self.viewingHallInfo.privilege_remaining_watches = math.max(count,0)
	end
end

function Role:getViewingHallPrivilegeRemainingWatches()
	return self.viewingHallInfo.privilege_remaining_watches
end

--@desc: 是否有观影堂特权
--@author:LvBin
--@time:2025-08-11 16:57:36
--@return
function Role:isViewingHallPrivilege()
	return self.viewingHallInfo.privilege_expired_time - GetTime() > 1
end

function Role:isShowViewingHallHongDian()
	if self:isViewingHallPrivilege() then
		return self:getViewingHallPrivilegeRemainingWatches() > 0
	else
		return self:getDayFlag("guanYingHongDian") == 0 
	end
end


Role.isEncrypted = true
return NewClass("Role", {IRoleInput}, Role, true)
0000