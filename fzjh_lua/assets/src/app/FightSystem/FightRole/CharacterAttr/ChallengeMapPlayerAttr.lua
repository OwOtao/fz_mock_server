local class = require("third.class.NewClass")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local PlayerAttr = require("app.FightSystem.FightRole.CharacterAttr.PlayerAttr")

--@SuperType [src.app.FightSystem.FightRole.CharacterAttr.BaseCharacterAttr#PlayerAttr]
local ChallengeMapPlayerAttr = {}

function ChallengeMapPlayerAttr:create(character)
    local p = self.new()
    p:init(character)
    return p
end

function ChallengeMapPlayerAttr:init(character)
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    self.__character = character
end

function ChallengeMapPlayerAttr:setNormalBuffSystem(normalBuffSystem)
    self.__normalBuffSystem = normalBuffSystem
end

function ChallengeMapPlayerAttr:__getNorBuffConstValue(attr)
    if self.__normalBuffSystem then
        if self.__normalBuffSystem:getConstAttr(attr) then
            return self.__normalBuffSystem:getConstAttr(attr)
        end
    end

    return 0
end

function ChallengeMapPlayerAttr:__getNorBuffPercentValue(attr)
    if self.__normalBuffSystem then
        if self.__normalBuffSystem:getPercentAttr(attr) then
            return self.__normalBuffSystem:getPercentAttr(attr)
        end
    end

    return 0
end

--@desc: 角色攻击力
function ChallengeMapPlayerAttr:__getAtk()
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

    -- * 常态Buff比例加成
    local normalBuffPercentAddition = self:__getNorBuffPercentValue("atk")

    -- * 常态Buff固值加成
    local normalBuffConstAddition = self:__getNorBuffConstValue("atk")

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
    --     * 经脉穴位攻击力累计值：根据经脉系统固本获得的对应属性加成总值。
    -- * 经脉穴位攻击力修正：读取 `战斗通用参数表.xlsx`

    -- 角色攻击力 = (角色等级*等级攻击修正系数 + 基本攻击武学攻击力 + 基本内功武学攻击力) * (1 + 先天臂力*先天臂力攻击比例加成 + 基本拳脚等级*基本拳脚攻击比例加成 + 常态Buff比例加成 ) + (准备攻击武学等级*准备攻击武学等级攻击力修正系数*准备攻击武学品质攻击力 + 先天臂力*角色等级/先天臂力攻击等级修正*先天臂力攻击等级臂力修正 + 经脉穴位攻击力累计值*经脉穴位攻击力修正 + 常态Buff固值加成)

    local value =
        (c_lv * atkLvCorrectionFactor + baseSkillAtk + baseNeiGongSkillAtk) * (1 + str * strAtkScaleAddition + baseQuanJiaoSkillLv * baseQuanJiaoAtkScaleAddition + normalBuffPercentAddition) +
        (prepAttackLv * prepAttackSkillAtkCorrectionFactor * prepAttackSkillQualityAtk + str * c_lv / strAtkLvCorrection * strAtkLvStrCorrection + meridianConstAtkAddition + normalBuffConstAddition)

    FightUtil:printLog("ChallengeMapPlayerAttr Attr GetAtk 攻击力: ", self:getAttr("name"))
    FightUtil:printLog("│├ parmas 角色等级 ：", c_lv)
    FightUtil:printLog("│├ parmas 等级攻击修正系数 ：", atkLvCorrectionFactor)
    FightUtil:printLog("│├ parmas 基本攻击武学攻击力 ：", baseSkillAtk)
    FightUtil:printLog("│├ parmas 基本内功武学攻击力 ：", baseNeiGongSkillAtk)
    FightUtil:printLog("│├ parmas 先天臂力 ：", str)
    FightUtil:printLog("│├ parmas 先天臂力攻击比例加成 ：", strAtkScaleAddition)
    FightUtil:printLog("│├ parmas 基本拳脚等级 ：", baseQuanJiaoSkillLv)
    FightUtil:printLog("│├ parmas 基本拳脚攻击比例加成 ：", baseQuanJiaoAtkScaleAddition)
    FightUtil:printLog("│├ parmas 经脉攻击比例加成 ：", meridianAtkAddition)
    FightUtil:printLog("│├ parmas 准备攻击武学等级 ：", prepAttackLv)
    FightUtil:printLog("│├ parmas 准备攻击武学等级攻击力修正系数 ：", prepAttackSkillAtkCorrectionFactor)
    FightUtil:printLog("│├ parmas 准备攻击武学品质攻击力 ：", prepAttackSkillQualityAtk)
    FightUtil:printLog("│├ parmas 先天臂力攻击等级修正 ：", strAtkLvCorrection)
    FightUtil:printLog("│├ parmas 先天臂力攻击等级臂力修正 ：", strAtkLvStrCorrection)
    FightUtil:printLog("│├ parmas 经脉固值攻击加成 ：", meridianConstAtkAddition)
    FightUtil:printLog("│├ parmas 常态Buff比例加成 ：", normalBuffPercentAddition)
    FightUtil:printLog("│├ parmas 常态Buff固值加成 ：", normalBuffConstAddition)
    FightUtil:printLog("└─ value  攻击力 ：", value)

    return value
end

--@desc: 防御力
function ChallengeMapPlayerAttr:__getDef()
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

    -- * 常态Buff比例加成
    local normalBuffPercentAddition = self:__getNorBuffPercentValue("def")

    -- * 常态Buff固值加成
    local normalBuffConstAddition = self:__getNorBuffConstValue("def")

    --  角色防御力 = (角色等级*等级防御修正系数 +基本招架武学防御力) * (1 + 先天身法*先天身法防御比例加成 + 基本轻功等级*基本轻功防御比例加成 + 常态Buff比例加成) + (准备招架武学等级*准备招架武学等级防御力修正系数*准备招架武学品质防御力 + 先天身法*角色等级/先天身法防御等级修正*先天身法防御等级身法修正 + 常态Buff固值加成 + 经脉穴位防御力累计值*经脉穴位防御力修正)
    local value =
        (c_lv * defLvCorrectionFactor + baseZhaoJiaDef) * (1 + dex * dexDefScaleAddition + baseDodgeSkillLv * baseDodgeDefScaleAddition + normalBuffPercentAddition) +
        (prepParrySkillLv * prepParrySkillDefCorrectionFactor * prepParrySkillQualityDef + dex * c_lv / dexDefLvCorrectionFactor * dexDefLvDexCorrectionFactor + meridianConstDefAddition +
            normalBuffConstAddition)

    FightUtil:printLog("ChallengeMapPlayerAttr Attr GetDef 防御力: ", self:getAttr("name"))
    FightUtil:printLog("│├ parmas 角色等级 ：", c_lv)
    FightUtil:printLog("│├ parmas 等级防御修正系数 ：", defLvCorrectionFactor)
    FightUtil:printLog("│├ parmas 基本招架武学防御力 ：", baseZhaoJiaDef)
    FightUtil:printLog("│├ parmas 先天身法 ：", dex)
    FightUtil:printLog("│├ parmas 先天身法防御比例加成 ：", dexDefScaleAddition)
    FightUtil:printLog("│├ parmas 基本轻功等级 ：", baseDodgeSkillLv)
    FightUtil:printLog("│├ parmas 基本轻功防御比例加成 ：", baseDodgeDefScaleAddition)
    FightUtil:printLog("│├ parmas 经脉防御比例加成 ：", meridianDefAddition)
    FightUtil:printLog("│├ parmas 准备招架武学等级 ：", prepParrySkillLv)
    FightUtil:printLog("│├ parmas 准备招架武学等级防御力修正系数 ：", prepParrySkillDefCorrectionFactor)
    FightUtil:printLog("│├ parmas 准备招架武学品质防御力 ：", prepParrySkillQualityDef)
    FightUtil:printLog("│├ parmas 先天身法防御等级修正 ：", dexDefLvCorrectionFactor)
    FightUtil:printLog("│├ parmas 先天身法防御等级身法修正 ：", dexDefLvDexCorrectionFactor)
    FightUtil:printLog("│├ parmas 经脉固值防御加成 ：", meridianConstDefAddition)
    FightUtil:printLog("│├ parmas 常态Buff比例加成 ：", normalBuffPercentAddition)
    FightUtil:printLog("│├ parmas 常态Buff固值加成 ：", normalBuffConstAddition)
    FightUtil:printLog("└─ value 防御力 ：", value)

    return value
end

--@desc: 防护力
function ChallengeMapPlayerAttr:__getProtect()
    local con = self:getAttr("con")

    -- * 先天根骨防护力修正系数：读取 `战斗通用参数表.xlsx`
    local conProtectCorrectionFactor = BattleConstConf:get("conProtectCorrectionFactor")

    -- * 基本内功武学防护力：读取 `武功基本武学等级属性.xlsx` 表
    local baseNeiGongSkillProtect = self:___getBaseNeiGongSkillProtect()

    -- * 装备防护力，身上所有装备防护力值总和
    local equipTotalProtect = self.__character:getEquipTotalProtect()

    -- * 装备防护力修正系数
    local equipmentProtectCorrectionFactor = BattleConstConf:get("equipmentProtectCorrectionFactor")

    -- * 常态Buff比例加成
    local normalBuffPercentAddition = self:__getNorBuffPercentValue("protect")

    -- * 常态Buff固值加成
    local normalBuffConstAddition = self:__getNorBuffConstValue("protect")

    -- 角色防护力 = (先天根骨*先天根骨防护力修正系数 + 基本内功武学防护力) * (1+常态Buff比例加成) + (装备防护力*装备防护力修正系数 + 常态Buff固值加成 + 经脉穴位防护力累计值*经脉穴位防护力修正)
    local protect = (con * conProtectCorrectionFactor + baseNeiGongSkillProtect) * (1 + normalBuffPercentAddition) + (equipTotalProtect * equipmentProtectCorrectionFactor + normalBuffConstAddition)

    FightUtil:printLog("ChallengeMapPlayerAttr Attr getProtect 防护力: ", self:getAttr("name"))
    FightUtil:printLog("│├ parmas 先天根骨 ：", con)
    FightUtil:printLog("│├ parmas 先天根骨防护力修正系数 ：", conProtectCorrectionFactor)
    FightUtil:printLog("│├ parmas 基本内功武学防护力 ：", baseNeiGongSkillProtect)
    FightUtil:printLog("│├ parmas 装备防护力 ：", equipTotalProtect)
    FightUtil:printLog("│├ parmas 装备防护力修正系数 ：", equipmentProtectCorrectionFactor)
    FightUtil:printLog("│├ parmas 常态Buff比例加成 ：", normalBuffPercentAddition)
    FightUtil:printLog("│├ parmas 常态Buff固值加成 ：", normalBuffConstAddition)
    FightUtil:printLog("└─ value 防御力 ：", protect)

    return protect
end

function ChallengeMapPlayerAttr:__getDodgeForce()
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

    -- * 常态Buff比例加成
    local normalBuffPercentAddition = self:__getNorBuffPercentValue("dodgeForce")

    -- * 常态Buff固值加成
    local normalBuffConstAddition = self:__getNorBuffConstValue("dodgeForce")

    --闪躲力 = (角色等级*等级闪躲力修正系数+基本轻功武学闪躲力) * (1+先天身法*先天身法闪躲力比例加成+基本轻功等级*基本轻功闪躲力比例加成+buff比例加成+经脉闪躲力比例加成) + (准备轻功武学等级*准备轻功武学等级闪躲力修正系数*准备轻功武学品质闪躲力 + buff固值闪躲力加成 + 经脉固值闪躲力加成)

    local value =
        (c_lv * dodgeForceLvCorrection + baseDodgeSkillDodgeForce) *
        (1 + dex * dexDodgeForceScaleAddition + baseDodgeSkllLv * baseDodgeDodgeForceScaleAddition + meridianDodgeForceAddition + normalBuffPercentAddition) +
        (prepDodgeSkillLv * prepDodgeSkillDodgeForceCorrectionFactor * prepDodgeSkillQualityDodgeForce + meridianConstDodgeForceAddition + normalBuffConstAddition)

    FightUtil:printLog("ChallengeMapPlayerAttr Attr getDodgeForce 闪躲力: ", self:getAttr("name"))
    FightUtil:printLog("│├ parmas 角色等级 ：", c_lv)
    FightUtil:printLog("│├ parmas 等级闪躲力修正系数 ：", dodgeForceLvCorrection)
    FightUtil:printLog("│├ parmas 基本轻功武学闪躲力 ：", baseDodgeSkillDodgeForce)
    FightUtil:printLog("│├ parmas 先天身法 ：", dex)
    FightUtil:printLog("│├ parmas 先天身法闪躲力比例加成 ：", dexDodgeForceScaleAddition)
    FightUtil:printLog("│├ parmas 基本轻功等级 ：", baseDodgeSkllLv)
    FightUtil:printLog("│├ parmas 基本轻功闪躲力比例加成 ：", baseDodgeDodgeForceScaleAddition)
    FightUtil:printLog("│├ parmas 经脉闪躲力比例加成 ：", meridianDodgeForceAddition)
    FightUtil:printLog("│├ parmas 准备轻功武学等级 ：", prepDodgeSkillLv)
    FightUtil:printLog("│├ parmas 准备轻功武学等级闪躲力修正系数 ：", prepDodgeSkillDodgeForceCorrectionFactor)
    FightUtil:printLog("│├ parmas 准备轻功武学品质闪躲力 ：", prepDodgeSkillQualityDodgeForce)
    FightUtil:printLog("│├ parmas 经脉固值闪躲力加成 ：", meridianConstDodgeForceAddition)
    FightUtil:printLog("│├ parmas 常态Buff比例加成 ：", normalBuffPercentAddition)
    FightUtil:printLog("│├ parmas 常态Buff固值加成 ：", normalBuffConstAddition)
    FightUtil:printLog("└─ value  闪躲力 ：", value)

    return value
end

function ChallengeMapPlayerAttr:__getParryForce()
    -- * 基本招架武学招架力：读取 `武功基本武学等级属性.xlsx` 表
    local baseParrySkillParryForce = self:___getBaseParrySkillParryForce()

    -- * 准备招架武学招架力：读取 `武功准备武学品质属性.xlsx` 表
    local prepParrySkillQualityParryForce = self:___getPrepParrySkillQualityParryForce()

    -- * 常态Buff比例加成
    local normalBuffPercentAddition = self:__getNorBuffPercentValue("parryForce")

    -- * 常态Buff固值加成
    local normalBuffConstAddition = self:__getNorBuffConstValue("parryForce")

    -- 角色招架力 = 基本招架武学招架力*(1+常态Buff比例加成) + (准备招架武学招架力+常态Buff固值加成)
    local parryForce = baseParrySkillParryForce * (1 + normalBuffPercentAddition) + (prepParrySkillQualityParryForce + normalBuffConstAddition)

    FightUtil:printLog("ChallengeMapPlayerAttr Attr getParryForce 招架力: ", self:getAttr("name"))
    FightUtil:printLog("│├ parmas 基本招架武学招架力 ：", baseParrySkillParryForce)
    FightUtil:printLog("│├ parmas 准备招架武学招架力 ：", prepParrySkillQualityParryForce)
    FightUtil:printLog("│├ parmas 常态Buff比例加成 ：", normalBuffPercentAddition)
    FightUtil:printLog("│├ parmas 常态Buff固值加成 ：", normalBuffConstAddition)
    FightUtil:printLog("└─ value 招架力 ：", parryForce)

    return parryForce
end

function ChallengeMapPlayerAttr:__getDamage()
    -- * 实际加力值：玩家在加力界面实际加点的值
    local plusPoint = self:getAttr("plusPoint")

    FightUtil:printLog("ChallengeMapPlayerAttr Attr __getDamage 伤害力: ", self:getAttr("name"))

    -- * 准备攻击武学品质伤害力：读取 `武功准备武学品质属性.xlsx`
    local prepAttackSkillQualityDamage = self:___getPrepAttackSkillQualityDamage()

    -- * 准备攻击武学等级伤害力修正系数：读取 `武功准备武学等级属性.xlsx`
    local prepAttackSkillDamageCorrectionFactor = self:___getPrepAttackSkillDamageCorrectionFactor()

    -- * 武器伤害力：装备武器的伤害力
    local weaponDamage = self:getAttr("wdamage")

    -- * 神兵完好度系数
    local shenbingWanHaodu = 1

    -- * 常态Buff比例加成
    local normalBuffPercentAddition = self:__getNorBuffPercentValue("damage")

    -- * 常态Buff固值加成
    local normalBuffConstAddition = self:__getNorBuffConstValue("damage")

    -- * 经脉穴位伤害力累计值
    local meridianDamage = 0

    -- * 经脉穴位伤害力修正
    local meridianDamageCorrectionFactor = 0
    
    -- * 拳脚伤害力
    local wsdamage = self:getAttr("wsdamage")

    --角色伤害力 = (实际加力值*准备攻击武学品质伤害力*准备攻击武学等级伤害力修正系数) * (1+常态Buff比例加成) + (武器伤害力*神兵完好度系数 + 常态Buff固值加成 + 经脉穴位伤害力累计值*经脉穴位伤害力修正)
    local damage =
        (plusPoint * prepAttackSkillQualityDamage * prepAttackSkillDamageCorrectionFactor) * (1 + normalBuffPercentAddition) +
        (weaponDamage * shenbingWanHaodu + normalBuffConstAddition + meridianDamage * meridianDamageCorrectionFactor  + wsdamage)

    FightUtil:printLog("│├parmas 实际加力值 ：", plusPoint)
    FightUtil:printLog("│├parmas 准备攻击武学品质伤害力 ：", prepAttackSkillQualityDamage)
    FightUtil:printLog("│├parmas 准备攻击武学等级伤害力修正系数 ：", prepAttackSkillDamageCorrectionFactor)
    FightUtil:printLog("│├parmas 武器伤害力 ：", weaponDamage)
    FightUtil:printLog("│└parmas 神兵完好度系数 ：", shenbingWanHaodu)
    FightUtil:printLog("│├ parmas 常态Buff比例加成 ：", normalBuffPercentAddition)
    FightUtil:printLog("│├ parmas 常态Buff固值加成 ：", normalBuffConstAddition)
    FightUtil:printLog("│├ parmas 经脉穴位伤害力累计值 ：", meridianDamage)
    FightUtil:printLog("│├ parmas 经脉穴位伤害力修正 ：", meridianDamageCorrectionFactor)
    FightUtil:printLog("│├ parmas 拳脚伤害力 ：", wsdamage)
    FightUtil:printLog("└─value  伤害力 ：", damage)

    return damage
end

return class("ChallengeMapPlayerAttr", {PlayerAttr}, ChallengeMapPlayerAttr)
00000000000