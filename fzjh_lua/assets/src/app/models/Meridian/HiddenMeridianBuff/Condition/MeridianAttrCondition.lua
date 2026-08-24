local newClass = require("third.class.NewClass")

local Meridian = require("app.models.Meridian.Meridian")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local MeridianAttrCondition = {}

function MeridianAttrCondition:create(...)
    local p = MeridianAttrCondition.new()
    p:init(...)
    return p
end

function MeridianAttrCondition:check()
    local value = 0
    if self:getAttrId() == "lv" then
        value = Meridian:getMeridianLv(self:getRole():getAttr("meridianExp"))
    elseif self:getAttrId() == "yinjiNum" then
        value = #self:getRole():getMeridianSystem():getCurrentPageMeridianImprintings()
    else
        error("MeridianAttrCondition:check() error 经脉系统类解锁条件 属性id未定义"..self:getAttrId())
    end

    return self:compare(value)
end

return newClass("MeridianAttrCondition", {BaseCondition}, MeridianAttrCondition)
0000000000000