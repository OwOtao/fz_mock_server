local class = require("third.class.NewClass")

local ACommand = require("app.FightSystem.FightCommand.ACommand")

local FightCommons = require("app.FightSystem.FightCommons")

local CMD_TYPE = FightCommons.FIGHT_CMD_TYPE

--@SuperType [src.app.FightSystem.FightCommand.ACommand#ACommand]
local TestCommand = {
    __type = CMD_TYPE.TEST
}

function TestCommand:create()
    return self.new()
end

function TestCommand:runCommand()
    self.__fight:popMessage("this is test cmd")
end


return class("TestCommand",{ACommand},TestCommand)000