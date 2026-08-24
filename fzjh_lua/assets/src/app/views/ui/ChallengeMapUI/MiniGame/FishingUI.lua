local FishingUI = class("FishingUI", LayerEx)

function FishingUI:create()
	local p = FishingUI:new()
	p:init()
	return p
end

function FishingUI:init()
    self._round = require("Layer/ActionUI/FishingGame/FishingGameUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function FishingUI:showUI()
    self:setVisible(true)
end

function FishingUI:hideUI()
    self:setVisible(false)
end

function FishingUI:setTitle(text)
    self.Panel_category.Text_Title:setString(text)   
end                   

function FishingUI:setDesc(text)
    self.Text_dec:setString(text)
end

function FishingUI:setTime(text)
    self.Text_time:setString(text)
end

function FishingUI:setDistraction(text)
    self.Text_distraction:setString(text)
end

function FishingUI:setFocus(text)
    self.Text_focus:setString(text)
end

function FishingUI:setCountText(text)
    self.Text_text:setString(text)
end

function FishingUI:setSucSize(width)
    self.Panel_bar.Image_3:setSize({width = width, height = 36.0000})
end

function FishingUI:setSucPosX(posX)
    self.Panel_bar.Image_3:setPositionX(posX)
end

function FishingUI:getFanilWidth()
    return self.Panel_bar:getSizeWidth()
end

function FishingUI:setTrackPosX(posX)
    self.Panel_bar.Panel_track:setPositionX(posX)
end

function FishingUI:getTrack()
    return self.Panel_bar.Panel_track
end

function FishingUI:setButton1Enabled(bool)
    self.Button_5:setEnabled(bool)
end

function FishingUI:setButton1(text,func)
	self.Button_5.Text_buttonName:setString(text)
	self.Button_5:releaseFunc(function()
		if func then
			func()
		end
	end)
end

return FishingUI000000000