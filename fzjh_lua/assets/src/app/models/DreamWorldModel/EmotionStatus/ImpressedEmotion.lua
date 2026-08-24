local BaseEmotion = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")
--@SuperType [BaseEmotion]
local ImpressedEmotion = class("ImpressedEmotion", BaseEmotion)

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local EmotionAttr = DreamConst.EmotionAttr

ImpressedEmotion.type = EmotionType.Impressed

function ImpressedEmotion:create(role, mgr)
    local p = ImpressedEmotion:new()
    p:init(role, mgr)
    return p
end

function ImpressedEmotion:onInit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent2, 2)
end

function ImpressedEmotion:onEnter()
    self.role:addBuffV2(201)
end

function ImpressedEmotion:onExit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent2, -2)
    self.role:removeBuffV2(201)
end

function ImpressedEmotion:getAttackFailDesc()
    return "HIR$N不忍心攻击对方。NOR"
end

function ImpressedEmotion:getTargetAttackFailDesc()
    return "HIR对方不忍心攻击你。NOR"
end

return ImpressedEmotion
00000000000000