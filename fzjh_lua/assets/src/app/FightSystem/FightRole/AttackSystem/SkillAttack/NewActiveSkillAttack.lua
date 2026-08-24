local newClass = require("third.class.NewClass")

local ISkillAttack = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ISkillAttack")

local FightCommons = require("app.FightSystem.FightCommons")

local CHARACTER_STATE = FightCommons.CHARACTER_STATE

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightBuffConstants = require("app.FightSystem.FightBuff.Constants")

local AttackFactory = require("app.FightSystem.Factory.CharacterFactory.AttackFactory")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local LOG_PREFIX = "# -> 主动技能 ActiveSkillAttack ："

local function ATTAK_LOG(str)
    FightUtil:printLog(LOG_PREFIX, str)
end

local NewActiveSkillAttack = {
    __index = 1,
    __zhaoAttacks = {},
    __zhaoComb = nil,
    __zhaoCombIsInterrupt = false,
    __isContinueAutoZhao = false,
    __combFinishEffectPopText = {}
}

function NewActiveSkillAttack:create(character)
    local p = self.new()
    p:setCharacter(character)
    return p
end

function NewActiveSkillAttack:setCharacter(character)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__attacker = character
end

function NewActiveSkillAttack:getFight()
    return self.__attacker:getFight()
end

--@desc: 设置攻击使用的招式组合
--@author:Seven
--@time:2021-06-25 18:09:53
function NewActiveSkillAttack:setZhaoComb(zhaoComb)
    --@RefType [src.app.FightSystem.FightRole.AttackSystem.ActiveSkill.ActiveZhaoCombAttack#ActiveZhaoCombAttack]
    self.__zhaoComb = zhaoComb

    if zhaoComb == nil then
        self.__activeSkill = nil
    else
        self.__activeSkill = self.__attacker:getActiveSkill(self.__zhaoComb:getActiveId())
    end
end

function NewActiveSkillAttack:getZhaoComb()
    return self.__zhaoComb
end

function NewActiveSkillAttack:setZhaoCombCanRelease(bool)
    if type(bool) ~= "boolean" then
        assert(false, "NewActiveSkillAttack setZhaoCombCanRelease 参数类型错误")
    end

    if self.__zhaoComb == nil then
        assert(false, "NewActiveSkillAttack:setZhaoCombCanRelease 主动技能未设置zhaoComb ，不可设置招式可出手，检查代码")
    end

    self.__canRelease = bool
end

function NewActiveSkillAttack:__doReleaseCost()
    local costTili = self.__activeSkill:getTiliCost()

    local costNeili = self.__activeSkill:getNeiliCost()

    self.__attacker:consumeTili(costTili)

    self.__attacker:consumeNeili(costNeili)

    ATTAK_LOG("startAttack 【体力消耗】：" .. costTili)
    ATTAK_LOG("startAttack 【内力消耗】：" .. costNeili)
end

function NewActiveSkillAttack:__outputReleaseStartText()
    local startText = self.__zhaoComb:getActionText()

    --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
    local desc = require("app.FightSystem.FightUtil.FightDesc"):create()

    desc:setText(startText)

    desc:setAttacker(self.__attacker)

    desc:setDefender(self.__target)

    desc:setHitPosName(self.__zhaoCombHitPosName)

    desc:setZhaoCombName(self.__zhaoComb:getActiveName())

    self.__attacker:outputDesces({desc})
end

function NewActiveSkillAttack:underBan()
    if self.__zhaoComb == nil then
        assert(false, "NewActiveSkillAttack:underBan 主动技能未设置zhaoComb ，无法检测是否被禁止，检查代码")
    end

    if self.__activeSkill == nil then
        assert(false, "NewActiveSkillAttack:underBan 主动技能未设置activeSkill ，无法检测是否被禁止，检查代码")
    end

    local underBan, popTips = self.__activeSkill:underBan()

    return underBan, popTips
end

function NewActiveSkillAttack:checkCanRelease()
    if self.__zhaoComb == nil then
        assert(false, "NewActiveSkillAttack:checkCanRelease 主动技能未设置zhaoComb ，无法检测是否可以出手，检查代码")
    end

    local isbool, failureText = self.__activeSkill:isMeetTheCost()

    return isbool, failureText
end

--@desc: 招式组合是否可以释放
--@author:Seven
--@time:2021-06-29 11:30:31
function NewActiveSkillAttack:zhaoCombCanRelease()
    if self:getZhaoComb() == nil then
        assert(false, "当前攻击招式组为空，检查代码！")
    end

    return self.__canRelease
end

--@desc: 准备出手
--@author:Seven
--@time:2021-06-27 02:36:08
function NewActiveSkillAttack:prepAttack()
    self.__zhaoAttacks = {}
    ATTAK_LOG(self.__attacker:getAttr("name") .. "准备出手主动技能 id:" .. self.__zhaoComb:getActiveId() .. " name :" .. self.__zhaoComb:getActiveName())
end

--@desc: 一次出手攻击开始
--@author:Seven
--@time:2021-06-25 15:15:34
function NewActiveSkillAttack:startAttack()
    ATTAK_LOG(self.__attacker:getAttr("name") .. "开始释放主动技能 id:" .. self.__zhaoComb:getActiveId() .. " name :" .. self.__zhaoComb:getActiveName())

    self.__target = self.__attacker:getTarget()

    self.__zhaoCombIsInterrupt = false

    if self:zhaoCombCanRelease() == false then
        assert(false, "NewActiveSkillAttack:startAttack 当前招式没有解锁出手，检查代码")
        return
    end

    self:setZhaoCombCanRelease(false)

    self.__attacker:setCanRecover(false)

    self.__attacker:releaseActiveSkill(self.__zhaoComb:getActiveId())

    self.__activeSkill:setCD(self.__activeSkill:getCoolDownTime())

    self.__zhaoCombHitPosName = self.__zhaoComb:randomHurtPosName()

    self:__doReleaseCost()

    self:__outputReleaseStartText()

    self.__isRunning = true
end

--@desc: 是否需要进行跳跃攻击
--@author:Seven
--@time:2021-06-27 17:54:39
function NewActiveSkillAttack:isNeedToJump()
    return self.__zhaoComb:isJumpAttack()
end

function NewActiveSkillAttack:isRunning()
    return self.__isRunning
end

function NewActiveSkillAttack:__initCurrZhaoCombDamages()
    local ZhaoHurtDegreeFactory = require("app.FightSystem.Factory.FightSkillFactory.ZhaoHurtDegreeFactory")

    local hurtIDs = self.__zhaoComb:getHurtIDs()

    if table.getn(hurtIDs) <= 0 then
        ATTAK_LOG("startCombAttack 【" .. self.__zhaoComb:getId() .. "无伤害】：")
        return
    end

    for _, hurtID in ipairs(hurtIDs) do
        local activeZhaoHurt = ZhaoHurtDegreeFactory:createActiveZhaoHurt(hurtID)

        activeZhaoHurt:setCharacter(self.__attacker)

        local activeZhaoHurtValue = activeZhaoHurt:getHurtValue()

        local attrName = activeZhaoHurt:getChangeAttrName()

        local info = {
            attrName = attrName,
            value = activeZhaoHurtValue,
            canBeAbsorbByShield = not activeZhaoHurt:getBreakShield(),
            damageTypeStr = activeZhaoHurt:getHurtDes()
        }

        if attrName == "qi" then
            info.factoryClass = require("app.FightSystem.FightRole.AttackSystem.DamageModel.ActiveQiDamagePropertyFactory")
        end

        self.__zhaoComb:addCombProjectedDamages(info)

        ATTAK_LOG("startCombAttack 【" .. attrName .. "伤害】：" .. activeZhaoHurtValue)
    end
end

function NewActiveSkillAttack:addOneOffEffect(effectInfo)
    if self.__oneOffEffects == nil then
        error("addOneOffEffect 战斗并未进入开始流程，动画效果名无法添加，检查代码")
    end

    local animName = AnimResManager:getOtherAnimName(effectInfo.animId)

    table.insert(
        self.__oneOffEffects,
        {
            eventName = effectInfo.eventName,
            animName = animName,
            targetId = effectInfo.targetId
        }
    )
end

--@desc: 一次招式组合攻击开始
--@author:Seven
--@time:2021-06-25 15:16:13
function NewActiveSkillAttack:startCombAttack()
    ATTAK_LOG("startCombAttack 【" .. self.__attacker:getAttr("name") .. "】使用组合-" .. self.__zhaoComb:getId() .. "开始攻击 : ")

    self.__oneOffEffects = {}

    self.__index = 1

    self.__isContinueAutoZhao = self.__zhaoComb:getCompletionUseAuto() == 1

    self.__startCombTargetQiStage = self.__target:getQiStage()

    self.__attacker:startCombAttack()

    self:__addBuffOnCompoStart()

    self:__initCurrZhaoCombDamages()
end

--@desc: 准备时间
--@author:Seven
--@time:2021-06-27 12:32:05
function NewActiveSkillAttack:getReadyDuration()
    return self.__zhaoComb:getReadyDuration()
end

--@desc: 攻击准备执行
--@author:Seven
--@time:2021-06-25 15:17:17
function NewActiveSkillAttack:doReadyZhao()
    local animName = self.__zhaoComb:getReadyAnimName()

    local soundId, soundStart = self.__zhaoComb:getReadySound()

    if animName ~= nil then
        ATTAK_LOG("doReadyZhao " .. self.__attacker:getAttr("name") .. " 释放准备招式动画：" .. animName)
        self.__attacker:activeReady(animName, soundId, soundStart)
    end
end

--@desc: 一次招式攻击开始
--@author:Seven
--@time:2021-06-25 15:17:27
function NewActiveSkillAttack:startZhaoAttack()
    ATTAK_LOG("startZhaoAttack" .. self.__attacker:getAttr("name") .. " 开始【第" .. self.__index .. "段】攻击")

    local hitType
    local zhaoAtk
    if self.__zhaoComb:isAttackSkill() then
        hitType = ATTACK_HIT_TYPE.HIT

        local builderParams =
            require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.HitBuilderParams"):create(self.__zhaoComb, self.__index, self.__attacker, self.__target, self.__oneOffEffects)
        --@RefType[src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.AtkHitBuilder#AtkHitBuilder]
        local activateAtkHitBuilder = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.AtkBuilder.ActivateAtkHitBuilder"):create(builderParams)
        zhaoAtk = activateAtkHitBuilder:build()
    else
        hitType = ATTACK_HIT_TYPE.NONE
        zhaoAtk = AttackFactory:createZhaoAtk(self.__zhaoComb, self.__index, self.__attacker, self.__target, hitType)
    end

    table.insert(self.__zhaoAttacks, zhaoAtk)
end

--@desc: 招式攻击
--@author:Seven
--@time:2021-06-25 15:17:38
function NewActiveSkillAttack:doZhaoAttack()
    ATTAK_LOG("doZhaoAttack【第" .. self.__index .. "/" .. self.__zhaoComb:getAtkCount() .. "段攻击")

    local zhaoAtk = self.__zhaoAttacks[self.__index]

    self.__attacker:attack(zhaoAtk)
end

--@desc: 招式攻击完成
--@author:Seven
--@time:2021-06-25 15:17:46
function NewActiveSkillAttack:finishZhaoAttack()
    ATTAK_LOG("finishZhaoAttack 【" .. self.__attacker:getAttr("name") .. "】 第" .. self.__index .. "段攻击结束")
    if self.__target:getAttr("qi") <= 0 then
        self.__target:changeState(CHARACTER_STATE.DEAD)
    end

    if self.__attacker:getAttr("qi") <= 0 then
        self.__attacker:changeState(CHARACTER_STATE.DEAD)
    end

    local currZhaoAttack = self.__zhaoAttacks[self.__index]
    if (currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.DODGE_SPC or currZhaoAttack:getHurtType() == ATTACK_HIT_TYPE.PARRY_SPEC) then
        self.__zhaoCombIsInterrupt = true
    end
end

--@desc: 招式组合攻击完成
--@author:Seven
--@time:2021-06-25 15:17:59
function NewActiveSkillAttack:finishCombAttack()
    ATTAK_LOG("finishCombAttack 【" .. self.__attacker:getAttr("name") .. "】组合-" .. self.__zhaoComb:getId() .. "攻击结束")

    self:__doCombFinishiOutputDesc()

    --@desc 当前招式结束，当前伤害相关属性清零
    self.__startCombTargetQiStage = 0
    local tempComb = self.__zhaoComb
    self.__zhaoComb = nil
    self.__zhaoAttacks = {}
    self.__attacker:doWhenFinishCombAttack(self)

    -- 结束后添加buff
    self:__addBuffOnCompoFinish()

    self:__doCombFinishEffectPopText()
    self.__combFinishEffectPopText = {}

    self.__attacker:finishCombAttack(self)
end

--@desc: 一次出手攻击的完成
--@author:Seven
--@time:2021-06-25 15:16:03
function NewActiveSkillAttack:finishAttack()
    self.__zhaoCombHitPosName = ""
    self.__zhaoComb = nil
    self.__zhaoAttacks = {}
    self.__attacker:setCanRecover(true)
    self.__isRunning = false
end

--@desc: 是否有一招攻击
--@author:Seven
--@time:2021-06-25 15:18:10
function NewActiveSkillAttack:hasNextZhaoAttack()
    local currZhaoAttack = self.__zhaoAttacks[self.__index]

    --@desc 被打断
    if currZhaoAttack and self:zhaoCombIsBeInterrupt() then
        return false
    end

    return self.__index < self.__zhaoComb:getAtkCount()
end

--@desc: 设置下一招攻击
--@author:Seven
--@time:2021-06-25 15:49:32
function NewActiveSkillAttack:setNextZhaoAttack()
    self.__index = self.__index + 1
    ATTAK_LOG(self.__attacker:getAttr("name") .. "设置下一段攻击：" .. self.__index)
end

--@desc: 获取攻击距离
--@author:Seven
--@time:2021-06-25 20:50:41
function NewActiveSkillAttack:getAttackOffset()
    local offset = BattleConstConf:get("activeZhaoJumpAttackDistance")

    if self.__zhaoComb:isAttackSkill() then
        local zhaoInfo = self.__zhaoComb:getZhaoInfo(self.__index)

        local atkWeapon = self.__attacker:getWeapon()

        local animName = AnimResManager:getAttackAnimName(zhaoInfo:getAnimResId(), atkWeapon:getWeaponModule())

        offset = AnimResManager:getAttackAnimOffset(animName)
    end

    return offset
end

--@desc: 获取当前攻击的攻击时间
--@author:Seven
--@time:2021-06-26 16:14:38
--@return:
function NewActiveSkillAttack:getAttackDuration()
    local zhaoAttack = self.__zhaoAttacks[self.__index]

    local duration = zhaoAttack:getDuration()

    return duration
end

function NewActiveSkillAttack:zhaoCombIsBeInterrupt()
    return self.__zhaoCombIsInterrupt
end

function NewActiveSkillAttack:canContinueUseAuto()
    return self.__isContinueAutoZhao
end

function NewActiveSkillAttack:addCombFinishEffectPopText(text)
    if text then
        table.insert(self.__combFinishEffectPopText, text)
    end
end

--[[
    @desc: 获得相关buff添加器 
    author:TangJian
    time:2022-03-03 17:55:57
    @return:
]]
function NewActiveSkillAttack:__getBuffAdders()
    local buffAdders = {cloneWithInherit(self.__zhaoComb:getBuffAdder())}

    -- local BuffAdder = require("app.FightSystem.FightBuff.BuffAdder.BuffAdder")
    -- buffAdders = {BuffAdder:create({"LaunTest_testZMsd"})}

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
function NewActiveSkillAttack:__addBuffOnCompoStart()
    -- 刷新当前buff状态
    self.__attacker:getBuffSystem():updateBuffEffect(self.__attacker:getId(), FightBuffConstants.EffectUpdateNodeType.AfterAttack)
    self.__attacker:getBuffSystem():updateBuffEffect(self.__target:getId(), FightBuffConstants.EffectUpdateNodeType.AfterAttack)

    local buffExecutors = {}
    -- 先判断添buff添加条件
    self.__buffAdders = self:__getBuffAdders()
    for i, buffAdder in ipairs(self.__buffAdders) do
        buffAdder:conditionCheck(self.__attacker.__character_sys:getFight(), self.__attacker, self.__target)
        table.appendArray(buffExecutors, buffAdder:addBuff(self.__attacker.__character_sys:getFight(), self.__attacker, self.__target, 0))
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
function NewActiveSkillAttack:__addBuffOnCompoFinish()
    -- 刷新当前buff状态
    self.__attacker:getBuffSystem():updateBuffEffect(self.__attacker:getId(), FightBuffConstants.EffectUpdateNodeType.BeforeAttack)
    -- 刷新当前buff状态
    self.__attacker:getBuffSystem():updateBuffEffect(self.__target:getId(), FightBuffConstants.EffectUpdateNodeType.BeforeAttack)

    local buffExecutors = {}
    for i, buffAdder in ipairs(self.__buffAdders) do
        table.appendArray(buffExecutors, buffAdder:addBuff(self.__attacker.__character_sys:getFight(), self.__attacker, self.__target, 1))
    end
    local AttackBuffExecutors = require("app.FightSystem.FightBuff.BuffExecutor.AttackBuffExecutors")
    local a_executors = AttackBuffExecutors:create()
    a_executors:setSkillAttack(self)
    for i, buffExecutor in ipairs(buffExecutors) do
        a_executors:addExecutor(buffExecutor)
    end

    a_executors:execute()
end

function NewActiveSkillAttack:__doCombFinishiOutputDesc()
    local ActiveSkillCombFinishDescVisitor = require("app.FightSystem.FightRole.AttackSystem.SkillAttack.ActiveSkillCombFinishDescVisitor")

    local visitor = ActiveSkillCombFinishDescVisitor:create()

    visitor:setAttacker(self.__attacker)

    visitor:setDefender(self.__target)

    visitor:setCombHitPosName(self.__zhaoCombHitPosName)

    visitor:setDefenderQiStage(self.__startCombTargetQiStage)

    for i = 1, table.getn(self.__zhaoAttacks) do
        local atk = self.__zhaoAttacks[i]

        atk:runOutputDescVisitor(visitor)
    end

    local outputList = visitor:outputDescList()
    self.__attacker:outputDesces(outputList)
end

function NewActiveSkillAttack:__doCombFinishEffectPopText()
    for i = 1, #self.__combFinishEffectPopText, 1 do
        self.__attacker:PopText(self.__combFinishEffectPopText[i])
    end
end

return newClass("NewActiveSkillAttack", {}, NewActiveSkillAttack)
0000000