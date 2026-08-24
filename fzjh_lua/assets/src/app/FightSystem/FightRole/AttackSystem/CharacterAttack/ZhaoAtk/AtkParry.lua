local class = require("third.class.NewClass")

local IZhaoAttack = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.IZhaoAttack")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightCommons = require("app.FightSystem.FightCommons")

local QiParryDamageProperty = require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiParryDamageProperty")

local DamageProperty = require("app.FightSystem.FightRole.AttackSystem.DamageModel.DamageProperty")

local NewAtkHit = require("app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.NewAtkHit")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local ATTACK_HIT_TYPE = FightCommons.ATTACK_HIT_TYPE

--@SuperType [src.app.FightSystem.FightRole.AttackSystem.CharacterAttack.ZhaoAtk.NewAtkHit#NewAtkHit]
local AtkParry = {
    __hurtType = ATTACK_HIT_TYPE.PARRY,
    --@desc 存放根据动画击中次数分配后的招式伤害数组[[damage,damage],[damage,damage]]
    __zhaoDamagesByHit = {},
    __attackerEffectChangeAttrByHit = {},
    __targetEffectChangeAttrByHit = {},
    __targetWeaponFly = false,
    __targetWeaponBlock = false
}

function AtkParry:create()
    return AtkParry.new()
end

function AtkParry:ctor()
end

function AtkParry:onInit()
end

function AtkParry:getTargetWeaponFly()
    return self.__targetWeaponFly
end

function AtkParry:getTargetWeaponBlock()
    return self.__targetWeaponBlock
end

--@desc: 计算受击方武器损耗值
--@author:Seven
--@time:2022-01-18 20:23:48
function AtkParry:__calTargetWeaponLossOfValue()
    local aWeapon = self.__attacker:getWeapon()

    local tWeapon = self.__target:getWeapon()

    if self.__target:weaponIsEmptyHand() then
        return
    end

    local SkillConst = require("app.models.skill.SkillConst")

    local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

    local value = 0

    FightUtil:printLog(string.format("AtkParry:__calTargetWeaponLossOfValue 目标(%s) 的武器损耗值相关 ：", self.__target:getAttr("name")))

    if self.__attacker:weaponIsEmptyHand() then
        local baseQuanJiaoSkill = self.__attacker:getBaseSkill(SKILL_SECOND_TYPE.QUAN_JIAO)

        value = math.min(Helper:preciseDecimal((self.__attacker:getAttr("str") + baseQuanJiaoSkill:getLevel() / 10) / 432 + baseQuanJiaoSkill:getLevel() / 1000, 3), 1.8)
        
        FightUtil:printLog("│├ parmas 攻击者基本拳脚等级 ：", baseQuanJiaoSkill:getLevel())
        FightUtil:printLog("│├ parmas 攻击者先天臂力 ：", self.__attacker:getAttr("str"))
    else
        local a_hardnessValue = aWeapon:getHardnessValue()

        local t_tenacity = tWeapon:getTenacity()

        value = Helper:preciseDecimal(a_hardnessValue * ((250 - t_tenacity) / 250) * 0.03, 3)

        FightUtil:printLog("│├ parmas 攻击者武器硬度 ：", a_hardnessValue)
        FightUtil:printLog("│├ parmas 受击者武器韧度 ：", t_tenacity)
    end

    if value > 0 then
        local finalValue = tWeapon:getLossOfValue() + value

        tWeapon:setLossOfValue(finalValue)
        
        FightUtil:printLog("└─  当前损耗值 ：", value)
        FightUtil:printLog("└─ 受击者武器累积损耗值 ：", finalValue)
    end
end

function AtkParry:__calTargetWeaponBlock()
    local tWeapon = self.__target:getWeapon()
    local aWeapon = self.__attacker:getWeapon()

    -- 攻击方武器类型能否打断对手武器
    if not aWeapon:canBreakWeapon() then
        return
    end

    -- 招架方武器类型能否被打断
    if not tWeapon:canBrokenWeapon() then
        return
    end

    -- 当攻击方装备武器时，
    --       - 当损耗值超过招架方武器坚韧之后，招架方每次招架都有**20%**概率武器被打断。
    -- 攻击方未装备武器时，
    --       - 当损耗值超过招架方武器坚韧之后，招架方每次招架都有**10%**概率武器被打断。
    if tWeapon:getLossOfValue() <= tWeapon:getHardnessValue() then
        return
    end

    local percent = 0

    FightUtil:printLog(string.format("AtkParry:__calTargetWeaponFly 目标(%s) 的武器打断概率计算 ：", self.__target:getAttr("name")))

    if self.__attacker:weaponIsEmptyHand() then
        local normalize = BattleConstConf:get("weaponDestroy_noWpBaseParam")

        local debugParam_weaponDestroy_noWp = BattleConstConf:get("debugParam_weaponDestroy_noWp")

        percent = (normalize + debugParam_weaponDestroy_noWp) * 100

        FightUtil:printLog("│├ parmas 基础攻方无武器武器打断概率 ：", normalize)
        FightUtil:printLog("│├ parmas 测试攻方无装备武器打断概率修正参数 ：", debugParam_weaponDestroy_noWp)
    else
        local normalize = BattleConstConf:get("weaponDestroy_haveWpBaseParam")

        local debugParam_weaponDestroy_haveWp = BattleConstConf:get("debugParam_weaponDestroy_haveWp")

        percent = (normalize + debugParam_weaponDestroy_haveWp) * 100

        FightUtil:printLog("│├ parmas 基础攻方有武器打断概率 ：", normalize)
        FightUtil:printLog("│├ parmas 测试攻方有装备武器打断概率修正参数 ：", debugParam_weaponDestroy_haveWp)
    end

    local rand = FightUtil:random(1, 100)

    FightUtil:printLog("└─ rand 随机结果概率 ：", rand)
    FightUtil:printLog("└─ finalValue 打断概率 ：", percent)

    if rand <= percent then
        FightUtil:printLog(string.format("AtkParry:__calTargetWeaponBlock 目标(%s) 的武器被打断", self.__target:getAttr("name")))

        self.__targetWeaponBlock = true

        self.__targetWeaponflyOrBlockAnim = AnimResManager:getOtherAnimNameByWeapon(BattleConstConf:get("weaponDestroy_animRes"), tWeapon:getWeaponModule())
    end
end

function AtkParry:__calTargetWeaponFly()
    if self.__targetWeaponBlock then
        return
    end

    local tWeapon = self.__target:getWeapon()

    local aWeapon = self.__attacker:getWeapon()

    -- 攻击方武器类型能否打飞对手武器
    if not aWeapon:canFlyWeapon() then
        return
    end

    -- 招架方武器类型能否被打飞
    if not tWeapon:canBeFlyWeapon() then
        return
    end

    local aWeight = aWeapon:getWeight()

    local tWeight = tWeapon:getWeight()

    local aWeaponSkill = self.__attacker:getPrepSkill(aWeapon:getAutoChooseSkill())
    if aWeaponSkill == nil then
        aWeaponSkill = self.__attacker:getBaseSkill(aWeapon:getAutoChooseSkill())
    end
    local aSkillLv = aWeaponSkill:getLevel()

    local tParrySkill = self.__target:getParrySkill()
    local tSkillLv = tParrySkill:getLevel()

    local percent = 0

    FightUtil:printLog(string.format("AtkParry:__calTargetWeaponFly 目标(%s) 的武器打飞概率计算 ：", self.__target:getAttr("name")))
    FightUtil:printLog("│├ parmas 攻击者武器重量 ：", aWeight)
    FightUtil:printLog("│├ parmas 受击者武器重量 ：", tWeight)
    FightUtil:printLog("│├ parmas 攻击者攻击武学等级 ：", aSkillLv)
    FightUtil:printLog("│├ parmas 受击者招架武学等级 ：", tSkillLv)

    if aWeight >= (tWeight * 2) then
        percent = math.min((1 - tSkillLv / 1200) * 100, 60)
    elseif (tWeight * 2) > aWeight and aWeight > tWeight and aSkillLv > tSkillLv then
        percent = Helper:getRange((1 - tSkillLv / aSkillLv), 7, 25)
    elseif (tWeight * 2) > aWeight and aWeight > tWeight and aSkillLv <= tSkillLv then
        percent = 7
    else
        percent = 0
    end

    local debugParam_weaponFly = BattleConstConf:get("debugParam_weaponFly")

    local finalPercent = percent + debugParam_weaponFly

    local rand = FightUtil:random(1, 100)

    FightUtil:printLog("│├ parmas 基础武器打飞概率 ：", percent)
    FightUtil:printLog("│├ parmas 测试武器打飞概率修正参数 ：", debugParam_weaponFly)
    FightUtil:printLog("└─ rand 随机结果概率 ：", rand)
    FightUtil:printLog("└─ finalValue 打飞概率 ：", finalPercent)

    if rand <= finalPercent then
        FightUtil:printLog(string.format("AtkParry:__calTargetWeaponFly 目标(%s) 的武器被打飞", self.__target:getAttr("name")))
        self.__targetWeaponFly = true

        self.__targetWeaponflyOrBlockAnim = AnimResManager:getOtherAnimNameByWeapon(BattleConstConf:get("weaponFly_animRes"), tWeapon:getWeaponModule())
    end
end

--@desc: 招式伤害按照动画击中次数分配
--@author:Seven
--@time:2022-01-04 16:16:03
function AtkParry:__allocZhaoDamages()
    local combProjectedDamages = self.__combAttack:getCombProjectedDamages()

    local animHitCount = self.__combAttack:getAnimHurtTimes()

    if animHitCount <= 0 then
        error("NewAtkHit:__allocZhaoDamages 招式配置动画击中次数为0，无法分配。")
    end

    for i = 1, animHitCount do
        local hitDamages = {}
        for _, damageInfo in ipairs(combProjectedDamages) do
            --@RefType [src.app.FightSystem.FightRole.AttackSystem.DamageModel.ADamageProperty#ADamageProperty]
            local damageProperty = nil

            if damageInfo.attrName == "qi" then
                local factory = damageInfo.factoryClass:create()

                factory:setDamagePropertyClass(require("app.FightSystem.FightRole.AttackSystem.DamageModel.QiParryDamageProperty"))

                factory:setQiShield(self.__qiDamageShield)

                factory:setReduceEffectMap(self.__target:getBuffSystem():getDamageReductionValueMap(self.__target:getId()))

                factory:setCanBeAbsorbByShield(damageInfo.canBeAbsorbByShield)

                factory:setDamageDescType(damageInfo.damageTypeStr)

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

function AtkParry:__doFlyOrBolck()
    local isMatch = false
    if self.__targetWeaponBlock then
        self.__target:blockWeapon()
        isMatch = true
    elseif self.__targetWeaponFly then
        self.__target:flyWeapon()
        isMatch = true
    end

    if isMatch then
        self.__targetNewActiveSkillVmList = self.__target:getChararcterActiveSkillVm()
        self.__targetNewViewInfo = self.__target:getCharacterViewInfo()
        self.__targetNewWeapon = self.__target:getWeapon()
    end
end

function AtkParry:getTargetWeaponBlockOrFlyInfo()
    return {
        activeSkillVm = self.__targetNewActiveSkillVmList,
        viewInfo = self.__targetNewViewInfo,
        weapon = self.__targetNewWeapon,
        targetUnderHitAnim = self.__targetWeaponflyOrBlockAnim
    }
end

--@attacker:[src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function AtkParry:doAttack()
    FightUtil:printLog(" LOGIC UPDATE ATK DOATTACK 【", self.__attacker:getAttr("name"), "】攻击被普通招架了")

    self:__calTargetWeaponLossOfValue()

    self:__calTargetWeaponBlock()

    self:__calTargetWeaponFly()

    self:__doFlyOrBolck()

    self:__calQiDamageShield()

    self:__calSufferDamge()

    local targetResults = self:__initTargetResult()

    self.__target:doChangeAttrMap(targetResults)

    local attackerResults = self:__initAttackerResults()

    self.__attacker:doChangeAttrMap(attackerResults)
end

return class("AtkParry", {NewAtkHit}, AtkParry)
0000000