local ActiveZhaoStopInsightUI = class("ActiveZhaoStopInsightUI", LayerEx)

function ActiveZhaoStopInsightUI:create()
	local p = ActiveZhaoStopInsightUI:new()
	p:init()
	return p
end

function ActiveZhaoStopInsightUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoStopInsightUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoStopInsightUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoStopInsightUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoStopInsightUI:setTextDsc(text)
	self.Text_dsc:setString(text)
end

function ActiveZhaoStopInsightUI:setTimeText(text)
    self.Text_time:setString(text)
end

function ActiveZhaoStopInsightUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoStopInsightUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoStopInsightUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoStopInsightUI00