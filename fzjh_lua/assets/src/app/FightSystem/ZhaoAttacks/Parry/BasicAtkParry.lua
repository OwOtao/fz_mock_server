--[[
    author:Seven
    time:2023-01-06 14:18:10
    desc:招式攻击招架结果处理基类
]]
local ABasicZhaoAttack = require("app.FightSystem.ZhaoAttacks.ABasicZhaoAttack")

local AnimResManager = require("app.FightSystem.ResourceManager.AnimResManager")

local FightCommons = require("app.FightSystem.FightCommons")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local BasicAtkHit = require("app.FightSystem.ZhaoAttacks.Hit.BasicAtkHit")

local TextResManager = require("app.FightSystem.ResourceManager.TextResManager")

local HIT_TYPE_HIT = FightCommons.ATTACK_HIT_TYPE

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.ZhaoAttacks.Hit.BasicAtkHit#BasicAtkHit]
local BasicAtkParry = {
    __hitType = HIT_TYPE_HIT.PARRY
}

--@desc: 执行攻击
--@author:Seven
--@time:2023-02-09 11:08:00
function BasicAtkParry:attack()
    FightUtil:printLog("招式攻击 -- 格挡：")
    local hurtTimes = self.__zhao:getAnimHurtTimes()
    for i = 1, hurtTimes do
        self.__currAtkIndex = i
        FightUtil:printLog("- 招式攻击第【" .. tostring(self.__currAtkIndex) .. "】次击中")
        self:__doOneAttack()
        if self.__currAtkIndex == hurtTimes then
            self:__parryLastAttack()
        end
    end
end

--@desc: 计算受击方武器损耗值
--@author:Seven
--@time:2023-02-17 15:59:35
function BasicAtkParry:__calTargetWeaponLossOfValue()
    local attacker = self.__context:getAttacker()

    local target = self.__context:getTarget()

    local aWeapon = attacker:getWeapon()

    local tWeapon = target:getWeapon()

    if target:weaponIsEmptyHand() then
        return
    end

    local SkillConst = require("app.models.skill.SkillConst")

    local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

    local value = 0

    FightUtil:printLog(string.format("BasicAtkParry:__calTargetWeaponLossOfValue 目标(%s) 的武器损耗值相关 ：", target:getAttr("name")))

    if attacker:weaponIsEmptyHand() then
        local baseQuanJiaoSkill = attacker:getBaseSkill(SKILL_SECOND_TYPE.QUAN_JIAO)

        value = math.min(Helper:preciseDecimal((attacker:getAttr("str") + baseQuanJiaoSkill:getLevel() / 10) / 432 + baseQuanJiaoSkill:getLevel() / 1000, 3), 1.8)

        FightUtil:printLog("│├ parmas 攻击者基本拳脚等级 ：", baseQuanJiaoSkill:getLevel())
        FightUtil:printLog("│├ parmas 攻击者先天臂力 ：", attacker:getAttr("str"))
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

function BasicAtkParry:__calTargetWeaponBlock()
    --@RefType[src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local attacker = self.__context:getAttacker()
    --@RefType[src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local target = self.__context:getTarget()

    local tWeapon = target:getWeapon()

    local aWeapon = attacker:getWeapon()

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

    FightUtil:printLog(string.format("AtkParry:__calTargetWeaponFly 目标(%s) 的武器打断概率计算 ：", target:getAttr("name")))

    if attacker:weaponIsEmptyHand() then
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
        FightUtil:printLog(string.format("AtkParry:__calTargetWeaponBlock 目标(%s) 的武器被打断", target:getAttr("name")))

        target:blockWeapon()

        --@RefType [src.app.FightSystem.ZhaoAttacks.Parry.OneAttackParryResult#OneAttackParryResult]
        local lastOneResult = self:getOneHitResult(self:getCurrentAttackIndex())
        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local fightDesc = require("app.FightSystem.FightUtil.FightDesc"):create()
        fightDesc:setText(TextResManager:getText("1090"))
        fightDesc:setAttacker(attacker)
        fightDesc:setDefender(target)

        lastOneResult:setTargetWeaponFlyOrBlockInfo(
            {
                weapon = target:getWeapon(),
                targetUnderHitAnim = AnimResManager:getOtherAnimNameByWeapon(BattleConstConf:get("weaponDestroy_animRes"), tWeapon:getWeaponModule()),
                printText = fightDesc:getString()
            }
        )
        return true
    end

    return false
end

function BasicAtkParry:__calTargetWeaponFly()
    local attacker = self.__context:getAttacker()

    local target = self.__context:getTarget()

    local tWeapon = target:getWeapon()

    local aWeapon = attacker:getWeapon()

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

    local aWeaponSkill = attacker:getPrepSkill(aWeapon:getAutoChooseSkill())
    if aWeaponSkill == nil then
        aWeaponSkill = attacker:getBaseSkill(aWeapon:getAutoChooseSkill())
    end
    local aSkillLv = aWeaponSkill:getLevel()

    local tParrySkill = target:getParrySkill()
    local tSkillLv = tParrySkill:getLevel()

    local percent = 0

    FightUtil:printLog(string.format("AtkParry:__calTargetWeaponFly 目标(%s) 的武器打飞概率计算 ：", target:getAttr("name")))
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
        FightUtil:printLog(string.format("AtkParry:__calTargetWeaponFly 目标(%s) 的武器被打飞", target:getAttr("name")))
        target:flyWeapon()

        --@RefType [src.app.FightSystem.ZhaoAttacks.Parry.OneAttackParryResult#OneAttackParryResult]
        local lastOneResult = self:getOneHitResult(self:getCurrentAttackIndex())

        --@RefType [src.app.FightSystem.FightUtil.FightDesc#FightDesc]
        local fightDesc = require("app.FightSystem.FightUtil.FightDesc"):create()
        fightDesc:setText(TextResManager:getText("1091"))
        fightDesc:setAttacker(attacker)
        fightDesc:setDefender(target)

        lastOneResult:setTargetWeaponFlyOrBlockInfo(
            {
                weapon = target:getWeapon(),
                targetUnderHitAnim = AnimResManager:getOtherAnimNameByWeapon(BattleConstConf:get("weaponFly_animRes"), tWeapon:getWeaponModule()),
                printText = fightDesc:getString()
            }
        )

        return true
    end

    return false
end

--@desc: 格挡最后一击需要执行的额外处理
--@author:Seven
--@time:2023-02-17 15:35:37
function BasicAtkParry:__parryLastAttack()
    self:__calTargetWeaponLossOfValue()

    if self:__calTargetWeaponBlock() then
        return
    elseif self:__calTargetWeaponFly() then
        return
    end
end

return newClass("BasicAtkParry", {BasicAtkHit}, BasicAtkParry)
0000000000000