--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=200，招式体力消耗修正N点**

        * 效果功能执行：角色使用指定的被动招式、主动招式时，体力消耗被影响，影响公式见 [角色战斗属性与战斗伤害/招式伤害计算公式](角色战斗属性与战斗伤害)
            * effectTypeParam配置影响招式类型。格式：类型；1=被动招式，2=主动招式
            * argsParam配置总Buff表效果伤害ID。ID读取 总Buff表效果伤害.xlsx 的 id
            * 效果值=`表[总Buff表效果伤害].id` 对应返回结果值
        * 效果生效表现：无
        * 效果值叠加方式：同效果类型ID效果值N的总和。
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect200 = {}

function BuffEffect200:create()
    return BuffEffect200.new():__init()
end

function BuffEffect200:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect200:updateEffectValue()
    if self.__isInit == false then
        self.__type = tonumber(self.__basicEffect:getEffectTypeParam())

        self.__calculatorId = self.__basicEffect:getArgsParam()

        self.__isInit = true
    end

    self.__calValue = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect200:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__addValue = self.__calValue

    if self.__type == 1 then
        self.__attrName = "autoTiliConst"
    elseif self.__type == 2 then
        self.__attrName = "activeTiliConst"
    else
        error("效果类型 200 未知影响招式类型：" .. tostring(self.__type))
    end

    FightUtil:printFormatLog("BuffEffect200：makeEffectOnAdd - %s 添加触发影响招式类型：%s，影响属性：%s， 影响值：%s", self.__buff:getBuffOwner():getAttr("name"), self.__type, self.__attrName, self.__addValue)
    self.__buff:getBuffOwner():addBuffAddAttr(self.__attrName, self.__addValue)
end

function BuffEffect200:makeEffectOnRemove()
    FightUtil:printFormatLog("BuffEffect200：makeEffectOnRemove - %s 移除触发影响招式类型：%s，影响属性：%s， 影响值：%s", self.__buff:getBuffOwner():getAttr("name"), self.__type, self.__attrName, -self.__addValue)
    self.__buff:getBuffOwner():addBuffAddAttr(self.__attrName, -self.__addValue)
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect200:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect200", {ABuffEffect}, BuffEffect200)
000000000000000