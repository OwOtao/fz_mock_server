--[[
    author:Codex
    time:2026-03-17
    desc: 新版战斗气血减伤/穿透纯算法计算器
]]
local newClass = require("third.class.NewClass")

local BattleQiDamageReducePenetrationConf = require("app.FightSystem.Configuration.BattleQiDamageReducePenetrationConf")
local FightUtil = require("app.FightSystem.FightUtil.FightUtil")
local FightCommons = require("app.FightSystem.FightCommons")

-- Buff 140 / 运行时穿透加成统一写入这套键，算法层只读这一套语义。
local BUFF_ADD_ATTR_PREFIX = FightCommons.HURT_REDUCE_ATTR_PREFIX

local CLASS_TYPE = {
    PENETRATION = 0,-- 0=穿透值。
    REDUCE_RATE = 1, --1=免伤率
    REDUCE_VALUE = 2 --2=免伤值
}

-- 固定遍历顺序，避免热路径中重复创建匿名表
local CLASS_TYPE_LIST = {CLASS_TYPE.PENETRATION, CLASS_TYPE.REDUCE_RATE, CLASS_TYPE.REDUCE_VALUE}

-- 模块级静态缓存：配置数据完全静态，以 damageType 为键，战斗内所有实例共享
local _staticConfigCache = {}

local function __buildConfigCacheForDamageType(damageType)
    if _staticConfigCache[damageType] then
        return _staticConfigCache[damageType]
    end

    local cache = {
        configDataMap = {},
        maxStageByClass = {},
        maxLvByClassStage = {},
        maxStage = 0
    }

    for _, classType in ipairs(CLASS_TYPE_LIST) do
        local maxStage = BattleQiDamageReducePenetrationConf:getMaxStageByDamageTypeAndClass(damageType, classType)
        cache.maxStageByClass[classType] = maxStage
        cache.maxLvByClassStage[classType] = {}

        if maxStage > cache.maxStage then
            cache.maxStage = maxStage
        end

        cache.configDataMap[classType] = {}
        for stage = 1, maxStage do
            local stageMap = {}
            cache.configDataMap[classType][stage] = stageMap
            local maxLv = BattleQiDamageReducePenetrationConf:getMaxLvByDamageTypeAndClassAndStage(damageType, classType, stage)
            cache.maxLvByClassStage[classType][stage] = maxLv

            for lv = 1, maxLv do
                stageMap[lv] =
                    BattleQiDamageReducePenetrationConf:getDataByDamageTypeAndClassAndStageAndLv(
                    damageType,
                    classType,
                    stage,
                    lv
                )
            end
        end
    end

    _staticConfigCache[damageType] = cache
    return cache
end

local function __toNumber(value, defaultValue)
    local num = tonumber(value)

    if num == nil then
        return defaultValue
    end

    return num
end

local function __getDamageTypeText(damageType)
    if tonumber(damageType) == 1 then
        return "被动"
    elseif tonumber(damageType) == 2 then
        return "主动"
    end

    return "未知"
end

local QiDamageReducePenetrationCalculator = {}

--@desc: 创建气血减伤/穿透计算器
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:create()
    return QiDamageReducePenetrationCalculator.new():__init()
end

--@desc: 初始化默认入参
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:__init()
    self.__originQiDamage = 0
    self.__allocPercent = 0
    self.__isCalculated = false
    return self
end

--@desc: 设置伤害类型
--@author:Codex
--@time:2026-03-17
--@damageType: 1=被动，2=主动
function QiDamageReducePenetrationCalculator:setDamageType(damageType)
    self.__damageType = __toNumber(damageType, nil)
    self.__isCalculated = false
end

--@desc: 设置当前受击帧原始气血伤害
--@author:Codex
--@time:2026-03-17
--@value: 原始气血伤害
function QiDamageReducePenetrationCalculator:setOriginQiDamage(value)
    self.__originQiDamage = __toNumber(value, 0)
    self.__isCalculated = false
end

--@desc: 设置当前帧在整套招式中的伤害分摊权重
--@author:Codex
--@time:2026-03-17
--@value: 分摊比例
function QiDamageReducePenetrationCalculator:setAllocPercent(value)
    self.__allocPercent = __toNumber(value, 0)
    self.__isCalculated = false
end

--@desc: 设置受击目标，用于读取免伤率/免伤值 Buff 加成
--@author:Codex
--@time:2026-03-17
--@target: 受击角色对象
function QiDamageReducePenetrationCalculator:setTarget(target)
    self.__target = target
    self.__isCalculated = false
end

--@desc: 设置攻击方角色，用于读取穿透值 Buff 加成
--@author:Seven
--@time:2026-03-20
--@attacker: 攻击角色对象
function QiDamageReducePenetrationCalculator:setAttacker(attacker)
    self.__attacker = attacker
    self.__isCalculated = false
end

--@desc: 获取指定阶段的实际气血伤害
--@author:Codex
--@time:2026-03-17
--@stage: 阶段
function QiDamageReducePenetrationCalculator:getStageActualQiDamage(stage)
    local result = self:getResult()
    local value = result.stageActualQiDamageMap[stage]

    if value == nil then
        error("QiDamageReducePenetrationCalculator:getStageActualQiDamage 未找到阶段 " .. tostring(stage) .. " 的结果")
    end

    return value
end

--@desc: 获取最后阶段的实际气血伤害
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:getFinalActualQiDamage()
    return self:getResult().finalActualQiDamage
end

--@desc: 获取实际气血伤害(免伤初期) = ceil(单次气血伤害(初始)) + 攻击方穿透值[1][1]
--@author:Seven
--@time:2026-03-20
function QiDamageReducePenetrationCalculator:getPreMitigationQiDamage()
    return self:getResult().preMitigationQiDamage
end

--@desc: 获取减伤明细列表
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:getReduceDetailList()
    return self:getResult().reduceDetailList
end

--@desc: 打印减伤计算日志，便于运行时排查阶段结算问题
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:printString()
    local result = self:getResult()

    FightUtil:printFormatLog(
        "气血减伤计算：伤害类型=%s(%s) 原始气血伤害=%s 分摊比例=%s 实际气血伤害(免伤初期)=%s 最终实际气血伤害=%s 各阶段实际气血伤害=%s",
        __getDamageTypeText(self.__damageType),
        tostring(self.__damageType),
        tostring(self.__originQiDamage),
        tostring(self.__allocPercent),
        tostring(result.preMitigationQiDamage),
        tostring(result.finalActualQiDamage),
        table.tostring(result.stageActualQiDamageMap)
    )

    for stage = 1, self.__maxStage do
        local stageResult = result.stageResultMap[stage]

        if stageResult ~= nil then
            FightUtil:printFormatLog(
                "气血减伤计算：第%s阶段 输入伤害=%s 当前穿透值=%s 各级免伤率=%s 各级免伤率实际生效值=%s 各级免伤值实际生效值=%s 穿透回加前剩余伤害=%s 本阶段实际气血伤害=%s",
                tostring(stageResult.stage),
                tostring(stageResult.inputDamage),
                tostring(stageResult.penetrationValue),
                table.tostring(stageResult.rateValueMap),
                table.tostring(stageResult.rateEffectMap),
                table.tostring(stageResult.valueEffectMap),
                tostring(stageResult.finalDamageBeforePenetration),
                tostring(stageResult.actualQiDamage)
            )
        end
    end

    FightUtil:printFormatLog("气血减伤计算：减伤明细列表=%s", table.tostring(result.reduceDetailList))
end

--@desc: 获取完整计算结果，首次调用时会触发实际结算
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:getResult()
    if self.__isCalculated == false then
        self:__calculate()
    end

    return self.__result
end

--@desc: 校验计算前必要入参
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:__checkRequiredParams()
    if self.__damageType == nil then
        error("QiDamageReducePenetrationCalculator:__checkRequiredParams damageType 未设置")
    end
end

--@desc: 执行完整阶段循环并缓存结果
--@author:Codex
--@time:2026-03-17
function QiDamageReducePenetrationCalculator:__calculate()
    self:__checkRequiredParams()
    self:__initConfigCache()

    local result = {
        stageActualQiDamageMap = {},
        reduceDetailList = {},
        stageResultMap = {}
    }

    local prevStageResult = nil

    for stage = 1, self.__maxStage do
        local stageResult = self:__calculateOneStage(stage, prevStageResult, result.reduceDetailList)
        result.stageActualQiDamageMap[stage] = stageResult.actualQiDamage
        result.stageResultMap[stage] = stageResult
        prevStageResult = stageResult

        if stage == 1 then
            -- 实际气血伤害(免伤初期) = ceil(单次气血伤害(初始)) + 攻击方穿透值[1][1]（未经减免且受穿透加成）
            result.preMitigationQiDamage = math.ceil(stageResult.inputDamage + stageResult.penetrationValue)
        end
    end

    result.finalActualQiDamage = result.stageActualQiDamageMap[self.__maxStage]

    self.__result = result
    self.__isCalculated = true
end

-- 从静态缓存读取配置索引（首次触发时按 damageType 构建一次）
function QiDamageReducePenetrationCalculator:__initConfigCache()
    local cache = __buildConfigCacheForDamageType(self.__damageType)
    self.__configDataMap = cache.configDataMap
    self.__maxStageByClass = cache.maxStageByClass
    self.__maxLvByClassStage = cache.maxLvByClassStage
    self.__maxStage = cache.maxStage
end

--@desc: 一个阶段的计算逻辑，包含穿透值继承与当前阶段免伤率/免伤值的结算
--@author:Seven
--@time:2026-03-18 11:37:09
--@stage: 阶段
--@prevStageResult: 上一阶段结果
--@reduceDetailList: 减伤明细列表
--@return: 阶段计算结果
function QiDamageReducePenetrationCalculator:__calculateOneStage(stage, prevStageResult, reduceDetailList)
    local stageInputDamage = self:__getStageInputDamage(prevStageResult)
    local penetrationValue = self:__getStageInitialPenetration(stage, prevStageResult)

    if prevStageResult ~= nil then
        penetrationValue = self:__applyPrevStageReduceRateToPenetration(penetrationValue, prevStageResult)
        penetrationValue = self:__applyPrevStageReduceValueToPenetration(penetrationValue, prevStageResult)
    end

    -- 每阶段先结算免伤率，再结算免伤值，最后才把当前剩余穿透加回伤害。
    local rateOutputDamage = stageInputDamage
    local reduceRateMaxLv = self:__getMaxLv(CLASS_TYPE.REDUCE_RATE, stage)
    local rateValueMap = {}
    local rateEffectMap = {}
    for lv = 1, reduceRateMaxLv do
        local data = self:__getConfigData(CLASS_TYPE.REDUCE_RATE, stage, lv)
        local reduceRate = math.min(self:__getConfigAndBuffValue(CLASS_TYPE.REDUCE_RATE, stage, lv), 1)
        local effectValue = math.ceil(rateOutputDamage * reduceRate)
        rateOutputDamage = rateOutputDamage - effectValue

        rateValueMap[lv] = reduceRate
        rateEffectMap[lv] = effectValue

        self:__appendReduceDetail(reduceDetailList, data, effectValue)
    end

    local valueOutputDamage = rateOutputDamage
    local reduceValueMaxLv = self:__getMaxLv(CLASS_TYPE.REDUCE_VALUE, stage)
    local valueEffectMap = {}
    for lv = 1, reduceValueMaxLv do
        local data = self:__getConfigData(CLASS_TYPE.REDUCE_VALUE, stage, lv)
        local projectedValue = math.ceil(self:__getConfigAndBuffValue(CLASS_TYPE.REDUCE_VALUE, stage, lv) * self.__allocPercent)
        local actualValue = math.min(valueOutputDamage, projectedValue)
        valueOutputDamage = valueOutputDamage - actualValue

        valueEffectMap[lv] = actualValue

        self:__appendReduceDetail(reduceDetailList, data, actualValue)
    end

    local stageResult = {
        stage = stage,
        inputDamage = stageInputDamage,
        penetrationValue = penetrationValue,
        rateValueMap = rateValueMap,
        rateEffectMap = rateEffectMap,
        valueEffectMap = valueEffectMap,
        rateCount = reduceRateMaxLv,
        valueCount = reduceValueMaxLv
    }

    stageResult.finalDamageBeforePenetration = valueOutputDamage
    stageResult.actualQiDamage = math.ceil(valueOutputDamage + penetrationValue)

    return stageResult
end

--@desc: 获取当前阶段输入伤害
--@author:Codex
--@time:2026-03-17
--@prevStageResult: 上一阶段结果
function QiDamageReducePenetrationCalculator:__getStageInputDamage(prevStageResult)
    if prevStageResult == nil then
        return math.ceil(self.__originQiDamage)
    end

    return prevStageResult.finalDamageBeforePenetration
end

--@desc: 获取当前阶段初始穿透值
--@author:Codex
--@time:2026-03-17
--@stage: 当前阶段
--@prevStageResult: 上一阶段结果
function QiDamageReducePenetrationCalculator:__getStageInitialPenetration(stage, prevStageResult)
    if stage == 1 then
        local value = self:__getConfigAndBuffValue(CLASS_TYPE.PENETRATION, stage, 1)
        return math.ceil(value * self.__allocPercent)
    end

    return prevStageResult.penetrationValue
end

--@desc: 用上一阶段免伤率继续削减继承穿透
--@author:Codex
--@time:2026-03-17
--@penetrationValue: 当前穿透值
--@prevStageResult: 上一阶段结果
function QiDamageReducePenetrationCalculator:__applyPrevStageReduceRateToPenetration(penetrationValue, prevStageResult)
    local result = penetrationValue

    -- 继承穿透仍要继续承受上一阶段已经生效的免伤率。
    for lv = 1, prevStageResult.rateCount do
        local reduceRate = prevStageResult.rateValueMap[lv]
        if reduceRate ~= nil then
            result = math.ceil(result * (1 - reduceRate))
        end
    end

    return result
end

--@desc: 用上一阶段免伤值继续削减继承穿透
--@author:Codex
--@time:2026-03-17
--@penetrationValue: 当前穿透值
--@prevStageResult: 上一阶段结果
function QiDamageReducePenetrationCalculator:__applyPrevStageReduceValueToPenetration(penetrationValue, prevStageResult)
    local result = penetrationValue

    -- 继承穿透同样会被上一阶段已生效的免伤值继续抵扣。
    for lv = 1, prevStageResult.valueCount do
        local reduceValue = prevStageResult.valueEffectMap[lv]
        if reduceValue ~= nil then
            result = math.max(result - reduceValue, 0)
        end
    end

    return result
end

--@desc: 追加一条实际生效的减伤明细
--@author:Codex
--@time:2026-03-17
--@reduceDetailList: 明细列表
--@data: 配置数据
--@value: 实际生效值
function QiDamageReducePenetrationCalculator:__appendReduceDetail(reduceDetailList, data, value)
    if data == nil or value == 0 then
        return
    end

    -- 明细只记录本帧真实生效值，供 UI / 文本汇总直接消费。
    table.insert(
        reduceDetailList,
        {
            id = data.id,
            damageType = data.damageType,
            class = data.class,
            stage = data.stage,
            lv = data.lv,
            value = value,
            tipText = data.attrTag
        }
    )
end

--@desc: 读取配置默认值与 Buff 修正后的最终值
--@author:Codex
--@time:2026-03-17
--@classType: 影响分类
--@stage: 阶段
--@lv: 等级
function QiDamageReducePenetrationCalculator:__getConfigAndBuffValue(classType, stage, lv)
    local data = self:__getConfigData(classType, stage, lv)
    local configValue = 0

    if data ~= nil then
        configValue = __toNumber(data.attrDefault, 0)
    end

    return configValue + self:__getBuffAddValue(data)
end

--@desc: 读取角色在指定配置维度上的 Buff 加成，通过配置 id 匹配 BuffEffect140 写入的键
--穿透值加成来自攻击方（attacker），免伤率/免伤值加成来自受击方（target）
--@author:Seven
--@time:2026-03-18
--@data: 角色免伤穿透配置数据
function QiDamageReducePenetrationCalculator:__getBuffAddValue(data)
    if data == nil then
        return 0
    end

    -- 穿透值加成读攻击方，免伤率/免伤值加成读受击方
    local isPenetration = data.class == CLASS_TYPE.PENETRATION
    local source = isPenetration and self.__attacker or self.__target

    if source == nil then
        local sourceLabel = isPenetration and "attacker" or "target"
        FightUtil:printFormatLog("QiDamageReducePenetrationCalculator: %s 未设置，Buff 加成将被忽略，configId=%s\n%s", sourceLabel, tostring(data.id), debug.traceback())
        return 0
    end

    if type(source.getBuffAddAttr) ~= "function" then
        error("QiDamageReducePenetrationCalculator:__getBuffAddValue source 缺少 getBuffAddAttr 方法")
    end

    -- 统一键格式：HRAP|{configId}，与 BuffEffect140 写入的键一致
    local key = BUFF_ADD_ATTR_PREFIX .. tostring(data.id)
    return __toNumber(source:getBuffAddAttr(key), 0)
end

--@desc: 获取指定维度下的配置数据
--@author:Codex
--@time:2026-03-17
--@classType: 影响分类
--@stage: 阶段
--@lv: 等级
function QiDamageReducePenetrationCalculator:__getConfigData(classType, stage, lv)
    local classData = self.__configDataMap[classType]
    if classData == nil then
        return nil
    end

    local stageData = classData[stage]
    if stageData == nil then
        return nil
    end

    return stageData[lv]
end

--@desc: 获取指定阶段的最大等级
--@author:Codex
--@time:2026-03-17
--@classType: 影响分类
--@stage: 阶段
function QiDamageReducePenetrationCalculator:__getMaxLv(classType, stage)
    local classData = self.__maxLvByClassStage[classType]
    if classData == nil then
        return 0
    end

    return classData[stage] or 0
end

return newClass("QiDamageReducePenetrationCalculator", {}, QiDamageReducePenetrationCalculator)
0000000000