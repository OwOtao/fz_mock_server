local interface = require("third.class.interface")

local IChannelStrategy = {}

function IChannelStrategy:startGameBindingMailLayer(parentNode)
end

function IChannelStrategy:getNotOpenDebugButtonConfig()
end

function IChannelStrategy:checkGMIsOpen(name)
end

function IChannelStrategy:isNeedNewEncript()
end

function IChannelStrategy:isOpenShiMing()
end

function IChannelStrategy:isOpenPay()
end

function IChannelStrategy:getSwitchServerSaveDataVersion()
end

function IChannelStrategy:getEncryptVersion()
end

function IChannelStrategy:getHttpEncryptVersion()
end

return interface("IChannelStrategy",IChannelStrategy)0000000000000000