--[[
Descripttion: 
version: 
Author: LvBin
Date: 2026-07-30 17:16:45
--]]
local ActiveZhaoMeditateConfirmUI = class("ActiveZhaoMeditateConfirmUI", LayerEx)

function ActiveZhaoMeditateConfirmUI:create()
	local p = ActiveZhaoMeditateConfirmUI:new()
	p:init()
	return p
end

function ActiveZhaoMeditateConfirmUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoMeditateConfirmUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoMeditateConfirmUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoMeditateConfirmUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoMeditateConfirmUI:setDscText(text)
	self.Text_dsc:setString(text)
end

function ActiveZhaoMeditateConfirmUI:setText1(text)
	self.Text_1:setString(text)
end

function ActiveZhaoMeditateConfirmUI:setText2(text)
	self.Text_2:setString(text)
end

function ActiveZhaoMeditateConfirmUI:setResText(textArray)
	for i = 1, 2 do
		local text = textArray[i]
		
		local _row = self["Text_res_"..tostring(i)]

		if text then
			_row:setVisible(true)
			_row:setString(text)
		else
			_row:setVisible(false)
		end
	end
end

function ActiveZhaoMeditateConfirmUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoMeditateConfirmUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoMeditateConfirmUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoMeditateConfirmUI00000000000000