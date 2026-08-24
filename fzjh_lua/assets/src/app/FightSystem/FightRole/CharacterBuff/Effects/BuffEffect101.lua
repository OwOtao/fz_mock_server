--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    **效果类型ID=101，角色战斗属性比例修正N%**

    * 效果触发节点：无特殊触发节点，持有Buff期间生效
    * 效果功能执行：影响角色战斗属性，影响公式见 [角色战斗属性与战斗伤害/角色战斗属性](角色战斗属性与战斗伤害)
        * effectTypeParam配置角色属性ID，格式：影响的具体属性ID查看 表[角色属性管理] 的 角色类
        * argsParam配置总Buff表效果伤害ID。ID读取 总Buff表效果伤害.xlsx 的 id
        * 效果值=`表[总Buff表效果伤害].id` 对应返回结果值
    * 效果生效表现：无
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect101 = {}

function BuffEffect101:create()
    return BuffEffect101.new():__init()
end

function BuffEffect101:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect101:updateEffectValue()
    if self.__isInit == false then
        self.__attrName = self.__basicEffect:getEffectTypeParam()

        self.__calculatorId = self.__basicEffect:getArgsParam()

        self.__isInit = true
    end

    self.__calValue = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect101:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__addValue = self.__calValue

    FightUtil:printFormatLog("BuffEffect101:makeEffectOnAdd %s 角色属性修正效果添加触发，属性ID=%s，修正值=%s", self.__buff:getBuffOwner():getAttr("name"), self.__attrName, self.__addValue)
    
    self.__buff:getBuffOwner():addBuffMulAttr(self.__attrName, self.__addValue)
end

function BuffEffect101:makeEffectOnRemove()
    FightUtil:printFormatLog("BuffEffect101:makeEffectOnRemove %s 角色属性修正效果移除触发，属性ID=%s，修正值=%s", self.__buff:getBuffOwner():getAttr("name"), self.__attrName, -self.__addValue)

    self.__buff:getBuffOwner():addBuffMulAttr(self.__attrName, -self.__addValue)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect101:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect101", {ABuffEffect}, BuffEffect101)
0000000000