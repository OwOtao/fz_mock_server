local GameChannelContext = {
    __context = nil
}

local initStrategy = function()
    if Game:getChannelId() == "test" and (Game:getVersion() == "1.1" or Game:getVersion() == "1.2" or Game:getVersion() == "1.3") then
        local outerGameTestStrategy = require("app.models.GameChannels.Channels.OuterGameTestStrategy"):create()
        outerGameTestStrategy:setGameChannelContext(GameChannelContext)
        GameChannelContext.__context = outerGameTestStrategy
    else
        local onlineGameStrategy = require("app.models.GameChannels.Channels.OnlineGameStrategy"):create()
        onlineGameStrategy:setGameChannelContext(GameChannelContext)
        GameChannelContext.__context = onlineGameStrategy
    end
end

initStrategy()

function GameChannelContext:isNeedNewEncript()
    return self.__context:isNeedNewEncript()
end

function GameChannelContext:isOpenShiMing()
    return self.__context:isOpenShiMing()
end

function GameChannelContext:isOpenPay()
    return self.__context:isOpenPay()
end

function GameChannelContext:getSwitchServerSaveDataVersion()
    return self.__context:getSwitchServerSaveDataVersion()
end

function GameChannelContext:getEncryptVersion()
    return self.__context:getEncryptVersion()
end

function GameChannelContext:showMailBindLayer(layer)
    self.__context:startGameBindingMailLayer(layer)
end

function GameChannelContext:checkGMIsOpen(name)
    return self.__context:checkGMIsOpen(name)
end

function GameChannelContext:getNotOpenDebugButtonConfig()
    return self.__context:getNotOpenDebugButtonConfig()
end

function GameChannelContext:getHttpEncryptVersion()
    return self.__context:getHttpEncryptVersion()
end

return GameChannelContext
000000000000