local MapInfo =
{
	-- historyAddList = {}, -- 历史添加记录
	-- maps =
	-- {
	-- 	fb01 =
	-- 	{
	-- 		roles =
	-- 		{

	-- 		},
	-- 		rooms =
	-- 		{

	-- 			roleList =
	-- 			{

	-- 			}
	-- 		}
	-- 	}
	-- }
}

local MapRole = {}



-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 20:33:57
-- @desc 地图内添加多个人物
function MapInfo:addMapRoleListByRandom(map, roleList)
	local retMap = map
	for k,role in pairs(roleList) do
		retMap = self:addMapRoleByRandom(retMap, role)
	end
	return retMap
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/14 20:41:46
-- @desc  检查该角色是有已经添加过
function MapInfo:checkRoleIsAdded(map, roleId)
	if roleId == nil then
		return nil, "角色ID不存在"
	end
	if map.historyAddList == nil then
		map.historyAddList = {}
	end

	if map.historyAddList[roleId] == true then
		return true
	else
		map.historyAddList[roleId] = true
		return false
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/12 10:50:36
-- @desc 地图内添加随机人物,添加过的角色无需再次添加
function MapInfo:addMapRoleByRandom(map, role)
	if MapIsEmpty(map) == true or MapIsEmpty(role) == true or self:checkRoleIsAdded(map, role.id) ~= false then
		return map
	end
	local retMap = map

	-- 获取随机房间ID
	local randomRoomId = self:getRandomRoomId(retMap)
	-- 如果没添加成功,则直接返回原有的Map
	if self:addMapRole(retMap, role) == false or self:addRoleToRoom(retMap, randomRoomId, role.id) == false then
		return map
	else
	end
	return retMap , randomRoomId
end
function MapInfo:addRoleToRoomByRoomId(map,roomId,role)
		if MapIsEmpty(map) == true or MapIsEmpty(role) == true  then
		return map
	end
	local retMap = map
	local randomRoomId = roomId
	if self:addMapRole(retMap, role) == false or self:addRoleToRoom(retMap, randomRoomId, role.id) == false then
		return map
	else
	end
	return retMap

end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/12 15:41:44
-- @desc 副本添加角色到角色列表, 返回true or false
function MapInfo:addMapRole(map, role)
	-- 地图不能为空,角色不能为空,角色ID属性必须存在
	if MapIsEmpty(map) == true or MapIsEmpty(role) == true or role.id == nil then
		return false
	end
	-- 如果副本角色属性列表为空,则给默认的table {}
	local roles = Helper:getDef(map:getRoles(), {})
	-- NEEDTODO 考虑角色属性已经存在的情况
	if roles[role.id] ~= nil then
	end

	-- 直接赋值,将角色添加到角色属性列表
	roles[role.id] = role

	-- 替换副本角色列表,更新为最新的角色列表
	map.roles = roles
	return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/12 17:20:40
-- @desc 副本添加角色到指定房间的角色列表 return true ro false
function MapInfo:addRoleToRoom(map, roomId, roleId)
	-- 其中有一个为空则不能添加
	if MapIsEmpty(map) == true or roomId == nil or roleId == nil then
		return false
	end
	local roleList = Helper:getDef(map:getRoomRoleList(roomId), {})
	-- 判断角色是否已经在房间内,如果已存在则无需继续添加
	for k,v in pairs(roleList) do
		if v == roleId then
			return false
		end
	end

	table.insert(roleList, roleId)
	return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2016/11/12 15:15:09
-- @desc 地图随机房间
function MapInfo:getRandomRoomId(map)
	-- 地图必须是存在的
	if MapIsEmpty(map) == true then
		return nil
	end

	-- 获取可随机的房间
	local CanRandomroomList = {}
	local mapList = require("script.others.blackpeople")["map"]
	for k,v in pairs(mapList) do
		if v.id == map.id then
			CanRandomroomList = string.split(v.possibleroom, ",")
		end
	end

	if MapIsEmpty(CanRandomroomList) ~= true then
		-- 获取房间随机数
		local randomIndex = math.random(#CanRandomroomList)
		-- 确定随机房间
		print("getRandomRoomId 获取随机房间 " .. CanRandomroomList[randomIndex])
		return CanRandomroomList[randomIndex]
	end

	return nil

	-- -- 获取地图所有房间
	-- local roomMap = map:getRoomMap()
	-- -- 如果房间是
	-- if MapIsEmpty(roomMap) == true then
	-- 	return nil
	-- end

	-- -- 获取房间Id的列表
	-- local roomIdList = {}
	-- for k,v in pairs(roomMap) do
	-- 	table.insert(roomIdList, k)
	-- end

	-- -- 获取房间随机数
	-- local randomIndex = math.random(#roomIdList)
	-- -- 确定随机房间
	-- print("getRandomRoomId 获取随机房间 " .. roomIdList[randomIndex])
	-- return roomIdList[randomIndex]
end

return MapInfo
00000