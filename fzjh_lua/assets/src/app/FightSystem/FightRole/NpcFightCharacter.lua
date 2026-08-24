local newClass = require("third.class.NewClass")

local FightCharacter = require("app.FightSystem.FightRole.FightCharacter")

--@SuperType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
local NpcFightCharacter = {}

--@return [src.app.FightSystem.FightRole.NpcFightCharacter#NpcFightCharacter]
function NpcFightCharacter:create()
    return NpcFightCharacter.new()
end

function NpcFightCharacter:initActivePrepActiveSkill()
    --@desc 暂时只有切换武器时会有这个调用，NPC暂时直接卸载当前的所有主动技能
    if not MapIsEmpty(self.__prep_act)  then
        self.__prep_act = {}
    end

    if MapIsEmpty(self:getActiveSkills()) then
        return
    end

    local pos_index = 1
    for actId, activeSkill in pairs(self:getActiveSkills()) do
        if activeSkill:isMeetUseCondition() then
            self:addPrepActiveSkill(actId,pos_index)
            pos_index = pos_index + 1
        end
    end
end

return newClass("NpcFightCharacter", {FightCharacter}, NpcFightCharacter)
00000000000