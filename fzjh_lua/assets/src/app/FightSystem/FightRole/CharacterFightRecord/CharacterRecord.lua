local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local CharacterRecord = {
    __replaceWeapons = {},
    --@desc 主动技能释放次数
    __activeReleaseTimesMap = {}
}

function CharacterRecord:create(character)
    local p = CharacterRecord.new()
    p:__init(character)
    return p
end

function CharacterRecord:__init(character)
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = character
end

function CharacterRecord:getWeapons()
    local list = {}

    table.insert(list, self.__character:getEquipment(FightCommons.EQUIP_PART.WEAPON))

    table.insert(list, self.__character:getStandbyWeapon())

    return list
end

--@desc: 添加主动技能释放次数
--@author:LvBin
--@time:2022-02-26 14:55:43
--@act_id: 主动技能id
--@return
function CharacterRecord:addActiveReleaseTime(act_id)
    if self.__activeReleaseTimesMap[act_id] == nil then
        self.__activeReleaseTimesMap[act_id] = 0
    end
    self.__activeReleaseTimesMap[act_id] = self.__activeReleaseTimesMap[act_id] + 1
end

function CharacterRecord:getActiveReleaseTimesMap()
    return self.__activeReleaseTimesMap
end

return newClass("CharacterRecord", {}, CharacterRecord)
000