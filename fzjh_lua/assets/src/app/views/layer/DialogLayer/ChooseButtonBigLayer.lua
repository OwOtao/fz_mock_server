--[[
	确定取消对话框
	常用地点： 消耗品，重置界面，拜师界面等
]]


local ChooseButtonBigLayer = class("ChooseButtonBigLayer", LayerEx)

function ChooseButtonBigLayer:create()
	local p = ChooseButtonBigLayer:new()
	p:init()
	return p
end

function ChooseButtonBigLayer:init()
	self._round = require("Layer/Dialog/ChooseButton2UI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUI(self) 
	self:setVisible(false)
	self:setPanelBack()
	self.Text_desc:setVisible(false)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 00:51:46

-- @desc 初始化页面
function ChooseButtonBigLayer:initLayer(text, ...)
	if text == nil then
		return
	end
	self:setTextDesc(text)
	self:showLayer(...)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 11:14:27
-- @desc 初始化界面用可变色文本
function ChooseButtonBigLayer:initLayerWithRichText(text, ...)
	if text == nil then
		return
	end
	self:setRichTextDesc(text)
	self:showLayer(...)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 11:15:50
-- @desc 界面显示
function ChooseButtonBigLayer:showLayer(...)
	local btn1Name, btn1Func, btn2Name, btn2Func, btn3Name, btn3Func, btn4Name, btn4Func, btn5Name, btn5Func = ... 
	self:setButton1(btn1Name, btn1Func)
	self:setButton2(btn2Name, btn2Func)
	self:setButton3(btn3Name, btn3Func)
	self:setButton4(btn4Name, btn4Func)
	self:setButton5(btn5Name, btn5Func)
	self:show()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 11:13:29
-- @desc 设置文本
function ChooseButtonBigLayer:setTextDesc(text)
	text = Helper:getDef(text, "")
	self.Text_desc:setVisible(true)
	self.Text_desc:setString(text)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:14:48
-- @desc 初始化文本框
function ChooseButtonBigLayer:initTextDesc()
	local x, y = self.Text_desc:getPosition()
	local size = self.Text_desc:getContentSize()

	if self.richText then
		self.richText:getRichText():removeAllElement()
		return
	end

	local richTextScroll = ExtRichTextScroll:create()
	self.Text_desc:getParent():addChild(richTextScroll)
	richTextScroll:move(cc.p(x, y))
   	richTextScroll:setSize(size)   	
   	richTextScroll:setDirection(kCCScrollViewDirectionVertical)
   	richTextScroll:getRichText():setVerticalSpace(5)
   	richTextScroll:setBounceEnabled(true)
	self.richText = richTextScroll
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:21:11
-- @desc 设置文本
local textColor = cc.c3b(102, 153, 153)
function ChooseButtonBigLayer:setRichTextDesc(text, verticalSpace)
	self:initTextDesc()

	self.richText:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 60)
	if verticalSpace ~= nil and type(verticalSpace) == "number" then
		self.richText:pushBackNewLine(verticalSpace)
	else
		self.richText:pushBackNewLine()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 00:52:07
-- @desc 设置按钮
function ChooseButtonBigLayer:setButtons(num, name, func)
	if num == nil then
		return
	end
	local button = self["Button_"..tostring(num)]
	local text = self["Text_name_"..tostring(num)]
	if name == nil or string.len(name) <= 0 then
		button:setVisible(false)
	else
		button:setVisible(true)
		text:setString(name)
	end

	button:releaseFunc(function()
		self:hide()
		if func then
			func()
		end
	end)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:01:54
-- @desc 设置第一个按钮
function ChooseButtonBigLayer:setButton1(name, func)
	self:setButtons("1", name, func)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:02:16
-- @desc 设置第二个按钮
function ChooseButtonBigLayer:setButton2(name, func)
	self:setButtons("2", name, func)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:02:36
-- @desc 设置第三个按钮
function ChooseButtonBigLayer:setButton3(name, func)
	self:setButtons("3", name, func)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:02:54
-- @desc 设置第四个按钮
function ChooseButtonBigLayer:setButton4(name, func)
	self:setButtons("4", name, func)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:04:11
-- @desc 设置第五个按钮
function ChooseButtonBigLayer:setButton5(name, func)
	self:setButtons("5", name, func)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/08/31 01:46:50
-- @desc 设置背景按钮点击
function ChooseButtonBigLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:setVisible(false)
	end)
end

Helper:classDefNodeGetInstance(ChooseButtonBigLayer)
return ChooseButtonBigLayer0000