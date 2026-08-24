local Resource = require("app.Resource")

local BiWuWatchUI = class("BiWuWatchUI",cc.Layer)

function BiWuWatchUI:create()
	local p = BiWuWatchUI:new()
	p:init()
	return p
end


function BiWuWatchUI:init()
	self._UI = require("Layer.BiWuUI.BiWuWatchUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setVisible(true)

	--c初始化打印
	self:initRichText()
end

---------------------------------------------------------------------------------------------------------------------
-- ----打印
function BiWuWatchUI:initRichText()
	local x, y = self.Image_help.Panel_talk:getPosition()
	local size = self.Image_help.Panel_talk:getContentSize()
	
	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
	richTextScroll:setAnchorPoint( 0.5 , 0.5 )
   	self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
   	local point = cc.p(self.Image_help.Panel_talk:getPosition())
   	richTextScroll:move(point)
   	richTextScroll:setSize(size)   	
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)
end

local textColor = cc.c3b(159,159,159)
function BiWuWatchUI:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6666 then
		self:initRichText()
	end

	self.RichText_print:pushBackText(str, textColor, 255, Resource:getFontPath("default"), 42)

	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.RichText_print:pushBackNewLine(verticalSpace)
	else
		self.RichText_print:pushBackNewLine()
	end
end

-----------------------------------------------------------------------------------
--设置精力
function BiWuWatchUI:setTextJingLi(str)
	if str then
		self.Text_JingLi:setString("『潜能』"..tostring(str))
	end
end

--设置金钱
function BiWuWatchUI:setTextMoney(str)
	if str then
		self.Text_money:setString("『碎银』"..tostring(str))
	end
end

---退出按钮
function BiWuWatchUI:setButtonBack(func)
	self.Button_Back:releaseFunc(function()
		if func then
			func()
		end
		Audio:playEffect("fanHuiQuXiao")
	end)
end

---取消观战
function BiWuWatchUI:setButtonCancelWatch(func)
	self.Button_Cancel_Watch:releaseFunc(function()
		if func then
			func()
		end
		Audio:playEffect("xiaoAnNiu")
	end)
end

---描述
function BiWuWatchUI:setDesc(str)
	if not str then
	else
		self.Text_desc:setString(str)
	end
end

Helper:classDefNodeGetInstance(BiWuWatchUI)

return BiWuWatchUI000000000000000