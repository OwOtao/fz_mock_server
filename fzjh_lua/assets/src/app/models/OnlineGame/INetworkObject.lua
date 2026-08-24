local interface = require("third.class.interface")

local INetworkObject = {}

function INetworkObject:getNetwork()
end

function INetworkObject:isLocal()
end

return interface("INetworkObject", INetworkObject)
00