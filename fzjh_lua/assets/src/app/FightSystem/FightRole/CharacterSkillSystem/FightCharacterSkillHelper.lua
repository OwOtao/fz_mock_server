--[[
    author:Seven
    time:2023-10-17 20:17:28
    desc: 战斗角色技能相关公用逻辑
]]
local FightCommons = require("app.FightSystem.FightCommons")

local FightSkillHelper = {}

--@desc: 把角色的主动技能携带的buff挂载到角色身上
--@author:Seven
--@time:2023-10-17 20:19:23
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightSkillHelper:attachActiveSkillCarryBuff(character)
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local active_skill = character:getPrepActiveSkillByPosIndex(i)
        if active_skill ~= nil then
            active_skill:addCarryBuffToCharacter()
        end
    end
end

--@desc: 把角色当前准备的主动技能携带buff移除
--@author:Seven
--@time:2023-10-17 20:33:28
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightSkillHelper:removeActiveSkillCarryBuff(character)
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local active_skill = character:getPrepActiveSkillByPosIndex(i)
        if active_skill ~= nil then
            active_skill:removeCarryBuffFromCharacter()
        end
    end
end

--@desc: 把角色已准备的主动技能携带的进场buff添加器挂载到角色身上
--@author:Seven
--@time:2023-10-17 20:31:56
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightSkillHelper:addActiveSkillEnterBuffAdder(character)
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local active_skill = character:getPrepActiveSkillByPosIndex(i)
        if active_skill ~= nil then
            active_skill:addCarryBuffAdderToCharacter()
        end
    end
end

--@desc: 把角色已准备的主动技能携带的进场buff添加器移除角色身上
--@time:2023-10-17 20:32:56
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightSkillHelper:removeActiveSkillEnterBuffAdder(character)
    for i = 1, FightCommons.PREP_ACT_MAX_COUNT do
        local active_skill = character:getPrepActiveSkillByPosIndex(i)
        if active_skill ~= nil then
            active_skill:removeCarryBuffAdderFromCharacter()
        end
    end
end

return FightSkillHelper
000000000