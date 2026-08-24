
local DialogUI = require("app.views.ui.Dialog.Dialog3UI")

local DialogCLayer = class("DialogCLayer", cc.Layer)

function DialogCLayer:create()
	local p = DialogCLayer:new()
	p:init()
	return p
end

function DialogCLayer:init()
	self._UI = DialogUI:create()
	self._UI:addTo(self)
end

function DialogCLayer:show(title, list, state)
	self._UI:show(title, list, state)
end

function DialogCLayer:hide()
	self._UI:hide()
end

function DialogCLayer:setListView(list)
	self._UI:setListView(list)
end

function DialogCLayer:setButton1(title, func, unHide)
	self._UI:setButton("Button_1", title, func, unHide)
end

function DialogCLayer:setButton2(title, func, unHide)
	self._UI:setButton("Button_2", title, func, unHide)
end

function DialogCLayer:setButton3(title, func, unHide)
	self._UI:setButton("Button_3", title, func, unHide)
end

function DialogCLayer:setButton4(title, func, unHide)
	self._UI:setButton("Button_4", title, func, unHide)
end

function DialogCLayer:getRow(rowNum)
	self._UI:getRow(rowNum)
end

function DialogCLayer:setTextState(str)
	self._UI:setTextState(str)
end

function DialogCLayer:setTextTitle(str)
	self._UI:setTextTitle(str)
end

function DialogCLayer:getList()
	self._UI:getList()
end

function DialogCLayer:setBack(isHide)
	self._UI:setBack(isHide)
end

function DialogCLayer:setListHeight(isBiguan)
	self._UI:setListHeight(isBiguan)
end

function DialogCLayer:setDescTextVisible(isVisible)
	self._UI:setDescTextVisible(isVisible)
end

Helper:classDefNodeGetInstance(DialogCLayer)
return DialogCLayer0000000000000