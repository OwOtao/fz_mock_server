
local QuestionsAndAnswers = assert(require("script.others.QuestionsAndAnswers"))
local QAMap = QuestionsAndAnswers["QA"]
local QBMap = QuestionsAndAnswers["QB"]
local MidAutumnFestivalLanternRiddleLayer = class("MidAutumnFestivalLanternRiddleLayer", LayerEx)
local selectedQusetion={}
local selectedQusetionA={}
local selectedQusetionB={}

function MidAutumnFestivalLanternRiddleLayer:create()
	local p = MidAutumnFestivalLanternRiddleLayer:new()
	p:init()
	return p
end

function MidAutumnFestivalLanternRiddleLayer:init()
	local UI = require("Layer/ActionUI/MidAutumnFestivalLanternRiddleUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
end

--从不同题库获取题目
function MidAutumnFestivalLanternRiddleLayer:getQuestionFromLibrary(questionNum,questionsLibraryResource,type)  --题目数量 题库 题库类型 1 A 2 B
	if questionNum<1 then 
		print("数量错误")
		return 
	end
	if not questionsLibraryResource  then 
		print("题库出错")
		return 
	end

	local tab_length=0
	for i,v in pairs(questionsLibraryResource) do
		tab_length=tab_length+1
	end
	if tab_length<1 then 
		print("题库出错")
		return
	end
	local i=1
	local selected_Qusetion={}
	while i<=questionNum do
		local index = math.random(1, tab_length)
		if #selected_Qusetion<1 then 
			questionsLibraryResource[tostring(index)]["index"]=index
			questionsLibraryResource[tostring(index)]["type"]=type
			if PRINT_MODE==1 then 
				print("type:"..type.."index:"..index)
			end
			table.insert(selected_Qusetion,questionsLibraryResource[tostring(index)])
			i=i+1
		else
			local isExist=false
			for i,v in pairs(selected_Qusetion) do
				if questionsLibraryResource[tostring(index)]==v then 
					isExist=true
				end
			end
			if isExist==false then 
				if PRINT_MODE==1 then 
					print("type:"..type.."index:"..index)
				end
				questionsLibraryResource[tostring(index)]["index"]=index
				questionsLibraryResource[tostring(index)]["type"]=type
				table.insert(selected_Qusetion,questionsLibraryResource[tostring(index)])
				i=i+1
			end 
		end
	end
	if #selected_Qusetion==questionNum then 
		return selected_Qusetion
	else
		print("选题出错")
	end
end

--判断某题属于某库  题库类型 1 A 2 B
function MidAutumnFestivalLanternRiddleLayer:isBelong(question)
	if not question or type(question) ~= "table" then 
		print("没验证问题")
		return 
	end
	if question["type"]==1 then
		return 1
	elseif question["type"]==2 then 
		return 2
	end
end

--确定答题题库（selectedQusetionLibrary--已答问题）
function MidAutumnFestivalLanternRiddleLayer:getQuestionLibrary(selectedQusetionLibrary)
	--从A、B两个题库各抽取10题
	self.questionsANum=10
	self.questionsBNum=10
	if self.lastQusetion and self.lastQusetion["type"]==1 then 
		self.questionsANum=self.questionsANum+1
	elseif self.lastQusetion and self.lastQusetion["type"]==2 then
		self.questionsBNum=self.questionsBNum+1
	end
	selectedQusetionA=self:getQuestionFromLibrary(self.questionsANum,QAMap,1)
	selectedQusetionB=self:getQuestionFromLibrary(self.questionsBNum,QBMap,2)
	if selectedQusetionA and selectedQusetionB then 
		for i=1,self.questionsANum do
			table.insert( selectedQusetion, selectedQusetionA[i])
		end
		for i=1,self.questionsBNum do
			table.insert( selectedQusetion, selectedQusetionB[i])
		end
	end
	if not selectedQusetion then 
		print("题库错误")
		return 
	end
	--移除已答题目
	selectedQusetion=self:removeSelectedQuestion(selectedQusetion,selectedQusetionLibrary)
	return selectedQusetion
end

--随机获取问题  
function MidAutumnFestivalLanternRiddleLayer:getQuestion()
	
	local questionTab
	local selectTab={}
	local tab_length=0
	for i,v in pairs(selectedQusetion) do
		if v then 
			tab_length=tab_length+1
		end
	end
	print("tab_length:"..tab_length)
	local index = math.random(1, tab_length)
	questionTab=selectedQusetion[index]
	selectTab["index"]=selectedQusetion[index]["index"]
	selectTab["type"]=selectedQusetion[index]["type"]
	table.remove(selectedQusetion,index)
	if not questionTab then 
		print("题目有问题")
		return
	end 
	table.insert(self.selectedQuestions,selectTab)
	--保存已经出现了题目
	User:getRole():setDayFlag("灯谜活动已答题", self.selectedQuestions)
	return questionTab
end

--移除已答问题 （selectedQusetionLibrary--已答问题 selectedQusetion-- 题库）
function MidAutumnFestivalLanternRiddleLayer:removeSelectedQuestion(selectedQusetion,selectedQusetionLibrary)
	local questionsAllNum=0
	local questionsANum=0
	local questionsBNum=0
	if not selectedQusetionLibrary or type(selectedQusetionLibrary)~="table" then 
		print("正常答题")
		return selectedQusetion
	end
	for q_index,question in pairs(selectedQusetionLibrary) do
		if self:isBelong(question)==1 then 
			questionsANum=questionsANum+1
			for i,v in pairs(selectedQusetion) do
				if question["index"]==v["index"] then 
					table.remove(selectedQusetion,i)
					questionsAllNum=questionsAllNum+1
					questionsANum=questionsANum-1
					break
				end
			end
		elseif self:isBelong(question)==2 then 
			questionsBNum=questionsBNum+1
			for i,v in pairs(selectedQusetion) do
				if question["index"]==v["index"] then 
					table.remove(selectedQusetion,i)
					questionsAllNum=questionsAllNum+1
					questionsBNum=questionsBNum-1
					break
				end
			end
		end
	end
	if questionsAllNum==#selectedQusetionLibrary then 
	else
		local selectedQusetion1=selectedQusetion
		for i,v in pairs(selectedQusetion1) do
			if self:isBelong(v)==1 and questionsANum>0 and #selectedQusetion>=1 then 
				table.remove(selectedQusetion,i)
				questionsANum=questionsANum-1
			elseif self:isBelong(v)==2 and questionsBNum>0 and #selectedQusetion>=1 then 
				table.remove(selectedQusetion,i)
				questionsBNum=questionsBNum-1
			end
			if questionsBNum==0 and questionsANum==0 then 
				break
			end
		end
	end
	return selectedQusetion
end

--（selectedQusetionLibrary--已答问题  questionsData 例如（5，1）答5题 对1题）
function MidAutumnFestivalLanternRiddleLayer:showLayer(selectedQusetionLibrary,questionsData)
	self:show()
	self.selectedQuestions={}
	self.questionsData="0;0"
	if selectedQusetionLibrary and type(selectedQusetionLibrary)=="table" then 
		print("#selectedQusetionLibrary:"..#selectedQusetionLibrary)
		self.lastQusetion=selectedQusetionLibrary[#selectedQusetionLibrary]
	end
	self:getQuestionLibrary(selectedQusetionLibrary)  --获取所有题目
	if selectedQusetionLibrary and type(selectedQusetionLibrary)=="table" then 
		selectedQusetionLibrary[#selectedQusetionLibrary]=nil
		self.selectedQuestions=selectedQusetionLibrary
	end
	if questionsData and type(questionsData)=="string" then 
		self.questionsData=questionsData
	end
	self.completeQuestions=self:getquestionData(1)
	self.trueQuestions=self:getquestionData(2)
	print("self.trueQuestions"..self.questionsData)
	self.isStart=false
	self:initBeforeUI()
end

function MidAutumnFestivalLanternRiddleLayer:startGame()
	self.startTime=GetTime()
	self.btnCanClick=true
	print("time:"..self.startTime)
	if self.completeQuestions>=20 then 
		self:endGame()
		return 
	end
	if self.isStart==true then
		if  self._handle==nil then 
			self._handle = self:schedule(function (ft)
				self:updateTime(ft)
			end,0.1)
		end
		self.currQuestion=self:getQuestion()
		if not self.currQuestion then 
			print("题目出错")
			return 
		end
		self.Panel_kaochang:setVisible(true)
		self:setData(self.currQuestion)
		print("答题开始")
	end
end

function MidAutumnFestivalLanternRiddleLayer:endGame()
	self:initAfterUI()
	local role = User:getRole()
	role:setDayFlag("灯谜活动答对题数", self.trueQuestions)
	role:setDayFlag("灯谜活动奖励领取", false)
	role:setDayFlag("灯谜活动答题", 1)

	role:setInheritFlag("weekxqdm_gameTimes",role:getInheritFlag("weekxqdm_gameTimes") + 1)
	
	if role:getInheritFlag("weekxqdm_gameTimes") > 22 then
		role:setInheritFlag("weekxqdm_gameTimes",1)
	end

	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end
end

function MidAutumnFestivalLanternRiddleLayer:showRightAnswer(x,y)
	self.Panel_kaochang.Panel_answer.Image_rightResult:setVisible(true)
	self.Panel_kaochang.Panel_answer.Image_rightResult:setPosition(x, y)
end

function MidAutumnFestivalLanternRiddleLayer:showErrorAnswer(x,y)
	self.Panel_kaochang.Panel_answer.Image_errorResult:setVisible(true)
	self.Panel_kaochang.Panel_answer.Image_errorResult:setPosition(x,y)
end

-- 设置题目
function MidAutumnFestivalLanternRiddleLayer:setData(question)
	-- 保存成绩
	-- 答完20题，提示交卷
	User:getRole():setDayFlag("灯谜活动答题结果", self.completeQuestions..";"..self.trueQuestions)   --(已打题数，正确题数)
	self.questionData=tostring(self.completeQuestions)..";"..tostring(self.trueQuestions)
	self.completeQuestions=self.completeQuestions+1
	if self:getquestionData(1) > 20 then
		self.Panel_kaochang.Text_count:setColor({r = 246, g = 244, b = 80})
		self.Panel_kaochang.Text_count:setString("20/20 ".. "(已完成)" )
		return
	end
	print("出题")
	if PRINT_MODE==1 then 
		print("题目来源："..question.type.."题目下表："..question.index)
	end
	local panel = self.Panel_kaochang.Panel_answer
	panel.Button_1:setPosition(540, 1110)
	panel.Button_2:setPosition(540, 950)
	panel.Button_3:setPosition(540, 790)
	panel.Button_4:setPosition(540, 630)
	panel.Text_button_1:setPosition(540, 1110)
	panel.Text_button_2:setPosition(540, 950)
	panel.Text_button_3:setPosition(540, 790)
	panel.Text_button_4:setPosition(540, 630)
	panel.Text_desc:setString(question.question)
	panel.Text_button_1:setString(question.answer1)
	panel.Button_1:setVisible(question.answer1 ~= nil and question.answer1 ~= "")
	panel.Text_button_2:setString(question.answer2)
	panel.Button_2:setVisible(question.answer2 ~= nil and question.answer2 ~= "")
	panel.Text_button_3:setString(question.answer3)
	panel.Button_3:setVisible(question.answer3 ~= nil and question.answer3 ~= "")
	panel.Text_button_4:setString(question.answer4)
	panel.Button_4:setVisible(question.answer4 ~= nil and question.answer4 ~= "")
    panel.Image_rightResult:setVisible(false)
    panel.Image_noResult:setVisible(false)
    panel.Image_errorResult:setVisible(false)

	local flag1= question.rightAnswer==question.answer1
	local flag2= question.rightAnswer==question.answer2
	local flag3= question.rightAnswer==question.answer3
	local flag4= question.rightAnswer==question.answer4

	-- 交换按钮位置
	for i=1,10 do
		self:changeBtn()
	end
	if flag1==true then 
		self.rightAnswerPositionX=panel.Button_1:getPositionX()
		self.rightAnswerPositionY=panel.Button_1:getPositionY()
	elseif flag2==true then
		self.rightAnswerPositionX=panel.Button_2:getPositionX()
		self.rightAnswerPositionY=panel.Button_2:getPositionY()
	elseif flag3==true then
		self.rightAnswerPositionX=panel.Button_3:getPositionX()
		self.rightAnswerPositionY=panel.Button_3:getPositionY()
	elseif flag4==true then
		self.rightAnswerPositionX=panel.Button_4:getPositionX()
		self.rightAnswerPositionY=panel.Button_4:getPositionY()
	end

	panel.Button_1:releaseFunc(function ()
		local showPositionX=panel.Button_1:getPositionX()
		local showPositionY=panel.Button_1:getPositionY()
		if self.btnCanClick==true then 
			self:btnFunction(flag1,showPositionX,showPositionY)
		end
	end)
	panel.Button_2:releaseFunc(function ()
		local showPositionX=panel.Button_2:getPositionX()
		local showPositionY=panel.Button_2:getPositionY()
		if self.btnCanClick==true then 
			self:btnFunction(flag2,showPositionX,showPositionY)
		end
	end)
	panel.Button_3:releaseFunc(function ()
		local showPositionX=panel.Button_3:getPositionX()
		local showPositionY=panel.Button_3:getPositionY()
		if self.btnCanClick==true then 
			self:btnFunction(flag3,showPositionX,showPositionY)
		end
	end)
	panel.Button_4:releaseFunc(function ()
		local showPositionX=panel.Button_4:getPositionX()
		local showPositionY=panel.Button_4:getPositionY()
		if self.btnCanClick==true then 
			self:btnFunction(flag4,showPositionX,showPositionY)
		end
	end)

	print("正确答案 【" .. question.rightAnswer .. "】")

	self.Panel_kaochang.Text_count:setColor({r = 208, g = 208, b = 208})
	self.Panel_kaochang.Text_count:setString( tostring(self.completeQuestions) .. "/20" )

end

--按钮回调
function MidAutumnFestivalLanternRiddleLayer:btnFunction(boolflag,showPositionX,showPositionY)
	print("答题")
	Audio:playEffect("xiaoAnNiu")
	self.btnCanClick=false
	if boolflag==true then 
		self.trueQuestions=self.trueQuestions+1
		self:answerTips(1,showPositionX,showPositionY)
	else
		self:answerTips(2,showPositionX,showPositionY)
	end
end
--答案提示 type 0--没作答时  1  正确时 2 错误时
function MidAutumnFestivalLanternRiddleLayer:answerTips(type,showPositionX,showPositionY)
	local pauseSchedulerAct=cc.CallFunc:create(function ()
		if self._handle ~= nil then
			self:pauseSchedulerAndActions(self._handle)
		end
	end)
	local showRightAnswerAct=cc.CallFunc:create(function ()
		self:showRightAnswer(self.rightAnswerPositionX,self.rightAnswerPositionY)
	end)
	local showErrorAnswerAct=cc.CallFunc:create(function ()
		self:showErrorAnswer(showPositionX,showPositionY)
	end)
	local showNoAnswerAct=cc.CallFunc:create(function ()
		self.Panel_kaochang.Panel_answer.Image_noResult:setVisible(true)
	end)
	local resumeSchedulerAct=cc.CallFunc:create(function ()
		if self._handle ~= nil then
			self:resumeSchedulerAndActions(self._handle)
		end
	end)
	local starNextAnswerAct=cc.CallFunc:create(function ()
		self:startGame()
		print("下一题")
	end)

	local seqAct0=cc.Sequence:create(pauseSchedulerAct,showRightAnswerAct,cc.DelayTime:create(0.5),showNoAnswerAct,cc.DelayTime:create(1.5),resumeSchedulerAct,starNextAnswerAct)
	local seqAct1=cc.Sequence:create(pauseSchedulerAct,showRightAnswerAct,cc.DelayTime:create(1),resumeSchedulerAct,starNextAnswerAct)
	local seqAct2=cc.Sequence:create(pauseSchedulerAct,showErrorAnswerAct,cc.DelayTime:create(0.5),showRightAnswerAct,cc.DelayTime:create(1.5),resumeSchedulerAct,starNextAnswerAct)
	if type==0 then 
		self:runAction(seqAct0)
	elseif type==1 then 
		self:runAction(seqAct1)
	elseif type==2 then
		self:runAction(seqAct2)
	end
end

--界面更新
function MidAutumnFestivalLanternRiddleLayer:updateTime(dt)
	local currTime = GetTime()
	local sec = 0
	sec = math.floor(20 - (currTime - self.startTime))
	if sec <= 0 then
		if self.completeQuestions>20 then 
			self:endGame()
		else
			self:answerTips(0)
		end
	end
	self.Panel_kaochang.Text_time_num:setString(sec)
end
--开始前界面初始化
function MidAutumnFestivalLanternRiddleLayer:initBeforeUI()
	self.Image_back:setVisible(false)
	self.Image_bg:setVisible(false)
	self.Panel_kaochang:setVisible(false)
	self.Image_desc.Button_startAnswer:setVisible(true)
	self.Image_desc.Button_cancel:setVisible(true)
	self.Panel_text:setVisible(false)
	self.Panel_kaochang.Panel_category.Text_Title:setString("猜灯谜")
	self.Text_desc:setString("灯谜答题一共20题，每题限时20秒，答完所有灯谜后找灯谜老人领取奖励。")
	self.Image_desc.Button_cancel:releaseFunc(function ()
		self:hideLayer()
	end)
	self.Image_desc.Button_startAnswer:releaseFunc(function ()
		--if User:getRole():getTimeLimitFlag("中秋答题")==1 then 
		--else

			self.Image_desc:setVisible(false)
			self.Panel_kaochang:setVisible(true)
			self.Image_back:setVisible(true)
			self.Image_bg:setVisible(true)
			self.Text_desc:setVisible(false)
			self.Image_desc.Button_startAnswer:setVisible(false)
			self.Image_desc.Button_cancel:setVisible(false)
			self.isStart=true
			self:startGame()
		--end
		
	end)
end
--答题后界面初始化
function MidAutumnFestivalLanternRiddleLayer:initAfterUI()
	self.Image_back:setVisible(false)
	self.Image_bg:setVisible(false)
	self.Panel_kaochang:setVisible(false)
	self.Image_desc:setVisible(true)
	self.Panel_text:setVisible(true)
	self.Text_desc:setVisible(true)
	self.Image_desc.Button_startAnswer:setVisible(false)
	self.Image_desc.Button_cancel:setVisible(false)
	self.Text_desc:setString("今日已答完所有灯谜，本次灯谜结果如下。")
	self.Panel_text.Text_true_num:setString(tostring(self.trueQuestions))
	self.Panel_text.Text_error_num:setString(tostring(self.completeQuestions-self.trueQuestions))
	self.Panel_text.Text_score_num:setString(tostring(self.trueQuestions*5))
	self.Panel_text.Text_all:setString("稍后可别忘了找灯谜老人领取奖励。")
	
	self.Panel_text:releaseFunc(function()
		self:hideLayer()
	end)

end
--获取奖励



function MidAutumnFestivalLanternRiddleLayer:hideLayer()
	PopupLayerController:hideLayer("MidAutumnFestivalLanternRiddleLayer",function (layer)
		layer:hide()
	end)
end

-- 交换按钮位置
function MidAutumnFestivalLanternRiddleLayer:changeBtn()
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

function MidAutumnFestivalLanternRiddleLayer:getquestionData(index)
	return tonumber(string.split(self.questionsData, ";")[index])
end

Helper:classDefNodeGetInstance(MidAutumnFestivalLanternRiddleLayer)

return MidAutumnFestivalLanternRiddleLayer00000000000000