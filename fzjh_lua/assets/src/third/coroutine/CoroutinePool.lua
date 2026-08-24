local inherit = require("third.inherit.inherit")
local Coroutine = require("third.coroutine.Coroutine")
local AsyncFunction = require("third.async.AsyncFunction")
local LogSystem = require("app.models.LogSystem.LogSystem")

local function log(...)
    LogSystem:logWithTab("协程池:", ...)
end

local CoroutinePool = {}

function CoroutinePool:create()
    local p = inherit({}, CoroutinePool)
    p:init()
    return p
end

function CoroutinePool:init()
    self._list = {}
    self._removeList = {}
    self._frameMaxDuration = 0.001
end

function CoroutinePool:update(dt)
    -- 执行协程
    self:doUpdate(dt)

    -- 清理
    for i = #self._removeList, 1, -1 do
        self:remove(self._removeList[i])
        table.remove(self._removeList, i)
    end
end

--[[
    @desc: 获得协程池当前大小
    author:TangJian
    time:2022-03-28 15:24:26
    @return:
]]
function CoroutinePool:count()
    return #self._list
end

-- 添加协程
function CoroutinePool:add(name, func, ...)
    log("添加", name)

    table.insert(self._list, Coroutine:create(name, func, ...))
end

--[[
    @desc: 添加异步函数
    author:TangJian
    time:2022-03-28 15:24:45
    --@name: 函数名称
	--@func: 函数体
	--@args: 函数参数
    @return:
]]
function CoroutinePool:addAsync(name, func, ...)
    self:add(
        name,
        function(...)
            AsyncFunction:create(func, {...}):await()
        end,
        ...
    )
end

-- 移除协程
function CoroutinePool:remove(name)
    for i = 1, #self._list do
        if self._list[i]:getName() == name then
            self:removeByIndex(i)
            break
        end
    end
end

function CoroutinePool:contains(name)
    for i = 1, #self._list do
        if self._list[i]:getName() == name then
            return true
        end
    end
    return false
end

-- 通过索引移除
function CoroutinePool:removeByIndex(index)
    -- log("移除", self._list[index]:getName())
    table.remove(self._list, index)
end

-- 执行协程
function CoroutinePool:doUpdate(dt)
    local cor = self._list[1]

    if cor then
        local canMove = cor:resume()
        -- log("执行", cor:getName(), "耗时", cor:getRunningTime())

        if canMove == false then
            log("完成", cor:getName(), "耗时", cor:getRunningTime())
            table.insert(self._removeList, cor:getName())
        end
    end
end

-- Decorator:addLog("CoroutinePool", CoroutinePool, {"update", "doUpdate"})

return CoroutinePool
000