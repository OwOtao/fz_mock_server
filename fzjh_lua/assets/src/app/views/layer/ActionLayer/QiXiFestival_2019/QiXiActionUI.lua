

local QiXiActionUI = class("QiXiActionUI", cc.Layer)

function QiXiActionUI:create()
	local p = QiXiActionUI:new()
	p:init()
	return p
end

function QiXiActionUI:init()
	self._round = require("Layer/ActionUI/QiXiActionUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点

	self.rich_text = nil

	self:initRichText()
end

function QiXiActionUI:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.Text_desc:getPosition()
	local size = self.Text_desc:getContentSize()
	size.width = size.width + 30

    self.rich_text = ExtRichTextScroll:create()

    self.Text_desc:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.5, 0.5))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(20)
end

function QiXiActionUI:show()
	self:setVisible(true)
end

function QiXiActionUI:hide()
	self:setVisible(false)
end

function QiXiActionUI:setRichText(desc)
	self.Text_desc:setString("")
	self:initRichText()

	local textColor = cc.c3b(208, 208, 208)
	self.rich_text:pushBackText(desc, textColor, 255, Resource:getFontPath("default"), 42)
	
	self:delayFunc(0.03,function ()
		self.rich_text:jumpToTop()
	end)
end

function QiXiActionUI:setButton(name, title, func)
	if not name then
		return
	end

	if not title then
		self[name]:setVisible(false)
	else
		self[name]:setVisible(true)
		self[name].Text_buttonName:setString(title)
	end

	self[name]:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function QiXiActionUI:setButton1(title, func)
	self:setButton("Button_1", title, func)
end

function QiXiActionUI:setButton2(title, func)
	self:setButton("Button_2", title, func)
end

function QiXiActionUI:setButton3(title, func)
	self:setButton("Button_3", title, func)
end

function QiXiActionUI:setTitleName(titleName)
	if titleName == nil then
		return
	end

	self.Text_title:setString(titleName)
end

function QiXiActionUI:setHongDianVisible(visible)
	self.Image_hongdian:setVisible(visible)
end

return QiXiActionUI00000000