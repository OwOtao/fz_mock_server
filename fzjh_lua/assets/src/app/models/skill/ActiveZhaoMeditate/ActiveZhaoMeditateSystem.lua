--[[
Descripttion: 主动招式领悟
version: 
Author: LvBin
Date: 2026-07-17 10:46:2
--]]
local newClass = require("third.class.NewClass")

local ActiveZhaoCanyeClass = require("app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoCanyeClass")

local ActiveZhaoLevelClass = require("app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoLevelClass")

local ActiveZhaoConst = require("app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoConst")

local ActiveZhaoLevelRes = require("script.skill.activeZhaoMeditateLevel")["data"]

local ActiveZhaoCanyeRes = require("script.skill.activeZhaoMeditateCanye")["data"]

local CurrencyUtil = require("app.models.Currency.CurrencyUtil")

local AdvanceCondition = require("app.models.skill.ActiveZhaoMeditate.AdvanceCondition")

local ActiveZhaoMeditateSystem = {}

function ActiveZhaoMeditateSystem:create(...)
    local p = ActiveZhaoMeditateSystem.new()
    p:__init(...)
    return p
end

function ActiveZhaoMeditateSystem:__init(role)
    self.__isNotSerializable = true
    self.__role = role
end

--@desc: 初始化领悟系统数据
--@author:LvBin
--@time:2026-07-22 20:21:41
--@callback: 
--@return
function ActiveZhaoMeditateSystem:pullSysData(callback)
	local currencyVersion = self.__role:getCurrencyVersion()
    
    HttpManagerEx:getActiveZhaoMeditateInfo(currencyVersion,function(status, errcode, errmsg, data)
        if status == 200 then
            if errcode == 0 then
                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

				self:__initSysData(data)

				callback(true)
            else
                callback(false,errmsg)
            end
        else
            callback(false,errmsg)
        end
    end,IS_SHOW_WAITING)
end

function ActiveZhaoMeditateSystem:__initSysData(data)
	self.__csgwNum = data.meditateenergyNum
	
	self.__weekCsgwNum = data.fusedCount

	self.__meditateLv = data.realmLevel

	self.__meditateList = data.activeInsights
end

--@desc: 获取尘世感悟数量
--@author:LvBin
--@time:2026-07-17 12:05:18
--@return
function ActiveZhaoMeditateSystem:getCsgwNum()
	return self.__csgwNum
end

--@desc: 获取尘世感悟数量上限
--@author:LvBin
--@time:2026-07-17 12:05:18
--@return
function ActiveZhaoMeditateSystem:getCsgwNumLimit()
	local currencyResClass = CurrencyUtil:getCurrencyResClass("meditateenergy")

	return currencyResClass:getTotalLimit()
end

--@desc: 获取这周已融汇尘世感悟数量
--@author:LvBin
--@time:2026-07-17 12:05:18
--@return
function ActiveZhaoMeditateSystem:getWeekCsgwNum()
	return self.__weekCsgwNum
end

--@desc: 获取这周已融汇尘世感悟数量
--@author:LvBin
--@time:2026-07-17 12:05:18
--@return
function ActiveZhaoMeditateSystem:getWeekCsgwNumLimit()
	local levelClass = self:getCurrActiveZhaoLevelClass()

	return levelClass:getWeeklyEnergyLimit()
end

--@desc: 获取当前领悟境界等级
--@author:LvBin
--@time:2026-07-17 12:05:51
--@return
function ActiveZhaoMeditateSystem:getMeditateLv()
	return self.__meditateLv
end

--@desc: 获取领悟列表
--@author:LvBin
--@time:2026-07-17 15:46:39
--@return
function ActiveZhaoMeditateSystem:getActiveZhaoMeditateList()
    local retSkills = {}
    local skillList = self.__role:getSkills()
    for skillId,v in pairs(skillList) do
        local skill = Skill:getSkill(skillId)
        local zhaoList = self.__role:getSkillZhaoList(skillId)
        local isLearn = false
        if not MapIsEmpty(zhaoList) then
            for i,zhao in ipairs(zhaoList) do
                if self.__role:getSkillZhaoExp(zhao.id) > 0 then
                    isLearn = true
                    break
                end
            end
        end
        if isLearn == true then
            table.insert(retSkills,skill)
        end
    end
    return retSkills
end

--@desc: 获取残页列表
--@author:LvBin
--@time:2026-07-21 18:47:18
--@return
function ActiveZhaoMeditateSystem:getActiveZhaoCanYeList()
    local zhaoShuXiang = self.__role:getAttr("zhaoShuXiang")

    return zhaoShuXiang
end

--@desc: 获取残页数量
--@author:LvBin
--@time:2026-07-22 14:57:00
--@canyeId: 残页id
--@return
function ActiveZhaoMeditateSystem:getCanYeNum(canyeId)
	local canyeData = self.__role:getZhaoShuXiang(canyeId)

	return canyeData ~= nil and canyeData.count or 0
end

--@desc: 获取境界等级资源对象
--@author:LvBin
--@time:2026-07-21 18:47:48
--@id: 境界等级
--@return [src.app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoLevelClass#ActiveZhaoLevelClass]
function ActiveZhaoMeditateSystem:getActiveZhaoLevelClass(id)
	local res = assert(ActiveZhaoLevelRes[id],"境界资源不存在 id = "..id)
	return ActiveZhaoLevelClass:create(res)
end

--@desc: 获取当前境界等级资源对象
--@author:LvBin
--@time:2026-07-23 11:38:01
--@return
function ActiveZhaoMeditateSystem:getCurrActiveZhaoLevelClass()
	return self:getActiveZhaoLevelClass(self:getMeditateLv())
end

--@desc: 获取境界最高等级
--@author:LvBin
--@time:2026-07-21 18:48:45
--@return
function ActiveZhaoMeditateSystem:getActiveZhaoMaxLevel()
	return #ActiveZhaoLevelRes
end

--@desc: 获取残页资源对象
--@author:LvBin
--@time:2026-07-23 11:19:50
--@id: 残页id
--@return [src.app.models.skill.ActiveZhaoMeditate.Config.ActiveZhaoCanyeClass#ActiveZhaoCanyeClass]
function ActiveZhaoMeditateSystem:getActiveZhaoCanyeClass(id)
	local res = assert(ActiveZhaoCanyeRes[id],"残页资源不存在 id = "..id)
	return ActiveZhaoCanyeClass:create(res)
end

--@desc: 融汇获取尘世感悟数量
--@author:LvBin
--@time:2026-07-21 18:49:59
--@canyeTable: 融汇的残页列表
--@return
function ActiveZhaoMeditateSystem:getMergeCsgwNum(canyeTable)
	local mergeCsgwNum = 0

	for itemId,num in pairs(canyeTable) do
		local _toEnergyBase= self:getActiveZhaoCanyeClass(itemId):getToEnergyBase()

		local _canyeToPowerAdd = self:getCurrActiveZhaoLevelClass():getCanyeToPowerAdd()

		mergeCsgwNum = mergeCsgwNum + (_toEnergyBase + _canyeToPowerAdd) * num
	end

	return mergeCsgwNum
end


--@desc: 是否正在领悟
--@author:LvBin
--@time:2026-07-22 10:33:19
--@return
function ActiveZhaoMeditateSystem:isMeditating()
	return #self.__meditateList >= 1
end

--@desc: 领悟剩余时间
--@author:LvBin
--@time:2026-07-24 19:19:14
--@return
function ActiveZhaoMeditateSystem:getResidueTime()
	local meditatingInfo = self:getMeditatingInfo()

	local residueTime = math.ceil(meditatingInfo.startTime + tonumber(meditatingInfo.needTime) - GetTime())

    return math.max(residueTime, 0)
end

--@desc: 领悟是否完成
--@author:LvBin
--@time:2026-07-22 11:44:32
--@return
function ActiveZhaoMeditateSystem:isCompleteMeditate()
    return  self:getResidueTime() <= 0
end

--@desc: 获取正在领悟的招式数据
--@author:LvBin
--@time:2026-07-22 11:57:25
--@return
function ActiveZhaoMeditateSystem:getMeditatingInfo()
	return self.__meditateList[1]
end

--@desc: 计算领悟获取招式熟练度 
--@author:LvBin
--@time:2026-07-23 11:09:44
--@canyeId:
	--@canyeNum:
	--@csgwNum: 
--@return
function ActiveZhaoMeditateSystem:calAddZhaoExp(canyeId,canyeNum,csgwNum)
	-- 残页领悟熟练度 = 向下取整((单个残页领悟熟练度基础值+境界残页领悟加成值)*该残页投入数)
	local currLevelClass = self:getCurrActiveZhaoLevelClass()

	local _toProficiencyBase = self:getActiveZhaoCanyeClass(canyeId):getToProficiencyBase()

	local _canyeToProficiencyAdd = currLevelClass:getCanyeToProficiencyAdd()

	local _canyeAddExp = (_toProficiencyBase + _canyeToProficiencyAdd) * canyeNum

	_canyeAddExp = math.floor(_canyeAddExp)

	-- 资源领悟熟练度 = 向下取整((资源领悟基础值+境界尘世领悟加成值)*能量投入数)

	local _powerToProficiencyBase = ActiveZhaoConst:getConf("powerToProficiencyBase")

	local _powerToProficiencyAdd = currLevelClass:getPowerToProficiencyAdd()

	local _csgwAddExp = (_powerToProficiencyBase + _powerToProficiencyAdd) * csgwNum

	_csgwAddExp = math.floor(_csgwAddExp)

	local addExp = _canyeAddExp + _csgwAddExp

	local itemAttr = Item:getOneItemByKey(canyeId)
	
	local zhaoId = itemAttr.zhaoId

	local zhaoExp = math.floor(self.__role:getSkillZhaoExp(zhaoId))

	local maxExp = self.__role:getZhaoExpLimit(zhaoId,self.__role:getZhaoLvLimit(zhaoId))

	local spillExp = 0

	local canAddExp = math.max(maxExp - zhaoExp,0)

	if addExp > canAddExp then
        spillExp = addExp - canAddExp
    end

	return addExp,spillExp
end

--@desc: 计算尘世感悟最大投入
--@author:LvBin
--@time:2026-07-29 18:12:37
--@canyeId: 
--@return
function ActiveZhaoMeditateSystem:calCsgwMaxNum(canyeId,canyeNum)
	-- 残页领悟熟练度 = 向下取整((单个残页领悟熟练度基础值+境界残页领悟加成值)*该残页投入数)
	local currLevelClass = self:getCurrActiveZhaoLevelClass()

	local _toProficiencyBase = self:getActiveZhaoCanyeClass(canyeId):getToProficiencyBase()

	local _canyeToProficiencyAdd = currLevelClass:getCanyeToProficiencyAdd()

	local _canyeAddExp = (_toProficiencyBase + _canyeToProficiencyAdd) * canyeNum

	_canyeAddExp = math.floor(_canyeAddExp)

	local itemAttr = Item:getOneItemByKey(canyeId)

	local zhaoId = itemAttr.zhaoId

	local zhaoExp = self.__role:getSkillZhaoExp(zhaoId)

	local maxExp = self.__role:getZhaoExpLimit(zhaoId,self.__role:getZhaoLvLimit(zhaoId))

	local canAddExp = maxExp - zhaoExp - _canyeAddExp

	canAddExp = math.max(canAddExp,0)

	local _powerToProficiencyBase = ActiveZhaoConst:getConf("powerToProficiencyBase")

	local _powerToProficiencyAdd = currLevelClass:getPowerToProficiencyAdd()

	local _one_csgwAddExp = _powerToProficiencyBase + _powerToProficiencyAdd

	local csgwNum = math.ceil(canAddExp/_one_csgwAddExp)

	return csgwNum
end

--@desc: 计算残页最大投入
--@author:LvBin
--@time:2026-07-29 18:12:37
--@canyeId: 
--@return
function ActiveZhaoMeditateSystem:calCanYeMaxNum(canyeId,csgwNum)
	-- 资源领悟熟练度 = 向下取整((资源领悟基础值+境界尘世领悟加成值)*能量投入数)
	local currLevelClass = self:getCurrActiveZhaoLevelClass()

	local _powerToProficiencyBase = ActiveZhaoConst:getConf("powerToProficiencyBase")

	local _powerToProficiencyAdd = currLevelClass:getPowerToProficiencyAdd()

	local _csgwAddExp = (_powerToProficiencyBase + _powerToProficiencyAdd) * csgwNum

	_csgwAddExp = math.floor(_csgwAddExp)

	local itemAttr = Item:getOneItemByKey(canyeId)
	
	local zhaoId = itemAttr.zhaoId
	
	local zhaoExp = self.__role:getSkillZhaoExp(zhaoId)
	
	local maxExp = self.__role:getZhaoExpLimit(zhaoId,self.__role:getZhaoLvLimit(zhaoId))

	local canAddExp = maxExp - zhaoExp - _csgwAddExp
	
	canAddExp = math.max(canAddExp,0)

	local _toProficiencyBase = self:getActiveZhaoCanyeClass(canyeId):getToProficiencyBase()

	local _canyeToProficiencyAdd = currLevelClass:getCanyeToProficiencyAdd()

	local _one_canyeAddExp = _toProficiencyBase + _canyeToProficiencyAdd

	local canyeNum = math.ceil(canAddExp/_one_canyeAddExp)

	return canyeNum
end

--@desc: 计算领悟所需时间
--@author:LvBin
--@time:2026-07-23 15:19:57
--@canyeId:
	--@canyeNum:
	--@csgwNum: 
--@return
function ActiveZhaoMeditateSystem:calNeedTime(canyeId,canyeNum,csgwNum)
	-- 残页领悟挂机时间（秒） = 单个残页挂机基础时间*该残页投入数
	local _costTimeBase = self:getActiveZhaoCanyeClass(canyeId):getCostTimeBase()

	local _canyeTime = _costTimeBase * canyeNum

	-- 资源领悟挂机时间（秒） = 资源挂机基础时间*该残页投入数

	local _powerCostTimeBase = ActiveZhaoConst:getConf("powerCostTimeBase")

	local _csgwTime = _powerCostTimeBase * csgwNum

	local needTime = math.floor(_canyeTime + _csgwTime)

	return needTime
end

--@desc: 开始领悟
--@author:LvBin
--@time:2026-07-23 21:19:53
--@zhaoId: 招式id
--@canyeNum: 残页数量
--@csgwNum: 尘世感悟数量
--@callback: 
--@return
function ActiveZhaoMeditateSystem:startMeditate(zhaoId,canyeNum,csgwNum,callback)
	local canyeId = zhaoId.."canye"

	local needTime = self:calNeedTime(canyeId,canyeNum,csgwNum)

	local addZhaoExp = self:calAddZhaoExp(canyeId,canyeNum,csgwNum)

	local meditateData = {
		zhaoId = zhaoId,
		meditateenergyCost = csgwNum,
		canyeId = canyeId,
		startTime = GetTime(),
		canyeCost = canyeNum,
		needTime = needTime,
		addZhaoExp = addZhaoExp
	}

	local currencyVersion = self.__role:getCurrencyVersion()
    
    HttpManagerEx:startActiveZhaoMeditate(
		meditateData,
		currencyVersion,
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.currencyVersion then
						self.__role:setCurrencyVersion(data.currencyVersion)
					end

					self.__csgwNum = self.__csgwNum - csgwNum

					self.__role:addZhaoShuXiang(canyeId, - canyeNum)

					table.insert(self.__meditateList,meditateData)

					callback(true)
				else
					callback(false,errmsg)
				end
			else
				callback(false,errmsg)
			end
		end,
		IS_SHOW_WAITING
	)
end

--@desc: 取消领悟
--@author:LvBin
--@time:2026-07-22 20:54:38
--@callback: 
--@return
function ActiveZhaoMeditateSystem:cancelMeditate(callback)
	local currencyVersion = self.__role:getCurrencyVersion()
    
	local zhaoId = self:getMeditatingInfo().zhaoId

    HttpManagerEx:cancelActiveZhaoMeditate(
		zhaoId,
		currencyVersion,
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.currencyVersion then
						self.__role:setCurrencyVersion(data.currencyVersion)
					end

					self.__meditateList = {}

					callback(true)
				else
					callback(false,errmsg)
				end
			else
				callback(false,errmsg)
			end
		end,
		IS_SHOW_WAITING
	)
end

--@desc: 完成领悟
--@author:LvBin
--@time:2026-07-22 21:02:53
--@callback: 
--@return
function ActiveZhaoMeditateSystem:completeMeditate(callback)
	local currencyVersion = self.__role:getCurrencyVersion()
    
	local meditatingInfo = self:getMeditatingInfo()

	local zhaoId = meditatingInfo.zhaoId

    HttpManagerEx:completeActiveZhaoMeditate(
		zhaoId,
		currencyVersion,
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.currencyVersion then
						self.__role:setCurrencyVersion(data.currencyVersion)
					end

					local zhaoExp = self.__role:getSkillZhaoExp(zhaoId)

					local maxExp = self.__role:getZhaoExpLimit(zhaoId,self.__role:getZhaoLvLimit(zhaoId))

					local addZhaoExp = Helper:getRange(meditatingInfo.addZhaoExp,0,maxExp - zhaoExp)

					self.__role:addSkillZhaoExp(zhaoId, addZhaoExp)

					self.__meditateList = {}

					callback(true,string.format("领悟完成，获得%d点%s熟练度", math.floor(addZhaoExp),Skill:getActiveZhao(zhaoId):getName()))
				else
					callback(false,errmsg)
				end
			else
				callback(false,errmsg)
			end
		end,
		IS_SHOW_WAITING
	)
end

--@desc: 融汇主动招式残页
--@author:LvBin
--@time:2026-07-22 21:10:14
--@callback: 
--@return
function ActiveZhaoMeditateSystem:mergeActiveZhaoCanYe(fuseCosts,callback)
	local currencyVersion = self.__role:getCurrencyVersion()

    HttpManagerEx:executeFuseActiveZhaoCanYe(
		fuseCosts,
		currencyVersion,
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.currencyVersion then
						self.__role:setCurrencyVersion(data.currencyVersion)
					end

					self.__csgwNum = data.meditateenergyNum

					self.__weekCsgwNum = data.fusedCount

					for itemId,num in pairs(fuseCosts) do
						self.__role:addZhaoShuXiang(itemId, - num)
					end

					callback(true,string.format("成功融汇，获得%d点尘世感悟", data.addNum))
				else
					callback(false,errmsg)
				end
			else
				callback(false,errmsg)
			end
		end,
		IS_SHOW_WAITING
	)
end

--@desc: 提升领悟境界
--@author:LvBin
--@time:2026-07-22 21:10:14
--@callback: 
--@return
function ActiveZhaoMeditateSystem:advanceActiveZhaoMeditateLevel(callback)
	local currencyVersion = self.__role:getCurrencyVersion()
	
	HttpManagerEx:advanceActiveZhaoMeditateLevel(
		currencyVersion,
		function(status, errcode, errmsg, data)
			if status == 200 then
				if errcode == 0 then
					if data.currencyVersion then
						self.__role:setCurrencyVersion(data.currencyVersion)
					end
					self.__csgwNum = data.meditateenergyNum
					
					self.__meditateLv = data.realmLevel

					callback(true,string.format("成功提升境界到%d级", data.realmLevel))
				else
					callback(false,errmsg)
				end
			else
				callback(false,errmsg)
			end
		end,
		IS_SHOW_WAITING
	)
end

--@desc: 检查当前境界晋升条件
--@author:LvBin
--@time:2026-07-24 21:21:21
--@return
function ActiveZhaoMeditateSystem:checkAdvanceCondition()
	local condition = AdvanceCondition:create(self:getCurrActiveZhaoLevelClass())

	local isOk,msg = condition:check(self.__role)

	return isOk,msg
end

return newClass("ActiveZhaoMeditateSystem", {}, ActiveZhaoMeditateSystem)
0