local newClass = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightFormula = require("app.FightSystem.FightFormula")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local FightBuffConstants = require("app.FightSystem.FightBuff.Constants")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

--@RefType[src.app.FightSystem.FightBuff.Constants#Constants]
local BuffSystemConstants = require("app.FightSystem.FightBuff.Constants")

local ShenBingBuffAdder = require("app.FightSystem.FightBuff.BuffAdder.ShenBingBuffAdder")

local ISkillAttack = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttack")

local NewAutoSkillAttack = {
    __zhaoCombIsInterrupt = false,
    __zhaoAtks = {},
    __zhaoAttackCount = 0,
    --@desc 受击方气血阶段记录
    __startCombTargetQiStage = 0,
    __zhaoCombHitPosName = "",
    __combFinishEffectPopText = {}
}

local LOG_PREFIX = "# -> 被动技能 AutoSkillAttack ："
local function ATTAK_LOG(str)
    FightUtil:printLog(LOG_PREFIX, str)
end

function NewAutoSkillAttack:create(character)
    local p = NewAutoSkillAttack.new()
    p:setCharacter(character)
    return p
end

function NewAutoSkillAttack:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__attacker = character
end

--@desc: 设置攻击使用的招式组合
--@author:Seven
--@time:2021-06-25 18:09:53
function NewAutoSkillAttack:setZhaoComb(zhaoComb)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.AutoSkill.AutoZhaoCombAttack#AutoZhaoCombAttack]
    self.__zhaoComb = zhaoComb
end

function NewAutoSkillAttack:getZhaoComb()
    return self.__zhaoComb
end

--@desc: 是否需要进行跳跃攻击
--@author:Seven
--@time:2021-06-27 17:54:39
function NewAutoSkillAttack:isNeedToJump()
    return true
end

function NewAutoSkillAttack:getFight()
    return self.__attacker:getFight()
end

function NewAutoSkillAttack:addOneOffEffect(effectInfo)
end

--@desc 生成招式直接伤害
function NewAutoSkillAttack:__initCurrZhaoCombDamages()
    local damageTypeStr = self.__zhaoComb:getDamageType()

    local qiDamageValue = FightFormula:calAutoZhaoQiDamageAttackValue(self.__zhaoComb, self.__attacker, self.__target)

    local qiMaxDamageValue =
        FightFormula:calAutoZhaoQiMaxDamageAttackValue(
        qiDamageValue,
        FightFormula:calDisabilityProbability(self.__zhaoComb, self.__attacker, self.__target),
        self.__zhaoComb,
        self.__attacker,
        self.__target
    )

    self.__zhaoComb:addCombProjectedDamages(
        {
            attrName = "qiMax",
            value = qiMaxDamageValue,
            damageTypeStr = damageTypeStr
        }
    )

    self.__zhaoComb:addCombProjectedDamages(
        {
            attrName = "qi",
            value = qiDamageValue,
            damageTypeStr = damageTypeStr,
            canBeAbsorbByShield = not self.__target:getBuffSystem():hasRealDamage(self.__target:getId()),
            factoryClass = require("app.FightSystem.FightRole.AttackSystem.DamageModel.AutoQiDamagePropertyFactory")
        }
    )

    ATTAK_LOG("startCombAttack 【气血总伤害】：" .. qiDamageValue)

    ATTAK_LOG("startCombAttack 【气血上限总伤害】：" .. qiMaxDamageValue)
end

function NewAutoSkillAttack:__doCombAttackCost()
    local costTili = FightFormula:calAutoAttackTiliCost(self.__zhaoComb:getTiliCost(), self.__attacker:getMulAutoZhaoTiliCost(), self.__attacker:getAddAutoZhaoTiliCost())

    local costNeili = FightFormula:calAutoAttackNeiliCost(self.__attacker:getPlusPointBattle(), self.__attacker:getMulAutoZhaoNeiliCost(), self.__attacker:getAddAutoZhaoNeiliCost())
    local currNeili = self.__attacker:getAttr("neili")
    if costNeili > currNeili then
        costNeili = math.ceil(currNeili)
    end

    self.__attacker:consumeTili(costTili)

    self.__attacker:consumeNeili(costNeili)

    ATTAK_LOG("startCombAttack 【体力消耗】：" .. costTili)

    ATTAK_LOG("startCombAttack 【内力消耗】：" .. costNeili)
end

function NewAutoSkillAttack:__outputCombStartActionText()
    local startCombText = self.__zhaoComb:getActionText()

    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

    desc:setText(startCombText)

    desc:setAttacker(self.__attacker)

    desc:setDefender(self.__target)

    desc:setHitPosName(self.__zhaoCombHitPosName)

    desc:setZhaoCombName(self.__zhaoComb:getZhaoName())

    self.__attacker:outputDesces({desc})
end

--@desc: 准备出手
--@author:Seven
--@time:2021-06-27 02:36:08
function NewAutoSkillAttack:prepAttack()
    --@desc 被动技能无准备攻击阶段
end

--@desc: 一次出手攻击开始
--@author:Seven
--@time:2021-06-25 15:15:34
function NewAutoSkillAttack:startAttack()
    ATTAK_LOG(self.__attacker:getAttr("name") .. "开始出手被动技能 id：" .. self.__zhaoComb:getId() .. " name：" .. self.__zhaoComb:getZhaoName())
    self.__attacker:setCanRecover(false)

    self.__target = self.__attacker:getTarget()
end

--[[
    @desc: 获得相关buff添加器 
    author:TangJian
    time:2022-03-03 17:55:57
    @return:
]]
function NewAutoSkillAttack:__getBuffAdders()
    local buffAdders = {}
    table.insert(buffAdders, cloneWithInherit(self.__attacker:getWeapon():getBuffAdder()))
    table.insert(buffAdders, cloneWithInherit(self.__attacker:getFistFootBuffLauncherAdder()))

    -- buff附带的buff添加器
    for i, buffAdderParams in ipairs(self.__attacker:getBuffSystem():getExtraAutoSkillBuffAdderParamsArray(self.__attacker:getId())) do
        local dynamicLaun = nil
        if buffAdderParams.buffAdderParams and table.getn(buffAdderParams.buffAdderParams) > 0 then
            dynamicLaun = buffAdderParams.buffAdderParams[1]
        end
        table.insert(buffAdders, ShenBingBuffAdder:create({buffAdderParams.buffAdderId}, {dynamicLaun = dynamicLaun}))
    end

    if table.getn(buffAdders) > 0 then
        local CustomBuffNeeded = require("app.FightSystem.FightBuff.CustomBuffNeeded")
        local buffNeeded = CustomBuffNeeded:create()
        buffNeeded:setGetAttrFunc(
            function(attrName)
                return self.__attacker:getAttr(attrName)
            end
        )

        buffNeeded:setSelfWeaponAttrGetter(
            function(attrName)
                return self.__attacker:getWeapon():getWeaponAttr(attrName)
            end
        )

        buffNeeded:setGetTargetAttrFunc(
            function(attrName)
                return self.__target:getAttr(attrName)
            end
        )

        buffNeeded:setTargetWeaponAttrGetter(
            function(attrName)
                return self.__target:getWeapon():getWeaponAttr(attrName)
            end
        )

        buffNeeded:setSelfWeaponType(self.__attacker:getWeapon():getFirstType())
        buffNeeded:setTargetWeaponType(self.__target:getWeapon():getFirstType())

        for _, buffAdder in ipairs(buffAdders) do
            buffAdder:setBuffNeeded(buffNeeded)
            buffAdder:setCharacter(self.__attacker)
        end
    end

    return buffAdders
end

--[[
    @desc:在连招前添加buff
    author:唐健
    time:2021-07-05 23:25:48
    --@buffParamsArray: 
    @return:
]]
function NewAutoSkillAttack:__addBuffOnCompoStart()
    -- 刷新当前buff状态
    self.__attacker:getBuffSystem():updateBuffEffect(self.__attacker:getId(), FightBuffConstants.EffectUpdateNodeType.BeforeAttack)
    self.__attacker:getBuffSystem():updateBuffEffect(self.__target:getId(), FightBuffConstants.EffectUpdateNodeType.BeforeAttack)

    local buffExecutors = {}
    -- 先判断添buff添加条件
    self.__buffAdders = self:__getBuffAdders()
    for i, buffAdder in ipairs(self.__buffAdders) do
        table.appendArray(buffExecutors, buffAdder:addBuff(self.__attacker.__character_sys:getFight(), self.__attacker, self.__target, 0, self.__zhaoCombHitPosName))
    end
    local AttackBuffExecutors = require("app.FightSystem.FightBuff.BuffExecutor.AttackBuffExecutors")
    local a_executors = AttackBuffExecutors:create()
    a_executors:setSkillAttack(self)
    for i, buffExecutor in ipairs(buffExecutors) do
        a_executors:addExecutor(buffExecutor)
    end

    a_executors:execute()
end

--[[
    @desc:在连招后添加buff
    author:唐健
    time:2021-07-05 23:26:09
    --@buffParamsArray: 
    @return:
]]
function NewAutoSkillAttack:__addBuffOnCompoFinish()
    -- 刷新当前buff状态
    self.__attacker:getBuffSystem():updateBuffEffect(self.__attacker:getId(), FightBuffConstants.EffectUpdateNodeType.AfterAttack)
    self.__attacker:getBuffSystem():updateBuffEffect(self.__target:getId(), FightBuffConstants.EffectUpdateNodeType.AfterAttack)

    local buffExecutors = {}
    local isAllHit, hasDodge, hasParry, hasDodgeJump, hasParryParry = self:__getHitType()
    -- self.__buffAdders = self:__getBuffAdders()
    for i, buffAdder in ipairs(self.__buffAdders) do
        buffAdder:conditionCheck(self.__attacker.__character_sys:getFight(), self.__attacker, self.__target, isAllHit, hasDodge or hasDodgeJump, hasParry or hasParryParry)
    end
    for i, buffAdder in ipairs(self.__buffAdders) do
        table.appendArray(buffExecutors, buffAdder:addBuff(self.__attacker.__character_sys:getFight(), self.__attacker, self.__target, 1, self.__zhaoCombHitPosName))
    end
    local AttackBuffExecutors = require("app.FightSystem.FightBuff.BuffExecutor.AttackBuffExecutors")
    local a_executors = AttackBuffExecutors:create()
    a_executors:setSkillAttack(self)
    for i, buffExecutor in ipairs(buffExecutors) do
        a_executors:addExecutor(buffExecutor)
    end

    a_executors:execute()
end

--@desc: 一次招式组合攻击开始
--@author:Seven
--@time:2021-06-25 15:16:13
function NewAutoSkillAttack:startCombAttack()
    -- ATTAK_LOG("startCombAttack 【" .. self.__attacker:getAttr("name") .. "】 第" .. self.__index .. "段攻击开始")
    ATTAK_LOG("startCombAttack 【" .. self.__attacker:getAttr("name") .. "】使用组合-" .. self.__zhaoComb:getId() .. "开始攻击 : ")
    self.__zhaoCombIsInterrupt = false

    self.__zhaoCombHitPosName = self.__zhaoComb:randomHurtPosName()

    self.__startCombTargetQiStage = self.__target:getQiStage()

    self.__zhaoAttackCount = 1

    self.__index = 1

    self.__attacker:startCombAttack()

    self:__addBuffOnCompoStart()

    self:__doCombAttackCost()

    self:__initCurrZhaoCombDamages()

    self:__outputCombStartActionText()
end

--@desc: 准备时间
--@author:Seven
--@time:2021-06-27 12:32:05
function NewAutoSkillAttack:getReadyDuration()
    return 0
end

--@desc: 攻击准备执行
--@author:Seven
--@time:2021-06-25 15:17:17
function NewAutoSkillAttack:doReadyZhao()
    --@desc 被动攻击无准备释放阶段
end

--@desc: 一次招式攻击开始
--@author:Seven
--@time:2021-06-25 15:17:27
function NewAutoSkillAttack:startZhaoAttack()
    ATTAK_LOG("startZhaoAttack 【" .. self.__attacker:getAttr("name") .. "】 第" .. self.__index .. "段攻击开始")

    --@RefType [AttackFactory]
    local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")

    local attackHitType = AttackFactory:randomAutoZhaoAttackHitType(self.__zhaoComb, self.__attacker, self.__target)

    local zhaoAtk
    if attackHitType == ATTACK_HIT_TYPE.HIT then
        local builderParams = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.HitBuilderParams"):create(self.__zhaoComb, self.__index, self.__attacker, self.__target)

        --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder#AtkHitBuilder]
        local autoAtkHitBuilder = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AutoAtkHitBuilder"):create(builderParams)

        zhaoAtk = autoAtkHitBuilder:build()
    else
        zhaoAtk = AttackFactory:createZhaoAtk(self.__zhaoComb, self.__index, self.__attacker, self.__target, attackHitType)
    end

    table.insert(self.__zhaoAtks, zhaoAtk)
end

--@desc: 招式攻击
--@author:Seven
--@time:2021-06-25 15:17:38
function NewAutoSkillAttack:doZhaoAttack()
    ATTAK_LOG("doZhaoAttack【第" .. self.__index .. "/" .. self.__zhaoComb:getAtkCount() .. "段攻击")

    local currAttack = self.__zhaoAtks[self.__index]

    self.__attacker:attack(currAttack)
end

--@desc: 招式攻击完成
--@author:Seven
--@time:2021-06-25 15:17:46
function NewAutoSkillAttack:finishZhaoAttack()
    ATTAK_LOG("finishZhaoAttack 【" .. self.__attacker:getAttr("name") .. "】 第" .. self.__index .. "段攻击结束")
    if self.__target:getAttr("qi") <= 0 then
        self.__target:changeState(CHARACTER_STATE.DEAD)
    end

    if self.__attacker:getAttr("qi") <= 0 then
        self.__attacker:changeState(CHARACTER_STATE.DEAD)
    end

    local currZhaoAttack = self.__zhaoAtks[self.__index]
    if (currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.DODGE_SPC or currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.PARRY_SPEC) then
        self.__zhaoCombIsInterrupt = true
    end
end

--@desc: 招式组合攻击完成
--@author:Seven
--@time:2021-06-25 15:17:59
function NewAutoSkillAttack:finishCombAttack()
    ATTAK_LOG("finishCombAttack 【" .. self.__attacker:getAttr("name") .. "】组合-" .. self.__zhaoComb:getId() .. "攻击结束")

    self:__doEffectWhenFinishComb()

    -- 结束后添加buff
    self:__addBuffOnCompoFinish()

    -- 尝试移除buff
    self:__tryRemoveBuff()

    self:__doCombFinishiOutputDesc()

    self:__doCombFinishEffectPopText()

    self.__startCombTargetQiStage = 0
    self.__zhaoCombHitPosName = ""
    self.__zhaoComb = nil
    self.__zhaoAtks = {}
    self.__combFinishEffectPopText = {}

    self.__attacker:doWhenFinishCombAttack(self)

    self.__attacker:finishCombAttack(self)
end

-- function NewAutoSkillAttack:__checkAttr()
--     local checkList = {
--         "qi",
--         "neili",
--         "qiMax"
--     }
--     for i, attr in ipairs(checkList) do
--         local a_value = self.__attacker:getAttr(attr)
--         local a_ui_value = self.__attacker.__output:getVmAttr(attr)

--         if Helper:mathFloor(a_value) ~= Helper:mathFloor(a_ui_value) then
--             print("attacker 不一致:" .. attr)
--             print(debug.traceback())
--         end

--         local t_value = self.__target:getAttr(attr)
--         local t_ui_value = self.__target.__output:getVmAttr(attr)

--         if Helper:mathFloor(t_value) ~= Helper:mathFloor(t_ui_value) then
--             print("target 不一致:" .. attr)
--             print(debug.traceback())
--         end
--     end
-- end

--@desc: 一次出手攻击的完成
--@author:Seven
--@time:2021-06-25 15:16:03
function NewAutoSkillAttack:finishAttack()
    ATTAK_LOG("finishAttack 【" .. self.__attacker:getAttr("name") .. "】本次出手结束")
    self.__attacker:setCanRecover(true)
    self.__zhaoComb = nil
    self.__zhaoAtks = {}
end

--@desc: 是否有一招攻击
--@author:Seven
--@time:2021-06-25 15:18:10
function NewAutoSkillAttack:hasNextZhaoAttack()
    local currZhaoAtk = self.__zhaoAtks[self.__index]

    --@desc 被打断
    if currZhaoAtk and self:zhaoCombIsBeInterrupt() then
        return false
    end

    return self.__index < self.__zhaoComb:getAtkCount()
end

--@desc: 设置下一招攻击
--@author:Seven
--@time:2021-06-25 15:49:32
function NewAutoSkillAttack:setNextZhaoAttack()
    self.__index = self.__index + 1
    ATTAK_LOG(self.__attacker:getAttr("name") .. "设置下一段攻击：" .. self.__index)
end
--@desc: 获取攻击距离
--@author:Seven
--@time:2021-06-25 20:50:41
function NewAutoSkillAttack:getAttackOffset()
    local offset = 0

    local zhaoInfo = self.__zhaoComb:getZhaoInfo(self.__index)

    local atkWeapon = self.__attacker:getWeapon()

    local animName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atkWeapon:getWeaponModule())

    offset = AnimResManager:getAttackAnimOffset(animName)

    return offset
end

--@desc: 获取当前攻击的攻击时间
--@author:Seven
--@time:2021-06-26 16:14:38
--@return:
function NewAutoSkillAttack:getAttackDuration()
    local zhaoAttack = self.__zhaoAtks[self.__index]

    local duration = zhaoAttack:getDuration()

    return duration
end

function NewAutoSkillAttack:zhaoCombIsBeInterrupt()
    return self.__zhaoCombIsInterrupt
end

function NewAutoSkillAttack:canContinueUseAuto()
    return true
end

function NewAutoSkillAttack:addCombFinishEffectPopText(text)
    if text then
        table.insert(self.__combFinishEffectPopText, text)
    end
end

function NewAutoSkillAttack:__getHitType()
    local isAllHit = true
    local hasDodge = false
    local hasParry = false

    local hasDodgeJump = false
    local hasParryParry = false

    local zhaoInfoCount = self.__index
    if zhaoInfoCount > 0 then
        for i = 1, zhaoInfoCount do
            local zhaoAttack = self.__zhaoAtks[i]

            local hurtType = zhaoAttack:getHurtType()

            -- 是否命中
            if hurtType == FightCommons.ATTACK_HIT_TYPE.HIT then
            else
                isAllHit = false
            end

            -- 招架闪避
            if hurtType == FightCommons.ATTACK_HIT_TYPE.DODGE then
                hasDodge = true
            elseif hurtType == FightCommons.ATTACK_HIT_TYPE.PARRY then
                hasParry = true
            elseif hurtType == FightCommons.ATTACK_HIT_TYPE.DODGE_SPC then
                hasDodgeJump = true
            elseif hurtType == FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC then
                hasParryParry = true
            end
        end
    end

    return isAllHit, hasDodge, hasParry, hasDodgeJump, hasParryParry
end

function NewAutoSkillAttack:__tryRemoveBuff()
    local isAllHit, hasDodge, hasParry, hasDodgeJump, hasParryParry = self:__getHitType()

    -- 触发所有命中移除
    if isAllHit then
        self.__attacker:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.HIT)

        self.__target:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UnderAutoZhao, FightCommons.ATTACK_HIT_TYPE.HIT)
    end

    -- 触发闪避移除
    if hasDodge then
        self.__attacker:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.DODGE)

        self.__target:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UnderAutoZhao, FightCommons.ATTACK_HIT_TYPE.DODGE)
    end

    -- 触发招架移除
    if hasParry then
        self.__attacker:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY)

        self.__target:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UnderAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY)
    end

    -- 触发闪避移除
    if hasDodgeJump then
        self.__attacker:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.DODGE_SPC)

        self.__target:getBuffSystem():roleTryRemoveBuff(self.__target:getId(), BuffSystemConstants.BuffTriggerType.UnderAutoZhao, FightCommons.ATTACK_HIT_TYPE.DODGE_SPC)
    end

    -- 触发招架移除
    if hasParryParry then
        self.__attacker:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC)
        self.__target:tryRemoveBuff(BuffSystemConstants.BuffTriggerType.UseAutoZhao, FightCommons.ATTACK_HIT_TYPE.PARRY_SPEC)
    end
end

function NewAutoSkillAttack:__hasParryDoEffectWhenFinishComb(attackerDoChangeModel, targetDoChangeModel)
    local EffectChangeAttrModel = require("app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel")

    local attacker = self.__attacker

    local target = self.__target

    local doTargetAttrsEffect = function(targetAttrsEffectArray)
        if targetAttrsEffectArray:getCount() > 0 then
            for i = 1, targetAttrsEffectArray:getCount() do
                local attrEffect = targetAttrsEffectArray:get(i)

                local targetType = attrEffect:getTargetType()

                --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel#EffectChangeAttrModel]
                local effectChange = EffectChangeAttrModel:create()
                effectChange:setCharacterSystem(self.__attacker:getCharacterSystem())
                effectChange:setAttackerId(self.__attacker:getId())
                effectChange:setDefenderId(target:getId())
                effectChange:setEffectOwnerId(target:getId())
                effectChange:setEffectId(attrEffect:getEffectFuncId())
                effectChange:setChangeAttrName(attrEffect:getAttrName())
                effectChange:setChangeValue(attrEffect:getValue())

                if targetType == "self" then
                    if not target:isDead() then
                        effectChange:setTargetId(target:getId())
                        targetDoChangeModel:addEffectChangeAttr(effectChange)
                    end
                elseif targetType == "atk" then
                    if not self.__attacker:isDead() then
                        effectChange:setTargetId(self.__attacker:getId())
                        attackerDoChangeModel:addEffectChangeAttr(effectChange)
                    end
                else
                    error('  NewAutoSkillAttack:__hasParryDoEffectWhenFinishComb 不应该存在目标类型是 "self" 和 "atk" 外的类型，请检查代码。传入值：' .. targetType)
                end
            end
        end
    end

    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]]
    local targetAttrsEffectArray1 = target:getBuffSystem():roleGetAutoParryAttrsEffectMap(target:getId())
    doTargetAttrsEffect(targetAttrsEffectArray1)

    local zhaoAttacks = {}
    for i = 1, self.__index do
        local za = self.__zhaoAtks[i]
        local hurtType = za:getHurtType()
        if hurtType == ATTACK_HIT_TYPE.PARRY then
            table.insert(zhaoAttacks, za)
        end
    end
    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]]
    local targetAttrsEffectArray2 = target:getBuffSystem():roleGetAutoParryOnHitDamageAttrsEffectMap(target:getId(), zhaoAttacks)
    doTargetAttrsEffect(targetAttrsEffectArray2)
end

--@author:Seven
--@time:2021-12-21 21:32:08
--@attackerDoChangeModel:[src.app.FightSystem.FightRole.AttackSystem.AttackModel.DoChangeCharacterModel#DoChangeCharacterModel]
--@targetDoChangeModel: [src.app.FightSystem.FightRole.AttackSystem.AttackModel.DoChangeCharacterModel#DoChangeCharacterModel]
function NewAutoSkillAttack:__hasDodgeDoEffectWhenFinishComb(attackerDoChangeModel, targetDoChangeModel)
    local EffectChangeAttrModel = require("app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel")

    local attacker = self.__attacker

    local target = self.__target

    --@RefType [src.app.FightSystem.FightBuff.BuffModel.ZhaoAttackAttrsEffectArray#ZhaoAttackAttrsEffectArray]]
    local targetAttrsEffectArray = target:getBuffSystem():roleGetAutoDodgeAttrsEffectMap(target:getId())
    if targetAttrsEffectArray:getCount() > 0 then
        for i = 1, targetAttrsEffectArray:getCount() do
            local attrEffect = targetAttrsEffectArray:get(i)

            local targetType = attrEffect:getTargetType()
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.EffectChangeAttrModel#EffectChangeAttrModel]
            local effectChange = EffectChangeAttrModel:create()
            effectChange:setCharacterSystem(self.__attacker:getCharacterSystem())
            effectChange:setAttackerId(self.__attacker:getId())
            effectChange:setDefenderId(target:getId())
            effectChange:setEffectOwnerId(target:getId())
            effectChange:setEffectId(attrEffect:getEffectFuncId())
            effectChange:setChangeAttrName(attrEffect:getAttrName())
            effectChange:setChangeValue(attrEffect:getValue())

            if targetType == "self" then
                if not target:isDead() then
                    effectChange:setTargetId(target:getId())
                    targetDoChangeModel:addEffectChangeAttr(effectChange)
                end
            elseif targetType == "atk" then
                if not self.__attacker:isDead() then
                    effectChange:setTargetId(self.__attacker:getId())
                    attackerDoChangeModel:addEffectChangeAttr(effectChange)
                end
            else
                error('  NewAutoSkillAttack:__hasParryDoEffectWhenFinishComb 不应该存在目标类型是 "self" 和 "atk" 外的类型，请检查代码。传入值：' .. targetType)
            end
        end
    end
end

function NewAutoSkillAttack:__doEffectWhenFinishComb()
    local zhaoInfoCount = self.__index
    local hasParry = false
    local hasDodge = false
    if zhaoInfoCount > 0 then
        for i = 1, zhaoInfoCount do
            local zhaoAttack = self.__zhaoAtks[i]

            local hurtType = zhaoAttack:getHurtType()

            if hurtType == FightCommons.ATTACK_HIT_TYPE.DODGE then
                hasDodge = true
            elseif hurtType == FightCommons.ATTACK_HIT_TYPE.PARRY then
                hasParry = true
            end
        end
    end

    local DoChangeCharacterModel = require("app.FightSystem.FightRole.AttackSystem.AttackModel.DoChangeCharacterModel")

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.DoChangeCharacterModel#DoChangeCharacterModel]
    local attackerDoChangeModel = DoChangeCharacterModel:create(self.__attacker)

    --@RefType [src.app.FightSystem.FightRole.AttackSystem.AttackModel.DoChangeCharacterModel#DoChangeCharacterModel]
    local targetDoChangeModel = DoChangeCharacterModel:create(self.__target)

    if hasParry then
        self:__hasParryDoEffectWhenFinishComb(attackerDoChangeModel, targetDoChangeModel)
    end

    if hasDodge then
        self:__hasDodgeDoEffectWhenFinishComb(attackerDoChangeModel, targetDoChangeModel)
    end

    local result = attackerDoChangeModel:doChangeAttrs()
    attackerDoChangeModel:doCharacterCombFinishPopText()
    attackerDoChangeModel:doCharacterCombFinishPrintDesc()

    if not MapIsEmpty(result) then
        for k, v in pairs(result) do
            if k == "qi" and v < 0 then
                self.__attacker:addUpSufferDamge(math.abs(v))
            end

            self.__attacker:doEffectChangeAttrUpdateInfo(k, v)
        end
    end

    local targetResult = targetDoChangeModel:doChangeAttrs()
    targetDoChangeModel:doCharacterCombFinishPopText()
    targetDoChangeModel:doCharacterCombFinishPrintDesc()

    if not MapIsEmpty(targetResult) then
        for k, v in pairs(targetResult) do
            if k == "qi" and v < 0 then
                self.__target:addUpSufferDamge(math.abs(v))
            end

            self.__target:doEffectChangeAttrUpdateInfo(k, v)
        end
    end
end

function NewAutoSkillAttack:__doCombFinishiOutputDesc()
    local AutoSkillCombFinishDescVisitor = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.AutoSkillCombFinishDescVisitor")

    local visitor = AutoSkillCombFinishDescVisitor:create()

    visitor:setAttacker(self.__attacker)

    visitor:setDefender(self.__target)

    visitor:setCombHitPosName(self.__zhaoCombHitPosName)

    visitor:setDefenderQiStage(self.__startCombTargetQiStage)

    for i = 1, table.getn(self.__zhaoAtks) do
        local atk = self.__zhaoAtks[i]

        atk:runOutputDescVisitor(visitor)
    end

    local outputList = visitor:outputDescList()
    self.__attacker:outputDesces(outputList)
end

function NewAutoSkillAttack:__doCombFinishEffectPopText()
    for i = 1, #self.__combFinishEffectPopText, 1 do
        self.__attacker:PopText(self.__combFinishEffectPopText[i])
    end
end

return newClass("NewAutoSkillAttack", {}, NewAutoSkillAttack)
00000