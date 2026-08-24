local TextPopLayer = class("TextPopLayer", cc.Layer)

function TextPopLayer:create()
	local p = TextPopLayer:new()
	p:init()
	return p
end

function TextPopLayer:init()
	self._round = require("Layer/Dialog/TextPopUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self)
	self:setVisible(false)
	self:initRichTextItem()
end

function TextPopLayer:initRichTextItem()
	if self.RichText_Print then
		self.RichText_Print:getRichText():removeFromParent()
	end
	
	local x, y = self.Image_back.Text_desc:getPosition()
	local size = self.Image_back.Text_desc:getContentSize()
	
	self.RichText_Print = ExtRichTextScroll:create()
	self.RichText_Print:setAnchorPoint( 0.5 , 0.5 )
	self.Image_back.Text_desc:getParent():addChild(self.RichText_Print)
	self.RichText_Print:move(cc.p(x, y))
	self.RichText_Print:setSize(size)
	self.RichText_Print:setVerticalSpace(8)
	self.RichText_Print:setDirection(kCCScrollViewDirectionVertical)
end

local textColor = cc.c3b(174, 174, 174)
function TextPopLayer:initRichText(str)
	if self.RichText_Print then
		self.RichText_Print:getRichText():removeAllElement()
	end
   	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 40)
	self.RichText_Print:setTouchEnabled(true)
	self:delayFunc(0.1,function ()
		self.RichText_Print:jumpToTop()
		self.Panel_back:setTouchEnabled(true)
		self.canBack = true
	end)
end
function TextPopLayer:setText(str)
	self:initRichText(str)
end

function TextPopLayer:showLayer(title,desc,func)
	self:show()
	self.canBack = false
	self.Image_back.Text_title:setString(title)
	self:setText(desc)
	self:setBack(func)
end


function TextPopLayer:setBack(func)
	self.Image_back.Button_close:releaseFunc(function()
		if self.canBack == true then
			Audio:playEffect("xiaoAnNiu")
			if func then
				func()
			end
			self:hide()
		end
	end)
end

Helper:classDefNodeGetInstance(TextPopLayer)
return TextPopLayer00000000000