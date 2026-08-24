local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local AbsConditions = require("app.models.Meridian.HiddenMeridianBuff.Conditions.AbsConditions")

local HiddenMeridianConditions = {}

function HiddenMeridianConditions:create(...)
    local p = HiddenMeridianConditions.new()
    p:__init(...)
    return p
end

function HiddenMeridianConditions:ctor()
end

function HiddenMeridianConditions:__init(role,conditions)
    self.__role = role

    self.__conditions = conditions
end

function HiddenMeridianConditions:getConditionRes(conditionId)
    return HiddenMeridianResources:getConditionRes(conditionId)
end

return newClass("HiddenMeridianConditions", {AbsConditions}, HiddenMeridianConditions)
000000000