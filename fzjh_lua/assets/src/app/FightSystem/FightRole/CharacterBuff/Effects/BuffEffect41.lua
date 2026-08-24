--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=41，造成主动招式直接气血伤害比例N%影响目标当前属性**

        * 效果触发节点：41=造成主动招式直接伤害
        * 效果功能执行：角色主动招式直接伤害实际造成的气血伤害X点，按比例N%，影响指定目标的指定当前属性M点。
            * 角色的一次招式组合攻击预计造成的气血伤害X点，指的是每个受击帧 `BasicQiAttackHurt:getFinalActualQiDamage()` 返回的**最终阶段实际气血伤害**，再汇总得到的**多次影响属性总和**。
            * 配置方式 同 效果类型ID=40
            * 效果值=`int(X*N%)`
            * 效果值不会小于0
        * 效果生效表现：同 效果类型ID=40
]]
local newClass = require("third.class.NewClass")

local isImplement = require("third.assertIsInstance.assertIsInstance")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

local BasicBuffEffectModifierAttr = require("app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr")

--@RefType [Constants]
local BUFF_CONSTANS = require("app.FightSystem.FightBuff.Constants")

local FightCommons = require("app.FightSystem.FightCommons")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect41 = {}

function BuffEffect41:create()
    return BuffEffect41.new():__init()
end

function BuffEffect41:__init()
    self.__isInit = false

    self.__calValueIsInit = false

    return self
end

function BuffEffect41:updateEffectValue()
    if self.__isInit == false then
        self.__attrName = self.__basicEffect:getEffectTypeParam()

        local args = string.split(self.__basicEffect:getArgsParam(), "#")

        self.__targetType = args[1]

        self.__calculatorId = args[2]

        self.__isInit = true
    end

    self.__value = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect41:makeEffectOnAdd()
    if self.__calValueIsInit == false then
        self:updateEffectValue()
        self.__calValueIsInit = true
    end

    self.__buff:registerMakeEffectListener(
        BUFF_CONSTANS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnActiveZhaoAttack,
        function(...)
            self:__onActiveZhaoAttack(...)
        end
    )
end

--@desc:击中时
--@author:Seven
--@time:2023-12-01 14:39:28
--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
--@oneAttackHitResult: [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function BuffEffect41:__onActiveZhaoAttack(context, oneAttackHitResult)
    local attacker = context:getAttacker()

    if attacker ~= self.__buff:getBuffOwner() then
        --@desc 该buff 只有作为攻击者时才触发
        return
    end

    local target = context:getTarget()

    if target ~= self.__buff:getBuffOwner():getTarget() then
        error(" BuffEffect41:__onActiveZhaoAttack 当前上下文攻击目标与该效果持有角色的攻击目标不一致，检查代码流程")
    end

    local currZhaoAttack = context:getCurrZhaoAttack()

    --@desc 目前照成招式伤害的只有击中及招架
    if not table.contains({FightCommons.ATTACK_HIT_TYPE.HIT, FightCommons.ATTACK_HIT_TYPE.PARRY}, currZhaoAttack:getHitType()) then
        return
    end

    local qiZhaoHurts = {}

    oneAttackHitResult:walkOneHitZhaoHurts(
        function(index, zhaoHurt)
            --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.ABasicAttackHurt#ABasicAttackHurt]
            zhaoHurt = zhaoHurt

            if zhaoHurt:getAttrName() == "qi" then
                isImplement(zhaoHurt, require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt"))

                table.insert(qiZhaoHurts, zhaoHurt)
            end
        end
    )

    for _, qiZhaoHurt in ipairs(qiZhaoHurts) do
        --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
        qiZhaoHurt = qiZhaoHurt

        -- 41 号效果与 40 号一致，统一读取最终阶段实际气血伤害。
        local originFinalValue = qiZhaoHurt:getFinalActualQiDamage()

        local finalValue = math.ceil(originFinalValue * self.__value)

        --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
        local effectModifier = BasicBuffEffectModifierAttr:create():initEffectHurt(self.__basicEffect:getId(), self.__attrName, finalValue, self.__buff:getBuffOwner():getId())

        if self.__targetType == "self" then
            effectModifier:doAttack(attacker)
            oneAttackHitResult:addAttackerEffectModifierAttr(effectModifier)
        elseif self.__targetType == "def" then
            effectModifier:doAttack(target)
            oneAttackHitResult:addTargetEffectModifierAttr(effectModifier)
        end
    end
end

function BuffEffect41:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect41:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect41", {ABuffEffect}, BuffEffect41)
000000