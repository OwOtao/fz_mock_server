local TechniqueImproveUI = class("TechniqueImproveUI", LayerEx)

function TechniqueImproveUI:create()
	local p = TechniqueImproveUI:new()
	p:init()
	return p
end

function TechniqueImproveUI:init()
    self._round = require("Layer/FistFootUI/TechniqueImproveUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function TechniqueImproveUI:setTextTitle1(text)
	if text == nil then
		assert(false,"TechniqueImproveUI:setTextTitle1 参数不可为空")
	end
    self.Text_Title1:setString(text)
end

function TechniqueImproveUI:setTextTitle2(text)
	if text == nil then
		assert(false,"TechniqueImproveUI:setTextTitle2 参数不可为空")
	end

	self.Text_Title2:setString(text)
end


function TechniqueImproveUI:setTextDesc1(text)
	if text == nil then
		assert(false,"TechniqueImproveUI:setTextDesc1 参数不可为空")
	end
	
	self.Text_desc_1:setString(text)
end

function TechniqueImproveUI:setPanelText1(text1,text2)
	if text1 == nil or text2 == nil then
		assert(false,"TechniqueImproveUI:setPanelText1 参数不可为空")
	end
	self.Panel_Text1.Text_title:setString(text1)
	self.Panel_Text1.Text_point:setString(text2)
end

function TechniqueImproveUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function TechniqueImproveUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return TechniqueImproveUI0