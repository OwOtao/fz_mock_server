local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local FistFootBranchLvCondition = {}

function FistFootBranchLvCondition:create(...)
    local p = FistFootBranchLvCondition.new()
    p:init(...)
    return p
end

function FistFootBranchLvCondition:check()
    return self:compare(self:getRole():getFistFootSystem():getBranchLv(self:getAttrId()))
end

return newClass("FistFootBranchLvCondition", {BaseCondition}, FistFootBranchLvCondition)
0000