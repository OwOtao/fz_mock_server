local abstract = require("third.class.abstract")

local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

local IConditions = require("app.models.Meridian.HiddenMeridianBuff.Conditions.IConditions")

local AbsConditions = {}

--@desc: 检查条件是否满足
--@author:LvBin
--@time:2025-02-24 19:30:35
--@return
function AbsConditions:check()
    if MapIsEmpty(self.__conditions) then
        return true
    end

    for i,conditionList in ipairs(self.__conditions) do
        if not self:checkConditionList(conditionList) then
            return false
        end
    end  

    return true
end

--@desc: 条件列表满足一个即可
--@author:LvBin
--@time:2025-02-24 19:29:59
--@conditionList: 
--@return
function AbsConditions:checkConditionList(conditionList)
    if MapIsEmpty(conditionList) then
        return true
    end
    
    for i,conditionId in ipairs(conditionList) do
        if self:checkCondition(conditionId) then
            return true
        end
    end  

    return false
end

function AbsConditions:getConditionRes(conditionId)
end

function AbsConditions:checkCondition(conditionId)
    local conditionRes = self:getConditionRes(conditionId)

    local cType = conditionRes.type

    local classPath = "app.models.Meridian.HiddenMeridianBuff.Condition."

    if cType == HiddenMeridianConstants.ConditionType.DirectPass then
        classPath = classPath .. "DirectPassCondition"
    elseif cType == HiddenMeridianConstants.ConditionType.RoleAttr then
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

    return condition:checkCondition()
end

return abstract("AbsConditions", {IConditions}, AbsConditions)

0000000