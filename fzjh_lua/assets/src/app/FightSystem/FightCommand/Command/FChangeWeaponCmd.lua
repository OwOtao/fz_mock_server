local class = require("third.class.NewClass")
local ACommand = require("app.FightSystem.FightCommand.ACommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

--@SuperType [src.app.FightSystem.FightCommand.ACommand#ACommand]
local FChangeWeaponCmd = {
    __type = CMD_TYPE.CHARACTER_ACTIVE
}

function FChangeWeaponCmd:create()
    return FChangeWeaponCmd.new()
end

function FChangeWeaponCmd:runCommand()
    local character_id = self.__characterId

    if character_id == nil then
        assert(false, "FChangeWeaponCmd 参数没有请求切换武器id ：character_id")
    end


    self.__fight:prepChangeWeapon(character_id)
end

return class("FChangeWeaponCmd", {ACommand}, FChangeWeaponCmd)
000000000