--[[
    author:Seven
    time:2023-02-06 11:42:32
    desc: 战斗技能创建工厂
]]
local BasicFightSkill = require("app.FightSystem.FightSkill.BasicFightSkill")

local BasicFightKnowledgeSkill = require("app.FightSystem.FightSkill.BasicFightKnowledgeSkill")

local FightSkillFactory = {}

--@desc: 创建战斗技能
--@author:Seven
--@time:2023-02-06 11:44:29
--@id: 技能id
--@return [src.app.FightSystem.FightSkill.BasicFightSkill#BasicFightSkill]
function FightSkillFactory.createBasicFightSkill(id,lv)
    local skill = BasicFightSkill:create(id)
    skill:setLevel(lv)
    return skill
end


function FightSkillFactory.createKnowledgeFightSkill(id,lv)
    local k_skill = BasicFightKnowledgeSkill:create(id)
    k_skill:setLevel(lv)
    return k_skill
end

return FightSkillFactory000000000