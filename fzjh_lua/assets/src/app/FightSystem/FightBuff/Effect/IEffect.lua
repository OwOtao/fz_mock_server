local interface = require("third.class.interface")
local IEffect = {}

function IEffect:refresh()
end

function IEffect:getType()
end

function IEffect:getShieldValue()
end

function IEffect:comsumeShieldValue(value)
end

return interface("IEffect", IEffect)
0000000000000