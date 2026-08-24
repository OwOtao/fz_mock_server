local QuestionAndAnswerPresenters = class("QuestionAndAnswerPresenters", cc.Layer)

function QuestionAndAnswerPresenters:create()
    local p = QuestionAndAnswerPresenters:new()
    p:init()
    return p
end

function QuestionAndAnswerPresenters:init()
    self._actionUI = require("app.views.ui.ActionUI.QuestionAndAnswerUI"):create()

    self._actionUI:addTo(self)

    local QuestionAndAnswer = require("app.models.Action.QuestionAndAnswer")

    self._interactor = QuestionAndAnswer:create()
end

function QuestionAndAnswerPresenters:showLayer()
    local startGame = function()
        self._isFirst = nil
        self._actionUI:showUI()
        self:setTitle()
        self:setResultPanelVisible(false)
        self:setQuestionPanelVisible(true)
        self:showQuestionAndAnswer()
        self:updateUI()
    end

    local getReward = function()
        self._actionUI:showUI()
        self:setTitle()
        self:gameOver()
    end

    local failFunc = function()
        self:hideLayer()
    end

    self._interactor:setRole(User:getRole())
    self._interactor:initData(startGame,getReward,failFunc)
end

function QuestionAndAnswerPresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end

function QuestionAndAnswerPresenters:setTitle()
    self._actionUI:setTitleText(self._interactor:getActionName())
end

function QuestionAndAnswerPresenters:setResultPanelVisible(visible)
    self._actionUI:setResultPanelVisible(visible)
end

function QuestionAndAnswerPresenters:setQuestionPanelVisible(visible)
    self._actionUI:setQuestionPanelVisible(visible)
end

function QuestionAndAnswerPresenters:showQuestionAndAnswer()
    
    local question = self._interactor:getQuestion()
    print("当前第"..tostring(self._interactor:getCurrQuestionIndex()).."题")
    Helper:print_lua_table(question)
    print("---------------------------------------------")
    self._currAnswerNum = self._interactor:getCurrQuestionAnswerNum()

    self._endQuestionTime = GetTime() + self._interactor:getAnswerTime()

    if not self._isFirst then
        self._isFirst = true
        self._endQuestionTime = self._endQuestionTime + 3
    end

    self._nextQuestionTime = self._endQuestionTime + self._interactor:getWaitTime()

    if self._currAnswerNum == 3 then
        self._actionUI:showThreeAnswers()
    else
        self._actionUI:showFourAnswers()
    end

    self._actionUI:hideAnswerResult()

    self._actionUI:setQuestionTipsText("")

    self._actionUI:setQuestionNumText(self._interactor:getCurrQuestionIndex().."/"..self._interactor:getQuestionNum())

    self._actionUI:setQuestionDescText(question.question)

    self._actionUI:setRightResultVisible(false)

    self._actionUI:setRrrorResultVisible(false)
    
    self._currRightAnswerIndex = 1

    
    for i = 1, self._currAnswerNum do
        if self._interactor:checkAnswerIsRight(question["answer"..tostring(i)]) then
            self._currRightAnswerIndex = i
        end
    end

    for i = 1, self._currAnswerNum do
        self._actionUI:setAnswerText(i,question["answer"..tostring(i)])
        self._actionUI:setAnswerFunc(i,function()
            if not self._answerState then
                if self._currRightAnswerIndex == i then
                    self._answerState = 1
                    self._actionUI:showAnswerResult("Image/UI/QuestionAndAnswerUI/8.png")
                    self._actionUI:setRightResultVisible(true)
                    self._actionUI:setRrrorResultVisible(false)
                    self._actionUI:setRightResultPosY(self._actionUI:getAnswerPos(self._currRightAnswerIndex,self._currAnswerNum))
                    self._interactor:setRightAnswerNum(self._interactor:getRightAnswerNum() + 1)
                else
                    self._actionUI:setRrrorResultVisible(true)
                    self._actionUI:setRightResultVisible(true)
                    self._actionUI:setRightResultPosY(self._actionUI:getAnswerPos(self._currRightAnswerIndex,self._currAnswerNum))
                    self._actionUI:setRrrorResultPosY(self._actionUI:getAnswerPos(i,self._currAnswerNum))
                    self._answerState = -1
                    self._actionUI:showAnswerResult("Image/UI/QuestionAndAnswerUI/7.png")
                end

                self._currRightAnswerIndex = nil

                self._currAnswerNum = nil

                self._nextQuestionTime = GetTime() + self._interactor:getWaitTime()
            end
        end)
    end
end

function QuestionAndAnswerPresenters:reStart()
    self._isFirst = nil
    self._interactor:initData()
    self:setResultPanelVisible(false)
    self:setQuestionPanelVisible(true)
    self:showQuestionAndAnswer()
    self:updateUI()
end

function QuestionAndAnswerPresenters:gameOver()
    self:setQuestionPanelVisible(false)
    self:setResultPanelVisible(true)
    self._actionUI:setResultTitle(self._interactor:getActionName())
    self._actionUI:setRightNumText("本次正确回答："..tostring(self._interactor:getRightAnswerNum()).."条")
    self._actionUI:setErrorNumText("本次错误回答："..tostring(self._interactor:getQuestionNum() - self._interactor:getRightAnswerNum()).."条")

    if self._interactor:checkIsPass() then
        self._actionUI:setResultButtonName(1,"领取奖励")
        self._actionUI:setResultButtonFunc(1,function()
            self._interactor:getReward(function()
                self:hideLayer()
            end)
        end)
        self._actionUI:setResultButtonName(2,"离开")
        self._actionUI:setResultButtonFunc(2,function()
            self:hideLayer()
        end)
    else
        self._actionUI:setResultButtonName(1,"再次挑战")
        self._actionUI:setResultButtonFunc(1,function()
            self:reStart()
        end)
        self._actionUI:setResultButtonName(2,"离开")
        self._actionUI:setResultButtonFunc(2,function()
            self:hideLayer()
        end)
    end
end

function QuestionAndAnswerPresenters:updateUI()
    if not self.schedule_up then
        self.schedule_up = self:schedule(function(dt)
            if GetTime() > self._nextQuestionTime then
                self._interactor:finishCurrQuestion()
                self._answerState = nil

                if self._interactor:isGameOver() then
                    self:unschedule(self.schedule_up)
                    self.schedule_up = nil
                    self._interactor:gameOver(function()
                        self:gameOver()
                    end)
                    return
                end
                
                self:showQuestionAndAnswer()
                return
            end

            if GetTime() > self._endQuestionTime or self._answerState then
                if self._answerState == nil then
                    self._answerState = 0
                    self._actionUI:setAnswerTimeText("0")
                    self._actionUI:showAnswerResult("Image/UI/QuestionAndAnswerUI/3.png")
                    self._actionUI:setRightResultVisible(true)
                    self._actionUI:setRightResultPosY(self._actionUI:getAnswerPos(self._currRightAnswerIndex,self._currAnswerNum))
                    self._currRightAnswerIndex = nil
                    self._currAnswerNum = nil
                end

                if self._interactor:getCurrQuestionIndex() + 1 <= self._interactor:getQuestionNum() then
                    self._actionUI:setQuestionTipsText(tostring(Helper:mathFloor(self._nextQuestionTime - GetTime()) + 1).."秒后进入下一题")
                end

                return
            end

            local time = Helper:mathFloor(self._endQuestionTime - GetTime())

            if time > self._interactor:getAnswerTime() then
                time = self._interactor:getAnswerTime()
            end

            self._actionUI:setAnswerTimeText(tostring(time))
        end,0.1)
    end 
end

function QuestionAndAnswerPresenters:setActionId(actionId)
    self._interactor:setActionId(actionId)
end


function QuestionAndAnswerPresenters:hideLayer()
    PopupLayerController:hideLayer(
        "QuestionAndAnswerPresenters",
        function(layer)
            self._actionUI:hideUI()
        end
    )
end

Helper:classDefNodeGetInstance(QuestionAndAnswerPresenters)

return QuestionAndAnswerPresenters
0000000