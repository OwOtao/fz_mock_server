local DialogUI = require("app.views.ui.Dialog.Dialog2UI")

local DialogBLayer = class("DialogBLayer", cc.Layer)

function DialogBLayer:create()
	local p = DialogBLayer:new()
	p:init()
	return p
end

function DialogBLayer:init()
	self._UI = DialogUI:create()
	self._UI:addTo(self)
end

function DialogBLayer:show(list)
	self._UI:show(list)
end

function DialogBLayer:hide()
	self._UI:hide()
end

function DialogBLayer:setButton1(title, func)
	self._UI:setButton("Button_1", title, func)
end

function DialogBLayer:setButton2(title, func)
	self._UI:setButton("Button_2", title, func)
end

function DialogBLayer:setButton3(title, func)
	self._UI:setButton("Button_3", title, func)
end

function DialogBLayer:getRow(rowNum)
	self._UI:getRow(rowNum)
end

Helper:classDefNodeGetInstance(DialogBLayer)
return DialogBLayer0000000000