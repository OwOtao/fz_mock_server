local BaseEmotion = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")
--@SuperType [BaseEmotion]
local FearEmotion = class("FearEmotion", BaseEmotion)

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local EmotionAttr = DreamConst.EmotionAttr

FearEmotion.type = EmotionType.Fear

function FearEmotion:create(role, mgr)
    local p = FearEmotion:new()
    p:init(role, mgr)
    return p
end

function FearEmotion:onInit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent5, 2)
end

function FearEmotion:onEnter()
    self.role:addBuffV2(200)
    self.role:addBuffV2(202)
end

function FearEmotion:onExit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent5, -2)
    self.role:removeBuffV2(202)
    self.role:removeBuffV2(200)
end

function FearEmotion:getAttackFailDesc()
    return "HIR$N害怕得使不上劲。NOR"
end

function FearEmotion:getAttackAddPercentDesc()
    return "HIR恐惧迫使$N拼死一搏。NOR"
end

return FearEmotion
000000000