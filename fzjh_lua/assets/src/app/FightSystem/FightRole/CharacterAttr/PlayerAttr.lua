local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local SKILL_THIRD_TYPE = SkillConst.SkillThirdType

--@RefType [src.app.FightSystem.Configuration.BaseSkillLvAttrConf#BaseSkillLvAttrConf]
local BaseSkillLvAttrConf = require("app.FightSystem.Configuration.BaseSkillLvAttrConf")

--@RefType src.app.FightSystem.Configuration.PrepSkillLvAttrConf#PrepSkillLvAttrConf
local PrepSkillLvAttrConf = require("app.FightSystem.Configuration.PrepSkillLvAttrConf")

local BaseCharacterAttr = require("app.FightSystem.FightRole.CharacterAttr.BaseCharacterAttr")

--@SuperType [src.app.FightSystem.FightRole.CharacterAttr.BaseCharacterAttr#BaseCharacterAttr]
local PlayerAttr = {}

function PlayerAttr:create()
    return PlayerAttr.new()
end

--@desc: 角色攻击力
--@author:Seven
--@time:2021-07-14 17:48:36
function PlayerAttr:__getAtk()
    -- * 角色等级：角色当前等级
    local c_lv = self:getAttr("lv")

    -- * 角色先天臂力：角色当前先天臂力
    local str = self:getAttr("str")

    -- * 等级攻击修正系数：读取`战斗通用参数表.xlsx`
    local atkLvCorrectionFactor = BattleConstConf:get("atkLvCorrectionFactor")

    -- * 基本攻击武学攻击力：根据使用的武学，读取 `武功基本武学等级属性.xlsx` 表
    local baseSkillAtk = self:___getAttackSkillBaseSkillAtk()

    -- * 基本内功武学攻击力：读取 `武功基本武学等级属性.xlsx` 表
    local baseNeiGongSkillAtk = self:___getBaseNeiGongSkillAtk()

    -- * 先天臂力攻击比例加成：读取`战斗通用参数表.xlsx`
    local strAtkScaleAddition = BattleConstConf:get("strAtkScaleAddition")

    local baseQuanJiaoSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QUAN_JIAO)

    -- * 基本拳脚等级
    local baseQuanJiaoSkillLv = baseQuanJiaoSkill:getLevel()

    -- * 基本拳脚攻击比例加成：读取`战斗通用参数表.xlsx`
    local baseQuanJiaoAtkScaleAddition = BattleConstConf:get("baseQuanJiaoAtkScaleAddition")

    -- * 经脉攻击比例加成
    local meridianAtkAddition = 0

    local prepAttackSkill = self.__character:getPrepAttackSkill()

    -- * 准备攻击武学等级
    local prepAttackLv = 0
    if prepAttackSkill then
        prepAttackLv = prepAttackSkill:getLevel()
    end

    -- * 准备攻击武学等级攻击力修正系数：读取`武功准备武学等级属性.xlsx`
    local prepAttackSkillAtkCorrectionFactor = self:___getPrepAttackSkillAtkCorrectionFactor()

    -- * 准备攻击武学品质攻击力：读取 `武功准备武学品质属性.xlsx`
    local prepAttackSkillQualityAtk = self:___getPrepAttackSkillQualityAtk()

    -- * 先天臂力攻击等级修正：读取 `战斗通用参数表.xlsx`
    local strAtkLvCorrection = BattleConstConf:get("strAtkLvCorrection")

    -- * 先天臂力攻击等级臂力修正：读取`战斗通用参数表.xlsx`
    local strAtkLvStrCorrection = BattleConstConf:get("strAtkLvStrCorrection")

    -- * 经脉固值攻击加成
    local meridianConstAtkAddition = 0

    -- 角色当前等级
    -- 如果玩家没有准备武学，等级=0
    -- 读取 `战斗通用参数表.xlsx`
    -- 根据使用的武学，读取 `武功基本武学等级属性.xlsx`
    -- 读取 `武功基本武学等级属性.xlsx`
    -- 读取 `战斗通用参数表.xlsx`
    -- 读取 `战斗通用参数表.xlsx`
    -- 读取 `武功准备武学等级属性.xlsx`
    -- 读取 `武功准备武学品质属性.xlsx`
    -- 读取 `战斗通用参数表.xlsx`
    -- 读取 `战斗通用参数表.xlsx`

    -- 攻击力 = (角色等级*等级攻击修正系数 + 基本攻击武学攻击力 + 基本内功武学攻击力) * (1+先天臂力*先天臂力攻击比例加成+基本拳脚等级*基本拳脚攻击比例加成+经脉攻击比例加成 ) + (准备攻击武学等级*准备攻击武学等级攻击力修正系数*准备攻击武学品质攻击力 + 先天臂力*角色等级/先天臂力攻击等级修正*先天臂力攻击等级臂力修正 + 经脉固值攻击加成)

    local value =
        (c_lv * atkLvCorrectionFactor + baseSkillAtk + baseNeiGongSkillAtk) * (1 + str * strAtkScaleAddition + baseQuanJiaoSkillLv * baseQuanJiaoAtkScaleAddition + meridianAtkAddition) +
        (prepAttackLv * prepAttackSkillAtkCorrectionFactor * prepAttackSkillQualityAtk + str * c_lv / strAtkLvCorrection * strAtkLvStrCorrection + meridianConstAtkAddition)

    FightUtil:printTemplateLog(
        "PLAYERATTR_GETATK",
        self:getAttr("name"),
        c_lv,
        atkLvCorrectionFactor,
        baseSkillAtk,
        baseNeiGongSkillAtk,
        str,
        strAtkScaleAddition,
        baseQuanJiaoSkillLv,
        baseQuanJiaoAtkScaleAddition,
        meridianAtkAddition,
        prepAttackLv,
        prepAttackSkillAtkCorrectionFactor,
        prepAttackSkillQualityAtk,
        strAtkLvCorrection,
        strAtkLvStrCorrection,
        meridianConstAtkAddition,
        value
    )

    return value
end

--@desc: 战斗用攻击力
--@author:Seven
--@time:2021-07-14 18:03:10
function PlayerAttr:__getAtkBattle()
    local roleAtk = self:getAttr("atk")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("atk")

    -- * buff固值加成
    local buffConstAtkValue = self.__character:getBuffAddAttr("atk")

    local value = roleAtk * (1 + buffAddition) + buffConstAtkValue

    FightUtil:printTemplateLog("PLAYERATTR_GETATKBATTLE", self:getAttr("name"), roleAtk, buffAddition, buffConstAtkValue, value)

    return value
end

--@desc: 防御力
--@author:Seven
--@time:2021-07-14 17:50:21
function PlayerAttr:__getDef()
    --* 角色等级
    local c_lv = self:getAttr("lv")

    --* 先天身法
    local dex = self:getAttr("dex")

    --* 等级防御修正系数：读取`战斗通用参数表.xlsx`
    local defLvCorrectionFactor = BattleConstConf:get("defLvCorrectionFactor")

    --* 基本招架武学防御力：读取 `武功基本武学等级属性.xlsx` 表
    local baseZhaoJiaDef = self:___getBaseSkillZhaoJiaDef()

    --* 先天身法防御比例加成：读取`战斗通用参数表.xlsx`
    local dexDefScaleAddition = BattleConstConf:get("dexDefScaleAddition")

    local baseDodgeSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QING_GONG)

    --* 基本轻功等级
    local baseDodgeSkillLv = baseDodgeSkill:getLevel()

    -- * 基本轻功防御比例加成：读取 `战斗通用参数表.xlsx`
    local baseDodgeDefScaleAddition = BattleConstConf:get("baseDodgeDefScaleAddition")

    -- * 经脉防御比例加成
    local meridianDefAddition = 0

    local prepParrySkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.ZHAO_JIA)

    local prepParrySkillLv = 0
    -- * 准备招架武学等级
    if prepParrySkill then
        prepParrySkillLv = prepParrySkill:getLevel()
    end

    -- * 准备招架武学等级防御力修正系数：读取 `武功准备武学等级属性.xlsx`
    local prepParrySkillDefCorrectionFactor = self:___getPrepParrySkillDefCorrectionFactor()

    -- * 准备招架武学品质防御力：读取 `武功准备武学品质属性.xlsx`
    local prepParrySkillQualityDef = self:___getPrepParrySkillQualityDef()

    -- * 先天身法防御等级修正：读取 `战斗通用参数表.xlsx`
    local dexDefLvCorrectionFactor = BattleConstConf:get("dexDefLvCorrectionFactor")

    -- * 先天身法防御等级身法修正：读取 `战斗通用参数表.xlsx`
    local dexDefLvDexCorrectionFactor = BattleConstConf:get("dexDefLvDexCorrectionFactor")

    -- * 经脉固值防御加成
    local meridianConstDefAddition = 0

    --  防御力 = (角色等级*等级防御修正系数 +基本招架武学防御力) * (1+先天身法*先天身法防御比例加成+基本轻功等级*基本轻功防御比例加成+buff比例加成+经脉防御比例加成) + (准备招架武学等级*准备招架武学等级防御力修正系数*准备招架武学品质防御力 + 先天身法*角色等级/先天身法防御等级修正*先天身法防御等级身法修正 + buff固值防御加成 + 经脉固值防御加成)
    local value =
        (c_lv * defLvCorrectionFactor + baseZhaoJiaDef) * (1 + dex * dexDefScaleAddition + baseDodgeSkillLv * baseDodgeDefScaleAddition + meridianDefAddition) +
        (prepParrySkillLv * prepParrySkillDefCorrectionFactor * prepParrySkillQualityDef + dex * c_lv / dexDefLvCorrectionFactor * dexDefLvDexCorrectionFactor + meridianConstDefAddition)

    FightUtil:printFormatLog(
        "PLAYERATTR_GETDEF",
        self:getAttr("name"),
        c_lv,
        defLvCorrectionFactor,
        baseZhaoJiaDef,
        dex,
        dexDefScaleAddition,
        baseDodgeSkillLv,
        baseDodgeDefScaleAddition,
        meridianDefAddition,
        prepParrySkillLv,
        prepParrySkillDefCorrectionFactor,
        prepParrySkillQualityDef,
        dexDefLvCorrectionFactor,
        dexDefLvDexCorrectionFactor,
        meridianConstDefAddition,
        value
    )

    return value
end

--@desc: 战斗防御力
--@author:Seven
--@time:2021-07-14 18:13:21
function PlayerAttr:__getDefBattle()
    local roleDef = self:getAttr("def")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("def")

    -- * buff固值防御加成
    local buffConstDefValue = self.__character:getBuffAddAttr("def")

    local value = roleDef * (1 + buffAddition) + buffConstDefValue

    FightUtil:printTemplateLog("PLAYERATTR_GETDEFBATTLE", self:getAttr("name"), buffAddition, buffConstDefValue, value)

    return value
end

--@desc: 防护力
--@author:Seven
--@time:2021-07-14 18:16:36
function PlayerAttr:__getProtect()
    local con = self:getAttr("con")

    -- * 先天根骨防护力修正系数：读取 `战斗通用参数表.xlsx`
    local conProtectCorrectionFactor = BattleConstConf:get("conProtectCorrectionFactor")

    -- * 基本内功武学防护力：读取 `武功基本武学等级属性.xlsx` 表
    local baseNeiGongSkillProtect = self:___getBaseNeiGongSkillProtect()

    -- * 装备防护力，身上所有装备防护力值总和
    local equipTotalProtect = self.__character:getEquipTotalProtect()

    -- * 装备防护力修正系数
    local equipmentProtectCorrectionFactor = BattleConstConf:get("equipmentProtectCorrectionFactor")

    -- 防护力 = (先天根骨*先天根骨防护力修正系数 + 基本内功武学防护力) + 装备防护力 * 装备防护力修正系数
    local protect = (con * conProtectCorrectionFactor + baseNeiGongSkillProtect) + equipTotalProtect

    FightUtil:printTemplateLog("PLAYERATTR_GETPROTECT", self:getAttr("name"), con, conProtectCorrectionFactor, baseNeiGongSkillProtect, equipTotalProtect, equipmentProtectCorrectionFactor, protect)

    return protect
end

--@desc: 战斗防护力
--@author:Seven
--@time:2021-07-14 18:19:37
function PlayerAttr:__getProtectBattle()
    local role_protect = self:getAttr("protect")

    -- * buff比例防护加成
    local buffAddition = self.__character:getBuffMulAttr("protect")

    -- * buff固值防护加成
    local buffProtectValue = self.__character:getBuffAddAttr("protect")

    local value = role_protect * (1 + buffAddition) + buffProtectValue

    FightUtil:printTemplateLog("PLAYERATTR_GETPROTECTBATTLE", self:getAttr("name"), role_protect, buffAddition, buffProtectValue, value)

    return value
end

function PlayerAttr:__getHitForce()
    local c_lv = self:getAttr("lv")

    local str = self:getAttr("str")

    -- * 等级命中力修正系数：读取 `战斗通用参数表.xlsx`
    local hitForceLvCorrectionFactor = BattleConstConf:get("hitForceLvCorrectionFactor")

    -- * 先天臂力命中力比例加成：读取 `战斗通用参数表.xlsx`
    local strHitForceScaleAddition = BattleConstConf:get("strHitForceScaleAddition")

    -- * 基本拳脚命中力比例加成：读取 `战斗通用参数表.xlsx`
    local baseQuanjiaoHitForceScaleAddition = BattleConstConf:get("baseQuanjiaoHitForceScaleAddition")

    -- * 准备攻击武学等级命中力修正系数：读取 `武功准备武学等级属性.xlsx`
    local prepAttackSkillHitForceCorrectionFactor = self:___getPrepAttackSkillHitForceCorrectionFactor()

    -- * 基本攻击武学命中力：读取 `武功基本武学等级属性.xlsx` 表
    local baseAttackSkillHitForce = self:___getBaseAttackSkillHitForce()

    -- * 准备攻击武学品质命中力：读取 `武功准备武学品质属性.xlsx`
    local prepAttackSkillQualityHitForce = self:___getPrepAttackSkillQualityHitForce()

    -- * 基础拳脚等级
    local baseQuanJiaoSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
    local baseQuanJiaoLv = baseQuanJiaoSkill:getLevel()

    -- * 准备攻击武学等级
    local prepAttackSkill = self.__character:getPrepAttackSkill()
    local prepAttackLv = 0
    if prepAttackSkill then
        prepAttackLv = prepAttackSkill:getLevel()
    end

    -- * 经脉命中力比例加成
    local meridianHitForceAddition = 0

    -- * 经脉固值命中力加成
    local meridianConstHitForceAddition = 0

    -- 命中力 = (角色等级*等级命中力修正系数 + 基本攻击武学命中力) * (1+先天臂力*先天臂力命中力比例加成+基本拳脚等级*基本拳脚命中力比例加成+buff比例加成+经脉命中力比例加成) + (准备攻击武学等级*准备攻击武学等级命中力修正系数*准备攻击武学品质命中力 + buff固值命中力加成 + 经脉固值命中力加成)
    local value =
        (c_lv * hitForceLvCorrectionFactor + baseAttackSkillHitForce) * (1 + str * strHitForceScaleAddition + baseQuanJiaoLv * baseQuanjiaoHitForceScaleAddition + meridianHitForceAddition) +
        (prepAttackLv * prepAttackSkillHitForceCorrectionFactor * prepAttackSkillQualityHitForce + meridianConstHitForceAddition)

    FightUtil:printTemplateLog(
        "PLAYERATTR_GETHITFORCE",
        self:getAttr("name"),
        c_lv,
        hitForceLvCorrectionFactor,
        baseAttackSkillHitForce,
        str,
        strHitForceScaleAddition,
        baseQuanJiaoLv,
        baseQuanjiaoHitForceScaleAddition,
        meridianHitForceAddition,
        prepAttackLv,
        prepAttackSkillHitForceCorrectionFactor,
        prepAttackSkillQualityHitForce,
        meridianConstHitForceAddition,
        value
    )

    return value
end

function PlayerAttr:__getHitForceBattle()
    local roleHitForce = self:getAttr("hitForce")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("hitForce")
    -- * buff固值命中力加成
    local buffConstHitForceValue = self.__character:getBuffAddAttr("hitForce")

    local value = roleHitForce * (1 + buffAddition) + buffConstHitForceValue

    FightUtil:printTemplateLog("PLAYERATTR_GETHITFORCEBATTLE", self:getAttr("name"), roleHitForce, buffAddition, buffConstHitForceValue, value)

    return value
end

function PlayerAttr:__getDodgeForce()
    local c_lv = self:getAttr("lv")

    --* 先天身法
    local dex = self:getAttr("dex")

    -- * 等级闪躲力修正系数：读取 `战斗通用参数表.xlsx`
    local dodgeForceLvCorrection = BattleConstConf:get("dodgeForceLvCorrection")

    -- * 先天身法闪躲力比例加成：读取 `战斗通用参数表.xlsx`
    local dexDodgeForceScaleAddition = BattleConstConf:get("dexDodgeForceScaleAddition")

    -- * 基本轻功闪躲力比例加成：读取 `战斗通用参数表.xlsx`
    local baseDodgeDodgeForceScaleAddition = BattleConstConf:get("baseDodgeDodgeForceScaleAddition")

    -- * 准备轻功武学等级闪躲力修正系数：读取 `武功准备武学等级属性.xlsx`
    local prepDodgeSkillDodgeForceCorrectionFactor = self:___getPrepDodgeSkillDodgeForceCorrectionFactor()

    -- * 基本轻功武学闪躲力：读取 `武功基本武学等级属性.xlsx` 表
    local baseDodgeSkillDodgeForce = self:___getBaseDodgeSkillDodgeForce()

    -- * 准备轻功武学品质闪躲力：读取 `武功准备武学品质属性.xlsx`
    local prepDodgeSkillQualityDodgeForce = self:___getPrepDodgeSkillQualityDodgeForce()

    -- * 基本轻功等级
    local baseDodgeSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QING_GONG)
    local baseDodgeSkllLv = baseDodgeSkill:getLevel()

    -- * 准备轻功武学等级
    local prepDodgeSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QING_GONG)
    local prepDodgeSkillLv = 0
    if prepDodgeSkill then
        prepDodgeSkillLv = prepDodgeSkill:getLevel()
    end

    -- * 经脉闪躲力比例加成
    local meridianDodgeForceAddition = 0

    -- * 经脉固值闪躲力加成
    local meridianConstDodgeForceAddition = 0

    --闪躲力 = (角色等级*等级闪躲力修正系数+基本轻功武学闪躲力) * (1+先天身法*先天身法闪躲力比例加成+基本轻功等级*基本轻功闪躲力比例加成+buff比例加成+经脉闪躲力比例加成) + (准备轻功武学等级*准备轻功武学等级闪躲力修正系数*准备轻功武学品质闪躲力 + buff固值闪躲力加成 + 经脉固值闪躲力加成)

    local value =
        (c_lv * dodgeForceLvCorrection + baseDodgeSkillDodgeForce) * (1 + dex * dexDodgeForceScaleAddition + baseDodgeSkllLv * baseDodgeDodgeForceScaleAddition + meridianDodgeForceAddition) +
        (prepDodgeSkillLv * prepDodgeSkillDodgeForceCorrectionFactor * prepDodgeSkillQualityDodgeForce + meridianConstDodgeForceAddition)

    FightUtil:printTemplateLog(
        "PLAYERATTR_GETDODGEFORCE",
        self:getAttr("name"),
        c_lv,
        dodgeForceLvCorrection,
        baseDodgeSkillDodgeForce,
        dex,
        dexDodgeForceScaleAddition,
        baseDodgeSkllLv,
        baseDodgeDodgeForceScaleAddition,
        meridianDodgeForceAddition,
        prepDodgeSkillLv,
        prepDodgeSkillDodgeForceCorrectionFactor,
        prepDodgeSkillQualityDodgeForce,
        meridianConstDodgeForceAddition,
        value
    )

    return value
end

function PlayerAttr:__getDodgeForceBattle()
    local dodgeForce = self:getAttr("dodgeForce")

    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("dodgeForce")

    -- * buff固值闪躲力加成
    local buffConstDodgeForceValue = self.__character:getBuffAddAttr("dodgeForce")

    local value = dodgeForce * (1 + buffAddition) + buffConstDodgeForceValue

    FightUtil:printTemplateLog("PLAYERATTR_GETDODGEFORCEBATTLE", self:getAttr("name"), dodgeForce, buffAddition, buffConstDodgeForceValue, value)

    return value
end

function PlayerAttr:__getParryForce()
    -- * 基本招架武学招架力：读取 `武功基本武学等级属性.xlsx` 表
    local baseParrySkillParryForce = self:___getBaseParrySkillParryForce()

    -- * 准备招架武学招架力：读取 `武功准备武学品质属性.xlsx` 表
    local prepParrySkillQualityParryForce = self:___getPrepParrySkillQualityParryForce()

    -- 招架力 = (基本招架武学招架力 + 准备招架武学招架力) * (1+buff比例加成) + buff固值加成
    local parryForce = (baseParrySkillParryForce + prepParrySkillQualityParryForce) * (1)

    FightUtil:printTemplateLog("PLAYERATTR_GETPARRYFORCE", self:getAttr("name"), baseParrySkillParryForce, prepParrySkillQualityParryForce, parryForce)

    return parryForce
end

function PlayerAttr:__getParryForceBattle()
    local parryForce = self:getAttr("parryForce")
    -- * buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("parryForce")

    -- * buff固值加成
    local buffConstParryForceValue = self.__character:getBuffAddAttr("parryForce")

    local value = parryForce * (1 + buffAddition) + buffConstParryForceValue

    FightUtil:printTemplateLog("PLAYERATTR_GETPARRYFORCEBATTLE", self:getAttr("name"), parryForce, buffAddition, buffConstParryForceValue, value)

    return value
end

function PlayerAttr:__getDamage()
    -- * 实际加力值：玩家在加力界面实际加点的值 （目前该算法值只用于）
    local plusPoint = self:getAttr("plusPoint")

    FightUtil:printTemplateLog("PLAYERATTR_GETDAMAGE", self:getAttr("name"))

    local damage = self:___getPlayerDamage(plusPoint)

    return damage
end

function PlayerAttr:__getDamageBattle()
    -- * 战斗加力值
    local plusPoint = self:getAttr("plusPointBattle")

    -- * 战场Buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("damage")

    -- * 战场Buff固值加成
    local buffConstDamageForceValue = self.__character:getBuffAddAttr("damage")

    -- * 准备攻击武学品质伤害力：读取 `武功准备武学品质属性.xlsx`
    local prepAttackSkillQualityDamage = self:___getPrepAttackSkillQualityDamage()

    -- * 准备攻击武学等级伤害力修正系数：读取 `武功准备武学等级属性.xlsx`
    local prepAttackSkillDamageCorrectionFactor = self:___getPrepAttackSkillDamageCorrectionFactor()

    -- * 武器伤害力：装备武器的伤害力
    local weaponDamage = self:getAttr("wdamage")

    -- * 神兵完好度系数
    local shenbingWanHaodu = self.__character:getWeapon():getCommenceFactor()

    -- * 拳脚伤害力
    local wsdamage = self:getAttr("wsdamage")

    -- * 经脉穴位伤害力累计值
    local meridianDamage = 0

    -- * 经脉穴位伤害力修正
    local meridianDamageCorrectionFactor = 0

    -- (战斗加力值*准备攻击武学品质伤害力*准备攻击武学等级伤害力修正系数) * (1+战场Buff比例加成) + (武器伤害力*神兵完好度系数 + 战场Buff固值加成 + 经脉穴位伤害力累计值*经脉穴位伤害力修正 + 拳脚伤害力)
    local value =
        (plusPoint * prepAttackSkillQualityDamage * prepAttackSkillDamageCorrectionFactor) * (1 + buffAddition) +
        (weaponDamage * shenbingWanHaodu + buffConstDamageForceValue + meridianDamage * meridianDamageCorrectionFactor + wsdamage)

    FightUtil:printTemplateLog(
        "PLAYERATTR_GETDAMAGEBATTLE",
        self:getAttr("name"),
        plusPoint,
        prepAttackSkillQualityDamage,
        prepAttackSkillDamageCorrectionFactor,
        weaponDamage,
        shenbingWanHaodu,
        buffAddition,
        buffConstDamageForceValue,
        meridianDamage,
        meridianDamageCorrectionFactor,
        wsdamage,
        value
    )

    return value
end

--@desc: 基本攻击武学攻击力
--@author:Seven
--@time:2021-06-29 19:18:05
function PlayerAttr:___getAttackSkillBaseSkillAtk()
    local baseSkillAtk = 0
    local baseAttackSkill = self.__character:getBaseAttackSkill()
    if baseAttackSkill:isBingQiSkill() then
        baseSkillAtk = BaseSkillLvAttrConf:get(baseAttackSkill:getLevel()).atkWuqi
    elseif baseAttackSkill:isQuanJiaoSkill() then
        baseSkillAtk = BaseSkillLvAttrConf:get(baseAttackSkill:getLevel()).atkQuanjiao
    else
        assert(false, self:getAttr("name") .. " ___getAttackSkillBaseSkillAtk 获取 基本攻击武学攻击力 失败，基础武学攻击类型错误，基础武学id:" .. baseAttackSkill:getId())
    end
    return baseSkillAtk
end

--@desc: 基本内功武学攻击力
--@author:Seven
--@time:2021-06-29 19:16:36
function PlayerAttr:___getBaseNeiGongSkillAtk()
    local baseNeiGongSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)
    local baseNeiGongSkillAtk = BaseSkillLvAttrConf:get(baseNeiGongSkill:getLevel()).atkNeigong
    return baseNeiGongSkillAtk
end

--@desc: 准备攻击武学等级攻击修正系数
--@author:Seven
--@time:2021-06-29 18:58:51
function PlayerAttr:___getPrepAttackSkillAtkCorrectionFactor()
    local prepAttackSkill = self.__character:getPrepAttackSkill()

    local prepAttackSkillAtkCorrectionFactor = 0

    if prepAttackSkill ~= nil then
        if prepAttackSkill:isBingQiSkill() then
            prepAttackSkillAtkCorrectionFactor = PrepSkillLvAttrConf:get(prepAttackSkill:getLevel()).atkWuqi
        elseif prepAttackSkill:isQuanJiaoSkill() then
            prepAttackSkillAtkCorrectionFactor = PrepSkillLvAttrConf:get(prepAttackSkill:getLevel()).atkQuanjiao
        else
            assert(false, self:getAttr("name") .. " ___getPrepAttackSkillAtkCorrectionFactor 获取 准备攻击武学等级攻击修正系数 失败，准备武学攻击类型错误，基础武学id:" .. prepAttackSkill:getId())
        end
    end

    return prepAttackSkillAtkCorrectionFactor
end

--@desc:  准备攻击武学品质攻击力
--@author:Seven
--@time:2021-06-29 19:11:01
function PlayerAttr:___getPrepAttackSkillQualityAtk()
    local prepAttackSkill = self.__character:getPrepAttackSkill()

    local prepAttackSkillQualityAtk = 0

    if prepAttackSkill ~= nil then
        prepAttackSkillQualityAtk = prepAttackSkill:getBattleQualityClass():getAttr("atk")
    end

    return prepAttackSkillQualityAtk
end

--@desc: 准备招架武学品质防御力
--@author:Seven
--@time:2021-06-29 22:26:20
function PlayerAttr:___getPrepAttackSkillQualityDamage()
    local prepAttackSkill = self.__character:getPrepAttackSkill()

    local prepAttackSkillQualityDamage = 0

    if prepAttackSkill ~= nil then
        prepAttackSkillQualityDamage = prepAttackSkill:getBattleQualityClass():getAttr("damage")
    end

    return prepAttackSkillQualityDamage
end

--@desc: 准备攻击武学等级伤害力修正系数
--@author:Seven
--@time:2021-06-29 18:58:51
function PlayerAttr:___getPrepAttackSkillDamageCorrectionFactor()
    local prepAttackSkill = self.__character:getPrepAttackSkill()

    local prepAttackSkillDamageCorrectionFactor = 0

    if prepAttackSkill ~= nil then
        if prepAttackSkill:isBingQiSkill() then
            prepAttackSkillDamageCorrectionFactor = PrepSkillLvAttrConf:get(prepAttackSkill:getLevel()).damageWuqi
        elseif prepAttackSkill:isQuanJiaoSkill() then
            prepAttackSkillDamageCorrectionFactor = PrepSkillLvAttrConf:get(prepAttackSkill:getLevel()).damageQuanjiao
        else
            assert(false, self:getAttr("name") .. " __getPrepAttackSkillDamageCorrectionFactor 获取 准备攻击武学等级攻击修正系数 失败，准备武学攻击类型错误，基础武学id:" .. prepAttackSkill:getId())
        end
    end

    return prepAttackSkillDamageCorrectionFactor
end

--@desc: 基本招架武学防御力
--@author:Seven
--@time:2021-06-29 20:04:17
function PlayerAttr:___getBaseSkillZhaoJiaDef()
    local baseZhaoJiaDef = 0
    local baseParrySkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.ZHAO_JIA)
    baseZhaoJiaDef = BaseSkillLvAttrConf:get(baseParrySkill:getLevel()).defenseZhaojia
    return baseZhaoJiaDef
end

--@desc: 准备招架武学防御力修正系数
--@author:Seven
--@time:2021-06-29 20:55:02
--@return
function PlayerAttr:___getPrepParrySkillDefCorrectionFactor()
    local prepParrySkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.ZHAO_JIA)

    local prepParrySkillDefCorrectionFactor = 0

    if prepParrySkill then
        local lv = prepParrySkill:getLevel()
        prepParrySkillDefCorrectionFactor = PrepSkillLvAttrConf:get(lv).defenseZhaojia
    end

    return prepParrySkillDefCorrectionFactor
end

--@desc: 基本内功武学防护力
--@author:Seven
--@time:2021-06-29 21:42:32
function PlayerAttr:___getBaseNeiGongSkillProtect()
    local baseNeiGongSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)
    local baseNeiGongSkillProtect = BaseSkillLvAttrConf:get(baseNeiGongSkill:getLevel()).defenseNeigong
    return baseNeiGongSkillProtect
end

--@desc: 准备招架武学品质防御力
--@author:Seven
--@time:2021-06-29 22:26:20
function PlayerAttr:___getPrepParrySkillQualityDef()
    local prepParrySkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.ZHAO_JIA)

    local prepParrySkillQualityDef = 0

    if prepParrySkill ~= nil then
        prepParrySkillQualityDef = prepParrySkill:getBattleQualityClass():getAttr("def")
    end

    return prepParrySkillQualityDef
end

--@desc: 准备攻击武学等级命中力修正系数
--@author:Seven
--@time:2021-06-29 21:55:24
function PlayerAttr:___getPrepAttackSkillHitForceCorrectionFactor()
    local prepAttackSkill = self.__character:getPrepAttackSkill()

    local prepAttackSkillHitForceCorrectionFactor = 0

    if prepAttackSkill ~= nil then
        if prepAttackSkill:isBingQiSkill() then
            prepAttackSkillHitForceCorrectionFactor = PrepSkillLvAttrConf:get(prepAttackSkill:getLevel()).hitWuqi
        elseif prepAttackSkill:isQuanJiaoSkill() then
            prepAttackSkillHitForceCorrectionFactor = PrepSkillLvAttrConf:get(prepAttackSkill:getLevel()).hitQuanjiao
        else
            assert(false, self:getAttr("name") .. " ___getPrepAttackSkillHitForceCorrectionFactor 获取【准备攻击武学等级命中力修正系数】失败，准备武学攻击类型错误，基础武学id:" .. prepAttackSkill:getId())
        end
    end

    return prepAttackSkillHitForceCorrectionFactor
end

--@desc: 基本攻击武学命中力
--@author:Seven
--@time:2021-06-29 22:05:23
function PlayerAttr:___getBaseAttackSkillHitForce()
    local baseAttackSkillHitForce = 0

    local baseAttackSkill = self.__character:getBaseAttackSkill()
    if baseAttackSkill:isBingQiSkill() then
        baseAttackSkillHitForce = BaseSkillLvAttrConf:get(baseAttackSkill:getLevel()).hitWuqi
    elseif baseAttackSkill:isQuanJiaoSkill() then
        baseAttackSkillHitForce = BaseSkillLvAttrConf:get(baseAttackSkill:getLevel()).hitQuanjiao
    else
        assert(false, self:getAttr("name") .. " ___getBaseAttackSkillHitForce 获取【基本攻击武学命中力】失败，基础武学攻击类型错误，基础武学id:" .. baseAttackSkill:getId())
    end
    return baseAttackSkillHitForce
end

--@desc:  准备攻击武学品质命中力
--@author:Seven
--@time:2021-06-29 19:11:01
function PlayerAttr:___getPrepAttackSkillQualityHitForce()
    local prepAttackSkill = self.__character:getPrepAttackSkill()

    local prepAttackSkillQualityHitForce = 0

    if prepAttackSkill ~= nil then
        prepAttackSkillQualityHitForce = prepAttackSkill:getBattleQualityClass():getAttr("hit")
    end

    return prepAttackSkillQualityHitForce
end

--@desc: 准备招架武学防御力修正系数
--@author:Seven
--@time:2021-06-29 20:55:02
--@return
function PlayerAttr:___getPrepDodgeSkillDodgeForceCorrectionFactor()
    local prepDodgeSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QING_GONG)

    local prepDodgeSkillDodgeForceCorrectionFactor = 0

    if prepDodgeSkill then
        local lv = prepDodgeSkill:getLevel()
        prepDodgeSkillDodgeForceCorrectionFactor = PrepSkillLvAttrConf:get(lv).dodgeQinggong
    end

    return prepDodgeSkillDodgeForceCorrectionFactor
end

-- 基本轻功武学基础体复力
function PlayerAttr:___getBaseDodgeSkillTiliRegainBaseQinggong()
    local baseDodgeSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QING_GONG)
    local tiliRegainBaseQinggong = BaseSkillLvAttrConf:get(baseDodgeSkill:getLevel()).tiliRegainBaseQinggong
    return tiliRegainBaseQinggong
end

--@desc: 准备轻功武学品质体复力
--@author:Seven
--@time:2021-08-26 16:37:38
function PlayerAttr:___getPrepDodgeSkillQualityTiliRegain()
    local prepDodgeSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QING_GONG)

    local prepDodgeSkillQualityTiliRegain = 0

    if prepDodgeSkill ~= nil then
        prepDodgeSkillQualityTiliRegain = prepDodgeSkill:getBattleQualityClass():getAttr("tiliRegain")
    end

    return prepDodgeSkillQualityTiliRegain
end

--@desc: 基本轻功武学闪躲力
--@author:Seven
--@time:2021-06-29 19:16:36
function PlayerAttr:___getBaseDodgeSkillDodgeForce()
    local baseDodgeSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QING_GONG)
    local baseDodgeSkillDodgeForce = BaseSkillLvAttrConf:get(baseDodgeSkill:getLevel()).dodgeQuanjiao
    return baseDodgeSkillDodgeForce
end

--@desc:  准备轻功武学品质闪躲力
--@author:Seven
--@time:2021-06-29 19:11:01
function PlayerAttr:___getPrepDodgeSkillQualityDodgeForce()
    local prepDodgeSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QING_GONG)

    local prepDodgeSkillQualityDodgeForce = 0

    if prepDodgeSkill ~= nil then
        prepDodgeSkillQualityDodgeForce = prepDodgeSkill:getBattleQualityClass():getAttr("dodge")
    end

    return prepDodgeSkillQualityDodgeForce
end

--@desc: 获取【基本招架武学招架力】
--@author:Seven
--@time:2021-06-30 14:49:39
function PlayerAttr:___getBaseParrySkillParryForce()
    local baseParrySkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.ZHAO_JIA)
    local baseParrySkillParryForce = BaseSkillLvAttrConf:get(baseParrySkill:getLevel()).parryZhaojia
    return baseParrySkillParryForce
end

--@desc: 获取【准备招架武学招架力】
--@author:Seven
--@time:2021-06-30 14:52:01
function PlayerAttr:___getPrepParrySkillQualityParryForce()
    local prepParrySkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.ZHAO_JIA)

    local prepParrySkillQualityParryForce = 0

    if prepParrySkill ~= nil then
        prepParrySkillQualityParryForce = prepParrySkill:getBattleQualityClass():getAttr("parry")
    end

    return prepParrySkillQualityParryForce
end

--@desc: 准备轻功武学等级体复力比例修正系数
--@author:Seven
--@time:2021-08-26 16:50:21
function PlayerAttr:___getPrepDodgeSkillDodgeTiliRegainScaleQinggong()
    local prepDodgeSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QING_GONG)

    local prepDodgeSkillDodgeTiliRegainScale = 0

    if prepDodgeSkill then
        local lv = prepDodgeSkill:getLevel()
        prepDodgeSkillDodgeTiliRegainScale = PrepSkillLvAttrConf:get(lv).tiliRegainScaleQinggong
    end

    return prepDodgeSkillDodgeTiliRegainScale
end

--@desc: 基本轻功武学体复力固值加成
--@author:Seven
--@time:2021-08-26 16:50:32
function PlayerAttr:___getBaseDodgeSkillTiliRegainAddQinggong()
    local baseDodgeSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QING_GONG)
    local baseDodgeSkillTiliRegainAddQinggong = BaseSkillLvAttrConf:get(baseDodgeSkill:getLevel()).tiliRegainAddQinggong
    return baseDodgeSkillTiliRegainAddQinggong
end

--@desc: 准备轻功武学等级体复力固值修正系数
--@author:Seven
--@time:2021-08-26 18:32:44
function PlayerAttr:___getPrepDodgeSkillDodgeTiliRegainAddQinggong()
    local prepDodgeSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.QING_GONG)

    local prepDodgeSkillDodgeTiliRegainAddQinggong = 0

    if prepDodgeSkill then
        local lv = prepDodgeSkill:getLevel()
        prepDodgeSkillDodgeTiliRegainAddQinggong = PrepSkillLvAttrConf:get(lv).tiliRegainAddQinggong
    end

    return prepDodgeSkillDodgeTiliRegainAddQinggong
end

--@desc: 基本内功武学基础疗伤恢复力
--@author:Seven
--@time:2022-01-20 14:52:19
function PlayerAttr:___getBaseNeiGongSkillHealthyQiMax()
    local baseNeiGongSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local healthyQiMaxBaseNeigong = BaseSkillLvAttrConf:get(baseNeiGongSkill:getLevel()).healthyQiMaxBaseNeigong

    return healthyQiMaxBaseNeigong
end

--@desc:  准备内功武学品质疗伤恢复力
--@author:Seven
--@time:2021-06-29 19:11:01
function PlayerAttr:___getPrepNeiGongSkillQualityRecoveryQiMax()
    -- 根据`准备内功武学`对应`武学品质ID`读取 `表[武功准备武学品质属性].内功武学品质疗伤恢复力;recoveryQiMax`
    local prepNeiGongSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local prepNeiGongSkillQualityRecoveryQiMax = 0

    if prepNeiGongSkill ~= nil then
        prepNeiGongSkillQualityRecoveryQiMax = prepNeiGongSkill:getBattleQualityClass():getAttr("recoveryQiMax")
    end

    return prepNeiGongSkillQualityRecoveryQiMax
end

--@desc:  准备内功武学等级疗伤恢复力修正系数
--@author:Seven
--@time:2021-06-29 19:11:01
function PlayerAttr:___getPrepNeiGongSkillHealthyQiMaxForceCorrectionFactor()
    -- * 没有准备内功，等级算0
    local prepNeiGongSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local prepNeiGongSkillHealthyQiMaxForceCorrectionFactor = 0

    if prepNeiGongSkill then
        local lv = prepNeiGongSkill:getLevel()
        prepNeiGongSkillHealthyQiMaxForceCorrectionFactor = PrepSkillLvAttrConf:get(lv).healthyQiMaxNeigong
    end

    return prepNeiGongSkillHealthyQiMaxForceCorrectionFactor
end

--@desc: 基本内功武学基础打坐内力恢复力
--@author:Seven
--@time:2022-01-20 14:52:19
function PlayerAttr:___getBaseNeiGongSkillHealthyNeili()
    local baseNeiGongSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local healthyNeiliBaseNeigong = BaseSkillLvAttrConf:get(baseNeiGongSkill:getLevel()).healthyNeiliBaseNeigong

    return healthyNeiliBaseNeigong
end

--@desc: 准备内功武学品质打坐内力恢复力
--@author:Seven
--@time:2021-06-29 19:11:01
function PlayerAttr:___getPrepNeiGongSkillQualityRecoveryNeili()
    -- 根据`准备内功武学`对应`武学品质ID`读取 `表[武功准备武学品质属性].内功武学品质疗伤恢复力;recoveryQiMax`
    local prepNeiGongSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local prepNeiGongSkillQualityRecoveryNeili = 0

    if prepNeiGongSkill ~= nil then
        prepNeiGongSkillQualityRecoveryNeili = prepNeiGongSkill:getBattleQualityClass():getAttr("recoveryNeili")
    end

    return prepNeiGongSkillQualityRecoveryNeili
end

--@desc: 准备内功武学等级打坐内力恢复力修正系数
--@author:Seven
--@time:2021-06-29 19:11:01
function PlayerAttr:___getPrepNeiGongSkillHealthyNeiliForceCorrectionFactor()
    -- * 没有准备内功，等级算0
    local prepNeiGongSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local prepNeiGongSkillHealthyNeiliForceCorrectionFactor = 0

    if prepNeiGongSkill then
        local lv = prepNeiGongSkill:getLevel()
        prepNeiGongSkillHealthyNeiliForceCorrectionFactor = PrepSkillLvAttrConf:get(lv).healthyNeiliNeigong
    end

    return prepNeiGongSkillHealthyNeiliForceCorrectionFactor
end

--@desc: 角色体复力
--@author:Seven
--@time:2021-08-26 16:21:19
function PlayerAttr:___getTiliRegain()
    -- * 角色基础体复力
    local tiliRegainBaseAll = BattleConstConf:get("tiliRegainBaseAll")

    -- * 基本轻功武学基础体复力 ，读取 `武功基本武学等级属性.xlsx`
    local tiliRegainBaseQinggong = self:___getBaseDodgeSkillTiliRegainBaseQinggong()

    -- * 准备轻功武学品质体复力 ，根据武学读取 `武功准备武学品质属性.xlsx
    local tiliRegain = self:___getPrepDodgeSkillQualityTiliRegain()

    -- * 准备轻功武学等级体复力比例修正系数 ，读取 `武功准备武学等级属性.xlsx`
    local tiliRegainScaleQinggong = self:___getPrepDodgeSkillDodgeTiliRegainScaleQinggong()

    -- * 先天身法体复力比例加成修正系数 ，读取 `战斗通用参数表.xlsx`
    local dexTiliRegainScaleCorrectionFactor = BattleConstConf:get("dexTiliRegainScaleCorrectionFactor")

    -- * 基本轻功武学体复力固值加成 ，读取 `武功基本武学等级属性.xlsx`
    local baseTiliRegainAddQinggong = self:___getBaseDodgeSkillTiliRegainAddQinggong()

    -- * 准备轻功武学等级体复力固值修正系数 ，读取 `武功准备武学等级属性.xlsx`
    local prepTiliRegainAddQinggong = self:___getPrepDodgeSkillDodgeTiliRegainAddQinggong()

    -- * 先天身法体复力固值加成 ，读取 `战斗通用参数表.xlsx`
    local dexTiliRegainAddition = BattleConstConf:get("dexTiliRegainAddition")

    local dex = self.__character:getAttr("dex")

    -- 角色体复力 = (角色基础体复力+基本轻功武学基础体复力) * (1+准备轻功武学品质体复力*准备轻功武学等级体复力比例修正系数+先天身法*先天身法体复力比例加成修正系数) + (基本轻功武学体复力固值加成+准备轻功武学品质体复力*准备轻功武学等级体复力固值修正系数+先天身法*先天身法体复力固值加成)
    local value =
        (tiliRegainBaseAll + tiliRegainBaseQinggong) * (1 + tiliRegain * tiliRegainScaleQinggong + dex * dexTiliRegainScaleCorrectionFactor) +
        (baseTiliRegainAddQinggong + tiliRegain * prepTiliRegainAddQinggong + dex * dexTiliRegainAddition)

    FightUtil:printTemplateLog(
        "PLAYERATTR_GETTILIREGAIN",
        self:getAttr("name"),
        tiliRegainBaseAll,
        tiliRegainBaseQinggong,
        tiliRegain,
        tiliRegainScaleQinggong,
        dexTiliRegainScaleCorrectionFactor,
        baseTiliRegainAddQinggong,
        prepTiliRegainAddQinggong,
        dex,
        dexTiliRegainAddition,
        value
    )

    return value
end

--@desc: 角色伤害力（面板属性值【目前仅用于棋局角色】）
--@author:Seven
--@time:2022-09-20 20:53:56
--@plusPoint: 加力值
function PlayerAttr:___getPlayerDamage(plusPoint)
    -- * 准备攻击武学品质伤害力：读取 `武功准备武学品质属性.xlsx`
    local prepAttackSkillQualityDamage = self:___getPrepAttackSkillQualityDamage()

    -- * 准备攻击武学等级伤害力修正系数：读取 `武功准备武学等级属性.xlsx`
    local prepAttackSkillDamageCorrectionFactor = self:___getPrepAttackSkillDamageCorrectionFactor()

    -- * 武器伤害力：装备武器的伤害力
    local weaponDamage = self:getAttr("wdamage")

    -- * 神兵完好度系数
    local shenbingWanHaodu = 1

    -- * 常态Buff比例加成
    local normalBuffPercentAddition = 0

    -- * 常态Buff固值加成
    local normalBuffConstAddition = 0

    -- * 经脉穴位伤害力累计值
    local meridianDamage = 0

    -- * 经脉穴位伤害力修正
    local meridianDamageCorrectionFactor = 0

    -- * 拳脚伤害力
    local wsdamage = self:getAttr("wsdamage")

    --角色伤害力 = (实际加力值*准备攻击武学品质伤害力*准备攻击武学等级伤害力修正系数) * (1+常态Buff比例加成) + (武器伤害力*神兵完好度系数 + 常态Buff固值加成 + 经脉穴位伤害力累计值*经脉穴位伤害力修正)
    local damage =
        (plusPoint * prepAttackSkillQualityDamage * prepAttackSkillDamageCorrectionFactor) * (1 + normalBuffPercentAddition) +
        (weaponDamage * shenbingWanHaodu + normalBuffConstAddition + meridianDamage * meridianDamageCorrectionFactor + wsdamage)

    FightUtil:printTemplateLog(
        "PLAYERATTR_GETPLAYERDAMAGE",
        self:getAttr("name"),
        plusPoint,
        prepAttackSkillQualityDamage,
        prepAttackSkillDamageCorrectionFactor,
        weaponDamage,
        shenbingWanHaodu,
        normalBuffPercentAddition,
        normalBuffConstAddition,
        meridianDamage,
        meridianDamageCorrectionFactor,
        wsdamage,
        damage
    )

    return damage
end

function PlayerAttr:__getPlusPoint()
    local plusPoint = self.__attrs.plusPoint

    local plusPointMax = self:__getPlusPointMax()

    if plusPoint > plusPointMax then
        return plusPointMax
    end

    return plusPoint
end

--@desc: 角色体力回复速度
--@author:Seven
--@time:2021-08-27 11:29:43
function PlayerAttr:__getTiliSpeed()
    -- 角色体力回复速度(秒) = 角色体复力 * 体复力转体力恢复速度
    local tiliRegain = self:___getTiliRegain()

    -- * 体复力转体力恢复速度 ，读取 `战斗通用参数表.xlsx`
    local speedTiliRegainParam = BattleConstConf:get("speedTiliRegainParam")

    local value = tiliRegain * speedTiliRegainParam

    FightUtil:printTemplateLog("PLAYERATTR_GETTILISPEED", self:getAttr("name"), tiliRegain, speedTiliRegainParam, value)

    return value
end

--@desc: 角色疗伤恢复力
--@author:Seven
--@time:2022-01-20 11:09:04
function PlayerAttr:__getHealthyQiMax()
    -- * 基本内功武学基础疗伤恢复力：根据基本内功武学等级，读取对应 `表[武功基本武学等级属性].基本内功武学基础疗伤恢复力;healthyQiMaxBaseNeigong`
    local baseNeiGongSkillHealthyQiMax = self:___getBaseNeiGongSkillHealthyQiMax()

    -- * 准备内功武学品质疗伤恢复力：根据`准备内功武学`对应`武学品质ID`读取 `表[武功准备武学品质属性].内功武学品质疗伤恢复力;recoveryQiMax`
    local prepParrySkillQualityRecoveryQiMax = self:___getPrepNeiGongSkillQualityRecoveryQiMax()

    -- * 准备内功武学等级疗伤恢复力修正系数：根据准备内功武学等级，读取 `表[武功准备武学等级属性].准备内功武学等级疗伤恢复力修正系数;healthyQiMaxNeigong`
    local prepNeiGongSkillHealthyQiMaxForceCorrectionFactor = self:___getPrepNeiGongSkillHealthyQiMaxForceCorrectionFactor()

    -- 角色疗伤恢复力 = 基本内功武学基础疗伤恢复力 + 准备内功武学品质疗伤恢复力*准备内功武学等级疗伤恢复力修正系数
    local value = baseNeiGongSkillHealthyQiMax + prepParrySkillQualityRecoveryQiMax * prepNeiGongSkillHealthyQiMaxForceCorrectionFactor

    FightUtil:printTemplateLog(
        "PLAYERATTR_GETHEALTHYQIMAX",
        self:getAttr("name"),
        baseNeiGongSkillHealthyQiMax,
        prepParrySkillQualityRecoveryQiMax,
        prepNeiGongSkillHealthyQiMaxForceCorrectionFactor,
        value
    )

    return value
end

--@desc: 角色打坐内力恢复力
--@author:Seven
--@time:2022-01-20 11:09:04
function PlayerAttr:__getHealthyNeili()
    -- * 基本内功武学基础打坐内力恢复力：根据基本内功武学等级，读取对应 `表[武功基本武学等级属性].基本内功武学基础打坐内力恢复力;healthyNeiliBaseNeigong`
    local healthyNeiliBaseNeigong = self:___getBaseNeiGongSkillHealthyNeili()

    -- * 准备内功武学品质打坐内力恢复力：根据`准备内功武学`对应`武学品质ID`读取 `表[武功准备武学品质属性].内功武学品质打坐内力恢复力;recoveryNeili`
    local prepNeiGongSkillQualityRecoveryNeili = self:___getPrepNeiGongSkillQualityRecoveryNeili()

    -- * 准备内功武学等级打坐内力恢复力修正系数：根据准备内功武学等级，读取 `表[武功准备武学等级属性].准备内功武学等级疗伤恢复力修正系数;healthyQiMaxNeigong`
    local prepNeiGongSkillHealthyNeiliForceCorrectionFactor = self:___getPrepNeiGongSkillHealthyNeiliForceCorrectionFactor()

    -- 角色打坐内力恢复力 = 基本内功武学基础打坐内力恢复力 + 准备内功武学品质打坐内力恢复力*准备内功武学等级打坐内力恢复力修正系数
    local value = healthyNeiliBaseNeigong + prepNeiGongSkillQualityRecoveryNeili * prepNeiGongSkillHealthyNeiliForceCorrectionFactor

    FightUtil:printTemplateLog("PLAYERATTR_HEALTHYNEILI", self:getAttr("name"), healthyNeiliBaseNeigong, prepNeiGongSkillQualityRecoveryNeili, prepNeiGongSkillHealthyNeiliForceCorrectionFactor, value)

    return value
end

return class("PlayerAttr", {BaseCharacterAttr}, PlayerAttr)
000000