local Resource = require("app.Resource")
local ActiveZhaoInfoUI = require("app.views.ui.SkillUI.ActiveZhaoInfoUI")

local SkillInfoPopSpecialUI = class("SkillInfoPopSpecialUI", LayerEx)

function SkillInfoPopSpecialUI:create()
	local p = SkillInfoPopSpecialUI:new()
	p:init()
	return p
end

function SkillInfoPopSpecialUI:init()
	local Ui = require("Layer/SkillUI/SkillInfoPopSpecialUI.lua").create()['root']
	Ui:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点

	-- local zhaoList = {
	-- 	{name = "特殊招式1"},
	-- 	{name = "特殊招式2"},
	-- 	{name = "特殊招式3"},
	-- 	{name = "特殊招式4"}
	-- }

	-- self:setActiveZhaoList(zhaoList)
end

function SkillInfoPopSpecialUI:updateSkin(skinConfig)
	if skinConfig.wxbg then
		self.Image_infoArea:loadTexture(skinConfig.wxbg,0)
	end

	if skinConfig.Basicbtnpic then
		self.Button_1:loadTextureNormal(skinConfig.Basicbtnpic,0)
		self.Button_2:loadTextureNormal(skinConfig.Basicbtnpic,0)
		self.Button_3:loadTextureNormal(skinConfig.Basicbtnpic,0)
	end
end

function SkillInfoPopSpecialUI:show(anim)
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

function SkillInfoPopSpecialUI:hide(anim)
	local actionTag = self:getActionTagByName("move")
	self:stopActionByTag(actionTag)
	if anim then
		self:setCascadeOpacityEnabled(true)
		self:callAllChild(
			function(child)
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
		-- self:setVisible(false)
		self:pauseSelfAndChildren()
	end	
end

function SkillInfoPopSpecialUI:setName(name)
	return self.Text_title:setString(name)
end

function SkillInfoPopSpecialUI:getName()
	return self.Text_title:getString()
end

function  SkillInfoPopSpecialUI:setSkillStageDsc(dsc)
	return self.Text_skillDsc:setString(dsc)
end

function SkillInfoPopSpecialUI:getSkillStageDsc()
	return self.Text_skillDsc:getString()
end

function SkillInfoPopSpecialUI:setSkillExpDsc(dsc)
	return self.Text_expDsc:setString(dsc)
end

function SkillInfoPopSpecialUI:getSkillExpDsc()
	return self.Text_expDsc:getString()
end

-- function SkillInfoPopSpecialUI:setSkillDetailDsc(dsc)
-- 	return self.Text_detailDsc:setString(dsc)
-- end

function SkillInfoPopSpecialUI:setSkillDetailDsc(dsc)
    -- add by tangjian, 临时解决 richText 问题
    self:initRichText()

    local textColor = cc.c3b(123, 123, 123)
    self.RichText_print:pushBackText(dsc, textColor, 255, Resource:getFontPath("HYCFS"),42)
    self:delayFunc(0.1,function ()
		self.RichText_print:jumpToTop()
	end)
end

--解决一句文字中，名字显示其他颜色
function SkillInfoPopSpecialUI:initRichText()
    if self.RichText_print then
        self.RichText_print:removeFromParent()
    end

    local x, y = self.Text_detailDsc:getPosition()
    local size = self.Text_detailDsc:getContentSize()

    self.RichText_print = ExtRichTextScroll:create()

    self.Text_detailDsc:getParent():addChild(self.RichText_print)
    self.RichText_print:move(cc.p(x, y))
    self.RichText_print:setSize(size)
    self.RichText_print:setDirection(kCCScrollViewDirectionVertical)
    self.RichText_print:getRichText():setVerticalSpace(10)
    self.RichText_print:setBounceEnabled(false)
end

-- function SkillInfoPopSpecialUI:getSkillDetailDsc()
-- 	return self.Text_detailDsc:getString()
-- end

function SkillInfoPopSpecialUI:setButton1(name, func)
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

function SkillInfoPopSpecialUI:setTextDesc1(str)
	if not str then
		self.Text_desc1:setVisible(false)
		return
	end
	self.Text_desc1:setVisible(true)
	self.Text_desc1:setString(str)
end

function SkillInfoPopSpecialUI:setButton2(name, func)
	if not name then
		self.Button_2:setVisible(false)
		self.Text_desc2:setVisible(false)
		return
	end
	self.Button_2:setVisible(true)
	self.Button_2:releaseFunc(func)
	self.Text_buttonName2:setString(name)
end

function SkillInfoPopSpecialUI:setTextDesc2(str)
	if not str then
		self.Text_desc2:setVisible(false)
		return
	end
	self.Text_desc2:setVisible(true)
	self.Text_desc2:setString(str)
end

function SkillInfoPopSpecialUI:setButton3(name, func)
	if not name then
		self.Button_3:setVisible(false)
		return
	end
	self.Button_3:setVisible(true)
	self.Button_3:releaseFunc(func)
	self.Text_buttonName3:setString(name)
end

function SkillInfoPopSpecialUI:createEventButton()
	local eventButton = Resource:getUIByName("Button_2")
	Helper:convertUI(eventButton)
	-- eventButton.Text_buttonName:setTextColor(cc.c4b())
	eventButton.Text_buttonName:enableOutline(cc.c4b(0, 0, 0, 255), 5)
	return eventButton
end

-- function SkillInfoPopSpecialUI:setSpecialSkills(skills)
-- 	local str = "特殊招式:"
-- 	for i, skill in ipairs(skills) do
-- 		local name = skill.name
-- 		str = str.."\n"..name	
-- 	end
-- 	self.Text_detailDsc:setString(str)
-- end

function SkillInfoPopSpecialUI:setEventList(eventList)
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

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/04 15:43:33
-- @desc 特殊招式列表
function SkillInfoPopSpecialUI:setActiveZhaoList(zhaoList,role)
	self.ListView_2:removeAllItems()
	if MapIsEmpty(zhaoList) == true then
		return
	end
	local tab = {}
	for i,v in ipairs(zhaoList) do
		table.insert(tab, v)
		if i % 2 == 0 then
			local panel = self:createOneRowZhaoPanel(tab,role)
			self.ListView_2:pushBackCustomItem(panel)
			tab = {}
		elseif i == #zhaoList then
			local panel = self:createOneRowZhaoPanel(tab,role)
			self.ListView_2:pushBackCustomItem(panel)
			tab = {}
		else
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/04 15:51:08
-- @desc 创建一行特殊招式 , 一行有两个
function SkillInfoPopSpecialUI:createOneRowZhaoPanel(twoZhaoList,role)
	local panel = self.Panel_2:clone()
	local zhaoPanel1 = self:createOneZhaoPanel(twoZhaoList[1],role)
	local zhaoPanel2 = self:createOneZhaoPanel(twoZhaoList[2],role)
	if zhaoPanel1 ~= nil then
		panel:addChild(zhaoPanel1)	
		zhaoPanel1:move(cc.p(0, 0))
	end
	if zhaoPanel2 ~= nil then
		panel:addChild(zhaoPanel2)	
		zhaoPanel2:move(cc.p(350, 0))
	end
	panel:setVisible(true)
	return panel
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/04 15:47:02
-- @desc 创建一个特殊招式
function SkillInfoPopSpecialUI:createOneZhaoPanel(zhao,role)
	if zhao == nil then
		return
	end
	local role = Helper:getDef(role,User:getRole())
	local panel = self.Panel_4:clone()
	Helper:convertUI(panel)
	panel:setVisible(true)
	panel.Text_3:enableOutline(cc.c4b(0, 0, 0, 255), 5)

	if Helper:getDef(role:getSkillZhaoExp(zhao:getId()), 0) <= 0 then
		panel.Text_3:setTextColor(cc.c4b(123, 123, 123, 255))
	else
		panel.Text_3:setTextColor(cc.c4b(208, 208, 208, 255))
	end

	panel.Text_3:setString(zhao.name)
	panel:releaseFunc(function()
		local layer = ActiveZhaoInfoUI:getInstance()
		local zhaoId = zhao:getId()
		local zhaoLv, zhaoExp = role:getSkillZhaoLv(zhaoId), role:getSkillZhaoExp(zhaoId)
		local needExp = role:conversionZhaoExpAndLv("exp", zhaoLv + 1, role:getSkillZhaoPotEfficiency(zhaoId)) - zhaoExp
		-- print("SkillInfoPopSpecialUI:createOneZhaoPanel(zhao)", zhao:getName(), zhaoExp, needExp, zhaoLv, zhao.desc, zhaoId)
		layer:showAllInfo(zhao:getName(), zhaoExp, needExp, zhaoLv, role:getZhaoUseDesc(zhaoId), role:getZhaoCondtionDesc(zhaoId), role, zhaoId)
	end)

	return panel
end

function SkillInfoPopSpecialUI:setPanelLearnSkill(tital,text)
	if not tital then
		self.Panel_learnSkill:setVisible(false)
		return
	end
	self.Panel_learnSkill:setVisible(true)
	self.Text_str1:setString(tital)
	local DialogELayer = require("app.views.layer.DialogLayer.DialogELayer")
    local dialog = DialogELayer:getInstance()
	self.Panel_tips:addTouchEventListener(
		function(ref, eventType)
	    	if eventType == ccui.TouchEventType.began then
	    		self.Image_7:setVisible(false)
	        elseif eventType == ccui.TouchEventType.ended then
	    		dialog:show(text)
	    		dialog:setPanelBack(function()
	    			self.Image_7:setVisible(true)
	    		end)
			elseif eventType == ccui.TouchEventType.canceled then
	    		self.Image_7:setVisible(true)
	        end
		end
	)
end

function SkillInfoPopSpecialUI:setImageBackFunc(func)
	self.Image_infoArea:releaseFunc(function()
		if func then
			func()
		end
	end)
end

function SkillInfoPopSpecialUI:setUseTipVisible(visible)
	visible = Helper:getDef(visible,false)
	self.Text_useTips:setVisible(visible)
end

function SkillInfoPopSpecialUI:setSkillThirdTypes(text)
	self.Text_desc3:setString(text)
end

function SkillInfoPopSpecialUI:setThirdTypeVisible(bool)
	if bool == nil then
		bool = false
	end
	self.Text_desc3:setVisible(bool)
end

return SkillInfoPopSpecialUI0