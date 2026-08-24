local RoomUI = require("app.views.ui.MapUI.RoomUI")
local TotalMapUI = require("app.views.ui.MapUI.TotalMapUI")

local MapLayer = class("MapLayer", require("app.views.base.BaseLayer"))
local MapInfo = require("app.models.map.MapInfo")

local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")

--@RefType [app.models.map.UserStatusMapRelation#UserStatusMapRelation]
local UserStatusMapRelation = require("app.models.map.UserStatusMapRelation")

local MAP_SHOW_TYPE_NONE = 0
local MAP_SHOW_TYPE_9 = 1
local MAP_SHOW_TYPE_TOTAL = 2

local function log(...)
	print("MapLayer:", ...)
end

function MapLayer:create()
	local p = MapLayer:new()
	p:init()
	return p
end

function MapLayer:ctor()

	--@desc 订阅
	self._subscriptions = {}
end

-- 初始化，不能主动调用
function MapLayer:init()
	self._mapShowType = MAP_SHOW_TYPE_NONE
	self._currRoom = nil
	self._currRoomUI = nil
	self._currMap = nil

	self.totalMapHide = false

	self._preMapId = nil
	
	-- 初始化地图UI
	self:initMapUI()

	-- 设置地图显示类型
	self:setMapShowType(MAP_SHOW_TYPE_9)

	-- 设置定时器
	self:schedule(
		function(ft)
			self:update(ft)
    	end)

end

local function setCallGuanJia(cond,text)
	if cond == nil then
		cond = true
	end
	return function (self)
		if cond== false then
			PopText(text)
		end
		return cond
	end
end
function MapLayer:setConditonCallGuanjia(condition,text)
	self.canCallGuanjia = setCallGuanJia(condition,text)
end

-- 主要方法 ----------------------------------------------------------------------------------
-- 设置地图
function MapLayer:setMap(map)   
	assert(map, "map == null")
	Helper:clearIntervalFunc("MapLayer.refreshMapTest")
	
	self._needRefreshMap = false
	self:setLayerClick(false)

	if self._preMapId ~= nil and self._preMapId ~= map.id then
		local preMap = User:getRole():getMapById(self._preMapId)

		if preMap and not MapIsEmpty(preMap.doResultFun) then
			preMap.doResultFun = {}
		end
	end

	map:init()

	self._currMap = map
	self._preMapId = map.id 
	User:getRole():setCurrMapId(map.id)

	self._currRoom = assert(self:getDefaultRoom())

	map:setCurrRoomId(self._currRoom.id)

	map._mapLayer = self

	map.__MapLayer = self

	--@RefType [app.models.map.MapHandle.MapHandle#MapHandle]
	local MapHandle = require("app.models.map.MapHandle.MapHandle")
	MapHandle:entryMap(map)

	self.Text_totalMap:setVisible(false)

	-- add by XiaoZhiWei 2018/05/10 21:45:38 地图属性改造之后再初始化全图, 全副本地图需要的修改
	self:initTotalMapUI(map.mapAppearance, map.mapAppearanceIndex)

	self.TotalMapBtn_IsInit = false

	-- 地图显示初始化设置
	self:setMapShowType(MAP_SHOW_TYPE_9)

	self.Text_totalMap:move(cc.p(915, 1365))
	if self._currMap:getMapType() == MAP_TYPE.MYHOME then
		self.Text_totalMap:setString("呼唤管家")
		self.totalMapHide = false
	elseif self._currMap:getMapType() == MAP_TYPE.DREAMMAP then
		self:setTotalMapHide()

		--@desc 暂时使用这种处理
		local DreamModel = require("app.models.DreamWorldModel.DreamModel")
		DreamModel:clearInfo()
		DreamModel:enterRoom(map,self._currRoom.id)
		
		local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
		MapRoleLayer:refreshDreamRoleAttrUI()

		--@desc 设置物品数量显示
		self:setItemCount()

		--@desc 设置梦境碎银文本
		self:setDreamPointText()
	elseif self._currMap:getMapType() == MAP_TYPE.FONDDREAMMAP then
		self:setTotalMapHide()

		local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
		MapRoleLayer:refreshDreamRoleAttrUI()
	else
		self.Text_totalMap:setString("查看全图")
		self.totalMapHide = false
	end
	
	if Map:getMapVersionByMapId(map.id) == EDITOR_MAP_VERSION then

	else
		-- 进入副本刷新条件结果
		local results = map:doRoomConditionAndResult(self._currRoom.id,
		{
			operation = "进入房间",
			roomId = self._currRoom.id,
			currRoomId = nil,
			mapLayer = self,
			currRole = nil
		})
		map:refreshYongBingRole(self._currRoom.id)
		map:refreshFollowRoles(self._currRoom.id)
		map:refreshMapProbabilityFunc("进入房间") -- add by XiaoZhiWei 2017/08/30 20:10:49 暂时放在这里
	end

	-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
	if User:getRole():getFlag("PVP战斗状态") == "离线模式" or Map:getMapState(map.id) ~= MAP_STATE.COMPLETE then
		self._currMap:updateRoomWebRoles(self._currRoom.id, {})
	else
	end

	Map:setPreMapId(map.id)

	self:initMapUIByMapType()

	self:delayRefreshMap()
end

function MapLayer:enterMap(map)
	self:setMap(map)
	
	-- 初始化观察者
	self:initObserver()
end

function MapLayer:switchMap(map)
	self:deInitObserver()
	
	self:setMap(map)
	
	-- 初始化观察者
	self:initObserver()
end

--@desc 初始化观察者
function MapLayer:initObserver()
	log("MapLayer:initObserver", self)

	if #self._subscriptions == 0 and self._currMap ~= nil then
		local BaseMap = require("app.models.map.BaseMap")

		do
			local subscription = self._currMap:subscribe(BaseMap.EventType.ROLE_DIE_QUITMAP_EVENT, 
				function()
					self:quit()
				end)

			table.insert(self._subscriptions, subscription)
		end
		
		local subscription = self._currMap:subscribe(BaseMap.EventType.ROLE_ATTR_CHANGE_EVENT, 
			function(eventName, attrName, new, old, change)
				self:registerAttrChangeFunc(attrName, new, old, change)
			end)

		table.insert(self._subscriptions, subscription)

		do
			local subscription = self._currMap:subscribe(BaseMap.EventType.ROLE_RESURGENCE_REPLACEROOM_EVENT, 
				function()
					self:replaceRoom(self._currMap.entryRoom1)
				end)

			table.insert(self._subscriptions, subscription)
		end
	end
end

--@desc 反初始化观察者
function MapLayer:deInitObserver()
	log("MapLayer:deInitObserver", self)

	if #self._subscriptions > 0 then
		for i, v in ipairs(self._subscriptions) do
			v:unsubscribe()
		end

		self._subscriptions = {}
	end 
end

function MapLayer:onDisable()
	MessageCenter:removeObjListener(self)
end

--@desc 注册属性变化调用函数
function MapLayer:registerAttrChangeFunc(attrName, new, old, change)
	local map = self._currMap
	local role = self._currMap:getPlayer()
	switch(attrName,{
		["dreamPoints"] = function()
			self:setDreamPointText()
		end,
		default = function()
			local mapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
			mapRoleLayer:refreshDreamRoleAttrUI()
		end
	})
end

-- 隐藏查看全图
function MapLayer:setTotalMapHide()
	self.totalMapHide = true
end

-- 获得默认房间
function MapLayer:getDefaultRoom()
	assert(self._currMap, "self._currMap == null")
	local player = User:getRole()
	-- --回家默认房间（entryType  1大门、0门前）
	-- if self._currMap.__entryType==1 and self._currMap.entryRoom2 then 
	-- 	self._currMap.__entryType=0
	-- 	return self:getRoom(self._currMap.entryRoom2)
	-- end
	if player:isMapCompleted(self._currMap.id) and self._currMap.entryRoom2 then
		return self:getRoom(self._currMap.entryRoom2)
	end

	return self:getRoom(self._currMap.entryRoom1)

end

-- 根据方向进入房间
function MapLayer:entryRoomByDirection(direction)
	-- 关闭这大地图的移动方式
	if true then
		return
	end

	if PRINT_MODE == 1 then
		print("direction = "..direction)
	end
	assert(self._currRoom)
	if self._currRoom == nil then
		if PRINT_MODE == 1 then
			print("self._currRoom == nil")
		end
		return
	end
	if self._currRoom.link == nil then
		if PRINT_MODE == 1 then
			print("self._currRoom.link == nil")
		end
		return
	end
	local toRoomId = self._currRoom.link[direction]
	if toRoomId == nil then
		if PRINT_MODE == 1 then
			print("toRoomId == nil")
		end
		return
	end
	self:entryRoom(self._currRoom.id, toRoomId, direction)
end

-- 刷新地图
function MapLayer:refreshMap(atonce)
	self._needRefreshMap = false

	-- 刷新房间
	self:refreshRoom()
	-- 刷新人物
	self:refreshRole()

	-- 刷新UI
	self:refreshUI()
end

-- 显示当前房间
function MapLayer:refreshRoom()
	local roomId = assert(self._currRoom.id)

	if self._mapShowType == MAP_SHOW_TYPE_9 then
		if self._currRoomUI == nil then
			self._currRoomUI = self:createRoom(roomId)
		end

		local UserMap = require("app.models.map.UserMap")
		local roomType = self._currMap.room[self._currRoom.id].roomType
		if UserMap:isOpenEnlarge() == true and UserMap:checkIsSpecailRoom(roomType) == false then
			self.Text_itemDsc:setString("可扩建为：")
			self:setEnlargeButton()
			self._currRoomUI:setRoomForEnlarge(self._currRoom,
			function(fromRoomId, roomId, direction)
				if PRINT_MODE == 1 then
					print(roomId)
				end
				PopText("该房间已存在，不能被扩建")
				-- self:entryRoom(fromRoomId, roomId, direction)
			end,
			function(direction)
				local ret, rtype = UserMap:checkCanEnlarge()
				if ret == true then
					self:enlargeRoom(direction, rtype)
				end
			end)	
		else
			self.Text_itemDsc:setString("这里有：")
			self._currRoomUI:setRoom(self._currRoom,
			function(fromRoomId, roomId, direction)
				if PRINT_MODE == 1 then
					print(roomId)
				end
				self:entryRoom(fromRoomId, roomId, direction)
			end)			
		end


		if self._currMap.mid ~= nil or self._currMap:getMapType() == MAP_TYPE.DREAMMAP or self._currMap:getMapType() == MAP_TYPE.FONDDREAMMAP then
			return
		end
		
		-- 刷新大地图
		self._currRoom.haveBeenTo = true
		local roomMap = self._currMap:getRoomMap()
		for k, room in pairs(roomMap) do
			if room.haveBeenTo then
				self._totalMapUI:setRoomShowType(room.id, "可见")
			else
				if room.mapHide == 1 then
					self._totalMapUI:setRoomShowType(room.id, "隐藏")
				else
					self._totalMapUI:setRoomShowType(room.id, "不可见")
				end
			end
		end		

	elseif self._mapShowType == MAP_SHOW_TYPE_TOTAL then
		self._currRoom.haveBeenTo = true
		local roomMap = self._currMap:getRoomMap()
		for k, room in pairs(roomMap) do
			if room.haveBeenTo then
				self._totalMapUI:setRoomShowType(room.id, "可见")
			else
				if room.mapHide == 1 then
					self._totalMapUI:setRoomShowType(room.id, "隐藏")
				else
					self._totalMapUI:setRoomShowType(room.id, "不可见")
				end
			end
		end

		local toRoom = self:getRoom(roomId)
		if toRoom == nil then
			if PRINT_MODE == 1 then
				print("toRoom = nil")
			end
			return
		end
		if PRINT_MODE == 1 then
			print("去房间"..toRoom.name)
		end
		self._currRoom = toRoom
		self._totalMapUI:scrollToRoom(self._currRoom.id)
		self._totalMapUI:setAllRoomColor(cc.c3b(255, 255, 255))
		self._totalMapUI:setRoomColor(self._currRoom.id, cc.c3b(255, 0, 0))
	end
end

-- 刷新当前房间角色
local MapAddNpcAndItem = require("app.views.layer.MapLayer.MapAddNpcAndItem")
function MapLayer:refreshRole()
	local totalRoleList = {}
	local roleList = self._currMap:getRoomRoleList(self._currRoom.id)
	self._currRoom.playList = {}--房间玩家列表 add by Gao Hanzheng
	--排序，将玩家放置list队尾
	if roleList then
		for i, roleId in ipairs(roleList) do
			local role = self._currMap:getRole(roleId)
			if role then
				if role.isForbidden == true then
					-- 禁止 则不显示
				else
					if role.type == "role" then
						if role.canSee == false or role.canSee == 0 and role.id == self._currMap:getYongBingId() then
						else
							
							table.insert(totalRoleList, role)
						end
					elseif role.type == "item" then
						if role.canSee == true or role.canSee == 1 then
							table.insert(totalRoleList, role)
						end
					end
				end
			end
		end
		--排序，将玩家放置list队尾
        local  roleListFromWeb = {} --初始化全玩家list
		for i= #totalRoleList,1, -1 do
			local role = totalRoleList[i]
			if role.isFromWeb == true or role.x_type == "denglong" then
				table.insert(roleListFromWeb, role) 
                table.remove(totalRoleList,i)  
			end
		end

		if MapIsEmpty(roleListFromWeb) == false then
			local key = "joinTime"
			table.sort(roleListFromWeb, function(a, b)
				if a[key] == nil then
					return false
				elseif b[key] == nil then
					return true
				else
					return a[key] > b[key]
				end
			end)
		end
		self._currRoom.playList = roleListFromWeb

		for i, v in ipairs(roleListFromWeb) do
			if v.x_type == "denglong" then
				table.insert(totalRoleList,1, v) 
			else
				table.insert(totalRoleList, v) 
			end
		end

	end
    
	-- 第十个副本的32号房间  添加 NPC 程药发
	if self._currMap.id == "fb10" and self._currRoom.id == "fb10_32" then
		for k,role in pairs(totalRoleList) do
			if role:getName() == "程药发" then
				table.remove(totalRoleList, k)
				break
			end
		end
	end

	MapAddNpcAndItem:createNpc(self._currMap.id,self._currRoom.id,totalRoleList)
	MapAddNpcAndItem:createItem(self._currMap.id,self._currRoom.id,totalRoleList)

	self.Text_dsc:setColor(cc.c3b(102, 153, 153))
	self.Text_dsc_1:setColor(cc.c3b(102, 153, 153))
	self:setText_dsc(self._currRoom.dsc)
	self:setRoleList(totalRoleList)

end

function MapLayer:getShenBingDataAndCreateTuDui(totalRoleList, func)
	local function createTuDui(v) 
		local num = v.index
		local _type = v.type
		local role =
		{
			type = "item",
			id = "tudui"..num,
			dsc = "树影婆娑，斑驳的光影泼洒在这堆黄土之上，凄冷的风挟带这悠长的笛声，这剑冢之中不知埋藏了多少剑客的遗恨。 心头中默然响起掩埋神兵之日，便是重铸之时。",
			canThrow = _type,--能否操作
		}
		if _type == 0 then
			role.name = "土堆"
		else
			role.name = "剑冢"
			role.dsc = ""
		end
		role.__data = v.data.data
		role = Helper:tableCover(require("app.models.item.BaseItem"):create(),role)
		table.insert(totalRoleList,role)
	end
	--加一个判断。只有进入房间次访问，在房间就不刷新了
	--有问题。一秒刷新一次，不是卡死
	HttpManagerEx:getThrowWeaponData(function(status, errcode, errmsg, data)
		if 200 == status then
			if 0 == errcode then
				local role = User:getRole()
				for i,v in pairs(data) do
					--是0显示土堆
					if v.type  then
						createTuDui(v)
					end
				end
				if func then
					func()
				end
			else
				PopText(tostring(errmsg))
			end
		else
    		PopText("网络请求出错,请换个网络环境再试!")
		end
	end, IS_SHOW_WAITING)
end
--
function MapLayer:getRoom(roomId)
	if PRINT_MODE == 1 then
		print(roomId)
	end
	return assert(self._currMap.room[roomId], "roomId = "..tostring(roomId))
end

-- UI部分 ------------------------------------------------------------------------------------

-- 初始化地图界面UI
function MapLayer:initMapUI()
	self._UI = require("Layer/MapUI/MapUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUI(self)

	-- 初始化全图显示模式
	-- self:initTotalMapUI()

	-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
	-- add by XiaoZhiWei 2017/06/14 10:39:21 江湖切磋按钮
	self.Text_history:setVisible(false)
	self:setHistory()

	self:setUseBaoWuButton()

	self:setTipsButton()

	self:setTextTotalMap()
end

function MapLayer:setTextTotalMap()
	-- 切换地图显示模式按钮
	self.Text_totalMap:setTouchEnabled(true)
	self.Text_totalMap:releaseFunc(function()
		if self._currMap:getMapType() == MAP_TYPE.MYHOME then
			self.determine_time = Helper:getDef(self.determine_time,0)
			if GetTime() - self.determine_time < 2 then
				PopText("您呼唤的太频繁了，请稍等片刻。")
				return
			end
			self.determine_time = GetTime()
			--@desc 判断能否呼唤管家
			if not self:canCallGuanjia() then
				return
			end
			
			local currRoomHaveGj = false
			local currFjId = self._currRoom.id
			local currRoomRoleList = self._currMap:getRoomRoleList(currFjId)
			for k,v in pairs(currRoomRoleList) do --判断管家是否在当前房间
				if v == "guanjia1001" then
					currRoomHaveGj = true
				end
			end
			if currRoomHaveGj == true then
				RichPrint("main","您的管家就在这里，你有什么事情直接跟他说就好了。")
			else
				local text ={
				"你运足内力，大喊了一声管家，声音传至整个房屋。",
				"不多时，管家一路小跑了过来，走到了你的身旁。"
				}
				for i = 1, #text do
					self:delayFunc((i - 1) * 1,               
						function()
							RichPrint("main", text[i])		

							if i == #text then
							
								local gjCurrRoom

								local roomMap = self._currMap:getRoomMap()
								for k,v in pairs(roomMap) do
									local roleList = self._currMap:getRoomRoleList(k)
									if roleList  then
										for ker,value in pairs(roleList) do
											if value == "guanjia1001" then
												gjCurrRoom = k
											end
										end
									end
								end
								if gjCurrRoom then
									self._currMap:removeRoomRole(gjCurrRoom, "guanjia1001")
									MapInfo:addRoleToRoom(self._currMap, currFjId, "guanjia1001")
								end
								self:refreshMap()
							end
						end
					)
				end
			end
		else
			if self._mapShowType == MAP_SHOW_TYPE_9 then
				-- 显示全图
				self:setMapShowType(MAP_SHOW_TYPE_TOTAL)
				self:delayRefreshMap()
				self.Text_totalMap:move(cc.p(915, 877))
				self.Text_totalMap:setString("关闭全图")
				self.Text_history:setVisible(false)
			elseif self._mapShowType == MAP_SHOW_TYPE_TOTAL then
				-- 关闭全图
				self:setMapShowType(MAP_SHOW_TYPE_9)
				self:delayRefreshMap()
				self.Text_totalMap:move(cc.p(915, 1365))
				self.Text_totalMap:setString("查看全图")
				self.Text_history:setVisible(true)
			end
		end
	end)
end


-- 初始化完整地图UI
function MapLayer:initTotalMapUI(mapData, mapIdData)
	if self._currMap.mid ~= nil then
		return
	end
	if self._totalMapUI == nil then
		self._totalMapUI = TotalMapUI:create(self.Panel_totalMap, mapData, mapIdData,
			function(index)
				if PRINT_MODE == 1 then
					print("index = "..index)
				end
				local indexToDirectionMap =
				{
					"leftDown",
					"down",
					"rightDown",
					"left",
					"center",
					"right",
					"leftUp",
					"up",
					"rightUp"
				}
				self:entryRoomByDirection(assert(indexToDirectionMap[index]))
			end)
		-- self._totalMapUI:addChild(cc.Sprite:create("test.png"))
		self.Panel_totalMap:addChild(self._totalMapUI)
		self._totalMapUI:setAnchorPoint(cc.p(0, 0))
	else
		self._totalMapUI:initWithMapData(self.Panel_totalMap, mapData, mapIdData,
			function(index)
				if PRINT_MODE == 1 then
					print("index = "..index)
				end
				local indexToDirectionMap =
				{
					"leftDown",
					"down",
					"rightDown",
					"left",
					"center",
					"right",
					"leftUp",
					"up",
					"rightUp"
				}
				self:entryRoomByDirection(assert(indexToDirectionMap[index]))
			end)
	end
end


function MapLayer:setMapShowType(showType)
	if self._mapShowType == showType then
		return
	end
	self._mapShowType = showType
	if self._mapShowType == MAP_SHOW_TYPE_9 then
		self.Text_dsc_1:setVisible(true)
		self.Text_mapDsc:setVisible(true)
		self.Panel_totalMap:setTouchEnabled(false)
		self.Panel_totalMap:setVisible(false)

		self.Panel_map:setTouchEnabled(true)
		self.Panel_map:setVisible(true)
	elseif self._mapShowType == MAP_SHOW_TYPE_TOTAL then
		self.Text_dsc_1:setVisible(false)
		self.Text_mapDsc:setVisible(false)
		self.Panel_map:setTouchEnabled(false)
		self.Panel_map:setVisible(false)

		self.Panel_totalMap:setTouchEnabled(true)
		self.Panel_totalMap:setVisible(true)
		self:delayRefreshMap()
	end
end

function MapLayer:setText_dsc(dsc)
	if self._currMap:getMapType() == MAP_TYPE.DREAMMAP then
		self.Text_dsc:setTextAreaSize(cc.size(1000, 0))
		self.ScrollView_1:jumpToPercentVertical(0)
		self.Text_dsc:setString(dsc)
		-- print("self.Text_dsc:getSizeHeight() = ",self.Text_dsc:getSizeHeight())
		if self.Text_dsc:getSizeHeight() > 285 then
			self.ScrollView_1:setTouchEnabled(true)
		else
			self.ScrollView_1:setTouchEnabled(false)
		end
	else
		self.Text_dsc_1:setString(dsc)
	end
end

function MapLayer:setItemCount()
	if not self._currMap then
		return
	end
	local player = self._currMap:getPlayer()
	if player == nil or self._currMap:getMapType() ~= MAP_TYPE.DREAMMAP then
		return
	end
	local xuhundengCount = player:getItemCount("drwp103")
	local baowuList = player:getItems(
		function(item)
			local itemId = item.itemId
			local itemAttr = Item:getOneItemByKey(itemId)
			return itemAttr.treasure == 1
		end
	)

	local baowuCount = 0

	if not MapIsEmpty(baowuList) then
		for i, v in pairs(baowuList) do
			baowuCount = baowuCount + v.count
		end
	end
	
	local yaoshi1Count = player:getItemCount("drwp101")
	local yaoshi2Count = player:getItemCount("drwp102")

	self.Text_2:setString("续魂灯："..xuhundengCount)
	self.Text_3:setString("异宝："..baowuCount)
	self.Text_4:setString("铜环钥："..yaoshi1Count)
	self.Text_5:setString("百解钥："..yaoshi2Count)
end

function MapLayer:setDreamPointText()
	local player = self._currMap:getPlayer()
	if player == nil or self._currMap:getMapType() ~= MAP_TYPE.DREAMMAP then
		return
	end
	local dreamPoints = player:getAttr("dreamPoints")
	self.Text_1:setString("碎银："..dreamPoints)
end

--根据副本类型初始化ui
function MapLayer:initMapUIByMapType()
	if self._currMap:getMapType() == MAP_TYPE.DREAMMAP then
		self.Text_dsc_1:setVisible(false)
		self.ScrollView_1:setVisible(true)
		self.Panel_dreamAttr:setVisible(true)
		self.Panel_anniu:setVisible(true)
	else
		self.Text_dsc_1:setVisible(true)
		self.ScrollView_1:setVisible(false)
		self.Panel_dreamAttr:setVisible(false)
		self.Panel_anniu:setVisible(false)
	end
end

function MapLayer:setUseBaoWuButton()
	self.Panel_anniu:releaseFunc(function()
		local role = User:getRole()
		local prepareTalent = role:getAttr("PrepareTalent")

		if MapIsEmpty(prepareTalent) then
			PopText("尚未准备周公之术主动技能")
			return
		end
		PopupLayerController:showLayer(
			"UseTalentLayer",
			function(layer)
                layer:showLayer(prepareTalent,self._currMap)
            end
        )
	end)
end

function MapLayer:setTipsButton()
	self.Panel_tips:addTouchEventListener(
	function(ref, eventType)
		if eventType == ccui.TouchEventType.began then
			self.Image_7:setVisible(false)
		elseif eventType == ccui.TouchEventType.ended then
			local role = self._currMap:getPlayer()
			local items = {}
			if role then
				items = role:getItems(
					function(item)
						local itemId = item.itemId
						local itemAttr = Item:getOneItemByKey(itemId)
						return itemAttr.treasure == 1
					end
				)
			end
			PopupLayerController:showLayer(
				"ItemDetailPopLayer",
				function(layer)
					layer:showLayer("宝物",items)
					layer:setPanelBack(function()
						self.Image_7:setVisible(true)
					end)
				end
			)
		elseif eventType == ccui.TouchEventType.canceled then
			self.Image_7:setVisible(true)
		end
	end)
end

function MapLayer:createRoom(roomId)
	if PRINT_MODE == 1 then
		print("roomId = "..tostring(roomId))
	end

	local room = RoomUI:create()
	room.mapLayer = self
	self.Panel_map:addChild(room)
	room:setRoom(self:getRoom(roomId),
		function(fromRoomId, roomId, direction)
			if PRINT_MODE == 1 then
				print("fromRoomId = "..tostring(fromRoomId))
				print("roomId = "..tostring(roomId))
				print("direction = "..tostring(direction))
			end
			self:entryRoom(fromRoomId, roomId, direction)
		end)
	return room
end
function MapLayer:setUnmoveRoom(loop,func)
	if loop  then 
		self._unmove = loop 
		if func then
			self._unmoveFunc = func
		end
	else
		self._unmove = false
	end
	if self._unmove == false then
		self._unmoveFunc = nil 
	end
end
function MapLayer:replaceRoom(roomId, direction,isShowText)

	if isShowText == nil then
		isShowText = true
	end

	if direction == nil then
		direction = "center"
	end

	local lastRoomId = self._currRoom.id

	if self._mapShowType == MAP_SHOW_TYPE_9 then
		local animDuration = 0.2

		if self._currRoomUI == nil then
			self._currRoomUI = self:createRoom(roomId)

		else
			local oppDirection = Helper:getOppositeDirection(direction)
			local fromUI = self._currRoomUI
			local toUI = self:createRoom(roomId)

			local formButton = fromUI:getRoomButton(direction)
			local toButton = toUI:getRoomButton("center")

			local formButtonWordPos = formButton:convertToWorldSpace(cc.p(0, 0))
			local toButtonWordPos = toButton:convertToWorldSpace(cc.p(0, 0))
			local offsetPos = cc.pSub(formButtonWordPos, toButtonWordPos)
			local toStartPos = cc.pAdd(cc.p(toUI:getPosition()), offsetPos)

			if PRINT_MODE == 1 then
				print("formButtonWordPos = "..formButtonWordPos.x..", "..formButtonWordPos.y)
				print("toButtonWordPos = "..toButtonWordPos.x..", "..toButtonWordPos.y)
			end

			toUI:setPosition(toStartPos)

			toUI:fadeIn(
				offsetPos,
				animDuration,
				function(ui)
				end)

			fromUI:fadeOut(
				offsetPos,
				animDuration,
				function(ui)
					ui:removeFromParent()
				end)
			--@desc 全局遮罩
			PopupLayerController:showLayer("GlobalShadeLayer",function (layer)
				layer:setPopText("")
				layer:showTime(0.3)
			end)
			self._currRoomUI = toUI

		end

		self._currRoom = self:getRoom(roomId)
	elseif self._mapShowType == MAP_SHOW_TYPE_TOTAL then
		local toRoom = self:getRoom(roomId)
		if toRoom == nil then
			if PRINT_MODE == 1 then
				print("toRoom = nil")
			end
			return
		end
		if PRINT_MODE == 1 then
			print("去房间"..toRoom.name)
		end
		self._currRoom = toRoom
		self._totalMapUI:scrollToRoom(self._currRoom.id)
		self._totalMapUI:setAllRoomColor(cc.c3b(255, 255, 255))
		self._totalMapUI:setRoomColor(self._currRoom.id, cc.c3b(255, 0, 0))
	end

	-- 设置房间状态为去过
	self._currRoom.haveBeenTo = true
	local lastRoom = self:getRoom(lastRoomId)
	if MapIsEmpty(lastRoom.webItemList) == false then
		for k, v in ipairs(lastRoom.webItemList) do 
			self._currMap:removeRoomRole(lastRoomId,v)
		end
		lastRoom.webItemList = {}
	end 

	-- 播放音效
	self:playStepSound(lastRoomId, roomId)
	self:playRoomMusic(self._currRoom)

	if isShowText then
		RichPrint("main", "WHT你进入了【"..tostring(self._currRoom.name).."】。")
	end
	self._currMap:setCurrRoomId(roomId)
	self:delayRefreshMap()
end

--@desc: 创建高级按钮
--@author:Liang SongQiang
--@time:2018-08-10 17:08:42
function MapLayer:createAdvancedButton()
	local roleButton = Resource:getUIByName("Button_JiaJu1")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end

--@desc: 创建Best按钮
--@author:Liang SongQiang
--@time:2018-08-10 17:09:31
function MapLayer:createBestButton()
	local roleButton = Resource:getUIByName("Button_JiaJu2")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end

function MapLayer:createNpcButton(role)
	local index = 0
	if role then
		index = role.btnImg or 0
	end
	--@RefType [app.views.layer.RoleLayer.RoleResConf#RoleResConf]
	local RoleResConf = require("app.views.layer.RoleLayer.RoleResConf")
	local btnName = RoleResConf:getBtnImgName(index)
	local roleButton = Resource:getUIByName(btnName)
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/15 11:50:33
-- @desc 创建偶遇玩家按钮
function MapLayer:createPlayerButton()
	local roleButton = Resource:getUIByName("Button_7")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end


-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/27 16:21:34
-- @desc 特殊物品按钮
function MapLayer:createWebItemButton()
	local roleButton = Resource:getUIByName("Button_webItem")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/03 16:50:10
-- @desc 创建江湖人士按钮
function MapLayer:createJiangHuButton()
	local roleButton = Resource:getUIByName("Button_8")
	Helper:convertUI(roleButton)
	roleButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return roleButton
end



--创建江湖人士按钮
function MapLayer:setJiangHuRoleButton(currRoleIndex,posX,posY)
	local roleButton = self:createJiangHuButton()
    self.Panel_item:addChild(roleButton)
    roleButton.Text_buttonName:setString("江湖人士")
    roleButton:move(posX, posY)
    roleButton:releaseFunc(function()
    	FubenClient:getAllRoomPlayers(self._currMap.id, self._currRoom.id)
    	PopupLayerController:showLayer("PlayerListLayer", function(layer)
			layer.mapLayer = self
			layer:showWithRollLeft()
    	end)
    end)
    self._JiangHuRolesButton = roleButton
    return currRoleIndex + 1
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/16 20:48:20
-- @desc 创建玩家按钮
function MapLayer:setPlayerButton(currRoleIndex,role,posX,posY)
    if role.id == self._currMap:getYongBingId() and User:getRole():getFlag("佣兵模式") == "开启" then
    	role = self._currMap:getYongBingRole()
    end
    role.name = Helper:getDef(role.name, "")-- 描述如果为空,gsub会报错
    role.dsc = Helper:getDef(role.dsc, "")-- 描述如果为空,gsub会报错
    role.name = string.gsub(role.name, "$N", " " .. User:getRoleAttr("name"))
    role.dsc = string.gsub(role.dsc, "$IN", User:getRoleAttr("inherit").name)
    role.dsc = string.gsub(role.dsc, "$N", User:getRoleAttr("name"))
	local roleButton = self:createPlayerButton()
    roleButton:releaseFunc(function()
    	if User:getRole():getFlag("副本状态") == "忙碌" and role.needState ~= 1 then
    		PopText("您正在做别的事情，无法进行此操作。")
    		return
		end
		
    	PopupLayerController:showLayer("RoleObserveLayer", function(layer)
    		-- add by XiaoZhiWei 2017/06/22 17:01:06 只需要从服务器获取一次
        	if role.inheritRoleDsc == nil then
            	local map = User:getRole():getCurrMap()
				local onlyId = Helper:getOnlyId()
            	map:setCallBack(function(eventName, params)
            		if eventName == "成功查看" then
						role.inheritRoleDsc = Helper:getDef(jsonpvp.decode(params.body), {}).inheritRoleDsc
						role.prayRoomId = Helper:getDef(jsonpvp.decode(params.body), {}).prayRoomId
						local successResult = OperationFactory:createResult("PVPFight")
						role.operations = {}
						table.insert(role.operations,OperationFactory:createNoConditionBtnOperation("切磋",{successResult}))
	                    layer:showLayer(role,"MAP")
            		end
            	end)
            	FubenClient:chakan(role.id, onlyId)
        	else
                layer:showLayer(role,"MAP")
			end
    	end)
	end)
	self.Panel_item:addChild(roleButton)
	roleButton.Text_buttonName:setString(role.name)
	roleButton:move(posX,posY)
	return currRoleIndex + 1
end



-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/02/26 16:03:28
-- @desc 创建物品按钮
function MapLayer:setWebItemButton(currRoleIndex,role,posX,posY)
    if role.id == self._currMap:getYongBingId() and User:getRole():getFlag("佣兵模式") == "开启" then
    	role = self._currMap:getYongBingRole()
    end
    role.name = Helper:getDef(role.name, "")-- 描述如果为空,gsub会报错
    role.dsc = Helper:getDef(role.dsc, "")-- 描述如果为空,gsub会报错
    role.name = string.gsub(role.name, "$N", " " .. User:getRoleAttr("name"))
    role.dsc = string.gsub(role.dsc, "$IN", User:getRoleAttr("inherit").name)
    role.dsc = string.gsub(role.dsc, "$N", User:getRoleAttr("name"))
	local roleButton = self:createWebItemButton()
	roleButton.clickTime = 0
	self._currRoom.webItemList = Helper:getDef(self._currRoom.webItemList,{})
	table.insert(self._currRoom.webItemList,role.id)
    roleButton:releaseFunc(function()
    	if User:getRole():getFlag("副本状态") == "忙碌" and role.needState ~= 1 then
    		PopText("您正在做别的事情，无法进行此操作。")
    		return
		end

    	if GetTime() - roleButton.clickTime < 5 then
    		-- PopText("您刚刚看过这个灯笼，请稍等一会再看吧。")
    		RichPrint("main","您刚刚看过这个灯笼，请稍等一会再看吧。")
    		return
    	end
    	roleButton.clickTime = GetTime()
    	PopupLayerController:showLayer("RoleObserveLayer", function(layer)
    		-- add by XiaoZhiWei 2017/06/22 17:01:06 只需要从服务器获取一次
        	if role.inheritRoleDsc == nil then
            	local map = User:getRole():getCurrMap()
				local onlyId = Helper:getOnlyId()
            	map:setCallBack(function(eventName, params)
            		if eventName == "成功查看" then
            			role.inheritRoleDsc = Helper:getDef(jsonpvp.decode(params.body), {}).inheritRoleDsc
            			role.prayRoomId = Helper:getDef(jsonpvp.decode(params.body), {}).prayRoomId
            			role.remainTimes = Helper:getDef(jsonpvp.decode(params.body), {}).remainTimes
            			local names = Helper:getDef(jsonpvp.decode(params.body), {}).names
            			role.dismissTime = Helper:getDef(jsonpvp.decode(params.body), {}).dismissTime
            			role.answerValue = Helper:getDef(jsonpvp.decode(params.body), {}).answerValue
            			role.subTime = Helper:getDef(jsonpvp.decode(params.body), {}).currentTime - GetTime()
	                    layer.mapLayer = self
	                    layer:showLayer()
						role.sex = "男"
						role.type = "item"
						role.name = "灯谜灯笼"
						role.dsc = "这红灯笼之上雕刻着精美的花纹，在火烛的映射下，煞是好看，灯笼下吊着数条红带，每条红带上都有几行小字，你凑近看去方才发现是元宵节的灯谜。\n  \n"
						if MapIsEmpty(names) == false  then
							if (role.answerValue == 0 or role.answerValue == 1) or role.remainTimes <= 0 then
								local nameStr = ""
								local count = 10
								if role.answerValue == 0 then
								elseif role.answerValue == 1 then
									nameStr = "HIW" .. User:getRole():getName() .. "HIY"
									count = 9
									for k,v in ipairs(names) do 
										if v == User:getRole():getName() then
											table.remove(names,k)
											break
										end
									end
								end
								for k,v in pairs(names) do
									if k <= count then 
										v = "HIM" .. v .. "HIY"
										if nameStr == "" then
											nameStr = v
										else
											nameStr = nameStr .. "、".. v
										end
									else
										break
									end
								end
								nameStr = "HIY该灯谜已被"..nameStr.."HIY答对。"
								role.dsc = role.dsc .. nameStr
							end
						end

						role.canCompete = 0
						role.canUse1 = true
						role.canSee = true
						role.canTalk = false
						role.useName1 = "猜灯谜"
	                    role.conditionAndResults =
							{
								{
									conditionRelation = "and",
									conditions =
									{
										{
											arg1 = "玩家操作",
											arg2 = "使用1"
										}
									},
									results =
									{
										{
											arg1 = "元宵灯谜玩法",
											-- --@desc 兑换的物品ID
											arg2 = "yuanxiaodengmi1",
											-- --@desc 兑换面具列表
											arg3 = "yuanxiaodengmi2",
											-- arg4 = "你拿到了#name#"
										}
									}
								}
							}
						layer:showLayer(role,"MAP")
                        map:setCallBack(nil)
            		end
            	end)
            	FubenClient:chakanDenglong(role.id, onlyId)
        	else
                layer.mapLayer = self
                layer:showLayer(role,"MAP")
			end
    	end)
	end)
	self.Panel_item:addChild(roleButton)
	roleButton.Text_buttonName:setString(role.name)
	roleButton:move(posX,posY)
	return currRoleIndex + 1
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/16 21:05:04
-- @desc 创建NPC按钮
function MapLayer:setNPCButton(currRoleIndex,role,posX,posY)
    if role.id == self._currMap:getYongBingId() and User:getRole():getFlag("佣兵模式") == "开启" then
    	role = self._currMap:getYongBingRole()
    end
    role.name = Helper:getDef(role.name, "")-- 描述如果为空,gsub会报错
    role.dsc = Helper:getDef(role.dsc, "")-- 描述如果为空,gsub会报错
    role.name = string.gsub(role.name, "$N", " " .. User:getRoleAttr("name"))
    role.dsc = string.gsub(role.dsc, "$IN", User:getRoleAttr("inherit").name)
	role.dsc = string.gsub(role.dsc, "$N", User:getRoleAttr("name"))
	local roleButton = self:createNpcButton(role)
	
	roleButton:releaseFunc(function()
        if PRINT_MODE == 1 then
            print("name = " .. role.name, role.id)
		end
		
		--@desc 状态检查
		if UserStatusMapRelation:checkRoleStatus(self._currMap,User:getRole()) == false then
			print("正在干别的事情。")
			return
		end

    	if User:getRole():getFlag("副本状态") == "忙碌" and role.needState ~= 1 then
    		PopText("您正在做别的事情，无法进行此操作。")
    		return
		end

        -- 佣兵信息重新获取一次,有可能有更新 (刷新处理)
	    if role.id == self._currMap:getYongBingId() and User:getRole():getFlag("佣兵模式") == "开启" then
	    	role = self._currMap:getYongBingRole()
        end
    	if role.id == "ouyezi1" then
			PopupLayerController:showLayer("ShenBingMainObserveLayer",function(layer)
				layer:showLayer(2,true)
			end)
		else
			PopupLayerController:showLayer("RoleObserveLayer", function(layer)
				if role.type2 == "familyGroup" then
					layer:showLayer(role,"MAP_FM")
				elseif role.id == "newdrwp02b" then
					--@desc 棋盘暂时用这种方式处理
					layer:showLayer(role,"MAP_CHESS")
				else
					layer:showLayer(role,"MAP")
				end
            end)
    	end
    end)
	self.Panel_item:addChild(roleButton)
	roleButton.Text_buttonName:setString(role.name)
	roleButton:move(posX,posY)
	return currRoleIndex + 1
end

function MapLayer:setRoleList(roleList)
    self.Panel_item:removeAllChildren()

    do
	   	-- add by XiaoZhiWei 2018/06/05 14:20:59 按钮刷新的时候,扩建相关的按钮需要去除掉
	    self.Panel_item.EnlargeCancel = nil
		self.Panel_item.EnlargeKongFang = nil
		self.Panel_item.EnlargeChangLang = nil
	end

    local currRoleIndex, roleMax = 1, #roleList
    if DEBUG_MODE == 1 then
    	roleMax = roleMax + 1
    end
    Helper:foreachItemInMatrixArea(self.Panel_item:getContentSize(), self:createNpcButton():getContentSize(), 3, 3, 80, 10,
        function(index, ix, iy, x, y)
        	-- add by XiaoZhiWei 2017/06/05 17:51:37 如果数量超过了9个则不需要继续显示,反正也显示不出来
            if currRoleIndex > roleMax or currRoleIndex > 9 then
                return
            end
            if (DEBUG_MODE == 1 and currRoleIndex == roleMax) or (roleMax > 9 and currRoleIndex == 9) then
            	currRoleIndex = self:setJiangHuRoleButton(currRoleIndex,x, y)
            else
            	local role = roleList[currRoleIndex]
	            -- local roleButton = self:createNpcButton()
	            if role.isFromWeb == true then
	            	if role.x_type == "denglong" then
	            		currRoleIndex = self:setWebItemButton(currRoleIndex,roleList[currRoleIndex],x, y)
	            		print("-----------------------denglong1-------------------------------")
	            	else
						currRoleIndex = self:setPlayerButton(currRoleIndex,roleList[currRoleIndex],x, y)
					end
	            else
	            	if role.x_type == "denglong" then
	            		currRoleIndex = self:setWebItemButton(currRoleIndex,roleList[currRoleIndex],x, y)
	            	else
		            	currRoleIndex = self:setNPCButton(currRoleIndex,roleList[currRoleIndex],x, y)
		            end
	            end
            end
        end)
end

-- 进入房间
function MapLayer:entryRoom(fromRoomId, roomId, direction)
	local roomMap = self._currMap:getRoomMap()
	local room = roomMap[roomId]

	if PRINT_MODE == 1 then
		print( "fromRoomId = " .. fromRoomId .. " -> " .. roomId )
	end

	local bool = PopupLayerController:checkLayerIsShow("RoleObserveLayer")

	if bool then
		local layer = PopupLayerController:getLayer("RoleObserveLayer")
		layer:hideLayer(true)
	end
	self.Panel_item:setSelfAndChildrenCancelButtonFunc()

	local player = self._currMap:getPlayer()
	-- local currMap = player:getCurrMap()

	--@desc 状态检查
	if UserStatusMapRelation:checkRoleStatus(self._currMap,player) == false then
		print("正在干别的事情。")
		return
	end


	-- 将上个房间编号记录在地图里面
	if self._currRoom then
		self._currMap.__last_Room = self._currRoom.id
	end

	if Map:getMapVersionByMapId(self._currMap.id) == EDITOR_MAP_VERSION then
		--@desc 检查能否进入新副本房间
		self:checkCanEnterNewMapRoom(self._currMap,player,fromRoomId, roomId, direction)
	else
		self:enterOldMapRoom(self._currMap,player,fromRoomId, roomId, direction)
	end

end

--@desc: 检查能否进入新副本房间
function MapLayer:checkCanEnterNewMapRoom(currMap, player, fromRoomId, roomId, direction)
	currMap:doRoomOperation("离开房间",fromRoomId,roomId)

	-- 判断当前房间是否可离开
	if tonumber(currMap:getRoomAttr(fromRoomId).canLeave) ~= 1 then
		print("无法离开")
		return false
	end

	-- 判断将要进入的房间是否可进入
	if tonumber(currMap:getRoomAttr(roomId).enterable) ~= 1 and currMap:getRoomAttr(roomId).enterable ~= true then
		--@desc 房间上锁，判断是否能解锁
		if currMap:getRoomAttr(roomId).roomKey == 1 then
			local keyId = nil
			local enterText = ""
			local showText = ""
			if player:getItemCount("drwp101") > 0 then
				keyId = "drwp101"
				enterText = "你将铜环钥插入锁孔，轻轻一拧，咔哒一声，门锁应声开启，手中的铜环钥也随之消散。"
				showText = "一扇铁门挡住去路，门锁结构简单，用铜环钥便能开启，是否用钥匙开门？"
			elseif player:getItemCount("drwp102") > 0 then
				keyId = "drwp102"
				enterText = "你将百解钥插入锁孔，正正反反连拧数圈，门锁终被打开。忽地手指一松，百解钥竟似消失了。"
				showText = "一扇厚重的铁门拦住，门锁设计精巧，用百解钥方能开启，是否用钥匙开门？"
			end

			if keyId then
				local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
				local dialog = DialogALayer:getInstance()
				dialog:hide()
				dialog:show(showText)
				dialog:setButton1("确定",function()
					--@desc 确认开锁，暂时这样处理，可以把开锁功能抽出来
					player:addItemCount(keyId,-1)
					currMap:getRoomAttr(roomId).enterable = 1
					currMap:getRoomAttr(roomId).roomKey = 2
					self:enterNewMapRoom(currMap,player,fromRoomId, roomId, direction)
					RichPrint("main",enterText)
				end)
				dialog:setButton2("取消",function()
				end)
				dialog:setWeChatVisible(false)
			else
				PopText("缺少钥匙，无法进入")
			end
		else
			print("无法进入")
		end
	else
		self:enterNewMapRoom(currMap,player,fromRoomId, roomId, direction)
	end
end

--@desc: 新副本执行逻辑
--@author:Liang SongQiang
--@time:2018-12-03 11:14:35
--@currMap: [src.app.models.map.BaseMap#BaseMap]
function MapLayer:enterNewMapRoom(currMap, player, fromRoomId, roomId, direction)
	MessageCenter:notify("leaveRoomEvent", {map = currMap, roomId = fromRoomId})

	--@desc 暂时使用这种处理
	if currMap:getMapType() == MAP_TYPE.DREAMMAP then
		local DreamModel = require("app.models.DreamWorldModel.DreamModel")
		DreamModel:leaveRoom(currMap,fromRoomId)
	elseif currMap:getMapType() == MAP_TYPE.FONDDREAMMAP then
		--@desc 删除房间角色列表
		local drSystem = User:getRole():getDreamSystem()
		drSystem:deleteRoleList(currMap, fromRoomId)
	end
	
	print("房间ID ：", roomId)
	
	self:replaceRoom(roomId,direction)

	--@region 修复一进入房间就删除跟随人物的操作后的bug
	currMap:refreshFollowRoles(roomId, fromRoomId)
	--@endregion 
	
	currMap:setCurrRoomId(roomId)

	-- 执行进入房间操作
	currMap:doRoomOperation("进入房间",roomId)

	currMap:refreshFollowRoles(roomId, fromRoomId)

	--@desc enterRoomEvent事件发放
	MessageCenter:notify("enterRoomEvent", {map = currMap, roomId = roomId, fromRoomId = fromRoomId})

	--@desc 暂时使用这种处理
	if currMap:getMapType() == MAP_TYPE.DREAMMAP then
		local DreamModel = require("app.models.DreamWorldModel.DreamModel")
		DreamModel:enterRoom(currMap,roomId)
	end

	if DEBUG_MODE == 1 then
		FubenClient:comeIn(currMap.id, roomId, currMap:getRoomNameById(roomId), Helper:getOnlyId())
	else
		-- add by XiaoZhiWei 2017/06/19 17:13:54 设置0.6秒延时,连续点击的情况则不会多次请求
		self:delayFunc(
			0.6,
			function()
				if self._currRoom.id == roomId then
					FubenClient:comeIn(currMap.id, roomId, currMap:getRoomNameById(roomId), Helper:getOnlyId())
				end
			end
		)
	end
end

function MapLayer:enterOldMapRoom(currMap, player, fromRoomId, roomId, direction)
	local roomMap = self._currMap:getRoomMap()
	local room = roomMap[roomId]

    -- add by XiaoZhiWei 2018/05/25 16:36:19 家园系统开关判断
    do
        if JIAYUAN_SYSTEM_IS_OPEN == true then
            local toRoom = self:getRoom(roomId)

			print("房间ID ：", roomId, "地皮ID ：", toRoom.flag)
			
            HomelandRoomUtil:updateRoomAttr(self._currMap, room)
            -- add by XiaoZhiWei 2018/05/25 16:36:34 在公共地图进入副本的情况下走当前判断入口
            local ret = self:entryUserRoom(toRoom.mid, toRoom.uid) -- add by XiaoZhiWei 2018/05/11 09:26:37 进入玩家副本房间
            if ret == true then
                return
            end
            if room.roomType and room.roomType == "tsfangjian002" then
                local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
                HomelandRoomUtil:jumpToMapInOutDoor(self._currMap, self._currRoom)
                return
            end
        end
    end

    -- add by XiaoZhiWei 2018/05/25 16:39:17 离开房间概率事件判断
    do
        local ret = currMap:refreshMapProbabilityFunc("离开房间")

        if ret == "阻止玩家移动" then
            return
        else
        end
    end

    -- 离开房间
    local results =
        currMap:doRoomConditionAndResult(
        fromRoomId,
        {
            operation = "离开房间",
            roomId = roomId,
            currRoomId = fromRoomId,
            mapLayer = self,
            currRole = role
        }
    )

    -- print("results:1111111111111111111111111111111111111111111111111111111111111111")
    -- Helper:print_lua_table(results)

    if results["阻止玩家移动"] then
        -- local role = results["阻止玩家移动"]
        -- RichPrint("main", role.name..": 想要过去?有没有问问RED大爷NOR我?")
    elseif results["攻击玩家"] then
    else
        if self._unmove and self._unmove == true then
            self._unmoveFunc()
            return
        end
		
		MessageCenter:notify("leaveRoomEvent", {map = currMap, roomId = fromRoomId})

        self:replaceRoom(roomId, direction)
        -- add by XiaoZhiWei 2017/06/20 16:42:30 离线模式 或者 未通关该副本或者  需要清空房间的所有的偶遇玩家
        if User:getRole():getFlag("PVP战斗状态") == "离线模式" or User:getRole():isMapCompleted(self._currMap.id) == false then
            currMap:updateRoomWebRoles(roomId, {})
        else
        end

        currMap:setCurrRoomId(roomId) -- add by XiaoZhiWei 2017/10/16 16:07:16 需要先设置房间,然后再执行该房间的条件结果
        -- 进入房间
        local roomName = self._currRoom.name
		local player = User:getRole()
		
		-- 修复一进入房间就删除跟随人物,出现的bug
		currMap:refreshFollowRoles(roomId, fromRoomId)

        local results =
            currMap:doRoomConditionAndResult(
            roomId,
            {
                operation = "进入房间",
                roomId = fromRoomId,
                currRoomId = roomId,
                mapLayer = self,
                currRole = role
            }
        )

        currMap:refreshYongBingRole(roomId, fromRoomId) -- add by XiaoZhiWei 2017/10/31 12:05:41 参数传递错误,解决章作之问题
        currMap:refreshFollowRoles(roomId, fromRoomId)
        currMap:refreshMapProbabilityFunc("进入房间") -- add by XiaoZhiWei 2017/08/30 20:10:49 暂时放在这里
        --鬼差任务判断
        if currMap.id == "fb201" then
            self:entryGuiChaiRoom(currMap, player, roomId, fromRoomId)
		end
		
		--@desc enterRoomEvent事件发放
		MessageCenter:notify("enterRoomEvent", {map = currMap, roomId = roomId, fromRoomId = fromRoomId})

        if DEBUG_MODE == 1 then
            FubenClient:comeIn(currMap.id, roomId, currMap:getRoomNameById(roomId), Helper:getOnlyId())
        else
            -- add by XiaoZhiWei 2017/06/19 17:13:54 设置0.6秒延时,连续点击的情况则不会多次请求
            self:delayFunc(
                0.6,
                function()
                    if self._currRoom.id == roomId then
                        FubenClient:comeIn(currMap.id, roomId, currMap:getRoomNameById(roomId), Helper:getOnlyId())
                    end
                end
            )
        end
    end

    -- -- add by XiaoZhiWei 2018/05/25 16:39:51 师门任务判断
    -- do
    --     if TEACHER_TASK_IS_OPEN == true then
    --         local TeacherTask = require("app.models.task.teacherTask.teacherTask")
    --         TeacherTask:createTeacherTaskNPCWithTypeTwo(self, self._currMap.id, roomId)
    --         TeacherTask:createQuanZhenDuoBaoNPC(self._currMap, self._currMap.id, roomId)
    --     end
    -- end

    -- add by XiaoZhiWei 2018/05/25 16:40:02 刷新副本UI
    self:delayRefreshMap()
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 15:00:48
-- @params 
-- @desc 鬼差任务逻辑部分处理
function MapLayer:entryGuiChaiRoom(currMap, player, roomId, fromRoomId)
	local list = {
		zyputong1	= true,
		zybansheng1	= true,	
		zybansheng2	= true,	
		zyshounue1	= true,
		zyshounue1a	= true,	
		zyqiecuo1	= true,
		zyqiecuo1a	= true,
		zydubo1		= true,
		zydubo1a = true,
	}

	local currRoom = currMap:getRoomById(roomId)
	
	local roleList = currRoom.roleList
	local hasRole = false
	for _, rRoleId in pairs(roleList) do
		if list[rRoleId] then
			hasRole = true
			break
		end
	end
	
	if not hasRole then
		local info = Helper:getDef(player:getAttr("ghostInfo"), {})
		local jindu = player:getFlag("酆都任务进度")
		if not MapIsEmpty(info) and jindu == 1 then
			if roomId == info.roomId then
				local npcName = info.npcName
				local npcDesName = info.npcDesName
				local npcRole = currMap:getRole(info.npcId)
				local npcSex = info.npcSex
				local npcDsc = info.npcDsc
				
				npcRole:setAttr("name", npcName)
				npcRole:setAttr("des_name",npcDesName)
				npcRole:setAttr("sex",npcSex)
				npcRole:setAttr("dsc",npcDsc)

				currMap:addRoomRole(roomId, npcRole.id)
				if info.npcId == "zyshounue1"  then
					print("受虐型")
					local switchId = "zyshounue1a"
					local npcRole_a = currMap:getRole(switchId)
					npcRole_a:setAttr("name",npcName)
					npcRole_a:setAttr("des_name",npcDesName)
					npcRole_a:setAttr("sex",npcSex)
					npcRole_a:setAttr("dsc",npcDsc)

					--伴生型
					local npcRole_1 = currMap:getRole("zybansheng1")
					npcRole_1:setAttr("name","男鬼")
					npcRole_1:setAttr("dsc",info.bStr1)
					currMap:addRoomRole(roomId,npcRole_1.id)

					local npcRole_2 = currMap:getRole("zybansheng2")
					npcRole_2:setAttr("sex","女")
					npcRole_2:setAttr("dsc",info.bStr2)
					npcRole_2:setAttr("name","女鬼")
					currMap:addRoomRole(roomId,npcRole_2.id)

				elseif info.npcId == "zyqiecuo1" then
					print("切磋型")
					local switchId = "zyqiecuo1a"
					local npcRole_a = currMap:getRole(switchId)
					npcRole_a:setAttr("name",npcName)
					npcRole_a:setAttr("des_name",npcDesName)
					npcRole_a:setAttr("sex",npcSex)
					npcRole_a:setAttr("dsc",npcDsc)

				elseif info.npcId == "zydubo1" then 
					print("赌博型")
					local switchId = "zydubo1a"
					local npcRole_a = currMap:getRole(switchId)
					npcRole_a:setAttr("name",npcName)
					npcRole_a:setAttr("des_name",npcDesName)
					npcRole_a:setAttr("sex",npcSex)
					npcRole_a:setAttr("dsc",npcDsc)
				end
			end
		end
		--偶遇恶鬼
		if jindu == 1 then
			currMap:refreshDevilRole(roomId, fromRoomId)
		end
	end
end

-- 刷新界面UI
function MapLayer:refreshUI()
	local roomName = self._currRoom.name

	if PRINT_MODE == 1 then
		print("MapLayer:refreshUI() roomName = "..tostring(roomName))
	end
	-- 设置标题显示当前房间名
	local mapRoleLayer = self.ControllLayer:getLayer("MapRoleLayer")
	mapRoleLayer:setTitle(Helper:getDef(roomName, "不知名的地方"))
	local UserMap = require("app.models.map.UserMap")
	-- add by XiaoZhiWei 2018/06/05 17:59:22 扩建状态下不需要刷新这个按钮
	if self._unmove ~= true and UserMap:isOpenEnlarge() ~= true then
		if self._currMap and (self._currMap:getMapType() == MAP_TYPE.DREAMMAP or self._currMap:getMapType() == MAP_TYPE.FONDDREAMMAP) then
			local player = self._currMap:getPlayer()
			mapRoleLayer:exitButtonFunc(true,nil,player.dreamWorld.cFloor.."层")
		else
			mapRoleLayer:exitButtonFunc(true)
		end
		
	end
end

-- 初始化地图音乐
function MapLayer:initMapMusic()
	self._currEffectId = nil
end

-- 关闭音乐
function MapLayer:stopMusic()
	Audio:stopAllEffects()

	Audio:stopMusic()

	self._currMusicBGM =  ""
end

-- 播放地图音乐
function MapLayer:playMapMusic()
	if PRINT_MODE == 1 then
		print( "  MapLayer:playMapMusic()  self._currMusicBGM=" ..  tostring( self._currMusicBGM ) .. " bgm=" .. tostring( self._currMap.BGM ) )
	end

	if self._currMusicBGM ~= self._currMap.BGM then
		self._currMusicBGM = self._currMap.BGM
		self._currMusicId = Audio:playMusic( self._currMap.BGM, true )
	end
end

-- 房间音乐
function MapLayer:playRoomMusic(room)
	local bgm, bgmRule, bgmSpaceTime, bgmDown = room.roomBgm, room.roomBgmRule, room.spaceTime, room.BgmDown

	if bgmDown == 1 then
		Audio:setMusicVolume(0.5)
	else
		Audio:setMusicVolume(1)
	end

	if PRINT_MODE == 1 then
		print( "  MapLayer:playRoomMusic() gmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgmbgm = " .. tostring(bgm) .. " fbgmRule=" .. tostring(bgmRule))
	end

	if bgm == nil or bgm == "" then
		self:playMapMusic()
		return
	end

	--self:stopMusic()
	if self._currMusicBGM ~= bgm then
		self._currMusicBGM = bgm

		if tonumber(bgmRule) == 1 then
			self._currEffectId = Audio:playMusic( bgm , true )
		else
			self._currMusicId = Audio:playMusic( bgm , false )
		end
	end
end

-- 播放脚步声
function MapLayer:playStepSound(fromRoomId, toRoomId)
	local fromRoom = self:getRoom(fromRoomId)
	local toRoom = self:getRoom(toRoomId)

	local fromSound = fromRoom.stepMusic
	local toSound = toRoom.stepMusic

	assert(fromSound and toSound, "fromSound = "..tostring(fromSound)..", toSound = "..tostring(toSound))

	Audio:playEffectWithCallback(fromSound, false, 0.3,
	function(effectId)
		Audio:playEffect(toSound, false)
	end)
end

-- 传送房间
function MapLayer:teleportRoom(roomId)
	self:entryRoom(self._currRoom.id, roomId, "center")
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 设置需要刷新地图
function MapLayer:setNeedRefreshMap()
	self._needRefreshMap = true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 延时刷新地图
function MapLayer:delayRefreshMap()
	self._needRefreshMap = true
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新地图
function MapLayer:refreshMapTest()
	if self._needRefreshMap then
		self:refreshMap()
		self:refreshButtonJiangHu()
		self:setLayerClick(true)
	end

	-- add by XiaoZhiWei 2017/07/03 16:14:38 通关 免打扰模式 非全图状态 偶遇开启 才能够显示该提示内容
	-- if User:getRole():isMapCompleted(self._currMap.id) == true and User:getRole():getFlag("PVP战斗状态") == "免打扰模式" and self._mapShowType == MAP_SHOW_TYPE_9 and Game:isOpenEncounter() == true then
	if User:getRole():getFlag("PVP战斗状态") == "免打扰模式" and self._mapShowType == MAP_SHOW_TYPE_9 then
		local list = MapPVP:getUnReadInvitation()
		if #list > 0 then
			self.Text_history:setString("有人向你发起切磋请求（"..tostring(#list).."）")
			self.Text_history:setVisible(true)
		else
			self.Text_history:setVisible(false)
		end
	else
		self.Text_history:setVisible(false)
	end

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/04 15:13:26
-- @desc 刷新江湖人士按钮
function MapLayer:refreshButtonJiangHu()
	-- add by XiaoZhiWei 2017/07/03 16:59:31 江湖人士按钮文本刷新
	if self._JiangHuRolesButton ~= nil and self._JiangHuRolesButton.Text_buttonName then
		local roleList = MapPVPRoles:getMapRoomRoleList(self._currMap.id, self._currRoom.id)
		local npcList, npcNum = self._currMap:getCurrRoomNpcListAndNumber()
		if #roleList + Helper:getRange(npcNum - 8 , 0) > 0 then
			self._JiangHuRolesButton.Text_buttonName:setString("江湖人士（"..tostring(#roleList + Helper:getRange(npcNum - 8 , 0)).."）")
		end
	end
end



-- 地图刷新
function MapLayer:update(ft)
	DoFuncWithInterval("MapLayer.refreshMapTest",
	function()
		self:refreshMapTest()
	end, 0.1)

	if self._currMap then
		-- map调度器
		self._currMap:scheduleFunc(ft)

		-- delayTaskUpdate
		DoFuncWithInterval("MapLayer.currMap.delayTaskUpdate",
		function()
			self._currMap:delayTaskUpdate()
		end, 2)

		DoFuncWithInterval("MapLayer.updateMapInfoOrStatus",
		function()
			if self._currMap:getMapType() == MAP_TYPE.MYHOME then
				local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
				if HomelandRoomUtil:roomIsCallup(self._currMap.room[self._currRoom.id].roomType) and HomelandRoleUtil:currMapHaveGj(self._currMap) 
					and self._isShowHhgj ~= 1 then
					self.Text_totalMap:setVisible(true)
				else
					self.Text_totalMap:setVisible(false)
				end
			else
				if User:getRole():isMapCompleted(self._currMap.id) and not self.TotalMapBtn_IsInit then
					self.Text_totalMap:setVisible(true)
					self.TotalMapBtn_IsInit = true
				end
	
				if self.totalMapHide == true then
					self.Text_totalMap:setVisible(false)
				end
			 end
			 
			if User:getRole():isMapCompleted(self._currMap.id) then
				if PRINT_MODE == 1 then
					-- print("地图已经通关")
				end
			else
				if Map:getMapVersionByMapId(self._currMap.id) == FORM_MAP_VERSION then
					local canCompleteConditionIndex = self._currMap:getCanCompleteConditionIndex()
	
					if canCompleteConditionIndex > 0 then
						-- 设置需要刷新地图
						self:delayRefreshMap()
		
						self._currMap:setCompleted() -- 设置地图为已通过状态
		
						if PRINT_MODE == 1 then
							print("地图通关 111111111")
						end
						local player = User:getRole()
						if player:isMapCompleted(self._currMap.id) then
							PopText("之前已经通关,没有奖励!!!")
						else
							-- 通关
							player:setMapCompleted(self._currMap.id)
		
							-------------------------------------------------------------------
							------------ 友盟接入
							if device.platform == "ios" then
								Mob.finishLevel(self._currMap.index)
							end
		
							PopupLayerController:showLayer("TongGuanPopLayer", function(layer)
								layer:maxZ()
								layer:show(player, self._currRoom, "通关")
								layer:setCompleteMainText(self._currMap:getAwardDesc(canCompleteConditionIndex))
								layer:setQuitFunc("离开副本" ,
									function()
										self:userQuit()
									end)
								layer:setButton2("继续探索")
							end)
							-- 获得通关奖励
							self._currMap:getMapCompleteAward(canCompleteConditionIndex)
						end
		
						-- 刷新当前房间
						self:replaceRoom(self._currRoom.id, "center",false)
					else
						-- print("地图尚未通关")
					end
				end
			end
	
			User:getRole():setFlag(self._currMap.id, GetTime())
		end, 0.1)
	end
end

function MapLayer:userQuit()
	self:quit()
end

function MapLayer:quit(showText)
	log("quit")

	self:stopMusic()

	-- 界面切换
	if showText ~= false then
		PopText("你退出了副本")
	end

	self:quitData()
	self:__quitLayer()
end

function MapLayer:quitData()
	self:delayFunc(0.1,function()
		self:deInitObserver()
	end)
	-- 离开副本
	local currMap = User:getRole():getCurrMap()
	currMap:leaveMap()
	
	User:getRole():setFlag("PVP活动状态","空闲中")

	User:getRole():setFlag("副本状态","空闲中")

	if self._currRoom and self._currRoom.id then
		if MapIsEmpty(self._currRoom.webItemList) == false then
			for k, v in ipairs(self._currRoom.webItemList) do 
				self._currMap:removeRoomRole(self._currRoom.id,v)
			end
			self._currRoom.webItemList = {}
		end
	end
end

function MapLayer:__quitLayer()
	self.ControllLayer:popLayer()
	self.ControllLayer:getLayer("MapRoleLayer"):onPause()
	self.ControllLayer:getLayer("MapRoleLayer"):hide()
	self.ControllLayer:getLayer("MapRoleLayer"):setVisible(false)

	if self._currRoomUI then
		self.Panel_map:removeChild(self._currRoomUI)
		self._currRoomUI = nil
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2017/04/07 18:23:55
-- @desc 得到房间之间的向量
function MapLayer:getTotalMapRoomVector(fromRoomId, toRoomId)	
	local fromRoomNode = self._totalMapUI:getRoomById(fromRoomId).node -- 通过totalMapUI获得大地图中的房间节点 add by TangJian 2017/04/07 18:30:51
	local toRoomNode = self._totalMapUI:getRoomById(toRoomId).node
	if fromRoomNode and toRoomNode then
			local fontWith
			do
				local roomNodeNameArray = string.splitUTF8(fromRoomNode:getString())
				local count = #roomNodeNameArray
				fontWith = fromRoomNode:getContentSize().width / count 
			end

			local function getPos(roomNode)
				local roomNodeName = roomNode:getString()
				local roomNodeNameArray = string.splitUTF8(roomNodeName)
				local roomPos,toRoomPos
				roomPos = cc.p(roomNode:getPosition())
				
				local count = #roomNodeNameArray				
				if count % 2 == 0 then
				else
					roomPos.x = roomPos.x + fontWith / 2
				end
				return roomPos
			end

		local fromRoomNodePos = getPos(fromRoomNode)
		local toRoomNodePos = getPos(toRoomNode)
		
		if DEBUG_MODE == 1 then
			print("begin")
			print("fromRoomNodeName = ", fromRoomNode:getString())
			print("fromRoomNodePos = ", fromRoomNodePos.x, fromRoomNodePos.y)

			print("toRoomNodeName = ", toRoomNode:getString())
			print("toRoomNodePos = ", toRoomNodePos.x, toRoomNodePos.y)

			print("cc.pSub(toRoomNodePos, fromRoomNodePos) = ", cc.pSub(toRoomNodePos, fromRoomNodePos).x, cc.pSub(toRoomNodePos, fromRoomNodePos).y)

			print("end")
		end

		return cc.pSub(toRoomNodePos, fromRoomNodePos) -- 得到房间from到房间to的向量 add by TangJian 2017/04/07 19:27:45
	end
	return nil -- 如果到这来了, 也就是说找不到方向
end
--获取当前房间到目的房间的向量
function MapLayer:getCurrRoomTotalMapRoomVector(toRoomId)
	if toRoomId == nil then
		return
	end
	return self:getTotalMapRoomVector(self._currRoom.id,toRoomId)
end
-- 获取目的房间到当前房间的距离 
function MapLayer:getRoomToCurrRoomDistance(roomId)

end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/14 10:11:52
-- @desc 江湖切磋按钮
function MapLayer:setHistory()
	self.Text_history:releaseFunc(function()
		-- PopText("这里打开江湖切磋界面")
		PopupLayerController:showLayer("PVPWaitingLayer", function(layer)
			layer:show()
			layer:setTitleText("江湖切磋")
			layer:showHistory(MapPVP:getData())	
		end)
	end)
end

--屏蔽人物的触摸
function MapLayer:setNPCTouchEnabled(loop,func)
	loop = Helper:getDef(loop,false)
	self.Panel_touch:setVisible(loop)
	self.Panel_touch:releaseFunc(function()
		if func then
			func()
		end
	end)
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--  玩家副本相关方法

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/11 09:24:57
-- @params 
-- @desc 公共地图进入玩家副本的方法入口
function MapLayer:entryUserRoom(mapId, userid)
	if mapId == nil or userid == nil then
		return false
	end
	--@RefType [app.models.role.Role#Role]
	local role = User:getRole()

	local mid = role:getHouseId()

	if mapId ~= mid then
		if role:getTimeLimitFlag("inUserMap") > 0 then
			PopText("你刚刚才进入别人家中，还是稍等一下。")
			return true
		end
	end

	local UserMap = require("app.models.map.UserMap")
	local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
	UserMap:getUserMap(mapId, userid, function(map,isSuccess)
		do
			if isSuccess == false then
				return
			end

			role:setTimeLimitFlag("inUserMap",1,10)

			FubenClient:disconnect()
			self:delayFunc(0.1,
			function()	
				map:setCallBackAndConnect(function()
					-- entryMapLayer:hide(function()
					-- 	RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
					-- end) -- 隐藏界面
					local dirMark = map.dirMark
					if map:getMapType() == MAP_TYPE.MYHOME or map:getMapType() == MAP_TYPE.OTHERHOME then
						self:stopMusic()
					end
					self:setMap(map)
					HomelandRoomUtil:updateRoomAttr(map,map:getRoomById(map:getDefaultRoomId()))
					map.__MapLayer:replaceRoom(map:getDefaultRoomId(),UserMap:getHouseDirByIndex(map.dirMark))
					self:delayRefreshMap()
				end)
			end)
		end
	end)
	return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/04 12:14:46
-- @params 
-- @desc 扩建相关渲染
function MapLayer:enlargeRoom(direction, rtype)
	local ltype = "xuxian"
	self._currRoomUI:changeLine(direction, ltype)
	self._currRoomUI:changeKuang(direction, ltype)

	self:setEnlargeButton(direction, rtype)

	self.Text_itemDsc:setString("可扩建为：")
end

local lan = cc.c3b(80, 246, 244) -- add by XiaoZhiWei 2018/06/05 12:10:09 蓝色
local hui = cc.c3b(159, 159, 159) -- add by XiaoZhiWei 2018/06/05 12:10:21 灰色
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 13:40:14
-- @params 
-- @desc 扩建取消底部按钮
function MapLayer:setEnlargeButton(direction, rtype)
	if self.Panel_item.EnlargeCancel ~= nil then
	else
		self.Panel_item:removeAllChildren()
	end

	local UserMap = require("app.models.map.UserMap")

	-- add by XiaoZhiWei 2018/06/05 16:05:07 下方按钮的颜色以及 地图按钮名字的控制
	local buttonColorFunc = function(btnType, btnName)
		switch(btnType, {
			cancel = function()

				if self.Panel_item.EnlargeKongFang ~= nil then
					self.Panel_item.EnlargeKongFang:setColor(hui)

				end
				if self.Panel_item.EnlargeChangLang ~= nil then

					self.Panel_item.EnlargeChangLang:setColor(hui)
				end
			end,
			["空房"] = function()
				if self.Panel_item.EnlargeKongFang ~= nil then
					self.Panel_item.EnlargeKongFang:setColor(lan)
				end
				if self.Panel_item.EnlargeChangLang ~= nil then
					self.Panel_item.EnlargeChangLang:setColor(hui)
				end
			end,
			["长廊"] = function()
				if self.Panel_item.EnlargeKongFang ~= nil then
					self.Panel_item.EnlargeKongFang:setColor(hui)
				end
				if self.Panel_item.EnlargeChangLang ~= nil then
					self.Panel_item.EnlargeChangLang:setColor(lan)
				end
			end
		})

		local UserMap = require("app.models.map.UserMap")
		if btnType ~= "cancel" then
			self._currRoomUI:changeXuXianName(direction, btnType)
			UserMap:setEnlargeRoomInfo(self._currRoom.id, direction, btnType)
			rtype = btnType
		else
			self._currRoomUI:changeXuXianName(direction, nil)
			UserMap:setEnlargeRoomInfo(self._currRoom.id, direction, btnName, "cancel")
		end
	end

	-- add by XiaoZhiWei 2018/06/05 13:43:26 取消按钮
	do
		local cancelBtn = self.Panel_item.EnlargeCancel
		if cancelBtn == nil then
			cancelBtn = Resource:getUIByName("Panel_fangzi")
			Helper:convertUI(cancelBtn)
			cancelBtn:setSelfAndChildrenCascadeColorEnabled(true)
			cancelBtn.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
			self.Panel_item:addChild(cancelBtn)
			self.Panel_item.EnlargeCancel = cancelBtn
		end
		cancelBtn:setPosition(cc.p(915, 165))
		cancelBtn:setColor(hui)
		cancelBtn.Text_name:setString("取消")
		cancelBtn:releaseFunc(function()
			self:setEnlargeButton()
			if direction == nil then
				PopText("请先选择你要扩建的位置！")
				return
			end
			buttonColorFunc("cancel", Helper:getDef(rtype, "空房") )
			self._currRoomUI:changeKuang(direction, "kuojian")
			self._currRoomUI:changeLine(direction, "kuojian")
		end)
	end

	-- add by XiaoZhiWei 2018/06/05 13:43:37 空房按钮
	do
		local kongFangBtn = self.Panel_item.EnlargeKongFang
		if kongFangBtn == nil then
			kongFangBtn = Resource:getUIByName("Panel_fangzi")
			Helper:convertUI(kongFangBtn)
			kongFangBtn:setSelfAndChildrenCascadeColorEnabled(true)
			kongFangBtn.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
			self.Panel_item:addChild(kongFangBtn)
			self.Panel_item.EnlargeKongFang = kongFangBtn
		end
		kongFangBtn:setPosition(cc.p(165, 165))
		kongFangBtn:setColor(hui)
		kongFangBtn.Text_name:setString("空房")
		kongFangBtn:releaseFunc(function()
			if direction == nil then
				PopText("请先选择你要扩建的位置！")
				return
			end
			if UserMap:checkCanEnlarge("空房") == true then
				buttonColorFunc("空房")
			end 
		end)
	end

	-- add by XiaoZhiWei 2018/06/05 13:43:48 长廊按钮
	do
		local changLangBtn = self.Panel_item.EnlargeChangLang
		if changLangBtn == nil then
			changLangBtn = Resource:getUIByName("Panel_fangzi")
			Helper:convertUI(changLangBtn)
			changLangBtn:setSelfAndChildrenCascadeColorEnabled(true)
			changLangBtn.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
			self.Panel_item:addChild(changLangBtn)
			self.Panel_item.EnlargeChangLang = changLangBtn
		end
		changLangBtn:setPosition(cc.p(365, 165))
		changLangBtn:setColor(hui)
		changLangBtn.Text_name:setString("长廊")
		changLangBtn:releaseFunc(function()
			if direction == nil then
				PopText("请先选择你要扩建的位置！")
				return
			end
			if UserMap:checkCanEnlarge("长廊") == true then
				buttonColorFunc("长廊")
			end
		end)
	end

	-- add by XiaoZhiWei 2018/06/05 15:01:46 默认选中空房
	do
		if direction then
			if self._currRoomUI[direction] ~= true then
				self._currRoomUI:setXuXianButtonFunc(direction, 
					function(direction, rtype)
						self:setEnlargeButton(direction, rtype)
					end)
				self._currRoomUI[direction] = true
				-- local UserMap = require("app.models.map.UserMap")
				-- if UserMap.enlargeCurrRoomCountNor >= UserMap.enlargeRoomCountNormal then
				-- 	buttonColorFunc("长廊")
				-- end
				--[[如果空房到达上限，则默认选中长廊]]
			else
			end
			buttonColorFunc(rtype)
		end
	end
end

function MapLayer:onResume()
	HomelandRoomUtil:updateRoomAttr(self._currMap,self._currRoom)
	local MapRoleLayer = MainControllLayer:getLayer("MapRoleLayer")
	
	MapRoleLayer:statusButtonFunc(true)

	if self._currMap and (self._currMap:getMapType() == MAP_TYPE.DREAMMAP or self._currMap:getMapType() == MAP_TYPE.FONDDREAMMAP) then
		local player = self._currMap:getPlayer()
		MapRoleLayer:exitButtonFunc(true,nil,player.dreamWorld.cFloor.."层")
	else
		MapRoleLayer:exitButtonFunc(true)
	end
	
	self:setUnmoveRoom(false)
	self:setConditonCallGuanjia()
end

function MapLayer:initRoom()
	self._currRoomUI:initRoom()
end

function MapLayer:setLayerClick(bool)
	bool = not bool

	local isVisible = self.Panel_click:isVisible()
	
	if bool == isVisible then
		return
	end

	self.Panel_click:setVisible(bool)
end

-- 加密标记
MapLayer.isEncrypted = true
return MapLayer
0