local class = require("third.class.NewClass")

local DreamSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.DreamSkillInfoViewModel")

local SkillConst = require("app.models.skill.SkillConst")

local FondDreamSkillInfoViewModel = {}

function FondDreamSkillInfoViewModel:create(role)
    local p = FondDreamSkillInfoViewModel:new()
    p:init(role)
    return p
end

function FondDreamSkillInfoViewModel:getSkill(skillId)
    skillId = skillId or self:getSkillId()
    return self:getRole():getSkillFile():getSkill(skillId)
end

function FondDreamSkillInfoViewModel:__isOpenZuoYouHuBo()
    return false
end

return class("FondDreamSkillInfoViewModel", {DreamSkillInfoViewModel}, FondDreamSkillInfoViewModel)00000