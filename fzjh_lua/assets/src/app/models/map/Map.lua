local MapConstant = require("app.models.map.constant.MapConstant")
local MapFactory = require("app.models.map.factory.MapFactory")
local MapResHelper = require("app.models.map.MapResHelper")

local filterList = { -- 筛选列表
	fb200 = true,
	fb201 = true,
	fb203 = true,
	fb204 = true,
	fb205 = true,
	fb206 = true,
	fb207 = true,
	fb208 = true,
	fb209 = true,
	fb210 = true,
	fb211 = true,
	fb212 = true,
	fb213 = true,
	fb214 = true,
	fb215 = true,
	fb216 = true,
	fb217 = true,
	fb301 = true,
	fb302 = true,
	fb303 = true,
	fb304 = true,
	fb305 = true,
}

local sortMap = { -- 地图排序列表
	-- fb01 = {index = 10},
	-- fb10 = {index = 1},
}

--@desc 储存隐藏卷ID 
local hiddenVolume = {
	-- [volId] = true
}

local Map = {
	defaultMap = {},
	defaultMapList = {},
	defaultMapVolume = {},
	cacheMap = {},

	mapRandomNpc = {},
	mapRoleConditions = {},
	mapNpc = {}
}

-- local function print(...)
-- end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/11 10:50:55
-- @params 
-- @desc 创建方法
function Map:create()
	local p = inherit({}, Map)
	return p
end

--@desc 设置上次进入的
function Map:setPreMapId(mapId)
	if self._preMapId ~= nil and mapId ~= self._preMapId then
		local preMap = self.cacheMap[self._preMapId]
		
		if preMap ~= nil and (preMap:getMapType() == MAP_TYPE.DREAMMAP or preMap:getMapType() == MAP_TYPE.FONDDREAMMAP) then
			self.cacheMap[self._preMapId] = nil
		end
	end
	self._preMapId = mapId
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/12/04 10:00:01
-- @params 
-- @desc 副本载入初始化
function Map:init()
	self:__initDefaultMap()
	self:__initMapVolume()
	self:__initDefaultList()

end

function Map:clearMapCache(mapId)
	self.cacheMap[mapId] = nil
	self.mapNpc[mapId] = nil
	self.mapRandomNpc[mapId] = nil
	self.mapRoleConditions[mapId] = nil
end

function Map:__initDefaultMap()
    self.defaultMap = assert(MapResHelper:getDefaultMapInfoRes())
    -- add by XiaoZhiWei 2017/05/10 19:55:39 加密
    for k, v in pairs(self.defaultMap) do
        -- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 副本奖励,条件结果)
        v.__VERSION = FORM_MAP_VERSION
        self.defaultMap[k] = createEncryptTable(v)
    end

    --@TODO 2018-12-01 14:15:15 看情况调整位置
    local mapInfo = MapResHelper:getEditorMapInfoRes()
    for i, v in ipairs(mapInfo) do
        if v.mapTitle then
            v.title = v.mapTitle
            v.mapTitle = nil
        end
        --@desc 编辑器副本标识
        v.__VERSION = EDITOR_MAP_VERSION
        self.defaultMap[v.id] = createEncryptTable(v)
    end

    -- 挑战副本res\script\challengeMap\mapInfo.lua
    for mapId, mapInfo in pairs(MapResHelper:getChallengeMapInfoRes()) do
        mapInfo.__VERSION = CHALLENGE_MAP_VERSION
        self.defaultMap[mapId] = mapInfo
    end
end


--@desc: 初始化地图基本信息
--@author:Liang SongQiang
--@time:2019-01-04 16:28:53
function Map:__initDefaultList()
	local index = 0
	for i,volume in ipairs(self.defaultMapVolume) do
		local map_id_list = volume.mapList
		for _,mapId in ipairs(map_id_list) do
			if self.defaultMap[mapId] then
				index = index + 1
				self.defaultMap[mapId].index = index
				table.insert( self.defaultMapList, index, self.defaultMap[mapId])
			end
		end
	end
end


--@desc: 获取分组信息
--@author:Liang SongQiang
--@time:2018-12-05 12:05:26
--@volumeId: 卷ID
function Map:getVolumeByVolumeId(volumeId)
	for i,v in ipairs(self.defaultMapVolume) do
		if v.id == volumeId then
			return v
		end
	end
end

--@desc: 根据分组ID 获取该组的排序
--@author:Liang SongQiang
--@time:2019-01-04 16:27:55
--@volumeId: 分卷ID
function Map:getVolumeIndexByVolumeId(volumeId)
	for i,v in ipairs(self.defaultMapVolume) do
		if v.id == volumeId then
			return i
		end
	end
end

--@desc: 获取副本在卷内的排序
--@author:Liang SongQiang
--@time:2019-01-04 16:26:06
--@mapId:副本ID 
function Map:getMapIndexInVolume(mapId)
	local volumeId = self:getVolumeIdByMapId(mapId)
	local map_list = self:getMapIdListInVolume(volumeId)
	for index,id in ipairs(map_list) do
		if mapId == id then
			return index
		end
	end
end

--@desc: 根据副本ID获取分卷ID
--@author:Liang SongQiang
--@time:2019-01-04 15:45:17
--@mapId:副本ID 
function Map:getVolumeIdByMapId(mapId)
	local defaultMap = self:getDefaultMapById(mapId)

	--@desc 获取家园副本可能为空值。
	if defaultMap == nil then
		return nil
	end

	return defaultMap.volumeId
end

--@desc: 获取副本分组信息
--@author:Liang SongQiang
--@time:2019-01-04 16:25:09
function Map:getMapVolume()
	return self.defaultMapVolume
end

--@desc: 根据分组ID获取该组内的所有副本ID
--@author:Liang SongQiang
--@time:2019-01-04 16:24:36
--@volumeId: 分组ID
function Map:getMapIdListInVolume(volumeId)
	local volume = self:getVolumeByVolumeId(volumeId)

	if volume and volume.mapList then
		return volume.mapList
	end
end

function Map:initMapById(mapId)
    if mapId == nil then
		print("mapId == nil", debug.traceback())
        return
    end

    if self:getMapVersionByMapId(mapId) == EDITOR_MAP_VERSION then
        --@TODO 2018-12-04 22:26:25 编辑器副本创建流程
        local mapData = inherit(self:getDefaultMapById(mapId), MapResHelper:getEditorMapRes(mapId))

        --@RefType [src.app.models.map.EditorMap#EditorMap]
        local EditorMap = require("app.models.map.EditorMap")
        local map = EditorMap:initMap(mapData)
        map:init()
        self.cacheMap[mapId] = map
    elseif self:getMapVersionByMapId(mapId) == CHALLENGE_MAP_VERSION then
        local map = MapFactory:createChallengeMap(mapId)
        self.cacheMap[mapId] = map
    else
        local map = self:__loadMap(mapId)
        map:init()
        self.cacheMap[mapId] = map
    end

    return self.cacheMap[mapId]
end

--@desc: 区分表格天禧副本还是编辑器副本
--@author:Liang SongQiang
--@time:2018-12-05 10:55:01
function Map:getMapVersionByMapId(mapId)
	--@desc 家园副本的处理
	if string.find(mapId,"user_fb_") then
		return FORM_MAP_VERSION
	end

	--@desc 梦境副本
	if string.find(mapId,"dr") then
		return EDITOR_MAP_VERSION
	end
	
	local defaultMap = self.defaultMap[mapId]

	local version
	if defaultMap ~= nil then
		version = defaultMap.__VERSION
	end

	return version
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/01/18 14:38:07
-- @desc 初始化房间联系
function Map:initRoomLink(room)
	local link = {}
	local linkKeyWord = {"center", "left", "leftUp", "up", "rightUp", "right", "rightDown", "down", "leftDown"}
	for k, keyWord in pairs(linkKeyWord) do
		if type(room[keyWord]) == "string" and string.len(room[keyWord]) >= 1 then
			link[keyWord] = room[keyWord]
		end
	end
	room.link = link
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/01/18 14:39:08
-- @desc 初始化房间角色
function Map:__initRoomRole(room)
	local roleList = {}
	for i=1, 999 do
		local role = room["role"..tostring(i)]
		if role then
			table.insert(roleList, role)
		else
			break
		end
	end
	for i=1, 999 do
		local role = room["item"..tostring(i)]
		if role then
			table.insert(roleList, role)
		else
			break
		end
	end
	room.roleList = roleList
end

-- 初始化副本中的房间
function Map:__initMapRoom(map)
	local mapId = map.id
	local mapRoom = assert(MapResHelper:getMapRoomRes(mapId))
	map.room = inherit({}, mapRoom)
	for k, room in pairs(map.room) do
		self:initRoomLink(room)
		self:__initRoomRole(room)
	end
end

function Map:__initMapRoleConditions(map, role)

	if not self.mapRoleConditions[map.id] then
		self.mapRoleConditions[map.id] = MapResHelper:getMapConditionAndResultRes(map.id)
	end

	local mapConditionAndResults = assert(self.mapRoleConditions[map.id], "map.id = "..tostring(map.id))
	local conditionAndResults = {}
	for i = 1, 999 do
		local conditionAndResult = {}
		local conditions = role["conditions"..tostring(i)]
		local results = role["results"..tostring(i)]
		if conditions and results then
			local conditionList = string.split(conditions, ";")
			local resultList = string.split(results, ";")

			conditions = {}
			results = {}
			for k, contitionName in pairs(conditionList) do
				local condition = mapConditionAndResults["con_"..contitionName]
				table.insert(conditions, condition)
			end
			for k, resultName in pairs(resultList) do				
				local result = mapConditionAndResults["rlt_"..resultName]
				if result then
					table.insert(results, result)
				end
			end

			conditionAndResult["conditions"] = conditions
			conditionAndResult["results"] = results
			conditionAndResult["conditionRelation"] = role["conditionRelation"..tostring(i)]
		else
			break
		end
		table.insert(conditionAndResults, conditionAndResult)
	end
	role.conditionAndResults = conditionAndResults
end

-- 初始化地图中人物
function Map:__initMapRole(map)
	local roles = MapResHelper:getMapRoleRes(map.id)
	local items = MapResHelper:getMapItemRes(map.id)

	map.roles = {}

	for k, role in pairs(roles) do
		role.type = "role"
		map.roles[k] = role

		self:__initMapRoleConditions(map, role)

		if role.words and type(role.words) == "string" then
			role.words = string.split(role.words, ";")
		end
	end

	for k, item in pairs(items) do
		item.type = "item"
		map.roles[k] = item
		self:__initMapRoleConditions(map, item)
	end
end

-- 初始化地图奖励
function Map:__initMapCompleteAward(map)
	local completeAwards = {}
	for i = 1, 999 do
		local needBreak = true
		local completeAward = {}
		for j = 1, 999 do
			local completeAwardType = map["completeAwardType"..tostring(i).."_"..tostring(j)]
			local completeAwardName = map["completeAwardName"..tostring(i).."_"..tostring(j)]
			local completeAwardValue = map["completeAwardValue"..tostring(i).."_"..tostring(j)]
			if completeAwardType and completeAwardName and completeAwardValue then
				needBreak = false

				table.insert(completeAward,
				createEncryptTable({
					["type"] = completeAwardType,
					["name"] = completeAwardName,
					["value"] = completeAwardValue
				}))
			else
				break
			end
		end

		if not MapIsEmpty(completeAward) then
			-- add by XiaoZhiWei 2017/05/11 10:44:09 加密 (主防 主线任务完成奖励)
			table.insert(completeAwards, createEncryptTable(completeAward))
		end

		if needBreak then
			break
		end
	end
	map.completeAwards = completeAwards
	map.completeAward = completeAwards[1]

	-- Helper:print_lua_table(completeAwards)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/01/18 14:44:44
-- @desc 初始化副本完成条件
function Map:__initMapCompleteCondition(map)
	local completeConditions = {}
	for i=1, 999 do
		local completeConditionName = map["completeConditionName"..tostring(i)]
		local completeConditionValue = map["completeConditionValue"..tostring(i)]
		if completeConditionName and completeConditionValue then
			table.insert(completeConditions,
			{
				name = completeConditionName,
				value = completeConditionValue
			})
		else
			break
		end
	end
	map.completeConditions = completeConditions
end

-- 载入地图
function Map:__loadMap(mapId)
    if mapId == nil then
        return
    end

    if PRINT_MODE == 1 then
        print("initMap()", mapId)
    end

    local mapData = self.defaultMap[mapId]

    if mapData then
        local map = inherit({}, mapData, MapFactory:createMap(MapConstant.MapType.BASE_MAP))

        self:__initMapCompleteAward(map)
        self:__initMapCompleteCondition(map)
        self:__initMapRoom(map)
        self:__initMapRole(map)
		self:__initMapNpc(mapId)
		self:__initRandomNpc(mapId)
		return map
    end
end


function Map:setMapWithId(mapId, map)
	if mapId == nil or MapIsEmpty(map) == true then
		return
	end
	self.cacheMap[mapId] = map
end

function Map:getMapById(mapId)
	if mapId == nil then
		if PRINT_MODE == 1 then
			error("参数错误,不能填写空的副本ID")
		end
		return 
	end
	if self.cacheMap[mapId] == nil then
		self:initMapById(mapId)
	end
	return self.cacheMap[mapId]
end

function Map:getMapByIndex(index)
	return self:getMapById(self:getMapIdByIndex(index))
end

function Map:getMapIdByIndex(index)
	if self.defaultMapList[index] == nil then
		return assert(self.defaultMapList[index], "index = "..tostring(index))
	end
	return self.defaultMapList[index].id
end

function Map:getMapIndexById(mapId)
	if self.defaultMap[mapId] == nil then
		return assert(self.defaultMap[mapId], "mapId = "..tostring(mapId))
	end
	return self.defaultMap[mapId].index
end

function Map:getDefaultMapById(mapId)
	if mapId == nil or self.defaultMap[mapId] == nil then
		if PRINT_MODE == 1 and string.find(mapId,"user_fb_") == nil and string.find(mapId,"drFloor_") == nil then
			assert(self.defaultMap[mapId], "副本参数错误,无效副本Id. mapId = "..mapId)
		end
		return
	end
	return self.defaultMap[mapId]
end

--
function Map:getMapRoleCondition(mapId)
	return self.mapRoleConditions[mapId]
end

function Map:addMapRoleCondition(mapId,condition)
	if not self.mapRoleConditions[mapId] then
		self.mapRoleConditions[mapId] = MapResHelper:getMapConditionAndResultRes(mapId)
	end

	self.mapRoleConditions[mapId][condition.id] = condition
end

function Map:getMapCount()
	return #self:__getMapList()
end

function Map:__getMapList()
	return self.defaultMapList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/19 21:43:16
-- @desc  获取地图列表, 排除部分特殊地图
function Map:getMapListWithFilter()
	local retList = self:__getMapList()
	if DEBUG_MODE == 1 then
		return retList
	end
	local v
	for i = #retList, 1, -1 do
		v = retList[i]
		if filterList[v.id] == true then
			table.remove(retList, i)
		end
	end
	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/19 21:45:54
-- @desc 获取地图数量, 排除部分特殊地图
function Map:getMapCountWithFilter()
	return #self:getMapListWithFilter()
end

function Map:__initMapNpc(id)
	self.mapNpc[id] = assert(MapResHelper:getMapNpcBaseRes(id))

	local allMapNpcList = assert(MapResHelper:getMapOtherNpcRes())

	do
		-- add by XiaoZ hiWei 2018/12/04 10:23:14 该初始化动作只需要执行一次
		if self.IS_INIT_AllMapNPC ~= true then
			-- add by XiaoZhiWei 2018/01/18 15:12:37 初始化全副本npc
			for npcId , npc in pairs(allMapNpcList) do
				if type(npc.words) == "string" then
					npc.words = string.split(npc.words,";") 
				end

				npc._version = FORM_MAP_VERSION
				Npc:initNpc(npc)
			end
			self.IS_INIT_AllMapNPC = true
		end
	end

	for mapId, mapNpcList in pairs(self.mapNpc) do
		if mapId == id then
			-- add by XiaoZhiWei 2018/01/18 15:12:19 初始化副本npc
			for npcId, npc in pairs(mapNpcList) do
				-- 初始化每一个npc的数据
				npc._version = FORM_MAP_VERSION
				Npc:initNpc(npc)

				mapNpcList[npcId] = npc --Helper:tableCover(Role:create(), npc) -- 继承role
			end

			-- add by XiaoZhiWei 2018/12/04 10:24:29 此处只需要进行索引关联即可
			for npcId , npc in pairs(allMapNpcList) do
				mapNpcList[npcId] = npc --Helper:tableCover(Role:create(), npc) -- 继承role
			end
		end
	end
end

-- 获取指定副本的 角色信息
function Map:getMapNpc(mapId, roleId)
	local mapNpc = self.mapNpc[mapId]

	if not mapNpc then
		self:__initMapNpc(mapId)
		mapNpc = self.mapNpc[mapId]
	end

	local role = mapNpc[roleId]

	if role == nil then
		local ouYuList = MapResHelper:getMapOuYuListRes()
		role = ouYuList[roleId]
	end

	assert(role, "mapId = "..tostring(mapId)..", roleId = "..tostring(roleId))
	return role
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/17 20:22:56
-- @desc 初始化 副本随机添加角色 功能
function Map:__initRandomNpc(mapId)
	if mapId == nil then
		return
	end

	local res = MapResHelper:getMapRandomNpcRes()

	-- 初始化 随即投放 npc 资源数据
	local initMapRandomNpc = function(map)
		local retMap = {}
		if MapIsEmpty(map) == false then
			for i=1,10 do
				if map["roomId"..tostring(i)] ~= nil and map["roles"..tostring(i)] ~= nil and map["number"..tostring(i)] ~= nil and map["step"..tostring(i)] ~= nil then
					--[[
						roomid = 
						{
							feizei = 
							{
								count = 5,
								step = 2
							},
							guxudaozhang = 
							{
								count = 1,
								step = 2
							}
						}
					]]
					local roleList = string.split(map["roles"..tostring(i)], ";")
					local countList = string.split(map["number"..tostring(i)], ";")
					local stepList = string.split(map["step"..tostring(i)], ";")
					local probList = string.split(map["probability"..tostring(i)], ";")
					local result = {}
					if MapIsEmpty(roleList) == false then
						for i=1,#roleList do
							local role = roleList[i]
							result[role] = 
							{
								count = tonumber(countList[i]),
								step = tonumber(stepList[i]),
								probability = tonumber(probList[i])
							}
						end
						retMap[map["roomId"..tostring(i)]] = result
					end
				end
			end
		else
		end
		return retMap
	end


	for id,map in pairs(res.mapNpc) do
		if id == mapId then
			self.mapRandomNpc[mapId] = initMapRandomNpc(map)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/12/17 23:33:44
-- @desc 获取 副本 需要投放的npc配置
function Map:getRandomNpcList(mapId)
	return self.mapRandomNpc[mapId]
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 11:43:40
-- @desc 获取雇佣名NPCID
local yongBingTab = 
{
	-- fb36r300_1;fb37r300_1;fb38r300_1;fb39r300_1;fb40r300_1
	["fb36"] = "fb36r300_1",
	["fb37"] = "fb37r300_1",
	["fb38"] = "fb38r300_1",
	["fb39"] = "fb39r300_1",
	["fb40"] = "fb40r300_1",
}
function Map:getYongBingIdByMapId(mapId)
	return switch(mapId, yongBingTab)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/07/18 18:55:18
-- @desc 获取当前房间是否能够偶遇切磋
local canNotQieCuoRoomList = 
{
	["fb03_116"] = true,
	["fb10_42"] = true,
	["fb10_43"] = true,
	["fb10_44"] = true,
	["fb10_45"] = true,
	["fb10_46"] = true,
	["fb10_47"] = true,
	["fb10_48"] = true,
	["fb10_49"] = true,
	["fb10_50"] = true,
	["fb37_71"] = true,

	-- 守墓 玩法无法切磋
	["fb205_68"] = true,
	["fb205_69"] = true,
	-- 奈何桥 玩法无法切磋
	["fb201_37"] = true,
}
function Map:checkRoomCanQieCuo(roomId)
	if roomId == nil then
		return false
	end
	
	if canNotQieCuoRoomList[roomId] == true then
		return false
	else
		return true
	end
end

--@desc: 初始化分组信息
--@author:Liang SongQiang
--@time:2019-01-04 16:28:45
function Map:__initMapVolume()
	local volumeInfo = MapResHelper:getMapVolumeRes()

	for i,v in ipairs(volumeInfo) do
		local volume = {
			mapList = {}
		}

		volume = inherit(v, volume)

		local includeMapList = string.split(v.includeMap,";")

		for _,mapId in ipairs(includeMapList) do
			if self.defaultMap[mapId] ~= nil then
				self.defaultMap[mapId].volumeId = volume.id
				table.insert(volume.mapList,mapId)
			end
		end

		table.insert(self.defaultMapVolume,volume )

		if tonumber(string.split(volume.id,"volume_")[2]) == 0 then
			hiddenVolume[volume.id] = true
		end
	end
end

--@desc 判断该卷是不是隐藏卷
function Map:__isHiddenVolume(volumeId)
    if hiddenVolume[volumeId] then
        return true
    end
    return false
end

--@desc 判断该副本时不是隐藏副本
function Map:isHiddenMapById(mapId)
    local volumeId = self:getVolumeIdByMapId(mapId)

    if volumeId == nil then
        return true
    end

    return self:__isHiddenVolume(volumeId)
end

--@desc: 获取副本刷新时间
--@author:Liang SongQiang
--@time:2019-01-04 17:42:03
--@mapId:副本Id 
function Map:getMapRefreshTime(mapId)
	local role = User:getRole()
	local currTime = GetTime()

	local leaveTime = role:getFlag(mapId)

	if leaveTime == 0 then
		return 0
	end

	return MAP_REFRESH_INTERVAL - (currTime - leaveTime)
end

--@desc: 获取副本状态
--@author:Liang SongQiang
--@time:2019-01-07 15:26:16
--@mapId:副本ID 
function Map:getMapState(mapId)
	local role = User:getRole()

	local state = MAP_STATE.UNLOCK

	local volumeId = self:getVolumeIdByMapId(mapId)

	if self:__isHiddenVolume(volumeId) then
		state = MAP_STATE.COMPLETE
		return state
	end

	local m_volume = role:getAttr("m_volume")

	if m_volume[volumeId] == false then
		state = MAP_STATE.NOTOPEN
		return state
	end

	--@desc 是否完成
	local isComplete = role:isMapCompleted(mapId)
	if isComplete then
		state = MAP_STATE.COMPLETE
		return state
	end

	--@desc 判断前置章节是否完成
	local defaultMap = self:getDefaultMapById(mapId)
	local preMapId = defaultMap.preMap

	if preMapId == nil then
		preMapId = 0
	end

	if tonumber(preMapId) == 0 then
		state = MAP_STATE.WORKING
	else
		local preComplete = role:isMapCompleted(preMapId)
		if preComplete then
			state = MAP_STATE.WORKING
		else
			--@desc 前置章节未完成
			state = MAP_STATE.UNLOCK
		end
	end

	return state
end

--@desc 获取主线（非隐藏副本）通关副本列表
function Map:getCompletedMapList(filterFunc)
	filterFunc = Helper:getDef(filterFunc,EMPTY_FUNC)
	
	return self:__getAllCompleteMapList(function (mapId)
		if mapId == "fb205" or mapId == "fb221" or mapId == "fb222" then
			return true
		end
		
		if (self:getMapVersionByMapId(mapId) == EDITOR_MAP_VERSION or self:isHiddenMapById(mapId)) or filterFunc(mapId) == true then
			return true
		end
		
		return false
	end)
end

--@desc 获取所有已完成的副本
function Map:__getAllCompleteMapList(filterFunc)
	filterFunc = Helper:getDef(filterFunc,EMPTY_FUNC)
	local role = User:getRole()
	local allMapState = role:getAllMapState()

	local list = {}

	if MapIsEmpty(allMapState) == false then
		for mapId,state in pairs(allMapState) do
			--@desc 清除存档中用户地图的完成状态
			if string.find( mapId,"user_fb_" ) then
				allMapState[mapId] = nil
			else
				if filterFunc(mapId) == false and state.isCompleted == true then
					table.insert(list,mapId)
				end
			end
			
		end
	end

	return list
end

--@desc: 重置副本
--@author:Liang SongQiang
--@time:2019-02-20 15:00:17
--@mapId:副本ID 
function Map:resetMapById(mapId)
	if self:getMapVersionByMapId(mapId) == EDITOR_MAP_VERSION then
		--@desc 需清除节点
		local role = User:getRole()

		local nodeRewards = role:getAttr("nodeRewards")
		
		local mapIndex = self:getMapIndexInVolume(mapId)
		
		local volume_maps = self:getMapIdListInVolume(self:getVolumeIdByMapId(mapId))
		
		--@desc 清理节点奖励信息
		if MapIsEmpty(nodeRewards) == false then
			for id, reward_type in pairs(nodeRewards) do
				if reward_type == NODE_REWARD_NOR then
					local reward_map_id = string.split(id,"_")[1]
					if mapId == reward_map_id then
						if PRINT_MODE == 1 then
							print("clear node reward : "..id,reward_type)
						end

						nodeRewards[id] = nil
					end
				end
			end
		end

		--@desc 通关副本重置成未通关
		local isCompleted = role:isMapCompleted(mapId)
		if isCompleted then
			local mapState = role:getMapState(mapId)
			mapState.isCompleted = false
		end
		
		--@desc 刷新地图标记
		local flag = role:getAttr("mapNodeFlag")
		if MapIsEmpty(flag[mapId]) == false then
			flag[mapId] = nil
			role:setAttr("mapNodeFlag",flag)
		end

		local mapStore = role:getAttr("mapStore")

		if MapIsEmpty(mapStore[mapId]) == false then
			mapStore[mapId] = nil
			role:setAttr("mapStore",mapStore)
		end

		--@desc 刷新地图
		-- self:initMapById(mapId)
		self.cacheMap[mapId] = nil
	else
		self.cacheMap[mapId] = nil
	end
end


--@desc: 获取当前所在地图，如果人物并非在地图中返回nil
--@author:Seven_L
--@time:2020-06-04 21:46:52
function Map:getCurrMap()
	local currLayer = MainControllLayer:getCurrLayer()
	if currLayer ~= "MapLayer" then
		return nil
	end
	
	local role = User:getRole()

	local map = role:getCurrMap()

	return map
end

-- 加密标记
Map.isEncrypted = true
return Map
00