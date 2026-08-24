local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local CanPrepareTypeSkillLvNumCondition = {}

function CanPrepareTypeSkillLvNumCondition:create(...)
    local p = CanPrepareTypeSkillLvNumCondition.new()
    p:init(...)
    return p
end

function CanPrepareTypeSkillLvNumCondition:check()
    local role = self:getRole()

    local prepareType = tonumber(self:getAttrId())

    local needSkillLv = tonumber(self:getParam()[1])

    if role.getNumOfSkillsByTypeAndLevel ~= nil then
        -- 旧版战斗会调用这里，战斗内因等级经验都不会调整，因此可以进行查询优化
        local num = role:getNumOfSkillsByTypeAndLevel(prepareType, needSkillLv)
        return self:compare(num)
    end

    local skillNum = 0

    local skills = self:getRole():getSkills()

    for k, roleSkill in pairs(skills) do
        local skillId = roleSkill.id

        local skill = Skill:getSkill(skillId)

        if skill.type ~= SKILL_TYPE_BASE and self:getRole():getSkillLv(skillId) >= needSkillLv then
            if prepareType == 0 or skill:canPrepareType(prepareType) then
                skillNum = skillNum + 1
            end
        end
    end

    return self:compare(skillNum)
end

return newClass("CanPrepareTypeSkillLvNumCondition", {BaseCondition}, CanPrepareTypeSkillLvNumCondition)
0000