--[[
    武学等级条件判断
]]
local newClass = require("third.class.NewClass")

local IActiveUseCondition = require("app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition")

local SkillLevelConditon = {}

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

function SkillLevelConditon:create(name, logicalSymbol, value)
    local p = SkillLevelConditon.new()
    p:init(name, logicalSymbol, value)
    return p
end

function SkillLevelConditon:init(skill_id, logicalSymbol, conditionLv)
    self.__skillId = skill_id
    self.__logicalSymbol = logicalSymbol
    self.__condLv = conditionLv
end

function SkillLevelConditon:getConditionType()
    return "2"
end

function SkillLevelConditon:getSkillId()
    return self.__skillId
end

function SkillLevelConditon:setCurrSkillLv(lv)
    self.__currConditionValue = lv
end

--@desc: 获取角色技能信息
--@author:Seven
--@time:2021-07-16 12:16:55
--@f_character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function SkillLevelConditon:matchCondititon(f_character)
    local skillRawData = f_character:getSkillRawData(self.__skillId)
    if skillRawData == nil then
        FightUtil:printLog("角色武学等级条件判断：武学Id: " .. self.__skillId .. " 角色未学会", tostring(false))
        return false
    end

    local Skill = require("app.models.skill.Skill")

    self.__condLv = Skill:getLv(skillRawData.exp)

    local isMatch =
        switch(
        self.__logicalSymbol,
        {
            ["小于"] = function()
                return self.__condLv < self.__currConditionValue
            end,
            ["小于等于"] = function()
                return self.__condLv <= self.__currConditionValue
            end,
            ["等于"] = function()
                return self.__condLv == self.__currConditionValue
            end,
            ["大于等于"] = function()
                return self.__condLv >= self.__currConditionValue
            end,
            ["大于"] = function()
                return self.__condLv > self.__currConditionValue
            end,
            ["default"] = false
        }
    )

    FightUtil:printLog("角色武学等级条件判断：【结果】", tostring(isMatch))

    return isMatch
end

local LogicalSymbolCHText = {
    ["小于"] = "低于",
    ["小于等于"] = "不高于",
    ["等于"] = "为",
    ["大于等于"] = "不低于",
    ["大于"] = "高于"
}

function SkillLevelConditon:getConditionText()
    local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")

    local f_skill = BasicSkillManager:getBasicSkill(self.__skillId)

    local symbol_text = LogicalSymbolCHText[self.__logicalSymbol]

    return string.format("[%s]%s%d级", f_skill:getName(), symbol_text, self.__condLv)
end

return newClass("SkillLevelConditon", {IActiveUseCondition}, SkillLevelConditon)
00000000000000