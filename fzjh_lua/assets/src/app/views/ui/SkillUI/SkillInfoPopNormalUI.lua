
local Resource = require("app.Resource")

local SkillInfoPopNormalUI = class("SkillInfoPopNormalUI", cc.Layer)

function SkillInfoPopNormalUI:create()
	local p = SkillInfoPopNormalUI:new()
	p:init()
	return p
end

function SkillInfoPopNormalUI:init()
	self._round = require("Layer/SkillUI/SkillInfoPopNormalUI.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点
end

function SkillInfoPopNormalUI:updateSkin(skinConfig)
	if skinConfig.jibenwxbg then
		self.Image_infoArea:loadTexture(skinConfig.jibenwxbg, 0)
	end

	if skinConfig.Basicbtnpic then
		self.Button_1:loadTextureNormal(skinConfig.Basicbtnpic,0)
		self.Button_2:loadTextureNormal(skinConfig.Basicbtnpic,0)
	end
end

function SkillInfoPopNormalUI:show(anim)
	local actionTag = self:getActionTagByName("move")
	self:stopActionByTag(actionTag)
	self:resumeSelfAndChildren()
	if anim then
		self:move(cc.p(0, 170))
		self:maxZ()
		local action = cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, 0)), 
				cc.FadeIn:create(UI_ANIM_DURATION)
			),
			cc.CallFunc:create(
				function()
					self:show()
				end))
		action:setTag(actionTag)
		self:runAction(action)	
	else
		self:move(cc.p(0, 0))
	end	
end

function SkillInfoPopNormalUI:hide(anim)
	local actionTag = self:getActionTagByName("move")
	self:stopActionByTag(actionTag)
	if anim then
		self:setCascadeOpacityEnabled(true)
		self:callAllChild(function(child)
				child:setCascadeOpacityEnabled(true)
			end)
		local action = cc.Sequence:create(
			cc.Spawn:create(
				cc.MoveTo:create(UI_ANIM_DURATION, cc.p(0, 170)), 
				cc.FadeOut:create(UI_ANIM_DURATION)				
				),
			cc.CallFunc:create(
				function()
					self:hide()
				end))
		action:setTag(actionTag)
		self:runAction(action)	
	else
		self:move(cc.p(0, display.height))
		self:pauseSelfAndChildren()
	end	
end

function SkillInfoPopNormalUI:setName(name)
	return self.Text_title:setString(name)
end

function SkillInfoPopNormalUI:getName()
	return self.Text_title:getString()
end

function  SkillInfoPopNormalUI:setSkillStageDsc(dsc)
	return self.Text_skillDsc:setString(dsc)
end

function SkillInfoPopNormalUI:getSkillStageDsc()
	return self.Text_skillDsc:getString()
end

function SkillInfoPopNormalUI:setSkillExpDsc(dsc)
	return self.Text_expDsc:setString(dsc)
end

function SkillInfoPopNormalUI:getSkillExpDsc()
	return self.Text_expDsc:getString()
end

function SkillInfoPopNormalUI:setSkillDetailDsc(dsc)
	return self.Text_detailDsc:setString(dsc)
end

function SkillInfoPopNormalUI:getSkillDetailDsc()
	return self.Text_detailDsc:getString()
end

function SkillInfoPopNormalUI:setButton1(name, func)
	if not name then
		self.Button_1:setVisible(false)
		self.Text_desc1:setVisible(false)
		return
	end
	self.Button_1:setVisible(true)
	self.ListView_eventArea:setVisible(false)
	self.Button_1:releaseFunc(func)
	self.Text_buttonName1:setString(name)
end

function SkillInfoPopNormalUI:setTextDesc1(str)
	if not str then
		self.Text_desc1:setVisible(false)
		return
	end
	self.Text_desc1:setVisible(true)
	self.Text_desc1:setString(str)
end

function SkillInfoPopNormalUI:setButton2(name, func)
	if not name then
		self.Button_2:setVisible(false)
		self.Text_desc2:setVisible(false)
		return
	end
	self.Button_2:setVisible(true)
	self.Button_2:releaseFunc(func)
	self.Text_buttonName2:setString(name)
end

function SkillInfoPopNormalUI:setTextDesc2(str)
	if not str then
		self.Text_desc2:setVisible(false)
		return
	end
	self.Text_desc2:setVisible(true)
	self.Text_desc2:setString(str)
end

function SkillInfoPopNormalUI:createEventButton()
	local eventButton = Resource:getUIByName("Button_2")
	Helper:convertUI(eventButton)
	-- eventButton.Text_buttonName:setTextColor(cc.c4b())
	eventButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return eventButton
end

function SkillInfoPopNormalUI:setEventList(eventList)
	self.ListView_eventArea:setVisible(true)
	self.Button_1:setVisible(false)
	self.Text_desc1:setVisible(false)
	self.Button_2:setVisible(false)
	self.Text_desc2:setVisible(false)
	self.ListView_eventArea:removeAllItems()

	for i, event in ipairs(eventList) do
		local name = assert(event.name)
		local func = assert(event.func)

		local eventButton = self:createEventButton()
		self.ListView_eventArea:pushBackCustomItem(eventButton)

		eventButton.Text_buttonName:setString(event.name)
		eventButton:releaseFunc(
			function()
				if func then
					func()
				end
			end
			)
	end
end

function SkillInfoPopNormalUI:setImageBackFunc(func)
	self.Image_infoArea:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function SkillInfoPopNormalUI:setUseTipVisible(visible)
	visible = Helper:getDef(visible,false)
	self.Text_useTips:setVisible(visible)
end

function SkillInfoPopNormalUI:setSkillThirdTypes(text)
	self.Text_desc3:setString(text)
end

function SkillInfoPopNormalUI:setThirdTypeVisible(bool)
	if bool == nil then
		bool = false
	end
	self.Text_desc3:setVisible(bool)
end

return SkillInfoPopNormalUI00000