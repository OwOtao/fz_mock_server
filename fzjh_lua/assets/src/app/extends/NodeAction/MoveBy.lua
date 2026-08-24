local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local MoveBy = {}

function MoveBy:create(duration, x, y)
    local p = MoveBy.new()
    p:__init(duration, x, y)
    return p
end

function MoveBy:__init(duration, x, y)
    self.__duration = duration

    if type(x) == "table" then
        self.__offset = x
    else
        self.__offset = {x = x, y = y}
    end

    self.__pastTime = 0
end

function MoveBy:update(dt)
    local currPos = cc.p(self.__target:getPosition())
    local newPos = nil

    if self.__pastTime + dt < self.__duration then
        newPos = cc.pAdd(currPos, cc.pMul(self.__offset, dt / self.__duration))
        self.__pastTime = self.__pastTime + dt
    else
        newPos = cc.pAdd(currPos, cc.pMul(self.__offset, (self.__duration - self.__pastTime) / self.__duration))
        self.__isFinished = true
    end

    self.__target:setPosition(newPos)
end

return NewClass("MoveBy", {AbsNodeAction}, MoveBy)
000000000000