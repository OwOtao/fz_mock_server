local NewClass = require("third.class.NewClass")
local AbsNodeAction = require("app.extends.NodeAction.AbsNodeAction")
local ScaleTo = {}

function ScaleTo:create(duration, x, y)
    local p = ScaleTo.new()
    p:__init(duration, x, y)
    return p
end

function ScaleTo:__init(duration, x, y)
    self.__duration = duration
    if type(x) == "table" then
        self.__toScale = x
    elseif y == nil then
        self.__toScale = {x = x, y = x}
    else
        self.__toScale = {x = x, y = y}
    end
    self.__changeScale = nil
    self.__pastTime = 0
    self.__isInited = false
end

function ScaleTo:__lazyInit()
    if self.__isInited == false then
        self.__isInited = true

        self.__changeScale = {x = self.__toScale.x - self.__target:getScaleX(), y = self.__toScale.y - self.__target:getScaleY()}
    end
end

function ScaleTo:update(dt)
    self:__lazyInit()

    local currScale = cc.p(self.__target:getScaleX(), self.__target:getScaleY())
    local newScale = nil

    if self.__pastTime + dt < self.__duration then
        newScale = cc.pAdd(currScale, cc.pMul(self.__changeScale, dt / self.__duration))
        self.__pastTime = self.__pastTime + dt
    else
        newScale = cc.pAdd(currScale, cc.pMul(self.__changeScale, (self.__duration - self.__pastTime) / self.__duration))
        self.__isFinished = true
    end

    self.__target:setScaleX(newScale.x)
    self.__target:setScaleY(newScale.y)
end

return NewClass("ScaleTo", {AbsNodeAction}, ScaleTo)
000000000000