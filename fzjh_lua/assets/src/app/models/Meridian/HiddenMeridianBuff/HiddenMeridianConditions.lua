--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-03-06 14:16:01
--]]
local newClass = require("third.class.NewClass")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

local HiddenMeridianConditions = {}

function HiddenMeridianConditions:create(...)
    local p = HiddenMeridianConditions:new()
    p:__init(...)
    return p
end

function HiddenMeridianConditions:ctor()
end

function HiddenMeridianConditions:__init(role,conditions)
    self.__role = role

    self.__conditions = conditions
end

--@desc: 条件列表满足一个即可
--@author:LvBin
--@time:2025-02-24 19:29:59
--@conditionList: 
--@return
function HiddenMeridianConditions:__checkConditionList(conditionList)
    if MapIsEmpty(conditionList) then
        return true
    end
    
    for i,conditionId in ipairs(conditionList) do
        if self:__checkCondition(conditionId) then
            return true
        end
    end  

    return false
end

function HiddenMeridianConditions:__checkCondition(conditionId)
    local conditionRes = HiddenMeridianResources:getConditionRes(conditionId)

    local cType = conditionRes.type

    local classPath = "app.models.Meridian.HiddenMeridianBuff.Condition."

    if cType == HiddenMeridianConstants.ConditionType.RoleAttr then
        classPath = classPath .. "RoleAttrCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.RoleAttrCalculated then
        classPath = classPath .. "RoleAttrCalculatedCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.RoleAttrFight then
        classPath = classPath .. "RoleAttrFightCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.RoleAttrFamily then
        classPath = classPath .. "RoleAttrFamilyCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.SkillLv then
        classPath = classPath .. "SkillLvCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.CanPrepareTypeSkillLvNum then
        classPath = classPath .. "CanPrepareTypeSkillLvNumCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.CanPrepareTypeSkillLvLimitNum then
        classPath = classPath .. "CanPrepareTypeSkillLvLimitNumCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.ActiveZhaoExp then
        classPath = classPath .. "ActiveZhaoExpCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.SelfCreatedSkillNum then
        classPath = classPath .. "SelfCreatedSkillNumCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.SelfCreatedSkillAffixCount then
        classPath = classPath .. "SelfCreatedSkillAffixCountCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.MapCompleted then
        classPath = classPath .. "MapCompletedCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.ChallengeMapCompleted then
        classPath = classPath .. "ChallengeMapCompletedCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.TeacherBuildAttr then
        classPath = classPath .. "TeacherBuildAttrCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.ShenBingSubTypeCount then
        classPath = classPath .. "ShenBingSubTypeCountCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.ShenBingAttrCount then
        classPath = classPath .. "ShenBingAttrCountCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.ShenBingFirstTypeCount then
        classPath = classPath .. "ShenBingFirstTypeCountCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.FistFootAttr then
        classPath = classPath .. "FistFootAttrCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.FistFootBranchLv then
        classPath = classPath .. "FistFootBranchLvCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.MeridianAttr then
        classPath = classPath .. "MeridianAttrCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.HiddenMeridianAttr then
        classPath = classPath .. "HiddenMeridianAttrCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.HiddenMeridianAttachBuff then
        classPath = classPath .. "HiddenMeridianAttachBuffCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.RoleTitle then
        classPath = classPath .. "RoleTitleCondition"
    end
    
    local condition = require(classPath):create(self.__role,conditionRes)

    return condition:check()
end

--@desc: 检查条件是否满足
--@author:LvBin
--@time:2025-02-24 19:30:35
--@return
function HiddenMeridianConditions:check()
    for i,conditionList in ipairs(self.__conditions) do
        if not self:__checkConditionList(conditionList) then
            return false
        end
    end  

    return true
end


return newClass("HiddenMeridianConditions", {}, HiddenMeridianConditions)
000000000000000