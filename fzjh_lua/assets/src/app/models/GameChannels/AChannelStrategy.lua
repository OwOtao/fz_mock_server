local abstarct = require("third.class.abstract")

local IChannelStrategy = require("app.models.GameChannels.IChannelStrategy")

local AChannelStrategy = {}

function AChannelStrategy:setGameChannelContext(context)
    self.__channelContext = context
end

function AChannelStrategy:getGameChannelContext()
    return self.__channelContext
end

return abstarct("AChannelStrategy", IChannelStrategy, AChannelStrategy)
00