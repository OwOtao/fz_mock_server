local class = require("third.class.NewClass")

local FightTeam = {}

--@return [app.FightSystem.FightDataModel.FightTeam#FightTeam]
function FightTeam:create()
    return FightTeam.new()
end

function FightTeam:ctor()
    self.__team_id = 0
    self.__characters = {}
end

function FightTeam:getTeamId()
    return self.__team_id
end

function FightTeam:setTeamId(team_id)
    self.__team_id = team_id
end

function FightTeam:addCharacter(character)
    table.insert(self.__characters, character)
end

function FightTeam:getCharacters()
    return self.__characters
end

return class("FightTeam", {}, FightTeam)
0000000000000