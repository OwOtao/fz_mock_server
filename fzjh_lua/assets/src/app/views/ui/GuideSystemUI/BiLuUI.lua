local BiLuUI = class("BiLuUI", cc.Layer)

function BiLuUI:create()
    local p = BiLuUI:new()
    p:init()
    return p
end

function BiLuUI:init()
	local UI = require("Layer/GuideSystemUI/BiLuUI.lua").create()['root']
	UI:addTo(self)
	Helper:convertUIByParent(self)
	
    self:hide()
end

function BiLuUI:showUI()
	self:show()
end

function BiLuUI:hideUI()
	self:hide()
end

function BiLuUI:initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

	self.Text_4:setVisible(false)

    local x, y = self.Text_4:getPosition()
    local size = self.Text_4:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Text_4:getParent():addChild(self.RichText_print)
    self.RichText_print:setPosition(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end

function BiLuUI:setButtonBackFunc(func)
	self.Button_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function BiLuUI:setTitleName(name)
    name = Helper:getDef(name,"")
	self.Text_title:setString(name)
end

function BiLuUI:setTitle_1Text(text)
    text = Helper:getDef(text,"")
	self.Text_1:setString(text)
end

function BiLuUI:setTitle_2Text(text)
    text = Helper:getDef(text,"")
	self.Text_2:setString(text)
end

function BiLuUI:setTitle_3Text(text)
    text = Helper:getDef(text,"")
	self.Text_3:setString(text)
end

function BiLuUI:setTitle_4Text(text)
    text = Helper:getDef(text,"")
	self:initRichText()

    local textColor = cc.c3b(255, 255, 255)
    self.RichText_print:pushBackText(text, textColor, 255, Resource:getFontPath("default"),50)

	self:delayFunc(0.2,function ()
		self.RichText_print:jumpToTop()
	end)
end

function BiLuUI:setTitle_5Text(text)
    text = Helper:getDef(text,"")
	self.Text_5:setString(text)
end

function BiLuUI:setButton_1Visible(visible)
    visible = Helper:getDef(visible,false)
	self.Button_1:setVisible(visible)
end

function BiLuUI:setButton_2Visible(visible)
    visible = Helper:getDef(visible,false)
	self.Button_2:setVisible(visible)
end

function BiLuUI:setButton_1Name(name)
    name = Helper:getDef(name,"")
	self.Button_1.Text_btn:setString(name)
end

function BiLuUI:setButton_2Name(name)
    name = Helper:getDef(name,"")
	self.Button_2.Text_btn:setString(name)
end

function BiLuUI:setButton_1Func(func)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function BiLuUI:setButton_2Func(func)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

Helper:classDefNodeGetInstance(BiLuUI)

return BiLuUI

0000000000000000