local Item = require("app.models.item.Item")
local Role = require("app.models.role.Role")

local function log(...)
	if DEBUG_MODE == 1 then
		print("BaseMap:", ...)
		local strList = table.map({...}, function(v) return tostring(v) end)
		-- PopText(table.concat(strList, " "))
	end
end

local BaseMap =
{
	-- name = "金牛武馆",

	-- title = "第一章",
	-- summary = "金牛武馆名声远扬\n无名小辈无人能挡",
	-- detailDsc = "地图:金牛武馆\n目标: 打败金牛武馆所有人\n奖励: 5W经验  2W潜能  20点江湖阅历",

	-- -- 地图人物 -------
	-- roles =
	-- {
	-- 	["谷虚道长"] =
	-- 	{
	-- 		type = "role",
	-- 		id = "谷虚道长",
	-- 		baseId = "guxudaozhang",
	-- 		name = "谷虚道长",
	-- 	},
	-- 	["宋远桥"] =
	-- 	{
	-- 		type = "role",
	-- 		id = "宋远桥",
	-- 		name = "宋远桥",
	-- 		baseId = "songyuanqiao",
	-- 		dsc = "这是宋远桥",
	-- 		canTalk = true,
	-- 		canPresent = false,
	-- 		canCompete = false,
	-- 		canConsult = false,
	-- 		canApprentice = false,
	-- 		canKill = false,
	-- 		talk =
	-- 		{
	-- 			"你好1",
	-- 			"你好2",
	-- 			"你好3",
	-- 			"你好4",
	-- 		},
	-- 		receivePresent = "屠龙刀",
	-- 		conditionAndResults =
	-- 		{
	-- 			{
	-- 				conditionRelation = "and",
	-- 				conditions =
	-- 				{
	-- 					{
	-- 						type = "玩家操作",
	-- 						name = "交谈",
	-- 						value = 1
	-- 					}
	-- 				},
	-- 				results =
	-- 				{
	-- 					{
	-- 						type = "玩家物品变化",
	-- 						name = "屠龙刀",
	-- 						value = 1
	-- 					},
	-- 					{
	-- 						type = "玩家属性变化",
	-- 						name = "age",
	-- 						value = 1
	-- 					},
	-- 					{
	-- 						type = "房间属性设置",
	-- 						name = "北大街2",
	-- 						value = "可见"
	-- 					}
	-- 				}
	-- 			}
	-- 		}
	-- 	},
	-- 	["屠龙刀"] =
	-- 	{
	-- 		type = "item",
	-- 		id = "屠龙刀",
	-- 		name = "屠龙刀",
	-- 		dsc = "这是一把屠龙刀",
	-- 		canPickUp = false, -- 拾取
	-- 		canUse = false, -- 使用
	-- 		canExtract = false, -- 提取
	-- 		canOpen = false, -- 打开
	-- 		canPushIn = false, -- 能放入
	-- 		conditions =
	-- 		{
	-- 			{
	-- 				condition =
	-- 				{
	-- 				},
	-- 				result =
	-- 				{
	-- 				}
	-- 			}
	-- 		}
	-- 	},
	-- 	["打开的箱子"] =
	-- 	{
	-- 		type = "item",
	-- 		id = "打开的箱子",
	-- 		name = "打开的箱子",
	-- 		dsc = "这个一个打开的箱子, 里面好像放着什么",
	-- 		canPickUp = false, -- 拾取
	-- 		canUse = false, -- 使用
	-- 		canExtract = true, -- 提取
	-- 		canOpen = false, -- 打开
	-- 		canPushIn = false, -- 能放入
	-- 	},
	-- 	["空的箱子"] =
	-- 	{
	-- 		type = "item",
	-- 		id = "空的箱子",
	-- 		name = "空的箱子",
	-- 		dsc = "里面空空如也",
	-- 		canPickUp = false, -- 拾取
	-- 		canUse = false, -- 使用
	-- 		canExtract = false, -- 提取
	-- 		canOpen = false, -- 打开
	-- 		canPushIn = false, -- 能放入
	-- 	},
	-- },

	-- -- 地图部分........
	-- entryRoom = "北门",
	-- room =
	-- {
	-- 	["北门"] =
	-- 	{
	-- 		id = "北门",
	-- 		name = "北门",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			down = "北大街1"
	-- 		},
	-- 		roleList =
	-- 		{
	-- 			"谷虚道长",
	-- 			"宋远桥"
	-- 		},
	-- 		permission = 1, -- 房间权限, 1 为可见, 2 为通关后可见
	-- 		visible = true,  -- 可见的
	-- 		enterable = true -- 可进入的
	-- 	},
	-- 	["北大街1"] =
	-- 	{
	-- 		id = "北大街1",
	-- 		name = "北大街",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "北门",
	-- 			left = "小吃店",
	-- 			down = "北大街2"
	-- 		},
	-- 		roleList =
	-- 		{
	-- 			"宋远桥",
	-- 			"屠龙刀"
	-- 		}
	-- 	},
	-- 	["北大街2"] =
	-- 	{
	-- 		id = "北大街2",
	-- 		name = "北大街",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "北大街1",
	-- 			right = "菜市场",
	-- 			down = "中央广场",
	-- 		},
	-- 		visible = false,  -- 可见的
	-- 	},
	-- 	["中央广场"] =
	-- 	{
	-- 		id = "中央广场",
	-- 		name = "中央广场",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "北大街2",
	-- 			left = "西大街",
	-- 			right = "东大街",
	-- 			down = "南大街1",
	-- 		}
	-- 	},
	-- 	["南大街1"] =
	-- 	{
	-- 		id = "南大街1",
	-- 		name = "南大街",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "中央广场",
	-- 			right = "钱庄",
	-- 			down = "南大街2"
	-- 		}
	-- 	},
	-- 	["南大街2"] =
	-- 	{
	-- 		id = "南大街2",
	-- 		name = "南大街",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "南大街1",
	-- 			down = "南门"
	-- 		}
	-- 	},
	-- 	["南门"] =
	-- 	{
	-- 		id = "南门",
	-- 		name = "南门",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "南大街2"
	-- 		}
	-- 	},
	-- 	["小吃店"] =
	-- 	{
	-- 		id = "小吃店",
	-- 		name = "小吃店",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			right = "北大街1"
	-- 		}
	-- 	},
	-- 	["西大街"] =
	-- 	{
	-- 		id = "西大街",
	-- 		name = "西大街",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			right = "中央广场",
	-- 			down = "小集市"
	-- 		}
	-- 	},
	-- 	["小集市"] =
	-- 	{
	-- 		id = "小集市",
	-- 		name = "小集市",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "西大街",
	-- 			down = "迎风酒店"
	-- 		}
	-- 	},
	-- 	["迎风酒店"] =
	-- 	{
	-- 		id = "迎风酒店",
	-- 		name = "迎风酒店",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "小集市"
	-- 		}
	-- 	},
	-- 	["菜市场"] =
	-- 	{
	-- 		id = "菜市场",
	-- 		name = "菜市场",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			left = "北大街2",
	-- 			down = "东大街",
	-- 			rightUp = "秘境"
	-- 		}
	-- 	},
	-- 	["东大街"] =
	-- 	{
	-- 		id = "东大街",
	-- 		name = "东大街",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			up = "菜市场",
	-- 			left = "中央广场"
	-- 		}
	-- 	},
	-- 	["钱庄"] =
	-- 	{
	-- 		id = "钱庄",
	-- 		name = "钱庄",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			left = "南大街1"
	-- 		}
	-- 	},
	-- 	["秘境"] =
	-- 	{
	-- 		id = "秘境",
	-- 		name = "秘境",
	-- 		dsc = "",
	-- 		link =
	-- 		{
	-- 			leftDown = "菜市场"
	-- 		}
	-- 	}
	-- }
}

BaseMap = {}

BaseMap.doResultFun = {}

--@desc 副本事件名
BaseMap.EventType = 
{
	--@desc 角色属性变化
	ROLE_ATTR_CHANGE_EVENT = "ROLE_ATTR_CHANGE_EVENT",

	--@desc 角色复活替换房间
	ROLE_RESURGENCE_REPLACEROOM_EVENT = "ROLE_RESURGENCE_REPLACEROOM_EVENT",

	--@desc 角色死亡退出副本
	ROLE_DIE_QUITMAP_EVENT = "ROLE_DIE_QUITMAP_EVENT"
}


function BaseMap:create()
    local p = inherit({}, BaseMap)

    p:ctor()

    return p
end

-- 构造方法
function BaseMap:ctor()
    self._delayTasks = {}

    self._observable = Observable:create()

    self._subscriptions = {}

	self._isInFighting = false

	self.__mapStatusTagsService = require("app.models.RoleStatusTags.MapStatusTagsService"):create(self)
end
-- 初始化
function BaseMap:init()
    --@desc 初始化地图类型
    if self.mid then
        if self:isUserMap() then
            self:__setMapType(MAP_TYPE.MYHOME)
        else
            self:__setMapType(MAP_TYPE.OTHERHOME)
        end
    else
        if self.mapType == nil then
            self:__setMapType(MAP_TYPE.BASE)
        else
            self:__setMapType(self.mapType)
        end
    end
end

--@desc 注册事件监听
function BaseMap:subscribe(eventName, callback)
	return self._observable:subscribe(eventName, callback)
end

--@desc 分发事件
function BaseMap:__notify(eventName, ...)
	log("分发事件 :",eventName)
	self._observable:notify(eventName, ...)
end

--@desc 初始化观察者
function BaseMap:initObserver()
	log("initObserver",self)
	if #self._subscriptions == 0 then
		-- 观察角色血量
		do
			local subscription = self:getPlayer():watchFinalAttrChange("qi", function(new, old, change)
				log("角色血量变化:", new, old, change)
				if Helper:mathFloor(new) <= 0 and old > 0 then
					self:__playerDie()
				end
			end)

			table.insert(self._subscriptions, subscription)
		end
		
		-- 观察角色所有属性变化
		local subscription = self:getPlayer():watchAllFinalAttrChange(function(attrName, new, old, change)
			log("角色属性变化:", attrName, new, old, change)
			self:__notify(BaseMap.EventType.ROLE_ATTR_CHANGE_EVENT, attrName, new, old, change)
		end)
		
		table.insert(self._subscriptions, subscription)
	else
		log("异常, 副本观察者已经初始化过")
	end
end

function BaseMap:__playerDie()
	local role = self:getPlayer()

	--@desc 续魂灯复活，恢复满状态，传送到默认房间
	if role:getItemCount("drwp103") > 0 then
		role:setAttr("qiPercent", 1)
		role:setAttr("qi", role:getCurrQiMax())
		role:setAttr("neili", role:getFinalAttr("neiliMax"))
		role:addItemCount("drwp103",-1)
		PopText("消耗续魂灯复活")
		self:__notify(BaseMap.EventType.ROLE_RESURGENCE_REPLACEROOM_EVENT)
	else
		local drSystem = User:getRole():getDreamSystem()
		drSystem:mapComplete(
			self,
			function()
				self:__notify(BaseMap.EventType.ROLE_DIE_QUITMAP_EVENT)
			end
		)
		return
	end
end

--@desc 反初始化观察者
function BaseMap:__deInitObserver()
	log("__deInitObserver",self)
	if #self._subscriptions > 0 then
		for i, v in ipairs(self._subscriptions) do
			v:unsubscribe()
		end
		self._subscriptions = {}
	else
		log("异常, 副本观察者没有进行初始化")
	end
end

-- 初始化所有角色
function BaseMap:initAllRole()
	if not MapIsEmpty(self.roles) then
		for k, role in pairs(self.roles) do
			self:getRole(role.id)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/12 16:28:41
-- @desc  获取地图角色属性列表
function BaseMap:getRoles()
	return self.roles
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/12 16:30:33
-- @desc 获取指定房间的角色列表
function BaseMap:getRoomRoleList(roomId)
	local roomMap = self:getRoomMap()--self.room
	-- 房间ID,副本房间Map,房间map内部是否存在该房间 任意一个不成立则返回为空
	if roomId == nil or MapIsEmpty(roomMap) == true or roomMap[roomId] == nil then
		return nil
	end
	-- 直接返回角色列表
	return roomMap[roomId].roleList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/09/07 10:38:17
-- @desc 初始化商人物品
local function initSalesItem(role)
	if role and (role.canSale == 1 or role.canSale == true) and role.saleList and type(role.saleList) == "string" then
		local items = string.split(role.saleList, ";")
		if role.type == "item" then
			role.items = items
		else
			for k,v in pairs(items) do
				--增加对能否获取物品的判断
				if not role:addItemCount(v, 1) then
					return
				end
			end
		end
		role.saleList = nil
	end
end

-- 得到地图角色
function BaseMap:getRole(roleId)
	local role = self.roles[roleId]

	if role == nil and (self:getMapType() == MAP_TYPE.DREAMMAP or self:getMapType() == MAP_TYPE.FONDDREAMMAP) then
		local drSystem = User:getRole():getDreamSystem()
		local role = drSystem:createNpc(roleId,self:getPlayer().dreamWorld.cFloor)

		if role ~= nil then
			self.roles[roleId] = role
			role._inMapInited = true
			return role
		else
			print("======================= warning ==========================")
			print("------------- 地图找不到ID："..roleId.."的NPC---------------")
			print("==========================================================")
			return nil
		end
	end


	if role == nil then
		if Game:isTesting() == true then
			assert(nil, "副本中没有该角色 name = "..tostring(roleId))
		else
			return
		end
	end

	-- 记录是否初始化, 只需要初始化一次
	if role._inMapInited == nil or role._inMapInited == false or role.name == "章作之" then

		-- baseId 判断不能省去（飞贼任务）
		if role.type == "role" then

			if Map:getMapVersionByMapId(self.id) == EDITOR_MAP_VERSION then
				role = Role:create(role)
			else
				if role.baseId ~= nil and self.mid == nil then
					-- local Npc = require("app.models.npc.Npc")
					-- local Map = require("app.models.map.Map")
					if role.zhang_inited ~= true then
						local npc = Map:getMapNpc(self.id, role.baseId)
						if npc == nil then
							npc = Npc:getNpc("guxudaozhang")
						end

						role = table.cloneAndRemoveFunctions(role)
						role = TableProxy:createEncryptedTableRecursive(role)
						role = inherit(role, npc)
						role = Role:create(role)

						if role.name == "章作之" then
							role.zhang_inited = true
						end
					end

					if PRINT_MODE == 1 then
						print("玩家名 = "..tostring(role.name).."; 玩家队伍 = "..tostring(role.teamMark))
					end
				end

				-- Npc:initRoleWithRandomAttr(role) -- add by XiaoZhiWei 2017/03/08 16:11:29 初始化副本角色随机属性
				-- Npc:initNpc(role)
				-- NPC属性修改
			end
			
			Npc:initSalesItem(role)
			
			self:npcAttrModify(role)
			-- 刷新npcbuff效果
			role:updateRoleBuff()
			--npc的血量和内力回满
			role.qi = role:getCurrQiMax()
			role.neili = role:getFinalAttr("neiliMax")
		elseif role.type == "item" then
			local BaseItem = require("app.models.item.BaseItem")
			role = inherit({}, role, BaseItem:create())
		end

		Npc:initRoleIsForbidden(role)
		role._inMapInited = true
		self.roles[roleId] = role
	end
	return self.roles[roleId]
end

function BaseMap:createRole(role)
	if role == nil or role.id == nil then
		return
	end
	if self.roles == nil then
		self.roles = {}
	end
	if self.roles[role.id] == nil then
		-- add by XiaoZhiWei 2017/04/27 23:54:41 做特殊处理,神书活动的NPC 不需要在这里补全结构
		if role.baseId == "shenshunpc" or role.baseId == "xunbaoren1" or role.baseId == "xunbaoren2" or role.baseId == "xunbaoren3" then
			self.roles[role.id] = role
		elseif role.isFromWeb == true then
			role._inMapInited = true
			self.roles[role.id] = Role:create(role)
		else
			self.roles[role.id] = Role:create(role)
		end

		if PRINT_MODE == 1 then
			print("创建角色成功!!!!")
		end
	elseif role.isFromWeb == true then
		-- add by XiaoZhiWei 2017/06/16 15:29:05 偶遇角色 需要实时更新
		self.roles[role.id] = Role:create(self.roles[role.id])
	else

		if PRINT_MODE == 1 then
			print("已经有该角色!!!!")
		end
	end
end

function BaseMap:addRoomRole(roomId, roleId, isRefresh)
	if PRINT_MODE == 1 then
		print("BaseMap:addRoomRole(roomId, roleId)")
	end
	if roleId == nil or roleId == "" then
		if PRINT_MODE == 1 then
			error("这个角色Id不存在,请检查代码 roomId: "..tostring(roomId)..", roleId: "..tostring(roleId))
		end
		return
	end

	if isRefresh == nil then
		isRefresh = true
	end
	local room = self:getRoomById(roomId)
	if room.roleList == nil then
		room.roleList = {}
	end

	if PRINT_MODE == 1 then
		print("添加角色"..tostring(roleId).."到房间"..tostring(roomId))
	end

	for k,rRoleId in pairs(room.roleList) do
		if roleId == rRoleId then

			if PRINT_MODE == 1 then
				print("房间中已存在该"..tostring(roleId).."角色，不需要再次添加")
			end

			return
		end
	end

	table.insert(room.roleList, roleId)

	MapPVPRoles._needRefresh = true -- add by XiaoZhiWei 2017/08/15 12:01:48 添加人物需要刷新一下江湖人士列表
	-- 添加角色后 判断整个房间的条件结果
	if isRefresh then
		self:doRoomConditionAndResult(roomId)
	end
end

-- 离开副本
function BaseMap:leaveMap()
	if self:getMapType() == MAP_TYPE.DREAMMAP or self:getMapType() == MAP_TYPE.FONDDREAMMAP then
		-- 反初始化副本观察者
		self:__deInitObserver()
	end 

	local role = User:getRole()
	if self:getMapType() ~= MAP_TYPE.MYHOME and self:getMapType() ~= MAP_TYPE.OTHERHOME and self:getMapType() ~= MAP_TYPE.DREAMMAP and self:getMapType() ~= MAP_TYPE.FONDDREAMMAP then
		role:setFlag(self.id, GetTime())
	end
	self.isInMap = false
	FubenClient:disconnect()
	User:getRole():setFlag("当前位置","离开副本")
	-------------------------------------------------------------------
	------------ 友盟接入
	if device.platform == "ios" then
		Mob.failLevel(self.index)
	end

	if self.comingAfterBoss ~= nil then

		print( "离开地图###############停止计时")
		if self.comingAfterBoss.delayFuncHandle ~= nil then
			 self.__MapLayer:stopActionByTag( self.comingAfterBoss.delayFuncHandle )
			 self.comingAfterBoss.delayFuncHandle = nil
		end

		self.comingAfterBoss = nil
	end

	if self.timerMap ~= nil then
		--清空计时器
		for k,v in pairs(self.timerMap) do
			if v.delayFuncHandle ~= nil then
				print("清除计时器: " .. tostring(v.name))
				self.__MapLayer:stopActionByTag( v.delayFuncHandle )
				v.delayFuncHandle = nil
			end
		end
		self.timerMap = nil
	end

	if MapIsEmpty(self.__scheduleList) == false then
		self.__scheduleList = nil
	end
	MessageCenter:notify("LeaveMap", {map = self})

	MessageCenter:removeObjListener(self)
end
-- 获取是否在副本中
function BaseMap:getRoleIsInMap()
	return Helper:getDef(self.isInMap,false)
end
--设置是否在副本中
function BaseMap:setRoleIsInMap(loop)
	loop = Helper:getDef(loop,false)
	self.isInMap = loop
end
function BaseMap:__callback(eventName, params)
	if self.__callBack then
		self.__callBack(eventName, params)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 11:58:29
-- @desc 副本回调
function BaseMap:setCallBack(func)
	self.__callBack = func
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/06 15:28:42
-- @desc 获取当前服务器链接状态
function BaseMap:getCurrConnectStatus()
	return self.__currConnectStatus
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/06 15:29:47
-- @desc 设置当前服务器链接状态
function BaseMap:__setCurrConnectStatus(status)
	self.__currConnectStatus = status
end


function BaseMap:setDissconnectCallback( callback )
	self.__disconnectWebCallBack = callback
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/06 12:18:11
-- @desc 链接服务器
function BaseMap:__connectWeb()
	FubenClient:setCallBack(function(eventName, params)

		local UserMap = require("app.models.map.UserMap")
		-- add by XiaoZhiWei 2018/06/05 14:17:13 在扩建的时候是不能偶遇的
		if UserMap:isOpenEnlarge() then
			return
		end

		if PRINT_MODE == 1 then
			print("eventName == ", eventName)
			print("params == ", params)
			Helper:print_lua_table(params)
		end
		local body = {}
		if params.body and params.body ~= "" then
			body = Helper:getDef(jsonpvp.decode(params.body), {}) 
		end
		if eventName == "连接成功" then
			local roomId = Helper:getDef(self:getCurrRoomId(),self:getDefaultRoomId())
			FubenClient:comeIn(self.id, roomId, self:getRoomNameById(roomId), Helper:getOnlyId())
			self:__setCurrConnectStatus(1)
			if MainControllLayer:isLayerRemoved("MapLayer") == false then
				MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
			end
		elseif eventName == "断开连接" then
			if self.__disconnectWebCallBack then
				self.__disconnectWebCallBack()
			end
			self:__setCurrConnectStatus(nil)

			self.__disconnectWebCallBack = nil
		elseif eventName == "连接出错" then
			self:__setCurrConnectStatus(nil)
		elseif eventName == "加入房间成功" then
			-- 先删除房间中原有的灯笼
			local maplayer = MainControllLayer:getLayer("MapLayer")
			local currRoomId = self:getCurrRoomId()
			if MapIsEmpty(maplayer._currRoom.webItemList) == false then
				for k,v in pairs(maplayer._currRoom.webItemList) do
					self:removeRoomRole(currRoomId,v, false)
				end
				maplayer._currRoom.webItemList = {}
			end


			local users = Helper:getDef(body.users, {})
			self:__addPlayerToRoom(users.roomId, users.list)
			local removeList = {}
			if not MapIsEmpty(users.list) then
				for k,v in pairs(users.list) do
					if v.x_type == "denglong" then
						table.insert(removeList,k)
					end
				end
			end
			if not MapIsEmpty(removeList) then
				for k,v in ipairs(removeList) do 
					users.list[v] = nil
				end
			end
			self:updateRoomWebRoles(users.roomId, users.list) -- add by XiaoZhiWei 2017/06/19 18:02:27 检查一下
			MapPVPRoles:setMapRoomRoleListWithMap(users.mapId, users.roomId, users.list)
			if MainControllLayer:isLayerRemoved("MapLayer") == false then
				MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
			end
		elseif eventName == "成功发送切磋请求" then
			MapPVP:updateFightMsg(body.key, {time = GetTime(), fightType = "切磋", startRole = "ME", status = "发起切磋中", userid = body.targetId, targetName = body.targetName, sex = Helper:getDef(self:getRole(body.targetId):getAttr("sex"), "男")})
			PopText("等待对方回应")
		elseif eventName == "对方请求切磋" then
			if User:getRole():getFlag("副本状态") == "忙碌" then
				FubenClient:reject(body.userid, params.actionCode, body.time, body.key, "您正在做别的事情，无法进行此操作。", params.id)
			end
			if Map:checkRoomCanQieCuo(self.__MapLayer._currRoom.id) == false then
				-- add by XiaoZhiWei 2017/07/18 19:28:55 这里的文本是给对方显示的
				FubenClient:reject(body.userid, params.actionCode, body.time, body.key, "对方正在忙碌中！", params.id) 
			else
				if User:getRole():getFlag("PVP活动状态") == "忙碌" then
					FubenClient:reject(body.userid, params.actionCode, body.time, body.key, "对方正在忙碌中！", params.id)
					return 
				end
				if User:getRole():getFlag("PVP战斗状态") == 0 then
					User:getRole():updateFightStatus("战斗结束")
				end
				local status = User:getRole():getFlag("PVP战斗状态")
				if PRINT_MODE == 1 then
					PopText(status)
				end
			local sex
			if MapIsEmpty(self:getRole(body.userid)) == false then
				sex = Helper:getDef(self:getRole(body.userid).sex, "男")
			end
			MapPVP:updateFightMsg(body.key, {time = body.time / 1000, fightType = "切磋", startRole = "HE", status = "被邀请切磋等待中", userid = body.userid, targetName = body.name, result = 0, actionCode = params.actionCode, id = params.id, sex = sex})
				if status == "主动邀战等待中" or status == "战斗结束" then
					if status == "战斗结束" then -- add by XiaoZhiWei 2017/06/17 17:24:14 主动邀战等待中 不需要更新状态
						User:getRole():updateFightStatus("被邀战等待中")
					end

					PopupLayerController:showLayer("PVPWaitingLayer", function(layer)
						layer:show()
						layer:setTitleText("江湖切磋")
						layer:showYingZhan(body.userid, params.actionCode, body.time / 1000, body.key, params.id)
					end)
				elseif status == "被邀战等待中" then
					if MapIsEmpty(MapPVP:getData()) == true then
						User:getRole():updateFightStatus("战斗结束")
					end 
				elseif status == "战斗中" or status == "战斗开始" then
					MapPVP:updateFightMsg(body.key, {reason = "忙碌，无法切磋", result = 61})
					FubenClient:reject(body.userid, params.actionCode, body.time, body.key, User:getRoleAttr("name").."正在忙碌，暂时无法与你切磋", params.id) 
				elseif status == "免打扰模式" then
					-- add by XiaoZhiWei 2017/06/16 10:57:45 就是不谈出邀战界面,可在切磋历史内查看并应战
				else
					PopText(status)
					MapPVP:updateFightMsg(body.key, {reason = "条件不符合，无法切磋", result = 60})
					FubenClient:reject(body.userid, params.actionCode, body.time, body.key, "条件不符合，无法切磋", params.id)
					User:getRole():updateFightStatus("战斗结束")
				end
			end
		elseif eventName == "切磋请求失败" then
			MapPVP:updateFightMsg(body.key, {time = GetTime(), fightType = "切磋", startRole = "ME", updateTime = GetTime(), status = "切磋请求失败", reason = body.reason, userid = body.targetId, targetName = self:getRole(body.targetId):getName(), sex = Helper:getDef(self:getRole(body.targetId):getAttr("sex"), "男")})
			PopText(body.reason)
		elseif eventName == "切磋请求结果" then
			if body.result == "YES" then
				MapPVP:updateFightMsg(body.key, {status = "切磋倒计时"})
				local role
				if body.sponsorId ~= tostring(User:getUserId()) then
					role = self:getRole(body.sponsorId)
				else
					role = self:getRole(body.targetId)
				end
				
				FubenClient:setValue("isFighting", true)
				PopupLayerController:showLayer("PVPWaitingLayer", function(layer)
					layer:show()
					layer:setTitleText("江湖切磋")
					layer:showWaiting(role, body.key, function()
						PopupLayerController:hideLayer("PVPWaitingLayer", function(layer)
							layer:hide()
						end)

						local targetId, targetName
						if body.sponsorId == tostring(User:getUserId()) then
							-- 本地为发起方
							targetId = body.targetId
							targetName = body.targetName
						else
							targetId = body.sponsorId
							targetName = body.sponsorName
						end

						local GamePVP = require("app.models.pvp1.PVPExpress")

						for k, v in pairs(body) do
							print(tostring(k) .. ":" .. tostring(v))
						end

						-- 通知服务器，本地正在战斗
						User:getRole():updateFightStatus("战斗中")
	        			local waitingLayer = WaitingLayer:createInRunningScene()
						FubenClient.pvp = GamePVP:create(targetId, targetName, body.key, 20, function (eventName, localRole, targetRole, value)
							-- print("eventName = " .. eventName)
							-- TODO 收到回掉后，关闭倒数界面
							if eventName == "战斗开始" then
								if waitingLayer then
									waitingLayer:hideAndRemoveSelf()
									waitingLayer = nil
								end
								-- TODO
							elseif eventName == "战斗异常" then
								if waitingLayer then
									waitingLayer:hideAndRemoveSelf()
									waitingLayer = nil
								end
								FubenClient:abortFight(body.sponsorId, body.targetId, body.key)

								FubenClient:setValue("isFighting", false)
								User:getRole():updateFightStatus("战斗结束")
								if targetRole ~= nil then
									MapPVP:updateFightMsg(body.key, {status = "战斗结束", reason = "战斗异常", userid = targetId, targetName = targetRole:getName(), sex = Helper:getDef(targetRole:getAttr("sex"), "男")})
								else
									MapPVP:updateFightMsg(body.key, {status = "战斗结束", reason = "战斗异常", userid = targetId, targetName = targetName, sex = "男"})	
								end
							elseif eventName == "战斗结束" then
								if waitingLayer then
									waitingLayer:hideAndRemoveSelf()
									waitingLayer = nil
								end
								FubenClient:setValue("isFighting", false)
								User:getRole():updateFightStatus("战斗结束")
								if targetRole ~= nil then
									MapPVP:updateFightMsg(body.key, {status = "战斗结束", result = value, userid = targetId, targetName = targetRole:getName(), sex = Helper:getDef(targetRole:getAttr("sex"), "男")})
								else
									MapPVP:updateFightMsg(body.key, {status = "战斗结束", result = value, userid = targetId, targetName = targetName, sex = "男"})	
								end

								local ZhongQiuUtil = require("app.models.Action.ChineseValentine.2018.ZhongQiuUtil")
								ZhongQiuUtil:getZhongQiuBiWuAward(self:getCurrRoomId(),value)
								
								local AnniversaryOfThird = require("app.models.Anniversary.AnniversaryOfThird")
								AnniversaryOfThird:getPVPBiWuAward(self.id,value)
								User:getRole():addSeeSkillAfterFight(targetRole) --战斗结束后添加见闻武学技能
							else
								if waitingLayer then
									waitingLayer:hideAndRemoveSelf()
									waitingLayer = nil
								end
							end

							FubenClient.pvp = nil
						-- TODO  回调事件
						end, body.pvpDomain, body.pvpPort, body.randomSeed)
					end)
				end)
			else
				User:getRole():updateFightStatus("战斗结束")
				MapPVP:updateFightMsg(body.key, {status = "拒绝战斗"})
				PopText(body.reason)
			end
		elseif eventName == "玩家加入房间" then
			if MainControllLayer:isLayerRemoved("MapLayer") == false then
				self:__addPlayerToRoom(self:getCurrRoomId(), {[body.user.userid] = body.user})
				MapPVPRoles:addOneRoleToRoom(self.id, self:getCurrRoomId(), body.user)
				MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
			end
		elseif eventName == "玩家离开房间" then
			if MainControllLayer:isLayerRemoved("MapLayer") == false then
				self:removeRoomRole(self:getCurrRoomId(), body.user.userid, false)
				MapPVPRoles:removeOneRoleFromRoom(self.id, self:getCurrRoomId(), body.user.userid)
				MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
			end
		elseif eventName == "清除灯笼" then
			if body.mapid ~= nil and body.roomid ~= nil then
				local currRoomId = self:getCurrRoomId()
				local maplayer = MainControllLayer:getLayer("MapLayer")
				if MapIsEmpty(maplayer._currRoom.webItemList) == false then
					for k,v in pairs(maplayer._currRoom.webItemList) do 
						print("-------------清除灯笼清除灯笼清除灯笼----------------------",currRoomId,v)

						self:removeRoomRole(currRoomId,v, false)
					end
					maplayer._currRoom.webItemList = {}
				end
			end
			MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
		elseif eventName == "刷新灯笼" then
			local maplayer = MainControllLayer:getLayer("MapLayer")
			if body.mapId ~= nil and body.roomId ~= nil then
				local currRoomId = self:getCurrRoomId()
				if MapIsEmpty(maplayer._currRoom.webItemList) == false then
					for k,v in pairs(maplayer._currRoom.webItemList) do
						self:removeRoomRole(currRoomId,v, false)
					end
					maplayer._currRoom.webItemList = {}
				end
			end
			if MainControllLayer:isLayerRemoved("MapLayer") == false then
				if MapIsEmpty(body.list) == false then
					if DEBUG_MODE == 1 then 
						Helper:print_lua_table(body.list)
					end
					for k,v in pairs(body.list) do 
						print(body.roomId,"-----------------灯笼列表------------------------",k,v.userid)
						self:__addPlayerToRoom(body.roomId,{[v.userid] = v})
					end
				end
				
			end
			MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
		elseif eventName == "灯笼次数减一" then
		elseif eventName == "获取房间玩家成功" then
			local users = Helper:getDef(body.users, {})
			local removeList = {}
			for k,v in pairs(users.list) do
				if v.x_type == "denglong" then
					table.insert(removeList,k)
				end
			end
			if not MapIsEmpty(removeList) then
				for k,v in ipairs(removeList) do 
					users.list[v] = nil
				end
			end
			MapPVPRoles:setMapRoomRoleListWithMap(users.mapId, users.roomId, users.list)
		elseif eventName == "值变化" then
			-- add by XiaoZhiWei 2017/07/04 11:35:11 更新玩家信息
			print(body.userid,"------------------------",User:getUserId())
			if body.key == "PopText" and tostring(body.userid) ~= tostring(User:getUserId()) then
				-- PopText(body.value)
				RichPrint("main",body.value)
				return
			end
			MapPVPRoles:addOneRoleToRoom(body.mapId, body.roomId, {userid = body.userid, [body.key] = body.value})
		elseif eventName=="被祝福" then
			local role = User:getRole()
			--记录被祝福次数
			local num = role:getDayFlag("被祝福奖励限制")
			
			if num >= 20 then
				if DEBUG_MODE == 1 then
					print("今天被祝福次数已达到20次的限制")
				end
				return
			end
			
			local lv = body.lv
			local prize_pot = lv+50

			role:setAttr("pot",role:getAttr("pot")+prize_pot)
			RichPrint("main","你突然感到灵台清明，精神亦为之一振，内力自行运转，遍行奇经八脉。")
			PopText(body.content)
			PopText("潜能 +"..prize_pot)
			RichPrint("main","潜能 +"..prize_pot)
			role:setDayFlag("被祝福奖励限制",num + 1)
			if DEBUG_MODE == 1 then
				print("今天被祝福次数："..num + 1)
			end
		end
		self:__callback(eventName, params)
	end)
	FubenClient:connect()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/06 12:17:57
-- @desc 设置回调并链接服务器
function BaseMap:setCallBackAndConnect(func)
	-- add by XiaoZhiWei 2017/09/26 10:31:11 调试模式直接可以进入偶遇模式
	self:enterMap()
	if func then
		func()
	end
	if DEBUG_MODE == 1 then
		self:__connectWeb()
	elseif (User:getRole():getFlag("PVP战斗状态") ~= "离线模式" and Game:isOpenEncounter() == true and Map:getMapState("fb15") == MAP_STATE.COMPLETE and GetTime() - Helper:getDef(User:getRoleAttr("createTime"), GetTime()) > 3600 * 24) then
		-- add by XiaoZhiWei 2017/09/25 17:13:54 
		--[[
				是否通关开启偶遇;ouyuopen
				填0或者没填，通关方可开启，填1为，无需通关开启，填2为，通关后也不开启
		]]
		if ((self.ouyuopen == 0 or self.ouyuopen == nil) and User:getRole():isMapCompleted(self.id) == true) or self.ouyuopen == 1 then
			-- add by XiaoZhiWei 2017/06/16 17:05:38 只有该副本完成主线的情况下才能开启偶遇功能  离线模式不能链接服务器
			self:__connectWeb()
		else
			--@desc 从开启副本进入未开启副本后回调副本错误
			FubenClient:disconnect()
		end
	elseif User:getRoleAttr("role_is_cheat") == true then
		DataBase:setDataByString("MapPvp", "OFFLINE")
		User:getRole():setFlag("PVP战斗状态", "离线模式")
		PopText("由于你的数据异常，已经自动切换成江湖隐者模式！")
		FubenClient:disconnect()
	end
end

-- 进入副本
function BaseMap:enterMap()
	--@RefType [src.app.models.role.Role#Role]
	local role = User:getRole()
	local currTime = GetTime()
	local leaveTime = role:getFlag(self.id)
	self.isInMap = true
	self.__scheduleList = {}
	role:setFlag("当前位置","进入副本")

	role:setFlag("PVP活动状态","空闲中")
	role:setFlag("副本状态","空闲中")

	-------------------------------------------------------------------
	------------ 友盟接入
	if device.platform == "ios" then
		Mob.startLevel(self.index)
	end

	if PRINT_MODE == 1 then
		print("准备初始化地图")
	end

	if leaveTime and leaveTime ~= 0 then
		local useTime = currTime - leaveTime
		-- 地图刷新时间设置为5分钟
		if useTime >= MAP_REFRESH_INTERVAL then

			if PRINT_MODE == 1 then
				-- 初始化  （待测试）
				print("地图初始化成功")
			end

			self:setMapInfo()

			role:initMapRoomStates(self.id)
		else
			
		end
	else
		self:setMapInfo()
	end
	-- 记录当次所获得的物品
	self.__itemList = {}

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/19 17:57:38
-- @desc 检查是否有已离开的玩家信息缓存下来,有则去掉
function BaseMap:updateRoomWebRoles(roomId, userMap)
	if roomId == nil then
		return
	end
	userMap = Helper:getDef(userMap, {})
	local roleList = self:getRoomRoleList(roomId)
	if MapIsEmpty(roleList) then
		return
	end
	for i = #roleList, 1, -1 do
		local roleId = roleList[i]
		local role = self:getRole(roleId)
		if role.isFromWeb == true and userMap[role.id] == nil then
			self:removeRoomRole(roomId, role.id)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/25 11:12:41
-- @desc 加入玩家
function BaseMap:__addPlayerToRoom(roomId, userMap)
	if roomId == nil or MapIsEmpty(userMap) == true then
		return
	end	

	for userid,role in pairs(userMap) do
		-- self:getRole()
		if tonumber(userid) == User:getUserId() then
		else
			role.id = tostring(userid)

			role.canSee = 1
			if role.isWhiteList == 1 then
				role.canSee = false
			end
			
			if role.x_type == "denglong" then
				role.type = "item"
			else
				role.canCompete = 1
				role.type = "role"
			end
			if tonumber(userid) == nil then
			else
				role.isFromWeb = true
			end
			
			self:createRole(role)
			self:addRoomRole(roomId, userid, false)
		end
	end
	if MainControllLayer:isLayerRemoved("MapLayer") == false then
		MainControllLayer:getLayer("MapLayer"):delayRefreshMap() -- add by XiaoZhiWei 2017/05/25 20:24:36 刷新副本
	end
end


 -- 限时任务
function BaseMap:delayTaskUpdate()
	local currTime = GetTime()
	if self._delayTasks and #self._delayTasks > 0 then
		local needFresh = false
		local removeArray = {}
		for i = #self._delayTasks, 1, -1 do
			local task = self._delayTasks[i]
			if currTime >= task.overTime then
				task.func()
				needFresh = true
				table.remove(self._delayTasks, i)
			end

			-- if TEACHER_TASK_IS_OPEN == true then
			-- 	local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
			-- 	if TeacherTask:getTeacherTaskAttr("receiveTask") == 0 or type(TeacherTask:getTeacherTaskAttr("isAppoint")) == "table" or task.onlyId ~= TeacherTask:getTeacherTaskAttr("receiveTask").taskOId  then
			-- 		if task.conditions == "师门任务" then
			-- 			task.func()
			-- 			needFresh = true
			-- 			table.remove(self._delayTasks, i)
			-- 		end
			-- 	end
			-- else
			-- end
		end

		if needFresh == true and MainControllLayer:isLayerRemoved("MapLayer") == false then
			MainControllLayer:getLayer("MapLayer"):setNeedRefreshMap()
		end
	end
end

-- 限时任务
function BaseMap:InSertTaskToDelayTasks(_tag,overtime,_func,conditions,onlyId)
	local tab = {
		tag = _tag,
		overTime = overtime,
		func = _func
	}
	if conditions then
		tab.conditions = conditions 
	end
	if onlyId then
		tab.onlyId = onlyId
	end
	self._delayTasks[_tag] = tab
end

function BaseMap:removeTaskFromDelayTasks(_tag)
	if _tag == nil then
		return
	end
	if self._delayTasks[_tag] ~= nil then
		self._delayTasks[_tag] = nil
	end
end

function BaseMap:updateShenShuList(itemId, count)
	if itemId == nil then
		return
	end

	--负数代表神书送礼不需要处理，大于0代表收集神书
	if count < 0 then
		return
	end

	local ShenShuHelper = require("app.models.shenshu.shenshu")

	local role = User:getRole()

	if ShenShuHelper:checkIsInFindBook(role) == false then
		return
	end

	local isTrue = ShenShuHelper:findBook(role, itemId)

	if isTrue then
		ShenShuHelper:getHintText(itemId)
		print("--------------------removeTaskFromDelayTasks------------------------",itemId)
		self:removeTaskFromDelayTasks(itemId)--神书卡顿优化
	end
end

function BaseMap:addItemCount(itemId, count)
	if not itemId or not count or type(count) ~= "number" then
		assert(nil, "BaseMap:addItemCount(itemId, count) ->  参数错误")
	end
	self:updateShenShuList(itemId, count)
	--显示得到了什么，拿出了什么
	local itemAttr = Item:getOneItemByKey(itemId)
	if not itemAttr then
		error("获取itemAtter失败，itemId："..tostring(itemId))
	end
	--判断是否能获得物品，  7/22
	if not User:getRole():checkCanBuyThings(itemId,count) then
		return false
	end

	if not self.__itemList then
		self.__itemList = {}
	end
	local list = self.__itemList
	if list[itemId] then
		list[itemId] = count + list[itemId]
	else
		list[itemId] = count
	end

	return true
end

function BaseMap:removeRoomRole(roomId, roleId, isRefresh)
	if PRINT_MODE == 1 then
		print("BaseMap:removeRoomRole(roomId, roleId) roomId = "..tostring(roomId).."  roleId == "..tostring(roleId))
	end

	isRefresh = Helper:getDef(isRefresh, true)

	local room = self:getRoomById(roomId)
	if room.roleList then

		for i = #room.roleList, 1, -1 do
			local tRoleId = room.roleList[i]
			if tRoleId == roleId then
				if PRINT_MODE == 1 then
					print("移除房间"..tostring(roomId).."的角色"..tostring(roleId))
				end
				table.remove(room.roleList, i)
				break
			end
		end
	end

	MapPVPRoles._needRefresh = true -- add by XiaoZhiWei 2017/08/15 12:01:48 删除角色需要刷新一下江湖人士列表
	-- 添加角色后 判断整个房间的条件结果
	if isRefresh == true then
		self:doRoomConditionAndResult(roomId)
	end
end

function BaseMap:swapRoomRole(roomId, fromRoleId, toRoleId)
	if PRINT_MODE == 1 then
		print("BaseMap:swapRoomRole("..tostring(roomId)..", "..tostring(fromRoleId)..", "..tostring(toRoleId)..")")
	end

	local room = self:getRoomById(roomId)
	if room.roleList then

		for i = #room.roleList, 1, -1 do
			local tRoleId = room.roleList[i]
			if PRINT_MODE == 1 then
				print("fromRoleId = "..tostring(fromRoleId).."    tRoleId = "..tostring(tRoleId))
			end

			if tRoleId == fromRoleId then
				if PRINT_MODE == 1 then
					print("tRoleId = "..tRoleId..", fromRoleId = "..fromRoleId)
				end

				room.roleList[i] = toRoleId
				-- return
				break
			end
		end
	end

	MapPVPRoles._needRefresh = true -- add by XiaoZhiWei 2017/08/15 12:01:48 换人需要刷新一下江湖人士列表

	if Map:getMapVersionByMapId(self.id) == EDITOR_MAP_VERSION then
	else
		-- 添加角色后 判断整个房间的条件结果
		self:doRoomConditionAndResult(roomId)
	end
end

-- ["打开的箱子"] =
-- 		{
-- 			type = "item",
-- 			id = "打开的箱子",
-- 			name = "打开的箱子",
-- 			dsc = "这个一个打开的箱子, 里面好像放着什么",
-- 			canPickUp = false, -- 拾取
-- 			canUse = false, -- 使用
-- 			canExtract = true, -- 提取
-- 			canOpen = false, -- 打开
-- 			canPushIn = false, -- 能放入
-- 		},
-- 		["空的箱子"] =
-- 		{
-- 			type = "item",
-- 			id = "空的箱子",
-- 			name = "空的箱子",
-- 			dsc = "里面空空如也",
-- 			canPickUp = false, -- 拾取
-- 			canUse = false, -- 使用
-- 			canExtract = false, -- 提取
-- 			canOpen = false, -- 打开
-- 			canPushIn = false, -- 能放入
-- 		},

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/29 19:25:28
-- @desc 玩家杀人方法,killType 1战斗杀死，2道具杀死
function BaseMap:playerKillRole(roomId, currRole,killType)
	currRole = inherit({}, currRole)
	killType = Helper:getDef(killType, 1)
	local player = self:getPlayer()

	-- 玩家奖励处理
	if DEBUG_MODE == 1 then
		print("奖励处理")
		Helper:print_lua_table(currRole:getDropSchemeIdArray())
	end

	local rewardIds = currRole:getDropSchemeIdArray()
	if table.getn(rewardIds) > 0 then
		--@RefType [src.app.models.Record.Reward.ARewardRecord#ARewardRecord]
		local ARewardRecord = require("app.models.Record.Reward.ARewardRecord")

		local rewardGet =
			require("app.models.reward.OpenRewardGet"):create(
			player,
			rewardIds,
			ARewardRecord.RTYPE.KILL_NPC_DROP,
			"mapRewardArrayWithRewardSchemeArray",
			{
				mapid = self.id,
				npcid = currRole.id
			}
		)

		local checkList = {
			guhunyeguijiangli2 = true,
			guhunyeguijiangli1 = true
		}

		local flag = false

		rewardGet:doGetReward(
			function(rewardArray)
				for i, reward in ipairs(rewardArray) do
					if reward.type == "物品" then
						if PRINT_MODE == 1 then
							local item = Item:getOneItemByKey(reward.id)
							if item then
								local name = Helper:getDef(Item:getOneItemByKey(reward.id).name, "")
								local value = Helper:getDef(reward.value, 1)
								if name then
									PopText("[测试才能看见]: 得到物品 [" .. name .. "] x " .. reward.value)
								end
							end
						end
						if currRole.corpseReward == 1 then
							self:dropItem(self:getCurrRoomId(), reward.id, reward.value)
							if checkList[reward.id] == true then
								flag = true
							end
						else
							currRole:addItemCount(reward.id, reward.value)
						end
					elseif reward.type == "属性" then
						if type(player:getCHAttrName(reward.id)) == "string" then
							PopText("获得" .. player:getCHAttrName(reward.id) .. tostring(reward.value))
						end
						player:addAttr(reward.id, reward.value)
						self:richPrintText(player, reward.id, reward.value) -- 属性变化文本显示
					else
						error()
					end
				end
			end
		)
	end

	if currRole.corpseReward == 1 then
		if killType == 1 then
			if flag == true then
				RichPrint("main", "你将" .. currRole.name .. "击毙，却见" .. currRole.name .. "身体化作一道道黑烟，消散在这空气之中，原地只留下一块小小的石头。")
			else
				RichPrint("main", "你将" .. currRole.name .. "击毙，却见" .. currRole.name .. "身体化作一道道黑烟，消散在这空气之中。")
			end
		end
	end
	return self:__killRole(roomId, currRole)

end

-- 杀死人物相关
function BaseMap:__killRole(roomId, currRole)
	if PRINT_MODE == 1 then
		print("function BaseMap:__killRole(roomId, currRole)")
	end

	if currRole then
		if PRINT_MODE == 1 then
			print("currRole.withCorpse = "..tostring(currRole.withCorpse))
		end
	end

	if currRole.withCorpse == -1 then
		self:removeRoomRole(roomId, currRole.id) -- 当withCorpse为-1时，不生成尸体，移除原来的角色
		return
	end

	local items = currRole:getItems()

	-- 尸体的书箱, 将原角色书箱内的物品添加到尸体物品列表内
	local bookItems = currRole:getBookItems()
	for k,v in pairs(bookItems) do
		table.insert(items, v)
	end

	-- add by XiaoZhiWei 2017/04/08 16:38:17 尸体的秘籍残页也需要添加进去
	local zhaoShuXiangItems = currRole:getZhaoShuXiangItems()
	for k,v in pairs(zhaoShuXiangItems) do
		table.insert(items, v)
	end

	--@desc 把npc 药囊里的东西也加入尸体
	local medicinalItems = currRole:getAttr("medicinalBox")
	if not MapIsEmpty(medicinalItems) then
		for k,v in pairs(medicinalItems) do
			table.insert(items, v)
		end
	end

	--@desc 把npc 冶炼箱里的东西也加入尸体
	local smeltBox = currRole:getAttr("smeltBox")
	if not MapIsEmpty(smeltBox) then
		for k,v in pairs(smeltBox) do
			table.insert(items, v)
		end
	end

	local corpseDsc
	corpseDsc = currRole:getHeCall().."生前是"..currRole.name.."。\n\n"
	corpseDsc = corpseDsc.."然而，"..currRole:getHeCall().."已经死了，只剩下一具尸体静静的躺在这里。\n"
	if currRole.killedBySkillName then
		corpseDsc = corpseDsc.."从尸体上的累累伤痕来看，分明是精通“"..currRole.killedBySkillName.."”绝技的江湖高手所为。\n\n"
	end
	if MapIsEmpty(items) == false then
		corpseDsc = corpseDsc..currRole:getHeCall().."的遗物有："
		for i, roleItem in ipairs(items) do
			local item = Item:getOneItemByKey(roleItem.itemId)
			roleItem.name = item.name
			corpseDsc = corpseDsc.."\n"..tostring(item.name).." X"..tostring(roleItem.count)
		end
	end

	local corpse = {
		type = "item",
		subType = "尸体",
		aliveId = currRole.id, -- 活着的时候的id
		aliveName = currRole.name, -- 活着的时候的名字
		aliveDsc = currRole.dsc, -- 描述
		killedBySkillName = currRole.killedBySkillName, -- 死法
		id = "尸体"..tostring(Helper:getOnlyId()),
		name = "尸体",
		dsc = corpseDsc,
		items = items, -- 尸体里面的物品
		sex = currRole.sex,
		canSee = 1,
	}

	--@desc 新旧副本区分
	if Map:getMapVersionByMapId(self.id) == EDITOR_MAP_VERSION then
		corpse = inherit({
			operations = {
				{
					isEnable = 1,
					condOperator = [[and]],
					results = {{arg1 = [[提取]]}},
					operationButton = [[提取]],
					faildResults = {},
					isVisible = 1,
					conditions = {},
					id = "extractCorpse"
				},
			}
		}, corpse)
	else
		corpse =
			inherit(
			{
				canPickUp = false, -- 拾取
				canUse = false, -- 使用
				canExtract = true, -- 提取
				canOpen = false, -- 打开
				canPushIn = false -- 能放入
			},
			corpse
		)

		if currRole.corpseReward == 1 then
			corpse.canSee = false
		end
		
		-- 是否杀的是周年庆任务人物 add by ZhangShengTang 2017/06/14 12:19:13
		local Anniversary = require("app.models.Anniversary.Anniversary")
		Anniversary:killNpc(currRole.id)
	end

	self:createRole(corpse) -- 创建尸体
	self:swapRoomRole(roomId, currRole.id, corpse.id) -- 替换掉活着的人
end

-- 搜刮尸体
function BaseMap:__pickUpCorpse(roomId, currRole, func)
	local User = require("app.models.user.User")
	local player = self:getPlayer()

	local MapBagLayer = require("app.views.layer.MapLayer.MapBagLayer")
	local mapBagLayer = MapBagLayer:getInstance()
	mapBagLayer:show()
	-- self:addChild(mapBagLayer)
	mapBagLayer:setRoles(player, currRole, function()
		local corpseDsc
		local items = currRole:getItems()
		corpseDsc = currRole:getHeCall().."生前是"..currRole.aliveName.."。\n\n"
		corpseDsc = corpseDsc.."然而，"..currRole:getHeCall().."已经死了，只剩下一具尸体静静的躺在这里。\n"
		if currRole.killedBySkillName then
			corpseDsc = corpseDsc.."从尸体上的累累伤痕来看，分明是精通“"..currRole.killedBySkillName.."”绝技的江湖高手所为。\n\n"
		end

		if MapIsEmpty(items) == false then
			corpseDsc = corpseDsc..currRole:getHeCall().."的遗物有："
			local length = #items
			if length > 6 then
				length = 6
			end
			for i=1, length do
				local roleItem = items[i]
				local item = Item:getOneItemByKey(roleItem.itemId)
				roleItem.name = item.name
				corpseDsc = corpseDsc.."\n"..tostring(item.name).." X"..tostring(roleItem.count)
			end
		end
		local corpse =
		{
			type = "item",
			subType = "尸体",
			aliveId = currRole.aliveId, -- 活着的时候的id
			aliveName = currRole.aliveName, -- 活着的时候的名字
			aliveDsc = currRole.aliveDsc, -- 描述
			killedBySkillName = currRole.killedBySkillName, -- 死法
			id = "尸体"..tostring(Helper:getOnlyId()),
			name = "尸体",
			dsc = corpseDsc,
			canSee = true, -- 可见
			canPickUp = false, -- 拾取
			canUse = false, -- 使用
			canExtract = true, -- 提取
			canOpen = false, -- 打开
			canPushIn = false, -- 能放入
			items = currRole:getItems(), -- 尸体里面的物品
			sex = currRole.sex
		}
		print(currRole.aliveId,currRole.aliveName,currRole.aliveDsc)
		self:createRole(corpse) -- 创建尸体
		self:swapRoomRole(roomId, currRole.id, corpse.id) -- 替换掉活着的人
		if func then
			func()
		end
	end)
end

-- 箱子相关
function BaseMap:__boxOpen(roomId, currRole, item) -- 打开箱子
	local function getitems(role)
		local itemNameList
		local items = {}
		if role.include then
			if PRINT_MODE == 1 then
				print("role.include = "..role.include)
			end
			itemNameList = string.split(role.include, ";")
		end
		if itemNameList then
			for i, itemId in ipairs(itemNameList) do
				local item = Item:getOneItemByKey(itemId)
				table.insert(items, item)
			end
		else
			assert(itemNameList, "物品名字列表不能为空....!!!!")
		end
		return items
	end

	local baseBox = Item:getOneItemByKey(currRole.baseId)

	local items = getitems(baseBox) -- 获得箱子里面的物品列表

	local boxDsc = "这是一个打开的箱子。\n里面有:"
	for i, item in ipairs(items) do
		boxDsc = boxDsc.."\n"..item.name
	end

	local name = "打开的"..baseBox.name

	local openedBox =
	{
		type = "item",
		subType = "打开的箱子",
		id = name..tostring(Helper:getOnlyId()),
		baseId = currRole.baseId,
		name = name,
		dsc = boxDsc,
		canSee = true, -- 可见
		canPickUp = false, -- 拾取
		canUse = false, -- 使用
		canExtract = true, -- 提取
		canOpen = false, -- 打开
		canPushIn = false, -- 能放入
		items = items -- 箱子里面的物品列表
	}
	self:createRole(openedBox) -- 创建打开的箱子
	self:swapRoomRole(roomId, currRole.id, openedBox.id) -- 替换掉未打开的箱子
end

function BaseMap:__boxPickUp(roomId, currRole, item) -- 拾取箱子里面的东西
	local User = require("app.models.user.User")
	local player = User:getRole()

	-- self:removeRoomRole(roomId, currRole.id)
	if currRole.items and #currRole.items > 0 then
		for i, item in ipairs(currRole.items) do

			--添加是否能获得物品的判断   7/22
			if not self:addItemCount(item.id, 1) then
				return
			end

			PopText("获得"..item.name)
			RichPrint("获得"..item.name)  -- 7/31
			player:addItemCount(item.id, 1)
			Statistics:recordItemCount(item.id, 1) -- 用于统计
		end
	end

	local baseBox = Item:getOneItemByKey(currRole.baseId)
	local name = "空的"..baseBox.name

	local openedBox =
	{
		type = "item",
		subType = "打开的箱子",
		id = name..tostring(Helper:getOnlyId()),
		name = name,
		dsc = "里面空空的,什么也没有",
		canSee = true, -- 可见
		canPickUp = false, -- 拾取
		canUse = false, -- 使用
		canExtract = false, -- 提取
		canOpen = false, -- 打开
		canPushIn = false, -- 能放入
		items = items -- 箱子里面的物品列表
	}
	self:createRole(openedBox) -- 创建打开的箱子
	self:swapRoomRole(roomId, currRole.id, openedBox.id) -- 替换掉未打开的箱子
end

function BaseMap:getRoomMap()
	return self.room
end

function BaseMap:getFlag(name)
	if not name then
		return
	end
	if self._flags == nil then
		self._flags = {}
	end
	if self._flags[name] == nil then
		self._flags[name] = 0
	end
	return self._flags[name]
end

function BaseMap:setFlag(name, value)
	if self._flags == nil then
		self._flags = {}
	end
	if self._flags[name] == nil then
		self._flags[name] = 0
	end
	if PRINT_MODE == 1 then
		print("flagName = "..tostring(name))
		print("flagValue = "..tostring(value))
	end
	self._flags[name] = value
end

function BaseMap:setMapStatusTags(tagId,value)
	self.__mapStatusTagsService:setStatusTags(tagId,value)
end

function BaseMap:getMapStatusTags(tagId)
	return self.__mapStatusTagsService:getStatusTags(tagId)
end

function BaseMap:getRoomById(roomId)
	return assert(self.room[roomId],"roomId ========".. tostring(roomId))
end

-- 获取地图完成奖励
function BaseMap:getMapCompleteAward(index)
	local completeAward = self.completeAwards[index]

	for k, award in pairs(completeAward) do
		self:__playerGetAward(award)
	end
end

-- 现在状态能否完成地图
function BaseMap:getCanCompleteConditionIndex()
	assert(self.completeConditions, "self.completeConditions = "..tostring(self.completeConditions))

	for i, completeCondition in ipairs(self.completeConditions) do
		local flagValue = self:getFlag(completeCondition.name)
		-- if PRINT_MODE == 1 then
		-- 	print("completeCondition.name = "..tostring(completeCondition.name))
		-- 	print("completeCondition.value = "..tostring(completeCondition.value))
		-- 	print("flagValue = "..tostring(flagValue))
		-- end
		if flagValue and flagValue == completeCondition.value then
			return i
		end
	end
	return 0
end

-- 设置地图为完成状态
function BaseMap:setCompleted()
	self._isCompleted = true
end

-- 判断地图是否完成
function BaseMap:isCompleted()
	if self._isCompleted == true then
		return true
	end
	return false
end

-- 获取奖励文本
function BaseMap:getAwardDesc(index)
	local player = User:getRole()
	local str = ""
	local completeAward = self.completeAwards[index]

	for k, award in pairs(completeAward) do
		if award.type == "属性" and player:getCHAttrName(award.name) then
			str = str..tostring(player:getCHAttrName(award.name))..tostring(award.value).."		"
		elseif award.type == "物品" then
			local item = Item:getOneItemByKey(award.name)
			str = str..tostring(item.name)..tostring(award.value)..tostring(item.unit).."		"
		end
	end
	if PRINT_MODE == 1 then
		print(str)
	end
	return str
end

-- 玩家获得奖励方法
function BaseMap:__playerGetAward(award)
	local player = User:getRole()

	if award.type == "属性" then
		PopText("获得"..award.value..tostring(player:getCHAttrName(award.name)))
		-- RichPrint("main","获得"..award.value.."点"..tostring(player:getCHAttrName(award.name)))
		player:addAttr(award.name, award.value)
		self:richPrintText(player, award.name, award.value) -- 属性变化文本显示
	elseif award.type == "物品" then
		--增加对能否获取物品的判断
		if not player:addItemCount(award.name, award.value) then
			return
		end
		PopText("获得"..award.value.."个"..tostring(Item:getOneItemByKey(award.name).name))
		-- RichPrint("main","获得"..award.value.."个"..tostring(Item:getOneItemByKey(award.name).name))
		Statistics:recordItemCount(award.name, tonumber(award.value)) -- 统计
	end
end

-- add by XiaoZhiWei 2017/11/30 15:43:21 条件优化
local ConditionMap = require("app.models.map.ConditionMap")
-- 判断条件是否为真
function BaseMap:__conditionIsTrue(condition, environment)
	if condition == nil or condition.arg1 == nil then
		return true
	end
	
	if Map:getMapVersionByMapId(self.id)== EDITOR_MAP_VERSION then
		print("开始判断条件 ：".. condition.arg1)
	end
	
	local player = self:getPlayer()
	local currRole = environment.currRole
	local ret = nil
	if ConditionMap[condition.arg1] ~= nil then
		ret = ConditionMap[condition.arg1](self, condition, environment, player, currRole)
	else
		ret = ConditionMap["default"](self, condition, environment, player, currRole)
	end
	-- local ret = switch(condition.arg1, ConditionMap, self, condition, environment, player, currRole)
	
	if Map:getMapVersionByMapId(self.id)== EDITOR_MAP_VERSION then
		print("条件 ".. condition.arg1 .. "判断结果 ："..tostring(ret))
	end

	return Helper:getDef(ret, false) 
end

function BaseMap:__conditionsIsTrue(conditions, conditionRelation, environment)
	if conditions == nil or #conditions == 0 then
		-- if PRINT_MODE == 1 then
			print("条件为空, 直接成立")
		-- end
		return true
	end

	if conditionRelation == "or" then
		for k, condition in ipairs(conditions) do
			if self:__conditionIsTrue(condition, environment) then
				return true
			end
		end
		return false
	elseif conditionRelation == "and" then
		for k, condition in ipairs(conditions) do
			if self:__conditionIsTrue(condition, environment) == false then
				return false
			else
				if PRINT_MODE == 1 then
					print("condition.arg1 = "..tostring(condition.arg1))
				end
			end
		end
		return true
	else
		for k, condition in ipairs(conditions) do
			if self:__conditionIsTrue(condition, environment) then
				return true
			end
		end
		return false
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/10 12:18:32
-- @desc 直线任务阅历奖励限制
function BaseMap:__recountYueLiReward(role, value)
	if Helper:checkParamsError("BaseMap:__recountYueLiReward(role, value)", 2, role, "table", value, "number") == true then
		return 0
	end
	-- add by XiaoZhiWei 2017/03/10 12:20:47 每个副本递增10点 上限值
	local countLimit = (tonumber(self.index) -1 ) * 10 + 200
	local dayCount = role:getDayFlag(tostring(self.id).."_yueli")
	value = Helper:getRange(math.ceil(math.min(value, countLimit - dayCount)), 0)

	role:setDayFlag(tostring(self.id).."_yueli", dayCount + value)
	return value
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/10 10:14:37
-- @desc 支线任务 奖励上限控制
function BaseMap:__recountGetReward(role, resultId, value, countLimit, levelLimit)
	if Helper:checkParamsError("BaseMap:__recountGetReward(role, resultId, value, countLimit, levelLimit)", 5, role, "table", resultId, "string", value, "number", countLimit, "number", levelLimit, "number") == true then
		return value
	end

	-- 公式
	--[[
		达到次数后 收益逐次递减,每次减少百分之20
		if 次数 <= 5 then
		return 配置的奖励
		else
		return 配置的奖励 * math.max ((1 - (次数 - 5) * 20%) , 0)
		end

		if 人物等级 - 任务等级 * 2 <= 600 then
			return 配置的奖励
		else
			return 配置的奖励 * math.max ((1 - (math.floor (人物等级 - 任务等级 * 2 - 600 )/200) * 50%) , 0.5)
		end
	]]
	local dayCount = role:getDayFlag(tostring(self.id).."_"..resultId)
	if dayCount < countLimit then
	else
		value = value * math.max ((1 - ((dayCount + 1) - countLimit) * 0.2) , 0)
	end

	if role:getLv() - levelLimit * 2 <= 600 then
	else
		value = value * math.max ((1 - (math.floor (role:getLv() - levelLimit * 2 - 600)/200) * 0.5) , 0.5)
	end


	role:setDayFlag(tostring(self.id).."_"..resultId, dayCount + 1) -- add by XiaoZhiWei 2017/03/10 12:22:42 次数加1
	return Helper:getRange(math.ceil(value), 0)  -- add by XiaoZhiWei 2017/03/10 11:53:22 最小值取0
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/10 14:38:40
-- @desc 需要控制的任务收益属性 (仅限 玩家属性变化 结果使用)
function BaseMap:checkCanGetReward(result, role)
	if MapIsEmpty(result) == true or MapIsEmpty(role) == true then
		return result
	end
	local addAttr = result.arg2
	local checkTab =   -- add by XiaoZhiWei 2017/03/10 14:51:57 需检查的列表
	{
		["exp"] = true,
		["pot"] = true,
		["money"] = true
	}
	local ret = result.arg3
	if checkTab[addAttr] == true then
		ret = self:__recountGetReward(role, result.id, tonumber(result.arg3), result.countLimit, result.level)
		end

	-- add by XiaoZhiWei 2017/03/10 14:58:39 阅历 每天有获取上限
	if addAttr == "yueli" then
		ret = self:__recountYueLiReward(role, result.arg3)
	end

	if ret == 0 then
		DoFuncWithInterval("BaseMap.checkCanGetReward",
		function()
			PopText("你今天获得的收益已达上限")
		end, 1)
		end
	return ret
end

function BaseMap:doResult(result, environment)
	if self.__MapLayer ==  nil then
		-- self.__MapLayer = require("app.views.layer.ControllLayer"):getInstance():getLayer("MapLayer")
		return
	end

	-- 每次执行结果的时候, 设置副本需要刷新
	self.__MapLayer:setNeedRefreshMap()

	if PRINT_MODE == 1 then
		print("BaseMap:doResult(result, environment)")
	end
	if result == nil or result.arg1 == nil then
		return
	end

	if environment.mapLayer == nil then
		-- local ControllLayer = require("app.views.layer.ControllLayer")
		environment.mapLayer = self.__MapLayer
	end

	-- local User = require("app.models.user.User")
	-- local player = User:getRole()
	-- local currRole = environment.currRole

	if PRINT_MODE == 1 then
		print("environment.operation = "..tostring(environment.operation))
		print("environment.currRoomId = "..tostring(environment.currRoomId))	
		print("environment.roomId = "..tostring(environment.roomId))
		print("result.arg1 = "..tostring(result.arg1)..", result.arg2 = "..tostring(result.arg2)..", result.arg3 = "..tostring(result.arg3))
	end

	if self.doResultFun[result.arg1] then
		local func = self.doResultFun[result.arg1]
		return func(self,result,environment)
	else
		--35章后新添加的noCurrRole系列的结果在这里
		assert(false, "未知结果 resultType = "..tostring(result.arg1)..", resultName = "..tostring(result.arg2))
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 18:30:30
-- @desc 设置副本概率事件
function BaseMap:setMapProbabilityResult(name, pType, percent, resultId, failRstId, timesLimit, minTimes, exceptList, environment)
	if PRINT_MODE == 1 then
		print("BaseMap:setMapProbabilityResult(name, pType, percent, resultId, failRstId, timesLimit, minTimes, exceptList, environment)", name, pType, percent, resultId, failRstId, timesLimit, minTimes, exceptList, environment)
	end
	if name == nil or type(percent) ~= "number" or resultId == nil then
		return
	end
	pType = Helper:getDef(pType, "进入房间")
	self.__ProResultInfo = Helper:getDef(self.__ProResultInfo, {})
	self.__ProResultInfo[name] = {
		pType = pType,
		percent = percent,
		resultId = resultId,
		failRstId = failRstId,
		timesLimit = timesLimit,
		minTimes = minTimes,
		exceptList = exceptList,
		environment = environment,
		succTimes = 0,
		failTImes = 0,
		ndRoomList = {fb201_64 = true,fb201_65 = true,b201_67 = true,fb201_72 = true,fb201_80 = true}
	}
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 11:49:57
-- @desc 更新副本概率事件 actionType add/update 
function BaseMap:updateMapProbabilityResult(actionType, name, key, value)
	if name == nil or key == nil or actionType == nil then
		return
	end
	self.__ProResultInfo = Helper:getDef(self.__ProResultInfo, {})
	self.__ProResultInfo[name] = Helper:getDef(self.__ProResultInfo[name], {})
	if actionType == "update" then
		self.__ProResultInfo[name][key] = value
	else
		-- add by XiaoZhiWei 2017/08/31 17:12:10 如果类型不都是数字  还是不允许添加
		if type(self.__ProResultInfo[name][key]) == "number" and type(value) == "number" then
			self.__ProResultInfo[name][key] = self.__ProResultInfo[name][key] + value
		else
			self.__ProResultInfo[name][key] = value
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 11:46:48
-- @desc 取消副本概率事件
function BaseMap:cancelMapProbabilityResult(name)
	if name == nil then
		return
	end
	self.__ProResultInfo = Helper:getDef(self.__ProResultInfo,{})
	self.__ProResultInfo[name] = {}
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 18:36:46
-- @desc 刷新副本概率事件
function BaseMap:refreshMapProbabilityFunc(actionType)
	local npcList = self:getFollowInfoByKey("npcList")
	local proInfoMap = Helper:getDef(self.__ProResultInfo, {})

	local function succFunc(proInfo, resultId, environment, succTimes)
		local role = User:getRole()
		if role:getFlag("当前中元任务") == "押送任务" then
			local needReturn = true
			-- add by XiaoZhiWei 2017/08/31 21:06:49 押送任务的时候需要判断一下队伍中是否存在一个 普通的鬼 如果不存在则无法触发成功方法
			for i,v in ipairs(npcList) do
				if v == "yasongrenwu1" then
					needReturn = false
					break
				end
			end

			if needReturn == true then
				return
			end
		else
		end
		if environment == nil then
			print("****************************environment is nil ，需要注意一下***************************")
			return 
		end
		environment.currRoomId = self:getCurrRoomId()
		if resultId ~= nil then
			self:doNoRoleResults(tostring(resultId), environment)
		end
		proInfo.succTimes = succTimes + 1
		proInfo.failTImes = 0
	end

	if MapIsEmpty(proInfoMap) == true then
	else
		for k,proInfo in pairs(proInfoMap) do
			print("proInfo.pType = ", proInfo.pType, actionType)
			if proInfo.pType ~= actionType then
			else
				if MapIsEmpty(proInfo) == true then
				else
					local percent, resultId, failRstId, timesLimit, minTimes, exceptList, environment, succTimes, failTImes = Helper:getDef(proInfo.percent, 0), proInfo.resultId, proInfo.failRstId, proInfo.timesLimit, proInfo.minTimes, Helper:getDef(proInfo.exceptList,{}), proInfo.environment, Helper:getDef(proInfo.succTimes, 0), Helper:getDef(proInfo.failTImes, 0)
					print("************查看随机事件最小触发概率*********************",k,failTImes,minTimes)
					if exceptList[self:getCurrRoomId()] == true then
						return
					-- elseif proInfo.exceptList[self:getCurrRoomId()] == true then
					-- 	return
					elseif type(timesLimit) == "number" and succTimes >= timesLimit then -- add by XiaoZhiWei 2017/08/30 19:36:39 必定不触发 上限
					elseif type(minTimes) == "number" and failTImes > 0 and failTImes % minTimes == 0 then -- add by XiaoZhiWei 2017/08/30 19:36:22 必定触发 保底
						succFunc(proInfo, resultId, environment, succTimes)
						if actionType == "离开房间" then
							print("**************************阻止玩家移动************************",failTImes,failTImes,tostring(failTImes % minTimes == 0))
							return "阻止玩家移动"
						end
						return
					else
						local random = math.random(1, 100) * 1000
						local percent = Helper:getDef(proInfo.percent, 0) * 1000
						if random < percent then
							succFunc(proInfo, resultId, environment, succTimes)
							if actionType == "离开房间" then
								print("**************************阻止玩家移动************************",random,percent)
								return "阻止玩家移动"
							end
							return
						else
							proInfo.failTImes = failTImes + 1
						end
					end
					if failRstId ~= nil then
						self:doNoRoleResults(tostring(failRstId), environment)
					end
				end
			end
		end
	end
end

--@desc: 设置需要轮询的方法
--@author:Liang SongQiang
--@time:2018-01-12 21:39:17
--@func:执行函数，执行时定时器会传入此定时器的tag
--@interval: 间隔时间，默认为0.1
--@delay: 是否延迟执行，默认为立即执行
--@count: 执行次数，默认为0，无限执行
function BaseMap:setSchedule( func,interval,delay,count )
	if type(func) ~= "function" then
		assert(false,"arg1 not a function.")
		return
	end
	local tag = self:__pushCustomSchedule({
		--@desc 延迟执行的时间
		delay = delay,
		--@desc 间隔时间
		interval = interval,
		--@desc 执行次数，默认为0，表示无限执行
		count = count,
		--@desc 已执行次数
		actionCount = 0,
		--@desc 上一次的执行时间
		actionTime = GetTime(),
		--@desc 是否暂停
		isPause = false,
		--@desc 要执行的方法逻辑
		func = func
	})
	return tag
end

--@desc: 把要定时执行的代码结构放入轮询列表
--@author:Liang SongQiang
--@time:2018-01-12 21:36:28
--@scheduleTb: 定时执行的代码结构
function BaseMap:__pushCustomSchedule(scheduleTb)
	if scheduleTb.interval == nil then
		scheduleTb.interval = 1
	end
	
	if scheduleTb.delay == nil then
		scheduleTb.delay = 0
	end

	if scheduleTb.isPause == nil then
		scheduleTb.isPause = false
	end
	
	if scheduleTb.func == nil then
		assert(false,"没有运行逻辑，请检查代码！")
	end
	
	if scheduleTb.count == nil then
		scheduleTb.count = 0
	end
	
	local tag = "Loop_"..Helper:getOnlyId()

	self.__scheduleList[tag] = scheduleTb
	
	return tag
end

--@desc: 暂停指定定时器
--@author:Liang SongQiang
--@time:2018-01-13 14:11:22
--@tag: 定时器的tag
function BaseMap:pauseSchedule( tag )
	local structure = self.__scheduleList[tag]
	if structure ~= nil then
		structure.isPause = true
	else
		if DEBUG_MODE == 1 then
			assert(false,"this structure not in __scheduleList，check!!!")
		end
	end
end

--@desc: 恢复指定定时器
--@author:Liang SongQiang
--@time:2018-01-13 14:11:22
--@tag: 定时器的tag
function BaseMap:resumeSchedule( tag )
	local structure = self.__scheduleList[tag]
	if structure ~= nil then
		structure.isPause = false
	else
		if DEBUG_MODE == 1 then
			assert(false,"this structure not in __scheduleList，check!!!")
		end
	end
end

--@desc: 从轮询列表中移除
--@author:Liang SongQiang
--@time:2018-01-12 21:34:05
--@tag: 标记
function BaseMap:unSchedule( tag )
	self.__scheduleList[tag] = nil
	return
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/29 11:01:49
-- @desc 获取轮训列表
function BaseMap:__getScheduleList()
	return Helper:getDef(self.__scheduleList, {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/29 10:54:57
-- @desc 轮询调度方法
function BaseMap:scheduleFunc(ft)
	local scheduleList = self:__getScheduleList()

	if MapIsEmpty(scheduleList) then
		return
	end
	
	for tag,structure in pairs(self.__scheduleList) do
		if structure.isPause == false then
			local nowTime = GetTime()
			local intervalTime = nowTime - structure.actionTime

			local isRun = false
			if structure.delay == 0 and structure.actionCount == 0 then
				isRun = true
			else
				if intervalTime >= structure.delay then
					if structure.delay ~= 0 then
						structure.delay = 0
					end
					
					if intervalTime >= structure.interval then
						isRun = true
					end
				end
			end


			if isRun then
				structure.actionTime = nowTime
				structure.func(tag)
				structure.actionCount = structure.actionCount + 1
				if structure.count ~= 0 then
					if structure.actionCount == structure.count then
						self:unSchedule(tag)
					end
				end
			end

		end
	end

end

function BaseMap:comingAfterBoss_changeDistacne( delta , bossName , environment  )
	if self.comingAfterBoss == nil or self.comingAfterBoss.status == "over" then
		return false
	end

	local dec_texts = {
		[0] = [[...]],
		[[你差一点就能追到$b了，现在他又和你拉开到了五丈距离。]],
		[[脚步声越来越远了，你和$b的距离大约在十丈左右。]],
		[[清晰的脚步声慢慢地变模糊了，你放眼望去，你离他大概十五丈左右。]],
		[[$b猛的一跃，与你的距离又拉开了数丈！]],
		[[脚步声时隐时现，$b的背影在你眼中慢慢变小，他已经慢慢远去了。]],
		[[现在你已经完全听不到脚步声了，但$b还在你的视线之中，距离已有百丈之余！]],
		[[$b的身影已经渐渐消失了，他就快脱离你的视线之外了，快加把力赶上去啊！]],
		[[$b已经离开你的视线之外了，要追上他相当困难了。]],
		[[你已经失去$b有一段时间了，你恐怕已经追不上他了。]],
		[[你已经很久没察觉到$b的动静了，你可能已经跟丢了！]],
		[[不要再追了，你已经跟丢了$b。]]
	}

	local inc_texts = {
		[0] = [[你已经追上$b了！]],
		[[快追上去，你和他已经近在咫尺了！]],
		[[$b就在你的前方十丈开外。快！追上去！]],
		[[你看着$b越来越清晰的背影，目测你与他之间的距离只有二十丈了！]],
		[[$b的脚步声越来越清晰，你与他之间的距离也越来越近了！]],
		[[你已经完全看到了$b的背影，快点追上他！]],
		[[你眼中的黑点越来越大，你已经可以隐约看到$b的背影了！]],
		[[你的眼中出现了一个移动的黑点，那就是$b，快一点，追上他！]],
		[[你似乎能够隐隐约约地看到一个小黑点在移动，但是不是特别清晰，那应该就是$b。]],
		[[你的耳旁隐约传来一阵轻微的脚步声，相信$b就在不远处！]],
		[[你运足功力疾奔，虽然还没有看到$b的身影，但应该是靠近了一些。]],
		[[...]]
	}

	self.comingAfterBoss.currSteps = self.comingAfterBoss.currSteps + delta
	print( "comingAfterBoss_changeDistacne|||| bossName= " .. bossName .. " delta = " .. delta .. "  curr=" .. self.comingAfterBoss.currSteps )

	if bossName ~= nil then
		self.comingAfterBoss.bossName = bossName
	end

	if self.comingAfterBoss.bossName == nil or self.comingAfterBoss.bossName == "" then
		self.comingAfterBoss.bossName = bossName
	end

	if delta < 0 then

		if self.comingAfterBoss.currSteps >= 0 then
			local text = inc_texts[ self.comingAfterBoss.currSteps ]
			text = string.gsub( text , "$b" , self.comingAfterBoss.bossName )
			RichPrint("main", "GRN"..text)
		end

		if self.comingAfterBoss.currSteps <= 0 then
			local results = self.comingAfterBoss.succResult
			self.comingAfterBoss.status = "over"

			if self.comingAfterBoss.delayFuncHandle ~= nil then
				environment.mapLayer:stopActionByTag( self.comingAfterBoss.delayFuncHandle )
				self.comingAfterBoss.delayFuncHandle = nil
			end
			self.comingAfterBoss = nil

			self:doNoRoleResults( results , environment )

			print( "comingAfterBoss_changeDistacne successful" )
			return false
		end

	elseif delta > 0 then

		if self.comingAfterBoss.currSteps > self.comingAfterBoss.failedSteps then
			local text = "不要再追了，你已经跟丢了$b。"
			text = string.gsub( text , "$b" , self.comingAfterBoss.bossName )
			RichPrint("main", "RED"..text)
		elseif self.comingAfterBoss.currSteps <= #dec_texts then
			local text = dec_texts[ self.comingAfterBoss.currSteps ]
			text = string.gsub( text , "$b" , self.comingAfterBoss.bossName )
			RichPrint("main", "RED"..text)
		end

		if self.comingAfterBoss.currSteps > self.comingAfterBoss.failedSteps then
			self.comingAfterBoss.status = "failed"
			--self:doNoRoleResults( self.comingAfterBoss.failedResult , environment )

			print( "comingAfterBoss_changeDistacne failed" )

			--self.comingAfterBoss = nil
			return false
		end
	else
		--没变化
	end

	return true
end

function BaseMap:doNoRoleResults( results_str , environment )
	-- local Map = require("app.models.map.Map")

	local MapConditions = Map:getMapRoleCondition(self.id)

	print( "doNoRoleResults " .. tostring( results_str ) )

	if results_str == nil or results_str == "" then
		return
	end

	if MapConditions == nil then
		assert( false , "没有找到结果 getMapRoleCondition "..self.id )
		return
	end

	local resultStrs = string.split( results_str , ";" )

	print( "resultStrs count= " .. #resultStrs )

	local retList = {}
	for i,result_str in ipairs(resultStrs) do

		result_str = string.gsub( result_str , " " , "" )--去除空格

		if result_str ~= nil and result_str ~= "" then --and result_str ~= "nil" then

			local result = MapConditions[ "rlt_"..result_str ]

			if result == nil then
				assert(false, "未知结果 = ("..result_str .. ")" )
				return
			end
			local ret = self:doResult( result , environment )
			if ret then
				if type( ret ) == "table" then
					for k, v in pairs(ret) do
						retList[k] = v
					end
				else
					retList[ret] = environment.currRole
				end
			end
		end
	end
	return retList

end

function BaseMap:doResults(results, environment)
	local retList = {}
	for i=1, #results do
		local result = results[i]
		local ret = self:doResult(result, environment)
		if ret then
			if type( ret ) == "table" then
				for k, v in pairs(ret) do
					retList[k] = v
				end
			else
				retList[ret] = environment.currRole
			end
		end
	end
	return retList
end

function BaseMap:doConditionAndResult(conditionAndResults, environment)
	if PRINT_MODE == 1 then
		print("function BaseMap:doConditionAndResult(conditionAndResults, environment)")
	end
	if conditionAndResults == nil then
		return {}
	end
	if environment == nil then
		environment = {}
	end

	local conditionAndResultIndex = 0

	local retList = {}
	local roomStates = {}
	if environment.currRoomId then
		roomStates = User:getRole():getMapRoomState(self.id, environment.currRoomId)
	end


	local currRole = environment.currRole
	-- 判断NPC是否被禁用 如果是玩家,也不需要判断条件结果
	if currRole.isForbidden == true or currRole.isFromWeb == true then
		return retList
	end

	if PRINT_MODE == 1 then
		-- 判断仇恨 主动攻击玩家
		print(MapIsEmpty(roomStates))
		print("类型 = "..tostring(currRole.type))
	end
	if not MapIsEmpty(roomStates) and currRole and currRole.type == "role" and environment.operation ~= "杀死" and environment.operation ~= "切磋" then
		if PRINT_MODE == 1 then
			print("开始判断玩家副本房间标记")
		end
		for i,v in ipairs(roomStates) do
			if PRINT_MODE == 1 then
				-- 拥有队伍仇恨标记
				print("标记"..i.." = "..v)
				print("npc id = "..tostring(currRole.id))
				print("npc队伍 = "..tostring(currRole.teamMark))
			end
			if v == currRole.teamMark then
				self:doResult({arg1 = "攻击玩家"}, environment)
				break
			end
		end
	end
	
	do
		--@desc 入侵战斗的判断
		local role = User:getRole()
		if self.mid and self.mid ~= role:getHouseId() and currRole.fightMark == true then
			self:doResult({arg1 = "入侵战斗"}, environment)
		end	
	end

	for k, conditionAndResult in ipairs(conditionAndResults) do
		conditionAndResultIndex = conditionAndResultIndex + 1
		if PRINT_MODE == 1 then
			print("开始判断第 "..tostring(conditionAndResultIndex).." 个条件:")
		end

		if conditionAndResult then
			local conditionRelation = conditionAndResult.conditionRelation
			local conditions = conditionAndResult.conditions
			local results = conditionAndResult.results

			if self:__conditionsIsTrue(conditions, conditionRelation, environment) then
				if PRINT_MODE == 1 then
					print("条件成立")
				end
				local ret = self:doResults(results, environment)
				if ret then
					for k, v in pairs(ret) do
						retList[k] = v
					end
				end
			else
				if PRINT_MODE == 1 then
					print("条件不成立")
				end
			end
		end
	end
	return retList
end

function BaseMap:doRoomConditionAndResult(roomId, environment)
	if PRINT_MODE == 1 then
		print("function BaseMap:doRoomConditionAndResult(roomId, environment)")
	end
	if environment == nil then
		environment = {}
	end

	if environment.currRoomId == nil then
		environment.currRoomId = roomId
	end

	local retList = {}
	local room = self:getRoomById(roomId)
	if room and room.roleList then

		local roleList = room.roleList

		local function roleInRoom(roleId)
			for i,v in ipairs(room.roleList) do
				if roleId == v then
					return true
				end
			end
			return false
		end

		if PRINT_MODE == 1 then
			print("START roomId = "..tostring(roomId) .. " op="..tostring(environment.operation) )
		end
		for i = #roleList,1, -1 do
			local roleId = roleList[i]
			if roleId ~= nil and roleInRoom(roleId) then
				local role = self:getRole(roleId)
				if role.isFromWeb ~= true then
					environment.currRole = role

					if PRINT_MODE == 1 then
						print("\t "..tostring(roomId).."开始判断角色"..tostring(role.name), role.isForbidden)
						--print("role.conditionAndResults:")
						--Helper:print_lua_table(role.conditionAndResults)
					end

					local ret = self:doConditionAndResult(role.conditionAndResults, environment)
					if ret then
						for k, v in pairs(ret) do
							retList[k] = v
						end
					end
				else

				end
				
			end
		end
		if PRINT_MODE == 1 then
			print("END roomId = "..tostring(roomId) .. " op="..tostring(environment.operation))
		end
	end
	return retList
end

function BaseMap:doRoomConditions(roomId, environment)
	if PRINT_MODE == 1 then
		print("function BaseMap:doRoomConditionAndResult(roomId, environment)")
	end
	if environment == nil then
		environment = {}
	end

	if environment.currRoomId == nil then
		environment.currRoomId = roomId
	end

	local retList = {}
	local room = self:getRoomById(roomId)
	if room and room.roleList then

		local roleList = room.roleList

		local function roleInRoom(roleId)
			for i,v in ipairs(room.roleList) do
				if roleId == v then
					return true
				end
			end
			return false
		end

		if PRINT_MODE == 1 then
			print("START roomId = "..tostring(roomId) .. " op="..tostring(environment.operation) )
		end
		for i = #roleList,1, -1 do
			local roleId = roleList[i]
			if roleId ~= nil and roleInRoom(roleId) then
				local role = self:getRole(roleId)
				if role.isFromWeb ~= true then
					environment.currRole = role

					if PRINT_MODE == 1 then
						print("\t "..tostring(roomId).."开始判断角色"..tostring(role.name), role.isForbidden)
						--print("role.conditionAndResults:")
						--Helper:print_lua_table(role.conditionAndResults)
					end

					local ret = self:__doConditions(role.conditionAndResults, environment)
					if ret then
						return true
					end
				else

				end
				
			end
		end
		if PRINT_MODE == 1 then
			print("END roomId = "..tostring(roomId) .. " op="..tostring(environment.operation))
		end
	end
	return false
end

function BaseMap:__doConditions(conditionAndResults, environment)
	if PRINT_MODE == 1 then
		print("function BaseMap:doConditionAndResult(conditionAndResults, environment)")
	end
	if conditionAndResults == nil then
		return {}
	end
	if environment == nil then
		environment = {}
	end

	local conditionAndResultIndex = 0

	local retList = {}
	local roomStates = {}
	if environment.currRoomId then
		roomStates = User:getRole():getMapRoomState(self.id, environment.currRoomId)
	end

	local currRole = environment.currRole
	-- 判断NPC是否被禁用 如果是玩家,也不需要判断条件结果
	if currRole.isForbidden == true or currRole.isFromWeb == true then
		return false
	end

	if PRINT_MODE == 1 then
		-- 判断仇恨 主动攻击玩家
		print(MapIsEmpty(roomStates))
		print("类型 = "..tostring(currRole.type))
	end

	for k, conditionAndResult in ipairs(conditionAndResults) do
		conditionAndResultIndex = conditionAndResultIndex + 1
		if PRINT_MODE == 1 then
			print("开始判断第 "..tostring(conditionAndResultIndex).." 个条件:")
		end

		if conditionAndResult then
			local conditionRelation = conditionAndResult.conditionRelation
			local conditions = conditionAndResult.conditions
			local results = conditionAndResult.results

			if self:__conditionsIsTrue(conditions, conditionRelation, environment) then
				if PRINT_MODE == 1 then
					print("条件成立")
				end
				return true
			else
				if PRINT_MODE == 1 then
					print("条件不成立")
				end
			end
		end
	end
	return false
end

-- 处理玩家操作
function BaseMap:dowithRoleOperation(param)
	if PRINT_MODE == 1 then
		print("param.operation = "..tostring(param.operation))
	end

	-- 得到玩家
	local player = User:getRole()

	-- add by XiaoZhiWei 2018/06/01 11:58:29 检查角色是否在当前房间,否则不执行条件结果
	if self:checkRoleIsInRoom(param.currRoomId, param.currRole.id) == false then
		return 
	end

	if param.operation == "拾取" then
		if param.currRole.type == "item" then
			if param.currRole.baseId then
				local Item = require("app.models.item.Item")
				local item = Item:getOneItemByKey(param.currRole.baseId)
				if item then

					-- if not User:getRole():checkCanBuyThings(item.id,1) then
					-- 	return
					-- end
					-- --添加是否能拾取物品的判断
					if not self:addItemCount(param.currRole.baseId, 1) then
						return
					end
					param.player:addItemCount(param.currRole.baseId, 1)
					Statistics:recordItemCount(param.currRole.baseId, 1) -- 用于统计

					self:removeRoomRole(param.currRoomId, param.currRole.id)
					PopText("你获得了 "..item.name)
					RichPrint("main","你获得了"..item.name)
					-- if TEACHER_TASK_IS_OPEN == true then
					-- local TeacherTask  = require("app.models.task.teacherTask.teacherTask")
					-- 	TeacherTask:dealPickUpTeacherTaskItem(param.currRole.baseId,function(roleId,roomId)
					-- 		if type(roleId) == "string" and type(roomId) == "string" then
					-- 			self:removeRoomRole(roomId,roleId)
					-- 			self.__MapLayer:setNeedRefreshMap()
					-- 		end
					-- 	end)
					-- end
				else
					PopText("该物品不存在")
				end
			else
				PopText("没有该物品")
			end
		else
			PopText("这个物品无法捡取")
		end
	elseif param.operation == "打开" then
		if param.currRole.type == "item" then
			if param.currRole.baseId then
				local Item = require("app.models.item.Item")
				local item = Item:getOneItemByKey(param.currRole.baseId)
				if item then
					PopText("打开了"..item.name)

					self:__boxOpen(param.currRoomId, param.currRole, item)

					-- param.player:addItemCount(param.currRole.baseId)
					-- self:removeRoomRole(param.currRoomId, param.currRole.id)
				else
					PopText("该物品不存在")
				end
			else
				PopText("没有该物品")
			end
		else
			PopText("这个物品无法捡取")
		end
	elseif param.operation == "提取" then
		if param.currRole.type == "item" then
			if param.currRole.subType == "打开的箱子" then
				-- PopText("已经拿了物品")
				self:__boxPickUp(param.currRoomId, param.currRole, item)
			elseif param.currRole.subType == "尸体" then
				self:__pickUpCorpse(param.currRoomId, param.currRole, param.func)
			end
		else
			PopText("这个物品无法提取")
		end
	elseif param.operation == "杀死" then
		-- PopText("杀死")
		-- PopText("param.currRole.type = "..tostring(param.currRole.type))
		-- PopText("param.result = "..tostring(param.result))
		if param.currRole.type == "role" then
			if param.result == "成功" then
				-- 变对手为尸体
				-- PopText("你杀死了"..param.currRole.name)

				self:playerKillRole(param.currRoomId, param.currRole)
			elseif param.result == "失败" then
				-- 杀死失败，玩家应该会挂．．

			elseif param.result == nil then

			else
				PopText("无法与这个人决斗")
			end
		else
			PopText("无法与这个人决斗")
		end
	elseif param.operation == "使用" or param.operation == "使用1" or param.operation == "使用2" or param.operation == "使用3" or param.operation == "使用4" or param.operation == "使用5" 
		or param.operation == "使用6" or param.operation == "使用7" or param.operation == "使用8" or param.operation == "使用9" or param.operation == "使用10" then   -- 使用
		if param.currRole.type == "item" then
			if param.currRole.baseId then
				local Item = require("app.models.item.Item")
				local item = Item:getOneItemByKey(param.currRole.baseId)
				if item then
					-- RichPrint("main", "使用了"..item.name)
					-- self:__boxOpen(param.currRoomId, param.currRole, item)
					item:itemUseDescShow(function()end, true)

					-- param.player:addItemCount(param.currRole.baseId)
					-- self:removeRoomRole(param.currRoomId, param.currRole.id)
					return true
				else
					-- PopText("该物品不存在")
				end
			else
				return true
			end
			-- return true
		else
			-- PopText("只能捡取物品!!")
		end
	else
		PopText(param.operation)
	end
end

--获取周围的房间(一定步数内) roomId 房间ID step 步数
function BaseMap:getNearRooms(roomId, step)
	if not roomId or not step or type(step) ~= "number" then
		return nil
	end
	local list, map, rmap = {}, {}, {}	-- list 最终返回table map 记录所有出现过的table rmap 记录每次新出现的房间ID

	-- 如果步数为0 则返回当前房间
	if step <= 0 then
		return {roomId}
	end

	-- 遍历房间ID获取相邻房间ID 只遍历新出现的房间ID
	local function getRoomMap(maps)
		if MapIsEmpty(maps) then
			return
		end
		rmap = {}
		for roomId,count in pairs(maps) do
			local roomLink = assert(self.room[roomId].link)
			for k,v in pairs(roomLink) do
				if not map[v] then
					map[v] = 1
					rmap[v] = 1
				else
					map[v] = map[v] + 1
				end
			end
		end
	end

	if MapIsEmpty(rmap) then
		getRoomMap({[roomId] = 1})
	end

	local index = 1
	while true do
		if step == index then
			break
		end
		local nmap = rmap
		getRoomMap(nmap)
		index = index + 1
	end

	local TransmitRoomModel = require("app.models.transmitRoom.TransmitRoomModel")
	local FILTER_MAP = TransmitRoomModel:getDefaultFilterRoomList()

	for k,v in pairs(map) do
		if FILTER_MAP[k] ~= true then
			table.insert(list, k)
		end
	end

	-- 添加自身
	table.insert(list, roomId)

	return list
end

-- add by XiaoZhiWei 2017/08/30 16:49:27 获取周围房间列表,排除当前房间
function BaseMap:getNearRoomsExceptSelf(roomId, step)
	local list = self:getNearRooms(roomId, step)
	for i=#list, 1,-1 do
		print(i, list[i], roomId)
		if list[i] == roomId then
			table.remove(list,i)
		end
	end
	return list
end
-- 计算两个房间之间的步数
function BaseMap:getStep(fromRoomId, toRoomId)
	if PRINT_MODE == 1 then
		print("计算房间"..tostring(fromRoomId).."到房间"..tostring(toRoomId).."之间的步数")
	end
	if not fromRoomId or not toRoomId then
		if PRINT_MODE == 1 then
			print(" BaseMap:getStep(fromRoomId, toRoomId) -> 参数为空")
		end
		return
	end
	local map, rmap = {}, {[fromRoomId] = 1}

	local function isTheRoom(maps)
		if MapIsEmpty(maps) then
			return false
		end
		rmap = {}
		for roomId,v in pairs(maps) do
			if PRINT_MODE == 1 then
				print(roomId)
			end
			local roomLink = assert(self.room[roomId].link)
			for k,v in pairs(roomLink) do
				if not map[v] then
					rmap[v] = 1
					if v == toRoomId then
						return true
					end
				end
			end
		end
		return false
	end

	local step = 1
	while not isTheRoom(rmap) do
		step = step + 1
	end

	return step
end

function BaseMap:getRoomNameById(roomId)
	return assert(self.room[roomId].name)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/19 16:37:58
-- @desc  主动任务添加NPC
function BaseMap:__setMapForTask()
	local role = User:getRole()
	local tasks = Task:getRoleTasks()
	for k,roleTask in pairs(tasks) do
		-- 任务状态是已接受
		if roleTask.state == TASK_STATE_ACCEPT and k ~= "task15" and k ~= "task22" then
			local task = Task:getTask(k)
			if PRINT_MODE == 1 then
				print("task.mapIndex = "..tostring(task.mapIndex))
				print("task.isInit = "..tostring(task.isInit))
			end

			-- 任务的副本ID等于当前地图ID, 并且地图任务角色未初始化
			if task and self.id == task.mapId and self.taskIsInit ~= true then
				-- add by XiaoZhiWei 2017/12/01 19:59:30 其中任意一个为空,则不做任何处理
				if task.zhuXianCondition ~= nil and task.zhuXianCondition.mapRoom ~= nil and task.zhuXianCondition.mapRoom[self.id] ~= nil then
				else
					return
				end
				local roomId = assert(task.zhuXianCondition.mapRoom[self.id].roomId)		-- 任务指定房间ID
				local step = tonumber(assert(task.zhuXianCondition.mapRoom[self.id].step))	-- 任务定义步数
				local roomList = self:getNearRooms(roomId, step)							-- 获取指定步数所有房间列表
				if not MapIsEmpty(task.zhuXianCondition.npcList) then 						-- 任务必须有需要添加的npc信息
 					for roleId,attr in pairs(task.zhuXianCondition.npcList) do 				-- 遍历NPC信息准备添加
						if not attr.count then 												-- 必须有npc数量
							if PRINT_MODE == 1 then
								PopText("任务角色添加失败,任务没有定义NPC的数量")
							end
							break
						end
						if attr.count <= role:getDayFlag("飞贼人数") then
							attr.count =  role:getDayFlag("飞贼人数")
						elseif  role:getDayFlag("飞贼人数") == 3  then 
							attr.count = 3
						end
						for i=1,attr.count do 												-- 循环
							local role = Npc:createTaskNpc(roleId) 							-- 创建NPC
							self:createRole(role) 											-- 添加角色
							if PRINT_MODE == 1 then
								print("role.id = "..role.id)
								print("任务角色创建成功~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
							end
							self:addRoomRole(roomList[math.random(1, #roomList)], role.id, false) -- 放入随机房间

							if PRINT_MODE == 1 then
								print("任务角色添加成功-----------------------------------------------------------")
							end
						end
					end
				else
					if PRINT_MODE == 1 then
						PopText("任务角色添加失败,任务没有定义NPC的信息")
					end
				end
				self.taskIsInit = true 														-- 地图任务角色是否初始化 的状态标记为已添加,防止重复添加
			end
		end
	end
end

-- 获取默认房间号
function BaseMap:getDefaultRoomId()
	local role = User:getRole()
	if role:isMapCompleted(self.id) and self.entryRoom2 then
		return self.entryRoom2
	else
		return assert(self.entryRoom1, "默认房间1是必填项")
	end
end

-- 添加自定义地图角色
function BaseMap:setMapInfo()
	local Inherit = require("app.models.inherit.Inherit")

	-- 传承前任角色
	Inherit:createSeniorRole(self)

	-- 飞贼任务的时候,检查下主动任务是否需要添加NPC
	if User:getRoleAttr("currTaskId") == "task16" or User:getRoleAttr("currTaskId") == "task17" then
		self:__setMapForTask()
	end

	-- add by ZhangShengTang 2017/06/14 11:53:39
	-- 周年庆活动
	local Anniversary = require("app.models.Anniversary.Anniversary")
	Anniversary:createRoleToMap(self)


	-- 添加随机 NPC
	self:__addRandomNpc()
end

-- 物品掉落（背包已满的情况使用）
function BaseMap:dropItem(roomId, itemId,count)
	if not roomId or not itemId then
		return
	end
	local item = Item:getOneItemByKey(itemId)
	if item == nil then
		if PRINT_MODE == 1 then
			assert(nil, "这个物品的资源不存在, 物品ID = "..tostring(itemId))
		end
	end

	local desc = "这是"..tostring(item.unit)..tostring(item.name)
	count = Helper:getDef(count ,1)
	for i = 1 ,count do 
		local itemBox =
		{
			type = "item",
			subType = "item",
			id = tostring(item.name)..tostring(Helper:getOnlyId()),
			baseId = itemId,
			name = tostring(item.name),
			dsc = desc,
			canSee = true, -- 可见
			canPickUp = true, -- 拾取
			canUse = false, -- 使用
			canExtract = false, -- 提取
			canOpen = false, -- 打开
			canPushIn = false, -- 能放入
		}
		self:createRole(itemBox) -- 创建打开的箱子
		self:addRoomRole(roomId, itemBox.id,false)
	end

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/28 15:55:11
-- @desc 切磋回调函数
function BaseMap:afterFightWithQieCuo(player, role, callback)
	self:__afterFight(player, role, callback, "切磋")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/28 16:48:59
-- @desc 杀死回调函数
function BaseMap:afterFightWithShaSi(player, role, callback, runFunc,failFunc)
	self:__afterFight(player, role, callback, "杀死", runFunc,failFunc)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/28 18:04:57
-- @desc 伤害类型
function BaseMap:__getDamageTypeDesc(damageType)
	local endStr = ""
	if damageType == "擦伤" or damageType == "割伤" then
		endStr = "砍倒了"
	elseif damageType == "刺伤" then
		endStr = "刺倒了"
	elseif damageType == "瘀伤" then
		endStr = "击倒了"
	elseif damageType == "内伤" then
		endStr = "震倒了"
	else
		endStr = "打败了"
	end
	return endStr
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/29 11:13:51
-- @desc 战斗结束描述文本
function BaseMap:__getAfterFightDesc(fightType, winTeamId, damageType)
	local retStr = ""
	if fightType == "切磋" and winTeamId == 1 then
		retStr = "战胜了"
	elseif fightType == "切磋" and winTeamId == 2 then
		retStr = "打趴在地"
	elseif fightType == "杀死" then
		retStr = self:__getDamageTypeDesc(damageType)
	else
	end
	return retStr
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/28 17:11:42
-- @desc 战斗相关逻辑
function BaseMap:__afterFight(player, role, callback, fightType, runFunc,failFunc)
	if fightType == nil then
		print("战斗类型不能没有")
		return
	end

	if type(failFunc) ~= "function" then
		failFunc = function()
			self:setMapFightState(false)
		end
	else
		local oldFailFunc = failFunc
		failFunc = function()
			oldFailFunc()
			self:setMapFightState(false)
		end
	end

	FubenClient:setValue("isFighting", true)
	User:getRole():updateFightStatus("战斗中")

	local FightLayer = require("app.views.layer.FightLayer.FightLayer")

	local yongbing = User:getRole():getFlag("佣兵模式")
	local btnType = 3
	if yongbing == "开启" and self:getYongBingId() ~= nil then
		player = self:getYongBingRole()
		btnType = 4
	end

	if  self:getMapType() == MAP_TYPE.DREAMMAP or self:getMapType() == MAP_TYPE.FONDDREAMMAP then
		btnType = 2 --隐藏恢复按钮
	end

	player:dispatchEvent("FightStartEvent",{player = player,target = role,fightType = fightType})
	role:dispatchEvent("FightStartEvent",{player = role,target = player,fightType = fightType})

    FightLayer:startMapFight({player}, {role},
    function(fightLayer, eventType, ...)
        local fight = fightLayer:getFight()
        if fight ~= nil then
        	print("fight 存在")
        end
		if eventType == FightLayer.EVENT_TYPE_FIGHT_READY then
			-- 暂停地图场景渲染
			self._mapLayer:pauseSelfAndChildren()
			self._mapLayer:setVisible(false)
			MainControllLayer:pauseUpdate()

			-- 战斗开始的时候设置下玩家
			local role1 = fight:getRoleByTeamIdAndInTeamId(1, 1)
			fight:setPlayer(role1)
			-- fight:start()
			if  self:getMapType() == MAP_TYPE.DREAMMAP then
				local DreamModel = require("app.models.DreamWorldModel.DreamModel")
				DreamModel:enterFightEvent(self)
			end
			-- 显示开场白
			fightLayer:printRolePrologue(1, fightType)
		elseif eventType == FightLayer.EVENT_TYPE_FIGHT_START then
			PopText("开始战斗")



			--战斗开始时准备的主动招式数组
			local role = fight:getRoleByTeamIdAndInTeamId(1, 1)
			local fightStartPreparedActiveZhaoIdArray = role:getRole():getPreparedActiveZhaoIdArray()
			role["fightStartPreparedActiveZhaoIdArray"] = fightStartPreparedActiveZhaoIdArray
        elseif eventType == FightLayer.EVENT_TYPE_FIGHT_FINISH then
            local winTeamId, teams = ...

			self:setMapFightState(false)
			FubenClient:setValue("isFighting", false)
			User:getRole():updateFightStatus("战斗结束")

			player:addSeeSkillAfterFight(role) --战斗结束后添加见闻武学技能

            -- 隐藏按钮区域
            fightLayer:callUIMemFunc("setButtonAreaVisble", false)
            -- 显示战斗结束文本区域
            fightLayer:callUIMemFunc("showFightEndTextArea")

            -- 设置战斗结束文本区域的文本
        	local target = fight:getRoleByTeamIdAndInTeamId(winTeamId, 1)
        	local zhao = target:getCurrAttackZhao()
        	-- local damageType = zhao.damageType
			local damageType = zhao ~= nil and zhao.damageType or ""
            if winTeamId == 1 then
                fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "胜利")
				fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你" .. self:__getAfterFightDesc(fightType, winTeamId, damageType) .. role:getName())
				
				--@RefType 战斗胜利后 副本内长生诀CD -10秒
				do
					if User:getRole():getFlag("长生诀时间") > 0 then
						User:getRole():setFlag("长生诀时间",User:getRole():getFlag("长生诀时间") - 10)
					end
				end

				if player.isGuYongBing == true then
					player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
                	User:getRole():uploadYongBingAttr(player)
                	local maxCount = 5
                	if DEBUG_MODE == 1 then
                		maxCount = 10000000
                	end
                	if User:getRole():getDayFlag("佣兵熟练度增加次数") < maxCount then -- add by XiaoZhiWei 2017/04/26 17:24:23 每天只能增加5次
	                	User:getRole():addMapNpcZhaoExp(player.AttrModifyId, 50) -- add by XiaoZhiWei 2017/04/26 16:46:22 雇佣兵模式,佣兵战斗一次获取50战斗熟练度
	                	local mapRolelist = self:getRoles()
						for k,v in pairs(mapRolelist) do
							self:npcAttrModify(v)
						end
						User:getRole():setDayFlag("佣兵熟练度增加次数", User:getRole():getDayFlag("佣兵熟练度增加次数") + 1)
					else
					end
                	User:getRole():setFlag("佣兵战斗结果", fightType.."成功")
				elseif player.isDreamRole == true then
				else
                	player:calcActiveZhaoUseTimes(fight:getRoleByTeamIdAndInTeamId(1, 1)) -- 计算主动招式熟练度
                end
            else
                fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "失败")
                fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你被" .. role:getName() .. self:__getAfterFightDesc(fightType, winTeamId, damageType))
				if player.isGuYongBing == true then
					player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
                	User:getRole():uploadYongBingAttr(player)
                	User:getRole():setFlag("佣兵战斗结果", fightType.."失败")
                end
            end
            fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
				
				-- 属性结算 add by TangJian 2016/11/02 19:37:54
				do
					player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
					role:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(2, 1), fightType)
				end

				self._mapLayer:resumeSelfAndChildren()
				self._mapLayer:setVisible(true)
				MainControllLayer:resumeUpdate()

				fightLayer:hide(
					function()
						fightLayer:destroyInstance()
						cleanTable(fightLayer)
						Helper:getDef(callback, EMPTY_FUNC)(winTeamId)
					end
				)
				
				player:dispatchEvent("FightEndEvent",{player = player ,target = role, map = self, fightType = fightType,fight = fight, fightResult = winTeamId, leftRole = fight:getRoleByTeamIdAndInTeamId(1, 1), rightRole = fight:getRoleByTeamIdAndInTeamId(2, 1)})
				role:dispatchEvent("FightEndEvent",{player = role ,target = player, map = self, fightType = fightType,fight = fight, fightResult = winTeamId, leftRole = fight:getRoleByTeamIdAndInTeamId(1, 1), rightRole = fight:getRoleByTeamIdAndInTeamId(2, 1)})
				if  self:getMapType() == MAP_TYPE.DREAMMAP then
					local DreamModel = require("app.models.DreamWorldModel.DreamModel")
					if fightType == "切磋" then
						DreamModel:qieCuoFightEnd(self,winTeamId)
					elseif fightType == "杀死" then
						DreamModel:jueDouFightEnd(self,winTeamId)
					end
				end
			end)
        elseif eventType == FightLayer.EVENT_TYPE_FIGHT_RUNAWAY then
			self:setMapFightState(false)
			FubenClient:setValue("isFighting", false)
			User:getRole():updateFightStatus("战斗结束")

            -- PopText([[你大喝一声：“三十六计，走为上计”]])
            -- 属性结算 add by TangJian 2016/11/02 19:37:54
            do
                player:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(1, 1), fightType)
                role:acceptMapFightResult(fight:getRoleByTeamIdAndInTeamId(2, 1), fightType)
            end

			player:addSeeSkillAfterFight(role) --战斗结束后添加见闻武学技能
			
            -- add by XiaoZhiWei 2017/05/02 15:41:35 佣兵模式属性上传
            if player.isGuYongBing == true then
            	User:getRole():uploadYongBingAttr(player)
            end

            -- 隐藏按钮区域
            fightLayer:callUIMemFunc("setButtonAreaVisble", false)
            -- 显示战斗结束文本区域
            fightLayer:callUIMemFunc("showFightEndTextArea")

            -- 设置战斗结束文本区域的文本
            fightLayer:callUIMemFunc("setFightEndTextAreaText", 1, "逃跑")
            fightLayer:callUIMemFunc("setFightEndTextAreaText", 2, "你大喝一声：“三十六计，走为上计")

            fightLayer:callUIMemFunc("setFightEndTextAreaReleaseFunc", function()
	            		-- player:calcActiveZhaoUseTimes(fight:getRoleByTeamIdAndInTeamId(1, 1)) -- 计算主动招式熟练度

				self._mapLayer:resumeSelfAndChildren()
				self._mapLayer:setVisible(true)
				MainControllLayer:resumeUpdate()

				fightLayer:hide(function()
                    fightLayer:destroyInstance()
					cleanTable(fightLayer)
					Helper:getDef(callback, EMPTY_FUNC)(3)
				end)

				player:dispatchEvent("FightEndEvent",{player = player ,target = role, map = self, fightType = fightType,fight = fight, fightResult = 3, leftRole = fight:getRoleByTeamIdAndInTeamId(1, 1), rightRole = fight:getRoleByTeamIdAndInTeamId(2, 1)})
				role:dispatchEvent("FightEndEvent",{player = role ,target = player, map = self, fightType = fightType,fight = fight, fightResult = 3, leftRole = fight:getRoleByTeamIdAndInTeamId(1, 1), rightRole = fight:getRoleByTeamIdAndInTeamId(2, 1)})
				if  self:getMapType() == MAP_TYPE.DREAMMAP then
					local DreamModel = require("app.models.DreamWorldModel.DreamModel")
					if fightType == "切磋" then
						DreamModel:qieCuoFightEnd(self,3)
					elseif fightType == "杀死" then
						DreamModel:jueDouFightEnd(self,3)
					end
				end
			end)
        end
    end, btnType, self._mapLayer._currRoom.fightBackground, runFunc,failFunc)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/17 23:32:06
-- @desc 投放NPC
function BaseMap:__addRandomNpc()
	local list = Map:getRandomNpcList(self.id) -- 获取地图的投放列表
	if MapIsEmpty(list) == false then
		for roomId,npcMap in pairs(list) do -- 循环投放列表 内部结构 mapid = {roomid1 = {}, roomid2 = {}, ...}
			for roleId,npcInfo in pairs(npcMap) do -- 循环房间列表 内部结构 roomid = { feizei1 = {step = 1, count = 1, probability = 100}, feizei2 = {}, ...}
				self:__addOneRandomNpc(roomId, roleId, npcInfo.step, npcInfo.count, npcInfo.probability)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/18 01:14:35
-- @desc 投放单个NPC roomId 房间 roleId 角色Id step 步数 count 数量 probability 出现概率
function BaseMap:__addOneRandomNpc(roomId, roleId, step, count, probability)
	probability = Helper:getDef(probability, 100) -- 概率,默认值100
	if roomId ~= nil and roleId ~= nil and step ~= nil and count ~= nil then
		local roomList = self:getNearRooms(roomId, step) -- 获取一定步数内的所有房间Id列表
		for i=1,count do
			-- 判断出现的概率
			local percent = math.random(1, 100)
			if percent <= probability then -- 判断概率
				local role = Npc:createRandomNpc(roleId)
				-- 创建角色
				if role == nil and Map:getMapNpc(self.id, roleId) ~= nil then
					-- 角色如果在NPC内不存在,则去副本内找
					role = Map:getMapNpc(self.id, roleId)
				else
				end

				if role ~= nil then
					Npc:initRoleIsForbidden(role)
					self:createRole(role)
					self:addRoomRole(roomList[math.random(1, #roomList)], role.id, false) -- 放入随机房间
				end
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/04 16:41:40
-- @desc 替换房间的背景音乐
function BaseMap:replaceRoomBGM(roomId, bgmName, vol, isLoop)
	if roomId == nil or bgmName == nil then
		return
	end
	vol = Helper:getDef(vol, 1)
	isLoop = Helper:getDef(isLoop, 0)
	local room = self:getRoomById(roomId)
	if room._BgmHistory == nil then
		room._BgmHistory = {} -- 记录bgm的替换历史
	end
	table.insert(room._BgmHistory, {bgm = bgmName, vol = vol, isLoop = isLoop})
	room.roomBgm, room.roomBgmRule, room.BgmDown = bgmName, isLoop, vol

	self.room[roomId] = room
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/04 18:03:28
-- @desc 播放该房间上一次播放的背景音乐
function BaseMap:replayLastRoomBgm(roomId, vol, isLoop)
	if roomId == nil then
		return
	end
	local room = self:getRoomById(roomId)
	if MapIsEmpty(room) == true or MapIsEmpty(room._BgmHistory) == true then
		return
	end
	local lastBgm = Helper:getDef(room._BgmHistory[#room._BgmHistory], {})
	isLoop, vol = isLoop == nil and lastBgm.roomBgmRule or isLoop, vol == nil and lastBgm.BgmDown or vol

	self:replaceRoomBGM(roomId, room.roomBgm, vol, isLoop)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/04 18:15:40
-- @desc 播放房间默认的背景音乐
function BaseMap:playDefaultBgm(roomId)
	if roomId == nil then
		return
	end
	local room = self:getRoomById(roomId)
	if MapIsEmpty(room) == true or MapIsEmpty(room._BgmHistory) == true then
		return
	end
	local firstBgm = Helper:getDef(room._BgmHistory[1], {})
	if firstBgm.bgm == nil then
		return
	end
	self:replaceRoomBGM(roomId, firstBgm.bgm, firstBgm.vol, firstBgm.isLoop)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/03 10:08:18
-- @desc 副本内角色属性变化的文本提示
function BaseMap:richPrintText(role, attr, value)
	if role == nil or attr == nil or value == nil or type(value) ~= "number" then
		return
	end

	-- 只有下列属性改变时,提示文本
	local text = switch(attr,
	{
		exp = "经验",
		pot = "潜能",
		money = "碎银",
		yueli = "阅历",
		weiwang = "江湖威望",
		default = nil
	})
	-- 判断角色是是否是当前用户
	if role == User:getRole() and text ~= nil then
		if value >= 0 then
			RichPrint("main", "你获得了"..tostring(value)..text.."。")
		else
			RichPrint("main", "你的"..text.."减少"..tostring(value).."。")
		end
	end
end

-- 改变副本Npc属性
function BaseMap:npcAttrModify(npc)
	local role = User:getRole()
	--local npc = self:getRole("npc01_03a")
	if npc == nil then
		return
	end

	local mapNpcAttrModify = role:getAttr("mapNpcAttrModify")

	for i,v in ipairs(mapNpcAttrModify) do
		if npc.AttrModifyId ~= nil and npc.AttrModifyId == v.npcId then
			local alterAttrList = { "str" , "con" , "int" , "dex", "jiaLi" , "qiMax" , "qi" }

			if npc.originAttr == nil then

				npc.originAttr = {}

				npc.originAttr['exp'] = npc:getAttr( 'exp' )
				for i,v in ipairs(alterAttrList) do
					npc.originAttr[v] = npc:getFinalAttr( v )
				end

				--装备的武功
				npc.originSkill = {}
				for k,v in pairs( npc.skillPrepare ) do
					npc.originSkill[k] = npc.skills[v].exp
				end
			end

			local buff = Helper:getDef(v.buff, 1)

			for i,v in ipairs(alterAttrList) do
				npc:setAttr( v , npc.originAttr[v] * buff )
			end


			--装备的武功
			for k,v in pairs( npc.skillPrepare ) do
				npc.skills[v].exp = npc.originSkill[k] * buff
			end

			-- for k,v in pairs(v.skills) do
			-- 	npc.skills[k].exp = npc.skills[k].exp + Skill:getExp(v)
			-- end

			-- add by XiaoZhiWei 2017/04/26 01:12:39 装备加成
			if MapIsEmpty(v.equips) == false then
				local equips = npc:getAttr("equips")
				for k,v in pairs(v.equips) do
					local item = Item:getOneItemByKey(v)
					if item ~= nil then
						equips[item.equipPart] = {id = Helper:getOnlyId(), itemId = item.id}
					end
				end
				npc:setAttr("equips", equips)
			end

			-- add by XiaoZhiWei 2017/04/25 21:31:55 增加NPC武功等级
			if v.skillAddLv ~= nil then
				for skillId,skills in pairs(npc.skills) do
					npc:setSkill(skillId, {id = skillId, exp= Skill:getExp(v.skillAddLv)})
				end
			end

			-- add by XiaoZhiWei 2017/04/26 01:45:31 NPC的招式列表
			local addZhaoList = Helper:getDef(v.addZhaoList, {})
			local activeZhaos = Helper:getDef(v.activeZhaos, {})
			for k,zhaoId in pairs(addZhaoList) do
				if activeZhaos[zhaoId] ~= nil then
					npc:setSkillZhao(zhaoId, {id = zhaoId, exp = activeZhaos[zhaoId]})
				else
					npc:setSkillZhao(zhaoId, {id = zhaoId, exp = 1})
				end
			end

			-- -- add by XiaoZhiWei 2017/04/25 21:20:06 NPC的招式熟练度
			-- if PRINT_MODE == 1 then
			-- 	-- local zhaoList = npc:getAttr("activeZhaos")
			-- 	local zhaoList = {
			-- 		"gonggongposhan",
			-- 		"chunhuidadi",
			-- 		"yiyezhangmu",
			-- 		"zuoyoubohu",
			-- 		"yueyihuaying",
			-- 		"yedichuandie"
			-- 	}
			-- 	if MapIsEmpty(zhaoList) == true then
			-- 		return
			-- 	else
			-- 		for k,zhaoId in pairs(zhaoList) do
			-- 			npc:setSkillZhao(zhaoId, {id = zhaoId, exp = Helper:getDef(activeZhaos[zhaoId], 1)})
			-- 		end
			-- 	end
			-- end

			-- add by XiaoZhiWei 2017/05/02 16:15:10 NPC属性列表
			local attrList = {"qi", "qiMax", "neili", "neiliMax", "qiPercent"}
			for i,attrName in ipairs(attrList) do
				if v[attrName] ~= nil then
					npc:setAttr(attrName, v[attrName])
				end
			end

			-- add by XiaoZhiWei 2017/06/10 17:37:21 检查气血和内力最大值是否异常 (章作之 bug专用,并且必须在血量校验之前)
			if v.npcId == "zhang" then
				local baseRole = Map:getMapNpc(self.id, npc.baseId)

				if npc:getFinalAttr("qiMax") < Helper:getDef(baseRole.qiMax, 22000) then
					npc:setAttr("qiMax", Helper:getDef(baseRole.qiMax, 22000))
				end

				if npc:getFinalAttr("neiliMax") < Helper:getDef(baseRole.neiliMax, 50000) then
					npc:setAttr("neiliMax", Helper:getDef(baseRole.neiliMax, 50000))
				end
			end

			-- add by XiaoZhiWei 2017/06/08 12:19:29 检查气血上限百分比是否超出百分之百
			if npc:getAttr("qiPercent") > 1 then
				npc:setAttr("qiPercent", 1)
			end

			-- add by XiaoZhiWei 2017/06/08 12:18:46 检查气血是否超出最大值
			if npc:getAttr("qi") > npc:getFinalAttr("qiMax") * npc:getAttr("qiPercent") then
				npc:setAttr("qi", npc:getFinalAttr("qiMax") * npc:getAttr("qiPercent"))
			end

			-- add by XiaoZhiWei 2017/06/08 12:18:46 检查内力是否超出最大值
			if npc:getAttr("neili") > npc:getFinalAttr("neiliMax") then
				npc:setAttr("neili", npc:getFinalAttr("neiliMax"))
			end

			return
		end
	end


end

-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------         佣兵类功能                   ---------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------

--[[
	角色列表
	指定房间列表 key value结构  value 转换为true
	标记key  标记必须是角色标记
	标记value
]]

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 10:03:20
-- @desc 设置跟随属性
function BaseMap:setFollowInfo(npcList, roomList, key, value)
	if MapIsEmpty(npcList) == true then
		local deleteList = Helper:getDef(self:getFollowInfoByKey("npcList"), {})
		Helper:print_lua_table(deleteList)
		-- print("******************************************************************************************")
		for i,oldNpcId in ipairs(deleteList) do
			self:removeRoomRole(self:getCurrRoomId(), oldNpcId)
		end
	end
	self.__FollowInfo = 
	{
		npcList = npcList,
		roomList = roomList,
		key = key,
		value = value
	}
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 10:08:02
-- @desc 更新跟随属性
function BaseMap:updateFollowInfo(key, value)
	if key == nil then
		return
	end
	-- add by XiaoZhiWei 2017/08/30 15:46:56 如果是佣兵列表发生了变化,需要及时删除当前房间的角色
	if key == "npcList" then
		local npcList = Helper:getDef(self:getFollowInfoByKey(key), {})
		local count_list = {}
		for k,v in pairs(Helper:getDef(value,{})) do 
			count_list[v] = Helper:getDef(count_list[v],0) + 1
		end

		for k,v in pairs(npcList) do 
			if not count_list[v] or count_list[v] < 1 then
				self:removeRoomRole(self:getCurrRoomId(), v)
			else
				count_list[v] = count_list[v] - 1
			end
		end
		-- for k,v in pairs(count_list) do
		-- 	local needCreate = true
		-- 	for i,npcId in pairs(npcList) do 
		-- 		if npcId == k then
		-- 			needCreate = false
		-- 		end
		-- 	end
		-- 	if needCreate == true then
		-- 		for i=1,v do 
		-- 			self:addRoomRole(self:getCurrRoomId(),k,true)--roomId, roleId
		-- 		end
		-- 	end
		-- end

	else
	end
	self.__FollowInfo = Helper:getDef(self.__FollowInfo, {})
	self.__FollowInfo[key] = value
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 10:15:34
-- @desc 获取所有跟随属性
function BaseMap:__getFollowInfo()
	return Helper:getDef(self.__FollowInfo, {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 10:09:40
-- @desc 获取指定跟随属性
function BaseMap:getFollowInfoByKey(key)
	if key == nil then
		return
	end
	self.__FollowInfo = Helper:getDef(self.__FollowInfo, {})
	return self.__FollowInfo[key]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 10:21:22
-- @desc 判断角色是否存在指定房间
function BaseMap:checkRoleIsInRoom(roomId, roleId)
	if roomId == nil or roleId == nil then
		return false
	end
	local room = self:getRoomById(roomId)
	local count = 0
	if MapIsEmpty(room) == true then
		if PRINT_MODE == 1 then
			print("这个房间不存在,请检查", roomId)
		end
	else
		local roleList = Helper:getDef(room.roleList, {})
		for k,v in pairs(roleList) do 
			if v == roleId then
				count = count +1
			end
		end
		for k,v in pairs(roleList) do
			if v == roleId then
				return true,count
			end
		end
	end
	return false,count
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/30 10:00:47
-- @desc 刷新跟随角色
function BaseMap:refreshFollowRoles(currRoomId, lastRoomId)
	if PRINT_MODE == 1 then
		print("BaseMap:refreshFollowRoles(currRoomId, lastRoomId) ", currRoomId, lastRoomId)
	end
	local followInfo = self:__getFollowInfo()
	if MapIsEmpty(followInfo) == true then
		return
	end

	-- Helper:print_lua_table(followInfo)
	local role = User:getRole()
	local roomList = Helper:getDef(followInfo.roomList, {})
	local npcList = Helper:getDef(followInfo.npcList, {})
	local function getRoleCountInFollow(npcId)
		local count = 0
		for k,v in pairs(npcList) do
			if v == npcId then
				count = count + 1 
			end
		end
		return count
	end
	local function addFollowRoles()
		-- add by XiaoZhiWei 2017/08/30 10:36:29 先判断房间
		if MapIsEmpty(roomList) == true or roomList[currRoomId] == true then
			for i,npcId in ipairs(npcList) do
				local count_list = getRoleCountInFollow(npcId)
				local roleIsIn ,count= self:checkRoleIsInRoom(currRoomId, npcId)
				print("跟随列表中",npcId,"的数量:",count_list, "当前房间中",npcId,"的数量:",count)
				if roleIsIn == true and count >= count_list then
				else
					self:addRoomRole(currRoomId, npcId, false) -- add by XiaoZhiWei 2017/08/30 10:35:06 添加角色
				end
			end
		else
			-- add by XiaoZhiWei 2017/08/30 15:46:00 房间如果变化了,及时删除当前房间的列表
			for i,npcId in ipairs(npcList) do
				local roleIsIn = self:checkRoleIsInRoom(currRoomId, npcId)
				if roleIsIn == true then
					self:removeRoomRole(currRoomId, npcId, false) -- add by XiaoZhiWei 2017/08/30 10:35:06 移除角色
				else
				end
			end
		end
	end

	local function removeFollowRoles()
		if MapIsEmpty(roomList) == true or roomList[lastRoomId] == true then
			for i,npcId in ipairs(npcList) do
				local roleIsIn = self:checkRoleIsInRoom(lastRoomId, npcId)
				if roleIsIn == true then
					self:removeRoomRole(lastRoomId, npcId, false) -- add by XiaoZhiWei 2017/08/30 10:35:06 移除角色
				else
				end
			end
		end
	end


	if followInfo.key == nil or followInfo.value == nil then
		addFollowRoles()
		removeFollowRoles()
	else
		local flag = role:getFlag(followInfo.key)
		if flag == followInfo.value then
			addFollowRoles()
		else
		end	
		removeFollowRoles()
	end
end




-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 22:58:55
-- @desc 判断角色(通过BaseId)是否存在于指定房间
function BaseMap:__checkRoleIsInRoomByBaseId(roomId, roleBaseId)
	if roomId == nil or roleBaseId == nil then
		return false
	end
	local room = self:getRoomById(roomId)
	if MapIsEmpty(room) == true then
		if PRINT_MODE == 1 then
			print("这个房间不存在,请检查", roomId)
		end
	else
		local roleList = Helper:getDef(room.roleList, {})
		local role
		for k,v in pairs(roleList) do
			role = self:getRole(v)
			print(k, v, role.name, role.id)
			if role ~= nil and roleBaseId == role.baseId then
				return true
			elseif role == nil then
				assert(nil, "这个NPC角色不存在,但是却在这个房间里面,这有问题")
			end
		end
	end
	return false
end


--偶遇恶鬼
function BaseMap:refreshDevilRole( currRoomId,lastRoomId )
	local odds = math.random(1,100)

	if DEBUG_MODE == 1 then
		print("随机数为 ："..odds)
	end
	
	if odds > 10 then
		return
	end

	--偶遇恶鬼
	self:addRoomRole(currRoomId,"guichairenwu1")
	local role
	local room = self:getRoomById(currRoomId)
	local roleList = Helper:getDef(room.roleList, {})
	for _,roleId in pairs(roleList) do
		if roleId == "guichairenwu1" then
			role = self:getRole(roleId)
			role:setAttr( "qiPercent" , 1.0 )
			role:setAttr( "qi" , role:getCurrQiMax() )
			role:setAttr( "neili" , role:getFinalAttr( "neiliMax" ) )
			break
		end
	end

	local player = User:getRole()
	local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
	local dialog = DialogALayer:getInstance()
	local currMap = self
	self.mapLayer = self.__MapLayer
	dialog:hide()
	dialog:show("HIR一名恶鬼盯上了你手中的祭品，向你扑了过来！","战斗中逃跑将扣除部分潜能")
	dialog:setBack(false)
	dialog:setButton1("迎战", function()
		Audio:playEffect("jiaoHu")
		if TANGJIAN_TEST_ENABLE then
			-- local role = currRole
			role:initNpcAttr() -- NPC状态初始化
			self:afterFightWithShaSi(player, role, function(winTeamId)
				-- 战斗胜利条件结果
				if winTeamId == 1 then
					-- 玩家操作默认
					role:setFlag("是否死亡", true)
					-- 刷新房间条件结果
					currMap:doRoomConditionAndResult(self.mapLayer._currRoom.id) 
					self:removeRoomRole(self:getCurrRoomId(),role.id)
					self.__MapLayer:delayRefreshMap()
				elseif winTeamId == 2 then
					self.__MapLayer.TotalMapBtn_IsInit = false
					self:removeRoomRole(self:getCurrRoomId(),role.id)
					self.__MapLayer:delayRefreshMap()
				elseif winTeamId == 3 then -- add by XiaoZhiWei 2017/09/06 14:37:38	逃跑的情况
				else
				end
			end,function() -- 逃跑回调
				local pot = player:getAttr("pot")
				local rePot = math.random(1000,2000)
				player:setAttr("pot",pot-rePot)
				PopText("潜能扣除 "..rePot)
				RichPrint("main","你在逃跑过程中不幸被鬼魂抓中，你只觉天旋地转，眼前模糊一片，待到回过神来，发现体内真气消散了不少。")
			end)
		end
	end)

end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 22:29:58
-- @desc 佣兵模式删除当前房间佣兵,进入的房间创建佣兵
function BaseMap:refreshYongBingRole(currRoomId, lastRoomId)
	if currRoomId == nil or self:getYongBingBaseId() == nil then
		return
	end

	local player = User:getRole()
	local roleIsIn = self:__checkRoleIsInRoomByBaseId(currRoomId, self:getYongBingBaseId())

	-- if player:getFlag("佣兵模式") == "暂时关闭" and roleIsIn == false then -- add by XiaoZhiWei 2017/04/25 23:06:27 当前房间没有和佣兵同名的NPc,并且佣兵模式为暂时关闭 这是后可以自动恢复佣兵模式
	-- 	player:setFlag("佣兵模式", "开启")
	-- else
	-- end
	local yongbing = player:getFlag("佣兵模式")
	if yongbing == "开启" then
		self:addRoomRole(currRoomId, self:getYongBingId(), false)

		-- 如果房间内已存在 章作之,则佣兵控制为不显示
		if roleIsIn == true then
			self:getRole(self:getYongBingId()).canSee = false
		else
			self:getRole(self:getYongBingId()).canSee = true
		end

	elseif yongbing == "关闭" and roleIsIn == true then -- add by XiaoZhiWei 2017/04/25 23:12:19 佣兵模式为关闭,并且当前房间佣兵还存在的话,需要删除佣兵
		self:removeRoomRole(currRoomId, self:getYongBingId())
	end


	local lastRoomRoleIsIn = self:__checkRoleIsInRoomByBaseId(lastRoomId, self:getYongBingBaseId())
	if lastRoomRoleIsIn == true and yongbing == "开启" then
		self:removeRoomRole(lastRoomId, self:getYongBingId())
	end
	print("当前房间是 == ", currRoomId, lastRoomId,  yongbing, lastRoomRoleIsIn, roleIsIn)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 23:58:46
-- @desc 获取佣兵角色
function BaseMap:getYongBingRole()
	if self:getYongBingId() == nil then
		return
	end
	local role = self:getRole(self:getYongBingId())
	-- role.AttrModifyId = testId
	role.isGuYongBing = true
	self:npcAttrModify(role)
	return role
end

function BaseMap:setCanLeave(bool)
	self.__canLeave = bool == nil and true or bool
end


function BaseMap:canLeaveRoom()
	return Helper:getDef(self.__canLeave,true)
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 12:16:29
-- @desc 获取佣兵 继承ID
function BaseMap:getYongBingBaseId()
	if self:getYongBingId() == nil then
		return
	end
	return assert(self.roles[self:getYongBingId()].baseId, "这个佣兵居然没有填写baseId")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 11:50:46
-- @desc 获取当前佣兵ID
function BaseMap:getYongBingId()
	if self._YongBingId == nil then
		self._YongBingId = Map:getYongBingIdByMapId(self.id)
	end
	return self._YongBingId
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/16 15:25:00
-- @desc 副本初始化 (副本的初始化流程太分散,归纳集中到该方法中)
function BaseMap:initMapInfo()

end

-- add by XiaoZhiWei 2017/07/19 09:15:17 记录一个当前房间ID, 方便获取当前房间的ID
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/19 09:13:37
-- @desc 设置当前房间
function BaseMap:setCurrRoomId(roomId)
	if roomId == nil then
		return
	end
	self.__currRoomId = roomId
end

--@desc 设置房间属性
function BaseMap:setRoomAttr(roomId,attrName,value)
	local room = self:getRoomById(roomId)

	if MapIsEmpty(room) then
		print("需要设置的房间不存在，roomId = "..roomId)
		return
	end

	room[attrName] = value
end

--@desc: 获得房间属性值
--@author:Liang SongQiang
--@time:2018-12-10 21:04:46
function BaseMap:getRoomAttrValue(roomId,attrName)
	local room = self:getRoomById(roomId)

	if MapIsEmpty(room) then
		print("需要设置的房间不存在，roomId = "..roomId)
		return
	end

	return room[attrName]
end

function BaseMap:getMapAttr(name)
	return self[name]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/19 09:14:29
-- @desc 获取当前房间
function BaseMap:getCurrRoomId()
	return Helper:getDef(self.__currRoomId, "")
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/22 14:55:20
-- @desc 获取当前房间的NPC列表以及数量
function BaseMap:getCurrRoomNpcListAndNumber()
	local number, retList = 0, {}
	local npcList = self:getRoomRoleList(self:getCurrRoomId())
	if MapIsEmpty(npcList) == true then
		return retList, number
	end
	for i,roleId in ipairs(npcList) do
		local role = self:getRole(roleId)
		-- print(i, roleId, role.isFromWeb, role.isForbidden, role.canSee, role.canSee, self:getYongBingId())
		-- add by XiaoZhiWei 2017/08/22 15:15:28 玩家数据,禁用,不可见,以及佣兵时均不用添加
		if role.isFromWeb == true or role.isForbidden == true or role.canSee == false or role.canSee == 0 or role.id == self:getYongBingId() then
		else
			number = number + 1
			table.insert(retList, role)
		end
	end

	return retList, number
end

-- @desc 判断是否是玩家副本
function BaseMap:isUserMap()

	local role = User:getRole()
	local fq = role:getHomelandAttr("fq")
	if not fq then
		return false
	end

	if not self.mid then
		return false
	end

	if tonumber(self.mid) == tonumber(fq.mid) then
		return true
	else
		return false
	end
end

--获取指定房间的属性，默认为当前房间
function BaseMap:getRoomAttr(roomId)
	roomId = Helper:getDef(roomId,self:getCurrRoomId())
	return self.room[roomId]
end

--@desc: 设置副本的类型
--@author:Liang SongQiang
--@time:2018-09-11 14:13:34
--@map_type: 0、普通副本，1、家园副本（自己），2、家园副本（玩家）
function BaseMap:__setMapType(map_type)
	self.__mapType = map_type or MAP_TYPE.BASE
end

function BaseMap:getMapType()
	return self.__mapType
end

function BaseMap:lockCurrRoom(lockMsg)
	return self:lockRoom(self.__currRoomId,lockMsg)
end

function BaseMap:unlockCurrRoom()
	return self:unlockRoom(self.__currRoomId)
end

--@desc: 房间上锁
--@author:Liang SongQiang
--@time:2018-09-27 10:02:04
function BaseMap:lockRoom(roomId,lockMsg)
	local room = self:getRoomById(roomId)
	room.lock = true
	room.lockMsg = lockMsg or ""
end

--@desc: 房间解锁
--@author:Liang SongQiang
--@time:2018-09-27 10:12:03
function BaseMap:unlockRoom(roomId)
	local room = self:getRoomById(roomId)
	room.lock = nil
	room.lockMsg = nil
end

--@desc: 设置副本锁，用来处理能否对整个副本进行升级和还原
function BaseMap:__setMapLock(mapLock)
	mapLock = Helper:getDef(mapLock,{})
	self.status = mapLock
end

--@desc: 加一条副本锁
function BaseMap:addMapLock(id,lockMsg)
	local MapLock = Helper:getDef(self:__getMapLock(),{})
	if not MapLock[id] then
		MapLock[id] = {
			id = id,
			lockMsg = lockMsg
		}

		self:__setMapLock(MapLock)
	end
end

--@desc: 获取副本锁
function BaseMap:__getMapLock()
	return Helper:getDef(self.status,{})
end

--@desc: 删除一条副本锁
function BaseMap:deleteOneMapLock(id)
	local MapLock = Helper:getDef(self:__getMapLock(),{})
	if MapLock[id] then
		MapLock[id] = nil

		self:__setMapLock(MapLock) 
	end
end

--判断副本能否重建（暂时是房屋升级和房屋还原）
function BaseMap:cheakUserMapIsRebuild()
	local MapLock = Helper:getDef(self:__getMapLock(),{})
	if not MapIsEmpty(MapLock) then
		for k, v in pairs(MapLock) do
			return false,Helper:getDef(v.lockMsg,"您的房屋暂时无法进行")
		end
	else
		local rooms = self:getRoomMap()
		for roomId , roomInfo in pairs(rooms) do
			if roomInfo.lock == true then
				return false, Helper:getDef(roomInfo.lockMsg,"您的房屋暂时无法进行")
			end
		end
	end

	local role = User:getRole()
	local plantInfo = role:getHomelandAttr("plant")
    
    if not MapIsEmpty(plantInfo) then
        return false ,"您有土地正在种植或者有植物未收取，无法进行"
    end
	
	return true
end

--@desc 计算房间类型数量
function BaseMap:addRoomTypeCount(roomType,num)
	if MapIsEmpty(self.roomCountByType) then
		self.roomCountByType = {}
	end

	if roomType == nil then
		return
	end

	local currCount = self.roomCountByType[roomType] or 0

	self.roomCountByType[roomType] = math.max(currCount + num,0)
end

function BaseMap:getRoomCountByType( roomType )
	if MapIsEmpty(self.roomCountByType) or self.roomCountByType[roomType] == nil then
		return 0
	end

	return tonumber(self.roomCountByType[roomType]) or 0
end

--@desc 计算家具类型数量
function BaseMap:addFurTypeCount(furType,num)
	if MapIsEmpty(self.furCountByType) then
		self.furCountByType = {}
	end

	if furType == nil then
		return
	end

	furType = math.abs(furType)

	local currCount = self.furCountByType[tostring(furType)] or 0

	self.furCountByType[tostring(furType)] = math.max(currCount + num,0)
end

function BaseMap:getFurTypeCount( itype )
	itype = math.abs(itype)
	if MapIsEmpty(self.furCountByType) or self.furCountByType[tostring(itype)] == nil then
		return 0
	end

	return tonumber(self.furCountByType[tostring(itype)]) or 0
end

--@desc 计算人物职业数量
function BaseMap:addPersonJobCount(jobType,num)
	if MapIsEmpty(self.personCountByJob) then
		self.personCountByJob = {}
	end
	
	if jobType == nil then
		return
	end

	if num == nil then
		num = 0
	end
	
	local currCount = self.personCountByJob[jobType] or 0

	self.personCountByJob[jobType] = math.max(currCount + num,0)

	--@desc 管家只能有一个，避免计数错误的情况
	if jobType == "guanjia001" and self.personCountByJob[jobType] > 1 then
		self.personCountByJob[jobType] = 1
	end
end

--@desc: 获取人物职业类型在副本中的的个数
--@author:Liang SongQiang
--@time:2018-12-03 15:13:11
--@jobType: 职业类型
function BaseMap:getPersonTypeCount( jobType )
	if MapIsEmpty(self.personCountByJob) or self.personCountByJob[jobType] == nil then
		return 0
	end

	return tonumber(self.personCountByJob[jobType]) or 0
end

function BaseMap:getPlayer()
	--@TODO 2019-09-30 11:47:56 暂时避免报错，角色写完后再进行处理。
	local player = Helper:getDef(self.player,User:getRole())

	if player == nil then
        assert(false, "map is not player!!!!!  " .. self.id)
	end
	
	return player
end

function BaseMap:setPlayer(role)
	if MapIsEmpty(role) then
		assert(false,"BaseMap:setPlayer(role) !!!")
		return	
	end
	self.player = role
end

function BaseMap:setMapFightState(fightState)
	self._isInFighting = fightState
end

function BaseMap:getMapFightState()
	return self._isInFighting
end
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------

-- Decorator:replaceAll(BaseMap,
-- 	function(funcName, func, ...)
-- 		print("funcName = "..tostring(funcName))

-- 		local ret
-- 		local params = {...}
-- 		return PerformanceAnalysis(funcName, function()
-- 			return func(unpack(params))
-- 		end)
-- 	end)

-- 加密标记
BaseMap.isEncrypted = true
return BaseMap
0000000000000000