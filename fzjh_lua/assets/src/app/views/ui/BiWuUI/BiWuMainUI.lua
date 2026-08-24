local Resource = require("app.Resource")
local RoleInfoLayer = require("app.views.layer.RoleLayer.RoleInfoLayer")

local BiWuMainUI = class("BiWuMainUI",cc.Layer)

function BiWuMainUI:create()
	local p = BiWuMainUI:new()
	p:init()
	return p
end


function BiWuMainUI:init()
	self._UI = require("Layer.BiWuUI.BiWuMainUI.lua").create()['root']
	self._UI:addTo(self)

	Helper:convertUIByParent(self)

	self:setVisible(true)

	self:backButton()


	--c初始化打印
	self:initRichText()
end

---------------------------------------------------------------------------------------------------------------------
-- ----打印
function BiWuMainUI:initRichText()
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

   RegisterRichPrint("BiWuWatchUIPrint", self, self.print)
end

local textColor = cc.c3b(159,159,159)
function BiWuMainUI:print(str, verticalSpace)
	local textHeight = self.RichText_print:getRichText():getNewContentSizeHeight()
	if textHeight >= 7000 then
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
---倒计时
function BiWuMainUI:setTiaoZhanTime(num,type,func)
	self.Text_Title_Tiaozhan_Time:setVisible(type)
	if not num then
		return
	end
	self.Text_Title_Tiaozhan_Time.Text_Number_People:setString(tostring(num))
	if func then
		fucn()
	end
end
----观看人数
function BiWuMainUI:setPeopleNumber(num,type,func)
	self.Text_Title_PeopleNum:setVisible(type)
	if not num then
		return
	end
	self.Text_Title_PeopleNum.Text_Number_People:setString(tostring(num))
	if func then
		fucn()
	end
end


----设置擂主名字
function BiWuMainUI:setMaster(name,type,data)
	self.Text_Name_Master:setVisible(type)
	if not name then
		return
	end

	self.Text_Name_Master.Button_Master.Text_buttonName:setString(tostring(name))
	self.Text_Name_Master.Button_Master:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		local roleInfoLayer = RoleInfoLayer:getInstance()
		roleInfoLayer:show(true)
		roleInfoLayer:setInfo(data)

	end)

end

---观看
function BiWuMainUI:setButtonWatch(str,func)
	if str ~= nil then
		self.Button_Provoke.Text_buttonName:setString(str)
	end
	self.Button_Provoke:releaseFunc(function()
		if func then
			func()
		end
	end)
end

---观看按钮名字
function BiWuMainUI:setButtonWatchName(str)
	if str ~= nil then
		self.Button_Provoke.Text_buttonName:setString(str)
	end
end


---上台
function BiWuMainUI:setButtonStage(str,func)
	-----设置上台按钮间隔时间一秒
	self.Button_Stage:setTouchInterval(2)
	self.Button_Stage:setVisible(true)
	if str ~= nil then
		self.Button_Stage.Text_buttonName:setString(str)
	end
	self.Button_Stage:releaseFunc(function()

		if func then
			func()
		end
	end)
end
---上台次数  type 为true是今天上台次数   为false 是挑战消耗元宝
function BiWuMainUI:setTimesNumber(Type,times,func)
	if type(times) == "number" then
		if Type == false then
			self.Text_Times:setVisible(false)
		else
			self.Text_Times:setVisible(true)
			self.Text_Times:setString("今天上台次数："..tostring(times))
		end
	end
	if func then
		func()
	end
end

--描述
function BiWuMainUI:setDesc(str)
	if not str then
		return
	end
	self.Text_desc:setString(tostring(str))
end


---离开
function BiWuMainUI:backButton(func)
	self.Text_Back:setTouchEnabled(true)
	self.Text_Back:releaseFunc(function()
		Audio:playEffect("fanHuiQuXiao")
		if func then
			func()
		end
	end)
end

Helper:classDefNodeGetInstance(BiWuMainUI)

return BiWuMainUI
0000000