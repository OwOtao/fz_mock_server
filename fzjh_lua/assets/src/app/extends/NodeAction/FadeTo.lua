local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local FadeTo = {}

function FadeTo:create(duration, alpha)
    local p = FadeTo.new()
    p:__init(duration, alpha)
    return p
end

function FadeTo:__init(duration, alpha)
    self.__duration = duration
    self.__toAlpha = alpha
    self.__changeAlpha = nil
    self.__pastTime = 0
    self.__isInited = false
end

function FadeTo:__lazyInit()
    if self.__isInited == false then
        self.__isInited = true

        self.__changeAlpha = self.__toAlpha - self.__target:getOpacity()
        self.__currAlpha = self.__target:getOpacity()
    end
end

function FadeTo:update(dt)
    self:__lazyInit()

    local currAlpha = self.__currAlpha
    local newAlpha = nil

    if self.__pastTime + dt < self.__duration then
        newAlpha = currAlpha + self.__changeAlpha * dt / self.__duration
        self.__pastTime = self.__pastTime + dt
    else
        newAlpha = currAlpha + self.__changeAlpha * (self.__duration - self.__pastTime) / self.__duration
        self.__isFinished = true
    end
    self.__currAlpha = newAlpha
    self.__target:setOpacity(newAlpha)
end

return NewClass("FadeTo", {AbsNodeAction}, FadeTo)
0000000