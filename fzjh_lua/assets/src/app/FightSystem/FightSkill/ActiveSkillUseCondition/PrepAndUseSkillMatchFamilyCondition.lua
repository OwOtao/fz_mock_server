--[[
    指定战斗正在使用准备在指定类型的武学为某门派
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local FamilyFactory = require("app.models.family.FamilyFactory")

local IActiveUseCondition = require("app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition")

local PrepAndUseSkillMatchFamilyCondition = {
    __type = 7
}

function PrepAndUseSkillMatchFamilyCondition:create(skillFirstTypeStr, logicalSymbol, familyIds)
    local p = PrepAndUseSkillMatchFamilyCondition.new()
    p:__init(skillFirstTypeStr, logicalSymbol, familyIds)
    return p
end

function PrepAndUseSkillMatchFamilyCondition:__init(skillFirstTypeStr, logicalSymbol, familyIds)
    self.__skillFirstTypeList = string.split(skillFirstTypeStr, "@")
    self.__logicalSymbol = logicalSymbol
    self.__conFamilyIdList = string.split(familyIds, "@")
end

function PrepAndUseSkillMatchFamilyCondition:getConditionType()
    return "7"
end

--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function PrepAndUseSkillMatchFamilyCondition:matchCondititon(f_character)
    local isMatch = false
    FightUtil:printLog("使用条件类型 7：开始判断")

    for _, skillFirstType in ipairs(self.__skillFirstTypeList) do
        FightUtil:printLog(" └─ 判断条件武学第一类型：" .. skillFirstType)

        local secSkillTypes = SkillClassifyManager:getAllSecondTypesByFirstType(skillFirstType)
        for _, secType in ipairs(secSkillTypes) do
            local match, msg = self:__match(f_character, tonumber(skillFirstType), secType)

            if match then
                FightUtil:printLog(string.format("  └─ 判断角色准备的武学（武学第二类型-%s） 结果 ：%s", secType, tostring(match)))
                isMatch = true
                break
            else
                FightUtil:printLog(string.format("  └─ 判断角色准备的武学（武学第二类型-%s） 结果 ：%s ， 【%s】", secType, tostring(match), msg))
            end
        end

        if isMatch == true then
            break
        end
    end

    return isMatch
end

--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function PrepAndUseSkillMatchFamilyCondition:__match(f_character, firstType, secType)
    local f_skill = f_character:getPrepSkill(secType)

    if f_skill == nil then
        return false, "当前类型未准备"
    end

    if not self:__matchFamily(f_skill) then
        return false, "门派不匹配"
    end

    if not self:__isCurrUseSkill(f_character, f_skill, firstType) then
        return false, "非当前使用武学"
    end

    return true
end

--@skill: [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function PrepAndUseSkillMatchFamilyCondition:__matchFamily(skill)
    if MapIsEmpty(self.__conFamilyIdList) then
        error("使用条件类型7 : 门派id未填写。")
        return
    end

    for _, condFamilyId in ipairs(self.__conFamilyIdList) do
        if skill:isFamily(condFamilyId) then
            return true
        end
    end

    return false
end

--@desc: 判断当前是否正在使用
--@author:Seven
--@time:2022-05-12 16:00:30
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@skill: [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function PrepAndUseSkillMatchFamilyCondition:__isCurrUseSkill(f_character, skill, firstType)
    if firstType < SkillConst.SkillFirstType.NEI_GONG and skill:isAttackSkill() then
        if f_character:getAttackSkill():getId() == skill:getId() then
            return true
        end
    elseif firstType == SkillConst.SkillFirstType.QING_GONG and skill:isDodgeSkill() then
        if f_character:getDodgeSkill():getId() == skill:getId() then
            return true
        end
    elseif firstType == SkillConst.SkillFirstType.NEI_GONG and skill:isNeiGongSkill() then
        if f_character:getNeiGongSkill():getId() == skill:getId() then
            return true
        end
    elseif firstType == SkillConst.SkillFirstType.ZHAO_JIA and skill:isParrySkill() then
        if f_character:getParrySkill():getId() == skill:getId() then
            return true
        end
    end
    return false
end

function PrepAndUseSkillMatchFamilyCondition:getConditionText()
    local firstTypeNameStr = ""
    for i, skillFirstType in ipairs(self.__skillFirstTypeList) do
        local name = SkillClassifyManager:getFirstTypeName(skillFirstType)

        if i == table.getn(self.__skillFirstTypeList) then
            firstTypeNameStr = firstTypeNameStr .. name
        else
            firstTypeNameStr = firstTypeNameStr .. name .. "或"
        end
    end

    local familyNameStr = ""
    for i, familyId in ipairs(self.__conFamilyIdList) do
        local familyFactor = FamilyFactory:getFamilyFactor(familyId)
        if i == table.getn(self.__conFamilyIdList) then
            familyNameStr = familyNameStr .. "[" .. familyFactor:getName() .. "]"
        else
            familyNameStr = familyNameStr .. "[" .. familyFactor:getName() .. "]或"
        end
    end

    local resStr = string.format("战斗中使用的%s武学属于%s", firstTypeNameStr, familyNameStr)

    return resStr
end

return newClass("PrepAndUseSkillMatchFamilyCondition", {IActiveUseCondition}, PrepAndUseSkillMatchFamilyCondition)
00000