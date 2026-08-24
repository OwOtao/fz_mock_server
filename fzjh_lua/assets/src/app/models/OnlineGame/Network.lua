local INetwork = require("app.models.OnlineGame.INetwork")
local NewClass = require("third.class.NewClass")

local rx = require("third.rx.rx")

local NetworkingPeer = require("app.models.OnlineGame.NetworkingPeer")

local function log(...)
    -- print("Network:", ...)
end

local Network = {}

function Network:create(ip, port)
    local p = Network.new()
    p:init(ip, port)
    return p
end

function Network:ctor()
    self._subject = rx.ReplaySubject:create()
end

function Network:init(ip, port)
    --@RefType[src.app.models.OnlineGame.NetworkingPeer#NetworkingPeer]
    self._networkingPeer = NetworkingPeer:create(ip, port)

    self._networkingPeer:setCloseCallback(
        function(str)
            log(" close : " .. str)
        end
    )

    self._networkingPeer:setNetErrorCallback(
        function(str)
            log(" error : " .. str)
        end
    )

    self._networkingPeer:setOnMessage(
        function(data)
            log(" recv Message: ")
            if self.__onRecvDataFunc ~= nil then
                self.__onRecvDataFunc(data)
            end
        end
    )
end

function Network:setIsHost(b)
    self._networkingPeer:setIsHost(b)
end

function Network:isHost()
    return self._networkingPeer:isHost()
end

-- @desc 连接游戏
function Network:connect(callback)
    return self._networkingPeer:connect(
        function(success)
            callback(success)
        end
    )
end

-- @desc 重启游戏
function Network:resetGame(callback)
    return self._networkingPeer:resetGame(
        function(success)
            return callback(success)
        end
    )
end

-- @desc 请求服务器获取唯一Id
function Network:getOnlyId(callback)
    return self._networkingPeer:getOnlyId(callback)
end

-- @desc 发送远程过程调用
function Network:sendRpc(networkId, funcName, args)
    if args == nil then
        args = {}
    end

    local send_data = {
        e = 301,
        ni = networkId,
        fn = funcName,
        ps = args
    }

    return self._networkingPeer:sendData(send_data)
end

function Network:sendFrame(network_id, frame_data)
    local send_data = {
        e = 304,
        ni = network_id,
        frame = frame_data
    }
    return self._networkingPeer:sendData(send_data)
end

function Network:setRecvDataFunc(func)
    assert(type(func) == "function")
    self.__onRecvDataFunc = func
end

-- @desc 订阅远程过程调用
function Network:subscribeRpc(networkId, callback)
    return self._networkingPeer:subscribeRpc(networkId, callback)
end

function Network:update(ft)
    return self._networkingPeer:update(ft)
end

return NewClass("Network", {INetwork}, Network)
000000