local newClass = require("third.class.NewClass")

local BaseCondition = require("app.models.Meridian.HiddenMeridianBuff.Condition.BaseCondition")

local SelfCreatedSkill = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkill.SelfCreatedSkill")

local SelfCreatedSkillAffixCountCondition = {}

function SelfCreatedSkillAffixCountCondition:create(...)
    local p = SelfCreatedSkillAffixCountCondition.new()
    p:init(...)
    return p
end

function SelfCreatedSkillAffixCountCondition:check()
    local sys = self:getRole():getSelfCreatedSkillSystem()

    local books = sys:getBooks()

    local secondType = tonumber(self:getAttrId())

    local affixCount = tonumber(self:getParam()[1])

    local maxZhaoCount = 0

    for i,v in ipairs(books) do
        local skill = SelfCreatedSkill:create(v)
        if secondType == 0 or skill:getSecondType() == secondType then
            local zhaoCount = 0
            local zhaos = skill:getZhaos()
            if not MapIsEmpty(zhaos) then
                for i, zhao in ipairs(zhaos) do
                    local affixs = zhao:getAffixs()
                    if #affixs >= affixCount then
                        zhaoCount = zhaoCount + 1
                    end
                end

                if zhaoCount > maxZhaoCount then
                    maxZhaoCount = zhaoCount
                end
            end
        end
    end

    return self:compare(maxZhaoCount)
end

return newClass("SelfCreatedSkillAffixCountCondition", {BaseCondition}, SelfCreatedSkillAffixCountCondition)
00000000