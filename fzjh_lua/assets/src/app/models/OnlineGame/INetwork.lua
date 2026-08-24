local inherit = require("third.inherit.inherit")
local interface = require("third.class.interface")
local rx = require("third.rx.rx")

local INetwork = {}

function INetwork:isHost()
end

function INetwork:connect(callback)
end

function INetwork:getOnlyId(callback)
end

function INetwork:sendRpc(networkId, funcName, args)
end

function INetwork:subscribeRpc(networkId, callback)
end

function INetwork:update(ft)
end

return interface("INetwork", INetwork)
00000000000