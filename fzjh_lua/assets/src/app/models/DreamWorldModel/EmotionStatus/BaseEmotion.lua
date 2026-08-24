local BaseEmotion = class("BaseEmotion")

local Emotion = require("script.dreamworld.Emotion")

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local EmotionAttr = DreamConst.EmotionAttr

BaseEmotion.type = EmotionType.None

local log = function(...)
    print(...)
end

function BaseEmotion:create(role, mgr)
    local p = BaseEmotion:new()
    p:init(role, mgr)
    return p
end

function BaseEmotion:getName()
    return self.luaData.name
end

function BaseEmotion:init(role, mgr)
    self.role = role

    self.emotionMgr = mgr

    self.luaData = Emotion["emotion"][tostring(self.type)]

    self:onInit()
end

function BaseEmotion:onInit()
end

function BaseEmotion:enter()
    self:onEnter()
    RichPrint("main", Helper:getDef(self.luaData.enterText, ""))
    if self.luaData.enterPopText ~= nil then
        PopText(self.luaData.enterPopText)
    end
end

function BaseEmotion:onEnter()
end

--@desc 情绪退出
function BaseEmotion:exit()
    RichPrint("main", Helper:getDef(self.luaData.leaveText, ""))
    self:onExit()
end

function BaseEmotion:onExit()
end

--@desc 情绪销毁
function BaseEmotion:destory()
    self:onDestory()
end

--@desc 自定义情绪销毁
function BaseEmotion:onDestory()
end

function BaseEmotion:showTips()
    RichPrint("main", Helper:getDef(self.luaData.tipText, ""))
end

--@desc: 交谈时受情绪影响，抽取规则
--@author:Seven_L
--@time:2020-06-12 15:14:21
--@target:
function BaseEmotion:getTalkData(context)
    local target = context.target

    local str = ""

    --#TODO 获取的该交谈数据结构可在初始化的进行优化
    local talks = EmotionUtil:getNpcTalks(target.id)
    if MapIsEmpty(talks) == true then
        error("NPC : " .. target.id .. "没有在情绪表中配置对话内容")
    end

    local randomList = {}
    local talkHistory = self.emotionMgr:getTalkHistory()
    for emotionId, v in pairs(talks) do
        for _, talkLua in pairs(v) do
            if talkHistory[talkLua.id] == nil or talkHistory[talkLua.id] < talkLua.max then
                table.insert(randomList, talkLua)
            end
        end
    end

    if MapIsEmpty(randomList) == true then
        return
    end

    local weightList = {}

    for i, tData in ipairs(randomList) do
        local weight =
            (tData.weight + self.emotionMgr:getAttr(EmotionAttr["talkWeight" .. self.type]) + self.role:getFinalAttr("talkWeight" .. self.type)) *
            (self.emotionMgr:getAttr(EmotionAttr["talkWeightPercent" .. self.type]) + self.role:getFinalAttr("talkWeightPercent" .. self.type))
        weightList[i] = weight

        log("交谈情绪 id ："..tData.id,"权重：".. weight)
    end

    local index = Helper:RandomByWeight(weightList)

    return randomList[index]
end

function BaseEmotion:getType()
    return self.type
end

--@desc: 在房间内生成随机事件
--@author:Seven_L
--@time:2020-06-23 18:28:52
--@context: 上下文对象
function BaseEmotion:getRandomEvent(context)
    local randomEvents = EmotionUtil:getRandomEvents()

    local emotionWeight = {}

    for eId, v in pairs(randomEvents) do
        if emotionWeight[eId] == nil then
            emotionWeight[eId] = 0
        end

        for i, eventData in ipairs(v) do
            local weight =
                (eventData.weight + self.emotionMgr:getAttr(EmotionAttr["randomEventWeight" .. self.type]) + self.role:getFinalAttr("randomEventWeight" .. self.type)) *
                (self.emotionMgr:getAttr(EmotionAttr["randomEventWeightPercent" .. self.type]) + self.role:getFinalAttr("randomEventWeightPercent" .. self.type))

            emotionWeight[eId] = emotionWeight[eId] + weight
            log("随机事件 id ："..eventData.id,"权重：".. weight)
        end
    end

    local emotionId = Helper:RandomByWeight(emotionWeight)

    local events = randomEvents[emotionId]

    local index = Helper:RandomByWeight(events, "weight")

    return events[index]
end

--@desc: 开启一个宝箱随机触发效果
--@author:Seven_L
--@time:2020-06-12 15:07:22
--@target:宝箱对象
function BaseEmotion:getOpenBoxEvent(context)
    local boxEvents = EmotionUtil:getBoxEvents()

    local emotionWeight = {}

    for eId, v in pairs(boxEvents) do
        if emotionWeight[eId] == nil then
            emotionWeight[eId] = 0
        end

        for i, eventData in ipairs(v) do
            local weight =
                (eventData.weight + self.emotionMgr:getAttr(EmotionAttr["boxEventWeight" .. self.type]) + self.role:getFinalAttr("boxEventWeight" .. self.type)) *
                (self.emotionMgr:getAttr(EmotionAttr["boxEventWeightPercent" .. self.type]) + self.role:getFinalAttr("boxEventWeightPercent" .. self.type))
            emotionWeight[eId] = emotionWeight[eId] + weight

            log("开箱事件 id ："..eventData.id,"权重：".. weight)
        end
    end

    local emotionId = Helper:RandomByWeight(emotionWeight)

    local events = boxEvents[emotionId]

    local index = Helper:RandomByWeight(events, "weight")

    return events[index]
end

function BaseEmotion:getAttackFailDesc()
    return ""
end

function BaseEmotion:getAttackAddPercentDesc()
    return ""
end

function BaseEmotion:getTargetAttackFailDesc()
    return ""
end

function BaseEmotion:getBeHitAtkAddDesc()
    return ""
end

function BaseEmotion:getTiliConsumeDesc()
    return ""
end

function BaseEmotion:enterFightEvent()
end

return BaseEmotion
000000