local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local SkillHelper = require("app.models.skill.SkillHelper")

local SkillLvCondition = {}

function SkillLvCondition:create(...)
    local p = SkillLvCondition.new()
    p:init(...)
    return p
end

function SkillLvCondition:check()
    local skillId = self:getAttrId()

    local skillExp = self:getRole():getSkillExp(skillId)

    local skillLv = SkillHelper:getLv(skillId,skillExp)

    return self:compare(skillLv)
end

return newClass("SkillLvCondition", {BaseCondition}, SkillLvCondition)
00000