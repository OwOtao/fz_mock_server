local ChallengeMapLoseUI = class("ChallengeMapLoseUI", LayerEx)

function ChallengeMapLoseUI:create()
	local p = ChallengeMapLoseUI:new()
	p:init()
	return p
end

function ChallengeMapLoseUI:init()
    self._round = require("Layer/ChallengeMapUI/ChallengeMapLoseUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ChallengeMapLoseUI:showUI()
    self:setVisible(true)
end

function ChallengeMapLoseUI:hideUI()
    self:setVisible(false)
end

function ChallengeMapLoseUI:setTextTitle(text)
    self.Text_title:setString(text)
end

function ChallengeMapLoseUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function ChallengeMapLoseUI:setButtonLeave(text,func)
	self.Button_leave.Text_ButtonName:setString(text)
	self.Button_leave:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ChallengeMapLoseUI000000000