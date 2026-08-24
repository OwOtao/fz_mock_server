local newClass = require("third.class.NewClass")

local AChannelStrategy = require("app.models.GameChannels.AChannelStrategy")

local OuterGameTestStrategy = {}

function OuterGameTestStrategy:create()
    return OuterGameTestStrategy.new()
end

function OuterGameTestStrategy:startGameBindingMailLayer(parentNode)
    parentNode:showBindingMailLayer()
end

function OuterGameTestStrategy:checkGMIsOpen(name)
    local DebugConfig = require("app.views.layer.DebugLayer.DebugConfig")
    return DebugConfig:checkGMIsOpen(name)
end

function OuterGameTestStrategy:getNotOpenDebugButtonConfig()
    local DebugConfig = require("app.views.layer.DebugLayer.DebugConfig")
    local btnConfig = DebugConfig:getBtnConfig()
    local list = {}
    if MapIsEmpty(btnConfig) == false then
        for btn, value in pairs(btnConfig) do
            if value == 0 then
                table.insert(list, btn)
            end
        end
    end

    return list
end

function OuterGameTestStrategy:isNeedNewEncript()
    return true
end

function OuterGameTestStrategy:isOpenShiMing()
    return false
end

function OuterGameTestStrategy:isOpenPay()
    return false
end

function OuterGameTestStrategy:getSwitchServerSaveDataVersion()
    return 2
end

function OuterGameTestStrategy:getEncryptVersion()
    if Game:getVersion() == "1.3" then
        return "FZJH02"
    else
        return 1
    end
end

function OuterGameTestStrategy:getHttpEncryptVersion()
    if Game:getVersion() == "1.3" then
        return "FZJH03"
    else
        return 1
    end
end

return newClass("OuterGameTestStrategy",{AChannelStrategy},OuterGameTestStrategy)000000000000000