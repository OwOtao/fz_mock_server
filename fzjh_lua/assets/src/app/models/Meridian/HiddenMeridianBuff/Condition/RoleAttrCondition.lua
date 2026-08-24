local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local RoleAttrCondition = {}

function RoleAttrCondition:create(...)
    local p = RoleAttrCondition.new()
    p:init(...)
    return p
end

function RoleAttrCondition:check()
    return self:compare(self:getRole():getAttr(self:getAttrId()))
end

return newClass("RoleAttrCondition", {BaseCondition}, RoleAttrCondition)
000000000000