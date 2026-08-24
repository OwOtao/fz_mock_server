local interface = require("third.class.interface")

local IMapBuilder = {}

function IMapBuilder:create(mapId)
end

function IMapBuilder:build()
end

function IMapBuilder:getMap()
end

return interface("IMapBuilder", IMapBuilder)
000000000000