local NewClass = require("third.class.NewClass")

local FistFootEffect = require("app.models.FistFootSystem.FistFootEffect.FistFootEffect")

local RoleFistFootEffect = {}

local SourceType = {
    PrepSkillType = 1,  --拳脚1
    StandBySkillType = 2,    --拳脚2
    PrepSkillAndStandBySkillType = 3 --拳脚1和拳脚2
}

function RoleFistFootEffect:create(data)
    local p = RoleFistFootEffect.new(data)
    return p
end

--设置武学来源类型
function RoleFistFootEffect:setSourceFromPrepSkill()
    self._sourceType = SourceType.PrepSkillType
end

function RoleFistFootEffect:setSourceFromStandBySkill()
    self._sourceType = SourceType.StandBySkillType
end

function RoleFistFootEffect:setSourceFromPrepSkillAndStandBySkill()
    self._sourceType = SourceType.PrepSkillAndStandBySkillType
end

function RoleFistFootEffect:setSourceType(sourceType)
    self._sourceType = sourceType
end

function RoleFistFootEffect:getSourceType()
    return self._sourceType
end

function RoleFistFootEffect:checkIsFromPrepSkill()
    return self._sourceType == SourceType.PrepSkillType or self._sourceType == SourceType.PrepSkillAndStandBySkillType
end

function RoleFistFootEffect:checkIsFromStandBySkill()
    return self._sourceType == SourceType.StandBySkillType or self._sourceType == SourceType.PrepSkillAndStandBySkillType
end

function RoleFistFootEffect:checkIsFromPrepSkillAndStandBySkill()
    return self._sourceType == SourceType.PrepSkillAndStandBySkillType
end

return NewClass("RoleFistFootEffect", { FistFootEffect }, RoleFistFootEffect)000000000000