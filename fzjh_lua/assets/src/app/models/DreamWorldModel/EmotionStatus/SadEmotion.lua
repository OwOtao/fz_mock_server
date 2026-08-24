local BaseEmotion = require("app.models.DreamWorldModel.EmotionStatus.BaseEmotion")
--@SuperType [BaseEmotion]
local SadEmotion = class("SadEmotion", BaseEmotion)

local EmotionUtil = require("app.models.DreamWorldModel.EmotionStatus.EmotionUtil")

local DreamConst = require("app.models.DreamWorldModel.DreamConst")

local EmotionType = DreamConst.EmotionType

local EmotionAttr = DreamConst.EmotionAttr

SadEmotion.type = EmotionType.Sad

function SadEmotion:create(role, mgr)
    local p = SadEmotion:new()
    p:init(role, mgr)
    return p
end

function SadEmotion:onInit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent7, 1)
end

function SadEmotion:onEnter()
    self.role:addBuffV2(207)
    self.role:addBuffV2(208)
end

function SadEmotion:enterFightEvent()
    PopText("你毫无战意，对伤害的感知减弱了。")
end

function SadEmotion:onExit()
    self.emotionMgr:addBuffAttr(EmotionAttr.talkWeightPercent7, -1)
    self.role:removeBuffV2(207)
    self.role:removeBuffV2(208)
end

return SadEmotion
0000000000000