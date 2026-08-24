--[[
    武学准备条件判断
]]
local newClass = require("third.class.NewClass")

local IActiveUseCondition = require("app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local PrepSkillCondition = {}

function PrepSkillCondition:create(name, logicalSymbol, value)
    local p = self.new()
    p:init(name, logicalSymbol, value)
    return p
end

function PrepSkillCondition:init(skill_id, logicalSymbol, firstSkillType)
    self.__skillIds = string.split(skill_id, "@")
    self.__logicalSymbol = logicalSymbol

    if firstSkillType == nil then
        error("主动技能使用条件判断 - 技能准备判断：条件判断值不可为空")
    end

    if tonumber(firstSkillType) == 0 then
        self.__condFirstSkillTypeIsAll = true
    else
        self.__condFirstSkillTypes = string.split(firstSkillType, "@")
    end
end

function PrepSkillCondition:getConditionType()
    return "3"
end

--@desc: 获取角色技能信息
--@author:Seven
--@time:2021-07-16 12:16:55
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function PrepSkillCondition:matchCondititon(f_character)
    local isMatch = false

    if tostring(self.__logicalSymbol) == tostring(0) or self.__logicalSymbol == "等于" then
        isMatch = self:__isInForce(f_character)
    elseif self.__logicalSymbol == "不等于" then
        isMatch = not self:__isInForce(f_character)
    else
        error("主动技能准备条件判断 -- 判断方式未定义 ：" .. self.__logicalSymbol)
    end

    local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

    FightUtil:printLog("角色武学准备条件判断：【结果】", tostring(isMatch))

    return isMatch
end

function PrepSkillCondition:__isInForce(f_character)
    local isPrepInCondiType = false
    for _, secType in pairs(SKILL_SECOND_TYPE) do
        local f_skill = f_character:getPrepSkill(secType)

        if f_skill then
            local f_skill_id = f_skill:getId()

            for index, skillId in ipairs(self.__skillIds) do
                if f_skill_id == skillId then
                    local firstType = SkillClassifyManager:getFirstTypeBySecondType(secType)

                    if self.__condFirstSkillTypeIsAll == true then
                        isPrepInCondiType = true
                        break
                    elseif self:__includeFirstType(firstType) then
                        isPrepInCondiType = true
                        break
                    end
                end
            end

            if isPrepInCondiType == true then
                break
            end
        end
    end

    return isPrepInCondiType
end

function PrepSkillCondition:__includeFirstType(firstType)
    for _, f_type in ipairs(self.__condFirstSkillTypes) do
        if tonumber(firstType) == tonumber(f_type) then
            return true
        end
    end

    return false
end

function PrepSkillCondition:getConditionText()
    local condTypeStr
    if tostring(self.__logicalSymbol) == tostring(0) or self.__logicalSymbol == "等于" then
        condTypeStr = ""
    elseif self.__logicalSymbol == "不等于" then
        condTypeStr = "禁止"
    else
        error("主动技能准备条件判断 -- 判断方式未定义 ：" .. self.__logicalSymbol)
    end

    local skill_name_text = ""
    local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")
    for i, skillId in ipairs(self.__skillIds) do
        local skill = BasicSkillManager:getBasicSkill(skillId)
        if i == 1 then
            skill_name_text = string.format("[%s]", skill:getName())
        else
            skill_name_text = skill_name_text .. "或[" .. skill:getName() .. "]"
        end
    end

    local prepFirstTypeText = ""
    if self.__condFirstSkillTypeIsAll ~= true then
        for i, v in ipairs(self.__condFirstSkillTypes) do
            local text = SkillClassifyManager:getFirstTypeName(v)
            if i == 1 then
                prepFirstTypeText = string.format("为[%s]", text)
            else
                prepFirstTypeText = prepFirstTypeText .. "或[" .. text .. "]"
            end
        end
    end

    return string.format("%s准备%s%s", condTypeStr, skill_name_text, prepFirstTypeText)
end

return newClass("PrepSkillCondition", {IActiveUseCondition}, PrepSkillCondition)
000000000000000