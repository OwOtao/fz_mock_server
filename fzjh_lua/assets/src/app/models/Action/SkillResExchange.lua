local class = require("third.class.NewClass")

local SkillResExchange = {}

function SkillResExchange:create()
    return SkillResExchange:new()
end

function SkillResExchange:ctor()
    self.__hongDianState = false
    self.__actionId = nil
    self.__roomId = nil
    self.__mapId = nil
end

function SkillResExchange:setActionId(actionId)
    self.__actionId = actionId
end

function SkillResExchange:init(func)
    local currencyVersion = User:getRole():getCurrencyVersion()

    HttpManagerEx:getMerchantEventInfo(self.__actionId, currencyVersion, function(status, errcode, errmsg, data)
        if status == 200 and errcode == 0 then
            local location = data.location
    
            self.__mapId = location[1]
            self.__roomId = location[2]
            self.__hongDianState = data.hongDianState

            if func then
                func()
            end
        else
            PopText(errmsg)
        end
    end,IS_SHOW_WAITING)
end

function SkillResExchange:getMapIdAndRoomId()
    return self.__mapId, self.__roomId
end

function SkillResExchange:getHongDianState()
    return self.__hongDianState
end

return class("SkillResExchange", {}, SkillResExchange)
0000