local ActiveSkillConf = require("app.FightSystem.Configuration.ActiveSkillConf")

local ZhaoInfo = require("app.FightSystem.FightSkill.ZhaoInfo")

local ActiveFactory = {}

--@desc: 创建主动招式组合
--@author:Seven
--@time:2021-06-17 18:16:58
--@active_id: 主动技能id
--@level: 等级
--@return [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination#ActiveZhaoCombination]
function ActiveFactory:createActiveZhaoComb(active_id, level)
    local active_res = ActiveSkillConf:getActiveSkillResByAIdAndLevel(active_id, level)

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination#ActiveZhaoCombination]
    local activeZhaoComb = require("app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination"):create()

    activeZhaoComb:loadFromRes(active_res)

    return activeZhaoComb
end

function ActiveFactory:createActiveZhaoCombById(combId)
    local active_res = ActiveSkillConf:getActiveSkillResByCombId(combId)

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination#ActiveZhaoCombination]
    local activeZhaoComb = require("app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination"):create()

    activeZhaoComb:loadFromRes(active_res)

    return activeZhaoComb
end

--@desc: 创建主动招式信息
--@author:Seven
--@time:2021-06-17 18:14:55
--@zhaoInfo_id: 招式信息编号
--@return [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
function ActiveFactory:createActiveZhaoInfo(zhaoInfo_id)
    local res = ActiveSkillConf:getActiveZhaoInfo(zhaoInfo_id)

    local zhaoInfo = ZhaoInfo:create(res)

    return zhaoInfo
end

function ActiveFactory:getActiveInfo(id)
    return assert(ActiveSkillConf:getActiveSkillResByCombId(id), "ActiveFactory:getActiveInfo 无法找到 id " .. id)
end

function ActiveFactory:__getFightActiveSkillClass(path)
    return require(path)
end

function ActiveFactory:__getFightActiveSkill(path, f_character, combId)
    local activeSkillClass = self:__getFightActiveSkillClass(path)

    --@RefType [src.app.FightSystem.FightSkill.BasicFightActiveSkill#BasicFightActiveSkill]
    local active_skill = activeSkillClass:create()

    local active_res = ActiveSkillConf:getActiveSkillResByCombId(combId)

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination#ActiveZhaoCombination]
    local activeZhaoComb = require("app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombination"):create()

    activeZhaoComb:loadFromRes(active_res)

    active_skill:setCharacter(f_character)

    active_skill:setZhaoComb(activeZhaoComb)

    return active_skill
end

function ActiveFactory:createPlayerFightActiveSkill(f_character, active_id, level)
    local active_res = ActiveSkillConf:getActiveSkillResByAIdAndLevel(active_id,level)

    local combId = active_res.id

    local activeSkill = self:__getFightActiveSkill("app.FightSystem.FightSkill.FightActiveSkills.PlayerFightActiveSkill", f_character, combId)

    return activeSkill
end

function ActiveFactory:createNpcFightActiveSkill(f_character, combId)
    local activeSkill = self:__getFightActiveSkill("app.FightSystem.FightSkill.FightActiveSkills.NPCFightActiveSkill", f_character, combId)

    return activeSkill
end

return ActiveFactory
0000000000