local ChallengeMapCustomsUI = class("ChallengeMapCustomsUI", LayerEx)

function ChallengeMapCustomsUI:create()
	local p = ChallengeMapCustomsUI:new()
	p:init()
	return p
end

function ChallengeMapCustomsUI:init()
    self._round = require("Layer/ChallengeMapUI/ChallengeMapCustomsUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ChallengeMapCustomsUI:showUI()
    self:setVisible(true)
end

function ChallengeMapCustomsUI:hideUI()
    self:setVisible(false)
end

function ChallengeMapCustomsUI:setDesc(text)
    self.Text_desc:setString(text)
end

function ChallengeMapCustomsUI:setListView(array)
	self.ListView_item:removeAllItems()
    for i,v in ipairs(array) do
        local panel = self.Panel_item:clone()
        Helper:convertUIByParent(panel)

        panel.Text_1:setString(v)
        
        self.ListView_item:pushBackCustomItem(panel)
    end
end

function ChallengeMapCustomsUI:setButton1(text,func)
	self.Button_1.Text_ButtonName:setString(text)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ChallengeMapCustomsUI:setButton2(text,func)
	self.Button_2.Text_ButtonName:setString(text)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ChallengeMapCustomsUI0000000000000000