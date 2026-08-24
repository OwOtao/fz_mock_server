local DialogILayer = class("DialogILayer", cc.Layer)

function DialogILayer:create()
	local p = DialogILayer:new()
	p:init()
	return p
end

function DialogILayer:init()
	self._round = require("Layer/Dialog/Dialog9UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
end

function DialogILayer:setText(str)
	if not str then
		self:hide()
		return
	end
	self.Text_1:setString(str)
end


Helper:classDefNodeGetInstance(DialogILayer)
return DialogILayer00000000000000