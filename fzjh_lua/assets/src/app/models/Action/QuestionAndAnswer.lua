local class = require("third.class.NewClass")

local rewardState = {
    NOT_PAY = 0,--未充值
    NOT_REWARD = 1, --可领取
    AWARDED = 2, --已领取
}

local QuestionAndAnswer = {}

function QuestionAndAnswer:create()
    return QuestionAndAnswer:new()
end

function QuestionAndAnswer:ctor()
    self._actionId = "QuestionAndAnswer"

    self._name = "猜灯谜"

    self._questions = {}

    self._questionNum = 20

    self._answerTime = 20

    self._waitTime = 2

    self._currQuestionIndex = 1

    self._passNum = 10

    self._rightAnswerNum = 0

    self._rewardId = nil
end

function QuestionAndAnswer:setActionId(actionId)
    self._actionId = actionId
end

function QuestionAndAnswer:setRole(role)
    self._role = role
end

function QuestionAndAnswer:initData(startGameFunc,rewardFunc,failFunc)
    self:__initActionConfig()
    self:__initQuestions()
    self._rightAnswerNum = 0
    self._currQuestionIndex = 1

    HttpManagerEx:getAnswerStatus(self._actionId,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if MapIsEmpty(data) == false then
                if data.status == 0 then
                    if startGameFunc then
                        startGameFunc()
                    end
                elseif data.status == 1 then
                    self:setRightAnswerNum(tonumber(data.pass_num))
                    if rewardFunc then
                        rewardFunc()
                    end
                elseif data.status == 2 then
                    PopText(errmsg)
                    if failFunc then
                        failFunc()
                    end
                end
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function QuestionAndAnswer:getActionName()
    return self._name
end

function QuestionAndAnswer:getQuestion()
    return self._questions[self._currQuestionIndex]
end

function QuestionAndAnswer:getCurrQuestionAnswerNum()
    local num = 0

    local question = self._questions[self._currQuestionIndex]
    for k,v in pairs(question) do
        if string.find( k,"answer") and v then
            num = num + 1
        end
    end

    return num
end

function QuestionAndAnswer:getAnswerTime()
    return self._answerTime
end

function QuestionAndAnswer:getWaitTime()
    return self._waitTime
end

function QuestionAndAnswer:getCurrQuestionIndex()
    return self._currQuestionIndex
end

function QuestionAndAnswer:getQuestionNum()
    return self._questionNum
end

function QuestionAndAnswer:checkAnswerIsRight(answer)
    local currQuestion = self._questions[self._currQuestionIndex]
    local rightAnswer = currQuestion["rightAnswer"]

    return rightAnswer == answer
end

function QuestionAndAnswer:setRightAnswerNum(rightAnswerNum)
    self._rightAnswerNum = rightAnswerNum
end

function QuestionAndAnswer:getRightAnswerNum()
    return self._rightAnswerNum
end

function QuestionAndAnswer:finishCurrQuestion()
    self._currQuestionIndex = self._currQuestionIndex + 1
end

function QuestionAndAnswer:checkIsPass()
    return self._rightAnswerNum >= self._passNum
end

function QuestionAndAnswer:isGameOver()
    return self._currQuestionIndex > self._questionNum
end

function QuestionAndAnswer:gameOver(func)
    if self:checkIsPass() == false then
        if func then
            func()
        end
        return
    end

    HttpManagerEx:setAnswerStatus(self._actionId,1,self._rightAnswerNum,function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            if func then
                func()
            end
        else
            PopText(errmsg)
        end
    end, IS_SHOW_WAITING)
end

function QuestionAndAnswer:getReward(func)
    local rewards = self:__getRewards()

    if MapIsEmpty(rewards) == false then
        if self:__checkCanGetReward(rewards) then
            HttpManagerEx:setAnswerStatus(self._actionId,2,0,function(status, errcode, errmsg, data)
                if status == 200 and errcode == 0 then
                    for i, reward in ipairs(rewards) do
                        if reward.type == "物品" then
                            PopText("获得了 " .. self._role:getOneItemByKey(reward.id).name)
                            self._role:addItemCount(reward.id, reward.value)
                        elseif reward.type == "属性" then
                            if type(self._role:getCHAttrName(reward.id)) == "string" then
                                PopText("获得" .. self._role:getCHAttrName(reward.id) .. tostring(reward.value))
                            end
                            self._role:addAttr(reward.id, reward.value)
                        else
                            error()
                        end
                    end

                    if data.num and data.num > 0 then
	                	PopText("七夕礼券+"..tostring(data.num))
	                end

                    if func then
                        func()
                    end
                else
                    PopText(errmsg)
                end
            end, IS_SHOW_WAITING)
        end
    else
        print("奖励为空 rewardid:",self._rewardId)
    end
end

function QuestionAndAnswer:__getRewards()
    if self._rewardId then
        local rewardArray = RewardManager:getRewardArrayWithRewardSchemeWithoutRestriction(self._rewardId, self._role:getAttr("exp"), self._role:getFinalAttr("luck"), self._role:getKongfu())
        return rewardArray
    end
    
end

function QuestionAndAnswer:__checkCanGetReward(rewards)
    if MapIsEmpty(rewards) == false then
        local items = {}
        for i, reward in ipairs(rewards) do
            if reward.type == "物品" then
                if items[reward.id] then
                    items[reward.id] = items[reward.id] + reward.value
                else
                    items[reward.id] = reward.value
                end
            end
        end

        if self._role:checkCanBuyTwoOrMoreThings(items,true) == false then
            return false
        else
            return true
        end
    end

    return true
end

function QuestionAndAnswer:__initActionConfig()
    local QuestionsAndAnswers = assert(require("script.others.NewQuestionsAndAnswers.lua"))
    local actionConfigs = QuestionsAndAnswers["Sheet1"]

    if MapIsEmpty(actionConfigs) == false then
        for actionId,config in pairs(actionConfigs) do
            if self._actionId == actionId then
                self._name = config.name

                self._questionNum = config.amount

                self._answerTime = config.countDown

                self._waitTime = config.waitingTime

                self._passNum = config.endAmount

                self._startTime = config.startTime

                self._endTime = config.endTime

                self._libraryAddress = config.questionList

                self._rewardId = config.awardid

                return
            end
        end
    end

    assert("答题系统活动未配置 活动名："..tostring(self._actionId))

end


function QuestionAndAnswer:__getActionLibrary()
    local librarys = assert(require("script.others.questionList.lua"))

    if MapIsEmpty(librarys) == false then
        for address,library in pairs(librarys) do
            if self._libraryAddress == address then
                return library
            end
        end
    end

    assert("答题系统活动题库未配置 题库地址："..tostring(self._libraryAddress))
end

function QuestionAndAnswer:__initQuestions()
    self._questions = {}
    
    local library = self:__getActionLibrary()
    local questionNum = 0
    local questions = {}

    for __,question in pairs(library) do
        if question then
            questionNum  = questionNum + 1
            table.insert(questions,question)
        end
    end

    local index_map = {}
    local randomNum = self._questionNum

    while randomNum > 0 do
        local index = math.random(1,questionNum)

        if not index_map[tostring(index)] then
            table.insert(self._questions, questions[index])
            index_map[tostring(index)] = true
            randomNum = randomNum - 1
        end
    end
end

return class("QuestionAndAnswer", {}, QuestionAndAnswer)
00000000000