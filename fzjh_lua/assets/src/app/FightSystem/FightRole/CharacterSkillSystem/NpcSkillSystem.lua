--[[
    author:Seven
    time:2023-02-13 16:52:58
    desc: NPC用技能系统
]]
local CharacterSkillSystem = require("app.FightSystem.FightRole.CharacterSkillSystem.CharacterSkillSystem")

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterSkillSystem.CharacterSkillSystem#CharacterSkillSystem]
local NpcSkillSystem = {}

function NpcSkillSystem:create()
    return NpcSkillSystem.new()
end

function NpcSkillSystem:getCurrActivePrepActiveSkillIdMap()
    if MapIsEmpty(self:getActiveSkills()) then
        return {}
    end

    local prep_map = {}

    for i, activeSkill in ipairs(self:getActiveSkills()) do
        if activeSkill:isMeetUseCondition() then
            prep_map[tostring(i)] = {
                activeSkillId = activeSkill:getId(),
                level = activeSkill:getLevel()
            }
        end
    end

    return prep_map
end

return newClass("NpcSkillSystem", {CharacterSkillSystem}, NpcSkillSystem)
0