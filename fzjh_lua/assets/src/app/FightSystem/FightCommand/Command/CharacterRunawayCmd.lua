local class = require("third.class.NewClass")
local ACommand = require("app.FightSystem.FightCommand.ACommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

--@SuperType [src.app.FightSystem.FightCommand.ACommand#ACommand]
local CharacterRunawayCmd = {
    __type = CMD_TYPE.CHARACTER_RUNAWAY
}

function CharacterRunawayCmd:create()
    return CharacterRunawayCmd.new()
end

function CharacterRunawayCmd:runCommand()
    local character_id = self.__characterId

    if character_id == nil then
        assert(false, "CharacterRunawayCmd 参数没有请求逃跑id ：character_id")
    end

    if self.__fight:getPlayerId() ~= character_id then
        --@TODO 2021-07-18 23:01:26 暂时只支持玩家逃跑
        return
    end

    self.__fight:prepRunaway(character_id)
end

return class("CharacterRunawayCmd", {ACommand}, CharacterRunawayCmd)
000000000000