local LogSystem = require("app.models.LogSystem.LogSystem")
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightBuff.BuffEffectDamageCalculator.BuffEffectDamagCalculatorFactory")
local oldPrint = print
local function print(...)
    LogSystem:log("增益日志.ActiveBuff:", ...)
end

local class = require("third.class.NewClass")
--@RefType[src.app.FightSystem.FightBuff.Constants#Constants]
local FightBuffConstants = require("app.FightSystem.FightBuff.Constants")
local FightCommons = require("app.FightSystem.FightCommons")
local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ActiveBuff = {}

function ActiveBuff:create(buff, buffNeeded)
    local p = ActiveBuff.new()
    p:__init(buff, buffNeeded)
    return p
end

function ActiveBuff:ctor()
    -- 触发次数
    self.__triggerTimes = 0

    -- 生效的效果
    self.__activeEffects = {}

    -- 外部参数
    self.__params = {}

    -- buff所需信息
    self.__buffNeeded = nil

    --
    self.__buffSystem = nil

    self.__extraAddAttrs = nil
    self.__extraMulAttrs = nil

    -- 承伤量
    self.__sufferDamgeRemain = 0
end

function ActiveBuff:__init(buff, buffNeeded)
    --@RefType[src.app.FightSystem.FightBuff.Buff#Buff]
    self.__buff = buff

    --@RefType[src.app.FightSystem.FightBuff.IBuffNeeded#IBuffNeeded]
    self.__buffNeeded = buffNeeded

    -- 生效的效果
    self.__activeEffects = buff:createActiveEffects(buffNeeded)

    for _, delete in ipairs(self:getDeletes()) do
        local deleteType, deleteParam = unpack(delete)
        deleteParam = self:__getParam(deleteParam)
        if type(deleteParam) == "string" then
            if deleteType == FightBuffConstants.BuffRemoveType.SufferDamge then
                self.__sufferDamgeRemain = BuffEffectDamageCalculatorFactory:create(deleteParam, self.__buffNeeded):getDamage()
                print("承伤量：", self.__sufferDamgeRemain)
            elseif deleteType == FightBuffConstants.BuffRemoveType.TriggerRound then
                self.__triggerTimes = BuffEffectDamageCalculatorFactory:create(deleteParam, self.__buffNeeded):getDamage()
                print("触发次数: ", self.__triggerTimes)
            end
        end
    end
end

function ActiveBuff:getId()
    return self.__buff:getId()
end

function ActiveBuff:getClass()
    return self.__buff:getClass()
end

function ActiveBuff:getEffectClass()
    return self.__buff:getBuffEffectClass()
end

function ActiveBuff:getName()
    return "ActiveBuff:" .. self.__buff:getName()
end

function ActiveBuff:getIcon()
    return self.__buff.buffIcon
end

--[[
    @desc: 尝试刷新移除状态
    author:TangJian
    time:2022-01-05 15:35:17
    @return:
]]
function ActiveBuff:getDeleteConArray()
    return self.__buff:getDeleteConArray()
end

--[[
    @desc: 尝试移除buff
    author:TangJian
    time:2022-01-05 15:35:35
    @return:
]]
function ActiveBuff:getDeletes()
    return self.__buff:getDeletes()
end

function ActiveBuff:initTriggerTimes()
    self.__triggerTimes = 0
end

function ActiveBuff:getTriggerProbability()
    return self:__getParam(self.__buff.triggerProbability)
end

function ActiveBuff:getActiveEffects()
    return self.__activeEffects
end

function ActiveBuff:getStackTimes()
    return self:__getParam(self.__buff:getStackTimes())
end

function ActiveBuff:setBuffSystem(buffSystem)
    self.__buffSystem = buffSystem
end

--[[
    @desc: 添加文本
    author:TangJian
    time:2022-01-05 15:36:05
    @return:
]]
function ActiveBuff:getAddText()
    return self.__buff.addBuffDesc
end

--[[
    @desc: 移除文本
    author:TangJian
    time:2022-01-05 15:36:12
    @return:
]]
function ActiveBuff:getRemoveText()
    return self.__buff.deleteBuffDesc
end

function ActiveBuff:__getParam(paramName)
    if paramName == "dynamicArg1" then
        return tonumber(self.__buffNeeded:getDynamicArg1())
    elseif paramName == "dynamicArg2" then
        return tonumber(self.__buffNeeded:getDynamicArg2())
    elseif paramName == "dynamicArg3" then
        return tonumber(self.__buffNeeded:getDynamicArg3())
    end

    return paramName
end

--[[
    @desc: 判断是否拥有护盾
    author:TangJian
    time:2022-01-05 15:36:40
    @return:
]]
function ActiveBuff:hasShield()
    for i, activeEffect in ipairs(self.__activeEffects) do
        if activeEffect:getType() == FightBuffConstants.EffectType.ShieldHp then
            return true
        end
    end
    return false
end

--[[
    @desc: 获取护盾值
    author:TangJian
    time:2022-01-05 15:36:51
    @return:
]]
function ActiveBuff:getShieldValue()
    local sheldValue = 0

    for i, activeEffect in ipairs(self.__activeEffects) do
        if activeEffect:getType() == FightBuffConstants.EffectType.ShieldHp then
            sheldValue = sheldValue + activeEffect:getShieldValue()
        end
    end

    return sheldValue
end

--[[
    @desc: 消耗护盾值
    author:TangJian
    time:2022-01-05 15:37:01
    --@value: 
    @return:
]]
function ActiveBuff:comsumeShieldValue(value)
    local remainValue = value

    for i, activeEffect in ipairs(self.__activeEffects) do
        if activeEffect:getType() == FightBuffConstants.EffectType.ShieldHp then
            if activeEffect:getShieldValue() >= remainValue then
                activeEffect:comsumeShieldValue(remainValue)
                remainValue = 0
                break
            else
                remainValue = remainValue - activeEffect:comsumeShieldValue(activeEffect:getShieldValue())
            end
        end
    end

    return value - remainValue
end

function ActiveBuff:getShieldAnimIdAndPriority()
    local currShieldAnimId = nil
    local currPriority = 0
    for i, activeEffect in ipairs(self.__activeEffects) do
        if activeEffect:getType() == FightBuffConstants.EffectType.ShieldHp then
            local newShieldAnimId, priority = activeEffect:getShieldAnimIdAndPriority()
            if priority > currPriority then
                currPriority = priority
                currShieldAnimId = newShieldAnimId
            end
        end
    end
    return currShieldAnimId, currPriority
end

function ActiveBuff:getFeetHaloAnimIdAndPriority()
    local currShieldAnimId = nil
    local currPriority = 0
    for i, activeEffect in ipairs(self.__activeEffects) do
        local newShieldAnimId, priority = activeEffect:getRoleFeetHaloAnimIdAndPriority()
        if newShieldAnimId and priority then
            if priority > currPriority then
                currPriority = priority
                currShieldAnimId = newShieldAnimId
            end
        end
    end
    return currShieldAnimId, currPriority
end

-- 获得当前承伤量
function ActiveBuff:getSufferDamage()
    return self.__sufferDamgeRemain
end

--  消耗承伤量
function ActiveBuff:comsumeSufferDamge(value)
    local remainValue = value

    if remainValue >= self.__sufferDamgeRemain then
        remainValue = remainValue - self.__sufferDamgeRemain
        self.__sufferDamgeRemain = 0
    else
        self.__sufferDamgeRemain = self.__sufferDamgeRemain - remainValue
        remainValue = 0
    end
    return value - remainValue
end

--[[
    @desc:尝试触发buff
    author:tangjian
    time:2021-07-27 11:33:02
    --@eventName:
	--@eventParam: 
    @return:
]]
function ActiveBuff:tryTrigger(eventName, eventParam)
    local triggerdActiveEffectArray = {}
    local hasTrigger = false
    for _, activeEffect in ipairs(self.__activeEffects) do
        if activeEffect:tryTrigger(eventName, eventParam) then
            hasTrigger = true
            table.insert(triggerdActiveEffectArray, activeEffect)
        end
    end

    if hasTrigger then
        print("触发buff ", self:getId())
        return true, triggerdActiveEffectArray
    end

    return false
end

--[[
    @desc: 尝试刷新移除状态
    author:TangJian
    time:2022-01-05 15:37:51
    --@eventName:
	--@eventParam: 
    @return:
]]
function ActiveBuff:tryDeleteCon(eventName, eventParam)
    local deleteConArray = self:getDeleteConArray()
    local hasTrigger = false
    for _, trigger in ipairs(deleteConArray) do
        local triggerType, triggerParam = unpack(trigger)
        if
            switch(
                eventName,
                {
                    [FightBuffConstants.BuffTriggerType.Add] = function()
                        if self == eventParam then
                            return triggerType == 1 or triggerType == 2
                        end
                    end,
                    [FightBuffConstants.BuffTriggerType.SomeBodyAttackEnd] = function()
                        return triggerType == FightBuffConstants.BuffTriggerType.SomeBodyAttackEnd
                    end,
                    [FightBuffConstants.BuffTriggerType.UseAutoZhao] = function()
                        if triggerType == FightBuffConstants.BuffTriggerType.UseAutoZhao then
                            return switch(
                                triggerParam,
                                {
                                    [0] = true,
                                    [1] = eventParam == FightCommons.ATTACK_HIT_TYPE.HIT,
                                    [10] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY,
                                    [11] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC,
                                    [20] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE,
                                    [21] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE_SPC,
                                    default = function()
                                        error("找不到被动招式触发类型" .. tostring(triggerParam))
                                    end
                                }
                            )
                        end
                    end,
                    [FightBuffConstants.BuffTriggerType.UseActiveZhao] = function()
                        if triggerType == FightBuffConstants.BuffTriggerType.UseActiveZhao then
                            return switch(
                                triggerParam,
                                {
                                    [0] = true,
                                    [1] = eventParam == FightCommons.ATTACK_HIT_TYPE.HIT,
                                    [10] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY,
                                    [11] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC,
                                    [20] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE,
                                    [21] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE_SPC,
                                    default = function()
                                        error("找不到主动招式触发类型" .. tostring(triggerParam))
                                    end
                                }
                            )
                        end
                    end,
                    [FightBuffConstants.BuffTriggerType.UnderAutoZhao] = function()
                        if triggerType == FightBuffConstants.BuffTriggerType.UnderAutoZhao then
                            -- 0=无特殊条件，使用被动招式组合算1次、
                            -- 1=被动招式组合所有招式判定都是命中算1次、
                            -- 10=被动招式组合任意一次招式判定是普通招架算1次、
                            -- 11=被动招式组合任意一次招式判定是格挡招架算1次、
                            -- 20=被动招式组合任意一次招式判定是轻功闪躲算1次、
                            -- 21=被动招式组合任意一次招式判定是轻功跳离算1次、
                            -- 30=被动招式组合任意一次招式判定是普通招架或者轻功闪躲算1次
                            return switch(
                                triggerParam,
                                {
                                    [0] = true,
                                    [1] = eventParam == FightCommons.ATTACK_HIT_TYPE.HIT,
                                    [10] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY,
                                    [11] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC,
                                    [20] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE,
                                    [21] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE_SPC,
                                    default = function()
                                        error("找不到被动招式触发类型" .. tostring(triggerParam))
                                    end
                                }
                            )
                        end
                    end,
                    [FightBuffConstants.BuffTriggerType.UnderActiveZhao] = function()
                        if triggerType == FightBuffConstants.BuffTriggerType.UnderActiveZhao then
                            return switch(
                                triggerParam,
                                {
                                    [0] = true,
                                    [1] = eventParam == FightCommons.ATTACK_HIT_TYPE.HIT,
                                    [10] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY,
                                    [11] = eventParam == FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC,
                                    [20] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE,
                                    [21] = eventParam == FightCommons.ATTACK_HIT_TYPE.DODGE_SPC,
                                    default = function()
                                        error("找不到主动招式触发类型" .. tostring(triggerParam))
                                    end
                                }
                            )
                        end
                    end,
                    [FightBuffConstants.BuffTriggerType.GetBuffClass] = function()
                        if triggerType == FightBuffConstants.BuffTriggerType.GetBuffClass then
                            return triggerParam == eventParam
                        end
                    end,
                    default = function()
                        error("eventName = " .. tostring(eventName))
                    end
                }
            )
         then
            hasTrigger = true
            break
        end
    end

    if hasTrigger then
        self.__triggerTimes = self.__triggerTimes + 1
        return true
    end

    return false
end

--[[
    @desc:尝试移除
    author:tangjian
    time:2021-07-27 11:30:14
    --@eventName:事件名
    @return:boolean
]]
function ActiveBuff:tryRemove(eventName, eventParam)
    for _, delete in ipairs(self:getDeletes()) do
        local deleteType, deleteParam = unpack(delete)
        deleteParam = self:__getParam(deleteParam)

        if
            switch(
                deleteType,
                {
                    -- 永不移出
                    [FightBuffConstants.BuffRemoveType.Never] = function()
                    end,
                    -- 触发移除
                    [FightBuffConstants.BuffRemoveType.TriggerRound] = function()
                        print(self:getId(), "触发移除条件判断", "当前触发次数", self.__triggerTimes, "移除触发次数", deleteParam)
                        if self.__triggerTimes >= deleteParam then
                            return true
                        end
                    end,
                    -- 退出战斗移除
                    [FightBuffConstants.BuffRemoveType.LeaveBattle] = function()
                        return true
                    end,
                    [FightBuffConstants.BuffRemoveType.NoWeaponType] = function()
                        error("暂未支持的移除类型" .. tostring(deleteType))
                    end,
                    [FightBuffConstants.BuffRemoveType.ShieldZero] = function()
                        return self:getShieldValue() <= 0
                    end,
                    [FightBuffConstants.BuffRemoveType.SufferDamge] = function()
                        return self.__sufferDamgeRemain <= 0
                    end,
                    default = function()
                        error("ActiveBuff:tryRemove unecpect deleteType:" .. tostring(deleteType))
                    end
                }
            )
         then
            return true
        end
    end

    return false
end

--[[
    @desc:获取属性加法加成
    author:tangjian
    time:2021-07-27 11:31:33
    @return:
]]
function ActiveBuff:getExtraAddAttrs()
    if self.__extraAddAttrs == nil then
        local addAttrs = {}

        for i, effect in ipairs(self.__activeEffects) do
            for attrName, addValue in pairs(effect:getAddAttrs()) do
                if addAttrs[attrName] == nil then
                    addAttrs[attrName] = 0
                end
                addAttrs[attrName] = addAttrs[attrName] + addValue
            end
        end

        self.__extraAddAttrs = addAttrs
    end
    return self.__extraAddAttrs
end

--[[
    @desc:获取属性乘法加成
    author:{author}
    time:2021-07-27 11:31:48
    @return:
]]
function ActiveBuff:getExtraMulAttrs()
    if self.__extraMulAttrs == nil then
        local mulAttrs = {}

        for i, effect in ipairs(self.__activeEffects) do
            for attrName, mulValue in pairs(effect:getMulAttrs()) do
                if mulAttrs[attrName] == nil then
                    mulAttrs[attrName] = 0
                end
                mulAttrs[attrName] = mulAttrs[attrName] + mulValue
            end
        end

        self.__extraMulAttrs = mulAttrs
    end
    return self.__extraMulAttrs
end

-- 禁用被动招式
function ActiveBuff:isBanAutoZhao()
    for i, effect in ipairs(self.__activeEffects) do
        if effect:isBanAutoZhao() then
            return true
        end
    end

    return false
end

-- 禁用主动招式
function ActiveBuff:isBanActiveZhao()
    for i, effect in ipairs(self.__activeEffects) do
        if effect:isBanActiveZhao() then
            return true
        end
    end

    return false
end

-- 禁用轻功闪躲
function ActiveBuff:isBanQingGongDodge()
    for i, effect in ipairs(self.__activeEffects) do
        if effect:isBanQingGongDodge() then
            return true
        end
    end

    return false
end

-- 禁用普通招架
function ActiveBuff:isBanNormalParry()
    for i, effect in ipairs(self.__activeEffects) do
        if effect:isBanNormalParry() then
            return true
        end
    end

    return false
end

function ActiveBuff:isRandomBaseAutoZhao()
    return self.__buff:isRandomBaseAutoZhao()
end

function ActiveBuff:removeBuff(buffClass, buffId)
    local removeBuffLevelCount = 0
    for i, effect in ipairs(self.__activeEffects) do
        if effect:getEffectType() == FightBuffConstants.EffectType.RemoveBuffClass then
            if effect:needRemoveBuff(buffClass, buffId) then
                removeBuffLevelCount = removeBuffLevelCount + effect:getLevelCount()
                effect:finish()
            end
        end
    end
    print("移除buff：buffClass, buffId, removeBuffLevelCount", buffClass, buffId, removeBuffLevelCount)
    return removeBuffLevelCount
end

-- 获取buff添加时动画效果数据
-- {eventName, animName}
function ActiveBuff:getAddBuffEffect()
    return self.__buff:getAddBuffEffect()
end

--[[
    @desc: 获取刷新节点
    author:TangJian
    time:2022-12-14 15:36:50
    @return:
]]
function ActiveBuff:getEffectUpdataNode()
    return self.__buff:getEffectUpdataNode()
end

--[[
    @desc: 刷新所有效果
    author:TangJian
    time:2022-12-14 15:46:17
    @return:
]]
function ActiveBuff:refreshAllEffect()
    print("刷新Buff：", self:getId())
    for i, activeEffect in ipairs(self.__activeEffects) do
        print("刷新效果:", activeEffect:getId(), activeEffect:getEffectId())
        activeEffect:refresh()
    end
end

return class("ActiveBuff", {}, ActiveBuff)
0