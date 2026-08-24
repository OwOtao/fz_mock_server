local newClass = require("third.class.NewClass")

local HttpListManager = {
    list = {}, -- 存储请求列表
    lock = false, -- 请求锁开关
    handel = nil, -- 句柄
    waitingLayer = nil, --遮罩
    __currHttpRequestId = nil -- 当前正在http回调函数中
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/10/09 18:34:35
-- @params
-- @desc 刷新调度,达到及时更新的效果
function HttpListManager:init()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/10/09 18:34:53
-- @params
-- @desc 添加一个请求至请求列表
function HttpListManager:addRequest(requestId, waitText, func, ...)
    table.insert(self.list, {id = requestId, waitText = waitText, func = func, params = {...}})

    -- 加入请求后马上尝试执行
    self:update()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/10/09 18:35:07
-- @params
-- @desc 移除第一个请求列表中的请求信息
function HttpListManager:removeFirstRequest(requestId)
    if MapIsEmpty(self.list) then
        return
    end

    if requestId == nil then
        table.remove(self.list, 1)
    else
        for i, v in ipairs(self.list) do
            if v.id == requestId then
                table.remove(self.list, i)
                break
            end
        end
    end

    self.lock = false

    if MapIsEmpty(self.list) then
        if self.waitingLayer then
            self.waitingLayer:hideAndRemoveSelf()
            self.waitingLayer = nil
        end
    end

    -- 完成一个请求后,尝试继续执行下一个请求
    self:update()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/10/09 18:35:19
-- @params
-- @desc 调用列表中的第一个请求
function HttpListManager:callRequest(index)
    if index == nil then
        index = 1
    end
    self.lock = true
    local requestId = self.list[index].id
    local func = self.list[index].func
    local params = self.list[index].params
    local isNeedWait = params[5]
    if isNeedWait == nil then
        isNeedWait = false
    end
    self:call(func, requestId, params)

    if self.waitingLayer == nil and isNeedWait == true then
        self.waitingLayer = WaitingLayer:createInRunningScene()
        self.waitingLayer:setText(self.list[1].waitText or "请稍后...")
    end
end

function HttpListManager:call(func, requestId, params)
    assert(type(requestId) == "number", "requestId must be number")
    for i = 1, 10 do
        params[tostring(i)] = params[i]
        if type(params[tostring(i)]) == "function" then
            local func = params[tostring(i)]
            params[tostring(i)] = function(...)
                local needSet__currHttpRequestId = self.__currHttpRequestId == nil
                if needSet__currHttpRequestId then
                    self.__currHttpRequestId = requestId
                end

                local rets = {func(...)}

                if needSet__currHttpRequestId then
                    self.__currHttpRequestId = nil
                end

                return unpack(rets)
            end
        end
    end
    func(params["1"], params["2"], params["3"], params["4"], params["5"], params["6"], params["7"], params["8"], params["9"], params["10"])
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/10/09 18:35:31
-- @params
-- @desc 更新方法,提供给调度器使用
function HttpListManager:update()
    if #self.list <= 0 or self.lock == true then
        return
    end
    self:callRequest()
end

return HttpListManager
00000000000