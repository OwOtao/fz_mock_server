local DialogYuanBaoPayLayer = class("DialogYuanBaoPayLayer", cc.Layer)

function DialogYuanBaoPayLayer:create()
	local p = DialogYuanBaoPayLayer:new()
	p:init()
	return p
end

function DialogYuanBaoPayLayer:init()
	self._UI = require("Layer/PayUI/YuanBaoPayUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
end

function DialogYuanBaoPayLayer:showLayer()
    self:show()
end

function DialogYuanBaoPayLayer:setTiTleText(text)
    self.Text_title:setString(text)
end

function DialogYuanBaoPayLayer:setDesc(desc)
    self.Text_desc:setTextVerticalAlignment(1)
    self.Text_desc:setString(desc)
end

function DialogYuanBaoPayLayer:setPrice(price)
    self.Text_price:setString(price)
end

function DialogYuanBaoPayLayer:setTextTitle1(text)
    self.Text_title_1:setString(text)
end

function DialogYuanBaoPayLayer:setButton1(name, func)
	self.Button_pay.Text_button_1Name:setString(name)
	self.Button_pay:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:hide()
		if func then
			func()
		end
	end)
end

function DialogYuanBaoPayLayer:setButton2(name, func)
	self.Button_cancel.Text_button_2Name:setString(name)
	self.Button_cancel:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:hide()
		if func then
			func()
		end
	end)
end

function DialogYuanBaoPayLayer:setTextTitle1IsVisible(bool)
    self.Text_title_1:setVisible(bool)
end

function DialogYuanBaoPayLayer:setTextItemNameIsVisible(bool)
    self.Text_itemName:setVisible(bool)
end

function DialogYuanBaoPayLayer:setImageItemIconIsVisible(bool)
    self.Image_itemIcon:setVisible(bool)
end

Helper:classDefNodeGetInstance(DialogYuanBaoPayLayer)
return DialogYuanBaoPayLayer00