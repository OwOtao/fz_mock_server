--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    **效果类型ID=300，普通闪躲成功，概率影响目标指定角色当前属性N点**

    * 效果触发节点：11=受被动招式攻击判定轻功闪躲
    * 效果功能执行：角色受到被动招式组合攻击，组合内任意一次攻击的命中判定结果是普通闪躲，在被动招式组合攻击结束时，判断触发概率，概率成功则影响指定目标的指定当前属性N点。
        * 由于只判断被动招式组合第一个招式动作的命中判定，可以认为一个被动招式组合只会触发一次。
        * effectTypeParam配置指定目标类型和影响属性类型，格式：影响属性类型。
            * 影响属性类型：qi=当前气血、qiMax=当前气血上限、neili=当前内力
        * argsParam配置格式：影响目标#效果伤害ID#生效概率
            * 影响目标：自身=self、攻击者=atk
            * 效果伤害ID：ID读取 总Buff表效果伤害.xlsx 的 id，计算出的公式返回结果值，就是效果值N点
            * 生效概率：配置范围1~100，可以调用Buff传入的动态参数
    * 效果生效表现：
        * T5=角色头顶弹字提示(招式组合)（影响目标头顶）。
            * 弹字时间：效果生效，在被动招式组合攻击结束时显示弹字。
            * 效果值M=0，弹字提示数字会显示0
        * T3=界面战斗信息区新增描述文本，在被动招式组合攻击结束，显示本次招式组合攻击实际影响的属性值总和。
            * 效果值M=0，属性值总和提示数字会显示0
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
local BuffEffect300 = {}

function BuffEffect300:create()
    return BuffEffect300.new():__init()
end

function BuffEffect300:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect300:updateEffectValue()
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

function BuffEffect300:makeEffectOnAdd()
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

function BuffEffect300:makeEffectOnRemove()
end

--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
function BuffEffect300:__makeEffectOnAutoCombFinish(context)
    local attacker = context:getAttacker()

    local target = context:getTarget()

    if self.__buff:getBuffOwner() ~= target then
        --@desc 该效果只有作为目标时才触发
        return
    end

    local hasDodge = false
    context:walkAllZhaoAttackInTheCombAttack(
        function(i, zhaoAttack)
            --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
            zhaoAttack = zhaoAttack
            if zhaoAttack:getHitType() == FightCommons.ATTACK_HIT_TYPE.DODGE then
                hasDodge = true

                return true
            end

            return false
        end
    )

    if not hasDodge then
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

function BuffEffect300:__trigger(target)
    --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
    local effectModifier = BasicBuffEffectModifierAttr:create():initEffectHurt(self.__basicEffect:getId(), self.__attrName, self.__calValue, self.__buff:getBuffOwner():getId())

    effectModifier:doAttack(target)

    return effectModifier
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect300:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect300", {ABuffEffect}, BuffEffect300)
00000000000