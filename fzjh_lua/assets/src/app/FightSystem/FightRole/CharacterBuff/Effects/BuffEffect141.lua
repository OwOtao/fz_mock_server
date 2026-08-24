--[[**效果类型ID=141，角色伤害抗性属性比例修正N点**
* 效果生效节点：无特殊触发节点，持有Buff期间生效
  * 效果功能执行：影响角色武学伤害抗性，影响公式见 [角色战斗属性与战斗伤害/武学伤害抗性/伤害属性修正系数](角色战斗属性与战斗伤害) 的【受击者其它系统.伤害防御属性值 - 主动效果.伤害属性攻击系数】和【攻击者其它系统.伤害攻击属性值 - 主动效果.伤害属性防御系数】
    * effectTypeParam配置：抗性类型#伤害属性类型ID
      * 抗性类型：atkDamageClass=攻击属性、defDamageClass=防御属性
      * 伤害属性类型ID：伤害属性类型ID查看 `表[武学伤害属性类型管理].id`
    * argsParam配置加成的效果值公式ID，公式ID读取 `表[总Buff表效果伤害].id`。
    * 效果值=`表[总Buff表效果伤害].id` 对应返回结果值（小数）
* 效果生效文本表现：无
* 效果值叠加方式：同效果类型ID效果值N的总和
]]

local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect141 = {}

function BuffEffect141:create()
    return BuffEffect141.new():__init()
end

function BuffEffect141:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect141:updateEffectValue()
    if self.__isInit == false then
        local effectTypeParams = string.split(self.__basicEffect:getEffectTypeParam(), "#")

        self.__attrTypeName = effectTypeParams[1]
        
        self.__attrTypeId = tostring(effectTypeParams[2])

        self.__calculatorId = self.__basicEffect:getArgsParam()

        self.__isInit = true
    end

    self.__calValue = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect141:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__addValue = self.__calValue
    FightUtil:printFormatLog("BuffEffect141:makeEffectOnAdd - %s 角色特殊战斗属性：%s，固值修正N点 %s", self.__buff:getBuffOwner():getAttr("name"), self.__attrTypeName, self.__attrTypeId, self.__addValue)

    if self.__attrTypeName == "atkDamageClass" then
        self.__buff:getBuffOwner():addSkillAtkResistance(self.__attrTypeId, self.__addValue)
    elseif skillDamageResistanceType == "defDamageClass" then
        self.__buff:getBuffOwner():addSkillDefResistance(self.__attrTypeId, self.__addValue)
    end
end

function BuffEffect141:makeEffectOnRemove()
    FightUtil:printFormatLog("BuffEffect141:makeEffectOnRemove - %s 角色特殊战斗属性：%s，固值修正N点 %s", self.__buff:getBuffOwner():getAttr("name"), self.__attrTypeName, self.__attrTypeId, -self.__addValue)

    if self.__attrTypeName == "atkDamageClass" then
        self.__buff:getBuffOwner():addSkillAtkResistance(self.__attrTypeId, -self.__addValue)
    elseif skillDamageResistanceType == "defDamageClass" then
        self.__buff:getBuffOwner():addSkillDefResistance(self.__attrTypeId, -self.__addValue)
    end
end

function BuffEffect141:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect141", {ABuffEffect}, BuffEffect141)
000000000