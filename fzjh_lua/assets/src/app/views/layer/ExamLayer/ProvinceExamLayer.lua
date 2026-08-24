local rightText =
{
	[1] = "HIC$T你思潮翻涌，快速地在记忆中检索，依稀记得是$A",
	[2] = "HIC$T你福至心灵，如有神助，心中无比笃定，答案是$A",
	[3] = "HIC$T你经过一番思索，确定答案就是$A",
	[4] = "HIC$T你略加思索，就确定答案一定是$A",
	[5] = "HIC$T你心中冷笑，如此简单岂能难到我？！答案明摆着是$A",
	[6] = "HIC$T你斟酌了一番，觉得答案应该是$A",

}

local wrongText =
{
	[1] = "HIC$T你思考了一番，但仍不得其法。",
	[2] = "HIC$T你想起了昨日喝的千日醉，一时竟勾起了酒虫，暗骂自己这个时候还胡思乱想。",
	[3] = "HIC$T你绞尽脑汁还是想不出，真是书到用时方恨少啊！",
	[4] = "HIC$T你望着粉刷得雪白的考场墙壁，怔怔出神，心中发问：我是谁，我为什么会在这里？",
	[5] = "HIC$T你觉得手中的毛笔似乎重逾万斤，无从下笔。",
	[6] = "HIC$T你思考了一番，还是毫无头绪。",
	[7] = "HIC$T你咬着笔头，完全不知道如何下笔。",
	[8] = "HIC$T你觉得此题似曾相识，却始终想不起答案是什么。",
	[9] = "HIC$T你把墨磨了又磨，希望能想起什么，却无济于事。",
}

local spiritState =
{
	[1] = "昏昏沉沉中",
	[2] = "浑浑噩噩中",
	[3] = "强打着精神",
	[4] = "抖擞着精神",
	[5] = "念头通达中",
	[6] = "全神贯注中",
}

-- 考官未注视
local examinerLookText =
{
	[1] = "WHT监考官面无表情地在走来走去，他的步子迈得很慢很轻。",
	[2] = "WHT监考官走远了，他的脚步声已经听不到了。",
	[3] = "WHT监考官不紧不慢地向你这边走来。",
	[4] = "RED监考官注视着你，也不知道在想些什么。",
}

-- -- 考官注视
-- local examinerLookText =
-- {
-- 	[1] = "RED监考官注视着你，也不知道在想些什么。",
-- }

-- 被发现作弊
local examinerBeFind =
{
	[1] = "RED监考官似乎发现了什么，他伸出手按住你的卷子，大声喝道：“大胆！竟敢私藏夹带，来人，将此子逐出考场！”"
}

local Exam = require("app.models.Exam.Exam")

local BookLiterary = require("app.models.book.BookLiterary")

-- 省试界面
local ProvinceExamLayer = class("ProvinceExamLayer", LayerEx)

function ProvinceExamLayer:create()
	local p = ProvinceExamLayer:new()
	p:init()
	return p
end

function ProvinceExamLayer:init()
	self._UI = require("Layer/ExamUI/ProvinceExamUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	-- 答案是否正确
	self.isRight = false

	-- 开始思考时间
	self.thinkTime = nil

	-- 考官
	self.examinerTime = nil

	-- 答案
	self.answer = nil

	-- 出自于哪本书
	self.book = nil

	-- 作弊状态 1 蜡烛 2 砚台 3 笔杆
	self.cheatState = 0

	-- 作弊时间
	self.cheatTime = nil

	-- 考官状态 0 1 未注视 2 注视中
	self.examinerState = 0

	-- 考官动作索引
	self.examinerAction = 1

	-- 成绩数据 答对题数 答错题数 总题数
	self.examData = "0;0;0"

	-- 作弊提示数据 提示 蜡烛 砚台 笔杆
	self.cheatData = "0;0;0;0"

	-- 能否答题
	self.isCanAnswer = false

	self:setButton()
	self:initActionRichText()
	--self:initExaminerRichText()
end

function ProvinceExamLayer:getExamData(index)
	return tonumber(string.split(self.examData, ";")[index])
end

--
function ProvinceExamLayer:setExamData(right, wrong, total)
	local examData = string.split(self.examData, ";")
	local rightCount = examData[1]
	local wrongCount = examData[2]
	local totalCount = examData[3]
	if right == 1 then
		rightCount = rightCount + 1
	end

	if wrong == 1 then
		wrongCount = wrongCount + 1
	end

	if total == 1 then
		totalCount = totalCount + 1
	end
	self.examData = rightCount .. ";" .. wrongCount .. ";" .. totalCount
	print("examData = " .. self.examData)
end

function ProvinceExamLayer:getCheatData(index)
	return tonumber(string.split(self.cheatData, ";")[index])
end

function ProvinceExamLayer:setCheatData(prompt, candle, yantai, pen)
	local cheatData = string.split(self.cheatData, ";")

	local promptCount = cheatData[1]
	local candleCount = cheatData[2]
	local yantaiCount = cheatData[3]
	local penCount = cheatData[4]

	promptCount = promptCount + prompt

	candleCount = candleCount + candle

	yantaiCount = yantaiCount + yantai

	penCount = penCount + pen

	self.cheatData = promptCount .. ";" .. candleCount .. ";" .. yantaiCount .. ";" .. penCount
	print("cheatData = " .. self.cheatData)
end

function ProvinceExamLayer:showLayer(isFormal)
	if isFormal == nil then
		isFormal = true
	end

	-- 是否正式考试
	self.isFormal = isFormal
	-- 返回按钮
	self.Panel_category.Button_return:setVisible(not self.isFormal)

	self:addCheatItem()
	self:show()
	self:showPanel("考场的气氛有些凝重。卷子已经发下来了，随时可以开考了。", "开始答题", function()
		Audio:playEffect("xiaoAnNiu")
		self:startExam()
	end)
	-- self:startExam()
end

-- 显示文本按钮界面
function ProvinceExamLayer:showPanel(str, btnName, func)
	if func == nil then
		func = function()
			if self._handle ~= nil then
				self:unschedule(self._handle)
				self._handle = nil
			end

			PopupLayerController:hideLayer("ProvinceExamLayer", function(layer)
				self:hide()
			end, 0)
		end
	end

	self.Panel_ending:setVisible(true)
	self.Panel_kaochang:setVisible(false)

	self.Panel_ending.Text_desc:setString(str)
	self.Panel_ending.Button_1.Text_button_text:setString(btnName)
	self.Panel_ending.Button_1:releaseFunc(function()
		func()
	end)
end

-- 开始考试
function ProvinceExamLayer:startExam()
	self.Panel_ending:setVisible(false)
	self.Panel_kaochang:setVisible(true)

	-- 显示答题界面
	self:changeZone(1)

	-- 开始时间
	self.startTime = GetTime()

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:UpdateTime(ft)
	end,1/10)

	self:UpdateExaminerState()

	self:getQuestion()
end

-- 获取题目
function ProvinceExamLayer:getQuestion()
	-- 答案是否正确
	self.isRight = false

	-- 答题不可用
	self.Panel_kaochang.Panel_btn.Button_answer:setEnabled(false)

	local role = User:getRole()
	local question = Exam:getProvinceExamQuestion()
	local desc = BookLiterary:getStageDesc(role:getLiteraryLv(question.book))

	self.Panel_kaochang.Text_question:setString(question.question)
	self.Panel_kaochang.Text_bookName:setString("——《" .. question.bookName .. "》")
	self.Panel_kaochang.Text_bookDesc:setString("(" .. desc .. ")")

	self.answer = question.answer
	self.book = question.book
	self.isCanAnswer = true

	self:actionPrint("你展开卷子，题目扑入眼帘。")

	self:thinkingGame()

	self.thinkTime = nil
end

-- 思索小游戏
function ProvinceExamLayer:thinkingGame()
	local panel = self.Panel_kaochang

	self.isThinking = true
	-- self.Panel_kaochang.Panel_btn.Button_answer:setEnabled(false)
	-- self.Panel_kaochang.Panel_btn.Button_prompt:setEnabled(false)
	-- self.Panel_kaochang.Panel_btn.Button_cheat:setEnabled(false)

	local bar_w = panel.Panel_bar:getSize().width
	local target_w = panel.Panel_bar.Panel_target:getSize().width
	-- panel.Panel_bar.Panel_target:setPositionX(math.random(target_w / 2, bar_w - target_w))

	panel.Panel_bar.Panel_track:setPositionX(25)
	self:moveBlock(true)

	-- 5秒后自动停止
	-- self.stopThinkingHandle =  self:delayFunc(5, function()
	-- 	self:stopThinking()
	-- end)
end

-- 移动方块
function ProvinceExamLayer:moveBlock(dir)
	local panel = self.Panel_kaochang

	local bar_w = panel.Panel_bar:getSize().width
	local track_w = panel.Panel_bar.Panel_track:getSize().width

	local x1 = bar_w - (track_w / 2)
	local x2 = (track_w / 2)

	panel.Panel_bar.Panel_track:stopAllActions()

	-- 先往右移动 再往左移动
	local animDuration = 6
	local action = cc.Sequence:create(
		cc.MoveTo:create(0, cc.p(x2, panel.Panel_bar.Panel_track:getPositionY() )),
		cc.MoveTo:create(animDuration, cc.p(x1, panel.Panel_bar.Panel_track:getPositionY() ))
	)
	panel.Panel_bar.Panel_track:runAction(cc.RepeatForever:create(action))

	-- 开始思考时间
	self.thinkTime = GetTime()

end

-- 停止移动方块
function ProvinceExamLayer:stopMoveBlock()
	local panel = self.Panel_kaochang

	panel.Panel_bar.Panel_track:stopAllActions()

	-- 判断黄方块是否位于灰方块中
	local target_x = panel.Panel_bar.Panel_target:getPositionX()
	local track_x = panel.Panel_bar.Panel_track:getPositionX()
	local target_w = panel.Panel_bar.Panel_target:getSize().width
	local track_w = panel.Panel_bar.Panel_track:getSize().width

	local barWidth = panel.Panel_bar:getSize().width

	-- 1	答案文本出现几率增加1~3%（随机）
	-- 2	答案文本出现几率增加4~6%（随机）
	-- 3	答案文本出现几率增加7~10%（随机）
	-- 4	答案文本出现几率增加11~15%（随机）
	-- 5	答案文本出现几率增加15~18%（随机）
	-- 6	答案文本出现几率增加18~20%（随机）

	print(" track_x = " .. track_x)
	print("barWidth = " .. barWidth)

	if track_x >= barWidth * (5 / 6) then
		print("区间6")
		return spiritState[6], math.random(18,20)
	elseif track_x >= barWidth * (4 / 6) then
		print("区间5")
		return spiritState[5], math.random(15,18)
	elseif track_x >= barWidth * (3 / 6) then
		print("区间4")
		return spiritState[4], math.random(11,15)
	elseif track_x >= barWidth * (2 / 6) then
		print("区间3")
		return spiritState[3], math.random(7,10)
	elseif track_x >= barWidth * (1 / 6) then
		print("区间2")
		return spiritState[2], math.random(4,6)
	else
		print("区间1")
		return spiritState[1], math.random(1,3)
	end

	-- --
	-- if math.abs(track_x - target_x) <= track_w then
	-- 	print("思索加成")
	-- 	return true
	-- else
	-- 	print("思索加成失败")
	-- 	return false
	-- end
end

-- 停止思索
function ProvinceExamLayer:stopThinking()
	self.isThinking = false

	-- 移除之前的5秒自动停止调用
	if self.stopThinkingHandle then
		self:stopActionByTag(self.stopThinkingHandle)
	end
	self.stopThinkingHandle = nil

	if self.Panel_kaochang.Panel_btn.Panel_thinking:isEnabled() == false then
		return
	end
	self.Panel_kaochang.Panel_btn.Panel_thinking:setEnabled(false)

	-- 停止移动
	-- 显示思索结果
	self:showThinkingResult(self:stopMoveBlock())

	-- 清空思索时间
	self.thinkTime = nil

	self:changeZone(1)
end

-- 显示思索结果
function ProvinceExamLayer:showThinkingResult(desc, buff)
	local role = User:getRole()
	local skillLv = role:getSkillLv("dushushizi", role:getSkillExp("dushushizi"))
	local literaryLv = role:getLiteraryLv(self.book)

	-- 概率
	-- 设【（相关书籍研读等级/ 1000）*0.5+（读书识字等级/1000）*0.3】为X，
	-- X取值不能超过0.8，最大0.8，即算出来的结果如果大于0.8，则取0.8
	local str = ""
	local pr =  math.floor((literaryLv / 1000) * 50 + (skillLv / 1000) * 30)
	if pr >= 80 then
		pr = 80
	end

	-- 思索结果
	print("读书识字等级 = " .. skillLv)
	print(self.book .. "等级 = " .. literaryLv)
	print("答对概率 = " .. pr + buff .. "/100")

	if math.random(1, 100) > pr + buff then
		str = wrongText[math.random(1, #wrongText)]
	else
		-- 获得正确答案
		self.isRight = true
		str = rightText[math.random(1, #rightText)]

		str = string.gsub(str, "$A", self.answer)
	end

	str = string.gsub(str, "$T", desc)

	self:actionPrint(str)

	self.Panel_kaochang.Panel_btn.Button_answer:setEnabled(true)
end

-- 获取提示
function ProvinceExamLayer:prompt()
	self:setCheatData(-1, 0, 0, 0)

	-- 获得正确答案
	local str
	self.isRight = true
	str = rightText[math.random(1, #rightText)]

	str = string.gsub(str, "$A", self.answer)
	str = string.gsub(str, "$T", "")

	self:actionPrint(str)
	self.Panel_kaochang.Panel_btn.Button_answer:setEnabled(true)
	self:changeZone(1)
end

-- 作弊结果
function ProvinceExamLayer:cheat()
	self.cheatState = 0

	local randNum = math.random(1, 2)
	if randNum == 1 then
		self:actionPrint("YEL你找到了答案，心中暗喜，赶紧把答案抄上去要紧。")
		self.isRight = true
		self.Panel_kaochang.Panel_btn.Button_answer:setEnabled(true)
	else
		self:actionPrint("HIC你鼓捣了半天，还是没找到答案。")
	end
	self:changeZone(1)
end

-- 作弊被抓
function ProvinceExamLayer:beCatch()
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self.examinerState = 3

	self:examinerPrint(examinerBeFind[math.random(1, #examinerBeFind)])

	-- 保存成绩
	if self.isFormal == true then
		Exam:saveProvinceScore(2, self:getExamData(1), 300)
	end

	self:delayFunc(1, function()
		self:showPanel("你的卷子已被监考官没收。本次考试成绩作废。", "离开考场")
	end)
end

-- 切换答题按钮区域 1 答题 2 思索 3 作弊
function ProvinceExamLayer:changeZone(state)
	self.Panel_kaochang.Panel_btn:setVisible(false)
	self.Panel_kaochang.Panel_cheat:setVisible(false)

	-- 思索按钮
	self.Panel_kaochang.Panel_btn.Panel_thinking:setVisible(not self.isRight)
	self.Panel_kaochang.Panel_btn.Panel_thinking:setEnabled(not self.isRight)
	self.Panel_kaochang.Panel_btn.Button_thinking:setVisible(self.isRight)
	self.Panel_kaochang.Panel_btn.Button_thinking:setEnabled(false)

	-- 思索进度条
	-- local width = self.Panel_kaochang.Panel_bar.Panel_track:getSize().width
	-- self.Panel_kaochang.Panel_bar.Panel_track:setPositionX(width / 2)

	-- 提示次数
	self.Panel_kaochang.Panel_btn.Button_prompt:setEnabled(self:getCheatData(1) > 0 and not self.isRight)

	-- 作弊
	self.Panel_kaochang.Panel_btn.Button_cheat:setEnabled(not self.isRight)

	-- 思索进度条
	self.Panel_kaochang.Panel_bar:setVisible(true)

	-- 没有作弊道具时 按钮不可点
	if self:getCheatData(2) <= 0 and self:getCheatData(3) <= 0 and self:getCheatData(4) <= 0 then
		self.Panel_kaochang.Panel_btn.Button_cheat:setEnabled(false)
	end

	if state == 1 then
		self.Panel_kaochang.Panel_btn:setVisible(true)
	elseif state == 2 then
		self.Panel_kaochang.Panel_bar:setVisible(true)
		self.Panel_kaochang.Panel_btn:setVisible(true)

		-- -- 停止思索
		-- self.Panel_kaochang.Panel_btn.Panel_thinking:releaseFunc(function()
		-- 	Audio:playEffect("xiaoAnNiu")

		-- end)
	elseif state == 3 then
		-- 蜡烛
		self.Panel_kaochang.Panel_cheat.Panel_candle.candleBar:setPercent(self:getCheatData(2) * 100)

		--砚台
		self.Panel_kaochang.Panel_cheat.Panel_yantai.yantaiBar:setPercent(self:getCheatData(3) * 100)

		-- 笔杆
		self.Panel_kaochang.Panel_cheat.Panel_pen.penBar:setPercent(self:getCheatData(4) * 100)

		self.Panel_kaochang.Panel_cheat:setVisible(true)
	end
end

function ProvinceExamLayer:setButton()
	-- 离开
	self.Panel_category.Button_return:releaseFunc(function()
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		PopupLayerController:hideLayer("ProvinceExamLayer", function(layer)
			self:hide()
		end, 0)
	end)

	-- 答题
	self.Panel_kaochang.Panel_btn.Button_answer:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		self.Panel_kaochang.Panel_btn.Button_answer:setEnabled(false)
		self.Panel_kaochang.Panel_btn.Button_prompt:setEnabled(false)
		self.Panel_kaochang.Panel_btn.Button_cheat:setEnabled(false)
		self.Panel_kaochang.Panel_btn.Panel_thinking:setEnabled(false)
		self.Panel_kaochang.Panel_btn.Panel_thinking:setVisible(false)
		self.Panel_kaochang.Panel_btn.Button_thinking:setVisible(true)

		if self.isCanAnswer == false then
			return
		end

		self.isCanAnswer = false

		self.Panel_kaochang.Text_question:setString("")
		self.Panel_kaochang.Text_bookName:setString("")
		self.Panel_kaochang.Text_bookDesc:setString("")

		if self.isRight == true then
			PopText("得分 + 5")
			self:setExamData(1, 0, 1)
			self:actionPrint("HIC你把心中所想誊写上去，与题面浑然一体，更加笃定所答是正确的。")
		else
			self:setExamData(0, 1, 1)
			self:actionPrint("HIC你把心中所想誊写上去后，就马上意识到自己答错了，可惜已经没法涂改了。")
		end

		-- 保存当前成绩
		if self:getExamData(3) >= 20 then
			-- 保存成绩 记录时间
			local currTime = GetTime()
			local time = currTime - self.startTime
			if time > 300 then
				time = 300
			end

			if self.isFormal == true then
				Exam:saveProvinceScore(0, self:getExamData(1), time)
			end

			self:delayFunc(0.5, function()
				self:showPanel("考试结束：题目已答完", "交卷")
			end)
			return
		else
			if self.isFormal == true then
				Exam:saveProvinceScore(0, self:getExamData(1), 300)
			end
		end

		self:delayFunc(2, function()
			-- 获得下一个题目
			self:getQuestion()
			self:changeZone(1)
		end)


	end)

	self.Panel_kaochang.Panel_btn.Panel_thinking:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.isCanAnswer == false then
			return
		end
		-- 停止思索
		self:stopThinking()

		self:thinkingGame()
	end)

	-- 提示
	self.Panel_kaochang.Panel_btn.Button_prompt:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isCanAnswer == false then
			return
		end

		self:prompt()
	end)

	-- 作弊
	self.Panel_kaochang.Panel_btn.Button_cheat:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		self:actionPrint("HIC你假作镇定，掏出在小贩那里买的特制小物品……")
		self:changeZone(3)
	end)

	-- 收起作弊
	self.Panel_kaochang.Panel_cheat.Button_retract:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:changeZone(1)
	end)

	-- 蜡烛
	self.Panel_kaochang.Panel_cheat.Panel_candle:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isCanAnswer == false then
			return
		end

		if self:getCheatData(2) <= 0 or self.cheatState ~= 0 then
			if self:getCheatData(2) <= 0 then
				PopText("道具已经用完了!")
			end

			return
		end

		self.cheatTime = GetTime()
		self.cheatState = 1
		self:setCheatData(0, -1, 0, 0)

		self.Panel_kaochang.Panel_cheat.Panel_candle.candleBar:setPercent(100)
		self.Panel_kaochang.Panel_cheat.Panel_yantai.yantaiBar:setPercent(0)
		self.Panel_kaochang.Panel_cheat.Panel_pen.penBar:setPercent(0)
		self.Panel_kaochang.Panel_cheat.Button_retract:setEnabled(false)
	end)

	-- 砚台
	self.Panel_kaochang.Panel_cheat.Panel_yantai:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isCanAnswer == false then
			return
		end

		if self:getCheatData(3) <= 0 or self.cheatState ~= 0 then
			if self:getCheatData(3) <= 0 then
				PopText("道具已经用完了!")
			end
			return
		end

		self.cheatTime = GetTime()
		self.cheatState = 2
		self:setCheatData(0, 0, -1, 0)

		self.Panel_kaochang.Panel_cheat.Panel_yantai.yantaiBar:setPercent(100)
		self.Panel_kaochang.Panel_cheat.Panel_candle.candleBar:setPercent(0)
		self.Panel_kaochang.Panel_cheat.Panel_pen.penBar:setPercent(0)
		self.Panel_kaochang.Panel_cheat.Button_retract:setEnabled(false)
	end)

	-- 笔杆
	self.Panel_kaochang.Panel_cheat.Panel_pen:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.isCanAnswer == false then
			return
		end

		if self:getCheatData(4) <= 0 or self.cheatState ~= 0 then
			if self:getCheatData(4) <= 0 then
				PopText("道具已经用完了!")
			end
			return
		end
		self.cheatTime = GetTime()
		self.cheatState = 3
		self:setCheatData(0, 0, 0, -1)

		self.Panel_kaochang.Panel_cheat.Panel_pen.penBar:setPercent(100)
		self.Panel_kaochang.Panel_cheat.Panel_candle.candleBar:setPercent(0)
		self.Panel_kaochang.Panel_cheat.Panel_yantai.yantaiBar:setPercent(0)
		self.Panel_kaochang.Panel_cheat.Button_retract:setEnabled(false)
	end)
end

-- 更新考试时间
function ProvinceExamLayer:UpdateTime(dt)
	local currTime = GetTime()
	local sec = 0

	sec = math.floor(300 - (currTime - self.startTime))

	if sec <= 0 then
		sec = 0
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		self:showPanel("考试结束：时辰已到。", "离开考场")
	end

	self.Panel_kaochang.Text_point:setString("得分：" .. self:getExamData(1) * 5 .. "分")

	self.Panel_kaochang.Text_time_num:setString(sec)

	self:UpdateProgress(dt)

	self:updateThink(dt)
end

-- 更新思索剩余时间
function ProvinceExamLayer:updateThink(dt)
	if self.thinkTime ~= nil then
		local currTime = GetTime()
		local time =  (currTime - self.thinkTime) / 2
		time = time * 100
		self.Panel_kaochang.Panel_btn.Panel_thinking:setEnabled(false)
		if time >= 100 then
			time = 100
			self.thinkTime = nil
			self.Panel_kaochang.Panel_btn.Panel_thinking:setEnabled(true)
		end
		self.Panel_kaochang.Panel_btn.Panel_thinking.bar:setPercent(time)
	end
end

-- 更新作弊进度条
function ProvinceExamLayer:UpdateProgress(dt)
	local currTime = GetTime()

	if self.cheatState == 1 then
		-- 作弊状态持续2秒
		local time = 2 - (currTime - self.cheatTime)
		if time <= 0 then
			time = 0
			self:cheat()
		end
		self.Panel_kaochang.Panel_cheat.Panel_candle.candleBar:setPercent(time / 2 * 100)

		if self.examinerState == 2 then
			self:beCatch()
		end
	elseif self.cheatState == 2 then

		-- 作弊状态持续2秒
		local time = 2 - (currTime - self.cheatTime)
		if time <= 0 then
			time = 0
			self:cheat()
		end
		self.Panel_kaochang.Panel_cheat.Panel_yantai.yantaiBar:setPercent(time / 2 * 100)

		if self.examinerState == 2 then
			self:beCatch()
		end
	elseif self.cheatState == 3 then
		-- 作弊状态持续2秒
		local time = 2 - (currTime - self.cheatTime)
		if time <= 0 then
			time = 0
			self:cheat()
		end
		self.Panel_kaochang.Panel_cheat.Panel_pen.penBar:setPercent(time / 2 * 100)

		if self.examinerState == 2 then
			self:beCatch()
		end
	else
		self.Panel_kaochang.Panel_cheat.Button_retract:setEnabled(true)
	end
end

-- 更新考官状态
function ProvinceExamLayer:UpdateExaminerState()
	-- 被发现了不再更新状态
	if self.examinerState == 3 then
		return
	end

	self:examinerPrint(examinerLookText[self.examinerAction])

	-- 按顺序播放文字
	self.examinerAction = self.examinerAction + 1

	if self.examinerAction > #examinerLookText then
		self.examinerAction = 1
	end

	if self.examinerAction == #examinerLookText then
		self.examinerState = 2
	else
		self.examinerState = 1
	end

	-- self:delayFunc(2, function()
	-- 	self:closeExaminerState()
	-- end)

	if self.delayFuncHandle ~= nil then
		self:stopActionByTag(self.delayFuncHandle)
		self.delayFuncHandle = nil
	end

	self.delayFuncHandle = self:delayFunc(2, function()
		self:UpdateExaminerState()
	end)
end

-- 清除考官状态
function ProvinceExamLayer:closeExaminerState()
	-- 被发现了不再更新状态
	if self.examinerState == 3 then
		return
	end

	self.examinerState = 0

	-- 清空考官输出框
	--self:initExaminerRichText()
	self:examinerPrint("")
end

-- 添加提示和作弊道具次数
function ProvinceExamLayer:addCheatItem()
	local role = User:getRole()

	-- 提示道具 总数不超过4次  cankao1押题集 4次 cankao2真题 2次
	local promptCount1 = 0
	promptCount1 = role:getItemCount("cankao1")
	if promptCount1 > 2 then
		promptCount1 = 2
	end
	if promptCount1 > 0 then
		role:addItemCount("cankao1", -promptCount1)
	end

	local promptCount2 = 0
	if promptCount1 < 2 and self.isFormal == true then
		promptCount2 = role:getItemCount("cankao2")

		if promptCount2 > 1 then
			promptCount2 = 1
		end
		if promptCount2 > 0 then
			role:addItemCount("cankao2", -promptCount2)
		end
	end

	-- 砚台
	local yantaiCount = 0
	yantaiCount = role:getItemCount("zuobi3")
	if yantaiCount > 4 then
		yantaiCount = 4
	end
	if yantaiCount > 0 then
		role:addItemCount("zuobi3", -yantaiCount)
	end

	-- 笔杆
	local penCount = 0
	penCount = role:getItemCount("zuobi2")
	if penCount > 3 then
		penCount = 3
	end
	if penCount > 0 then
		role:addItemCount("zuobi2", -penCount)
	end

	-- 蜡烛
	local candleCount = 0
	candleCount = role:getItemCount("zuobi1")
	if candleCount > 2 then
		candleCount = 2
	end
	if candleCount > 0 then
		role:addItemCount("zuobi1", -candleCount)
	end

	local promptCount = (promptCount1 * 2) + (promptCount2 * 4)
	if promptCount > 4 then
		promptCount = 4
	end
	self:setCheatData(promptCount, candleCount, yantaiCount, penCount)
end

-- 初始化输出框
function ProvinceExamLayer:initActionRichText()
	local x, y = self.Panel_kaochang.Image_actionPrint.Text_desc:getPosition()
	local size = self.Panel_kaochang.Image_actionPrint.Text_desc:getContentSize()

	if self.ActionRichText_print then
		self.ActionRichText_print:removeFromParent()
		self.ActionRichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_kaochang.Image_actionPrint.Text_desc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_kaochang.Image_actionPrint.Text_desc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.ActionRichText_print = richTextScroll

   	self.ActionRichText_print:setBounceEnabled(false)
end

function ProvinceExamLayer:actionPrint(str, verticalSpace)
	-- self.Panel_kaochang.Image_actionPrint.Text_desc:setString(str)
	self:initActionRichText()
	if str == "" then
		return
	end
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.ActionRichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initActionRichText()
	end

	self.ActionRichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 40)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.ActionRichText_print:pushBackNewLine(verticalSpace)
	else
		self.ActionRichText_print:pushBackNewLine()
	end
end

-- 初始化输出框
function ProvinceExamLayer:initExaminerRichText()
	local x, y = self.Panel_kaochang.Image_examinerPrint.Text_desc:getPosition()
	local size = self.Panel_kaochang.Image_examinerPrint.Text_desc:getContentSize()

	if self.ExaminerRichText_print then
		self.ExaminerRichText_print:removeFromParent()
		self.ExaminerRichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Panel_kaochang.Image_examinerPrint.Text_desc:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Panel_kaochang.Image_examinerPrint.Text_desc:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.ExaminerRichText_print = richTextScroll

   	self.ExaminerRichText_print:setBounceEnabled(false)
end

function ProvinceExamLayer:examinerPrint(str, verticalSpace)
	-- if str == "" then
	-- 	return
	-- end
	self.Panel_kaochang.Image_examinerPrint.Text_desc:setString(str)
	-- local textColor = cc.c3b(159,159,159)
	-- local textHeight = self.ExaminerRichText_print:getRichText():getNewContentSizeHeight()
	-- if textHeight >= 6666 then
	-- 	self:initExaminerRichText()
	-- end

	-- self.ExaminerRichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 36)

	-- if verticalSpace ~= nil and type(verticalSpace) == "number" then
	-- 	self.ExaminerRichText_print:pushBackNewLine(verticalSpace)
	-- else
	-- 	self.ExaminerRichText_print:pushBackNewLine()
	-- end
end

Helper:classDefNodeGetInstance(ProvinceExamLayer)

return ProvinceExamLayer000