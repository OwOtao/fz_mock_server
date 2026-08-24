local BaseUI = require("app.FightSystem.UICtrl.UI.BaseUI")
local NewClass = require("third.class.NewClass")
--@SuperType [src.app.FightSystem.UICtrl.UI.BaseUI#BaseUI]
local PrintAreaUI = {}

local RECORD_FIGHT_STATUS_STRING_LINE_MAX = 50

function PrintAreaUI:onInit()
    self:addRichText()
end

function PrintAreaUI:onDestroy()
end
 
function PrintAreaUI:onUpdate(ft)
end

function PrintAreaUI:addRichText()
    self.richPrint = self:getNode():getChildByName("printPanel")

    if not self.richPrint then
        self.richPrint = ExtRichTextScroll:create()
        self:getNode():addChild(self.richPrint)
        self.richPrint:setName("printPanel")
        
        local size = self.Text_print:getContentSize()
        local x, y = self.Text_print:getPosition()
        
        self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
        self.richPrint:setSize(size)
        self.richPrint:setScrollBarEnabled(false)
        self.richPrint:getRichText():setVerticalSpace(5)
        
        -- 设置最大显示高度
        self.richPrint:setTextMaxHeight(size.height)
        
        -- 记录文本, 用作战斗结束回顾
        self.richPrint.fightStatusStringArray = {}
        
        self.richPrint.scheduleHandle = self:getNode():scheduleUnique(function(elapsed)
            self.richPrint:scrollToBottom(0, false)
            self.richPrint:jumpToBottom()
        end, 0, "self.richPrint:setPosition")
    end
end

local textColor = cc.c3b(159, 159, 159)-- 战斗输出默认文字颜色
local textFont = nil
function PrintAreaUI:print(str)
	str = tostring(str)
	
	if textFont == nil then
		textFont = Resource:getFontPath("default")
	end
	
	-- 记录战斗字符串
	if self.richPrint.fightStatusStringArray then
		if #self.richPrint.fightStatusStringArray >= RECORD_FIGHT_STATUS_STRING_LINE_MAX then -- 长度超过上限, 需要移除老的记录
			table.remove(self.richPrint.fightStatusStringArray, 1)
		end
		table.insert(self.richPrint.fightStatusStringArray, str .. "NOR\n")
	end
	
	self.richPrint:pushBackText(str, textColor, 255, textFont, 42)
	self.richPrint:pushBackNewLine(0)
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 16:55:52
-- @desc 得到战斗状态字符串
function PrintAreaUI:getFightStatusString()
	local maxLine = RECORD_FIGHT_STATUS_STRING_LINE_MAX
	if type(self.richPrint.fightStatusStringArray) == "table" then
		if #self.richPrint.fightStatusStringArray > maxLine then
			local from, to = Helper:getRange(#self.richPrint.fightStatusStringArray - maxLine, 0, maxLine), #self.richPrint.fightStatusStringArray
			return table.concat(self.richPrint.fightStatusStringArray, nil, from, to)
		else
			return table.concat(self.richPrint.fightStatusStringArray)
		end
	else
		return ""
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/11/23 17:08:12
-- @desc 富文本中显示战斗所有文本
function PrintAreaUI:richTextShowAllFightStatusString()
	local fightStatusString = self:getFightStatusString()
	local scheduleHandle = self.richPrint.scheduleHandle
	
	if self.richPrint then
		self.richPrint:removeFromParent()
		self.richPrint = nil
	end
	self.Image_print.Text_print:setVisible(false)
	self.richPrint = ExtRichTextScroll:create()
	self.Image_print:addChild(self.richPrint)
	
	local size = self.Image_print.Text_print:getContentSize()
	local x, y = self.Image_print.Text_print:getPosition()
	
	-- 设置richtext位置到self.Image_2.Text_1中心位置
	self.richPrint:setPosition(cc.p(x - size.width / 2, y - size.height / 2))
	self.richPrint:setSize(size)
	self.richPrint:getRichText():setVerticalSpace(5)
	
	-- 设置最大显示高度
	self.richPrint:setTextMaxHeight(9999999999)
	
	self:print(fightStatusString)
	
	self:getNode():delayFunc(0.1, function()
		self:getNode():unschedule(scheduleHandle)
	end)
end

return NewClass("PrintAreaUI", {BaseUI}, PrintAreaUI)
0000000000000