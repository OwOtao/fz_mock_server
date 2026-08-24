local speedDesc =
{
	[1] = "HIR龙舟行进得十分缓慢，还请加快些速度吧！",
	[2] = "RED龙舟在水中慢悠悠地前进，还是再快一些吧！",
	[3] = "YEL龙舟在水中缓慢地前行着，水面荡出阵阵涟漪。",
	[4] = "HIY龙舟平稳地航行在水面上，荡出阵阵波纹，煞是好看。",
	[5] = "BLU龙舟快速航行在水面上，在旁的观众不禁为你喝彩。",
	[6] = "HIB龙舟快速向前行驶，两岸风景快速向后倒退。",
	[7] = "CYN龙舟行进速度很快，溅起阵阵水花。",
	[8] = "HIC龙舟速度极快，在水面泛起道道横波。",
	[9] = "WHT龙舟速度飞快，周围的观众不禁为你呐喊助威。",
	[10] = "HIW龙舟宛如箭一般，飞速驰骋在水面上！",
}

local rankDesc =
{
	[1] = "HIW第一名",
	[2] = "WHT第二名",
	[3] = "RED第三名",
	[4] = "HIY第四名",
	[5] = "YEL第五名",
	[6] = "GRN第六名",
	[7] = "HIC第七名",
	[8] = "CYN第八名",
}

-- 超过
local exceed = "HIC在你的指挥之下，你的龙舟已经超过了$N的队伍。"

-- 被超过
local beExceed = "HIR你的龙舟速度太慢了，竟然被$N超过了。"

-- 距离
local spacing =
{
	[1] = "RED你离前方$MRED的队伍还十分遥远。",
	[2] = "HIY你离前方$MHIY的队伍还有数丈之遥。",
	[3] = "HIC你离前方$MHIC的队伍只有丈余距离，快追上去！",
	[4] = "HIW你离前方$MHIW的队伍已经十分接近，快超过它！",
}

-- 挑衅
local provokeDesc =
{
	[1] = "CYN$M$NCYN向你发出了挑衅！",
	[2] = "CYN你不由得勃然大怒，运起轻功跳上对面的龙舟，与$N展开了战斗。",
	[3] = "RED你并不理会$N的行为，但你方船员见此状，不由得士气低落，船行速度降低了一些。",
	[4] = "CYN你冷笑一声，反而开始挖苦$N起来，$N也不示弱，你两人在江上对骂，骂了许久，也没个结果。",
	[5] = "HIR你十分气恼，反而开始讥讽$N，但$N哪是易与之辈，你两人竟就此在江上对骂，正骂到激烈之时，却没想到你一时语塞，闹了笑话，你方船员见此光景，不仅士气低落，你方船队速度降低了。",
	[6] = "HIC你呵呵一笑，也不气恼，转头便将$N的祖辈上下数落了个干净，你方船员见此状士气大振，努力划桨，龙舟一下驶出丈余。",
	[7] = "HIY你满是不屑地挑衅着$N。",
	[8] = "HIR$N不由得勃然大怒，直接跳上你的船只与你决斗。",
	[9] = "HIC$N并不理会你的行为，你方船队队员见此状不由得哈哈大笑，队员士气高涨，船队速度又快了一些！",
	[10] = "CYN$N冷笑一声，反而开始挖苦你，你也不示弱，你两人在江上对骂，骂了许久，也没个结果。",
	[11] = "HIR$N十分气恼，反而开始讥讽你，但你哪是易与之辈，你两人竟就此在江上对骂，正骂到激烈之时，却没想到你一时语塞，闹了笑话，你方船员见此光景，不仅士气低落，你方船队速度降低了。",
	[12] = "HIC$N呵呵一笑，也不气恼，转头便将你的祖辈上下数落了个干净，你立马还击，将$N辩得无话可说。你方船员见此状士气大振，努力划桨，龙舟一下驶出丈余。",
}

-- 决斗
local fightDesc =
{
	[1] = "HIR$M$NHIR见你方船队靠近，二话不说跳上你方船队与你展开战斗！",
	[2] = "HIR$M$NHIR向你发起了决斗！",
	[3] = "CYN你毅然决然地跳上$MCYN的龙舟与$N展开了决斗。",
}

-- 飞镖文本
local dartsDesc =
{
	[1] = "CYN你轻松躲开了$N射来的飞镖，没有受到任何伤害，你方船员见状不由得士气大涨。",
	[2] = "CYN你被$N的飞镖所击中，受了不轻的伤。 ",
	[3] = "HIC你轻松接住了来自$N的飞镖，使得你的船员免受伤害。",
	[4] = "HIR你没能接住来自$N的飞镖，你的船员受伤了！你们船队的速度下降了一些。",
	[5] = "HIC你将飞镖打向$N的船员，$N没接住来自你的飞镖，致使船员受伤，速度下降了！",
	[6] = "CYN你将飞镖打向$N的船员，但$N一个小跳接住了你发射的暗器。"
}

-- 胜利文本
local winDesc =
{
	[1] = "HIC你三招两式便将$N打得找不到北，你方船队见此状不由得士气大增，划船速度都快了不少！",
	[2] = "HIC你三招两式便将$N打得找不到北，你方船队见此状不由得士气大增，划船更有力气了！",
}

-- 胜利速度到达上限文本
local winLimitDesc =
{
	[1] = "HIC你三招两式便将$N打得找不到北，你方船队见此状不由得士气大增，划船都更有力气了！",
	[2] = "HIC你将$M$NHIC揍得鼻青脸肿，你方船员见得此景不由得士气大增，划船更有力气了！",
}

-- 失败文本
local failDesc =
{
	[1] = "HIR一番较量之后，你被$N打的鼻青脸肿，你方船员见此光景，不由得情绪低落，划船速度降低了一些。",
	[2] = "HIR你技不如人，败了回来，你方船员见此光景，不由得情绪低落，划船速度降低了一些。",
}

-- 鼓舞文本
local inspireDesc =
{
	[1] = "HIC你鼓舞着船员的士气，船员们受你感染，划动的速度更快了！",
	[2] = "HIC你鼓舞着船员的士气，船员们受你感染，划船更有力气了！",
}

-- 游龙
local dragonDesc = "HIM你大喝一声，运起全身真气护住船头，船员见此状纷纷大力划桨，你们的船宛若游龙一般在江上驰骋数丈有余！"

local boatData = require("script.others.dragonBoat")["船只信息"]
local familyData = require("script.others.dragonBoat")["门派信息"]

-- 赛龙舟
local DragonBoatLayer = class("DragonBoatLayer", LayerEx)

function DragonBoatLayer:create()
	local p = DragonBoatLayer:new()
	p:init()
	return p
end

function DragonBoatLayer:init()
	self._UI = require("Layer/PopUI/DragonBoatUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:initRichText()
	self:setBack()
	self:setButton()
end

-- 显示界面
function DragonBoatLayer:showLayer(map, isPractice, isFree)

	-- 是否是练习模式
	self.isPractice = isPractice
	-- 是否免费
	self.isFree = isFree

	if map then
		self._map = map
		self._mapLayer = map._mapLayer
	end

	--在赛龙舟里，退出。进入江湖偶遇不可以决斗
	local role = User:getRole()
	role:setFlag("PVP活动状态","忙碌")

	-- 初始化AI
	self:initAI()

	if isPractice == true then
		self.Panel_category.Button_return:setVisible(true)
		self:initDragonBoat()
		self:show()
	else
		-- 赛龙舟：初始化
		role:setDayFlag("赛龙舟积分", 0)
		role:setDayFlag("赛龙舟奖励状态", 1) -- 待领取
		role:setDayFlag("赛龙舟次数", role:getDayFlag("赛龙舟次数") + 1)

		self.Panel_category.Button_return:setVisible(false)

		-- 文本动画
		self:delayFunc(2,function()
			Audio:playEffect("DragonBoatIn", false)
		end)
		self:setVisible(false)
		local familyStr = User:getRole():getFamilyName()
		if familyStr == nil then
			familyStr = ""
		end
		for k,v in pairs(self.AIList) do
			familyStr = familyStr .. "、" ..v.noname
		end
		local text =
		{
			[1] = "端午佳节，江湖同庆。",
			[2] = "各大门派齐聚平安小镇，以龙舟为介一较高下。#####",
			[3] = "本次出场的门派共有八个。",
			[4] = "分别为 " .. familyStr .. "。 #####",
			[5] = "他们已经做好了准备！#####",
			[6] = "那么比试！#####",
			[7] = "开始！",
		}

		local TeacherAnimationLayer = require("app.views.layer.TeacherLayer.TeacherAnimationLayer")
		local teacherAnimationLayer = TeacherAnimationLayer:getInstance()

		teacherAnimationLayer:setVisible(false)
		teacherAnimationLayer:createTextFromArray(text)
		teacherAnimationLayer:show(function()
			Audio:stopAllEffects()
			-- 初始化船只信息
			self:initDragonBoat()
			self:show()
		end)
	end
end

-- 初始化
function DragonBoatLayer:initDragonBoat()
	-- 开始时间
	self.startTime = GetTime()

	-- 上一次计算距离的时间
	self.lastCountTime = GetTime()

	-- 上一次减速时间
	self.lastSubSpeedTime = GetTime()

	-- 上一次检测距离时间
	self.lastCheckDistance = GetTime()

	-- 上一次事件触发时间
	self.lastEventTime = GetTime() + 5

	-- 上一次排名
	self.lastRank = 8

	-- 时间触发间隔
	self.eventInterval = math.random(12,17)

	-- 游戏数据 剩余路程;速度;士气值
	self.data = "1000;1;0"

	-- 是否已经左划过
	self.leftAlready = false

	-- 是否已经右划过
	self.rightAlready = false

	-- 目标船队
	self.targetTeam = nil

	-- 是否游戏结束
	self.isOver = false

	-- 进度条按钮
	self.barList =
	{
		-- left
		["left"] = { panel = self.Panel_left, startTime = nil, isCd = false },

		-- right
		["right"] = { panel = self.Panel_right, startTime = nil, isCd = false },

		-- 鼓舞
		["inspire"] = { panel = self.Panel_inspire, startTime = nil, isCd = false },

		-- 游龙
		["dragon"] = { panel = self.Panel_dragon, startTime = nil, isCd = false },

		-- 飞镖
		["darts"] = { panel = self.Panel_darts, startTime = nil, isCd = false },

		-- 决斗
		["fight"] = { panel = self.Panel_fight, startTime = nil, isCd = false },

		-- 挑衅
		["provoke"] = { panel = self.Panel_provoke, startTime = nil, isCd = false },
	}

	-- 暂停时间
	self.stopTime = nil

	-- 是否暂停中
	self.isStop = false

	self.Panel_inspire:setVisible(false)
	self.Panel_dragon:setVisible(false)
	self.Panel_darts:setVisible(false)
	self.Panel_fight:setVisible(false)
	self.Panel_provoke:setVisible(false)

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1/30)

	Audio:playEffect("DragonBoatIng", true)
end

-- 初始化AI信息
function DragonBoatLayer:initAI()
	local familyCount = 0
	for k,v in pairs(familyData) do
		familyCount = familyCount + 1
	end

	local listCount = 0
	self.AIList = {}

	local UserFamily = User:getRole():getFamilyName()
	if UserFamily == nil then
		UserFamily = "江湖浪人"
	end

	-- 随机取七个门派
	while listCount < 7 do
		local randNum = math.random(1, familyCount)
		for k,v in pairs(familyData) do
			if v.id == randNum then
				if self.AIList[v.name] == nil and UserFamily ~= v.noname then
					listCount = listCount + 1
					local data = boatData[tostring(listCount)]
					local sex = "男"
					if v.sex == 1 then
						sex = "男"
					elseif v.sex == 2 then
						sex = "女"
					elseif v.sex == 0 then
						if math.random(1,2) == 1 then
							sex = "女"
						end
					end

					local npcList = string.split(v.takeid, ";")
					local npcId = npcList[math.random(1, #npcList)]

					self.AIList[v.name] =
					{
						rank = listCount,
						noname = v.noname,
						name = v.name,
						speed = tonumber(data.speed),
						distance = data.far,
						npcId = npcId,
						sex = sex,
						npcName = Helper:getRandomName(sex)
					}
				end
			end
		end
	end
end

function DragonBoatLayer:getData(index)
	return tonumber(string.split(self.data, ";")[index])
end

function DragonBoatLayer:setData(distance, speed, morale)
	distance = Helper:getDef(distance, self:getData(1))
	speed 	 = Helper:getDef(speed, self:getData(2))
	morale 	 = Helper:getDef(morale, self:getData(3))

	local str = distance .. ";" .. speed .. ";" .. morale
	-- print("setData " .. str)
	self.data = str
end

-- 游戏结束
function DragonBoatLayer:gameOver()
	--在赛龙舟结束时，重置江湖偶遇可以决斗
	local role = User:getRole()
	role:setFlag("PVP活动状态","空闲中")
	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self.isOver = true

	self:print("HIW你的船队已经到达了终点，本次比试你取得了" .. rankDesc[self:getPlayerRank()] .. "的成绩。")

	-- local role = User:getRole()
	local point = 0
	local currTime = GetTime()
	local interval = currTime - self.startTime

	self.Panel_over.Text_time:setString("本次耗时：" .. math.floor(interval))
	self.Panel_over.Text_pot:setString("获得潜能：" .. 0)
	self.Panel_over.Text_exp:setString("获得经验：" .. 0)
	self.Panel_over.Text_point:setString("龙舟积分：" .. 0)
	self.Panel_over.Text_rank_num:setString(rankDesc[self:getPlayerRank()])

	-- 练习模式 或者已领取过奖励，不会再获得奖励
	if self.isPractice ~= true then
		local pot,exp = self:getReward()
		self.Panel_over.Text_pot:setString("获得潜能：" .. pot)
		self.Panel_over.Text_exp:setString("获得经验：" .. exp)
		role:addAttr("pot", pot)
		role:addAttr("exp", exp)
	end
    
    --练习模式可以一直耍 正式模式一天只可以玩一次
	-- if self.isPractice == false then
	-- 	role:setDayFlag("2018端午赛龙舟",1)
	-- end

	point = math.floor(((366 - interval) / 6.8) ^ 1.5)
	if interval >= 300 then
		point = 30
	end
	if point >= 265 then
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
		PopupLayerController:hideLayer("DragonBoatLayer", function(layer)
			self:hide()	
		end, 0)
		return
	end

	if self.isPractice == true then
		self.Panel_over.Text_rank:setString("你在本次练习获得")
	else
		self.Panel_over.Text_rank:setString("你在本次比赛获得")
		self.Panel_over.Text_point:setString("龙舟积分：" .. point)

		local menpai = role:getFamilyId()
		if not role:hasFamily() then
			menpai = "youxia"
		end

		HttpManagerEx:updateDragonBoatPoint(menpai, point, interval, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					PopText("赛龙舟积分上传成功")
					-- 更新赛龙舟状态，成绩
					role:setDayFlag("赛龙舟积分", point)
					role:setDayFlag("赛龙舟奖励状态", 1) -- 待领取
					-- 跨天，因为上一天的标记被重置了，这时更新标记
					if role:getDayFlag("赛龙舟次数") == 0 then
						-- 为第二天增加赛龙舟次数
						role:setDayFlag("赛龙舟次数", 1)
						-- 标记是否付费后跨天，付费后，第二天之后的两次参赛一次免费，一次付费，跨天前那次没有付费的话，第二天之后的两次参赛都需要付费
						if self.isFree == false then
							role:setDayFlag("赛龙舟付费后跨天", 1)
						end
					end
				elseif errcode == 2 then  --跨天为活动时间结束时
					-- 更新赛龙舟状态，成绩
					role:setDayFlag("赛龙舟积分", point)
					role:setDayFlag("赛龙舟奖励状态", 1) -- 待领取
		            PopText(errmsg)
				else
					PopText(errmsg)
				end
				return true
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING, HTTP_MANAGER_RETRY_TYPE_RETRY)
	end

	self:delayFunc(2, function()
		Audio:stopAllEffects()
		self.Panel_over:setVisible(true)
	end)
end

-- 获取奖励
function DragonBoatLayer:getReward()
	local rank = self:getPlayerRank()
	local pot = 20000 - (rank - 1) * 1000
	local exp = 20000 - (rank - 1) * 2000

	return pot,exp
end










------------------------------- 刷新相关 -------------------------------

-- 刷新
function DragonBoatLayer:update()
	local currTime = GetTime()

	-- 暂停中 把暂停的时间补上
	if self.isStop and self.stopTime ~= nil then
		local time = currTime - self.stopTime
		self.lastSubSpeedTime = self.lastSubSpeedTime + time
		self.lastCountTime = self.lastCountTime + time
		self.lastEventTime = self.lastEventTime + time
		self.startTime = self.startTime + time
		self.lastCheckDistance = self.lastCheckDistance + time

		-- 进度条
		for k,v in pairs(self.barList) do
			if v.startTime ~= nil then
				self.barList[k].startTime = self.barList[k].startTime + time
			end
		end
		self.stopTime = currTime
		return
	end

	-- 每7秒降低速度
	local sec = 7
	-- 时间更改
	if currTime - self.startTime >= 90 then
		sec = 4
	elseif currTime - self.startTime >= 30 then
		sec = 6
	end

	if currTime - self.lastSubSpeedTime >= sec then
		self.lastSubSpeedTime = currTime
		local speed = self:getData(2)

		speed = speed - 1
		if speed <= 0 then
			speed = 1
		end
		self:setData(nil, speed, nil)
	end

	self:refreshDistance()
	self:refreshUI()
	self:refreshBtnBar()

	-- 检测事件触发
	self:checkEvenTouchOff()
end

-- 暂停游戏
function DragonBoatLayer:stopGame()
	-- Audio:stopAllEffects()

	self.isStop = true
	self.stopTime = GetTime()
end

--恢复游戏
function DragonBoatLayer:recoveryGame()
	-- Audio:playEffect("DragonBoatIng", true)
	self.isStop = false
	self.stopTime = nil
end

-- 检测事件触发
function DragonBoatLayer:checkEvenTouchOff()
	local currTime = GetTime()
	if currTime - self.lastEventTime > self.eventInterval then
		self:TouchOffEvent()

		-- 触发时间更改
		if currTime - self.startTime >= 60 then
			self.eventInterval = math.random(4, 6)
		elseif currTime - self.startTime >= 30 then
			self.eventInterval = math.random(5, 9)
		else
			self.eventInterval = math.random(7, 12)
		end
		print("下次时间开启时间 " .. self.eventInterval .. "秒后")
		self.lastEventTime = currTime
	end
end

-- 刷新按钮进度条CD
function DragonBoatLayer:refreshBtnBar()
	-- 刷新所有进度条
	local currTime = GetTime()
	local role = User:getRole()

	-- 冷却时间
	local CDTime =
	{
		-- left
		["left"] = 4,

		-- right
		["right"] = 4,

		-- 鼓舞
		["inspire"] = 30,

		-- 游龙
		["dragon"] = 30,

		-- 飞镖
		["darts"] = 20,

		-- 决斗
		["fight"] = 20,

		-- 挑衅
		["provoke"] = 20,
	}

	-- 冷却时间更改
	if currTime - self.startTime >= 50 then
		CDTime["left"] = 2
		CDTime["right"] = 2
	elseif currTime - self.startTime >= 25 then
		CDTime["left"] = 3
		CDTime["right"] = 3
	end


	local familyId = role:getFamilyId()

	-- 唐门飞镖时间缩短
	if familyId == "tangmen" then
		CDTime["darts"] = 10
	end

	-- 海鲸帮
	if familyId == "haijing" then
		CDTime["dragon"] = 20
	end

	-- 遍历进度条
	for k,v in pairs(self.barList) do
		local per = 100
		if v.startTime ~= nil then
			v.panel.Bar.Text_ButtonName:setColor({r = 208, g = 208, b = 208, a = 255})
			per = ((currTime - v.startTime) / CDTime[k]) * 100
			if per >= 100 then
				per = 100
				self.barList[k].startTime = nil
				self.barList[k].isCd = false
			else
				v.panel.Bar.Text_ButtonName:setColor({r = 127, g = 127, b = 127, a = 255})
			end

		end
		v.panel.Bar:setPercent(per)
	end
end

-- 刷新距离
function DragonBoatLayer:refreshDistance()
	local currTime = GetTime()
	local distance = self:getData(1)
	local speed = self:getData(2)

	local interval = currTime - self.lastCountTime
	local sub = interval * speed

	self.lastCountTime = currTime

	distance = distance - sub
	if distance < 0 then
		distance = 0
		-- 游戏结束 上传成绩
		self:gameOver()
	end

	self:setData(distance, speed, self:getData(3))

	-- 刷新AI距离
	for k,v in pairs(self.AIList) do
		local sub = interval * v.speed
		local distance = v.distance
		distance = distance - sub

		if distance < 0 then
			distance = 0
		end

		self.AIList[k].distance = distance
	end

	-- 计算AI排名
	local rankList = {}
	for k,v in pairs(self.AIList) do
		table.insert(rankList, {name = v.name, distance = v.distance})
	end

	table.sort(rankList, function(a, b)
		return a.distance < b.distance
	end)

	for i,v in ipairs(rankList) do
		self.AIList[v.name].rank = i
	end
end

-- 刷新UI
function DragonBoatLayer:refreshUI()
	local currTime = GetTime()
	local time = math.floor(currTime - self.startTime)
	local distance = self:getData(1)
	local speed = self:getData(2)
	local morale = self:getData(3)

	-- 时间
	self.Text_time:setString("『时间』" .. time .. "秒")

	-- 剩余距离
	local far = math.floor(distance) / 10
	self.Text_distance:setString("『剩余』" .. far .. "丈")

	-- 进度条
	self.LoadingBar:setPercent((morale / 20) * 100)

	-- 速度描述
	self.Image_print.Text_desc:setString(speedDesc[speed])

	-- 排名
	local rank = self:getPlayerRank()
	self.Text_rankName:setString(rankDesc[rank])

	if rank ~= self.lastRank then
		if rank < self.lastRank then
			self:print(exceed)
			self.lastRank = rank
		end
	end

	-- 设置新的目标船队
	local text, BoatName = self:getTargetTeam(rank)
	self.Text_beforeBoatTeam:setString(text)
	self.Text_beforeBoatTeamName:setString(BoatName)

	if rank ~= self.lastRank then
		if rank > self.lastRank then
			self:print(beExceed)
			self.lastRank = rank
		end
	end

	-- 检测与NPC的距离
	if currTime - self.lastCheckDistance > 2 then
		local num = math.abs(self.targetTeam.distance - distance)
		if rank ~= 1 then
			if num > 50 then
				self:print(spacing[1])
			elseif num >= 30 then
				self:print(spacing[2])
			elseif num >= 10 then
				self:print(spacing[3])
			elseif num >= 0 then
				self:print(spacing[4])
			end
		end

		-- print("==================== 排名 ====================")
		-- for k,v in pairs(self.AIList) do
		-- 	print(v.noname .. "	距离 = " .. math.floor(v.distance) .. "	排名 = " .. v.rank .. "	速度 = " .. v.speed)
		-- end
		self.lastCheckDistance = currTime
	end

	-- 按钮出现
	-- 鼓舞
	if currTime - self.startTime >= 9 then
		self.Panel_inspire:setVisible(true)
	end

	-- 游龙
	if currTime - self.startTime >= 30 then
		self.Panel_dragon:setVisible(true)
	end

	-- 飞镖
	if currTime - self.startTime >= 15 then
		self.Panel_darts:setVisible(true)
	end

	-- 决斗
	if currTime - self.startTime >= 20 then
		self.Panel_fight:setVisible(true)
	end

	-- 挑衅
	if currTime - self.startTime >= 25 then
		self.Panel_provoke:setVisible(true)
	end
end












------------------------------- 事件相关 -------------------------------

-- 随机触发事件
function DragonBoatLayer:TouchOffEvent()
	if self.targetTeam == nil then
		print("没有目标船队")
		return
	end

	local distance = self:getData(1)
	local npcDistance = self.targetTeam.distance

	-- 0 什么不触发 1 飞镖 2 飞镖决斗 3 飞镖决斗挑衅
	local state = 0
	local num = math.abs(distance - npcDistance)


	if num >= 50 then
		state = 0
		return
	elseif num >= 30 then
		state = 1
	elseif num >= 20 then
		state = 2
	else
		state = 3
	end

	print("与" .. self.targetTeam.name .. "船队距离 = " .. num .. " state = " .. state)

	local eventNum = math.random(1, state)

	-- 飞镖
	if eventNum == 1 then
		self:beDarts()
	-- 挑衅
	elseif eventNum == 2 then
		self:print(provokeDesc[1])
		self:stopGame()
		self:popPanel(provokeDesc[1],
			"决斗", function()
				self:print(provokeDesc[2])
				local npc = self:getFightNpc()
				npc:setAttr("name", self.targetTeam.npcName)
				npc:setAttr("sex", self.targetTeam.sex)
				self:fight(npc)
			end,
			"不理会", function()
				self:print(provokeDesc[3])
				self:recoveryGame()
				local speed = self:getData(2)
				speed = speed - 1
				if speed <= 0 then
					speed = 1
				end

				self:setData(nil, speed, nil)
			end,
			"反讥", function()
				self:recoveryGame()
				-- 反讥
				local randNum = math.random(1,3)
				if randNum == 1 then
					-- 无效果
					self:print(provokeDesc[4])
				elseif randNum == 2 then
					-- 速度减1
					local speed = self:getData(2)

					speed = speed - 1
					if speed <= 0 then
						speed = 1
					end

					self:print(provokeDesc[5])
					self:setData(nil, speed, nil)
				else
					-- 距离减10
					local distance = self:getData(1)
					distance = distance - 10
					if distance < 0 then
						distance = 0
					end

					self:print(provokeDesc[6])
					self:setData(distance, nil, nil)
				end
			end
		)

	-- 决斗
	elseif eventNum == 3 then
		self:print(fightDesc[1])
		self:stopGame()
		self:popPanel(fightDesc[2], "应战", function()
			local npc = self:getFightNpc()
			npc:setAttr("name", self.targetTeam.npcName)
			npc:setAttr("sex", self.targetTeam.sex)
			self:fight(npc)
		end)
	end
end

-- 被NPC使用飞镖
function DragonBoatLayer:beDarts()
	self:stopGame()

	if math.random(1,2) == 1 then
		self:dartsToYou()
	else
		self:dartsToCrew()
	end
end

-- 飞镖射玩家
function DragonBoatLayer:dartsToYou( ... )
	PopupLayerController:showLayer("NewDialogDodgeLayer", function(layer)
		if layer:isAvail() == false then
			print("dodgeLayer is now busy")
			return
		end

		layer:reinit()

		layer:setAttackerName( self.targetTeam.npcName )
		layer:setAnqiName( "飞镖" )
		layer:setTime( 1.5 )
		layer:setDamagePercent( 0.1 )
		layer:setResultCallback(function(isSucc)
			self:recoveryGame()
			if isSucc == true then
				self:print(dartsDesc[1])

				-- 增加士气
				local morale = self:getData(3)

				morale = morale + 2
				if morale > 20 then
					morale = 20
				end
				self:setData(nil, nil, morale)
			else
				self:print(dartsDesc[2])
			end
		end)

		layer:show()
	end)
end

-- 飞镖射船员
function DragonBoatLayer:dartsToCrew( ... )
	PopupLayerController:showLayer("NewDialogDodgeLayer", function(layer)
		if layer:isAvail() == false then
			print("dodgeLayer is now busy")
			return
		end

		layer:reinit()
		-- 设置文本
		layer:setDodgeTexts(
		{
			["up"] = { "你身形陡然纵起，凌空一跃，伸手试图接下$w。" , "你身体向上笔直纵身，跃起数丈，尝试接下$w。" } ,
			["down"] = {"你飘然向下一闪，身体贴向$w，试图将其拦下。" } ,
			["left"] = { "你身体晃动，向左移动数步，尝试接下$w。。" , "你身随意转，向左一闪，举手伸向$w。" } ,
			["right"] = { "你向右，侧身一摆。" , "你足不点地，向右窜开。" } ,
			["still"] = { "你停留在原地，什么也没做！" , "你尚未回过神来！" }
		})
		layer:setSuccTexts(
		{
			"十分轻松地接下了暗器！",
			"犹如鬼魅一般，十分利索地接下了暗器！",
			"电光火石之间接下了暗器的攻击",
		})
		layer:setHurtTexts(
		{
			"你虽然反应极快，但$w还是打伤了你的船员。",
			"$w来势甚猛，你接取失败，你的船员受到了伤害 ",
			"你速度太慢，$w击中你的船员",
			"你身法虽快，却未快过这$w，你的船员受伤不轻 ",
		})
		layer:setFireTexts(
		{
			[[$N单手一翻，$w散射而出，击向你的船员的$d。]] ,
			[[$N向你的船员$d发射了一枚$w，快闪开！]] ,
			[[$N一个转身，$w飞快地向你船员的$d射来，快躲开！]] ,
			[[$N飞身而起，双手如散花般发射了数枚$w,暗器以极快的速度向你船员的$d袭来！]] ,
			[[$N手中$w激射而出，向你船员的$r飞来，只听“叮”地一声，暗器在空中突然转向，向你船员的$d射来！原来是$N再发一枚暗器，将先前暗器方向打偏！]] ,
			[[$N向你船员的头部发射了一枚$w，快$R！暗器飞至一半，却不知为何转向向你船员的$d打来！]],
			[[快$D！$N飞快地向你船员射出了数枚暗器！]] ,
			[[$N向你船员射出了数枚$w！快$R！不对不对！应该是$D]] ,


			[[$N腾空而起，手中$w飞速打向你船员的$d！]] ,
			[[$N眼中冷芒闪过，手中的$w已无踪迹，再看时，暗器已经离你船员的$d半步之遥！]] ,
			[[$N微微一笑，$w脱手而出，只刹那便至你船员的$d！]] ,
			[[$N凌空一掷！手中$w已经朝你船员的$r飞来，眼看就快靠近，暗器突地一转，打向你船员的$d！]] ,
			[[快闪开！$N手指弹出数枚$w,极快打向你船员的$r！不好！暗器在空中方向突变，打向了你船员的$d！]] ,
			[[$N腾空而起，手中$w飞速打向你的船员，快$D！]] ,
			[[$N眼中冷芒闪过，手中的$w已无踪迹，再看时，暗器已经离你船员的$d半步之遥！快$D！]] ,
			[[$N飞身而起，$w飞快地向你船员的$d射来！快$R！不对不对！不能$B]] ,
			[[快$D！暗器已朝你飞速射来，只见$N冷笑一声，暗器竟然偏离方向朝你的$d射来！]]
		})

		layer:setToFireTexts({ "头部" , "下身", "左侧" , "右侧" })
		layer:setToDodgeTexts({ "跳接" , "下接" , "左接" , "右接" })
		layer:setBtnName({ "跳接" , "下接" , "左接" , "右接" })

		layer:setAttackerName( self.targetTeam.npcName )
		layer:setAnqiName( "飞镖" )
		layer:setTime( 1.5 )
		layer:setDamagePercent( 0 )
		layer:setResultCallback(function(isSucc)
			self:recoveryGame()
			if isSucc == true then
				self:print(dartsDesc[3])
			else
				print("射中船员 速度减1")
				local speed = self:getData(2)
				speed = speed - 1
				if speed <= 0 then
					speed = 1
				end

				self:print(dartsDesc[4])
				self:setData(nil, speed, nil)
			end
		end)

		layer:show()
	end)
		
end

function DragonBoatLayer:fight(npc)
	Audio:stopAllEffects()
	-- 胜利调用
	local func1 = function ()
		local speed = self:getData(2)
		local morale = self:getData(3)
		local str = winDesc[math.random(1, #winDesc)]
		speed = speed + 1

		if speed > 10 then
			speed = 10
			str = winLimitDesc[math.random(1, #winLimitDesc)]
		end

		-- 增加士气
		morale = morale + 3
		if morale > 20 then
			morale = 20
		end

		self:print(str)
		self:setData(nil, speed, morale)
		Audio:playEffect("DragonBoatIng", true)
	end

	-- 失败逃跑调用
	local func2 = function()
		local speed = self:getData(2)
		local str = failDesc[math.random(1, #failDesc)]
		speed = speed - 1
		if speed <= 0 then
			speed = 1
		end
		self:print(str)
		self:setData(nil, speed, nil)
		Audio:playEffect("DragonBoatIng", true)
	end

	local FightLayer = require("app.views.layer.FightLayer.FightLayer")
	local player = User:getRole()

	if player:getAttr("qi") <= 0 then 
		local speed = self:getData(2)
		speed = speed - 1
		if speed <= 0 then
			speed = 1
		end
		self:print("你气血不足，无力再战，你方船员见此光景，不由得情绪低落，划船速度降低了一些")
		self:setData(nil, speed, nil)
		Audio:playEffect("DragonBoatIng", true)
		self:recoveryGame()
		return
	end

	local role = npc
	local fightType = "切磋"
	 FightLayer:startMapFight({player}, {role},
    function(fightLayer, eventType, ...)
        local fight = fightLayer:getFight()
        if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
			if self._mapLayer then
				-- 暂停地图场景渲染
				self._mapLayer:pauseSelfAndChildren()
				self._mapLayer:setVisible(false)
			end

            -- PopText("战斗开始!!!")
            -- 战斗开始的时候设置下玩家
            local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
            fight:setPlayer(role)

            -- 显示开场白
            fightLayer:printRolePrologue(1, fightType)

			-- fight:start()
		elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then

        	-- if self._mapLayer then
			-- 	-- 暂停地图场景渲染
			-- 	self._mapLayer:pauseSelfAndChildren()
			-- 	self._mapLayer:setVisible(false)
			-- end

            PopText("战斗开始!!!")
            -- -- 战斗开始的时候设置下玩家
            -- local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
            -- fight:setPlayer(role)

            -- -- 显示开场白
            -- fightLayer:printRolePrologue(1, fightType)
        elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
            local winTeamId, teams = ...

            -- 属性结算 add by TangJian 2016/11/02 19:37:54
            do
                player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
                role:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(2, 1), fightType)
            end

            -- 隐藏按钮区域
            fightLayer:callUIMemFunc("setButtonAreaVisble", false)
            -- 显示战斗结束文本区域
            fightLayer:callUIMemFunc("showFightEndTextArea")

            -- 设置战斗结束文本区域的文本
        	local target = fight:getRoleByTeamIdAndInTeamId(winTeamId, 1)
        	local zhao = target:getCurrAttackZhao()
        	local damageType = zhao.damageType

            if winTeamId == 1 then
                fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
                fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你" .. "打赢了" .. role:getName())
        		player:calcActiveZhaoUseTimes(fight:getRoleByTeamIdAndInTeamId(1, 1)) -- 计算主动招式熟练度

        		self:delayFunc(1, function()
        			Helper:getDef(callback, EMPTY_FUNC)(winTeamId)
		    		if self._mapLayer then
						self._mapLayer:resumeSelfAndChildren()
						self._mapLayer:setVisible(true)
					end

		            fightLayer:hide(function()
		                fightLayer:destroyInstance()
		                cleanTable(fightLayer)
		                func1()
		                self:recoveryGame()
		            end)
        		end)
            else
                fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
                fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. role:getName() .. "击败了")
                self:delayFunc(1, function()
        			Helper:getDef(callback, EMPTY_FUNC)(winTeamId)
		    		if self._mapLayer then
						self._mapLayer:resumeSelfAndChildren()
						self._mapLayer:setVisible(true)
					end

		            fightLayer:hide(function()
		                fightLayer:destroyInstance()
		                cleanTable(fightLayer)
		                func2()
		                self:recoveryGame()
		            end)
        		end)
            end
        elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
            -- 属性结算 add by TangJian 2016/11/02 19:37:54
            do
                player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
                role:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(2, 1), fightType)
            end

            -- 隐藏按钮区域
            fightLayer:callUIMemFunc("setButtonAreaVisble", false)
            -- 显示战斗结束文本区域
            fightLayer:callUIMemFunc("showFightEndTextArea")

            -- 设置战斗结束文本区域的文本
            fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
            fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你大喝一声：“三十六计，走为上计")

            fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
                if self._mapLayer then
					self._mapLayer:resumeSelfAndChildren()
					self._mapLayer:setVisible(true)
				end

                fightLayer:hide(function()
                    fightLayer:destroyInstance()
                    cleanTable(fightLayer)
                    func2()
                    self:recoveryGame()
                end)
            end)
        end
    end, nil, nil, nil, function()
    	-- add by XiaoZhiWei 2018/06/22 11:43:03 战斗启动失败的时候,直接调用成功的结果
         self:delayFunc(1, function()
			Helper:getDef(callback, EMPTY_FUNC)(winTeamId)
    		if self._mapLayer then
				self._mapLayer:resumeSelfAndChildren()
				self._mapLayer:setVisible(true)
			end
            func2()
            self:recoveryGame()
		end)
    end)
end








------------------------------- 弹窗相关 -------------------------------
-- 弹出窗口
function DragonBoatLayer:popPanel(text, btn1, func1, btn2, func2, btn3, func3)
	local panel = self.Panel_pop

	-- 初始化输出框
	local function initRichText()
		local x, y = panel.Text_desc:getPosition()
		local size = panel.Text_desc:getContentSize()

		if self.RichText_print2 then
			self.RichText_print2:removeFromParent()
			self.RichText_print2 = nil
		end

		local richTextScroll = ExtRichTextScroll:create()
		richTextScroll:setAnchorPoint( 0.5 , 0.5 )
	   	panel.Text_desc:getParent():addChild(richTextScroll)
	   	local point = cc.p(panel.Text_desc:getPosition())
	   	richTextScroll:move(point)
	   	richTextScroll:setSize(size)
	   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
	   	richTextScroll:getRichText():setVerticalSpace(5)
	   	self.RichText_print2 = richTextScroll

	   	self.RichText_print2:setBounceEnabled(false)
	end

	local function print2(str, verticalSpace)
		if str == "" then
			return
		end
		str = self:changeText(str)

		local textColor = cc.c3b(159,159,159)
		local textHeight = self.RichText_print2:getRichText():getNewContentSizeHeight()
		if textHeight >= 6666 then
			initRichText()
		end

		self.RichText_print2:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

		if verticalSpace ~= nil and type(verticalSpace) == "number" then
			self.RichText_print2:pushBackNewLine(verticalSpace)
		else
			self.RichText_print2:pushBackNewLine()
		end
	end

	initRichText()

	panel:setVisible(true)
	btn1 = Helper:getDef(btn1, "")
	btn2 = Helper:getDef(btn2, "")
	btn3 = Helper:getDef(btn3, "")

	func1 = Helper:getDef(func1, EMPTY_FUNC)
	func2 = Helper:getDef(func2, EMPTY_FUNC)
	func3 = Helper:getDef(func3, EMPTY_FUNC)

	panel.Button_1:setVisible(btn1 ~= "")
	panel.Button_2:setVisible(btn2 ~= "")
	panel.Button_3:setVisible(btn3 ~= "")

	panel.Button_1.Text_button_text:setString(btn1)
	panel.Button_2.Text_button_text:setString(btn2)
	panel.Button_3.Text_button_text:setString(btn3)
	print2(text)

	panel.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		func1()
		panel:setVisible(false)
	end)

	panel.Button_2:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		func2()
		panel:setVisible(false)
	end)

	panel.Button_3:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		func3()
		panel:setVisible(false)
	end)

end







------------------------------- 获取相关 -------------------------------

-- 获得玩家当前排名
function DragonBoatLayer:getPlayerRank()
	local distance = self:getData(1)
	local rank = 8

	for k,v in pairs(self.AIList) do
		if distance < v.distance then
			rank = rank - 1
		end
	end

	return rank
end

-- 获得目标船队 前方船队 或者后方船队
function DragonBoatLayer:getTargetTeam(rank)
	rank = Helper:getDef(rank, self:getPlayerRank())

	local targetRank = rank - 1
	local str = "『前方船队』"
	local name = ""

	if targetRank == 0 then
		targetRank = 1
		str = "『后方船队』"
	end

	for k,v in pairs(self.AIList) do
		if v.rank == targetRank then
			name = v.name
			self.targetTeam = v
			break
		end
	end

	return str, name
end

-- 获取决斗的NPC
function DragonBoatLayer:getFightNpc()
	if self._map and self.targetTeam then
		local npc = nil
		-- local npcList = string.split(self.targetTeam.npcId, ";")
		-- local npcId = npcList[math.random(1, #npcList)]
		local npcId = self.targetTeam.npcId
		local mapRolelist = self._map:getRoles()--地图角色属性
		for id,mapNpc in pairs(mapRolelist) do
			-- print(mapNpc.baseId)
			if mapNpc.baseId == npcId then
				npc = self._map:getRole(id)
				break
			end
		end

		local role = Role:create()
		if npc == nil then
			npc = role
		end
		setmetatable(npc, getmetatable(role))
		-- if npc == nil then
		-- 	print("找不到 " .. npcId)
		-- 	npc = Role:create()
		-- end

		-- print("DragonBoatLayer:getFightNpc()", npc.name, npc.id, npc.qi, npc.qiMax)

		return npc
	else
		return Role:create()
	end

end









------------------------------- 按钮相关 -------------------------------

function DragonBoatLayer:setButton()
	local function setLoadingBar(name)
		Audio:playEffect("xiaoAnNiu")

		if self.barList[name] == nil or self.barList[name].isCd == true then
			return false
		end

		self.barList[name].startTime = GetTime()
		self.barList[name].isCd = true
		return true
	end

	-- 鼓舞按钮
	self.Panel_inspire:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver == true or self.isStop == true then
			return
		end

		if setLoadingBar("inspire") == true then
			print("使用鼓舞")
			local speed = self:getData(2)
			local morale = self:getData(3)
			local str = inspireDesc[1]

			speed = speed + 1
			if speed > 10 then
				speed = 10
				str = inspireDesc[2]
			end

			-- 增加士气
			morale = morale + 2
			if morale > 20 then
				morale = 20
			end

			self:print(str)
			self:setData(nil, speed, morale)
		else
			PopText("该技能冷却中")
		end
	end)

	-- 游龙
	self.Panel_dragon:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver == true or self.isStop == true then
			return
		end

		if self:getData(3) < 20 then
			PopText("士气不足")
			print("士气不足 无法使用游龙")
			return
		end

		if setLoadingBar("dragon") == true then
			print("使用游龙")
			self:print(dragonDesc)
			local distance = self:getData(1)
			distance = distance - 50
			if distance < 0 then
				distance = 0
			end

			self:setData(distance, nil, 0)
		else
			PopText("该技能冷却中")
		end
	end)

	-- 飞镖
	self.Panel_darts:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver == true or self.isStop == true then
			return
		end

		if self.targetTeam ~= nil then
			if math.abs(self.targetTeam.distance - self:getData(1)) >= 50 then
				PopText("你的附近没有敌人")
				return
			end
		end
		if setLoadingBar("darts") == true then
			print("使用飞镖")
			if self.targetTeam ~= nil and math.random(1,2 ) == 1 then
				local speed = self.AIList[self.targetTeam.name].speed
				speed = speed - 1
				if speed <= 0 then
					speed = 1
				end
				print(self.targetTeam.name .. " 速度 = " .. speed )
				self.AIList[self.targetTeam.name].speed = speed
				self:print(dartsDesc[5])
			elseif self.targetTeam ~= nil then
				self:print(dartsDesc[6])
			end
		else
			PopText("该技能冷却中")
		end
	end)

	-- 决斗 Panel_fight
	self.Panel_fight:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver == true or self.isStop == true then
			return
		end

		if self.targetTeam ~= nil then
			if math.abs(self.targetTeam.distance - self:getData(1)) >= 20 then
				PopText("你的附近没有敌人")
				return
			end
		end
		if setLoadingBar("fight") == true then
			print("使用决斗")
			self:print(fightDesc[3])
			self:stopGame()
			local npc = self:getFightNpc()
			npc:setAttr("name", self.targetTeam.npcName)
			self:fight(npc)
		else
			PopText("该技能冷却中")
		end
	end)

	-- 挑衅
	self.Panel_provoke:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver == true or self.isStop == true then
			return
		end

		if self.targetTeam ~= nil then
			if math.abs(self.targetTeam.distance - self:getData(1)) >= 50 then
				PopText("你的附近没有敌人")
				return
			end
		end
		if setLoadingBar("provoke") == true then
			print("使用挑衅")
			self:print(provokeDesc[7])
			local randNum = math.random(1,3)
			if randNum == 1 then
				-- 决斗
				self:print(provokeDesc[8])
				self:stopGame()
				self:popPanel(fightDesc[2], "应战", function()
					local npc = self:getFightNpc()
					npc:setAttr("name", self.targetTeam.npcName)
					npc:setAttr("sex", self.targetTeam.sex)
					self:fight(npc)
				end)
			elseif randNum == 2 then
				-- 不理会你
				self:print(provokeDesc[9])
				local speed = self:getData(2)

				speed = speed + 1
				if speed > 10 then
					speed = 10
				end

				self:setData(nil, speed, nil)
			else
				-- 反讥
				randNum = math.random(1,3)
				if randNum == 1 then
					-- 无效果
					local str = provokeDesc[10]
					self:print(str)
				elseif randNum == 2 then
					-- 速度减1
					local speed = self:getData(2)
					local str = provokeDesc[11]

					speed = speed - 1
					if speed <= 0 then
						speed = 1
					end

					self:print(str)
					self:setData(nil, speed, nil)
				else
					-- 距离减10
					local distance = self:getData(1)
					local str = provokeDesc[12]
					distance = distance - 10
					if distance < 0 then
						distance = 0
					end

					self:print(str)
					self:setData(distance, nil, nil)
				end
			end
		else
			PopText("该技能冷却中")
		end
	end)

	-- 左划
	self.Panel_left:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver == true or self.isStop == true then
			return
		end

		if setLoadingBar("left") == false then
			local speed = self:getData(2)
			if speed > 4 then
				print("冷却中重复点击 速度降低")
				speed = speed - 1
				self:setData(nil, speed, nil)
				self:print("HIR由于你的指挥不当，船队速度没有得到提升，反而还下降了。")
			else
				self:print("HIR由于你的指挥不当，船队速度没有得到提升。")
			end
		else
			self:print("CYN船队在你的指挥下一齐往左划动，溅起道道水花。")
			self.leftAlready = true
			if self.rightAlready == true then
				local speed = self:getData(2)
				local morale = self:getData(3)
				local str = "HIC你指挥船队左右向后划动，你们船队的速度提升了！"

				speed = speed + 1
				if speed > 10 then
					speed = 10
					str = "HIC你指挥船队左右向后划动，你们船队飞快地驰骋在水面上！"
				end

				morale = morale + 1
				if morale > 20 then
					morale = 20
				end

				self:setData(nil, speed, morale)
				self.rightAlready = false
				self.leftAlready = false
				self:print(str)
			end
		end
	end)

	-- 右划
	self.Panel_right:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isOver == true or self.isStop == true then
			return
		end

		if setLoadingBar("right") == false then
			local speed = self:getData(2)
			if speed > 4 then
				print("冷却中重复点击 速度降低")
				speed = speed - 1
				self:setData(nil, speed, nil)
				self:print("HIR由于你的指挥不当，船队速度没有得到提升，反而还下降了。")
			else
				self:print("HIR由于你的指挥不当，船队速度没有得到提升。")
			end
		else
			self:print("CYN船队在你的指挥下一齐往右划动，溅起道道水花。")
			self.rightAlready = true
			if self.leftAlready == true then
				local speed = self:getData(2)
				local morale = self:getData(3)
				local str = "HIC你指挥船队左右向后划动，你们船队的速度提升了！"

				speed = speed + 1
				if speed > 10 then
					speed = 10
					str = "HIC你指挥船队左右向后划动，你们船队飞快地驰骋在水面上！"
				end

				morale = morale + 1
				if morale > 20 then
					morale = 20
				end

				self:setData(nil, speed, morale)
				self.rightAlready = false
				self.leftAlready = false
				self:print(str)
			end
		end
	end)
end

function DragonBoatLayer:setBack()
	self.Panel_category.Button_return:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
		--退出赛龙舟，可以江湖偶遇切磋
		local role = User:getRole()
		role:setFlag("PVP活动状态","空闲中")

		PopupLayerController:hideLayer("DragonBoatLayer", function(layer)
			self:hide()	
		end, 0)
	end)

	self.Panel_over.Button_return:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		PopupLayerController:hideLayer("DragonBoatLayer", function(layer)
			self:hide()	
		end, 0)
	end)
end







------------------------------- 输出相关 -------------------------------
-- 初始化输出框
function DragonBoatLayer:initRichText()
	local x, y = self.Image_print_1.Text_desc:getPosition()
	local size = self.Image_print_1.Text_desc:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_print_1.Text_desc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_print_1.Text_desc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function DragonBoatLayer:print(str, verticalSpace)
	if str == "" then
		return
	end
	str = self:changeText(str)

	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 40)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

-- 替换文本
function DragonBoatLayer:changeText(str)
	if str == nil or self.targetTeam == nil then
		return ""
	end

	local text = str

	text = string.gsub(text, "$M", self.targetTeam.name)
	text = string.gsub(text, "$N", self.targetTeam.npcName)

	return text
end

Helper:classDefNodeGetInstance(DragonBoatLayer)

return DragonBoatLayer00000000000