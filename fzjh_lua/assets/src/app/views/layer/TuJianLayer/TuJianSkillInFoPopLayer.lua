local TuJianSkillInFoPopLayer = class("TuJianSkillInFoPopLayer", cc.Layer)

local TuJianActiveZhaoInFoLayer = require("app.views.layer.TuJianLayer.TuJianActiveZhaoInFoLayer")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local AnimFightLayer = require("app.views.layer.FightLayer.AnimFightLayer")
local TuJianUtil = require("app.models.TuJian.TuJianUtil")
local StringUtil = require("app.extends.StringUtil")
local SkillHelper = require("app.models.skill.SkillHelper")

local NoOpenWuXueAnimList = TuJianUtil:getNotOpenWuXueAnimList()

function TuJianSkillInFoPopLayer:create()
	local p = TuJianSkillInFoPopLayer:new()
	p:init()
	return p
end

function TuJianSkillInFoPopLayer:init()
	self._round = require("Layer/TuJianUI/tujianSkillInfo.lua").create()['root']
	self._round:addTo(self)
	
	Helper:convertUI(self) -- 获得所有子节点

	self:setPanelBack()
end

function TuJianSkillInFoPopLayer:showLayer()
	self._playAnim = true
	self:show()
end

function TuJianSkillInFoPopLayer:setRole(role)
	self._role = role
end

function TuJianSkillInFoPopLayer:getRole()
	return Helper:getDef(self._role,User:getRole())
end

function TuJianSkillInFoPopLayer:setName(name)
	print("name = ",name)
	self.Text_title:enableOutline(cc.c4b(31, 31, 31), 5)
	return self.Text_title:setString(name)
end

function TuJianSkillInFoPopLayer:getName()
	return self.Text_title:getString()
end

-- function TuJianSkillInFoPopLayer:setSkillLvDsc(skillId)
-- 	local skillLv = User:getRole():getSkillLv(skillId)
-- 	local baseSkill = Skill:getSkill(skillId)
-- 	local skillDes = ""
-- 	if skillLv <= 0 then
-- 		skillDes = "BLU尚未掌握"
-- 	else
-- 		skillDes = baseSkill:getSkillDescForValid(skillLv)
-- 	end
-- 	self.Text_skillDsc:setString(skillDes)
-- 	self.Text_expDsc:setString(skillLv.."级")
-- end

function TuJianSkillInFoPopLayer:setSkillDetailDsc(dsc)
    -- add by tangjian, 临时解决 richText 问题
    self:initRichText()

    local textColor = cc.c3b(167, 167, 167)
    self.RichText_print:pushBackText(Helper:getDef(dsc,""), textColor, 255, Resource:getFontPath("HYCFS"),42)
    self:delayFunc(0.1,function ()
		self.RichText_print:jumpToTop()
	end)
end

--解决一句文字中，名字显示其他颜色
function TuJianSkillInFoPopLayer:initRichText()
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

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/04 15:43:33
-- @desc 特殊招式列表
function TuJianSkillInFoPopLayer:setActiveZhaoList(zhaoList)
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

-----------------------------------------------------------------------------------------------------------
function TuJianSkillInFoPopLayer:createOneRowZhaoPanel(twoZhaoList)
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


function TuJianSkillInFoPopLayer:createOneZhaoPanel(zhao)
	if zhao == nil then
		return
	end
	local role = User:getRole()
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
		self:showActiveZhaoInFoUI(zhao:getId())	
	end)

	return panel
end

function TuJianSkillInFoPopLayer:setPanelBack()
	self.Panel_back:releaseFunc(function()
		self:hideLayer()
	end)

	self.Image_infoArea:releaseFunc(function()
		self:hideLayer()
	end)
end

function TuJianSkillInFoPopLayer:hideLayer()
	if self._animRoleLayer then
		local animRole = self._animRoleLayer:getRoleByTeamIdAndInTeamId(1, 1)
		if animRole then
			animRole._action = nil
			animRole:setVisible(false)
			self._playAnim = nil
			-- animRole.anim:clearTrack(0)
		end
	end
	
	self.__zhaoLevel = nil

	PopupLayerController:hideLayer("TuJianSkillInFoPopLayer",function(layer)
		layer:hide()
	end)
end

function TuJianSkillInFoPopLayer:setAutoZhaoDsc(skillId,titalIndex,isGrasp)
	if titalIndex == nil or NoOpenWuXueAnimList[titalIndex] == true or not isGrasp then
		self.Text_detailDsc1_0:setVisible(false)
		self.Text_Auto:setVisible(false)
		self.Panel_6:setVisible(false)
		self.Text_prepareCondition:setVisible(false)
		return
	end

	self.Text_detailDsc1_0:setVisible(true)
	
	self.Text_Auto:setVisible(true)
	
	self.Panel_6:setVisible(true)
	
	local skill = self:getSkill(skillId)

	local skills = skill:getAutoSkills()

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

function TuJianSkillInFoPopLayer:playWuXueAnim(skillId,titalIndex)
	if titalIndex == nil or NoOpenWuXueAnimList[titalIndex] == true then
		self.Panel_animFightArea:setVisible(false)
		return
	end
	
	self.Panel_animFightArea:setVisible(true)

	local leftPositions = {}
    local rightPositions = {}

	table.insert(leftPositions, cc.p(self.Panel_leftFightPos1:getPosition()))
	table.insert(rightPositions, cc.p(self.Panel_rightFightPos1:getPosition()))

    if self._animRoleLayer then
        self._animRoleLayer = nil
	end
	
	self._animRoleLayer = AnimFightLayer:createInPanel(self.Panel_animFightArea)
    self._animRoleLayer:FightStart(leftPositions, rightPositions)
	-- self._animRoleLayer:setMoveCameraEnabled(true)

	local animRole = self._animRoleLayer:getRoleByTeamIdAndInTeamId(1, 1)
	local daocaoren = self._animRoleLayer:getRoleByTeamIdAndInTeamId(2, 1)
    animRole:setVisible(true)
	daocaoren:setVisible(true)
	daocaoren.anim:setPositionX(daocaoren.anim:getPositionX() + 15)

	local skill = self:getSkill(skillId)

	local weapontype = nil
	if #skill.weapontype > 0 then
		weapontype = skill.weapontype[math.random(1,#skill.weapontype)]
	end

	-- 设置武器
	local weaponAttachmentName = self:getCurrWeaponimage(titalIndex,weapontype)
	print("weapontype= " ,weapontype,"titalIndex = ",titalIndex,"weaponAttachmentName = ",weaponAttachmentName)

	-- 武器
	animRole.anim:setAttachment("weapon", weaponAttachmentName)
	if string.find(titalIndex, "shuangchi") then
		animRole.anim:setAttachment("weapon5", weaponAttachmentName)
	else
		animRole.anim:setAttachment("weapon5", "")
	end

	animRole.shadowSprite:setVisible(true)
	daocaoren.shadowSprite:setVisible(true)

	local function addAnimation(anims)
		if MapIsEmpty(anims) then
			return
		end

		local count = 0

		local function playRoleAnim(objectRole,animName,from,to,speed)
			objectRole.anim:playAnim(animName)

			if from or to then
				objectRole.anim:setAnimFrameFromTo(from, to)
			end
			if speed then
				objectRole.anim:setSpeedScale(speed)
			end
		end

		-- 待机姿势
		local standAnimName = skill:getStandAnimName()
		if string.find(standAnimName, "_", -1) then
			standAnimName = standAnimName..StringUtil:subNum(weapontype)
		end

		playRoleAnim(animRole,standAnimName)
		playRoleAnim(daocaoren,"daocaoren-hurt-chest",1,2)

		animRole.anim:registerSpineEventHandler(function(event)
			if self._playAnim ~= true then
				return
			end
			if count > #anims then
				count = 1
			end
			
			local randomDelayTime = 0
			if count == 0 then
				randomDelayTime = 0.5
			end

			animRole:runActionWithName("playRoleAnim",
            cc.Sequence:create(
                cc.DelayTime:create(randomDelayTime),
				cc.CallFunc:create(function()
					local name,offsetX,duration
					if count == 0 then
						duration = 10/30
						offsetX = anims[1]["offset"]
					else
						duration = 5/30
						offsetX = anims[count]["offset"]
					end
					local moveVecX = math.abs((daocaoren:getPositionX() - animRole:getPositionX())) + offsetX
					if moveVecX <= 50 then
						name = "move"
					else
						name = "jump"
					end

					animRole._action =
					{
						name = name,
						target = daocaoren,
						offsetX = offsetX,
						offsetY = 0,
						duration = duration,
						elapsed = 0
					}

					if count == 0 then
						local JumpForwardAnimName = skill:getJumpForwardAnimName()
						if string.find(JumpForwardAnimName, "_", -1) then
							JumpForwardAnimName = JumpForwardAnimName..StringUtil:subNum(weapontype)
						end
						self._animRoleLayer:delayFunc(duration,function()
							playRoleAnim(animRole,JumpForwardAnimName)
							count = count + 1
						end)
					else
						local daocaorenAnims = "daocaoren-hurt-chest"
						self._animRoleLayer:delayFunc(duration,function()
							playRoleAnim(animRole,anims[count]["anim"])
							playRoleAnim(daocaoren,daocaorenAnims)
							count = count + 1
						end)
					end
                end)))
		end, sp.EventType.ANIMATION_COMPLETE)
	end
	
	local skills = skill:getAutoSkills()
	
	local animList = self:getSkillAnimList(skills,weapontype)

	if not MapIsEmpty(animList) then
		if #animList > 3 then
			addAnimation(animList)
		else
			local jibenSkills = self:getJiBenSkills(titalIndex)
			animList = table.mergeArray(animList, self:getSkillAnimList(jibenSkills,weapontype))
			addAnimation(animList)
		end
	else
		local jibenSkills = self:getJiBenSkills(titalIndex)
		local jibenAnimList = self:getSkillAnimList(jibenSkills,weapontype)
		addAnimation(jibenAnimList)
	end
end

function TuJianSkillInFoPopLayer:playZhaoAnim_GM(zhao)
	
	self.Panel_animFightArea:setVisible(true)
	local leftPositions = {}
    local rightPositions = {}

	table.insert(leftPositions, cc.p(self.Panel_leftFightPos1:getPosition()))
	table.insert(rightPositions, cc.p(self.Panel_rightFightPos1:getPosition()))

    if self._animRoleLayer then
        self._animRoleLayer = nil
	end
	
	self._animRoleLayer = AnimFightLayer:createInPanel(self.Panel_animFightArea)
    self._animRoleLayer:FightStart(leftPositions, rightPositions)
	-- self._animRoleLayer:setMoveCameraEnabled(true)

	local animRole = self._animRoleLayer:getRoleByTeamIdAndInTeamId(1, 1)
	local daocaoren = self._animRoleLayer:getRoleByTeamIdAndInTeamId(2, 1)
    animRole:setVisible(true)
	daocaoren:setVisible(true)
	daocaoren.anim:setPositionX(daocaoren.anim:getPositionX() + 15)

	local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")

	local baseSkillId = switch(zhao.type,{
		[SelfCreatedSkillConstants.SkillThirdType.QUAN_FA] = "jibenquanjiao",
		[SelfCreatedSkillConstants.SkillThirdType.ZHANG_FA] = "jibenquanjiao",
		[SelfCreatedSkillConstants.SkillThirdType.ZHUA_FA] = "jibenquanjiao",
		[SelfCreatedSkillConstants.SkillThirdType.ZHI_FA] = "jibenquanjiao",
		[SelfCreatedSkillConstants.SkillThirdType.TUI_FA] = "jibenquanjiao",
		[SelfCreatedSkillConstants.SkillThirdType.JIAN_FA] = "jibenjianfa",
		[SelfCreatedSkillConstants.SkillThirdType.DAO_FA] = "jibendaofa",
		[SelfCreatedSkillConstants.SkillThirdType.GUN_FA] = "jibengunfa",
		[SelfCreatedSkillConstants.SkillThirdType.BIAN_FA] = "jibenbianfa",
		[SelfCreatedSkillConstants.SkillThirdType.AN_QI] = "jibenanqi",
		[SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI] = "jibenshuangchi",
		[SelfCreatedSkillConstants.SkillThirdType.QIN_FA] = "jibenqinfa",
		[SelfCreatedSkillConstants.SkillThirdType.QING_GONG] = "jibenqinggong",
		[SelfCreatedSkillConstants.SkillThirdType.NEI_GONG] = "jibenneigong",
		[SelfCreatedSkillConstants.SkillThirdType.ZHAO_JIA] = "jibenzhaojia",
	})

	local baseSkill = Skill:getSkill(baseSkillId)

	local weapon_type_List = {
		[SelfCreatedSkillConstants.SkillThirdType.JIAN_FA] = {"jian","jianfa","剑"},
		[SelfCreatedSkillConstants.SkillThirdType.DAO_FA] = {"dao","daofa","刀"},
		[SelfCreatedSkillConstants.SkillThirdType.GUN_FA] = {"gun","gunfa","棍"},
		[SelfCreatedSkillConstants.SkillThirdType.BIAN_FA] ={"bian","bianfa","鞭"},
		[SelfCreatedSkillConstants.SkillThirdType.AN_QI] = {"anqi","anqi","暗器"},
		[SelfCreatedSkillConstants.SkillThirdType.SHUANG_CHI] = {"shuangchi","shuangchi","双持"},
		[SelfCreatedSkillConstants.SkillThirdType.QIN_FA] = {"qin","qinfa","乐器"},
	}

	local weapontype,titalIndex = nil,nil
	if weapon_type_List[zhao.type] then
		titalIndex = weapon_type_List[zhao.type][1]
		local weaponType1 = User:getRole():getCurrWeaponType()
		local weaponType2 = User:getRole():getCurrWeaponType2()
		if weaponType1 == weapon_type_List[zhao.type][3] and weaponType2 then
			weapontype = weapon_type_List[zhao.type][2]..tostring(weaponType2)
		else
			weapontype = baseSkill.weapontype[math.random(1,#baseSkill.weapontype)]
		end
	end

	-- 设置武器
	local weaponAttachmentName = self:getCurrWeaponimage(titalIndex,weapontype)
	print("weapontype= " ,weapontype,"titalIndex = ",titalIndex,"weaponAttachmentName = ",weaponAttachmentName)

	-- 武器
	animRole.anim:setAttachment("weapon", weaponAttachmentName)
	if titalIndex and string.find(titalIndex, "shuangchi") then
		animRole.anim:setAttachment("weapon5", weaponAttachmentName)
	else
		animRole.anim:setAttachment("weapon5", "")
	end

	animRole.shadowSprite:setVisible(true)
	daocaoren.shadowSprite:setVisible(true)

	local function addAnimation(anims)
		if MapIsEmpty(anims) then
			return
		end

		local count = 0

		local function playRoleAnim(objectRole,animName,from,to,speed)
			objectRole.anim:playAnim(animName)

			if from or to then
				objectRole.anim:setAnimFrameFromTo(from, to)
			end
			if speed then
				objectRole.anim:setSpeedScale(speed)
			end
		end

		-- 待机姿势
		local standAnimName = baseSkill:getStandAnimName()
		if string.find(standAnimName, "_", -1) then
			standAnimName = standAnimName..StringUtil:subNum(weapontype)
		end

		playRoleAnim(animRole,standAnimName)
		playRoleAnim(daocaoren,"daocaoren-hurt-chest",1,2)

		animRole.anim:registerSpineEventHandler(function(event)
			if self._playAnim ~= true then
				return
			end
			if count > #anims then
				count = 1
			end
			
			local randomDelayTime = 0
			if count == 0 then
				randomDelayTime = 0.5
			end

			animRole:runActionWithName("playRoleAnim",
            cc.Sequence:create(
                cc.DelayTime:create(randomDelayTime),
				cc.CallFunc:create(function()
					local name,offsetX,duration
					if count == 0 then
						duration = 10/30
						offsetX = anims[1]["offset"]
					else
						duration = 5/30
						offsetX = anims[count]["offset"]
					end
					local moveVecX = math.abs((daocaoren:getPositionX() - animRole:getPositionX())) + offsetX
					if moveVecX <= 50 then
						name = "move"
					else
						name = "jump"
					end

					animRole._action =
					{
						name = name,
						target = daocaoren,
						offsetX = offsetX,
						offsetY = 0,
						duration = duration,
						elapsed = 0
					}

					if count == 0 then
						local JumpForwardAnimName = baseSkill:getJumpForwardAnimName()
						if string.find(JumpForwardAnimName, "_", -1) then
							JumpForwardAnimName = JumpForwardAnimName..StringUtil:subNum(weapontype)
						end
						self._animRoleLayer:delayFunc(duration,function()
							playRoleAnim(animRole,JumpForwardAnimName)
							count = count + 1
						end)
					else
						local daocaorenAnims = "daocaoren-hurt-chest"
						self._animRoleLayer:delayFunc(duration,function()
							playRoleAnim(animRole,anims[count]["anim"])
							playRoleAnim(daocaoren,daocaorenAnims)
							count = count + 1
						end)
					end
                end)))
		end, sp.EventType.ANIMATION_COMPLETE)
	end
	
	local animList = {}

	local newSkillanim = assert(require("script.skill.newSkillanim").Sheet1)

    if not weapon_type_List[zhao.type] then
		for i = 1, 10 do
			local anim = zhao["anim" .. i]
			local hitPos = zhao["hitPos" .. i]
			local offset = zhao["offset" .. i]
			local speed = zhao["speed" .. i]
			if anim and hitPos and offset then
				table.insert(animList,
					{
						anim = anim,
						hitPos = hitPos,
						offset = offset,
						speed = Helper:getDef(speed, 1)
					})
			end
		end
	else
		for i = 1, 10 do
			local anim = zhao["anim" .. i]
			local speed = zhao["speed" .. i]
			if anim then
				local tab = {}

				local weaponTypeNum = StringUtil:subNum(weapontype)

				print("animName:",anim,"crruWeapon:",weaponTypeNum)
			   
				local newAnimId = anim..weaponTypeNum
					
				local newSkillanimParam = newSkillanim[newAnimId]
				local hitPos = newSkillanimParam["location"]
				local offset = newSkillanimParam["offset"]


				tab = {
					anim = newAnimId,
					hitPos = hitPos,
					offset = offset,
					speed = Helper:getDef(speed, 1) 

				}
				table.insert(animList,tab)  
			end
			
		end    
	end

	addAnimation(animList)
end

function TuJianSkillInFoPopLayer:getCurrWeaponimage(subType,weapontype)
    return TuJianUtil:getCurrWeaponimage(subType,weapontype)
end

function TuJianSkillInFoPopLayer:getSkillAnimList(skills,weapontype)
	return TuJianUtil:getSkillAnimList(skills,weapontype)
end

function TuJianSkillInFoPopLayer:getJiBenSkills(titalIndex)
	return TuJianUtil:getJiBenSkills(titalIndex)
end

function TuJianSkillInFoPopLayer:getSkill(skillId)
	local skill = Skill:getSkill(skillId)

	if MapIsEmpty(skill) then
		print("---------TuJianSkillInFoPopLayer:getSkill 技能有问题, skillId:",skillId)
        print(debug.traceback())
		return false
	end

	return skill
end

--@desc: 设置要显示的招式的重数
--@author:LvBin
--@time:2025-08-26 16:08:59
--@level: 招式重数
--@return
function TuJianSkillInFoPopLayer:setShowZhaoLevel(level)
	self.__zhaoLevel = level
end

function TuJianSkillInFoPopLayer:showActiveZhaoInFoUI(zhaoId)
	local zhao

	if self.__zhaoLevel then
		zhao = Skill:getActiveZhao(zhaoId..tostring(self.__zhaoLevel))
	else
		local zhaoLv = self:getRole():getSkillZhaoLv(zhaoId)
		if zhaoLv > 1 then
			zhaoId = zhaoId..zhaoLv
		end
		
		zhao = Skill:getActiveZhao(zhaoId)
	end

	local layer = TuJianActiveZhaoInFoLayer:getInstance()
	layer:showAllInfo(zhao:getName(),zhao:getDesc(), zhao:getLearnConditionListWithCN(),zhao:getUseConditonListWithCN())	
end

Helper:classDefNodeGetInstance(TuJianSkillInFoPopLayer)
return TuJianSkillInFoPopLayer000000