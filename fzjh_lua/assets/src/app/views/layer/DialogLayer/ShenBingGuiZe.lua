local ShenBingGuiZe = class("ShenBingGuiZe", cc.Layer)

function ShenBingGuiZe:create()
	local p = ShenBingGuiZe:new()
	p:init()
	return p
end

function ShenBingGuiZe:init()
	self._round = require("Layer/Dialog/ShenBingGuiZeUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self)
	self:setVisible(false)
	-- self:initRichTextItem()
end

function ShenBingGuiZe:initRichTextItem()
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
	self.RichText_Print:setDirection(kCCScrollViewDirectionVertical)
end

-----------------------------------------------------------------------------------------------------------
-- @author GaoHanZheng
-- @time 2018/01/26 14:21:59
-- @desc 
local textColor = cc.c3b(102, 153, 153)
function ShenBingGuiZe:initRichText(str)
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
function ShenBingGuiZe:setText(str)
	-- self:initRichText(str)
		self.Panel_back:setTouchEnabled(true)
		self.canBack = true
	self.Image_back.Text_desc:setString(str)
end

function ShenBingGuiZe:showLayer(title,desc,func)
	self:show()
	self.Image_back.Text_title:setString(title)
	self:setText(desc)
	self:setBack(func)
	-- self.canBack = false
end


function ShenBingGuiZe:setBack(func)
	self.Panel_back:releaseFunc(function()
		print("--------------------------------------------------")
		if self.canBack == true then
			if func then
				func()
			end
			self:hide()
		end
	end)
end

Helper:classDefNodeGetInstance(ShenBingGuiZe)
return ShenBingGuiZe00000000000000