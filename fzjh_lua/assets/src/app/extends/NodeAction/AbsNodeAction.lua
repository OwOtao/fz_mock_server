local abstract = require("third.class.abstract")
local INodeAction = require("app.extends.NodeAction.INodeAction")
--@SuperType [src.app.extends.NodeAction.INodeAction#INodeAction]
local AbsNodeAction = {}

function AbsNodeAction:create(duration, x, y)
    local p = AbsNodeAction.new()
    return p
end

function AbsNodeAction:ctor()
    self.__duration = 0
    self.__currTime = 0
    self.__target = nil
    self.__isFinished = false
    self.__isRemoved = false
end

function AbsNodeAction:setTarget(target)
    self.__target = target
end

function AbsNodeAction:getDuration()
    return self.__duration
end

function AbsNodeAction:isFinished()
    return self.__isFinished
end

function AbsNodeAction:onFinish()
end

function AbsNodeAction:isRemoved()
    return self.__isRemoved
end

function AbsNodeAction:remove()
    self.__isRemoved = true
end

return abstract("NodeAction", {INodeAction}, AbsNodeAction)
000