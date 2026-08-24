local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local TeacherBuildAttrCondition = {}

function TeacherBuildAttrCondition:create(...)
    local p = TeacherBuildAttrCondition.new()
    p:init(...)
    return p
end

function TeacherBuildAttrCondition:check()
    local value = 0
    if self:getRole():hasFamily() then
        if self:getAttrId() == "classlevel" then
            value = self:getRole():getTeacherBuildSystem():getFeatClassLevel()
        elseif self:getAttrId() == "featscount" then
            value = self:getRole():getTeacherBuildSystem():getFeatScount()
        else
            error("TeacherBuildAttrCondition:check() error 师门培养类解锁条件 属性id未定义"..self:getAttrId())
        end
    end

    return self:compare(value)
end

return newClass("TeacherBuildAttrCondition", {BaseCondition}, TeacherBuildAttrCondition)
0000000000