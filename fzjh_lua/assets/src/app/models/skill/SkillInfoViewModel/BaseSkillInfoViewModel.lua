local class = require("third.class.NewClass")

local SkillConst = require("app.models.skill.SkillConst")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local BaseSkillInfoViewModel = {}

function BaseSkillInfoViewModel:create(role)
    local p = BaseSkillInfoViewModel:new()
    p:init(role)
    return p
end

function BaseSkillInfoViewModel:setRole(role)
    self.__role = role
end

function BaseSkillInfoViewModel:getRole()
    return self.__role
end

function BaseSkillInfoViewModel:setSkillId(skillId)
    self.__skillId = skillId
end

function BaseSkillInfoViewModel:getSkillId()
    return self.__skillId
end

function BaseSkillInfoViewModel:getSkill(skillId)
    skillId = skillId or self:getSkillId()
    return Skill:getSkill(skillId)
end

function BaseSkillInfoViewModel:setPresenter(presenter)
    self.__presenter = presenter
end

function BaseSkillInfoViewModel:getSkillListTab()
    return self.__skillListTab
end

function BaseSkillInfoViewModel:getCurrSkillListTab()
    return self.__skillListTab[self.__presenter:getCurrTabIndex()]
end

function BaseSkillInfoViewModel:getCurrSkillList()
    return self:getCurrSkillListTab().list
end

return class("BaseSkillInfoViewModel", {}, BaseSkillInfoViewModel)00000000000000