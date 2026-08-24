local EmotionUtil = {}

local EmotionData = require("script.dreamworld.Emotion")

local DreamSpecialNpc = require("script.dreamworld.dreamspecialnpc")

--@desc 梦境特殊NPC需要触发的效果
local BoseEffects = {}

local NpcTalks = {}

local RandomEvents = {}

local BoxOpenEvents = {}

local EmotionsArray = {}

local function init()
    for k, v in pairs(EmotionData.talk) do
        local npcId = v.npcId

        if NpcTalks[npcId] == nil then
            NpcTalks[npcId] = {}
        end

        local emotionId = v.emotionId

        if NpcTalks[npcId][emotionId] == nil then
            NpcTalks[npcId][emotionId] = {}
        end

        table.insert(NpcTalks[npcId][emotionId], v)
    end

    --@desc 随机事件表初始化
    for k, v in pairs(EmotionData.randomEvents) do
        local emotionId = v.emotionId
        if RandomEvents[emotionId] == nil then
            RandomEvents[emotionId] = {}
        end
        table.insert(RandomEvents[emotionId], v)
    end

    --@desc 瓶罐事件初始化
    for k, v in pairs(EmotionData.boxOpenEvents) do
        local emotionId = v.emotionId
        if BoxOpenEvents[emotionId] == nil then
            BoxOpenEvents[emotionId] = {}
        end
        table.insert(BoxOpenEvents[emotionId], v)
    end

    for k, v in pairs(EmotionData.emotion) do
        EmotionsArray[tonumber(k)] = v.id
    end

    local boseffects = DreamSpecialNpc.boseffects

    for _, v in pairs(boseffects) do
        if BoseEffects[v.npcid] == nil then
            BoseEffects[v.npcid] = {}
        end

        table.insert(BoseEffects[v.npcid], v)
    end
end

init()

function EmotionUtil:getNpcTalks(npcId)
    return NpcTalks[npcId]
end

function EmotionUtil:getRandomEvents()
    return RandomEvents
end

function EmotionUtil:getBoxEvents()
    return BoxOpenEvents
end

function EmotionUtil:getEmotionsArray()
    return EmotionsArray
end

function EmotionUtil:getTalkRule()
    return EmotionData.talkRule
end

function EmotionUtil:getBoseEffects(npcId)
    return Helper:getDef(BoseEffects[npcId], {})
end

return EmotionUtil
00000000000