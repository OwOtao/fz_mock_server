--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=201，招式体力消耗比例修正N%**

        * 效果触发节点：1=使用被动招式、2=使用主动招式
        * 效果功能执行：角色使用指定的被动招式、主动招式时，体力消耗被影响，影响公式见 [角色战斗属性与战斗伤害/招式伤害计算公式](角色战斗属性与战斗伤害)
            * effectTypeParam配置影响招式类型。格式：类型#类型；1=被动招式，2=主动招式
            * argsParam配置总Buff表效果伤害ID。ID读取 总Buff表效果伤害.xlsx 的 id
            * 效果值=`表[总Buff表效果伤害].id` 对应返回结果值
        * 效果值叠加方式：同效果类型ID效果值N%的最大值。
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect201 = {}

function BuffEffect201:create()
    return BuffEffect201.new():__init()
end

function BuffEffect201:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect201:updateEffectValue()
    if self.__isInit == false then
        self.__type = tonumber(self.__basicEffect:getEffectTypeParam())

        self.__calculatorId = self.__basicEffect:getArgsParam()

        self.__isInit = true
    end

    self.__calValue = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect201:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__addValue = self.__calValue

    if self.__type == 1 then
        self.__attrName = "autoTiliCorrectionFactor"
    elseif self.__type == 2 then
        self.__attrName = "activeTiliConstCorrectionFactor"
    else
        error("效果类型 201 未知影响招式类型：" .. tostring(self.__type))
    end

    self.__onlyId = self.__buff:getBuffOwner():addBuffMaxValue(self.__attrName, self.__addValue, self.__basicEffect:getEffectID())
end

function BuffEffect201:makeEffectOnRemove()
    self.__buff:getBuffOwner():removeBuffMaxValue(self.__attrName, self.__onlyId)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect201:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect201", {ABuffEffect}, BuffEffect201)
000