--[[
    author:Seven
    time:2023-02-13 16:48:21
    desc: 玩家用主动技能系统
]]
local CharacterSkillSystem = require("app.FightSystem.FightRole.CharacterSkillSystem.CharacterSkillSystem")

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightRole.CharacterSkillSystem.CharacterSkillSystem#CharacterSkillSystem]
local PlayerSkillSystem = {}

function PlayerSkillSystem:create()
    return PlayerSkillSystem.new()
end

function PlayerSkillSystem:getCurrActivePrepActiveSkillIdMap()
    --@RefType [src.app.models.ActiveSkillPrepare.ActiveSkillPrepareV2#ActiveSkillPrepareV2]
    local activeSkillPrepareV2 = require("app.models.ActiveSkillPrepare.ActiveSkillPrepareV2"):create()

    local weapon = self.__character:getWeapon()

    activeSkillPrepareV2:setCharacter(self.__character)

    activeSkillPrepareV2:setWeaponType(weapon:getFirstType())

    activeSkillPrepareV2:setWeaponSecType(weapon:getSecondType())

    activeSkillPrepareV2:initialize()

    print(table.tostring(activeSkillPrepareV2:getPreparedActiveSkillList()))

    local prep_map = activeSkillPrepareV2:getPreparedActiveSkillList()

    return prep_map
end

return newClass("PlayerSkillSystem", {CharacterSkillSystem}, PlayerSkillSystem)
00