local Role_Map = {}
-- 副本地图
function Role_Map:initMap()
end

-- 单个副本重置
function Role_Map:initMapById(mapId)
	if mapId == nil then
		return
	end
	return Map:initMapById(mapId)
end

function Role_Map:setCurrMapId(mapId)
	self.currMapId = mapId
end

function Role_Map:getCurrMapId()
	return self.currMapId
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 16:45:02
-- @params 
-- @desc 缓存非本地资源副本
function Role_Map:setMapWithId(mapId, map)
	Map:setMapWithId(mapId, map)
end

--@author:Liang SongQiang
--@time:2018-10-15 14:21:38
--@return [app.models.map.BaseMap#BaseMap]
function Role_Map:getCurrMap()
	if not MainControllLayer or MainControllLayer:getCurrLayer() ~= "MapLayer" then
		return
	end
	return self:getMapById(self:getCurrMapId())
end

function Role_Map:getAllMapState()
	return Helper:getDef(self._mapStates,{})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/12 17:41:11
-- @desc 地图有可能会发生变化,将变化后的地图重新设置进角色 
-- add by XiaoZhiWei 2017/12/20 17:57:16 弃用,副本中变化的内容是角色身上的同一份地图,不需要重新设置
function Role_Map:setCurrMap(map)
	-- if MapIsEmpty(map) == true then
	-- 	return false, "要设置的地图信息不能为空"
	-- end
	-- -- if map.id ~= self:getCurrMapId() then
	-- -- 	return false, "设置失败,只能设置当前进入的副本"
	-- -- end
	-- local currMap = self:getCurrMap()
	-- -- 判断当前地图是否为空, 如果为空,则不让设置
	-- if MapIsEmpty(currMap) == true then
	-- 	return false, "设置失败,当前没有进入任何地图"
	-- end
	return true
end

function Role_Map:getMapById(mapId)
	return Map:getMapById(mapId)
end

function Role_Map:getMapByIndex(mapIndex)
	return Map:getMapByIndex(mapIndex)
end

-- 地图完成程度等数据的存储
function Role_Map:getMapState(mapId)
	assert(mapId, "mapId = "..tostring(mapId))
	if PRINT_MODE == 1 then
		-- print("mapId = "..tostring(mapId))
	end

	--@desc 隐藏副本不计入人物存档完成状态
	if Map:isHiddenMapById(mapId) then
		return {isCompleted = true}
	end

	if self._mapStates == nil then
		self._mapStates = {}
	end
	if self._mapStates[mapId] == nil then
		self._mapStates[mapId] = {isCompleted = false}
	end
	return self._mapStates[mapId]
end

-- 设置地图为完成状态
function Role_Map:setMapCompleted(mapId)
	local mapState = self:getMapState(mapId)
	mapState.isCompleted = true

	-- local map = self:getMapById(mapId)
	-- self:setAttr("jindu", map.index + 1)
end

-- 判断地图是否完成
function Role_Map:isMapCompleted(mapId)
	local mapState = self:getMapState(mapId)
	return mapState.isCompleted
end

-- 重置地图房间标记
function Role_Map:initMapRoomStates(mapId)
	assert(mapId, "function Role_Map:initMapRoomStates(mapId)")
	if not self._mapRoomStates then
		self._mapRoomStates = {}
	end
	self._mapRoomStates[mapId] = {}
end

-- 地图房间标记（随地图重置而初始化， 暂用于npc分组仇恨标记）
function Role_Map:setMapRoomState(mapId, roomId, state)
	if PRINT_MODE == 1 then
		-- print("玩家产生地图房间标记: mapId = "..tostring(mapId).."; roomId = "..tostring(roomId)..";state = "..tostring(state))
	end
	assert((mapId and roomId), "function Role_Map:setMapRoomState(mapId, roomId, state)")
	if not self._mapRoomStates then
		self._mapRoomStates = {}
	end

	if not self._mapRoomStates[mapId] then
		self._mapRoomStates[mapId] = {}
	end

	if not self._mapRoomStates[mapId][roomId] then
		self._mapRoomStates[mapId][roomId] = {}
	end
	if MapIsEmpty(self._mapRoomStates[mapId][roomId]) then
		table.insert(self._mapRoomStates[mapId][roomId], state)
	else
		for i,v in ipairs(self._mapRoomStates[mapId][roomId]) do
			if v == state then
				break
			elseif i == #self._mapRoomStates[mapId][roomId] then
				table.insert(self._mapRoomStates[mapId][roomId], state)
			end
		end
	end
end

-- 获取地图房间标记
function Role_Map:getMapRoomState(mapId, roomId)
	assert((mapId and roomId), "function Role_Map:getMapRoomState(mapId, roomId)")
	if PRINT_MODE == 1 then
		print("获取玩家地图房间标记")
	end
	if MapIsEmpty(self._mapRoomStates) or MapIsEmpty(self._mapRoomStates[mapId]) or MapIsEmpty(self._mapRoomStates[mapId][roomId]) then
		return nil
	else
		return self._mapRoomStates[mapId][roomId]
	end
end


return Role_Map0000000000