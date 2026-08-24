local class = require("third.class.NewClass")
local ACommand = require("app.FightSystem.FightCommand.ACommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

--@SuperType [src.app.FightSystem.FightCommand.ACommand#ACommand]
local FRecoverQiCmd = {
    __type = CMD_TYPE.RECOVER_QI
}

function FRecoverQiCmd:create()
    return FRecoverQiCmd.new()
end

function FRecoverQiCmd:runCommand()
    local character_id = self.__characterId

    if character_id == nil then
        assert(false, "FRecoverQiCmd 参数没有请求切换武器id ：character_id")
    end

    self.__fight:prepRecoverQi(character_id)
end

return class("FRecoverQiCmd", {ACommand}, FRecoverQiCmd)
000000000