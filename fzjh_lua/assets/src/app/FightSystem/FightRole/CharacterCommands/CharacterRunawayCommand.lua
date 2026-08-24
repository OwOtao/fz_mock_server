local newClass = require("third.class.NewClass")

local ACharacterCommand = require("app.FightSystem.FightRole.CharacterCommands.ACharacterCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.FightRole.CharacterCommands.ACharacterCommand#ACharacterCommand]
local CharacterRunawayCommand = {
    __type = CHARACTER_CMD_TYPE.RUNAWAY,
    __priority = 1
}

function CharacterRunawayCommand:create()
    return CharacterRunawayCommand.new()
end

function CharacterRunawayCommand:getCommandName()
    return FightCommons.RUNAWAY_NAME
end

function CharacterRunawayCommand:isMatchCondition()
    local character = self.__characterSystem:getCharacter(self.__characterId)
    local isMatch, tip = character:canRunAway()
    return isMatch, tip
end

function CharacterRunawayCommand:execute()
    local character = self.__characterSystem:getCharacter(self.__characterId)

    character:triggerEvent("RUNAWAY")
end

return newClass("CharacterRunawayCommand", {ACharacterCommand}, CharacterRunawayCommand)
000000000