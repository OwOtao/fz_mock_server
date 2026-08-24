local FondDrSkillInfoLayer = class("FondDrSkillInfoLayer", cc.Layer)  

local TuJianActiveZhaoInFoLayer = require("app.views.layer.TuJianLayer.TuJianActiveZhaoInFoLayer")
local AnimFightLayer = require("app.views.layer.FightLayer.AnimFightLayer")
local TuJianUtil = require("app.models.TuJian.TuJianUtil")

function FondDrSkillInfoLayer:create()
	local p = FondDrSkillInfoLayer:new()
	p:init()
	return p
end

function FondDrSkillInfoLayer:init()
	self._round = require("Layer/TuJianUI/tujianSkillInfo.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点

	self:setPanelBack()
end

function FondDrSkillInfoLayer:showLayer()
	self:show()
end

function FondDrSkillInfoLayer:setRole(role)
	self._role = role
end

function FondDrSkillInfoLayer:getRole()
	return Helper:getDef(self._role,User:getRole())
end

function FondDrSkillInfoLayer:setName(name)
	self.Text_title:enableOutline(cc.c4b(31, 31, 31), 5)
	return self.Text_title:setString(name)
end

function FondDrSkillInfoLayer:getName()
	return self.Text_title:getString()
end

function FondDrSkillInfoLayer:setSkillDetailDsc(dsc)
    -- add by tangjian, 临时解决 richText 问题
    self:initRichText()

    local textColor = cc.c3b(167, 167, 167)
    self.RichText_print:pushBackText(Helper:getDef(dsc,""), textColor, 255, Resource:getFontPath("HYCFS"),42)
    self:delayFunc(0.1,function ()
		self.RichText_print:jumpToTop()
	end)
end

function FondDrSkillInfoLayer:initRichText()
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

function FondDrSkillInfoLayer:setActiveZhaoList(zhaoList)
	self.ListView_2:removeAllItems()
	if MapIsEmpty(zhaoList) == true then
		return
	end
	local tab = {}
	for i,v in ipairs(zhaoList) do
		table.insert(tab, v)
		if i % 2 == 0 then
			local panel = self:createOneRowZhaoPanel(tab)
			self.ListView_2:pushBackCustomItem(panel)
			tab = {}
		elseif i == #zhaoList then
			local panel = self:createOneRowZhaoPanel(tab)
			self.ListView_2:pushBackCustomItem(panel)
			tab = {}
		else
		end
	end
end

function FondDrSkillInfoLayer:createOneRowZhaoPanel(twoZhaoList)
	local panel = self.Panel_2:clone()
	local zhaoPanel1 = self:createOneZhaoPanel(twoZhaoList[1])
	local zhaoPanel2 = self:createOneZhaoPanel(twoZhaoList[2])
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

function FondDrSkillInfoLayer:createOneZhaoPanel(zhao)
	if zhao == nil then
		return
	end
	local role = self:getRole()
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
		local layer = TuJianActiveZhaoInFoLayer:getInstance()

		layer:showAllInfo(zhao:getName(),zhao:getDesc(), zhao:getLearnConditionListWithCN(),zhao:getUseConditonListWithCN())	
	end)

	return panel
end

function FondDrSkillInfoLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)

	self.Image_infoArea:releaseFunc(function()
		self:hideLayer()
	end)
end

function FondDrSkillInfoLayer:hideLayer()
	if self._handel then
		self:unschedule(self._handel)
	end
	if self._animLeftUI then
		self.AnimNode_left:setVisible(false)
		self._animLeftUI:onDestroy()
		self._animLeftUI = nil
	end
	if self._animRightUI then
		self.AnimNode_right:setVisible(false)
		self._animRightUI:onDestroy()
		self._animRightUI = nil
	end
	PopupLayerController:hideLayer("FondDrSkillInfoLayer",function(layer)
		layer:hide()
	end)
end

function FondDrSkillInfoLayer:setAutoZhaoDsc(skillId,titalIndex,isVisible)
	if isVisible == nil then
		isVisible = true
	end

	local skill = self:getSkill(skillId)

	local skills = skill:getAutoSkills()
	if isVisible == false then
		self.Text_detailDsc1_0:setVisible(false)
		self.Text_Auto:setVisible(false)
		self.Panel_6:setVisible(false)
	else
		self.Text_detailDsc1_0:setVisible(true)
		self.Text_Auto:setVisible(true)
		self.Panel_6:setVisible(true)
	end
	self.Text_Auto:setString("共有"..Helper:numberCast(#skills).."招")

	if skill.type == SKILL_TYPE_SELFCREATE then
		self.Text_prepareCondition:setVisible(true)
		local allEffectLv = skill.allEffectLv
		self.Text_prepareCondition:setString("(武学纯熟需要"..allEffectLv.."级)")
	else
		self.Text_prepareCondition:setVisible(false)
	end
	

	local showNormalSkillZhao = function()
		local DialogKlayer = require("app.views.layer.DialogLayer.DialogKLayer")
		local dialog = DialogKlayer:getInstance()
		dialog:hide()
		
		local str = ""
		for i,v in ipairs(skills) do
			str = str.."DUY"..v.skillText.."\n".."GRA"..v.action.."\n  \n"
		end

		str = string.gsub(str, "$N", "你")
		str = string.gsub(str, "$n", "对方")
		str = string.gsub(str, "$w", Helper:getDef(TuJianUtil:getWeaponStr(titalIndex),"") )
		str = string.gsub(str, "$l", "身体")
		str = string.gsub(str, "$p", "对方")

		local skillName = skill.name

		--去除文本内的颜色字符
		for _, v in ipairs(GetColorList()) do
			local s, e = string.find(str, v.id)
			if s ~= nil and e ~= nil then
				str = string.gsub(str,v.id,"")
			end

			local s1, e1 = string.find(skillName, v.id)
			if s1 ~= nil and e1 ~= nil then
				skillName = string.gsub(skillName,v.id,"")
			end 

		end 

		dialog:showLayer("CYN"..skillName.."武学招式：共有"..#skills.."招", str)	
	end

	local selfCreateSkillZhao = function()
		PopupLayerController:showLayer("TujianSelfCreateSkillActiveZhaoInfoLayer",function(layer)
			layer:showLayer(skill)
		end)
	end

	self.Panel_6:releaseFunc(function()
		if skill.type == SKILL_TYPE_SELFCREATE then
			selfCreateSkillZhao()
		else
			showNormalSkillZhao()
		end
	end)
end

function FondDrSkillInfoLayer:playWuXueAnim(skillId,titalIndex,isPlay)
	if isPlay == false then
		return
	end

	local weaponSkin,anims = self:_getSkinAndAnims(skillId)

	local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")
	local FondDrSkillAnimUI = require("app.views.layer.FondDrLayer.FondDrSkillAnimUI")
	local FightCommons = require("app.FightSystem.FightCommons")
	local FightFormula = require("app.FightSystem.FightFormula")
	local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")
	self.AnimNode_right:setVisible(true)
	self.AnimNode_left:setVisible(true)
	self._animRightUI = FondDrSkillAnimUI:create(self.AnimNode_right)
	self._animRightUI:setPosition(815,365,0)
	self._animRightUI:setAnimScaleX(-1)
	--@desc 稻草人模型往右移动15像素
	self._animRightUI:setSkeletonAnimationPosition(15,0)
	self._animLeftUI = FondDrSkillAnimUI:create(self.AnimNode_left)
	self._animLeftUI:setPosition(240,365,0)

	if weaponSkin then
		self._animLeftUI:setWeaponSkin(weaponSkin)
	end
	self._animLeftUI:setVisible(true)
	self._animRightUI:setVisible(true)

	self._time = 0
	self._index = 1
	self._duration = 0
	self._moveTime = 0
	local attackAnimIndex = 3
	local _start_pos = {x = 240,y =365,h = 0}
	local _offset = AnimResManager:getAttackAnimOffset(anims[attackAnimIndex].animName)
	local _target_pos = {x = 815 - _offset,y = 365,h = 0}
	local _highest = math.abs((_target_pos.x - _start_pos.x)) / 1080 * 30

	self._handel = self:schedule(
		function(ft)
			self._animLeftUI:onUpdate(ft)
			self._animRightUI:onUpdate(ft)
			
			self._time = self._time + ft
			if self._time > self._duration then
				if self._index > #anims then
					self._index = attackAnimIndex
				end
				
				local animName = anims[self._index].animName
				local animType = anims[self._index].type
				local duration = anims[self._index].duration
				local eventCallback = EMPTY_FUNC
				if animType == "idle" then
					self._move = false
					local daocaorenAnim = AnimResManager:getOtherAnimName(BattleConstConf:get("battleIdleAnimScarecrow"))
					self._animRightUI:playAnim(daocaorenAnim)
				elseif animType == "forward" then
					self._move = true
				elseif animType == "attack" then
					local offset = AnimResManager:getAttackAnimOffset(animName)
					self._animLeftUI:setPosition(815 - offset, 365, 0)

					eventCallback = function(event)
						if event.name == "Hurt" then
							local daocaorenAnim = AnimResManager:getOtherAnimName(BattleConstConf:get("hurtChestAnimScarecrow"))
							self._animRightUI:playAnim(daocaorenAnim)
						end
					end
				end

				self._duration = duration
				self._animLeftUI:playAnim(animName)
				self._animLeftUI:setEventCallback(eventCallback)
				self._index = self._index + 1
				self._time = 0
			end

			if self._move == true then
				local total_time = 3 / FightCommons.LOGIC_FPS
				local percent = math.min(self._moveTime / total_time, 1)
				
				local next_pos = FightFormula:jumpFoward(_start_pos, _target_pos, percent)
				
				local hight = FightFormula:jumpHeight(_highest, percent)

				self._animLeftUI:setPosition(next_pos.x, next_pos.y, hight)
				
				if percent >= 1 then
					self._move = false
				end
				self._moveTime = self._moveTime + ft
			end
		end, 0
	)
end

function FondDrSkillInfoLayer:getSkill(skillId)
	local FondSkill = require("app.models.FondDream.Skill.FondSkill")
	return FondSkill:getSkill(skillId)
end

function FondDrSkillInfoLayer:_getSkinAndAnims(skillId)
	local skill = self:getSkill(skillId)
	local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")
	local weaponSkin,weaponModule = self:_getWeaponSkinAndModule(skill)
	
	local retAnims = {}

	--入场动画
	-- local joinAnim = AnimResManager:getOtherAnimName(skill.getBattleJoinAnim)
	--待机动画
	local idleAnim = AnimResManager:getOtherAnimName(skill.getBattleIdleAnim)
	--攻击前跳动画
	local runAnim = AnimResManager:getOtherAnimName(skill.getBattleRunAnim)
	--攻击后跳动画
	-- local backAnim = AnimResManager:getOtherAnimName(skill.getBattleBackAnim)

	table.insert(retAnims,{animName = idleAnim,type = "idle",duration = 0.2})
	table.insert(retAnims,{animName = runAnim,type = "forward",duration = 0.3})

	--招式动画
	local autoZhaos = skill:getAutoSkills()
	for i,autoZhao in ipairs(autoZhaos) do
		for i,animResId in ipairs(autoZhao.animResIds) do
			local zhaoAnim = AnimResManager:getAttackAnimName(animResId, weaponModule)
			table.insert(retAnims,{animName = zhaoAnim,type = "attack",duration = AnimResManager:getAnimTime(zhaoAnim)})
		end
	end
	return weaponSkin,retAnims
end


--武器皮肤和动画模组
function FondDrSkillInfoLayer:_getWeaponSkinAndModule(skill)
	local weaponTypes = skill.getWeaponTypes
	local weaponType = weaponTypes[math.random(1,#weaponTypes)]
	local WeaponTypesResManager = require("app.FightSystem.FightRole.CharacterEquipment.WeaponTypesResManager")
	local weaponInfo = WeaponTypesResManager:getWeaponInfo(weaponType)

	return weaponInfo.weaponSkin,weaponInfo.weaponModule
end

Helper:classDefNodeGetInstance(FondDrSkillInfoLayer)
return FondDrSkillInfoLayer00000