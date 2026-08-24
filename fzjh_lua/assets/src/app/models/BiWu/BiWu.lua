
------------------状态-----------------------
-- 状态self.status = 观看状态

--战斗两种状态：self.fight = 挑衅 TiaoXin /  激战 JiZhan
-- self.result = 战斗结束后

--在每一个界面有一个状态 layerStatus  mainLayer  exitLayer  startLayer

----------------------数据---------
--剩余上台挑战次数： stageTimes
--本周对战记录保存在名为:FightRecord 文件里,数据为：FightRecordData = {}


------方法--------------------------------
--保存本周对栈记录
--查看任务介绍
--获取角色名字。门派。江湖称号等的属性

local Item = require("app.models.item.Item")
local Resource = require("app.Resource")
local DataBase = require("app.DataBase")


-- local BiWu = class("BiWu",cc.Layer)

local BiWu =
{
}
----------------------初始化一些属性------------------------------------------------------------------------------------------
local fightDataMap  = {} --- 在战斗时候统计需要的数据,敌人的气血值

--o就是false 1
-- 没有使用技能回血：+2           notUsedSkill
-- 自身血量小于10%战胜对手：+7    winAndBloodLessTen
-- 3回合内战胜对手：+7            threeWin
-- 1回合内战胜对手：+17           oneWin
-- 无伤战胜对手：+17
---保存战斗的结果  "win|lose|cancel 取消| run 逃跑"      保存在本地
local fightAllData = {}
-----------

-----单独保存本周对战记录的数据
local fightWeekAllData = {}

--初始化属性
function BiWu:init()
	self.status = nil
	self.fight = nil
	self.result = nil
	self.layerStatus = nil
	self.list = nil
	self._isShowMainLayer = nil
	self._callServerTimes = nil
	------武馆管家赶走人的标识
	self._guanJiaThrowOutBattle = nil
	------------能在mainlayer界面打印信息
	self._inMainlayerCanPrintFightMesg = nil

	----切换存档的标识
	self._changeFileBiWuStartLayer = nil
	self._changeFileBiWuWatcherLayer = nil
	self._changeFileBiWuMainLayer = nil

	-----在观看界面观战。自动停止时候，应该在主界面打印提示信息
	self._isWatchNoMoney = nil
	self._isWatchNoTime = nil

	----战斗的过程标志 0没有战斗，1正在战斗， 2战斗结束
	self.fightMark = nil
end

----------------- 获取状态、数据的一些方法 -------------------------------------------------------------------------------------------------------------

-- local fightAllData_tmp = {}

--新建一个文件保存战斗结果
function BiWu:savefightAllData(tb)
	DataBase:setLuaTable("BiWufightAllData"..tostring(User:getRole().userid), fightAllData)
end

---获取战斗结果
function BiWu:getfightAllData()
	return fightAllData
end


--新建一个文件保存本周对战记录的结果
function BiWu:savefightWeekAllData(tb)
	DataBase:setLuaTable("BiWufightWeekAllData"..tostring(User:getRole().userid), fightWeekAllData)
end

---获取本周对战的结果
function BiWu:getfightWeekAllData()
	return fightWeekAllData
end

-- 获取fightAllData的默认结构
local function getFightWeekDataTable()
	local table =
	{
	    ---本周对战记录
	    weekUserData =
	    {
		    list =
			   	{
			   	},
	    }
	}
	return table
end

-- 获取fightAllData的默认结构
local function getFightDataTable()
	local table =
	{
		userid = nil,--保存玩家的userid
		fid = nil, -- 上台的id
		watchFid = nil,--观看的fid

		result = nil ,
		id = 0, -- 当前是战斗的id

		---剩余挑战次数
		left_times = nil,

		notUsedSkill =0 ,
	    winAndBloodLessTen = 0 ,
	    threeWin = 0 ,
	    oneWin = 0,
	    noHurtWin =0 ,

	    ----失败需要告诉服务器的值
	    qi = nil,      -- 气血
	    qiMax = nil,   -- 最大气血
	    neili = nil,   -- 内力
	    neiliMax = nil, -- 最大内力

	    fightOverTime = nil,---战斗结束时间

	    -----保存玩家数据..也需要保存到本地，因为下次进来，挑战时间没有过期 ，应该直接挑战
	    user = nil,

	    role = nil,-----克隆自己的数据去战斗
	    ------对手门派名字信息，用于挑战界面打印
	    opponentMenPaiName = nil,

	    ---挑战的对手信息，用于显示，始终值保存一个数据
	    challengeData=
	    {

	    },
	    _isDeleteWeekFightData = nil,---是否删除了本周对战记录
	    _deleteWeekFightDataTime = nil,---删除本周记录的时间

	---观看数据
	    current_time = nil,---进入观看界面的时间
		expired_time = nil,---最大收益的过期时间
		stopWatchTime = nil,---结束观看时间
		watchTotalPot = nil ,---这次观战获得的总潜能
		watchTotalMoney = nil ,---这次观战消耗的总银两


	---战斗失败，挑战时间，和挑战失效时间
	    fightCurrent_time = nil, ---
		fightExpired_time = nil, ---

		---
		watch_cnt = nil, --在线人数（主界面的人数）
		fightMsgList ={}, ----保存实时输出的对战信息（从服务器获取的list）

		--exitLayer界面的人气数量
		renqi = nil,
		--exitLayer界面的本场人气变化值,显示为(本场人气)，可为负数,下台后清零
		add_renqi = 0,
		--exitLayer界面的今日人气最大值
		day_renqi = nil, 
		---
		fightType = nil, ----1挑衅，2邀战，3告辞， 4挑战


		--五分钟上传存单的时间
		uploadRecord = nil,

		---观看界面被动挑战的结果信息
		watchFightResultMsg = {}  ,

		---本周人气值  历史人气值   本周人气和人气值是一个值 ，用最新的那一个
		history_renqi = nil,
		week_renqi = nil,

		-----第几回合战斗,显示出来的
		current_cnt = 0,

		----这次战斗赢了多少场
		win_times = 0,

		----所有对手的名字
		allBattleName = nil  ,

		---------------使用卡牌的id
		cardId = nil,
		----------本周自己能获取的奖励数
		thisWeekRewardData = nil,


	-----------------------------------------------------------------------一次战斗的信息
		oneFight =
		{
			------本次上台打败人数最多人数
			peopleNum = 0,

			-------挑战界面显示的信息
			tiaoZhanMesg =
			{},
			------------------战斗结束后当次得到的人气数
			win_points = nil, --赢了得到的人气数
			lose_points = nil, --输了得到的人气数

			-----------------本次战斗所获得银两
			allMoney = 0,--一次上台获得的银两

			fightTenAllWin = nil,---一次战斗全胜
			-----得到了这次10场奖励的标示
			isGetWinTimesReward = nil,


			--人气变化
			renqi_delta = 0,
			usedCards = {},
			startTime = nil
		}

	}
	return table
end

--初始化比武保存所有信息的文件
function BiWu:initfightAllData()
	fightAllData = getFightDataTable()
	local ret = DataBase:getLuaTable("BiWufightAllData"..tostring(User:getRole().userid))
	Helper:tableCover(fightAllData, ret)
end
--初始化比武保存本周对战记录的数据
function BiWu:initfightWeekAllData()
	fightWeekAllData = getFightWeekDataTable()
	local ret = DataBase:getLuaTable("BiWufightWeekAllData"..tostring(User:getRole().userid))
	Helper:tableCover(fightWeekAllData, ret)
end


---------获取服务器得到的对战输出信息,每次获取一条，如果输出玩了，自动在获取信息，如果这次时间离开上次获取时间超过一小时，重新获取
function BiWu:getOnefightMsgList()
	local role = User:getRole()
	local time = role:getFlag("访问服务器获取战斗信息")
	local currTime = GetTime()
	local lastTime,currTime = role:getFlag("上次获取战斗打印信息时间"),GetTime()

	if MapIsEmpty(fightAllData) or MapIsEmpty(fightAllData.fightMsgList) or lastTime == nil or tonumber(currTime) - tonumber(lastTime) > 3600 then
		-----上次访问服务器的时间
		if time and currTime - time < 300 then
			if PRINT_MODE ==1 then
				-- PopText("访问服务器太过频繁")
			end
		else
			self:getBiWuFighMessage()  --如果请求出错，连续请求几次，buqingq
			role:setFlag("访问服务器获取战斗信息",GetTime())
		end
	end
	local oneFightMsg = ""
	---一到三秒随机打印信息
	local figure = math.random(1,3)

	if figure == 2 then

		if fightAllData.fightMsgList ~= nil and fightAllData.fightMsgList[1] ~= nil then
			oneFightMsg = Helper:getDef(fightAllData.fightMsgList[1].msg, "")
		end

		---删除一条信息
		table.remove(fightAllData.fightMsgList,1)
		self:savefightAllData(fightAllData)
	
		role:setFlag("上次获取战斗打印信息时间",GetTime())
	else
		return nil
	end
	return oneFightMsg
end


---------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------
-----两种办法，一种：先摆好文本，在创建
--------------二种：先一句一句的创建text，在创建文本，加入到panel里，在摆放位置

--------------------------------------------------------------------------------------------------------------------------------------------
---------------比武所有文本-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------
--观看超时的文本
local watchTimeOverText =""--"你今日已经在这观战得够久了，还是明天再来吧。"
local watchNoMoneyText =
{
	[1] = "CYN你正看的兴起，但此时来了个小厮收赏钱，你身上钱却不够，这尴尬的气氛让你无心再观看比武，你悻悻地离开了观看台。",
	[2] = "CYN你看着擂台之上两位高手正打得不分高下，这时来了个小厮收赏钱，你身上却无分文，这尴尬的气氛让你无心再看比武了。",
}



local watchStageDesc = "擂台的旁边簇拥着不少人，上面有两位高手正在对决，周边还有不少小厮拿着铜锣收些赏钱。"
local wuguanguanjiaDesc = "他就是武馆老管家，脸上笑眯眯的。\n他看起来约六十多岁，他生的YEL面颊凹陷，瘦骨伶仃，可怜可叹NOR。\n他的武功看起来BLU不堪一击NOR，出手似乎HIG很轻NOR。\n他看起来HIG气血充盈，并没有受伤NOR。"

--进入界面说的话
local mainLayerToStartLayerText = "CYN你昂首阔步，走进了比武场。"
local startLayerTextToMainLayerText = "CYN你拨开了人群，来到了擂台的最前面。"
local mainLayerToWatchLayerText = "CYN你登上了观看台，找了一个位置坐下来。"


----武馆管家的交谈
local wuGuanTalkText =
{
	[1] = "YEL武馆管家：少侠初来乍到吧，这比武上台获胜可以获得人气呢。",
	[2] = "YEL武馆管家：观看他人比武说不定能从别人身上学到点东西呢。",
	[3]	= "YEL武馆管家：擂台上被人打败，你也可以继续挑战擂主，不过得选择挑战才行。",
	[4] = "YEL武馆管家：少侠若是觉得对手不合你意，也可以与小老儿说说，不过这个代价嘛..嘿嘿..",
	-- [5] = "YEL武馆管家：打败对手可以获得人气，每周人气最高的大侠可以获得我们独有的称号，他的事迹也将记录在我们的公告之中。",
}

-----观看时候获得收益的文本输出
local watchRewardText =
{
	[1] = "CYN台上的打斗十分激烈，你看的十分高兴，打赏了$M银两，潜能+$E",
	[2] = "CYN比武台上两位高手的较量十分精彩，你不由得看入了神，待你回过神来，你发现你的钱袋居然被偷了！潜能+$E，银两-$M",
	[3] = "CYN台上刀光剑影好一阵打斗，你不由得拍手叫好，你打赏了$M银两，潜能+$E",
	[4] = "CYN台上两位高手打斗得十分精彩，台下一片叫好声不断，你也跟着喝彩，潜能+$E,银两-$M",
	[5] = "CYN两位高手激烈的战斗精彩之极，深深打动了你，你一掷千金，打赏了$M银两，潜能+$E",
	[6] = "CYN擂台上两位高手的打斗让你受益匪浅，你忍不住打赏了$M银两，潜能+$E",
}
local watchStageTwoHour =
{
	[1] = "台上擂主冲着你招了招手，你忍不住上台与他切磋了一二，你被击败了（击败了n），人气+1(-1)",
	[2] = "你看着台上高手的激烈战斗，你忍不住也想一展身手，你登上了擂台，与$N交手获胜（被n打败了），人气+1（-1）",
}

-------------------------------挑战者跳上擂台的文本
--startLayer 的描述
local startLayerDescText = "这里是比武大会观众席，高据擂台之上，雕梁琉瓦，花木游栏。四望青山迎爽，向下看擂台周围人头攒动。桌上放着一块小木牌 ，后壁上贴着一张红纸告示。"
-- local watchTimeIsTwoHour = ""


----------exitLayer界面三个按钮对应的文本，告辞，激战，挑衅
--m代表门派，n代表名字，j代表技能，w代表武器，z代表评价，c代表称号。
--上台，没有上一个对手名字
local defaultText =
{
	[1] =
	{
		[1] = "GLD你双腿一蹬，腾空而起，轻轻落在擂台边上，衣袂襟风，十分潇洒。",
		[2] = "GLD你腾空落在擂台边上，衣袂襟风，十分潇洒。",
		[3] = "GLD你身形飘忽，有如鬼魅，众人眼前一花，再看之时他已经出现在了擂台之上。",
		[4] = "GLD你一个纵身飞起，脚下如凌波踏水，空踏数步，登上了擂台。",
		[5] = "GLD你微微一笑，身形化为一道模糊身影，轻飘飘地落在了擂台之上。",
		[6] = "GLD你单足微一点地，提气纵起，在空中连跨数步，已然落在擂台之上。",
		[7] = "GLD你脚下猛力一登，身体拔起丈高，落在了擂台之上。",
	},
	[2] =
	{
		[1] = "GLD向台下众人抱拳道：",
		[2] = "GLD微一颔首，对众人道：",
		[3] = "GLD微微一笑，冲着台下诸人道：",
	},
	[3] =
	{
		[1] = "GLD吾乃$MWHT$NGLD，江湖人称$C",
		[2] = "GLD吾名为WHT$NGLD，江湖人给面子，人送外号$C",
		[3] = "GLD吾名为WHT$NGLD，乃是$T",
		[4] = "GLD在下WHT$NGLD，外号$T",
		[5] = "GLD在下$CWHT$NGLD，诸位有礼了",
	},
}
--上台，存在上一个对手
local defaultTextExistLastBattle =
{
	[1] =
	{
		[1] = "GLD你双腿一蹬，腾空而起，轻轻落在擂台边上，衣袂襟风，十分潇洒。",
		[2] = "GLD你腾空落在擂台边上，衣袂襟风，十分潇洒。",
		[3] = "GLD你身形飘忽，有如鬼魅，众人眼前一花，再看之时他已经出现在了擂台之上。",
		[4] = "GLD你一个纵身飞起，脚下如凌波踏水，空踏数步，登上了擂台。",
		[5] = "GLD你微微一笑，身形化为一道模糊身影，轻飘飘地落在了擂台之上。",
		[6] = "GLD你单足微一点地，提气纵起，在空中连跨数步，已然落在擂台之上。",
		[7] = "GLD你脚下猛力一登，身体拔起丈高，落在了擂台之上。",
	},
	[2] =
	{
		[1] = "GLD向台下众人抱拳道：",
		[2] = "GLD微一颔首，对众人道：",
		[3] = "GLD微微一笑，冲着台下诸人道：",
	},
	[3] =
	{
		[1] = "GLD吾乃$MWHT$NGLD，江湖人称$C",
		[2] = "GLD吾名为WHT$NGLD，江湖人给面子，人送外号$C",
		[3] = "GLD吾名为WHT$NGLD，乃是$T",
		[4] = "GLD在下WHT$NGLD，外号$T",
		[5] = "GLD在下$CWHT$NGLD，诸位有礼了",
	},
	[4] =
	{
		[1] = "GLD刚教训了一个不知天高地厚的WHT$LGLD。",
	},
}
--请武馆老管家赶走人的文本，打赏换人的文本
local defaultTextWUGuanGuanJiaBattle =
{
	[1] =
	{
		[1] = "GLD你双腿一蹬，腾空而起，轻轻落在擂台边上，衣袂襟风，十分潇洒。",
		[2] = "GLD你腾空落在擂台边上，衣袂襟风，十分潇洒。",
		[3] = "GLD你身形飘忽，有如鬼魅，众人眼前一花，再看之时他已经出现在了擂台之上。",
		[4] = "GLD你一个纵身飞起，脚下如凌波踏水，空踏数步，登上了擂台。",
		[5] = "GLD你微微一笑，身形化为一道模糊身影，轻飘飘地落在了擂台之上。",
		[6] = "GLD你单足微一点地，提气纵起，在空中连跨数步，已然落在擂台之上。",
		[7] = "GLD你脚下猛力一登，身体拔起丈高，落在了擂台之上。",
	},
	[2] =
	{
		[1] = "GLD向台下众人抱拳道：",
		[2] = "GLD微一颔首，对众人道：",
		[3] = "GLD微微一笑，冲着台下诸人道：",
	},
	[3] =
	{
		[1] = "GLD吾乃$MWHT$NGLD，江湖人称$C",
		[2] = "GLD吾名为WHT$NGLD，江湖人给面子，人送外号$C",
		[3] = "GLD吾名为WHT$NGLD，乃是$T",
		[4] = "GLD在下WHT$NGLD，外号$T",
		[5] = "GLD在下$CWHT$NGLD，诸位有礼了",
	},
	[4] =
	{
		[1] = "GLD刚刚WHT$AGLDWHT$BGLD身体抱恙不能比武。。。",
	},
}
--金蝉脱壳的的文本
local defaultTextJinChanTuoQiao =
{
	[1] =
	{
		[1] = "GLD你双腿一蹬，腾空而起，轻轻落在擂台边上，衣袂襟风，十分潇洒。",
		[2] = "GLD你腾空落在擂台边上，衣袂襟风，十分潇洒。",
		[3] = "GLD你身形飘忽，有如鬼魅，众人眼前一花，再看之时他已经出现在了擂台之上。",
		[4] = "GLD你一个纵身飞起，脚下如凌波踏水，空踏数步，登上了擂台。",
		[5] = "GLD你微微一笑，身形化为一道模糊身影，轻飘飘地落在了擂台之上。",
		[6] = "GLD你单足微一点地，提气纵起，在空中连跨数步，已然落在擂台之上。",
		[7] = "GLD你脚下猛力一登，身体拔起丈高，落在了擂台之上。",
	},
	[2] =
	{
		[1] = "GLD向台下众人抱拳道：",
		[2] = "GLD微一颔首，对众人道：",
		[3] = "GLD微微一笑，冲着台下诸人道：",
	},
	[3] =
	{
		[1] = "GLD吾乃$MWHT$NGLD，江湖人称$C",
		[2] = "GLD吾名为WHT$NGLD，江湖人给面子，人送外号$C",
		[3] = "GLD吾名为WHT$NGLD，乃是$T",
		[4] = "GLD在下WHT$NGLD，外号$T",
		[5] = "GLD在下$CWHT$NGLD，诸位有礼了",
	},
	[4] =
	{
		[1] = "GLD刚刚我身体不适，休息了一会，如今,",
	},
}
local defaultBattleText =
{
	[1] =
	{
		[1] = "WHT一名挑战者跳上擂台",

	},
	[2] = {
		[1] =  "$SWHT看起来WHT$ageWHT，WHT$faceWHT。",
	},
	[3] =
	{
		[1] ="WHT$SWHT$fightWHT",

	}
	-- [4] =
	-- {
	-- 	[1] = "WHT吾乃 $NWHT$BWHT，江湖人称$C",
	-- 	[2] = "WHT吾名为 $NWHT，江湖人给面子，人送外号$C",
	-- 	[3] = "WHT吾名为 $NWHT，乃是$T",
	-- 	[4] = "WHT在下 $NWHT，外号$T",
	-- 	[5] = "WHT在下 $CWHT$NWHT，诸位有礼了",
	-- },
}

local _getTiaoZhanText =
{
	[1] =
	{
		[1] = "GLD你双腿一蹬，腾空而起，轻轻落在擂台边上，衣袂襟风，十分潇洒。",
		[2] = "GLD你腾空落在擂台边上，衣袂襟风，十分潇洒。",
		[3] = "GLD你身形飘忽，有如鬼魅，众人眼前一花，再看之时他已经出现在了擂台之上。",
		[4] = "GLD你一个纵身飞起，脚下如凌波踏水，空踏数步，登上了擂台。",
		[5] = "GLD你微微一笑，身形化为一道模糊身影，轻飘飘地落在了擂台之上。",
		[6] = "GLD你单足微一点地，提气纵起，在空中连跨数步，已然落在擂台之上。",
		[7] = "GLD你脚下猛力一登，身体拔起丈高，落在了擂台之上。",
	},
	[2] =
	{
		[1] = "GLD向台下众人抱拳道：",
		[2] = "GLD微一颔首，对众人道：",
		[3] = "GLD微微一笑，冲着台下诸人道：",
	},
	[3] =
	{
		[1] = "GLD吾乃$MWHT$NGLD，江湖人称  $C",
		[2] = "GLD吾名为WHT$NGLD，江湖人给面子，人送外号      $C",
		[3] = "GLD吾名为WHT$NGLD，乃是 $T",
		[4] = "GLD在下WHT$NGLD，外号 $T",
		[5] = "GLD在下$CWHT$NGLD，诸位有礼了",
	},
	[4] =
	{
		[1] = "GLD刚刚一个不小心，我要再战一回",
	},
}

--告辞
local _ByeByeText =
{
	[1] =
	{
		[1] = "GLD今日在下还有其他事，就此告辞。",
		[2] = "GLD今日天色已晚，不便再战，就此告辞。",
		[3] = "GLD在下还有要事，今日就此告辞。",
		[4] = "GLD今日不宜再战，在下就此告辞。",
	}
}

--邀战
local _BattleText =
{
	[1] =
	{
		[1] = "GLD不知哪位朋友愿上台来与我切磋一二？",
		[2] = "GLD还望各位武林同道不吝赐教！",
		[3] = "GLD不知哪位英雄好汉愿指点一二？",
	}
}

--邀战答复
local _BattleReplyText =
{
	[1] =
	{
		[1] = "WHT少侠客气了，我乃$AWHT$BWHT，愿以$KWHT与少侠一战。",
		[2] = "WHT在下$AWHT$BWHT，今日就以$KWHT与少侠切磋一二。",
		[3] = "WHT在下$AWHT$BWHT，愿以$KWHT与少侠切磋一二。",
	}
}

--邀战胜利文本：
local _BattleWinText =
{
	[1] =
	{
		[1] = "GLD你打败了$MWHT$BGLD,一脚把他踢下台去，对台下众人抱拳道：",
	},
	[2] =
	{
		[1] ="GLD吾乃$TWHT$NGLD，江湖人称$C",
	}
}



--挑衅
local _ProvokeText =
{
	[1] =
	{
		[1] = "GLD哪个不怕死的敢来挑战！",
		[2] = "GLD哪个不怕死的敢上台来！",
		[3] = "GLD不知哪个不知死活的要上台来讨打！",
	}
}

--挑衅答复
local _ProvokeReplyText =
{
	[1] =
	{
		[1] = "WHT哼，今日我 $BWHT就以$KWHT来会会你这狂妄之徒！",
		[2] = "WHT休要放肆！就让我$BWHT来收拾你这狂徒！",
		[3] = "WHT哪来的狂徒！不知天高地厚，今日我$BWHT定要你让你尝尝我这$KWHT的厉害！",
	}
}

----挑衅胜利文本：
local _ProvokeWinText =
{
	[1] =
	{
		[1] = "GLD哼，就这点实力也敢来挑战我，真是讨打！",
		[2] = "GLD真是不禁打，我还没出力就倒下了。",
		[3] = "GLD唉，无敌真是寂寞啊。",
	}
}

local cardTab = {
	[1] ="RED暗箭伤人" ,
	[2] = "DWT灵丹妙药",
	[3] ="DWT打赏换人",
	[4] = "DWT巧舌如簧",
	[5] = "RED暗中下毒",
	[6] = "DWT护心铜镜",
	[7] ="DWT九转大还" ,
	[8] = "DWT金蝉脱壳",
	[9] ="RED借刀杀人",
	[10] ="DWT以逸待劳" ,
	[11] ="DWT刀刀入肉",
	[12] ="RED趁火打劫",
	[13] ="DWT步步高升",
	[14] ="RED浑水摸鱼",
	[15] ="DWT打草惊蛇",
	[16] ="DWT瞒天过海",
	[17] ="RED笑里藏刀",
	[18] ="RED顺手牵羊",
	[19] ="DWT乾坤一掷" ,
	[20] ="RED求助师门",
	[21] = "DWT指桑骂槐",
	[22] = "DWT灵机一动" ,
	[23] = "DWT无中生有",
	[24] ="DWT饮鸩止渴",
	[25] ="DWT背水一战",
	[26] ="RED釜底抽薪",
	[27] ="HIG一丝不挂",
	[28] ="RED摇尾乞怜",
	[29] ="DWT神兵利器",
	[30] ="DWT攀亲带故",
	[31] ="DWT打情骂俏",
	[32] = "DWT以彼之矛",
	[33] ="DWT垂死挣扎",
	[34] = "HIG让你三招" ,
	[35] ="DWT贴身肉搏" ,
	[36] ="DWT借尸还魂",
}

-----------------------------------挑战界面输出文本
-- local _tiaoZhanText =
-- {
-- 	[1] = "你战胜了$A$B",

-- }

-------------------获取文本的方法  get加文本名字--------------------------------------
--上台
function BiWu:getDefaultText()
	return defaultText
end
function BiWu:getdefaultTextExistLastBattle()
	return defaultTextExistLastBattle
end
function BiWu:getDefaultBattleText(  )
	local defaultBattleText2 = clone(defaultBattleText)
	return defaultBattleText2
end

function BiWu:_getByeByeText()
	return _ByeByeText
end
function BiWu:_getTiaoZhanText()
	return _getTiaoZhanText
end
function BiWu:_getBattleText()
	return _BattleText
end

function BiWu:_getBattleReplyText()
	return _BattleReplyText
end

function BiWu:_getProvokeText()
	return _ProvokeText
end

function BiWu:_getProvokeReplyText()
	return _ProvokeReplyText
end

function BiWu:getByeByeText()
	return ByeByeText
end

function BiWu:getBattleText()
	return BattleText
end

function BiWu:getProvokeText()
	return ProvokeText
end

function BiWu:getExitLayerText()
	return ExitLayerText
end

function BiWu:getStartLayerDescText(  )
	return startLayerDescText
end
function BiWu:getwatchTimeOverText()
	return watchTimeOverText
end
function BiWu:getwatchNoMoneyText()
	local figure = math.random(1,#watchNoMoneyText)
	return watchNoMoneyText[figure]
end
function BiWu:getwatchTimeIsTwoHour()
	return watchTimeIsTwoHour
end
function BiWu:getwatchStageDesc()
	return watchStageDesc
end
function BiWu:getwuGuanTalkText()
	return wuGuanTalkText
end
function BiWu:getwuguanguanjiaDesc()
	return wuguanguanjiaDesc
end
function BiWu:getmainLayerToStartLayerText()
	return mainLayerToStartLayerText
end
function BiWu:getstartLayerTextToMainLayerText()
	return startLayerTextToMainLayerText
end
function BiWu:getmainLayerToWatchLayerText()
	return mainLayerToWatchLayerText
end
function BiWu:getwatchRewardText()
	local figure = math.random(1,#watchRewardText)
	return watchRewardText[figure]
end
function BiWu:getBattleWinText(  )
	return _BattleWinText
end
function BiWu:getdefaultTextWUGuanGuanJiaBattle()
	return defaultTextWUGuanGuanJiaBattle
end

function BiWu:getdefaultTextJinChanTuoQiao()
	return defaultTextJinChanTuoQiao
end

function BiWu:getCardTab()
	return cardTab
end



----------------切换存档以后进入论剑界面，清空输出框
function BiWu:setChangFIleIsTrue()
	self._changeFileBiWuStartLayer = true
	self._changeFileBiWuWatcherLayer = true
	self._changeFileBiWuMainLayer = true
end
function BiWu:isChangFIleIsTrue(layerName)
	if layerName == "BiWuMainLayer" then
		if self._changeFileBiWuMainLayer and self._changeFileBiWuMainLayer == true then
			return true
		else
			return false
		end
	elseif layerName == "BiWuWatchLayer" then
		if  self._changeFileBiWuWatcherLayer and self._changeFileBiWuWatcherLayer == true then
			return true
		else
			return false
		end
	elseif layerName == "BiWuStartLayer" then
		if self._changeFileBiWuStartLayer and self._changeFileBiWuStartLayer == true then
			return true
		else
			return false
		end
	end

	return false
end
--------------------------------------------------------------------------------------------
	--只需要调用createText(),指定ui界面和文本
-------------------------------------------------------------------------------

------用来保存创建好的Panelitem
local  Panel_itemArry = {}

---置换文本
--m代表门派，n代表名字，j代表技能，w代表武器，z代表评价，c代表称号。T头衔
function BiWu:changeText(text)
	---用来保存已经转换h后的名称称呼的文本
	local resultText = {}

	local printText = text
	if not printText then
		return nil
	end

	local role = User:getRole()
	local sex = role:getAttr("sex")
	local touxian = role:getTouXian()			--xx门派XX代弟子
	local familyName = role:getFamilyName()			--XX门派
	local chenghao = role:getChengHaoColorName()				--【称号】
	local name = role:getName()						--名字
	local currSkillName = role:getCurrSkillName()	--当前武功名字


	local battlefamilyName = "江湖散人"   ---对手门派
	local battleOpponentName = ""    --对手武功名字
	local battleName = ""                    --对手名字
	local fightAllData = self:getfightAllData()
	local player
	local ageDesc = ""
	local faceDesc = ""
	local fightDesc = ""
	local sex = ""
	local lastName = "" --- 上一个对手的名字

	local battleCurrWeaponType   -- 当前装备兵器类型，没有返回拳脚

	if fightAllData and fightAllData.user and fightAllData.user.name then
		player = Helper:tableCover(require("app.models.role.Role"):create(), fightAllData.user)
		ageDesc = player:getAgeDsc()
		faceDesc = player:getFaceDsc()
		-- fightDesc = player:getKongfuDesc()
		fightDesc = "WHT的武功看来"..player:getKongfuDsc().."WHT，出手似乎"..player:getJialiDsc().."WHT。 "
		sex = player.sex
		battlefamilyName = player:getFamilyName()
	end
	if player == nil then
		battleName = ""
		battleOpponentName = ""

		battleCurrWeaponType = ""
	else

		battleName = player.name
		battleOpponentName = player:getCurrSkillName()

		battleCurrWeaponType    =  player:getCurrWeaponType()
	end

	if currSkillName == nil  then
		currSkillName = "基本拳脚"
	end
   
	if battleOpponentName == nil then
		battleOpponentName = "基本拳脚"
	end
	if battlefamilyName == nil then
		battlefamilyName = "江湖散人"
	end
	-- local role = User:getRole()

	-- 特殊情况下 npc玩家未装备武功，但是装备了兵器
	if battleCurrWeaponType ~= "拳脚" and battleOpponentName == "基本拳脚"  then
		if battleCurrWeaponType == "暗器" then
			battleOpponentName = "基本"..battleCurrWeaponType
		else
			battleOpponentName = "基本"..battleCurrWeaponType.."法"
		end
	end

	if sex == "男" then
		sex = "WHT他"
	else
		sex = "WHT她"
	end


------上一个对手的门派名字
	if fightAllData.allBattleName and fightAllData.allBattleName[1] then
		lastName = fightAllData.allBattleName[1]
	end


	--替换文本
	for i=1,#printText do
		for j=1,#printText[i] do
			printText[i][j] = string.gsub(printText[i][j],"$M",tostring(familyName) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$T",tostring(touxian) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$N",tostring(name) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$C",tostring(chenghao) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$J",tostring(currSkillName) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$B",tostring(battleName) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$K",tostring(battleOpponentName) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$age",tostring(ageDesc) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$face",tostring(faceDesc) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$fight",tostring(fightDesc) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$S",tostring(sex) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$A",tostring(battlefamilyName) .. "HIW")
			printText[i][j] = string.gsub(printText[i][j],"$L",tostring(lastName) .. "HIW")
		end
		resultText[i] = printText[i]

	end
	return resultText
end

--创建文本ExtRichTextScroll 存入Panel_itemArry中返回
function BiWu:createTextFromArray(ui, Panel_item, text)
	Panel_itemArry = {}

	-------防止描述一样，string,gsub会改变原来的字符串
	local textClone = clone(text)
	local resultText = self:changeText(textClone)

	for j,index in ipairs(resultText) do
		local Text = ExtRichTextScroll:create()
		ui:addChild(Text)

	    Text:setSize(cc.size(900,90))
    	Text:setDirection(kCCScrollViewDirectionVertical)
    	Text:getRichText():setVerticalSpace(10)
	    Text:setAnchorPoint(0.5,0.5)
		Text:setTouchEnabled(false)

	    --随机提取文本
		local textColor = cc.c3b(246,144,80)--cc.c3b(208, 208, 208)
		local randNum = math.random(1, #resultText[j])
	    Text:pushBackText(resultText[j][randNum], textColor, 255, Resource:getFontPath("default"), 48)
	    --设置透明度为0
	    Text:setSelfAndChildrenCascadeOpacityEnabled(true)
		Text:setOpacity(0)

		Panel_itemArry[#Panel_itemArry + 1] = Text
		local richText = Text:getRichText()
		richText:formatText()
		local height = richText:getNewContentSizeHeight()
		Text:setSize(cc.size(900, height))
	end

	return Panel_itemArry 
end

---执行动画。变大变小的显现出来，在往上移动的
-- 参数  容器  容器在容器数组里的索引   距可视区域上边的距离
function BiWu:runActionText(Panel_item, index, distance, height,mark)

	if not Panel_item then
		return
	end
	---------distance 默认2
	if not distance then
		distance = 3	
	end
	if mark == false then
		distance = distance * 100 + height + 80
	else
		distance = distance * 100 + height + 200
	end

	local Size = Panel_item:getContentSize()

	local viewsize = cc.Director:getInstance():getWinSize()

	-----设置屏幕中间
	Panel_item:setVisible(true)
	Panel_item:setOpacity(255)
	Panel_item:setScale(1.25)
	Panel_item:setPosition(cc.p(Size.width/2 + 100, viewsize.height - distance - Size.height/2 ))
	Panel_item:runAction(
			 	cc.Sequence:create(
		 			cc.ScaleTo:create(0.1 , 1.0 , 1.0 )
			 	)
			)

end
---------------------------------------------------------------------------------------------------------------------------
------------------------------比武的网络请求接口---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------
--观战 POST watch_fight  将玩家加入到候选匹配队列（什么时候从队列移除，被挑战过，还是被打败。）
---点击观战告诉服务器进入观看状态
function BiWu:sendBiWuWatch(func,failed_func)
    func = Helper:getDef(func, EMPTY_FUNC)
   	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)

   	HttpManagerEx:sendBiWuWatch(
   		function(status, errcode, errmsg, data)
   			if PRINT_MODE == 1 then
   				print("`````````````````````````````````````")		
   				Helper:print_lua_table(data)
   				print("status = "..status.."   errmsg ="..errmsg.."     errcode ="..errcode)
   			end

   		    if status == 200 then
   		    	if errcode == 0 then
	    	    	---保存服务器获取的观看数据，一个是开始观看时间，一个是最大收益的时间
	    	    	fightAllData.current_time = data.current_time
	    	    	fightAllData.expired_time = data.expired_time

	    	    	---每次观战重新计算观战收益
	    	    	if fightAllData then
	    	    		fightAllData.watchTotalPot = 0
	    	    		fightAllData.watchTotalMoney = 0
	    	    	end

	    	    	fightAllData.watchFid = data.fid
	    	    	--- 保存在存档里

	    	    	-- 保存数据到本地
	    	    	self:savefightAllData(fightAllData)

	    	    	func()
	    	    elseif errcode == 1 then
	    	    	PopText(tostring(errmsg))
	    	    	failed_func()
    	    	---------正在观战
	    	    elseif errcode == 2 then
		    		local role = User:getRole()
		    		role:setAttr("currWatchFid", data.fid)
	    			role:setFlag("观战时间", GetTime())
		    		role:stopGuanZhan(function()
		    		end)
		    		-------应该清空本地管战记录，并且告诉服务器，这次观战失败，重新观战
		    		--已经记录在角色 currWatchFid
		    		if PRINT_MODE == 1  then
				        PopText(tostring(errmsg))
				    end
    	    	---每天只能观战八小时，提示，不能进入观战
	    	    elseif errcode == 3 then
	    	    	PopText(errmsg)
					failed_func()

				-- 超过23点 结算每日  不能上台提示
				elseif errcode == 6 then
		        	if errmsg then
		        		PopText(tostring(errmsg))
					end
					
	    	    else
	    	    	if errmsg then
	    	    		PopText(tostring(errmsg))
	    	    	else
	    	    		PopText("访问网络出错")
	    	    	end
	    	    end
	    	else
	    		PopText("网络请求出错,请换个网络环境再试!")
    	    end
   		end,IS_SHOW_WAITING)
end

-- 结束观战
function BiWu:stopWatch(fid, unWtatchTime, func,failed_func)
	if fid == nil or unWtatchTime == nil then
		return
	end
	local params =
	{
		fid = fid, 		-- 观战编号
		unwatch_time = unWtatchTime	-- 最近的观战时间
	}
	self:sendBiWuUnWatch(params, func,failed_func)
end

--取消观战 POST unwatch_fight
function BiWu:sendBiWuUnWatch(params,func,failed_func)
    func = Helper:getDef(func, EMPTY_FUNC)
	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)

	HttpManagerEx:sendBiWuUnWatch(params,
		function(status, errcode, errmsg, data)
		    if status == 200 then
		    	if errcode == 0 then
		    		---------------在这里，保存结束观看的时间
		    		fightAllData.stopWatchTime = GetTime()
		    		fightAllData.watchFid = nil
		    		self:savefightAllData(fightAllData)

		    		func()

		    	elseif errcode == 1 then
	    			---这次观战不存在
	    			failed_func()
	    			PopText(tostring(errmsg))
	    		else
	    			PopText(tostring(errmsg))
		    	end
		    else
	    		PopText("网络请求出错,请换个网络环境再试!")
		    end
		end,IS_SHOW_WAITING)
end

-------获取对战结果列表 GET get_fight_msg---------------------------------------------
function BiWu:getBiWuFighMessage(func,failed_func)
	func = Helper:getDef(func, EMPTY_FUNC)
	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)

    HttpManagerEx:getBiWuFighMessage(
	    function(status, errcode, errmsg, data)
	    	if PRINT_MODE == 1  then
	    		print("````````````````````````")
	    		print("errcoe = "..tostring(errcode).."    status = "..tostring(status).."  errmsg ="..tostring(errmsg))
	    		Helper:print_lua_table(data)
	    	end
	        if status == 200 then
    			if errcode == 0 then
    				if data.watch_msg then
    					--保存观看人数和打印信息
    					fightAllData.fightMsgList = data.watch_msg
    					fightAllData.watch_cnt = data.watch_cnt
    					fightAllData.week_renqi = data.week_renqi
						fightAllData.history_renqi = data.history_renqi
						-- fightAllData.day_renqi = data.today_max_point	
										
						self:savefightAllData(fightAllData)
						-- PopText("调用get_fight_msg，成功返回"..fightAllData.day_renqi)
    				end
    				func()
    			else
    				PopText(tostring(errmsg))
    				failed_func()
    			end
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
	    end,IS_SHOW_WAITING)
end

---------上台挑战 POST join_fight
function BiWu:sendBiWuJoinFight(func,failed_func)
   func = Helper:getDef(func, EMPTY_FUNC)
   failed_func = Helper:getDef(failed_func, EMPTY_FUNC)

   HttpManagerEx:sendBiWuJoinFight(
	   	function(status, errcode, errmsg, data)
	        if status == 200 then
	        	---保存下载下来的fid 和 times
	        	if errcode == 0  then
		        		--保存exitLayer的气数量
	        		fightAllData.renqi = data.renqi
	        		fightAllData.fid = data.fid
	        		---增加一个字段，回合数
	        		fightAllData.current_cnt = data.current_cnt
					User:getRole().fightFid = data.fid
					--加一个字段，每日最高人气
					fightAllData.day_renqi = data.today_max_point
					
					-- 本场人气改为直接获取服务器的值
					if data and data.stage_renqi then
						fightAllData.add_renqi = data.stage_renqi
					end

	        		---将fid 和 lefttimes 保存到本地数据
	        		self:savefightAllData(fightAllData)
					-- PopText("调用join_fight，成功返回"..fightAllData.day_renqi)
			    	func()

	        	elseif errcode == 201 then
	        		PopYuanBaoBuyItemLayer(data.itemId, function(eventType)
	        			if eventType == "success" then
	        				self:sendBiWuJoinFight(func,failed_func)
	        			elseif eventType == "failed" then

	        			end
	        		end)
	        	-----上台失败
	        	elseif errcode == 1  then
					PopText(tostring(errmsg))

				-- 超过23点 结算每日  不能上台提示
				elseif errcode == 6 then
		        	if errmsg then
		        		PopText(tostring(errmsg))
					end
					
				else
					PopText(tostring(Helper:getDef(errmsg, "网络请求异常")))
	        	end
	        	return true
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
	   	end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)--,HTTP_MANAGER_RETRY_TYPE_RETRY
end
--------------开始匹配对手 POST fight/{ } 1挑衅，2邀战，3告辞 / 4挑战
function BiWu:sendBiWuFight(fight_type,params,func,failed_func,failedOverTime_func)
	func = Helper:getDef(func, EMPTY_FUNC)
	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)
	failedOverTime_func = Helper:getDef(failedOverTime_func, EMPTY_FUNC)

	HttpManagerEx:sendBiWuFight(fight_type,params,
		function(status, errcode, errmsg, data)
		    if status == 200 then
		    	---保存下载下来的fid 和 times
		    	if errcode == 0 then
					--保存exitLayer的气数量

	        		local role  = User:getRole()
	        		role.fightId = data.id
	        		fightAllData.id = data.id

	        		--继承role的属性和方法
					fightAllData.fightType = fight_type
					
					-- jian110 青锋剑
					-- dao108  雁翎刀
					-- gun109  盘龙棍
					-- bian111 月影鞭
					-- 转换  将data.user 中的老神兵转换成 普通兵器，功法不变
					if data.user and  data.user.equips and data.user.equips.weapon and data.user.equips.weapon.itemId 
					and data.user.equips.weapon.itemId == "神兵" then
						local  weaponType  = data.user.shenBingweapon.type
						print("此npc玩家装备了神兵，类型是",weaponType)
						if weaponType == "剑" then
							data.user.equips.weapon.itemId = "jian110"
							data.user.items[1].itemId = "jian110"
						elseif weaponType == "刀" then
							data.user.equips.weapon.itemId = "dao108"
							data.user.items[1].itemId = "dao108"
						elseif weaponType == "棍" then
							data.user.equips.weapon.itemId = "gun109"
							data.user.items[1].itemId = "gun109"
						elseif weaponType == "鞭" then
							data.user.equips.weapon.itemId = "bian111"
							data.user.items[1].itemId = "bian111"
						end
						data.user.shenBingweapon = {}
					end

					fightAllData.user = data.user

				
	        		------ 获取人气值
					fightAllData.win_points = data.win_points 
					fightAllData.day_renqi = data.today_max_point
					
	        		----记录第几回合战斗
	        		if data.current_cnt then
	        			fightAllData.current_cnt = data.current_cnt
	        		else
		             ----挑战的时候不算回合数，这时候，记录上一次的回合数
		      			--用原来fightAllData.current_cnt 保存的数据
					end

					-- 告辞时结算本周人气
					if fight_type  == 3 then
						fightAllData.renqi = data.week_renqi 
					end
 
	        		self:savefightAllData(fightAllData)

			    	func()
		    	elseif errcode == 201 then
		    		PopYuanBaoBuyItemLayer(data.itemId, function(eventType)
		    			if eventType == "success" then
		    				self:sendBiWuFight(fight_type,params,func,failed_func,failedOverTime_func)
		    			elseif eventType == "failed" then

		    			end
		    		end)
		    	---重新代用获取借口，没有获取到
		    	elseif errcode == 1 then
		    		self:sendBiWuFight(fight_type,params,func,failed_func,failedOverTime_func)
		    	----上次未完成的战斗
		    	elseif errcode == 2 then
		    		local params = {}
		    		if data.id and data.fid then
			    		params.id = data.id
			    		params.fid = data.fid
		    			-----如果失败了，就删除记录，重新上台
			    		-- @author LiJie 在向服务器清空这次不存在的战斗后，重新调用这个接口，失败的话，重新上台
		    			self:sendBiWuFightResult(params,function ()
		    				self:sendBiWuFight(fight_type,params,func,failed_func,failedOverTime_func)
		    			end,function ()
		    			--汇报失败，重新上台
		    				failedOverTime_func()
		    			end)
		    		else
		    			---数据不存在，重新上台
		    			failedOverTime_func()
			    	end
		    	----战斗次数已经达到上限了
		    	elseif errcode == 3 then
		    		PopText(tostring(errmsg))
		    		------战斗次数达到，挑战时间还是10分钟不变
		    		-- if failed_func then
		    		-- 	failed_func()
		    		-- end
		    	----该战斗不存在
		    	elseif errcode == 4 then
		    		PopText(tostring(errmsg))
		    		failed_func()
		    	----挑战超时
		    	elseif errcode == 5 then
		    		PopText(tostring(errmsg))
					failed_func()
				-- 超过23点 结算每日 
				elseif errcode == 6 then
		        	if errmsg then
		        		PopText(tostring(errmsg))
					end
					-- failed_func()
					failedOverTime_func()
		    	else
		    		PopText("网络异常")
		    		failed_func()
		    	end
		    	return true 
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
		    end
		end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)--,HTTP_MANAGER_RETRY_TYPE_RETRY
end
-----汇报战斗结果 POST report_fight_result    "win|lose|cancel 取消| run 逃跑"
function BiWu:sendBiWuFightResult(params,func,failed_func,failedOverTime_func)
	func = Helper:getDef(func, EMPTY_FUNC)
	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)
	failedOverTime_func = Helper:getDef(failedOverTime_func, EMPTY_FUNC)
	HttpManagerEx:sendBiWuFightResult(params,
	function(status, errcode, errmsg, data)
	    if status == 200 then
        	if errcode == 0 then ------已结重试成功了，不用再次重试  errcode == 3
	        	if data and data.current_time and data.expired_time then
	        		fightAllData.fightCurrent_time = data.current_time
	        		fightAllData.fightExpired_time = data.expired_time
	        		if data.lose_points then
	        			if fightAllData.oneFight.lose_points == nil then
	        				fightAllData.oneFight.lose_points = 0
	        			end
	        			fightAllData.oneFight.lose_points = data.lose_points
	        		end
	        		--这次上台赢了多少场
	           	end
	           	---------战斗回合数
	           	if data and data.current_cnt then
	           		fightAllData.current_cnt = data.current_cnt
	           	end
	           	if data and data.renqi then
	           		fightAllData.renqi = data.renqi
				end
				-- -- 异常退出时 将本场人气清零
				-- if fightAllData.add_renqi and fightAllData.add_renqi > 0 then
				-- 	fightAllData.add_renqi = 0
				-- end
                -- PopText("调用report_fight_result成功返回"..fightAllData.day_renqi)
	           	if data and data.win_points and data.win_times then
	        		fightAllData.win_times=data.win_times
	        		if fightAllData.oneFight.win_points == nil then
	        			fightAllData.oneFight.win_points = 30
	        		end
	        		fightAllData.oneFight.win_points = data.win_points
	    			self:countRoleFightResultMoneyReward(data.win_points)
				end
				
				-- 本场人气改为直接获取服务器的值
				if data and data.stage_renqi then
					fightAllData.add_renqi = data.stage_renqi
				end

				-- 今日最高人气改为直接获取服务器的值
				if data and data.today_max_point then
					fightAllData.day_renqi = data.today_max_point	
				end
            
	        	-----汇报结果结束，应该把战斗结果的Id 致为空
	        	fightAllData.id = nil
	        	func()
        	--本地战斗记录与服务器战斗记录不匹配，清空本地记录..或者对手找不到了
        	elseif errcode == 1 or errcode == 2 then
        		fightAllData.fid = nil
        		fightAllData.id = nil
        		fightAllData.result = nil

        		failed_func()
        		PopText(tostring(errmsg))
        	else
        		failed_func()
        		PopText(tostring(errmsg))
        	end
       		self:savefightAllData(fightAllData)
        	return true 
		else
    		PopText("网络请求出错,请换个网络环境再试!")
        end
	end,IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
end
-----汇报使用的卡牌ID POST fid id card_id
function BiWu:sendBiWuFightCardId(params,func,failed_func)
	func = Helper:getDef(func, EMPTY_FUNC)
	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)
	HttpManagerEx:sendBiWuFightCardId(params,
	function(status, errcode, errmsg, data)
	    if status == 200 then
	        if errcode == 0 then
				func()
	        else
	        	failed_func()
	        	PopText(tostring(errmsg))
	        end
		else
    		PopText("网络请求出错,请换个网络环境再试!")
	    end
	end,IS_SHOW_WAITING)
end
---fight_times   ---获取今天上台的次数
function BiWu:getBiWuFightTimes(callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getBiWuFightTimes(
	    function(status, errcode, errmsg, data)
	        if status == 200 then
	        	if errcode == 0 then
				--	保存剩余时间
					fightAllData.left_times = data.fight_times

					-- 返回数据新加入回合数，防止锦囊等下台丢失当前回合数
					if data.current_cnt and data.current_cnt > 0 then
						fightAllData.current_cnt = data.current_cnt  --新加入回合数
					end
					
	        		self:savefightAllData(fightAllData)
		        	callback()
		        else
	            	PopText(tostring(errmsg))
		        end
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
    end,IS_SHOW_WAITING)
end
--get_fight_yuanbao   ---获取上台的所需元宝
function BiWu:getBiWuFightYuanBao(type,callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getBiWuFightYuanBao(type,
	    function(status, errcode, errmsg, data)
	        if status == 200 then
	        	if errcode == 0 then
		        	callback(data.yuanbao)
		        else
	            	PopText(tostring(errmsg))
		        end
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
    end,IS_SHOW_WAITING)
end
---get_chanllenge_msg   观战中的战斗信息
function BiWu:getChanllengeMsg(callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getChanllengeMsg(
	    function(status, errcode, errmsg, data)
	        if status == 200 then
	        	----可以观战
	        	if errcode == 0 then
	        		fightAllData.watchFightResultMsg = data
	        		self:savefightAllData(fightAllData)
		        	callback()
		        else
	            	PopText(tostring(errmsg))
		        end
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
    end,IS_SHOW_WAITING)
end

---是否可以观战 can_watch_fight     errcode=0 可以观战    errcode=1 不可以观战
function BiWu:getCanGuanZhan(callback,failed_func)
	callback = Helper:getDef(callback, EMPTY_FUNC)
	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)
    HttpManagerEx:getCanGuanZhan(
	    function(status, errcode, errmsg, data)
	        if status == 200 then
	        	----可以观战
	        	if errcode == 0 then
		        	callback()
		        elseif errcode == 1 then
		        	if errmsg then
		        		PopText(tostring(errmsg))
		        	end
		        --服务器正在观战，本地没有更新的情况
		        elseif errcode == 2  then
		        	failed_func()
		        	if errmsg then
		            	PopText(tostring(errmsg))
		            else
		            	PopText("正在观战中")
					end

				-- -- 超过23点 无法观战 弹出提示
				-- elseif errcode == 6 then
		        -- 	if errmsg then
		        -- 		PopText(tostring(errmsg))
		        -- 	end
				
		        else
	            	PopText("请求失败,请联系客服")
		        end
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
    end,IS_SHOW_WAITING)
end
----------------------三个排行榜的数据---
-- 初始化self._rankings,得到数据
function BiWu:initRankings(type,func,failed_func)
	self._BiWuRankingList = {}
-----获取人气榜 GET get_fight_board/{type} 1历史人气 2本周人气 3挑战记录
	func = Helper:getDef(func, EMPTY_FUNC)
	failed_func = Helper:getDef(failed_func, EMPTY_FUNC)

    HttpManagerEx:getBiWuRankingList(type,
	    function(status, errcode, errmsg, data)
	        if status == 200 then
				if errcode == 0 then
            
					-- 如果人气榜的 人气 和 本地数据不一样  以人气榜为主
					if type == 2 then
						local renqiStr = tonumber(string.sub(data.body.mine.dsc,4,-1))
						if fightAllData.renqi ~=  renqiStr then

							fightAllData.renqi = renqiStr
							self:savefightAllData(fightAllData)

						end
					end
					
					for k,listData in pairs(data) do
		
						table.insert(self._BiWuRankingList, listData)
						
					end
					func(true,self._BiWuRankingList)
    			else
    				if errmsg then
    					PopText(tostring(errmsg))
    				end
					failed_func()
    			end
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
	    end,IS_SHOW_WAITING)
end

-- 告诉服务器已经下台，结算
function BiWu:getBiWuFightEnd(callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getBiWuFightEnd(
	    function(status, errcode, errmsg, data)
	        if status == 200 then
	        	if errcode == 0 then
				--	保存每日最大人气
	                fightAllData.day_renqi = data.today_max_point	
					self:savefightAllData(fightAllData)
					PopText("调用get_out_fight_stage，成功返回"..fightAllData.day_renqi)
		        	callback()
		        else
	            	PopText(tostring(errmsg))
		        end
    		else
	    		PopText("网络请求出错,请换个网络环境再试!")
	        end
    end,IS_SHOW_WAITING)
end

----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----战斗需要统计的 参数  出手次数、是否使用技能回血
function BiWu:countFightDataMap(playerName,key,value)
	if fightDataMap[playerName] == nil then
		fightDataMap[playerName] = {}
	end
	if fightDataMap[playerName][key] ~= nil and type(fightDataMap[playerName][key]) == "number" and type(value) == "number" then
		fightDataMap[playerName][key] = fightDataMap[playerName][key] + value
	else
		fightDataMap[playerName][key] = value
	end
end

--获取统计的数据
function BiWu:getFightDataMap(playerName,key)
	if playerName == nil or key == nil then
		return fightDataMap
	elseif playerName and key then
		if fightDataMap[playerName] == nil then
			fightDataMap[playerName] = {}
		end
		return fightDataMap[playerName][key]
	end

	return nil
end
--初始化统计数据，在战斗之前统计
function BiWu:initFightData()
	fightDataMap  = {}
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
}
----克隆一个角色保存到fightllData
function BiWu:cloneRoleSaveToFightAllData(role)
	local list = {}
	local fightAllData = self:getfightAllData()
	for k,v in pairs(role) do
		if trimMap[k] == true then-- if k == "kongfuDsc" or k == "maps" or k == "qiDsc" or k == "looksDsc" or k == "ageDsc" or k == "chengHaoDesc" or k == "attackSkill" or k == "autoSkills" or k == "fightQiDesc" or k == "chengHuDesc" then
			-- 排除一些描述性属性
		else
			list[k] = v
		end
	end
	if not MapIsEmpty(role._shenbingCache) then
        for k,v in pairs(role._shenbingCache) do
            setmetatable(list._shenbingCache[k], getmetatable(v))
        end
    end
	
	--论剑中去掉 
	list["meridian"] = nil
	list["_fightRoleJingMai"] = nil
	--@desc 论剑角色的属性可能存在该字段，需要清除
	list["meridianImprinting"] = nil
	list["m_meridianImprintings"] = nil
	list["_buffManager"] = nil

	fightAllData.role = list

	self:savefightAllData(fightAllData)
end

-----将fightRole 的属性设置动ROLE里去
function BiWu:setFightResultAttrToRole(fightRole,Role)
	if fightRole and Role then
		local qi = fightRole:getAttr("qi")
		local neili = fightRole:getAttr("neili")
		local qiPercent = fightRole:getAttr("qiPercent")

-------影响玩家属性，谨慎  值设置  气血  气血百分比  内力
		Role:setAttr("qi",qi)
		Role:setAttr("qiPercent",qiPercent)
		Role:setAttr("neili",neili)
	end
end

----清空一下战斗类型
function BiWu:clearFightType()
	local fightAllData = self:getfightAllData()
	fightAllData.fightType = nil
	self:savefightAllData(fightAllData)
end
----清空保存到fightAllData.role克隆的玩家数据
function BiWu:clearFightAllDataRoleData()
	local fightAllData = self:getfightAllData()
	fightAllData.role = {}
	self:savefightAllData(fightAllData)
end
-------战斗完玩家得到的碎银奖励
function BiWu:countRoleFightResultMoneyReward(moneyWin)

	local role = User:getRole()
	local figure = math.random(1,9)
	-- if moneyLose then
	-- 	role:setAttr("money",tonumber(role:getAttr("money")) + tonumber(moneyLose)*3 + figure)
	-- end
	
	-- 重陽節活動
	local rewardBuff = 1
	if role:getFlag("论剑战斗奖励加成") ~= 0 then
		rewardBuff = Helper:getRange(Helper:getDef(role:getFlag("论剑战斗奖励加成"), 0), 1, 6)
	end

	if moneyWin then
		role:addAttr("money", (tonumber(moneyWin)*3 + figure)*rewardBuff)
		-- role:setAttr("money", (tonumber(role:getAttr("money")) + (tonumber(moneyWin)*3 + figure  )*rewardBuff) ) 
		PopText("碎银奖励:"..tostring((tonumber(moneyWin)*3 + figure)*rewardBuff))
	end
	role:setFlag("论剑战斗奖励加成", 0)

	----计算赢了的碎银奖励
	local fightAllData = self:getfightAllData()
	if fightAllData.oneFight.allMoney == nil then
		fightAllData.oneFight.allMoney = 0
	end
	-- print("11111111fightAllData.oneFight.allMone  allMoney = "..fightAllData.oneFight.allMoney.."  win_point = "..moneyWin)
	fightAllData.oneFight.allMoney = fightAllData.oneFight.allMoney + tonumber(moneyWin)*3 + figure
	self:savefightAllData()
end


---------战斗中如果一次上台十次全胜的情况，奖励1800
function BiWu:isFightTenWinCountRoleReward()
	---如果诗词全胜
	local fightAllData = self:getfightAllData()
	if fightAllData.win_times == 10 then
		local role = User:getRole()
		role:addAttr("money",1800 )
		fightAllData.oneFight.isGetWinTimesReward = true
		self:savefightAllData()

	end
end


function BiWu:clearOneFightData()
	local fightAllData = self:getfightAllData()
	fightAllData.oneFight = {}
end
----一个礼拜删除一次本周对战数据
function BiWu:deleteWeekFightData()
	-----一个礼拜删除一次本周对战记录
	local currTime = GetTime()
	local fightAllData = self:getfightAllData()
	if fightAllData == nil then
		return
	end
	local deleteWeekFightDataTime = fightAllData._deleteWeekFightDataTime

	if deleteWeekFightDataTime == nil then
		deleteWeekFightDataTime = GetTime()
	end

	if tostring(Helper:date("%A", GetTime())) ~= "Wednesday" then
		fightAllData._isDeleteWeekFightData = false
		self:savefightAllData(fightAllData)
	end
	if (tostring(Helper:date("%A", GetTime())) == "Wednesday" and fightAllData._isDeleteWeekFightData == false) or Helper:diffWithDate(currTime,deleteWeekFightDataTime) > 7 then
		fightWeekAllData.weekUserData.list = {}
		fightAllData._isDeleteWeekFightData = true
		fightAllData._deleteWeekFightDataTime = GetTime()

		-------周三清空人气值，和服务器同步,
		self:clearFightRenQiInWednesday()

		self:savefightAllData(fightAllData)
		self:savefightWeekAllData(fightWeekAllData)
	end
	-- PopText("Helper:diffWithDate(deleteWeekFightDataTime,currTime) = "..Helper:diffWithDate(deleteWeekFightDataTime,currTime))
end

--- 处理异常的战斗结果
function BiWu:resolveUnnormalFightResult()
	local fightAllData = self:getfightAllData()

	------如果手中的卡牌是  金蝉脱壳  ，则，不需要想服务器汇报结果
	if fightAllData.cardId and (fightAllData.cardId == 8 or fightAllData.cardName == "金蝉脱壳") then
		return
	end

	local role = User:getRole()
	local  params = {}
	---告辞取消的，不想服务器报告
	if fightAllData and fightAllData.result == "cancel"  then
		if fightAllData.id == 0 or fightAllData.id == nil then
			return
		else
			params.id = fightAllData.id
			params.fid = fightAllData.fid
		end
		if fightAllData.cardId then
			params.card_id = fightAllData.cardId
		else
			params.card_id = 0
		end
		params.result = fightAllData.result
		-- Helper:print_lua_table(params)

		self:sendBiWuFightResult(params)
	elseif fightAllData and  fightAllData.result == "run" then
		if fightAllData.id == 0 or fightAllData.id == nil then
			params.id = role.fightId
			params.fid = role.fightFid
		else
			params.id = fightAllData.id
			params.fid = fightAllData.fid
		end
		if fightAllData.cardId then
			params.card_id = fightAllData.cardId
		else
			params.card_id = 0
		end
		params.result = fightAllData.result
     
		self:sendBiWuFightResult(params)
	else

	end

end
---给角色加满状态
function BiWu:setRoleFullStatus(role)
	local qi = role:getAttr("qi")
	local qiMax = role:getFinalAttr("qiMax")
	local neili = role:getAttr("neili")
	local neiliMax = role:getFinalAttr("neiliMax")
	local currQiMax = role:getCurrQiMax()

	if tonumber(currQiMax) < tonumber(qiMax) then
		role:setAttr("qiPercent",1)
		role:setAttr("qi",qiMax)
	end
	if tonumber(neili) < tonumber(neiliMax) then
		role:setAttr("neili",neiliMax - 1)
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------------------


-------------------五分钟上传一次存档
function BiWu:uploadRecordFiveMinuteOnce()
	--从文件获取状态，如果是canel和run 状态，告诉服务器，处理上次没处理的问题
	local fightAllData = self:getfightAllData()

	local currTime = GetTime()
	--五分钟上传存档一次
	if (fightAllData and fightAllData.uploadRecord and currTime - fightAllData.uploadRecord >=300) or
		(fightAllData and fightAllData.uploadRecord ==nil) then

		HttpManagerEx:uploadUserData("shangchuan", function(status, errcode, errmsg, data, isEncrypted)

			if status == 200 and errcode == 0 then
				local fightAllData = BiWu:getfightAllData()
				fightAllData.uploadRecord = currTime -- 更新上传存单的时间时间
				self:savefightAllData()
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
	end
end
--------------------------
--战斗气血显示
function BiWu:countQiXueNeiLiPersent(player)
	local BaseItem = require("app.models.item.BaseItem")

	local QiPercent, CurrQiPercent, NlPercent
	local role
	local fightAllData = self:getfightAllData()
	if player == nil then
		 -- role= User:getRole()
		 --人物buff刷新调整后 论剑人物创建数据调整(原论剑角色无buff刷新)
		if MapIsEmpty(fightAllData.role) == false then
			player = User:getRole()
			if MapIsEmpty(player._shenbingCache) == false and MapIsEmpty(fightAllData.role._shenbingCache) == false then
				local initShenBingList = {}

				for k,v in pairs(fightAllData.role._shenbingCache) do
					initShenBingList[k] = false
				end 

				for k,v in pairs(player._shenbingCache) do
					if not fightAllData.role._shenbingCache[k] then
						fightAllData.role._shenbingCache[k] = v
					end
					
					fightAllData.role._shenbingCache[k] = inherit(clone(fightAllData.role._shenbingCache[k]), BaseItem)

					initShenBingList[k] = true
				end

				for k,v in pairs(initShenBingList) do
					if v == false then
						fightAllData.role._shenbingCache[k] = nil
					end
				end
			else
				fightAllData.role._shenbingCache = nil
			end
		end

		role = Role:create(fightAllData.role)

	else
		role = player
	end

	QiPercent = math.floor(role:getNumAttr("qi")/role:getNumAttr("qiMax")*100)
	CurrQiPercent = math.floor(Helper:getDef(role:getAttr("qiPercent"), 1)*100)
	NlPercent = math.floor(role:getNumAttr("neili")/role:getNumAttr("neiliMax")*100)

	return QiPercent, CurrQiPercent, NlPercent
end

----------------------------------------------------




----------------------------------------------------------------
--消耗元宝
---消耗元宝的流程，如果扣除了，会不会返回给玩家
function BiWu:payYuanBao(func)
	PopYuanBaoBuyItemLayer("kuaisu_jieshutiaozhan", function(eventType)
		if eventType == "success" then
			if func then
				func()
			end
		end
	end)

end


----------------------人气奖励相关接口
----获取自己的奖励列表
function BiWu:getFightRewardList(callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getFightRewardList(
    function(status, errcode, errmsg, data)
        if status == 200 then
	    	if errcode == 0 then
        		fightAllData.thisWeekRewardData = data
        		callback(data)
        		self:savefightAllData(fightAllData)
	        --没有比武或者没有达到条件。就没有记录，直接弹出提示
	        elseif errcode == 1 then
	        	----已经领取的情
	        	if errmsg then
	        		PopText(tostring(errmsg))
	        	else
					PopText("已经领取,无需再次领取")
	        	end
	        else
	        	if errmsg then
	        		PopText(tostring(errmsg))
	        	else
					PopText("网络请求出错,请联系客服!")
	        	end
	        end
		else
    		PopText("网络请求出错,请换个网络环境再试!")
	    end
    end,IS_SHOW_WAITING)
end

------领取自己的奖励
function BiWu:getFightSelfReward(callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)
	----这里需不需要重新定义一个类型
	local item = {}
	if fightAllData.thisWeekRewardData then
		item = fightAllData.thisWeekRewardData
	end
-- 记录（设置）交易凭证item ,count  , transType 1 元宝类 2 月卡类 3 福缘丹 4 论剑奖励
	local transId = TransCheck:setTrans(item, 1, 4)
	if transId == nil or (type(transId) == "number" and transId <= 0) then
		return
	end
	HttpManagerEx:getFightSelfReward({trans_id = transId},
	function(status, errcode, errmsg, data)
	    if status == 200 then
	        if errcode == 0 then
				if data.reward_list and data.renqi and data.danyao then
	            	callback(data.reward_list,data.renqi,data.danyao)
	            end
				TransCheck:updateTrans(transId, RESPONSE_STATUS_SUCCESS)
	        elseif errcode == 1 then
	        	PopText(tostring(errmsg))
	        else
	        	PopText(tostring(errmsg))
	        	TransCheck:updateTrans(transId, RESPONSE_STATUS_FAILED)
	        end
		else
    		PopText("网络请求出错,请换个网络环境再试!")
	    end
	end)
end


---获取奖励预览列表 get_fight_reward_notice 

function BiWu:getFightWeekNotice(callback)
	callback = Helper:getDef(callback, EMPTY_FUNC)
    HttpManagerEx:getFightWeekNotice(
    function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
    			if data.notice  then
                	callback(data.notice)
                else
                	PopText("网络错误")
                end
            else
            	PopText(tostring(errmsg))
            end
		else
    		PopText("网络请求出错,请换个网络环境再试!")
        end
    end)
end

----------------------------------------------------------------------------
--周三清空数据后，存在人气值显示错误，这里在周三情况数据后，清除显示数据
function BiWu:clearFightRenQiInWednesday()
	---本周人气值  历史人气值   本周人气和人气值是一个值 ，用最新的那一个
	fightAllData.history_renqi = 0
	fightAllData.week_renqi = 0
	fightAllData.renqi = 0
	self:savefightAllData(fightAllData)

end

return BiWu
0