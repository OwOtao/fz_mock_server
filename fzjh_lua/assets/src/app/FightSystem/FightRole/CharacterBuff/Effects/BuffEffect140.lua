--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc:
        **效果类型ID=140，角色穿透免伤属性修正N点**

        * 效果触发节点：无特殊触发节点，持有Buff期间生效
            * 效果功能执行：影响角色战斗属性，影响公式见 角色战斗属性与战斗伤害/角色特殊战斗属性/被动招式实际伤害与分摊规则
              和 角色战斗属性与战斗伤害/角色特殊战斗属性/主动招式直接攻击伤害招式分摊规则
              的【Buff.穿透值加成】、【Buff.免伤率加成】、【Buff.免伤值加成】
                * effectTypeParam配置角色免伤穿透属性id，属性ID对应 `表[角色免伤穿透属性].id`
                * argsParam配置 免伤穿透效果值公式ID。
                    * 效果伤害ID读取 `表[总Buff表效果伤害].id`
                * 效果值=`表[总Buff表效果伤害].id` 对应返回结果值
                * Buff效果生效时处于僵持阶段，生成效果值计算公式用到目标角色属性，
                  如果Buff持有者有锁定攻击目标，则将锁定的目标作为计算公式的目标角色；
                  如果Buff持有者当前没有锁定的攻击目标，则公式用到目标角色属性按0计算。
                * 效果值叠加方式：相同角色免伤穿透属性id的效果值N按总和计算。
        * 效果生效表现：无
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect140 = {}

function BuffEffect140:create()
    return BuffEffect140.new():__init()
end

function BuffEffect140:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect140:updateEffectValue()
    if self.__isInit == false then
        self.__reduceId = FightCommons.HURT_REDUCE_ATTR_PREFIX .. self.__basicEffect:getEffectTypeParam()

        self.__calculatorId = self.__basicEffect:getArgsParam()

        self.__isInit = true
    end

    self.__calValue = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect140:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__addValue = self.__calValue
    FightUtil:printFormatLog("BuffEffect140:makeEffectOnAdd - %s 角色穿透免伤属性：%s，修正N点 %s", self.__buff:getBuffOwner():getAttr("name"), self.__reduceId, self.__addValue)
    self.__buff:getBuffOwner():addBuffAddAttr(self.__reduceId, self.__addValue)
end

function BuffEffect140:makeEffectOnRemove()
    FightUtil:printFormatLog("BuffEffect140:makeEffectOnRemove - %s 角色穿透免伤属性：%s，修正N点 %s", self.__buff:getBuffOwner():getAttr("name"), self.__reduceId, -self.__addValue)
    self.__buff:getBuffOwner():addBuffAddAttr(self.__reduceId, -self.__addValue)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect140:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect140", {ABuffEffect}, BuffEffect140)
0000000000000