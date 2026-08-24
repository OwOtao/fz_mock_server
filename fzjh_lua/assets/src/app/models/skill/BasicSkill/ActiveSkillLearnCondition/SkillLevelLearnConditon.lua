--[[
    武学等级条件判断
]]
local newClass = require("third.class.NewClass")

local IActiveLearnCondition = require("app.models.skill.BasicSkill.ActiveSkillLearnCondition.IActiveLearnCondition")

local BasicSkillManager = require("app.models.skill.BasicSkill.BasicSkillManager")

local SkillLevelLearnConditon = {}

function SkillLevelLearnConditon:create(name, logicalSymbol, value)
    local p = SkillLevelLearnConditon.new()
    p:init(name, logicalSymbol, value)
    return p
end

function SkillLevelLearnConditon:init(skill_id, logicalSymbol, conditionLv)
    self.__skillId = skill_id
    self.__logicalSymbol = logicalSymbol
    self.__condLv = conditionLv
end

function SkillLevelLearnConditon:getSkillId()
    return self.__skillId
end

function SkillLevelLearnConditon:setCurrSkillLv(lv)
    self.__currConditionValue = lv
end

function SkillLevelLearnConditon:matchCondititon(f_character)
    --@desc 暂未开放使用
    return false
end

local LogicalSymbolCHText = {
    ["小于"] = "低于",
    ["小于等于"] = "不高于",
    ["等于"] = "为",
    ["大于等于"] = "不低于",
    ["大于"] = "高于"
}

function SkillLevelLearnConditon:getConditionText()
    local basicSkill = BasicSkillManager:getBasicSkill(self.__skillId)

    local symbol_text = LogicalSymbolCHText[self.__logicalSymbol]

    return string.format("[%s]%s%d级", basicSkill:getName(), symbol_text, self.__condLv)
end

return newClass("SkillLevelLearnConditon", {IActiveLearnCondition}, SkillLevelLearnConditon)
00000000