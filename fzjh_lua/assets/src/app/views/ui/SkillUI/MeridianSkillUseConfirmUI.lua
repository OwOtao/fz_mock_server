local MeridianSkillUseConfirmUI = class("MeridianSkillUseConfirmUI", LayerEx)

function MeridianSkillUseConfirmUI:create()
	local p = MeridianSkillUseConfirmUI:new()
	p:init()
	return p
end

function MeridianSkillUseConfirmUI:init()
	local Ui = require("Layer/SkillUI/MeridianSkillUseConfirmUI.lua").create()['root']
	Ui:addTo(self)
	
	Helper:convertUIByParent(self) -- 获得所有子节点
end

function MeridianSkillUseConfirmUI:showUI()
	self:show()
end

function MeridianSkillUseConfirmUI:hideUI()
	self:hide()
end

function MeridianSkillUseConfirmUI:showLayer()
	self:showUI()
end

function MeridianSkillUseConfirmUI:setButton1(name,func)
    self.Button_1.Text_ButtonName:setString(name)
	self.Button_1:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function MeridianSkillUseConfirmUI:setButton2(name,func)
    self.Button_2.Text_ButtonName:setString(name)
	self.Button_2:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function MeridianSkillUseConfirmUI:initRichText()
	if self.RichText_Print then
		self.RichText_Print:getRichText():removeFromParent()
	end
	
	local x, y = self.Text_desc:getPosition()
	local size = self.Text_desc:getContentSize()
	
	self.RichText_Print = ExtRichTextScroll:create()
	self.RichText_Print:setAnchorPoint( 0.5 , 0.5 )
	self.Text_desc:getParent():addChild(self.RichText_Print)
	self.RichText_Print:move(cc.p(x, y))
	self.RichText_Print:setSize(size)
	self.RichText_Print:setVerticalSpace(8)
	self.RichText_Print:setDirection(kCCScrollViewDirectionVertical)
end

function MeridianSkillUseConfirmUI:setTextDesc(text)
    self:initRichText()
	self.RichText_Print:getRichText():removeAllElement()
    self.RichText_Print:pushBackText(text, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 50)
	self.RichText_Print:setTouchEnabled(false)
	self:delayFunc(0.1,function ()
		self.RichText_Print:jumpToTop()
	end)
end

function MeridianSkillUseConfirmUI:setTextBreathVal(text)
	self.Text_breathVal:setString(text)
end

function MeridianSkillUseConfirmUI:setTextUseTime(text)
	self.Text_useTime:setString(text)
end

function MeridianSkillUseConfirmUI:setTextResetTime(text)
	self.Text_resetTime:setString(text)
end

Helper:classDefNodeGetInstance(MeridianSkillUseConfirmUI)
return MeridianSkillUseConfirmUI0