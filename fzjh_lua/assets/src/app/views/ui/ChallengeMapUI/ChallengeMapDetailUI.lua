local ChallengeMapDetailUI = class("ChallengeMapDetailUI", LayerEx)

function ChallengeMapDetailUI:create()
	local p = ChallengeMapDetailUI:new()
	p:init()
	return p
end

function ChallengeMapDetailUI:init()
    self._round = require("Layer/ChallengeMapUI/ChallengeMapDetailUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ChallengeMapDetailUI:showUI()
    self:setVisible(true)
end

function ChallengeMapDetailUI:hideUI()
    self:setVisible(false)
end

function ChallengeMapDetailUI:setMapName(name)
    self.Text_mapName:setString(name)
end

function ChallengeMapDetailUI:setMapDesc(text)
    self.Image_desc.Text_desc:setString(text)
end

function ChallengeMapDetailUI:setGradeSelectText(text)
    self.Text_gradeSelect:setString(text)
end

function ChallengeMapDetailUI:setGradeName(text)
    self.Text_gradeName:setString(text)
end

function ChallengeMapDetailUI:setTextFinishCon(text)
    self.Text_finishCon:setString(text)
end

function ChallengeMapDetailUI:setListViewReward(array)
	self.Image_reward.ListView_reward:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self.Panel_reward:clone()
        Helper:convertUIByParent(panel)

		panel.Text_1:setString(v["reward1"])
		panel.Text_2:setString(v["reward2"])

        self.Image_reward.ListView_reward:pushBackCustomItem(panel)
    end
    self.Image_reward.ListView_reward:jumpToTop()
end

function ChallengeMapDetailUI:setTextEnterConItem(text)
    self.Text_enterConItem:setString(text)
end

function ChallengeMapDetailUI:setTextEnterConItems(text)
    self.Text_enterConItems:setString(text)
end

function ChallengeMapDetailUI:setTextEnterConLv(text)
    self.Text_enterConLv:setString(text)
end

function ChallengeMapDetailUI:setTextEnterConsume(text)
    self.Text_enterConsume:setString(text)
end

function ChallengeMapDetailUI:setTextCurrConsume(text)
    self.Text_currConsume:setString(text)
end

function ChallengeMapDetailUI:setTextEnterCondotion(text)
    self.Text_enterCondotion:setString(text)
end

function ChallengeMapDetailUI:setButtonLeft(func)
	self.Button_left:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ChallengeMapDetailUI:setButtonRight(func)
	self.Button_right:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ChallengeMapDetailUI:setButtonEnter(args)
	self.Button_enter:setPosition(args.positionX, args.positionY)
	self.Button_enter:setVisible(args.isVisible)
	self.Button_enter.Text_ButtonName:setString(args.text)
	self.Button_enter:releaseFunc(function()
		if args.func then
			args.func()
		end
	end)
end

function ChallengeMapDetailUI:setButtonBack(func)
	self.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ChallengeMapDetailUI:setButtonCustoms(args)
	self.Button_customs:setPosition(args.positionX, args.positionY)
	self.Button_customs:setVisible(args.isVisible)
	self.Button_customs.Text_ButtonName:setString(args.text)
	self.Button_customs:releaseFunc(function()
		if args.func then
			args.func()
		end
	end)
end

return ChallengeMapDetailUI000000000000