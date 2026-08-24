local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local HiddenMeridianAttrCondition = {}

function HiddenMeridianAttrCondition:create(...)
    local p = HiddenMeridianAttrCondition.new()
    p:init(...)
    return p
end

function HiddenMeridianAttrCondition:check()
    local value = 0
    if self:getAttrId() == "chartLv" then
        value = self:getRole():getHiddenMeridianSystem():getHiddenMeridianChartLv()
    elseif self:getAttrId() == "acupointActivatedNum" then
        value = self:getRole():getHiddenMeridianSystem():getAcupointActivatedNum()
    else
        error("HiddenMeridianAttrCondition:check() error 隐脉系统类解锁条件 属性id未定义"..self:getAttrId())
    end

    return self:compare(value)
end

return newClass("HiddenMeridianAttrCondition", {BaseCondition}, HiddenMeridianAttrCondition)
0000000000000