-- 殿试入场动画界面
local PalaceExamEntranceLayer = class("PalaceExamEntranceLayer", LayerEx)

local Exam = require("app.models.Exam.Exam")

function PalaceExamEntranceLayer:create()
	local p = PalaceExamEntranceLayer:new()
	p:init()
	return p
end

function PalaceExamEntranceLayer:init()
	self._UI = require("Layer/ExamUI/PalaceExamEntranceUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setButton()

	-- 阶段
	self.stage = 1
end

function PalaceExamEntranceLayer:showLayer(id)
	-- 题目ID
	self.subjectId = id

	self.Text_8:setString(Exam:getPalaceQuestion(self.subjectId).question)

	self.stage = 1
	self:showAnimation()
	Audio:playEffect("taijian", false)
	Audio:playEffect("king", true)
	self:show()
end

-- 显示动画
function PalaceExamEntranceLayer:showAnimation()
	local function showAction(panel, delay)
		local animDuration = 2
		panel:setVisible(true)
		panel:setOpacity(0)
		panel:runAction(YXEaseAction:create( cc.Sequence:create(
			cc.DelayTime:create(delay),
			cc.FadeIn:create(animDuration)
		),  Sine_EaseOut ))
	end

	self.Text_1:setVisible(false)
	self.Text_2:setVisible(false)
	self.Text_3:setVisible(false)
	self.Text_4:setVisible(false)
	self.Text_5:setVisible(false)
	self.Text_6:setVisible(false)
	self.Text_7:setVisible(false)
	self.Text_8:setVisible(false)
	self.Button_1:setVisible(false)
	self.Button_2:setVisible(false)


	if self.stage == 1 then
		showAction(self.Text_1, 0)
		showAction(self.Text_2, 2)
		showAction(self.Text_3, 4)
		showAction(self.Text_4, 6)
		showAction(self.Text_5, 8)
		showAction(self.Text_6, 10)
		showAction(self.Button_1, 12)
	elseif self.stage == 2 then
		showAction(self.Text_7, 0)
		showAction(self.Text_8, 2)
		showAction(self.Button_2, 4)
	end
end

function PalaceExamEntranceLayer:setButton()
	self.Button_1:releaseFunc(function()
		if self.stage == 1 then
			self.stage = 2
			self:showAnimation()
		end
	end)
	self.Button_2:releaseFunc(function()
		Audio:stopAllEffects()
		PopupLayerController:hideLayer("PalaceExamEntranceLayer", function(layer)
			self:hide()
		end, 0)
		PopupLayerController:showLayer("PalaceExamLayer", function(layer)
			layer:showLayer(self.subjectId)
		end)
	end)
end

Helper:classDefNodeGetInstance(PalaceExamEntranceLayer)

return PalaceExamEntranceLayer00000