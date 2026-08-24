-- 下毒玩法
local PoisonPlayLayer = class("PoisonPlayLayer", LayerEx)

function PoisonPlayLayer:create()
	local p = PoisonPlayLayer:new()
	p:init()
	return p
end

function PoisonPlayLayer:init()
	self._UI = require("Layer/PoisonPlayUI/PoisonPlayUI.lua").create()['root']
	self._UI:addTo(self)
	Helper:convertUIByParent(self)

    self.map = nil
    self.environment = nil
    self.finalResult = nil --最终下毒结果
    self.succResult = nil --下毒成功结果
    self.failedResult = nil --下毒失败结果
    self.timeoutResult = nil --下毒超时结果
    self.animDuration = nil --动画时间

    self.sucfulRegional_X = nil --成功区域的横坐标（区域总长100.4，所以横坐标左右50.2的范围属于成功区域）

    self:setPoisonButton()
end

function PoisonPlayLayer:hideLayer()
    PopupLayerController:hideLayer("PoisonPlayLayer", function(layer)
        layer:hide()
    end)
end

function PoisonPlayLayer:showLayer(map,environment,succResult,failedResult,timeoutResult,animDuration)
    self.map = map
    self.environment = environment
    self.succResult = succResult
    self.failedResult = failedResult
    self.timeoutResult = timeoutResult
    self.animDuration = animDuration

    self.Button_5:setEnabled(true)

    -- 开始时间
	self.startTime = GetTime()

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:updateTime()
	end,0.1)

    self:randomSuccessfulRegional()

    self:moveBlock()

    self:show()	
end

function PoisonPlayLayer:updateTime()
    local currTime = GetTime()
	local num = 0

	num = math.floor(30 - (currTime - self.startTime))

	if num <= 0 then
		num = 0
		if self._handle ~= nil then
			self:unschedule(self._handle)
			self._handle = nil
		end

        --提交下毒结果，关闭界面
        self:stopMoveBlock()
        self.finalResult = self.timeoutResult --超时
        self:submitResults()

        self:delayFunc(0.5, function()
            self:hideLayer()
        end)
        return
	end

    local sec = Helper:numberCast(num)
	self.Text_time:setString("掷毒时机剩余："..sec.."息")
end

--随机成功区域
function PoisonPlayLayer:randomSuccessfulRegional()
    local panel = self.Panel_bar
    local Image_3_x = (math.random( 1,10)-1)*100 + 50.2

    self.sucfulRegional_X = Image_3_x
    panel.Image_3:setPositionX(Image_3_x)
    panel.Text_distraction:setPositionX(Image_3_x) 
end

-- 移动方块
function PoisonPlayLayer:moveBlock()
    local panel = self.Panel_bar
    panel.Panel_track:setPositionX(20)

    local bar_w = panel:getSize().width
	local track_w = panel.Panel_track:getSize().width

    print("bar_w = ",bar_w)
    print("track_w = ",track_w)

	local x1 = bar_w - (track_w / 2)
	local x2 = (track_w / 2)

	panel.Panel_track:stopAllActions()

	local animDuration = Helper:getDef(self.animDuration,3)
	local action = cc.Sequence:create(
		cc.MoveTo:create(0, cc.p(x2, panel.Panel_track:getPositionY())),
		cc.MoveTo:create(animDuration, cc.p(x1, panel.Panel_track:getPositionY())),
        cc.MoveTo:create(animDuration, cc.p(x2, panel.Panel_track:getPositionY()))
	)
	panel.Panel_track:runAction(cc.RepeatForever:create(action))
end

-- 停止移动方块
function PoisonPlayLayer:stopMoveBlock()
	local panel = self.Panel_bar

	panel.Panel_track:stopAllActions()

	--判断是否在成功区域
    local minSucfulRegional_X = self.sucfulRegional_X - 50.2
    local maxSucfulRegional_X = self.sucfulRegional_X + 50.2

	local track_x = panel.Panel_track:getPositionX()

    if track_x >= minSucfulRegional_X and track_x <= maxSucfulRegional_X then
        --停在成功区域
        self.finalResult = self.succResult
    else
        self.finalResult = self.failedResult
    end
end

function PoisonPlayLayer:setPoisonButton()
    self.Button_5:releaseFunc(function()
        --提交下毒结果，关闭界面
        self:stopMoveBlock()

        self:submitResults()

        self:delayFunc(0.5, function()
            self:hideLayer()
        end)
    end)
end

--提交下毒结果
function PoisonPlayLayer:submitResults()
    self.Button_5:setEnabled(false)

    local currRole = self.environment.currRole
    local operations = nil
    if currRole ~= nil then
        operations = currRole.operations
    end

    if MapIsEmpty(operations) then
        operations = self.environment.currRoom.operations
    end

    if operations == nil then
        return
    end

    self.map:doOperationById(self.finalResult,operations, self.environment)
end

Helper:classDefNodeGetInstance(PoisonPlayLayer)

return PoisonPlayLayer000000000000