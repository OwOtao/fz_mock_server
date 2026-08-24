--[[
    只能被\app\models\SelfCreatedSkillSystem\SelfCreatedSkill\SelfCreatedSkillOld.lua 继承，其余地方不可用
]]

local BaseSelfCreatedSkill = inherit({}, require("app.models.skill.BaseSkill"))


function BaseSelfCreatedSkill:getAutoSkills()
    return self.autoZhaos
end

-- @desc 得到平均攻击力
function BaseSelfCreatedSkill:getAvgAtk(skillLv)
    local avgAtk = 0
    if self.getAvgAtkCache == nil then
        local atk, count = 0, 0
        
        for k, v in pairs(self.autoSkills) do
            if skillLv >= v.lv then
                atk = atk + v.atk
                count = count + 1
            end
        end
        avgAtk = atk / count
        self.getAvgAtkCache = avgAtk
    else
        avgAtk = self.getAvgAtkCache
    end
    return avgAtk
end

function BaseSelfCreatedSkill:getSkillTypes()
    return self._newSkill:getSkillType()
end

function BaseSelfCreatedSkill:getSkillThridTypes()
    return {self._newSkill:getThirdType()}
end

return BaseSelfCreatedSkill000000000