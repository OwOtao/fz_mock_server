local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local ShenBingSubTypeCountCondition = {}

function ShenBingSubTypeCountCondition:create(...)
    local p = ShenBingSubTypeCountCondition.new()
    p:init(...)
    return p
end

function ShenBingSubTypeCountCondition:check()
    local count = 0
    local shenBingItems = self:getRole():getAttr("shenBingItems")
    for i,v in ipairs(shenBingItems) do
		if v.bType == self:getAttrId() then
            count = count + 1
        end
	end 
    return self:compare(count)
end

return newClass("ShenBingSubTypeCountCondition", {BaseCondition}, ShenBingSubTypeCountCondition)
000000000000