local AnswerUI = class("AnswerUI", LayerEx)

function AnswerUI:create()
	local p = AnswerUI:new()
	p:init()
	return p
end

function AnswerUI:init()
    self._round = require("Layer/ChallengeMapUI/ChallengeMapAnswerUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function AnswerUI:showUI()
    self:setVisible(true)
end

function AnswerUI:hideUI()
    self:setVisible(false)
end

function AnswerUI:setTitle(text)
    self.Panel_category.Text_Title:setString(text)   
end                     

function AnswerUI:setTimeText(text)
    self.Panel_kaochang.Text_time_num:setString(text) 
end

function AnswerUI:setTopicCountText(text)
    self.Panel_kaochang.Text_count:setString(text) 
end

function AnswerUI:getPanelAnswer()
    return self.Panel_kaochang
end


return AnswerUI000000