local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local DirectPassCondition = {}

function DirectPassCondition:create(...)
    local p = DirectPassCondition.new()
    p:init(...)
    return p
end

function DirectPassCondition:check()
    return self:compare(1)
end

return newClass("DirectPassCondition", {BaseCondition}, DirectPassCondition)
0000000