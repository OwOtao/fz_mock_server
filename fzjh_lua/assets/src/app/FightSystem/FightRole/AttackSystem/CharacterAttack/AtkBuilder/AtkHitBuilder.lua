local newClass = require("third.class.NewClass")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")

local AttackSound = require("app.FightSystem.AttackModel.AttackSound")

local AtkHitBuilder = {}

function AtkHitBuilder:create(builderParams)
    local p = AtkHitBuilder.new()

    p:__init(builderParams)

    return p
end

function AtkHitBuilder:__init(builderParams)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.HitBuilderParams#HitBuilderParams]
    self.__builderParams = builderParams

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.NewAtkHit#NewAtkHit]
    self.__zhao_atk = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.NewAtkHit"):create()
end

function AtkHitBuilder:__buildIdentity()
    self.__zhao_atk:setAttacker(self.__builderParams:getAttacker())

    self.__zhao_atk:setTarget(self.__builderParams:getTarget())
end

-- function AtkHitBuilder:__buildZhaoInfo()
--     local index = self.__builderParams:getZhaoAttackIndex()
--     --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
--     local zhaoInfo = self.__builderParams:getAttackComb():getZhaoInfo(index)
--     self.__zhao_atk:setZhaoInfo(zhaoInfo)
-- end

--@desc: 一次性特效生成
--@author:Seven
--@time:2022-08-16 15:43:48
--@attackAnims: [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
function AtkHitBuilder:__buildOneOffeffects(attackAnims)
    local oneOffEffects = self.__builderParams:getOneOffEffect()

    if table.getn(oneOffEffects) > 0 then
        for _, v in ipairs(oneOffEffects) do
            attackAnims:addOneOffEffectAnimName(v.eventName, v.targetId, v.animName)
        end
    end
end

function AtkHitBuilder:__buildAttackAnimsAndDuration()
    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    local attackAnims = require("app.FightSystem.AttackModel.AttackAnims"):create()

    local attacker = self.__builderParams:getAttacker()

    local target = self.__builderParams:getTarget()

    local atk_weapon = attacker:getWeapon()

    local index = self.__builderParams:getZhaoAttackIndex()

    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    local zhaoInfo = self.__builderParams:getAttackComb():getZhaoInfo(index)

    local attackAnimName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atk_weapon:getWeaponModule())

    attackAnims:setAttackerAnim(attackAnimName)

    attackAnims:setAttackerSoundId(AttackSound.getAttackSound(zhaoInfo,attacker))

    attackAnims:setAttackerSoundStart(zhaoInfo:getSoundStart())

    local duration = AnimResManager:getAnimTime(attackAnimName)

    local buffSys = attacker:getBuffSystem()

    local hurtExpression = buffSys:getRoleHurtExpression(attacker:getId())

    local HIT_POS = FightCommons.HIT_POS

    if hurtExpression == 0 then
        local hurtSoundId = CharacterDefaultConf:getHurtSoundId(target:getSpecies())
        attackAnims:addTargetAnimAndSound(HIT_POS.CHEST, CharacterDefaultConf:getHurtAnim(target:getSpecies(), HIT_POS.CHEST), hurtSoundId)
        attackAnims:addTargetAnimAndSound(HIT_POS.FOOT, CharacterDefaultConf:getHurtAnim(target:getSpecies(), HIT_POS.FOOT), hurtSoundId)
        attackAnims:addTargetAnimAndSound(HIT_POS.HEAD, CharacterDefaultConf:getHurtAnim(target:getSpecies(), HIT_POS.HEAD), hurtSoundId)
    elseif hurtExpression == 1 then
        local hurtSoundId = CharacterDefaultConf:getHurtSoundId(target:getSpecies())
        local parryClasses = target:getParrySkill():getParryClasses()
        for hitPos, parryClassList in pairs(parryClasses) do
            if #parryClassList > 0 then
                for _, parryClass in ipairs(parryClassList) do
                    local animName = AnimResManager:getOtherAnimName(parryClass:getActionNormal())
                    attackAnims:addTargetAnimAndSound(hitPos, animName, hurtSoundId)
                end
            end
        end
    elseif hurtExpression == 2 then
        --@desc 闪避动画
        local dodgeClasses = target:getDodgeSkill():getDodgeClasses()
        for hitPos, dodgeClassList in pairs(dodgeClasses) do
            if #dodgeClassList > 0 then
                for _, dodgeClass in ipairs(dodgeClassList) do
                    local animName = AnimResManager:getOtherAnimName(dodgeClass:getActionNormal())
                    attackAnims:addTargetAnimAndSound(hitPos, animName, hurtSoundId)
                end
            end
        end
    end

    self:__buildOneOffeffects(attackAnims)

    self.__zhao_atk:setAttackAnims(attackAnims)

    self.__zhao_atk:setDuration(duration)
end

function AtkHitBuilder:__buildCombAttack()
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.CombAttack#CombAttack]
    local combAttack = require("app.FightSystem.FightRole.AttackSystem.AttackModel.CombAttack"):create()

    local zhaoComb = self.__builderParams:getAttackComb()

    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    local zhaoInfo = zhaoComb:getZhaoInfo(self.__builderParams:getZhaoAttackIndex())

    combAttack:setId(zhaoInfo:getId())

    combAttack:setCombTotalWeight(zhaoComb:getCombHurtTotalWeight())

    combAttack:setCombProjectedDamages(zhaoComb:getCombProjectedDamages())

    combAttack:setAnimHurtTimes(zhaoInfo:getAnimHurtTimes())

    combAttack:setAnimHurtWeightArray(zhaoInfo:getAnimHurtWeight())

    combAttack:setZhaoAllocWeight(zhaoInfo:getHurtWeight())

    self.__zhao_atk:setCombAttack(combAttack)
end

function AtkHitBuilder:__buildAttackerZhaoEffectAttrs()
    error("AtkHitBuilder:__buildAttackerZhaoEffectAttrs 该方法不可直接调用，击中结果生成需重写该方法。")
end

function AtkHitBuilder:__buildTargetZhaoEffectAttrs()
    error("AtkHitBuilder:__buildTargetZhaoEffectAttrs 该方法不可直接调用，击中结果生成需重写该方法。")
end

function AtkHitBuilder:build()
    self:__buildIdentity()

    self:__buildCombAttack()

    self:__buildAttackAnimsAndDuration()

    self:__buildAttackerZhaoEffectAttrs()

    self:__buildTargetZhaoEffectAttrs()

    self.__zhao_atk:initAttack()

    return self.__zhao_atk
end

return newClass("AtkHitBuilder", {}, AtkHitBuilder)
0000000000000000