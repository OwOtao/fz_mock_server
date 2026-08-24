--[[
    author:Seven
    time:2023-02-21 11:24:44
    desc: 战斗用主动技能创建
]]
local FightActiveSkillFactory = {}

local ActiveSkillConf = require("app.FightSystem.Configuration.ActiveSkillConf")

--@desc: 创建玩家战斗用主动技能
--@author:Seven
--@time:2023-02-21 11:29:03
--@id:主动技能id
--@level: 等级
--@return [src.app.FightSystem.FightSkill.FightActiveSkills.PlayerFightActiveSkill#PlayerFightActiveSkill]
function FightActiveSkillFactory.createPlayerFightActiveSkill(id, level)
    return require("app.FightSystem.FightSkill.FightActiveSkills.PlayerFightActiveSkill"):create(id, level)
end

--@desc: 创建NPC战斗用主动技能
--@author:Seven
--@time:2023-02-21 11:36:50
--@id: 主动技能id
--@level: 主动技能等级
--@return [src.app.FightSystem.FightSkill.FightActiveSkills.NPCFightActiveSkill#NPCFightActiveSkill]
function FightActiveSkillFactory.createNpcFightActiveSkill(id, level)
    return require("app.FightSystem.FightSkill.FightActiveSkills.NPCFightActiveSkill"):create(id, level)
end

function FightActiveSkillFactory.createNpcFightAcitiveSkillByCombId(combId)
    local cmob = ActiveSkillConf:getActiveSkillResByCombId(combId)

    local activeId = cmob.activeId

    local level = cmob.activeLevel

    return FightActiveSkillFactory.createNpcFightActiveSkill(activeId, level)
end

return FightActiveSkillFactory
0000000000