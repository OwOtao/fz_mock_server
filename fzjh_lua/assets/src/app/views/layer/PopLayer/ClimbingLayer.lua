-- 石壁
local ClimbingLayer = class("ClimbingLayer", LayerEx)

function ClimbingLayer:create()
	local p = ClimbingLayer:new()
	p:init()
	return p
end

function ClimbingLayer:init()
	self._UI = require("Layer/PopUI/ClimbingUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setShowAndHideAnimType("ROLL")

	self.scheduleHandle = nil
	self.totalTime = 0
	self.intervalTime = 0

	self.count = 0

	self.rightFunc = nil
	self.wrongFunc = nil

	-- 文本
	self.RichText_print = nil

	-- 正确方向 1上 2下 3左 4右
	self.rightDirection = 0

	self.textMap = {}
	self.richTextMap = {}

	self:initRichText()
	self:setBack()
	self:setButton()
end

-- 显示界面
function ClimbingLayer:showLayer(title, desc, time, count, textMap, rightFunc, wrongFunc)
	if self.scheduleHandle ~= nil then
		self:unschedule( self.scheduleHandle )
		self.scheduleHandle = nil
	end

	self.Button_up:setOpacity(0)
	self.Button_down:setOpacity(0)
	self.Button_left:setOpacity(0)
	self.Button_right:setOpacity(0)

	self.count = count

	self.intervalTime = time

	self.rightFunc = rightFunc
	self.wrongFunc = wrongFunc

	if self.rightFunc == nil then
		self.rightFunc = function()
		end
	end

	if self.wrongFunc == nil then
		self.wrongFunc = function()
		end
	end

	self.Text_title:setString(title)
	self.Text_desc:setString(desc)

	local strs = string.split(textMap, ",")

	self.textMap = string.split(strs[1], ";")
	self.richtextMap = string.split(strs[2], ";")

	self:hideUI()

	self:show()

	self:delayFunc(1, function()
		self:start()
	end)
end

function ClimbingLayer:setButtonName(str)
	if str == nil then
		return
	end
	local btnName = string.split(str, ";")

	self.Button_up.Text_Name:setString(btnName[1])
	self.Button_down.Text_Name:setString(btnName[2])
	self.Button_left.Text_Name:setString(btnName[3])
	self.Button_right.Text_Name:setString(btnName[4])
end

function ClimbingLayer:initRichText()
	if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Text_desc_1:getPosition()
    local size = self.Text_desc_1:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Text_desc_1:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
end

-- 开始
function ClimbingLayer:start()
	self:stopSchedule()

	self:showUI()

	-- 随机方向
	self.rightDirection = math.random(1, 4)
	self:initRichText()
	local textColor = cc.c3b(208, 208, 208)
    self.RichText_print:pushBackText(self.textMap[self.rightDirection], textColor, 255, Resource:getFontPath("default"), 42)
	--self.RichText_print:setString(self.textMap[self.rightDirection])

	-- 次数减1
	self.count = self.count - 1

	self:setTime()

	self:showButtonAim({self.Button_up, self.Button_down, self.Button_left, self.Button_right}, 0)

	self.scheduleHandle = self:schedule( function(ft)
		self:update(ft)
	end, 30/1000 )
end

-- 结束
function ClimbingLayer:finish()
	self:showButtonAim({self.Button_up, self.Button_down, self.Button_left, self.Button_right}, 1)
	self:stopSchedule()
	self:initRichText()
	self:hideUI()
end

-- 停止刷新进度条
function ClimbingLayer:stopSchedule()
	if self.scheduleHandle ~= nil then
		self:unschedule( self.scheduleHandle )
		self.scheduleHandle = nil
	end
end

-- 设置时间间隔
function ClimbingLayer:setTime()
	self.totalTime = self.intervalTime * 1000 / 30
	self.currTime = self.totalTime
end

function ClimbingLayer:setBack()
end

function ClimbingLayer:setButton()
	self.Button_up:releaseFunc(function()
		self:finish()
		if self.rightDirection == 1 then
			RichPrint("main", self.richtextMap[1])
			if self.count == 0 then
				self.rightFunc()
				PopupLayerController:hideLayer("ClimbingLayer", function(layer)
		    		self:hide()
		    	end)
				return
			end
			self:delayFunc(1, function()
				self:start()
			end)
		else
			self.wrongFunc()
			PopupLayerController:hideLayer("ClimbingLayer", function(layer)
	    		self:hide()
	    	end)
		end
	end)

	self.Button_down:releaseFunc(function()
		self:finish()
		if self.rightDirection == 2 then
			RichPrint("main", self.richtextMap[2])
			if self.count == 0 then
				self.rightFunc()
				PopupLayerController:hideLayer("ClimbingLayer", function(layer)
		    		self:hide()
		    	end)
				return
			end
			self:delayFunc(1, function()
				self:start()
			end)
		else
			self.wrongFunc()
			PopupLayerController:hideLayer("ClimbingLayer", function(layer)
	    		self:hide()
	    	end)
		end
	end)

	self.Button_left:releaseFunc(function()
		self:finish()
		if self.rightDirection == 3 then
			RichPrint("main", self.richtextMap[3])
			if self.count == 0 then
				self.rightFunc()
				PopupLayerController:hideLayer("ClimbingLayer", function(layer)
		    		self:hide()
		    	end)
				return
			end
			self:delayFunc(1, function()
				self:start()
			end)
		else
			self.wrongFunc()
			PopupLayerController:hideLayer("ClimbingLayer", function(layer)
	    		self:hide()
	    	end)
		end
	end)

	self.Button_right:releaseFunc(function()
		self:finish()
		if self.rightDirection == 4 then
			RichPrint("main", self.richtextMap[4])
			if self.count == 0 then
				self.rightFunc()
				PopupLayerController:hideLayer("ClimbingLayer", function(layer)
		    		self:hide()
		    	end)
				return
			end
			self:delayFunc(1, function()
				self:start()
			end)
		else
			self.wrongFunc()
			PopupLayerController:hideLayer("ClimbingLayer", function(layer)
	    		self:hide()
	    	end)
		end
	end)
end

-- 显示按钮动画
function ClimbingLayer:showButtonAim(btnList, isInOut)
	if MapIsEmpty(btnList) == true then
		return
	end

	local animDuration = 0.25
	local function buttonAnim(button, dir, isInOut)
		local offsetsXY = {{0, 200}, {0, - 200}, {-350, 0}, {350, 0}}
		button:setOpacity(isInOut * 255)

		if isInOut == 0 then
			button:setPosition(cc.p(540, 900))
			button:runAction(YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( button:getPositionX() + offsetsXY[dir][1], button:getPositionY() + offsetsXY[dir][2]) ) ,
				cc.FadeIn:create(animDuration)
			),  Sine_EaseOut ))
		else
			button:runAction(YXEaseAction:create( cc.Spawn:create(
				cc.MoveTo:create(animDuration, cc.p( button:getPositionX() - offsetsXY[dir][1], button:getPositionY() - offsetsXY[dir][2]) ) ,
				cc.FadeOut:create(animDuration)
			),  Sine_EaseOut ))
		end
	end

	local index = 1
	for k,v in pairs(btnList) do
		buttonAnim(v, index, isInOut)
		index = index + 1
	end
end

-- 屏蔽UI
function ClimbingLayer:hideUI()
	self.Text_desc_1:setVisible(false)
	self.LoadingBar:setVisible(false)
end

-- 显示UI
function ClimbingLayer:showUI()
	self.LoadingBar:setPercent(100)
	self.Text_desc_1:setVisible(true)
	self.LoadingBar:setVisible(true)
end

function ClimbingLayer:update(ft)
	self.currTime = self.currTime - 1

	self.LoadingBar:setPercent( self.currTime * 100 / self.totalTime )

	if self.currTime * 100 / self.totalTime <= 0 then
		self:finish()
		self.wrongFunc()
		PopupLayerController:hideLayer("ClimbingLayer", function(layer)
    		self:hide()
    	end)
	end
end

Helper:classDefNodeGetInstance(ClimbingLayer)

return ClimbingLayer0000000000000