-- 奈何桥界面
local HellBridgeLayer = class("HellBridgeLayer", LayerEx)

local HellBridgeNpc = require("script.others.livediebook")["奈何桥"]
local HellBridgeSelect = require("script.others.livediebook")["奈何桥选择"]
local HellBridgeResult = require("script.others.livediebook")["奈何桥结果"]
local Record = require("app.models.Record.Record")

function HellBridgeLayer:create()
	local p = HellBridgeLayer:new()
	p:init()
	return p
end

function HellBridgeLayer:init()
	self._UI = require("Layer/PopUI/HellBridgeUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setShowAndHideAnimType("ROLL")

	self.selectArray = {}
	self.resultArray = {}
	for k,v in pairs(HellBridgeSelect) do
		self.selectArray[v.eventId] = v
	end

	for k,v in pairs(HellBridgeResult) do
		self.resultArray[v.resultId] = v
	end

	self:setButton()

	self.Panel_play.Text_surplusCount:setString("『剩余时间』" .. "150秒")
end

function HellBridgeLayer:showLayer(func, map)
	if func == nil then
		func = function()
		end
	end
	self.func = func
	if self.RichText_print_text then
		self.RichText_print_text:removeFromParent()
		self.RichText_print_text = nil
	end
	-- 输出框 3个界面都有
	self.RichText_print_start = nil
	self.RichText_print_text = nil
	self.RichText_print_over = nil

	self.needShowFunc = function()
	end

	if map then
		self._map = map
		self._mapLayer = map._mapLayer
	end

	self:showStart()
	self:show()
end

-- 开始界面
function HellBridgeLayer:showStart()
	self.Panel_start:setVisible(true)
	self.Panel_play:setVisible(false)
	self.Panel_over:setVisible(false)
	self.RichText_print_start = self:initRichText(self.RichText_print_start, self.Panel_start.Text_print)
	self:print("呵呵，这位朋友，老身有事需要离开一小会，你可否暂代我守一守这奈何桥啊？", self.RichText_print_start)
end

-- 进行中界面
function HellBridgeLayer:showPlay()
	self.Panel_start:setVisible(false)
	self.Panel_play:setVisible(true)
	self.Panel_over:setVisible(false)

	self.RichText_print_text = self:initRichText(self.RichText_print_text, self.Panel_play.Text_print)

	self:initData()
end

-- 结算界面
function HellBridgeLayer:showOver()
	self.Panel_start:setVisible(false)
	self.Panel_play:setVisible(false)
	self.Panel_over:setVisible(true)
	self.RichText_print_over = self:initRichText(self.RichText_print_over, self.Panel_over.Text_print)
	self:print("嗯，看来老身不在的这段时间内，你做的不错啊，这是给你的奖励，拿去吧。", self.RichText_print_over)

	local points =
	{
		[1] = 96, 	--37,
		[2] = 115,	--42,
		[3] = 138,	--47,
		[4] = 163,	--53,
		[5] = 192,	--59,
		[6] = 223,	--64,
		[7] = 256,	--71,
		[8] = 293,	--77,
		[9] = 332,	--83,
		[10] = 374,	--90,
		[11] = 419,	--97,
		[12] = 467,	--104,
		[13] = 517,	--111,
		[14] = 571,	--118,
		[15] = 628,	--125,
		[16] = 687,	--133,
		[17] = 749,	--141,
		[18] = 814,	--149,
	}

	self.Panel_over.Text_count:setString("已完成			" .. self.totalCount .. "人")
	local role = User:getRole()
	-- if role:getDayFlag("奈何桥每日奖励") < 9000 then
	-- 	self.Panel_over.Text_mingbi:setString("获得碎银		" .. 3000)
	-- 	role:addAttr("money", 3000)
	-- 	role:setDayFlag("奈何桥每日奖励", role:getDayFlag("奈何桥每日奖励") + 3000)
	-- else
	-- 	self.Panel_over.Text_mingbi:setString("今日奖励已达上限")
	-- end

	if role:getFlag("奈何桥奖励") < 30000 then
		self.Panel_over.Text_mingbi:setString("获得碎银		" .. 10000)
		role:addAttr("money", 10000)
		role:setFlag("奈何桥奖励", role:getFlag("奈何桥奖励") + 10000)
	else
		self.Panel_over.Text_mingbi:setString("本周奖励已达上限")
	end

	local point = 0
	for k,v in pairs(points) do
		if self.totalCount >= k then
			if point < v then
				point = v
			end
		end
	end


	--抓鬼的时候判断是否带面具
	local mianju = role:getPortraitId()
	local effectData = 1
	local need = 0
	if mianju == "mianju1069" or mianju == "mianju1070" or mianju == "mianju1151" then
		effectData = 1.25
		need = 1
	end
	if  GetTime() > Helper:getTimeStampWithStringDate("20210820", 0)  and GetTime() < Helper:getTimeStampWithStringDate("20210903", 0) then 
		effectData=effectData+0.25
	end
	point = point *effectData
	HttpManagerEx:addDeadCurrency(3, point,need, function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.number > 0 then
						PopText("冥币 + " .. data.number .. "亿")
					end
					local role = User:getRole()
					-- role:setDayFlag("奈何桥玩法", role:getDayFlag("奈何桥玩法") + 1)

					role:setFlag("奈何桥玩法", role:getFlag("奈何桥玩法") + 1)
					role:setFlag("奈何桥结束时间",GetTime())

					Record:addRecordCount("naiheqiao", "naiheqiao", point)
				else
					PopText(errmsg)
				end
			else
				PopText(errmsg)
			end
		end, IS_SHOW_WAITING)
end

-- 初始化数据
function HellBridgeLayer:initData()
	self.events =
	{
		["坦诚相告"] 	= "",
		["好言相劝"] 	= "",
		["武力逼迫"] 	= "",
		["花言巧语"] 	= "",
		["出言威逼"] 	= "",
		["以利诱之"] 	= "",
		["追上去"]	= "",
		["不追"]    	= "",
	}

	-- 开始时间
	self.startTime = nil

	-- 完成人数
	self.totalCount = 0

	-- 剩余时间
	self.surplusTime = 150

	-- 已经随机过的人
	self.alreadyRand = {}

	-- 动作中的按钮数量
	self.isAction = 0

	self:initNpc()

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1/30)
end

-- 创建Npc
function HellBridgeLayer:createNpc()
	local Role = require("app.models.role.Role")
	local npc = self:randNpc()

	while self.alreadyRand[npc.name] == 1 do
		npc = self:randNpc()
	end
	self.alreadyRand[npc.name] = 1

	--Helper:print_lua_table_ChunWai(self.npcPerfectEevents)
	return npc
end

-- 随机NPC
function HellBridgeLayer:randNpc()
	local npc = nil
	local count = 0
	for k,v in pairs(HellBridgeNpc) do
		count = count + 1
	end

	print("HellBridgeNpc count = " .. count)

	-- 随机NPC
	local index = 1
	local randNum = math.random(1, count)
	for k,v in pairs(HellBridgeNpc) do
		if randNum == index then
			if self._map then
				local mapRolelist = self._map:getRoles()
				for npcId,mapNpc in pairs(mapRolelist) do
					if mapNpc.baseId == v.level then
						npc = mapNpc
						break
					end
				end
			end

			local role = Role:create()
			if npc == nil then
				npc = role
			else
				npc = Helper:tableCover(role,npc)
			end
			setmetatable(npc, getmetatable(role))
				
			npc.sex = v.sex
			npc.age = v.age
			self.npcLooksDesc = v.looks
			self.npcDesc = v.desc
			self.PerfectEeventsText = v.talkText
			if v.name then
				npc.name = v.name
			else
				npc.name = Helper:getRandomName(npc.sex)
			end

			local CHTab =
			{
				honest = "坦诚相告",
				blandishments = "花言巧语",
				advice = "好言相劝",
				intimidate = "出言威逼",
				force = "武力逼迫",
				inducement = "以利诱之",
			}
			for key,ch in pairs(CHTab) do
				self.npcPerfectEevents[ch] = v[key]
			end
			break
		end
		index = index + 1
	end

	return npc
end

-- 初始化NPC
function HellBridgeLayer:initNpc()
	-- NPC描述
	self.npcDesc = ""

	-- NPC容貌描述
	self.npcLooksDesc = ""

	-- 完美事件对话文本
	self.PerfectEeventsText = ""

	-- npc完美事件
	self.npcPerfectEevents =
	{
		["坦诚相告"] 	= 0,
		["好言相劝"] 	= 0,
		["武力逼迫"] 	= 0,
		["花言巧语"] 	= 0,
		["出言威逼"] 	= 0,
		["以利诱之"] 	= 0,
		["追上去"]	= 0,
		["不追"]    	= 0,
	}

	self.npc = self:createNpc()
	if self.npc == nil then
		print("npc == nil")
		return
	end

	-- 刷新人数
	self:updateTotalCount()

	-- 清空按键属性
	self:clearBtnEvent()
	self:btnUnVisible()

	self.Panel_play.Text_npcDesc:setOpacity(0)
	self.Panel_play.Text_npcDesc:setVisible(false)

	self.Panel_play.Text_npcName:setOpacity(0)
	self.Panel_play.Text_npcName:setVisible(false)

	local cl = "WHT"
	local sex = self.npc:getHeOrHer()
	local npcDesc = "CYN"
	npcDesc = npcDesc .. sex .. "看起来约" .. self.npc:getAgeDsc() .. "。"
	npcDesc = npcDesc .. sex .. "生得" .. self.npcLooksDesc .. "。\n"
	npcDesc = npcDesc .. self.npcDesc
	self.Panel_play.Text_npcDesc:setString(npcDesc)

	self.Panel_play.Text_npcName:setString(self.npc.name)

	-- 渐现动画
	local animDuration = 3

	self.Panel_play.Text_npcDesc:runAction(YXEaseAction:create( cc.Sequence:create(
		cc.DelayTime:create(2),
		cc.CallFunc:create(function()
			self.Panel_play.Text_npcDesc:setOpacity(0)
			self.Panel_play.Text_npcDesc:setVisible(true)

			self.Panel_play.Text_npcName:setOpacity(0)
			self.Panel_play.Text_npcName:setVisible(true)

			self.Panel_play.Text_npcName:runAction(YXEaseAction:create( cc.Sequence:create(
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ))

			self:print("HIC只见远处走来一人。三生石上缓缓浮现出他的名字和生平。", self.RichText_print_text, 36)
		end),
		cc.DelayTime:create(1),
		cc.FadeIn:create(animDuration),
		cc.CallFunc:create(function()
			self.events =
			{
				["坦诚相告"] 	= "xuanze1",
				["好言相劝"] 	= "xuanze3",
				["武力逼迫"] 	= "xuanze5",
				["花言巧语"] 	= "xuanze2",
				["出言威逼"] 	= "xuanze4",
				["以利诱之"] 	= "xuanze6",
				["追上去"]	= "",
				["不追"]    	= "",
			}
			if self.startTime == nil then
				self.startTime = GetTime()
			end
			self:refreshButtonEnabled()
			self:showBtn()
		end)
	),  Sine_EaseOut ))
end

-- 初始化输出框
function HellBridgeLayer:initRichText(richText, parentNode)
	local x, y = parentNode:getPosition()
	local size = parentNode:getContentSize()

	if richText then
		richText:removeFromParent()
		richText = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	parentNode:getParent():addChild(richTextScroll)
   	local point = cc.p(parentNode:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	richText = richTextScroll

   	richText:setBounceEnabled(false)
   	return richText
end

function HellBridgeLayer:print(str, richText, fontSize, verticalSpace)
	if str == "" or richText == nil then
		return
	end

	if fontSize == nil then
		fontSize = 48
	end


	local textColor = cc.c3b(159,159,159)
	local textHeight = richText:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		if richText == self.RichText_print_text then
			richText = self:initRichText(richText, self.Panel_play.Text_print)
			self.RichText_print_text = richText
		end
	end

	richText:pushBackText(str, textColor, 255, Resource:getFontPath("default"), fontSize)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		richText:pushBackNewLine(verticalSpace)
	else
		richText:pushBackNewLine()
	end
end

-- 所有按钮不可见
function HellBridgeLayer:btnUnVisible()
	self.Panel_play.Button_chase:setVisible(false)
	self.Panel_play.Button_unchase:setVisible(false)
	self.Panel_play.Button_honest:setVisible(false)
	self.Panel_play.Button_advice:setVisible(false)
	self.Panel_play.Button_force:setVisible(false)
	self.Panel_play.Button_blandishments:setVisible(false)
	self.Panel_play.Button_intimidate:setVisible(false)
	self.Panel_play.Button_inducement:setVisible(false)
end

function HellBridgeLayer:refreshButtonEnabled()
	self:btnUnVisible()
	if self.isOver then
		return
	end

	if self.events["追上去"] ~= "" and self.events["不追"] ~= "" then
		self.Panel_play.Button_chase:setVisible(true)
		self.Panel_play.Button_unchase:setVisible(true)
	else
		self.Panel_play.Button_honest:setVisible(true)
		self.Panel_play.Button_advice:setVisible(true)
		self.Panel_play.Button_force:setVisible(true)
		self.Panel_play.Button_blandishments:setVisible(true)
		self.Panel_play.Button_intimidate:setVisible(true)
		self.Panel_play.Button_inducement:setVisible(true)

		self.Panel_play.Button_honest:setEnabled(self.events["坦诚相告"] ~= "")
		self.Panel_play.Button_advice:setEnabled(self.events["好言相劝"] ~= "")
		self.Panel_play.Button_force:setEnabled(self.events["武力逼迫"] ~= "")
		self.Panel_play.Button_blandishments:setEnabled(self.events["花言巧语"] ~= "")
		self.Panel_play.Button_intimidate:setEnabled(self.events["出言威逼"] ~= "")
		self.Panel_play.Button_inducement:setEnabled(self.events["以利诱之"] ~= "")
	end
end

-- 处理选择事件
function HellBridgeLayer:doSelectEvent(selectEvent)
	if self.npc == nil then
		return
	end

	if selectEvent == nil then
		print("selectEvent == nil")
		return
	end

	if self.isOver then
		return
	end

	print("==================================")
	print("doSelectEvent(selectEvent)")
	--Helper:print_lua_table_ChunWai(selectEvent)
	print("==================================")

	-- 输出文本
	local str = selectEvent.text
	if str then
		str = string.gsub(str, "$x", self.npc.name)

		local strs = string.split(str, ";")
		for k,v in pairs(strs) do
			self:print(v, self.RichText_print_text, 36)
		end
	end

	-- 完美事件
	if self.npcPerfectEevents[selectEvent.name] == 1 then
		-- 清空按钮触发的事件
		self:clearBtnEvent()
		self:clearPerfectEevents()

		-- 输出文本
		local str = self.PerfectEeventsText
		if str then
			str = string.gsub(str, "$x", self.npc.name)
			local strs = string.split(str, ";")
			for k,v in pairs(strs) do
				self:print(v, self.RichText_print_text, 36)
			end
		end

		self:delayFunc(1, function()
			self.totalCount = self.totalCount + 1
			self:initNpc()
		end)

		return
	end

	-- 选了一次之后也要清空 完美事件
	self:clearPerfectEevents()


	-- 随机结果
	local results = string.split(selectEvent.result, ";")
	local weight = selectEvent.weight
	if weight == nil or weight == 1 then
		weight = "1"
	end
	local result = results[Helper:RandomIndexByPercentWithString(weight)]
	self:doResult(self.resultArray[result])
end

-- 处理结果
function HellBridgeLayer:doResult(result)
	if self.npc == nil then
		return
	end

	if result == nil then
		print("result == nil")
		return
	end

	print("==================================")
	print("doResul(result)")
	--Helper:print_lua_table_ChunWai(result)
	print("==================================")

	-- 清空按钮触发的事件
	self:clearBtnEvent()

	if self.isOver then
		return
	end

	-- 输出文本
	local str = result.text
	if str then
		str = string.gsub(str, "$x", self.npc.name)

		local strs = string.split(str, ";")
		for k,v in pairs(strs) do
			self:print(v, self.RichText_print_text, 36)
		end
	end

	-- 判断标记
	if result.fight == 1 then
		self:delayFunc(1, function()
			self:fightToNpc()
		end)
		return
	elseif result.finish == 0 then
		self:delayFunc(1, function()
			self:initNpc()
		end)
		return
	elseif result.finish == 1 then
		self:delayFunc(1, function()
			self.totalCount = self.totalCount + 1
			self:initNpc()
		end)
		return
	end

	-- 随机结果
	local results = string.split(result.result, ";")
	-- 判断是不是选择事件

	for k,v in pairs(self.selectArray) do
		if results[1] == v.eventId then
			print("触发事件")
			-- 只要出现一个选择事件，其余一定是选择事件
			self:updateState(results)
			self.needShowFunc = function()
				self:refreshButtonEnabled()
				self:showBtn()
				self.needShowFunc = function()
				end
			end
			return
		end
	end

	local weight = result.weight
	if weight == nil or weight == 1 then
		weight = "1"
	end
	local NextResult = results[Helper:RandomIndexByPercentWithString(weight)]
	self:doResult(self.resultArray[NextResult])
end

-- 更换状态
function HellBridgeLayer:updateState(selectEvents)
	for k,v in pairs(selectEvents) do
		if self.selectArray[v] then
			self.events[self.selectArray[v].name] = v
		end
	end
end

-- 清空按钮状态
function HellBridgeLayer:clearBtnEvent()
	for k,v in pairs(self.events) do
		self.events[k] = ""
	end
end

-- 清空完美事件
function HellBridgeLayer:clearPerfectEevents()
	for k,v in pairs(self.npcPerfectEevents) do
		v = 0
	end
end

function HellBridgeLayer:setButton()
	self.Panel_start.Button_accept:releaseFunc(function()
		self:showPlay()
	end)

	self.Panel_start.Button_leave:releaseFunc(function()
		PopupLayerController:hideLayer("HellBridgeLayer", function(layer)
			self:hide()
		end, 0)
	end)

	self.Panel_over.Button_accept:releaseFunc(function()
		self.func()
		PopupLayerController:hideLayer("HellBridgeLayer", function(layer)
			self:hide()
		end, 0)
	end)

	-- 坦诚相告 honest
	self.Panel_play.Button_honest:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["坦诚相告"]])
	end)

	-- 好言相劝 advice
	self.Panel_play.Button_advice:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["好言相劝"]])
	end)

	-- 武力逼迫 force
	self.Panel_play.Button_force:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["武力逼迫"]])
	end)

	-- 花言巧语 blandishments
	self.Panel_play.Button_blandishments:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["花言巧语"]])
	end)

	-- 出言威逼 intimidate
	self.Panel_play.Button_intimidate:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["出言威逼"]])
	end)

	-- 以利诱之 inducement
	self.Panel_play.Button_inducement:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["以利诱之"]])
	end)

	-- 追
	self.Panel_play.Button_chase:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["追上去"]])
	end)

	-- 不追
	self.Panel_play.Button_unchase:releaseFunc(function()
		if self.isAction ~= 0 then
			return
		end
		self:hideBtn()
		self:doSelectEvent(self.selectArray[self.events["不追"]])
	end)
end

-- 战斗
function HellBridgeLayer:fightToNpc()
	-- 战胜
	local func1 = function()
		self:doResult(self.resultArray["jieguo6"])
		if self.isAction == 0 then
			self.needShowFunc()
		end
	end

	-- 战败
	local func2 = function()
		self:doResult(self.resultArray["jieguo7"])
		if self.isAction == 0 then
			self.needShowFunc()
		end
	end
	local FightLayer = require("app.views.layer.FightLayer.FightLayer")
	local player = User:getRole()
	local role = self.npc
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

   --      	if self._mapLayer then
			-- 	-- 暂停地图场景渲染
			-- 	self._mapLayer:pauseSelfAndChildren()
			-- 	self._mapLayer:setVisible(false)
			-- end

            PopText("战斗开始!!!")
   --          -- 战斗开始的时候设置下玩家
   --          local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
   --          fight:setPlayer(role)

            -- 显示开场白
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
		            end)
	        		func1()
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
		            end)
	        		func2()
        		end)
            end
    --         fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
    --     		Helper:getDef(callback, EMPTY_FUNC)(winTeamId)
    --     		if self._mapLayer then
				-- 	self._mapLayer:resumeSelfAndChildren()
				-- 	self._mapLayer:setVisible(true)
				-- end

    --             fightLayer:hide(function()
    --                 fightLayer:destroyInstance()
    --                 cleanTable(fightLayer)
    --             end)
    --         end)
        elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
            -- PopText([[你大喝一声：“三十六计，走为上计”]])
            -- 属性结算 add by TangJian 2016/11/02 19:37:54
            do
                player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
                --role:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(2, 1), fightType)
            end

            -- 隐藏按钮区域
            fightLayer:callUIMemFunc("setButtonAreaVisble", false)
            -- 显示战斗结束文本区域
            fightLayer:callUIMemFunc("showFightEndTextArea")

            -- 设置战斗结束文本区域的文本
            fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
            fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你大喝一声：“三十六计，走为上计")

            fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
	            		-- player:calcActiveZhaoUseTimes(fight:getRoleByTeamIdAndInTeamId(1, 1)) -- 计算主动招式熟练度
	            if self._mapLayer then
					self._mapLayer:resumeSelfAndChildren()
					self._mapLayer:setVisible(true)
				end
				func2()

                fightLayer:hide(function()
                    fightLayer:destroyInstance()
                    cleanTable(fightLayer)
                end)
            end)
        end
    end,nil,nil,nil,function ()
		func1()
	end)
end

function HellBridgeLayer:update()
	local currTime = GetTime()

	if self.startTime then
			self.surplusTime = self.surplusTime - (currTime - self.startTime)
			self.startTime = GetTime()

			if self.surplusTime <= 0 then
				self.surplusTime = 0
				self:timeOver()
			end
			self.Panel_play.Text_surplusCount:setString("『剩余时间』" .. math.floor(self.surplusTime) .. "秒")
	end
end

-- 时间结束
function HellBridgeLayer:timeOver()
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	if self.isOver then
		return
	end

	self.isOver = true
	self:clearBtnEvent()
	self:delayFunc(1, function()
		self:showOver()
	end)
end

function HellBridgeLayer:updateTotalCount()
	if self.totalCount == 0 then
		self.Panel_play.Text_totalCount:setString("『已完成』")
	elseif self.totalCount > 0 then
		self.Panel_play.Text_totalCount:setString("『已完成』" .. self.totalCount .. "人")
	end

end

-- 显示按钮动画
function HellBridgeLayer:showButtonAnimation(button, statrPos, endPos, InOut)
	if self.isAction then
		self.isAction = self.isAction + 1
	end
	local animDuration = 0.25
	button:setPosition(statrPos)
	if InOut == 1 then
		button:setOpacity(0)
		button:runAction(YXEaseAction:create( cc.Sequence:create(
			cc.CallFunc:create(function()
			end),
			cc.Spawn:create(
				cc.MoveTo:create(animDuration, endPos ) ,
				cc.FadeIn:create(animDuration)
			),
			cc.CallFunc:create(function()
				if self.isAction then
					self.isAction = self.isAction - 1
					if self.isAction < 0 then
						self.isAction = 0
					end
				end
			end)
		),  Sine_EaseOut ))
	elseif InOut == 2 then
		button:setOpacity(255)
		button:runAction(YXEaseAction:create( cc.Sequence:create(
			cc.CallFunc:create(function()
			end),
			cc.Spawn:create(
				cc.MoveTo:create(animDuration, endPos ) ,
				cc.FadeOut:create(animDuration)
			),
			cc.CallFunc:create(function()
				button:setVisible(false)
				if self.isAction then
					self.isAction = self.isAction - 1
					if self.isAction < 0 then
						self.isAction = 0
					end
					if self.isAction == 0 then
						self.needShowFunc()
					end
				end
			end)
		),  Sine_EaseOut ))
	end

end

-- 显示按钮
function HellBridgeLayer:showBtn()
	-- 坦诚相告 honest
	self:showButtonAnimation(self.Panel_play.Button_honest, cc.p(190, 500), cc.p(340, 500), 1)

	-- 好言相劝 advice
	self:showButtonAnimation(self.Panel_play.Button_advice, cc.p(190, 350), cc.p(340, 350), 1)

	-- 武力逼迫 force
	self:showButtonAnimation(self.Panel_play.Button_force, cc.p(190, 200), cc.p(340, 200), 1)

	-- 花言巧语 blandishments
	self:showButtonAnimation(self.Panel_play.Button_blandishments, cc.p(890, 500), cc.p(740, 500), 1)

	-- 出言威逼 intimidate
	self:showButtonAnimation(self.Panel_play.Button_intimidate, cc.p(890, 350), cc.p(740, 350), 1)

	-- 以利诱之 inducement
	self:showButtonAnimation(self.Panel_play.Button_inducement, cc.p(890, 200), cc.p(740, 200), 1)

	-- 追
	self:showButtonAnimation(self.Panel_play.Button_chase, cc.p(540, 375), cc.p(540, 425), 1)

	-- 不追
	self:showButtonAnimation(self.Panel_play.Button_unchase, cc.p(540, 325), cc.p(540, 275), 1)
end

-- 隐藏按钮
function HellBridgeLayer:hideBtn()
	-- 坦诚相告 honest
	self:showButtonAnimation(self.Panel_play.Button_honest, cc.p(340, 500), cc.p(190, 500), 2)

	-- 好言相劝 advice
	self:showButtonAnimation(self.Panel_play.Button_advice, cc.p(340, 350), cc.p(190, 350), 2)

	-- 武力逼迫 force
	self:showButtonAnimation(self.Panel_play.Button_force, cc.p(340, 200), cc.p(190, 200), 2)

	-- 花言巧语 blandishments
	self:showButtonAnimation(self.Panel_play.Button_blandishments, cc.p(740, 500), cc.p(890, 500), 2)

	-- 出言威逼 intimidate
	self:showButtonAnimation(self.Panel_play.Button_intimidate, cc.p(740, 350), cc.p(890, 350), 2)

	-- 以利诱之 inducement
	self:showButtonAnimation(self.Panel_play.Button_inducement, cc.p(740, 200), cc.p(890, 200), 2)

	-- 追
	self:showButtonAnimation(self.Panel_play.Button_chase, cc.p(540, 425), cc.p(540, 375), 2)

	-- 不追
	self:showButtonAnimation(self.Panel_play.Button_unchase, cc.p(540, 275), cc.p(540, 325), 2)
end

Helper:classDefNodeGetInstance(HellBridgeLayer)

return HellBridgeLayer000000