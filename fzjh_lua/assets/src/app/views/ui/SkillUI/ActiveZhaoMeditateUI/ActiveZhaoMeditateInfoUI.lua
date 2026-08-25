--[[
Descripttion: 
version: 
Author: LvBin
Date: 2026-07-19 16:59:29
--]]
local ActiveZhaoMeditateInfoUI = class("ActiveZhaoMeditateInfoUI", LayerEx)

function ActiveZhaoMeditateInfoUI:create()
	local p = ActiveZhaoMeditateInfoUI:new()
	p:init()
	return p
end

function ActiveZhaoMeditateInfoUI:init()
    self._round = require("Layer/SkillUI/ActiveZhaoMeditate/ActiveZhaoMeditateInfoUI.lua").create()['root']
    self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ActiveZhaoMeditateInfoUI:showUI()
    self:setVisible(true)
end

function ActiveZhaoMeditateInfoUI:hideUI()
    self:setVisible(false)
end

function ActiveZhaoMeditateInfoUI:setTextTitle(text)
	self.Text_title:setString(text)
end

function ActiveZhaoMeditateInfoUI:setText(index,text)
	if self["Text_"..index] then
		self["Text_"..index]:setString(text)
	end
end

function ActiveZhaoMeditateInfoUI:setSelectText1(text)
	self.Image_1.Text_selectNum:setString(text)
end

function ActiveZhaoMeditateInfoUI:setSelectText2(text)
	self.Image_2.Text_selectNum:setString(text)
end

function ActiveZhaoMeditateInfoUI:setButtonCanyeMin(func)
	self.Image_1.Button_1:releaseFunc(
		function()
			if func then
				func()
			end
		end
	)
end

function ActiveZhaoMeditateInfoUI:setButtonCanyeMax(func)
	self.Image_1.Button_4:releaseFunc(
		function()
			if func then
				func()
			end
		end
	)
end

function ActiveZhaoMeditateInfoUI:setButtonCsgwMin(func)
	self.Image_2.Button_1:releaseFunc(
		function()
			if func then
				func()
			end
		end
	)
end

function ActiveZhaoMeditateInfoUI:setButtonCsgwMax(func)
	self.Image_2.Button_4:releaseFunc(
		function()
			if func then
				func()
			end
		end
	)
end

function ActiveZhaoMeditateInfoUI:setButtonCanyeDec(data)
    self.Image_1.Button_2:releaseFuncTotally(function()
        data.beganFunc()
    end,function()
        data.endedFunc()
    end,function()
        data.canceledFunc()
    end)
end

function ActiveZhaoMeditateInfoUI:setButtonCanyeAdd(data)
    self.Image_1.Button_3:releaseFuncTotally(function()
        data.beganFunc()
    end,function()
        data.endedFunc()
    end,function()
        data.canceledFunc()
    end)
end

function ActiveZhaoMeditateInfoUI:setButtonCsgwDec(data)
    self.Image_2.Button_2:releaseFuncTotally(function()
        data.beganFunc()
    end,function()
        data.endedFunc()
    end,function()
        data.canceledFunc()
    end)
end

function ActiveZhaoMeditateInfoUI:setButtonCsgwAdd(data)
    self.Image_2.Button_3:releaseFuncTotally(function()
        data.beganFunc()
    end,function()
        data.endedFunc()
    end,function()
        data.canceledFunc()
    end)
end

function ActiveZhaoMeditateInfoUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
        if func then
            func()
        end
    end)
end

function ActiveZhaoMeditateInfoUI:setPanelBack(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return ActiveZhaoMeditateInfoUI00