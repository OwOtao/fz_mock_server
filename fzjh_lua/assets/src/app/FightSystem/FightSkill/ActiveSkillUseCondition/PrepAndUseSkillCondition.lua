--[[
    指定武学准备在指定类型且当前战斗正在使用
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local IActiveUseCondition = require("app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition")

local PrepAndUseSkillCondition = {
    __type = 6
}

function PrepAndUseSkillCondition:create(skillIds, logicalSymbol, skillFirstType)
    local p = PrepAndUseSkillCondition.new()
    p:__init(skillIds, logicalSymbol, skillFirstType)
    return p
end

function PrepAndUseSkillCondition:__init(skillIds, logicalSymbol, skillFirstType)
    self.__skillIdList = string.split(skillIds, "@")

    self.__logicalSymbol = logicalSymbol

    self.__conFirstType = string.split(skillFirstType, "@")
    if MapIsEmpty(self.__conFirstType) then
        error("主动技能使用类型【" .. tostring(self.__type) .. "】判断值(指定武学使用类型)不可为空")
    end
end

function PrepAndUseSkillCondition:getConditionType()
    return "6"
end

--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function PrepAndUseSkillCondition:matchCondititon(f_character)
    if MapIsEmpty(self.__skillIdList) then
        error("使用条件类型6 : 判断技能ID未填写。")
    end

    local isMatch = false

    if self.__logicalSymbol == "等于" then
        for _, skillId in ipairs(self.__skillIdList) do
            for _, firstType in ipairs(self.__conFirstType) do
                FightUtil:printLog(string.format(" └─ 开始判断一类型【%s】：", firstType))
                if self:__isMatchUseOnSkillFirstType(f_character, skillId, firstType) then
                    isMatch = true
                    break
                end
            end
        end
    end

    return isMatch
end

function PrepAndUseSkillCondition:__isMatchUseOnSkillFirstType(f_character, skillId, firstType)
    local isMatch = false

    local secSkillTypes = SkillClassifyManager:getAllSecondTypesByFirstType(firstType)

    for _, secType in pairs(secSkillTypes) do
        local f_skill = f_character:getPrepSkill(secType)

        if f_skill and f_skill:getId() == skillId and self:__isCurrUseSkill(f_character, f_skill, tonumber(firstType)) then
            isMatch = true
        end

        FightUtil:printLog(string.format("  └─【指定[%s - %s]二类型武学使用Id】：%s，【判断条件】%s，【结果】%s", tostring(firstType), tostring(secType), skillId, self.__logicalSymbol, tostring(isMatch)))

        if isMatch then
            break
        end
    end

    return isMatch
end

--@desc: 判断当前是否正在使用
--@author:Seven
--@time:2022-05-12 16:00:30
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@skill: [src.app.models.skill.BasicSkill.BasicActiveSkill#BasicActiveSkill]
function PrepAndUseSkillCondition:__isCurrUseSkill(f_character, skill, firstType)
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

function PrepAndUseSkillCondition:getConditionText()
    local skillTypeName = ""

    for i, firstType in ipairs(self.__conFirstType) do
        local firstName = SkillClassifyManager:getFirstTypeName(firstType)
        if i < table.getn(self.__conFirstType) then
            skillTypeName = skillTypeName .. firstName .. "或"
        else
            skillTypeName = skillTypeName .. firstName
        end
    end

    local skillNameStr = ""

    local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")
    for i, skillId in ipairs(self.__skillIdList) do
        local skill = BasicSkillManager:getBasicSkill(skillId)
        local str
        if i < table.getn(self.__skillIdList) then
            str = "[" .. skill:getName() .. "]或"
        else
            str = "[" .. skill:getName() .. "]"
        end

        skillNameStr = skillNameStr .. str
    end

    local resStr = string.format("战斗中使用%s武学为%s", skillTypeName, skillNameStr)

    return resStr
end
return newClass("PrepAndUseSkillCondition", {IActiveUseCondition}, PrepAndUseSkillCondition)
000000000