--[[
    判断角色拥有某类型神兵是否满足指定数量判断
]]

local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

--@SuperType [src.app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition#BaseCondition]
local ShenBingFirstTypeCountCondition = {}

function ShenBingFirstTypeCountCondition:create(...)
    local p = ShenBingFirstTypeCountCondition.new()
    p:init(...)
    return p
end

function ShenBingFirstTypeCountCondition:check()
    local count = 0
    local shenBingItems = self:getRole():getAttr("shenBingItems")
    for i,v in ipairs(shenBingItems) do
		if v.type == self:getAttrId() then
            count = count + 1
        end
	end 
    return self:compare(count)
end

return newClass("ShenBingFirstTypeCountCondition", {BaseCondition}, ShenBingFirstTypeCountCondition)
000000000000000