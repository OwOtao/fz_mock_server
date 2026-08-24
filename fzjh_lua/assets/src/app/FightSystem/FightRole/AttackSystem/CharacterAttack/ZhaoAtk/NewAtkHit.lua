local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

local QiHitDamageProperty = require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty")

local DamageProperty = require("app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty")

local EffectChangeAttrByQiHitDamage = require("app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage")

local NewAtkHit = {
    __hurtType = ATTACK_HIT_TYPE.HIT,
    --@desc 存放根据动画击中次数分配后的招式伤害数组[[damage,damage],[damage,damage]]
    __zhaoDamagesByHit = {},
    __attackerEffectChangeAttrByHit = {},
    __targetEffectChangeAttrByHit = {}
}

function NewAtkHit:create()
    return NewAtkHit.new()
end

function NewAtkHit:getHurtType()
    return self.__hurtType
end

function NewAtkHit:setAttacker(attacker)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__attacker = attacker
end

function NewAtkHit:setTarget(target)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__target = target
end

--@desc: 攻击招式相关信息
--@author:Seven
--@time:2022-01-04 15:41:46
--@combAttack: [src.app.FightSystem.FightRole.AttackSystem.AttackModel.CombAttack#CombAttack]
function NewAtkHit:setCombAttack(combAttack)
    self.__combAttack = combAttack
end

function NewAtkHit:setAttackAnims(attackAnims)
    --@RefType [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
    self.__attackAnims = attackAnims
end

--@return [src.app.FightSystem.AttackModel.AttackAnims#AttackAnims]
function NewAtkHit:getAttackAnims()
    return self.__attackAnims
end

function NewAtkHit:setDuration(duration)
    self.__duration = duration
end

function NewAtkHit:getDuration()
    return self.__duration
end

function NewAtkHit:getAnimHurtTimes()
    return self.__combAttack:getAnimHurtTimes()
end

--@desc 攻击者攻击时buff的影响
function NewAtkHit:setZhaoEffectAttrsForAttacker(array)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    self.__attackerEffectAttrsArray = array
end

function NewAtkHit:setZhaoEffectAttrsForTarget(array)
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]
    self.__targetEffectAttrsArray = array
end

--@desc: 招式伤害按照动画击中次数分配
--@author:Seven
--@time:2022-01-04 16:16:03
function NewAtkHit:__allocZhaoDamages()
    local combProjectedDamages = self.__combAttack:getCombProjectedDamages()

    local animHitCount = self.__combAttack:getAnimHurtTimes()

    if animHitCount <= 0 then
        error(string.format("NewAtkHit:__allocZhaoDamages 招式(%s)配置动画击中次数为0，无法分配。", self.__combAttack:getId()))
    end

    for i = 1, animHitCount do
        local hitDamages = {}
        for _, damageInfo in ipairs(combProjectedDamages) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.ADamageProperty#ADamageProperty]
            local damageProperty = nil

            if damageInfo.attrName == "qi" then
                local factory = damageInfo.factoryClass:create()
                factory:setDamagePropertyClass(require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty"))

                factory:setQiShield(self.__qiDamageShield)

                factory:setReduceEffectMap(self.__target:getBuffSystem():getDamageReductionValueMap(self.__target:getId()))

                factory:setDamageDescType(damageInfo.damageTypeStr)

                factory:setCanBeAbsorbByShield(damageInfo.canBeAbsorbByShield)

                factory:setProjectedValue(damageInfo.value)

                factory:setCombTotalWeight(self.__combAttack:getCombTotalWeight())

                factory:setZhaoAllocWeight(self.__combAttack:getZhaoAllocWeight())

                factory:setAnimHitAllocWeight(self.__combAttack:getAnimHurtAllocWeight(i))

                factory:setAnimHurtTotalWeight(self.__combAttack:getAnimHurtTotalWeight())

                damageProperty = factory:getDamageProperty()
            else
                damageProperty = DamageProperty:create()
                damageProperty:setAttrName(damageInfo.attrName)
                damageProperty:setDamageDescType(damageInfo.damageTypeStr)
                damageProperty:setProjectedValue(damageInfo.value)
                damageProperty:setCombTotalWeight(self.__combAttack:getCombTotalWeight())
                damageProperty:setZhaoAllocWeight(self.__combAttack:getZhaoAllocWeight())
                damageProperty:setAnimHitAllocWeight(self.__combAttack:getAnimHurtAllocWeight(i))
                damageProperty:setAnimHurtTotalWeight(self.__combAttack:getAnimHurtTotalWeight())
                damageProperty:calActualValue()
            end

            table.insert(hitDamages, damageProperty)
        end

        table.insert(self.__zhaoDamagesByHit, hitDamages)
    end
end

function NewAtkHit:__initEffectChangeByQiDamageOfHit()
    local animHitCount = self.__combAttack:getAnimHurtTimes()
    if animHitCount <= 0 then
        error("NewAtkHit:__initEffectChangeByQiDamageOfHit 招式配置动画击中次数为0，无法分配。")
    end

    for i = 1, animHitCount do
        table.insert(self.__attackerEffectChangeAttrByHit, i, {})
        table.insert(self.__targetEffectChangeAttrByHit, i, {})
    end
end

function NewAtkHit:__allocAttackerEffectCauseByQiProjectedDamage()
    local effectCount = self.__attackerEffectAttrsArray:getCount()

    if effectCount <= 0 then
        return
    end

    local animHitCount = self.__combAttack:getAnimHurtTimes()

    if animHitCount <= 0 then
        error("NewAtkHit:__allocAttackerEffectCauseByQiProjectedDamage 招式配置动画击中次数为0，无法分配。")
    end

    for i = 1, animHitCount do
        local zhaoHitDamage = self:getZhaoHitDamagesByHitIndex(i)

        local qiDamages = {}

        local effectChangeAttrsByHit = {}

        for _, damageProperty in ipairs(zhaoHitDamage) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
            damageProperty = damageProperty
            if damageProperty:getAttrName() == "qi" then
                table.insert(qiDamages, damageProperty)
            end
        end

        for _, qiDamageProperty in ipairs(qiDamages) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
            qiDamageProperty = qiDamageProperty
            for j = 1, effectCount do
                --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                local zhaoAttackAttrsEffect = self.__attackerEffectAttrsArray:get(j)

                --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
                local effectChangeAttrDamage = EffectChangeAttrByQiHitDamage:create()

                effectChangeAttrDamage:setChangeAttrName(zhaoAttackAttrsEffect:getAttrName())

                effectChangeAttrDamage:setQiDamageProjectedValue(qiDamageProperty:getProjectedValue())

                effectChangeAttrDamage:setPercent(zhaoAttackAttrsEffect:getValue())

                effectChangeAttrDamage:setOwnerId(zhaoAttackAttrsEffect:getOwnerId())

                effectChangeAttrDamage:setEffectFuncId(zhaoAttackAttrsEffect:getEffectFuncId())

                local targetType = zhaoAttackAttrsEffect:getTargetType()

                effectChangeAttrDamage:calActualValue()

                if targetType == "self" then
                    effectChangeAttrDamage:setTargetId(self.__attacker:getId())
                    table.insert(self.__attackerEffectChangeAttrByHit[i], effectChangeAttrDamage)
                elseif targetType == "def" then
                    effectChangeAttrDamage:setTargetId(self.__target:getId())
                    table.insert(self.__targetEffectChangeAttrByHit[i], effectChangeAttrDamage)
                else
                    error(' NewAtkHit:__allocAttackerEffectCauseByQiProjectedDamage 不应该存在目标类型是 "self" 和 "atk" 外的类型，请检查代码。传入值：' .. targetType)
                end
            end
        end
    end
end

function NewAtkHit:__allocTargetEffectCauseByQiProjectedDamage()
    local effectCount = self.__targetEffectAttrsArray:getCount()

    if effectCount <= 0 then
        return
    end

    local animHitCount = self.__combAttack:getAnimHurtTimes()

    if animHitCount <= 0 then
        error("NewAtkHit:__allocTargetEffectCauseByQiProjectedDamage 招式配置动画击中次数为0，无法分配。")
    end

    for i = 1, animHitCount do
        local zhaoHitDamage = self:getZhaoHitDamagesByHitIndex(i)

        local qiDamages = {}

        local effectChangeAttrsByHit = {}

        for _, damageProperty in ipairs(zhaoHitDamage) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
            damageProperty = damageProperty
            if damageProperty:getAttrName() == "qi" then
                table.insert(qiDamages, damageProperty)
            end
        end

        for _, qiDamageProperty in ipairs(qiDamages) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QiHitDamageProperty#QiHitDamageProperty]
            qiDamageProperty = qiDamageProperty
            for j = 1, effectCount do
                --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffect#ZhaoAttackAttrsEffect]
                local zhaoAttackAttrsEffect = self.__targetEffectAttrsArray:get(j)

                --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
                local effectChangeAttrDamage = EffectChangeAttrByQiHitDamage:create()

                effectChangeAttrDamage:setChangeAttrName(zhaoAttackAttrsEffect:getAttrName())

                effectChangeAttrDamage:setQiDamageProjectedValue(qiDamageProperty:getProjectedValue())

                effectChangeAttrDamage:setPercent(zhaoAttackAttrsEffect:getValue())

                effectChangeAttrDamage:setOwnerId(zhaoAttackAttrsEffect:getOwnerId())

                effectChangeAttrDamage:setEffectFuncId(zhaoAttackAttrsEffect:getEffectFuncId())

                local targetType = zhaoAttackAttrsEffect:getTargetType()

                effectChangeAttrDamage:calActualValue()

                if targetType == "self" then
                    effectChangeAttrDamage:setTargetId(self.__target:getId())
                    table.insert(self.__targetEffectChangeAttrByHit[i], effectChangeAttrDamage)
                elseif targetType == "atk" then
                    effectChangeAttrDamage:setTargetId(self.__attacker:getId())
                    table.insert(self.__attackerEffectChangeAttrByHit[i], effectChangeAttrDamage)
                else
                    error(' NewAtkHit:__allocTargetEffectCauseByQiProjectedDamage 不应该存在目标类型是 "self" 和 "atk" 外的类型，请检查代码。传入值：' .. targetType)
                end
            end
        end
    end
end

function NewAtkHit:__initTargetResult()
    local results = {}
    for i = 1, table.getn(self.__zhaoDamagesByHit) do
        local hitDamamges = self.__zhaoDamagesByHit[i]

        for j = 1, table.getn(hitDamamges) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.ADamageProperty#ADamageProperty]
            local damage = hitDamamges[j]

            local attrName = damage:getAttrName()

            local value = -damage:getActualValue()

            if results[attrName] == nil then
                results[attrName] = 0
            end

            results[attrName] = results[attrName] + value
        end
    end

    for i = 1, table.getn(self.__targetEffectChangeAttrByHit) do
        local effectChangeAttrsByHit = self.__targetEffectChangeAttrByHit[i]

        for j = 1, table.getn(effectChangeAttrsByHit) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
            local damage = effectChangeAttrsByHit[j]

            local attrName = damage:getAttrName()

            local value = damage:getActualValue()

            if results[attrName] == nil then
                results[attrName] = 0
            end

            results[attrName] = results[attrName] + value
        end
    end

    return results
end

function NewAtkHit:__initAttackerResults()
    local results = {}
    for i = 1, table.getn(self.__attackerEffectChangeAttrByHit) do
        local effectChangeAttrsByHit = self.__attackerEffectChangeAttrByHit[i]

        for j = 1, table.getn(effectChangeAttrsByHit) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
            local damage = effectChangeAttrsByHit[j]

            local attrName = damage:getAttrName()

            local value = damage:getActualValue()

            if results[attrName] == nil then
                results[attrName] = 0
            end

            results[attrName] = results[attrName] + value
        end
    end

    return results
end

function NewAtkHit:__initQiDamageShield()
    local QiDamageShield = require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiDamageShield")

    local targetQiShieldValue = self.__target:getBuffSystem():getShieldValue(self.__target:getId())

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.QIDamageShield#QiDamageShield]
    self.__qiDamageShield = QiDamageShield:create(targetQiShieldValue)
end

function NewAtkHit:getZhaoHitDamages()
    return self.__zhaoDamagesByHit
end

function NewAtkHit:getZhaoHitDamagesByHitIndex(index)
    if index <= 0 or index > table.getn(self.__zhaoDamagesByHit) then
        error("NewAtkHit:getZhaoHitDamagesByHitIndex 获取招式击中伤害索引大于或小于实际击中伤害数组个数，检查代码。")
    end

    return self.__zhaoDamagesByHit[index]
end

function NewAtkHit:initAttack()
    self:__initQiDamageShield()
    self:__allocZhaoDamages()

    self:__initEffectChangeByQiDamageOfHit()
    self:__allocAttackerEffectCauseByQiProjectedDamage()
    self:__allocTargetEffectCauseByQiProjectedDamage()
end

function NewAtkHit:__calQiDamageShield()
    if self.__qiDamageShield:getHasAbsorbedDamage() > 0 then
        self.__target:getBuffSystem():comsumeShieldValue(self.__target:getId(), self.__qiDamageShield:getHasAbsorbedDamage())
    end
end

function NewAtkHit:__calSufferDamge()
    for i = 1, table.getn(self.__zhaoDamagesByHit) do
        local hitDamamges = self.__zhaoDamagesByHit[i]

        for j = 1, table.getn(hitDamamges) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.ADamageProperty#ADamageProperty]
            local damage = hitDamamges[j]

            local attrName = damage:getAttrName()

            local value = damage:getActualValue()

            if attrName == "qi" and value > 0 then
                FightUtil:printLog(" LOGIC UPDATE ATK DOATTACK 【", self.__target:getAttr("name"), "】增加承伤量：", value)

                self.__target:addUpSufferDamge(value)
            end
        end
    end
end

function NewAtkHit:doAttack()
    FightUtil:printLog("attack hit 击中统计 : ")

    self:__calQiDamageShield()

    self:__calSufferDamge()

    local targetResults = self:__initTargetResult()

    self.__target:doChangeAttrMap(targetResults)

    local attackerResults = self:__initAttackerResults()

    self.__attacker:doChangeAttrMap(attackerResults)
end

--@desc:
--@author:Seven
--@time:2022-01-06 15:01:27
--@visitor: [src.app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttackCombFinishDescVisitor#ISkillAttackCombFinishDescVisitor]
function NewAtkHit:runOutputDescVisitor(visitor)
    visitor:visitorQiShieldAbsorbedDamage(self.__qiDamageShield)

    for i = 1, table.getn(self.__zhaoDamagesByHit) do
        local hitZhaoDamages = self.__zhaoDamagesByHit[i]

        for j = 1, table.getn(hitZhaoDamages) do
            local damageProperty = hitZhaoDamages[j]

            visitor:visitDamageActualValue(damageProperty)
        end
    end

    for i = 1, table.getn(self.__attackerEffectChangeAttrByHit) do
        local effectChangeAttrsByHit = self.__attackerEffectChangeAttrByHit[i]

        for j = 1, table.getn(effectChangeAttrsByHit) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
            local damage = effectChangeAttrsByHit[j]

            visitor:visitEffectChangeAttrActualValue(damage)
        end
    end

    for i = 1, table.getn(self.__targetEffectChangeAttrByHit) do
        local effectChangeAttrsByHit = self.__targetEffectChangeAttrByHit[i]

        for j = 1, table.getn(effectChangeAttrsByHit) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
            local damage = effectChangeAttrsByHit[j]

            visitor:visitEffectChangeAttrActualValue(damage)
        end
    end
end

--@author:Seven
--@time:2022-01-06 20:29:51
--@index: 击中帧索引
--@visitor: [src.app.FightSystem.UICtrl.UI.CharacterUIState.AttackUIState.UnderHitVisitors.IUnderHitVisitor#IUnderHitVisitor]
function NewAtkHit:runHitFrameVisitor(index, visitor)
    local hitZhaoDamages = self.__zhaoDamagesByHit[index]

    for j = 1, table.getn(hitZhaoDamages) do
        local damageProperty = hitZhaoDamages[j]

        visitor:visitZhaoDamagePopText(damageProperty)
    end

    local effectChangeAttrsByHit = self.__attackerEffectChangeAttrByHit[index]
    if effectChangeAttrsByHit ~= nil then
        for j = 1, table.getn(effectChangeAttrsByHit) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
            local damage = effectChangeAttrsByHit[j]

            visitor:visitAttackerEffectDamagePopText(damage)
        end
    end

    local effectChangeAttrsByHit = self.__targetEffectChangeAttrByHit[index]

    if effectChangeAttrsByHit ~= nil then
        for j = 1, table.getn(effectChangeAttrsByHit) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.EffectChangeAttrByQiHitDamage#EffectChangeAttrByQiHitDamage]
            local damage = effectChangeAttrsByHit[j]

            visitor:visitTargetEffectDamagePopText(damage)
        end
    end
end

return newClass("NewAtkHit", {}, NewAtkHit)
0000000000