local abstract = require("third.class.abstract")

local ICharacterCommand = require("app.FightSystem.FightRole.CharacterCommands.ICharacterCommand")

--@SuperType [src.app.FightSystem.FightRole.CharacterCommands.ICharacterCommand#ICharacterCommand]
local ACharacterCommand = {
    __frameIndex = 0,
    __priority = 0
}

function ACharacterCommand:getCmdType()
    return self.__type
end

function ACharacterCommand:setCharacterSystem(sys)
    --@RefType [src.app.FightSystem.FightRole.CharacterSystem#CharacterSystem]
    self.__characterSystem = sys
end

function ACharacterCommand:setOwnerId(c_id)
    self.__characterId = c_id
end

function ACharacterCommand:getOwnerId()
    return self.__characterId
end

function ACharacterCommand:setFrameIndex(index)
    self.__frameIndex = index
end

function ACharacterCommand:getFrameIndex()
    return self.__frameIndex
end

function ACharacterCommand:getPriority()
    return self.__priority
end

return abstract("ACharacterCommand", {ICharacterCommand}, ACharacterCommand)
00000000000