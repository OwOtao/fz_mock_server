local class = require("third.class.NewClass")

local BaseSkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.BaseSkillInfoViewModel")

local TeacherSkillInfoViewModel = {}

function TeacherSkillInfoViewModel:create(role)
    local p = TeacherSkillInfoViewModel:new()
    p:init(role)
    return p
end

function TeacherSkillInfoViewModel:init(role)
    self:setRole(role)

    self:__initRoleSkillList()
end

function TeacherSkillInfoViewModel:__initRoleSkillList()
    local name = self.__role:getName()
     
    local list = self.__role:skillSort()

    self.__skillListTab = {
        {name = name,list = list}
    }
end

return class("TeacherSkillInfoViewModel", {BaseSkillInfoViewModel}, TeacherSkillInfoViewModel)0000000