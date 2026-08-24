--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=42，受被动招式攻击气血伤害按N%影响目标当前属性**

        * 效果触发节点：20=受被动招式攻击造成伤害
        * 效果功能执行：角色受到被动招式预计造成的气血伤害X点，按比例N%，影响指定目标的指定当前属性M点。
            * 角色受到的一次招式组合攻击预计造成的气血伤害X点，指的是每个受击帧 `BasicQiAttackHurt:getStageActualQiDamage(1)` 返回的**第一阶段实际气血伤害**，再汇总得到的**多次影响属性总和**。
            * effectTypeParam配置指定目标类型和影响属性类型，格式：影响属性类型。
                * 影响属性类型：qi=当前气血、qiMax=当前气血上限、neili=当前内力
            * N%=argsParam配置的总Buff表效果伤害ID对应返回结果值，格式：影响目标#效果伤害ID 。 
                * 影响目标，自身=self、攻击者=atk。
                * 效果伤害ID，ID读取 总Buff表效果伤害.xlsx 的 id
            * 效果值=`int(X*N%)`
            * 效果值不会小于0
        * 效果生效表现：
            * T3=界面战斗信息区新增描述文本，显示实际影响的属性值总和。
                * 效果值M=0，属性值总和提示数字会显示0
            * T1=角色头顶弹字提示(受击帧)（影响目标=self），T6=攻击者头顶弹字提示(受击帧)（影响目标=atk），弹字时间与受击帧时间一致。
                * 效果值M=0，弹字提示数字会显示0
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

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect42 = {}

function BuffEffect42:create()
    return BuffEffect42.new():__init()
end

function BuffEffect42:__init()
    self.__isInit = false

    self.__calValueIsInit = false

    return self
end

function BuffEffect42:updateEffectValue()
    if self.__isInit == false then
        self.__attrName = self.__basicEffect:getEffectTypeParam()

        local args = string.split(self.__basicEffect:getArgsParam(), "#")

        self.__targetType = args[1]

        self.__calculatorId = args[2]

        self.__isInit = true
    end

    self.__value = BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage()
end

function BuffEffect42:makeEffectOnAdd()
    if self.__calValueIsInit == false then
        self:updateEffectValue()
        self.__calValueIsInit = true
    end

    self.__buff:registerMakeEffectListener(
        BUFF_CONSTANS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnAutoZhaoAttack,
        function(...)
            self:__onAutoZhaoAttack(...)
        end
    )
end

--@desc:击中时
--@author:Seven
--@time:2023-12-01 14:39:28
--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
--@oneAttackHitResult: [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
function BuffEffect42:__onAutoZhaoAttack(context, oneAttackHitResult)
    local target = context:getTarget()
    if target ~= self.__buff:getBuffOwner() then
        --@desc 该buff 只有作为受击者时才会生效
        return
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

        local originFinalValue = qiZhaoHurt:getPreMitigationQiDamage()

        local finalValue = math.ceil(originFinalValue * self.__value)

        FightUtil:printFormatLog(
            "BuffEffect42: owner=%s attrName=%s targetType=%s 实际气血伤害(免伤初期)=%s 比例=%s 效果值=%s",
            tostring(self.__buff:getBuffOwner():getAttr("name")),
            tostring(self.__attrName),
            tostring(self.__targetType),
            tostring(originFinalValue),
            tostring(self.__value),
            tostring(finalValue)
        )

        --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
        local effectModifier = BasicBuffEffectModifierAttr:create():initEffectHurt(self.__basicEffect:getId(), self.__attrName, finalValue, self.__buff:getBuffOwner():getId())

        if self.__targetType == "self" then
            effectModifier:doAttack(target)
            oneAttackHitResult:addTargetEffectModifierAttr(effectModifier)
        elseif self.__targetType == "atk" then
            effectModifier:doAttack(context:getAttacker())
            oneAttackHitResult:addAttackerEffectModifierAttr(effectModifier)
        end
    end
end

function BuffEffect42:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect42:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect42", {ABuffEffect}, BuffEffect42)
0000000000000000