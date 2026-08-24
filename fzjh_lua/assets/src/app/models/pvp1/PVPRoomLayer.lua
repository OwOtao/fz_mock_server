local PVPRoomLayer = class("PVPRoomLayer", cc.Layer)

local buttonLayer = nil

local callbacks = {}

local titleText = nil
local leftText  = nil
local rightText = nil

function PVPRoomLayer:create(room)
    local p = PVPRoomLayer:new()
    p.buttonLayer = nil
    p.room = room
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 获得随机的角色数据
local function getRandomRoleData(name, dataId)
    assert(type(name) == "string")
    qi = math.random(30000000, 50000000)
    neili = math.random(1000000, 20000000)
    local roleData =
    {
        id = dataId,
        name = name,
        atk = 300,
        qi = qi / 2,
        qiMax = qi,
        neili = neili,
        neiliMax = neili,
        	--先天属性
		str = 10,   -- 臂力
		int = 10,   -- 悟性
		con = 10,   -- 根骨
		dex = 10,   -- 身法
		--后天属性
		secStr = math.random(5, 25),	-- 臂力
		secInt = math.random(5, 25),	-- 悟性
		secCon = math.random(5, 25),	-- 根骨
		secDex = math.random(5, 25)		-- 身法
    }

	roleData.preparedZhaos =
            {
                --"chuixiongkou10",
                "tiandirenmo10",
                "zixiahuti10",
                "yuntaiji10",
                "qianhunluoyi10",
            }

    return roleData
end

function PVPRoomLayer:addButton(text, position, downProcessFunc)
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

function PVPRoomLayer:init()
	-- self.room:setCallback(function (eventName)
	-- 	if eventName == "游戏开始" then
	-- 	else if eventName == "游戏暂停" then

	-- end)

    -- add background image
    display.newSprite("/res/bk.jpg")
        :move(display.center)
        :addTo(self)

	print("display width = " .. display.width)

	self.buttonLayer = display.newLayer()
	self.buttonLayer:addTo(self)	
	local editBox = ccui.EditBox:create({width = display.width, height = 42}, "/res/it.png")    
	editBox:setInputFlag(cc.EDITBOX_INPUT_FLAG_INITIAL_CAPS_WORD)
	editBox:setPosition(cc.p(display.width / 2, 50))
	editBox:setFontSize(42)
	editBox:setText("")
	editBox:setFontColor(cc.c3b(0, 0, 0))
	editBox:addTo(self.buttonLayer)

	-- 得到角色数据
	-- local Npc = require("app.models.npc.Npc")
 --    local Map = require("app.models.map.Map")
    
    -- -- 得到一个角色
    -- local info = getRandomRoleData(User:getUserId() .. "", User:getUserId() .. "")
    -- self.room:setLocalRole(info)

	-- 
	self:addButton("准备", cc.p(50, 150), function()
		-- body
		print("准备")
		self.room:ready()
	end)

	-- 
	self:addButton("取消准备", cc.p(400, 150), function()
		-- body
		print("取消准备")
		self.room:unready()
	end)

	-- 
	self:addButton("离开房间", cc.p(800, 150), function()
		-- body
		print("离开房间")
		self.room:exit()
		self:hide()
	end)

	-- 
	self:addButton("开始游戏", cc.p(50, 300), function()
		-- body
		print("开始游戏")
		self.room:startGame()
	end)
	-- 
	self:addButton("停止游戏", cc.p(400, 300), function()
		-- body
		print("停止游戏")
		self.room:stop()
	end)

	self:addButton("发送消息", cc.p(800, 300), function()
		-- body
		print("发送消息")
		self.room:sendMessage(editBox:getText())
	end)

	--Create titleText
	local titleText = ccui.Text:create()
	titleText:ignoreContentAdaptWithSize(true)
	titleText:setTextAreaSize({width = 0, height = 0})
	titleText:setFontName("Font/default.ttf")
	titleText:setFontSize(60)
	titleText:setTextColor(cc.c3b(0, 0, 0))
	titleText:setString(self.room.name .. ":" .. self.room.rid)
	titleText:setLayoutComponentEnabled(true)
	titleText:setName("titleText")
	titleText:setTag(46)
	titleText:setCascadeColorEnabled(true)
	titleText:setCascadeOpacityEnabled(true)
	titleText:setPosition(540.0000, 1800.0000)
	layout = ccui.LayoutComponent:bindLayoutComponent(titleText)
	layout:setPositionPercentX(0.5000)
	layout:setPositionPercentY(0.9375)
	layout:setPercentWidth(0.2222)
	layout:setPercentHeight(0.0349)
	layout:setSize({width = 240.0000, height = 67.0000})
	layout:setLeftMargin(420.0000)
	layout:setRightMargin(420.0000)
	layout:setTopMargin(86.5000)
	layout:setBottomMargin(1766.5000)
	self:addChild(titleText)

end

return PVPRoomLayer
00000000000