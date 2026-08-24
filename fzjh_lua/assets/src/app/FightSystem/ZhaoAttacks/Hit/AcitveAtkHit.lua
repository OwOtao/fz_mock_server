--[[
    author:Seven
    time:2022-12-16 20:22:28
    desc: 主动招式攻击命中
]]
local newClass = require("third.class.NewClass")

local OneAttackHitResult = require("app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult")

local BasicAtkHit = require("app.FightSystem.ZhaoAttacks.Hit.BasicAtkHit")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE

--@SuperType [src.app.FightSystem.ZhaoAttacks.Hit.BasicAtkHit#BasicAtkHit]
local AcitveAtkHit = {}

function AcitveAtkHit:create(context, zhao)
    return AcitveAtkHit.new():__init(context, zhao)
end

function AcitveAtkHit:__init(context, zhao)
    --@RefType [src.app.FightSystem.BattleActions.AttackBattleAction.ActiveAttack.ActiveAttackContext#ActiveAttackContext]
    self.__context = context

    --@RefType [src.app.models.skill.BasicSkill.ActiveZhao.BasicActiveZhaoInfo#BasicActiveZhaoInfo]
    self.__zhao = zhao

    self:__initHitAttack()

    return self
end

--@desc: 执行一个
--@author:Seven
--@time:2023-02-09 14:59:56
function AcitveAtkHit:__doOneAttack()
    --@RefType [src.app.FightSystem.ZhaoAttacks.Hit.OneAttackHitResult#OneAttackHitResult]
    local attackResults = OneAttackHitResult:create()

    attackResults:setZhaoHurts(self:__initAndDoZhaoHurts())

    table.insert(self.__hitResults, attackResults)

    self.__context:getAttacker():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveZhaoAttack, self.__context, attackResults)

    self.__context:getTarget():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnActiveZhaoAttack, self.__context, attackResults)
end

--@desc: 创建并执行招式一击造成的数组
--@author:Seven
--@time:2023-02-09 14:37:46
function AcitveAtkHit:__initAndDoZhaoHurts()
    local zhaoHurts = {}

    local zhaoWeight = self.__zhao:getHurtWeight()
    local combTotalWeight = self.__context:getAttackComb():getCombAttackTotalWeight()
    local animWeight = self.__zhao:getAnimHurtWeightValue(self.__currAtkIndex)
    local animTotalWeight = self.__zhao:getTotalAnimHurtWeight()

    -- 主动招式与被动招式共用同一套分摊结算逻辑，只在 damageType 上分流。
    for _, combHurt in ipairs(self.__context:getCombHurts()) do
        --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
        combHurt = combHurt

        local atkHurt
        if combHurt:getAttrName() == "qi" then
            --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt#BasicQiAttackHurt]
            -- 主动招式统一按 damageType=2 进入新版气血减伤算法。
            local qiAtkHurt = require("app.FightSystem.CharacterHurt.AttackHurt.BasicQiAttackHurt"):create(2)
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

return newClass("AcitveAtkHit", {BasicAtkHit}, AcitveAtkHit)
0000000000000000