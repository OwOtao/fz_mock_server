-- 琴音助功玩法
local SoundAssistsLayer = class("SoundAssistsLayer", LayerEx)
local soundResource = require("script.others.shiti")["shiti"]

function SoundAssistsLayer:create()
	local p = SoundAssistsLayer:new()
	p:init()
	return p
end

function SoundAssistsLayer:init()
	self._UI = require("Layer/SoundAssistsUI/SoundAssistsUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

    self.audioName = nil
    self.beingQuestion = nil
    self.map = nil
    self.environment = nil
    self.questionTime = nil --每题时间（秒）
    self.questionNum = nil --题目数量
    self.needNum = nil --成功需要答对的题目数量
    self.succResult = nil --成功结果
    self.failedResult = nil --失败结果

    self.currQuestionNum = nil --当前回答过的题目数量
    self.rightQuestionNum = nil --回答对的题目数量

    self:setVisible(false)
end

function SoundAssistsLayer:hideLayer()
    PopupLayerController:hideLayer("SoundAssistsLayer", function(layer)
        layer:hide()
    end)
end

function SoundAssistsLayer:showLayer(map,environment,questionTime,questionNum,needNum,succResult,failedResult)
    self.map = map
    self.environment = environment
    self.questionTime = questionTime
    self.questionNum = questionNum
    self.needNum = needNum
    self.succResult = succResult
    self.failedResult = failedResult

    self.currQuestionNum = 0
    self.rightQuestionNum = 0

    -- 更新剩余时间
    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self:startUi()

    self:show()	
end

function SoundAssistsLayer:updateTime()
    local currTime = GetTime()
	local num = 0

    if self.startTime == nil then
        return
    end

	num = math.floor(self.questionTime - (currTime - self.startTime))

	if num <= 0 then
		num = 0

        self.currQuestionNum = self.currQuestionNum + 1
        if self.beingQuestion then
            self:RichPrintResultText(self.beingQuestion.nothingText)
        end
        -- self:delayFunc(0.5, function()
            self:refreshQuestion()
        -- end)
        return
	end

	self.Panel_1.Text_time:setString("剩余时间："..num.."秒")
end

--刷新题目
function SoundAssistsLayer:refreshQuestion()
    if self.currQuestionNum >= self.questionNum then
        --答题结束 计算结果
        if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end
        self:hideLayer()
        self:submitResults()
    else
        --未结束，切换题目
        self.startTime = GetTime() --设置开始时间

        local question = self:getRandomQuestion()

        self.beingQuestion = question

        --刷新相关ui
        self:refreshUi(question)

        --播放音频
        self:playAudio(question.audio)
    end
end

--获取一个随机题目
function SoundAssistsLayer:getRandomQuestion()
    local questionList = {}

    for k,v in pairs(soundResource) do
        table.insert( questionList,v)
    end
    return questionList[math.random(1,#questionList)]
end

function SoundAssistsLayer:startUi()
    self:setLeftButton("试听琴音",function()
        self:playAudio("试听")
    end)
    self:setRightButton("开始",function()
        self:refreshQuestion()

        self._handle = self:schedule(function (ft)
            self:updateTime()
        end,0.1)
    end)
    self:setQuestionDsc("")
    self.Panel_1.Text_time:setString("")

    -- self.Panel_1.Text_dec2:setTouchEnabled(true)
    -- self.Panel_1.Text_dec3:setTouchEnabled(true)
    -- self.Panel_1.Text_dec4:setTouchEnabled(true)
    -- self.Panel_1.Text_dec5:setTouchEnabled(true)
    -- self.Panel_1.Text_dec6:setTouchEnabled(true)
    -- self.Panel_1.Text_dec2:releaseFunc(function()
    -- end)
end

--刷新相关ui
function SoundAssistsLayer:refreshUi(question)
    self:setLeftButton(question.choose1,function()
        self.Button_left:setEnabled(false)
        self.Button_right:setEnabled(false)

        self.currQuestionNum = self.currQuestionNum + 1
        if question.choose1 == question.answer then
            self.rightQuestionNum = self.rightQuestionNum + 1
            self:RichPrintResultText(question.trueText)
            print("成功加1")
        else
            self:RichPrintResultText(question.failText)
        end

        -- self:delayFunc(0.5, function()
            self:refreshQuestion()
        -- end)
    end)
    
    self:setRightButton(question.choose2,function()
        self.Button_left:setEnabled(false)
        self.Button_right:setEnabled(false)

        self.currQuestionNum = self.currQuestionNum + 1
        if question.choose2 == question.answer then
            self.rightQuestionNum = self.rightQuestionNum + 1 
            self:RichPrintResultText(question.trueText)
            print("成功加1")
        else
            self:RichPrintResultText(question.failText)
        end

        -- self:delayFunc(0.5, function()
            self:refreshQuestion()
        -- end)
    end)
    self:setQuestionDsc(question.question)
end

function SoundAssistsLayer:setLeftButton(buttonName,func)
    self.Button_left:setEnabled(true)
    self.Button_left.Text_buttonName:setString(buttonName)
    self.Button_left:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function SoundAssistsLayer:setRightButton(buttonName,func)
    self.Button_right:setEnabled(true)
    self.Button_right.Text_buttonName:setString(buttonName)
    self.Button_right:releaseFunc(function()
        if func then
            func()
        end
    end)
end

--设置问题描述文本
function SoundAssistsLayer:setQuestionDsc(text)
    self.Panel_1.Text_dec7:setString(text)
end

--提交结果
function SoundAssistsLayer:submitResults()
    local currRole = self.environment.currRole
    local operations = nil
    if currRole ~= nil then
        operations = currRole.operations
    end

    if MapIsEmpty(operations) then
        if self.environment.currRoom then
            operations = self.environment.currRoom.operations
        end
    end

    if operations == nil then
        return
    end

    if self.rightQuestionNum >= self.needNum then
        --成功
        self.map:doOperationById(self.succResult,operations, self.environment)
    else
        --失败
        self.map:doOperationById(self.failedResult,operations, self.environment)
    end
end

--输出回答结果文本
function SoundAssistsLayer:RichPrintResultText(text)
    RichPrint("main",text)
end

function SoundAssistsLayer:playAudio(audioIndex)
    local audioName
    if audioIndex == "宫" then
        audioName = "qyzg1"
    elseif audioIndex == "商" then
        audioName = "qyzg2"
    elseif audioIndex == "角" then
        audioName = "qyzg3"
    elseif audioIndex == "徵" then
        audioName = "qyzg4"
    elseif audioIndex == "羽" then
        audioName = "qyzg5"
    elseif audioIndex == "试听" then
        audioName = "qyzghe"
    else
        print("SoundAssistsLayer:playAudio  audioIndex = ",audioIndex)
    end

    if audioName == nil then
        return
    end
    
    if self.audioName then
        Audio:stopEffect(self.audioName)
    end

    self.audioName = Audio:playEffect(audioName)
end

Helper:classDefNodeGetInstance(SoundAssistsLayer)

return SoundAssistsLayer000000000000