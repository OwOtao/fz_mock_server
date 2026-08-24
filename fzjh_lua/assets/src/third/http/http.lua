--[[
    -- get请求:
    http.open("get", url):setHeaders(headers):send():subscribe(function(statue, response)end)
]]
local Rx = require("third.rx.rx")

local http = class("http", Rx.Observable)

local log = function(...)
    if PRINT_MODE == 1 then
        print("http:", ...)
    end
end

-- get请求
function http.get(url, headers)
    return http.open("get", url):setHeaders(headers):send()
end

-- post请求
function http.post(url, headers, sendData)
    return http.open("post", url):setHeaders(headers):setSendData(sendData):send()
end

function http.create(subscribe)
    local self = http.new()
    self._subscribe = subscribe
    return self
end

-- 创建网络请求
function http.open(httpType, url)
    local _xhr = nil

    return http.create(
        function(observer)
            if _xhr == nil then
                log("http.open", observer)

                _xhr = cc.XMLHttpRequest:new()
                _xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
                _xhr:open(httpType, url, true)

                _xhr.timeout = 10
            end

            observer:onNext(_xhr)
            observer:onCompleted()
        end
    )
end

-- 设置头
function http:setHeaders(headers)
    return http.create(
        function(observer)
            local function onNext(xhr)
                log("http:setHeaders", xhr)

                if type(headers) == "table" then
                    for k, v in pairs(headers) do
                        log("setHeader", k, v)
                        xhr:setRequestHeader(k, v)
                    end
                end

                observer:onNext(xhr)
            end

            local function onCompleted()
                observer:onCompleted()
            end

            return self:subscribe(onNext, nil, onCompleted)
        end
    )
end

-- 设置发送的数据
function http:setSendData(sendData)
    return http.create(
        function(observer)
            local function onNext(xhr)
                xhr._sendData = sendData
                observer:onNext(xhr)
            end

            local function onCompleted()
                observer:onCompleted()
            end

            return self:subscribe(onNext, nil, onCompleted)
        end
    )
end

-- 加密发送数据
function http:encryptSendData(encryptFunc)
    if encryptFunc == nil then
        return self
    end

    return http.create(
        function(observer)
            local function onNext(xhr)
                xhr._sendData = encryptFunc(xhr._sendData)
                observer:onNext(xhr)
            end

            local function onCompleted()
                observer:onCompleted()
            end

            return self:subscribe(onNext, nil, onCompleted)
        end
    )
end

-- 发送
function http:send()
    return http.create(
        function(observer)
            local _isCompletedTimes = 0
            local _response = nil
            local _status = nil

            local function finished()
                _isCompletedTimes = _isCompletedTimes + 1
                if _isCompletedTimes >= 2 then
                    observer:onNext(_status, _response)
                    observer:onCompleted()
                end
            end

            local function onNext(xhr)
                log("send", xhr._postData)
                xhr:send(xhr._postData)

                xhr:registerScriptHandler(
                    function()
                        _response, _status = xhr.response, xhr.status
                        _response = _response or ""
                        
                        xhr:release()

                        finished()
                    end
                )
            end

            local function onCompleted()
                finished()
            end

            return self:subscribe(onNext, nil, onCompleted)
        end
    )
end

-- 解密收到数据

-- 设置回调
function http:onCompleted(func)
    return http.create(
        function(observer)
            local _status, _response

            local function onNext(status, response)
                _status, _response = status, response
            end

            local function onCompleted()
                func(_status, _response)
                observer:onNext(_status, _response)
                observer:onCompleted()
            end

            return self:subscribe(onNext, nil, onCompleted)
        end
    )
end

-- 订阅
function http:subscribe(onNext, onError, onCompleted)
    return self._subscribe(Rx.Observer.create(onNext, onError, onCompleted))
end

-- 请求测试
function http.test()
    local get1 =
        http.get("http://www.baidu.com"):onCompleted(
        function(status, response)
            print("get1", "status", status)
        end
    )

    local get2 =
        http.get("http://www.baidu.com"):onCompleted(
        function(status, response)
            print("get2", "status", status)
        end
    )

    get1:concat(get2):subscribe(
        nil,
        nil,
        function()
            print("完成")
        end
    )
end

return http
00