local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local RemoveSelf = {}

function RemoveSelf:create()
    local p = RemoveSelf.new()
    return p
end

function RemoveSelf:update(dt)
    self.__isFinished = true
end

function RemoveSelf:onFinish()
    self.__target:removeFromParent()
end

return NewClass("RemoveSelf", {AbsNodeAction}, RemoveSelf)
0000000000000