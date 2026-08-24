--[[
    author:Seven
    time:2022-12-16 20:22:19
    desc: 被动招式攻击命中
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local OneAttackHitResult = require("app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE

local BasicAtkHit = require("app.FightSystem.ZhaoAttacks.Hit.BasicAtkHit")

--@SuperType [src.app.FightSystem.ZhaoAttacks.Hit.BasicAtkHit#BasicAtkHit]
local AutoAtkHit = {}

function AutoAtkHit:create(context, zhao)
    return AutoAtkHit.new():__init(context, zhao)
end

function AutoAtkHit:__init(context, zhao)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.AutoAttack.AutoAttackContext#AutoAttackContext]
    self.__context = context

    --@RefType [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoInfo#BasicAutoZhaoInfo]
    self.__zhao = zhao

    self:__initHitAttack()

    return self
end

--@desc: 执行一个
--@author:Seven
--@time:2023-02-09 14:59:56
function AutoAtkHit:__doOneAttack()
    --@RefType [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
    local oneAttackResult = OneAttackHitResult:create()

    oneAttackResult:setZhaoHurts(self:__initAndDoZhaoHurts())

    table.insert(self.__hitResults, oneAttackResult)

    self.__context:getAttacker():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoAttack, self.__context, oneAttackResult)

    self.__context:getTarget():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoAttack, self.__context, oneAttackResult)
end

--@desc: 创建并执行招式一击造成的数组
--@author:Seven
--@time:2023-02-09 14:37:46
function AutoAtkHit:__initAndDoZhaoHurts()
    local zhaoHurts = {}

    local zhaoWeight = self.__zhao:getHurtWeight()
    local combTotalWeight = self.__context:getAttackComb():getCombAttackTotalWeight()
    local animWeight = self.__zhao:getAnimHurtWeightValue(self.__currAtkIndex)
    local animTotalWeight = self.__zhao:getTotalAnimHurtWeight()

    -- 同一受击帧下，所有属性伤害都按统一分摊权重实例化并立即结算。
    for _, combHurt in ipairs(self.__context:getCombHurts()) do
        --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
        combHurt = combHurt

        local atkHurt
        if combHurt:getAttrName() == "qi" then
            -- 被动招式统一按 damageType=1 进入新版气血减伤算法。
            --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
            local qiAtkHurt = require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt"):create(1)
            qiAtkHurt:setCombHurt(combHurt)
            qiAtkHurt:setZhaoWeight(zhaoWeight)
            qiAtkHurt:setCombTotalWeight(combTotalWeight)
            qiAtkHurt:setAnimWeight(animWeight)
            qiAtkHurt:setAnimTotalWeight(animTotalWeight)
            qiAtkHurt:initHurt()
            table.insert(zhaoHurts, qiAtkHurt)
            atkHurt = qiAtkHurt
        else
            --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.BasicAttrAttackHurt#BasicAttrAttackHurt]
            local otherHurt = require("app.FightSystem.CharacterHurt.AttackHurt.BasicAttrAttackHurt"):create()
            otherHurt:setCombHurt(combHurt)
            otherHurt:setZhaoWeight(zhaoWeight)
            otherHurt:setCombTotalWeight(combTotalWeight)
            otherHurt:setAnimWeight(animWeight)
            otherHurt:setAnimTotalWeight(animTotalWeight)
            otherHurt:initHurt()
            table.insert(zhaoHurts, otherHurt)
            atkHurt = otherHurt
        end

        atkHurt:inAttack(self.__context:getAttacker(), self.__context:getTarget())
    end

    return zhaoHurts
end

return newClass("AutoAtkHit", {BasicAtkHit}, AutoAtkHit)
000000000