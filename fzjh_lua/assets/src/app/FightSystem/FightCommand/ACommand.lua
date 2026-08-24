local abstract = require("third.class.abstract")

local ICommand = require("app.FightSystem.FightCommand.ICommand")

--@SuperType [src.app.FightSystem.FightCommand.ICommand#ICommand]
local ACommand = {
    __type = 0,
    __fight = nil,
    __characterId = nil,
    __data = {}
}

function ACommand:setFight(fight)
    --@RefType [src.app.FightSystem.Fight.Fight#Fight]
    self.__fight = fight
end

function ACommand:setCharacterId(c_id)
    self.__characterId = c_id
end

function ACommand:getCmdType()
    return self.__type
end

function ACommand:putData(key, value)
    self.__data[key] = value
end

function ACommand:getData(key)
    return self.__data[key]
end

return abstract("ACommand", {ICommand}, ACommand)
000000000000000