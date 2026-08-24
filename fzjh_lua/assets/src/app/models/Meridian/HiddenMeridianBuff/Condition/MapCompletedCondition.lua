local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local MapCompletedCondition = {}

function MapCompletedCondition:create(...)
    local p = MapCompletedCondition.new()
    p:init(...)
    return p
end

function MapCompletedCondition:check()    
    local mapId = self:getAttrId()

    return self:compare(self:getRole():isMapCompleted(mapId) and 1 or 0)
end

return newClass("MapCompletedCondition", {BaseCondition}, MapCompletedCondition)
000