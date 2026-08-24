local ChessLeaveUI = class("ChessLeaveUI", LayerEx)

function ChessLeaveUI:create()
	local p = ChessLeaveUI:new()
	p:init()
	return p
end

function ChessLeaveUI:init()
    self._round = require("Layer/ChessboardUI/ChessLeaveUI.lua").create()['root']
	self._round:addTo(self)

    Helper:convertUIByParent(self)
end

function ChessLeaveUI:showUI()
    self:show()
end

function ChessLeaveUI:hideUI()
    self:hide()
end

function ChessLeaveUI:setLeaveText(text)
    self.Text_2:setString(text)
end

function ChessLeaveUI:setCurrFloorText(text)
    self.Text_3:setString(text)
end

function ChessLeaveUI:setButtonBack(func)
	self.Image_title.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ChessLeaveUI:setButton1(name,func)
    self.Button_1.Text_buttonName:setString(name)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function ChessLeaveUI:setButton2(name,func)
    self.Button_2.Text_buttonName:setString(name)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end


return ChessLeaveUI000000000