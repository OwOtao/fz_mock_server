local PopWindowsLayer = class("PopWindowsLayer", LayerEx)

function PopWindowsLayer:create()
	local p = PopWindowsLayer:new()
	p:init()
	return p
end

function PopWindowsLayer:init()
	local UI = require("Layer/Dialog/PopWindowsUI.lua").create()["root"]
	UI:addTo(self)

	Helper:convertUIByParent(self)
end

-- title 按钮名
-- 按钮执行函数
-- text 弹窗展示文本
-- canHide 点击背景能否关闭
function PopWindowsLayer:showLayer(title,text,canHide,func)
	self:setBack(canHide)
    self:setVisible(true)
    self:setButton(title,func)
    self:setText(text)
end

function PopWindowsLayer:hide()
	PopupLayerController:hideLayer("PopWindowsLayer", function(layer)
		self:setVisible(false)
	end)
end

function PopWindowsLayer:setBack(canHide)
    self.Panel_back:releaseFunc(function()
        if canHide == true then
            self:hide()
        end
	end)
end

function PopWindowsLayer:setButton(title, func)
	if not title then
		self.Button_1:setVisible(false)
	else
		self.Button_1:setVisible(true)
		self.Button_1.Text_buttonName:setString(title)
	end

	self.Button_1:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:hide()
		if func then
			func()
		end
	end)
end

function PopWindowsLayer:setText(text)
    if text == nil or text == "" then
		self.Text_desc2:setVisible(false)
	else
		self.Text_desc2:setVisible(true)
		self.Text_desc2:setString(text)
	end
end

Helper:classDefNodeGetInstance(PopWindowsLayer)

return PopWindowsLayer
00000000000000