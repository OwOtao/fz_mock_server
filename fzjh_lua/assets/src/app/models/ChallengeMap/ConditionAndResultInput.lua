local class = require("third.class.NewClass")
local ConditionAndResultInput = {}

function ConditionAndResultInput:create()
    return ConditionAndResultInput.new()
end

function ConditionAndResultInput:setMap(map)
    self.__map = map
end

function ConditionAndResultInput:getMap()
    return self.__map
end

function ConditionAndResultInput:setEventName(eventName)
    self.__eventName = eventName
end

function ConditionAndResultInput:setEventType(eventType)
    self.__eventType = eventType
end

function ConditionAndResultInput:getEventType()
    return self.__eventType
end

function ConditionAndResultInput:setEventArgs(eventArgs)
    self.__eventArgs = eventArgs
end

function ConditionAndResultInput:getEventArgs()
    return self.__eventArgs or {}
end

function ConditionAndResultInput:setArgs(args)
    self.__args = args
end

function ConditionAndResultInput:getArgs()
    return self.__args or {}
end

function ConditionAndResultInput:getEventName()
    return self.__eventName
end

function ConditionAndResultInput:setRoomId(roomId)
    self.__roomId = roomId
end

function ConditionAndResultInput:getRoomId()
    return self.__roomId
end

function ConditionAndResultInput:setRoleId(roleId)
    self.__roleId = roleId
end

function ConditionAndResultInput:getRoleId()
    return self.__roleId
end

return class("ConditionAndResultInput", {}, ConditionAndResultInput)
00000000000