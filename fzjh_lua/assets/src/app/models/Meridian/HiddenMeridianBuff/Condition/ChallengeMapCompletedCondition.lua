local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local ChallengeMapSystem = require("app.models.ChallengeMap.ChallengeMapSystem")

local ChallengeMapCompletedCondition = {}

function ChallengeMapCompletedCondition:create(...)
    local p = ChallengeMapCompletedCondition.new()
    p:init(...)
    return p
end

function ChallengeMapCompletedCondition:check()
    local mapId = self:getAttrId()

    local isCompleted = ChallengeMapSystem:getInstance():isCompleted(mapId)

    local value = isCompleted and 1 or 0
    
    return self:compare(value)
end

return newClass("ChallengeMapCompletedCondition", {BaseCondition}, ChallengeMapCompletedCondition)
00000000