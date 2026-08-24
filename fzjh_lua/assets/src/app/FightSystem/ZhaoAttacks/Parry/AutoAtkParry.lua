--[[
    author:Seven
    time:2023-02-17 15:00:37
    desc:被动招式攻击格挡
]]
local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local OneAttackParryResult = require("app.FightSystem.ZhaoAttacks.Parry.OneAttackParryResult")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

--@RefType [Constants]
local BUFF_CONSTANTS = require("app.FightSystem.FightBuff.Constants")
local BUFF_EFFECT_ON_TYPE = BUFF_CONSTANTS.BUFF_MAKE_EFFECT_ON_NODE_TYPE

local BasicAtkParry = require("app.FightSystem.ZhaoAttacks.Parry.BasicAtkParry")

--@SuperType [src.app.FightSystem.ZhaoAttacks.Parry.BasicAtkParry#BasicAtkParry]
local AutoAtkParry = {}

function AutoAtkParry:create(context, zhao)
    return AutoAtkParry.new():__init(context, zhao)
end

function AutoAtkParry:__init(context, zhao)
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
function AutoAtkParry:__doOneAttack()
    --@RefType
    local attackResults = OneAttackParryResult:create()

    attackResults:setZhaoHurts(self:__initAndDoZhaoHurts())

    table.insert(self.__hitResults, attackResults)

    self.__context:getAttacker():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoAttack, self.__context, attackResults)

    self.__context:getTarget():makeBuffEffectOn(BUFF_EFFECT_ON_TYPE.OnAutoZhaoAttack, self.__context, attackResults)
end

--@desc: 创建并执行招式一击造成的数组
--@author:Seven
--@time:2023-02-09 14:37:46
function AutoAtkParry:__initAndDoZhaoHurts()
    local zhaoHurts = {}

    local zhaoWeight = self.__zhao:getHurtWeight()
    local combTotalWeight = self.__context:getAttackComb():getCombAttackTotalWeight()
    local animWeight = self.__zhao:getAnimHurtWeightValue(self.__currAtkIndex)
    local animTotalWeight = self.__zhao:getTotalAnimHurtWeight()

    -- 招架场景只改初始气血伤害，后续减伤与明细仍复用统一算法。
    for _, combHurt in ipairs(self.__context:getCombHurts()) do
        --@RefType [src.app.FightSystem.CharacterHurt.BasicHurt#BasicHurt]
        combHurt = combHurt

        local atkHurt
        if combHurt:getAttrName() == "qi" then
            -- 招架后的气血伤害仍沿用被动减伤配置，因此这里继续传 damageType=1。
            --@RefType [src.app.FightSystem.CharacterHurt.AttackHurt.ParryQiAttackHurt#ParryQiAttackHurt]
            local qiAtkHurt = require("app.FightSystem.CharacterHurt.AttackHurt.ParryQiAttackHurt"):create(1)
            qiAtkHurt:setCombHurt(combHurt)
            qiAtkHurt:setParryQiHurtFactor(self.__context:getAttacker():getAttr("parryqiHurtFactor"))
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

return newClass("AutoAtkParry", {BasicAtkParry}, AutoAtkParry)
00000000000000