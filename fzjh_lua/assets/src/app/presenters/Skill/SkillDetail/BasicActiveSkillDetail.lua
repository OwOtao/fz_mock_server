--[[
    author:Seven
    time:2022-11-07 16:13:02
    desc: 主动技能信息UI使用model
]]
local newClass = require("third.class.NewClass")
--@RefType [src.app.models.skill.BasicSkill.BasicActiveSkill#BasicActiveSkill]
local BasicActiveSkill = require("app.models.skill.BasicSkill.BasicActiveSkill")

local BasicActiveSkillManager = require("app.models.skill.BasicSkill.BasicActiveSkillManager")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BookSkillsHelper = require("app.models.book.BookSkillsHelper")

local BasicActiveSkillDetail = {}

function BasicActiveSkillDetail:create(active_id)
    return BasicActiveSkillDetail.new():__init(active_id)
end

function BasicActiveSkillDetail:__init(active_id)
    --@RefType [src.app.models.skill.BasicSkill.BasicActiveSkill#BasicActiveSkill]
    self.__basicActiveSkill = BasicActiveSkillManager:getBasicActiveSkill(active_id)

    return self
end

function BasicActiveSkillDetail:getName()
    return self.__basicActiveSkill:getActiveName()
end

function BasicActiveSkillDetail:getActiveText()
    return self.__basicActiveSkill:getDesc()
end

function BasicActiveSkillDetail:getLearnMethod()
    return self.__basicActiveSkill:getLearnMethod()
end

function BasicActiveSkillDetail:getLearnConditions()
    return self.__basicActiveSkill:getLearnConditions()
end

function BasicActiveSkillDetail:getLearnConditionTexts()
    if self:getLearnMethod() == BasicActiveSkill.LEARN_METHOD.FROM_BOOK then
        local str = BookSkillsHelper:getActiveSkillLearnForBookText(self.id)
        return {str}
    elseif self:getLearnMethod() == BasicActiveSkill.LEARN_METHOD.FROM_CONDITION then
        local list = {}

        for _, v in ipairs(self:getLearnConditions()) do
            --@RefType [src.app.models.skill.BasicSkill.ActiveSkillLearnCondition.IActiveLearnCondition#IActiveLearnCondition]
            local v = v
            local text = v:getConditionText()

            if text ~= "" then
                table.insert(list, text)
            end
        end

        return list
    end

    assert(false, "BasicActiveSkillDetail:getLearnConditionTexts 学习类型未知")
end

function BasicActiveSkillDetail:getUseConditionTexts()
    local list = {}

    local neiliCost = self.__basicActiveSkill:getNeiliCost()

    if neiliCost > 0 then
        table.insert(list, string.format(FightUtil:getCharacterAttrCHName("neili") .. "不低于%d", neiliCost))
    end

    local tiliCost = self.__basicActiveSkill:getTiliCost()
    if tiliCost > 0 then
        table.insert(list, string.format(FightUtil:getCharacterAttrCHName("tili") .. "不低于%d", tiliCost))
    end

    for _, v in ipairs(self.__basicActiveSkill:getUseConditions()) do
        --@RefType [src.app.FightSystem.FightSkill.ActiveSkillUseCondition.IActiveUseCondition#IActiveUseCondition]
        local v = v

        local text = v:getConditionText()

        if text ~= "" then
            table.insert(list, text)
        end
    end
    return list
end

return newClass("BasicActiveSkillDetail", {}, BasicActiveSkillDetail)
0000000000000