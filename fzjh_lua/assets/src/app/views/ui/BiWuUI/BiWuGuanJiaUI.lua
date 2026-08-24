local Resource = require("app.Resource")
local BiWu = require("app.models.BiWu.BiWu")


local BiWuGuanJiaUI = class("BiWuGuanJiaUI",cc.Layer)
function BiWuGuanJiaUI:create()
	local p = BiWuGuanJiaUI:new()
	p:init()
	return p
end

function BiWuGuanJiaUI:init()
	self._UI = require("Layer.BiWuUI.BiWuGuanJiaUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)


	self:initRichText()
	local str = BiWu:getwuguanguanjiaDesc()
	self:print(str)


	---点击背景隐藏自己
	self.Panel_back:releaseFunc(function ()
		self:hide()
	end)
end

function BiWuGuanJiaUI:show()
	self:setVisible(true)
end

local guanjia = 
{
	name = "武馆管家",
	desc = "这是武馆管家"
}

---------------------------------------------------------------------------------------------------------------------
-- ----打印
function BiWuGuanJiaUI:initRichText()
	local x, y = self.Panel_attr.Panel_Desc:getPosition()
	local size = self.Panel_attr.Panel_Desc:getContentSize()
	
	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Panel_attr.Panel_Desc:getParent():addChild(richTextScroll)
   	richTextScroll:move(cc.p(90,730))
   	richTextScroll:setSize(size)   	
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(false)

end

local textColor = cc.c3b(159,159,159)
function BiWuGuanJiaUI:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 4000 then
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
--交谈
function BiWuGuanJiaUI:setButtonTalk(str,func)
	if str then
		local str = tostring(str)
		self.Panel_attr.Button_Talk.Text_TalkName:setString(str)
	end
	self.Panel_attr.Button_Talk:releaseFunc(function()
		Audio:playEffect("nianLaoZhengNan")
		if func then
			func()
		end
		self:hide()
	end)
end

--送礼
function BiWuGuanJiaUI:setButtonpresent(str,func)
	if str then
		local str = tostring(str)
		self.Panel_attr.Button_Present.Text_PresentName:setString(str)
	end
	self.Panel_attr.Button_Present:releaseFunc(function()
		if func then
			func()
		end
		self:hide()
	end)
end


--挑战纪录
function BiWuGuanJiaUI:setButtonTiaoZhan(str,func)
	if str then
		local str = tostring(str)
		self.Panel_attr.Button_TiaoZhan.Text_TiaoZhanName:setString(str)
	end
	self.Panel_attr.Button_TiaoZhan:releaseFunc(function ()
		if func then
			func()
		end
		self:hide()
	end)
end

----规则
function BiWuGuanJiaUI:setButtonRule( func )
	self.Panel_attr.Button_Rule:releaseFunc(function ()
		if func then
			func()
		end
	end)
end

Helper:classDefNodeGetInstance(BiWuGuanJiaUI)
return BiWuGuanJiaUI0000000000000