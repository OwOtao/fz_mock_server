-- 殿试跳转界面
local PalaceExamJumpLayer = class("PalaceExamJumpLayer", LayerEx)

function PalaceExamJumpLayer:create()
	local p = PalaceExamJumpLayer:new()
	p:init()
	return p
end

function PalaceExamJumpLayer:init()
	self._UI = require("Layer/ExamUI/PalaceExamJumpUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setButton()
end

function PalaceExamJumpLayer:showLayer(func)
	self.func = Helper:getDef(func, function()end)

	-- 更新剩余时间
	if self._handle ~= nil then
		self:unschedule(self._handle)
		self._handle = nil
	end

	self._handle = self:schedule(function (ft)
		self:update(ft)
	end,1/10)

	self.startTime = GetTime()

	local function showAction(panel, delay)
		local animDuration = 1.5
		panel:setVisible(true)
		panel:setOpacity(0)
		panel:runAction(YXEaseAction:create( cc.Sequence:create(
			cc.DelayTime:create(delay),
			cc.FadeIn:create(animDuration)
		),  Sine_EaseOut ))
	end

	showAction(self.Text_1, 0)
	showAction(self.Text_2, 3)


	self:show()
end

-- 更新进度条
function PalaceExamJumpLayer:update(dt)
	if self.startTime then
		local currTime = GetTime()
		local percent = ((currTime - self.startTime) / 5) * 100
		if percent >= 100 then
			percent = 100

			if self._handle ~= nil then
				self:unschedule(self._handle)
				self._handle = nil
			end

			self:delayFunc(0,function()
				self.func()
				PopupLayerController:hideLayer("PalaceExamJumpLayer", function(layer)
					self:hide()
				end, 0)
			end)
		end
		self.LoadingBar:setPercent(percent)
	end
end


function PalaceExamJumpLayer:setButton()
end

Helper:classDefNodeGetInstance(PalaceExamJumpLayer)

return PalaceExamJumpLayer000000