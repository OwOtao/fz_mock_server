local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local ActiveZhaoExpCondition = {}

function ActiveZhaoExpCondition:create(...)
    local p = ActiveZhaoExpCondition.new()
    p:init(...)
    return p
end

function ActiveZhaoExpCondition:check()
    return self:compare(self:getRole():getSkillZhaoExp(self:getAttrId()))
end

return newClass("ActiveZhaoExpCondition", {BaseCondition}, ActiveZhaoExpCondition)
000000