local DialogKLayer = class("DialogKLayer", cc.Layer)

function DialogKLayer:create()
	local p = DialogKLayer:new()
	p:init()
	return p
end

function DialogKLayer:init()
	self._round = require("Layer/Dialog/Dialog15UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self)
	self:setVisible(false)
	self:initRichTextItem()
end

function DialogKLayer:initRichTextItem()
	if self.RichText_Print then
		self.RichText_Print:getRichText():removeFromParent()
	end
	
	local x, y = self.Image_back.Text_desc:getPosition()
	local size = self.Image_back.Text_desc:getContentSize()
	
	self.RichText_Print = ExtRichTextScroll:create()
	self.RichText_Print:setAnchorPoint( 0.5 , 0.5 )
	self:addChild(self.RichText_Print)
	self.RichText_Print:move(cc.p(x, y+360))
	self.RichText_Print:setSize(size)
	self.RichText_Print:setVerticalSpace(5)
	self.RichText_Print:setDirection(kCCScrollViewDirectionVertical)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/26 14:21:59
-- @desc 
local textColor = cc.c3b(102, 153, 153)
function DialogKLayer:initRichText(str)
	if self.RichText_Print then
		self.RichText_Print:getRichText():removeAllElement()
	end
   	self.RichText_Print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)
	self.RichText_Print:setTouchEnabled(true)
	self:delayFunc(0.1,function ()
		self.RichText_Print:jumpToTop()
		self.Panel_back:setTouchEnabled(true)
		self.canBack = true
	end)
end
function DialogKLayer:setText(str)
	self:initRichText(str)
end

function DialogKLayer:showLayer(title,desc,func)
	self:show()
	self.Image_back.Text_title:setString(title)
	self:setText(desc)
	self:setBack(func)
	self.canBack = false
end


function DialogKLayer:setBack(func)
	self.Panel_back:releaseFunc(function()
		if self.canBack == true then
			if func then
				func()
			end
			self:hide()
		end
	end)
end

Helper:classDefNodeGetInstance(DialogKLayer)
return DialogKLayer00000000