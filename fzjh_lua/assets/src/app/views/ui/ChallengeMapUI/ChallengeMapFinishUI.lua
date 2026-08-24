local ChallengeMapFinishUI = class("ChallengeMapFinishUI", LayerEx)

function ChallengeMapFinishUI:create()
	local p = ChallengeMapFinishUI:new()
	p:init()
	return p
end

function ChallengeMapFinishUI:init()
    self._round = require("Layer/ChallengeMapUI/ChallengeMapFinishUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ChallengeMapFinishUI:showUI()
    self:setVisible(true)
end

function ChallengeMapFinishUI:hideUI()
    self:setVisible(false)
end

function ChallengeMapFinishUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function ChallengeMapFinishUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function ChallengeMapFinishUI:setTextTips(text)
    self.Text_tips:setString(text)
end

function ChallengeMapFinishUI:setListViewReward(array)
	self.ListView_reward:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self.Panel_reward:clone()
        Helper:convertUIByParent(panel)

		panel.Text_reward:setString(v["rewardText"])
        self.ListView_reward:pushBackCustomItem(panel)
    end
    self.ListView_reward:jumpToTop()
end

function ChallengeMapFinishUI:setButtonLeave(text,func)
	self.Button_leave.Text_ButtonName:setString(text)
	self.Button_leave:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ChallengeMapFinishUI0000000000