local ActiveZhaoInsightConfirmUI = class("ActiveZhaoInsightConfirmUI", LayerEx)

function ActiveZhaoInsightConfirmUI:create()
	local p = ActiveZhaoInsightConfirmUI:new()
	p:init()
	return p
end

function ActiveZhaoInsightConfirmUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoInsightConfirmUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoInsightConfirmUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoInsightConfirmUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoInsightConfirmUI:setLevelText(text)
	self.Text_level:setString(text)
end

function ActiveZhaoInsightConfirmUI:setEffectDscText(text)
	self.Text_effect_dsc:setString(text)
end

function ActiveZhaoInsightConfirmUI:setConditionDscText(text)
	self.Text_condition_dsc:setString(text)
end

function ActiveZhaoInsightConfirmUI:setResText(textArray)
    if MapIsEmpty(textArray) == false then
        for i=1, #textArray do
            if self["Text_res_"..tostring(i)] then
                self["Text_res_"..tostring(i)]:setVisible(true)
                self["Text_res_"..tostring(i)]:setString(Helper:getDef(textArray[i], ""))
            end
        end
    end
end

function ActiveZhaoInsightConfirmUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoInsightConfirmUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoInsightConfirmUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoInsightConfirmUI0000000