--
-- Author: TanQinJian
-- Date: 2019-11-27 15:56:37
--
local SkillConst = require("app.models.skill.SkillConst")

local SkillXiuLianUtil ={}

--[[
	修炼参考练功 
	
]]

--获取修炼实际相关信息
function SkillXiuLianUtil:getXiuLianActualSkillInfo(skillId,itemRole,xiuLianTime)
	local currNeedJing = self:getXiuLianNeedJing(itemRole.jjId,xiuLianTime)
	local currNeedDurable = self:getXiuLianNeedDurable(xiuLianTime)
	local currAddExp = self:getXiuLianSkillAddExp(skillId,itemRole.jjId,xiuLianTime)
	local role = User:getRole()
	local itemRoleDurable = itemRole.durable or 100
	local roleSkill = role:getSkill(skillId)
	local skillType = role:getFlag("武功修炼类型")
	local LV_LIMIT = false --技能提升等级限制
	local JING_LIMIT = false --经验限制
	local DURABLE_LIMIT = false --耐久限制
	
	if role:getAttr("jing") < currNeedJing then 
		JING_LIMIT = true
	end
	if itemRoleDurable < currNeedDurable then 
		DURABLE_LIMIT = true
	end
	
	local afterExp,actualAddExp,actualNeedJing,actualNeedDurable= 0,0,0,0
	if roleSkill then 
		afterExp = currAddExp + roleSkill.exp
	else
		print("未学习该武功 skillId 出错")
		return
	end
	local isCan,maxExp = self:checkCanLevelUp(skillId,afterExp,itemRole.jjId,skillType)

	if isCan == false then 
		actualAddExp = maxExp - roleSkill.exp
		LV_LIMIT = true
	else
		actualAddExp = currAddExp
	end

	local actualTime = xiuLianTime
	local limitType = 0 --  条件限制类型 0 无 1 精力 2 耐久 3 等级上限
	local lvTime,jingTime,durableTime = 0,0,0

	if LV_LIMIT then 
		lvTime = actualAddExp / self:getXiuLianSkillAddExp(skillId,itemRole.jjId)
		actualTime = xiuLianTime
		if lvTime < xiuLianTime then 
			actualTime = lvTime
			limitType = 3
		end
	end

	if JING_LIMIT or DURABLE_LIMIT then 
		jingTime = role:getAttr("jing") / self:getXiuLianNeedJing(itemRole.jjId)
		durableTime = itemRoleDurable / self:getXiuLianNeedDurable()
		local time_limit = jingTime < durableTime and jingTime or durableTime
		local curr_limit_type = jingTime < durableTime and 1 or 2
		if time_limit < actualTime then 
			actualTime = time_limit
			limitType = curr_limit_type
		end
	end

	actualAddExp = self:getXiuLianSkillAddExp(skillId,itemRole.jjId,actualTime)
	actualNeedJing = self:getXiuLianNeedJing(itemRole.jjId,actualTime)
	actualNeedDurable = self:getXiuLianNeedDurable(actualTime)
	if PRINT_MODE == 1 then 
		print("limitType:",limitType,"jingTime:",jingTime,"durableTime:",durableTime,"actualTime:",actualTime,"lvTime:",lvTime,"actualAddExp:",actualAddExp,"actualNeedJing:",actualNeedJing,"actualNeedDurable:",actualNeedDurable)
	end
	local afterLv = role:conversionSkillExpAndLv("lv", roleSkill.exp + actualAddExp)
	return afterLv,actualTime,actualNeedJing,actualNeedDurable,limitType
end

--skillId 当前修炼技能id exp 修炼后该技能经验 jjId 修炼道具id
function SkillXiuLianUtil:checkCanLevelUp(skillId,exp,jjId,skillType)
	local role = User:getRole()

	if not skillId or not exp then
		print("参数错误")
		return false
	end

	local maxExp = 0

	local currSkillType = skillType
	if currSkillType ~= 0 then 
		--内功不允许修炼
		local prepareList = SkillConst.PrepareList

		if prepareList[currSkillType] ~= nil and role:getSkill(prepareList[currSkillType]) ~= nil and role:getSkill(prepareList[currSkillType]).exp ~= nil then
			maxExp = role:getSkill(prepareList[currSkillType]).exp
		end

	end

	-- 练功最多可以到基本功等级 + 1 
	-- 修炼根据修炼道具可提升到基本功等级 + breakLV （breakLV 道具决定的值，由策划填写）
	do
		local breakLV =self:getRoleItemLvBuff(jjId) 
		local jbSkillLv = role:conversionSkillExpAndLv("lv", maxExp)
		-- local jbSkillLv = Skill:getLv(maxExp)
		local afterLv = jbSkillLv + breakLV
		if afterLv > role:getSkillLvLimit(skillId)  then  --不能突破上限
			afterLv = role:getSkillLvLimit(skillId)
		end
		local roleLVmax = role:getLv()
		if  jbSkillLv + breakLV > roleLVmax  then
			maxExp = role:conversionSkillExpAndLv("exp", roleLVmax)
		else
			maxExp = role:conversionSkillExpAndLv("exp", afterLv)				
		end
	end

	--@desc 练功不能超过自身武学上限等级
	maxExp = math.min(maxExp,role:conversionSkillExpAndLv("exp", role:getSkillLvLimit(skillId)))

	if maxExp < exp then
		return false , maxExp
	end
	return true, exp
end

--获取修炼所需精力 xiuLianTime为修炼时间 为空时 默认返回每秒所需
function SkillXiuLianUtil:getXiuLianNeedJing(jjId,xiuLianTime)
	if not xiuLianTime or type(xiuLianTime)~= "number" then 
		xiuLianTime = 1
	end
	local role = User:getRole()
	local subJing = 2/60
	local jingBuff = self:getRoleItemJingBuff(jjId)
	--@desc 长生诀.阳 提高练功速率
	local cLvy =  role:getFlag("练功长生诀等级",0)
	local csjJingBuff = 0 
	local num1 = 0
	if cLvy >= 600 then
		num1=1 - math.pow(cLvy / 2000,2)
		num1 = num1 * 100
		if num1 % 1 >= 0.5 then 
			num1=math.ceil(num1)
		else
			num1=math.floor(num1)
		end
		csjJingBuff = 1- num1 * 0.01
	end
	return subJing * xiuLianTime * (jingBuff + csjJingBuff + 1)
end

--获取修炼所需耐久 xiuLianTime为修炼时间 为空时 默认返回每秒所需
--一分钟一点耐久
function SkillXiuLianUtil:getXiuLianNeedDurable(xiuLianTime)
	local unitDurable = 60
	-- if DEBUG_MODE == 1 then 
	-- 	unitDurable = 20
	-- end
	if not xiuLianTime then 
		return 1/unitDurable
	end
	return math.ceil(xiuLianTime/unitDurable)
end

--获取修炼所增加经验 xiuLianTime为修炼时间 为空时 默认返回每秒所需
function SkillXiuLianUtil:getXiuLianSkillAddExp(skillId,jjId,xiuLianTime)
	if not skillId then 
		print("参数skillid 为空")
		return
	end
	if not xiuLianTime or type(xiuLianTime)~= "number" then 
		xiuLianTime = 1
	end
	local role = User:getRole()
	local skill = Skill:getSkill(skillId)
	local addExp = 200*skill:getPotEfficiency(role)/3600
	local expBuff = self:getRoleItemExpBuff(jjId)
	local csjExpBuff= 0
	--@desc 长生诀.阳 提高练功速率
	local cLvy =  role:getFlag("练功长生诀等级",0)
	local num1 = 0
	if cLvy >= 600 then
		num1=1 - math.pow(cLvy / 2000,2)
		num1 = num1 * 100
		if num1 % 1 >= 0.5 then 
			num1=math.ceil(num1)
		else
			num1=math.floor(num1)
		end
		csjExpBuff = 1- num1 * 0.01
	end
	
	return addExp * xiuLianTime * (1 + csjExpBuff + expBuff)
end

--开始修炼数据处理
function SkillXiuLianUtil:startXiuLian(skillId,itemRole,xiuLianTime)
	local xiuLianData={}
	local role = User:getRole()
	xiuLianData.startTime = GetTime()
	xiuLianData.fid = itemRole.fid
	xiuLianData.jjId = itemRole.jjId
	xiuLianData.durable = itemRole.durable
	xiuLianData.skillId = skillId
	if xiuLianTime < 0.0001 then --防止修炼时间过短 因为时间精度导致开始结束时间一致
		xiuLianTime = 0.0001
	end
	xiuLianData.endTime = GetTime() + xiuLianTime
	role:setAttr("xiuLianData", xiuLianData)
	role:setRoleCurrState(ROLE_CURR_STATE_XIULIAN)
end

--itemAttr.value 精力值消耗折扣百分比；获得武学经验值加成百分比；可突破上限等级（填0时默认为突破1级）
--jjid 假人家具id
function SkillXiuLianUtil:getRoleItemExpBuff(jjId)
	if not jjId then 
		print("SkillXiuLianUtil:getRoleItemExpBuff 参数有误！！")
		return
	end
	local expBuff = 0
	local itemAttr = Item:getOneItemByKey(jjId)
	local buffTab = string.split(itemAttr.value,";")
	if buffTab[2] then 
		expBuff = expBuff + buffTab[2]
	end
	return expBuff
end

function SkillXiuLianUtil:getRoleItemJingBuff(jjId)
	if not jjId then 
		print("SkillXiuLianUtil:getRoleItemJingBuff 参数有误！！")
		return
	end
	local jingBuff = 0
	local itemAttr = Item:getOneItemByKey(jjId)
	local buffTab = string.split(itemAttr.value,";")
	if buffTab[1] then 
		jingBuff = jingBuff - buffTab[1]
	end
	
	return jingBuff
end

function SkillXiuLianUtil:getRoleItemLvBuff(jjId)
	if not jjId then 
		print("SkillXiuLianUtil:getRoleItemLvBuff 参数有误！！")
		return
	end
	local breakLV = 1
	local itemAttr = Item:getOneItemByKey(jjId)
	local buffTab = string.split(itemAttr.value,";")
	if buffTab[3] then 
		breakLV = breakLV + buffTab[3]
	end
	return breakLV
end

function SkillXiuLianUtil:checkIsSpecailItem(jjId)
	local itemAttr = Item:getOneItemByKey(jjId)
	if itemAttr.att >=9999 then 
		return true
	end
	return false
end

local isUpload = true

function SkillXiuLianUtil:updateRoleItemInfo(callBack)
	local role = User:getRole()
	local roleCurrState = role:getAttr("roleCurrState")
	local isInXiuLian = false
	if MapIsEmpty(roleCurrState) == false then
		for state, bool in pairs(roleCurrState) do
			if tostring(state) == tostring(ROLE_CURR_STATE_XIULIAN) then
				isInXiuLian = true
				break
			end
		end
	end

	if isInXiuLian == false then
		return
	end

	local mid = role:getHouseId()
	local durable = role:getAttr("xiuLianData").durable
	if durable <1/60 then 
		durable = 0
	end
	local itemId = role:getAttr("xiuLianData").fid
	local item_jjId = role:getAttr("xiuLianData").jjId

	if self:checkIsSpecailItem(item_jjId) then 
		durable = 9999
	end
	
	local itemInfo = {}
	itemInfo.fid = itemId
	local attr = {}
	attr.durable = durable
	itemInfo.attr = attr

	local extraAttr = {}
	table.insert(extraAttr,itemInfo)

	if isUpload then
		isUpload = false
		HttpManagerEx:uploadFurnitureExtra(mid,extraAttr,function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if role:getCurrMap() and role:getCurrMap():getRoleIsInMap() == true then 
						local curMap = role:getCurrMap() 
						local currRole = curMap:getRole("f_"..itemId)
						if currRole then 
							currRole.durable = durable
						end
					end
					isUpload = true
					local xiuLianData = role:getAttr("xiuLianData")
					xiuLianData.skillId = nil
					xiuLianData.durable = nil
					role:setAttr("xiuLianData", xiuLianData)
					role:removeRoleCurrState(ROLE_CURR_STATE_XIULIAN)
					RichPrint("main","HIC你调整呼吸，收起架势，停止了修炼。")
					if callBack then 
						callBack()
					end
					return true
				else
					PopText(errmsg)
					isUpload = true
				end
			else
				PopText(errmsg)
				isUpload = true
			end 
		end, IS_SHOW_WAITING,HTTP_MANAGER_RETRY_TYPE_RETRY)
	end
	
end

return SkillXiuLianUtil000000000