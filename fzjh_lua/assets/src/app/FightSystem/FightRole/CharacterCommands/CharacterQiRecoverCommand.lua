local newClass = require("third.class.NewClass")

local ACharacterCommand = require("app.FightSystem.FightRole.CharacterCommands.ACharacterCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.FightRole.CharacterCommands.ACharacterCommand#ACharacterCommand]
local CharacterQiRecoverCommand = {
    __type = CHARACTER_CMD_TYPE.QI_RECOEVE,
    __priority = 3
}

function CharacterQiRecoverCommand:create()
    return CharacterQiRecoverCommand.new()
end

function CharacterQiRecoverCommand:getCommandName()
    return FightCommons.RCOVER_QI_NAME
end

function CharacterQiRecoverCommand:isMatchCondition()
    local character = self.__characterSystem:getCharacter(self.__characterId)

    local isMatch, tip = character:canDoQiRecover()

    return isMatch, tip
end

function CharacterQiRecoverCommand:execute()
    local character = self.__characterSystem:getCharacter(self.__characterId)

    local isBool, tip = self:isMatchCondition()

    if isBool then
        character:triggerEvent("RECOVER_QI")
        return
    end

    if tip ~= nil then
        self.__characterSystem:getFight():popMessage(tip)
    end
end

return newClass("CharacterQiRecoverCommand", {ACharacterCommand}, CharacterQiRecoverCommand)
0000000