--[[
    战斗相关公式
]]
local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local FightFormula = {}

local FightCommons = require("app.FightSystem.FightCommons")

function FightFormula:getTiliRecoverValue(ft, tiliMax)
    local addValue = tiliMax / 3 * ft
    return addValue
end

--@desc: 获取跳跃距离
--@author:Seven_L
--@time:2020-05-06 15:18:47
--@startPos: 开始位置
--@endPos: 结束位置
--@totalTime: 总时间
--@offset: 位移（填写在动画中）
--@dt: 已经经过的时间
function FightFormula:jumpFoward(startPos, endPos, percent)
    local startPosX = startPos.x

    local startPosY = startPos.y

    local endPosX = endPos.x

    local endPosY = endPos.y

    local dx = (endPosX - startPosX) * (math.sin(percent * (math.pi / 2)))

    local dy = (endPosY - startPosY) * percent

    local moveToPos = cc.pAdd(startPos, cc.p(dx, dy))

    return moveToPos
end

function FightFormula:jumpBackward(startPos, endPos, percent)
    local dx = (endPos.x - startPos.x) * (math.sin(percent * (math.pi / 2)))
    local dy = (endPos.y - startPos.y) * (math.sin(percent * (math.pi / 2)))

    local movtToPos = cc.pAdd(startPos, cc.p(dx, dy))

    return movtToPos
end

function FightFormula:calJumpHeighest(startPosX, targetPosX)
    return math.abs((targetPosX - startPosX)) / 1080 * 30
end

--@desc: 人物动画跳起的距离
--@author:Seven_L
--@time:2020-05-06 16:22:26
--@heightest:最高的距离
--@totalTime:总时间
--@dt: 已经经过的时间
function FightFormula:jumpHeight(heightest, percent)
    local jumpY = (0.5 - math.abs(0.5 - percent)) * heightest
    jumpY = jumpY * jumpY
    return jumpY
end

--@desc: 招式伤害计算
--@author:Seven
--@time:2021-06-30 15:36:09
--@zhaoComb: [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
--@attacker: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightFormula:calAutoZhaoQiDamageAttackValue(zhaoComb, attacker, target)
    -- * 攻击力
    local atk = attacker:getAtk()

    -- * 目标防御力
    local def = target:getDef()

    -- * 招式攻击性能
    local attack = zhaoComb:getAttack()

    -- * 攻击修正系数
    local attackCorrectionFactor = BattleConstConf:get("attackCorrectionFactor")

    -- * 防御修正系数
    local defCorrectionFactor = BattleConstConf:get("defCorrectionFactor")

    -- * 招式攻击性能修正系数
    local zhaoCombAttackCorrectionFactor = BattleConstConf:get("zhaoCombAttackCorrectionFactor")

    -- * 实际加力值
    local plusPoint = attacker:getPlusPointBattle()

    -- * 实际加力气血伤害加成系数
    local plusPointQiHurtFactorAddition = BattleConstConf:get("plusPointQiHurtFactorAddition")

    -- * 被动普通气血伤害系数
    local qiatkFactor = attacker:getAttr("qiatkFactor")

    local autoZhaoAtkDamageClass = zhaoComb:getAutoZhaoAtkDamageClass()

    -- * 伤害属性修正系数
    local skillDamageAttrCorrectionFactor = 1
    if autoZhaoAtkDamageClass ~= "0" then
        skillDamageAttrCorrectionFactor = self:calSkillDamageAttrCorrectionFactor(attacker, target, autoZhaoAtkDamageClass)
    end

    -- 普通气血伤害 = 战斗攻击力*攻击修正系数 * (1+招式攻击性能*招式攻击性能修正系数) / (目标战斗防御力*防御修正系数) * (1+战斗加力值*实际加力气血伤害加成系数+被动普通气血伤害系数) * 伤害属性修正系数
    local qiDamage =
        atk * attackCorrectionFactor * (1 + attack * zhaoCombAttackCorrectionFactor) / (def * defCorrectionFactor) * (1 + plusPoint * plusPointQiHurtFactorAddition + qiatkFactor) *
        skillDamageAttrCorrectionFactor

    FightUtil:printLog("calAutoZhaoQiDamageAttackValue 被动招式组合攻击气血计算: ")
    FightUtil:printLog("│├ parmas 攻击者 ：", attacker:getAttr("name"), "，受击者 ：", target:getAttr("name"))
    FightUtil:printLog("│├ parmas 招式id ：", zhaoComb:getId(), "，招式名称 ：", zhaoComb:getCombName())
    FightUtil:printLog("│├ parmas 攻击力 ：", atk)
    FightUtil:printLog("│├ parmas 攻击修正系数 ：", attackCorrectionFactor)
    FightUtil:printLog("│├ parmas 招式攻击性能 ：", attack)
    FightUtil:printLog("│├ parmas 招式攻击性能修正系数 ：", zhaoCombAttackCorrectionFactor)
    FightUtil:printLog("│├ parmas 目标防御力 ：", def)
    FightUtil:printLog("│├ parmas 防御修正系数 ：", defCorrectionFactor)
    FightUtil:printLog("│├ parmas 战斗加力值 ：", plusPoint)
    FightUtil:printLog("│├ parmas 实际加力气血伤害加成系数 ：", plusPointQiHurtFactorAddition)
    FightUtil:printLog("│├ parmas 被动普通气血伤害系数 ：", qiatkFactor)
    FightUtil:printLog("│├ parmas 伤害属性修正系数 ：", skillDamageAttrCorrectionFactor)
    FightUtil:printLog("└─ qiDamage 气血伤害 ：", qiDamage)

    return qiDamage
end

--@desc: 普通气血上限伤害
--@author:Seven
--@time:2021-07-12 18:45:06
--@qiDamage: 气血伤害
--@disabilityProbability: 伤残率
--@attacker: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@zhaoComb: [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
function FightFormula:calAutoZhaoQiMaxDamageAttackValue(qiDamage, disabilityProbability, zhaoComb, attacker, target)
    local qiMaxHurtCorrectionFactor = BattleConstConf:get("qiMaxHurtCorrectionFactor")

    -- 普通气血上限伤害 = 普通气血伤害 * 普通气血上限伤害修正系数 * 伤残率
    local value = qiDamage * qiMaxHurtCorrectionFactor * disabilityProbability

    FightUtil:printLog("calAutoZhaoQiMaxDamageAttackValue 被动招式组合攻击气血上限计算: ")
    FightUtil:printLog("│├ parmas 攻击者 ：", attacker:getAttr("name"), "，受击者 ：", target:getAttr("name"))
    FightUtil:printLog("│├ parmas 招式id ：", zhaoComb:getId(), "，招式名称 ：", zhaoComb:getCombName())
    FightUtil:printLog("│├ parmas 普通气血伤害 ：", qiDamage)
    FightUtil:printLog("│├ parmas 普通气血上限伤害修正系数 ：", qiMaxHurtCorrectionFactor)
    FightUtil:printLog("│├ parmas 伤残率 ：", disabilityProbability)
    FightUtil:printLog("└─ value 气血上限伤害 ：", value)

    return value
end

--@desc: 伤残率
--@author:Seven
--@time:2021-07-12 18:45:35
--@zhaoComb: [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
--@attacker: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightFormula:calDisabilityProbability(zhaoComb, attacker, target)
    -- * 伤害力
    local damage = attacker:getDamage()

    -- * 伤残率修正系数
    local disabledProbabilityCorrectionFactor = BattleConstConf:get("disabledProbabilityCorrectionFactor")

    -- * 目标防护力
    local targetProtect = target:getProtect()

    -- * 招式伤害性能
    local zhaoTopLimit = zhaoComb:getTopLimit()

    -- * 招式伤害性能伤残率修正系数
    local zhaoDamageDisabledProbabilityCorrectionFactor = BattleConstConf:get("zhaoDamageDisabledProbabilityCorrectionFactor")

    -- 伤残率 = 伤害力*伤残率修正系数/(目标防护力+伤害力) * (1+招式伤害性能*招式伤害性能伤残率修正系数)
    local value = damage * disabledProbabilityCorrectionFactor / (targetProtect + damage) * (1 + zhaoTopLimit * zhaoDamageDisabledProbabilityCorrectionFactor)

    local finalValue = Helper:preciseDecimal(value, 4)

    FightUtil:printLog("FightFormula:calDisabilityRate 伤残率计算: ")
    FightUtil:printLog("│├ parmas 攻击者 ：", attacker:getAttr("name"), "，受击者 ：", target:getAttr("name"))
    FightUtil:printLog("│├ parmas 招式id ：", zhaoComb:getId(), "，招式名称 ：", zhaoComb:getCombName())
    FightUtil:printLog("│├ parmas 战斗伤害力 ：", damage)
    FightUtil:printLog("│├ parmas 伤残率修正系数 ：", disabledProbabilityCorrectionFactor)
    FightUtil:printLog("│├ parmas 目标防护力 ：", targetProtect)
    FightUtil:printLog("│├ parmas 招式伤害性能 ：", zhaoTopLimit)
    FightUtil:printLog("│├ parmas 招式伤害性能伤残率修正系数 ：", zhaoDamageDisabledProbabilityCorrectionFactor)
    FightUtil:printLog("│├ value 伤残率 ：", value)
    FightUtil:printLog("└─ finalValue 伤残率 ：", finalValue)

    return finalValue
end

-- 主动气血直接伤害修正系数
function FightFormula:calActiveAttackQiHurtCorrectionFactor(attackerQiActiveAtkFactor, targetQiActiveDefFactor)
    local qiActiveFactorMin = BattleConstConf:get("qiActiveFactorMin")
    local qiActiveFactorMax = BattleConstConf:get("qiActiveFactorMax")
    -- 主动气血直接伤害修正系数 = min(max(1+攻击者主动气血直接伤害系数-受击者主动气血直接防御系数,主动气血直接伤害加成系数下限),主动气血直接伤害加成系数上限)
    local value = math.min(math.max(1 + attackerQiActiveAtkFactor - targetQiActiveDefFactor, qiActiveFactorMin), qiActiveFactorMax)
    FightUtil:printLog("active hurt calActiveAttackQiHurtCorrectionFactor 主动气血直接伤害修正系数计算: ")
    FightUtil:printLog("│├ parmas 攻击者主动气血直接伤害系数 ：", attackerQiActiveAtkFactor)
    FightUtil:printLog("│├ parmas 受击者主动气血直接防御系数 ：", targetQiActiveDefFactor)
    FightUtil:printLog("│├ parmas 主动气血直接伤害加成系数下限 ：", qiActiveFactorMin)
    FightUtil:printLog("│├ parmas 主动气血直接伤害加成系数上限 ：", qiActiveFactorMax)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveAttackHurtValue(autoAvgAtk, hurtDrgreeValue, hurtGrow, hurtBase, qiAttackHurtFactor, skillDamageAttrCorrectionFactor)
    -- (被动招式攻击均值 * 攻击伤害强度返回值 * 伤害增长倍率 + 主动基础伤害)* 主动气血直接伤害修正系数 * 伤害属性修正系数
    local value = (autoAvgAtk * hurtDrgreeValue * hurtGrow + hurtBase) * qiAttackHurtFactor * skillDamageAttrCorrectionFactor
    FightUtil:printLog("active hurt calActiveAttackHurtValue 主动招式结果值计算: ")
    FightUtil:printLog("│├ parmas 被动招式攻击均值 ：", autoAvgAtk)
    FightUtil:printLog("│├ parmas 攻击伤害强度返回值 ：", hurtDrgreeValue)
    FightUtil:printLog("│├ parmas 伤害增长倍率 ：", hurtGrow)
    FightUtil:printLog("│├ parmas 主动基础伤害 ：", hurtBase)
    FightUtil:printLog("│├ parmas 主动气血直接伤害修正系数 ：", qiAttackHurtFactor)
    FightUtil:printLog("│├ parmas 伤害属性修正系数 ：", skillDamageAttrCorrectionFactor)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

--@desc: 闪躲率
--@author:Seven
--@time:2021-07-12 14:38:52
--@zhaoComb: [src.app.FightSystem.FightSkill.AutoZhao.BasicFightAutoZhaoCombination#BasicFightAutoZhaoCombination]
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function FightFormula:calAutoZhaoDodgeProbability(zhaoComb, attacker, target)
    -- * 闪躲率计算结果范围 0~1 之间，保留4位小数，随机精度到 0.0001
    -- * 招式命中性能：读取使用的被动招式，对应 `武功被动招式组合.xlsx` 的 `命中性能;hit` 字段参数
    -- * 闪躲率修正系数、招式命中性能闪避率修正系数，读取 `战斗通用参数表.xlsx`

    -- * 闪躲率修正系数
    local dodgeProbabilityCorrectionFactor = BattleConstConf:get("dodgeProbabilityCorrectionFactor")

    -- * 目标闪躲力
    local targetDodgeForce = target:getDodgeForce()

    -- * 命中力
    local hitForce = attacker:getHitForce()

    -- * 招式命中性能
    local zhaoHit = zhaoComb:getHit()

    -- * 招式命中性能闪避率修正系数
    local zhaoHitdodgeProbabilityCorrectionFactor = BattleConstConf:get("zhaoHitdodgeProbabilityCorrectionFactor")

    -- * 测试闪躲率修正参数
    local debugParam_dodgeProbability = BattleConstConf:get("debugParam_dodgeProbability")

    -- 闪躲率 = max( 目标闪躲力*闪躲率修正系数/(目标闪躲力+命中力) * (1-招式命中性能*招式命中性能闪躲率修正系数) + 测试闪躲率修正参数 , 0)
    local value =
        math.max(targetDodgeForce * dodgeProbabilityCorrectionFactor / (targetDodgeForce + hitForce) * (1 - zhaoHit * zhaoHitdodgeProbabilityCorrectionFactor) + debugParam_dodgeProbability, 0)

    local finalValue = Helper:preciseDecimal(value, 4) * 10000

    FightUtil:printLog("calDodgeProbability 被动招式组合闪躲率计算: ")
    FightUtil:printLog("│├ parmas 攻击者 ：", attacker:getAttr("name"), "，受击者 ：", target:getAttr("name"))
    FightUtil:printLog("│├ parmas 招式id ：", zhaoComb:getId(), "，招式名称 ：", zhaoComb:getCombName())
    FightUtil:printLog("│├ parmas 目标闪躲力 ：", targetDodgeForce)
    FightUtil:printLog("│├ parmas 闪躲率修正系数 ：", dodgeProbabilityCorrectionFactor)
    FightUtil:printLog("│├ parmas 命中力 ：", hitForce)
    FightUtil:printLog("│├ parmas 招式命中性能 ：", zhaoHit)
    FightUtil:printLog("│├ parmas 招式命中性能闪避率修正系数 ：", zhaoHitdodgeProbabilityCorrectionFactor)
    FightUtil:printLog("│├ parmas 测试闪躲率修正参数 ：", debugParam_dodgeProbability)
    FightUtil:printLog("│├ value 被动招式闪躲率 ：", value)
    FightUtil:printLog("└─ finalValue 闪躲概率 ：", finalValue)

    return finalValue
end

--@desc: 普通招架率
--@author:Seven
--@time:2021-07-12 15:29:01
--@zhaoComb: [src.app.models.skill.BasicSkill.AutoZhao.BasicAutoZhaoCombination#BasicAutoZhaoCombination]
--@attacker: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@target:  [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function FightFormula:calAutoZhaoParryProbability(zhaoComb, attacker, target)
    -- * 目标招架力
    local targetParryForce = target:getParryForce()

    -- * 普通招架率修正系数
    local parryProbabilityCorrectionFactor = BattleConstConf:get("parryProbabilityCorrectionFactor")

    -- * 测试招架率修正参数
    local debugParam_parryProbability = BattleConstConf:get("debugParam_parryProbability")

    -- * 命中力
    local hitForce = target:getHitForce()

    -- 普通招架率 = max( 目标招架力*普通招架率修正系数/(目标招架力+命中力) / 100 + 测试招架率修正参数 , 0)
    local value = math.max(targetParryForce * parryProbabilityCorrectionFactor / (targetParryForce + hitForce) / 100 + debugParam_parryProbability, 0)

    local finalValue = Helper:preciseDecimal(value, 4) * 10000

    FightUtil:printLog("calAutoZhaoParryProbability 被动招式组合普通招架率计算: ")
    FightUtil:printLog("│├ parmas 攻击者 ：", attacker:getAttr("name"), "，受击者 ：", target:getAttr("name"))
    FightUtil:printLog("│├ parmas 招式id ：", zhaoComb:getId(), "，招式名称 ：", zhaoComb:getCombName())
    FightUtil:printLog("│├ parmas 目标招架力 ：", targetParryForce)
    FightUtil:printLog("│├ parmas 普通招架率修正系数 ：", parryProbabilityCorrectionFactor)
    FightUtil:printLog("│├ parmas 测试招架率修正参数 ：", debugParam_parryProbability)
    FightUtil:printLog("│├ parmas 命中力 ：", hitForce)
    FightUtil:printLog("│├ value 被动招式招架率 ：", value)
    FightUtil:printLog("└─ finalValue 招架概率 ：", finalValue)

    return finalValue
end

--@desc: 平均普通气血伤害
--@author:Seven
--@time:2021-07-12 18:00:54
--@attacker: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightFormula:calQiAvgDamage(attacker, target)
    local attackSkill = attacker:getAttackSkill()
    local zhaoComb = attackSkill:getAutoZhaoCombByLvMax()

    -- * 攻击力
    local atk = attacker:getAtk()

    -- *  攻击修正系数
    local attackCorrectionFactor = BattleConstConf:get("attackCorrectionFactor")

    -- * 招式平均攻击性能
    local attackAverage = zhaoComb:getAttackAverage()

    -- * 招式攻击性能修正系数
    local zhaoCombAttackCorrectionFactor = BattleConstConf:get("zhaoCombAttackCorrectionFactor")

    -- * 目标防御力
    local targetDef = target:getDef()

    -- * 目标默认防御力
    local targetDefaultDef = BattleConstConf:get("targetDefaultDef")

    -- * 防御修正系数
    local defCorrectionFactor = BattleConstConf:get("defCorrectionFactor")

    -- 攻击力*攻击修正系数 * (1+招式平均攻击性能*招式攻击性能修正系数) /(目标防御力*防御修正系数)
    local value = atk * attackCorrectionFactor * (1 + attackAverage * zhaoCombAttackCorrectionFactor) / (math.max(targetDef, targetDefaultDef) * defCorrectionFactor)

    FightUtil:printLog("calQiAvgDamage 平均普通气血伤害: ")
    FightUtil:printLog("│├ parmas 攻击者 ：", attacker:getAttr("name"), "，受击者 ：", target:getAttr("name"))
    FightUtil:printLog("│├ parmas 招式id ：", zhaoComb:getId(), "，招式名称 ：", zhaoComb:getCombName())
    FightUtil:printLog("│├ parmas 攻击力 ：", atk)
    FightUtil:printLog("│├ parmas 攻击修正系数 ：", attackCorrectionFactor)
    FightUtil:printLog("│├ parmas 招式平均攻击性能 ：", attackAverage)
    FightUtil:printLog("│├ parmas 招式攻击性能修正系数 ：", zhaoCombAttackCorrectionFactor)
    FightUtil:printLog("│├ parmas 目标防御力 ：", targetDef)
    FightUtil:printLog("│├ parmas 目标默认防御力 ：", targetDefaultDef)
    FightUtil:printLog("│├ parmas 防御修正系数 ：", defCorrectionFactor)
    FightUtil:printLog("└─ value 平均普通气血伤害 ：", value)

    return value
end

--@desc: 战斗平均普通气血伤害
--@author:Seven
--@time:2026-03-26 17:06:44
--@owner: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function FightFormula:calBattleQiAvgDamage(owner, target)
    local attackSkill = owner:getAttackSkill()
    local zhaoComb = attackSkill:getAutoZhaoCombByLvMax()

    -- * 攻击力
    local atk = owner:getAtk()

    -- *  攻击修正系数
    local attackCorrectionFactor = BattleConstConf:get("attackCorrectionFactor")

    -- * 招式平均攻击性能
    local attackAverage = zhaoComb:getAttackAverage()

    -- * 招式攻击性能修正系数
    local zhaoCombAttackCorrectionFactor = BattleConstConf:get("zhaoCombAttackCorrectionFactor")

    -- * 目标防御力
    local targetDef = 0
    if target ~= nil and not target:isDead() then
        targetDef = target:getDef()
    end

    -- * 目标默认防御力
    local targetDefaultDef = BattleConstConf:get("targetDefaultDef")

    -- * 防御修正系数
    local defCorrectionFactor = BattleConstConf:get("defCorrectionFactor")

    -- 战斗平均普通气血伤害 = 战斗攻击力*攻击修正系数 * (1+招式平均攻击性能*招式攻击性能修正系数) / (max(目标战斗防御力,目标默认战斗防御力)*防御修正系数)
    local value = atk * attackCorrectionFactor * (1 + attackAverage * zhaoCombAttackCorrectionFactor) / (math.max(targetDef, targetDefaultDef) * defCorrectionFactor)

    FightUtil:printLog("calBattleQiAvgDamage 战斗平均普通气血伤害: ")
    FightUtil:printLog("│├ parmas 效果执行者 ：", owner:getAttr("name"), "，效果执行者目标 ：", target and target:getAttr("name") or "目标不存在")
    FightUtil:printLog("│├ parmas 招式id ：", zhaoComb:getId(), "，招式名称 ：", zhaoComb:getCombName())
    FightUtil:printLog("│├ parmas 效果执行者战斗攻击力 ：", atk)
    FightUtil:printLog("│├ parmas 攻击修正系数 ：", attackCorrectionFactor)
    FightUtil:printLog("│├ parmas 招式平均攻击性能 ：", attackAverage)
    FightUtil:printLog("│├ parmas 招式攻击性能修正系数 ：", zhaoCombAttackCorrectionFactor)
    FightUtil:printLog("│├ parmas 效果执行者目标防御力 ：", targetDef)
    FightUtil:printLog("│├ parmas 效果执行者目标默认防御力 ：", targetDefaultDef)
    FightUtil:printLog("│├ parmas 防御修正系数 ：", defCorrectionFactor)
    FightUtil:printLog("└─ value 平均普通气血伤害 ：", value)

    return value
end

--@desc:被动招式内力消耗
--@author:Seven
--@time:2021-07-12 21:20:06
--@plusPoint: 角色实际加力值
--@buffTiliCostCorrectionFactor: buff内力消耗比例修正系数
--@buffConstCostTiliValue: buff内力消耗固值修正参数
function FightFormula:calAutoAttackNeiliCost(plusPoint, buffNeiliCostCorrectionFactor, buffConstCostNeiliValue)
    local plusPointAutoZhaoNeiliCostCorrectionFactor = BattleConstConf:get("plusPointAutoZhaoNeiliCostCorrectionFactor")

    local value = math.max(math.ceil(plusPoint * plusPointAutoZhaoNeiliCostCorrectionFactor * (1 + buffNeiliCostCorrectionFactor) + buffConstCostNeiliValue), 0)

    FightUtil:printLog("被动招式内力消耗计算：")
    FightUtil:printLog("│├ parmas 角色实际加力值 ：", plusPoint)
    FightUtil:printLog("│├ parmas 实际加力被动内力消耗修正系数 ：", plusPointAutoZhaoNeiliCostCorrectionFactor)
    FightUtil:printLog("│├ parmas buff内力消耗比例修正系数 ：", buffNeiliCostCorrectionFactor)
    FightUtil:printLog("│├ parmas buff内力消耗固值修正参数 ：", buffConstCostNeiliValue)
    FightUtil:printLog("└─ value 内力消耗 ：", value)

    return value
end

function FightFormula:calAutoAttackTiliCost(zhaoTili, buffTiliCostCorrectionFactor, buffConstCostTiliValue)
    local autoZhaoTiliCostCorrectionFactor = BattleConstConf:get("plusPointAutoZhaoNeiliCostCorrectionFactor")

    local value = math.max(math.ceil(zhaoTili * (1 + buffTiliCostCorrectionFactor) + buffConstCostTiliValue), 0)

    FightUtil:printLog("被动招式体力消耗计算：")
    FightUtil:printLog("│├ parmas 招式体力消耗 ：", zhaoTili)
    FightUtil:printLog("│├ parmas buff体力消耗比例修正系数 ：", buffTiliCostCorrectionFactor)
    FightUtil:printLog("│├ parmas buff体力消耗固值修正参数 ：", buffConstCostTiliValue)
    FightUtil:printLog("└─ value 体力消耗 ：", value)

    return value
end

--@desc: 主动技能内力消耗计算
--@author:Seven
--@time:2021-07-14 21:57:27
function FightFormula:calActiveActtackNeiliCost(neiliCost, buffNeiliCostCorrectionFactor, buffConstCostNeiliValue)
    local value = math.max(math.ceil(neiliCost * (1 + buffNeiliCostCorrectionFactor) + buffConstCostNeiliValue), 0)

    -- FightUtil:printLog("主动技能内力消耗计算：")
    -- FightUtil:printLog("│├ parmas 主动招式消耗内力值 ：" , neiliCost)
    -- FightUtil:printLog("│├ parmas buff主动内力消耗比例影响系数 ：" , buffNeiliCostCorrectionFactor)
    -- FightUtil:printLog("│├ parmas buff主动内力消耗固值影响系数 ：" , buffConstCostNeiliValue)
    -- FightUtil:printLog("└─ value 内力消耗 ：" , value)

    return value
end

--@desc: 主动技能体力消耗计算
--@author:Seven
--@time:2021-07-14 22:04:32
function FightFormula:calActiveAttackTiliCost(tiliCost, buffTiliCostCorrectionFactor, buffConstCostTiliValue)
    local value = math.max(math.ceil(tiliCost * (1 + buffTiliCostCorrectionFactor) + buffConstCostTiliValue), 0)

    -- FightUtil:printLog("主动技能体力消耗计算：")
    -- FightUtil:printLog("│├ parmas 主动招式消耗体力值 ：" , tiliCost)
    -- FightUtil:printLog("│├ parmas buff主动体力消耗比例影响系数 ：" , buffTiliCostCorrectionFactor)
    -- FightUtil:printLog("│├ parmas buff主动体力消耗固值影响系数 ：" , buffConstCostTiliValue)
    -- FightUtil:printLog("└─ value 体力消耗 ：" , value)

    return value
end

local cache_battleAction_healthy_healReduceqiMin = nil
--@desc: 恢复当前气血
--@author:Seven
--@time:2026-03-09 11:04:31
function FightFormula:calReocverQiValue(neiliMax, healthyQi, healReduceqi, healReduceqiSXBH)
    --  = ((20+neiliMax/50)*1.5*角色气血恢复力+50) * max(1-角色气血恢复抗性qi-角色气血恢复抗性SXBH, 战斗气血恢复下限)
    if cache_battleAction_healthy_healReduceqiMin == nil then
        cache_battleAction_healthy_healReduceqiMin = BattleConstConf:get("battleAction_healthy_healReduceqiMin")
    end
    local value = ((20 + neiliMax / 50) * 1.5 * healthyQi + 50) * math.max(1 - healReduceqi - healReduceqiSXBH, cache_battleAction_healthy_healReduceqiMin)
    FightUtil:printLog("恢复气血值：")
    FightUtil:printLog("│├ parmas 内力最大值 ：", neiliMax)
    FightUtil:printLog("│├ parmas 角色气血恢复力 ：", healthyQi)
    FightUtil:printLog("│├ parmas 角色气血恢复抗性qi ：", healReduceqi)
    FightUtil:printLog("│├ parmas 角色气血恢复抗性SXBH ：", healReduceqiSXBH)
    FightUtil:printLog("│├ parmas 战斗气血恢复下限 ：", cache_battleAction_healthy_healReduceqiMin)
    FightUtil:printLog("└─ value 气血值 ：", value)
    return value
end

--@desc: 伤害属性修正系数，根据指定抗性ID进行计算
--@author:Seven
--@time:2025-02-27 14:50:49
--@attacker: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@target: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
--@attackerAtkDamageClass: 攻击者伤害抗性属性类型
function FightFormula:calSkillDamageAttrCorrectionFactor(attacker, target, attackerAtkDamageClass)
    local targetParrySkill = target:getParrySkill()

    local targetParrySkillDefDamageClass = targetParrySkill:getZhaoJiaDefDamageClass()

    -- 攻击者其他系统.伤害攻击属性值
    local attackerAtkDamageClassValue = attacker:getSkillAtkResistance(attackerAtkDamageClass)

    -- 招架武学等效等级
    local targetParrySkillLevel = targetParrySkill:getLevel()

    --受击者招架武学.伤害防御属性值
    local targetZhaoJiaDefDamageParam = 0
    if targetParrySkillDefDamageClass ~= "0" and attackerAtkDamageClass == targetParrySkillDefDamageClass then
        targetZhaoJiaDefDamageParam = targetParrySkill:getZhaoJiaDefDamageParam()
    end

    --受击者其它系统.伤害防御属性值
    local targetDefDamageClassValue = target:getSkillDefResistance(attackerAtkDamageClass)

    --招架属性防御修正值
    local damageClass_zhaoJiaDef = BattleConstConf:get("damageClass_zhaoJiaDef")
    local damageClass_hurtMin = BattleConstConf:get("damageClass_hurtMin")
    local damageClass_hurtMax = BattleConstConf:get("damageClass_hurtMax")

    --伤害抗性pvp影响系数,用于pvp战斗
    -- local damageClass_PVPparam = BattleConstConf:get("damageClass_PVPparam")

    -- 伤害属性修正系数 = min(max( 1 - (受击者招架武学.伤害防御属性值*招架武学等效等级/招架属性防御修正值 + 受击者其它系统.伤害防御属性值)*伤害抗性pvp影响系数 + 攻击者其他系统.伤害攻击属性值*伤害抗性pvp影响系数, 气血属性伤害影响下限), 气血属性伤害影响上限)
    local skillDamageAttrCorrectionFactor =
        math.min(
        math.max(1 - (targetZhaoJiaDefDamageParam * targetParrySkillLevel / damageClass_zhaoJiaDef + targetDefDamageClassValue) + attackerAtkDamageClassValue, damageClass_hurtMin),
        damageClass_hurtMax
    )

    FightUtil:printTemplateLog(
        "FIGHTFORMULA_SKILL_DAMAGE_ATTR_CORRECTION_FACTOR",
        attacker:getAttr("name"),
        target:getAttr("name"),
        attackerAtkDamageClass,
        targetParrySkillDefDamageClass,
        targetZhaoJiaDefDamageParam,
        targetParrySkillLevel,
        damageClass_zhaoJiaDef,
        targetDefDamageClassValue,
        attackerAtkDamageClassValue,
        damageClass_hurtMin,
        damageClass_hurtMax,
        skillDamageAttrCorrectionFactor
    )

    return skillDamageAttrCorrectionFactor
end

--@region 伤害强度计算公式

function FightFormula:calActiveHurtDrgreeValue1001(x1, a, b, c, maxL, rmin, rmax)
    -- 1001=`min(a*x1^2+b*x1+c, maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * (x1 ^ 2) + b * x1 + c, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1001 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1002(x1, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1002=`min((a*x1+b)/(c*x1+d), maxL) * random(rmin,rmax)/100`
    local value = math.min((a * x1 + b) / (c * x1 + d), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1002 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1003(x1, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1003=`min(a*x1^3+b*x1^2+c*x1+d, maxL) * random(rmin,rmax)/100`
    local value = math.min(a * (x1 ^ 3) + b * (x1 ^ 2) + c * x1 + d, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1003 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1004(x1, a, b, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1004=`min(a*x1+b, maxL) + random(rmin,rmax)`
    local value = math.min(a * x1 + b, maxL) + randomNum
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1004 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)
    return value
end

function FightFormula:calActiveHurtDrgreeValue1005(x1, a, b, c, d, e, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1005=`min(a*x1^2+b*x1+c, maxL) * (d*x1+e) * random(rmin,rmax)/100`
    local value = math.min(a * (x1 ^ 2) + b * x1 + c, maxL) * (d * x1 + e) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1005 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)
    return value
end

function FightFormula:calActiveHurtDrgreeValue1201(x1, x2, a, b, c, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1201=`min(a*x1^2+b*x1+c, maxL) * x2 * random(rmin,rmax)/100`
    local value = math.min(a * (x1 ^ 2) + b * x1 + c, maxL) * x2 * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1201 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1202(x1, x2, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1202=`min((a+x1/b)*(c*x2+d*x1), maxL) * random(rmin,rmax)/100`
    local value = math.min((a + x1 / b) * (x2 * c + x1 * d), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1202 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1203(x1, x2, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1203=`min(a*x1+b*x2+c, maxL) * d * random(rmin,rmax)/100`
    local value = math.min(a * x1 + b * x2 + c, maxL) * d * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1203 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1204(x1, x2, a, b, c, d, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1204=`min(a*x1+b, c*x2+d) * random(rmin,rmax)/100`
    local value = math.min(a * x1 + b, c * x2 + d) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1204 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1205(x1, x2, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1205=`min((a*x1+b)*(c*x2+d), maxL) * random(rmin,rmax)/100`
    local value = math.min((a * x1 + b) * (c * x2 + d), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1205 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1206(x1, x2, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1206=`min(a*x1^2+b*x1+c*x2+d, maxL) * random(rmin,rmax)/100`
    local value = math.min(a * x1 ^ 2 + b * x1 + c * x2 + d, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1206 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1207(x1, x2, a, b, c, maxL, rmin, rmax)
    -- 1207=`min(int(a*x1+b*x2+c), maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(Helper:mathFloor(a * x1 + b * x2 + c), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1207 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1208(x1, x2, a, b, c, d, maxL, rmin, rmax)
    -- 1208=`min(a*x1+(b*x2+c)^2+d, maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + (b * x2 + c) ^ 2 + d, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1208 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1209(x1, x2, a, b, c, d, maxL, rmin, rmax)
    -- 1209=`min(a*x1+b*min(x2,d)+c, maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + b * math.min(x2, d) + c, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1209 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1210(x1, x2, a, b, c, d, maxL, rmin, rmax)
    -- 1210 = `min(a*x1^2+b*x1+c*x1*x2+d*x2, maxL) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 ^ 2 + b * x1 + c * x1 * x2 + d * x2, maxL) * randomNum / 100

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1210 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1211(x1, x2, a, b, c, d, e, maxL, rmin, rmax)
    -- 1211 = `min((a*x1+b*x2+c)*(d+e*x2), maxL) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + b * x2 + c) * (d + e * x2), maxL) * randomNum / 100

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1211 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1212(x1, x2, a, b, c, d, maxL, rmin, rmax)
    -- 1212=`min((a*x1+c)*min(b*x2+d,1), maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + c) * math.min(b * x2 + d, 1), maxL) * randomNum / 100

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1212 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1213(x1, x2, a, b, c, d, e, maxL, rmin, rmax)
    -- 1213=`min(a*x1+b,maxL)*min(c*x2+d,e) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + b, maxL) * math.min(c * x2 + d, e) * randomNum / 100

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1213 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1214(x1, x2, a, b, c, d, e, maxL, rmin, rmax)
    -- 1214=`min(a*x1+b,maxL)*min(c/x2+d,e) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + b, maxL) * math.min(c / x2 + d, e) * randomNum / 100

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1214 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1215(x1, x2, a, b, c, d, e, maxL, rmin, rmax)
    -- 1215=`min(x1^a+b,maxL)*min(c*x2+d,e) * random(rmin,rmax)/100
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(x1 ^ a + b, maxL) * math.min(c * x2 + d, e) * randomNum / 100

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1215 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1216(x1, x2, a, b, c, d, e, maxL, rmin, rmax)
    -- 1216 = `min(x1^a+b,maxL)*min(c*x2+d,e) + random(rmin,rmax)`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(x1 ^ a + b, maxL) * math.min(c * x2 + d, e) + randomNum

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1216 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1217(x1, x2, a, b, c, d, e, maxL, rmin, rmax)
    -- 1217 = `(min(a*x1+b, c)+d)  * (1+e*x2) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = (math.min(a * x1 + b, c) + d) * (1 + e * x2) * randomNum / 100

    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1217 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1401(x1, x2, x3, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1401=`min(a*x1+b*x2+c*x3+d, maxL) * random(rmin,rmax)/100`
    local value = math.min(a * x1 + b * x2 + c * x3 + d, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1401 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1402(x1, x2, x3, a, b, c, d, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 1402=`min(x1*(a+b*x2)+c,d*x3+maxL) * random(rmin,rmax)/100`
    local value = math.min(x1 * (a + b * x2) + c, d * x3 + maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1402 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1403(x1, x2, x3, a, b, c, d, maxL, rmin, rmax)
    -- 1403=`min(a*x1+b*x2+c, maxL) * min(x3,d) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + b * x2 + c, maxL) * math.min(x3, d) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1403 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1404(x1, x2, x3, a, b, c, d, e, maxL, rmin, rmax)
    -- 1404=`min((a*x1+c)*(b*x2+d)*min(x3,e), maxL) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + c) * (b * x2 + d) * math.min(x3, e), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1404 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1405(x1, x2, x3, a, b, c, d, maxL, rmin, rmax)
    -- 1405=`min((a*x1+b)*x2, maxL) * (c*x3+d) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + b) * x2, maxL) * (c * x3 + d) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1405 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1406(x1, x2, x3, a, b, c, d, e, maxL, rmin, rmax)
    -- 1406=`min(a*x1+b*x2+c, maxL) * (d*x3+e) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + b * x2 + c), maxL) * (d * x3 + e) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1406 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1407(x1, x2, x3, a, b, c, d, e, maxL, rmin, rmax)
    -- 1407=`min(a*x1+b,maxL)*min(c*x2/x3+d,e) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + b), maxL) * math.min((c * x2 / x3 + d), e) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1407 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1408(x1, x2, x3, a, b, c, d, e, maxL, rmin, rmax)
    -- 1408=`min(a*x1+b*x2+c, maxL) * (x2/460+d) * (e*x3/825+(1-e)) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + b * x2 + c), maxL) * (x2 / 460 + d) * (e * x3 / 825 + (1 - e)) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1408 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1409(x1, x2, x3, a, b, c, d, e, maxL, rmin, rmax)
    -- 1409=`(min(a*x1+b, x2)+c)  * (d*x3+e)  * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = (math.min((a * x1 + b), x2) + c) * (d * x3 + e) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1409 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1410(x1, x2, x3, a, b, c, d, e, maxL, rmin, rmax)
    -- 1410=`min(a*x1+b, maxL) * min(c+x2*d,rmax) * max(1-x3*e,rmin)`
    local value = math.min(a * x1 + b, maxL) * math.min(c + x2 * d, rmax) * math.max(1 - x3 * e, rmin)
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1410 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1601(x1, x2, x3, x4, a, b, c, d, e, maxL, rmin, rmax)
    -- 1601=`(a*x1+b) * (1+e*x2) * min(c*x3/x4+d,maxL) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = (a * x1 + b) * (1 + e * x2) * math.min(c * x3 / x4 + d, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1601 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas x4 ：", x4)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1602(x1, x2, x3, x4, a, b, c, d, e, maxL, rmin, rmax)
    -- 1602=`min(a*x1+b*x2+c,d) * min(x3,maxL) * (1+e*x4) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + b * x2 + c, d) * math.min(x3, maxL) * (1 + e * x4) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1602 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas x4 ：", x4)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1603(x1, x2, x3, x4, a, b, c, d, e, maxL, rmin, rmax)
    -- 1603=`(a*x1+b) * min(c*x2/x3+d,1) * min(x3,maxL) * (1+e*x4) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = (a * x1 + b) * math.min(c * x2 / x3 + d, 1) * math.min(x3, maxL) * (1 + e * x4) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1603 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas x4 ：", x4)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1604(x1, x2, x3, x4, a, b, c, d, e, maxL, rmin, rmax)
    -- 1604=`min((a*x1+b) * x2 + c , d*x3+c) * (1+e*x4) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + b) * x2 + c, d * x3 + c) * (1 + e * x4) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1604 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas x4 ：", x4)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue1605(x1, x2, x3, x4, a, b, c, d, e, maxL, rmin, rmax)
    -- 1605=`min(a*x1+b*x2+c*x3+d, maxL) * (1+e*x4) * random(rmin,rmax)/100`

    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + b * x2 + c * x3 + d, maxL) * (1 + e * x4) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue1605 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas x3 ：", x3)
    FightUtil:printLog("│├ parmas x4 ：", x4)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue2004(y1, a, b, maxL, rmin, rmax)
    local randomNum = FightUtil:random(rmin, rmax)
    -- 2004=`min(a*y1+b, maxL) + random(rmin,rmax)`
    local value = math.min(a * y1 + b, maxL) + randomNum
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue2004 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas y1 ：", y1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue2401(y1, y2, y3, a, b, c, d, e, maxL, rmin, rmax)
    -- 2401=`min(a*y1+b, maxL) * min(c+y2*d,rmax) * max(1-y3*e,rmin)`
    local value = math.min(a * y1 + b, maxL) * math.min(c + y2 * d, rmax) * math.max(1 - y3 * e, rmin)
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue2401 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas y1 ：", y1)
    FightUtil:printLog("│├ parmas y2 ：", y2)
    FightUtil:printLog("│├ parmas y3 ：", y3)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end
function FightFormula:calActiveHurtDrgreeValue3001(x1, y1, a, b, c, maxL, rmin, rmax)
    -- 3001 = `min(a*x1+b*y1+c, maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min(a * x1 + b * y1 + c, maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue3001 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas y1 ：", y1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue3002(x1, y1, a, b, c, d, maxL, rmin, rmax)
    -- 3002=`min((a*x1+c)*(b*y1+d), maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + c) * (b * y1 + d), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue3002 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas y1 ：", y1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue3003(x1, y1, a, b, c, d, maxL, rmin, rmax)
    -- 3003=`min((a*x1+c)*min(b*y1+d,1), maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + c) * math.min(b * y1 + d, 1), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue3003 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas y1 ：", y1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue3201(x1, x2, y1, a, b, c, e, maxL, rmin, rmax)
    -- 3201=`min((a*x1+b*x2+c)*min(y1,e), maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + b * x2 + c) * math.min(y1, e), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue3201 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas y1 ：", y1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

function FightFormula:calActiveHurtDrgreeValue3202(x1, x2, y1, a, b, c, d, e, maxL, rmin, rmax)
    -- 3202=`min((a*x1+c)*(b*x2+d)*min(y1,e), maxL) * random(rmin,rmax)/100`
    local randomNum = FightUtil:random(rmin, rmax)
    local value = math.min((a * x1 + c) * (b * x2 + d) * math.min(y1, e), maxL) * randomNum / 100
    FightUtil:printLog("active hurtDrgree calActiveHurtDrgreeValue3202 主动招式强度计算: ")
    FightUtil:printLog("│├ parmas x1 ：", x1)
    FightUtil:printLog("│├ parmas x2 ：", x2)
    FightUtil:printLog("│├ parmas y1 ：", y1)
    FightUtil:printLog("│├ parmas a ：", a)
    FightUtil:printLog("│├ parmas b ：", b)
    FightUtil:printLog("│├ parmas c ：", c)
    FightUtil:printLog("│├ parmas d ：", d)
    FightUtil:printLog("│├ parmas e ：", e)
    FightUtil:printLog("│├ parmas maxL ：", maxL)
    FightUtil:printLog("│├ parmas rmin ：", rmin)
    FightUtil:printLog("│├ parmas rmax ：", rmax)
    FightUtil:printLog("│├ parmas 随机值 ：", randomNum)
    FightUtil:printLog("└─ value 计算结果 ：", value)

    return value
end

--@endregion

return FightFormula
000000000