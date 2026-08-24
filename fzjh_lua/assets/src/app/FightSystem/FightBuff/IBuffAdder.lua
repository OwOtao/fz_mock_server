local interface = require("third.class.interface")
local IBuffAdder = {}

function IBuffAdder:canAdd(mine, target)
end

function IBuffAdder:add(mine, target)
end

return interface("IBuffAdder", IBuffAdder)
00000000