local INetworkingPeer = require("app.models.OnlineGame.INetworkingPeer")
local NewClass = require("third.class.NewClass")

local rx = require("third.rx.rx")
local FunctionManager = require("app.extends.FunctionManager")
local json = require("third.json.json")

local function log(...)
    -- print("NetworkingPeer:", ...)
end

local NetworkingPeer = {}

function NetworkingPeer:create(ip, port)
    local p = NetworkingPeer.new()
    self:init(ip, port)
    return p
end

function NetworkingPeer:ctor()
    self._ip = "127.0.0.1"
    self._port = 5454

    self._isHost = false -- 是否是主机
    self._isOffline = false -- 是否离线

    self._isConnecting = false -- 是否在连接中
    self._isConnected = false -- 是否连上服务器

    self._websocket = nil
    self._subject = rx.ReplaySubject.create()

    self._functions = {}
end

function NetworkingPeer:init(ip, port)
    assert(type(ip) == "string")
    assert(type(port) == "number")
    self._ip = ip
    self._port = port
end

function NetworkingPeer:setIsHost(b)
    self._isHost = b
end

function NetworkingPeer:isHost()
    return self._isHost
end

function NetworkingPeer:setIsOffline(b)
    self._isOffline = b
end

function NetworkingPeer:isOffline()
    return self._isOffline
end

function NetworkingPeer:setCloseCallback(callback)
    assert(type(callback) == "function")
    self.__connect_close_callback = callback
end

function NetworkingPeer:setOnMessage(callback)
    assert(type(callback) == "function")
    self.__message_callback = callback
end

function NetworkingPeer:setNetErrorCallback(callback)
    assert(type(callback) == "function")
    self.__err_callback = callback
end

-- @desc 连接游戏
function NetworkingPeer:connect(callback)
    if self._isConnecting or self._isConnected then
        log("不能反复连接")
        return false
    end

    self._isConnecting = true

    log("connect")
    -- self._websocket = cc.WebSocket:create("http://139.9.179.52:80/game")
    -- 连接日本服务器
    -- self._websocket = cc.WebSocket:create("http://167.179.67.242:5454/game")
    self._websocket = cc.WebSocket:create("http://" .. self._ip .. ":" .. self._port .. "/game")

    -- @desc 注册回调以上的函数
    self._websocket:registerScriptHandler(
        function(str)
            self._isConnecting = false
            self._isConnected = true
            self._isOffline = false

            self:__onStart(str)

            -- 连接成功回调
            callback(true)
        end,
        cc.WEBSOCKET_OPEN
    )
    self._websocket:registerScriptHandler(
        function(str)
            self:__onRecv(str)
        end,
        cc.WEBSOCKET_MESSAGE
    )
    self._websocket:registerScriptHandler(
        function(str)
            self:__onClose(str)
        end,
        cc.WEBSOCKET_CLOSE
    )
    self._websocket:registerScriptHandler(
        function(str)
            self.__onError(str)
        end,
        cc.WEBSOCKET_ERROR
    )
end

-- @desc 重启游戏
function NetworkingPeer:resetGame(callback)
    local __callback = function(response, status)
        print("response, status", response, status)
        if status == 200 and response == "ok" then
            callback(true)
        else
            callback(false)
        end
    end
    self:__get("http://127.0.0.1:5454/restartGame", "", nil, __callback)
end

-- @desc 请求服务器获取唯一Id
function NetworkingPeer:getOnlyId(callback)
    local sendData = {
        e = 302
    }

    self:__send(json.encode(sendData))

    self._subject:filter(
        function(data)
            if data.EventType == 303 then
                return true
            end
            return false
        end
    ):subscribe(
        function(data)
            callback(data.OnlyId)
        end
    )
end

function NetworkingPeer:sendData(send_data)
    return self:__send(json.encode(send_data))
end

-- @desc 发送远程过程调用
function NetworkingPeer:sendRpc(networkId, funcName, args)
    if args == nil then
        args = {}
    end

    local sendData = {
        e = 301,
        ni = networkId,
        fn = funcName,
        ps = args
    }
    self:__send(json.encode(sendData))
end

-- @desc 订阅远程过程调用
function NetworkingPeer:subscribeRpc(networkId, callback)
    log("subscribeRpc", networkId, callback)
    self._subject:filter(
        function(data)
            log("data.EventType", data.EventType, data.NetworkId, networkId)

            if data.EventType == 301 then
                return data.NetworkId == networkId
            end
            return false
        end
    ):subscribe(
        function(data)
            log("networkId = " .. tostring(networkId) .. ", funcName = " .. tostring(data.FuncName) .. ", index = " .. tostring(data.Index))

            -- @desc 将远程过程调用存下来慢慢执行
            local funcName = data.FuncName
            local params = data.Params

            table.insert(
                self._functions,
                {
                    callback,
                    funcName,
                    params
                }
            )
        end,
        function(errmsg)
            log("errmsg = " .. tostring(errmsg))
        end
    )
end

function NetworkingPeer:update(ft)
    local beginTime = os.clock()
    self:__executeRpc()
end

------------------
-- 以下为私有方法 --
------------------
function NetworkingPeer:__onStart(str)
    log("game onStart", str)
end

function NetworkingPeer:__onRecv(str)
    log("game onRecv" .. tostring(str))
    local tb = json.decode(str)

    self.__message_callback(tb)

    -- self._subject:onNext(tb)
end

function NetworkingPeer:__onClose(str)
    log("game onClose", str)
    self._isConnected = false
    if self.__connect_close_callback then
        self.__connect_close_callback(str)
    end
end

function NetworkingPeer:__onError(str)
    log("game onError", str)
    if self.__err_callback then
        self.__err_callback(str)
    end
end

function NetworkingPeer:__send(str)
    self._websocket:sendString(str)
end

function NetworkingPeer:__executeRpc()
    for i = 1, 100 do
        if self._functions[1] ~= nil then
            self._functions[1][1](self._functions[1][2], self._functions[1][3])
            table.remove(self._functions, 1)
        else
            break
        end
    end
end

function NetworkingPeer:__get(url, sendStr, headers, callback)
    -- 创建请求
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open("get", url, true)
    xhr:registerScriptHandler(
        function()
            if callback then
                callback(xhr.response, xhr.status)
            end
        end
    )

    -- 设置超时
    xhr.timeout = 10

    -- 设置头
    if headers ~= nil then
        for k, v in headers do
            xhr:setRequestHeader(k, v)
        end
    end

    xhr:send(sendStr)
end

return NewClass("NetworkPeer", {INetworkingPeer}, NetworkingPeer)
00000000000