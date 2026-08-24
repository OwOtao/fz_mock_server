local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local Spawn = {}

function Spawn:create(...)
    local p = Spawn.new()
    p:__init(...)
    return p
end

function Spawn:__init(...)
    self.__actions = {...}
    self.__currIndex = 1
    self.__isFinished = false
end

function Spawn:update(dt)
    local isFinished = true
    for _, action in ipairs(self.__actions) do
        action:setTarget(self.__target)
        if action:isFinished() == false then
            isFinished = false
            action:update(dt)
            
            if action:isFinished() then
                action:onFinish()
            end
        end
    end

    if isFinished then
        self.__isFinished = true
    end
end

return NewClass("Spawn", {AbsNodeAction}, Spawn)
000000000000000