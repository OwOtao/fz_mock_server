local MeridianSkillInfoUI = class("MeridianSkillInfoUI", LayerEx)

function MeridianSkillInfoUI:create()
	local p = MeridianSkillInfoUI:new()
	p:init()
	return p
end

function MeridianSkillInfoUI:init()
	local Ui = require("Layer/SkillUI/MeridianSkillInfoUI.lua").create()['root']
	Ui:addTo(self)
	
	Helper:convertUIByParent(self) -- 获得所有子节点
end

function MeridianSkillInfoUI:showUI()
	self:show()
end

function MeridianSkillInfoUI:hideUI()
	self:hide()
end

function MeridianSkillInfoUI:showLayer()
	self:showUI()
end

function MeridianSkillInfoUI:setBackFunc(func)
	self.Panel_back:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function MeridianSkillInfoUI:setSkillExpDesc(dsc)
	self.Panel_1.Image_infoArea.Text_expDsc:setString(dsc)
end

function MeridianSkillInfoUI:setSkillSkillDesc(desc)
	self.Panel_1.Image_infoArea.Text_detailDsc:setString(desc)
end

function MeridianSkillInfoUI:setSkillName(name)
	self.Panel_1.Image_infoArea.Text_title:setString(name)
end

function MeridianSkillInfoUI:initRichText1()
	if self.RichText_Print1 then
		self.RichText_Print1:getRichText():removeFromParent()
	end
	
	local x, y = self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc:getPosition()
	local size = self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc:getContentSize()
	
	self.RichText_Print1 = ExtRichTextScroll:create()
	self.RichText_Print1:setAnchorPoint( 0.5 , 0.5 )
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailDsc:getParent():addChild(self.RichText_Print1)
	self.RichText_Print1:move(cc.p(x, y))
	self.RichText_Print1:setSize(size)
	self.RichText_Print1:setVerticalSpace(8)
	self.RichText_Print1:setDirection(kCCScrollViewDirectionVertical)
end

function MeridianSkillInfoUI:initRichText2()
	if self.RichText_Print2 then
		self.RichText_Print2:getRichText():removeFromParent()
	end
	
	local x, y = self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc:getPosition()
	local size = self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc:getContentSize()
	
	self.RichText_Print2 = ExtRichTextScroll:create()
	self.RichText_Print2:setAnchorPoint( 0.5 , 0.5 )
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailDsc:getParent():addChild(self.RichText_Print2)
	self.RichText_Print2:move(cc.p(x, y))
	self.RichText_Print2:setSize(size)
	self.RichText_Print2:setVerticalSpace(8)
	self.RichText_Print2:setDirection(kCCScrollViewDirectionVertical)
end

function MeridianSkillInfoUI:initPanelItem1(itemInfo)
	self.Panel_1.Image_infoArea.Panel_item_1.Text_detailTitle:setString(itemInfo.title)

    self:initRichText1()
	self.RichText_Print1:getRichText():removeAllElement()
    self.RichText_Print1:pushBackText(itemInfo.desc, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 36)
	self.RichText_Print1:setTouchEnabled(false)
	self:delayFunc(0.1,function ()
		self.RichText_Print1:jumpToTop()
	end)
end

function MeridianSkillInfoUI:initPanelItem2(itemInfo)
	self.Panel_1.Image_infoArea.Panel_item_2.Text_detailTitle:setString(itemInfo.title)

    self:initRichText2()
	self.RichText_Print2:getRichText():removeAllElement()
    self.RichText_Print2:pushBackText(itemInfo.desc, cc.c3b(255, 255, 255), 255, Resource:getFontPath("default"), 36)
	self.RichText_Print2:setTouchEnabled(false)
	self:delayFunc(0.1,function ()
		self.RichText_Print2:jumpToTop()
	end)
end

function MeridianSkillInfoUI:setPanelItem2Visible(visible)
	self.Panel_1.Image_infoArea.Panel_item_2:setVisible(visible)
end

Helper:classDefNodeGetInstance(MeridianSkillInfoUI)
return MeridianSkillInfoUI000000000