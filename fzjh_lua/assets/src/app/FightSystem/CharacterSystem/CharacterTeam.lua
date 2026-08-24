--[[
    author:Seven
    time:2022-08-29 19:48:48
    desc:
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local CharacterTeam = {}

function CharacterTeam:create(teamId)
    local p = CharacterTeam.new()
    p:__init(teamId)
    return p
end

function CharacterTeam:__init(teamId)
    if teamId == nil then
        error("CharacterTeam create 参数teamId不可为nil")
    end
    self.__id = teamId

    self.__characters = {}
end

function CharacterTeam:getId()
    return self.__id
end

function CharacterTeam:addCharacter(character)
    if table.getn(self.__characters) >= FightCommons.TEAMMATE_COUNT then
        assert(false, "当前队伍已满人或超出人员限制，无法增加人数")
    end

    table.insert(self.__characters, character)
end

function CharacterTeam:removeCharacter(id)
    for i = table.getn(self.__characters), 1, -1 do
        local e = self.__characters[i]

        if e:getId() == id then
            table.remove(self.__characters, i)

            return true
        end
    end

    assert(false, "当前队伍并没有该队员，队员ID：" .. tostring(id))
end

function CharacterTeam:getCharacters()
    return self.__characters
end

return newClass("CharacterTeam", {}, CharacterTeam)
0000000000000000