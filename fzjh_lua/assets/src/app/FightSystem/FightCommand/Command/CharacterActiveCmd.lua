local class = require("third.class.NewClass")
local ACommand = require("app.FightSystem.FightCommand.ACommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

--@SuperType [src.app.FightSystem.FightCommand.ACommand#ACommand]
local CharacterActiveCmd = {
    __type = CMD_TYPE.CHARACTER_ACTIVE
}

function CharacterActiveCmd:create()
    return self.new()
end

function CharacterActiveCmd:runCommand()
    local character_id = self.__characterId

    local act_id = self:getData("act_id")

    if character_id == nil then
        assert(false, "CharacterActiveCmd 参数没有释放者id ：character_id")
    end

    if act_id == nil then
        assert(false, "CharacterActiveCmd 参数没有技能 id ：act_id")
    end

    self.__fight:prepReleaseActiveSkill(character_id,act_id)
end

return class("CharacterActiveCmd", {ACommand}, CharacterActiveCmd)
0000000