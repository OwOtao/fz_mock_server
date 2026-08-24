local ActionOf4399 = {
    __isOpen = false,
    __actionId = "",
}

function ActionOf4399:setActionOpen(open)
    self.__isOpen = open
end

function ActionOf4399:setActionId(id)
    self.__actionId = id
end

function ActionOf4399:getActionId()
    return self.__actionId
end

function ActionOf4399:getActionOpen()
    return self.__isOpen
end

return ActionOf4399000000000000000