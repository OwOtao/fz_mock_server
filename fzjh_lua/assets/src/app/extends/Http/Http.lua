local newClass = require("third.class.NewClass")

local BaseHttp = require("app.extends.Http.BaseHttp")

local HttpListManager = require("app.extends.Http.HttpListManager")

local Http = inherit({__requestId = 0},BaseHttp,HttpListManager)

local WaitingLayer = require("app.views.layer.PopLayer.WaitingLayer")

function Http:retryWithHeaderAsync(waitText, doType, url, sendData, headers, callback, isNeedWait, retryType, isNeedEncrypt)
    Game:addBlockAsyncFunc("retryWithHeader" .. url, function()
        local waitingLayer = WaitingLayer:createInRunningScene()
        waitingLayer:setText(waitText or "请稍后...")
    
        local isFinished = false

        if PRINT_MODE == 1 then
            print("url = "..tostring(url))
        end

        -- 记录局部变量的table
        local localTable = {}


        if doType == "post" then
            isNeedEncrypt = Helper:getDef(isNeedEncrypt, NEED_ENCRYPT)
        else
            isNeedEncrypt = false -- add by XiaoZhiWei 2018/09/19 18:37:04 原有的版本get请求没有这个参数,所以传递false
        end
        -- 发送请求
        function localTable.doSend()
            local isFinished = false
            local callbackParams = {}
            local callback = function(response, status)
                callbackParams.response = response
                callbackParams.status = status
                isFinished = true
            end
            self:send(doType, url, sendData, headers, callback, isNeedWait, isNeedEncrypt)

            while isFinished == false do
                coroutine.yield()
            end
            
            waitingLayer:hideAndStopAction()
            localTable.callback(callbackParams.response, callbackParams.status)
        end

        -- 重试方法
        function localTable.callback(...)
            if retryType == nil or retryType == 0 then
                callback(...)
                isFinished = true
                return
            end
            -- 返回值如果为true 才会隐藏
            local notNeedRetry, status, errcode = callback(...)
            if not notNeedRetry then
                local userid = DataBase:getDataWithString("userid")
                local err_text_format = "%s;%s;%s;%s"
                local err_text = string.format(err_text_format, string.gsub(url, DOMAIN, ""), tostring(status), tostring(errcode), tostring(userid))
                if retryType == HTTP_MANAGER_RETRY_TYPE_RETRY then
                    local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                        function()
                        end)

                    buttonPopLayer:setErrorText(err_text)
                    
                    -- 获取按钮事件
                    local touchEventType = nil
                    repeat
                        touchEventType = buttonPopLayer:getButton1CurrTouchEvent()
                        coroutine.yield()
                    until touchEventType == ccui.TouchEventType.ended
                    
                    -- 按钮事件为松开，移除重试界面并且再次请求
                    buttonPopLayer:hideAndRemoveSelf()
                    localTable.doSend()
                elseif retryType == HTTP_MANAGER_RETRY_TYPE_RETRY_CANCEL then
                    local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                        function()
                            localTable.doSend()
                        end,
                        "取消",
                        function()
                            isFinished = true
                        end)
                    buttonPopLayer:setErrorText(err_text)
                else
                    local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                        function()
                        end)
                    buttonPopLayer:setErrorText(err_text)
                    -- 获取按钮事件
                    local touchEventType = nil
                    repeat
                        touchEventType = buttonPopLayer:getButton1CurrTouchEvent()
                        coroutine.yield()
                    until touchEventType == ccui.TouchEventType.ended

                    -- 按钮事件为松开，移除重试界面并且再次请求
                    buttonPopLayer:hideAndRemoveSelf()
                    localTable.doSend()
                end
            else
                isFinished = true
            end
        end
        -- 请求网络
        localTable.doSend()

        while isFinished == false do
            coroutine.yield()
        end

        waitingLayer:hideAndRemoveSelf()
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 可重试, 带头 post请求       增加一个是否加密的参数 isNeedEncrypt 传true，对sendData加密
function Http:retryPostWithHeader(...)
    self:retryWithHeaderAsync("请稍后...", "post", ...)
end

--[[
    @desc: 可重试, 带头 带等待文本的post请求
    author:TangJian
    time:2022-03-15 14:37:36
    --@waitText:
	--@args: 
    @return:
]]
function Http:retryPostWithHeaderAndWaitText(waitText, ...)
    self:retryWithHeaderAsync(waitText, "post", ...)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 可重试, 带头 get请求
function Http:retryGetWithHeader(...)
    self:retryWithHeaderAsync("请稍后...", "get", ...)
end

--[[
    @desc: 可重试, 带头,带等待文本的get请求
    author:TangJian
    time:2022-03-15 14:36:33
    --@waitText:
	--@args: 
    @return:
]]
function Http:retryGetWithHeaderAndWaitText(waitText, ...)
    self:retryWithHeaderAsync(waitText, "get", ...)
end

function Http:retryWithHeader(requestId,doType, url, sendData, headers, callback, isNeedWait, retryType, isNeedEncrypt)
    if PRINT_MODE == 1 then
        print("url = "..tostring(url))
    end
    -- 记录局部变量的table
    local localTable = {}


    if doType == "post" then
        isNeedEncrypt = Helper:getDef(isNeedEncrypt, NEED_ENCRYPT)
    else
        isNeedEncrypt = false -- add by XiaoZhiWei 2018/09/19 18:37:04 原有的版本get请求没有这个参数,所以传递false
    end
    -- 发送请求
    function localTable.doSend()
        self:send(doType, url, sendData, headers, localTable.callback, isNeedWait, isNeedEncrypt)
    end

    -- 重试方法
    function localTable.callback(...)
        if retryType == nil or retryType == 0 then
            callback(...)
            self:removeFirstRequest(requestId)
            return
        end
        -- 返回值如果为true 才会隐藏
        local notNeedRetry, status, errcode = callback(...)
        if not notNeedRetry then
            local userid = DataBase:getDataWithString("userid")
            local err_text_format = "%s;%s;%s;%s"
            local err_text = string.format(err_text_format, string.gsub(url, DOMAIN, ""), tostring(status), tostring(errcode), tostring(userid))
            if retryType == HTTP_MANAGER_RETRY_TYPE_RETRY then
                local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                    function()
                        localTable.doSend()
                    end)
                    buttonPopLayer:setErrorText(err_text)
            elseif retryType == HTTP_MANAGER_RETRY_TYPE_RETRY_CANCEL then
                local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                    function()
                        localTable.doSend()
                    end,
                    "取消",
                    function()
                        self:removeFirstRequest(requestId)
                    end)
                buttonPopLayer:setErrorText(err_text)
            else
                local buttonPopLayer = ButtonPopLayer:createCustomInRunningScene("网络错误, 请重试", "重试",
                    function()
                        localTable.doSend()
                    end)
                buttonPopLayer:setErrorText(err_text)
            end
        else
            self:removeFirstRequest(requestId)
        end
    end
    -- 请求网络
    localTable.doSend()
end

--@desc: 可重试, 带头 post请求
--@author:LvBin
--@time:2024-06-27 16:36:23
--@args: 
--@return
function Http:retryPostWithHeaderOrig(...)
    self.__requestId = self.__requestId + 1
    local currRequestId = self.__requestId
    self:addRequest(currRequestId,"请稍后...",function(...)
        self:retryWithHeader(currRequestId,"post", ...)
    end, ...)
end

--@desc: 可重试, 带头 get请求
--@author:LvBin
--@time:2024-06-27 16:36:32
--@args: 
--@return
function Http:retryGetWithHeaderOrig(...)
    self.__requestId = self.__requestId + 1
    local currRequestId = self.__requestId
    self:addRequest(currRequestId,"请稍后...",function(...)
        self:retryWithHeader(currRequestId,"get", ...)
    end, ...)
end

--@desc: 可重试, 带头 带等待文本的post请求
--@author:LvBin
--@time:2024-06-27 16:37:12
--@waitText:
	--@args: 
--@return
function Http:retryPostWithHeaderAndWaitTextOrig(waitText, ...)
    self.__requestId = self.__requestId + 1
    local currRequestId = self.__requestId
    self:addRequest(currRequestId,waitText,function(...)
        self:retryWithHeader(currRequestId,"post", ...)
    end, ...)
end

--@desc: 可重试, 带头,带等待文本的get请求
--@author:LvBin
--@time:2024-06-27 16:37:44
--@waitText:
	--@args: 
--@return
function Http:retryGetWithHeaderAndWaitTextOrig(waitText, ...)
    self.__requestId = self.__requestId + 1
    local currRequestId = self.__requestId
    self:addRequest(currRequestId,waitText,function(...)
        self:retryWithHeader(currRequestId,"get", ...)
    end, ...)
end

return Http000000000