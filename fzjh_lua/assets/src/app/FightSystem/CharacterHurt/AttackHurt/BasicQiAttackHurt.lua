--[[
    author:Seven
    time:2023-02-07 20:13:28
    desc: 基础气血攻击伤害
]]
local newClass = require("third.class.NewClass")

local ABasicAttackHurt = require("app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt")

local QiDamageReducePenetrationCalculator = require("app.FightSystem.CharacterHurt.AttackHurt.QiDamageReducePenetrationCalculator")

--@SuperType [src.app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt#ABasicAttackHurt]
local BasicQiAttackHurt = {}

--@desc: 创建基础气血伤害实例
--@author:Codex
--@time:2026-03-17
--@damageType: 1=被动，2=主动
function BasicQiAttackHurt:create(damageType)
    return BasicQiAttackHurt.new():__init(damageType)
end

--@desc: 初始化气血伤害类型
--@author:Codex
--@time:2026-03-17
--@damageType: 1=被动，2=主动
function BasicQiAttackHurt:__init(damageType)
    self.__qiDamageType = tonumber(damageType)

    if self.__qiDamageType == nil then
        error("BasicQiAttackHurt:__init damageType 未设置")
    end

    return self
end

--@desc: 组装新版减伤计算器
--@author:Codex
--@time:2026-03-17
--@attacker: 攻击方角色
--@target: 受击目标
function BasicQiAttackHurt:__initCalculator(attacker, target)
    local calculator = QiDamageReducePenetrationCalculator:create()
    calculator:setDamageType(self.__qiDamageType)
    calculator:setOriginQiDamage(self.__originValue)
    calculator:setAllocPercent(self:getAllocPercent())
    calculator:setAttacker(attacker)
    calculator:setTarget(target)
    return calculator
end

--@desc: 获取当前受击帧减伤明细
--@author:Codex
--@time:2026-03-17
function BasicQiAttackHurt:getReduceDetailList()
    if self.__reduceDetailList == nil then
        error("BasicQiAttackHurt:getReduceDetailList 减免明细未计算，检查代码调用流程")
    end

    return self.__reduceDetailList
end

--@desc: 获取最终预计伤害
--@author:Codex
--@time:2026-03-17
function BasicQiAttackHurt:getFinalOriginHurtValue()
    if self.__finalOriginValue == nil then
        error("BasicQiAttackHurt:getFinalOriginHurtValue 最终预计值为空，检查代码")
    end

    return self.__finalOriginValue
end

--@desc: 获取指定阶段实际气血伤害
--@author:Codex
--@time:2026-03-17
--@stage: 阶段
function BasicQiAttackHurt:getStageActualQiDamage(stage)
    if self.__stageActualQiDamageMap == nil then
        error("BasicQiAttackHurt:getStageActualQiDamage 阶段结果未计算，检查代码调用流程")
    end

    local value = self.__stageActualQiDamageMap[stage]
    if value == nil then
        error("BasicQiAttackHurt:getStageActualQiDamage 未找到阶段 " .. tostring(stage) .. " 的结果")
    end

    return value
end

--@desc: 获取实际气血伤害(免伤初期)
--@author:Seven
--@time:2026-03-20
function BasicQiAttackHurt:getPreMitigationQiDamage()
    if self.__preMitigationQiDamage == nil then
        error("BasicQiAttackHurt:getPreMitigationQiDamage 免伤初期值未计算，检查代码调用流程")
    end

    return self.__preMitigationQiDamage
end

--@desc: 获取最终阶段实际气血伤害
--@author:Codex
--@time:2026-03-17
function BasicQiAttackHurt:getFinalActualQiDamage()
    if self.__finalActualQiDamage == nil then
        error("BasicQiAttackHurt:getFinalActualQiDamage 最终阶段结果未计算，检查代码调用流程")
    end

    return self.__finalActualQiDamage
end

--@desc: 执行一次气血伤害结算
--@author:Codex
--@time:2026-03-17
--@attacker: 攻击者
--@target: 受击目标
function BasicQiAttackHurt:inAttack(attacker, target)
    local calculator = self:__initCalculator(attacker, target)
    local result = calculator:getResult()

    self.__stageActualQiDamageMap = result.stageActualQiDamageMap
    self.__reduceDetailList = result.reduceDetailList
    self.__finalActualQiDamage = result.finalActualQiDamage
    self.__preMitigationQiDamage = result.preMitigationQiDamage
    -- 新算法下，最终预计伤害与实际扣盾前基准统一使用最后阶段结果。
    self.__finalOriginValue = self.__finalActualQiDamage

    local finalValue = self.__finalActualQiDamage

    -- 保留旧链路的运行时日志能力，方便直接从 FightLog 排查阶段结算问题。
    calculator:printString()

    -- 先结算新算法的最终气血伤害，再按是否可穿盾决定护盾吸收量。
    if self.__bypassShield == false and target:getQiShieldValue() > 0 then
        local shieldValue = target:getQiShieldValue()
        if shieldValue > finalValue then
            self.__shieldCostValue = finalValue

            target:costQiShieldValue(finalValue)

            self.__value = 0
        else
            self.__shieldCostValue = shieldValue

            target:costQiShieldValue(shieldValue)

            self.__value = finalValue - shieldValue
        end
    else
        self.__value = finalValue
    end

    target:addAttr(self.__attrName, -self.__value)

    if target:getBuffAddAttr("RecordDamageBuffNum") > 0 and self.__value > 0 then
        target:addAttr("recordDamage", self.__value)
    end
end

return newClass("BasicQiAttackHurt", {ABasicAttackHurt}, BasicQiAttackHurt)
0