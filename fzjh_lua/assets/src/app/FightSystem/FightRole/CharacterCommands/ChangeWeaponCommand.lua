local newClass = require("third.class.NewClass")

local ACharacterCommand = require("app.FightSystem.FightRole.CharacterCommands.ACharacterCommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_CMD_TYPE = FightCommons.CHARATER_CMD_TYPE

--@SuperType [src.app.FightSystem.FightRole.CharacterCommands.ACharacterCommand#ACharacterCommand]
local ChangeWeaponCommand = {
    __type = CHARACTER_CMD_TYPE.CHANGE_WEAPON,
    __priority = 2
}

function ChangeWeaponCommand:create()
    return ChangeWeaponCommand.new()
end

function ChangeWeaponCommand:getCommandName()
    return FightCommons.CHANGE_WEAPON_NAME
end

function ChangeWeaponCommand:isMatchCondition()
    local character = self.__characterSystem:getCharacter(self.__characterId)

    local isMatch, tip = character:canDoChangeWeapon()
    
    return isMatch, tip
end

function ChangeWeaponCommand:execute()
    local character = self.__characterSystem:getCharacter(self.__characterId)

    character:triggerEvent("CHANGE_WEAPON")
end

return newClass("ChangeWeaponCommand", {ACharacterCommand}, ChangeWeaponCommand)
00000000