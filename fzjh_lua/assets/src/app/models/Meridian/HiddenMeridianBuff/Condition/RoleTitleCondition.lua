local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local RoleTitleCondition = {}

function RoleTitleCondition:create(...)
    local p = RoleTitleCondition.new()
    p:init(...)
    return p
end

function RoleTitleCondition:check()    
    local titleId = self:getAttrId()

    return self:compare(self:getRole():hasBasicTitle(titleId) and 1 or 0)
end

return newClass("RoleTitleCondition", {BaseCondition}, RoleTitleCondition)
00