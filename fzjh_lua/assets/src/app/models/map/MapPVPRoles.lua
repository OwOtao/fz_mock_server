local MapPVPRoles = 
{
	_needRefresh = true, -- add by XiaoZhiWei 2017/06/23 20:12:01 是否需要刷新
	cacheList = {} -- add by XiaoZhiWei 2017/06/22 18:20:05 缓存排序副本角色信息  --[[ mapId = { roomId = { {roleid = ..., jointime =... }, {roleid = ..., jointime =... }, {roleid = ..., jointime =... } } } ]]
}


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 16:25:46
-- @desc 角色加入房间
function MapPVPRoles:addOneRoleToRoom(mapId, roomId, role)
	if mapId == nil or roomId == nil or MapIsEmpty(role) == true or role.userid == tostring(User:getUserId()) then
		return
	end
	if PRINT_MODE == 1 then
		print("function MapPVPRoles:addOneRoleToRoom(mapId, roomId, role)")
	end
	local cacheRoleList = self:getMapRoomRoleList(mapId, roomId)
	local result, index = self:checkRoleIsInRoom(mapId, roomId, role.userid)
	if result == true then
		if PRINT_MODE == 1 then
			print("角色".. tostring(role.name) .." 已经存在在该房间, 可能需要刷新缓存", mapId, roomId)
		end
		cacheRoleList[index] = Helper:tableCover(cacheRoleList[index], role) -- add by XiaoZhiWei 2017/07/04 11:32:09 如果已经存在了,则将新的信息覆盖老的信息
	else
		table.insert(cacheRoleList, 1, role)  -- add by XiaoZhiWei 2017/06/23 16:33:18 新加入的始终加入到第一个	
		if PRINT_MODE == 1 then
			print("角色".. tostring(role.name) .." 添加到房间成功", mapId, roomId)
		end
	end
	self:setMapRoomRoleList(mapId, roomId, cacheRoleList)
	self._needRefresh = true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 16:33:54
-- @desc 角色离开房间
function MapPVPRoles:removeOneRoleFromRoom(mapId, roomId, userid)
	if mapId == nil or roomId == nil or userid == nil then
		return
	end
	if PRINT_MODE == 1 then
		print("function MapPVPRoles:removeOneRoleFromRoom(mapId, roomId, userid)")
	end
	local cacheRoleList = self:getMapRoomRoleList(mapId, roomId)
	local result, index = self:checkRoleIsInRoom(mapId, roomId, userid)
	if result == true then
		table.remove(cacheRoleList, index)
		if PRINT_MODE == 1 then
			print("移除角色成功", mapId, roomId, userid)
		end
	else
		if PRINT_MODE == 1 then
			print("当前房间没有该角色,请检查逻辑是否出错")
		end
	end
	self:setMapRoomRoleList(mapId, roomId, cacheRoleList)
	self._needRefresh = true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 16:59:55
-- @desc 检查角色是否在房间内
function MapPVPRoles:checkRoleIsInRoom(mapId, roomId, userid)
	if mapId == nil or roomId == nil or userid == nil then
		return
	end
	if PRINT_MODE == 1 then
		print("function MapPVPRoles:checkRoleIsInRoom(mapId, roomId, userid)", mapId, roomId, userid)
	end
	local cacheRoleList = self:getMapRoomRoleList(mapId, roomId)
	for i,role in ipairs(cacheRoleList) do
		if userid == role.userid then
			if PRINT_MODE == 1 then
				print("角色在这个房间")
			end
			return true, i
		end
	end
	if PRINT_MODE == 1 then
		print("角色不在这个房间")
	end
	return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/22 17:45:44
-- @desc 排序指定副本,指定房间的角色列表数据
function MapPVPRoles:sortMapRoomRoleList(list,key)
	-- if mapId == nil or roomId == nil or key == nil then
	-- 	return
	-- end
	-- local cacheRoleList = self:getMapRoomRoleList(mapId, roomId)

	table.sort(list, function(a, b)
		if a[key] == nil then
			return false
		elseif b[key] == nil then
			return true
		else
			return a[key] > b[key]
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/22 17:53:03
-- @desc 获取指定副本的缓存数据
function MapPVPRoles:getMapRoomMap(mapId)
	if mapId == nil then
		return
	end
	return Helper:getDef(self.cacheList[mapId], {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/22 18:12:51
-- @desc 设置指定副本的缓存数据 (注: 缓存的数据是一个数组,传入的房间Map请注意数据的准确性)
function MapPVPRoles:setMapRoomMap(mapId, roomMap)
	if mapId == nil then
		return
	end
	roomMap = Helper:getDef(roomMap, {})
	if PRINT_MODE == 1 then
		print("function MapPVPRoles:setMapRoomMap(mapId, roomMap)", mapId)
	end
	self.cacheList[mapId] = roomMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 10:31:16
-- @desc 获取指定副本,指定房间的角色列表数据Map
function MapPVPRoles:getMapRoomRoleMap(mapId, roomId, from, to)
	local retMap = {}
	if mapId == nil or roomId == nil then
		return retMap
	end
	local cacheRoleList = self:getMapRoomRoleList(mapId, roomId)
	local fromNum, toNum = 1, #cacheRoleList

	-- add by XiaoZhiWei 2017/06/23 14:46:38 from to 从第多少条到多少条 如果 to 为空,则 是第一条到 from 条
	if type(from) ~= "number" then
	elseif type(to) ~= "number" then
		fromNum = 1
		toNum = from
	else
		fromNum = from
		toNum = to
	end

	for i,role in ipairs(cacheRoleList) do
		if i >= fromNum and i <= toNum then
			retMap[role.userid] = role
		end
	end
	return retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/22 17:47:50
-- @desc  获取指定副本,指定房间的角色列表数据
function MapPVPRoles:getMapRoomRoleList(mapId, roomId, from, to)
	local retList = {}
	if mapId == nil or roomId == nil then
		return retList
	end
	local cacheMapRoom = self:getMapRoomMap(mapId)
	local cacheRoleList = Helper:getDef(cacheMapRoom[roomId], {})
	local fromNum, toNum = 1, #cacheRoleList

	-- add by XiaoZhiWei 2017/06/23 14:46:38 from to 从第多少条到多少条 如果 to 为空,则 是第一条到 from 条
	if type(from) ~= "number" then
	elseif type(to) ~= "number" then
		fromNum = 1
		toNum = from
	else
		fromNum = from
		toNum = to
	end

	if PRINT_MODE == 1 then
		print("function MapPVPRoles:getMapRoomRoleList(mapId, roomId, from, to)", mapId, roomId, from, to, fromNum, toNum)
	end
	
	-- retList原本存放满足在from, to区间的玩家role， 现修改为存放所有玩家role
	for i,role in ipairs(cacheRoleList) do
		-- if i >= fromNum and i <= toNum then
			table.insert(retList, role)
		-- end
	end

	-- if PRINT_MODE == 1 then
	-- 	Helper:print_lua_table(retList)
	-- end

	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/22 18:14:29
-- @desc 设置指定副本,指定房间的角色列表数据
function MapPVPRoles:setMapRoomRoleList(mapId, roomId, roleList)
	if mapId == nil or roomId == nil then
		return
	end
	roleList = Helper:getDef(roleList, {})
	if PRINT_MODE == 1 then
		print("function MapPVPRoles:setMapRoomRoleList(mapId, roomId, roleList)", mapId, roomId, roleList)
	end
	local cacheRoomMap = self:getMapRoomMap(mapId)
	cacheRoomMap[roomId] = roleList
	self:setMapRoomMap(mapId, cacheRoomMap)
	self:sortMapRoomRoleList(cacheRoomMap[roomId],"joinTime")
	self._needRefresh = true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 15:44:13
-- @desc 设置指定副本,指定房间的角色列表数据 参数是map
function MapPVPRoles:setMapRoomRoleListWithMap(mapId, roomId, roleMap)
	if mapId == nil or roomId == nil then
		return
	end 
	if PRINT_MODE == 1 then
		print("function MapPVPRoles:setMapRoomRoleListWithMap(mapId, roomId, roleMap)", mapId, roomId)
	end
	roleMap = Helper:getDef(roleMap, {})
	local roleList = {}
	for userid,role in pairs(roleMap) do
		if role.userid == tostring(User:getUserId()) then
			-- add by XiaoZhiWei 2017/06/23 20:28:49 排除玩家自身
		else
			table.insert(roleList, role)	
		end
	end
	if PRINT_MODE == 1 then
		Helper:print_lua_table(roleList)
	end


	self:setMapRoomRoleList(mapId, roomId, roleList)

end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/06/23 16:56:38
-- @desc  测试方法
function MapPVPRoles:test()
	local role = json.decode([[{
        "joinTime": 1498208437621,
        "sex": "女",
        "channel": "4399",
        "equips": {
          "head": {
            "itemId": "mao107",
            "id": 2140
          }
        },
        "portrait": {
            "id": "",
            "lv": 1
          },
        "userid": "3046229067",
        "skills": {
          "chijiayangshagong": {
            "id": "chijiayangshagong",
            "exp": 6202406
          },
          "qibaotianlanwu": {
            "id": "qibaotianlanwu",
            "exp": 6452434.2265789
          }
        },
        "looks": 97,
        "dsc": "",
        "name": "燕灵阳",
        "qi": 12741.430803571,
        "family": {
          "level": 2,
          "name": "youming"
        },
        "qiPercent": 1,
        "exp": 48130533.522528,
        "age": 23
      }]])

     local data = json.decode([[{"users":{"size":2,"mapId":"fb01","list":{"3046229067":{"joinTime":1498208437621,"sex":"女","channel":"4399","equips":{"head":{"itemId":"mao107","id":2140}},"portrait":{"id":"","lv":1},"userid":"3046229067","skills":{"chijiayangshagong":{"id":"chijiayangshagong","exp":6202406},"qibaotianlanwu":{"id":"qibaotianlanwu","exp":6452434.2265789}},"looks":97,"dsc":"","name":"燕灵阳","qi":12741.430803571,"family":{"level":2,"name":"youming"},"qiPercent":1,"exp":4.8130533522528E7,"age":23},"3046228917":{"joinTime":1498206421334,"sex":"男","channel":"4399","equips":[],"portrait":{"id":"mianju1020","lv":1},"userid":"3046228917","skills":{"yijinjingshengong":{"id":"yijinjingshengong","exp":9674590},"shaolinwuyingjian":{"id":"shaolinwuyingjian","exp":9570273.1583074}},"looks":40,"dsc":"","name":"孙龙","qi":16659.57676,"family":{"level":2,"name":"shaolin"},"qiPercent":1,"exp":6.830906064492E7,"age":27}},"roomId":"fb01_01a"}}]])
     local users = data.users
     print("111111111111111111111111111111")
     Helper:print_lua_table(users)

     self:setMapRoomRoleListWithMap(users.mapId, users.roomId, users.list)

     print("222222222222222222222222222222")
     Helper:print_lua_table(self.cacheList)

     self:addOneRoleToRoom(users.mapId, users.roomId, role)

     print("33333333333333333333333333333")
     Helper:print_lua_table(self.cacheList)

     self:removeOneRoleFromRoom(users.mapId, users.roomId, role.userid)

     print("44444444444444444444444444444")
     Helper:print_lua_table(self.cacheList)

     self:addOneRoleToRoom(users.mapId, users.roomId, role)

     print("55555555555555555555555555555")
     Helper:print_lua_table(self.cacheList)

	self:removeOneRoleFromRoom(users.mapId, users.roomId, role.userid)

     print("66666666666666666666666666666")
     Helper:print_lua_table(self.cacheList)

	self:removeOneRoleFromRoom(users.mapId, users.roomId, role.userid)

     print("777777777777777777777777777777")
     Helper:print_lua_table(self.cacheList)

end


return MapPVPRoles00