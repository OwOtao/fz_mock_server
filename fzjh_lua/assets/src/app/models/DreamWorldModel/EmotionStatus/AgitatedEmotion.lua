--[[
    烦躁
]]
local BaseEmotion = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")
--@SuperType [BaseEmotion]
local AgitatedEmotion = class("AgitatedEmotion", BaseEmotion)

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local EmotionAttr = DreamConst.EmotionAttr

AgitatedEmotion.type = EmotionType.Agitated

function AgitatedEmotion:create(role, mgr)
    local p = AgitatedEmotion:new()
    p:init(role, mgr)
    return p
end

function AgitatedEmotion:onInit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent6, 1)
end

function AgitatedEmotion:onEnter()
    self.role:addBuffV2(205)
end

function AgitatedEmotion:enterFightEvent()
    PopText("你心中烦怒无比，焦躁烦郁，失了分寸。")
end

function AgitatedEmotion:onExit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent6, -1)
    self.role:removeBuffV2(205)
end

return AgitatedEmotion
000000000