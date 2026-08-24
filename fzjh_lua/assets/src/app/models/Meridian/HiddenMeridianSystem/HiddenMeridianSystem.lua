--[[
Descripttion: 
version: 
Author: LvBin
Date: 2025-02-27 15:56:38
--]]
local newClass = require("third.class.NewClass")

local IHiddenMeridianSystem = require("app.models.Meridian.HiddenMeridianSystem.IHiddenMeridianSystem")

local HiddenMeridianResources = require("app.models.Meridian.HiddenMeridianResources.HiddenMeridianResources")

local HiddenMeridianBuff = require("app.models.Meridian.HiddenMeridianBuff.HiddenMeridianBuff")

local HiddenMeridianChart = require("app.models.Meridian.HiddenMeridianChart")

local Acupoint = require("app.models.Meridian.Acupoint")

local HiddenMeridianConstants = require("app.models.Meridian.HiddenMeridianConstants")

--@SuperType [src.app.models.Meridian.HiddenMeridianSystem.IHiddenMeridianSystem#IHiddenMeridianSystem]
local HiddenMeridianSystem = {}

function HiddenMeridianSystem:create(...)
    local p = HiddenMeridianSystem.new()
    p:__init(...)
    return p
end

function HiddenMeridianSystem:ctor()
    self.__ygpillCount = 0 --养真丹数量

    self.__isInitSysData = false --是否初始化过系统数据

    self.__version = 0 -- 版本号

    self.__currHiddenMeridianChartId = "minditem1" -- 当前隐脉图id

    self.__breakThroughState = false -- 是否处于破境状态

    self.__breakThroughFinishTime = 0 -- 破境结束时间

    self.__currAcupointId = nil -- 当前冲脉的窍关id

    self.__acupointActivateState = false -- 是否处于冲脉状态

    self.__acupointActivateFinishTime = 0 -- 冲脉结束时间

    self.__yuQiState = false -- 是否处于余炁状态

    self.__yuQiBuffAttrs = {} -- 余炁buff属性

    self.__yuQiBuffActiveEffects = {} -- 余炁buff主动效果

    self.__yuQiBuffIds = {} --余炁玄络Id

    -- Buff映射表
    self.__buffMap = {}

    -- 窍关映射表
    self.__acupointMap = {}
end

function HiddenMeridianSystem:__init(role)
    self.__role = assert(role, "HiddenMeridianSystem:__init role is nil")

	self:__repairHiddenMeridianData()
end

function HiddenMeridianSystem:__repairHiddenMeridianData()
	--pvp转换二维数组json报错修复,把buff主动效果结构改成map结构
	if self.__role:getInheritFlag("repairHiddenMeridianData") == 0 then
		local roleHiddenMeridianData = self.__role:getAttr("hiddenMeridianData")

		local yuQiBuffActiveEffects = roleHiddenMeridianData.yuQiBuffActiveEffects

		local newYuQiBuffActiveEffects = {}
		
		if not MapIsEmpty(yuQiBuffActiveEffects) then
			for i,v in ipairs(yuQiBuffActiveEffects) do
				newYuQiBuffActiveEffects[tostring(i)] = v
			end
		end

		roleHiddenMeridianData.yuQiBuffActiveEffects = newYuQiBuffActiveEffects

		self.__role:setAttr("hiddenMeridianData",roleHiddenMeridianData)

		self.__role:setInheritFlag("repairHiddenMeridianData",1)
	end
end

--@desc: 是否初始化过系统数据
--@author:LvBin
--@time:2025-03-07 14:55:16
--@return
function HiddenMeridianSystem:isInitSysData()
    return self.__isInitSysData == true
end

--@desc: 初始化系统数据
--@author:LvBin
--@time:2025-03-01 12:09:42
--@return
function HiddenMeridianSystem:initSysData()
    local roleHiddenMeridianData = self.__role:getAttr("hiddenMeridianData")

    self.__version = roleHiddenMeridianData.version

    self.__currHiddenMeridianChartId = roleHiddenMeridianData.currHiddenMeridianChartId

    self.__breakThroughState = roleHiddenMeridianData.breakThroughState

    self.__breakThroughFinishTime = roleHiddenMeridianData.breakThroughFinishTime

    self.__currAcupointId = roleHiddenMeridianData.currAcupointId

    self.__acupointActivateState = roleHiddenMeridianData.acupointActivateState

    self.__acupointActivateFinishTime = roleHiddenMeridianData.acupointActivateFinishTime

    self.__yuQiState = roleHiddenMeridianData.yuQiState

    self.__yuQiBuffAttrs = roleHiddenMeridianData.yuQiBuffAttrs
    
    self.__yuQiBuffActiveEffects = roleHiddenMeridianData.yuQiBuffActiveEffects

    self.__yuQiBuffIds = roleHiddenMeridianData.yuQiBuffIds

    if not MapIsEmpty(roleHiddenMeridianData.buffMap) then
        self.__buffMap = table.mergeToLeft({}, roleHiddenMeridianData.buffMap)
    end

    if not MapIsEmpty(roleHiddenMeridianData.acupointMap) then
        self.__acupointMap = table.mergeToLeft({}, roleHiddenMeridianData.acupointMap)
    end

    self.__isInitSysData = true
end

--@desc: 保存人物数据
--@author:LvBin
--@time:2025-03-01 12:10:01
--@return
function HiddenMeridianSystem:__saveRoleData()
    local roleHiddenMeridianData = {}

    roleHiddenMeridianData.version = self.__version

    roleHiddenMeridianData.currHiddenMeridianChartId = self.__currHiddenMeridianChartId

    roleHiddenMeridianData.breakThroughState = self.__breakThroughState

    roleHiddenMeridianData.breakThroughFinishTime = self.__breakThroughFinishTime

    roleHiddenMeridianData.currAcupointId = self.__currAcupointId

    roleHiddenMeridianData.acupointActivateState = self.__acupointActivateState

    roleHiddenMeridianData.acupointActivateFinishTime = self.__acupointActivateFinishTime

    roleHiddenMeridianData.yuQiState = self.__yuQiState

    roleHiddenMeridianData.yuQiBuffAttrs = self.__yuQiBuffAttrs

    roleHiddenMeridianData.yuQiBuffActiveEffects = self.__yuQiBuffActiveEffects

    roleHiddenMeridianData.yuQiBuffIds = self.__yuQiBuffIds

    roleHiddenMeridianData.buffMap = self.__buffMap

    roleHiddenMeridianData.acupointMap = self.__acupointMap

    self.__role:setAttr("hiddenMeridianData", roleHiddenMeridianData)
end

function HiddenMeridianSystem:getRole()
    return self.__role
end

--@desc: 获取养真丹数量
--@author:LvBin
--@time:2025-03-04 15:14:21
--@return
function HiddenMeridianSystem:getYgpillCount()
    return self.__ygpillCount
end

--@desc: 获取养真丹中文名字
--@author:LvBin
--@time:2025-03-11 17:29:54
--@return
function HiddenMeridianSystem:getYgpillName()
    return Role:getCHAttrName(HiddenMeridianConstants.ResItemId)
end

--@desc: 获取隐脉相关资源数量(现在只有养真丹)
--@author:LvBin
--@time:2025-03-04 15:11:33
--@callback: 回调函数
--@return
function HiddenMeridianSystem:getHiddenMeridianInfo(callback)
    HttpManagerEx:getHiddenMeridianInfo(
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__ygpillCount = data.ygpill

                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 隐脉系统解锁条件为：二转且角色等级350级
--@author:LvBin
--@time:2025-02-27 10:35:20
--@return
function HiddenMeridianSystem:isUnlocked()
    return self.__role:getAttr("inheritCount") >= 2 and self.__role:getLv() >= 350
end

--@desc: 获取玄脉图对象
--@author:LvBin
--@time:2025-02-19 17:48:49
--@return [src.app.models.Meridian.HiddenMeridianChart#HiddenMeridianChart]
function HiddenMeridianSystem:getHiddenMeridianChart()
    return HiddenMeridianChart:create(self.__currHiddenMeridianChartId, self.__acupointMap)
end

--@desc: 获取当前玄脉图等级
--@author:LvBin
--@time:2025-02-21 11:34:21
--@return
function HiddenMeridianSystem:getHiddenMeridianChartLv()
    return self:getHiddenMeridianChart():getClass()
end

--@desc: 获取玄脉图最高等级
--@author:LvBin
--@time:2025-02-21 11:42:19
--@return
function HiddenMeridianSystem:getHiddenMeridianChartMaxLv()
    return HiddenMeridianResources:getHiddenMeridianChartMaxLv()
end

--@desc: 当前玄脉图等级是否已经最高
--@author:LvBin
--@time:2025-02-21 11:27:30
--@return
function HiddenMeridianSystem:isHiddenMeridianChartMaxLv()
    return self:getHiddenMeridianChartLv() == self:getHiddenMeridianChartMaxLv()
end

--@desc: 获取指定等级玄脉图对象
--@author:LvBin
--@time:2025-02-19 17:48:49
--@return [src.app.models.Meridian.HiddenMeridianChart#HiddenMeridianChart]
function HiddenMeridianSystem:getHiddenMeridianChartByLv(lv)
    local chartId = HiddenMeridianResources:getHiddenMeridianChartIdByLv(lv)
    return HiddenMeridianChart:create(chartId)
end

--@desc: 获取窍关对象
--@author:LvBin
--@time:2025-02-19 17:48:49
--@return [src.app.models.Meridian.Acupoint#Acupoint]
function HiddenMeridianSystem:getAcupoint(acupointId)
    return Acupoint:create(acupointId, self.__acupointMap[acupointId])
end

--@desc: 获取玄络对象
--@author:LvBin
--@time:2025-02-19 17:48:49
--@return [src.app.models.Meridian.HiddenMeridianBuff.HiddenMeridianBuff#HiddenMeridianBuff]
function HiddenMeridianSystem:getHiddenMeridianBuff(meridianBuffId)
    return HiddenMeridianBuff:create(self.__role, meridianBuffId)
end

--@desc: 检查指定窍关是否已解锁
--@author:LvBin
--@time:2025-02-20 16:06:53
--@acupointIndex: 窍关位置索引
--@return
function HiddenMeridianSystem:isAcupointUnlocked(acupointIndex)
    return self:getHiddenMeridianChart():isAcupointUnlocked(acupointIndex)
end

--@desc: 检查指定玄络buff是否已解锁
--@author:LvBin
--@time:2025-02-20 16:06:53
--@meridianBuffId: 玄络buffId
--@return
function HiddenMeridianSystem:isBuffUnlocked(meridianBuffId)
    if self.__buffMap[meridianBuffId] then
        return true
    end

    return false
end

--@desc: 检查指定玄络buff是否已安装
--@author:LvBin
--@time:2025-02-20 16:06:53
--@meridianBuffId: 玄络buffId
--@return true or false ,安装的窍关id
function HiddenMeridianSystem:isBuffAttach(meridianBuffId)
    for acupointId, v in pairs(self.__acupointMap) do
        if v.buffId == meridianBuffId then
            return true, acupointId
        end
    end

    return false
end

--@desc: 获取窍关装备的玄络buffId
--@author:LvBin
--@time:2025-03-06 17:30:33
--@acupointId:
--@return
function HiddenMeridianSystem:getAcupointAttachBuffId(acupointId)
    for id, v in pairs(self.__acupointMap) do
        if id == acupointId then
            return v.buffId
        end
    end
end

--@desc: 窍关安装玄络buff
--@author:LvBin
--@time:2025-02-20 16:06:53
--@acupointId: 窍关id
--@meridianBuffId: 玄络buffId
--@return
function HiddenMeridianSystem:attachMeridianBuff(acupointId, meridianBuffId)
    local isAttach, attachAcupointId = self:isBuffAttach(meridianBuffId)

    if isAttach then
        self.__acupointMap[attachAcupointId].buffId = nil
    end

    if self.__acupointMap[acupointId] == nil then
        self.__acupointMap[acupointId] = {}
    end

    self.__acupointMap[acupointId].buffId = meridianBuffId

    self:__saveRoleData()
end

--@desc: 获取隐脉buff加成属性列表
--@author:LvBin
--@time:2025-02-20 20:51:53
--@return
function HiddenMeridianSystem:getHiddenMeridianBuffAttrs()
    if self.__yuQiState then
        local yuQiRatio = self:getYuQiRatio()

        return table.map(
            self.__yuQiBuffAttrs,
            function(buffInfoMap)
                return table.map(
                    buffInfoMap,
                    function(buffValue)
                        return buffValue * yuQiRatio
                    end
                )
            end
        )
    end

    return self:getCurrHiddenMeridianBuffAttrs()
end

--[[
    @desc: 获取当前隐脉玄络buffId列表
    author:tanqinjian
    time:2025-09-05 11:09:26
    @return:
]]
function HiddenMeridianSystem:getCurrHiddenMeridianBuffIds()
    local buffIdList = {}

    for i, acupoint in ipairs(self:getHiddenMeridianChart():getAcupointList()) do
        if acupoint:isAttachBuff() then
            local buffId = acupoint:getAttachBuffId()
            table.insert(buffIdList, buffId)
        end
    end

    return buffIdList
end

--@desc: 获取当前隐脉图buff加成属性列表
--@author:LvBin
--@time:2025-02-20 20:51:53
--@return
function HiddenMeridianSystem:getCurrHiddenMeridianBuffAttrs()
    local buffAttrs = {}

    for i, acupoint in ipairs(self:getHiddenMeridianChart():getAcupointList()) do
        if acupoint:isAttachBuff() then
            local buffId = acupoint:getAttachBuffId()

            --@RefType[src.app.models.Meridian.HiddenMeridianBuff.HiddenMeridianBuff#HiddenMeridianBuff]
            local meridianBuff = HiddenMeridianBuff:create(self.__role, buffId)

            local effectList = meridianBuff:getTriggerEffectList()

            for i, effect in ipairs(effectList) do
                if buffAttrs[effect:getDamageId()] == nil then
                    buffAttrs[effect:getDamageId()] = {}
                end

                if buffAttrs[effect:getDamageId()][effect:getDamageType()] == nil then
                    buffAttrs[effect:getDamageId()][effect:getDamageType()] = effect:getValue()
                else
                    buffAttrs[effect:getDamageId()][effect:getDamageType()] = buffAttrs[effect:getDamageId()][effect:getDamageType()] + effect:getValue()
                end
            end
        end
    end

    return buffAttrs
end

--@desc: 获取隐脉图buff主动效果列表
--@author:LvBin
--@time:2025-02-20 20:51:53
--@return
function HiddenMeridianSystem:getHiddenMeridianActiveEffectDataList()
    if self.__yuQiState then
        return self.__yuQiBuffActiveEffects
    end

    return self:getCurrHiddenMeridianActiveEffectDatatList()
end

--@desc: 获取当前隐脉图buff主动效果列表
--@author:LvBin
--@time:2025-06-19 14:39:16
--@return
function HiddenMeridianSystem:getCurrHiddenMeridianActiveEffectDatatList()
    local activeEffectDataList = {}

	local effectIndex = 0

    for i, acupoint in ipairs(self:getHiddenMeridianChart():getAcupointList()) do
        if acupoint:isAttachBuff() then
            local buffId = acupoint:getAttachBuffId()

            --@RefType[src.app.models.Meridian.HiddenMeridianBuff.HiddenMeridianBuff#HiddenMeridianBuff]
            local meridianBuff = HiddenMeridianBuff:create(self.__role, buffId)

			local triggerActiveEffects = meridianBuff:getTriggerActiveEffectDataList()

			if not MapIsEmpty(triggerActiveEffects) then
				for _,effectData in ipairs(triggerActiveEffects) do
					effectIndex = effectIndex + 1

					activeEffectDataList[tostring(effectIndex)] = effectData
				end
			end
        end
    end

    return activeEffectDataList
end

--[[
    @desc: 获取当前隐脉图buff主动效果作用文本
    author:tanqinjian
    time:2025-08-18 15:32:42
    @return:
]]
function HiddenMeridianSystem:getCurrHiddenMeridianActiveEffectAttrText()
    local textList = {}

    for i, acupoint in ipairs(self:getHiddenMeridianChart():getAcupointList()) do
        if acupoint:isAttachBuff() then
            local buffId = acupoint:getAttachBuffId()

            --@RefType[src.app.models.Meridian.HiddenMeridianBuff.HiddenMeridianBuff#HiddenMeridianBuff]
            local meridianBuff = HiddenMeridianBuff:create(self.__role, buffId)

            local text = meridianBuff:getSpecialEffectText()

			if text ~= "" then
                table.insert(textList, text)
            end
        end
    end

    return textList
end

--@desc: 获取余炁隐脉buff加成属性列表
--@author:LvBin
--@time:2025-02-21 19:23:59
--@return
function HiddenMeridianSystem:getYuQiBuffAttrs()
    return self.__yuQiBuffAttrs
end

--[[
    @desc: 获取余炁buff特殊效果文本描述
    author:tanqinjian
    time:2025-09-05 11:04:50
    @return:
]]
function HiddenMeridianSystem:getYuQiBuffEffectText()
    local textList = {}

    if self.__yuQiState then
        for i, buffId in ipairs(self.__yuQiBuffIds) do
            local meridianBuff = HiddenMeridianBuff:create(self.__role, buffId)

            local text = meridianBuff:getSpecialEffectText()

			if text ~= "" then
                table.insert(textList, text)
            end
        end
    end

    return textList
end

--@desc: 获取破境状态
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function HiddenMeridianSystem:getBreakThroughState()
    return self.__breakThroughState
end

--@desc: 获取破境完成时间
--@author:LvBin
--@time:2025-02-25 17:33:54
--@return
function HiddenMeridianSystem:getBreakThroughTime()
    return self.__breakThroughFinishTime
end

--@desc: 破境是否完成
--@author:LvBin
--@time:2025-02-25 16:00:24
--@return
function HiddenMeridianSystem:isFinishBreakThrough()
    return GetTime() > self.__breakThroughFinishTime
end

--@desc: 能否终止破境
--@author:LvBin
--@time:2025-03-11 15:56:59
--@return
function HiddenMeridianSystem:isStopBreakThrough()
    if self:isFinishBreakThrough() then
        return false, "本次破境已经完成，无法终止"
    end

    return true
end

--@desc: 破境
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function HiddenMeridianSystem:breakThrough(callback)
    HttpManagerEx:startHiddenMeridianBreakThrough(
        self.__currHiddenMeridianChartId,
        self.__version,
        self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local time = self:getHiddenMeridianChart():getTime()

                self.__breakThroughFinishTime = GetTime() + time

                self.__breakThroughState = true

                self.__ygpillCount = data.count

                self.__version = data.version

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

                self:__saveRoleData()

                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 终止破境
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function HiddenMeridianSystem:stopBreakThrough(callback)
    HttpManagerEx:cancelHiddenMeridianBreakThrough(
        self.__currHiddenMeridianChartId,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__breakThroughState = false

                self.__breakThroughFinishTime = 0

                self.__version = data.version

                self:__saveRoleData()

                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 能否加速破境
--@author:LvBin
--@time:2025-03-11 16:03:51
--@cost: 加速选择消耗的资源数量
--@return
function HiddenMeridianSystem:isSpeedUpBreakThrough(cost)
    if self:isFinishBreakThrough() then
        return false, "本次破境已经完成，无法进行加速"
    end

    if cost <= 0 then
        return false, "加速选择消耗的资源数量要大于0"
    end

    return true
end

--@desc: 加速破境
--@author:LvBin
--@time:2025-02-25 19:22:28
--@cost: 加速消耗的资源数量
--@callback:
--@return
function HiddenMeridianSystem:speedUpBreakThrough(cost, callback)
    local realCost = self:__calcSpeedUpBreakThroughCost(cost)

    HttpManagerEx:speedUpHiddenMeridianBreakThrough(
        self.__currHiddenMeridianChartId,
        cost,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__breakThroughFinishTime = self.__breakThroughFinishTime - self:__calcSpeedUpTime(data.cost)

                self.__ygpillCount = data.count

                self.__version = data.version

                self:__saveRoleData()

                callback(true, "成功使用" .. data.cost .. "个" .. self:getYgpillName())
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 计算加速破境实际消耗的资源数量
--@author:LvBin
--@time:2025-03-11 16:14:59
--@cost: 选择消耗得资源数量
--@return
function HiddenMeridianSystem:__calcSpeedUpBreakThroughCost(cost)
    local intervalTime = self.__breakThroughFinishTime - GetTime()

    if intervalTime <= 0 then
        return 0
    end

    local maxCost = math.ceil(intervalTime / HiddenMeridianConstants.SpeedUpTime)

    local realCost = math.min(maxCost, cost)

    return realCost
end

--师门指点加速破境
function HiddenMeridianSystem:speedUpBreakThroughByTeacherGuidance(callback)
    HttpManagerEx:executeSectGuidance(
        self.__role:getFamilyId(),
        self.__currHiddenMeridianChartId,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__breakThroughFinishTime = self.__breakThroughFinishTime - data.speedUpTime

                self.__version = data.version

                self:__saveRoleData()

                callback(true, data)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 破境完成
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function HiddenMeridianSystem:breakThroughFinish(callback)
    local yuQiBuffAttrs = self:getCurrHiddenMeridianBuffAttrs()

    HttpManagerEx:finishHiddenMeridianBreakThrough(
        self.__currHiddenMeridianChartId,
        yuQiBuffAttrs,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__breakThroughState = false

                self.__breakThroughFinishTime = 0

                self.__yuQiState = true

                self.__yuQiBuffAttrs = yuQiBuffAttrs

                self.__yuQiBuffActiveEffects = self:getCurrHiddenMeridianActiveEffectDatatList()

                self.__yuQiBuffIds = self:getCurrHiddenMeridianBuffIds()

                self.__acupointMap = {}

                local nextLv = self:getHiddenMeridianChartLv() + 1

                self.__currHiddenMeridianChartId = self:getHiddenMeridianChartByLv(nextLv):getId()

                self.__version = data.version

                self:__saveRoleData()

                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 计算加速可以减少的时间
--@author:LvBin
--@time:2025-03-04 17:13:13
--@cost:
--@return
function HiddenMeridianSystem:__calcSpeedUpTime(cost)
    return cost * HiddenMeridianConstants.SpeedUpTime
end

--@desc: 获取正在冲脉的窍关id
--@author:LvBin
--@time:2025-02-27 16:53:54
--@return
function HiddenMeridianSystem:getCurrAcupointActivateId()
    return self.__currAcupointId
end

--@desc: 获取冲脉状态
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function HiddenMeridianSystem:getAcupointActivateState()
    return self.__acupointActivateState
end

--@desc: 获取冲脉完成时间
--@author:LvBin
--@time:2025-02-25 17:33:54
--@return
function HiddenMeridianSystem:getAcupointActivateTime()
    return self.__acupointActivateFinishTime
end

--@desc: 冲脉是否完成
--@author:LvBin
--@time:2025-02-25 16:00:24
--@return
function HiddenMeridianSystem:isFinishAcupointActivate()
    return GetTime() > self.__acupointActivateFinishTime
end

--@desc: 能否终止冲脉
--@author:LvBin
--@time:2025-03-11 15:59:36
--@return
function HiddenMeridianSystem:isStopAcupointActivate()
    if self:isFinishAcupointActivate() then
        return false, "本次冲脉已经完成，无法终止"
    end

    return true
end

--@desc: 冲脉
--@author:LvBin
--@time:2025-02-21 12:35:49
--@acupoint: 窍关id
--@return true or false
function HiddenMeridianSystem:acupointActivate(acupointId, callback)
    HttpManagerEx:startAcupointActivate(
        acupointId,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                local time = self:getAcupoint(acupointId):getTime()

                self.__acupointActivateFinishTime = GetTime() + time

                self.__acupointActivateState = true

                self.__currAcupointId = acupointId

                self.__ygpillCount = data.count

                self.__version = data.version

                self:__saveRoleData()

                callback(true)

                do  --限时历练
                    local LimitedTimeExperience = require("app.models.Action.LimitedTimeExperience")

                    if LimitedTimeExperience:checkTaskIsOpen("ymchongmai") then
                        LimitedTimeExperience:setRole(self.__role)
                        LimitedTimeExperience:finishTaskByTaskType("ymchongmai")
                    end
                end
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 终止冲脉
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function HiddenMeridianSystem:stopAcupointActivate(callback)
    HttpManagerEx:cancelAcupointActivate(
        self.__currAcupointId,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__acupointActivateState = false

                self.__acupointActivateFinishTime = 0

                self.__currAcupointId = nil

                self.__version = data.version

                self:__saveRoleData()

                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 能否加速冲脉
--@author:LvBin
--@time:2025-03-11 16:10:06
--@cost: 加速选择得消耗资源数量
--@return
function HiddenMeridianSystem:isSpeedUpAcupointActivate(cost)
    if self:isFinishAcupointActivate() then
        return false, "本次冲脉已经完成，无法进行加速"
    end

    if cost <= 0 then
        return false, "加速选择消耗的资源数量要大于0"
    end

    return true
end

--@desc: 加速冲脉
--@author:LvBin
--@time:2025-02-25 19:22:28
--@cost: 加速消耗的资源数量
--@callback:
--@return
function HiddenMeridianSystem:speedUpAcupointActivate(cost, callback)
    local realCost = self:__calcSpeedUpAcupointActivateCost(cost)

    HttpManagerEx:speedUpAcupointActivate(
        self.__currAcupointId,
        cost,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__acupointActivateFinishTime = self.__acupointActivateFinishTime - self:__calcSpeedUpTime(data.cost)

                self.__ygpillCount = data.count

                self.__version = data.version

                self:__saveRoleData()

                callback(true, "成功使用" .. data.cost .. "个" .. self:getYgpillName())
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 计算加速冲脉实际消耗的资源数量
--@author:LvBin
--@time:2025-03-11 16:14:59
--@cost: 选择消耗得资源数量
--@return
function HiddenMeridianSystem:__calcSpeedUpAcupointActivateCost(cost)
    local intervalTime = self.__acupointActivateFinishTime - GetTime()

    if intervalTime <= 0 then
        return 0
    end

    local maxCost = math.ceil(intervalTime / HiddenMeridianConstants.SpeedUpTime)

    local realCost = math.min(maxCost, cost)

    return realCost
end

--师门指点加速冲脉
function HiddenMeridianSystem:speedUpAcupointActivateByTeacherGuidance(callback)
    HttpManagerEx:executeSectGuidance(
        self.__role:getFamilyId(),
        self.__currAcupointId,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__acupointActivateFinishTime = self.__acupointActivateFinishTime - data.speedUpTime

                self.__version = data.version

                self:__saveRoleData()

                callback(true, data)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 冲脉完成(窍关激活)
--@author:LvBin
--@time:2025-02-21 12:35:49
--@return true or false
function HiddenMeridianSystem:acupointActivateFinish(callback)
    HttpManagerEx:finishAcupointActivate(
        self.__currAcupointId,
        self.__version,
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                self.__acupointActivateState = false

                self.__acupointActivateFinishTime = 0

                if self.__acupointMap[self.__currAcupointId] == nil then
                    self.__acupointMap[self.__currAcupointId] = {isActivated = false}
                end

                self.__acupointMap[self.__currAcupointId].isActivated = true

                self.__currAcupointId = nil

                if self:acupointAllActivate() == true then
                    self:removeYuQi()
                end

                self.__version = data.version

                self:__saveRoleData()

                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

--@desc: 窍关是否全部完成冲脉激活
--@author:LvBin
--@time:2025-03-03 20:23:43
--@return true or false
function HiddenMeridianSystem:acupointAllActivate()
    local acupointList = self:getHiddenMeridianChart():getAcupointList()

    for i, acupoint in ipairs(acupointList) do
        if acupoint:isActivated() == false then
            return false
        end
    end

    return true
end

--@desc: 解锁玄络buff
--@author:LvBin
--@time:2025-02-21 12:35:49
--@meridianBuffId:玄络buffid
--@return true or false
function HiddenMeridianSystem:unlockBuff(meridianBuffId, callback)
    HttpManagerEx:unlockHiddenMeridianBuff(
        meridianBuffId,
        self.__version,
        self.__role:getCurrencyVersion(),
        function(status, errcode, errmsg, data)
            if status == 200 and errcode == 0 then
                if self.__buffMap[meridianBuffId] == nil then
                    self.__buffMap[meridianBuffId] = {}
                end

                self.__ygpillCount = data.count

                self.__version = data.version

                if data.currencyVersion then
                    self.__role:setCurrencyVersion(data.currencyVersion)
                end

                self:__saveRoleData()

                callback(true)
            else
                callback(false, errmsg)
            end
        end,
        IS_SHOW_WAITING
    )
end

function HiddenMeridianSystem:getDeleteMeridianBuffList(delNodal)
    if table.keyof(HiddenMeridianConstants.DeleteBuffNodal, delNodal) == nil then
        assert(false, "HiddenMeridianSystem:getDeleteMeridianBuffList unknown delNodal" .. tostring(delNodal))
    end

    local remove_lsit = {}

    local buffMap = self.__buffMap

    for m_buffId, _ in pairs(buffMap) do
        local mbuff = self:getHiddenMeridianBuff(m_buffId)
        if mbuff:canDelete(delNodal) then
            table.insert(remove_lsit, m_buffId)
        end
    end

    return remove_lsit
end

--@desc: 删除玄络buff，并解除窍关安装的buff
--@author:Seven
--@time:2025-03-17 17:02:09
--@remove_list: 删除的buff列表
function HiddenMeridianSystem:deleteHMBuff(remove_list)
    if table.getn(remove_list) <= 0 then
        return
    end

    for i, v in ipairs(remove_list) do
        self.__buffMap[v] = nil
    end

    local acupointMap = self.__acupointMap
    for k, v in pairs(acupointMap) do
        if v.buffId then
            v.buffId = nil
        end
    end

    self:__saveRoleData()
end

function HiddenMeridianSystem:deleteHMBuffByNodal(delNodal)
    local remove_list = self:getDeleteMeridianBuffList(delNodal)
    self:deleteHMBuff(remove_list)

    LogSystem:log("玄络条件检测","删除节点 : "..delNodal.. "检测开始")

    if table.getn(remove_list) > 0 then
        for i, v in ipairs(remove_list) do
            LogSystem:log("玄络条件检测","删除玄络 id : "..v)
        end
    else
        LogSystem:log("玄络条件检测","无删除玄络")
    end
end

--@desc: 玄络buff是否能够解锁
--@author:LvBin
--@time:2025-02-24 16:46:53
--@meridianBuffId:
--@return
function HiddenMeridianSystem:canUnlockBuff(meridianBuffId)
    local meridianBuff = self:getHiddenMeridianBuff(meridianBuffId)

    return meridianBuff:canUnlock()
end

--@desc: 解除余炁
--@author:LvBin
--@time:2025-03-01 15:01:52
--@return
function HiddenMeridianSystem:removeYuQi(callback)
    self.__yuQiState = false

    self:__saveRoleData()

    if type(callback) == "function" then
        callback(true, "")
    end
end

--@desc: 获取余炁比例
--@author:LvBin
--@time:2025-02-21 15:18:35
--@return 余炁比例保留4位小数
function HiddenMeridianSystem:getYuQiRatio()
    local acupointList = self:getHiddenMeridianChart():getAcupointList()

    local acupointCount = #acupointList

    local unlockCount = 0

    for i, acupoint in ipairs(acupointList) do
        if acupoint:isActivated() == true then
            unlockCount = unlockCount + 1
        end
    end

    local ratio = 1 - (unlockCount / acupointCount) ^ 2

    ratio = Helper:roundPreciseDecimal(ratio, 4)

    return ratio
end

--@desc: 设置余炁状态
--@author:LvBin
--@time:2025-02-21 15:26:59
--@bool: true or false
function HiddenMeridianSystem:setYuQiState(bool)
    assert(type(bool) == "boolean", "yuQiState must be boolean")

    self.__yuQiState = bool

    self:__saveRoleData()
end

--@desc: 获取余炁状态
--@author:LvBin
--@time:2025-02-21 15:25:43
--@return true or false
function HiddenMeridianSystem:getYuQiState()
    return self.__yuQiState
end

--@desc: 获取已冲脉（激活）的窍关数量
--@author:LvBin
--@time:2025-03-10 16:39:38
--@return
function HiddenMeridianSystem:getAcupointActivatedNum()
    local num = 0

    for acupointId, v in pairs(self.__acupointMap) do
        if v.isActivated == true then
            num = num + 1
        end
    end

    return num
end

--@desc: 获取指定类型玄络安装数量
--@author:LvBin
--@time:2025-03-10 16:39:43
--@buffType: 玄络类型
--@buffLevel: 玄络等级
--@return
function HiddenMeridianSystem:getAttachBuffNumByType(buffType, buffLevel)
    local num = 0
    for acupointId, v in pairs(self.__acupointMap) do
        if v.buffId then
            --@RefType[src.app.models.Meridian.HiddenMeridianBuff.HiddenMeridianBuff#HiddenMeridianBuff]
            local meridianBuff = HiddenMeridianBuff:create(self.__role, v.buffId)

            if meridianBuff:getType() == buffType and meridianBuff:getClass() == buffLevel then
                num = num + 1
            end
        end
    end

    return num
end

return newClass("HiddenMeridianSystem", {}, HiddenMeridianSystem)
0000