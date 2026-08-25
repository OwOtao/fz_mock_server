local interface = require("third.class.interface")

local Ihurt = {}

function Ihurt:getType()
end

function Ihurt:getValue()
end

function Ihurt:isAutoHurt()
end

function Ihurt:isActiveHurt()
end

return interface("Ihurt", Ihurt)
0000000