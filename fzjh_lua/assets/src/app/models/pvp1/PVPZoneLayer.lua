local PVPZoneLayer = class("PVPZoneLayer", cc.Layer)


function PVPZoneLayer:create(zid, name, bottom)
    local p = PVPZoneLayer:new()
    p.buttonLayer = nil
    p.bottom = bottom
    p.zid = zid
    p.name = name
    p._players = {}
    p:addNodeEvent("enter", 
    	function(...)
    		print("enter")
    		print(...)
		    p._client = require("app.models.pvp1.PVPClient")
    		p._client:connect(User:getUserId() .. "", User:getUserId() .. "")
    	end)
    p:init()
    return p
end

function PVPZoneLayer:addButton(text, position, downProcessFunc)
	local button = ccui.Button:create()
	button:setTitleText(text)
	position.x = position.x + 100
	position.y = position.y + 100
	button:setPosition(position)
	button:setTitleColor(cc.c3b(0, 0, 0))
	button:addClickEventListener(downProcessFunc)
	button:addTo(self.buttonLayer)
	button:setTitleFontSize(60)
end

function PVPZoneLayer:addPlayerItem(k, v, downProcessFunc)
	local button = ccui.Button:create()
	button:setTitleText(v.id .. ":" .. v.name .. ":" .. v.sex .. ":" .. v.age .. ":" .. v.looks)
	local position = {}
	position.x = 500
	position.y = 1800 - k * 100
	button:setPosition(position)
	button:setTitleColor(cc.c3b(0, 0, 0))
	button:addClickEventListener(downProcessFunc)
	button:addTo(self.playerLayer)
	button:setTitleFontSize(42)
end

function PVPZoneLayer:showPlayers()
	self.playerLayer = display.newLayer()
	self.playerLayer:addTo(self)
	for k,v in pairs(self._players) do
		self:addPlayerItem(k, v, function () 
			-- 查看信息
			-- TODO
			PopText("查看" .. v.name .. "的信息")
		end)
	end
end

function PVPZoneLayer:init()
    display.newSprite("/res/bk.jpg")
        :move(display.center)
        :addTo(self)

    -- 建立连接
    self._client = require("app.models.pvp1.PVPClient")
    local uid = User:getUserId() .. ""
    local tb = {
    	userid = uid,
		uuid = Game:getIdfv(),
		platform  = Game:getPlatformId(),
		channel = Game:getChannelId()
	}
	local json = json.encode(tb)
	local data = JMForLua:encrypt(json)
    self._client:connect(uid, data)

	self.buttonLayer = display.newLayer()
	self.buttonLayer:addTo(self)

	local button = ccui.Button:create()
	button:setTitleText(self.zid .. ":" .. self.name)
	local position = {}
	position.x = 500
	position.y = 1800
	button:setPosition(position)
	button:setTitleColor(cc.c3b(0, 0, 0))
	button:addClickEventListener(function () end)
	button:addTo(self.buttonLayer)
	button:setTitleFontSize(60)
	self.button = button
    -- 设置会调
    self._client:setOtherCallback(function (eventName, ...)
    	print("eventName = " .. eventName)
		if eventName == "exitZone" then
			local typ, zoneId = ...
			if typ == "result" then
				PopText("离开" .. zoneId .. "区成功")
			elseif typ == "error" then
				PopText("离开" .. zoneId .. "区失败")
			end
		elseif eventName == "zoneInfo" then
			local typ, tb = ...
			if typ == "result" then
				self.info = tb
				self.button:setTitleText(tb.zid .. ":" .. tb.name .. ":" .. tb.count .. "人")
				self._client:getPlayers(self.zid, 0, tb.count)
			elseif typ == "error" then
				PopText("得到区信息失败")
			end
		elseif eventName == "zonePlayerList" then
			local typ, tb = ...
			if typ == "result" then
				-- TODO 添加到数据后面
				self._players = tb.data
				self:showPlayers()
			end
		elseif eventName == "connectSuccess" then
			self._client:getZones()
			local role = getRoleData(uid)
			self._client:sendLocalRole(role.name, role)
		elseif eventName == "connectError" then
			PopText("连接出错")
		elseif eventName == "disconnect" then
			PopText("断开连接")
		end
	end)
    self._client:getZoneInfo(self.zid)

	print("display width = " .. display.width)

	local editBox = ccui.EditBox:create({width = display.width, height = 42}, "/res/it.png")   
	editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD) 
	editBox:setPosition(cc.p(display.width / 2, 50))
	editBox:setFontSize(42)
	editBox:setText("")
	editBox:setFontColor(cc.c3b(0, 0, 0))
	editBox:addTo(self.buttonLayer)

	-- 
	self:addButton("创建房间", cc.p(50, 150), function()
		-- body
		print("创建房间")
		local PVPRoom = require("app.models.pvp1.PVPRoom")
		local room = PVPRoom:new(function (eventName, r)
			if eventName == "创建房间成功" then
				local PVPRoomLayer = require("app.models.pvp1.PVPRoomLayer")
				local roomLayer = PVPRoomLayer:create(r)
				roomLayer:addTo(self)
				roomLayer:show()
			elseif eventName == "创建房间失败" then

			elseif eventName == "加入房间成功" then

			end
		end)
		room:create(editBox:getText())
	end)

	-- 
	self:addButton("加入房间", cc.p(400, 150), function()
		-- body
		print("加入房间")
		local PVPRoom = require("app.models.pvp1.PVPRoom")
		local room = PVPRoom:new(function (eventName, r)
			if eventName == "创建房间成功" then

			elseif eventName == "创建房间失败" then
				
			elseif eventName == "加入房间成功" then
				local PVPRoomLayer = require("app.models.pvp1.PVPRoomLayer")
				local roomLayer = PVPRoomLayer:create(r)
				roomLayer:addTo(self)
				roomLayer:show()
			end
		end)
		room:enter(editBox:getText())
	end)

	-- 
	self:addButton("离开页面", cc.p(800, 150), function()
		-- body
		print("离开页面")
			self:hide()
			self.bottom:onResume()
	end)
end

return PVPZoneLayer
0