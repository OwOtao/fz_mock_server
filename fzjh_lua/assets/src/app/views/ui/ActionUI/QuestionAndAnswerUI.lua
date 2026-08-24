local QuestionAndAnswerUI = class("QuestionAndAnswerUI", cc.Layer)

function QuestionAndAnswerUI:create()
    local p = QuestionAndAnswerUI:new()
    p:init()
    return p
end

function QuestionAndAnswerUI:init()
	local UI = require("Layer/ActionUI/QuestionAndAnswerUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)

    self:hide()
end

function QuestionAndAnswerUI:showUI()
	self:show()
end

function QuestionAndAnswerUI:hideUI()
	self:hide()
end

function QuestionAndAnswerUI:setTitleText(text)
	self.Panel_title.Text_Title:setString(text)
end

function QuestionAndAnswerUI:showThreeAnswers()
	local posY = {
		1013.32,856.83,700.35
	}
	for i = 1,3 do
		self.Panel_kaochang.Panel_answer["Button_"..tostring(i)]:setVisible(true)
		self.Panel_kaochang.Panel_answer["Button_"..tostring(i)]:setPositionY(posY[i])
	end
	self.Panel_kaochang.Panel_answer["Button_4"]:setVisible(false)
end

function QuestionAndAnswerUI:showFourAnswers()
	local posY = {
		1081.52,938.89,796.26,653.63
	}
	for i = 1,4 do
		self.Panel_kaochang.Panel_answer["Button_"..tostring(i)]:setVisible(true)
		self.Panel_kaochang.Panel_answer["Button_"..tostring(i)]:setPositionY(posY[i])
	end
end

function QuestionAndAnswerUI:getAnswerPos(index,showNum)
	local posY_1 = {
		1013.32,856.83,700.35
	}
	local posY_2 = {
		1081.52,938.89,796.26,653.63
	}

	if showNum == #posY_1 then
		return posY_1[index]
	else
		return posY_2[index]
	end
end

function QuestionAndAnswerUI:setAnswerText(index,text)
	if self.Panel_kaochang.Panel_answer["Button_"..tostring(index)] then
		self.Panel_kaochang.Panel_answer["Button_"..tostring(index)].Text_btnName:setString(text)
	end
end

function QuestionAndAnswerUI:setAnswerFunc(index,func)
	if self.Panel_kaochang.Panel_answer["Button_"..tostring(index)] then
		self.Panel_kaochang.Panel_answer["Button_"..tostring(index)]:releaseFunc(function()
			if func then
				func()
			end
		end)
	end
end

function QuestionAndAnswerUI:hideAnswerResult()
	self.Panel_kaochang.Panel_answer.Image_noResult:setVisible(false)
end

function QuestionAndAnswerUI:showAnswerResult(texture)
	self.Panel_kaochang.Panel_answer.Image_noResult:setVisible(true)
	self.Panel_kaochang.Panel_answer.Image_noResult:loadTexture(texture)
end

function QuestionAndAnswerUI:setRightResultVisible(visible)
	if visible ~= true then
		visible = false
	end

	self.Panel_kaochang.Panel_answer.Image_rightResult:setVisible(visible)
end

function QuestionAndAnswerUI:setRrrorResultVisible(visible)
	if visible ~= true then
		visible = false
	end

	self.Panel_kaochang.Panel_answer.Image_errorResult:setVisible(visible)
end

function QuestionAndAnswerUI:setRightResultPosY(pos)
	self.Panel_kaochang.Panel_answer.Image_rightResult:setPositionY(pos)
end

function QuestionAndAnswerUI:setRrrorResultPosY(pos)
	self.Panel_kaochang.Panel_answer.Image_errorResult:setPositionY(pos)
end

function QuestionAndAnswerUI:setQuestionDescText(text)
	self.Panel_kaochang.Panel_answer.Text_desc:setString(text)
end

function QuestionAndAnswerUI:setQuestionTipsText(text)
	self.Panel_kaochang.Panel_answer.Text_tip:setString(text)
end

function QuestionAndAnswerUI:setQuestionTipsTextVisible(visible)
	if visible ~= true then
		visible = false
	end
	self.Panel_kaochang.Panel_answer.Text_tip:setVisible(visible)
end

function QuestionAndAnswerUI:setAnswerTimeText(text)
	self.Panel_kaochang.Text_time_num:setString(text)
end

function QuestionAndAnswerUI:setQuestionNumText(text)
	self.Panel_kaochang.Text_count:setString(text)
end

function QuestionAndAnswerUI:setQuestionPanelVisible(visible)
	if visible ~= true then
		visible = false
	end
	self.Panel_kaochang:setVisible(visible)
end

function QuestionAndAnswerUI:setResultPanelVisible(visible)
	if visible ~= true then
		visible = false
	end
	self.Panel_result:setVisible(visible)
end

function QuestionAndAnswerUI:setRightNumText(text)
	self.Panel_result.Text_true:setString(text)
end

function QuestionAndAnswerUI:setErrorNumText(text)
	self.Panel_result.Text_error:setString(text)
end

function QuestionAndAnswerUI:setResultTitle(text)
	self.Panel_result.Text_title:setString(text)
end

function QuestionAndAnswerUI:setResultButtonFunc(index,func)
	self.Panel_result["Button_"..tostring(index)]:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function QuestionAndAnswerUI:setResultButtonName(index,name)
	self.Panel_result["Button_"..tostring(index)].Text_btnName:setString(name)
end

Helper:classDefNodeGetInstance(QuestionAndAnswerUI)

return QuestionAndAnswerUI

00000000000000