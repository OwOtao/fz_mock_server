local Skill = require("app.models.skill.Skill")
local SkillConst = require("app.models.skill.SkillConst")
local SkillHelper = require("app.models.skill.SkillHelper")

local Role_Skill = {}

-- @author XiaoZhiWei
-- @time 2017/08/21 10:33:41
-- @desc 角色创建安全的列表table
local function roleCreateSafeTable(key, tab)
	key = Helper:getDef(key, tostring(User:getUserId()))
	return createSafeTable(key, tab, function(tab, valueName, valueFrom, valueTo)
		Collection:memoryCheat(User:getUserId(), valueName, valueFrom, valueTo)
	end)
end

-- 技能
function Role_Skill:getSkills()
	local selfCreatedSkills = self._selfCreatedSkillSystem:getSkillIdAndExpMap()
	return table.mergeMap(self.skills, selfCreatedSkills)
end

-- 获取准备的技能列表(偶遇用)
function Role_Skill:getPrepareSkills()
	local prepareTypeList = {
		"quanjiao",
		"zhaojia",
		"neigong",
		"qinggong",
		"jianfa",
		"daofa",
		"anqi",
		"bianfa",
		"gunfa",
		"shuangchi",
		"qinfa",
	}

	local retList = {}
	for k,pType in pairs(prepareTypeList) do
		local skillId = self:getPrepareSkillIdByType(pType)
		if skillId ~= nil then
			retList[skillId] = self:getSkill(skillId)
			-- 拳脚需要考虑拳脚2的武功
			if pType == "quanjiao" then
				local skillId2 = self:getPrepareSkillIdByType("quanjiao2")
				if skillId2 ~= nil then
					retList[skillId2] = self:getSkill(skillId2)
				end
			end
		end

		if self:getSkill("jiben"..pType) ~= nil then
			retList["jiben"..pType] = self:getSkill("jiben"..pType)
		end
	end

	return retList
end


function Role_Skill:getSkill(skillId)
	return self:getSkills()[skillId]
end

function Role_Skill:setSkill(id, skill)
	-- 文本提示
	if self == User:getRole() then
		if Skill:getSkill(id) == nil or Skill:getSkill(id).name == nil then
			if PRINT_MODE == 1 then
				print("资源文件缺失")
			end
			return
		end
		local skillName = Skill:getSkill(id).name
		local oldRoleSkill = self.skills[id]
		local exp, lv = 0, 0
		if MapIsEmpty(oldRoleSkill) == false then
			exp = oldRoleSkill.exp
			-- lv = Skill:getLv(exp)
			lv = self:conversionSkillExpAndLv("lv", exp)
		end
		local newRoleSkill = skill
		if MapIsEmpty(newRoleSkill) == false then
			exp = newRoleSkill.exp - exp
			lv = self:conversionSkillExpAndLv("lv", newRoleSkill.exp) - lv
		end

		if lv ~= 0 then
			if lv > 0 then
				RichPrint("main", "你的 【" .. tostring(skillName) .. "】 等级 +" .. tostring(lv))
			else
				RichPrint("main", "你的 【" .. tostring(skillName) .. "】 等级 -" .. tostring(math.abs(lv)))
			end
		else
		end
	end


	self.skills[id] = roleCreateSafeTable("player.skills."..tostring(id), skill)
	self:checkActiveZhaoIsDeblocking() 	-- add by XiaoZhiWei 2017/02/24 17:33:27 检查招式的解锁条件

	local RoleSecAttrHelper = require("app.models.role.RoleSecAttrHelper")
	RoleSecAttrHelper:updateSecAttrBySkillId(self, id)

	if id == "jibenneigong" then
		self:checkAttr("neigong")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/07 15:01:46
-- @desc 技能等级经验转换
function Role_Skill:conversionSkillExpAndLv(ctype, value)
	if ctype == nil or type(value) ~= "number" then
		return 0
	end
	return switch(ctype, {
		["exp"] = function() return Skill:getExp(value) end,
		["lv"] = function() return Skill:getLv(value) end,
		default = 0
	})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/07 14:57:11
-- @desc 获取技能经验
function Role_Skill:getSkillExp(skillId)
	if skillId == nil then
		return 0
	end
	local roleSkill = self:getSkill(skillId)
	if not roleSkill then
		return 0
	end
	return Helper:getDef(roleSkill.exp, 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/07 15:08:28
-- @desc 获取技能等级
function Role_Skill:getSkillLv(skillId, exp)
	if skillId == nil then
		return 0
	end
	exp = Helper:getDef(exp, 0)
	return Helper:getDef(self:conversionSkillExpAndLv("lv", self:getSkillExp(skillId) + exp), 0) + self:getBuffAttr(skillId.."Lv") -- add by XiaoZhiWei 2018/06/20 04:05:07 NPC特性增加buff,后续需考虑人物等级上限是否影响
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/10 11:28:57
-- @desc 获取技能等级 受角色等级限制
function Role_Skill:getSkillLvWithRoleLvLimit(skillId, exp)
	if skillId == nil then
		return 0
	end
	local skill = self:getSkillFile():getSkill(skillId)
	if MapIsEmpty(skill) == true then
		return 0
	end
	-- 只有普通类型的技能才有这个角色等级限制
	if self.onlyId == User:getRole().onlyId and skill.type == SKILL_TYPE_NORMAL then
		return math.min(self:getSkillLv(skillId, exp), self:getLv())
	else
		return self:getSkillLv(skillId, exp)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/07 15:16:30
-- @desc 技能提升等级所需经验值
function Role_Skill:getSkillNeedExp(skillId, addLv)
	if skillId == nil or type(addLv) ~= "number" then
		if DEBUG_MODE == 1 then
			-- assert(nil, "传递参数有误 skillId == "..tostring(skillId).." addLv == "..tostring(addLv))
		end
		return 0
	end
	local sillExp = self:getSkillExp(skillId)
	local skillLv = self:getSkillLv(skillId)
	
	local afterskillLv = math.min((skillLv + addLv), self:getSkillLvLimit(skillId))
	return Helper:getDef(self:conversionSkillExpAndLv("exp", afterskillLv) - sillExp, 0)
end

-- 根据当前武器获取技能
function Role_Skill:getCurrSkillIdWithWeapon()
	local prepareSkillType = self:getCurrTypeByWeapon()
	if prepareSkillType == "quanjiao" then
		prepareSkillType = "quanjiao1"
	end
	local prepareSkillId = self:getPrepareSkill(prepareSkillType)
	return prepareSkillId
end

---获取技能名字  如果不传ID 则默认是准备的技能名称
function Role_Skill:getCurrSkillName(skillId)
	if skillId == nil then
		skillId = self:getCurrSkillIdWithWeapon()
	end

	---如果技能名称为空
	local skill = Skill:getSkill(skillId)
	if skill == nil then
		return nil
	end
	if skill.name == nil then
		return nil
	else
		return skill.name
	end
	return nil
end

--@desc: 增加技能等级
--@author:LvBin
--@time:2025-09-20 16:57:48
--@skillId:
--@value: 
--@return
function Role_Skill:addSkillLv(skillId, value)
	local exp = self:getSkillNeedExp(skillId, value)

	local ret = self:canLevelUp(skillId, exp)
	if ret == true then
		local addExp = self:__addSkillExpUnchecked(skillId, exp)
		
		return true, addExp
	else
		PopText(tostring(ret))
		return false
	end
end

function Role_Skill:addSkillExpBySkillId(skillId,exp)
	local isUnCheckRoleLv = Skill:checkSkillIsUnlimited(skillId)
	if isUnCheckRoleLv == true then
		return self:addSkillExp(skillId,exp)
	else
		return self:addSkillExpLimitedByRoleLv(skillId,exp)
	end
end

-- 增加技能经验
function Role_Skill:addSkillExp(skillId, value)
	local ret = self:canLevelUp(skillId, value)

	if ret == true then
		local addExp = self:__addSkillExpUnchecked(skillId, value)
		return true, addExp
	else
		PopText(tostring(ret))
		return false
	end
end

--@desc: 添加武学经验,受角色等级限制
--@author:LvBin
--@time:2025-09-20 16:36:40
--@skillId:武学id
--@value: 添加的武学经验
--@return
function Role_Skill:addSkillExpLimitedByRoleLv(skillId, value)
	local roleLv = self:getLv()

	local currExp = self:getSkillExp(skillId)

	local roleExpLimit = self:conversionSkillExpAndLv("exp", roleLv + 1) - 1

	local addExp = Helper:getRange(value,0,roleExpLimit - currExp)
	
	return self:addSkillExp(skillId,addExp)
end

--@desc: 添加武学经验,不受检查条件限制
--@author:LvBin
--@time:2025-09-20 16:25:46
--@skillId:武学id
--@value: 添加的武学经验
--@return
function Role_Skill:__addSkillExpUnchecked(skillId, value)
	local skill = Skill:getSkill(skillId)
	
	if skill.type == SKILL_TYPE_SELFCREATE then
		return self:addSelfCreatedSkillExp(skillId, value)
	end

	local roleSkill = self:getSkill(skillId)

	local roleSkillExp = value

	local oldExp = 0
	if roleSkill then
		oldExp = roleSkill.exp
		roleSkillExp = oldExp + value
	end

	roleSkillExp = Helper:getRange(roleSkillExp,1,self:getSkillExpLimit(skillId))

	self:setSkill(skillId, {id = skillId, exp = roleSkillExp})

	local addExp = roleSkillExp - oldExp

	return addExp
end

function Role_Skill:addSelfCreatedSkillExp(skillId, value)
	local roleSkill = self:getSkill(skillId)

	if not roleSkill then
		print("有问题 自创武学技能必须存在")
		return false
	end

	-- 修正:等级不能为负
	if roleSkill.exp <= 0 then
		roleSkill.exp = 1
	end

	local afterExp = roleSkill.exp + value
	
	afterExp = math.min(afterExp, self:conversionSkillExpAndLv("exp", self:getSkillLvLimit(skillId)))
	
	self._selfCreatedSkillSystem:addSkillDataExp(skillId,afterExp - roleSkill.exp)
	
	--@desc 经验变化需要刷新自创武学数据
    self._selfCreatedSkillSystem:updataSelfCreatedSkillDataInSkillConfig(skillId)

	local skillName = Skill:getSkill(skillId).name
	local beforeLv = self:conversionSkillExpAndLv("lv", roleSkill.exp)
	local afterLv = self:conversionSkillExpAndLv("lv", afterExp)
	
	if afterLv - beforeLv > 0 then
		RichPrint("main", "你的 【"..tostring(skillName).."】 等级 +"..tostring(afterLv - beforeLv))
	elseif afterLv - beforeLv < 0 then
		RichPrint("main", "你的 【"..tostring(skillName).."】 等级 -"..tostring(math.abs(afterLv - beforeLv)))
	end
	
	return true
end

-- 判断学习条件是否成立
function Role_Skill:canLevelUp(skillId, exp)
	assert((skillId and exp), "Role_Skill:canLevelUp(skillId, exp) -> 数据异常，参数为空")
	-- add by XiaoZhiWei 2017/07/10 18:00:11 检查该技能是否为不需要检查的
	if Skill:checkSkillIsUnlimited(skillId) == true then
		return true
	end

	local skill = Skill:getSkill(skillId)

	local selfSkill = self:getSkill(skillId)
	local skillLv
	if not selfSkill then
		skillLv = self:conversionSkillExpAndLv("lv", exp)
		-- skillLv = Skill:getLv(0 + exp)
	else
		skillLv = self:getSkillLv(skillId, exp)
		-- skillLv = Skill:getLv(selfSkill.exp + exp)
	end
	if skillLv > self:getLv() then
		return "也许是缺乏实战经验，你对["..tostring(skill.name).."]的心法总是无法领会。"
	end
	return true
end

function Role_Skill:getSkillPrepare()
	return self.skillPrepare
end
--增加周公之术经验
function Role_Skill:addZhouGongZhiShuExp(exp)
	local ZhouGongZhiShuSkill = require("app.models.skill.skills.ZhouGongZhiShuSkill")
	local roleSkill = self:getSkill("zhougongzhishu")
	if MapIsEmpty(roleSkill) then
		roleSkill = {id = "zhougongzhishu",exp = 1}
		self:setSkill("zhougongzhishu",roleSkill)
		return true
	end
	local zhouGongZhiShu = inherit(roleSkill, ZhouGongZhiShuSkill)

	local success = zhouGongZhiShu:addExp(exp)
	return success
end

--获取周公之术等级
function Role_Skill:getZhouGongZhiShuLv()
	local ZhouGongZhiShuSkill = require("app.models.skill.skills.ZhouGongZhiShuSkill")
	local roleSkill = self:getSkill("zhougongzhishu")
	if MapIsEmpty(roleSkill) then
		return 0
	end
	local zhouGongZhiShu = inherit(roleSkill, ZhouGongZhiShuSkill)
	return zhouGongZhiShu:getLv(roleSkill.exp)
end

--获取周公之术当前阶段
function Role_Skill:getZhouGongZhiShuLvStatus()
	local roleSkill = self:getSkill("zhougongzhishu")
	if MapIsEmpty(roleSkill) then
		return 0
	end
	local ZhouGongZhiShuSkill = require("app.models.skill.skills.ZhouGongZhiShuSkill")
	local zhouGongZhiShu = inherit(roleSkill, ZhouGongZhiShuSkill)
	
	local lvStatus = zhouGongZhiShu:getZhouGongZhiShuLvStatus(roleSkill.exp)
	return lvStatus
end

--突破周公之术
function Role_Skill:breakZhouGongZhiShuLvLimit()
	local roleSkill = self:getSkill("zhougongzhishu")
	if MapIsEmpty(roleSkill) then
		return false
	end
	local ZhouGongZhiShuSkill = require("app.models.skill.skills.ZhouGongZhiShuSkill")
	local zhouGongZhiShu = inherit(roleSkill, ZhouGongZhiShuSkill)
	
	return zhouGongZhiShu:breakZhouGongZhiShuLvLimit()
end


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/01/17 19:10:13
-- @desc 获取所准备技能的Id
function Role_Skill:getPrepareSkillIdByType(ptype)
	if ptype == nil then
		return
	elseif ptype == "quanjiao" then
		ptype = "quanjiao1"
	end

	return self:getSkillPrepare()[ptype]
end


-- 判断是否可以准备或取消准备武功
function Role_Skill:canPrepareSkill(type, skillName)
	if type == "neigong" and self:isInCurrState(ROLE_CURR_STATE_DAZUO) then
		return false,"你正在打坐不能执行该操作"
	end

	if type == "neigong" and self:isInCurrState(ROLE_CURR_STATE_BIGUAN) then
		return false,"你正在闭关不能执行该操作"
	end

	local currSkillType = self:getFlag("武功准备类型")
	if type == currSkillType and self:isInCurrState(ROLE_CURR_STATE_LIANGONG) then
		return false,"你正在练功不能执行该操作"
	end
	return true
end

-- 获取技能准备类型
function Role_Skill:getPrepareType(skillId)
	if not skillId then
		return {}
	end
	local prepare = self:getSkillPrepare()
	if MapIsEmpty(prepare) then
		return {}
	end
	local rList = {}
	for k,v in pairs(prepare) do
		if v == skillId then
			table.insert(rList, k)
		end
	end
	return rList
end

function Role_Skill:prepareSkill(type, skillName)
	assert(type, "Role_Skill:prepareSkill(type, skillName) ->  类型不能为空")
	if skillName == "" then
        return false
    end

    local result,msg = self:canPrepareSkill(type, skillName)
    if not result then
        PopText(msg)
        return false
    end

	if self.skillPrepare == nil then
		self.skillPrepare = {}
	end

	if skillName ~= nil and string.len(skillName) > 0 then
		--@desc 检查技能能否被装备师门相关限制条件
		local result,msg = self:getPrepareSkillModel():skillCanEquipByFamily(type,skillName)
		if result == false then
			PopText(msg)
			return false
		end

		if type == "quanjiao2" then
			local skill1 = Skill:getSkill(self.skillPrepare["quanjiao1"])
			local skill2 = Skill:getSkill(skillName)
			if skill1 ~= nil then
				RichPrint("main", "你决定将["..tostring(skill2.name).."]组合["..tostring(skill1.name).."]做为你的[HIW基本拳脚NOR]。")
			else
				PopText("请先装备主拳脚武功！")
				return false
			end
		end
	end

	if type == "quanjiao1" then
		self.skillPrepare["quanjiao2"] = nil
	end

	self.skillPrepare[type] = skillName

	if type == "neigong" then
		self:checkAttr("neigong")
	end

	self:updateActiveZhaoStatus()

	return true
end

function Role_Skill:getPrepareSkill(type)
	if self.skillPrepare == nil then
		return nil
	end
	return self.skillPrepare[type]
end

function Role_Skill:clearPrepareSkills()
	if self.skillPrepare == nil then
		return
	end

	self.skillPrepare = {}
end

--删除指定技能
function Role_Skill:removeSkill(skillId)
	if not skillId then
		print("not skillId") 
		return false
	end
	local allSkill = self.skills

	for i,v in pairs(allSkill) do 
		if i == skillId then 
			allSkill[skillId] = nil
			return true
		end
	end

	local isTrue = self:getSelfCreatedSkillSystem():deleteSelfCreatedSkillDataBySkillId(skillId)
	if isTrue == true then
		return true
	end

	if PRINT_MODE == 1 then
		print(skillId.."  the skill is not exist or the id of skill is not correct")
	end

	return false
	
end

--------------------------------------------------------------------------------


-- 获取准备技能的系数
function Role_Skill:getPrepareSkillFactor(type, fName)
	assert(type, "Role_Skill:getPrepareSkillAndFactor(type, fName) -> 准备类型不能为空")
	assert(fName, "Role_Skill:getPrepareSkillAndFactor(type, fName) -> 系数名不能为空")

	local roleSkillId = self:getPrepareSkill(type)
	if not roleSkillId then
		if PRINT_MODE == 1 then
			-- print("Role_Skill:getPrepareSkillAndFactor(type, fName) -> 没有准备该类型的武功  "..tostring(type))
		end
		if type == "quanjiao1" or type == "quanjiao2" then
			type = "quanjiao"
		end
		roleSkillId = "jiben"..type
	end
	local skill = self:getSkillFile():getSkill(roleSkillId)
	local factor = skill:getFactor(fName)
	return factor
end

function Role_Skill:getSkillArray() -- 排好序
	local skills = self:getSkills()
	if skills then
		local function sortFunc(a, b)
			local skillA = Skill:getSkill(a.id)
			local skillB = Skill:getSkill(b.id)
			return skillA.onlyId < skillB.onlyId
		end

		local skillArray = {}
		for k,v in pairs(skills) do
			table.insert(skillArray, v)
		end
		table.sort(skillArray, sortFunc)
		-- Helper:print_lua_table(skillArray)
		return skillArray
	end
	return nil
end

-- @author XiaoZhiWei
-- @time 2017/04/10 14:38:56
-- @desc 获取技能有效等级(受角色等级限制)
function Role_Skill:getRealSkillLvWithRoleLvLimit(type)
	local realLv = 0
	local __type = type
	if __type == "quanjiao1" or __type == "quanjiao2" then
		__type = "quanjiao"
	end

	-- 拳脚类型需要特殊处理
	if type == "quanjiao" then
		type = "quanjiao1"
	end

	-- add by XiaoZhiWei 2017/04/10 10:14:06 有效等级 = 基本等级/2 + 准备的武功等级
	realLv = self:getSkillLv("jiben"..__type) / 2 + self:getSkillLvWithRoleLvLimit(self:getPrepareSkill(type)) -- add by XiaoZhiWei 2017/04/10 14:40:10 基本类型无需限制,特殊类型才有限制
	return realLv
end

-- 获取武功系数
function Role_Skill:getSkillFactor(sType, fName)
	if not sType or not fName then
		return 50
	end
	local roleSkill = self:getPrepareSkillIdByType(sType)
	local skill
	if not roleSkill then
		if sType == "quanjiao1" or sType == "quanjiao2" then
			sType = "quanjiao"
		end
		skill = Skill:getSkill("jiben"..sType)
	else
		skill = Skill:getSkill(roleSkill)
	end

	if not skill or not skill.factors or not skill.factors[fName] then
		return 50
	end
	return skill.factors[fName]
end

-- 获取武功有效等级即对应系数
function Role_Skill:getSkillLvAndFactor(sType, fName)
	return self:getRealSkillLvWithRoleLvLimit(sType), self:getSkillFactor(sType, fName)
end

-- 获得当前准备的攻击招式
function Role_Skill:getPrepareAttackSkill()
	local cType = self:getCurrTypeByWeapon()
	local skillId
	if cType == "quanjiao1" or cType == "quanjiao2" then
		cType = "quanjiao"
	end
	if cType == "quanjiao" then
		local quanjiao1 = self:getPrepareSkill("quanjiao1")
		local quanjiao2 = self:getPrepareSkill("quanjiao2")
		if not quanjiao1 and not quanjiao2 then
			skillId = "jibenquanjiao"
		elseif not quanjiao2 then
			return Skill:getSkill(quanjiao1)
		else
			-- 不需要随机, 直接返回两个拳脚
			return Skill:getSkill(quanjiao1), Skill:getSkill(quanjiao2)
		end
	else
		skillId = self:getPrepareSkill(cType)
	end
	if not skillId then
		return Skill:getSkill("jiben"..cType)
	else
		--根据子类型获取对应技能
		if self:checkSkillZhaoCanPreparedByWeaponSubType(skillId) == true then
			return Skill:getSkill(skillId)
		else
			return Skill:getSkill("jiben"..cType)
		end
	end
end

-- 获得当前准备的闪避招式
function Role_Skill:getPrepareDodgeSkill()
	local qinggong = self:getPrepareSkill("qinggong")
	if not qinggong then
		return Skill:getSkill("jibenqinggong")
	end
	return Skill:getSkill(qinggong)
end

-- 基本招架
function Role_Skill:getPrepareParrySkill()
	local zhaojia = self:getPrepareSkill("zhaojia")
	if not zhaojia then
		return Skill:getSkill("jibenzhaojia")
	end
	return Skill:getSkill(zhaojia)
end
-- 技能有效等级
function Role_Skill:getRealSkillLv(type)
	local realLv = 0
	local __type = type
	if __type == "quanjiao1" or __type == "quanjiao2" then
		__type = "quanjiao"
	end

	-- 拳脚类型需要特殊处理
	if type == "quanjiao" then
		type = "quanjiao1"
	end

	-- add by XiaoZhiWei 2017/04/10 10:14:06 有效等级 = 基本等级/2 + 准备的武功等级
	realLv = self:getSkillLv("jiben"..__type) / 2 + self:getSkillLv(self:getPrepareSkill(type))
	return realLv
end

function Role_Skill:getRealWugong()
	return self:getRealSkillLv(self:getCurrTypeByWeapon())
end

function Role_Skill:getRealNeigong()
	return self:getRealSkillLv("neigong")
end

function Role_Skill:getRealQinggong()
	return self:getRealSkillLv("qinggong")
end

function Role_Skill:getRealZhaojia()
	return self:getRealSkillLv("zhaojia")
end

-- @author XiaoZhiWei
-- @time 2017/06/17 15:17:49
-- @desc 获取N个等级最高的已装备技能
function Role_Skill:getHigestPreparedSkills(num)
	local retMap = {}
	num = Helper:getDef(num, 10)
	local prepareSkills = self:getSkillPrepare()
	local list = {}
	for pType,skillId in pairs(prepareSkills) do
		table.insert(list, self:getSkill(skillId))
	end

	table.sort(list, function(a, b)
		return a.exp > b.exp
	end)

	num = math.min(num, #list)
	for i=1,num do
		retMap[list[i].id] = list[i]
	end

	return retMap
end

-- 检查技能是否能够升级
function Role_Skill:checkCanLevelUp(skillId, exp)
	-- 参数错误，不能升级
	if not skillId or not exp then
		return false
	end
	local typeList = self:getPrepareType(skillId)
	-- 没有准备  不能升级
	if MapIsEmpty(typeList) then
		return false
	end

	local maxExp = 0
	--[[
		修改记录:
		  改为有 武功准备类型 的时候,去当前类型的基本技能,没有的时候取最大的基本类型
	]]
	local currSkillType = self:getFlag("武功准备类型")
	if currSkillType ~= 0 then
		local prepareList = SkillConst.PrepareList

		if prepareList[currSkillType] ~= nil and self:getSkill(prepareList[currSkillType]) ~= nil and self:getSkill(prepareList[currSkillType]).exp ~= nil then
			maxExp = self:getSkill(prepareList[currSkillType]).exp
		end
	else
		-- 没有准备类型 则取最大基本等级
		for k,v in pairs(typeList) do
			if v == "quanjiao1" or v == "quanjiao2" then
				v = "quanjiao"
			end
			local jbSkill = "jiben"
			local jbSkillId = jbSkill..tostring(v)
			local jbSkill = self:getSkill(jbSkillId)
			if jbSkill and jbSkill.exp and  maxExp < jbSkill.exp  then
				maxExp = jbSkill.exp
			end
		end
	end

	-- 练功最多可以到基本功等级 + 1
	do
		local jbSkillLv = self:conversionSkillExpAndLv("lv", maxExp)
		-- local jbSkillLv = Skill:getLv(maxExp)
		local roleLVmax = self:getLv()
		if  jbSkillLv + 1 > roleLVmax  then
			maxExp = self:conversionSkillExpAndLv("exp", roleLVmax)
		else
			maxExp = self:conversionSkillExpAndLv("exp", jbSkillLv + 1)				
		end
		
	end

	--@desc 练功不能超过自身武学上限等级
	maxExp = math.min(maxExp,self:conversionSkillExpAndLv("exp", self:getSkillLvLimit(skillId)))

	if maxExp < exp then
		return false , maxExp
	end
	return true, exp
end

--角色技能排序
-- 排序规则列表
--[[门派心法，读书识字，基本拳脚，基本招架，基本内功，基本轻功，基本剑法，基本刀法，基本暗器，基本鞭法，基本棍法，门派内功，
轻功，拳脚，兵器]]
function Role_Skill:skillSort()
	local skills = self:getSkills()
	if MapIsEmpty(skills) then
		return
	end

	local list, mlist, dlist, jlist, olist = {}, {}, {}, {}, {}

	for k,v in pairs(skills) do
		if PRINT_MODE == 1 then
			print(v.id)
		end
		local skill = Skill:getSkill(v.id)
		if skill.type == SKILL_TYPE_SPECIAL then
			-- 门派心法
			table.insert(mlist, v)
		elseif skill.type == SKILL_TYPE_DUSHU then
			-- 读书识字
			table.insert(dlist, v)
		elseif skill.type == SKILL_TYPE_BASE then
			-- 基本类型
			jlist[v.id] = v
		else
			-- 普通类型
			table.insert(olist, v)
		end
	end

	for i,v in ipairs(mlist) do
		table.insert(list, v)
	end

	for i,v in ipairs(dlist) do
		table.insert(list, v)
	end

	local tabName =
	{
		"jibenquanjiao",
		"jibenzhaojia",
		"jibenneigong",
		"jibenqinggong",
		"jibenjianfa",
		"jibendaofa",
		"jibenanqi",
		"jibenbianfa",
		"jibengunfa",
		"jibenshuangchi",
		"jibenqinfa"
	}

	for i=1,100 do
		if not tabName[i] then
			break
		end
		if jlist[tabName[i]] and type(jlist[tabName[i]]) ~= "nil" then
			table.insert(list, jlist[tabName[i]])
		end
	end

	for i,v in ipairs(olist) do
		table.insert(list, v)
	end

	return list
end

--战斗结束后添加见闻武学技能
function Role_Skill:addSeeSkillAfterFight(targetRole)
	if targetRole == nil then
		return 
	end
	local skillPrepare = targetRole:getAttr("skillPrepare")
	if DEBUG_MODE == 1 then
		print("对方准备武学")
		Helper:print_lua_table(skillPrepare)
	end
	if not MapIsEmpty(skillPrepare) then
		for k,skillId in pairs(skillPrepare) do
			self:addSeeSkill(skillId)
		end
	end
end

--筛选已见闻的武学技能
function Role_Skill:filtrateSeeSkill()
	local allSkill=self:getSkills()
	for skillId,skill in pairs(allSkill) do 
		self:addSeeSkill(skillId)
	end
end

--获取武学技能状态
function Role_Skill:getSkillStatus(skillId)
	if self:getSkillExp(skillId) > 0 then
		return SKILL_STATE_GRASP
	end

	for i,v in ipairs(self.seeSkills) do
		if v == skillId then
			return SKILL_STATE_NOGRASP
		end
	end

	return SKILL_STATE_NOSEE
end
	
--增加见闻武学技能
function Role_Skill:addSeeSkill(skillId)
	if skillId == nil then
		return
	end

	-- if self:getSkillExp(skillId) > 0 then
	-- 	print("已掌握的武学不能添加到已见闻列表 skillId = ",skillId)
	-- 	return
	-- end
	if self ~= User:getRole() then
		return
	end 

	local skill = Skill:getSkill(skillId)
	
	if MapIsEmpty(skill) then
		return 
	end

	--自创武学不加入已见闻列表
	if skill.type == SKILL_TYPE_SELFCREATE then
		return
	end
	
	if MapIsEmpty(self.seeSkills) then
		table.insert(self.seeSkills,skillId)
	else
		local isHave = false
		for i,v in ipairs(self.seeSkills) do
			if v == skillId then
				isHave = true
				break
			end
		end
		if isHave == false then
			table.insert(self.seeSkills,skillId)
		end
	end
end

--删除见闻武学技能
function Role_Skill:deleteSeeSkill(skillId)
	if skillId == nil then
		return
	end
	if MapIsEmpty(self.seeSkills) then
		return
	end

	for i,v in ipairs(self.seeSkills) do
		if v == skillId then
			table.remove(self.seeSkills,i)
			break
		end
	end
end

function Role_Skill:getSpecialZhiShiSkillLv(skillId)
	local skill = Skill:getSkill(skillId)
	if skill == nil then
		return 0
	end

	if skill:checkIsSpecialZhiShiSkill(skillId) then
		return skill:getLv(self:getSkillExp(skillId))
	end

	return 0
end

function Role_Skill:setSkillBreId(skillId,breId)
	local skillBreakData = self:getAttr("skillBreakData")
	skillBreakData[skillId] = breId
end

function Role_Skill:getSkillBreId(skillId)
	local skillBreakData = self:getAttr("skillBreakData")
	if skillBreakData[skillId] then
		return skillBreakData[skillId]
	end
	return self:getSkillBreakThroughSystem():getSkillDefaultBreId()
end

--@desc: 获取武学等级上限
--@author:LvBin
--@time:2022-01-14 11:46:09
--@skillId: 
--@return
function Role_Skill:getSkillLvLimit(skillId)
	return self:getSkillBreakThroughSystem():getSkillBreakThroughMap(skillId).Blevel
end

--@desc: 获取武学经验上限
--@author:LvBin
--@time:2024-08-07 16:25:57
--@skillId: 
--@return
function Role_Skill:getSkillExpLimit(skillId)
	return self:conversionSkillExpAndLv("exp", self:getSkillLvLimit(skillId))
end

function Role_Skill:getSkillBreakThroughSystem()
    return self._skillBreakThroughSys
end

function Role_Skill:getPrepareSkillModel()
	if self.__prepareSkillModel == nil then
        local RolePrepareSkill = require("app.models.RolePrepareSkill.RolePrepareSkill")
	    self.__prepareSkillModel = RolePrepareSkill:create(self)
    end

	return self.__prepareSkillModel
end

--@desc: 能否进行武学进阶
--@author:LvBin
--@time:2024-07-22 16:57:12
--@skillAdvance: src.app.models.skill.SkillAdvance.SkillAdvance#SkillAdvance
--@return
function Role_Skill:isCanSkillAdvance(skillAdvance)
    if self:getItemCount(skillAdvance:getItemId()) < skillAdvance:getItemNum() then
        return false,"妙法秘录不足，无法学习该武学"
    end

	if self:getSkillLv(skillAdvance:getNeedSkillId()) < skillAdvance:getNeedSkillLv() then
		return false,"你尚未符合此武学传授条件，请修行足够后再来找我吧"
	end
	
    if skillAdvance:getNeedActiveZhaoId1() then
        if self:getSkillZhaoExp(skillAdvance:getNeedActiveZhaoId1()) < skillAdvance:getNeedActiveZhaoExp1() then
            return false,"你尚未符合此武学传授条件，请修行足够后再来找我吧"
        end
    end

    if skillAdvance:getNeedActiveZhaoId2() then
        if self:getSkillZhaoExp(skillAdvance:getNeedActiveZhaoId2()) < skillAdvance:getNeedActiveZhaoExp2() then
            return false,"你尚未符合此武学传授条件，请修行足够后再来找我吧"
        end
    end

	return true
end

--@desc: 开始武学进阶
--@author:LvBin
--@time:2024-07-22 17:11:42
--@skillAdvance: src.app.models.skill.SkillAdvance.SkillAdvance#SkillAdvance
--@return
function Role_Skill:startSkillAdvance(skillAdvance)
	self:addSkillLv(skillAdvance:getSkillId(), skillAdvance:getSkillLv())

	if skillAdvance:getActiveZhaoId1() then
		self:addSkillZhaoExp(skillAdvance:getActiveZhaoId1(), skillAdvance:getActiveZhaoExp1())
	end

	if skillAdvance:getActiveZhaoId2() then
		self:addSkillZhaoExp(skillAdvance:getActiveZhaoId2(), skillAdvance:getActiveZhaoExp2())
	end

	self:addItemCount(skillAdvance:getItemId(),-skillAdvance:getItemNum())
end

return Role_Skill000000000000000