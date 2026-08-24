local TotalMapRoomUI = require("app.views.ui.MapUI.TotalMapRoomUI")

local TotalMapLayer = class("TotalMapLayer", require("app.views.base.BaseLayer"))

function TotalMapLayer:create()
	local p = TotalMapLayer:new()
	p:init()
	return p
end

function TotalMapLayer:init()
	return true
end

function TotalMapLayer:setMap(map)
	self._currMap = map


	-- local text = ccui.Text:create()
	-- text:setString("大地图!!! 构思中....")
	-- text:setFontSize(100)
	-- text:addTo(self)
	-- text:move(display.center)


	self:initRooms()
end

function TotalMapLayer:initRooms()
	if PRINT_MODE == 1 then
		print("TotalMapLayer:initRooms()")
	end
	
	-- local function getIndexByXY(x, y)
	-- 	-- body
	-- end

	local rooms = {}
	local startRoom = nil	
	local currX, currY = 0, 0
	local roomCount = 0
	local maxX, minX, maxY, minY = 0, 0, 0, 0

	for k, room in pairs(self._currMap.room) do
		startRoom = room
		break
	end


	-- 深度优先遍历
	local function walkRoom(room, func, ...)
		local walkedRoom = {} -- 已经遍历过的房间

		-- 深度优先遍历
		local function _depthFirstWalkRoom(room, func, ...)
			assert(func, "func == nil")

			if walkedRoom[room.id] then -- 遍历过的不再次遍历
				return
			end			

			do -- 遍历
				walkedRoom[room.id] = room
				func(room, ...)
			end

			local link = room.link
			if link == nil then
				return
			end
			for direction, roomId in pairs(link) do
				if PRINT_MODE == 1 then
					print("direction = "..tostring(direction))
					print("roomId = "..tostring(roomId))
				end
				_depthFirstWalkRoom(self._currMap.room[roomId], func, direction)
			end
		end

		-- -- 广度优先遍历
		-- local breadthFirstList = {}
		-- local function _breadthFirstWalkRoom(room, func, ...)
		-- 	assert(func, "func == nil")

		-- 	if walkedRoom[room.id] then -- 遍历过的不再次遍历
		-- 		return
		-- 	end

		-- 	do -- 遍历
		-- 		walkedRoom[room.id] = room
		-- 		func(room, ...)
		-- 	end

		-- 	local link = room.link
		-- 	if link == nil then
		-- 		return
		-- 	end

		-- 	for direction, roomId in pairs(link) do
		-- 		print("direction = "..tostring(direction))
		-- 		print("roomId = "..tostring(roomId))
		-- 		breadthFirstList()
		-- 	end


		-- end
		
		_depthFirstWalkRoom(room, func, ...)		
	end

	local function walkRoom(room, func, ...)
		-- 广度优先遍历
		local walkedRoom = {}
		local breadthFirstParentList = {}
		local breadthFirstChildList = {}
		local function _breadthFirstWalkRoom(room, func, ...)
			assert(room and func, "room and func 不能为nil或者false")

			if walkedRoom[room.id] then -- 遍历过的不再次遍历
				return
			end

			do -- 遍历
				walkedRoom[room.id] = room
				func(room, ...)
			end

			local link = room.link
			if link == nil then
				return
			end

			for direction, roomId in pairs(link) do
				if PRINT_MODE == 1 then
					print("direction = "..tostring(direction))
					print("roomId = "..tostring(roomId))
				end
				
				table.insert(breadthFirstChildList, {room = self._currMap.room[roomId], direction = direction})
			end
		end

		table.insert(breadthFirstParentList, {room = room, direction = "center"})
		while true do 
			breadthFirstChildList = {}
			for k,v in pairs(breadthFirstParentList) do
				_breadthFirstWalkRoom(v.room, func, v.direction)
			end

			if #breadthFirstChildList > 0 then
				breadthFirstParentList = breadthFirstChildList			
			else
				break -- 完成
			end
		end
	end

	local function tidyRooms(rooms, __x, __y, direction)
		local directionVec2 = Helper:getDirectionVec2(direction)
		local needMoveRooms = {}
		for y = minY, maxY do
			for x= minX, maxX do
				local room = rooms[x..y]
				if room then
					-- 筛选反方向的所有房间					
					local needMove = true
					if directionVec2.x > 0 and x >= __x then
						needMove = false
					end

					if directionVec2.x < 0 and x <= __x then
						needMove = false
					end

					if directionVec2.y > 0 and y >= __y then
						needMove = false
					end

					if directionVec2.y < 0 and y <= __y then
						needMove = false
					end
					if needMove then
						table.insert(needMoveRooms, room)
					end
				end
			end
		end

		if PRINT_MODE == 1 then
			print("needMoveRooms count = "..tostring(#needMoveRooms))
		end
		for k, room in pairs(needMoveRooms) do
			local oldKey = room.x..room.y
			room.x = room.x - directionVec2.x
			room.y = room.y - directionVec2.y
			local newKey = room.x..room.y
			rooms[newKey] = rooms[oldKey]
			rooms[oldKey] = nil
		end
	end
	
	walkRoom(startRoom, 
		function(room, direction)
			if room then			
				if PRINT_MODE == 1 then
					print("roomName = "..room.name)
				end
				roomCount = roomCount + 1

				local directionVec2 = nil
				if direction == "center" then
					directionVec2 = Helper:getDirectionVec2(direction)
				else
					directionVec2 = Helper:getDirectionVec2(direction)
				end
				currX = currX + directionVec2.x
				currY = currY + directionVec2.y

				maxX = math.max(maxX, currX)
				minX = math.min(minX, currX)
				maxY = math.max(maxY, currY)
				minY = math.min(minY, currY)

				if rooms[currX..currY] then
					-- 如果该位置已经有了，则需要调整其余位置
					-- tidyRooms(rooms, currX, currY, direction)
					-- 如果这个位置没有，则直接设置
					rooms[currX..currY] = 
					{
						x = currX,
						y = currY,
						room = room
					}
				else
					-- 如果这个位置没有，则直接设置
					rooms[currX..currY] = 
					{
						x = currX,
						y = currY,
						room = room
					}
				end
			end
		end, "center")

	if PRINT_MODE == 1 then
		print("roomCount = "..roomCount)
		print("minX = "..minX)
		print("maxX = "..maxX)
		print("minY = "..minY)
		print("maxY = "..maxY)
	end

	local function getRoomPos(x, y)
		local width = 100
		local height = 100
		local posX = x * width
		local posY = y * height
		return posX, posY
	end

	for y = minY, maxY do
		for x= minX, maxX do
			local room = rooms[x..y]
			if room then
				-- 有该房间，可以直接放置
				local totalMapRoomUI = TotalMapRoomUI:create()
				self:addChild(totalMapRoomUI)
				totalMapRoomUI:move(cc.pAdd(display.center, cc.p(getRoomPos(x, y))))
				totalMapRoomUI:setName(room.room.name)
			end
		end
	end
end

return TotalMapLayer0000000