--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
        **效果类型ID=301，普通招架成功，概率影响目标指定角色当前属性N点**

        * 效果触发节点：12=受被动招式攻击判定普通招架
        * 效果功能执行：角色受到被动招式组合攻击，组合内任意一次攻击的命中判定结果是普通招架，在被动招式组合攻击结束时，判断触发概率，概率成功则影响指定目标的指定当前属性N点。
            * 配置方式同 效果类型ID=300
        * 效果生效表现：同 效果类型ID=300
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
local BuffEffect301 = {}

function BuffEffect301:create()
    return BuffEffect301.new():__init()
end

function BuffEffect301:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect301:updateEffectValue()
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

function BuffEffect301:makeEffectOnAdd()
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

function BuffEffect301:makeEffectOnRemove()
end

--@context: [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
function BuffEffect301:__makeEffectOnAutoCombFinish(context)
    local attacker = context:getAttacker()

    local target = context:getTarget()

    if self.__buff:getBuffOwner() ~= target then
        --@desc 该效果只有作为目标时才触发
        return
    end

    local hasParry = false
    context:walkAllZhaoAttackInTheCombAttack(
        function(i, zhaoAttack)
            --@RefType [src.app.FightSystem.ZhaoAttacks.ABasicZhaoAttack#ABasicZhaoAttack]
            zhaoAttack = zhaoAttack
            if zhaoAttack:getHitType() == FightCommons.ATTACK_HIT_TYPE.PARRY then
                hasParry = true

                return true
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

function BuffEffect301:__trigger(target)
    --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
    local effectModifier = BasicBuffEffectModifierAttr:create():initEffectHurt(self.__basicEffect:getId(), self.__attrName, self.__calValue, self.__buff:getBuffOwner():getId())

    effectModifier:doAttack(target)

    return effectModifier
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect301:makeEffectOnTransfer(buffEffect)
end

return newClass("BuffEffect301", {ABuffEffect}, BuffEffect301)
000000000