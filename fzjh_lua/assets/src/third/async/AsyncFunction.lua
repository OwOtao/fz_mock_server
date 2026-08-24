local AsyncFunction = {}

AsyncFunction.YieldType = {
    Finish = 0
}

function AsyncFunction:create(func, args)
    local obj = setmetatable({}, {__index = AsyncFunction})
    obj:init(func, args)
    return obj
end

function AsyncFunction:init(func, args)
    assert(type(func) == "function", "func must be a function")

    self.coroutine =
        coroutine.create(
        function(...)
            return select(
                2,
                xpcall(
                    func,
                    function(msg)
                        print(string.rep("AsyncFunctionError:", 100), debug.traceback(msg, 5))
                    end,
                    ...
                )
            )
        end
    )

    self.args = args
    self.result = nil
    self.isFinished = false
end

--[[
    @desc: 通过回调方法创建异步方法
    author:TangJian
    time:2022-03-31 17:35:07
    --@functionWithCallback: 一个有回调的方法
	--@args: functionWithCallback的参数列表，在列表中标出callback的位置，异步函数执行完成后会直接返回callback的参数
    @return:
]]
function AsyncFunction:createWithCallbackFunction(functionWithCallback, args)
    return AsyncFunction:create(
        function(thread, args)
            local callbackIndex = nil
            for i, v in ipairs(args) do
                if v == "callback" then
                    assert(callbackIndex == nil, "Only one callback function is allowed")
                    callbackIndex = i
                end
            end
            assert(callbackIndex ~= nil, "callback is nil")

            local hasFinished = false
            local results = nil

            args[callbackIndex] = function(...)
                hasFinished = true
                results = {...}
            end

            functionWithCallback(table.unpack(args))

            while hasFinished == false do
                thread:yield()
            end
            thread:finish(results)
        end,
        args
    )
end

function AsyncFunction:asyncCall(func, ...)
    local args = {...}
    return table.unpack(
        AsyncFunction:create(
            function(async)
                async:finish({func(table.unpack(args))})
            end,
            {...}
        ):call()
    )
end

function AsyncFunction:asyncAwaitWithCallback(func, ...)
    return table.unpack(self:createWithCallbackFunction(func, {...}):await())
end

function AsyncFunction:asyncAwait(func, ...)
    local args = {...}
    return table.unpack(
        AsyncFunction:create(
            function(async)
                async:finish({func(table.unpack(args))})
            end,
            {...}
        ):await()
    )
end

-- 尝试获取结果
function AsyncFunction:tryGetResult()
    if self.isFinished == false then
        local r = table.pack(coroutine.resume(self.coroutine, self, self.args))
        local canMoveNext, yieldType = r[1], r[2]
        if canMoveNext == false then
            error(debug.traceback(self.coroutine) .. " : " .. tostring(yieldType))
        end
        assert(canMoveNext == true, "coroutine error")
        if yieldType == AsyncFunction.YieldType.Finish then
            self.isFinished = true
            self.result = table.pack(table.unpack(r, 3, r.n))
            self:__tryFinish()
        end
    end

    if self.result == nil then
        return self.isFinished, nil
    else     
        return self.isFinished, table.unpack(self.result)
    end
end

-- 阻塞执行完成,并且获得返回值
function AsyncFunction:call(args)
    self.args = args or self.args
    while true do
        local isFinished = self:tryGetResult()
        if isFinished then
            break
        end
    end
    return table.unpack(self.result)
end

-- 等待执行完成,并且获得返回值
function AsyncFunction:await(args)
    self.args = args or self.args
    while true do
        local isFinished = self:tryGetResult()
        if isFinished then
            break
        end
        coroutine.yield()
    end
    return table.unpack(self.result)
end

function AsyncFunction:wait(time)
    local beginTime = socket.gettime()
    while socket.gettime() - beginTime < time do
        coroutine.yield()
    end
end

function AsyncFunction:onFinish(func)
    self.__onFinish = func
    return self
end

-- 尝试完成异步函数
function AsyncFunction:__tryFinish()
    if self.isFinished then
        if self.__onFinish then
            self.__onFinish(table.unpack(self.result))
            self.__onFinish = nil
        end
    end
end

function AsyncFunction:yield()
    coroutine.yield()
end

function AsyncFunction:finish(...)
    coroutine.yield(AsyncFunction.YieldType.Finish, ...)
end

return AsyncFunction
0