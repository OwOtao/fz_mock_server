local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local HiddenMeridianAttachBuffCondition = {}

function HiddenMeridianAttachBuffCondition:create(...)
    local p = HiddenMeridianAttachBuffCondition.new()
    p:init(...)
    return p
end

function HiddenMeridianAttachBuffCondition:check()
    return self:compare(self:getRole():getHiddenMeridianSystem():getAttachBuffNum(tonumber(self:getAttrId()),tonumber(self:getParam()[1])))
end

return newClass("HiddenMeridianAttachBuffCondition", {BaseCondition}, HiddenMeridianAttachBuffCondition)
00