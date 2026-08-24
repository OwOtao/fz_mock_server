-- local luaTableEncode, luaTableDecode = require("app.views.tableToString")
local FubenClient = {}
local ifclient = nil

-- 副本事件
local FUBEN_EVENT_TYPE = 300
local PING_EVENT_TYPE = 0X0010

local TYPE_SET = 0
local TYPE_GET = 1
local TYPE_RESULT= 2
local TYPE_ERROR = 3

local CONNECT_STATE_NONE = 0
local CONNECT_STATE_OPEN = 2001
local CONNECT_STATE_SUSPEND = 2002
local CONNECT_STATE_CLOSE = 2003
local CONNECT_STATE_OPENING = 2004

local ROLE_ACTION_COMEIN = 0 -- add by XiaoZhiWei 2017/05/25 10:16:31 进入房间
local ROLE_ACTION_LEAVE = 1 -- add by XiaoZhiWei 2017/05/25 10:17:13 离开副本
local ROLE_ACTION_QIECUO = 2 -- add by XiaoZhiWei 2017/05/25 10:17:38 副本切磋
local ROLE_ACTION_JUEDOU = 3 -- add by XiaoZhiWei 2017/05/25 10:17:52 副本决斗
local ROLE_ACTION_XIAOXI = 4 -- add by XiaoZhiWei 2017/05/25 10:18:31 副本消息
local ROLE_ACTION_CHAKAN = 5 -- add by XiaoZhiWei 2017/05/25 10:57:28 查看信息
local ROLE_ACTION_KEY_VALUE = 6 -- 玩家设置数据

-- 例如：打招呼，可以自定义到body里面，客户端进行处理
local ROLE_ACTION_PEER_TO_PEER = 7 -- 点对点的发送，服务端不会做任何处理

local ROLE_ACTION_ROOM_LIST = 8  -- 进入房间不会返回所有玩家的，这能通过这个动作来获取房间内所有的
local DENGLONG_ACTION_MINUS_1 = 101 -- 灯笼次数剑一
local DENGLONG_CHAKAN = 102 -- 查看灯笼

local DENGLONG_CLEAR = 103  --	清除灯笼
local DENGLONG_REFRESH = 104 --刷新灯笼
local GAME_ACTION_ABORT = 1000  -- 游戏终止，一般战斗没有连接成功，通知对方

local SERVER_ACTION_JUEDOU1 = 2000 -- add by XiaoZhiWei 2017/05/26 11:38:29 服务器下发决斗消息
local SERVER_ACTION_CHECK_IDLE = 2001 -- add by XiaoZhiWei 2017/05/26 11:38:29 服务器检测客户端是否是idle状态
local SERVER_ACTION_QIECUO1 = 2002  -- 服务器下发的切磋
local SERVER_ACTION_MESSAGE =  2003  -- 服务器发来的消息

local username = ""
local password = ""
local zoneid = ""
local serverDomain = "119.23.215.99"
-- local serverDomain = "192.168.1.136"
if DEBUG_MODE == 2 and Game:isTesting() == false then
	serverDomain = "120.76.20.14"
end

--local serverDomain = "192.168.1.136"
local resource = "1"
local currentState = CONNECT_STATE_CLOSE

local keepReconnect = false
local delayReconnect = 0

local __callBack = nil -- add by XiaoZhiWei 2017/05/25 10:04:44 回调函数

function FubenClient:send(...)
	if ifclient then
		ifclient:sendEvent(...)
	end
end

function FubenClient:sendResult(params)
	self:send(params.fromUid, params.fromResource, TYPE_RESULT, params.eventType, params.actionCode, "", params.id)
end

local auth = 
{
	uuid = Game:getIdfv(),
	platform  = Game:getPlatformId(),
	channel = Game:getChannelId()
}

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:24:48
-- @desc  进入副本
function FubenClient:comeIn(mapId, roomId, roomName, onlyId)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		mapId = mapId,
		roomId = roomId,
		roomName = roomName
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_COMEIN, jsonStr, onlyId)
end

-- mapId 地图ID
-- roomId 房间ID
-- 得到所有房间内的玩家，返回结果同加入房间成功一样
function FubenClient:getAllRoomPlayers(mapId, roomId)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		mapId = mapId,
		roomId = roomId
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_GET, FUBEN_EVENT_TYPE, ROLE_ACTION_ROOM_LIST, jsonStr, Helper:getOnlyId())
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:24:48
-- @desc  离开副本
function FubenClient:leave(mapId, roomId)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		mapId = mapId,
		roomId = roomId
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_LEAVE, jsonStr, Helper:getOnlyId())
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:24:48
-- @desc  副本切磋
local unCheckList = {
	fb205_26 = true,
	fb205_09 = true,
	fb02_11 = true,
	fb10_11 = true,
	fb214_06 = true, 
	fb214_11 = true,

	fb217_07 = true,
	fb217_06 = true,
	fb217_12 = true,
	fb217_05 = true,
	fb217_10 = true,
	fb217_15 = true,
	fb217_16 = true,
	fb217_17 = true,
	fb217_11 = true,
}
function FubenClient:qieCuo(userid)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	-- add by XiaoZhiWei 2017/06/22 17:42:45 限制切磋频率
	self.__Last_Qie_Cuo_Time = math.min(Helper:getDef(self.__Last_Qie_Cuo_Time, 0), GetTime()) -- add by XiaoZhiWei 2017/06/22 17:43:40 math.min 考虑记录的时间比当前时间大的情况

	if unCheckList[User:getRole():getCurrMap():getCurrRoomId()] ~= true and User:getRole():getCurrMapId() ~= "fb217" and self.__Last_Qie_Cuo_Time ~= GetTime() and GetTime() - self.__Last_Qie_Cuo_Time < 60 then
		PopText("不要如此好斗，歇会再说吧！")
		return
	end

	local function sendQieCuo()
		local tb = {
			userid = userid,
		}
		local jsonStr = jsonpvp.encode(tb)
		self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_QIECUO, jsonStr, Helper:getOnlyId())
		self.__Last_Qie_Cuo_Time = GetTime()
	end
	
	local roleDatas = {
		selfCreatedSkillData = User:getRole():getAttr("selfCreatedSkillData"), --自创武学数据
		roleAttrData = {
			looks = User:getRole():getAttr("looks"),
			jingMax = User:getRole():getJingMax(),
			neiLiLimit = User:getRole():getNeiLiLimit(),
			qiMax = User:getRole():getCurrQiMax(),
			atk = User:getRole():getAtk(),
			dodge = User:getRole():getDodge(),
			def = User:getRole():getDef(),
			damage = User:getRole():getPowerDamage(),
			protect = User:getRole():getFangHu(),
			str = User:getRole():getAttr("str"),
			dex = User:getRole():getAttr("dex"),
			int = User:getRole():getAttr("int"),
			con = User:getRole():getAttr("con"),
			currStr = User:getRole():getEffectStr(),
			currDex = User:getRole():getEffectDex(),
			currInt = User:getRole():getFinalAttr("currInt"),
			currCon = User:getRole():getEffectCon(),
			inheritCount = User:getRole():getNumAttr("inheritCount"),
			age = User:getRole():getAttr("age")
		}
	}

	if PRINT_MODE == 1 then
		print("人物属性详情")
		Helper:print_lua_table(roleDatas.roleAttrData)
	end

	--@desc 校验发起切磋者数据是否作弊
	HttpManagerEx:pvpRoleDataVerify(roleDatas,function(status, errcode, errmsg, data, isEncrypted)
		if status == 200 then
			if errcode == 0 then
				sendQieCuo()
			elseif errcode == 2 then
				PopText("请公平公正的参与游戏")
				if PRINT_MODE == 1 then
					print("作弊属性详情")
					Helper:print_lua_table(data)
				end
			else
				PopText(errmsg)																												
			end
		else
			PopText(errmsg)
		end
	end, IS_SHOW_WAITING)
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:24:48
-- @desc  副本决斗
function FubenClient:jueDou(userid)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		userid = userid,
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_JUEDOU, jsonStr, Helper:getOnlyId())
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:24:48
-- @desc  副本消息
function FubenClient:xiaoxi(mapId, roomId, text)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		mapId = mapId,
		roomId = roomId,
		text = text
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_XIAOXI, jsonStr, Helper:getOnlyId())
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:24:48
-- @desc  副本查看
function FubenClient:chakan(userid)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	self:send(userid, '1', TYPE_GET, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, "", Helper:getOnlyId())
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/26 11:48:02
-- @desc 接受切磋/决斗
function FubenClient:accept(targetUserid, action, time, key, onlyId)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		userid = targetUserid,
		time = time,
		result = "YES",
		key = key
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_RESULT, FUBEN_EVENT_TYPE, action, jsonStr, onlyId)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/26 11:50:18
-- @desc 拒绝切磋/决斗
function FubenClient:reject(targetUserid, action, time, key, reason, onlyId)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		userid = targetUserid,
		time = time,
		result = "NO",
		key = key,
		reason = reason
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_RESULT, FUBEN_EVENT_TYPE, action, jsonStr, onlyId)
end

-- 通知对方，终止当前的战斗
function FubenClient:abortFight(sponsorId, targetId, key)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		key = key,
		sponsorId = sponsorId,
		targetId = targetId
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, GAME_ACTION_ABORT, jsonStr, Helper:getOnlyId())		
end

-- targetId: 对方id
-- body: table,内容
-- 自定义的点对点发送，客户端自由处理
function FubenClient:sendPeerToPeer(targetid, body)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end
	local json = jsonpvp.encode(body)
	print("json = " .. json)
	self:send(targetId, '1', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_PEER_TO_PEER, json, Helper:getOnlyId())
end

function FubenClient:setValue(key, value)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	local tb = {
		key = key,
		value = value
	}
	local jsonStr = jsonpvp.encode(tb)
	self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, ROLE_ACTION_KEY_VALUE, jsonStr, Helper:getOnlyId())			
end


-- 查看灯笼信息
function FubenClient:chakanDenglong(userid)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end

	self:send(zoneid, 'z', TYPE_GET, FUBEN_EVENT_TYPE, DENGLONG_CHAKAN, userid, Helper:getOnlyId())
end

-- 灯笼次数剑一
function FubenClient:minusDenglong(userId,roomUserid,val)
	if currentState ~= CONNECT_STATE_OPEN then
		return
	end
	local tb = {
		userid = userId,
		roomUserid = roomUserid,
		value = val    -- 1  答对， 0 答错
	}

	self:send(zoneid, 'z', TYPE_SET, FUBEN_EVENT_TYPE, DENGLONG_ACTION_MINUS_1, json.encode(tb), Helper:getOnlyId())
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:05:49
-- @desc 回调状态
local function callBackStatus(eventName, params)
	if __callBack then
        Game:addBlockAsyncFunc("callBackStatus", function()
            __callBack(eventName, params)
        end)
	end
end

local function onMessageRecvCallback(params)
	-- print("onMessageRecvCallback params = "..tostring(params))
	
	params = luaTableDecode(params)
	-- for k,v in pairs(params) do
	-- 	print(tostring(k) .. " = " .. tostring(v))
	-- end
	callBackStatus("消息", params)
end

local function onEventRecvCallback(params)
	-- print("onEventRecvCallback params = "..tostring(params))
	
	params = luaTableDecode(params)
	-- for k,v in pairs(params) do
	-- 	print(tostring(k) .. " = " .. tostring(v))
	-- end

	if params.eventType == 0x0010 and params.type == TYPE_SET then
		FubenClient:sendResult(params)
		return
	end

	if params.actionCode == nil then
	elseif params.actionCode == ROLE_ACTION_COMEIN then  -- 进入房间
		if params.type == TYPE_RESULT then
			callBackStatus("加入房间成功", params)
		elseif params.type == TYPE_SET then
			callBackStatus("玩家加入房间", params)
		else
			callBackStatus("加入房间失败", params)
		end
	elseif params.actionCode == ROLE_ACTION_LEAVE then  -- 离开房间
		if params.type == TYPE_RESULT then
			--callBackStatus("离开房间成功", params)
		elseif params.type == TYPE_SET then
			callBackStatus("玩家离开房间", params)
		else
			callBackStatus("离开房间失败", params)
		end
	elseif params.actionCode == ROLE_ACTION_QIECUO then  -- 切磋
		if params.type == TYPE_RESULT then
			-- params.body带有一个 timeout:15000  告诉客户端这个切磋请求多久超时，单位ms，表示15秒
			callBackStatus("成功发送切磋请求", params)
		elseif params.type == TYPE_SET then
			-- params.body中会带上请求者的基本信息
			-- TODO 头像id，最强的3中武学，门派，第几代弟子，同登陆的时候
			callBackStatus("对方请求切磋", params)
		else
			callBackStatus("切磋请求失败", params)
			-- 如果对方不在线
			-- 如果对方正在忙碌
		end
	elseif params.actionCode == ROLE_ACTION_JUEDOU then  -- 决斗
		if params.type == TYPE_RESULT then
			-- params.body带有一个 timeout:15000  告诉客户端这个切磋请求多久超时，单位ms，表示15秒
			callBackStatus("成功发送决斗请求", params)
		elseif params.type == TYPE_SET then
			callBackStatus("对方请求决斗", params)
		else
			callBackStatus("决斗请求失败", params)
		end
	elseif params.actionCode == ROLE_ACTION_XIAOXI then
	elseif params.actionCode == DENGLONG_CHAKAN then
		if params.type == TYPE_RESULT then
			callBackStatus("成功查看", params)
		else
			callBackStatus("查看失败", params)
		end
	elseif params.actionCode == DENGLONG_CLEAR then
		print("-----------------清除灯笼------------------")
		if params.type == TYPE_SET then
			callBackStatus("清除灯笼", params)
			-- tb = params.body
			-- tb.mapid
			-- tb.roomid
		end
	elseif params.actionCode == DENGLONG_REFRESH then
		print("-----------------刷新灯笼------------------")
		if params.type == TYPE_SET then
			callBackStatus("刷新灯笼", params)
		end	
	elseif params.actionCode == DENGLONG_ACTION_MINUS_1 then
		if params.type == TYPE_SET then
			callBackStatus("灯笼次数减一", params)
		end		
	elseif params.actionCode == ROLE_ACTION_CHAKAN then
		if params.type == TYPE_RESULT then
			callBackStatus("成功查看", params)
		elseif params.type == TYPE_GET then
			--@RefType [src.app.models.role.Role#Role]
			local player = User:getRole()
			local chakanTbl = {
				--desc = player:getDsc(player:getCurrMap():getRole(params.fromUid)),
				prayRoomId = player:getAttr("prayRoomId"),
				userid = tostring(User:getUserId()),
				family = player:getAttr("family"),
				exp = player:getAttr("exp"),      -- 经验
				pot = player:getAttr("pot"),      -- 潜能
				money = player:getAttr("money"),    -- 碎银
				gold = player:getAttr("gold"),    -- 金币
				age = player:getAttr("age"),
				lv = player:getAttr("lv"),       -- 等级
				luck = player:getAttr("luck"),  -- 福缘
				inheritCount = player:getNumAttr("inheritCount"), --传承次数
				-- jindu = player:getAttr("jindu"), -- 江湖进度
				looks = player:getAttr("looks"), -- 容貌
				--先天属性
				str = player:getAttr("str"),   -- 臂力
				int = player:getAttr("int"),   -- 悟性
				con = player:getAttr("con"),   -- 根骨
				dex = player:getAttr("dex"),   -- 身法
				--后天属性
				secStr = player:getAttr("secStr"),	-- 臂力
				secInt = player:getAttr("secInt"),	-- 悟性
				secCon = player:getAttr("secCon"),	-- 根骨
				secDex = player:getAttr("secDex"),	-- 身法
				--等效属性
				currStr = player:getEffectStr(),	-- 臂力
				currInt = player:getFinalAttr("currInt"),	-- 悟性
				currCon = player:getEffectCon(),	-- 根骨
				currDex = player:getEffectDex(),	-- 身法
				jing = player:getAttr("jing"),  -- 精力
				jingMax = player:getJingMax(), -- 最大精力
				qi = player:getAttr("qi"), -- 气血
				qiMax = player:getCurrQiMax(),   -- 最大气血
				neiLiLimit = player:getNeiLiLimit(), --内力上限
				atk = player:getAtk(), -- 攻击力
				damage = player:getPowerDamage(), -- 伤害力
				fanghu = player:getFangHu(), -- 防护力
				def = player:getDef(),	-- 防御力
				dodge = player:getDodge(), -- 躲闪力
				equips = player:getAttr("equips"),
				portrait  = player:getAttr("portrait"),
				polymorph = player:getAttr("polymorph"), --易容术

				skillPrepare = player:getAttr("skillPrepare"), --准备技能
				skills = player:getPrepareSkills(), --技能
				zhengqi = player:getAttr("zhengqi"), --正气
				officialType = player:getAttr("officialType"), --官职类型
				officialAchievement = player:getAttr("officialAchievement"), -- 政绩
				yueKaValid = player:getAttr("yueKaValid"), --是否拥有月卡
				inheritRoleDsc = player:getInheritRoleWebDsc(), --传承者相关信息

				title_id = player:getAttr("title_id"),

				basicTitleData = player:getBasicTitleData(),

				borderVer = player:getAttr("borderVer"),
				
				borderShowList = player:getAttr("borderShowList"),

				channel = Game:getChannelId(),
				createTime = player:getAttr("createTime") -- 创建时间
			}
			local chakanStr = jsonpvp.encode(chakanTbl)
			FubenClient:send(params.fromUid, params.fromResource, TYPE_RESULT, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, chakanStr, params.id)
		else
			callBackStatus("查看失败", params)

		end
	elseif params.actionCode == ROLE_ACTION_PEER_TO_PEER then
		if params.type == TYPE_SET then
			-- 收到一个点对点的SET请求
			-- 告诉对方已经收到
			FubenClient:sendResult(params)
			callBackStatus("收到点对点的SET请求", params)
		elseif params.type == TYPE_GET then
			-- 收到一个点对点的GET请求
			-- 告诉对方已经收到
			FubenClient:sendResult(params)
			callBackStatus("收到点对点的GET请求", params)
		elseif params.type == TYPE_RESULT then

			callBackStatus("点对点请求成功", params)
		else
			callBackStatus("点对点请求失败", params)
		end
	elseif params.actionCode == ROLE_ACTION_ROOM_LIST then
		if params.type == TYPE_RESULT then
			-- body同加入房间
			callBackStatus("获取房间玩家成功", params)
		end
	elseif params.actionCode == GAME_ACTION_ABORT then
		-- 对方通知我要终止战斗
		if params.type == TYPE_SET then
			local tb = jsonpvp.encode(params.body)
			if FubenClient.pvp ~= nil and FubenClient.pvp:getRid() == tb.key then
				FubenClient.pvp:abort()
				FubenClient:setValue("isFighting", false)

				-- TODO  回掉事件
				local eventName = "战斗异常"

				FubenClient.pvp = nil
			end
		end
	elseif params.actionCode == ROLE_ACTION_KEY_VALUE then
		if params.type == TYPE_SET then
			-- 收到用户的key value
			callBackStatus("值变化", params)
		end
	elseif params.actionCode == SERVER_ACTION_QIECUO1 then
		if params.type == TYPE_RESULT then
		elseif params.type == TYPE_SET then
			-- params.body带有文本
			-- sponsorId:xxx  发起方ID
			-- targetId:xxx  被发起方ID
			-- sponsorName:xxx  发起方的名字
			-- targetName:xxx  被发起方的名字
			-- key:xxx  战斗的ID  
			-- result:xxx YES OR NO
			-- startText:xxx  开始的文本
			-- startCountdown: n 开始的倒计时
			-- reason:xxx NO才带有这个字段   
			callBackStatus("切磋请求结果", params)
			-- FubenClient:send(params.fromUid, params.fromResource, TYPE_RESULT, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, User:getRole():getDsc(), params.id)
		else
			-- callBackStatus("查看失败", params)
		end

	elseif params.actionCode == SERVER_ACTION_JUEDOU1 then
		if params.type == TYPE_RESULT then
		elseif params.type == TYPE_SET then
			callBackStatus("决斗请求结果", params)
			-- FubenClient:send(params.fromUid, params.fromResource, TYPE_RESULT, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, User:getRole():getDsc(), params.id)
		else
			-- callBackStatus("查看失败", params)
		end
	elseif params.actionCode == SERVER_ACTION_CHECK_IDLE then
		if params.type == TYPE_GET then
			callBackStatus("是否空闲状态", params)
			-- FubenClient:send(params.fromUid, params.fromResource, TYPE_RESULT, FUBEN_EVENT_TYPE, ROLE_ACTION_CHAKAN, User:getRole():getDsc(), params.id)
		else
			-- callBackStatus("查看失败", params)
		end
	elseif params.actionCode == SERVER_ACTION_MESSAGE then
		if params.type == TYPE_SET then
			-- 服务器通知
			callBackStatus("被祝福",params)
			-- local tbl = json.decode(params.body)
		end
	end 

end

local function onConnectSuccessCallback(params)
	-- print("onConnectSuccessCallback")
	currentState = CONNECT_STATE_OPEN
	-- if luaTableEncode == nil then 
	-- 	print("luaTableEncode = nil")
	-- else
	-- 	print("luaTableEncode = " .. type(luaTableEncode))
	-- end
	-- 连接成功
	params = luaTableDecode(params)

	-- for k,v in pairs(params) do
	-- 	print(tostring(k) .. " = " .. tostring(v))
	-- end
	-- PopText(params.uid .. "连接成功")

	delayReconnect = 0

	callBackStatus("连接成功", params)
end

local function onConnectErrorCallback(params)
	-- print("onConnectErrorCallback")
	currentState = CONNECT_STATE_CLOSE
	-- 连接出错
	params = luaTableDecode(params)
	-- print("lua回调funcName = "..params.funcName)

	-- for k,v in pairs(params) do
	-- 	print(tostring(k) .. " = " .. tostring(v))
	-- end

	-- PopText("连接出错" .. params.reason)

	callBackStatus("连接出错", params)

	-- 异常断开重连，一般在界面呗遮挡，失去活动焦点后，gl线程被挂起，导致服务器的ping得不到回到
	if keepReconnect == true then
		cc.Director:getInstance():getRunningScene():uniqueDelayFunc("onConnectErrorCallback", delayReconnect, 
			function()
				if ifclient ~= nil then
					FubenClient:reconnect()
				end
			end) 		
	end
	delayReconnect = delayReconnect + 1
	if delayReconnect >= 5 then
		delayReconnect = 5
	end
end

local function onDisconnectCallback(params)
	-- print("onDisconnectCallback")
	currentState = CONNECT_STATE_CLOSE
	-- 断开连接
	params = luaTableDecode(params)

	-- print("lua回调funcName = "..params.funcName)

	-- for k,v in pairs(params) do
	-- 	print(tostring(k) .. " = " .. tostring(v))
	-- end

	if params.reason ~= nil and params.reason == "no this channel" then
		ifclient = nil
	elseif params.reason == "disconnect" then
		ifclient = nil
	end

	-- PopText("断开连接")

	callBackStatus("断开连接", params)
end

function FubenClient:disconnect()
	keepReconnect = false
	currentState = CONNECT_STATE_CLOSE
	if ifclient ~= nil then
		ifclient:disconnect(false)
	end
end

function FubenClient:isConnect()
	if ifclient ~= nil then
		if currentState == CONNECT_STATE_OPEN then
			return true
		else
			return false
		end
	end

	return false
end

-- 只用调用一次，后面可以使用reconnect来重复连接
function FubenClient:connect()
	if currentState == CONNECT_STATE_OPENING then
		return
	end
	self.timeout = timeout

	if ifclient == nil then
		local uid = User:getUserId() .. ""
		username = uid
		zoneid = Game:getChannelId()

		-- 这里放入登陆的数据
		local extra = {}
		local role = User:getRole()
		extra.channel = zoneid
		extra.userid = uid
		extra.name = role:getAttr("name")
		-- TODO 头像id，最强的3中武学，门派，第几代弟子， 
		extra.looks = role:getAttr("looks")
		extra.sex = role:getAttr("sex")
		extra.dsc = role:getAttr("dsc")
		extra.age = role:getAttr("age")
		extra.qi = role:getAttr("qi")
		extra.qiPercent = role:getAttr("qiPercent")
		extra.exp = role:getAttr("exp")
		extra.family = role:getAttr("family") -- add by XiaoZhiWei 2017/06/17 15:43:17 门派信息
		extra.portrait = role:getAttr("portrait")	-- add by XiaoZhiWei 2017/06/17 15:43:04 装备装饰品
		extra.equips = role:getAttr("equips") -- add by XiaoZhiWei 2017/06/17 15:42:51 装备头帽
		extra.jiaLi = role:getFinalAttr("jiaLi")
		-- extra.inheritHistory = role:getAttr("inheritHistory") -- add by XiaoZhiWei 2017/06/17 15:42:43 传承历史
		extra.skillPrepare = role:getSkillPrepare()	 -- add by XiaoZhiWei 2017/06/17 15:43:38 准备的技能列表
		extra.skills = role:getPrepareSkills() -- add by XiaoZhiWei 2017/06/17 15:43:31 准备的等级最高的三个技能

		extra.zhengqi = role:getAttr("zhengqi")
		extra.officialType = role:getAttr("officialType") --官职类型
		extra.officialAchievement = role:getAttr("officialAchievement") --政绩
		extra.yueKaValid = role:getAttr("yueKaValid") --是否拥有月卡
		
		-- 易容术数据
		extra.polymorph = role.polymorph
		-- extra._yirongSelectList = role._yirongSelectList
		--pvp等待界面显示所需数据
		extra.title = role:getChengHaoColorName() --称号
		extra.title_type = role:getAttr("title_type") --称号类型
		extra.title_id = role:getAttr("title_id")
		extra.basicTitleData = role:getBasicTitleData()
		extra.borderVer = role:getAttr("borderVer")
		extra.borderShowList = role:getAttr("borderShowList")
		extra.kongfu = role:getKongfu() --武功值
		extra.jiaLiDsc = role:getJialiDsc()
		extra.weaponName = role:getCurrWeaponName()
		extra.appearance = role.appearance

		if role:checkRoleIsPolymorph() then		
			extra.sex = role.polymorph.sex
		end
		local shenbings = role:getItems(function (item)
			return item.type == "神兵"
		end)
		extra.items = {}
		extra.shenBingItems = {}  -- add by XiaoZhiWei 2017/07/03 21:19:26	神兵信息
		if shenbings[1] and shenbings[1].itemId  then
			table.insert( extra.items,shenbings[1])
			local shenbing
			for i,v in ipairs(role.shenBingItems) do
				if v.id == shenbings[1].itemId then
					shenbing = v
					break
				end
			end
			if string.len(shenbing.name) > 15 then  --对存档修改进行屏蔽
				shenbing.name = "普通神兵" 
			end
			table.insert( extra.shenBingItems,shenbing )
		end



		-- local shenbingId = shenbings[1].itemId

		-- local shenbingItems = role:getAttr("shenBingItems")

		-- Helper:print_lua_table(shenbingItems)

		
		--七夕活动相关属性
		extra.prayRoomId = role:getAttr("prayRoomId")

		-- --@desc 武学突破数据
		-- extra.skillBreakData = role:getAttr("skillBreakData")

		-- --@desc 招式突破数据
		-- extra.zhaoBreakData = role:getAttr("zhaoBreakData")

		extra.isWhiteList = role:getAttr("isWhiteList")

		local tb = {
	    	userid = uid,
	    	uuid = Game:getIdfv(),
	    	platform  = Game:getPlatformId(),
	    	channel = Game:getChannelId()
		}
		local authJson = jsonpvp.encode(tb)
		local data = JMForLua:encrypt(authJson)

		extra.auth = data
		local params = jsonpvp.encode(extra)
		if FENGZUDUIKANG_IS_OPEN == true then
			serverDomain = "192.168.1.60"
		end
		ifclient = wyf.Ifclient:create(serverDomain, 9529, username, params, 17, 100000000)
		ifclient:setCallback(onMessageRecvCallback, onEventRecvCallback, onConnectSuccessCallback
			, onConnectErrorCallback, onDisconnectCallback)
	end
	currentState = ifclient:getState();
	print("currentState = " .. currentState)

	self:reconnect()

	keepReconnect = true
end

-- 断开连接后，如果要重连，直接调用本函数
function FubenClient:reconnect()
	if currentState == CONNECT_STATE_OPENING then
		return
	end

	if (currentState == CONNECT_STATE_CLOSE) then
		-- 初始化构造连接
		-- 只能调用一次
		ifclient:connect(10)
		currentState = CONNECT_STATE_OPENING
	elseif (currentState == CONNECT_STATE_OPEN) then
		-- 当前状态是打开的，不用管，直接返回
		return
	elseif (currentState == CONNECT_STATE_SUSPEND) then
		-- 当前状态是挂起的，恢复连接
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 10:02:32
-- @desc 设置链接回调函数
function FubenClient:setCallBack(func)
	__callBack = func
end

function FubenClient:ifClientIsNil()
	return ifclient == nil
end

return FubenClient
00000000000