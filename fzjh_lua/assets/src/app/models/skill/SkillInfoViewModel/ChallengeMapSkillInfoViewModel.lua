local class = require("third.class.NewClass")

local SkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.SkillInfoViewModel")

local SkillConst = require("app.models.skill.SkillConst")

local ChallengeMapSkillInfoViewModel = {}

function ChallengeMapSkillInfoViewModel:create(role)
    local p = ChallengeMapSkillInfoViewModel:new()
    p:init(role)
    return p
end

function ChallengeMapSkillInfoViewModel:__initSkillListTab(qjList, bqList, qgList, ngList, zjList, zsList)
    self.__skillListTab = {
        {name = "拳脚",skillType ="quanjiao1",list = qjList},
        {name = "兵器",skillType ="bingqi",list = bqList},
        {name = "轻功",skillType ="qinggong",list = qgList},
        {name = "内功",skillType ="neigong",list = ngList},
        {name = "招架",skillType ="zhaojia",list = zjList},
    }
end

function ChallengeMapSkillInfoViewModel:__isOpenZuoYouHuBo()
    return false
end

function ChallengeMapSkillInfoViewModel:getSkills()
    local skills =  self.__role:getSkills()
    local retSkills = {}
    for skillId ,v in pairs(skills) do
        local skill = Skill:getSkill(skillId)
        if skill.type ~= SKILL_TYPE_SELFCREATE then
            retSkills[skillId] = v
        end
    end

    return retSkills
end

return class("ChallengeMapSkillInfoViewModel", {SkillInfoViewModel}, ChallengeMapSkillInfoViewModel)0000