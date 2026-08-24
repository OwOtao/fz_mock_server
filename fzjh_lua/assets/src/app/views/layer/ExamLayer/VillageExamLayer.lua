local QuestionsAndAnswers = assert(require("script.others.QuestionsAndAnswers"))

local QAMap = QuestionsAndAnswers["QA"]

local Exam = require("app.models.Exam.Exam")

-- 乡试界面
local VillageExamLayer = class("VillageExamLayer", LayerEx)

function VillageExamLayer:create()
	local p = VillageExamLayer:new()
	p:init()
	return p
end

function VillageExamLayer:init()
	self._UI = require("Layer/ExamUI/VillageExamUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setButton()

	-- 成绩数据 答对题数 答错题数 当前题数
	self.examData = "0;0;1"
end

function VillageExamLayer:showLayer()
	self.state = 1
	self:show()
	self:insideRoom()

	-- 开打界面就保存成绩
	Exam:saveVillageExamScore(0, self:getExamData(1))
end

function VillageExamLayer:getExamData(index)
	return tonumber(string.split(self.examData, ";")[index])
end

function VillageExamLayer:setExamData(right, wrong, total)
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
end

-- 考场内
function VillageExamLayer:insideRoom()
	self.Panel_gongyuan:setVisible(false)
	self.Panel_kaochang:setVisible(true)

	self.Text_desc:setString("")

	-- 答题界面
	self.Panel_kaochang.Panel_answer:setVisible(false)
	-- 开始答题按钮
	self.Panel_kaochang.Button_startAnswer:setVisible(false)
	-- 交卷按钮
	self.Panel_kaochang.Button_handExam:setVisible(false)
	-- 考试时间到界面
	self.Panel_kaochang.Panel_timeOver:setVisible(false)
	-- 题目数量
	self.Panel_kaochang.Text_count:setVisible(false)
	self.Panel_kaochang.Text_text1:setVisible(false)
	self.Panel_kaochang.Text_text1_0:setVisible(false)

	-- 剩余时间
	self.Panel_kaochang.Text_time:setVisible(false)
	self.Panel_kaochang.Text_time_num:setVisible(false)
	self.Panel_kaochang.Text_time_0:setVisible(false)

	if self.state == 1 then
		-- 等待考试
		self.Text_desc:setString("监考官已经就位，考生们也都已经就座了。整个考场的气氛有些凝重。")
		self.Panel_kaochang.Button_startAnswer:setVisible(true)
	elseif self.state == 2 then
		-- 考试中
		self.Panel_kaochang.Text_count:setVisible(true)
		self.Panel_kaochang.Panel_answer:setVisible(true)
		self.Panel_kaochang.Text_text1:setVisible(true)
		self.Panel_kaochang.Text_text1_0:setVisible(true)
		self.Panel_kaochang.Text_time:setVisible(true)
		self.Panel_kaochang.Text_time_num:setVisible(true)
		self.Panel_kaochang.Text_time_0:setVisible(true)
	elseif self.state == 3 then
		-- 答完时间未结束
		self.Text_desc:setString("卷子上的题目已经答完，可以交卷了。交完卷稍后可以在考官那里查看成绩。")
		-- self.Panel_kaochang.Text_count:setVisible(true)
		self.Panel_kaochang.Button_handExam:setVisible(true)
	elseif self.state == 4 then
		-- 考试时间到
		-- self.Panel_kaochang.Text_count:setVisible(true)
		self.Panel_kaochang.Panel_timeOver:setVisible(true)
	end
end

-- 开始答题
function VillageExamLayer:startExam()
	-- 开始时间
	self.startTime = GetTime()

	-- 正确答案
	self.rightAnswer = ""

	-- 成绩数据 答对题数 答错题数 当前题数
	self.scoreStr = "0;0;1"

	-- 考试中
	self.state = 2

	-- 少于60秒提醒
	self.remind = false

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:UpdateTime(ft)
	end,1/10)

	self:setData(self:getQuestion())
end

-- 答题时间到
function VillageExamLayer:timeOver()
	self.state = 4
	RichPrint("main", "HIC几个监考官如狼似虎地奔过来，将所有人的卷子都收走了。有些没答完的考生脸色苍白，如丧考妣，还有些考生以头抢地请求再给点时间，更有甚者直接就晕了过去……")
	self:insideRoom()
	self.Panel_kaochang.Text_count:setColor({r = 241, g = 16, b = 16})
	local totalCount = self:getExamData(3)
	if totalCount > 20 then
		totalCount = 20
	end
	self.Panel_kaochang.Text_count:setString( totalCount .. "/20 " )
end

-- 随机获取问题
function VillageExamLayer:getQuestion()
	local count = 0
	for k,v in pairs(QAMap) do
		count = count + 1
	end
	local index = math.random(1, count)

	return QAMap[tostring(index)]
end

-- 设置题目
function VillageExamLayer:setData(question)
	-- 保存成绩
	Exam:saveVillageExamScore(0, self:getExamData(1))

	-- 答完20题，提示交卷
	if self:getExamData(3) > 20 then
		self.state = 3
		self:insideRoom()
		self.Panel_kaochang.Text_count:setColor({r = 246, g = 244, b = 80})
		self.Panel_kaochang.Text_count:setString("20/20 ".. "(已完成)" )
		return
	end

	local panel = self.Panel_kaochang.Panel_answer

	panel.Button_1:setPosition(540, 1150)
	panel.Button_2:setPosition(540, 1000)
	panel.Button_3:setPosition(540, 850)
	panel.Button_4:setPosition(540, 700)
	panel.Text_button_1:setPosition(540, 1150)
	panel.Text_button_2:setPosition(540, 1000)
	panel.Text_button_3:setPosition(540, 850)
	panel.Text_button_4:setPosition(540, 700)

	panel.Text_desc:setString(question.question)

	panel.Text_button_1:setString(question.answer1)
	panel.Button_1:setVisible(question.answer1 ~= nil and question.answer1 ~= "")
	panel.Text_button_2:setString(question.answer2)
	panel.Button_2:setVisible(question.answer2 ~= nil and question.answer2 ~= "")
	panel.Text_button_3:setString(question.answer3)
	panel.Button_3:setVisible(question.answer3 ~= nil and question.answer3 ~= "")
	panel.Text_button_4:setString(question.answer4)
	panel.Button_4:setVisible(question.answer4 ~= nil and question.answer4 ~= "")

	self.rightAnswer = question.rightAnswer
	print("正确答案 【" .. self.rightAnswer .. "】")

	self.Panel_kaochang.Text_count:setColor({r = 208, g = 208, b = 208})
	self.Panel_kaochang.Text_count:setString( self:getExamData(3) .. "/20" )

	-- 交换按钮位置
	for i=1,10 do
		self:changeBtn()
	end
end

function VillageExamLayer:setButton()
	--
	self.Panel_kaochang.Panel_category.Button_return:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		if self.state == 1 then
			RichPrint("main", "RED科考乃人生大事，岂可儿戏？现在离开，本次乡试成绩作废！慎之慎之！ ")
		elseif self.state == 2 then
			RichPrint("main", "RED科考乃人生大事，岂可儿戏？现在离开，本次乡试成绩作废！慎之慎之！ ")
		elseif self.state == 3 then
			RichPrint("main", "RED请先交卷子再离开考场！")
		end
	end)

	-- 开始答题
	self.Panel_kaochang.Button_startAnswer:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		RichPrint("main", "HIC你研好墨，深吸一口气，开始下笔答题了！")
		self:startExam()
		self:insideRoom()
	end)

	-- 离开考场
	self.Panel_kaochang.Panel_timeOver.Button_level:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self.state = 5
		-- 保存成绩
		Exam:saveVillageExamScore(0, self:getExamData(1))

		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		PopupLayerController:hideLayer("VillageExamLayer", function(layer)
			self:hide()
		end, 0)
	end)

	-- 交卷
	self.Panel_kaochang.Button_handExam:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self.state = 5
		RichPrint("main", "HIC你做完了卷子，百无聊赖，于是提前交了卷子。在其他考生复杂的目光中，你施施然地走出了考场。")
		-- 保存成绩
		Exam:saveVillageExamScore(0, self:getExamData(1))
		-- 离开考场
		--self:outsideRoom()

		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

		PopupLayerController:hideLayer("VillageExamLayer", function(layer)
			self:hide()
		end, 0)
	end)

	self.Panel_kaochang.Panel_answer.Button_1:releaseFunc(function()
		local right = 0
		local wrong = 0
		if self.rightAnswer == self.Panel_kaochang.Panel_answer.Text_button_1:getString() then
			right = 1
		else
			wrong = 1
		end
		self:setExamData(right, wrong, 1)
		self:setData(self:getQuestion())
	end)

	self.Panel_kaochang.Panel_answer.Button_2:releaseFunc(function()
		local right = 0
		local wrong = 0
		if self.rightAnswer == self.Panel_kaochang.Panel_answer.Text_button_2:getString() then
			right = 1
		else
			wrong = 1
		end
		self:setExamData(right, wrong, 1)
		self:setData(self:getQuestion())
	end)

	self.Panel_kaochang.Panel_answer.Button_3:releaseFunc(function()
		local right = 0
		local wrong = 0
		if self.rightAnswer == self.Panel_kaochang.Panel_answer.Text_button_3:getString() then
			right = 1
		else
			wrong = 1
		end
		self:setExamData(right, wrong, 1)
		self:setData(self:getQuestion())
	end)

	self.Panel_kaochang.Panel_answer.Button_4:releaseFunc(function()
		local right = 0
		local wrong = 0
		if self.rightAnswer == self.Panel_kaochang.Panel_answer.Text_button_4:getString() then
			right = 1
		else
			wrong = 1
		end
		self:setExamData(right, wrong, 1)
		self:setData(self:getQuestion())
	end)
end

-- 更新时间
function VillageExamLayer:UpdateTime(dt)
	local currTime = GetTime()
	local sec = 0

	sec = math.floor(300 - (currTime - self.startTime))

	if sec <= 0 then
		sec = 0
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
		self:timeOver()
	end

	if sec <= 60 and self.remind == false then
		RichPrint("main", "RED监考官轻咳一声说道：“大家要抓紧时间了！”")
		self.remind = true
	end

	self.Panel_kaochang.Text_time_num:setString(sec)
	-- self.Panel_kaochang.LoadingBar:setPercent((sec / 300) * 100)
end

-- 交换按钮位置
function VillageExamLayer:changeBtn()
	local btn =
	{
		self.Panel_kaochang.Panel_answer.Button_1,
		self.Panel_kaochang.Panel_answer.Button_2,
		self.Panel_kaochang.Panel_answer.Button_3,
		self.Panel_kaochang.Panel_answer.Button_4,
	}
	local text =
	{
		self.Panel_kaochang.Panel_answer.Text_button_1,
		self.Panel_kaochang.Panel_answer.Text_button_2,
		self.Panel_kaochang.Panel_answer.Text_button_3,
		self.Panel_kaochang.Panel_answer.Text_button_4,
	}

	local num1 = math.random(1, 4)
	local num2 = math.random(1, 4)

	if not btn[num1]:isVisible() or not btn[num2]:isVisible() then
		return
	end

	local x,y = btn[num1]:getPosition()
	btn[num1]:setPosition(btn[num2]:getPosition())
	text[num1]:setPosition(text[num2]:getPosition())
	btn[num2]:setPosition(x, y)
	text[num2]:setPosition(x, y)
end

Helper:classDefNodeGetInstance(VillageExamLayer)

return VillageExamLayer000000