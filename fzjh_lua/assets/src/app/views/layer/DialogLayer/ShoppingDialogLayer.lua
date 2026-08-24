--[[
	在商人处购物二次确认界面，黑商，小贩，冥商
]]

local ShoppingDialogUI = require("app.views.ui.Dialog.ShoppingDialogUI")

local ShoppingDialogLayer = class("ShoppingDialogLayer", cc.Layer)

function ShoppingDialogLayer:create()
	local p = ShoppingDialogLayer:new()
	p:init()
	return p
end

function ShoppingDialogLayer:init()
	self._UI = ShoppingDialogUI:create()
	self._UI:addTo(self)
end

--[[textList = {
    Text_tital = "",
    Text_type = "",
    Text_dsc = "",
    Text_price = "",
    Text_affirm = "",
    Text_havenum = "",
}]]
function ShoppingDialogLayer:showLayer(textList, func)
	self:maxZ()
	self._UI:initRichText()
	self._UI:show(textList, func)

	self._UI.Button_batchBuy:setVisible(false)
end

function ShoppingDialogLayer:setRichText(text)
	self._UI:setRichText(text)
end

function ShoppingDialogLayer:hide()
	self._UI:hide()
end

function ShoppingDialogLayer:setButton_confirm(title, func)
	self._UI:setButton("Button_confirm", title, func)
end

function ShoppingDialogLayer:setButton_close(title, func)
	self._UI:setButton("Button_close", title, func)
end

function ShoppingDialogLayer:setButton_batchBuy(title, func)
	self._UI.Button_batchBuy:setVisible(true)
	self._UI:setButton("Button_batchBuy", title, func)
end

--是否显示打折页面
function ShoppingDialogLayer:isShowDiscountLayer(boolean)
	self._UI:isShowDiscountLayer(boolean)
end

Helper:classDefNodeGetInstance(ShoppingDialogLayer)
return ShoppingDialogLayer00