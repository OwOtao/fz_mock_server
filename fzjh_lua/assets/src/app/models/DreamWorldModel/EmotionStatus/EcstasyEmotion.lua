local BaseEmotion = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")

local BaseEmotion = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")

--@SuperType [BaseEmotion]
local EcstasyEmotion = class("EcstasyEmotion", BaseEmotion)

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local EmotionAttr = DreamConst.EmotionAttr

EcstasyEmotion.type = EmotionType.Ecstasy

function EcstasyEmotion:create(role, mgr)
    local p = EcstasyEmotion:new()
    p:init(role, mgr)
    return p
end

function EcstasyEmotion:onInit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent3, 1)
end

function EcstasyEmotion:onEnter()
    self.role:addBuffV2(203)
    self.role:addBuffV2(204)
end

function EcstasyEmotion:onExit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent3, -1)
    self.role:removeBuffV2(203)
    self.role:removeBuffV2(204)
end

function EcstasyEmotion:getBeHitAtkAddDesc()
    return "HIR你得意忘形，被打中要害NOR"
end

function EcstasyEmotion:getTiliConsumeDesc()
    return "你心里一阵快意，耐力消耗减少了"
end

return EcstasyEmotion
000000000000000