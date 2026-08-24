local Skill = require("app.models.skill.Skill")
local SkillUtil = require("app.models.skill.SkillUtil")
local SkillConst = require("app.models.skill.SkillConst")

local Role_ActiveZhao = {}

local methodsTab =
{
	["quanjiao1"] = SKILL_METHOD_TYPE_QUANJIAO,
	["quanjiao2"] = SKILL_METHOD_TYPE_QUANJIAO,
	["neigong"] = SKILL_METHOD_TYPE_NEIGONG,
	["qinggong"] = SKILL_METHOD_TYPE_QINGGONG,
	["zhaojia"] = SKILL_METHOD_TYPE_ZHAOJIA,
	["jianfa"] = 5,
	["daofa"] = 5,
	["gunfa"] = 5,
	["anqi"] = 5,
	["bianfa"] = 5,
	["shuangchi"] = 5,
	["qinfa"] = 5,
}

local CHEKC_TIME = 0
-- local ZHAO_MAX_LV = 9 -- add by XiaoZhiWei 2017/03/17 11:49:21 招式最高重数
local ZHAO_MAX_COUNT = 6 -- add by XiaoZhiWei 2017/03/17 11:49:39 招式最多个数
--[[
	-- 主动招式
	activeZhaos =
	{
		liumaishenjian = {id = "liumaishenjian", exp = 999},
		leitingyiji = {id = "leitingyiji", exp = 999},
		sanhuantaoyue = {id = "sanhuantaoyue", exp = 999},
	},
]]
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 19:42:21
-- @desc 招式技能等级经验换算公式 retType "exp" "lv" 返回类型
function Role_ActiveZhao:conversionZhaoExpAndLv(retType, value, potEfficiency)
	if Helper:checkParamsError("Role_ActiveZhao:conversionZhaoExpAndLv(retType, value, potEfficiency)", 3, retType, "string", value, "number", potEfficiency, "number") == true then
		return 0
	end
	return switch(retType,
	{
		-- ["exp"] = function() return 0.15*(100*value)^3/500*100/potEfficiency end, -- add by XiaoZhiWei 2017/03/01 15:55:21 等级换算成经验
		-- ["lv"] = function() return (value/100*potEfficiency*500/0.15)^(1/3)/100 end, -- add by XiaoZhiWei 2017/03/01 15:55:31 经验换算成等级
		["exp"] = function() return 0.15*(100*value)^3/500*100/potEfficiency/10 end,
		["lv"] = function() return math.max(Helper:mathFloor((value/10*potEfficiency*500/0.15)^(1/3)/100), 1) end, -- add by XiaoZhiWei 2017/03/30 19:11:15 公式修正 策划提出
		default = 0
	})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/23 21:37:39
-- @desc 获取招式 学习 或 使用文本 UI界面使用
function Role_ActiveZhao:getZhaoCondtionDesc(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:getZhaoCondtionDesc(zhaoId)", 1, zhaoId, "string") == true then
		return {}
	end
	local zhaoLv = self:getSkillZhaoLv(zhaoId)
	local zhaoExp = self:getSkillZhaoExp(zhaoId)
	-- add by XiaoZhiWei 2017/04/01 20:31:21 描述需要根据招式的重数来显示
	if zhaoLv > 1 then
		zhaoId = zhaoId..zhaoLv
	else
	end
	local zhao = self:getSkillFile():getActiveZhao(zhaoId)
	-- add by XiaoZhiWei 2017/06/23 12:10:44 修改招式使用条件判断准则,由等级判断修改为经验判断
	if zhaoExp <= 0 then
		return zhao:getLearnConditionListWithCN()
	else
		return zhao:getUseConditonListWithCN()
	end
end

-- @author LvBin
-- @time 2018/07/17 15:37:39
-- @desc 获取招式描述文本
function Role_ActiveZhao:getZhaoUseDesc(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:getZhaoUseDesc(zhaoId)", 1, zhaoId, "string") == true then
		return ""
	end
	local zhaoLv = self:getSkillZhaoLv(zhaoId)
	if zhaoLv > 1 then
		zhaoId = zhaoId..zhaoLv
	else
	end	
	local zhao = self:getSkillFile():getActiveZhao(zhaoId)

	return zhao:getDesc()
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 18:00:14
-- @desc 获取招式经验
function Role_ActiveZhao:getSkillZhaoExp(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:getSkillZhaoExp(zhaoId)", 1, zhaoId, "string") == true then
		return 0
	end
	local activeZhaos = self:getAttr("activeZhaos")
	if MapIsEmpty(activeZhaos) == true or activeZhaos[zhaoId] == nil then
		return 0
	end
	return Helper:getDef(tonumber(activeZhaos[zhaoId].exp), 0)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 18:06:10
-- @desc 获取招式等级
function Role_ActiveZhao:getSkillZhaoLv(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:getSkillZhaoLv(zhaoId)", 1, zhaoId, "string") == true then
		return 0
	end
	local zhaoExp = self:getSkillZhaoExp(zhaoId)
	if zhaoExp == 0 then
		return 0
	end

	return Helper:getRange(Helper:getDef(self:conversionZhaoExpAndLv("lv", zhaoExp, self:getSkillZhaoPotEfficiency(zhaoId)), 1), 1, self:getZhaoLvLimit(zhaoId))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 17:48:11
-- @desc 获取技能招式
function Role_ActiveZhao:getSkillZhao(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:getSkillZhao(zhaoId)", 1, zhaoId, "string") == true then
		return
	end
	local skillZhao = self:getAttr("activeZhaos")
	if MapIsEmpty(skillZhao) == true then
		return
	else
		return skillZhao[zhaoId]
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/03 15:53:53
-- @desc 判断招式是否能够升级
function Role_ActiveZhao:checkSkillZhaoCanUp(zhaoId, addExp)
	if Helper:checkParamsError("Role_ActiveZhao:checkSkillZhaoCanUp(zhaoId, addExp)", 2, zhaoId, "string", addExp, "number") == true then
		return false, 0
	end
	--[[
		获取招式等级
		获取技能等级
		判断招式等级和技能等级的差值
		判断招式是否能够升级
		不能升级的情况,需重新计算
	]]
	local msg = ""
	local zhaoExp = self:getSkillZhaoExp(zhaoId)
	local skillId = Skill:getSkillIdByZhaoId(zhaoId)

	if self:getSkillLv(skillId) <= 0 then -- add by XiaoZhiWei 2017/03/31 15:56:12 武功不存在,则招式的学习条件不符合
		return false, 0, "武功不存在"
	end

	local maxZhaoLv = self:getZhaoLvLimit(zhaoId)
	
	local maxExp = self:getZhaoExpLimit(zhaoId,maxZhaoLv)

	if zhaoExp >= maxExp then
		return false, 0,"熟练度已达上限"
	end

	
	addExp = Helper:getRange(math.min(addExp,  maxExp - zhaoExp), 0)
	return true, addExp
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 17:15:29
-- @desc 增加招式经验
function Role_ActiveZhao:addSkillZhaoExp(zhaoId, addExp)
	if Helper:checkParamsError("Role_ActiveZhao:addSkillZhaoExp(zhaoId, addExp)", 2, zhaoId, "string", addExp, "number") == true then
		return
	end
	-- add by XiaoZhiWei 2017/04/26 01:35:53 雇佣兵模式下,不需要判断,直接加成
	local ret
	if self.isGuYongBing ~= true then
		ret, addExp = self:checkSkillZhaoCanUp(zhaoId, addExp)  -- add by XiaoZhiWei 2017/03/03 17:38:22 判断是否能够升级,重新计算一下能加的经验值
		if ret == false then
			return
		end
	end
	local roleSkillZhao = self:getSkillZhao(zhaoId)
	if MapIsEmpty(roleSkillZhao) == true then
		roleSkillZhao = {id = zhaoId, exp = addExp}
	else
		roleSkillZhao = {id = zhaoId, exp = roleSkillZhao.exp + addExp}
	end
	self:setSkillZhao(zhaoId, roleSkillZhao)
	return ret,addExp
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 17:54:25
-- @desc 增加招式等级
function Role_ActiveZhao:addSkillZhaoLv(zhaoId, addLv)
	if Helper:checkParamsError("Role_ActiveZhao:addSkillZhaoLv(zhaoId, addLv)", 2, zhaoId, "string", addLv, "number") == true then
		return
	end
	local roleSkillZhao = self:getSkillZhao(zhaoId)
	local potEfficiency = self:getSkillZhaoPotEfficiency(zhaoId)
	local ret, addExp = true, 0
	if MapIsEmpty(roleSkillZhao) == true then
		ret, addExp = self:checkSkillZhaoCanUp(zhaoId, self:conversionZhaoExpAndLv("exp", addLv, potEfficiency)) -- add by XiaoZhiWei 2017/03/03 17:38:22 判断是否能够升级,重新计算一下能加的经验值
		if ret == false then
			return
		end
		roleSkillZhao = {id = zhaoId, exp = addExp}
	else
		local zhaoLv = self:getSkillZhaoLv(zhaoId)
		addExp = self:conversionZhaoExpAndLv("exp", zhaoLv + addLv, potEfficiency) - self:conversionZhaoExpAndLv("exp", zhaoLv, potEfficiency) -- add by XiaoZhiWei 2017/02/23 19:54:53 当前等级所需经验值 到 需要等加到的等级的经验值 的差值 即为所需经验值

		ret, addExp = self:checkSkillZhaoCanUp(zhaoId, addExp)  -- add by XiaoZhiWei 2017/03/03 17:38:22 判断是否能够升级,重新计算一下能加的经验值
		if ret == false then
			return
		end
		roleSkillZhao = {id = zhaoId, exp = roleSkillZhao.exp + addExp}
	end
	self:setSkillZhao(zhaoId, roleSkillZhao)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 15:45:01
-- @desc 学习主动招式
function Role_ActiveZhao:setSkillZhao(zhaoId, roleSkillZhao)
	if Helper:checkParamsError("Role_ActiveZhao:setSkillZhao(zhaoId, roleSkillZhao)", 2, zhaoId, "string", roleSkillZhao, "table") == true then
		return
	end
	local skillZhao = self:getAttr("activeZhaos")
	if MapIsEmpty(skillZhao) == true then
		skillZhao = {}
	end

	skillZhao[zhaoId] = roleSkillZhao

	self:setAttr("activeZhaos", skillZhao)

	-- add by XiaoZhiWei 2017/04/01 16:29:53 招式经验修复过一次, 这是标记,学会了招式又没有标记,则需要将标记打上,否自招式经验会被扣除
	if self:getFlag("resetActiveZhaos") ~= 1 then
		self:setFlag("resetActiveZhaos", 1)
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/20 15:25:56
-- @desc 获取技能的所有主动招式
function Role_ActiveZhao:getSkillZhaoList(skillId)
	-- if PRINT_MODE == 1 then
	-- 	print("Role_ActiveZhao:getSkillZhaoList(skillId)", skillId)
	-- end
	local zhaoList = self:getSkillFile():getSkillZhaoList(skillId)
	for i,zhao in ipairs(zhaoList) do
		-- if zhao:getId() == "huifu" then
		-- 	zhao.lv = 1
		-- 	zhao.exp = 1
		-- else
			local roleSkillZhao = self:getSkillZhao(zhao:getId())
			if MapIsEmpty(roleSkillZhao) == true then
			else
				zhao.lv = self:getSkillZhaoLv(zhao:getId())
				zhao.exp = self:getSkillZhaoExp(zhao:getId())
			end
		-- end
		zhao._currskillId = skillId
	end
	return zhaoList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/23 16:02:04
-- @desc 获取技能的所有主动招式Map
function Role_ActiveZhao:getSkillZhaoMap(skillId)
	local retMap = {}
	local zhaoList = self:getSkillZhaoList(skillId)
	for i,zhao in ipairs(zhaoList) do
		-- if zhao:getId() == "huifu" then
		-- 	zhao.lv = 1
		-- 	zhao.exp = 1
		-- else
			local roleSkillZhao = self:getSkillZhao(zhao:getId())
			if MapIsEmpty(roleSkillZhao) == true then
			else
				zhao.lv = self:getSkillZhaoLv(zhao:getId())
				zhao.exp = self:getSkillZhaoExp(zhao:getId())
				zhao._currskillId = skillId
				retMap[zhao:getId()] = zhao
			end
		-- end
	end
	return retMap
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/03 14:45:26
-- @desc 战斗后熟练度的计算
function Role_ActiveZhao:calcActiveZhaoUseTimes(fightRole)
	if MapIsEmpty(fightRole) == true then
		return
	end

	local dayMaxExp = 40 -- add by XiaoZhiWei 2017/03/30 18:02:38 修正 上限40点
	if DEBUG_MODE == 1 then -- add by XiaoZhiWei 2017/03/13 12:01:00 测试期间,上限控制为200
		dayMaxExp = 20
	end

	-- 每次攻击20点经验,每天最多获取2000点经验
	-- local zhaoList = self:getPreparedActiveZhaoIdArray()

	--战斗开始时的招式数组
	local fightStartZhaoIdArray = Helper:getDef(fightRole.fightStartPreparedActiveZhaoIdArray,{})

	--战斗完成时的招式数组
	local fightFinishZhaoIdArray = fightRole:getRole():getPreparedActiveZhaoIdArray()

	local zhaoList = Helper:arrayUnion(fightStartZhaoIdArray,fightFinishZhaoIdArray)

	if MapIsEmpty(zhaoList) == true then
		return
	else
		for i,zhaoId in pairs(zhaoList) do
			if zhaoId == "huifu" then
			else
				local baseZhaoId = Skill:getBaseZhaoId(zhaoId) -- add by XiaoZhiWei 2017/03/16 17:52:04 招式之间的关联招式ID (例:huifu招式1-9重,关联招式Id为huifu)
				local currLv = self:getSkillZhaoLv(baseZhaoId) -- 增加前的招式等级
				local dayExp = self:getDayFlag(baseZhaoId) 	-- 记录每天记录的增加量

				print(" Role_ActiveZhao:calcActiveZhaoUseTimes(fightRole)", currLv, dayExp, zhaoId, fightRole:getActiveZhaoUseTimes(zhaoId))
				if baseZhaoId ~= nil and fightRole:getActiveZhaoUseTimes(zhaoId) > 0 and dayExp < dayMaxExp then
					local atkExp = fightRole:getActiveZhaoUseTimes(zhaoId) * 2	 -- add by XiaoZhiWei 2017/03/30 18:01:52 修正 每次获得2点
					local addExp = Helper:getRange(math.min(atkExp, dayMaxExp - dayExp), 0)  -- 获取能增加的量,攻击总经验值和当天剩余的量之间取最小值
					self:addSkillZhaoExp(baseZhaoId, addExp)
					self:setDayFlag(baseZhaoId, dayExp + addExp) -- 更新每天记录的增加量

					self:checkZhaoIsLevelUp(baseZhaoId, currLv)
				end
			end
		end
	end
end

-------------------------------------------------------------------------------- 主动技能

--[[


]]


--[[
	preparedActiveZhao = -- 准备的招式,分兵器和拳脚两种
	{
		bingqi = {},
		quanjiao = {}
	},
]]

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 11:26:32
-- @desc 获取准备的招式列表
function Role_ActiveZhao:getZhaoPrepareListWithZhaoType(zhaoType)
	if Helper:checkParamsError("Role_ActiveZhao:getZhaoPrepareListWithZhaoType(zhaoType)", 1, zhaoType, "string") == true then
		return {}
	end
	zhaoType = switch(zhaoType, {["兵器"] = "bingqi", ["拳脚"] = "quanjiao", bingqi = "bingqi", quanjiao = "quanjiao", default = nil})
	if zhaoType == nil then
		return {}
	end
	local prepareZhaoList = self:getAttr("preparedActiveZhao")
	if MapIsEmpty(prepareZhaoList) == true then
		prepareZhaoList =
		{
			bingqi = {},
			quanjiao = {}
		}
		self:setAttr("preparedActiveZhao", prepareZhaoList)
	end
	return Helper:getDef(prepareZhaoList[zhaoType], {})
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/14 10:51:54
-- @desc 获取准备的招式
function Role_ActiveZhao:getPrepareZhaoWithIndex(zhaoType, zhaoIndex)
	if Helper:checkParamsError("Role_ActiveZhao:getPrepareZhaoWithIndex(zhaoType, zhaoIndex)", 2, zhaoType, "string", zhaoIndex, "number") == true then
		return
	end
	zhaoType = switch(zhaoType, {["兵器"] = "bingqi", ["拳脚"] = "quanjiao", bingqi = "bingqi", quanjiao = "quanjiao", default = nil})
	if zhaoType == nil then
		return
	end
	local prepareZhaoList = self:getZhaoPrepareListWithZhaoType(zhaoType)
	if MapIsEmpty(prepareZhaoList) == true then
		return
	else
		return prepareZhaoList["zhaoshi"..tostring(zhaoIndex)]
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/13 14:47:10
-- @desc 准备主动技能招式
function Role_ActiveZhao:prepareSkillZhao(zhaoType, zhaoIndex, zhaoId,methodType)
	if Helper:checkParamsError("Role_ActiveZhao:prepareSkillZhao(zhaoType, zhaoIndex, zhaoId)", 2, zhaoType, "string", zhaoIndex, "number") == true then
		return
	end
	zhaoType = switch(zhaoType, {["兵器"] = "bingqi", ["拳脚"] = "quanjiao", bingqi = "bingqi", quanjiao = "quanjiao", default = nil})
	if zhaoType == nil or zhaoId == "" then
		return
	end

	-- add by XiaoZhiWei 2017/03/11 18:33:43 检查下招式是否能够准备 (技能未准备 则招式不能准备)
	-- if zhaoId ~= nil and zhaoId ~= "huifu" then
	if zhaoId ~= nil then
		local skillId = Skill:getSkillIdByZhaoId(zhaoId)
		if self:checkSkillIsPrepared(skillId) ~= true then
			return
		end

		if self:getCurrTypeByWeapon() == methodType and self:checkSkillZhaoCanPreparedByWeaponSubType(skillId) ~= true then
			return
		end
		
	end

	local prepareZhaoList = self:getAttr("preparedActiveZhao")
	if prepareZhaoList[zhaoType] == nil then
		prepareZhaoList[zhaoType] = {}
	end
	-- add by XiaoZhiWei 2017/02/21 20:40:33 添加或移除主动技能招式列表中的招式
	if zhaoId == nil then
		self:removePrepareZhaos(prepareZhaoList[zhaoType]["zhaoshi"..tostring(zhaoIndex)])
	else
		self:setPrepareZhaos(zhaoId)
	end

	-- add by XiaoZhiWei 2017/03/24 16:39:07 判断当前招式是否已装备,已装备则取消
	for k,zId in pairs(prepareZhaoList[zhaoType]) do
		if zId == zhaoId then
			prepareZhaoList[zhaoType][k] = nil
		end
	end

	prepareZhaoList[zhaoType]["zhaoshi"..tostring(zhaoIndex)] = zhaoId
	self:setAttr("preparedActiveZhao", prepareZhaoList)
end

--检查兵器类技能能否准备根据武器子类型
function Role_ActiveZhao:checkSkillZhaoCanPreparedByWeaponSubType(skillId)
    local skill = Skill:getSkill(skillId)
	local weapontype = skill.weapontype
	local weaponType2 = self:getCurrWeaponType2()
	local methodType = self:getCurrTypeByWeapon()

	-- Helper:print_lua_table(weapontype)
	if type(weapontype) ~= "table" then
		return true
	end

	if MapIsEmpty(weapontype) or weaponType2 == nil or methodType == "quanjiao" then
		return true
	else
		for i,v in ipairs(weapontype) do
			if v == methodType..weaponType2 then
				return true
			end
		end
	end

	return false
end
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/07 21:26:35
-- @desc 主动技能招式是否已准备
function Role_ActiveZhao:skillZhaoIsPrepared(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:isSkillZhaoIsPrepared(zhaoId)", 1, zhaoId, "string") == true then
		return false
	end
	local prepareZhaoMap = self:getZhaoPrepareListWithZhaoType(
		switch(self:getCurrTypeByWeapon(),
		{
			["daofa"] = "bingqi",
			["jianfa"] = "bingqi",
			["anqi"] = "bingqi",
			["gunfa"] = "bingqi",
			["bianfa"] = "bingqi",
			["shuangchi"] = "bingqi",
			["qinfa"] = "bingqi",
			["quanjiao"] = "quanjiao",
			default = nil
		}))
	for k,id in pairs(prepareZhaoMap) do
		if zhaoId == id then
			return true
		end
	end
	return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/11 21:20:32
-- @desc 将 准备的招式列表重新排序 不需要传参数类型
function Role_ActiveZhao:reSortPrepareZhaos()
	if self:getCurrTypeByWeapon() == "quanjiao" then
		self:reSortPrepareZhaosWithType("quanjiao")
	else
		self:reSortPrepareZhaosWithType("bingqi")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/11 19:05:10
-- @desc 将 准备的招式列表重新排序 需要传参数类型 (注, 效率很低,不建议定时器调用)
function Role_ActiveZhao:reSortPrepareZhaosWithType(zhaoType)
	zhaoType = switch(zhaoType, {["兵器"] = "bingqi", ["拳脚"] = "quanjiao", bingqi = "bingqi", quanjiao = "quanjiao", default = nil})
	if zhaoType == nil then
		return
	end
	local zhaoList = self:getZhaoPrepareListWithZhaoType(zhaoType)

	local list = {}
	local ptypeList = {}
	-- add by XiaoZhiWei 2017/03/11 17:08:30 遍历记下准备顺序
	for i=1,10 do
		if zhaoList["zhaoshi"..tostring(i)] ~= nil then
			-- add by XiaoZhiWei 2017/03/14 20:46:17 招式Id如果是恢复,并且内功已准备,则保留恢复技能
			-- if zhaoList["zhaoshi"..tostring(i)] == "huifu" and self:getPrepareSkill("neigong") ~= nil then
			-- 	table.insert(list, zhaoList["zhaoshi"..tostring(i)])
			-- else
				-- add by XiaoZhiWei 2017/03/11 18:56:28 判断招式锁对应的武功是否准备,未准备则不能继续准备 招式了  还要判断招式使用条件是否已达成
				local zhao = Skill:getActiveZhao(zhaoList["zhaoshi"..tostring(i)])
				local skillId = Skill:getSkillIdByZhaoId(zhaoList["zhaoshi"..tostring(i)])
				if self:checkSkillIsPrepared(skillId) == true and zhao:zhaoUseCondition(self) == true then
					local prepareTypeList = self:getPrepareType(skillId)
					for j,ptype in ipairs(prepareTypeList) do -- add by XiaoZhiWei 2017/03/12 12:34:55 判断技能准备所对应类型 和招式的类型是否一致
						if zhao:checkTypeIsZhaoMethods(methodsTab[ptype]) == true and (ptype == "neigong" or ptype == "qinggong" or ptype == "zhaojia") then
							-- add by XiaoZhiWei 2017/03/14 20:13:53 准备的类型是 招架, 轻功, 内功 的时候判断招式类型是否 符合,符合则保留
							table.insert(list, zhaoList["zhaoshi"..tostring(i)])
							table.insert(ptypeList, ptype)
							break
						elseif (ptype == self:getCurrTypeByWeapon() or ((ptype == "quanjiao1" or ptype == "quanjiao2") and self:getCurrTypeByWeapon() == "quanjiao")) then
							-- add by XiaoZhiWei 2017/03/14 20:13:48 当前准备的武器和准备的招式类型相匹配的时候, 则保留招式
							table.insert(list, zhaoList["zhaoshi"..tostring(i)])
							table.insert(ptypeList, ptype)
							break
						end
					end
				end
			-- end
		end
	end

	-- add by XiaoZhiWei 2017/03/11 17:09:01 清空准备列表,再重新和准备招式
	self.preparedActiveZhao[zhaoType] = {}
	for i=1,10 do
		if list[i] ~= nil then
			self:prepareSkillZhao(zhaoType, i, list[i],ptypeList[i])
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/28 14:37:24
-- @desc 准备主动技能招式不用指定位置 (自动准备使用,自动准备时,按照准备的先后循序重新排序) (注, 效率很低,不建议定时器调用)
function Role_ActiveZhao:prepareSkillZhaoWithOutIndex(zhaoType, zhaoId,methodType)
	zhaoType = switch(zhaoType, {["兵器"] = "bingqi", ["拳脚"] = "quanjiao", bingqi = "bingqi", quanjiao = "quanjiao", default = nil})
	if zhaoType == nil then
		return
	end
	self:reSortPrepareZhaosWithType(zhaoType) -- add by XiaoZhiWei 2017/03/11 19:12:39 先重新排序
	local zhaoList = self:getZhaoPrepareListWithZhaoType(zhaoType)
	local index = 0 -- add by XiaoZhiWei 2017/03/12 11:14:54 计数使用
	for k,roleZhaoId in pairs(zhaoList) do -- add by XiaoZhiWei 2017/03/12 11:22:36 判断是否已准备,已准备则无需再次准备
		index = index + 1
		if roleZhaoId == zhaoId then
			return
		end
	end
	self:prepareSkillZhao(zhaoType, index + 1, zhaoId,methodType)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/28 12:37:59
-- @desc 自动准备技能招式 (注, 效率很低,不建议定时器调用)
function Role_ActiveZhao:autoPrepareSkillZhao(zhaoId, methodType)
	if zhaoId == nil or methodType == nil then
		return
	end

	-- print(self:getCurrTypeByWeapon(), zhaoId, methodType)

	if (methodType == "quanjiao1" or methodType == "quanjiao2") and self:getCurrTypeByWeapon() == "quanjiao" then
		self:prepareSkillZhaoWithOutIndex("quanjiao", zhaoId,methodType)
	elseif methodType == "neigong" or methodType == "qinggong" or methodType == "zhaojia" then
		self:prepareSkillZhaoWithOutIndex("quanjiao", zhaoId,methodType)
		self:prepareSkillZhaoWithOutIndex("bingqi", zhaoId,methodType)
	elseif self:getCurrTypeByWeapon() == methodType then
		local skillId = Skill:getSkillIdByZhaoId(zhaoId,methodType)
		if self:checkSkillZhaoCanPreparedByWeaponSubType(skillId) == true then
			self:prepareSkillZhaoWithOutIndex("bingqi", zhaoId,methodType)
		else
		end
	end
end

--[[
	-- 准备了的主动招式
	preparedZhaos =
	{
		"liumaishenjian",
		"leitingyiji",
		"sanhuantaoyue"
	},
]]
-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/21 18:20:55
-- @desc 添加主动技能招式
function Role_ActiveZhao:setPrepareZhaos(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:setPrepareZhaos(zhaoId)", 1, zhaoId, "string") == true then
		return
	end
	local preparedZhaos = self:getAttr("preparedZhaos")
	if MapIsEmpty(preparedZhaos) == true then
		preparedZhaos = {}
	else
		for i, id in ipairs(preparedZhaos) do
			if zhaoId == id then
				return
			end
		end
	end
	table.insert(preparedZhaos, zhaoId)
	self:setAttr("preparedZhaos", preparedZhaos)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/21 20:07:31
-- @desc 移除主动技能招式的准备
function Role_ActiveZhao:removePrepareZhaos(zhaoId)
	if Helper:checkParamsError("Role_ActiveZhao:setPrepareZhaos(zhaoId)", 1, zhaoId, "string") == true then
		return
	end
	local preparedZhaos = self:getAttr("preparedZhaos")
	if MapIsEmpty(preparedZhaos) == false then
		for i, id in ipairs(preparedZhaos) do
			if zhaoId == id then
				table.remove(preparedZhaos, i)
				self:setAttr("preparedZhaos", preparedZhaos)
				return
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/22 21:20:17
-- @desc 获取可装备招式的列表
function Role_ActiveZhao:getCanPrepareZhaoMap(zhaoType, currZhaoId)
	--[[
		根据当前的武器获取 攻击类型的武功 和准备好的轻功内功 招架
		然后获取这些功法的招式
		招式中又要筛选出未学会的招式
		暂定为 筛选掉使用条件不符合的招式
	]]
	local retMap = {}
	if Helper:checkParamsError("Role_ActiveZhao:getCanPrepareZhaoList(zhaoType, currZhaoId)", 1, zhaoType, "string") == true then
		return retMap
	end
	zhaoType = switch(zhaoType, {["兵器"] = "bingqi", ["拳脚"] = "quanjiao", bingqi = "bingqi", quanjiao = "quanjiao", default = nil})
	if zhaoType == nil then
		return retMap
	end
	local qgZhaoMap, ngZhaoMap, wgZhaoMap = {}, {}, {}
	local prepareSkills = self:getSkillPrepare() -- 获取当前准备招式的列表

	-- 获取当前装备的兵器
	local currWeaponType = self:getCurrTypeByWeapon()

	-- 如果准备的武功列表是空的, 或者  内功,轻功,拳脚,当前装备的兵器所对应的武功都未准备
	if MapIsEmpty(prepareSkills) == true or (prepareSkills.qinggong == nil and prepareSkills.neigong == nil and prepareSkills.quanjiao1 == nil and prepareSkills[currWeaponType] == nil) then
		PopText("您还没有准备任何武功,请先准备好武功再来准备招式")
		return retMap
	else
		-- 获取准备的武功所对应的招式
		qgZhaoMap = self:getSkillZhaoMap(prepareSkills.qinggong)
		ngZhaoMap = self:getSkillZhaoMap(prepareSkills.neigong)
		wgZhaoMap = {}
		if currWeaponType == "quanjiao" and zhaoType == "quanjiao" then
			wgZhaoMap = self:getSkillZhaoMap(prepareSkills.quanjiao1)
			wgZhaoMap = table.mergeMap(wgZhaoMap, self:getSkillZhaoMap(prepareSkills.quanjiao2))
		elseif zhaoType == "bingqi" and currWeaponType ~= "quanjiao" then
			wgZhaoMap = self:getSkillZhaoMap(prepareSkills[currWeaponType])
		end

		retMap = table.mergeMap(wgZhaoMap, ngZhaoMap)
		retMap = table.mergeMap(retMap, qgZhaoMap)
	end

	-- 排除当前已准备的招式
	if retMap[currZhaoId] ~= nil then
		retMap[currZhaoId] = nil
	end

	return retMap
end



--[[
	准备取消武功的时候需要一个联动的效果
	准备武功时,武功所对应的招式,需要根据武功准备的类型,准备对应类型的招式,往后面准备



	取消武功时,武功所对应的招式,需要根据武功准备的类型,取消准备对应类型的招式,取消后重新排序


]]


-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/10 17:06:55
-- @desc 根据技能准备状态及时更新主动技能招式的准备状态 (注, 效率很低,不建议定时器调用)
function Role_ActiveZhao:updateActiveZhaoStatus()
	-- add by XiaoZhiWei 2017/03/25 11:06:37 准备界面已做好,不需要自动准备功能
	-- if true then
	-- 	return
	-- end

	-- print("Role_ActiveZhao:updateActiveZhaoStatus() --- > 已执行")
	local prepareList = self:getSkillPrepare()
	if MapIsEmpty(prepareList) == true then
	-- print("Role_ActiveZhao:updateActiveZhaoStatus() --- > 已执行  22")
		self:setAttr("preparedActiveZhao", {})
	else
		self:reSortPrepareZhaos()
		for k,skillId in pairs(prepareList) do
			local zhaoList = self:getSkillZhaoList(skillId)
			for i,zhao in ipairs(zhaoList) do
				-- add by XiaoZhiWei 2017/03/11 17:24:26 招式已学会,并且招式使用条件已达成,然后才可以准备该招式
				-- print("111111111111111111111111111111111 = ", zhao:getId(), self:getSkillZhaoExp(zhao:getId()), zhao:zhaoUseCondition(self), zhao:checkTypeIsZhaoMethods(methodsTab[k]), methodsTab[k], k)
				-- if zhao:getId() == "huifu" and k == "neigong"  then -- add by XiaoZhiWei 2017/03/14 19:07:45 恢复技能不需要判断条件,内功准备了即可
					-- self:autoPrepareSkillZhao(zhao:getId(), k)
				-- elseif self:getSkillZhaoExp(zhao:getId()) > 1 and zhao:zhaoUseCondition(self) == true and zhao:checkTypeIsZhaoMethods(methodsTab[k]) == true then
				if self:getSkillZhaoExp(zhao:getId()) > 1 and zhao:zhaoUseCondition(self) == true and zhao:checkTypeIsZhaoMethods(methodsTab[k]) == true then
					self:autoPrepareSkillZhao(zhao:getId(), k)
				end
			end
		end
	end
end

--[[
    @desc: 保存准备好的主动招式列表
    author:TangJian
    time:2022-09-17 16:40:19
    --@weaponType:
	--@preparedActiveZhaoList: 
    @return:
]]
function Role_ActiveZhao:savePreparedActiveZhaoList(weaponType, preparedActiveZhaoList)
    if self._activeZhaoPrepareMap == nil then
        self._activeZhaoPrepareMap = {}
    end
    local attackingSkillType = SkillUtil:weaponTypeToAttackingSkillType(weaponType)
    self._activeZhaoPrepareMap[attackingSkillType] = table.getMap(preparedActiveZhaoList, function(k, v)
        return tostring(k), {skillId = v.skillId, activeSkillId = v.activeSkillId}
    end)
end

--[[
    @desc: 获取持有某种武器类型时可以准备的主动技能列表
    author:TangJian
    time:2022-09-16 19:00:07
    --@weaponType: 
    @return:
]]
function Role_ActiveZhao:getCanPrepareActiveZhaoList(weaponName)
    local canPrepareActiveZhaoList = {}
    local prepareList = self:getSkillPrepare()
    local function appendCanPrepareActiveZhao(prepareType, skillId, prepareMethod)
        assert(type(prepareMethod) == "number", "prepareMethod must is number! but get " .. tostring(prepareMethod))
        
        local skill = Skill:getSkill(skillId)
        if skill then
            local zhaoList = self:getSkillZhaoList(skillId)
            for i, zhao in ipairs(zhaoList) do
                if self:getSkillZhaoExp(zhao:getId()) > 0 and zhao:zhaoUseCondition(self, weaponName) == true and zhao:checkTypeIsZhaoMethods(methodsTab[prepareType]) == true then
					table.insert(canPrepareActiveZhaoList, {prepareMethod = prepareMethod, prepareType = prepareType, skillId = skillId, activeSkillId = zhao:getId(), level = 1})
                end
            end
        else
            print("找不到技能id:" .. tostring(skillId))
        end
    end
    if not MapIsEmpty(prepareList) then
        for prepareType, skillId in pairs(prepareList) do
            local skill = Skill:getSkill(skillId)
            if skill then
                if table.contains({"quanjiao1", "quanjiao2", "jianfa", "daofa", "gunfa", "anqi", "bianfa", "shuangchi", "qinfa"}, prepareType) then
                    if skill:canPrepareType(self:getMethodByWeaponType(weaponName)) then
                        if SkillUtil:weaponTypeToPrepareType(weaponName) == string.gsub(prepareType, "%d", "") then
                            appendCanPrepareActiveZhao(prepareType, skillId, 1)
                        end
                    end
                else
                    appendCanPrepareActiveZhao(prepareType, skillId, switch(prepareType, {neigong = 2, qinggong = 3, zhaojia = 4}))
                end
            else
                print("找不到技能id:" .. tostring(skillId))
            end
        end
    end
    return canPrepareActiveZhaoList
end

--[[
    @desc: 获取当前准备的主动技能招式id的map
    author:TangJian
    time:2022-09-19 16:50:17
    @return:
]]
function Role_ActiveZhao:getPreparedActiveZhaoIdWithLevelMap()
    local preparedActiveZhaoList = self:getPreparedActiveZhaoListAndCanPrepareActiveZhaoList(self:getCurrWeaponType())
    
	for k, v in pairs(preparedActiveZhaoList) do
		--prepareMethod == 1攻击武学
		if v.prepareMethod == 1 and self:checkSkillZhaoCanPreparedByWeaponSubType(v.skillId) ~= true then
			preparedActiveZhaoList[k] = nil
		end
	end

	return table.map(preparedActiveZhaoList, function(v) 
        local level = self:getSkillZhaoLv(v.activeSkillId)
        local activeSkillId = v.activeSkillId 
        if level > 1 then
            activeSkillId = v.activeSkillId .. tostring(level) 
        end
        return activeSkillId
    end)
end

--[[
    @desc: 获取主动技能招式Id和名称的Map
    author:TangJian
    time:2022-09-19 16:51:26
    @return:
]]
function Role_ActiveZhao:getPreparedActiveZhaoIdAndNameWithLevelMap()
    local preparedActiveZhaoList = self:getPreparedActiveZhaoListAndCanPrepareActiveZhaoList(self:getCurrWeaponType())
    
	for k, v in pairs(preparedActiveZhaoList) do
		--prepareMethod == 1 攻击武学
		if v.prepareMethod == 1 and self:checkSkillZhaoCanPreparedByWeaponSubType(v.skillId) ~= true then
			preparedActiveZhaoList[k] = nil
		end
	end

	return table.map(preparedActiveZhaoList, function(v)
        local level = self:getSkillZhaoLv(v.activeSkillId)
        local activeSkillId = v.activeSkillId 
        if level > 1 then
            activeSkillId = v.activeSkillId .. tostring(level) 
        end
        return {id = activeSkillId, name = Skill:getActiveZhao(v.activeSkillId):getName()}
    end)
end

function Role_ActiveZhao:getPreparedActiveZhaoListAndCanPrepareActiveZhaoList(weaponType)
    -- 添加重数和准备方式的属性
    local function subjoin(skillList)
        local skillIdToMethodMap = {}
        for k, v in pairs(self:getSkillPrepare()) do
            if skillIdToMethodMap[v] == nil then
                skillIdToMethodMap[v] = 6
            end
            if SkillUtil:weaponTypeToPrepareType(weaponType) == string.gsub(k, "%d", "") then
                skillIdToMethodMap[v] = 1
            else
                -- 仅用作排序
                local sortValue = switch(k, {quanjiao1 = 5, quanjiao2 = 5, jianfa = 5, daofa = 5, gunfa = 5, anqi = 5, bianfa = 5, shuangchi = 5, qinfa = 5, neigong = 3, qinggong = 4, zhaojia = 5, default = 6})
                if skillIdToMethodMap[v] > sortValue then
                    skillIdToMethodMap[v] = sortValue
                end
            end
        end
        -- 补充重数
        local function mapFunc(v)
            v.level = self:getSkillZhaoLv(v.activeSkillId)
            v.prepareMethod = skillIdToMethodMap[v.skillId]
            return v
        end
        skillList = table.map(skillList, mapFunc)
    end

    local function sortedSkillList(skillList)
        -- 排序
        local function sortFunc(a, b)
            local sortValueA = a.prepareMethod * 10 + a.level
            local sortValueB = b.prepareMethod * 10 + b.level
            if sortValueA < sortValueB then
                return true
            elseif sortValueA > sortValueB then
                return false
            else
                if a.activeSkillId < b.activeSkillId then
                    return true
                elseif a.activeSkillId > b.activeSkillId then
                    return false
                else
                    return false
                end
            end
        end
        table.sort(skillList, sortFunc)
        return skillList
    end

    -- 获得当前已经准备的主动技能列表
    local canPrepareActiveSkillList = self:getCanPrepareActiveZhaoList(weaponType)
    local canPrepareMap =
        table.getMap(
        canPrepareActiveSkillList,
        function(k, v)
            return v.activeSkillId, true
        end
    )
    local activeZhaoPrepareMap = self._activeZhaoPrepareMap
    if  activeZhaoPrepareMap == nil then
         activeZhaoPrepareMap = {}
    end
    activeZhaoPrepareMap = clone(activeZhaoPrepareMap)
    local attackingSkillType = SkillUtil:weaponTypeToAttackingSkillType(weaponType)
    local preparedActiveSkillList = activeZhaoPrepareMap[attackingSkillType]
    -- 补充属性
    subjoin(preparedActiveSkillList)
    subjoin(canPrepareActiveSkillList)
    -- 去重 canPrepareActiveSkillList
    table.removeDuplicates(canPrepareActiveSkillList, "activeSkillId")

    if preparedActiveSkillList == nil then
        preparedActiveSkillList = sortedSkillList(table.slice(canPrepareActiveSkillList, 1, 6))
        canPrepareActiveSkillList = sortedSkillList(table.slice(canPrepareActiveSkillList, 7, -1))
    else
        preparedActiveSkillList = table.getMap(preparedActiveSkillList, function(k, v) return tonumber(k), v end)
        -- 撤掉不能使用的主动技能
        for i = 6, 1, -1 do
            if preparedActiveSkillList[i] then
                if canPrepareMap[preparedActiveSkillList[i].activeSkillId] then
                    -- 已经准备的可以准备的主动技能，从能准备的map中移除
                    canPrepareMap[preparedActiveSkillList[i].activeSkillId] = nil
                else
                    -- 撤掉不能准备的主动技能
                    preparedActiveSkillList[i] = nil
                end
            end
        end

        -- 去除能准备的主动技能中已经准备了的主动技能
        for i = table.getn(canPrepareActiveSkillList), 1, -1 do
            if not canPrepareMap[canPrepareActiveSkillList[i].activeSkillId] then
                table.remove(canPrepareActiveSkillList, i)
            end
        end

        sortedSkillList(canPrepareActiveSkillList)

        -- 用能使用的主动技能补空缺
        for i = 1, 6 do
            if preparedActiveSkillList[i] == nil then
                if table.getn(canPrepareActiveSkillList) > 0 then
                    preparedActiveSkillList[i] = table.remove(canPrepareActiveSkillList, 1)
                else
                    break
                end
            end
        end
    end
    return preparedActiveSkillList, canPrepareActiveSkillList
end

function Role_ActiveZhao:updateActiveZhaoStatusInCoroutine()
	-- add by XiaoZhiWei 2017/03/25 11:06:37 准备界面已做好,不需要自动准备功能
	-- if true then
	-- 	return
	-- end

	-- print("Role_ActiveZhao:updateActiveZhaoStatus() --- > 已执行")
	local prepareList = self:getSkillPrepare()
	if MapIsEmpty(prepareList) == true then
	-- print("Role_ActiveZhao:updateActiveZhaoStatus() --- > 已执行  22")
		self:setAttr("preparedActiveZhao", {})
	else
		self:reSortPrepareZhaos()
		for k,skillId in pairs(prepareList) do
			local zhaoList = self:getSkillZhaoList(skillId)
			for i,zhao in ipairs(zhaoList) do
				-- add by XiaoZhiWei 2017/03/11 17:24:26 招式已学会,并且招式使用条件已达成,然后才可以准备该招式
				-- print("111111111111111111111111111111111 = ", zhao:getId(), self:getSkillZhaoExp(zhao:getId()), zhao:zhaoUseCondition(self), zhao:checkTypeIsZhaoMethods(methodsTab[k]), methodsTab[k], k)
				-- if zhao:getId() == "huifu" and k == "neigong"  then -- add by XiaoZhiWei 2017/03/14 19:07:45 恢复技能不需要判断条件,内功准备了即可
					-- self:autoPrepareSkillZhao(zhao:getId(), k)
				-- elseif self:getSkillZhaoExp(zhao:getId()) > 1 and zhao:zhaoUseCondition(self) == true and zhao:checkTypeIsZhaoMethods(methodsTab[k]) == true then
				if self:getSkillZhaoExp(zhao:getId()) > 1 and zhao:zhaoUseCondition(self) == true and zhao:checkTypeIsZhaoMethods(methodsTab[k]) == true then
					self:autoPrepareSkillZhao(zhao:getId(), k)
				end
				coroutine.yield()
			end
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/02/24 16:47:51
-- @desc 检测主动技能的学习条件(解锁条件)是否到达
function Role_ActiveZhao:checkActiveZhaoIsDeblocking()

	local skills = self:getSkills()
	if MapIsEmpty(skills) == true then
		return
	else
		local coroutineName= "checkActiveZhaoIsDeblocking:检测主动技能的学习条件" .. tostring(self)
		
		if MainCoroutinePool:contains(coroutineName) == false then
			MainCoroutinePool:add(coroutineName, 
			function()
				for skillId,roleSkill in pairs(skills) do
					local zhaoList = self:getSkillZhaoList(skillId)
					local skill = Skill:getSkill(skillId)
					for i,zhao in ipairs(zhaoList) do
						-- 判断招式是否已学 并且 招式学习条件到达
						if self:getSkillZhaoExp(zhao:getId()) <= 0 and zhao:learnCondition(self) == true then
							self:addSkillZhaoLv(zhao:getId(), 1)  -- add by XiaoZhiWei 2017/03/03 11:11:25 学会了即有 300经验值
							RichPrint("main", "经过日积月累的修炼，你终于领悟了「"..tostring(Skill:getSkill(skillId).name).."」的特殊招式「"..tostring(zhao:getName()).."」！")
							-- self:updateActiveZhaoStatusInCoroutine() -- add by XiaoZhiWei 2017/03/18 22:04:43 招式学会之后 更新一下招式的准备状态
						-- elseif Helper:getDef(self:getSkillZhaoExp(zhao:getId()), 0) > 0 then
						-- 	RichPrint("main", "你对["..zhao:getName().."]的理解达到了质的飞跃，成功将其突破至第"..self:getSkillZhaoLv(zhao:getId()).."重！")
						-- elseif self:skillZhaoIsPrepared(zhao:getId()) == false then
							-- self:updateActiveZhaoStatusInCoroutine() -- add by XiaoZhiWei 2017/03/18 22:04:43 招式通过书页学会,但是属性变化引起使用条件达成,也需要走到自动准备
						-- else
						end
						coroutine.yield()
					end
				end
			end)
		end
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/10 17:09:22
-- @desc 判断技能是否准备
function Role_ActiveZhao:checkSkillIsPrepared(skillId)
	if skillId == nil then -- add by XiaoZhiWei 2017/03/10 17:10:20 空的技能是不能准备的
		return false
	end
	local prepareList = self:getSkillPrepare()
	if MapIsEmpty(prepareList) == true then
		return false
	else
		for ptype, id in pairs(prepareList) do
			if id == skillId then
				return true
			end
		end
	end
	return false
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/03 10:25:59
-- @desc 获取武功潜能转换率
function Role_ActiveZhao:getSkillPotEfficiency(skillId)
	-- BaseSkill:getPotEfficiency 默认值为80 所以改方法默认值也为80
	if Helper:checkParamsError("Role_ActiveZhao:getSkillPotEfficiency(skillId)", 1, skillId, "string") == true then
		return 80
	end
	local skill = Skill:getSkill(skillId)
	if MapIsEmpty(skill) == true then
		return 80
	end
	return Helper:getDef(skill:getPotEfficiency(self), 80)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/03/03 10:37:58
-- @desc  获取招式所对应武功的潜能转换率
function Role_ActiveZhao:getSkillZhaoPotEfficiency(zhaoId)
	-- BaseSkill:getPotEfficiency 默认值为80 所以改方法默认值也为80
	if Helper:checkParamsError("Role_ActiveZhao:getSkillZhaoPotEfficiency(zhaoId)", 1, zhaoId, "string") == true then
		return 80
	end
	if zhaoId == "huifu" then
		return 80
	end
	return self:getSkillPotEfficiency(Skill:getSkillIdByZhaoId(zhaoId))
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/01 17:11:44
-- @desc 判断招式是否提升等级
function Role_ActiveZhao:checkZhaoIsLevelUp(zhaoId, oldLv)
	local nowLv = self:getSkillZhaoLv(zhaoId) -- 增加后的招式等级

	local zhao = Skill:getActiveZhao(zhaoId)

	if nowLv >= 2 and nowLv - oldLv >= 1 then -- add by XiaoZhiWei 2017/03/15 09:27:18 两级之后,并且等级提神一级才提示
		RichPrint("main", "你对「"..zhao:getName().."」的理解达到了质的飞跃，成功将其突破至第"..tostring(nowLv).."重！")
	end

	-- add by LvBin 2025/10/20 19:24:16 招式熟练度变化时提示文本
	local zhaoExp = Helper:mathFloor(self:getSkillZhaoExp(zhaoId))

	local zhaoExpLimit = self:getZhaoExpLimit(zhaoId,self:getZhaoLvLimit(zhaoId))

	local deficitExp = zhaoExpLimit - zhaoExp

	if deficitExp > 0 then
		RichPrint("main", "你对第"..tostring(nowLv).."重「"..zhao:getName().."」的理解已出类拔萃，若要更上一层楼，还需练习"..deficitExp.."点。")
	else
		RichPrint("main", "你对第"..tostring(nowLv).."重「"..zhao:getName().."」的理解已达到登峰造极的程度！")
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/28 11:43:37
-- @desc 主动招式
function Role_ActiveZhao:getPreparedActiveZhaoMap()
	local preparedActiveZhaoMap = {}
	local prepareZhaoList = self.preparedZhaos
	-- if false then
	if true then
		prepareZhaoList = self:getPreparedActiveZhaoIdArray()
		if MapIsEmpty(prepareZhaoList) == true then
			return {}
		end
	else
	end
	for i, activeZhaoId in ipairs(prepareZhaoList) do
		print("activeZhaoId = ", activeZhaoId)
		if i > ZHAO_MAX_COUNT then
			break
		end
		preparedActiveZhaoMap[activeZhaoId] = Skill:getActiveZhao(activeZhaoId):clone()--NEEDTOCHECK
	end
	return preparedActiveZhaoMap
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/28 15:48:46
-- @desc 得到准备好的招式数组
function Role_ActiveZhao:getPreparedActiveZhaoArray()
	local preparedActiveZhaoArray = {}
	local prepareZhaoList = self.preparedZhaos
	-- if false then
	if true then
		prepareZhaoList = self:getPreparedActiveZhaoIdArray()
		if MapIsEmpty(prepareZhaoList) == true then
			return {}
		end
	else
	end
	for i, activeZhaoId in ipairs(prepareZhaoList) do
		print("activeZhaoId = ", activeZhaoId)
		print("Skill:getActiveZhao(activeZhaoId):getId() = ", Skill:getActiveZhao(activeZhaoId):getId())
		if i > ZHAO_MAX_COUNT then
			break
		end
		table.insert(preparedActiveZhaoArray, Skill:getActiveZhao(activeZhaoId):clone())--NEEDTOCHECK
	end
	return preparedActiveZhaoArray
end

-----------------------------------------------------------------------------------------------------------
-- @author TangJian
-- @time 2016/12/28 15:47:02
-- @desc 得到准备好的主动技能编号数组
function Role_ActiveZhao:getPreparedActiveZhaoIdArray()
	local prepareZhaoList = {}
	local prepareZhaoMap = self:getZhaoPrepareListWithZhaoType(
		switch(self:getCurrTypeByWeapon(),
		{
			["daofa"] = "bingqi",
			["jianfa"] = "bingqi",
			["anqi"] = "bingqi",
			["gunfa"] = "bingqi",
			["bianfa"] = "bingqi",
			["shuangchi"] = "bingqi",
			["qinfa"] = "bingqi",
			["quanjiao"] = "quanjiao",
			default = nil
		}))
	local hasHuiFu = false -- add by XiaoZhiWei 2017/03/15 19:46:47 判断招式列表是否存在恢复 招式
	for k,zhaoId in pairs(prepareZhaoMap) do
		if zhaoId == "huifu" then
			hasHuiFu = true
			table.insert(prepareZhaoList, "huifu")
		else
			local zhaoLv = self:getSkillZhaoLv(zhaoId)
			if zhaoLv >= 2 then
				table.insert(prepareZhaoList, zhaoId..tostring(zhaoLv)) -- add by XiaoZhiWei 2017/03/15 20:16:34 招式后拼上重数
			else
				table.insert(prepareZhaoList, zhaoId)
			end
		end
	end
	if hasHuiFu == false then
		table.insert(prepareZhaoList, "huifu")
	end

	
	for index = #prepareZhaoList, 1, -1 do
		local activeZhao = Skill:getActiveZhao(prepareZhaoList[index])

		for i = 1, 10 do
			local typeList = string.split(activeZhao["use_type_" .. tostring(i)], ";")
			local idList = string.split(activeZhao["use_id_" .. tostring(i)], ";")
			local logicList = string.split(activeZhao["use_logic_" .. tostring(i)], ";")
			local valueList = string.split(activeZhao["use_value_" .. tostring(i)], ";")

			local needBreak = false
			for j, id in ipairs(idList) do
				local ltype = Helper:getDef(typeList[j], typeList[1])
				local logic = Helper:getDef(logicList[j], logicList[1])

				local canUse = true
				if ltype == "装备武器" then
					canUse = activeZhao:weaponCondition(self:getCurrWeaponType(), id, logic, valueList[j])
				end

				if canUse == false then
					table.remove(prepareZhaoList, index)
					needBreak = true
					break
				end
			end

			if needBreak == true then
				break
			end

		end
	end


	-- add by XiaoZhiWei 2017/04/26 18:11:50 雇佣兵 或者章作之NPC
	if self.isGuYongBing == true or self._isZhang == true then
		prepareZhaoList = {}
		for k,zhao in pairs(self.activeZhaos) do
			local zhaoId = zhao.id
			local zhaoExp = self:getSkillZhaoExp(zhaoId)
			local zhaoLv = Helper:getRange(Helper:getDef(self:conversionZhaoExpAndLv("lv", zhaoExp, self:getSkillZhaoPotEfficiency(zhaoId)), 0), 1, 9)

			if zhaoLv >= 2 then
				table.insert(prepareZhaoList, zhaoId..tostring(zhaoLv)) -- add by XiaoZhiWei 2017/03/15 20:16:34 招式后拼上重数
			else
				table.insert(prepareZhaoList, zhaoId)
			end
		end

		-- print("获取招式列表成功")
		-- Helper:print_lua_table(prepareZhaoList)

		return prepareZhaoList
	end
	return Helper:getDef(prepareZhaoList, {})
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 章作之玩法相关方法定义


-- 副本NPC属性改变
function Role_ActiveZhao:setMapNpcBuff(npcId, buff)
	-- npcId
	-- buff
	-- equips

	local flag = false
	local mapNpcAttrModify = self:getAttr("mapNpcAttrModify")
	for i,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			mapNpcAttrModify[i].buff = mapNpcAttrModify[i].buff + buff
			flag = true
		end
	end

	if flag == false then
		table.insert(mapNpcAttrModify, {npcId = npcId, buff = 1 + buff, equips = {}})
	end

	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
end

-- 副本NPC装备改变
function Role_ActiveZhao:setMapNpcEquips(npcId, itemId, equipPart)
	if npcId == nil then
		return
	end
	local equips
	local mapNpcAttrModify = self:getAttr("mapNpcAttrModify")
	for i,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			equips = mapNpcAttrModify[i].equips
		end
	end

	if equips == nil then
		equips = {}
		table.insert(mapNpcAttrModify, {npcId = npcId, buff = 1, equips = equips})
	else
		-- for i,v in ipairs(mapNpcAttrModify) do
		-- 	if v.npcId == npcId then
		-- 		equips = mapNpcAttrModify[i].equips
		-- 	end
		-- end
	end

	local item = self:getOneItemByKey(itemId)
	equips[item.equipPart] = itemId
	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/22 11:00:07
-- @desc 增加副本NPC武功等级
function Role_ActiveZhao:addMapNpcSkillLv(npcId, addLv)
	if npcId == nil or type(addLv) ~= "number" then
		return
	end
	local mapNpcAttrModify = self:getAttr("mapNpcAttrModify")
	local isAdd = false
	for i,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			v.skillAddLv = Helper:getDef(v.skillAddLv, 0)
			v.skillAddLv = v.skillAddLv + addLv
			isAdd = true
		end
	end

	if isAdd == false then
		table.insert(mapNpcAttrModify, {npcId = npcId, buff = 1, skillAddLv = addLv})
	end

	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/25 21:09:51
-- @desc 增加副本NPC武功招式熟练度 (所有招式增加的经验值一样)
function Role_ActiveZhao:addMapNpcZhaoExp(npcId, addExp)
	if npcId == nil or type(addExp) ~= "number" then
		return
	end
	local mapNpcAttrModify = Helper:getDef(self:getAttr("mapNpcAttrModify"), {})
	local isAdd = false
	for i,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			local zhaoList = Helper:getDef(v.addZhaoList, {})
			v.activeZhaos = Helper:getDef(v.activeZhaos, {})
			for k,zhaoId in pairs(zhaoList) do
				v.activeZhaos[zhaoId] = Helper:getDef(v.activeZhaos[zhaoId], 0) + addExp
			end
			isAdd = true
		end
	end

	if isAdd == false then
		table.insert(mapNpcAttrModify, {npcId = npcId, buff = 1, activeZhaos = {}})
	end

	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 01:40:33
-- @desc 增加副本NPC武功招式
function Role_ActiveZhao:addMapNpcZhao(npcId, zhaoId)
	if npcId == nil or zhaoId == nil then
		return
	end

	local mapNpcAttrModify = Helper:getDef(self:getAttr("mapNpcAttrModify"), {})
	local isAdd = false
	for k,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			v.addZhaoList = Helper:getDef(v.addZhaoList, {})
			if #v.addZhaoList == 0 then
				table.insert(v.addZhaoList, zhaoId)
			else
				for i,npcZhaoId in ipairs(v.addZhaoList) do
					if npcZhaoId == zhaoId then
						break
					elseif i == #v.addZhaoList then
						table.insert(v.addZhaoList, zhaoId)
					end
				end
			end
			isAdd = true
		end
	end

	if isAdd == false then
		table.insert(mapNpcAttrModify, {npcId = npcId, buff = 1, addZhaoList = {zhaoId}})
	end

	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 21:01:27
-- @desc 获取副本NPC最大的招式重数
function Role_ActiveZhao:getMapNpcMaxZhaoLv(npcId)
	if npcId == nil then
		return 0
	end

	local mapNpcAttrModify = Helper:getDef(self:getAttr("mapNpcAttrModify"), {})
	local retValue = 0
	for k,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			local activeZhaos = Helper:getDef(v.activeZhaos, {})
			local zhaoList = Helper:getDef(v.addZhaoList, {})
			if MapIsEmpty(zhaoList) == false then -- add by XiaoZhiWei 2017/05/04 11:33:02 招式存在默认等级至少为1级
				retValue = 1
			end
			for zhaoId,zhaoExp in pairs(activeZhaos) do
				if retValue < self:conversionZhaoExpAndLv("lv", zhaoExp, 80) then
					retValue = self:conversionZhaoExpAndLv("lv", zhaoExp, 80)
				end
			end
		end
	end
	return Helper:getRange(Helper:getDef(retValue, 0), 0, 9)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 23:13:58
-- @desc 赠与物品处理
function Role_ActiveZhao:giveItem(item, role, func)
	if item == nil or role == nil or role.AttrModifyId == nil then
		return
	end

	local itemAttr = self:getOneItemByKey(item.itemId)
	local equipItem -- add by XiaoZhiWei 2017/06/12 17:16:03 记录之前已装备的物品
	if itemAttr.type ~= "药品" and itemAttr.type ~= "药材" then
		local isAdd , list= false, Helper:getDef(self:getFlag("佣兵异常的装备列表"), {}) 
		local mapNpcAttrModify = self:getAttr("mapNpcAttrModify")
		-- for i = #mapNpcAttrModify, 1, -1 do
		for i,v in ipairs(mapNpcAttrModify) do
			if v.npcId == role.AttrModifyId then
				v.equips = Helper:getDef(v.equips, {})
				-- add by XiaoZhiWei 2017/05/02 17:51:24 isAdd用来标记只能返回背包一次
				if isAdd == false then
					if v.equips[itemAttr.equipPart] ~= nil then
						equipItem = v.equips[itemAttr.equipPart]
					end
					v.equips[itemAttr.equipPart] = item.itemId
					isAdd = true
				else
					-- add by XiaoZhiWei 2017/09/01 17:46:54 需要将出现异常的清空掉,并且将物品退还给玩家
					if MapIsEmpty(v.equips) ~= nil then
						for k,itemId in pairs(v.equips) do
							list[itemId] = Helper:getDef(list[itemId], 0) + 1
						end
					end
					mapNpcAttrModify[i] = {}
				end
			end
		end

		if MapIsEmpty(list) == false then
			self:setFlag("佣兵异常的装备列表", list)
			local flag = self:getFlag("是否修复佣兵装备列表")

			local cList = {}
			for k,v in pairs(list) do
				cList[k] = 1
			end

			if flag ~= true then
				if self:checkCanBuyTwoOrMoreThings(cList, false) == true then
					for itemId,count in pairs(cList) do
						self:addItemCount(itemId, count,nil,nil,"修复佣兵装备")
					end
					self:setFlag("是否修复佣兵装备列表", true)
				end
			end
		end

		if isAdd == false then
			table.insert(mapNpcAttrModify, {npcId = role.AttrModifyId, buff = 1, equips = {[itemAttr.equipPart] = item.itemId}})
		end
		self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
	else
		-- do
			-- 	local RoleGlobalLayer = require("app.views.layer.RoleLayer.RoleGlobalLayer")
			-- 	RoleGlobalLayer:create(role)
			-- role:useItem(itemAttr.id,nil,"佣兵给予")
		-- end
		-- add by XiaoZhiWei 2017/04/26 23:28:04 暂未编写药品的使用
		do
			local RoleGlobalLayer = require("app.views.layer.RoleLayer.RoleGlobalLayer")
			RoleGlobalLayer:create(role)
		end
		role:useItem(itemAttr.id,nil,ITEM_USE_TYPE.USE_ITEM_YONGBING)
		self:uploadYongBingAttr(role)
	end
	self:addItemCount(item.itemId, -1,nil,nil,"给予佣兵")
	-- add by XiaoZhiWei 2017/06/12 17:18:05 修改为先扣除物品,再添加(处理背包满了的情况)
	if equipItem ~= nil then
		self:addItemCount(equipItem, 1,nil,nil,"佣兵返还") -- add by XiaoZhiWei 2017/04/26 23:24:54 如果雇佣兵身上装备了该部位的道具,则将新道具带上,原有道具返回到玩家背包
	end
	if func then
		func()
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/02 14:02:17
-- @desc 佣兵战斗结果额外处理
function Role_ActiveZhao:uploadYongBingAttr(role)
	if role == nil then
		return
	end
	local list = {"qi", "qiMax", "neili", "neiliMax", "qiPercent"}
	for i,v in ipairs(list) do
		self:setMapNpcAttr(role.AttrModifyId, v, role:getAttr(v))
	end
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/04/26 22:49:13
-- @desc 获取赠予界面物品列表
function Role_ActiveZhao:getZengYuItemList()
	local items = self:getItems()
	local retList = {}
	for k,item in pairs(items) do
		if item.type == "神兵" then
			-- add by XiaoZhiWei 2017/06/09 11:28:54 神兵不能赠予
		else
			local itemAttr = self:getOneItemByKey(item.itemId)
			if MapIsEmpty(itemAttr) == false and self:checkItemIsEquip(item.id) == false and self:checkIsPrepareWeapon(item.id) == false then
				switch(itemAttr.type,
				{
					["剑"] = function() table.insert(retList, item) end,
					["刀"] = function() table.insert(retList, item) end,
					["棍"] = function() table.insert(retList, item) end,
					["鞭"] = function() table.insert(retList, item) end,
					["暗器"] = function() table.insert(retList, item) end,
					["头帽"] = function() table.insert(retList, item) end,
					["上装"] = function() table.insert(retList, item) end,
					["下装"] = function() table.insert(retList, item) end,
					["腰带"] = function() table.insert(retList, item) end,
					["手部"] = function() table.insert(retList, item) end,
					["鞋子"] = function() table.insert(retList, item) end,
					["项链"] = function() table.insert(retList, item) end,
					["戒指"] = function() table.insert(retList, item) end,
					["腰坠"] = function() table.insert(retList, item) end,
					["药品"] = function() table.insert(retList, item) end,
					["药材"] = function() table.insert(retList, item) end,
					default = 1
				})
			end
		end

	end

	return retList
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/02 11:53:03
-- @desc 地图NPc属性变化
function Role_ActiveZhao:addMapNpcAttr(npcId, attrName, attrValue)
	if npcId == nil or attrName == nil or type(attrValue) ~= "number" then
		return
	end

	local mapNpcAttrModify = Helper:getDef(self:getAttr("mapNpcAttrModify"), {})
	local isAdd = false
	local checkMap = {["qi"] = true, ["qiMax"] = true, ["neili"] = true, ["neiliMax"] = true, ["qiPercent"] = true} -- add by XiaoZhiWei 2017/05/02 14:41:01 用于检查属性是否有效
	for k,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			v[attrName] = Helper:getDef(v[attrName], 0) + attrValue
			if checkMap[attrName] == true and v[attrName] < 0 then -- add by XiaoZhiWei 2017/05/02 15:05:02 在检测列表内,并且值小于0,则代表无效,需给定默认值 0
				v[attrName] = 0
			end
			isAdd = true
		end
	end

	if isAdd == false then
		table.insert(mapNpcAttrModify, {npcId = npcId, buff = 1, [attrName] = attrValue})
	end

	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/02 15:30:23
-- @desc 地图NPC属性设置
function Role_ActiveZhao:setMapNpcAttr(npcId, attrName, attrValue)
	if npcId == nil or attrName == nil or type(attrValue) ~= "number" then
		return
	end

	local mapNpcAttrModify = Helper:getDef(self:getAttr("mapNpcAttrModify"), {})
	local isAdd = false
	local checkMap = {["qi"] = true, ["qiMax"] = true, ["neili"] = true, ["neiliMax"] = true, ["qiPercent"] = true} -- add by XiaoZhiWei 2017/05/02 14:41:01 用于检查属性是否有效
	for k,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			v[attrName] = attrValue
			if checkMap[attrName] == true and v[attrName] < 0 then -- add by XiaoZhiWei 2017/05/02 15:05:02 在检测列表内,并且值小于0,则代表无效,需给定默认值 0
				v[attrName] = 0
			end
			isAdd = true
		end
	end

	if isAdd == false then
		table.insert(mapNpcAttrModify, {npcId = npcId, buff = 1, [attrName] = attrValue})
	end

	self:setAttr("mapNpcAttrModify", mapNpcAttrModify)
end

-----------------------------------------------------------------------------------------------------------
-- @author XiaoZhiWei
-- @time 2017/05/04 14:54:32
-- @desc 获取地图NPC的装备物品列表
function Role_ActiveZhao:getMapNpcItemList(npcId)
	local retList = {}
	if npcId == nil then
		return
	end
	local mapNpcAttrModify = Helper:getDef(self:getAttr("mapNpcAttrModify"), {})
	for k,v in pairs(mapNpcAttrModify) do
		if v.npcId == npcId then
			local equips = Helper:getDef(v.equips, {})
			for k,itemId in pairs(equips) do
				table.insert(retList, {id = self:getItemOnlyId(), count = 1, itemId = itemId})
			end
		end
	end
	return retList
end

-- @author TangJian
-- @desc 获得招式攻击前后帧数
function Role_ActiveZhao:getAttackZhaoFrames(attackZhao)
	return math.floor(self:getSwingDuration("begin", attackZhao) * 30), 0, math.floor(self:getSwingDuration("after", attackZhao) * 30)
end

-- 获取当前招式攻击前摇
function Role_ActiveZhao:getSwingDuration(name, zhao)
	-- print("function Role_ActiveZhao:getSwingDuration(name, zhao), name = "..tostring(name)..", zhao = "..tostring(zhao))

	if not name or not zhao then
		assert(nil, "请选择一个招式")
	end
	local skillLv, factor = self:getSkillLvAndFactor("qinggong", "atkSpd")
	-- print("name:", name)
	-- print("self:getName():", self:getName())
	-- print("skillLv:", skillLv)
	-- print("factor:", factor)
	-- print("zhao.preDuration:", zhao.preDuration)
	-- print("zhao.aftDuration:", zhao.aftDuration)
	-- print("self:getEffectDex():", self:getEffectDex())
	--招式前摇时间 * 1.5/math.min((1.08 + 轻功等效技能等级 * 轻功的攻速系数 * 0.00001 + 等效身法/270), 3.6)

	local swingDuration = nil

	if name == "begin" then
		swingDuration = zhao.preDuration*1.5/math.min((1.08+skillLv*factor*0.00001+self:getEffectDex()/270), 3.6)
	elseif name == "after" then
		swingDuration = zhao.aftDuration*1.5/math.min((1+skillLv*factor*0.00001+self:getEffectDex()/200), 3)
	end

	assert(type(swingDuration) == "number", "swingDuration不能为空")

	return swingDuration
end

-- 出招伤害
function Role_ActiveZhao:getAtkDamage(zhao)
	if not zhao then
		assert(nil, "请选择一个招式")
	end
	
	local cType = self:getCurrTypeByWeapon()
	local skillLv = self:getRealSkillLv(cType)
	-- add by XiaoZhiWei 2018/03/13 10:52:02 修正:拳脚的准备类型不存在,需获取拳脚1所对应的武学
	local skillId = self:getPrepareSkill(cType == "quanjiao" and "quanjiao1" or cType)
	if skillId == nil then
		if cType == "quanjiao1" or cType == "quanjiao2" then
			cType = "quanjiao"
		end
		skillId = "jiben"..cType
	end
	local skill = Skill:getSkill(skillId)

	local fistFootAddValue = 0

	if cType == "quanjiao" then
		local atkSkillId = zhao.atkSkillId
		if atkSkillId then
			local FightRoleFistFootEffect = require("src.app.models.fight.FightRoleFistFootEffect")
			fistFootAddValue = FightRoleFistFootEffect:getAtkBuffsValue(self, atkSkillId)
		end
	end

	local finalAtk = fistFootAddValue + self:getAtk()

	if DEBUG_MODE == 1 then
		print("===============================================获取出招伤害====================================================================")
		print("Role_ActiveZhao:getAtkDamage(zhao) -> ")
		print("skillLv = "..skillLv)
		print("skill.damRate = "..skill.damRate)
		print("self:getAtk() = "..self:getAtk())
		print("zhao.atk = "..zhao.atk)
		print("fistFootAddValue = "..fistFootAddValue)
		print("finalAtk = "..finalAtk)
		print(self:getName().."的出招伤害 = "..math.min((2*math.log(150+finalAtk*(1+zhao.atk))-8.5), 8)*(skill.damRate + finalAtk*(1+zhao.atk)/1000*skill.damRate))
	end

	-- return (0.1+math.floor(skillLv/10)*skill.damRate/1000)*(finalAtk)*(1+zhao.atk)

	return math.min((2*math.log(150+finalAtk*(1+zhao.atk))-8.5), 8)*(skill.damRate + finalAtk*(1+zhao.atk)/1000*skill.damRate)
end

function Role_ActiveZhao:setZhaoBreId(zhaoId,breId)
	local zhaoBreakData = self:getAttr("zhaoBreakData")
	zhaoBreakData[zhaoId] = breId
end

function Role_ActiveZhao:getZhaoBreId(zhaoId)
	local zhaoBreakData = self:getAttr("zhaoBreakData")
	if zhaoBreakData[zhaoId] then
		return zhaoBreakData[zhaoId]
	end

	return self:getSkillBreakThroughSystem():getZhaoDefaultBreId(zhaoId)
end

function Role_ActiveZhao:getZhaoLvLimit(zhaoId)
	local skillId = Skill:getSkillIdByZhaoId(zhaoId)

	local skillLv = Helper:getRange(Helper:mathFloor(self:getSkillLvWithRoleLvLimit(skillId)) , 100) -- 在0-100级的时候使用100级的条件判断
	
	local maxZhaoLv = math.floor(skillLv/100)
	if skillLv < 500 then
		maxZhaoLv = math.floor(skillLv/100)
	elseif skillLv < 540 then
		maxZhaoLv = 5
	elseif skillLv < 560 then
		maxZhaoLv = 6
	elseif skillLv < 580 then
		maxZhaoLv = 7
	elseif skillLv < 600 then
		maxZhaoLv = 8
	else
		maxZhaoLv = self:getSkillBreakThroughSystem():getZhaoLvLimit(zhaoId)
	end

	return maxZhaoLv
end

--@desc: 获取招式当前能到的经验上限
--@author:LvBin
--@time:2022-01-22 16:48:56
--@zhaoId: 
--@return
function Role_ActiveZhao:getZhaoExpLimit(zhaoId,zhaoLv)
	local skillId = Skill:getSkillIdByZhaoId(zhaoId)
	local skill = Skill:getSkill(skillId)

	local skillId = SkillConst:getZhiShiSkillParamContent(SkillConst.ZhiShiSkillParams.SKILLID_TRANSFORM)
	local xisuijingExp = self:getSkillExp(skillId)
	local xisuijing = Skill:getSkill(skillId)
	--@desc 洗点知识武学先天悟性额外洗髓转换值
	local xisuijingAdd = xisuijing:getAttrPointValue("int",xisuijingExp)
	
	--@desc 武学潜能转化率
	local skillLearnPotEfficiency = skill:getLearnPotEfficiency()

	--@desc 读书识字武学等级
	local dushuSkillLv = self:getSkillLv("dushushizi")

	local maxExp = 0.15*(100*(zhaoLv+1))^3/500*100/(skillLearnPotEfficiency*(200+((20-xisuijingAdd)+ math.floor(self:getSkillLv("dushushizi")/10)))/200)/10 - 1

	return Helper:mathFloor(maxExp)
end

--判断当前招式是否属于当前武学
function Role_ActiveZhao:checkZhaoIsBelongToSkill(zhaoId, skillId)
	if not zhaoId or not skillId then
		return false
	end

	zhaoId = string.gsub(zhaoId,"%d","")

    local zhaoList = self:getSkillZhaoList(skillId)
    for i, zhao in ipairs(zhaoList) do
        local _zhaoId = string.gsub(zhao:getId(),"%d","")
        if  _zhaoId == zhaoId then
            return true
        end
    end

    return false
end

return Role_ActiveZhao000