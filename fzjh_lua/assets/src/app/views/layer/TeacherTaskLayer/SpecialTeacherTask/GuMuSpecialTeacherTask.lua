-- 石壁
local GuMuSpecialTeacherTask = class("GuMuSpecialTeacherTask", LayerEx)

function GuMuSpecialTeacherTask:create()
	local p = GuMuSpecialTeacherTask:new()
	p:init()
	return p
end

function GuMuSpecialTeacherTask:init()
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
function GuMuSpecialTeacherTask:showLayer(title, desc, time, count,successCount, textMap, rightFunc, wrongFunc)
	if self.scheduleHandle ~= nil then
		self:unschedule( self.scheduleHandle )
		self.scheduleHandle = nil
	end

	self.Button_up:setOpacity(0)
	self.Button_down:setOpacity(0)
	self.Button_left:setOpacity(0)
	self.Button_right:setOpacity(0)

	self.count = count
	self.successCount = successCount
	self.number = 0
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
function GuMuSpecialTeacherTask:setButtonName(str)
	local strs = string.split(str, ";")
	self.Button_up.Text_Name:setString(strs[1])
	self.Button_down.Text_Name:setString(strs[2])
	self.Button_left.Text_Name:setString(strs[3])
	self.Button_right.Text_Name:setString(strs[4])
end
function GuMuSpecialTeacherTask:initRichText()
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
function GuMuSpecialTeacherTask:start()
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
	-- button:setPosition(cc.p(540, 900))
	self:showButtonAim({self.Button_up, self.Button_down, self.Button_left, self.Button_right}, 0)

	self.scheduleHandle = self:schedule( function(ft)
		self:update(ft)
	end, 30/1000 )
end

-- 结束
function GuMuSpecialTeacherTask:finish()
	self:showButtonAim({self.Button_up, self.Button_down, self.Button_left, self.Button_right}, 1)
	self:stopSchedule()
	self:initRichText()
	self:hideUI()
end

-- 停止刷新进度条
function GuMuSpecialTeacherTask:stopSchedule()
	if self.scheduleHandle ~= nil then
		self:unschedule( self.scheduleHandle )
		self.scheduleHandle = nil
	end
end

-- 设置时间间隔
function GuMuSpecialTeacherTask:setTime()
	self.totalTime = self.intervalTime * 1000 / 30
	self.currTime = self.totalTime
end

function GuMuSpecialTeacherTask:setBack()
end
function GuMuSpecialTeacherTask:getRichPrintText(isSuccess,direction)
	if isSuccess then
		if math.random(1,2) == 1 then
			return "你轻身一跃，往"..direction.."飞去，一手便捉住了在逃的麻雀。"
		else
			return "你足尖轻一点地，整个人往"..direction.."方腾空而起，轻而易举地捉住了麻雀。"
		end
	else
		if math.random(1,2) == 1 then
			return "你运起轻功，提身而起，却跳错了方位，使得麻雀飞走了。"

		else
			return "你没看清方位便着急地腾空一跃，使得麻雀拍拍翅膀飞走了。"
		end
	end
end
function GuMuSpecialTeacherTask:setButton()
	self.Button_up:releaseFunc(function()
		self:finish()
		print("剩余抓捕次数:",self.count)
		if self.rightDirection == 1 then
			RichPrint("main", self:getRichPrintText(true,"上"))
			self.number = self.number +1 
			if self.number == self.successCount then
				self.rightFunc()
				self:hide()
				return
			end
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
				return
			end
			print("当前成功抓捕次数:",self.number)
			self:delayFunc(1, function()
				self:start()
			end)
		else
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
			else
				RichPrint("main", self:getRichPrintText(false))
				self:delayFunc(1, function()
					self:start()
				end)
			end
		end
	end)

	self.Button_down:releaseFunc(function()
		self:finish()
		print("剩余抓捕次数:",self.count)
		if self.rightDirection == 2 then
			RichPrint("main", self:getRichPrintText(true,"斜"))
			self.number = self.number +1 
			if self.number == self.successCount then
				self.rightFunc()
				self:hide()
				return
			end
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
				return
			end
			self:delayFunc(1, function()
				self:start()
			end)
		else
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
			else
				RichPrint("main", self:getRichPrintText(false))
				self:delayFunc(1, function()
					self:start()
				end)
			end		end
	end)

	self.Button_left:releaseFunc(function()
		self:finish()
		print("剩余抓捕次数:",self.count)
		if self.rightDirection == 3 then
			RichPrint("main", self:getRichPrintText(true,"左"))
			self.number = self.number +1 
			if self.number == self.successCount then
				self.rightFunc()
				self:hide()
				return
			end
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
				return
			end
			self:delayFunc(1, function()
				self:start()
			end)
		else
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
			else
				RichPrint("main", self:getRichPrintText(false))
				self:delayFunc(1, function()
					self:start()
				end)
			end
		end
	end)

	self.Button_right:releaseFunc(function()
		self:finish()
		print("剩余抓捕次数:",self.count)
		if self.rightDirection == 4 then
			RichPrint("main", self:getRichPrintText(true,"右"))
			self.number = self.number +1 
			if self.number == self.successCount then
				self.rightFunc()
				self:hide()
				return
			end
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
				return
			end
			self:delayFunc(1, function()
				self:start()
			end)
		else
			if self.count <= 0 then
				self.wrongFunc()
				self:hide()
			else
				RichPrint("main", self:getRichPrintText(false))
				self:delayFunc(1, function()
					self:start()
				end)
			end
		end
	end)
end

-- 显示按钮动画
function GuMuSpecialTeacherTask:showButtonAim(btnList, isInOut)
	if MapIsEmpty(btnList) == true then
		return
	end

	local animDuration = 0.25
	local function buttonAnim(button, dir, isInOut)
		local offsetsXY = {{0, 200}, {0, - 200}, {-350, 0}, {350, 0}}
		local offsetsXY1 = {{540, 1100}, {540, 700}, {190, 900}, {890, 900}}
		local offsetsXY2 = {{540, 700}, {540, 1100}, {890, 900}, {190, 900}}
		button:setOpacity(isInOut * 255)
		if isInOut == 0 then
			button:setPosition(cc.p(540, 900))
			button:setVisible(true)
			button:runActionWithName("YXEaseAction",YXEaseAction:create( cc.Spawn:create(
				cc.CallFunc:create(function()button:setTouchEnabled(false) end),
				cc.MoveTo:create(animDuration, cc.p(offsetsXY1[dir][1], offsetsXY1[dir][2]) ) ,
				cc.FadeIn:create(animDuration),
				cc.CallFunc:create(function()button:setTouchEnabled(true) end)
			),  Sine_EaseOut ))
		else
			button:setVisible(true)
			button:runActionWithName("YXEaseAction",YXEaseAction:create( cc.Spawn:create(
				cc.CallFunc:create(function()button:setTouchEnabled(false) end),
				cc.MoveTo:create(animDuration, cc.p(offsetsXY2[dir][1], offsetsXY2[dir][2]) ) ,
				cc.FadeOut:create(animDuration),
				cc.CallFunc:create(function()button:setTouchEnabled(true) end)
			),  Sine_EaseOut ))
		end
	end

	local index = 1
	for k,v in pairs(btnList) do 
		v:stopActionByName("YXEaseAction")
		v:setVisible(false)
	end
	for k,v in pairs(btnList) do
		-- v:setPosition(cc.p(540, 900))
		buttonAnim(v, index, isInOut)
		index = index + 1
	end
end

-- 屏蔽UI
function GuMuSpecialTeacherTask:hideUI()
	self.Text_desc_1:setVisible(false)
	self.LoadingBar:setVisible(false)
end

-- 显示UI
function GuMuSpecialTeacherTask:showUI()
	self.LoadingBar:setPercent(100)
	self.Text_desc_1:setVisible(true)
	self.LoadingBar:setVisible(true)
end

function GuMuSpecialTeacherTask:update(ft)
	self.currTime = self.currTime - 1

	self.LoadingBar:setPercent( self.currTime * 100 / self.totalTime )

	if self.currTime * 100 / self.totalTime <= 0 then
		self:finish()
		print("剩余抓捕次数:",self.count)
		if self.count <= 0 then
			self.wrongFunc()
			self:hide()
			return
		end
		RichPrint("main", "你眼睁睁看着麻雀从你眼前飞过，却没做出任何反应。")
		self:delayFunc(1, function()
			self:start()
		end)
	end
end

Helper:classDefNodeGetInstance(GuMuSpecialTeacherTask)

return GuMuSpecialTeacherTask000000000000