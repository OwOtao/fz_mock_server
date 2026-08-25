--[[
	Author: LvBin
	Date: 2026-07-17 10:46:2
	Descripttion: 境界等级晋升条件判断类
	核心功能：判断玩家是否满足对应境界的2个晋升条件（总武学数 + 指定武学收集）
--]]

local newClass = require("third.class.NewClass")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local AdvanceCondition = {}

--@desc: 创建
--@author:LvBin
--@time:2026-07-24 20:03:54
--@activeZhaoLevelClass: 配置数据对象，提供getUpgradeNeedSkillTotal/getUpgradeNeedSkillList
--@return AdvanceCondition实例
function AdvanceCondition:create(activeZhaoLevelClass)
    local p = AdvanceCondition.new()
    p:__init(activeZhaoLevelClass)
    return p
end

function AdvanceCondition:__init(activeZhaoLevelClass)
	self.__upgradeNeedSkillTotal = activeZhaoLevelClass:getUpgradeNeedSkillTotal() or 0

	self.__upgradeNeedSkillList = activeZhaoLevelClass:getUpgradeNeedSkillList() or {}
end

--@desc: 对外入口：检查是否满足晋升全部条件
--@author:LvBin
--@time:2026-07-24 20:08:07
--@role: 角色对象
--@return bool 是否满足, string 失败原因
function AdvanceCondition:check(role)
    -- 条件1：总武学数量校验
    local numOk, errmsg = self:__checkSkillNum(role)
    if not numOk then
        return false, errmsg
    end

    -- 条件2：指定武学列表组校验
    local listOk, errmsg = self:__checkNeedSkillList(role)
    if not listOk then
        return false, errmsg
    end

    -- 两个条件全部通过
    return true
end

-- 私有方法1：校验总收集武学数量是否达标
-- return bool, errMsg
function AdvanceCondition:__checkSkillNum(role)
    local needTotal = self.__upgradeNeedSkillTotal

    -- 如果需求为0，直接跳过数量限制
    if needTotal == 0 then
        return true
    end

	-- 如果需求为-1，不可升级
	if needTotal == -1 then
        return false,"当前已达到最大等级"
    end

	local skills = role:getSkills()
	
	local skillNum = 0

	if not MapIsEmpty(skills) then
		for k, roleSkill in pairs(skills) do
			local skillId = roleSkill.id
				
			local skill = Skill:getSkill(skillId)
			
			if skill.type ~= SKILL_TYPE_SELFCREATE and skill.type ~= SKILL_TYPE_BASE then
				skillNum = skillNum + 1
			end
		end
	end

    if skillNum < needTotal then
        return false,string.format("还需收集%d门武学", needTotal - skillNum)
    end

    return true
end

-- 私有方法2：校验所有武学条件组
--配置格式：[[需求条件ID,武学类型ID,需要收集武学等级,需求收集武学数量]]
-- 规则：所有分组必须全部满足
-- return bool, errMsg
function AdvanceCondition:__checkNeedSkillList(role)
    local groupList = self.__upgradeNeedSkillList
    -- 无指定武学要求，直接通过
    if MapIsEmpty(groupList) then
        return true
    end

	local skills = role:getSkills()

    -- 遍历每一组条件
    for _groupIdx, skillData in ipairs(groupList) do
		local skillNum = 0

		local conditionType = skillData[1]

		local needSkillType = skillData[2]
        
		local needSkillLv = skillData[3]

		local needNum = skillData[4]

		if not MapIsEmpty(skills) then
			for k, roleSkill in pairs(skills) do

				local skillId = roleSkill.id
				
				local skill = Skill:getSkill(skillId)
				
				if skill.type == SKILL_TYPE_NORMAL then
					local skillTypes = skill:getSkillTypes()
	
					for _,classifyId in ipairs(skillTypes) do
						local compareType = 0
	
						if conditionType == 1 then
							compareType = SkillClassifyManager:getClassifyFirstType(classifyId)
						elseif conditionType == 2 then
							compareType = SkillClassifyManager:getClassifySecondType(classifyId)
						end
	
						if compareType == needSkillType and role:getSkillLv(skillId) >= needSkillLv then
							skillNum = skillNum + 1
						end
					end
				end
			end
		end

		if skillNum < needNum then
			local skillTypeName = ""

			if conditionType == 1 then
				skillTypeName = SkillClassifyManager:getFirstTypeName(needSkillType)
			elseif conditionType == 2 then
				skillTypeName = SkillClassifyManager:getSecondTypeName(needSkillType)
			end

			return false,string.format("还需要收集%d门%d级%s武学",needNum - skillNum,needSkillLv,skillTypeName)
		end
    end

    -- 所有分组全部满足
    return true
end

return newClass("AdvanceCondition", {}, AdvanceCondition)000000000