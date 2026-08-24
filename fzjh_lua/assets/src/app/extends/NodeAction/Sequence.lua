local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local Sequence = {}

function Sequence:create(...)
    local p = Sequence.new()
    p:__init(...)
    return p
end

function Sequence:__init(...)
    self.__actions = {...}
    self.__currIndex = 1
    self.__isFinished = false
end

function Sequence:update(dt)
    local action = self.__actions[self.__currIndex]
    if action then
        action:setTarget(self.__target)
        action:update(dt)
        if action:isFinished() then
            action:onFinish()
            self.__currIndex = self.__currIndex + 1
        end
    else
        self.__isFinished = true
    end
end

return NewClass("Sequence", {AbsNodeAction}, Sequence)
00000000000