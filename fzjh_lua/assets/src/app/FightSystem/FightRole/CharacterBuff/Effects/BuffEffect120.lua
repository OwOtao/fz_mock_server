--[[
    author:Seven
    time:2023-03-16 12:07:45
    desc: 
    **效果类型ID=120，定次间隔影响角色当前属性比例N点**

    * 效果触发节点：3=被添加Buff、50=任意角色招式组合结束、51=僵持阶段定时触发
    * 效果功能执行：角色获得Buff时生效一次，根据间隔次数再次生效多次，生效时角色指定当前属性加或者减；战场上任意角色招式组合攻击结束算1个次数。
        * effectTypeParam配置影响的角色当前属性类型和间隔次数，格式：当前属性ID#生效间隔次数。
            * 当前属性ID：qi=当前气血、qiMax=当前气血上限、neili=当前内力、neiliMax=角色当前内力上限、tili=角色当前体力
        * argsParam配置的 `表[总Buff表效果伤害].id` 
        * 效果值 = (`表[总Buff表效果伤害].id` 对应返回结果值)x伤害属性修正系数，结果值不用做取整处理（效果120值最终结果的取整方式取决于`表[总Buff表效果伤害].computingRound`规则即可）
    * 效果生效表现：T5=角色头顶弹字提示(招式组合)、T3=界面战斗信息区新增描述文本
]]
local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightFormula = require("app.FightSystem.FightFormula")

local ABuffEffect = require("app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect")

--@RefType [src.app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory#BuffEffectDamageCalculatorFactory]
local BuffEffectDamageCalculatorFactory = require("app.FightSystem.FightRole.CharacterBuff.Buffs.BuffDamageCalculator.BuffEffectDamagCalculatorFactory")

local BasicBuffEffectModifierAttr = require("app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")

--@SuperType [src.app.FightSystem.FightRole.CharacterBuff.Effects.ABuffEffect#ABuffEffect]
local BuffEffect120 = {}

function BuffEffect120:create()
    return BuffEffect120.new():__init()
end

function BuffEffect120:__init()
    self.__isInit = false

    self.__isCalValueInit = false

    return self
end

function BuffEffect120:updateEffectValue()
    if self.__isInit == false then
        self:__initEffectParam()
        self.__isInit = true
    end
    local skillDamageAttrCorrectionFactor = 1
    if self.__damageClass ~= "0" then
        local owner = self.__buff:getBuffOwner()
        local target = owner:getTarget()
        skillDamageAttrCorrectionFactor = FightFormula:calSkillDamageAttrCorrectionFactor(owner, target, self.__damageClass)
    end

    self.__skillDamageAttrCorrectionFactor = skillDamageAttrCorrectionFactor

    -- 四舍五入取整 最小值为0
    self.__calValue = Helper:roundPreciseDecimal(BuffEffectDamageCalculatorFactory:create(self.__calculatorId, self.__buff):getDamage() * skillDamageAttrCorrectionFactor, 0)
end

function BuffEffect120:__initEffectParam()
    local effectTypeParams = string.split(self.__basicEffect:getEffectTypeParam(), "#")

    self.__attrName = effectTypeParams[1]

    self.__intervalCount = tonumber(effectTypeParams[2])

    if self.__attrName ~= "qi" then
        self.__damageClass = "0"
    else
        local damageClass = effectTypeParams[3]
        if damageClass == nil then
            self.__damageClass = "0"
        elseif tostring(damageClass) == "0" then
            self.__damageClass = "0"
        else
            self.__damageClass = tostring(damageClass)
        end
    end

    if self.__intervalCount == nil then
        error(" CharacterEffect120:initEffect() ： 间隔次数读取失败，" .. tostring(effectTypeParams[2]) .. " effectId :" .. self.__basicEffect:getEffectID())
    end

    self.__calculatorId = self.__basicEffect:getArgsParam()
end

function BuffEffect120:makeEffectOnAdd()
    if self.__isCalValueInit == false then
        self:updateEffectValue()
        self.__isCalValueInit = true
    end

    if self.__count == nil then
        self.__count = 0
    end

    self.__buff:getBuffContext():addBuffEffectHurt(self:__trigger())

    self.__buff:registerMakeEffectListener(
        BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE.OnAnyCombFinish,
        function(...)
            self:__makeEffectOnAnyCombFinish(...)
        end
    )
end

function BuffEffect120:__makeEffectOnAnyCombFinish(context)
    self.__count = self.__count + 1

    FightUtil:printFormatLog("BuffEffect120 角色 %s 触发计数，当前计数： ", self.__buff:getBuffOwner():getAttr("name"), self.__basicEffect:getEffectID(), self.__count)

    if self.__count == self.__intervalCount then
        local effectModifier = self:__trigger()

        context:addCharacterEffectModifierAttr(effectModifier)

        self.__count = 0
    end
end

function BuffEffect120:makeEffectOnRemove()
end

--@desc 被转移至新对象时调用
--@author:Seven
--@time:2023-11-28 18:11:03
--@buffEffect: [src.app.FightSystem.FightRole.CharacterBuff.Effects.IBuffEffect#IBuffEffect]
function BuffEffect120:makeEffectOnTransfer(buffEffect)
end

function BuffEffect120:__trigger()
    --@RefType [src.app.FightSystem.CharacterHurt.BuffEffectHurt.BasicBuffEffectModifierAttr#BasicBuffEffectModifierAttr]
    local effectModifier = BasicBuffEffectModifierAttr:create():initEffectHurt(self.__basicEffect:getId(), self.__attrName, self.__calValue, self.__buff:getBuffOwner():getId(), self.__damageClass)

    effectModifier:doAttack(self.__buff:getBuffOwner())

    FightUtil:printFormatLog(
        "CharacterEffect120 角色 %s 触发效果 %s ，影响属性 %s ，伤害属性修正系数 %s ，影响值 %s ",
        self.__buff:getBuffOwner():getAttr("name"),
        self.__basicEffect:getEffectID(),
        self.__attrName,
        self.__skillDamageAttrCorrectionFactor,
        self.__calValue
    )

    return effectModifier
end

function BuffEffect120:setEffectOnCount(count)
    self.__count = count
end

return newClass("BuffEffect120", {ABuffEffect}, BuffEffect120)
000000000000000