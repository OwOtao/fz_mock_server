-- local luaTableEncode, luaTableDecode = require("app.views.tableToString")
local PVPClient = {}
PVPClient.timeout = 10
local ifclient = nil

local PING_EVENT_TYPE = 0X0010
local FZJH_EVENT_TYPE = 200

local TYPE_SET = 0
local TYPE_GET = 1
local TYPE_RESULT= 2
local TYPE_ERROR = 3

local CONNECT_STATE_NONE = 0
local CONNECT_STATE_OPEN = 2001
local CONNECT_STATE_SUSPEND = 2002
local CONNECT_STATE_CLOSE = 2003
local CONNECT_STATE_OPENING = 2004

local username = ""
local password = ""
local serverDomain = "120.24.215.82"
--local serverDomain = "192.168.1.136"
local serverPort = 9530
local resource = "1"

-- 区action code
local ZONE_ENTER_CODE = 1
local ZONE_EXIT_CODE = 2
local ZONE_INFO_CODE = 3
local ZONE_PLAYER_LIST_CODE = 4
local ZONE_PLAYER_INFO_CODE = 5

-- fzjh event handler action code 
local ZONE_LIST_CODE = 1001
local CREATE_ROOM_CODE = 1003
local PLAYER_INFO_CODE = 10001			  	-- 玩家信息
local PLAYER_VALUE_CODE = 10002				-- 玩家VALUE
local PLAYER_VALUES_CODE = 10003			-- 玩家VALUEs

local otherCallback = nil
local zoneCallback = nil
local roomCallback = nil
local currentState = CONNECT_STATE_CLOSE

local reconnectTimes = 0

local function onRoomCallback(...)
	if roomCallback ~= nil then
		roomCallback(...)
	end
end

local function onOtherCallback(...)
	if otherCallback ~= nil then
		otherCallback(...)
	end
end

local function onZoneCallback(...)
	if zoneCallback ~= nil then
		zoneCallback(...)
	end
end

function PVPClient:getLocalUsername()
	return username
end

function PVPClient:setRoomCallback(cbs)
	roomCallback = cbs
end

function PVPClient:sendMessage(...)
	ifclient:sendMessage(...)
end

function PVPClient:sendEvent(...)
	ifclient:sendEvent(...)
end

-- 以下所有返回不在这里处理，在消息callback
-- 创建房间，系统会自动创建者加到房间，创建成功后
-- 调用getRoomInfo来获得房间信息，或者不处理
function PVPClient:createRoom(roomname, cbs)
	local tb =
	{
		type = "set",
		action = CREATE,
		name = roomname
	}

	local jsonString = json.encode(tb)
	print("jsonString = " .. jsonString)
	if DEBUG_MODE == 1 then
		PopText(jsonString)
	end
	roomCallback = cbs

	ifclient:sendEvent(serverDomain, '0', TYPE_SET, FZJH_EVENT_TYPE, CREATE_ROOM_CODE, jsonString, math.random(100, 100000))
end

local ENTER_CODE = 4						-- 进入
-- 进入房间，进入房间后，调用getRoomInfo去获得房间信息
function PVPClient:enterRoom(roomId, cbs)
	local tb =
	{
		rid = roomId
	}

	local jsonString = json.encode(tb)
	print("jsonString = " .. jsonString)

	roomCallback = cbs
	ifclient:sendEvent(roomId, '2', TYPE_SET, 0, ENTER_CODE, jsonString, math.random(100, 100000))
end

function PVPClient:setOtherCallback(cbs)
	otherCallback = cbs
end

function PVPClient:setZoneCallback(cbs)
	zoneCallback = cbs
end

function PVPClient:setRoomCallback(cbs)
	roomCallback = cbs
end

function PVPClient:getZones()
 	print("getZones")
	if ifclient ~= nil then
		ifclient:sendEvent(serverDomain, '0', TYPE_GET, FZJH_EVENT_TYPE, ZONE_LIST_CODE, "", math.random(100, 100000))
	end	
end


function PVPClient:sendLocalRole(name, data)
	local tb =
	{
		type = "set",
		name = name,
		role = data
	}

	local jsonString = json.encode(tb)
	print("sendLocalRole" .. " jsonString = " .. jsonString)
	if ifclient ~= nil then
		ifclient:sendEvent(serverDomain, '0', TYPE_SET, FZJH_EVENT_TYPE, PLAYER_INFO_CODE, jsonString, math.random(100, 100000))
	end	
end

function PVPClient:enterZone(zid)
	local tb =
	{
	}

	local jsonString = json.encode(tb)
	print("enterZone" .. " jsonString = " .. jsonString)
	if ifclient ~= nil then
		ifclient:sendEvent(zid, '3', TYPE_SET, 0, ZONE_ENTER_CODE, jsonString, math.random(100, 100000))
	end		
end

function PVPClient:getZoneInfo(zid)
	if ifclient ~= nil then
		ifclient:sendEvent(zid, '3', TYPE_GET, 0, ZONE_INFO_CODE, "", math.random(100, 100000))
	end		
end

-- start : 起始位置
-- size : 大小
function PVPClient:getPlayers(zid, start, size)
	local tb =
	{
		start = start,
		size = size
	}
	local jsonString = json.encode(tb)
	print("getPlayers" .. " jsonString = " .. jsonString)
	if ifclient ~= nil then
		ifclient:sendEvent(zid, '3', TYPE_GET, 0, ZONE_PLAYER_LIST_CODE, jsonString, math.random(100, 100000))
	end		
end

local function onMessageRecvCallback(params)
	print("pvp onMessageRecvCallback params = "..tostring(params))
	
	params = luaTableDecode(params)
	for k,v in pairs(params) do
		print(tostring(k) .. " = " .. tostring(v))
	end

	-- 普通消息
	if (params.title == nil) then
		return
	end

	local tb = json.decode(params.body)
	if params.fromResource == "2" then
		onRoomCallback("message", params)
	else
		onOtherCallback("messageRecv", params, tb)
	end
end

local function onEventRecvCallback(params)
	print("pvp onEventRecvCallback params = "..tostring(params))
	
	params = luaTableDecode(params)
	for k,v in pairs(params) do
		print(tostring(k) .. " = " .. tostring(v))
	end

	-- 收到player事件
	if params.eventType == 100 then
	end

	-- 收到服务器事件
	if params.fromResource == "0" then
		if params.type == TYPE_RESULT then
			if params.actionCode == ZONE_LIST_CODE then
				-- 得到区列表
				local tb = json.decode(params.body)
				onOtherCallback("zoneList", "result", tb)
			elseif params.actionCode == PLAYER_INFO_CODE then
				-- 玩家信息
				print("上传玩家信息成功")
			elseif params.actionCode == CREATE_ROOM_CODE then
				local tb = json.decode(params.body)
				onRoomCallback("event", params)
				print("创建房间成功")
			end
		elseif params.type == TYPE_SET then
		elseif params.type == TYPE_ERROR then
			if params.actionCode == ZONE_LIST_CODE then
				-- 得到区列表
				local tb = json.decode(params.body)
				onOtherCallback("zoneList", "error")
			elseif params.actionCode == PLAYER_INFO_CODE then
				-- 退出区
				print("上传玩家信息失败")
			elseif params.actionCode == CREATE_ROOM_CODE then
				print("创建房间失败")
			end
		end
	end

	-- 区
	if params.fromResource == "3" then
		if params.type == TYPE_RESULT then
			if params.actionCode == ZONE_ENTER_CODE then
				-- 加入区
				onOtherCallback("enterZone", "result", params.fromUid)
			elseif params.actionCode == ZONE_EXIT_CODE then
				-- 退出区
				onOtherCallback("exitZone", "result", params.fromUid)
			elseif params.actionCode == ZONE_INFO_CODE then
				-- 区信息
				local tb = json.decode(params.body)
				onOtherCallback("zoneInfo", "result", tb)
			elseif params.actionCode == ZONE_PLAYER_LIST_CODE then
				-- 区成员列表，简单信息
				local tb = json.decode(params.body)
				onOtherCallback("zonePlayerList", "result", tb)
			elseif params.actionCode == ZONE_PLAYER_INFO_CODE then
				-- 玩家细信息
				local tb = json.decode(params.body)
				onOtherCallback("zonePlayerInfo", "result", tb)
			end
		elseif params.type == TYPE_SET then
		elseif params.type == TYPE_ERROR then
			if params.actionCode == ZONE_ENTER_CODE then
				-- 加入区
				onOtherCallback("enterZone", "error", params.fromUid)
			elseif params.actionCode == ZONE_EXIT_CODE then
				-- 退出区
				onOtherCallback("exitZone", "error", params.fromUid)
			end
		end
	end

	-- 收到的消息是房间事件
	if params.fromResource == "2" then
		if params.type==TYPE_SET and params.actionCode==1007 then 
			-- self:disconnect()
			onOtherCallback("disconnect", {reason = "作弊"})
			local tb = json.decode(params.body)
			PopText(tb.reason)
		else
			onRoomCallback("event", params)
		end
	end -- params.title == "room"
	-- 调用监听方法
end

local function onConnectSuccessCallback(params)
	print("pvp onConnectSuccessCallback")
	currentState = CONNECT_STATE_OPEN
	if luaTableEncode == nil then 
		print("luaTableEncode = nil")
	else
		print("luaTableEncode = " .. type(luaTableEncode))
	end
	-- 连接成功
	params = luaTableDecode(params)

	for k,v in pairs(params) do
		print(tostring(k) .. " = " .. tostring(v))
	end
	if DEBUG_MODE == 1 then
		PopText(params.uid .. "连接成功")
	end
	onOtherCallback("connectSuccess", params)
	-- PVPClient:createRoom("room1")
end

local function onConnectErrorCallback(params)
	print("pvp onConnectErrorCallback")
	currentState = CONNECT_STATE_CLOSE
	-- 连接出错
	params = luaTableDecode(params)
	print("lua回调funcName = "..params.funcName)

	for k,v in pairs(params) do
		print(tostring(k) .. " = " .. tostring(v))
	end

	if DEBUG_MODE == 1 then
		PopText("连接出错" .. params.reason)
	end
	onOtherCallback("connectError", params)
end

local function onDisconnectCallback(params)
	print("pvp onDisconnectCallback")
	currentState = CONNECT_STATE_CLOSE
	-- 断开连接
	params = luaTableDecode(params)

	print("lua回调funcName = "..params.funcName)

	for k,v in pairs(params) do
		print(tostring(k) .. " = " .. tostring(v))
	end

	if DEBUG_MODE == 1 then
		PopText("断开连接")
	end
	onOtherCallback("disconnect", params)
end

function PVPClient:disconnect()
	if ifclient ~= nil then
		ifclient:disconnect(false)
	end
end

function PVPClient:isConnect()
	if ifclient ~= nil then
		if currentState == CONNECT_STATE_OPEN then
			return true
		else
			return false
		end
	end

	return false
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得随机的角色数据
local function getRoleData(dataId)
	local role = User:getRole()
	
	--@desc 刷新角色主动技能
	role:updateActiveZhaoStatus()

    local cloneRole = {}

    cloneRole.id = dataId .. ""
    cloneRole.userid = dataId
	---------------------
	cloneRole.name = role.name
	--神兵列表，记录自己所有的神兵
	-- cloneRole.shenBingweapon = role.shenBingweapon

	--cloneRole.shuxiang = role.shuxiang
	cloneRole.sex = role.sex
	cloneRole.age = role.age
	cloneRole.looks = role.looks
	cloneRole.luck = role.luck
	cloneRole.tili = role.tili
	cloneRole.tiliMax = role.tiliMax
	cloneRole.str = role.str
	cloneRole.int = role.int
	cloneRole.con = role.con
	cloneRole.dex = role.dex

	cloneRole.secStr = role.secStr
	cloneRole.secInt = role.secInt
	cloneRole.secCon = role.secCon
	cloneRole.secDex = role.secDex
	cloneRole.currStr = role.currStr
	cloneRole.currInt = role.currInt
	cloneRole.currCon = role.currCon
	cloneRole.currDex = role.currDex
	cloneRole.fenpei = role.fenpei
	cloneRole.fenpeiList = role.fenpeiList

	cloneRole.jing = role.jing
	-- cloneRole.jingMax = role.jingMax
	cloneRole.qi = role.qi
	cloneRole.qiMax =  role.qiMax
	cloneRole.neili = role.neili
	cloneRole.neiliMax = role.neiliMax
	cloneRole.exp = role.exp
	cloneRole.pot = role.pot
	cloneRole.money = role.money
	cloneRole.gold = role.gold
	cloneRole.lv = role.lv
	cloneRole.yuanbao = role.yuanbao
	cloneRole.totalYuanBao = role.totalYuanBao
	cloneRole.weight = role.weight

	cloneRole.ckLimit = role.ckLimit
	cloneRole.zhengqi = role.zhengqi	
	cloneRole.kill = role.kill
	cloneRole.yueli = role.yueli
	cloneRole.killPlayer = role.killPlayer
	cloneRole.weiwang = role.weiwang
	cloneRole.dead = role.dead
	cloneRole.meili = role.meili
	cloneRole.deadReason = role.deadReason
	cloneRole.jindu = role.jindu
	cloneRole.lunhui = role.lunhui
	cloneRole.mengjing = role.mengjing
	cloneRole.panshi = role.panshi
	cloneRole.guanqiaLimit = role.guanqiaLimit
	cloneRole.species = role.species
	cloneRole.dsc = role.dsc

	cloneRole.gongji =math.floor(role:getAtk())
	cloneRole.dodge = math.floor(role:getDodge())
	cloneRole.def = math.floor(role:getDef())
	cloneRole.powerdamage = math.floor(role:getPowerDamage())
	cloneRole.fanghu =math.floor(role:getFangHu()) 
	cloneRole.jingMax =math.floor(role:getJingMax()) 
	cloneRole.currQiMax =math.floor(role:getCurrQiMax()) 

    cloneRole.inheritCount=role.inheritCount
	
	cloneRole.atkRate = role.atkRate
	cloneRole.kongfu = role.kongfu
	cloneRole.title_type = role.title_type
	cloneRole.title_id = role.title_id
	cloneRole.basicTitleData = role.basicTitleData
	cloneRole.inherit = role.inherit
	cloneRole.jiaLi = role.jiaLi

	cloneRole.tempAttrList = role.tempAttrList  -------

	cloneRole.family = role.family
	cloneRole.teacherName = role.teacherName

	cloneRole.teacherId = role.teacherId
	cloneRole.skills = role.skills  -- 角色的所有技能
	cloneRole.skillPrepare = role.skillPrepare -- 角色当前准备的技能列表
	cloneRole.activeZhaos = role.activeZhaos -- 角色学会的所有主动招式
	cloneRole.preparedActiveZhao = role.preparedActiveZhao -- 角色准备的主动招式（有兵器和拳脚之分）
	cloneRole.preparedZhaos =  {
				"chuixiongkou10",
                "tiandirenmo10",
                "xiyanling10",
                "zixiahuti10",
                "yuntaiji10",
                "qianhunluoyi10",
	}
	cloneRole.preparedZhaos = role.preparedZhaos -- 暂时没用到
	--cloneRole.items = role.items
	cloneRole.equips = role.equips
	cloneRole.portrait = role.portrait

	cloneRole.prepareWeapon=role.prepareWeapon

	cloneRole.isInYiWu=false

	cloneRole.meridian = role.meridian

	-- 经脉经验
	cloneRole.meridianExp = role.meridianExp

	-- 真气值
	cloneRole.breathVal = role.breathVal

	-- 经脉印记
	cloneRole.m_meridianImprintings = role.m_meridianImprintings
	cloneRole.m_meridianImprintings.__convertBeforeTemp = nil

	-- 隐脉数据
	cloneRole.hiddenMeridianData = role.hiddenMeridianData

	-- 左右互搏熟练度
	cloneRole.leftRightFightExp = role.leftRightFightExp

	cloneRole.borderVer = role.borderVer

	cloneRole.borderShowList = clone(role.borderShowList)

	local shenbings = role:getItems(function (item)
		return item.type == "神兵"
	end)
	
	cloneRole.items = {}
	
	cloneRole.shenBingItems = {}  -- add by XiaoZhiWei 2017/07/03 21:19:26	神兵信息
	for __, shenbing in ipairs(shenbings) do
		for i,v in ipairs(role.shenBingItems) do
			if v.id == shenbing.itemId then
				table.insert(cloneRole.shenBingItems, v)
			end
		end
		table.insert(cloneRole.items,shenbing)
	end

	for k, v in pairs(role.equips) do
		local item = role:getItemWithOnlyId(v.id)
		table.insert(cloneRole.items, item)
	end
	-- 易容术数据
	cloneRole.polymorph = role.polymorph
	-- cloneRole._yirongSelectList = role._yirongSelectList

	cloneRole.poison = role.poison

	cloneRole.xingzhen = role.xingzhen
	cloneRole.AsleepBuff = role.AsleepBuff --入梦buff
	cloneRole._roleBuff = role._roleBuff

	cloneRole.officialType = role.officialType --官职类型
	cloneRole.officialAchievement = role.officialAchievement --政绩
	cloneRole.titles = role.titles --额外称号
    cloneRole.yueKaValid = role.yueKaValid --是否拥有月卡
	cloneRole.appearance = role.appearance

	-- 自创武学系统
	cloneRole.selfCreatedSkillData = role.selfCreatedSkillData

	--@desc 武学突破数据
	cloneRole.skillBreakData = role.skillBreakData

	--@desc 招式突破数据
	cloneRole.zhaoBreakData = role.zhaoBreakData

	-- 新的主动技能准备表
	if role._activeZhaoPrepareMap then
		cloneRole._activeZhaoPrepareMap = role._activeZhaoPrepareMap
	end

	local fistFootSystem = role:getFistFootSystem()
	local fistFootSystemPVPInfo = fistFootSystem:serializationForPVP()
	cloneRole.fistFootSystemPVPInfo = fistFootSystemPVPInfo

	local teacherBuildSystem = role:getTeacherBuildSystem()
	local teacherBuildSystemPVPInfo = teacherBuildSystem:serializationForPVP()
	cloneRole.teacherBuildSystemPVPInfo = teacherBuildSystemPVPInfo

	cloneRole.hitRate = role:getHitRate()
	cloneRole.parry = role:getParry()
	--调试招架加成
	cloneRole.debugParryRateBuff = 0
	if TEST_COMMAD_VALUE == 5 then
		cloneRole.debugParryRateBuff = 888
	end

	cloneRole._timeLimitFlags = {}
	local timeLimitFlags = role._timeLimitFlags
	local fightTimeLimitFlag = {
		"经脉印记防御力提升",
		"经脉印记攻击力提升",
	}

	for __, flag in ipairs(fightTimeLimitFlag) do
		if role:getTimeLimitFlag(flag) ~= 0 then
			cloneRole._timeLimitFlags[flag] = timeLimitFlags[flag]
		end
	end

	return cloneRole
end

function PVPClient:connect(domain, port, targetName, key, randomSeed, timeout)
	if currentState == CONNECT_STATE_OPENING then
		return
	end
	self.timeout = timeout
	local uid = User:getUserId() .. ""
	username = uid

	local roleData = getRoleData(uid)
    local tb = {
    	userid = uid,
		uuid = Game:getIdfv(),
		platform  = Game:getPlatformId(),
		channel = Game:getChannelId()
	}
	local authJson = json.encode(tb)
	-- local data = JMForLua:encrypt(authJson)

	local extra 
	if key == nil then
		extra = {
    		auth = authJson
    	}
	else
		local roomName = roleData.name .. "vs" .. targetName
		extra = {
			user = roleData,
	    	name = roomName,
	    	key = key,
	    	seed = randomSeed,
	    	auth = authJson
		}
	end
	

	local extraJson = json.encode(extra)

	if ifclient ~= nil then
		currentState = ifclient:getState()
	end
	serverDomain = domain
	serverPort = port
	print("currentState = " .. currentState)
	if (currentState == CONNECT_STATE_CLOSE) then
		ifclient = wyf.Ifclient:create(serverDomain, serverPort, username, extraJson, 17, 100000)
		ifclient:setCallback(onMessageRecvCallback, onEventRecvCallback, onConnectSuccessCallback
			, onConnectErrorCallback, onDisconnectCallback)
		-- 初始化构造连接
		-- 只能调用一次
		ifclient:connect(self.timeout)
		currentState = CONNECT_STATE_OPENING
	elseif (currentState == CONNECT_STATE_OPEN) then
		-- 当前状态是打开的，不用管，直接返回
		return
	elseif (currentState == CONNECT_STATE_SUSPEND) then
		-- 当前状态是挂起的，恢复连接
	end
end

function PVPClient:reconnect()
	if currentState == CONNECT_STATE_OPENING then
		return
	end

	if (currentState == CONNECT_STATE_CLOSE) then
		-- 初始化构造连接
		-- 只能调用一次
		ifclient:connect(self.timeout)
		currentState = CONNECT_STATE_OPENING
	elseif (currentState == CONNECT_STATE_OPEN) then
		-- 当前状态是打开的，不用管，直接返回
		return
	elseif (currentState == CONNECT_STATE_SUSPEND) then
		-- 当前状态是挂起的，恢复连接
	end
end

return PVPClient
0000