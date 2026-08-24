-- 文本弹出窗口
local TextPopLayer = class("TextPopLayer", LayerEx)

function TextPopLayer:create()
	local p = TextPopLayer:new()
	p:init()
	return p
end

function TextPopLayer:init()
	self._UI = require("Layer/PopUI/TextPopUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
	self:setShowAndHideAnimType("ROLL")

	self:setBack()
end

-- 初始化输出框
function TextPopLayer:initRichText()
	local x, y = self.ListView_titlelistArea:getPosition()
	local size = self.ListView_titlelistArea:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.ListView_titlelistArea:getParent():addChild(richTextScroll)
   	local point = cc.p(self.ListView_titlelistArea:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)
   	richTextScroll:setDirection(kCCTableViewFillBottomUp)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

function TextPopLayer:showLayer(title, strs, textSize)
	if textSize == nil then
		textSize = 48
	end

	self:initRichText()
	local textColor = cc.c3b(159,159,159)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()

	for i,v in ipairs(strs) do
		self.RichText_print:pushBackText(v, textColor, 255, Resource:getFontPath("default"), textSize)
		self.RichText_print:pushBackNewLine(30)
	end
	
	--@desc 确保文本输出过长的时，显示后列表依然在顶部
	self:delayFunc(0.4,function ()
		self.RichText_print:jumpToTop()
	end)

	self.Text_title:setString(title)
	self:show()
end

function TextPopLayer:setBack()
	self.Panel_back:releaseFunc(function()
		PopupLayerController:hideLayer("TextPopLayer", function(layer)
			self:hide()
		end)
	end)
end

Helper:classDefNodeGetInstance(TextPopLayer)

return TextPopLayer000000