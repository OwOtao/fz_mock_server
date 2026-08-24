local interface = require("third.class.interface")
local INodeAction = {}

function INodeAction:setTarget(target)
end

function INodeAction:getDuration()
end

function INodeAction:isFinished()
end

function INodeAction:isRemoved()
end

function INodeAction:update(dt)
end

return interface("INodeAction", INodeAction)
000000000000000