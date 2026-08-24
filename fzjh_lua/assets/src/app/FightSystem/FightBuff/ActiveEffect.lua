local LogSystem = require("app.models.LogSystem.LogSystem")
local BuffSystemUtil = require("app.FightSystem.FightBuff.BuffSystemUtil")
local oldPrint = print
local function print(...)
    LogSystem:logWithTab("增益日志.ActiveEffect:", ...)
end

local inherit = require("third.inherit.inherit")
local class = require("third.class.NewClass")
local Constants = require("app.FightSystem.FightBuff.Constants")
local AttrsEffect = require("app.FightSystem.FightBuff.AttrsEffect")
local Desc = require("app.FightSystem.FightBuff.Desc")
local FightCommons = require("app.FightSystem.FightCommons")
local FightBuffConstants = require("app.FightSystem.FightBuff.Constants")
local BuffEffectAppearenceConf = require("app.FightSystem.Configuration.BuffConf")
local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")
local IEffect = require("app.FightSystem.FightBuff.Effect.IEffect")

local ActiveEffect = {}

function ActiveEffect:create(effect, buffNeeded)
    local p = ActiveEffect.new()
    p:__init(effect, buffNeeded)
    return p
end

function ActiveEffect:ctor()
    -- 是否已经初次触发
    self.__firstTriggered = false
    self.__triggerTimes = 0
    self.__triggerGapActive = 0

    self.__addAttrs = {}
    self.__mulAttrs = {}

    -- 需要驱散的buffclass列表
    self.__removeBuffClass = nil

    -- 免疫所有主动技能buff
    self.__immuneActiveBuff = false

    -- 免疫主动招式添加的指定buffclass
    self.__immuneActiveBuffClassMap = nil
    -- 免疫主动招式添加的指定buffId
    self.__immuneActiveBuffIdMap = nil

    -- 被动招式伤害减免
    self.__autoZhaoReductionOfInjury = nil

    -- 主动招式直接伤害比例减免
    self.__activeZhaoReductionOfInjury = nil

    -- 被动招式伤害减免
    self.__activeZhaoReductionOfInjurySub = nil

    -- 体力消耗
    self.__addTiliCost = 0
    self.__mulTiliCost = 0

    -- 内力小号
    self.__addNeiliCost = 0
    self.__mulNeiliCost = 0
end

function ActiveEffect:__init(effect, buffNeeded)
    self.__effect = effect
    self.__buffNeeded = buffNeeded

    local addAttrs = {}
    local mulAttrs = {}

    print("self:getEffectType()=", self:getEffectType())
    switch(
        self:getEffectType(),
        {
            [Constants.EffectType.AddCurrAttr] = function()
                addAttrs[self:getEffectTypeParam()] = self:getDamage()
                self.__addAttrName = self:getEffectTypeParam()
                self.__addAttrValue = self:getDamage()
            end,
            [Constants.EffectType.AddAttr] = function()
                addAttrs[self:getEffectTypeParam()] = self:getDamage()
                self.__addAttrName = self:getEffectTypeParam()
                self.__addAttrValue = self:getDamage()
            end,
            [Constants.EffectType.FixedMulCurrAttr] = function()
                mulAttrs[self:getEffectTypeParam()] = self:getDamage()
                self.__mulAttrName = self:getEffectTypeParam()
                self.__mulAttrValue = self:getDamage()
            end,
            [Constants.EffectType.FixedMulAttr] = function()
                mulAttrs[self:getEffectTypeParam()] = self:getDamage()
                self.__mulAttrName = self:getEffectTypeParam()
                self.__mulAttrValue = self:getDamage()
            end,
            [Constants.EffectType.RemoveBuffClass] = function()
                self.__removeBuffClass = self:getArgsParam()
            end,
            [Constants.EffectType.ImmuneActiveBuffClass] = function()
                if self:getEffectTypeParam() == "BuffAll" then
                    self.__immuneActiveBuff = true
                elseif self:getEffectTypeParam() == "BuffID" then
                    self.__immuneActiveBuffIdMap = self:getArgsParams()
                elseif self:getEffectTypeParam() == "BuffClass" then
                    self.__immuneActiveBuffClassMap = self:getArgsParams()
                end
            end,
            [Constants.EffectType.AutoZhaoReductionOfInjurySub] = function()
                self.__autoZhaoReductionOfInjurySub = self:getDamage()
            end,
            [Constants.EffectType.AutoZhaoReductionOfInjury] = function()
                self.__autoZhaoReductionOfInjury = self:getDamage()
            end,
            [Constants.EffectType.ActiveZhaoReductionOfInjurySub] = function()
                self.__activeZhaoReductionOfInjurySub = self:getDamage()
            end,
            [Constants.EffectType.ActiveZhaoReductionOfInjury] = function()
                self.__activeZhaoReductionOfInjury = self:getDamage()
            end,
            [Constants.EffectType.SelfAutoZhaoEffectCurrAttr] = function()
                self.__selfAutoZhaoEffectCurrAttrDamageRate = self:getDamage()
            end,
            [Constants.EffectType.SelfActiveZhaoEffectCurrAttr] = function()
                self.__selfActiveZhaoEffectCurrAttrDamageRate = self:getDamage()
            end,
            [Constants.EffectType.TargetAutoZhaoEffectCurrAttr] = function()
                self.__targetAutoZhaoEffectCurrAttrDamageRate = self:getDamage()
            end,
            [Constants.EffectType.TargetActiveZhaoEffectCurrAttr] = function()
                self.__targetActiveZhaoEffectCurrAttrDamageRate = self:getDamage()
            end,
            [Constants.EffectType.AddTiliCost] = function()
                self.__addTiliCost = self:getDamage()
            end,
            [Constants.EffectType.MulTiliCost] = function()
                self.__mulTiliCost = self:getDamage()
            end,
            [Constants.EffectType.AddNeiliCost] = function()
                self.__addNeiliCost = self:getDamage()
            end,
            [Constants.EffectType.MulNeiliCost] = function()
                self.__mulNeiliCost = self:getDamage()
            end,
            default = function()
                print("error!! 没有该类型")
            end
        }
    )

    self.__addAttrs = addAttrs
    self.__mulAttrs = mulAttrs
end

--[[
    @desc: 重新初始化效果
    author:TangJian
    time:2022-12-08 16:58:13
    --@effect:
	--@buffNeeded: 
    @return:
]]
function ActiveEffect:refresh()
    self.__addAttrs = {}
    self.__mulAttrs = {}

    -- 需要驱散的buffclass列表
    self.__removeBuffClass = nil

    -- 免疫所有主动技能buff
    self.__immuneActiveBuff = false

    -- 免疫主动招式添加的指定buffclass
    self.__immuneActiveBuffClassMap = nil
    -- 免疫主动招式添加的指定buffId
    self.__immuneActiveBuffIdMap = nil
    -- 被动招式伤害减免
    self.__autoZhaoReductionOfInjury = nil

    -- 主动招式直接伤害比例减免
    self.__activeZhaoReductionOfInjury = nil

    -- 被动招式伤害减免
    self.__activeZhaoReductionOfInjurySub = nil

    -- 体力消耗
    self.__addTiliCost = 0
    self.__mulTiliCost = 0

    -- 内力小号
    self.__addNeiliCost = 0
    self.__mulNeiliCost = 0
    self:__init(self.__effect, self.__buffNeeded)
end

local getDamageSwitchMap = {
    [Constants.EffectType.SelfAutoZhaoEffectCurrAttr] = function(self)
        return self.__effect:getDamage(self:getArgsParam(2), self.__buffNeeded)
    end,
    [Constants.EffectType.SelfActiveZhaoEffectCurrAttr] = function(self)
        return self.__effect:getDamage(self:getArgsParam(2), self.__buffNeeded)
    end,
    [Constants.EffectType.TargetAutoZhaoEffectCurrAttr] = function(self)
        return self.__effect:getDamage(self:getArgsParam(2), self.__buffNeeded)
    end,
    [Constants.EffectType.TargetActiveZhaoEffectCurrAttr] = function(self)
        return self.__effect:getDamage(self:getArgsParam(2), self.__buffNeeded)
    end,
    default = function(self)
        return self.__effect:getDamage(self:getArgsParam(), self.__buffNeeded)
    end
}

function ActiveEffect:getDamage()
    return switch(self:getEffectType(), getDamageSwitchMap, self)
end

function ActiveEffect:getId()
    return self.__effect:getId()
end

function ActiveEffect:getEffectId()
    return self.__effect:getEffectId()
end

function ActiveEffect:getType()
    return self.__effect:getEffectType()
end

--[[
    @desc: 获取效果堆叠类型
    author:TangJian
    time:2021-12-21 20:40:01
    @return:
]]
function ActiveEffect:getStackType()
    return self.__effect:getStackType()
end

function ActiveEffect:getEffectType()
    return self.__effect:getEffectType()
end

function ActiveEffect:getEffectTypeParam(index)
    if index == nil then
        index = 1
    end
    return self.__effect:getEffectTypeParam()[index]
end

function ActiveEffect:getArgsParam(index)
    if index == nil then
        index = 1
    end
    return self.__effect:getArgsParam()[index]
end

function ActiveEffect:getArgsParams()
    local finnalArgsParams = {}
    for _, param in ipairs(self.__effect:getArgsParam()) do
        table.insert(finnalArgsParams, self.__buffNeeded:getDynamicArg(param))
    end
    return finnalArgsParams
end

function ActiveEffect:getAddAttr()
    BuffSystemUtil:log("ActiveEffect:getAddAttr()", self.__addAttrName, self.__addAttrValue)
    return self.__addAttrName, self.__addAttrValue
end

function ActiveEffect:getMulAttr()
    return self.__mulAttrName, self.__mulAttrValue
end

-- 获取加属性表
function ActiveEffect:getAddAttrs()
    print("效果加属性参数:", self.__addAttrs)
    return inherit({}, self.__addAttrs)
end

-- 获取乘属性表
function ActiveEffect:getMulAttrs()
    print("效果乘属性参数:", self.__mulAttrs)
    return inherit({}, self.__mulAttrs)
end

function ActiveEffect:isBanAutoZhao()
    return self.__effect:isBanAutoZhao()
end

function ActiveEffect:isBanActiveZhao(activeZhaoType)
    if self.__effect:isBanActiveZhao() then
        if self:getEffectTypeParam() == nil then
            return true
        elseif self:getEffectTypeParam() == "0" then
            return true, self.__effect:getActiveEffectUseZhaoTips()
        else
            return tonumber(self:getEffectTypeParam()) == activeZhaoType, self.__effect:getActiveEffectUseZhaoTips()
        end
    end
    return false
end

function ActiveEffect:isBanQingGongDodge()
    return self.__effect:isBanQingGongDodge()
end

function ActiveEffect:isBanNormalParry()
    return self.__effect:isBanNormalParry()
end

--[[
    @desc: 获取自动招式伤害减免率
    author:TangJian
    time:2021-12-02 20:01:25
    @return: 
]]
function ActiveEffect:tryGetAutoZhaoReductionOfInjury()
    if self.__autoZhaoReductionOfInjury ~= nil then
        return true, self.__autoZhaoReductionOfInjury
    end
    return false
end

--[[
    @desc: 获取主动招式伤害减免率
    author:TangJian
    time:2021-12-02 20:14:45
    @return: 
]]
function ActiveEffect:tryGetActiveZhaoReductionOfInjury()
    if self.__activeZhaoReductionOfInjury ~= nil then
        return true, self.__activeZhaoReductionOfInjury
    end
    return false
end

--[[
    @desc: 获取被动招式伤害减免值
    author:TangJian
    time:2021-12-02 20:17:06
    @return:
]]
function ActiveEffect:tryGetAutoZhaoReductionOfInjurySub()
    if self.__autoZhaoReductionOfInjurySub ~= nil then
        return true, self.__autoZhaoReductionOfInjurySub
    end
    return false
end

--[[
    @desc: 获取主动招式伤害减免值
    author:TangJian
    time:2021-12-02 20:18:12
    @return:
]]
function ActiveEffect:tryGetActiveZhaoReductionOfInjurySub()
    if self.__activeZhaoReductionOfInjurySub ~= nil then
        return true, self.__activeZhaoReductionOfInjurySub
    end
    return false
end

--[[
    @desc: 获取角色状态
    author:TangJian
    time:2021-12-02 20:19:00
    @return:
]]
function ActiveEffect:getRoleState()
    return self.__effect:getRoleState()
end

function ActiveEffect:getRoleHurtState()
    return self.__effect:getRoleHurtState()
end

function ActiveEffect:getRoleHeadText()
    return self.__effect:getRoleHeadText()
end

--[[
    @desc:判断是否免疫buff
    author:唐健
    time:2021-07-08 17:42:23
    --@buff: 
    @return:
]]

function ActiveEffect:isImmuneBuff(buff)
    print("ActiveEffect:isImmuneBuff:", "buffId:",buff:getId(), "buffClass:", buff:getClass())
    print("ActiveEffect:isImmuneBuff:", self.__immuneActiveBuff, self.__immuneActiveBuffClassMap, self.__immuneActiveBuffIdMap)

    if self.__immuneActiveBuff then
        return true
    end

    if MapIsEmpty(self.__immuneActiveBuffClassMap) == false then
        local buffClass = buff:getClass()
        for i, v in ipairs(self.__immuneActiveBuffClassMap) do
            if tostring(v) == tostring(buffClass) then
                return true
            end
        end
    end
   
    if MapIsEmpty(self.__immuneActiveBuffIdMap) == false then
        local buffId = buff:getId()
        for i, v in ipairs(self.__immuneActiveBuffIdMap) do
            if tostring(v) == tostring(buffId) then
                return true
            end
        end
    end

    return false
end

--[[
    @desc:尝试获取要驱散的buff类型列表
    author:唐健
    time:2021-07-08 17:22:12
    @return: boolean, {string}
]]
function ActiveEffect:tryGetRemoveBuffClass()
    if self.__removeBuffClass then
        return true, self.__removeBuffClass, self.__effect:getActiveEffectUseZhaoTips()
    end
    return false
end

function ActiveEffect:getActiveEffectUseZhaoTips()
    return self.__effect:getActiveEffectUseZhaoTips()
end

--[[
    @desc:属性影响, 触发的时候作用于对象
    author:tang
    time:2021-07-15 11:15:11
    @return:
]]
function ActiveEffect:tryGetAttrsEffect()
    local addAttrs = self.__addAttrs
    local mulAttrs = self.__mulAttrs

    if next(addAttrs) ~= nil or next(mulAttrs) ~= nil then
        local attrsEffect = AttrsEffect:create()
        attrsEffect:setAddAttrs(addAttrs)
        attrsEffect:setMulAttrs(mulAttrs)
        return true, attrsEffect
    end

    return false
end

--[[
    @desc: 合并主动效果
    author:TangJian
    time:2021-12-02 21:04:29
    --@activeEffect: 
    @return:
]]
function ActiveEffect:combine(activeEffect)
    assert(self:getId() == activeEffect:getId(), "self:getId() == activeEffect:getId()")
    assert(self.__addAttrName == activeEffect.__addAttrName, "self.__addAttrName == activeEffect.__addAttrName")
    assert(self.__mulAttrName == activeEffect.__mulAttrName, "self.__mulAttrName == activeEffect.__mulAttrName")

    if self.__effect:getStackType() == Constants.EffectStackType.Add then
        self.__addAttrValue = self.__addAttrValue + activeEffect.__addAttrValue
        self.__mulAttrValue = self.__mulAttrValue + activeEffect.__mulAttrValue

        for k, v in pairs(activeEffect.__addAttrs) do
            if self.__addAttrs[k] == nil then
                self.__addAttrs[k] = 0
            end
            self.__addAttrs[k] = self.__addAttrs[k] + v
        end

        for k, v in pairs(activeEffect.__mulAttrs) do
            if self.__mulAttrs[k] == nil then
                self.__mulAttrs[k] = 0
            end
            self.__mulAttrs[k] = self.__mulAttrs[k] + v
        end
    elseif self.__effect:getStackType() == Constants.EffectStackType.Max then
        self.__addAttrValue = math.max(self.__addAttrName, activeEffect.__addAttrValue)
        self.__mulAttrValue = math.max(self.__mulAttrName, activeEffect.__mulAttrValue)

        for k, v in pairs(activeEffect.__addAttrs) do
            if self.__addAttrs[k] == nil then
                self.__addAttrs[k] = 0
            end
            self.__addAttrs[k] = math.max(self.__addAttrs[k], v)
        end

        for k, v in pairs(activeEffect.__mulAttrs) do
            if self.__mulAttrs[k] == nil then
                self.__mulAttrs[k] = 0
            end
            self.__mulAttrs[k] = math.max(self.__mulAttrs[k], v)
        end
    end
end

--[[
    @desc:获取描述
    author:tang
    time:2021-07-15 11:15:58
    @return:
]]
function ActiveEffect:tryGetDesc()
    local text = self:getPrintText()
    if text ~= "" then
        return true, Desc:create(text)
    end
    return false
end

--[[
    @desc: 打印输出文本
    author:TangJian
    time:2021-12-02 21:04:19
    @return:
]]
function ActiveEffect:getPrintText()
    return self.__effect.activeEffectDesc or self.__effect.zhaoComboDirectDamgeDesc or ""
end

--[[
    @desc: 头顶弹出文本
    author:TangJian
    time:2021-12-02 21:04:08
    @return:
]]
function ActiveEffect:getPopText()
    return self.__activeEffectHurtRolePop or ""
end

--[[
    @desc: 头顶提示文本
    author:TangJian
    time:2021-12-02 21:04:02
    @return:
]]
function ActiveEffect:getTipText()
    return self.__activeEffectUseZhaoTips or ""
end

--[[
    @desc: 是否随机释放基本被动招式
    author:TangJian
    time:2021-12-02 21:03:43
    @return:
]]
function ActiveEffect:isRandomBaseAutoZhao()
    return self.__effect:isRandomBaseAutoZhao()
end

--[[
    @desc: 获取主动招式体力消耗影响值
    author:TangJian
    time:2021-12-02 21:03:20
    @return:
]]
function ActiveEffect:getAddActiveZhaoTiliCost()
    if self:getEffectTypeParam() == "2" then
        return self.__addTiliCost
    end
    return 0
end

--[[
    @desc: 获取被动招式体力消耗影响值
    author:TangJian
    time:2021-12-02 21:03:05
    @return:
]]
function ActiveEffect:getAddAutoZhaoTiliCost()
    if self:getEffectTypeParam() == "1" then
        return self.__addTiliCost
    end
    return 0
end

--[[
    @desc: 获取主动招式体力消耗影响率
    author:TangJian
    time:2021-12-02 21:02:15
    @return:
]]
function ActiveEffect:getMulActiveZhaoTiliCost()
    if self:getEffectTypeParam() == "2" then
        return self.__mulTiliCost
    end
    return 0
end

--[[
    @desc: 获取被动招式体力消耗影响率
    author:TangJian
    time:2021-12-02 21:02:05
    @return:
]]
function ActiveEffect:getMulAutoZhaoTiliCost()
    if self:getEffectTypeParam() == "1" then
        return self.__mulTiliCost
    end
    return 0
end

--[[
    @desc: 获取主动招式内力消耗影响值
    author:TangJian
    time:2021-12-02 21:01:52
    @return:
]]
function ActiveEffect:getAddActiveZhaoNeiliCost()
    if self:getEffectTypeParam() == "2" then
        return self.__addNeiliCost
    end
    return 0
end

--[[
    @desc: 获取主动招式内力消耗影响率
    author:TangJian
    time:2021-12-02 21:00:06
    @return:
]]
function ActiveEffect:getMulActiveZhaoNeiliCost()
    if self:getEffectTypeParam() == "2" then
        return self.__mulNeiliCost
    end
    return 0
end

--[[
    @desc: 获取被动招式内力消耗影响值
    author:TangJian
    time:2021-12-02 20:58:14
    @return:
]]
function ActiveEffect:getAddAutoZhaoNeiliCost()
    if self:getEffectTypeParam() == "1" then
        return self.__addNeiliCost
    end
    return 0
end

--[[
    @desc: 获取被动招式内力消耗影响率
    author:TangJian
    time:2021-12-02 20:58:41
    @return:
]]
function ActiveEffect:getMulAutoZhaoNeiliCost()
    if self:getEffectTypeParam() == "1" then
        return self.__mulNeiliCost
    end
    return 0
end

--[[
    @desc: 获取被动招式时的属性影响
    author:TangJian
    time:2021-12-02 20:56:53
    @return:
]]
function ActiveEffect:getUseAutoZhaoAttrEffect()
    if self:getEffectType() == Constants.EffectType.SelfAutoZhaoEffectCurrAttr then
        return true, self:getArgsParam(1), self:getEffectTypeParam(1), self.__selfAutoZhaoEffectCurrAttrDamageRate
    end
    return false, 0
end

--[[
    @desc: 获取在被动招式下的属性影响
    author:TangJian
    time:2021-12-02 20:56:35
    @return:
]]
function ActiveEffect:getUnderAutoZhaoAttrEffect()
    if self:getEffectType() == Constants.EffectType.TargetAutoZhaoEffectCurrAttr then
        return true, self:getArgsParam(1), self:getEffectTypeParam(1), self.__targetAutoZhaoEffectCurrAttrDamageRate
    end
    return false, 0
end

--[[
    @desc: 获取主动攻击时的属性影响
    author:TangJian
    time:2021-12-02 20:56:17
    @return:
]]
function ActiveEffect:getUseActiveZhaoAttrEffect()
    if self:getEffectType() == Constants.EffectType.SelfActiveZhaoEffectCurrAttr then
        return true, self:getArgsParam(1), self:getEffectTypeParam(1), self.__selfActiveZhaoEffectCurrAttrDamageRate
    end
    return false, 0
end

--[[
    @desc: 获取在主动招式下的属性影响
    author:TangJian
    time:2021-12-02 20:55:49
    @return:
]]
function ActiveEffect:getUnderActiveZhaoAttrEffect()
    if self:getEffectType() == Constants.EffectType.TargetActiveZhaoEffectCurrAttr then
        return true, self:getArgsParam(1), self:getEffectTypeParam(1), self.__targetActiveZhaoEffectCurrAttrDamageRate
    end
    return false, 0
end

--[[
    @desc: 尝试触发
    author:TangJian
    time:2021-12-02 20:54:29
    --@eventName:
	--@eventParam: 
    @return:
]]
function ActiveEffect:tryTrigger(eventName, eventParam)
    return switch(
        eventName,
        {
            [Constants.BuffTriggerType.Add] = function()
                return switch(
                    self:getEffectType(),
                    {
                        [Constants.EffectType.TransferBuff] = function()
                            return true
                        end,
                        [Constants.EffectType.FixedMulCurrAttr] = function()
                            if self.__firstTriggered == false then
                                self.__firstTriggered = true
                                self.__triggerTimes = self.__triggerTimes + 1
                                print("触发效果成功 ", "添加时触发 ", "当前触发次数=", self.__triggerTimes)
                                --@TODO 2021-12-23 21:47:21 沒有支持FixedMulCurrAttr
                                return false
                            end
                            print("触发效果失败 ", eventName)
                            return false
                        end,
                        [Constants.EffectType.AddCurrAttr] = function()
                            if self.__firstTriggered == false then
                                self.__firstTriggered = true
                                self.__triggerTimes = self.__triggerTimes + 1
                                print("触发效果成功 ", "添加时触发 ", "当前触发次数=", self.__triggerTimes)
                                return true
                            end
                            print("触发效果失败 ", eventName)
                            return false
                        end,
                        [Constants.EffectType.FixedMulAttr] = function()
                            -- 该类型不需要触发
                            return false
                        end,
                        [Constants.EffectType.AddAttr] = function()
                            return false
                        end,
                        default = function()
                            print("触发效果失败 ", eventName)
                            return false
                        end
                    }
                )
            end,
            [Constants.BuffTriggerType.SomeBodyAttackEnd] = function()
                return switch(
                    self:getEffectType(),
                    {
                        [Constants.EffectType.FixedMulCurrAttr] = function()
                            if self.__triggerGapActive >= self:__getTriggerGap() then
                                self.__triggerGapActive = 0
                                self.__triggerTimes = self.__triggerTimes + 1
                                print("触发效果成功 ", "攻击结束时触发 ", "当前触发次数=", self.__triggerTimes)
                                return true
                            else
                                self.__triggerGapActive = self.__triggerGapActive + 1
                                return false
                            end
                        end,
                        [Constants.EffectType.AddCurrAttr] = function()
                            if self.__triggerGapActive >= self:__getTriggerGap() then
                                self.__triggerGapActive = 0
                                self.__triggerTimes = self.__triggerTimes + 1
                                print("触发效果成功 ", "攻击结束时触发 ", "当前触发次数=", self.__triggerTimes)
                                return true
                            else
                                self.__triggerGapActive = self.__triggerGapActive + 1
                                return false
                            end
                        end,
                        default = function()
                            print("触发效果失败 ", eventName)
                            return false
                        end
                    }
                )
            end,
            [Constants.BuffTriggerType.UseAutoZhao] = function()
                return switch(
                    self:getEffectType(),
                    {
                        [Constants.EffectType.SelfAutoZhaoEffectCurrAttr] = true,
                        default = false
                    }
                )
            end,
            [Constants.BuffTriggerType.UseActiveZhao] = function()
                return switch(
                    self:getEffectType(),
                    {
                        [Constants.EffectType.SelfActiveZhaoEffectCurrAttr] = true,
                        default = false
                    }
                )
            end,
            [Constants.BuffTriggerType.UnderAutoZhao] = function()
                return switch(
                    self:getEffectType(),
                    {
                        [Constants.EffectType.AutoZhaoReductionOfInjurySub] = true,
                        [Constants.EffectType.ActiveZhaoReductionOfInjury] = true,
                        -- [Constants.EffectType.TargetAutoZhaoEffectCurrAttr] = true,
                        default = false
                    }
                )
            end,
            [Constants.BuffTriggerType.UnderActiveZhao] = function()
                return switch(
                    self:getEffectType(),
                    {
                        [Constants.EffectType.ActiveZhaoReductionOfInjurySub] = true,
                        [Constants.EffectType.AutoZhaoReductionOfInjury] = true,
                        -- [Constants.EffectType.TargetActiveZhaoEffectCurrAttr] = true,
                        default = false
                    }
                )
            end,
            default = function()
                print("不触发 eventName = ", tostring(eventName))
                return false
            end
        }
    )
end

function ActiveEffect:getShieldValue()
    return 1
end

function ActiveEffect:comsumeShieldValue(value)
    return value
end

-- 获取触发间隔
function ActiveEffect:__getTriggerGap()
    return tonumber(self:getEffectTypeParam(2))
end

function ActiveEffect:getRoleFeetHaloAnimIdAndPriority()
    return self.__effect:getRoleFeetHaloAnimIdAndPriority()
end

return class("ActiveEffect", {IEffect}, ActiveEffect)
000000