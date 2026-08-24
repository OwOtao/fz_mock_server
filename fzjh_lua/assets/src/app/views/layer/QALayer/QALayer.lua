local QALayer = class("QALayer", LayerEx)

local QuestionsAndAnswers = assert(require("script.others.QuestionsAndAnswers"))

local QAMap = QuestionsAndAnswers["QA"]

function QALayer:create()
	local p = QALayer:new()
	p:init()
	return p
end

function QALayer:init()
	self._UI = require("Layer/QALayer/QAUI.lua").create()['root']
	self._UI:addTo(self)

	self:setVisible(false)

	self.stratTime = 0
	self.isShow = false
	self.rightAnswer = 0

	self.rightFunc = nil
	self.wrongFunc = nil

	-- 是否限时
	self.timeLimit = true

	Helper:convertUIByParent(self)
	self:setButton()

	self.Text_time:setString("")

	-- -- 更新剩余时间
	-- self:schedule(
	-- function(dt)
	-- 	self:UpdateTime(dt)
	-- end, 0)
end

-- 显示UI
function QALayer:showLayer(rightFunc, wrongFunc)
	self:setshowAndHideAnimDuration(0.25)
	self:setShowAndHideAnimType("ROLL")

	self.timeLimit = true
	self.rightFunc = rightFunc
	self.wrongFunc = wrongFunc

	if self.rightFunc == nil then
		self.rightFunc = function()
		end
	end

	if self.wrongFunc == nil then
		self.wrongFunc = function()
		end
	end

	self.Button_1:setPosition(540, 1000)
	self.Button_2:setPosition(540, 750)
	self.Button_3:setPosition(540, 500)
	self.Button_4:setPosition(540, 250)
	self.Text_button_1:setPosition(540, 1000)
	self.Text_button_2:setPosition(540, 750)
	self.Text_button_3:setPosition(540, 500)
	self.Text_button_4:setPosition(540, 250)

	self:setButton()
	self:setTime()
	self:setData(self:getQuestion())

	-- 交换按钮位置
	for i=1,10 do
		self:changeBtn()
	end
	self:show()
end

-- 十六章答题
function QALayer:showLayerByMap(rightNoneFunc, rightOneFunc, rightTwoFunc, rightThreeFunc)
	self:setshowAndHideAnimDuration(4)
	self:setShowAndHideAnimType("FADE")

	self.timeLimit = false
	self.isShow = false

	if rightNoneFunc == nil then
		rightNoneFunc = function()
		end
	end

	if rightOneFunc == nil then
		rightOneFunc = function()
		end
	end

	if rightTwoFunc == nil then
		rightTwoFunc = function()
		end
	end

	if rightThreeFunc == nil then
		rightThreeFunc = function()
		end
	end

	self.Button_1:setPosition(540, 1000)
	self.Button_2:setPosition(540, 750)
	self.Button_3:setPosition(540, 500)
	self.Button_4:setPosition(540, 250)
	self.Text_button_1:setPosition(540, 1000)
	self.Text_button_2:setPosition(540, 750)
	self.Text_button_3:setPosition(540, 500)
	self.Text_button_4:setPosition(540, 250)

	local tab =
	{
		[1] =
		{
			question = "名驰塞外三千里,味占三晋第一春”说的哪种酒？",
			answer1 = "葡萄酒",
			answer2 = "梨花春",
			answer3 = "长安酒",
			rightAnswer = "梨花春"
		},
		[2] =
		{
			question = "葡萄美酒夜光杯，欲饮琵琶马上催”乃是王翰所作诗句，你可知西域的葡萄及葡萄酒酿造技术，是何时引入中原的么？",
			answer1 = "唐朝",
			answer2 = "汉朝",
			answer3 = "晋朝",
			rightAnswer = "汉朝"
		},
		[3] =
		{
			question = "你可知“女儿红”产于何地？",
			answer1 = "豫州",
			answer2 = "徐州",
			answer3 = "扬州",
			rightAnswer = "扬州"
		},
	}

	-- 答对的次数
	local rightCount = 0

	local questionIndex = 1

	local function nextQuestion(index)
		if index > 3 then
			if rightCount == 0 then
				rightNoneFunc()
			elseif rightCount == 1 then
				rightOneFunc()
			elseif rightCount == 2 then
				rightTwoFunc()
			elseif rightCount == 3 then
				rightThreeFunc()
			end
			self:setshowAndHideAnimDuration(0.5)
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
			return
		end
		self:setData(tab[index])
	end

	nextQuestion(questionIndex)

	self.Button_1:releaseFunc(function()
		if self.isShow == false then
			return
		end
		if self.rightAnswer == self.Text_button_1:getString() then
			rightCount = rightCount + 1
			PopText("回答正确")
		else
			PopText("回答错误")
		end
		questionIndex = questionIndex + 1
		nextQuestion(questionIndex)
	end)

	self.Button_2:releaseFunc(function()
		if self.isShow == false then
			return
		end
		if self.rightAnswer == self.Text_button_2:getString() then
			rightCount = rightCount + 1
			PopText("回答正确")
		else
			PopText("回答错误")
		end
		questionIndex = questionIndex + 1
		nextQuestion(questionIndex)
	end)

	self.Button_3:releaseFunc(function()
		if self.isShow == false then
			return
		end
		if self.rightAnswer == self.Text_button_3:getString() then
			rightCount = rightCount + 1
			PopText("回答正确")
		else
			PopText("回答错误")
		end
		questionIndex = questionIndex + 1
		nextQuestion(questionIndex)
	end)

	-- 交换按钮位置
	for i=1,10 do
		self:changeBtn()
	end

	self:show(function()
		self.isShow = true
	end)
end

-- 随机获取问题
function QALayer:getQuestion()
	local count = 0
	for k,v in pairs(QAMap) do
		count = count + 1
	end
	local index = math.random(1, count)

	return QAMap[tostring(index)]
end

-- 更新剩余时间
function QALayer:UpdateTime(dt)
	if self.timeLimit == false then
		self.Text_time:setString("")
		return
	end

	local currTime = GetTime()
	local sec = 0

	sec = math.floor(10 - (currTime - self.stratTime))

	if sec <= 0 then
		sec = 0
		if self.isShow == true then
			self.isShow = false
			PopText("超时，答题失败")
			self.wrongFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		end
	end

	self.Text_time:setString("剩余时间:" .. sec .. "秒")
end

function QALayer:setTime()
	self.isShow = true
	self.stratTime = GetTime()
end

-- 设置文本
function QALayer:setData(question)
	self.Text_desc:setString(question.question)

	self.Text_button_1:setString(question.answer1)
	self.Button_1:setVisible(question.answer1 ~= nil and question.answer1 ~= "")
	self.Text_button_2:setString(question.answer2)
	self.Button_2:setVisible(question.answer2 ~= nil and question.answer2 ~= "")
	self.Text_button_3:setString(question.answer3)
	self.Button_3:setVisible(question.answer3 ~= nil and question.answer3 ~= "")
	self.Text_button_4:setString(question.answer4)
	self.Button_4:setVisible(question.answer4 ~= nil and question.answer4 ~= "")

	self.rightAnswer = question.rightAnswer
end

-- 设置按钮
function QALayer:setButton()
	self.Button_1:releaseFunc(function()
		if self.isShow == false then
			return
		end
		self.isShow = false

		if self.rightAnswer == self.Text_button_1:getString() then
			PopText("回答正确")
			self.rightFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		else
			PopText("回答错误")
			self.wrongFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		end
	end)

	self.Button_2:releaseFunc(function()
		if self.isShow == false then
			return
		end
		self.isShow = false

		if self.rightAnswer == self.Text_button_2:getString() then
			PopText("回答正确")
			self.rightFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		else
			PopText("回答错误")
			self.wrongFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		end
	end)

	self.Button_3:releaseFunc(function()
		if self.isShow == false then
			return
		end
		self.isShow = false

		if self.rightAnswer == self.Text_button_3:getString() then
			PopText("回答正确")
			self.rightFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		else
			PopText("回答错误")
			self.wrongFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		end
	end)

	self.Button_4:releaseFunc(function()
		if self.isShow == false then
			return
		end
		self.isShow = false

		if self.rightAnswer == self.Text_button_4:getString() then
			PopText("回答正确")
			self.rightFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		else
			PopText("回答错误")
			self.wrongFunc()
			PopupLayerController:hideLayer("QALayer", function(layer)
				self:hide()
			end)
		end
	end)
end

-- 交换按钮位置
function QALayer:changeBtn()
	local btn =
	{
		self.Button_1,
		self.Button_2,
		self.Button_3,
		self.Button_4,
	}
	local text =
	{
		self.Text_button_1,
		self.Text_button_2,
		self.Text_button_3,
		self.Text_button_4,
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

Helper:classDefNodeGetInstance(QALayer)

return QALayer000