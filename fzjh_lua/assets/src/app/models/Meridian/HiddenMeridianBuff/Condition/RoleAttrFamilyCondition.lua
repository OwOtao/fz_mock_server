local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local BookLiterary = require("app.models.book.BookLiterary")

local RoleAttrFamilyCondition = {}

function RoleAttrFamilyCondition:create(...)
    local p = RoleAttrFamilyCondition.new()
    p:init(...)
    return p
end

function RoleAttrFamilyCondition:check()
    local familyId = self:getAttrId()

    return self:compare(self:getRole():getFamilyId() == familyId and 1 or 0)
end

return newClass("RoleAttrFamilyCondition", {BaseCondition}, RoleAttrFamilyCondition)
0000