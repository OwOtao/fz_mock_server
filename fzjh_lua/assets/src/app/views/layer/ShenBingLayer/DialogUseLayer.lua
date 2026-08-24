local DialogUseLayer = class("DialogUseLayer", cc.Layer)

function DialogUseLayer:create()
	local p = DialogUseLayer:new()
	p:init()
	return p
end

function DialogUseLayer:init()
	self._round = require("Layer/ShenBing/DialogUseUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
	self:setButton1()
	self:setButton2()
	self:setVisible(true)
end

function  DialogUseLayer:setButton1(func)
	self.Button_1:releaseFunc(function()
	if func then
		func()
	end
	PopupLayerController:hideLayer("DialogUseLayer", function(layer)
		self:hide()
	end)
end)
end

function DialogUseLayer:setButton2(func)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
		PopupLayerController:hideLayer("DialogUseLayer", function(layer)
			self:hide()
		end)
	end)
end
function DialogUseLayer:setTitle(str)
	self.Text_text:setString(str)
end
function DialogUseLayer:setTextUseGoods(str)
	self.Text_Use_Goods:setString(str)
end

-- 设置描述文本
function DialogUseLayer:setTextDesc(str)
	if str == nil then
		self.Text_desc:setVisible(false)
	else
		self.Text_desc:setVisible(true)
	end
	self.Text_desc:setString(str)
end

Helper:classDefNodeGetInstance(DialogUseLayer)
return DialogUseLayer00000000000000