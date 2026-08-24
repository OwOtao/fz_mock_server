local PopTextUI = require("app.views.ui.PopUI.PopTextUI")

local PopTextLayer = class("PopTextLayer", cc.Layer)

function PopTextLayer:create()
	local p = PopTextLayer:new()
	p:init()
	return p
end

function PopTextLayer:init()
	self._UI = PopTextUI:create()
	self._UI:addTo(self)
end

function PopTextLayer:showLayer(desc,confirmFunc,levelFunc)
	self._UI:setDesc(desc)
	self:setButtonConfirm(confirmFunc)
	self:setButtonLevel(levelFunc)
	self._UI:show()
end

function PopTextLayer:setButtonConfirm(confirmFunc)
	self._UI:setButtonConfirm(function()
		if confirmFunc then
			confirmFunc()
		end
		self._UI:hide()
	end)
end

function PopTextLayer:setButtonLevel(levelFunc)
	self._UI:setButtonLevel(function()
		if levelFunc then
			levelFunc()
		end
		self._UI:hide()
	end)
end

function PopTextLayer:setTitle(title)
	self._UI:setTitle(title)
end
Helper:classDefNodeGetInstance(PopTextLayer)
return PopTextLayer000000