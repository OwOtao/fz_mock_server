local AutoZhaoFactory = require("app.FightSystem.Factory.FightSkillFactory.AutoZhaoFactory")

local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local AttackSound = require("app.FightSystem.AttackModel.AttackSound")

local AttackFactory = {}

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local FightFormula = require("app.FightSystem.FightFormula")

local CharacterDefaultConf = require("app.FightSystem.Configuration.CharacterDefaultConf")

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

local INFLUENCE_ATTACK_HIT_TYPE = FightCommons.INFLUENCE_ATTACK_HIT_TYPE

--@desc: 随机击中结果
--@author:Seven
--@time:2021-06-10 11:11:12
--@zhaoCombAttack: [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttackFactory:randomAutoZhaoAttackHitType(zhaoCombAttack, attacker, target)
    local randomHit = function(probability, min, max)
        if probability < min then
            return false
        end

        if probability >= max then
            return true
        end

        local rand = FightUtil:random(min, max)
        FightUtil:printLog("** AttackFactory __randomAttackHitType  ** 随机值：", rand, " , 范围值：[", min, " , ", probability, "]")
        if min <= rand and rand <= probability then
            return true
        end

        return false
    end

    --@region 轻功闪躲计算
    local dodgeProbability = -1

    if attacker:beInluenceByAttack(INFLUENCE_ATTACK_HIT_TYPE.ATTACKER_BE_DODGE) then
        dodgeProbability = 1 * 10000
    end

    if target:beInluenceByHit(INFLUENCE_ATTACK_HIT_TYPE.TARGET_BAN_DODGE) then
        dodgeProbability = 0
    end

    if dodgeProbability < 0 then
        dodgeProbability = FightFormula:calAutoZhaoDodgeProbability(zhaoCombAttack, attacker, target)
    end

    FightUtil:printLog("** AttackFactory __randomAttackHitType **", attacker:getAttr("name"), "  随机闪躲率 ：")
    if randomHit(dodgeProbability, 1, 10000) then
        FightUtil:printLog("** AttackFactory __randomAttackHitType ** 随机结果：轻功闪避")
        return ATTACK_HIT_TYPE.DODGE
    end
    --@endregion

    --@region 格挡概率计算
    local parryProbability = -1

    if attacker:beInluenceByAttack(INFLUENCE_ATTACK_HIT_TYPE.ATTACKER_BE_PARRY) then
        parryProbability = 1 * 10000
    end

    if target:beInluenceByHit(INFLUENCE_ATTACK_HIT_TYPE.TARGET_BAN_PARRY) then
        parryProbability = 0
    end

    if parryProbability < 0 then
        parryProbability = FightFormula:calAutoZhaoParryProbability(zhaoCombAttack, attacker, target)
    end

    FightUtil:printLog("** AttackFactory __randomAttackHitType **", attacker:getAttr("name"), "  随机普通招架 ：")
    if randomHit(parryProbability, 1, 10000) then
        FightUtil:printLog("** AttackFactory __randomAttackHitType ** 随机结果：普通招架")
        return ATTACK_HIT_TYPE.PARRY
    end
    --@endregion

    -- local parrySpecRate = attacker:getParrySpecial()
    -- if parrySpecRate > 0 then
    --     FightUtil:printLog("** AttackFactory __randomAttackHitType **", attacker:getAttr("name") , "  随机招架格挡 ：")
    --     if randomHit(parrySpecRate, 1, 100) then
    --         FightUtil:printLog("** AttackFactory __randomAttackHitType ** 随机结果：招架格挡")
    --         return ATTACK_HIT_TYPE.PARRY_SPEC
    --     end
    -- end

    -- local dodgeSpecialRate = attacker:getDodgeSpecial()
    -- if dodgeSpecialRate > 0 then
    --     FightUtil:printLog("** AttackFactory __randomAttackHitType **", attacker:getAttr("name") , "  随机轻功跳离 ：")
    --     if randomHit(dodgeSpecialRate, 1, 100) then
    --         FightUtil:printLog("** AttackFactory __randomAttackHitType ** 随机结果：轻功跳离")
    --         return ATTACK_HIT_TYPE.DODGE_SPC
    --     end
    -- end

    FightUtil:printLog("** AttackFactory __randomAttackHitType ** 随机结果：击中")
    return ATTACK_HIT_TYPE.HIT
end

--@desc: 创建攻击招式（即：攻击段）
--@author:Seven
--@time:2021-05-17 16:15:03
--@attackComb: [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
--@zhaoAttackIndex: 招索引
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@return [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack#IZhaoAttack]
function AttackFactory:createZhaoAtk(attackComb, zhaoAttackIndex, attacker, target, hitType)
    local zhao_atk
    if hitType == ATTACK_HIT_TYPE.NONE then
        zhao_atk = self:__initNoneAttack(attackComb, zhaoAttackIndex, attacker, target)
    elseif hitType == ATTACK_HIT_TYPE.HIT then
        zhao_atk = self:__initHitAttack(attackComb, zhaoAttackIndex, attacker, target)
    elseif hitType == ATTACK_HIT_TYPE.DODGE then
        -- elseif hitType == ATTACK_HIT_TYPE.DODGE_SPC then
        --     zhao_atk = self:__initDodgeSpecAttack(attackComb, zhaoAttackIndex, attacker, target)
        zhao_atk = self:__initDodgeAttack(attackComb, zhaoAttackIndex, attacker, target)
    elseif hitType == ATTACK_HIT_TYPE.PARRY then
        -- elseif hitType == ATTACK_HIT_TYPE.PARRY_SPEC then
        --     zhao_atk = self:__initParrySpecAttack(attackComb, zhaoAttackIndex, attacker, target)
        zhao_atk = self:__initParryAttack(attackComb, zhaoAttackIndex, attacker, target)
    else
        error("AttackFactory createZhaoAtk 创建一段攻击，攻击结果类型未定义")
    end

    return zhao_atk
end

function AttackFactory:__initNoneAttack(attackComb, zhaoAttackIndex, attacker, target)
    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    local zhaoInfo = attackComb:getZhaoInfo(zhaoAttackIndex)

    local animResId = zhaoInfo:getAnimResId()

    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    local attackAnims = require("app.FightSystem.AttackModel.AttackAnims"):create()

    local releaseAnimName
    local duration = 0
    if animResId ~= 0 then
        releaseAnimName = AnimResManager:getOtherAnimName(animResId)
        duration = AnimResManager:getAnimTime(releaseAnimName)
        attackAnims:setAttackerAnim(releaseAnimName)
    end

    attackAnims:setAttackerSoundId(AttackSound.getAttackSound(zhaoInfo, attacker))

    attackAnims:setAttackerSoundStart(zhaoInfo:getSoundStart())

    local zhao_atk = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkNone"):create()

    zhao_atk:setAttacker(attacker)

    zhao_atk:setTarget(target)

    zhao_atk:setZhaoInfo(zhaoInfo)

    zhao_atk:setAttackAnims(attackAnims)

    zhao_atk:setDuration(duration)

    return zhao_atk
end

--@desc: 生成击中
--@author:Seven
--@time:2021-07-06 18:11:07
--@attackComb: [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
--@zhaoAttackIndex: 招式信息索引
--@attacker:[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target:[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@return
function AttackFactory:__initHitAttack(attackComb, zhaoAttackIndex, attacker, target)
    error("击中的对象使用 AtkHitBuilder ，该方法不应调用。")
end

--@attackComb: [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target:  [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttackFactory:__initDodgeAttack(attackComb, zhaoAttackIndex, attacker, target)
    local zhaoInfo = attackComb:getZhaoInfo(zhaoAttackIndex)

    local atk_weapon = attacker:getWeapon()

    local attackAnimName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atk_weapon:getWeaponModule())

    --@desc 动画事件
    local attackEvents = AnimResManager:getAnimHurtEvents(attackAnimName)

    local hitPos = attackEvents[1].stringValue

    local target_dodgeSkill = target:getDodgeSkill()

    local dodgeClass = target_dodgeSkill:getDodgeClass(hitPos)

    local moveBackOffset = dodgeClass:getOffsetNormal()

    local moveBackDuration = 5 / 30

    local startMoveBackTime = 7 / 30

    local returnDuration = 5 / 30

    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    local attackAnims = require("app.FightSystem.AttackModel.AttackAnims"):create()

    attackAnims:setAttackerAnim(attackAnimName)

    attackAnims:setAttackerSoundId(AttackSound.getAttackSound(zhaoInfo, attacker))

    attackAnims:setAttackerSoundStart(zhaoInfo:getSoundStart())

    attackAnims:addTargetAnimAndSound(hitPos, AnimResManager:getOtherAnimName(dodgeClass:getActionNormal()), dodgeClass:getSoundNormal())

    --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkDodge#AtkDodge]
    local zhao_atk = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkDodge"):create()

    zhao_atk:setAttacker(attacker)

    zhao_atk:setTarget(target)

    zhao_atk:setZhaoInfo(zhaoInfo)

    zhao_atk:setAttackAnims(attackAnims)

    zhao_atk:setMoveBackOffset(moveBackOffset)

    zhao_atk:setMoveBackDuration(moveBackDuration)

    zhao_atk:setStartMoveBackTime(startMoveBackTime)

    zhao_atk:setReturnDuration(returnDuration)

    return zhao_atk
end

--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target:  [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttackFactory:__initDodgeSpecAttack(attackComb, zhaoAttackIndex, attacker, target)
    local zhaoInfo = attackComb:getZhaoInfo(zhaoAttackIndex)

    local atk_weapon = attacker:getWeapon()

    local attackAnimName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atk_weapon:getWeaponModule())

    --@desc 动画事件
    local attackEvents = AnimResManager:getAnimHurtEvents(attackAnimName)

    local hitPos = attackEvents[1].stringValue

    local target_dodgeSkill = target:getDodgeSkill()

    local dodgeClass = target_dodgeSkill:getDodgeClass(hitPos)

    local moveBackOffset = dodgeClass:getOffsetSpecial()

    local moveBackDuration = 5 / 30

    local startMoveBackTime = 7 / 30

    local returnDuration = 5 / 30

    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    local attackAnims = require("app.FightSystem.AttackModel.AttackAnims"):create()

    attackAnims:setAttackerAnim(attackAnimName)

    attackAnims:setAttackerSoundId(AttackSound.getAttackSound(zhaoInfo, attacker))

    attackAnims:setAttackerSoundStart(zhaoInfo:getSoundStart())

    attackAnims:addTargetAnimAndSound(hitPos, AnimResManager:getOtherAnimName(dodgeClass:getActionSpecial()), dodgeClass:getSoundSpecial())

    --@desc src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkDodgeSpec#AtkDodgeSpec
    local zhao_atk = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkDodgeSpec"):create()

    zhao_atk:setAttacker(attacker)

    zhao_atk:setTarget(target)

    zhao_atk:setZhaoInfo(zhaoInfo)

    zhao_atk:setAttackAnims(attackAnims)

    zhao_atk:setMoveBackOffset(moveBackOffset)

    zhao_atk:setMoveBackDuration(moveBackDuration)

    zhao_atk:setStartMoveBackTime(startMoveBackTime)

    zhao_atk:setReturnDuration(returnDuration)

    return zhao_atk
end

--@attackComb: [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target:  [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttackFactory:__initParryAttack(attackComb, zhaoAttackIndex, attacker, target)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.CombAttack#CombAttack]
    local combAttack = require("app.FightSystem.FightRole.AttackSystem.AttackModel.CombAttack"):create()

    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    local zhaoInfo = attackComb:getZhaoInfo(zhaoAttackIndex)

    combAttack:setId(zhaoInfo:getId())

    combAttack:setCombTotalWeight(attackComb:getCombHurtTotalWeight())

    combAttack:setCombProjectedDamages(attackComb:getCombProjectedDamages())

    combAttack:setAnimHurtTimes(zhaoInfo:getAnimHurtTimes())

    combAttack:setAnimHurtWeightArray(zhaoInfo:getAnimHurtWeight())

    combAttack:setZhaoAllocWeight(zhaoInfo:getHurtWeight())

    local atk_weapon = attacker:getWeapon()

    local attackAnimName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atk_weapon:getWeaponModule())

    local duration = AnimResManager:getAnimTime(attackAnimName)

    local target_parrySkill = attacker:getParrySkill()

    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    local attackAnims = require("app.FightSystem.AttackModel.AttackAnims"):create()

    attackAnims:setAttackerAnim(attackAnimName)

    attackAnims:setAttackerSoundId(AttackSound.getAttackSound(zhaoInfo, attacker))

    attackAnims:setAttackerSoundStart(zhaoInfo:getSoundStart())

    local parryClasses = target:getParrySkill():getParryClasses()
    for hitPos, parryClassList in pairs(parryClasses) do
        if #parryClassList > 0 then
            for _, parryClass in ipairs(parryClassList) do
                local animName = AnimResManager:getOtherAnimName(parryClass:getActionNormal())
                attackAnims:addTargetAnimAndSound(hitPos, animName, parryClass:getSoundNormal())
            end
        end
    end

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkParry#AtkParry]
    local zhao_atk = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkParry"):create()

    zhao_atk:setAttacker(attacker)

    zhao_atk:setTarget(target)

    zhao_atk:setCombAttack(combAttack)

    zhao_atk:setAttackAnims(attackAnims)

    zhao_atk:setDuration(duration)

    local ZhaoAttackAttrsEffectArray = require("app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray")

    zhao_atk:setZhaoEffectAttrsForAttacker(ZhaoAttackAttrsEffectArray:create())

    zhao_atk:setZhaoEffectAttrsForTarget(ZhaoAttackAttrsEffectArray:create())

    zhao_atk:initAttack()

    return zhao_atk
end

--@attackComb: [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target:  [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AttackFactory:__initParrySpecAttack(attackComb, zhaoAttackIndex, attacker, target)
    --@RefType [src.app.FightSystem.FightSkill.ZhaoInfo#ZhaoInfo]
    local zhaoInfo = attackComb:getZhaoInfo(zhaoAttackIndex)

    local atk_weapon = attacker:getWeapon()

    local attackAnimName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atk_weapon:getWeaponModule())

    --@desc 动画事件
    local attackEvents = AnimResManager:getAnimHurtEvents(attackAnimName)

    local hitPos = attackEvents[1].stringValue

    local firstHitTime = attackEvents[1].time

    local target_parrySkill = attacker:getParrySkill()

    local parryClass = target_parrySkill:getParryClass(hitPos)

    local parryAninName = AnimResManager:getOtherAnimName(parryClass:getActionSpecial())

    local moveBackOffset = parryClass:getOffsetSpecial()

    local moveBackDuration = 0
    local returnDuration = 0
    if moveBackOffset > 0 then
        moveBackDuration = 5 / 30
        returnDuration = 5 / 30
    end

    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    local attackAnims = require("app.FightSystem.AttackModel.AttackAnims"):create()

    attackAnims:setAttackerAnim(attackAnimName)

    attackAnims:setAttackerSoundId(AttackSound.getAttackSound(zhaoInfo, attacker))

    attackAnims:setAttackerSoundStart(zhaoInfo:getSoundStart())

    attackAnims:addTargetAnimAndSound(hitPos, AnimResManager:getOtherAnimName(parryClass:getActionSpecial()), parryClass:getSoundSpecial())

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkParrySpec#AtkParrySpec]
    local zhao_atk = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.AtkParrySpec"):create()

    zhao_atk:setAttacker(attacker)

    zhao_atk:setTarget(target)

    zhao_atk:setZhaoInfo(zhaoInfo)

    zhao_atk:setAttackAnims(attackAnims)

    zhao_atk:setMoveBackOffset(moveBackOffset)

    zhao_atk:setMoveBackDuration(moveBackDuration)

    zhao_atk:setFirstHitTime(firstHitTime)

    zhao_atk:setReturnDuration(returnDuration)

    zhao_atk:setHitPos(hitPos)

    return zhao_atk
end

return AttackFactory
00000000000