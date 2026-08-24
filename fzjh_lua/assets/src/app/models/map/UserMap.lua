--[[
	处理玩家副本相关的数据转换
	对外接口,功其他开发人员使用
		getUserMap
		changeRoomName
]]
local UserMap = {}

local HomelandRoleUtil = require("app.models.HomelandModel.HomelandRoleUtil")
local HomelandRoomUtil = require("app.models.HomelandModel.HomelandRoomUtil")
local PuRenModel = require("app.models.HomelandModel.HomelandRoleModel.PuRenModel")

local UserMapConstans = TableProxy:createEncryptedTableRecursive({
	enlargeRoomPrice = 800,
})
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 16:26:25
-- @params func 回调函数,返回的第一个参数即为初始化好的副本. 因为可能需要从服务器获取最新信息,所以需要通过回调处理
-- @desc 获取玩家副本信息
function UserMap:getUserMap(mapId, userId, func)
	func = Helper:getDef(func, EMPTY_FUNC)

	-- local role = User:getRole()
	-- local map = role:getMapById("user_fb_"..mapId)
	-- local isNeedRefresh = false
	-- -- 本地没有地图,或者本地地图需要刷新了, 才需要去服务器获取最新的地图信息
	-- if map == nil then
	-- 	isNeedRefresh = true
	-- else
	-- 	local currTime = GetTime()
	-- 	local leaveTime = role:getFlag("user_fb_"..mapId)
	-- 	local useTime = currTime - leaveTime
	-- 	-- 地图刷新时间设置为5分钟
	-- 	if useTime >= MAP_REFRESH_INTERVAL then
	-- 		isNeedRefresh = true
	-- 	else
	-- 		-- 直接反馈缓存的玩家副本
	-- 	end
	-- end
	
	local isNeedRefresh = true
	
	if isNeedRefresh == true then
		self:getWebUserMapInfo(mapId, userId, func)
	else
		-- func(map)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 17:07:05
-- @params 
-- @desc 修改副本房间名字 (供副本内修改房间名字时使用,需要刷新全图)
function UserMap:changeRoomName(map, roomId, roomName)
	-- self:changeFullFigure(map, roomId, roomName)

	-- add by XiaoZhiWei 2018/05/25 17:09:17 刷新全图信息
	local layer = MainControllLayer:getLayer("MapLayer")
	layer:initTotalMapUI(map.mapAppearance, map.mapAppearanceIndex)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 15:51:42
-- @params mapId 要去的玩家副本的Id
-- @params userid 要取的玩家的角色id
-- @desc 获取服务器玩家副本信息
--[[
	mapId和UserId为空的情况. 
	1. 平安小镇进入自己的房间,mapId为空和userid均可为空. 
]]
function UserMap:getWebUserMapInfo(mapId, userId, func)
	func = Helper:getDef(func, EMPTY_FUNC)
    --local startTime=GetTime()
    local role = User:getRole()

    local localVer = role:getAttr("sCk_ver")

	HttpManagerEx:getUserMap(mapId, userId, localVer["homeland"], function(status, errcode, errmsg, data)
		if status == 200 and errcode == 0 then
			-- 进入玩家副本房间
			local map = self:initUserMap(data)
			
			local local_ver = role:getAttr("sCk_ver")
            local_ver["homeland"] = data.ver
            role:setAttr("sCk_ver", local_ver)

			--map.__getInfoTime=GetTime()-startTime
			func(map,true)
			return true
		else
			print("errcode = ",errcode)
			PopText(errmsg)
			func(nil,false)
		end

	end, IS_SHOW_WAITING)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 15:51:21
-- @params 服务器下发的玩家副本数据
-- @desc 初始化玩家副本
function UserMap:initUserMap(mapInfo)
	if MapIsEmpty(mapInfo) == true or MapIsEmpty(mapInfo.usermap) == true then
		return
	end
	local map = Helper:tableCover(require("app.models.map.BaseMap"):create(), mapInfo.usermap)

	-- 1 更新角色副本列表内的副本信息
	-- 2 更新当前层的副本信息
	-- 3 进入副本操作

	if type(map.extra) ~= "table" then
		map.extra = {}
	end
	if map.BGM == "" or map.BGM == "jiaobu" then
		map.BGM = nil
		--替换旧音乐
		if map.hxId then 
			local hxId=map.hxId
			hxId=string.gsub(hxId,"huxing","")
			if tonumber(hxId)==3 then 
				map.BGM="bgm001"
			elseif tonumber(hxId)==4 then
				map.BGM="bgm002"
			elseif tonumber(hxId)>4 then 
				map.BGM="bgm003"
			end
		end
	end
	
	--@desc 房间所有者
	map._houseOwner=mapInfo.owner or ""
	--@desc 房间类型数量统计
	map.roomCountByType = {}

	--@desc 家具类型数量统计
	map.furCountByType = {}

	--@desc  仆人类型数量统计
	map.personCountByJob = {}
	
	do
		map.room = {}
		-- add by XiaoZhiWei 2018/05/18 21:22:56 初始化房间		
		local maproom = Helper:getDef(mapInfo.maproom, {})
		local room
		for k,roomInfo in pairs(maproom) do
			room = roomInfo
			Map:initRoomLink(room)
			-- room.id = room.fjId -- add by XiaoZhiWei 2018/05/22 09:55:58 预留初始化动作,暂不添加,需要的时候加
			room.id = room.fjId 
			room.roleList = {}
			room.dsc = room.desc
			map.room[room.id] = room

			if type(room.extra) == "string" then
				room.extra = {}
			end
			if room.roomType=="tsfangjian011" then 
				map.entryDreamDefaultlRoom=room.fjId
			end
			-- if room.roomType=="tsfangjian004" then 
			-- 	map.entryRoom2=room.fjId
			-- end
			map:addRoomTypeCount(room.roomType,1)
		end 
	end

	do
		-- add by XiaoZhiWei 2018/05/18 21:23:08 初始化角色及物品
		--@desc 初始化家具
		map.roles = {}
		self:initFurniture(map, mapInfo.roomfurniture)

		-- add by XiaoZhiWei 2018/05/22 09:56:54 初始化角色
		do
			local roomRole = Helper:getDef(mapInfo.roomperson, {})
			local role
			for k,roleInfo in pairs(roomRole) do

				--人物初始化
				roleInfo.id = roleInfo.rwId
				if type(roleInfo.extra) ~= "table" then
					roleInfo.extra = {}
				end
				local roleInfo = HomelandRoleUtil:initHomelandMapRole(roleInfo,map)
				if map.room[roleInfo.fjId] == nil then
					if PRINT_MODE == 1 then
						error("数据错误, 房间ID : "..tostring(roleInfo.fjId) .. "不在副本内")
					end
				else
					map.room[roleInfo.fjId].roleList = Helper:getDef(map.room[roleInfo.fjId].roleList, {})
					table.insert(map.room[roleInfo.fjId].roleList, roleInfo.rwId)
					map.roles[roleInfo.rwId] = roleInfo
					map:addPersonJobCount(roleInfo.job,1)
					--记录仆人的基本信息
					if roleInfo.jobType ~= "guanjia001" then 
						local prName = roleInfo.realName or roleInfo.name
						PuRenModel:updateMapPuRenInfo("add", map, roleInfo.rwId, roleInfo.fjId, prName)
					end
				end
			end
		end

		-- add by XiaoZhiWei 2018/05/22 09:57:00 初始化物品
		do
			local roomItem = Helper:getDef(mapInfo.roomfurniture, {})
			for k,itemInfo in pairs(roomItem) do
				if map.room[itemInfo.fjId] == nil then
					if PRINT_MODE == 1 then
						error("数据错误, 房间ID : "..tostring(itemInfo.fjId) .. "不在副本内")
					end
				else
                    map.room[itemInfo.fjId].roleList = Helper:getDef(map.room[itemInfo.fjId].roleList, {})
					table.insert(map.room[itemInfo.fjId].roleList, "f_"..itemInfo.fid)
					
					map:addFurTypeCount(itemInfo.itype,1)
				end
			end
		end
	end


	-- 设置成所有房间已进入
	--[[
		permission 权限,根据副本是否通关,控制房间是否可见 (玩家副本不需要考虑该属性)
		mapHide 地图隐藏,控制房间是否在地图上显示 1为隐藏
		visible 控制房间是否可见 (暂时不考虑)
	]]
	local roomMap = map:getRoomMap()
	for k, room in pairs(roomMap) do
		if room.mapHide == 1 then
			-- add by XiaoZhiWei 2018/05/25 16:49:54 隐藏的副本不需要设置可见
		else
			room.haveBeenTo = true -- add by XiaoZhiWei 2018/05/18 20:58:38 全部都需要设置成已进入
		end
	end


	map.id = "user_fb_" .. map.mid -- add by XiaoZhiWei 2018/05/25 16:43:40 给予一个唯一的副本ID值
	map.entryRoom1 = map.entryRoom

	map.mapAppearanceIndex = string.gsub(map.mapAppearanceIndex, "\r", "")
	map.mapAppearance = string.gsub(map.mapAppearance, "\r", "")
	map.completeConditions = {}
	User:getRole():setMapWithId(map.id, map) -- add by XiaoZhiWei 2018/05/25 16:48:20 将新获取的Id缓存到角色存档

	return map
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/05/25 16:59:04
-- @params 
-- @desc 修改全图相关信息
function UserMap:changeFullFigure(map, roomId, roomName)
	if roomId == nil then
		return 
	end

	local roomIdArray = Helper:getRoomIdArray(map.mapAppearanceIndex)
	local mapLines, mapRoomNamePosArray = Helper:splitMapData(map.mapAppearance)

	local pos 
	for i,id in ipairs(roomIdArray) do
		if id == roomId then
			pos = mapRoomNamePosArray[i]
			break
		end
	end

	local oldName = mapLines[pos.x + 1][pos.y].text
	local str1 = string.sub(map.mapAppearance, 1, pos.index - string.len(oldName)- 1)
	local str2 = string.sub(map.mapAppearance, pos.index - string.len(oldName))
	str2 = string.gsub(str2, oldName, roomName, 1)
	map.mapAppearance = str1.. str2
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 17:36:48
-- @params 
-- @desc 扩建信息初始化
function UserMap:initEnlargeInfo()
	
	-- self.enlargeRoomCount = nil

	self.enlargeCurrRoomCountNor = nil

	self.enlargeCurrRoomCountSpec = nil

	--@desc 普通房间扩建上限
	self.enlargeRoomCountNormal = nil

	--@desc 特殊房间扩建上限
	self.enlargeRoomCountSpecial = nil
	
	self.enlargeRoomTotalCount = nil
	self.enlargeRoomInfo = nil
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/04 11:38:48
-- @params 
-- @desc 是否开启扩建
function UserMap:isOpenEnlarge()
	return Helper:getDef(self._enlargeState, false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 17:06:33
-- @params 
-- @desc 设置扩建开关状态
function UserMap:setEnlargeState(state, normalCount,specialCount)
	self._enlargeState = Helper:getDef(state, false)
	if state == false then
		MainControllLayer:getLayer("MapLayer")._isShowHhgj = 0
	else
		MainControllLayer:getLayer("MapLayer")._isShowHhgj = 1
	end
	if type(normalCount) == "number" and type(specialCount) == "number"  then
		self.enlargeRoomCountNormal = normalCount
		self.enlargeRoomCountSpecial = specialCount
	end
	self:clearEnlargeRoomInfo() -- add by XiaoZhiWei 2018/06/05 17:08:22 不管是设置为开,还是设置为关,都需要把历史记录清空掉


	-- add by XiaoZhiWei 2018/06/05 18:20:32 设置顶部按钮事件
	do
		local layer = MainControllLayer:getLayer("MapRoleLayer")
		if state == true then
			layer:exitButtonFunc(false, function()
				self:setEnlargeState(false)
			end, "RED放弃")
			layer:statusButtonFunc(false, function()
				self:submitEnlargeRoomInfo()
				-- MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
			end, "HIY完成")
		else
			self:initEnlargeInfo()
			layer:exitButtonFunc(true)
			layer:statusButtonFunc(true)
			MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 17:49:24
-- @params 
-- @desc 检查是否已达上限
function UserMap:checkCanEnlarge(rtype)
	if rtype == "空房" then
		self.enlargeCurrRoomCountNor = Helper:getDef(self.enlargeCurrRoomCountNor,0)
		if self.enlargeRoomCountNormal ~= nil and self.enlargeRoomCountNormal  <= self.enlargeCurrRoomCountNor then
			PopText("能扩建的空房数量已达到上限。")
			return false
		end
	elseif rtype == "长廊" then
		self.enlargeCurrRoomCountSpec = Helper:getDef(self.enlargeCurrRoomCountSpec,0)
		if self.enlargeRoomCountSpecial ~= nil and self.enlargeRoomCountSpecial  <= self.enlargeCurrRoomCountSpec then
			PopText("能扩建的长廊数量已达到上限。")
			return false
		end
	else
		self.enlargeCurrRoomCountNor = Helper:getDef(self.enlargeCurrRoomCountNor,0)
		if self.enlargeRoomCountNormal ~= nil and self.enlargeRoomCountNormal > self.enlargeCurrRoomCountNor then
			return true, "空房"
		end
		
		self.enlargeCurrRoomCountSpec = Helper:getDef(self.enlargeCurrRoomCountSpec,0)
		if self.enlargeRoomCountSpecial ~= nil and self.enlargeRoomCountSpecial > self.enlargeCurrRoomCountSpec then
			return true, "长廊"
		end
		PopText("能扩建的数量已达到上限。")
		return false
	end

	return true
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 16:24:53
-- @params 
-- @desc 记录扩建信息
-- 例 : self.enlargeRoomInfo = { fb_01a = {left = "空房", up = "长廊", ...}, ...}
function UserMap:setEnlargeRoomInfo(roomId, direction, rtype,handlerType)
	print(roomId, direction, rtype)
	if roomId == nil or direction == nil then
		return
	end

	-- if self.enlargeRoomTotalCount ~= nil and self.enlargeRoomTotalCount <= self.enlargeRoomCount and rtype ~= nil then
	-- 	return 
	-- end

	-- self.enlargeRoomCount = Helper:getDef(self.enlargeRoomCount, 0)
	self.enlargeCurrRoomCountNor = Helper:getDef(self.enlargeCurrRoomCountNor, 0)
	self.enlargeCurrRoomCountSpec = Helper:getDef(self.enlargeCurrRoomCountSpec, 0)

	self.enlargeRoomInfo = Helper:getDef(self.enlargeRoomInfo, {})
	self.enlargeRoomInfo[roomId] = Helper:getDef(self.enlargeRoomInfo[roomId], {})
	
	if self.enlargeRoomInfo[roomId][direction] == nil then
		-- self.enlargeRoomCount = self.enlargeRoomCount + 1
		if rtype == "空房" then
			self:handleKongFangCount("add")
		elseif rtype == "长廊" then
			self:handleChangLangCount("add")
		else
			print("房间类型出错")
		end
	else
		if handlerType ~= "cancel" and self.enlargeRoomInfo[roomId][direction] == rtype then
		elseif handlerType ~= "cancel" and self.enlargeRoomInfo[roomId][direction] ~= rtype then
			if rtype == "空房" then
				self:handleChangLangCount("sub")
				self:handleKongFangCount("add")
			elseif rtype == "长廊" then
				self:handleChangLangCount("add")
				self:handleKongFangCount("sub")
			end
		elseif handlerType == "cancel" and self.enlargeRoomInfo[roomId][direction] == rtype then
			if rtype == "空房" then
				self:handleKongFangCount("sub")
			elseif rtype == "长廊" then
				self:handleChangLangCount("sub")
			end
			rtype = nil
		elseif handlerType == "cancel" and self.enlargeRoomInfo[roomId][direction] ~= rtype then
			error("操作错误")
			if self.enlargeRoomInfo[roomId][direction] == "空房" then
				self:handleKongFangCount("sub")
			elseif self.enlargeRoomInfo[roomId][direction] == "长廊" then
				self:handleChangLangCount("sub")
			end
			rtype = nil
		end
	end
	print(rtype,handlerType, self.enlargeCurrRoomCountNor, self.enlargeCurrRoomCountSpec)
	self.enlargeRoomInfo[roomId][direction] = rtype
end

function UserMap:handleKongFangCount(handleType)
	self.enlargeCurrRoomCountNor = Helper:getDef(self.enlargeCurrRoomCountNor, 0)
	if handleType == "add" then
		self.enlargeCurrRoomCountNor = self.enlargeCurrRoomCountNor + 1
	elseif handleType == "sub" then
		self.enlargeCurrRoomCountNor = math.max( self.enlargeCurrRoomCountNor - 1,0)
	end
end
function UserMap:handleChangLangCount(handleType)
	self.enlargeCurrRoomCountSpec = Helper:getDef(self.enlargeCurrRoomCountSpec, 0)
	if handleType == "add" then
		self.enlargeCurrRoomCountSpec = self.enlargeCurrRoomCountSpec + 1
	elseif handleType == "sub" then
		self.enlargeCurrRoomCountSpec = math.max( self.enlargeCurrRoomCountSpec - 1,0)
	end
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 16:27:08
-- @params 
-- @desc 获取指定房间的扩建信息
function UserMap:getEnlargeRoomInfoByRoomId(roomId)
	self.enlargeRoomInfo = Helper:getDef(self.enlargeRoomInfo, {})
	return Helper:getDef(self.enlargeRoomInfo[roomId], {}) 
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 16:51:01
-- @params 
-- @desc 清空房间扩建信息
function UserMap:clearEnlargeRoomInfo()
	self.enlargeRoomInfo = {}
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 16:52:02
-- @params 
-- @desc 提交房间扩建信息
function UserMap:submitEnlargeRoomInfo()
	if self:isOpenEnlarge() == false then
		if PRINT_MODE == 1 then
			assert(nil, "状态不对,需要检查")
		end
	end

	--[[
		self.enlargeRoomInfo 房屋扩建信息 例 : self.enlargeRoomInfo = { fb_01a = {left = "空房", up = "长廊", ...}, ...}
		self.enlargeRoomCount 房屋扩建的总数量

		self.enlargeRoomCost  房屋扩建的总金额
		需要判断扩建数量是否过多
	]]

	if self.enlargeCurrRoomCountNor == nil or self.enlargeCurrRoomCountSpec == nil or 
	(self.enlargeCurrRoomCountNor == 0 and self.enlargeCurrRoomCountSpec == 0) then
		PopText("没有任何改动！")
		return
	end

	-- add by XiaoZhiWei 2018/06/05 16:53:25 结构化服务器需要的房屋信息
	local AddRoomData = {}
	local transform = {
		up = "down",
		down = "up",
		left = "right",
		right = "left",
		leftUp = "rightDown",
		leftDown = "rightUp",
		rightDown = "leftUp",
		rightUp = "leftDown",
	}

	local currMap = User:getRole():getCurrMap()
	local mid = currMap.mid
	local attr = {}

	local upload = {}
	local count = 0
	
	local totalCount = self.enlargeCurrRoomCountNor + self.enlargeCurrRoomCountSpec
	local point = totalCount * UserMapConstans.enlargeRoomPrice
	for currRoomId,tab in pairs(self.enlargeRoomInfo) do
		local roomIdList = self:createOneOrMoreRoomId(totalCount)
		for k,v in pairs(tab) do
			count = count + 1
			local newdata = {}
			local fjId = roomIdList[count]
			
			table.insert(newdata,currRoomId )
			table.insert(newdata,k )
			table.insert(newdata,fjId )

			table.insert(upload,newdata)

			local attrList = {}
			local roomType = ""
			if v == "空房" then
				roomType = "tsfangjian001"
				attrList = clone(HomelandRoomUtil:getSpeciaRoomAttr(roomType))
			elseif v == "长廊" then
				roomType = "ptfangjian001"
				attrList = clone(HomelandRoomUtil:getNormalRoomAttr(roomType))
			else
				assert(false,"扩建房间类型出错")
			end
			
			attrList.fjId = fjId
			attrList[transform[k]]= currRoomId
			table.insert(attr,attrList)

			local relation1 = 
				{
					id = fjId,
					name = v,
					dsc = attrList.roomdsc,
					roomType = roomType,
					link = 
					{
						[transform[k]] = currRoomId,
					}
				}
			local relation2 = 
				{
					id = currRoomId,
					link = 
					{
						[k] = fjId,
					}
				}

			table.insert( AddRoomData,relation1 )
			table.insert( AddRoomData,relation2 )

		end
		
	end
	Helper:print_lua_table(upload)
	Helper:print_lua_table(attr)

	-- add by XiaoZhiWei 2018/06/05 17:10:36 批量提交房屋扩建信息
	do	
		if MapIsEmpty(upload) then
			print("没有上传数据，直接关闭。")
			self:setEnlargeState(false)
			-- MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
			-- MainControllLayer:getLayer("MapLayer"):initRoom()
			return
		end
		local DialogALayer = require("app.views.layer.DialogLayer.DialogALayer")
		local dialog = DialogALayer:getInstance()
		dialog:show("你确定要花费"..point.."银票扩建吗？")
		dialog:setButton1("确定", function()
			print("mid,attr,point,upload = ",mid,attr,point,upload)
			HttpManagerEx:roomExtension(mid,attr,point,upload,function(status, errcode, errmsg, data)
				if status == 200 then
					if errcode == 0  then
					Helper:print_lua_table(AddRoomData)
					for k,v in pairs(AddRoomData) do
						local mapRoom = currMap:getRoomMap()
						local room = mapRoom[v.id]
						if room == nil then
							local baseRoom = {
								id = "",
								name = "",
								up = "",
								down = "",
								left = "",
								right = "",
								leftUp = "",
								leftDown = "",
								rightDown = "",
								rightUp = "",	
								roomBgm = "",
								haveBeeTo = true,
								roomBgmRule = 1,
								spaceTime = 0,
								vasible = 1,
								link = {},
								mapHide = 0,
								BgmDown = 1,
								desc = "",
								dsc = "",
								permission = 1,
								enterable = 1,
								fjId = "",
								roomType = "",
								stepMusic = "jiaobu",
								roleList = {},
								mid=mid,
							}
							Helper:tableCover(baseRoom,v)
							
							currMap.room[v.id] = baseRoom

							--@desc 房间数量统计
							currMap:addRoomTypeCount(currMap.room[v.id].roomType,1)
						else
							Helper:tableCover(room,v)
						end
					end

					
					PopupLayerController:showLayer("GlobalShadeLayer",function ( layer )
						layer:showLayer()
						layer:setPopText("房间扩建中，请稍后。")
					end)

					-- add by XiaoZhiWei 2018/06/05 18:16:01 提交完成之后需要关闭扩建模式
					local HomelandDesc = require("app.models.HomelandModel.HomelandDesc")
					local textArr = HomelandDesc:getEnlargeRoomDesc(currMap)
					local index = 1
					currMap:setSchedule(function (tag)
						RichPrint("main",textArr[index])
						if index == #textArr then
							currMap:unSchedule(tag)
							self:setEnlargeState(false)
							MainControllLayer:getLayer("MapLayer"):delayRefreshMap()
							MainControllLayer:getLayer("MapLayer"):initRoom()
							PopupLayerController:hideLayer("GlobalShadeLayer",function ( layer )
								layer:hideLayer()
							end)
						end
						index = index + 1
					end,2)

					else
						print("errcode : ",errcode)
						PopText(errmsg)
					end
				else
					PopText(errmsg)
				end
			end, IS_SHOW_WAITING)
		end)
		dialog:setButton2("取消", function()
			-- dialog:hide()
		end)
	end

end

-- 检查是否是特殊房间 
function UserMap:checkIsSpecailRoom(roomType)
		-- 判断
	-- self._currMap.room[self._currRoom.id].roomType
	if HomelandRoomUtil:roomIsSpecial(roomType) then
		return true
	end
	return false
end

--扩建生成RoomId
--num 生成id的数量
function UserMap:createOneOrMoreRoomId(num)
	num = Helper:getDef(num,1)

	local roomIdList= {}
	do  
		local currMap = User:getRole():getCurrMap()

		local roomMap = currMap:getRoomMap()

		local tab = {}
		local str
		for k,v in pairs(roomMap) do
			str = string.split(k,"_")
			table.insert( tab,str[2])
		end

		table.sort(tab,function (a,b)
			return tonumber(a) < tonumber(b)
		end)
		
		local MaxNum = tab[#tab]

		for i = 1,num do
			local roomId = str[1].."_"..tonumber(MaxNum+i)
			table.insert(roomIdList,roomId)
		end
	end
	
	return roomIdList
end

--@desc: 初始化家具信息
--@author:Liang SongQiang
--@time:2018-06-01 09:41:09
--@furnitureList: 家具列表
function UserMap:initFurniture(map, furnitureList)
    --@RefType [src.app.models.HomelandModel.FurnitureModel.FurnitureModel#FurnitureModel]
    local FurnitureModel = require("app.models.HomelandModel.FurnitureModel.FurnitureModel")

    for k, v in pairs(furnitureList) do
        FurnitureModel:initFurnitureForUserMap(map, v)
    end
end

--@desc:
--@author:Liang SongQiang
--@time:2018-06-28 17:48:59
function UserMap:updateMapExtraAttr(mid,attr,point,callback)
	if not mid then
		if DEBUG_MODE == 1 then
			assert(false,"没有mid，检查代码")
		end
		return
	end

	if not point then
		point = 0
	end
	HttpManagerEx:uploadMapExtra(
		mid,
		attr,
		point,
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					print("上传成功")
					if callback then
						callback()
					end
				else
					PopText(errmsg)
				end
				return true
			else
				PopText(errmsg)
				return false
			end
		end,
		IS_SHOW_WAITING,
		HTTP_MANAGER_RETRY_TYPE_RETRY
	)
end


--@desc: 获取房屋朝向，反方向。
--@author:Liang SongQiang
--@time:2018-07-02 21:05:13
--@index:索引 
function UserMap:getHouseNegativeDirByIndex(index)
	index = index or 0

	local dir = switch(tostring(index),{
		["0"] = "down",
		["1"] = "left",
		["2"] = "up",
		["3"] = "right",
	})
	
	return dir
end

--@desc: 获取房屋朝向
--@author:Liang SongQiang
--@time:2018-07-02 21:05:13
--@index:索引 
function UserMap:getHouseDirByIndex(index)
	index = index or 0

	local dir = switch(tostring(index),{
		["0"] = "up",
		["1"] = "right",
		["2"] = "down",
		["3"] = "left",
	})
	
	return dir
end

--@desc: 设置缓存
--@author:Liang SongQiang
--@time:2018-07-03 11:00:57
--@time: 过期时间
function UserMap:setCache(key,value,duration)
	local currTime = GetTime()

	duration = duration or 900

	local expireTime = currTime + duration

	local uid = User:getUserId()

	local file = DataBase:getLuaTable("userMapCache")

	local res
	if not file or file[uid] == nil then
		DataBase:setLuaTable("userMapCache",{[uid] = {}})
	end
	
	file = DataBase:getLuaTable("userMapCache")
	local _flag = false

	for k,v in pairs(file[uid]) do
		if self:getCache(k) ~= 0 then
			_flag = true
		end
	end
	if _flag == false then
		DataBase:setLuaTable("userMapCache",{[uid] = {}})
		file = DataBase:getLuaTable("userMapCache")
	end

	if file[uid][key] == nil then
		file[uid][key] = {
			value = 0,
			expireTime = 0,
		}
	end

	file[uid][key].value = value
	file[uid][key].expireTime = expireTime
	DataBase:setLuaTable("userMapCache",file)
end

--@desc 获取缓存值
function UserMap:getCache( key )
	local uid = User:getUserId()

	local file = DataBase:getLuaTable("userMapCache")

	local res
	if not file then
		DataBase:setLuaTable("userMapCache",{[uid] = {}})
	end

	res = DataBase:getLuaTable("userMapCache")[uid]
	
	if res == nil then
		res = {}
	end

	if res[key] == nil then
		res[key] = {
			value = 0,
			expireTime = 0,
		}
	end
	
	if res[key].expireTime ~= 0 and GetTime() >= res[key].expireTime then
		res[key] = {
			value = 0,
			expireTime = 0,
		}
	end

	return res[key].value
end

--@desc 清除缓存
function UserMap:clearCache(key)
	local uid = User:getUserId()
	local file = DataBase:getLuaTable("userMapCache")
	local res
	if not file then
		DataBase:setLuaTable("userMapCache",{[uid] = {}})
	end

	file = DataBase:getLuaTable("userMapCache")

	if file[uid][key] ~= nil then
		file[uid][key] = nil
	end

	DataBase:setLuaTable("userMapCache",file)
end

--@desc 进入小村庄
function UserMap:goVillageMap(fromMap,locationArray,needAnim)
	--@RefType [src.app.models.map.UserMapRelation#UserMapRelation]
	local UserMapRelation = require("app.models.map.UserMapRelation")

	if needAnim == nil then
		needAnim = true
	end

			
	local time = 0.1
	local entryMapLayer
	if needAnim then
		time = 1
		entryMapLayer = fromMap.__MapLayer.ControllLayer:getLayer("EntryMapLayer")
		entryMapLayer:maxZ()
		entryMapLayer:show()
	end
	

	local villageIndex = locationArray[3]
	local toMapId = UserMapRelation:getVillageFbId(villageIndex)

	local function goVillage(village_user_house)
		fromMap.__MapLayer.TotalMapBtn_IsInit = false

						-- Helper:print_lua_table(data)
		--@desc 获取副本对应的地图模板
		local toMap = User:getRole():getMapById(toMapId)
		toMap = User:getRole():initMapById(toMapId)

		fromMap.__MapLayer:delayFunc(time,
		function()	
			toMap:setCallBackAndConnect(function()
				if entryMapLayer then
					entryMapLayer:hide(function()
					end) -- 隐藏界面
					RichPrint("main", "HIC你身形一转，跃下马来，姿势十分优美。")
				end
				
				--@desc 需要替换公共副本数据
				toMap.cityIndex = locationArray[1]
				toMap.villageIndex = villageIndex

				local room
				for index, roomInfo in pairs(village_user_house) do
					-- local roomId = string.split(roomInfo.dpRoomId,";")[2]
					local rooms = toMap.room
					for mRoomId,mRoomInfo in pairs(rooms) do
						if mRoomInfo.flag1 and mRoomInfo.flag1 == roomInfo.loc_sort then
							room = Helper:tableCover(toMap.room[mRoomId], roomInfo)
							break
						end
					end
				end

				fromMap.__MapLayer:setMap(toMap)
				-- FubenClient:comeIn(toMap.id, fromMap.__MapLayer._currRoom.id, toMap:getRoomNameById(fromMap.__MapLayer._currRoom.id), Helper:getOnlyId())
				local toRoomId = fromMap.toRoomId
				if toRoomId ~= nil then
					fromMap.__MapLayer:replaceRoom(toRoomId,self:getHouseNegativeDirByIndex(fromMap.dirMark))
					fromMap.__MapLayer:delayFunc(
						0.6,
						function()
							FubenClient:comeIn(toMap.id, toRoomId, toMap:getRoomNameById(toRoomId), Helper:getOnlyId())
						end
					)
				else
					toRoomId = toMap.entryRoom1
					fromMap.__MapLayer:replaceRoom(toRoomId,self:getHouseNegativeDirByIndex(fromMap.dirMark))
					fromMap.__MapLayer:delayFunc(
						0.6,
						function()
							FubenClient:comeIn(toMap.id, toRoomId, toMap:getRoomNameById(toRoomId), Helper:getOnlyId())
						end
					)
				end
				fromMap.__MapLayer:delayRefreshMap()
				-- 释放地图动画层
				MainControllLayer:removeLayer("EntryMapLayer")
				MainControllLayer:pushLayer("MapLayer")
				MessageCenter:notify("EnterMap",{map=toMap})
			end)
		end)
	end


	HttpManagerEx:getLocationMap(locationArray,function (status, errcode, errmsg, data)
		if status == 200 then
			if errcode == 0 then
				--@TODO 暂时不设置缓存
				-- self:setCache(_cacheKey,data.list)
				goVillage(data.list)
				return true
			else
				PopText(errmsg)
				print("errcode : ",errcode)
				return false
			end
		else
			PopText(errmsg)
			return false
		end
	end,
	IS_SHOW_WAITING,
	HTTP_MANAGER_RETRY_TYPE_RETRY)

	
	-- --@desc 读取缓存
	-- local _cacheKey = ""
	-- for k,v in pairs(locationArray) do
	-- 	_cacheKey = _cacheKey..v
	-- end
	-- _cacheKey = _cacheKey..toMapId

	-- print("_cacheKey : ",_cacheKey)

	-- local dataCache = self:getCache(_cacheKey)

	-- if dataCache == 0 then
	-- else
	-- 	goVillage(dataCache)
	-- end

end


return UserMap0000000000000000