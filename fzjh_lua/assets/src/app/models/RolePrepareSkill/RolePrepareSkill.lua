local newClass = require("third.class.NewClass")

local SkillConst = require("app.models.skill.SkillConst")

local RolePrepareSkill = {}

function RolePrepareSkill:create(role)
    local p = RolePrepareSkill.new()
    p:setRole(role)
    return p
end

function RolePrepareSkill:setRole(role)
    self.__role = role
end

--@desc: 修复装备武学设计冲突,取消所有装备的外门武学，如果取消的外门武学正在练功闭关等状态中，自动结算后并取消装备
--@author:LvBin
--@time:2023-10-09 11:24:07
--@return
function RolePrepareSkill:repairPrepareSkill()
	if self.__role:getInheritFlag("repairPrepareSkill") ~= 0 then
		return
	end

	local AsyncFunction = require("third.async.AsyncFunction")

	local skillPrepare = self.__role:getSkillPrepare()
		
	local familyId = self.__role:getFamilyId()

	local lianGongSystem = self.__role:getLianGongSystem()

	for _preType,_skillId in pairs(skillPrepare) do
		local skill = Skill:getSkill(_skillId)

		if skill:isUnSectSkill(familyId) then
			if _preType == "neigong" and self.__role:isInCurrState(ROLE_CURR_STATE_DAZUO) then
				self.__role:stopDaZuo()
			end
		
			if _preType == "neigong" and self.__role:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
				self.__role:stopBiGuan()
			end

			if _preType == self.__role:getFlag("武功准备类型") and _skillId == lianGongSystem:getSkillId() and self.__role:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
				local ok, msg = AsyncFunction:asyncAwaitWithCallback(lianGongSystem.stopLianGongOnline, lianGongSystem, "callback",nil)
			end

			self.__role:prepareSkill(_preType, nil)
		end
	end

	
	self.__role:setInheritFlag("repairPrepareSkill",1)
end


--@desc: 技能能否被装备(门派心法和师门建筑的限制条件)
--@author:LvBin
--@time:2023-09-19 16:43:04
--@type: 装备类型
--@skillId: 
--@return
function RolePrepareSkill:skillCanEquipByFamily(type,skillId)
	local familyId = self.__role:getFamilyId()

	local skill = Skill:getSkill(skillId)

	local needSkillId,needLv = skill:getMcmrestrict()
	 
	if skill:isUnSectSkill(familyId) then
		--@desc 是否是新增的武学装备类型
		local function isAddEquipType()
			local skillFirstType = SkillConst:getSkillTypeByPrepareType(type)
		
			local skillPrepare = self.__role:getSkillPrepare()
		
			for _preType,_skillId in pairs(skillPrepare) do
				local _skillFirstType = SkillConst:getSkillTypeByPrepareType(_preType)
		
				if skillFirstType == _skillFirstType and Skill:getSkill(_skillId):isUnSectSkill(familyId) then
					return false
				end
			end
		
			return true
		end

		local canPrepareSkillNum,skillLvLimit = 0,0

		if self.__role:isYouXia() then
			canPrepareSkillNum,skillLvLimit = self:getYouXiaCanPrepareSkillLimit()
		else
			canPrepareSkillNum,skillLvLimit = self.__role:getTeacherBuildSystem():getTeacherBuildCanPrepareSkillLimit()
		end

		if canPrepareSkillNum == 0 then
			return false,"当前不可准备门外武学，请提升论武堂的名位等级后再准备武学"
		end
		
		if isAddEquipType() and self:getUnSectPrepareSkillNum() >= canPrepareSkillNum then
			return false,"当前准备的外门武学已超出"..canPrepareSkillNum.."个，请更换后再准备此武学"
		end

		if needLv > skillLvLimit then
			return false,"当前门派心法等级不足，准备失败"
		end
	else
		if needSkillId and self.__role:getSkillLv(needSkillId) < needLv then
			return false,"当前门派心法等级不足，准备失败"
		end
	end

	return true
end

--@desc: 获取装备的外门武学数量
--@author:LvBin
--@time:2023-09-19 18:36:24
--@return
function RolePrepareSkill:getUnSectPrepareSkillNum()
	local skillNum = 0

	local skillPrepare = self.__role:getSkillPrepare()

	if MapIsEmpty(skillPrepare) then
		return 0
	end

	local familyId = self.__role:getFamilyId()

	local filtTab = {}

	for _preType,skillId in pairs(skillPrepare) do
		local skill = Skill:getSkill(skillId)
		
		local skillFirstType = SkillConst:getSkillTypeByPrepareType(_preType)

		--@desc 武学类型一相同的武学，算一门外门武学
		if skill:isUnSectSkill(familyId) and filtTab[skillFirstType] ~= true then
			skillNum = skillNum + 1

			filtTab[skillFirstType] = true
		end
	end

	return skillNum
end

function RolePrepareSkill:getYouXiaCanPrepareSkillLimit()
	local mcmrestrictLevel = require("script.others.mcmrestrictLevel")["1"]

	local canPrepareSkillNum = 0
	
	local skillLvLimit = 0

	local mcmrestrictId = self.__role:getAttr("mcmrestrictId")

	if mcmrestrictId and mcmrestrictLevel[tostring(mcmrestrictId)] then
		canPrepareSkillNum = mcmrestrictLevel[tostring(mcmrestrictId)].count

		skillLvLimit = mcmrestrictLevel[tostring(mcmrestrictId)].mcmrestrict
	end
	
	return canPrepareSkillNum,skillLvLimit
end

return newClass("RolePrepareSkill", {}, RolePrepareSkill)
0000000000000