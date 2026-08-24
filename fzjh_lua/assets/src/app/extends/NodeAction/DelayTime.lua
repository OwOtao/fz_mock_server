local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local DelayTime = {}

function DelayTime:create(duration)
    local p = DelayTime.new()
    p:__init(duration)
    return p
end

function DelayTime:__init(duration, alpha)
    self.__duration = duration
end

function DelayTime:update(dt)
    self.__currTime = self.__currTime + dt
    if self.__currTime >= self.__duration then
        self.__isFinished = true
    end
end

return NewClass("DelayTime", {AbsNodeAction}, DelayTime)
0000