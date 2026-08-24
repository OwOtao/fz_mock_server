-- -- local luaTableEncode, luaTableDecode = require("app.views.tableToString")
-- local FubenClient = {}
-- local ifclient = nil

-- -- 副本事件
-- local FUBEN_EVENT_TYPE = 300
-- local PING_EVENT_TYPE = 0X0010

-- local TYPE_SET = 0
-- local TYPE_GET = 1
-- local TYPE_RESULT= 2
-- local TYPE_ERROR = 3

-- local CONNECT_STATE_NONE = 0
-- local CONNECT_STATE_OPEN = 2001
-- local CONNECT_STATE_SUSPEND = 2002
-- local CONNECT_STATE_CLOSE = 2003
-- local CONNECT_STATE_OPENING = 2004

-- local ROLE_ACTION_COMEIN = 0 -- add by XiaoZhiWei 2017/05/25 10:16:31 进入房间
-- local ROLE_ACTION_LEAVE = 1 -- add by XiaoZhiWei 2017/05/25 10:17:13 离开副本
-- local ROLE_ACTION_QIECUO = 2 -- add by XiaoZhiWei 2017/05/25 10:17:38 副本切磋
-- local ROLE_ACTION_JUEDOU = 3 -- add by XiaoZhiWei 2017/05/25 10:17:52 副本决斗
-- local ROLE_ACTION_XIAOXI = 4 -- add by XiaoZhiWei 2017/05/25 10:18:31 副本消息
-- local ROLE_ACTION_CHAKAN = 5 -- add by XiaoZhiWei 2017/05/25 10:57:28 查看信息
-- local SERVER_ACTION_JUEDOU1 = 6 -- add by XiaoZhiWei 2017/05/26 11:38:29 服务器下发决斗消息
-- local SERVER_ACTION_CHECK_IDLE = 7 -- add by XiaoZhiWei 2017/05/26 11:38:29 服务器检测客户端是否是idle状态

-- local username = ""
-- local password = ""
-- --local serverDomain = "120.24.215.82"
-- local serverDomain = "192.168.1.136"
-- local resource = "1"
-- local currentState = CONNECT_STATE_CLOSE

-- local __callBack = nil -- add by XiaoZhiWei 2017/05/25 10:04:44 回调函数

-- function FubenClient:send(...)
-- 	ifclient:sendEvent(...)
-- end

-- local auth = 
-- {
	-- uuid = Game:getIdfv(),
	-- platform  = Game:getPlatformId(),
	-- channel = Game:getChannelId()
-- }

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:24:48
-- -- @desc  进入副本
-- function FubenClient:comeIn(mapId, roomId, roomName,onlyId)
-- 	local tb = {
-- 		mapId = mapId,
-- 		roomId = roomId,
-- 		roomName = roomName
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_COMEIN, jsonStr, onlyId)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:24:48
-- -- @desc  离开副本
-- function FubenClient:leave(mapId, roomId, onlyId)
-- 	local tb = {
-- 		mapId = mapId,
-- 		roomId = roomId
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_LEAVE, jsonStr, onlyId)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:24:48
-- -- @desc  副本切磋
-- function FubenClient:qieCuo(userid, onlyId)
-- 	local tb = {
-- 		userid = userid,
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_QIECUO, jsonStr, onlyId)
-- end
-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:24:48
-- -- @desc  副本决斗
-- function FubenClient:jueDou(userid, onlyId)
-- 	local tb = {
-- 		userid = userid,
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_JUEDOU, jsonStr, onlyId)
-- end
-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:24:48
-- -- @desc  副本消息
-- function FubenClient:xiaoxi(mapId, roomId, text, onlyId)
-- 	local tb = {
-- 		mapId = mapId,
-- 		roomId = roomId,
-- 		text = text
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_XIAOXI, jsonStr, onlyId)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:24:48
-- -- @desc  副本查看
-- function FubenClient:chakan(userid, onlyId)
-- 	self:send(userid, '1', TYPE_GET, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, "", onlyId)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/26 11:48:02
-- -- @desc 接受切磋/决斗
-- function FubenClient:accept(targetUserid, action, time, onlyId)
-- 	local tb = {
-- 		userid = targetUserid,
-- 		time = time,
-- 		result = "YES"
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_RESULT, FUBEN_EVENT_TYPE, action, jsonStr, onlyId)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/26 11:50:18
-- -- @desc 拒绝切磋/决斗
-- function FubenClient:reject(targetUserid, action, time, onlyId)
-- 	local tb = {
-- 		userid = targetUserid,
-- 		time = time,
-- 		result = "NO"
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_RESULT, FUBEN_EVENT_TYPE, action, jsonStr, onlyId)
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/26 11:50:18
-- -- @desc 当前的idle状态
-- function FubenClient:sendIdle(isIdle, onlyId)
-- 	local tb = {
-- 		userid = targetUserid,
-- 		time = time,
-- 		result = "NO"
-- 	}
-- 	local jsonStr = json.encode(tb)
-- 	self:send(serverDomain, '0', TYPE_RESULT, FUBEN_EVENT_TYPE, action, jsonStr, onlyId)	
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:05:49
-- -- @desc 回调状态
-- local function callBackStatus(eventName, params)
-- 	if __callBack then
-- 		__callBack(eventName, params)
-- 	end
-- end

-- local function onMessageRecvCallback(params)
-- 	print("onMessageRecvCallback params = "..tostring(params))
	
-- 	params = luaTableDecode(params)
-- 	for k,v in pairs(params) do
-- 		print(tostring(k) .. " = " .. tostring(v))
-- 	end
-- 	callBackStatus("消息", params)
-- end

-- local function onEventRecvCallback(params)
-- 	print("onEventRecvCallback params = "..tostring(params))
	
-- 	params = luaTableDecode(params)
-- 	for k,v in pairs(params) do
-- 		print(tostring(k) .. " = " .. tostring(v))
-- 	end

-- 	if params.actionCode == nil then
-- 	elseif params.actionCode == ROLE_ACTION_COMEIN then
-- 		if params.type == TYPE_RESULT then
-- 			callBackStatus("加入房间成功", params)
-- 		elseif params.type == TYPE_SET then
-- 			callBackStatus("玩家加入房间", params)
-- 		else
-- 			callBackStatus("加入房间失败", params)
-- 		end
-- 	elseif params.actionCode == ROLE_ACTION_LEAVE then 
-- 		if params.type == TYPE_RESULT then
-- 			callBackStatus("离开房间成功", params)
-- 		elseif params.type == TYPE_SET then
-- 			callBackStatus("玩家离开房间", params)
-- 		else
-- 			callBackStatus("离开房间失败", params)
-- 		end
-- 	elseif params.actionCode == ROLE_ACTION_QIECUO then
-- 		if params.type == TYPE_RESULT then
-- 			callBackStatus("接受切磋", params)
-- 		elseif params.type == TYPE_SET then
-- 			callBackStatus("拒绝切磋", params)
-- 		else
-- 			callBackStatus("切磋请求失败", params)
-- 		end
-- 	elseif params.actionCode == ROLE_ACTION_JUEDOU then
-- 		if params.type == TYPE_RESULT then
-- 			callBackStatus("决斗请求已发送", params)
-- 		elseif params.type == TYPE_SET then
-- 			callBackStatus("对方请求决斗", params)
-- 		else
-- 			callBackStatus("决斗请求失败", params)
-- 		end
-- 	elseif params.actionCode == ROLE_ACTION_XIAOXI then
-- 	elseif params.actionCode == ROLE_ACTION_CHAKAN then
-- 		if params.type == TYPE_RESULT then
-- 			callBackStatus("成功查看", params)
-- 		elseif params.type == TYPE_GET then
-- 			FubenClient:send(params.fromUid, params.fromResource, TYPE_RESULT, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, User:getRole():getDsc(), params.id)
-- 		else
-- 			callBackStatus("查看失败", params)
-- 		end
-- 	elseif params.actionCode == SERVER_ACTION_JUEDOU1 then
-- 		if params.type == TYPE_RESULT then
-- 		elseif params.type == TYPE_SET then
-- 			callBackStatus("决斗请求结果", params)
			
-- 			-- FubenClient:send(params.fromUid, params.fromResource, TYPE_RESULT, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, User:getRole():getDsc(), params.id)
-- 		else
-- 			-- callBackStatus("查看失败", params)
-- 		end
-- 	elseif params.actionCode == SERVER_ACTION_CHECK_IDLE then
-- 		if params.type == TYPE_GET then
-- 			callBackStatus("是否空闲状态", params)
-- 			-- FubenClient:send(params.fromUid, params.fromResource, TYPE_RESULT, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, User:getRole():getDsc(), params.id)
-- 		else
-- 			-- callBackStatus("查看失败", params)
-- 		end
-- 	end 

-- end

-- local function onConnectSuccessCallback(params)
-- 	print("onConnectSuccessCallback")
-- 	currentState = CONNECT_STATE_OPEN
-- 	if luaTableEncode == nil then 
-- 		print("luaTableEncode = nil")
-- 	else
-- 		print("luaTableEncode = " .. type(luaTableEncode))
-- 	end
-- 	-- 连接成功
-- 	params = luaTableDecode(params)

-- 	for k,v in pairs(params) do
-- 		print(tostring(k) .. " = " .. tostring(v))
-- 	end
-- 	PopText(params.uid .. "连接成功")

-- 	callBackStatus("连接成功", params)
-- end

-- local function onConnectErrorCallback(params)
-- 	print("onConnectErrorCallback")
-- 	currentState = CONNECT_STATE_CLOSE
-- 	-- 连接出错
-- 	params = luaTableDecode(params)
-- 	print("lua回调funcName = "..params.funcName)

-- 	for k,v in pairs(params) do
-- 		print(tostring(k) .. " = " .. tostring(v))
-- 	end

-- 	PopText("连接出错" .. params.reason)

-- 	callBackStatus("连接出错", params)
-- end

-- local function onDisconnectCallback(params)
-- 	print("onDisconnectCallback")
-- 	currentState = CONNECT_STATE_CLOSE
-- 	-- 断开连接
-- 	params = luaTableDecode(params)

-- 	print("lua回调funcName = "..params.funcName)

-- 	for k,v in pairs(params) do
-- 		print(tostring(k) .. " = " .. tostring(v))
-- 	end

-- 	PopText("断开连接")

-- 	callBackStatus("断开连接", params)
-- end

-- function FubenClient:disconnect()
-- 	if ifclient ~= nil then
-- 		ifclient:disconnect(false)
-- 	end
-- end

-- function FubenClient:isConnect()
-- 	return (currentState == CONNECT_STATE_OPEN)
-- end

-- -- 只用调用一次，后面可以使用reconnect来重复连接
-- function FubenClient:connect(uid, extra)
-- 	print("FubenClient:connect " .. uid)
-- 	username = uid
-- 	auth.userid = uid
-- 	extra = Helper:getDef(extra, {})
-- 	extra.auth = JMForLua:encrypt(json.encode(extra))
-- 	local params = json.encode(extra)
-- 	if ifclient == nil then
-- 		ifclient = wyf.Ifclient:create(serverDomain, 9529, username, params, 17, 100000)
-- 		ifclient:setCallback(onMessageRecvCallback, onEventRecvCallback, onConnectSuccessCallback
-- 			, onConnectErrorCallback, onDisconnectCallback)
-- 	end
-- 	local currentState = ifclient:getState();
-- 	print("currentState = " .. currentState)

-- 	self:reconnect()
-- end

-- -- 断开连接后，如果要重连，直接调用本函数
-- function FubenClient:reconnect()
-- 	if currentState == CONNECT_STATE_OPENING then
-- 		return
-- 	end

-- 	if (currentState == CONNECT_STATE_CLOSE) then
-- 		-- 初始化构造连接
-- 		-- 只能调用一次
-- 		ifclient:connect(10)
-- 		currentState = CONNECT_STATE_OPENING
-- 	elseif (currentState == CONNECT_STATE_OPEN) then
-- 		-- 当前状态是打开的，不用管，直接返回
-- 		return
-- 	elseif (currentState == CONNECT_STATE_SUSPEND) then
-- 		-- 当前状态是挂起的，恢复连接
-- 	end
-- end

-- -----------------------------------------------------------------------------------------------------------
-- -- @author XiaoZhiWei
-- -- @time 2017/05/25 10:02:32
-- -- @desc 设置链接回调函数
-- function FubenClient:setCallBack(func)
-- 	__callBack = func
-- end

-- return FubenClient
0