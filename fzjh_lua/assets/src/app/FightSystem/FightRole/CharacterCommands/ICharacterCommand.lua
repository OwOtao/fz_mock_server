local interface = require("third.class.interface")

local ICharacterCommand = {}

function ICharacterCommand:getCmdType()
end

function ICharacterCommand:getCommandName()
end

function ICharacterCommand:execute()
end

return interface("ICharacterCommand", ICharacterCommand)
000000000000000