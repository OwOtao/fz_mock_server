local Resource = require("app.Resource")


local BiWuStartUI = class("BiWuStartUI",cc.Layer)

function BiWuStartUI:create()
	local BiWuStartLayer = BiWuStartUI:new()
	BiWuStartLayer:init()
	return BiWuStartLayer
end




function BiWuStartUI:init()
	self._UI = require("Layer.BiWuUI.BiWuStartUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)
		
	self:initRichText()
end

function BiWuStartUI:show()
	self:setVisible(true)
end

--描述
function BiWuStartUI:setDesc(str,func)
	local str = tostring(str)
	self.Text_desc:setString(str)
	if func then
		func()
	end
end

--武馆老管家的按钮
function BiWuStartUI:setButtonWuGuanGuanJia(str,func)
	if str then
		local str = tostring(str)
		self.Button_WuGuanGuanJia.Text_buttonName:setString(str)
	end
	self.Button_WuGuanGuanJia:releaseFunc(function ()
		Audio:playEffect("nianLaoZhengNan")
		if func then
			func()
		end
	end)

end

--公告
function BiWuStartUI:setButtonNotice(str,func)
	if str then
		local str = tostring(str)
		self.Button_Notice.Text_buttonName:setString(str)
	end
	self.Button_Notice:releaseFunc(function ()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end

--人气榜
function BiWuStartUI:setButtonPeople(str,func)
	if str then
		local str = tostring(str)
		self.Button_People.Text_buttonName:setString(str)
	end
	self.Button_People:releaseFunc(function ()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end
--本周人气值
function BiWuStartUI:setWeekRenQi(str,func)
	if str then
		local str = tostring(str)
		self.Text_Week_RenQi:setString("本周人气值："..str)
	end
	self.Text_Week_RenQi:releaseFunc(function ()
		Audio:playEffect("xiaoAnNiu")
		if func then
			func()
		end
	end)
end


--入场
function BiWuStartUI:setButtonExit(str,func)
	if str then
		local str = tostring(str)
		self.Button_Exit.Text_buttonName:setString(str)
	end
	self.Button_Exit:releaseFunc(function ()
		if func then
			func()
		end
		Audio:playEffect("xiaoAnNiu")
	end)
end


---------------------------------------------------------------------------------------------------------------------
-- ----打印
function BiWuStartUI:initRichText()
	local x, y = self.Image_help.Panel_talk:getPosition()
	local size = self.Image_help.Panel_talk:getContentSize()

	if self.RichText_print then
		self.RichText_print:removeFromParent()
		self.RichText_print = nil
	end

	local richTextScroll = ExtRichTextScroll:create()
   	self.Image_help.Panel_talk:getParent():addChild(richTextScroll)
   	richTextScroll:move(cc.p(27, 22))
   	richTextScroll:setSize(size)   	
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	self.RichText_print = richTextScroll

   	self.RichText_print:setBounceEnabled(true)

   	-- self.RichText_print:setVerticalSpace(-5)

	-- self:print("HIY【HIB江HIM湖HIC通HIW告RAN】:RED欢GRN迎YEL来BLU到MAG天CYN下WHT第HIR一HIG.")
	-- self:print("测试")
end
local textColor = cc.c3b(102, 153, 153)
function BiWuStartUI:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 6888 then
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

Helper:classDefNodeGetInstance(BiWuStartUI)

return BiWuStartUI000000000000