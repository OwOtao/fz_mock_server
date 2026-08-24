local Connection = require("app.views.Connection")  
local Fight = require("app.models.fight.Fight")

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 战斗层
local FightTestLayer = class("FightTestLayer", LayerEx)

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建实例
function FightTestLayer:create()
    local p = FightTestLayer.new()
    p:init()
    return p
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 构造
function FightTestLayer:ctor()
    self._isConnected = false

    self._accounts =
    {
        {
            name = "123123",
            password = "123123"
        },
        {
            name = "321321",
            password = "321321"
        }
    }

    self._account = self._accounts[1]
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化
function FightTestLayer:init()
    self._UI = require("Layer/FightUI/FightTest.lua").create()['root']
    self._UI:addTo(self)

    Helper:convertUI(self)

    self:initUI()
    self:refreshUI()
end

function FightTestLayer:isConnected()
    return self._isConnected
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 初始化UI
function FightTestLayer:initUI()
    -- 编辑框
	do
		  -- 初始化变量
		self._editBoxString = ""

		-- 初始化编辑框
		local editBox = ccui.EditBox:create(cc.size(1080, 50), "请输入")
		self.Button_connect:getParent():addChild(editBox)
		editBox:setPosition(self.Button_connect:getPositionX(), self.Button_connect:getPositionY() - 200)
		editBox:setText("请输入")
		editBox:setLocalZOrder(999)

		-- 设置输入类型
		editBox:setInputMode(1)
		editBox:setReturnType(1)
		editBox:setInputFlag(3)

		-- 是否正在编辑
		self._isEditing = false

		-- 注册事件监听
		editBox:onEditHandler(function(event)
			local eventName = event.name
			local eventTarget = event.target

			if PRINT_MODE == 1 then
				print("eventName = "..tostring(eventName))
				print("eventTarget = "..tostring(eventTarget))
			end

			if eventName == "began" then
				self._isEditing = true
			elseif eventName == "changed" then
				self._editBoxString = editBox:getText()
				if PRINT_MODE == 1 then
					print("self._editBoxString = "..tostring(self._editBoxString))
				end

			elseif eventName == "end" then

			elseif eventName == "return" then
					self._isEditing = false
			end
		end)

		self.editBox = editBox
	end


    -- 按钮
    -- 点击背景, 隐藏战斗测试层
    self.Panel_back:releaseFunc(function()
        self:hide()
    end)

    -- 切换帐号
    self.Button_switch:releaseFunc(function()
        if self._isConnected == false then
            self._account = switch(self._account,
            {
                [self._accounts[1]] = self._accounts[2],
                [self._accounts[2]] = self._accounts[1],
                default = function() error() end
            })
        else
            PopText("已经连接, 帐号:" .. self._account.name)
        end
        self:refreshUI()
    end)

    -- 连接服务器
    self.Button_connect:releaseFunc(function()
        if self._isConnected == false then
            self:initFight(self._account.name)

            self._isConnected = true
            Connection:connect(self._account.name, self._account.password)
            self.Button_connect:setTitleText("已经连接, 帐号:" .. self._account.name)
        else
            PopText("已经连接, 帐号:" .. self._account.name)
        end
        self:refreshUI()
    end)

    -- 创建房间
    self.Button_createRoom:releaseFunc(function()
        if self:isConnected() then
            self._fight:createRoom("testRoom")
        else
            PopText("请先连接服务器")
        end
    end)

    -- 加入房间
    self.Button_enterRoom:releaseFunc(function()
        if self._fight:getState() == FIGHT_STATE_NONE then
            self._editBoxString = "12345678"
            self._fight:enterRoom(self._editBoxString)
        else
            PopText("你已经加入房间")
        end
    end)

    -- 本地测试
    self.Button_localTest:releaseFunc(function()
        PopText("开始本地测试")
        Fight.test()
    end)

    -- 新版本, 本地测试
    self.Button_newLocalTest:releaseFunc(function()
        PopText("开始本地测试")
        local FightLayer = require("app.views.layer.FightLayer.FightLayer")
        FightLayer.test()
    end)

    -- 打印战况
    self.Button_printFightStatus:releaseFunc(function()
        self._fight:printInfo()
    end)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 创建战斗
function FightTestLayer:initFight(accountName)
    self._fight = Fight.createNetTestFight(accountName)
     local FightLayer = require("app.views.layer.FightLayer.FightLayer")
     FightLayer.testFight(self._fight)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @desc 刷新UI
function FightTestLayer:refreshUI()
    self.Button_switch:setTitleText("当前帐号:" .. self._account.name .. "(点击切换)")
end

Helper:classDefNodeGetInstance(FightTestLayer)
return FightTestLayer
000000