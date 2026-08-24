local inherit = require("third.inherit.inherit")

local function log(...)
    print("Coroutine:", ...)
end

local Coroutine = {}

function Coroutine:create(name, func, ...)
    local p = inherit({}, Coroutine)
    p:init(name, func, ...)
    return p
end

function Coroutine:init(name, func, ...)
    if type(func) == "function" then
        self._func = coroutine.create(func)
    elseif type(func) == "thread" then
        self._func = func
    else
        error([[error: type(func) = ]] .. type(func))
    end

    self._name = name
    self._params = {...}
    self._firstResume = true
    self._beginTime = socket.gettime()
end

function Coroutine:getName()
    return self._name
end

function Coroutine:resume()
    local canMoveNext = true
    if self._firstResume then
        self._firstResume = false
        canMoveNext = coroutine.resume(self._func, unpack(self._params))
    else
        canMoveNext = coroutine.resume(self._func)
    end

    if canMoveNext == false then
        return false, debug.traceback(self._func)
    end
    return canMoveNext
end

function Coroutine:getRunningTime()
    return socket.gettime() - self._beginTime
end

-- Decorator:addLog("Coroutine", Coroutine)

return Coroutine
000