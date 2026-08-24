local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local AbsConditions = require("app.models.Meridian.HiddenMeridianBuff.Conditions.AbsConditions")

local HiddenMeridianShowConditions = {}

function HiddenMeridianShowConditions:create(...)
    local p = HiddenMeridianShowConditions.new()
    p:__init(...)
    return p
end

function HiddenMeridianShowConditions:ctor()
end

function HiddenMeridianShowConditions:__init(role,conditions)
    self.__role = role

    self.__conditions = conditions
end

function HiddenMeridianShowConditions:getConditionRes(conditionId)
    return HiddenMeridianResources:getShowConditionRes(conditionId)
end

return newClass("HiddenMeridianShowConditions", {AbsConditions}, HiddenMeridianShowConditions)
00000