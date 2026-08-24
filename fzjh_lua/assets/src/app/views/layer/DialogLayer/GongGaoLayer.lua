local GongGaoLayer = class("GongGaoLayer", cc.Layer)

function GongGaoLayer:create()
	local p = GongGaoLayer:new()
	p:init()
	return p
end

function GongGaoLayer:init()
	self._round = require("Layer/Dialog/GongGaoUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
end

function GongGaoLayer:setButton1(str, func)
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

function GongGaoLayer:setText(str)
	if not str then
		self:hide()
		return
	end
	self.Text_2:setString(str)
end

function GongGaoLayer:setTitle(str)
	if not str then
		str = "公告"
	end
	self.Text_1:setString(str)
end


Helper:classDefNodeGetInstance(GongGaoLayer)
return GongGaoLayer0000000000000000