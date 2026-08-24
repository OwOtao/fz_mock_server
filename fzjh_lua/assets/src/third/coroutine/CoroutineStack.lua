local CoroutineStack = {}

local ErrmsgRecord = require("app.models.Record.ErrmsgRecord.ErrmsgRecord")

local stack = {}
local stackArray = {}
local executingCoroutine = nil
local executingCoroutineName = nil
local executeStartTime = 0
local isExecuting = false

-- 添加协程
function CoroutineStack:push(name, func)
    local cor =
        coroutine.create(
        function(...)
            return select(
                2,
                xpcall(
                    func,
                    function(msg)
                        local traceback_msg = debug.traceback(msg, 5)
                        print(string.rep("CoroutineStackError:", 100), traceback_msg)
                        ErrmsgRecord:addErrmsg(traceback_msg)
                    end,
                    ...
                )
            )
        end
    )

    if isExecuting and coroutine.running() then
        table.insert(stackArray[1], {name = name, cor = cor})
        coroutine.yield()
    else
        table.insert(stackArray, {{name = name, cor = cor}})
    end
end

-- 获取正在执行的协程数目
function CoroutineStack:count()
    local count = 0
    for i = 1, #stackArray do
        count = count + #stackArray[i]
    end
    return count
end

-- 单步还行协程
function CoroutineStack:resume()
    if #stackArray == 0 then
        return false
    end
    local stack = stackArray[1]
    local callStackIndex = #stack
    local executingCoroutine = stack[callStackIndex]

    -- 开始
    if executingCoroutine.startTime == nil then
        executingCoroutine.startTime = socket.gettime()
        print("协程执行开始：", executingCoroutine.name)
    end

    -- 执行
    isExecuting = true
    local canMoveNext = coroutine.resume(executingCoroutine.cor)
    isExecuting = false
    if canMoveNext == false then
        debug.traceback(executingCoroutine.cor)
    end

    -- 结束
    if canMoveNext == false then
        table.remove(stack, callStackIndex)
        print("协程执行完成：", executingCoroutine.name, "耗时:", socket.gettime() - executingCoroutine.startTime)
    end

    if #stack == 0 then
        table.remove(stackArray, 1)
    end

    return true
end

function CoroutineStack:clear()
    stackArray = {}
end

return CoroutineStack
0000000