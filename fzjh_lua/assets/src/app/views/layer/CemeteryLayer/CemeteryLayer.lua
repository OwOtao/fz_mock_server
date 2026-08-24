-- 守墓
local CemeteryLayer = class("CemeteryLayer", LayerEx)

-- 火势文本
local FireLevelDesc =
{
	[0] = "HIR火焰已然熄灭，空留些许惆怅。",
	[1] = "HIR火堆中只剩零星火苗，几欲熄灭！",
	[2] = "RED火焰十分微弱，应该多加些黄纸才是。",
	[3] = "YEL火焰有些微弱，似乎应该加些黄纸了。",
	[4] = "HIY火焰明亮闪耀，没有一丝阴霾。",
	[5] = "HIC火焰散发着光热，暖人心身，在这清明时节，倍显温暖。",
	[6] = "HIC火焰燃烧得十分旺盛，屡有青烟升起，随风飘荡。",
	[7] = "HIW火焰熊熊燃烧，袅袅青烟盘旋升起，飘往远方。",
	[8] = "HIW炽烈的火焰，带起阵阵青烟，飘往天空。",
}

-- 刮风文本
local windDesc =
{
	[1] =
	{
		[1] = "RED一阵微风吹过，火焰似乎小了一些。",
		[2] = "RED一阵微风袭来，火焰似乎小了一些。",
	},
	[2] =
	{
		[1] = "RED一阵轻风吹过，火焰似乎小了一些。",
		[2] = "RED一阵轻风袭来，火焰似乎小了一些。",
	},
	[3] =
	{
		[1] = "RED一阵疾风吹过，火焰似乎小了一些。",
		[2] = "RED一阵疾风袭来，火焰似乎小了一些。",
	},
}

-- 异常状态文本
local debuffDesc =
{
	-- 堵塞 1 2 3对应风的层级
	[1] =
	{
		[1] = "RED一阵微风吹过，火堆突然小了不少，里面似乎被堵住了。",
		[2] = "RED一阵轻风袭来，火堆突然小了不少，里面似乎被堵住了。",
		[3] = "RED一阵疾风袭来，火堆突然小了不少，里面似乎被堵住了。",
	},
	-- 刮风 1 2 3对应风的层级
	[2] =
	{
		[1] = "",
		[2] = "RED一阵轻风吹过，火堆被吹得火苗乱窜，宛如舞动的火蛇。",
		[3] = "RED一阵疾风吹过，火堆被吹得火苗乱窜，宛如舞动的火蛇。",
	},
	-- 潮湿 1 2 3对应风的层级
	[3] =
	{
		[1] = "",
		[2] = "",
		[3] = "RED一阵疾风袭来，雨水亦被吹入了火堆，潮湿的火堆让火苗小了不少。;RED一阵疾风吹过，雨水亦被吹入了火堆，潮湿的火堆让火苗小了不少。",
	},
}

-- 风层级描述
local windLevelDesc =
{
	[1] = "HIC天空中下起了细雨，雨纤如星芒,如缕缕银丝，看来接下来不会那么轻松了。",
	[2] = "HIC雨越下越大，周遭聚起淡淡雨雾，你仿佛置身于仙境，但这对于守墓来说，无疑是提升了难度。",
	[3] = "HIC雨愈发大了，如帘幕一般，朦胧了你的双眼，接下来的守墓将会更加困难了。",
}

-- 奖励文本
local rewardDesc =
{
	[1] = "RAN火苗微动，青烟袅袅，寄托着人们的思念，令人动容。",
	[2] = "RAN微风带起阵阵轻烟，飘向远方，直至消散，就如同人的思念一般，让人感伤不已。",
	[3] = "RAN一片相思一片情，火光映照在墓碑之上，似乎在吐露着对亡人的思念，这让你感慨万千。",
	[4] = "RAN相携蹒跚一二影，香蜡冷酒话情深，看着往来祭拜的人们，你的心中油然生出些许惆怅。",
	[5] = "RAN逝者如斯夫，生者当怀念，你隔着火光亦能感到人们对亡人的思念，也被这哀伤的情绪所感染。",
	[6] = "RAN冰凉冰壶寒世界，能不思卿愁默然。在这清明时分，不禁让人缅怀亲人，你静坐于墓前，深有体会。",
}

function CemeteryLayer:create()
	local p = CemeteryLayer:new()
	p:init()
	return p
end

function CemeteryLayer:init()
	self._UI = require("Layer/CemeteryUI/CemeteryUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setShowAndHideAnimType("ROLL")

	self:initRichText()
	self:setButton()
end

-- 初始化数据
function CemeteryLayer:initData()
	local role = User:getRole()

	-- 金元宝
	local num = role:getItemCount("qingminghuodong2")
	if num > 20 then
		num = 20
	end
	self.goldNum = num
	role:addItemCount("qingminghuodong2", -num)
	self.Panel_start.Text_goldNum:setString("可用" .. self.goldNum)


	-- 纸人
	num = role:getItemCount("qingminghuodong3")
	if num > 5 then
		num = 5
	end
	self.paperManNum = num
	role:addItemCount("qingminghuodong3", -num)
	self.Panel_start.Text_paperManNum:setString("可用" .. self.paperManNum)

	-- 黄纸
	self.paperNum = 99
	self.Panel_start.Text_paperNum:setString("可用" .. self.paperNum)

	-- 火堆等级
	self.fireLevel = 8

	-- 风层级
	self.windLevel = 0

	-- 挡风异常状态 0 无 1 有
	-- 拨弄异常状态 0 无 1 有
	-- 去潮异常状态 0 无 1 有
	self.debuff =
	{
		[1] = 0,
		[2] = 0,
		[3] = 0,
	}

	-- 火堆能量条
	self.fireVal = 100

	-- 开始时间
	self.startTime = GetTime()

	-- 更新时间
	self.updateTime = GetTime()

	-- 刮风间隔
	self.windIntervalTime = 0

	-- 上次刮风时间
	self.windTime = 0

	-- 上次获得奖励时间
	self.rewardTime = GetTime()

	-- 本次获得的潜能
	self.totalPot = 0

	-- 游戏是否结束
	self.isOver = false

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1/30)
end

function CemeteryLayer:showLayer(func)
	if func == nil then
		func = function()
		end
	end
	self.func = func
	self.Panel_start.Button_wind:setVisible(false)
	self.Panel_start.Button_put:setVisible(false)
	self.Panel_start.Button_damp:setVisible(false)
	self.Panel_start.Button_paper:setVisible(false)
	self.Panel_start.Button_gold:setVisible(false)
	self.Panel_start.Button_paperman:setVisible(false)
	self:show()
end

-- 初始化输出框
function CemeteryLayer:initRichText()
	local x, y = self.Panel_start.Text_desc_1:getPosition()
	local size = self.Panel_start.Text_desc_1:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_start.Text_desc_1:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_start.Text_desc_1:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function CemeteryLayer:print(str, verticalSpace)
	if str == "" then
		return
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 36)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

-- 开始游戏
function CemeteryLayer:start()
	self.Panel_start.Button_start:setVisible(false)

	self:showButtonAnimation(self.Panel_start.Button_wind, 		cc.p(190,425.00))
	self:showButtonAnimation(self.Panel_start.Button_put, 		cc.p(540,425.00))
	self:showButtonAnimation(self.Panel_start.Button_damp, 		cc.p(890,425.00))
	self:showButtonAnimation(self.Panel_start.Button_paper, 	cc.p(190,425.00))
	self:showButtonAnimation(self.Panel_start.Button_gold, 		cc.p(540,425.00))
	self:showButtonAnimation(self.Panel_start.Button_paperman, 	cc.p(890,425.00))

	self.Panel_start.Text_paperNum:setVisible(true)
	self.Panel_start.Text_goldNum:setVisible(true)
	self.Panel_start.Text_paperManNum:setVisible(true)

	local desc =
	{
		[1] = "HIG你点燃了一张黄纸放入火堆之中，开始了守墓。",
		[2] = "HIG你将一张黄纸点燃放入火堆之中，望着燃烧的火堆，守墓也开始了。",
	}
	self:print(desc[math.random(1,2)])

	self:initData()

	Audio:playEffect("CemeteryFrie", true)
end

-- 游戏结束
function CemeteryLayer:over()
	-- 结束时将未使用的清明道具 元宝 纸人 添加回背包
	local role	= User:getRole()	
	role:addItemCount("qingminghuodong2", Helper:getDef(self.goldNum,0))
	role:addItemCount("qingminghuodong3", Helper:getDef(self.paperManNum,0))

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	if self.isOver then
		return
	end

	local desc =
	{
		[1] = "CYN清明时节雨纷纷，路上行人欲断魂。你望着往来祭拜亲人先祖的人们和已熄灭的火堆，心中生出些许异样，却又难以言喻。",
		[2] = "CYN火已熄灭，守墓已然结束，风雨散去，只剩淡淡的哀伤和一丝惆怅。",
	}

	self.Panel_over.Text_desc:setString(desc[math.random(1,2)])
	self.Panel_over.Text_time:setString("本次持续时间:" ..  math.floor(GetTime() - self.startTime ))
	self.Panel_over.Text_reward:setString("本次获得潜能:" .. self.totalPot)
	self:delayFunc(1, function()
		Audio:stopAllEffects()
		self.Panel_over:setVisible(true)
	end)

	self.isOver = true
end

-- 显示按钮动画
function CemeteryLayer:showButtonAnimation(button, statrPos)
	local animDuration = 0.25
	button:setVisible(true)
	button:setOpacity(0)
	local endPos = cc.p( button:getPositionX(), button:getPositionY())
	button:setPosition(statrPos)
	button:runAction(YXEaseAction:create( cc.Spawn:create(
		cc.MoveTo:create(animDuration, endPos ) ,
		cc.FadeIn:create(animDuration)
	),  Sine_EaseOut ))
end

function CemeteryLayer:setButton()
	self.Panel_start.Button_start:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:start()
	end)

	-- 黄纸
	self.Panel_start.Button_paper:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.isOver then
			return
		end

		if self.paperNum <= 0 then
			PopText("黄纸已经用完了。")
			return
		end

		self.paperNum = self.paperNum - 1
		self.Panel_start.Text_paperNum:setString("可用" .. self.paperNum)

		local desc =
		{
			[1] = "CYN你将一张黄纸放入火堆之中，火堆燃烧的得更旺了。",
			[2] = "CYN你将黄纸投入火堆，火焰又壮大了一些。",
			[3] = "HIW你将黄纸投入火堆，火焰熊熊燃烧，已是不能再大了。",
		}

		local num = math.random(1,2)

		if self.fireLevel == 8 then
			num = 3
		end

		self.fireLevel = self.fireLevel + 1
		if self.fireLevel > 8 then
			self.fireLevel = 8
			self.fireVal = 100
		end

		self:print(desc[num])
	end)

	-- 金元宝
	self.Panel_start.Button_gold:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.isOver then
			return
		end

		if self.goldNum <= 0 then
			PopText("金元宝已经用完了。")
			return
		end

		self.goldNum = self.goldNum - 1
		self.Panel_start.Text_goldNum:setString("可用" .. self.goldNum)

		local desc =
		{
			[1] = "CYN你将金元宝投入火堆，火焰瞬间吞噬了它，壮大了不少。",
			[2] = "CYN你将金元宝投入火堆之中，火焰燃烧的更加旺盛了。",
			[3] = "HIW你将金元宝投入火堆，火焰熊熊燃烧，已是不能再大了。",
		}

		local num = math.random(1,2)

		if self.fireLevel == 8 then
			num = 3
		end

		self.fireLevel = self.fireLevel + 2
		if self.fireLevel > 8 then
			self.fireLevel = 8
			self.fireVal = 100
		end

		self:print(desc[num])
	end)

	-- 纸人
	self.Panel_start.Button_paperman:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.isOver then
			return
		end

		if self.paperManNum <= 0 then
			PopText("纸人已经用完了。")
			return
		end

		self.paperManNum = self.paperManNum - 1
		self.Panel_start.Text_paperManNum:setString("可用" .. self.paperManNum)

		local desc =
		{
			[1] = "CYN你将纸人投入火堆，顿时火光大盛。",
			[2] = "CYN你将纸人投入火堆之中，火焰燃烧得十分猛烈。",
			[3] = "HIW你将纸人投入火堆，火焰熊熊燃烧，已是不能再大了。",
		}

		local num = math.random(1,2)

		if self.fireLevel == 8 then
			num = 3
		end

		self.fireLevel = self.fireLevel + 3
		if self.fireLevel > 8 then
			self.fireLevel = 8
			self.fireVal = 100
		end

		self:print(desc[num])

	end)

	-- 挡风
	self.Panel_start.Button_wind:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.isOver then
			return
		end

		-- 没有异常时
		if self.debuff[2] == 0 then
			local desc = "RED你用身体遮住了火堆，却没想到火变得更小了。"
			self.fireLevel = self.fireLevel - 1
			self:print(desc)
			return
		end

		self.debuff[2] = 0
		local desc = "HIC你赶忙用身体挡住了大风，火苗不再乱窜，回到了本来的样子。"
		self:print(desc)
	end)

	-- 拨弄
	self.Panel_start.Button_put:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.isOver then
			return
		end

		-- 没有异常时
		if self.debuff[1] == 0 then
			local desc = "RED你用木棍，胡乱拨弄着火堆，没想到让火变得更小了。"
			self.fireLevel = self.fireLevel - 1
			self:print(desc)
			return
		end

		self.debuff[1] = 0
		local desc = "HIC你拿起旁边的木棍，拨弄了几下火堆，火堆又能正常燃烧了。"
		self:print(desc)
	end)

	-- 去潮
	self.Panel_start.Button_damp:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.isOver then
			return
		end

		-- 没有异常时
		if self.debuff[3] == 0 then
			local desc = "RED你拿起小铲，对着火堆铲了数下，火堆居然变小了。"
			self.fireLevel = self.fireLevel - 1
			self:print(desc)
			return
		end

		self.debuff[3] = 0
		local desc = "HIC你拿起小铲，将受潮的部分铲了出去，火堆又恢复了正常。"
		self:print(desc)
	end)

	-- 结束
	self.Panel_over.Button_return:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self.func()
		PopupLayerController:hideLayer("CemeteryLayer", function(layer)
			self:hide()
		end, 0)
	end)
end

-- 刷新
function CemeteryLayer:update()
	self:updateFireVal()
	self:wind()
	self:getReward()
	self:updateText()
end

-- 刷新火堆能量条
function CemeteryLayer:updateFireVal()
	local currTime = GetTime()

	-- 异常状态 每级减少0.2S
	local weakNum =
	{
		[1] = 10,
		[2] = 50,
		[3] = 120,
	}

	local LevelConsume =
	{
		[1] = 5.7,
		[2] = 5.6,
		[3] = 5.5,
		[4] = 5.4,
		[5] = 5.3,
		[6] = 5.2,
		[7] = 5.1,
		[8] = 5,
	}

	if self.fireLevel <= 0 then
		self.fireLevel = 0
		self.fireVal = 0
		self:over()
		self:setValBar()
		return
	end

	local debuff = 0
	if currTime - self.startTime > weakNum[3]  then
		if self.windLevel < 3 then
			self:print(windLevelDesc[3])
			Audio:stopAllEffects()
			Audio:playEffect("CemeteryFrie", true)
			Audio:playEffect("CemeteryBigRain", true)
		end
		self.windLevel = 3
		debuff = 0.6
	elseif currTime - self.startTime > weakNum[2] then
		if self.windLevel < 2 then
			self:print(windLevelDesc[2])
			Audio:stopAllEffects()
			Audio:playEffect("CemeteryFrie", true)
			Audio:playEffect("CemeteryMiddleRain", true)
		end
		self.windLevel = 2
		debuff = 0.4
	elseif currTime - self.startTime > weakNum[1] then
		if self.windLevel < 1 then
			self:print(windLevelDesc[1])
			Audio:stopAllEffects()
			Audio:playEffect("CemeteryFrie", true)
			Audio:playEffect("CemeterySmallRain", true)
		end
		self.windLevel = 1
		debuff = 0.2
	end

	-- 三种异常状态
	for i,v in ipairs(self.debuff) do
		if v == 1 then
			debuff = debuff + 1
		end
	end

	local consume = LevelConsume[self.fireLevel] - debuff
	local val = ( currTime - self.updateTime ) * (100 / consume )

	self.updateTime = GetTime()

	self.fireVal = self.fireVal - val

	while self.fireVal < 0 do
		self.fireVal = self.fireVal + 100
		self.fireLevel = self.fireLevel - 1
	end

	-- 层级0 游戏结束
	if self.fireLevel <= 0 then
		self.fireLevel = 0
		self.fireVal = 0
		self:over()
	end

	self:setValBar()
end

-- 刮风
function CemeteryLayer:wind()
	local currTime = GetTime()
	-- 在小雨时候会吹微风，可造成堵塞状态。
	-- 在中雨时会吹轻风，可造成堵塞、火苗乱窜状态、
	-- 在大雨时，会吹疾风，可造成火苗乱窜，潮湿，堵塞状态
	-- 若三种状态都有时，不会再叠加状态。
	-- 点击按钮，若没有对应状态存在时，会降低火层次数。

	-- 可能出现的异常数量 1 只会堵塞 2 堵塞、火苗乱串 3 堵塞、火苗乱串、潮湿
	if self.windLevel == 0 or self.isOver == true then
		return
	end

	if currTime - self.windTime < self.windIntervalTime then
		return
	end

	Audio:playEffect("CemeteryWind", false)

	self.windTime = GetTime()
	if self.windLevel == 1 then
		self.windIntervalTime = math.random(8000,10000) / 1000
	elseif self.windLevel == 2 then
		self.windIntervalTime = math.random(6000,10000) / 1000
	elseif self.windLevel == 3 then
		self.windIntervalTime = math.random(5000,10000) / 1000
	end

	local array = {}

	-- 不重复添加异常状态
	for i=1,self.windLevel do
		if self.debuff[i] == 0 then
			table.insert(array, i)
		end
	end

	if MapIsEmpty(array) == true then
		local randNum = math.random(1, 2)
		self:print(windDesc[self.windLevel][randNum])
	else
		local randNum = array[math.random(1, #array)]
		print("randNum = " .. randNum)
		self.debuff[randNum] = 1
		local descs = debuffDesc[randNum]
		local strs = string.split(descs[self.windLevel], ";")

		self:print(strs[math.random(1, #strs)])
	end

	self.fireLevel = self.fireLevel - 1

end

function CemeteryLayer:getReward()
	local currTime = GetTime()
	local role = User:getRole()
	local rewardNum =
	{
		[0] = 400,
		[30] = 500,
		[60] = 600,
		[90] = 650,
		[120] = 750,
		[150] = 800,
		[180] = 850,
		[210] = 900,
		[240] = 1000,
		[270] = 1100,
		[300] = 1200,
	}

	local maxReward = role:getDayFlag("守墓每日奖励")
	-- -- 奖励上限 50100
	-- if maxReward >= 50100 then
	-- 	return
	-- end	
	if maxReward >= 30000 then
		return
	end

	if currTime - self.rewardTime > 5 then
		self.rewardTime = GetTime()
		-- 获得奖励
		local role = User:getRole()
		local totalTime = math.floor(currTime - self.startTime)
		local reward = 400

		for i,v in pairs(rewardNum) do
			if totalTime > i and reward < v then
				reward = v
			end
		end

		if maxReward + reward > 30000 then --maxReward + reward > 50100 then
			-- reward = 50100 - maxReward
			reward = 30000 - maxReward
		end

		role:addAttr("pot", reward)
		PopText("潜能 + " .. reward)
		self.totalPot = self.totalPot + reward
		self:print(rewardDesc[math.random(1, #rewardDesc)])

		role:setDayFlag("守墓每日奖励", role:getDayFlag("守墓每日奖励") + reward)
	end
end

-- 设置进度条
function CemeteryLayer:setValBar()
	self.Panel_start.LoadingBar:setPercent(self.fireVal)
end

-- 刷新文本
function CemeteryLayer:updateText()
	local currTime = GetTime()
	self.Panel_start.Text_time:setString("『持续时间』 " .. math.floor(currTime - self.startTime ) .. "秒")

	self.Panel_start.Text_desc:setString(FireLevelDesc[self.fireLevel])

	-- 异常状态
	local str = ""
	if self.debuff[1] == 1 then
		str = str .. " RED堵塞NORRED "
	end
	if self.debuff[2] == 1 then
		str = str .. " RED火苗乱窜NORRED "
	end
	if self.debuff[3] == 1 then
		str = str .. " RED受潮NORRED "
	end

	if str == "" then
		str = " 无"
		self.Panel_start.Text_state_0:setColor(cc.c3b(208, 208, 208))	
	end

	self.Panel_start.Text_state:setString("『火堆状态』  ")
	self.Panel_start.Text_state_0:setString( str)
end

Helper:classDefNodeGetInstance(CemeteryLayer)

return CemeteryLayer0000000000