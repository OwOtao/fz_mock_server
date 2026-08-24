--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    - **效果类型ID=311，普通招架成功，根据受到命中伤害影响目标指定角色当前属性N点**

    * 效果生效节点：12=受被动招式攻击判定普通招架(攻击招式结束时-被动受击者-普通招架)

        * 效果功能执行：

        * 将角色受到被动招式组合攻击，*单次攻击*命中判定结果是普通招架的攻击、计算*预计攻击命中受到气血伤害A*。

            * 单次攻击：被动招式组合一个独立判断命中的攻击动画为单次攻击

            * 预计攻击命中受到气血伤害A：指的是 [角色战斗属性与战斗伤害.md - 招式伤害计算公式/被动招式/被动招式直接攻击伤害招式分摊规则](角色战斗属性与战斗伤害) 内**单次气血伤害(命中)、计算攻击权重分摊伤害后**公式计算返回值

            > 单次气血伤害(命中)可以认为效果值是不受招架削减、也不受免伤抵扣的初始命中气血伤害

        * 在被动招式组合攻击结束后将多个气血伤害A算总和，乘以效果修正值后作为效果值N。

            * 效果修正值，配置在argsParam，第2个参数公式返回值

        * 判断效果生效概率，概率成功则对指定目标的指定当前属性减少N点

            * 效果生效概率，配置在argsParam，第3个参数

            > 效果值N计算的是判断为招架的攻击预计命中伤害。
            >
            > 假如一个攻击组合有3次，命中判断都是命中的话气血伤害是A1、A2、A3，效果修正值是0.75，效果生效概率90%，影响目标当前气血
            >
            > 实际战斗中第2、3次攻击普通招架了，则 效果值N=(A2+A3)x0.75，在攻击组合结束有90%概率扣除目标当前气血N点

        * effectTypeParam配置指定目标类型和影响属性类型，格式：影响属性类型。

        * 影响属性类型：qi=当前气血、qiMax=当前气血上限、neili=当前内力

        * argsParam配置格式：影响目标#效果修正值公式ID#效果生效概率

        * 影响目标：自身=self、攻击者=atk
        * 效果修正值公式ID：ID读取 总Buff表效果伤害.xlsx 的 id，计算出的公式返回结果值，就是效果修正值
        * 效果生效概率：配置范围1~100，可以调用Buff传入的动态参数

        * 效果生效表现：

        * T5=角色头顶弹字提示(招式组合)（影响目标头顶）。

            * 弹字时间：效果生效，在被动招式组合攻击结束时显示弹字。
            * 效果值N=0，弹字提示数字会显示0

        * T3=界面战斗信息区新增描述文本，在被动招式组合攻击结束，显示本次招式组合攻击实际影响目标的属性值总和。

            * 效果值N=0，属性值总和提示数字会显示0

    * 效果值叠加方式：同效果类型ID效果值N的总和。


]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

local FightCommons = require("app.FightSystem.FightCommons")

--@RefType [Constants]
local BUFF_CONTANTS = require("app.FightSystem.FightBuff.Constants")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

local BasicBuffEffectModifierAttr = require("app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect311 = {}

function BuffEffect311:create()
    return BuffEffect311.new():__init()
end

function BuffEffect311:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect311:updateEffectValue()
    if self.__isInit == false then
        self.__attrName = self.__basicEffect:getEffectTypeParam()

        local args = string.split(self.__basicEffect:getArgsParam(), "#")

        self.__targetType = args[1]

        self.__calculatorId = args[2]

        local rate = tonumber(args[3])

        if rate == nil then
            self.__rate = self.__buff:getBuffDynamicArg(args[3])
        else
            self.__rate = rate
        end

        self.__isInit = true
    end

    self.__calValue = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect311:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    self.__buff:registerMakeEffectListener(
        BUFF_CONTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnAutoCombFinish,
        function(...)
            self:__makeEffectOnAutoCombFinish(...)
        end
    )
end

function BuffEffect311:makeEffectOnRemove()
end

--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
function BuffEffect311:__makeEffectOnAutoCombFinish(context)
    local attacker = context:getAttacker()

    local target = context:getTarget()

    if self.__buff:getBuffOwner() ~= target then
        --@desc 该效果只有作为目标时才触发
        return
    end

    local hasParry = false

    self.__totalHurtValue = 0
    context:walkAllZhaoAttackInTheCombAttack(
        function(i, zhaoAttack)
            --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
            zhaoAttack = zhaoAttack
            if zhaoAttack:getHitType() == FightCommons.ATTACK_HIT_TYPE.PARRY then
                hasParry = true

                --@RefType [src.app.FightSystem.ZhaoAttacks.AttackResultVisitor.QiOriginHurtTotalValueAttackResultVisitor#QiOriginHurtTotalValueAttackResultVisitor]
                local qiValueVisitor = require("app.FightSystem.ZhaoAttacks.AttackResultVisitor.QiOriginHurtTotalValueAttackResultVisitor"):create()

                zhaoAttack:runAttackResultVisitor(qiValueVisitor)

                self.__totalHurtValue = self.__totalHurtValue + qiValueVisitor:getQiOriginHurtTotalValue()
            end

            return false
        end
    )

    if not hasParry then
        return
    end

    local istrigger = false

    if self.__rate >= 100 then
        istrigger = true
    elseif self.__rate <= 0 then
    else
        local randomRate = FightUtil:random(1, 100)
        if randomRate <= self.__rate then
            istrigger = true
        else
            istrigger = false
        end
    end

    if not istrigger then
        return
    end

    local effectTarget
    if self.__targetType == "self" then
        effectTarget = target
    elseif self.__targetType == "atk" then
        effectTarget = attacker
    end

    local effectModifier = self:__trigger(effectTarget)

    context:addCharacterEffectModifierAttr(effectModifier)
end

function BuffEffect311:__trigger(target)
    local value = self.__totalHurtValue * self.__calValue
    FightUtil:printFormatLog("Buff 效果311 __trigger： 影响属性：【%s】, buff计算值【%s】 ,招架招式气血值【%s】 , 最终值【%s】", self.__attrName, tostring(self.__calValue), tostring(self.__totalHurtValue), tostring(value))

    --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
    local effectModifier = BasicBuffEffectModifierAttr:create():initEffectHurt(self.__basicEffect:getId(), self.__attrName, value, self.__buff:getBuffOwner():getId())

    effectModifier:doAttack(target)

    return effectModifier
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect311:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect311", {ABuffEffect}, BuffEffect311)
0000000