local NewClass = require("third.class.NewClass")

local TuJianActiveZhaoInFoLayer = require("app.views.layer.TuJianLayer.TuJianActiveZhaoInFoLayer")
local SelfCreatedSkillConstants = require("app.models.SelfCreatedSkillSystem.SelfCreatedSkillConstants")
local AnimFightLayer = require("app.views.layer.FightLayer.AnimFightLayer")
local TuJianUtil = require("app.models.TuJian.TuJianUtil")
local StringUtil = require("app.extends.StringUtil")

local SkillGoodsInfoPresenter = {}

function SkillGoodsInfoPresenter:create(goods)
    local o = SkillGoodsInfoPresenter.new()
	o:init(goods)
    return o
end

function SkillGoodsInfoPresenter:init(goods)
	self.__ui = require("app.views.ui.GoodsInfoUI.SkillGoodsInfoUI"):create()
	self.__goods = goods

	local skillId = goods:getViewInfo()[1]
	self.__skill = Skill:getSkill(skillId)
end

function SkillGoodsInfoPresenter:getUI()
    return self.__ui
end

function SkillGoodsInfoPresenter:showUI()
    self.__ui:setTitle("武学信息")

	self:__setName()
	self:__setSkillDetailDsc()
	self:__setActiveZhao()
	self:__setAutoZhao()
	self:__showAnim()

    self.__ui:showUI()
end

function SkillGoodsInfoPresenter:hide()
	if self._animRoleLayer then
		local animRole = self._animRoleLayer:getRoleByTeamIdAndInTeamId(1, 1)
		if animRole then
			animRole._action = nil
			animRole:setVisible(false)
			self._playAnim = nil
		end

		self._animRoleLayer:removeFromParent()
		self._animRoleLayer = nil
	end

    self.__ui:hideUI()
end

function SkillGoodsInfoPresenter:setButtonBackVisible(visible)
    self.__ui:setButtonBackVisible(visible)
end

function SkillGoodsInfoPresenter:setButtonBack(func)
    self.__ui:setButtonBack(function()
        if func then
            func()
        end
    end)
end

function SkillGoodsInfoPresenter:__setName()
    self.__ui:setTextName(self.__skill:getName())
end

function SkillGoodsInfoPresenter:__setSkillDetailDsc()
    self.__ui:setTextDesc(self.__skill:getDsc())
end

function SkillGoodsInfoPresenter:__setActiveZhao()
    local zhaoList = Skill:getSkillZhaoList(self.__skill.id)
    
	if #zhaoList <= 0 then
		self.__ui:setActiveZhaoVisible(false)
	else
		self.__ui:setActiveZhaoVisible(true)

		local zhaoInfo = {}

		for k, zhao in ipairs(zhaoList) do
			local info = {}
			info.name = zhao:getName()
			info.func = function()
				local layer = TuJianActiveZhaoInFoLayer:getInstance()
				local maxZhao = Skill:getActiveZhao(zhao:getId().."10")
				layer:showAllInfo(maxZhao:getName(),maxZhao:getDesc(), maxZhao:getLearnConditionListWithCN(),maxZhao:getUseConditonListWithCN())	
			end
	
			table.insert(zhaoInfo, info)
		end

		self.__ui:setActiveZhao(zhaoInfo)
	end
end

function SkillGoodsInfoPresenter:__setAutoZhao()
	local skills = self.__skill:getAutoSkills()

	if #skills > 0 then
		self.__ui:setAutoZhaoVisible(true)

		local autoZhaoInfo = {}

		autoZhaoInfo.text = "共有"..Helper:numberCast(#skills).."招"

		autoZhaoInfo.func = function()
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
	
			local skillName = self.__skill.name
	
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

		self.__ui:initAutoZhaoPanel(autoZhaoInfo)
	else
		self.__ui:setAutoZhaoVisible(false)
	end

end

function SkillGoodsInfoPresenter:__showAnim()
	local skills = self.__skill:getAutoSkills()

	if #skills <= 0 then
		self.__ui:getAnimFightAreaPanel():setVisible(false)
		return
	end

	self._playAnim = true

	local titalIndex = TuJianUtil:getSkillDefalutTuJianType(self.__skill.id)

	self.__ui:getAnimFightAreaPanel():setVisible(true)

	local leftPositions = {}
    local rightPositions = {}

	table.insert(leftPositions, cc.p(self.__ui:getLeftFightPos1()))
	table.insert(rightPositions, cc.p(self.__ui:getRightFightPos1()))

    if self._animRoleLayer then
        self._animRoleLayer = nil
	end
	
	self._animRoleLayer = AnimFightLayer:createInPanel(self.__ui:getAnimFightAreaPanel())
    self._animRoleLayer:FightStart(leftPositions, rightPositions)

	local animRole = self._animRoleLayer:getRoleByTeamIdAndInTeamId(1, 1)
	local daocaoren = self._animRoleLayer:getRoleByTeamIdAndInTeamId(2, 1)
    animRole:setVisible(true)
	daocaoren:setVisible(true)
	daocaoren.anim:setPositionX(daocaoren.anim:getPositionX() + 15)

	local weapontype = nil
	if #self.__skill.weapontype > 0 then
		weapontype = self.__skill.weapontype[math.random(1,#self.__skill.weapontype)]
	end

	-- 设置武器
	local weaponAttachmentName = self:__getCurrWeaponimage(titalIndex,weapontype)
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
		local standAnimName = self.__skill:getStandAnimName()
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
						local JumpForwardAnimName = self.__skill:getJumpForwardAnimName()
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
	
	local animList = self:__getSkillAnimList(skills,weapontype)

	if not MapIsEmpty(animList) then
		if #animList > 3 then
			addAnimation(animList)
		else
			local jibenSkills = self:__getJiBenSkills(titalIndex)
			animList = table.mergeArray(animList, self:__getSkillAnimList(jibenSkills,weapontype))
			addAnimation(animList)
		end
	else
		local jibenSkills = self:__getJiBenSkills(titalIndex)
		local jibenAnimList = self:__getSkillAnimList(jibenSkills,weapontype)
		addAnimation(jibenAnimList)
	end
end

function SkillGoodsInfoPresenter:__getCurrWeaponimage(subType,weapontype)
    return TuJianUtil:getCurrWeaponimage(subType,weapontype)
end

function SkillGoodsInfoPresenter:__getSkillAnimList(skills,weapontype)
	return TuJianUtil:getSkillAnimList(skills,weapontype)
end

function SkillGoodsInfoPresenter:__getJiBenSkills(titalIndex)
	return TuJianUtil:getJiBenSkills(titalIndex)
end

return NewClass("SkillGoodsInfoPresenter", {}, SkillGoodsInfoPresenter)0000