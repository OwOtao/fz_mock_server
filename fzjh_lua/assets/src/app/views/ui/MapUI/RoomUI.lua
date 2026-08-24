
local Resource = require("app.Resource")

local RoomUI = {}

local buttonDirections = 
{
	"center",
	"left",
	"leftUp",
	"up",
	"rightUp",
	"right",
	"rightDown",
	"down",
	"leftDown"
}

-- -- add by XiaoZhiWei 2018/06/04 12:29:36 相对方向
-- --[[
-- 	中间	-	中间
-- 	左		-	右
-- 	左上	-	右下
-- 	上		-	下
-- 	右上	-	左下
-- 	右 		- 	左
-- 	右下	-	左上
-- 	下		- 	上
-- 	左下	-	右上
-- ]]
-- local buttonRelativeDirection = {
-- 	center = "center",
-- 	left = "right",
-- 	leftUp = "rightDown",
-- 	up = "down",
-- 	rightUp = "leftDown",
-- 	right = "left",
-- 	rightDown = "leftUp",
-- 	down = "up",
-- 	leftDown = "rightUp",
-- }

function RoomUI:create()
	local p = Resource:getUIByName("Panel_mapUI")
	Helper:tableCover(p, RoomUI)
	p:init()
	return p
end

function RoomUI:init()
	Helper:convertUI(self)
	self:setPosition(0, 0)
	
	-- add by XiaoZhiWei 2017/06/30 13:26:14 add with ios 1.0
	self:setSelfAndChildrenCascadeColorEnabled(false)
end

local LightColor = cc.c3b(51, 204, 204)
local darkColor = cc.c3b(72, 72, 72)
local normalColor = cc.c3b(255, 255, 255)

function RoomUI:setRoom(data, callback)
	local link = data.link
	assert(link, "roomId = "..tostring(data.id))
	for i, direction in ipairs(buttonDirections) do
		local linkRoomId = link[direction]
		local roomButton = self:getRoomButton(direction)
		local line = self:getLine(direction)
		if roomButton then
			roomButton:setVisible(true)
		end
		if line then
			line:setVisible(true)
		end
		if direction == "center" then
			roomButton:setColor(LightColor)
			roomButton.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
			roomButton.Text_name:setColor(LightColor)
            if DEBUG_MODE == 1 then
                roomButton.Text_name:setString(data.name .. "\n" .. data.id)
            else
                roomButton.Text_name:setString(data.name)
            end
		elseif linkRoomId and linkRoomId ~= "" then
			local roomData = assert(self.mapLayer:getRoom(linkRoomId), linkRoomId)			
			roomButton:setColor(darkColor)
			roomButton.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
			roomButton.Text_name:setColor(cc.WHITE)
	
			if DEBUG_MODE == 1 then
                roomButton.Text_name:setString(roomData.name .. "\n" .. roomData.id)
            else
                roomButton.Text_name:setString(roomData.name)
            end
            
			roomButton.Text_name:setVisible(true)
			roomButton.roomId = roomData.id
			roomButton.direction = direction
			if not data.mid and roomData.mid and roomData.mid==User:getRole():getHouseId() then 
				roomButton.Text_name:setColor(cc.c3b(219,57,57))
			end
			roomButton:pressFunc(
				function()		
					if callback then
						callback(data.id, roomButton.roomId, roomButton.direction)
					end
				end)

			line:setColor(LightColor)

			if roomData.permission == 2 and User:getRole():isMapCompleted(self.mapLayer._currMap.id) == false then
				roomButton:setVisible(false)
				line:setVisible(false)
			end
			if roomData.visible == false or tonumber(roomData.visible) == 0 then
				roomButton:setVisible(false)
				line:setVisible(false)
			end

			if (roomData.flag or roomData.flag1 )and roomData.mid then
				self:changeKuang(direction,"dpIsHouse")
			elseif (roomData.flag or roomData.flag1) and not roomData.mid then
				self:changeKuang(direction,"dpNoBing")
			end
			
			if roomData.roomType == "tsfangjian002" then
				self:changeKuang(direction,"dpNoBing")
			end
			
			--@desc 梦境上锁
			if roomData.roomKey == 1 then
				roomButton.Text_name:setVisible(false)
				self:changeKuang(direction,"lock")
			elseif roomData.roomKey == 2 then
				roomButton.Text_name:setVisible(false)
				self:changeKuang(direction,"unlock")
			end

		else
			local parent = roomButton:getParent()
			local kuojianBtn = parent["KuoJianButton_"..direction]
			if kuojianBtn ~= nil then
				kuojianBtn:setVisible(false)
			end
			
			roomButton:setVisible(false)			
			if line then
				line:setVisible(false)
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/04 11:29:53
-- @params 
-- @desc 
function RoomUI:setRoomForEnlarge(data, callback, KJcallback)
	local link = data.link
	local UserMap = require("app.models.map.UserMap")
	local enlargeRoomInfo = UserMap:getEnlargeRoomInfoByRoomId(data.id)

	for i, direction in ipairs(buttonDirections) do
		local linkRoomId = link[direction]
		local roomButton = self:getRoomButton(direction)
		local line = self:getLine(direction)
		if roomButton then
			roomButton:setVisible(true)
		end
		if line then
			line:setVisible(true)
		end

		if direction == "center" then
			roomButton:setColor(LightColor)
			roomButton.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
			roomButton.Text_name:setColor(LightColor)
			if DEBUG_MODE == 1 then
                roomButton.Text_name:setString(data.name .. "\n" .. data.id)
            else
                roomButton.Text_name:setString(data.name)
            end
		elseif linkRoomId then		
			local roomData = assert(self.mapLayer:getRoom(linkRoomId), linkRoomId)			
			roomButton:setColor(darkColor)
			roomButton.Text_name:enableOutline(cc.c4b(0, 0, 0, 255), 5)
			roomButton.Text_name:setColor(cc.WHITE)
			if DEBUG_MODE == 1 then
                roomButton.Text_name:setString(roomData.name .. "\n" .. roomData.id)
            else
                roomButton.Text_name:setString(roomData.name)
            end
			roomButton.roomId = roomData.id
			roomButton.direction = direction

			roomButton:releaseFunc(
				function()		
					if callback then
						callback(data.id, roomButton.roomId, roomButton.direction)
					end
				end)

			line:setColor(LightColor)

			if tonumber(roomData.permission) == 2 and User:getRole():isMapCompleted(self.mapLayer._currMap.id) == false then
				roomButton:setVisible(false)
				line:setVisible(false)
			end
			if roomData.visible == false or tonumber(roomData.visible) == 0 then
				roomButton:setVisible(false)
				line:setVisible(false)
			end
		elseif enlargeRoomInfo[direction] ~= nil then
			-- add by XiaoZhiWei 2018/06/05 16:31:51 有扩建记录
			self:changeKuang(direction, "xuxian")
			self:changeLine(direction, "xuxian")
			self:changeXuXianName(direction, enlargeRoomInfo[direction])
			self:setXuXianButtonFunc(direction, 
				function(direction, relativeDirection, rtype)
					self.mapLayer:setEnlargeButton(direction, relativeDirection, rtype)
				end)
		else	
			local parent = roomButton:getParent()
			local kuojianBtn = parent["KuoJianButton_"..direction]
			if kuojianBtn == nil then
				kuojianBtn = self:getKuoJianButton()
				parent["KuoJianButton_"..direction] = kuojianBtn
				parent:addChild(kuojianBtn)
			end

			roomButton:setVisible(false)
			kuojianBtn:setVisible(true)
			kuojianBtn:setPosition(roomButton:getPosition())
			kuojianBtn.direction = direction
			-- kuojianBtn.relattiveDirection = buttonRelativeDirection[direction]

			kuojianBtn:releaseFunc(
			function()	
				-- add by XiaoZhiWei 2018/06/04 11:34:04 扩建相关的动作
				if KJcallback then
					KJcallback(direction)
				end
			end)

			if line then
				line:setVisible(false)
			end
		end
	end
end


function RoomUI:getRoomButton(direction)
	local button = assert(self["Button_"..direction], "direction = "..direction)
	Helper:convertUI(button)
	return button
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 12:35:42
-- @params 
-- @desc 初始化地图线条以及框
function RoomUI:initRoom()
	for i, direction in ipairs(buttonDirections) do
		self:changeKuang(direction)
		self:changeLine(direction)
	end
end

local lan = cc.c3b(80, 246, 244) -- add by XiaoZhiWei 2018/06/05 12:10:09 蓝色
local hui = cc.c3b(159, 159, 159) -- add by XiaoZhiWei 2018/06/05 12:10:21 灰色

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 12:52:31
-- @params 
-- @desc 获取扩建按钮
function RoomUI:getKuoJianButton()
	local button = Resource:getUIByName("Panel_kuojian")
	Helper:convertUI(button)
	button.Text_name:enableOutline(cc.c4b(17, 18, 18, 255), 5)
	return button
end

local lastDirection = nil
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 14:53:09
-- @params 
-- @desc 虚线框换名
function RoomUI:changeXuXianName(direction, name)
	name = Helper:getDef(name, "")
	local roomButton = self:getRoomButton(direction)
	roomButton.Text_name:setString(name)
	roomButton.rtype = name
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 15:47:37
-- @params 
-- @desc 设置虚线框点击方法
function RoomUI:setXuXianButtonFunc(direction, func)
	local roomButton = self:getRoomButton(direction)
	roomButton:releaseFunc(function()
		if func then
			func(direction, roomButton.rtype)
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 12:43:00
-- @params 
-- @desc 替换框的图片
function RoomUI:changeKuang(direction, ltype, color)
	local roomButton = self:getRoomButton(direction)
	roomButton:setVisible(true)
	if roomButton:getParent()["KuoJianButton_"..direction] ~= nil then
		roomButton:getParent()["KuoJianButton_"..direction]:setVisible(false)
	end
	switch(ltype, {
		shixian = function()
			roomButton:loadTextureNormal("Image/UI/MapUI/dituanniu.png", 0)
			roomButton:loadTexturePressed("Image/UI/MapUI/dituanniu.png", 0)
			roomButton:loadTextureDisabled("Image/UI/MapUI/dituanniu.png", 0)
			roomButton:setColor(darkColor)
		end,
		xuxian = function()
			roomButton:loadTextureNormal("Image/UI/MapUI/xuxian_dituanniu.png", 0)
			roomButton:loadTexturePressed("Image/UI/MapUI/xuxian_dituanniu.png", 0)
			roomButton:loadTextureDisabled("Image/UI/MapUI/xuxian_dituanniu.png", 0)
			roomButton:setColor(lan)
		end,
		kuojian = function()
			roomButton:setVisible(false)
			if roomButton:getParent()["KuoJianButton_"..direction] ~= nil then
				roomButton:getParent()["KuoJianButton_"..direction]:setVisible(true)
			end
		end,
		dpNoBing = function ()
			roomButton:setColor(cc.c3b(175, 145, 25))
		end,
		dpIsHouse = function ()
			roomButton:setColor(cc.c3b(246, 244, 80))
		end,
		lock = function ()
			roomButton:loadTextureNormal("Image/UI/DreamUI/roomLock.png", 0)
			roomButton:setColor(normalColor)
		end,
		unlock = function ()
			roomButton:loadTextureNormal("Image/UI/DreamUI/roomOpen.png", 0)
			roomButton:setColor(normalColor)
		end,
		default = function()
			roomButton:loadTextureNormal("Image/UI/MapUI/dituanniu.png", 0)
			roomButton:loadTexturePressed("Image/UI/MapUI/dituanniu.png", 0)
			roomButton:loadTextureDisabled("Image/UI/MapUI/dituanniu.png", 0)
			roomButton:setColor(darkColor)
		end
	})

	-- add by XiaoZhiWei 2018/06/05 13:16:54 恢复上次变化的框的颜色
	-- if lastDirection ~= direction and lastDirection ~= nil then
	-- 	self:changeKuang(lastDirection, "kuojian")
	-- 	self:changeLine(lastDirection, "kuojian")
	-- end
	-- lastDirection = direction
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2018/06/05 11:11:30
-- @params  direction, ltype, color : 方向, 线条类型 (实线, 虚线), 颜色
-- @desc 替换线的图片
function RoomUI:changeLine(direction, ltype, color)
	if ltype == nil then
		ltype = "shixian"
	end
	local xianMap = {
		left = "line02.png",
		right = "line02.png",
		up = "line01.png",
		down = "line01.png",
		leftUp = "line03.png",
		rightUp = "line03.png",
		rightDown = "line03.png",
		leftDown = "line03.png",
	}

	if xianMap[direction] == nil then
		return
	end

	local line = self:getLine(direction)
	line:setVisible(true)
	switch(ltype, {
		shixian = function()
			line:loadTexture("Image/UI/MapUI/"..xianMap[direction], 0)
			line:setColor(darkColor)
		end,
		xuxian = function()
			line:loadTexture("Image/UI/MapUI/xuxian_"..xianMap[direction], 0)
			line:setColor(lan)
		end,
		kuojian = function()
			line:setVisible(false)
		end,
		default = function()
			line:loadTexture("Image/UI/MapUI/"..xianMap[direction], 0)
			line:setColor(darkColor)
		end
	})

	if color ~= nil then
		line:setColor(color)
	end
end

function RoomUI:getLine(direction)
	return self["Image_"..direction]
end

local animDuration = 2
function RoomUI:fadeIn(offset, duration, callback)
	self:setCascadeOpacityEnabled(true)
	self:callAllChild(
		function(child)
			child:setCascadeOpacityEnabled(true)
		end)
	self:setOpacity(0)
	self:runAction(
		cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveBy:create(duration, cc.p(-offset.x, -offset.y)),
				cc.FadeIn:create(duration)
				),
			cc.CallFunc:create(
				function()
					callback(self)
				end
				)
			))
end

function RoomUI:fadeOut(offset, duration, callback)
	self:setCascadeOpacityEnabled(true)
	self:callAllChild(
		function(child)
			child:setCascadeOpacityEnabled(true)
		end)
	self:runAction(
		cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveBy:create(duration, cc.p(-offset.x, -offset.y)),
				cc.FadeOut:create(duration)
				),
			cc.CallFunc:create(
				function()
					callback(self)
				end
				)
			))
end


return RoomUI0000000000