local SpeedUpGuaJiUI = class("SpeedUpGuaJiUI", LayerEx)

function SpeedUpGuaJiUI:create()
	local p = SpeedUpGuaJiUI:new()
	p:init()
	return p
end

function SpeedUpGuaJiUI:init()
    self._round = require("Layer/FistFootUI/SpeedUpGuaJiUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function SpeedUpGuaJiUI:setTextDesc(text)
    self.Text_desc:setString(text)
end

function SpeedUpGuaJiUI:setTextTime(text)
    self.Text_time:setString(text)
end

function SpeedUpGuaJiUI:setTextNum(num)
    self.Text_num:setString(num)
end

function SpeedUpGuaJiUI:setTextSpeedTime(text)
    self.Text_speedTime:setString(text)
end

function SpeedUpGuaJiUI:setPanelMin(data)
    self.Panel_min.Image_di:loadTexture(data.image)
    self.Panel_min.Text_1:setTextColor(data.color)
    self.Panel_min:releaseFunc(function()
		if data.func then
			data.func()
		end
	end)
end

function SpeedUpGuaJiUI:setButtonDec(data)
    self.Button_dec.Image_di:setVisible(data.bright)
    self.Button_dec:setBright(data.bright)
    self.Button_dec:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function SpeedUpGuaJiUI:setButtonAdd(data)
    self.Button_add.Image_di:setVisible(data.bright)
    self.Button_add:setBright(data.bright)
    self.Button_add:releaseFuncTotally(function()
        data["beganFunc"]()
    end,function()
        data["endedFunc"]()
    end,function()
        data["canceledFunc"]()
    end)
end

function SpeedUpGuaJiUI:setPanelMax(data)
    self.Panel_max.Image_di:loadTexture(data.image)
    self.Panel_max.Text_1:setTextColor(data.color)
    self.Panel_max:releaseFunc(function()
		if data.func then
			data.func()
		end
	end)
end

function SpeedUpGuaJiUI:setButtonConfirm(func)
    self.Button_confirm:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function SpeedUpGuaJiUI:setButtonCancel(func)
    self.Button_cancel:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return SpeedUpGuaJiUI0000000000000000