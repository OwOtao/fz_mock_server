
local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local AbsConditions = require("app.models.Meridian.HiddenMeridianBuff.Conditions.AbsConditions")

local HiddenMeridianDelConditions = {}

function HiddenMeridianDelConditions:create(...)
    local p = HiddenMeridianDelConditions.new()
    p:__init(...)
    return p
end

function HiddenMeridianDelConditions:ctor()
end

function HiddenMeridianDelConditions:__init(role,conditions,delNodal)
    self.__role = role

    self.__conditions = conditions

    self.__delNodal = delNodal
end

function HiddenMeridianDelConditions:check()
    if MapIsEmpty(self.__conditions) then
        return false
    end

    for i,conditionList in ipairs(self.__conditions) do
        if not self:checkConditionList(conditionList) then
            return false
        end
    end  

    return true
end

function HiddenMeridianDelConditions:getConditionRes(conditionId)
    return HiddenMeridianResources:getDelConditionRes(conditionId)
end

function HiddenMeridianDelConditions:checkConditionList(conditionList)
    if MapIsEmpty(conditionList) then
        return false
    end
    
    for i,conditionId in ipairs(conditionList) do
        local conditionRes = self:getConditionRes(conditionId)

        local nodal = conditionRes.nodal

        LogSystem:log("玄络条件检测","删除条件id : "..conditionId.. "  检测开始")
        LogSystem:log("玄络条件检测","检测节点 : "..self.__delNodal," 条件节点 : "..nodal," 是否相等 : ",tonumber(self.__delNodal) == tonumber(nodal))
        
        if self:checkCondition(conditionId) and tonumber(self.__delNodal) == tonumber(nodal) then
            return true
        end
    end  

    return false
end


return newClass("HiddenMeridianDelConditions", {AbsConditions}, HiddenMeridianDelConditions)
00000000000