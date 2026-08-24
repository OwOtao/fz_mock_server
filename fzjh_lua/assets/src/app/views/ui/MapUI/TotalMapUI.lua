local Resource = require("app.Resource")
local TotalMapUI = class("TotalMapUI", ccui.Widget)

local ITEM_TYPE_BLANK = 1
local ITEM_TYPE_ROOM = 2
local function print()
end

function TotalMapUI:create(parent, mapData, roomIdData, buttonCallback)
	local p = TotalMapUI:new()
	p:initWithMapData(parent, mapData, roomIdData, buttonCallback)
	return p
end

function TotalMapUI:init()
	if PRINT_MODE == 1 then
		print("display.width = "..display.width)
		print("display.height = "..display.height)
	end
	self:setAnchorPoint(cc.p(0, 0.5))
	self:setContentSize(display.width, display.height)
	self:initWithMapData()
end

function TotalMapUI:initWithMapData(parent, mapData, roomIdData, buttonCallback)
	self:removeAllChildren()

	self:setAnchorPoint(cc.p(0, 0))
	if parent ~= nil then
		self:setContentSize(parent:getContentSize())
	else
		self:setContentSize(display.width, display.height)
	end

	self.roomMap = {}

	if mapData == nil then
		mapData = [[菜地——后院——菜地
　　　　　▏
马房——后院——木材房　　　馆主卧室　　　　　　　卧室——卧室
　　　　　▏　　　　　　　　　　▏　　　　　　　　　▏
水房——后院——柴房　　　　　长廊——书房　　　　长廊
　　　　　▏　　　　　　　　　　▏　　　　　　　　　▏
　　　　石路　　　习武堂　　　　▏　　　　学堂　　　▏
　　　　　▏　　　　▏　　　　　▏　　　　　▏　　　▏
饭厅——石路———石路————大厅————石路——物品房
　　　　　▏　　　　▏　　　　　▏　　　　　▏　　　▏
　　　　长廊　　　习武堂　　　　▏　　　　帐房　　长廊
　　　　　▏　　　　　　　　　　▏　　　　　　　　　▏
　　　　西武场　　　　　　　武馆大院　　　　　　　东武场
　　　　　▏　　　　　　　　　　▏　　　　　　　　　▏
　　　　西武场——长廊———武馆大院———长廊——东武场
　　　　　　　　　　　　　　　　▏
　　　　　　　　　　　　　　　石路
　　　　　　　　　　　　　　　　▏
　　　　　　　　　　　　　　　石路
　　　　　　　　　　　　　　　　▏
　　　　　　　　　　　　　　　大门
　　　　　　　　　　　　　　　　▏
　　　　　　　　　　　　　　　石路]]
	end

	if roomIdData == nil then
		roomIdData = [[fb01_35,fb01_36,fb01_37
fb01_30,fb01_31,fb01_32,fb01_07,fb01_33,fb01_34
fb01_26,fb01_27,fb01_28,fb01_05,fb01_06,fb01_29
fb01_23,fb01_24,fb01_25
fb01_18,fb01_19,fb01_20,fb01_04,fb01_21,fb01_22
fb01_14,fb01_15,fb01_16,fb01_17
fb01_12,fb01_03,fb01_13
fb01_08,fb01_09,fb01_02,fb01_10,fb01_11
fb01_01c
fb01_01b
fb01_01
fb01_01a]]
	end

	local width = self:getContentSize().width --1080
	local height =self:getContentSize().height --1080
	if PRINT_MODE == 1 then
		print("width = "..tostring(width))
	end

	-- if self.scrollView == nil then
	self.scrollView = ccui.ScrollView:create()
	-- end

	local scrollView = self.scrollView

	self:addChild(scrollView)
	scrollView:setDirection(3) -- both
	scrollView:setBounceEnabled(true)
	-- scrollView:setPosition(cc.p(0, 1920 - 1080))
	scrollView:setContentSize(width, height)

	-- 屏蔽触控层
	self._ignoreTouchLayer = ccui.Layout:create()
	self:addChild(self._ignoreTouchLayer, 1)
	self._ignoreTouchLayer:setContentSize(width, height)
	self:setScrollViewTouchEnabled(true)
	-- self._ignoreTouchLayer:setTouchEnabled(true)
	-- self._ignoreTouchLayer:setSwallowTouches(true)


	-- 房间节点集合
	local roomGroupNode = self:createRoomGroupNode(mapData, roomIdData)
	scrollView:addChild(roomGroupNode)
	scrollView:setScrollBarEnabled(false)
	scrollView:setInnerContainerSize(roomGroupNode:getContentSize())

	-- 适应区域大小
	if width > roomGroupNode:getContentSize().width then
		roomGroupNode:setPositionX((width - roomGroupNode:getContentSize().width) / 2)
	end
	if height > roomGroupNode:getContentSize().height then
		roomGroupNode:setPositionY((height - roomGroupNode:getContentSize().height) / 2)
	end

	-- local sprite = cc.Sprite:create("test.png")
	-- scrollView:addChild(sprite)
	-- sprite:setPosition(scrollView:getInnerContainerSize().width / 2, scrollView:getInnerContainerSize().height / 2)
	-- self:scrollToPosition(sprite:getPositionX(), sprite:getPositionY(), 0)
	self:scrollToPercent(50, 50, 0)


	-- 添加按钮
	if buttonCallback == nil then
		buttonCallback = function(index)
			if PRINT_MODE == 1 then
				print("index = "..index)
			end
		end
	end

	local posX, posY = scrollView:getPosition()
	local width, height = scrollView:getContentSize().width, scrollView:getContentSize().height
	for i = 1, 3 do
		for j = 1, 3 do
			local x = posX + (j - 1) * (width / 3)
			local y = posY + (i - 1) * (height / 3)

			local button = ccui.Button:create("test.png")
			button:setAnchorPoint(cc.p(0, 0))
			-- button:setContentSize(scrollView:getContentSize())
			button:setScaleX((width / 3) / button:getContentSize().width)
			button:setScaleY((height / 3) / button:getContentSize().height)
			self:addChild(button)
			button:setPosition(cc.p(x, y))
			button:setSwallowTouches(false)
			button:setMoveTouchCancelEnable(true)
			button:setOpacity(0)
			button:releaseFunc(function()
				-- print("测试..")
				if buttonCallback then
					buttonCallback((i - 1) * 3 + j)
				end
			end)
		end
	end


	-- self:setAllRoomColor(cc.c3b(255, 0, 0))

	-- 其他操作
	-- self:moveToCenter()
	-- fb01_04

	-- self:scrollToRoom("fb01_04")

	-- self:scrollToPosition(0, y, 0)
	-- self:scrollToPercent(50, 50, 0)

	-- for k, room in pairs(self.roomMap) do
	-- 	print("roomMap."..k.." = "..room.text)
	-- 	room.node:setColor(cc.c3b(255, 0, 0))
	-- end
end

-- 得到房间数据
function TotalMapUI:getRoomById(roomId)
	return assert(self.roomMap[roomId], "找不到房间号:"..tostring(roomId))
end

-- 设置某个room的名字
function TotalMapUI:setRoomName(roomId, name)
	local room = self:getRoomById(roomId)
	if name then
		room.node:setString(name)
	else
		room.node:setString(room.text)
	end
end

-- 设置显示状态
function TotalMapUI:setRoomShowType(roomId, showType)
	local room = self:getRoomById(roomId)
	if showType == "可见" then
		room.node:setVisible(true)
		room.node:setString(room.text)
	elseif showType == "不可见" then
		room.node:setVisible(true)
		local len = string.len(room.text)
		if PRINT_MODE == 1 then
			print("len = "..len)
		end
		local text = ""
		for i=1, len / 3 do
			text = text.."?"
		end
		room.node:setString(text)
	elseif showType == "隐藏" then
		room.node:setVisible(false)
	end
end

-- 设置某个room的颜色
function TotalMapUI:setRoomColor(roomId, color)
	local room = self:getRoomById(roomId)
	room.node:setColor(color)
end

-- 设置所有room颜色
function TotalMapUI:setAllRoomColor(color)
	for k, room in pairs(self.roomMap) do
		room.node:setColor(color)
	end
end

-- 移动到某个房间
function TotalMapUI:scrollToRoom(roomId)
	local room = self:getRoomById(roomId)
	if PRINT_MODE == 1 then
		print("移动到房间"..room.text)
	end
	local roomNode = room.node
	local roomNodeSize = room.node:getContentSize()
	roomNode:setColor(cc.c3b(0, 255, 0))

	local worldPos =  roomNode:convertToWorldSpace(cc.p(0, 0))
	local scrollPos = self.scrollView:getInnerContainer():convertToNodeSpace(worldPos)

	local x, y = roomNode:getPosition()
	if PRINT_MODE == 1 then
		print("节点当前位置 = "..x..", "..y)

		print("worldPos = "..worldPos.x..", "..worldPos.y)
		print("scrollPos = "..scrollPos.x..", "..scrollPos.y)
	end


	-- 移动钱禁用触控
	self:setScrollViewTouchEnabled(false)
	self:scrollToPosition(x + roomNodeSize.width / 2, y - roomNodeSize.height / 2, nil,
		function()
			-- 移动后恢复触控
			self:setScrollViewTouchEnabled(true)
		end)
end

-- 按百分比移动
function TotalMapUI:scrollToPercent(percentX, percentY, duration, callback)
	if PRINT_MODE == 1 then
		print("TotalMapUI:scrollToPercent("..tostring(percentX)..", "..tostring(percentY)..", "..tostring(duration)..")")
	end

	if duration == nil then
		duration = 0.3
	end
	percentY = 100 - percentY
	if percentX < 0 then
		percentX = 0
	elseif percentX > 100 then
		percentX = 100
	end

	if percentY < 0 then
		percentY = 0
	elseif percentY > 100 then
		percentY = 100
	end

	if duration > 0 then
		self.scrollView:scrollToPercentBothDirection(cc.p(percentX, percentY), duration, true)
	else
		self.scrollView:jumpToPercentBothDirection(cc.p(percentX, percentY))
	end

	self:delayFunc(duration,
		function()
			if type(callback) == "function" then
				callback()
			end
		end)
end

-- 按位置移动
function TotalMapUI:scrollToPosition(posX, posY, duration, callback)
	local contentSize = self.scrollView:getContentSize()
 	local innerContainerSize = self.scrollView:getInnerContainerSize()



 	-- local percentX = (posX / innerContainerSize.width) * 100  --/ (innerContainerSize.width - contentSize.width) * 100
 	-- local percentY = (posY / innerContainerSize.height) * 100 -- / (innerContainerSize.height - contentSize.height) * 100

 	local percentX = (posX - contentSize.width / 2) / (innerContainerSize.width - contentSize.width) * 100
 	local percentY = (posY - contentSize.height / 2) / (innerContainerSize.height - contentSize.height) * 100

 	self:scrollToPercent(percentX, percentY, duration, callback)
end

-- 移动到中间
function TotalMapUI:moveToCenter()
	self:scrollToPercent(50, 50, 0)
end

-- 设置是否可以触控
function TotalMapUI:setScrollViewTouchEnabled(b)
	if PRINT_MODE == 1 then
		print("TotalMapUI:setScrollViewTouchEnabled("..tostring(b)..")")
	end

	self._ignoreTouchLayer:setTouchEnabled(true)
	self._ignoreTouchLayer:setSwallowTouches(true)
	if b == true then
		self._ignoreTouchLayer:setPositionY(9999)
	else
		self._ignoreTouchLayer:setPositionY(0)
	end
end

-- 创建房间集合节点
function TotalMapUI:createRoomGroupNode(mapStr, mapRoomIdData)
	-- 房间map
	self.roomMap = {}
	local currRoomMapCount = 0

	-- 获得房间id数组
	local roomIdArray = self:getRoomIdArray(mapRoomIdData)
	local mapRoomIdCount = #roomIdArray

	-- 创建房间集合节点
	local mapNodeGroup = cc.Node:create()
	local mapLines, mapRoomNamePosArray = self:splitMapData(mapStr)
	local mapRoomNameCount = #mapRoomNamePosArray
	local startPosX, startPosY = 0, 0
	local posX, posY = startPosX, startPosY
	local lineHeight = 0
	local width, height = 0, 0
	-- for i, mapLine in ipairs(mapLines) do
	if PRINT_MODE == 1 then
		print("mapRoomIdCount = "..tostring(mapRoomIdCount)..", mapRoomNameCount = "..tostring(mapRoomNameCount))
	end
	assert(mapRoomIdCount == mapRoomNameCount, "mapRoomIdCount = "..tostring(mapRoomIdCount)..", mapRoomNameCount = "..tostring(mapRoomNameCount))

	local mapNodes = {}
	for i = 1, #mapLines do
		local mapLine = mapLines[i]
		posX = startPosX
		for i, item in ipairs(mapLine) do
			local textView, textViewSize =  self:createLabel(item.text)
			if PRINT_MODE == 1 then
				print("textViewSize.width = "..textViewSize.width)
			end
			table.insert(mapNodes, textView)
			textView:setAnchorPoint(cc.p(0.5, 0.5))
			-- textView:setColor(cc.c3b(math.random(127, 255), math.random(127, 255), math.random(127, 255)))
			mapNodeGroup:addChild(textView)
			textView:move(cc.p(posX + textViewSize.width / 2, posY - textViewSize.height / 2))
			if PRINT_MODE == 1 then
				print("posX = "..posX)
			end
			posX = posX + textViewSize.width
			lineHeight = textViewSize.height

			width = math.max(width, posX) -- 地图宽度

			-- 添加房间节点到roomMap
			do
				if item.type == ITEM_TYPE_ROOM then
					local room = {}
					room.text = item.text
					room.node = textView

					local roomId = roomIdArray[currRoomMapCount + 1]
					if PRINT_MODE == 1 then
						print("#roomIdArray = "..tostring(#roomIdArray))
						print("currRoomMapCount = "..currRoomMapCount)
					end

					if type(roomId) == "string" then
						self.roomMap[roomId] = room
						currRoomMapCount = currRoomMapCount + 1
					elseif type(roomId) == "table" then
						for k, id in pairs(roomId) do
							self.roomMap[id] = room
						end
						currRoomMapCount = currRoomMapCount + 1
					else
						error("roomId类型出错不能为:"..type(roomId))
					end
				end
			end
		end
		posY = posY - lineHeight

		height = math.max(height, -posY) -- 地图高度
	end

	-- 移动所有节点，让整体锚点在 0，0 位置。
	for i, node in ipairs(mapNodes) do
		node:setPositionY(node:getPositionY() + height)
	end

	if PRINT_MODE == 1 then
		print("width = "..width)
		print("height = "..height)
	end

	mapNodeGroup:setContentSize(width, height) -- 设置地图宽高
	return mapNodeGroup
end

-- 拆分房间名和占位符
local otherStr = {["▏"]=true, ["\n"]=true,["—"] = true, ["╲"] = true, ["　"] = true, [" "] = true, ["╱"] = true, ["＠"] = true}
function TotalMapUI:splitMapData(str)
	return Helper:splitMapData(str)
end

-- 从房间id数据中得到房间id数组
function TotalMapUI:getRoomIdArray(roomIdData)
	return Helper:getRoomIdArray(roomIdData)
end

-- 创建Label
function TotalMapUI:createLabel(str)
	local text = cc.Label:createWithTTF(str, Resource:getFontPath("default"), 36)
	local textSize = text:getContentSize()
	text:enableOutline(cc.c4b(0, 0, 0, 1), 5)
	return text, textSize
end

return TotalMapUI
0000000000