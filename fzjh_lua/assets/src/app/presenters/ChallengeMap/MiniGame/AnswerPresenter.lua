local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")

local AnswerPresenter = class("AnswerPresenter", cc.Layer)

function AnswerPresenter:create()
    local p = AnswerPresenter:new()
    p:init()
    return p
end

function AnswerPresenter:init()
    self.__ui = require("app.views.ui.ChallengeMapUI.MiniGame.AnswerUI"):create()
    self.__ui:addTo(self)

    self.__ui:hideUI()
end

function AnswerPresenter:showLayer()
    self:setTitle()

    self:startGame()

    self.__ui:showUI()
end

function AnswerPresenter:setFinishCallbackFunc(fishFinishCallback)
    self.__fishFinishCallback = fishFinishCallback
end

function AnswerPresenter:setAnswerData(answerData)
    self.__answerData = answerData
end

function AnswerPresenter:setRole(role)
    self.__role = role
end

function AnswerPresenter:setTitle()
    self.__ui:setTitle(self.__answerData.title)
end

function AnswerPresenter:setTopicCountText()
    self.__ui:setTopicCountText(self.__questionIndex .. "/" .. self.__answerData.numberquestions)
end

function AnswerPresenter:startGame()
    self.__btnCanClick = true

    self.__startTime = GetTime()

    -- 更新剩余时间
    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self._handle =
        self:schedule(
        function(ft)
            self:updateTime()
        end,
        0.1
    )

    self.__questionMap = {}

    self:createRandomQuestion()

    self.__questionIndex = 1

    self:startAnswer()

    self:setTopicCountText()
end

function AnswerPresenter:updateTime()
    local currTime = GetTime()

    local sec = 0

    sec = math.floor(self.__answerData.endtime - (currTime - self.__startTime))

    if sec <= 0 then
        sec = 0

        PopText("本次挑战已结束")

        self:__finishGame()

        return
    end

    self.__ui:setTimeText(sec)
end

--@desc: 生成随机题库
--@author:LvBin
--@time:2024-01-05 18:17:45
--@return
function AnswerPresenter:createRandomQuestion()
    local questionMap = ChallengeMapResource:getInstance():getQuestionMapByBankId(self.__answerData.questionbankid)

    local questionCount = self.__answerData.numberquestions

    if questionCount > #questionMap then
        error("题目数量大于题库数量")
    end

    for i = 1, questionCount do
        local randomQuestion = table.remove(questionMap, math.random(1, #questionMap))

        table.insert(self.__questionMap, randomQuestion)
    end
end

function AnswerPresenter:startAnswer()
    local currQuestion = self.__questionMap[self.__questionIndex]

    local nums = {1, 2, 3, 4}

    local randomNums = {}

    for i = 1, 4 do
        table.insert(randomNums, table.remove(nums, math.random(1, #nums)))
    end

    local buttonText1 = currQuestion["answer" .. randomNums[1]]

    local buttonText2 = currQuestion["answer" .. randomNums[2]]

    local buttonText3 = currQuestion["answer" .. randomNums[3]]

    local buttonText4 = currQuestion["answer" .. randomNums[4]]

    local answerRow = self.__ui:getPanelAnswer()

    answerRow.Text_desc:setString(currQuestion.question)

    answerRow.Button_1.Text_buttonName:setString(buttonText1)

    answerRow.Button_2.Text_buttonName:setString(buttonText2)

    answerRow.Button_3.Text_buttonName:setString(buttonText3)

    answerRow.Button_4.Text_buttonName:setString(buttonText4)

    answerRow.Button_1.Image_right:setVisible(false)

    answerRow.Button_1.Image_error:setVisible(false)

    answerRow.Button_2.Image_right:setVisible(false)

    answerRow.Button_2.Image_error:setVisible(false)

    answerRow.Button_3.Image_right:setVisible(false)

    answerRow.Button_3.Image_error:setVisible(false)

    answerRow.Button_4.Image_right:setVisible(false)

    answerRow.Button_4.Image_error:setVisible(false)

    answerRow.Button_1:releaseFunc(
        function()
            if self.__btnCanClick == true then
                self:btnFunction(buttonText1 == currQuestion.rightAnswer, answerRow.Button_1)
            end
        end
    )

    answerRow.Button_2:releaseFunc(
        function()
            if self.__btnCanClick == true then
                self:btnFunction(buttonText2 == currQuestion.rightAnswer, answerRow.Button_2)
            end
        end
    )

    answerRow.Button_3:releaseFunc(
        function()
            if self.__btnCanClick == true then
                self:btnFunction(buttonText3 == currQuestion.rightAnswer, answerRow.Button_3)
            end
        end
    )

    answerRow.Button_4:releaseFunc(
        function()
            if self.__btnCanClick == true then
                self:btnFunction(buttonText4 == currQuestion.rightAnswer, answerRow.Button_4)
            end
        end
    )
end

function AnswerPresenter:btnFunction(isRight, button)
    self.__btnCanClick = false

    button.Image_right:setVisible(isRight)

    button.Image_error:setVisible(not isRight)

    self.__questionIndex = self.__questionIndex + 1

    if isRight then
        local itemId = Helper:RandomByWeight(self.__answerData.award, 2, 1)

        self.__role:addItemCount(itemId, 1)

        PopText("成功获得" .. Item:getOneItemByKey(itemId).name)
    else
        PopText("失败了，请再次尝试")
    end

    self:delayFunc(
        0.5,
        function()
            if self.__questionIndex > self.__answerData.numberquestions then
                PopText("本次小挑战结束")
                
                self:__finishGame()
            else
                self.__btnCanClick = true

                self:startAnswer()

                self:setTopicCountText()
            end
        end
    )
end

function AnswerPresenter:hideLayer()
    PopupLayerController:hideLayer(
        "AnswerPresenter",
        function(layer)
            self.__ui:hideUI()
        end
    )
end

function AnswerPresenter:__finishGame()
    if self.__fishFinishCallback then
        self.__fishFinishCallback()
    end

    if self._handle ~= nil then
        self:unschedule(self._handle)
        self._handle = nil
    end

    self:hideLayer()


end

Helper:classDefNodeGetInstance(AnswerPresenter)
return AnswerPresenter
000