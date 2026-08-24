local PVPDebugLayer = class("PVPDebugLayer", cc.Layer)

local zoneLayerTag = 9527

function PVPDebugLayer:create()
    local p = PVPDebugLayer:new()
    p.buttonLayer = nil
    p.Callbacks  = nil
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

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得随机的角色数据
local function getRoleData(dataId)
    local role = User:getRole()
    local cloneRole = {}

    cloneRole.id = dataId .. ""
	---------------------
	cloneRole.name = role.name
	--神兵列表，记录自己所有的神兵
	-- cloneRole.shenBingweapon = role.shenBingweapon

	--cloneRole.shuxiang = role.shuxiang
	cloneRole.sex = role.sex
	cloneRole.age = role.age
	cloneRole.looks = role.looks
	cloneRole.luck = role.luck
	cloneRole.tili = role.tili
	cloneRole.tiliMax = role.tiliMax
	cloneRole.str = role.str
	cloneRole.int = role.int
	cloneRole.con = role.con
	cloneRole.dex = role.dex

	cloneRole.secStr = role.secStr
	cloneRole.secInt = role.secInt
	cloneRole.secCon = role.secCon
	cloneRole.secDex = role.secDex
	cloneRole.currStr = role.currStr
	cloneRole.currInt = role.currInt
	cloneRole.currCon = role.currCon
	cloneRole.currDex = role.currDex
	cloneRole.fenpei = role.fenpei
	cloneRole.fenpeiList = role.fenpeiList

	cloneRole.jing = role.jing
	cloneRole.jingMax = role.jingMax
	cloneRole.qi = role.qi
	cloneRole.qiMax =  role.qiMax
	cloneRole.neili = role.neili
	cloneRole.neiliMax = role.neiliMax
	cloneRole.exp = role.exp
	cloneRole.pot = role.pot
	cloneRole.money = role.money
	cloneRole.gold = role.gold
	cloneRole.lv = role.lv
	cloneRole.yuanbao = role.yuanbao
	cloneRole.totalYuanBao = role.totalYuanBao
	cloneRole.weight = role.weight

	cloneRole.ckLimit = role.ckLimit
	cloneRole.zhengqi = role.zhengqi	
	cloneRole.kill = role.kill
	cloneRole.yueli = role.yueli
	cloneRole.killPlayer = role.killPlayer
	cloneRole.weiwang = role.weiwang
	cloneRole.dead = role.dead
	cloneRole.meili = role.meili
	cloneRole.deadReason = role.deadReason
	cloneRole.jindu = role.jindu
	cloneRole.lunhui = role.lunhui
	cloneRole.mengjing = role.mengjing
	cloneRole.panshi = role.panshi
	cloneRole.guanqiaLimit = role.guanqiaLimit
	cloneRole.species = role.species
	cloneRole.dsc = role.dsc
	
	cloneRole.atkRate = role.atkRate
	cloneRole.kongfu = role.kongfu
	cloneRole.title_type = role.title_type
	cloneRole.inherit = role.inherit
	cloneRole.jiaLi = role.jiaLi

	cloneRole.tempAttrList = role.tempAttrList  -------

	cloneRole.family = role.family
	cloneRole.teacherName = role.teacherName

	cloneRole.teacherId = role.teacherId
	cloneRole.skills = role.skills  -- 角色的所有技能
	cloneRole.skillPrepare = role.skillPrepare -- 角色当前准备的技能列表
	cloneRole.activeZhaos = role.activeZhaos -- 角色学会的所有主动招式
	cloneRole.preparedActiveZhao = role.preparedActiveZhao -- 角色准备的主动招式（有兵器和拳脚之分）
	cloneRole.preparedZhaos =  {
				"chuixiongkou10",
                "tiandirenmo10",
                "xiyanling10",
                "zixiahuti10",
                "yuntaiji10",
                "qianhunluoyi10",
	}
	cloneRole.preparedZhaos = role.preparedZhaos -- 暂时没用到
	--cloneRole.items = role.items
	cloneRole.equips = role.equips
	cloneRole.portrait = role.portrait

    return cloneRole
end

function PVPDebugLayer:onResume()
	self:removeChildByTag(zoneLayerTag, true)
	self._client:setOtherCallback(self.Callbacks)
end

function PVPDebugLayer:onEnter()
	print(" PVPDebugLayer:onEnter  PVPDebugLayer:onEnter  PVPDebugLayer:onEnter")
	self._client:reconnect()
end

function PVPDebugLayer:showLayer()
	self:show()
	self:onEnter()
end

function PVPDebugLayer:addButton(text, position, downProcessFunc)
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

function PVPDebugLayer:addButton1(text, position, downProcessFunc)
	local button = ccui.Button:create()
	button:setTitleText(text)
	position.x = position.x + 100
	position.y = position.y + 1000
	button:setPosition(position)
	button:setTitleColor(cc.c3b(0, 0, 0))
	button:addClickEventListener(downProcessFunc)
	button:addTo(self.zoneListLayer)
	button:setTitleFontSize(60)
end

function PVPDebugLayer:init()
	local debugLayer = self
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
	-- 设置会调
	self.Callbacks = function (eventName, ...) 
		print("eventName = " .. eventName)
		if eventName == "enterZone" then
			local typ, zoneId = ...
			if typ == "result" then
				PopText("进入" .. zoneId .. "区成功")

				-- 这里表示成功加入区
				local PVPZoneLayer = require("app.models.pvp1.PVPZoneLayer")
				local tb = self._zoneList[zoneId]
				print("username = " .. tb.username)
				print("name = " .. tb.name)
				local zoneLayer = PVPZoneLayer:create(tb.username, tb.name, self)
				zoneLayer:addTo(self, 1, zoneLayerTag)
				zoneLayer:show()
			elseif typ == "error" then
				PopText("进入" .. zoneId .. "区失败")
			end
		elseif eventName == "exitZone" then
			local typ, zoneId = ...
			if typ == "result" then
			PopText("离开" .. zoneId .. "区成功")
			elseif typ == "error" then
				PopText("离开" .. zoneId .. "区失败")
			end
		elseif eventName == "zoneList" then
			local typ, tb = ...
			if typ == "result" then
				print("zone size : " .. tb.size)
				self._zoneList = {}
				self.zoneListLayer:removeAllChildren()
				for k,v in pairs(tb.data) do
					print(tostring(k) .. " = " .. tostring(v))
					self._zoneList[v.username] = v
					-- 这里得到所有区消息
					self:addButton1(v.name .. k .. "区:" .. v.username, cc.p(400, -150 * k), function()
						-- body
						print("进入区" .. v.name)
						self._client:enterZone(v.username)
					end)

				end
			elseif typ == "error" then
				PopText("得到区信息失败")
			end
		elseif eventName == "connectSuccess" then
			self._client:getZones()
			local role = getRoleData(uid)
			self._client:sendLocalRole(role.name, role)
		elseif eventName == "connectError" then
		elseif eventName == "disconnect" then
		end
	end

	self._client:setOtherCallback(self.Callbacks)
    self._client:connect(uid, data)
    

    display.newSprite("/res/bk.jpg")
        :move(display.center)
        :addTo(self)

	print("display width = " .. display.width)

	self.buttonLayer = display.newLayer()
	self.buttonLayer:addTo(self)	
	self.zoneListLayer = display.newLayer()
	self.zoneListLayer:addTo(self)
	local editBox = ccui.EditBox:create({width = display.width, height = 42}, "/res/it.png")   
	editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD) 
	editBox:setPosition(cc.p(display.width / 2, 50))
	editBox:setFontSize(42)
	editBox:setText("")
	editBox:setFontColor(cc.c3b(0, 0, 0))
	editBox:addTo(self.buttonLayer)

	-- 
	self:addButton("离开页面", cc.p(800, 150), function()
		-- body
		print("离开页面")
			self:hide()
	end)
end

return PVPDebugLayer
00000000000000