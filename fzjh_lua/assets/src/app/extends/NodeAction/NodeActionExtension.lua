local Node = cc.Node

function Node:__nodeActionLazyInit()
    self.__nodeAction = {}
end

function Node:doAction(action)
end

function Node:actionUpdate(dt)
end
000