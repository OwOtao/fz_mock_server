

local DialogUI = class("DialogUI", cc.Layer)

function DialogUI:create()
	local p = DialogUI:new()
	p:init()
	return p
end

function DialogUI:init()
	self._round = require("Layer/Dialog/DialogUI.lua").create()['root']
	self._round:addTo(self)

	Helper:convertUIByParent(self) -- 获得所有子节点

	self.rich_text = nil
	if Game:isOpenWeiXinShare() == true then
		self.Image_weixin:setVisible(true)
		self:setWeiXinShared()
	else
		self.Image_weixin:setVisible(false)	
	end
	self:initRichText()
end

function DialogUI:initRichText()
	if self.rich_text ~= nil then
        self.rich_text:removeFromParent()
	end

	local x, y = self.Text_text:getPosition()
    local size = self.Text_text:getContentSize()

    self.rich_text = ExtRichTextScroll:create()

    self.Text_text:getParent():addChild(self.rich_text)
    self.rich_text:move(cc.p(x, y))
    self.rich_text:setSize(size)
    self.rich_text:setAnchorPoint(cc.p(0.0, 0.5))
    self.rich_text:setDirection(kCCScrollViewDirectionVertical)
    self.rich_text:getRichText():setVerticalSpace(20)
end

function DialogUI:show(text, desc, func)
	self:setVisible(true)
	self.Text_desc:setFontSize(48)
	self.Text_desc:setColor( cc.c3b( 150 , 150 , 150 ) )
	self.Text_text:setColor(cc.c3b(208, 208, 208))
	self.Text_extraDesc:setVisible(false)
	self.Button_1:setVisible(false)
	self.Button_2:setVisible(false)
	self.Button_3:setVisible(false)
	self.Panel_hideSelect:setVisible(false)
	self.Panel_hideSelect.CheckBox_hide:setSelected(false)
	self.Panel_hideSelect.CheckBox_hide:setBright(false)

	if func then
		func()
	end
	self:setText(text)
	self:setDesc(desc)
	self:setBack()
end

function DialogUI:hide()
	self:setVisible(false)
end

function DialogUI:setText(text)
	self.Text_text:setOpacity(255)
	self.Text_text:setString(text)
end

function DialogUI:setRichText(text)
	self.Text_text:setString("")
	self:initRichText()

	local textColor = cc.c3b(208, 208, 208)
    self.rich_text:pushBackText(text, textColor, 255, Resource:getFontPath("default"), 60)
end

function DialogUI:setDescColor(color)
	self.Text_desc:setColor(color)
end

function DialogUI:setDesc(desc)
	self.Text_desc:setString(desc)
end

function DialogUI:setExtraDescVisible(visible)
	self.Text_extraDesc:setVisible(visible)
end

function DialogUI:setExtraDescColor(color)
	self.Text_extraDesc:setColor(color)
end

function DialogUI:setExtraDesc(desc)
	self.Text_extraDesc:setString(desc)
end

function DialogUI:setSelectVisible(bool)
	bool = Helper:getDef(bool,true)
	self.Panel_hideSelect:setVisible(bool)
end

function DialogUI:setSelectFunc(func)
	self.Panel_hideSelect:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")

		if self.Panel_hideSelect.CheckBox_hide:isSelected() == true then
			self.Panel_hideSelect.CheckBox_hide:setSelected(false)
			self.Panel_hideSelect.CheckBox_hide:setBright(false)
		else
			self.Panel_hideSelect.CheckBox_hide:setSelected(true)
			self.Panel_hideSelect.CheckBox_hide:setBright(true)
		end

		if func then
			func(self.Panel_hideSelect.CheckBox_hide:isSelected())
		end
	end)
end

function DialogUI:setButton(name, title, func)
	if not name then
		return
	end

	if not title then
		self[name]:setVisible(false)
	else
		self[name]:setVisible(true)
		self[name].Text_name:setString(title)
	end

	self[name]:releaseFunc(function()
		Audio:playEffect("xiaoAnNiu")
		self:hide()
		if func then
			func()
		end
	end)
end

function DialogUI:setButton1(title, func)
	self:setButton("Button_1", title, func)
end

function DialogUI:setButton2(title, func)
	self:setButton("Button_2", title, func)
end

function DialogUI:setButton3(title, func)
	self:setButton("Button_3", title, func)
end

-- canHide false 点击背景不能隐藏界面  true 点击背景可以隐藏界面 默认 true
function DialogUI:setBack(canHide)
	self.Panel_back:setTouchEnabled(true)
	if canHide == nil then
		canHide = true
	end
	self.Panel_back:releaseFunc(function()
		if canHide == false then
			return
		end
		self:hide()
	end)
end

function DialogUI:textFadeIn(item, anim, text, func)
	if not text then
		return
	end
	if not item then
		item = self.Text_text
	end
	item:setString(text)
	local self = item
	local x, y = self:getPosition()
	local actionTag = self:getActionTagByName("move")
	self:stopActionByTag(actionTag)
	if anim then
		self:move(cc.p(540, 1330))
		local action = cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveTo:create(1.5, cc.p(540, 1360)),
				cc.FadeIn:create(0.5)
			),
			cc.CallFunc:create(
				function()
					if func then
						func()
					end
					-- self:show()
				end))
		action:setTag(actionTag)
		self:runAction(action)
	else
		self:move(cc.p(0, 0))
		self:resumeSelfAndChildren()
	end
end

function DialogUI:textFadeOut(item, anim, func)
	if not item then
		item = self.Text_text
	end
	local self = item
	local actionTag = self:getActionTagByName("move")
	local x, y = self:getPosition()
	self:setOpacity(255)
	self:stopActionByTag(actionTag)
	if anim then
		self:setCascadeOpacityEnabled(true)
		self:callAllChild(function(child)
				child:setCascadeOpacityEnabled(true)
			end)

		local action = cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveTo:create(0.5, cc.p(540, 1370)),
				cc.FadeOut:create(0.5)
				),
			cc.CallFunc:create(
				function()
					if func then
						func()
					end
					-- self:hide()
				end))
		action:setTag(actionTag)
		self:runAction(action)
	else
		self:move(cc.p(0, display.height))
		self:pauseSelfAndChildren()
	end
end

function DialogUI:setWeChatVisible(bool)
	bool = Helper:getDef(bool,true)
	self.Image_weixin:setVisible(bool)
end


-- 微信分享功能
function DialogUI:setWeiXinShared()
	self.Image_weixin:releaseFunc(function()
		local WXShare = require("app.models.wxShare.WXShare")
		WXShare:doShare()
	end)
end

return DialogUI0000