local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local CanPrepareTypeSkillLvLimitNumCondition = {}

function CanPrepareTypeSkillLvLimitNumCondition:create(...)
    local p = CanPrepareTypeSkillLvLimitNumCondition.new()
    p:init(...)
    return p
end

function CanPrepareTypeSkillLvLimitNumCondition:check()
    local role = self:getRole()

    local prepareType = tonumber(self:getAttrId())

    local needSkillLvLimit = tonumber(self:getParam()[1])

    if role.getNumOfSkillsByTypeAndLevelLimit ~= nil then
        -- 旧版战斗会调用这里，战斗内因等级经验都不会调整，因此可以进行查询优化
        local num = role:getNumOfSkillsByTypeAndLevelLimit(prepareType, needSkillLvLimit)
        return self:compare(num)
    end

    local skillNum = 0

    local skills = self:getRole():getSkills()

    for k, roleSkill in pairs(skills) do
        local skillId = roleSkill.id

        local skill = Skill:getSkill(skillId)

        if skill.type ~= SKILL_TYPE_BASE and self:getRole():getSkillLvLimit(skillId) >= needSkillLvLimit then
            if prepareType == 0 or skill:canPrepareType(prepareType) then
                skillNum = skillNum + 1
            end
        end
    end

    return self:compare(skillNum)
end

return newClass("CanPrepareTypeSkillLvLimitNumCondition", {BaseCondition}, CanPrepareTypeSkillLvLimitNumCondition)
00000000