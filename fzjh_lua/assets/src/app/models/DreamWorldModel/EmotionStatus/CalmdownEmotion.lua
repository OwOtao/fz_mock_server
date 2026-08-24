--[[
    冷静
]]
local BaseEmotion = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")
--@SuperType [BaseEmotion]
local CalmdownEmotion = class("CalmdownEmotion", BaseEmotion)

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local EmotionAttr = DreamConst.EmotionAttr

CalmdownEmotion.type = EmotionType.Calmdown

function CalmdownEmotion:create(role, mgr)
    local p = CalmdownEmotion:new()
    p:init(role, mgr)
    return p
end

function CalmdownEmotion:onInit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent4, 1)
end

function CalmdownEmotion:onEnter()
    self.role:addBuffV2(206)
end

function CalmdownEmotion:enterFightEvent()
    PopText("你变得更谨慎了，以至于有点畏手畏脚。")
end

function CalmdownEmotion:onExit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent4, -1)
    self.role:removeBuffV2(206)
end

return CalmdownEmotion
000000000