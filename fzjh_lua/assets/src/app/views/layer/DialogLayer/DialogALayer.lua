--[[
	确定取消对话框
	常用地点： 消耗品，重置界面，拜师界面等
]]

local DialogUI = require("app.views.ui.Dialog.DialogUI")

local DialogALayer = class("DialogALayer", cc.Layer)

function DialogALayer:create()
	local p = DialogALayer:new()
	p:init()
	return p
end

function DialogALayer:init()
	self._UI = DialogUI:create()
	self._UI:addTo(self)
end

function DialogALayer:show(text, desc, func)
	self:maxZ()
	self._UI:initRichText()
	self._UI:show(text, desc, func)
	self._UI:setWeChatVisible(true)
end

function DialogALayer:setVisible(bool)
	self._UI:setVisible(bool)
end

function DialogALayer:setRichText(text)
	self._UI:setRichText(text)
end

function DialogALayer:hide()
	self._UI:hide()
end

function DialogALayer:setDescColor(color)
	self._UI:setDescColor(color)
end

function DialogALayer:setText(text)
	self._UI:setText(text)
end

function DialogALayer:setExtraDescVisible(visible)
	self._UI:setExtraDescVisible(visible)
end

function DialogALayer:setExtraDescColor(color)
	self._UI:setExtraDescColor(color)
end

function DialogALayer:setExtraDesc(desc)
	self._UI:setExtraDesc(desc)
end

function DialogALayer:setButton1(title, func)
	self._UI:setButton("Button_1", title, func)
end

function DialogALayer:setButton2(title, func)
	self._UI:setButton("Button_2", title, func)
end

function DialogALayer:setButton3(title, func)
	self._UI:setButton("Button_3", title, func)
end

function DialogALayer:setBack(canHide)
	self._UI:setBack(canHide)
end

function DialogALayer:textFadeIn(item, anim, text, func)
	self._UI:textFadeIn(item, anim, text, func)
end

function DialogALayer:textFadeOut(item, anim, func)
	self._UI:textFadeOut(item, anim, func)
end


function DialogALayer:setWeChatVisible(bool) 
	self._UI:setWeChatVisible(bool)
end

function DialogALayer:setSelectVisible(bool)
	self._UI:setSelectVisible(bool)
end

function DialogALayer:setSelectFunc(func)
	self._UI:setSelectFunc(func)
end 

Helper:classDefNodeGetInstance(DialogALayer)
return DialogALayer00