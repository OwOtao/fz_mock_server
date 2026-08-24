local DialogHLayer = class("DialogHLayer", cc.Layer)

function DialogHLayer:create()
	local p = DialogHLayer:new()
	p:init()
	return p
end

function DialogHLayer:init()
	self._round = require("Layer/Dialog/Dialog8UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
end

function DialogHLayer:setButton1(str, func)
	if not str then
		self.Button_1:setVisible(false)
	else
		self.Text_name:setString(str)
		self.Button_1:setVisible(true)
	end
	
	self.Button_1:releaseFunc(function()
		self:hide()
		if func then
			func()
		end
	end)
end

function DialogHLayer:setText(str)
	if not str then
		self:hide()
		return
	end
	self.Text_2:setString(str)
end

function DialogHLayer:setTitle(str)
	if not str then
		str = "公告"
	end
	self.Text_1:setString(str)
end

function DialogHLayer:setBackOpacity(opacity)
	self.Panel_back:setBackGroundColorOpacity(opacity)
end


Helper:classDefNodeGetInstance(DialogHLayer)
return DialogHLayer00000