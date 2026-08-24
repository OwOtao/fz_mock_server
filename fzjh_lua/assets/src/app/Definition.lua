require("socket")
require("app.models.game.Game")

-- DEBUG
MessageCenter = require("app.MessageCenter")

--@desc 1 DEBUG模式 2 非DEBUG模式 3 DEBUG模式（本地数据库）
DEBUG_MODE = 2     
PRINT_MODE = 2     -- 1 输出, 2 不输出
PRINT_MODE_GHZ = true
DEBUG_TANG = true -- 调试开关

-- 年龄
AGE = -2

-- 用作功能测试 add by TangJian 2016/11/02 17:13:12
TANGJIAN_TEST_ENABLE = true

-- 不能修改 add by TangJian 2016/11/08 16:03:54
FILE_IS_LOADING = false -- 文件是否已加载 true 已加载 false 未加载 （主要用于处理 MyAPP文件 因文件未加载而调用的报错）

-- add by XiaoZhiWei 2017/08/17 15:44:47 用于判断是否能够保存存档
IS_ABLE_TO_SAVE_DATA = true

-- add by XiaoZhiWei 2019/02/25 14:44:42 判断新报检查返回状态
NOT_NEED_CHECK = 0			-- 无需检查
NEED_CHECK_AND_IS_OPEN = 1	-- 需要检查并且开关打开
NEED_CHECK_AND_NOT_OPEN = 2	-- 需要检查并且开关未开

-- 全局变量 -------------------------------------------------------------
DIRECTION_RIGHT = 1
DIRECTION_LEFT = -1

-- number的最大最小值 -------------------------------------------------------------
NUMBER_MAX = 99999999
NUMBER_MIN = -99999999

-- 空方法
EMPTY_FUNC = function()end

--按钮音效类型------------------------------------
WIDGET_TOUCH_VOICE_TYPE_BIGBUTTON = 1
WIDGET_TOUCH_VOICE_TYPE_SMALLBUTTON = 2
WIDGET_TOUCH_VOICE_TYPE_BACKBUTTON = 3
WIDGET_TOUCH_VOICE_TYPE_DASUANPANBUTTON = 4
WIDGET_TOUCH_VOICE_TYPE_GOUMAIBUTTON = 5

-- HttpManager -------------------------------------------------------------
-- RetryType
HTTP_MANAGER_RETRY_TYPE_OK = 0
HTTP_MANAGER_RETRY_TYPE_RETRY = 1
HTTP_MANAGER_RETRY_TYPE_RETRY_CANCEL = 2

IS_SHOW_WAITING = true -- 是否显示等待界面  true 显示  false 不显示

-- 是否需要加密 add by XiaoZhiWei 2016/11/14 16:03:54
NEED_ENCRYPT = true 		-- 需要加密
NOT_NEED_ENCRYPT = false 	-- 不需要加密

-- add by XiaoZhiWei 2017/04/21 14:24:00 当前渠道
CURR_DEVICE_CHANNEL = "windows"

--- Order相关 -----------------------------------------------------
ORDER_STATUS_NORMAL = 1				-- 普通的订单
ORDER_STATUS_NOT_NEED_CHECK = 2 	-- 订单信息无误,无需校验 [和服务器校验成功,但本地处理出现异常的情况]

--- Response -----------------------------------------------------
--- Status
RESPONSE_STATUS_SUCCESS = 1
RESPONSE_STATUS_FAILED = 2
RESPONSE_STATUS_UNKNOW = 3

-- fight -------------------------------------------------------------
FIGHT_STATE_NONE = 0 -- 刚创建, 啥都没干的状态
FIGHT_STATE_IDLE = 1 -- 待机状态
FIGHT_STATE_READY = 2 -- 准备状态
FIGHT_STATE_START = 3 -- 开始状态
FIGHT_STATE_RUNNING = 4 -- 运行中
FIGHT_STATE_PAUSE = 5 -- 暂停状态
FIGHT_STATE_COMPLETE = 6 -- 完成状态

-- 新版动画战斗, 变速调整
FIGHT_JUMP_SPEED_SCALE = 1
FIGHT_PRESWING_SPEED_SCALE = 2
FIGHT_AFTSWING_SPEED_SCALE = 1

--  攻击类型
HIT_TYPE_HIT = 1
HIT_TYPE_PARRY = 2
HIT_TYPE_DODGE = 3


------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- add by XiaoZhiWei 2017/11/28 09:34:27 用于模块功能开关按钮
TEACHER_TASK_IS_OPEN = false  -- add by XiaoZhiWei 2017/11/30 17:05:41 师门任务
TEACHER_GUAJI_TASK_IS_OPEN = true --师门挂机任务
ROLE_MONITOR_IS_OPEN = false -- add by XiaoZhiWei 2017/12/01 23:14:38 角色属性相关

LONGEVITY_TASK_IS_OPEN = true 
DONGZHI_ACTION_IS_OPEN = true  -- add by XiaoZhiWei 2017/12/18 11:51:56 冬至活动

CAN_CANGBING = false--是否可以藏兵
JIAYUAN_SYSTEM_IS_OPEN = true -- add by XiaoZhiWei 2018/05/25 16:35:51 家园系统是否开启

ZHONGQIU_2018_IS_OPEN = true
ROLE_DATA_SAVE_STYLE_AUTO = true --存档保存方式 默认自动 false 为手动

DREAM_IS_OPEN = true --梦境系统开关

-- ROLE_MONITOR_IS_OPEN = true
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- action -------------------------------------------------------------
-- 运动变化类型
Linear = 0

Sine_EaseIn = 1
Sine_EaseOut = 2
Sine_EaseInOut = 3

--4倍速率
Quad_EaseIn = 4
Quad_EaseOut = 5
Quad_EaseInOut = 6


Cubic_EaseIn = 7
Cubic_EaseOut = 8
Cubic_EaseInOut = 9

--四分之一
Quart_EaseIn = 10
Quart_EaseOut = 11
Quart_EaseInOut = 12

Quint_EaseIn = 13
Quint_EaseOut = 14
Quint_EaseInOut = 15

Expo_EaseIn = 16
Expo_EaseOut = 17
Expo_EaseInOut = 18

Circ_EaseIn = 19
Circ_EaseOut = 20
Circ_EaseInOut = 21

Elastic_EaseIn = 22
Elastic_EaseOut = 23
Elastic_EaseInOut = 24

Back_EaseIn = 25
Back_EaseOut = 26
Back_EaseInOut = 27

Bounce_EaseIn = 28
Bounce_EaseOut = 29
Bounce_EaseInOut = 30


------神兵系统
DUANZAO_EXP_MAX_DAY = 72000 --锻造增加锻造之术每日经验上限
RONGLIAN_EXP_MAX_DAY = 12000 --熔炼增加锻造之术每日经验上限
MAX_CUILIAN_DAY_EXP = 40000 --淬炼增加锻造之术每日经验上限
CAN_SHENBING_EXP = 3000000  --经验限制
FIRST_DUANZAO  = 30   --锻造时间
SHENBING_LV_LIMIT = 100  --等级
SHENBING_JIAGONG_PAYYUANBAO = 30  ---加工元宝消耗
SHENBING_PAY_QI = 10   --消耗的气血
SHENBING_PAY_JING = 1   --消耗的精力
-- UI -------------------------------------------------------------
UI_ANIM_DURATION = 0.2 -- UI动画时间

-- 角色 -------------------------------------------------------------
ROLE_TYPE_USER = 1
ROLE_TYPE_NPC = 2

-- 技能 -------------------------------------------------------------
-- 技能基本类型
SKILL_TYPE_BASE = 1     -- 基本招式
SKILL_TYPE_NORMAL = 2   -- 普通招式, 可装备
SKILL_TYPE_SPECIAL = 3  -- 门派技能
SKILL_TYPE_DUSHU = 4	-- 读书识字（特殊基本招式）
SKILL_TYPE_HUIFU = 5	-- 回复类型
SKILL_TYPE_DUNDI = 6	-- 遁地类型
SKILL_TYPE_ZHISHI = 7	-- 知识类型
SKILL_TYPE_SELFCREATE = 8 --自创武学

--@desc 基本武功 及 某些特殊武功等级上限，其余武功及知识类技能等级上限在此基础上+1
SKILL_LEVEL_LIMIT = 1000

-- 手段类型
SKILL_METHOD_TYPE_QUANJIAO = 1	-- 拳脚
SKILL_METHOD_TYPE_NEIGONG = 2 	-- 内功
SKILL_METHOD_TYPE_QINGGONG = 3	-- 轻功
SKILL_METHOD_TYPE_ZHAOJIA = 4	-- 招架
SKILL_METHOD_TYPE_JIAN = 5    	-- 剑法
SKILL_METHOD_TYPE_DAO = 6    	-- 刀法
SKILL_METHOD_TYPE_GUN = 7   	-- 棍法
SKILL_METHOD_TYPE_ANQI = 8    	-- 暗器
SKILL_METHOD_TYPE_BIANFA = 9    -- 鞭法
SKILL_METHOD_TYPE_SHUANGCHI = 10    -- 双持
SKILL_METHOD_TYPE_QIN = 11    -- 琴

-- 任务 -------------------------------------------------------------
TASK_STATE_NONE = 1      -- 无状态
TASK_STATE_DISABLE = 2   -- 不能用
TASK_STATE_IDLE = 3      -- 空闲
TASK_STATE_GUAJI = 4     -- 挂机
TASK_STATE_COOLDOWN = 5  -- 冷却
TASK_STATE_ACCEPT = 6	 -- 接受
TASK_STATE_TO_SUBMIT = 7 -- 待提交
TASK_STATE_DISPATCH = 8 -- 派遣中
TASK_STATE_COMPLETE = 9 -- 已完成




-- 师门 -------------------------------------------------------------
FAMLIY_FUNCTION_ID_CONSULT = 1 -- 请教
FAMLIY_FUNCTION_ID_MYSKILL = 2 -- 技能
FAMLIY_FUNCTION_ID_KOWTOW  = 3 -- 磕头
FAMLIY_FUNCTION_ID_LIANGONG = 4-- 练功

-- 任务当前状态
ROLE_CURR_STATE_IDLE = "1"		-- 空闲
ROLE_CURR_STATE_ZHUDONG = "2"		-- 主动任务
ROLE_CURR_STATE_GUAJI = "3"		-- 挂机任务
ROLE_CURR_STATE_DAZUO = "4"		-- 打坐
ROLE_CURR_STATE_LIANGONG = "5"	-- 练功
ROLE_CURR_STATE_BIGUAN = "6"		-- 闭关
ROLE_CURR_STATE_GUANZHAN = "7"	-- 观战
ROLE_CURR_STATE_TIAOXI = "8"		-- 调息
ROLE_CURR_STATE_READ = "9"		-- 研读
ROLE_CURR_STATE_SHIMEN = "10"     -- 师门任务
ROLE_CURR_STATE_LIANJINGHUAQI = "12"		--练精化气
ROLE_CURR_STATE_TEACHERGUAJI = "13" --师门挂机任务
ROLE_CURR_STATE_XIULIAN = "14" 	-- 修炼

-- 效果类型
-- 0=正面效果 1=减益效果(非毒类) 2=控制效果 3=其他效果 4= 毒类  (负面效果包括减益和毒类效果)
-- 5 特殊增益（无法被截脉或被窃取，或者用于某些特殊需要）6 特殊减益（来自自己，用于某些特殊需要，不能划到一般减益效果里的）7 特殊毒 8 特殊控制
EFFECT_TYPE_POSITIVE = 0
EFFECT_TYPE_NEGATIVE = 1
EFFECT_TYPE_CONTROLL = 2
EFFECT_TYPE_ELSE = 3
EFFECT_TYPE_POISON = 4
EFFECT_SPECIAL_POSITIVE = 5
EFFECT_SPECIAL_NEGATIVE = 6
EFFECT_SPECIAL_POISON = 7
EFFECT_SPECIAL_CONTROLL = 8

--丹药服用状态
ITEM_IS_NOT_USE = 1		-- 未使用
ITEM_IS_IN_USE = 2		-- 使用中

-- 服务器时间
WEB_TIME = 0
BACKGROUND_TIME = 0 -- add by XiaoZhiWei 2018/02/13 15:05:16 用于处理戏台文本输出的bug (显示剩余0秒的bug)
NETWORK_STATE = 1 -- 网络状态 0 未连接 1 已连接

-- 物品状态 （主要区分0 1两种状态）
ITEM_STATE_FALSE = 0	-- 不可用/不可叠加/不可。。。。
ITEM_STATE_TRUE = 1		-- 可用/可叠加/可。。。

DOMAIN = Game:getDomain()
T_TOKEN = ""

OU_SKILL_LV = 1200 --欧冶子锻造技术等级
TIEJIANG_SKILL_LV = 500 --铁匠锻造技术等级


POISONSYS = true --毒药系统开关

NPC_AI = true

SHENBINGSYS = true --神兵系统开关

YIRONGSHU = true --易容术特殊容貌开关

SKILL_ITEM_TYPE = 1 -- 五行遁法使用
SKILL_ITEM_DUNDIFU_TYPE = 2 -- 遁地符使用

-- 伤害类型 1=真伤（无视护盾，但还是会被偏转和反弹影响）
True_Damage = 1

if Game:isTesting() == true then
	PVP_POISONSYS = true --pvp毒药系统开关
	PVP_SHENBINGSYS = true --pvp神兵系统开关
	IS_OPEN_PVP_JINGMAI = true --pvp经脉系统开关
	IS_OPEN_PVP_YIWU = false
else
	PVP_POISONSYS = false
	PVP_SHENBINGSYS = true
	IS_OPEN_PVP_JINGMAI = true
	IS_OPEN_PVP_YIWU =false
end
WEAPONSUBTYPE_IS_OPEN = true 

--家园系统
USER_MAP = true --呼唤管家

--事务功能类
AFFAIR_TYPE_FUN = 1 
--事务显示类
AFFAIR_TYPE_SHOW = 2
--事务信差类
AFFAIR_TYPE_POST = 3

--江湖怪客玩法开关
JIANG_HU_GUAI_KE_ISOPEN = true

-- 新经脉测试开关
IS_OPEN_HUAZHIWEIJIAN = true

--@desc 节点奖励 普通奖励
NODE_REWARD_NOR = 0
--@desc 节点奖励 首次奖励（重置不刷新，传承刷新）
NODE_REWARD_FIRST = 1
--@desc 节点奖励 一次性奖励（从不刷新）
NODE_REWARD_ONLY = 2

-- 新经脉测试开关
IS_OPEN_HUAZHIWEIJIAN = true

-- 商城物品是否打折
IS_NOT_DISCOUNT = 0  --不打折
IS_DISCOUNT = 1 --打折
--------------------------------------------------------------------------------------
-----------------------------  程序内部时间间隔管理
-- 地图刷新间隔(单位 秒)
MAP_REFRESH_INTERVAL = 300

BUTTON_FUNC_LIST = {} -- 按钮事件列表

FORM_MAP_VERSION = 1
EDITOR_MAP_VERSION = 2
CHALLENGE_MAP_VERSION = 3

MAP_TYPE = {
	--@desc 普通副本
	BASE = 1,
	--@desc 玩家自身副本
	MYHOME = 2,
	--@desc 其它玩家的副本
	OTHERHOME = 3,
	--@desc 师门地图
	TEACHERMAP = 4,
	--@desc 梦境副本
	DREAMMAP = 5,
	--@desc 南柯梦境
	FONDDREAMMAP = 6
}

MAP_STATE = {
	--@desc 未解锁
	NOTOPEN = 0,

	--@desc 已解锁
	UNLOCK = 1,

	--@desc 进行中
	WORKING = 2,

	--@desc 已完成
	COMPLETE = 3,
}

--新副本节点状态 
NODE_NOTOPEN = 0 --未解锁
NODE_WORKING = 1 --进行中
NODE_COMPLETE = 2 --已完成
--武学技能状态
SKILL_STATE_GRASP = 1 --已掌握
SKILL_STATE_NOGRASP = 2   --未掌握
SKILL_STATE_NOSEE = 3 --未见闻

-- 连接方向
DIRECTION_LINK = {
	UP = 0,
	RIGHT = 1,
	DOWN = 2,
	LEFT = 3,
	RIGHTUP = 4,
	RIGHTDOWN = 5,
	LEFTDOWN = 6,
	LEFTUP = 7,
	CENTER = 8
}
DIRECTION_LINK_STR = {
	[DIRECTION_LINK.UP] = "up",
	[DIRECTION_LINK.RIGHT] = "right",
	[DIRECTION_LINK.DOWN] = "down",
	[DIRECTION_LINK.LEFT] = "left",
	[DIRECTION_LINK.RIGHTUP] = "rightUp",
	[DIRECTION_LINK.RIGHTDOWN] = "rightDown",
	[DIRECTION_LINK.LEFTDOWN] = "leftDown",
	[DIRECTION_LINK.LEFTUP] = "leftUp",
	[DIRECTION_LINK.CENTER] = "center",
}
--防沉迷
SCREEN_TIME_OPEN = false --防沉迷开关
SCREEN_TIME_LIMIT = 5400 --防沉迷游戏时间上限



AttrName = {
    [1] = "atk",
    [2] = "damage",
    [3] = "protect",
    [4] = "def",
    [5] = "dodge",
    [6] = "parry",
    [7] = "secStr",
    [8] = "secDex",
    [9] = "secCon",
    [10] = "secInt",
    [11] = "str",
    [12] = "dex",
    [13] = "con",
    [14] = "int",
    [15] = "currStr",
    [16] = "currDex",
    [17] = "currCon",
    [18] = "currInt",
    [19] = "qiMax",
    [20] = "neiliMax",
    [21] = "effectStr",
    [22] = "effectDex",
    [23] = "effectCon",
	[24] = "effectInt",
	[25] = "pijuanMax",
	[26] = "neiLiLimit",
    [301] = "atk",
    [302] = "atkScale",
    [303] = "damage",
    [304] = "damageScale",
    [305] = "protect",
    [306] = "protectScale",
    [307] = "def",
    [308] = "defScale",
    [309] = "dodge",
    [310] = "dodgeScale",
    [311] = "parry",
    [312] = "parryScale",
    [313] = "secStr",
    [314] = "secStrScale",
    [315] = "secDex",
    [316] = "secDexScale",
    [317] = "secCon",
    [318] = "secConScale",
    [319] = "secInt",
    [320] = "secIntScale",
    [321] = "str",
    [322] = "strScale",
    [323] = "dex",
    [324] = "dexScale",
    [325] = "con",
    [326] = "conScale",
    [327] = "int",
    [328] = "intScale",
    [329] = "currStr",
    [330] = "currStrScale",
    [331] = "currDex",
    [332] = "currDexScale",
    [333] = "currCon",
    [334] = "currConScale",
    [335] = "currInt",
    [336] = "currIntScale",
    [337] = "qiMax",
    [338] = "qiMaxScale",
    [339] = "neiliMax",
	[340] = "neiliMaxScale",
	[341] = "effectStr",
	[342] = "effectStrScale",
	[343] = "effectDex",
	[344] = "effectDexScale",
	[345] = "effectCon",
	[346] = "effectConScale",
	[347] = "effectInt",
	[348] = "effectIntScale",
	[349] = "zhaoAtkScale",
	[350] = "pijuanMax",
	[351] = "neiLiLimit",
	[352] = "neiLiLimitScale",


	[360] = "zhaoHitReduceRate",
	[361] = "zhaoIsHit",

    [500] = "qiRecover",
    [501] = "neiliRecover",
    [502] = "activeNeiliCost",
	[503] = "activeNeiliCostPercent",
	[504] = "jiaLiNeiliCost",
	[505] = "jiaLiNeiliCostPercent",
    [506] = "useRestFailRate",
	
	
    [600] = "enterDreamRate",
    [601] = "soberRecover",
    [602] = "drRoleMoneyAdd",
	[603] = "drRoleWeightAdd",
	[604] = "drEmgrAttackFailRate", -- 情绪buff导致的攻击失败
	[605] = "drEmotionAttackRate", -- 情绪buff导致的攻击失败
	[606] = "drEmotionAttackPercent", -- 情绪buff导致的攻击失败
	[607] = "drEmgrTargetAttackFailRate", -- 情绪buff导致的对方攻击失败概率
	[608] = "drEmotionTargetAtkRate", -- 情绪附带对方攻击加成概率
	[609] = "drEmotionTargetAtkPercent", -- 情绪附带对方攻击加成缩放
	[610] = "drTiliConsumeRate", -- 情绪附带普攻体力消耗减少概率
    [611] = "drTiliConsumePercent", -- 情绪附带普攻体力消耗减少倍数
	[612] = "drActiveZhaoUseFailRate",
	[613] = "drFailRecoverQiRate",
	[614] = "drSellItemMoneyAddPercent",
	[615] = "drAddDreamPointsEffectAdditionPercent",

	[650] = "talkWeight1",
	[651] = "talkWeightPercent1",
	[652] = "talkWeight2",
	[653] = "talkWeightPercent2",
	[654] = "talkWeight3",
	[655] = "talkWeightPercent3",
	[656] = "talkWeight4",
	[657] = "talkWeightPercent4",
	[658] = "talkWeight5",
	[659] = "talkWeightPercent5",
	[660] = "talkWeight6",
	[661] = "talkWeightPercent6",
	[662] = "talkWeight7",
	[663] = "talkWeightPercent7",
	[664] = "randomEventWeight1",
	[665] = "randomEventWeightPercent1",
	[666] = "randomEventWeight2",
	[667] = "randomEventWeightPercent2",
	[668] = "randomEventWeight3",
	[669] = "randomEventWeightPercent3",
	[670] = "randomEventWeight4",
	[671] = "randomEventWeightPercent4",
	[672] = "randomEventWeight5",
	[673] = "randomEventWeightPercent5",
	[674] = "randomEventWeight6",
	[675] = "randomEventWeightPercent6",
	[676] = "randomEventWeight7",
	[677] = "randomEventWeightPercent7",
	[678] = "boxEventWeight1",
	[679] = "boxEventWeightPercent1",
	[680] = "boxEventWeight2",
	[681] = "boxEventWeightPercent2",
	[682] = "boxEventWeight3",
	[683] = "boxEventWeightPercent3",
	[684] = "boxEventWeight4",
	[685] = "boxEventWeightPercent4",
	[686] = "boxEventWeight5",
	[687] = "boxEventWeightPercent5",
	[688] = "boxEventWeight6",
	[689] = "boxEventWeightPercent6",
	[690] = "boxEventWeight7",
	[691] = "boxEventWeightPercent7",
	[692] = "newFloorRate",
	[693] = "newFloorRatePercent",
	[694] = "battleWinRate",
	[695] = "battleWinRatePercent",
	[696] = "battleLoseRate",
	[697] = "battleLoseRatePercent",
	[698] = "fightWinRate",
	[699] = "fightWinRatePercent",
	[700] = "fightLoseRate",
	[701] = "fightLoseRatePercent",
	[702] = "talkRate",
	[703] = "talkRatePercent",
	[704] = "randEventRate",
	[705] = "randEventRatePercent",

    [1201] = "qi",
	[1202] = "neili",
	[1203] = "exp",
	[1204] = "lv",
	[1205] = "pijuan",
	[1206] = "looks",
	[1207] = "zhengqi",
	[1208] = "luck",
	[1209] = "money",
	[1210] = "inheritCount",
	[1211] = "qiPercent",



	[1250] = "dreamPoints",
	[1251] = "sober"
}


--御汇令相关
YUHUILING_BUFF = 0.25
YUHUILING_NUM_LIMIT = 2500

--物品使用表现类型
ITEM_USE_TYPE = {
	USE_ITEM_CONFIRM = 1,	--直接使用
	USE_ITEM_ONLY_SHOW_DESC = 2, --仅仅显示输出文本
	USE_ITEM_SHOW_DIALOG = 3,	--显示弹出框
	USE_ITEM_BATCH = 4, --批量使用
	USE_ITEM_YONGBING = 5, --佣兵使用物品
}

--测试代码(1、恢复武器默认打飞打断概率， 2、开启快捷打飞武器，3、开启快捷打断武器，4、开启非招架触发打飞打断武器（正常概率），5、提升玩家pvp招架率)
TEST_COMMAD_VALUE = 0

--角色年龄限制最大为424
ROLE_AGE_LIMIT = 424

function GetLocalTime()
	return socket.gettime()
end

function Sleep(n)
   socket.select(nil, nil, n)
end

function GetTime()
	return WEB_TIME
end

function SetTime(time)
	WEB_TIME = time
    Game:setTime(time)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 重写assert
if DEBUG_MODE == 2 then
  -- function assert(...)
  -- return ...
  -- end
end

-- 输出, 非log
local RegisterRichPrintList = {}
function RegisterRichPrint(id, node, printFunc)
	RegisterRichPrintList[id] = {id = id, node = node, printFunc = printFunc}
	node:addNodeEvent("exit",
	function()
		RegisterRichPrintList[id] = nil
	end)
end

function RichPrint(id, str, verticalSpace)
	local item = RegisterRichPrintList[id]
	if item then
		if item.node and item.printFunc then
			item.printFunc(item.node, str, verticalSpace)

		end
	else
		if PRINT_MODE == 1 then
			print("RichPrint: 找不到 "..tostring(id))
		end
	end
end

-- 弹出文本显示
function PopText(text, color, font, fontSize)
	local PopRichText = require("app.views.layer.PopLayer.PopText")
	local popRichText = PopRichText:pop(text, color, font, fontSize)
end

-- 检查Map是否为空 空 true 非空 false
function MapIsEmpty(map)
	if type(map) ~= "table" then
		return true
	else
		for _, _ in pairs(map) do
			return false		
		end
		return true
	end
end

--打印日记文件的方法
local LOG_FILE_PATH = cc.FileUtils:getInstance():getWritablePath().."BiWuLog.txt"
function writeLog(str)
	local f = io.open(LOG_FILE_PATH, "a")
	f:write(str)
	f:close()
end
-- 是否debug模式 屏蔽打印
if DEBUG_MODE == 2 then
	-- function print()
	-- end
end

if device.platform == "android" then
	local info = Game:getDevInfo()
	local jsonInfo = json.decode(info)
	CURR_DEVICE_CHANNEL = jsonInfo.app_channel
elseif device.platform == "ios" then
	CURR_DEVICE_CHANNEL = "ios"
elseif device.platform == "windows" then
	CURR_DEVICE_CHANNEL = "windows"
end

local ColorManager = require("app.models.colorRes.ColorManager")
local commands = ColorManager:getColors()

function GetColorTb()
    return commands
end

local color_list = {}
for _, colorInfo in pairs(commands) do
    table.insert(color_list, colorInfo)
end

table.sort(
    color_list,
    function(a, b)
        return a.index < b.index
    end
)

function GetColorList()
    return color_list
end



-- function log(...)
-- end
-- function logt(...)
-- end
000000000000