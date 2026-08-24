--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=130，角色气血护盾生命值修正N点并激活气血护盾**

        * 效果触发节点：无特殊触发节点，持有Buff期间生效
        * 效果功能执行：Buff有效期内，修正(增加或者减少)角色气血护盾的生命值，且激活气血护盾效果。
            * 每个buff的气血护盾剩余生命值，各自计算。
            * 具体气血护盾规则见：[角色战斗属性与战斗伤害.md/角色特殊战斗属性/气血护盾](角色战斗属性与战斗伤害)
        * 修正指定类型角色气血护盾生命值N点，N=argsParam配置的总Buff表效果伤害ID对应返回结果值。
            * ID读取 总Buff表效果伤害.xlsx 的 id
        * 气血护盾效果生效表现：无效果生效表现
        * 效果值叠加方式：同效果类型ID效果值N，各自计算抵消。
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect130 = {}

function BuffEffect130:create()
    return BuffEffect130.new():__init()
end

function BuffEffect130:__init()
    self.__isInit = false

    return self
end

function BuffEffect130:updateEffectValue()
    self.__calculatorId = self.__basicEffect:getArgsParam()

    if self.__isInit == false then
        self:setShileValue(BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage())
    end
end

function BuffEffect130:makeEffectOnAdd()
    self:updateEffectValue()

    local shieldAnimId, priority = self.__buff:getShieldAnimAndPriority()

    if shieldAnimId == nil then
        error("BuffEffect130:makeEffectOnAdd buffId:" .. tostring(self.__buff:getId()) .. " 没有配置气血护盾动画")
    end

    local BuffShield = require("app.FightSystem.FightRole.CharacterShield.Shields.BuffShield")
    --@RefType [src.app.FightSystem.FightRole.CharacterShield.Shields.BuffShield#BuffShield]
    self.__shield = BuffShield:create(self.__buff:getId())

    self.__shield:setShieldValue(self.__calValue)

    self.__shield:setShieldAnimId(shieldAnimId)

    self.__shield:setPriority(priority)

    self.__buff:getBuffOwner():addQiShield(self.__shield)
end

function BuffEffect130:makeEffectOnRemove()
    self.__buff:getBuffOwner():removeQiShield(self.__shield:getShieldId())
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect130:makeEffectOnTransfer(buffEffect)
    buffEffect:setShileValue(self.__shield:getShieldValue())
end

function BuffEffect130:setShileValue(value)
    self.__calValue = value
    self.__isInit = true
end

return newClass("BuffEffect130", {ABuffEffect}, BuffEffect130)
00000