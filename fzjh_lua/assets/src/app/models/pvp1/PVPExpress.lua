cc.exports.PVP_BASE_ZHAO_COUNT = 1

-- 发送数据的等待超时时间2秒
local SEND_TIMEOUT = 2.0
-- 这里是放置江湖有关房间逻辑的代码，不包括UI层，仅逻辑

-- 已经确认好的一些房间动作常量
-- 这里一般出现在房间游戏还没开始的时候
local CREATE_ROOM_CODE = 1003				-- 房间创建
local INVITE_CODE = 2						-- 邀请
local EXIT_CODE = 3							-- 退出				
local ENTER_CODE = 4						-- 进入
local BAN_CODE = 5							-- 禁止
local READY_CODE = 6						-- 准备
local UNREADY_CODE = 7						-- 取消准备
local INFO_CODE = 8							-- 房间信息（包括所有在房间内的玩家信息）
local START_CODE = 9						-- 开始游戏
local STOP_CODE = 10						-- 停止游戏
local ALL_READY_CODE = 11					-- 所有人都已经准备好
local HOLDER_CHANGE_CODE = 12				-- 房主变化
local USER_INFO_CODE = 13					-- 用户信息
local ACTION_GAMEOVER_CODE = 14				-- 战斗结束

-- 这里一般发生在游戏开始后的地图加载期
local MAP_INIT_CODE = 100					-- 游戏地图
local ALL_MAP_INIT_CODE = 101

-- 这里是游戏已经开始的相关动作
local ACTION_SYNC_DATA_CODE = 200			-- 同步数据
local ACTION_SYNC_ALL_CODE = 201			-- 同步当前所有
local ACTION_PAUSE_GAME_CODE = 202			-- 游戏暂停（不同于stop）
local ACTION_RESUME_GAME_CODE = 203			-- 游戏恢复（和暂停配套使用）

-- 几个type状态
local TYPE_SET = 0							-- XX端发给服务器的event一般用set，服务器受理成功返回result，失败返回error
local TYPE_GET = 1							-- XX端想要得到服务端的数据一般用get，服务器受理成功返回result，失败返回error
local TYPE_RESULT= 2						-- 结果
local TYPE_ERROR = 3						-- 错误

-- message的title区分
local TITLE_TIPS = "tp"						-- 提示
local TITLE_CHAT = "ct"						-- 聊天栏内容
local TITLE_DATA = "dt"						-- 数据

-- client: 本地的客户端
-- rid: 房间的一个唯一ID
-- name: 房间名
-- creator: 房间创建者
-- holder: 房间当前拥有者
-- localuser: 本地的角色
-- users: 房间内的所有角色，包括localuser
-- callbacks: 房间事件回调
local PVPRoom = {
	client = nil,
	reconnectTimes = 0,
	rid = nil,
	name = nil,
	creator = nil,
	holder = nil,
	start = false,
	localuser = {},
	targetuser = {},
	users = {},
	fight = nil,
	connectSuccess = false,
	localcallback = {},
	gotime = 0,
	fightDatas = {},
	fightDataCount = 0,
	done = false,
	zhaoSend = {
		sending = false,
		sendId = 0,
		sendTime = 0
	}
}

function PVPRoom:create(targetUid, targetName, key, time, callback, pvpDomain, pvpPort, randomSeed)
	local room = clone(PVPRoom)
	room.client = require("app.models.pvp1.PVPClient")
	room.client:disconnect()
	room:init()
	room.callabck = callback
	room:createNow(targetUid, targetName, key, time, pvpDomain, pvpPort, randomSeed)

	cc.Director:getInstance():getRunningScene():uniqueDelayFunc("PVPRoom", 30, 
		function()
			print("开始游戏超时")
			if room.done == false then
				if room.client:isConnect() ~= true and room.fight == nil then
					-- value 1 自己获胜，2 对方获胜，3平手，4   自己逃跑
					room.done = true
					room.client:disconnect()
	        		room.callabck("战斗异常", nil, nil, 3)
	        		PopText("未成功连接服务器，请重新尝试")
	        	elseif room.client:isConnect() == true and room.fight == nil then
	        		room.done = true
	        		local uid = User:getUserId() .. ""
	        		room:gameover("战斗异常", 0)
					room.client:disconnect()
	        		room.callabck("战斗异常", nil, nil, 3)
	        		PopText("对战创建失败，请重新尝试")
				end
			end
		end) 

	return room
end

function PVPRoom:createNow(targetUid, targetName, key, time, pvpDomain, pvpPort, randomSeed)
	print(targetUid .. " " .. targetName .. " " .. key)
	self.connectTimeout = time + GetLocalTime()
	-- 设置会调
	self.Callbacks = function (eventName, params) 
		print("eventName = " .. eventName)
		if self.done == true then
			return
		end
		if eventName == "connectSuccess" then
			-- 登陆成功后，什么都不用做
			self.connectSuccess = true
			self.zhaoSend.sending = false
			self.zhaoSend.sendTime = 0
			--self.reconnectTimes = 0
			if self.fight ~= nil and self.fight:getState() == "start" then
				self:requeryZhao()
			end
		elseif eventName == "connectError" then
			self:processConnectionBroken(params.reason)
		elseif eventName == "disconnect" then
			self:processConnectionBroken(params.reason)
		end
	end
	self.randomSeed = randomSeed
	self.client:setOtherCallback(self.Callbacks)
	self.client:setRoomCallback(self.localcallbacks)
    self.client:connect(pvpDomain, pvpPort, targetName, key, randomSeed, (time / 2 - 1))
    self.rid = key
end

function PVPRoom:processConnectionBroken(reason)
	if reason == "作弊" then
		self.done = true
		local uid = User:getUserId() .. ""
		-- self:gameover("战斗异常", 0)
		self.client:disconnect()
		self.callabck("战斗异常", nil, nil, 3)
	--	PopText("战斗异常")
		return
	end


	if self.connectSuccess == false then
		-- 如果时间已经超过，那么将会停止重连
		if GetLocalTime() > self.connectTimeout then
			self.done = true
			self.callabck("战斗异常", "连接失败")
			return
		end
		self.client:reconnect()
		return
	end

	if self.client:isConnect() ~= true and self.fight ~= nil then
		self.reconnectTimes = self.reconnectTimes + 1

		if self.reconnectTimes < 2 then 
			if reason == "server shutdown" then
				self.reconnectTimes = 3
			else
				--self.client:connect()
				self.client:reconnect()
			end
		end
    end
end

function PVPRoom:clearFight()
	self.zhaoSend.sending = false
	self.zhaoSend.sendId = 0
	self.fightDatas = {}
	self.fightDataCount = 0
	self.gotime = 0
	self.fight = nil
	collectgarbage("collect")
end

-- zhaoProxy实现函数
-- @index  从0开始
-- @return 得到一个数据，如果没有，返回nil
function PVPRoom:takeData(index)
	return self.fightDatas[index]
end

function PVPRoom:addZhao(zhao)
	
	if self.fight then 
		if self.fight:getFightIsOffLine() then
			zhao.title = TITLE_DATA
			self.fightDatas[self.fight.currentDataIndex] = zhao
			--保持与服务器连接，防止断线重连回滚
			self:addChat({msg = "ping"})
			return
		end
	end

	if self.reconnectTimes >= 2 and self.client:isConnect() ~= true then
		if zhao.x_m == "runaway" then
			local zhaoSize = self.fightDataCount
			zhao.index = zhaoSize
			self:addData(zhao)
		end

		return
	end


	if self:isZhaoSending() then
		return
	end
	-- 得到一个ID，然后标记，等待服务器返回
	self.zhaoSend.sendId = math.random(1, 1000000)
	self.zhaoSend.sending = true
	self:sendZhao(zhao, self.zhaoSend.sendId)
end

-- 查询startIndex之后（包括startIndex）是否有相应的招式
-- @roleId 角色id
-- @startiIndex 开始位置
-- @mode 模式 "au" or "ac"
-- @return true or false
function PVPRoom:hasZhao(roleId, startIndex, mode)
	for i = startIndex, self.fightDataCount do
		local data = self.fightDatas[i]
		if data ~= nil and data.x_f == roleId and data.x_m == mode then
			return true
		end
	end

	return false
end

function PVPRoom:addChat(msg)
	msg = json.encode(msg)
	-- TODO 聊天数据
	self.client:sendMessage(self.rid, '2', TITLE_CHAT, msg,math.random(1,100000))
end

-- 发送招式到服务器，然后在广播下来
-- @zhao 招式
function PVPRoom:sendZhao(zhao, id)
	self.zhaoSend.sendTime = GetLocalTime()
	self:sendMessage(TITLE_DATA, zhao, id)
end

-- 是否正在发送招
-- @return true or false
function PVPRoom:isZhaoSending()
	-- 得到上次时间
	if GetLocalTime() - self.zhaoSend.sendTime > SEND_TIMEOUT then
		return false
	end

	return self.zhaoSend.sending
end

-- 请求下发招式
-- @start 开始的位置
function PVPRoom:requeryZhao(start)
	if start ~= nil and type(start) == "number" then
		local tb = {
			start = start
		}
		self:sendEvent(TYPE_GET, ACTION_SYNC_DATA_CODE, tb)
	else
		local tb = {
			start = self.fightDataCount
		}
		self:sendEvent(TYPE_GET, ACTION_SYNC_DATA_CODE, tb)
	end
end

-- 在指定位置加入招
-- @startIndex 招加入的位置
-- @datas 带有数值的招
function PVPRoom:addDatas(startIndex, datas)
    -- 如果放入的索引比大，表示数据已经异常了，要重新去获取
    local zhaoSize = self.fightDataCount
    print("zhao size = " .. zhaoSize .. " startIndex = " .. startIndex)
    if startIndex > zhaoSize then
        -- 请求新的招式
        self:requeryZhao(zhaoSize)
        return 
    elseif startIndex < zhaoSize then
        return
    end

    -- 第一招的k是0
    for k, v in pairs(zhaos) do
        self.fightDatas[k] = v
    end
end

-- 在指定位置加入招
-- @startIndex 招加入的位置
-- @datas 带有数值的招
function PVPRoom:addData(data)
    -- 如果放入的索引比大，表示数据已经异常了，要重新去获取
    local zhaoSize = self.fightDataCount
    print("zhao size = " .. zhaoSize .. " data index = " .. data.index)
    if data.index > zhaoSize then
        -- 请求新的招式
        self:requeryZhao(zhaoSize)
        return 
    elseif data.index < zhaoSize then
        return
    end

    -- 第一招的k是0
    self.fightDatas[data.index] = data
    self.fightDataCount = self.fightDataCount + 1
end

-- 战斗逻辑过来的会调
function PVPRoom:fightListener(eventName, ...)
	print("fightListener eventName = " .. eventName)
    if eventName == "init" then
    	-- 战斗准备好之后，设置一个数据代理
    	-- 因为room已经实现pvp即时战斗的数据，所以直接设置
    	self.fight:setDataProxy(self)
    	self:initLayer()
   	elseif eventName == "start" then

   	elseif eventName == "stop"	then
   		self:clearFight()
   	end
end

function PVPRoom:init()
	self.localcallbacks = function(...)
		self:localcallback(...)
	end

	-- 初始化所有动作会调
	self.actionCallback = {}

	self.actionCallback[INFO_CODE] = function (self, typ, tb)
		if typ == TYPE_RESULT then
			print("房间信息")
			local roominfo = tb
			self.start = false
			self.name = roominfo.name
			-- 发送本地数据
			-- 构造本地数据
			print("type = " .. type(roominfo.players))
			for k,v in pairs(roominfo.players) do
				print(tostring(k) .. " = " .. tostring(v))
				print("--------------------- v.username = " .. v.username .. ";", type(v.username))
				print("--------------------- localusername = " .. self.client:getLocalUsername() .. ";", type(self.client:getLocalUsername()))
				local b = (v.username == self.client:getLocalUsername())
				print(b)
				if b then
					if DEBUG_MODE == 1 then
						PopText("房间信息 : 同步本地用户" .. v.username .. "数据")
					end
					self.localuser = v
				else
					if DEBUG_MODE == 1 then
						PopText("房间信息 : 同步对方用户" .. v.username .. "数据")
					end
					self.targetuser = v
				end

				self.users[v.username] = v
			end
		end
	end

	self.actionCallback[START_CODE] = function (self, typ, tb)
		-- 游戏开始
		-- TODO 构造地图
		if typ == TYPE_SET then
			print("游戏开始")
			PopText("游戏开始")
			local targetFirst = true
			local firstNo = 2
			if self.localuser.index == 0 then
				targetFirst = false
				firstNo = 1
			end
			if targetFirst then
				if DEBUG_MODE == 1 then
					PopText("对方  先出招")
				end
				print("对方  先出招")
			else 
				if DEBUG_MODE == 1 then
					PopText("本地  先出招")
				end
				print("本地  先出招")
			end
			-- local FightLayer = require("app.models.pvp1.PVPFightLayer")

	  --       self.fightLayer = FightLayer:createPVP(self.localuser.info, self.targetuser.info, firstNo
	  --       	, function (eventName, ...) 
	  --       		self:fightLayerListener(eventName) 
	  --       	  end
	  --       	, function(eventName, ...) 
	  --       	  	self:fightListener(eventName, ...) 
	  --       	  end)
	  --       self.fight = self.fightLayer:getFight()

	        -- 游戏开始，创建一个Fight
	        -- 战斗创建完成后会调
	        local PVPFight = require("app.models.pvp1.PVPFight")
	        self.fight = PVPFight:createFight(self.localuser.info, self.targetuser.info, firstNo, self, self.randomSeed)
	        self.fight:setCallback(function (eventName, localRole, targetRole, value)
	        	-- value 1 自己获胜，2 对方获胜，3平手，4   自己逃跑
	        	if eventName == "gameover" then
	        		if self.done == true then
		        		return
		        	end
		        	self.done = true
	        		-- 将fight 置为nil，在其他情况下就能知道是否重连什么的
	        		self.fight = nil

	        		if value == 1 or value == 4 then
        				self:gameover("战斗正常", value, localRole:getAttr("userid"))
        			elseif value == 2 or value == 5 then
        				self:gameover("战斗正常", value, localRole:getAttr("userid"))
        			else
        				self:gameover("战斗正常", value, localRole:getAttr("userid"))
        				--self:gameover("pingshou")
        			end
	        		self.client:disconnect()
	        		self.callabck("战斗结束", localRole, targetRole, value)
	        	end
	        	if eventName == "start" then
	        		self.callabck("战斗开始")
	        	end
	        end)
	        self.fight:show()
		end
	end

	self.actionCallback[STOP_CODE] = function (self, typ, tb)
	end

	self.actionCallback[ALL_READY_CODE] = function (self, typ, tb)
	end

	self.actionCallback[HOLDER_CHANGE_CODE] = function (self, typ, tb)
	end

	self.actionCallback[USER_INFO_CODE] = function (self, typ, tb)
		if typ == TYPE_SET then
			print("用户信息")
			local userinfo = tb.user
			for k,v in pairs(userinfo) do
				print(tostring(k) .. " = " .. tostring(v))
				print("--------------------- v.username = " .. v.username .. ";", type(v.username))
				print("--------------------- localusername = " .. self.client:getLocalUsername() .. ";", type(self.client:getLocalUsername()))
				local b = (v.username == self.client:getLocalUsername())
				print(b)
				if b then
					if DEBUG_MODE == 1 then
						PopText("用户信息 : 同步本地用户" .. v.username .. "数据")
					end
					self.localuser = v
				else
					if DEBUG_MODE == 1 then
						PopText("用户信息 : 同步对方用户" .. v.username .. "数据")
					end
					self.targetuser = v
				end
				self.users[v.username] = v
			end
		end
	end

	self.actionCallback[MAP_INIT_CODE] = function (self, typ, tb)

	end

	self.actionCallback[ALL_MAP_INIT_CODE] = function (self, typ, tb)
		-- 地图都准备好
		-- 游戏可以开始了
		if typ == TYPE_SET then
			print("游戏地图都初始化完毕，游戏开始")
			self.fight:start()
		end
		-- self.fightLayer.isRunFromRoom = true
		-- -- 游戏动起来
		-- self.goTime = GetLocalTime()
  -- 		self.fightLayer:schedule(
	 --        function(ft)
	 --            -- for i=1, 10 do
	 --            if self.goTime == 0 then 
	 --            	return
	 --            end
	 --            local currentTime = GetLocalTime()
	 --            local deltaTime = currentTime - self.goTime
	 --            print(self.goTime .. "      " .. currentTime .. "      deltaTime = " .. deltaTime)
	 --            local shouldCurrentFrame = math.ceil(deltaTime / 0.033333333333)
	 --            if self.fight.currentFrameCount < shouldCurrentFrame then
	 --            	for i = self.fight.currentFrameCount, shouldCurrentFrame do
	 --            		self.fight:updateFrame()
	 --            	end
	 --            end
	 --        -- end
	 --        end, 0)
	end

	self.actionCallback[ACTION_SYNC_DATA_CODE] = function (self, typ, tb)

	end

	self.actionCallback[ACTION_SYNC_ALL_CODE] = function (self, typ, tb)

	end

	self.actionCallback[ACTION_PAUSE_GAME_CODE] = function (self, typ, tb)

	end

	self.actionCallback[ACTION_RESUME_GAME_CODE] = function (self, typ, tb)

	end

	self.dataCallback = {}

	-- 收到房间发来的提示等信息
	self.dataCallback[TITLE_TIPS] = function (self, from, tb, id)
	end

	-- 收到房间的聊天信息
	self.dataCallback[TITLE_CHAT] = function (self, from, tb, id)
		if tb.msg == "gameover" then
			if self.fight then
				self.fight:setFightIsOffLine(true) 
			end
		end
	end

	-- 收到游戏中的数据
	-- 只在游戏开始后才能收到
	self.dataCallback[TITLE_DATA] = function (self, from, tb, id)
		print("sendid = " .. self.zhaoSend.sendId .. " recvid = " .. id)
		if self.zhaoSend.sendId ~= nil and self.zhaoSend.sendId == id then
			self.zhaoSend.sending = false
		end
		self:addData(tb)
	end
end


-- 从服务器下发的会调，还没有解析，只是丢给了房间
function PVPRoom:localcallback(packetTypeName, params)
	if self.done == true then
		return
	end
	if packetTypeName == "message" then
		-- 消息处理
		local callback = self.dataCallback[params.title]
		if callback ~= nil then
			local tb = json.decode(params.body)
			callback(self, params.from, tb, params.id)
		end
	elseif packetTypeName == "event" then
		local tb = {}
		if params.body ~= nil and params.body ~= "" then
			-- 事件处理
			tb = json.decode(params.body)
			if not MapIsEmpty(tb) then
				for k,v in pairs(tb) do
					print(tostring(k) .. " = " .. tostring(v))
				end
			end
		end
		local callback = self.actionCallback[params.actionCode]
		if callback ~= nil then
			callback(self, params.type, tb)
		end
	end
end

-- 发送消息，这类会广播给房间类的所有成员
-- @title 一个区分标题
-- @tb 一个包好消息的表
function PVPRoom:sendMessage(title, tb, id)
	if self.client:isConnect() ~= true then
		return
	end

	local jsonString = ""
	if tb ~= nil then
		tb.title = title
		jsonString = json.encode(tb)

		print("sendMessage tb = " .. jsonString)
	else
		print("sendMessage tb = nil")
	end
	if id == nil then
		id = math.random(1, 10000000)
	end
	self.client:sendMessage(self.rid, '2', title, jsonString, id)
end

-- 发送一个事件给房间
-- @typ 类型 TYPE_SET, TYPE_GET
-- @code 一个动作编码
-- @tb 可以转成json的表
function PVPRoom:sendEvent(typ, code, tb, id)
	if self.client:isConnect() ~= true then
		return
	end

	local jsonString = ""
	if tb ~= nil then
		jsonString = json.encode(tb)
	end

	if id == nil then
		id = math.random(1, 10000000)
	end
	self.client:sendEvent(self.rid, '2', typ, 0, code, jsonString, id)
end

function PVPRoom:getRid() 
	return self.rid
end


function PVPRoom:gameover(result, state, localRoleUserId)
	state = state .. ""
	local tb = {
		winner = state,
		result = result,
		state = state,
		localRoleUserId = localRoleUserId
	}

	self:addChat({msg = "gameover"})
	self:sendEvent(TYPE_SET, ACTION_GAMEOVER_CODE, tb)
end

-- 如果对方没有进入游戏
function PVPRoom:abort()
	self.fight = nil
	if self.client:isConnect() then
		self.client:disconnect()
	end
end

-- 获取房间信息
function PVPRoom:getRoomInfo()
	self:sendEvent(TYPE_GET, INFO_CODE)
end

-- 开始游戏
function PVPRoom:startGame()
	self:sendEvent(TYPE_SET, START_CODE)
end

-- 停止游戏
function PVPRoom:stopGame()
	self:sendEvent(TYPE_SET, STOP_CODE)
end

-- 本地准备
function PVPRoom:ready()
	self:sendEvent(TYPE_SET, READY_CODE)
end

-- 本地取消准备
function PVPRoom:unready()
	self:sendEvent(TYPE_SET, UNREADY_CODE)
end

-- 本地退出
function PVPRoom:exit()
	self:sendEvent(TYPE_SET, EXIT_CODE)
end

-- 本地地图已经初始化好
function PVPRoom:initLayer()
	self:sendEvent(TYPE_SET, MAP_INIT_CODE)
end

-- 
function PVPRoom:setCallback(callback)
	self.callback = callback
end

function PVPRoom:release()
	self.client:disconnect()
end

return PVPRoom000000