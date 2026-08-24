local interface = require("third.class.interface")

local ISerializable = {}

function ISerializable:serialize()
end

return interface("ISerializable", ISerializable)
0