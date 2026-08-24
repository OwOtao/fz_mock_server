local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local FistFootAttrCondition = {}

function FistFootAttrCondition:create(...)
    local p = FistFootAttrCondition.new()
    p:init(...)
    return p
end

function FistFootAttrCondition:check()
    local value = 0
    if self:getAttrId() == "jqdamagezhang" then
        value = self:getRole():getFistFootSystem():getBranchJqdamage("10020")
    elseif self:getAttrId() == "basislv" then
        value = self:getRole():getFistFootSystem():getReflectLv()
    else
        error("FistFootAttrCondition:check() error 拳脚培养类解锁条件 属性id未定义"..self:getAttrId())
    end

    return self:compare(value)
end

return newClass("FistFootAttrCondition", {BaseCondition}, FistFootAttrCondition)
00000