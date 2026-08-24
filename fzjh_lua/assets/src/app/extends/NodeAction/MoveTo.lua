local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local MoveTo = {}

function MoveTo:create(duration, x, y)
    local p = MoveTo.new()
    p:__init(duration, x, y)
    return p
end

function MoveTo:__init(duration, x, y)
    self.__duration = duration
    self.__offset = nil

    if type(x) == "table" then
        self.__moveToPos = x
    else
        self.__moveToPos = {x = x, y = y}
    end

    self.__pastTime = 0
    self.__isInited = false
end

function MoveTo:__lazeInit()
    if self.__isInited == false then
        self.__isInited = true

        self.__offset = cc.pSub(self.__moveToPos, cc.p(self.__target:getPosition()))
    end
end

function MoveTo:update(dt)
    self:__lazeInit()

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

return NewClass("MoveTo", {AbsNodeAction}, MoveTo)
00000000000