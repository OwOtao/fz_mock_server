local newClass = require("third.class.NewClass")

local AChannelStrategy = require("app.models.GameChannels.AChannelStrategy")

local OnlineGameStrategy = {}

function OnlineGameStrategy:create()
    return OnlineGameStrategy.new()
end

function OnlineGameStrategy:startGameBindingMailLayer(parentNode)
end

function OnlineGameStrategy:checkGMIsOpen(name)
    return true
end

function OnlineGameStrategy:getNotOpenDebugButtonConfig()
    return {}
end

function OnlineGameStrategy:showGmLayer(gmlayer)
end

function OnlineGameStrategy:isNeedNewEncript()
    if Game:getPlatformId() == "android" then 
        return true 
    elseif Game:getPlatformId() == "ios" and Game:getVersion() == "1.10.0" then
        return true
    else
        return false
    end
end

function OnlineGameStrategy:isOpenShiMing()
    return true
end

function OnlineGameStrategy:isOpenPay()
    return true
end

function OnlineGameStrategy:getSwitchServerSaveDataVersion()
    return 3
end

function OnlineGameStrategy:getEncryptVersion()
    return "FZJH02"
end

function OnlineGameStrategy:getHttpEncryptVersion()
    return "FZJH03"
end

return newClass("OnlineGameStrategy",{AChannelStrategy},OnlineGameStrategy)00000000000000