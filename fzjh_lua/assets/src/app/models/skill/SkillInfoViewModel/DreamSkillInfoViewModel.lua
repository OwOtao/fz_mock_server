local class = require("third.class.NewClass")

local SkillInfoViewModel = require("app.models.skill.SkillInfoViewModel.SkillInfoViewModel")

local SkillConst = require("app.models.skill.SkillConst")

local DreamSkillInfoViewModel = {}

function DreamSkillInfoViewModel:create(role)
    local p = DreamSkillInfoViewModel:new()
    p:init(role)
    return p
end

function DreamSkillInfoViewModel:__initSkillListTab(qjList, bqList, qgList, ngList, zjList, zsList)
    self.__skillListTab = {
        {name = "拳脚",skillType ="quanjiao1",list = qjList},
        {name = "兵器",skillType ="bingqi",list = bqList},
        {name = "轻功",skillType ="qinggong",list = qgList},
        {name = "内功",skillType ="neigong",list = ngList},
        {name = "招架",skillType ="zhaojia",list = zjList},
    }
end

function DreamSkillInfoViewModel:getSkillExpDsc(skillId)
    local skillLv = self.__role:getSkillLv(skillId)

    return skillLv.."级"
end

function DreamSkillInfoViewModel:getSkillStageDsc(skillId)
    return User:getRole():getDreamSystem():getDreamSkillDsc(skillId,self.__role) 
end

return class("DreamSkillInfoViewModel", {SkillInfoViewModel}, DreamSkillInfoViewModel)0000000000000