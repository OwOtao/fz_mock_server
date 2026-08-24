local newClass = require("third.class.NewClass")

local ABasicCharacterFuncSystem = require("app.FightSystem.FightRole.BasicFuncSystem.ABasicCharacterFuncSystem")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local ICharacterAttr = require("app.FightSystem.FightRole.CharacterAttr.ICharacterAttr")

local BattleConstConf = require("app.FightSystem.Configuration.BattleConstConf")

local PrepSkillLvAttrConf = require("app.FightSystem.Configuration.PrepSkillLvAttrConf")

local BaseSkillLvAttrConf = require("app.FightSystem.Configuration.BaseSkillLvAttrConf")

local BasicSkill = require("app.models.skill.BasicSkill.BasicSkill")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local addAttrFuncMap = {
    qi = "__addQi",
    qiMax = "__addQiMax",
    neili = "__addNeili",
    tili = "__addTili"
}

local setFuncNameCache = {}

local getFuncNameCache = {}

--@SuperType [src.app.FightSystem.FightRole.CharacterAttr.ICharacterAttr#ICharacterAttr]
local BaseCharacterAttr = {
    __attrCache = {},
    __attrs = {
        id = -1,
        lv = 1,
        name = "",
        jingMax = 0,
        qi = 0,
        qiMax = 0,
        qiLimit = 0,
        neili = 0,
        neiliMax = 0,
        neiliLimit = 0,
        age = 1,
        zhengqi = 0,
        sex = "男",
        looks = 1,
        tili = 0,
        tiliSpeed = BattleConstConf:get("tiliSpeed"),
        -- 先天臂力
        str = 0,
        -- 先天身法
        dex = 0,
        -- 先天根骨
        con = 0,
        -- 先天悟性
        int = 0,
        --@desc 加力值
        plusPoint = 0,
        strCondGWeapon = 0,
        dexCondGWeapon = 0,
        conCondGWeapon = 0,
        intCondGWeapon = 0,
        strCondSkill = 0,
        dexCondSkill = 0,
        conCondSkill = 0,
        intCondSkill = 0,
        --@desc 武练值
        fdamage = 0,
        qiatkFactor = 0,
        parryHurtFixRateFactor = 0,
        recordDamage = 0,
        qiActiveAtkFactor = 0,
        qiActiveDefFactor = 0
    }
}

function BaseCharacterAttr:onInit()
end

function BaseCharacterAttr:onDestory()
end

function BaseCharacterAttr:onUpdate(ft)
end

function BaseCharacterAttr:setAttr(name, value)
    local setFuncName = setFuncNameCache[name]

    if setFuncName == nil then
        setFuncName = string.format("__set%s", string.gsub(name, "^%l", string.upper))
        setFuncNameCache[name] = setFuncName
    end

    if self[setFuncName] ~= nil then
        return self[setFuncName](self, value)
    end

    error(string.format("角色属性：%s 不支持修改或未定义", name))
end

function BaseCharacterAttr:getAttr(name)
    local getFuncName = getFuncNameCache[name]
    if getFuncName == nil then
        getFuncName = string.format("__get%s", string.gsub(name, "^%l", string.upper))
        getFuncNameCache[name] = getFuncName
    end

    local cacheValue = self.__attrCache[name]
    if cacheValue ~= nil then
        return cacheValue
    end

    if self[getFuncName] ~= nil then
        return self[getFuncName](self)
    end

    error(string.format("角色属性：%s 不支持读取或未定义", name))
end

function BaseCharacterAttr:addAttr(name, value)
    self:setAttr(name, self:getAttr(name) + value)

    return value
end

function BaseCharacterAttr:__setId(value)
    -- value 不可包含"|"
    if string.find(value, "|") then
        error("角色ID不可包含特殊字符|")
    end
    self.__attrs.id = value

    self.__attrCache["id"] = value
end

function BaseCharacterAttr:__getId()
    return self.__attrs.id
end

function BaseCharacterAttr:__setName(value)
    self.__attrs.name = value

    self.__attrCache["name"] = value
end

function BaseCharacterAttr:__getName()
    return self.__attrs.name
end

function BaseCharacterAttr:__setLv(value)
    self.__attrs.lv = value

    self.__attrCache["lv"] = value
end

function BaseCharacterAttr:__getLv()
    return self.__attrs.lv
end

function BaseCharacterAttr:__setStr(value)
    self.__attrs.str = value
end

function BaseCharacterAttr:__getStr()
    return self.__attrs.str
end

function BaseCharacterAttr:__setDex(value)
    self.__attrs.dex = value
end

function BaseCharacterAttr:__getDex()
    return self.__attrs.dex
end

function BaseCharacterAttr:__setCon(value)
    self.__attrs.con = value
end

function BaseCharacterAttr:__getCon()
    return self.__attrs.con
end

function BaseCharacterAttr:__setInt(value)
    self.__attrs.int = value
end

function BaseCharacterAttr:__getInt()
    return self.__attrs.int
end

function BaseCharacterAttr:__setAge(value)
    self.__attrs.age = value
end

function BaseCharacterAttr:__getAge()
    return self.__attrs.age
end

function BaseCharacterAttr:__setZhengqi(value)
    self.__attrs.zhengqi = value
end

function BaseCharacterAttr:__getZhengqi()
    return self.__attrs.zhengqi
end

function BaseCharacterAttr:__setSex(value)
    self.__attrs.sex = value
end

function BaseCharacterAttr:__getSex()
    return self.__attrs.sex
end

function BaseCharacterAttr:__setLooks(value)
    self.__attrs.looks = value
end

function BaseCharacterAttr:__getLooks()
    return self.__attrs.looks
end

function BaseCharacterAttr:__setQi(value)
    self.__attrs.qi = value
end

function BaseCharacterAttr:__getQi()
    return self.__attrs.qi
end

function BaseCharacterAttr:__setQiMax(value)
    self.__attrs.qiMax = value
end

function BaseCharacterAttr:__getQiMax()
    return self.__attrs.qiMax
end

function BaseCharacterAttr:__setQiLimit(value)
    self.__attrs.qiLimit = value
end

--@desc: 战斗用气血最大值
--@author:Seven
--@time:2021-07-19 10:47:43
function BaseCharacterAttr:__getQiLimitBattle()
    local qiLimit = self:getAttr("qiLimit")

    -- * buff比例防护加成
    local buffAddition = self.__character:getBuffMulAttr("qiLimit")

    -- * buff固值防护加成
    local buffQiLimitConstValue = self.__character:getBuffAddAttr("qiLimit")

    local value = qiLimit * (1 + buffAddition) + buffQiLimitConstValue

    return value
end

function BaseCharacterAttr:__getQiLimit()
    return self.__attrs.qiLimit
end

function BaseCharacterAttr:__setNeili(value)
    self.__attrs.neili = value
end

function BaseCharacterAttr:__getNeili()
    return self.__attrs.neili
end

function BaseCharacterAttr:__setNeiliMax(value)
    self.__attrs.neiliMax = value
end

function BaseCharacterAttr:__getNeiliMax()
    return self.__attrs.neiliMax
end

function BaseCharacterAttr:__setNeiliLimit(value)
    self.__attrs.neiliLimit = value
end

function BaseCharacterAttr:__getNeiliLimit()
    return self.__attrs.neiliLimit
end

function BaseCharacterAttr:__setTiliSpeed(value)
    self.__attrs.tiliSpeed = value
end

function BaseCharacterAttr:__getWeaponWeightByStrFactor()
    -- 武器重量
    local weaponWeight = self.__character:getWeapon():getWeight()

    local value = 0
    -- 普通武器重量为0
    if weaponWeight == 0 then
        value = 1
    end

    -- 先天臂力
    local str = self:getAttr("str")

    -- 基本拳脚等级
    local lv = self.__character:getBaseSkill(SKILL_SECOND_TYPE.QUAN_JIAO):getLevel()

    -- 判断值 = 先天臂力+int（基本拳脚等级/10）+其他系统加成臂力
    local judgeValue = str + math.floor(lv / 10)
    if judgeValue >= weaponWeight * 10 then
        -- Addvalue = math.min（（武器重量/50）,0.2）
        value = 1 + math.min(weaponWeight / 50, 0.2)
    elseif judgeValue > weaponWeight * 5 then
        value = 1
    elseif judgeValue > weaponWeight * 2 then
        value = 1 + -math.min(weaponWeight / 100, 0.05)
    elseif judgeValue > weaponWeight then
        value = 1 + -math.min(weaponWeight / 100, 0.1)
    elseif judgeValue > weaponWeight / 2 then
        value = 1 + -math.min(weaponWeight / 200, 0.15)
    else
        value = 1 + -math.min(weaponWeight / 100, 0.2)
    end

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETWEAPONWEIGHTBYSTRFACTOR", self:getAttr("name"), weaponWeight, str, lv, judgeValue, value)

    return value
end

function BaseCharacterAttr:__getWeightCapacity()
    local weightCapacityBase = BattleConstConf:get("weightCapacityBase")

    local weaponWeightByStrFactor = self:getAttr("weaponWeightByStrFactor")

    local value = weightCapacityBase + weaponWeightByStrFactor

    return value
end

function BaseCharacterAttr:__getTiliSpeedBattle()
    local tiliSpeed = self:getAttr("tiliSpeed")

    -- * Buff比例加成
    local buffAddition = self.__character:getBuffMulAttr("tiliSpeedBattle")

    -- * Buff固值加成
    local buffTiliSpeedConstValue = self.__character:getBuffAddAttr("tiliSpeedBattle")

    -- * 角色负重影响值
    local weightCapacity = self:__getWeightCapacity()

    local value = math.max((tiliSpeed * (1 + buffAddition) + buffTiliSpeedConstValue), 0) * weightCapacity

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETTILISPEEDBATTLE", self:getAttr("name"), tiliSpeed, buffAddition, buffTiliSpeedConstValue, weightCapacity, value)

    return value
end

function BaseCharacterAttr:__getNeiliLimitBattle()
    local neiliLimit = self:getAttr("neiliLimit")

    -- * buff比例防护加成
    local buffAddition = self.__character:getBuffMulAttr("neiliLimit")

    -- * buff固值防护加成
    local buffNeiliLimitConstValue = self.__character:getBuffAddAttr("neiliLimit")

    local value = neiliLimit * (1 + buffAddition) + buffNeiliLimitConstValue

    return value
end

function BaseCharacterAttr:__setTili(value)
    self.__attrs.tili = value
end

function BaseCharacterAttr:__getTili()
    return self.__attrs.tili
end

function BaseCharacterAttr:__getTiliMax()
    return BattleConstConf:get("tiliMax")
end

function BaseCharacterAttr:__setPlusPoint(value)
    self.__attrs.plusPoint = value
end

function BaseCharacterAttr:__getPlusPointBattle()
    --@desc 实际加力值
    local plusPoint = self:getAttr("plusPoint")

    local buffAddition = self.__character:getBuffMulAttr("plusPoint")

    local buffConstPlusPoint = self.__character:getBuffAddAttr("plusPoint")

    local plusPointValue

    local currNeili = self:getAttr("neili")
    if plusPoint == 0 then
        plusPointValue = 0
    elseif plusPoint > currNeili then
        plusPointValue = math.ceil(currNeili / (plusPoint * (1 + buffAddition) + buffConstPlusPoint) * plusPoint)
    elseif plusPoint <= currNeili then
        plusPointValue = plusPoint * (1 + buffAddition) + buffConstPlusPoint
    end

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETPLUSPOINTBATTLE", self:getAttr("name"), plusPoint, buffAddition, buffConstPlusPoint, currNeili, plusPointValue)

    return plusPointValue
end

function BaseCharacterAttr:__setStrCondGWeapon(value)
    self.__attrs.strCondGWeapon = value
end

function BaseCharacterAttr:__getStrCondGWeapon()
    return self.__attrs.strCondGWeapon
end

function BaseCharacterAttr:__setDexCondGWeapon(value)
    self.__attrs.dexCondGWeapon = value
end

function BaseCharacterAttr:__getDexCondGWeapon()
    return self.__attrs.dexCondGWeapon
end

function BaseCharacterAttr:__setConCondGWeapon(value)
    self.__attrs.conCondGWeapon = value
end

function BaseCharacterAttr:__getConCondGWeapon()
    return self.__attrs.conCondGWeapon
end

function BaseCharacterAttr:__setIntCondGWeapon(value)
    self.__attrs.intCondGWeapon = value
end

function BaseCharacterAttr:__getIntCondGWeapon()
    return self.__attrs.intCondGWeapon
end

function BaseCharacterAttr:__setStrCondSkill(value)
    self.__attrs.strCondSkill = value
end

function BaseCharacterAttr:__getStrCondSkill()
    return self.__attrs.strCondSkill
end

function BaseCharacterAttr:__setDexCondSkill(value)
    self.__attrs.dexCondSkill = value
end

function BaseCharacterAttr:__getDexCondSkill()
    return self.__attrs.dexCondSkill
end

function BaseCharacterAttr:__setConCondSkill(value)
    self.__attrs.conCondSkill = value
end

function BaseCharacterAttr:__getConCondSkill()
    return self.__attrs.conCondSkill
end

function BaseCharacterAttr:__setIntCondSkill(value)
    self.__attrs.intCondSkill = value
end

function BaseCharacterAttr:__getIntCondSkill()
    return self.__attrs.intCondSkill
end

function BaseCharacterAttr:__getWdamage()
    local wDamage = self.__character:getWeapon():getDamage()
    local value = wDamage + self:getAttr("wdamageRole")

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETWDAMAGE", self:getAttr("name"), wDamage, value)

    return value
end

--@desc: 角色武器伤害力
--@author:Seven
--@time:2022-01-12 18:00:58
function BaseCharacterAttr:__getWdamageRole()
    -- * Buff固值加成
    local buffConstValue = self.__character:getBuffAddAttr("wdamageRole")

    local value = 0 + buffConstValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETWDAMAGEROLE", self:getAttr("name"), 0, buffConstValue, value)

    return value
end

--@desc: 角色气血恢复抗性qi
--@author:Seven
--@time:2022-01-12 18:01:21
function BaseCharacterAttr:__getHealReduceqi()
    -- * Buff固值加成
    local buffConstValue = self.__character:getBuffAddAttr("healReduceqi")
    local value = 0 + buffConstValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCEQI", self:getAttr("name"), 0, buffConstValue, value)

    return value
end

--@desc: 角色内力恢复抗性
--@author:Seven
--@time:2022-01-20 11:08:06
function BaseCharacterAttr:__getHealReduceneili()
    -- * Buff固值加成
    local buffConstValue = self.__character:getBuffAddAttr("healReduceneili")
    local value = 0 + buffConstValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCENEILI", self:getAttr("name"), 0, buffConstValue, value)

    return value
end

--@desc: 角色气血恢复抗性-属性变化类
--@author:Seven
--@time:2026-01-10
function BaseCharacterAttr:__getHealReduceqiSXBH()
    local buffConstValue = self.__character:getBuffAddAttr("healReduceqiSXBH")
    local value = 0 + buffConstValue
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCEQISXBH", self:getAttr("name"), 0, buffConstValue, value)
    return value
end

--@desc: 角色气血恢复抗性-伤害转气血类
--@author:Seven
--@time:2026-01-10
function BaseCharacterAttr:__getHealReduceqiSHZQX()
    local buffConstValue = self.__character:getBuffAddAttr("healReduceqiSHZQX")
    local value = 0 + buffConstValue
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCEQISHZQX", self:getAttr("name"), 0, buffConstValue, value)
    return value
end

--@desc: 角色气血恢复抗性-闪耀类
--@author:Seven
--@time:2026-01-10
function BaseCharacterAttr:__getHealReduceqiSY()
    local buffConstValue = self.__character:getBuffAddAttr("healReduceqiSY")
    local value = 0 + buffConstValue
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCEQISY", self:getAttr("name"), 0, buffConstValue, value)
    return value
end

--@desc: 角色气血恢复抗性-架御类
--@author:Seven
--@time:2026-01-10
function BaseCharacterAttr:__getHealReduceqiJY()
    local buffConstValue = self.__character:getBuffAddAttr("healReduceqiJY")
    local value = 0 + buffConstValue
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCEQIJY", self:getAttr("name"), 0, buffConstValue, value)
    return value
end

--@desc: 角色内力恢复抗性-属性变化类
--@author:Seven
--@time:2026-01-10
function BaseCharacterAttr:__getHealReduceneiliSXBH()
    local buffConstValue = self.__character:getBuffAddAttr("healReduceneiliSXBH")
    local value = 0 + buffConstValue
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCENEILISXBH", self:getAttr("name"), 0, buffConstValue, value)
    return value
end

--@desc: 角色内力恢复抗性-闪烁类
--@author:Seven
--@time:2026-01-10
function BaseCharacterAttr:__getHealReduceneiliSS()
    local buffConstValue = self.__character:getBuffAddAttr("healReduceneiliSS")
    local value = 0 + buffConstValue
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCENEILISS", self:getAttr("name"), 0, buffConstValue, value)
    return value
end

--@desc: 角色内力恢复抗性-架势类
--@author:Seven
--@time:2026-01-10
function BaseCharacterAttr:__getHealReduceneiliJS()
    local buffConstValue = self.__character:getBuffAddAttr("healReduceneiliJS")
    local value = 0 + buffConstValue
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALREDUCENEILIJS", self:getAttr("name"), 0, buffConstValue, value)
    return value
end

--@desc:基本内功武学基础气血恢复力
--@author:Seven
--@time:2022-01-19 18:50:33
function BaseCharacterAttr:___getBaseNeiGongSkillHealthyQi()
    local baseNeiGongSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)
    local value = BaseSkillLvAttrConf:get(baseNeiGongSkill:getLevel()).healthyQiBaseNeigong
    return value
end

--@desc: 准备内功武学品质气血恢复力
--@author:Seven
--@time:2022-01-19 18:44:20
function BaseCharacterAttr:___getPrepNeiGongSkillQualityRecoveryQixue()
    local value = 0
    local prepNeiGongSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)
    if prepNeiGongSkill then
        value = prepNeiGongSkill:getBattleQualityClass():getAttr("recoveryQixue")
    end

    return value
end

--@desc: 准备内功武学等级气血恢复力修正系数
--@author:Seven
--@time:2022-01-19 18:47:52
function BaseCharacterAttr:___getPrepNeiGongSkillLvHealthyQiBaseCorrectionFactor()
    local value = 0
    local prepNeiGongSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)
    if prepNeiGongSkill then
        value = PrepSkillLvAttrConf:get(prepNeiGongSkill:getLevel()).healthyQiNeigong
    end

    return value
end

--@desc: 角色气血恢复力
--@author:Seven
--@time:2022-01-16 16:13:33
function BaseCharacterAttr:__getHealthyQi()
    -- * 基本内功武学基础气血恢复力：根据基本内功武学等级，读取对应 `表[武功基本武学等级属性].基本内功武学基础气血恢复力;healthyQiBaseNeigong`
    local baseNeiGongHealthyQi = self:___getBaseNeiGongSkillHealthyQi()

    -- * 准备内功武学品质气血恢复力：根据`准备内功武学`对应`武学品质ID`读取 `表[武功准备武学品质属性].内功武学品质气血恢复力;recoveryQixue`
    local recoveryQixueValue = self:___getPrepNeiGongSkillQualityRecoveryQixue()

    -- * 准备内功武学等级气血恢复力修正系数：根据准备内功武学等级，读取 `表[武功准备武学等级属性].准备内功武学等级气血恢复力修正系数;healthyQiNeigong`
    local healthyQiNeigong = self:___getPrepNeiGongSkillLvHealthyQiBaseCorrectionFactor()

    -- 基本内功武学基础气血恢复力 + 准备内功武学品质气血恢复力 * 准备内功武学等级气血恢复力修正系数
    local value = baseNeiGongHealthyQi + recoveryQixueValue * healthyQiNeigong

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETHEALTHYQI", self:getAttr("name"), baseNeiGongHealthyQi, recoveryQixueValue, healthyQiNeigong, value)

    return value
end

function BaseCharacterAttr:__getJingMax()
    return self.__attrs.jingMax
end

function BaseCharacterAttr:__setJingMax(value)
    self.__attrs.jingMax = value
end

function BaseCharacterAttr:__addNeili(value)
    local n_neili = self:getAttr("neili")

    local neiliLimit = self:getAttr("neiliLimit")

    local realNeili = n_neili + value

    if realNeili > neiliLimit then
        realNeili = neiliLimit
    elseif realNeili < 0 then
        realNeili = 0
    end

    self:setAttr("neili", realNeili)

    local realAddValue = realNeili - n_neili

    return realAddValue
end

function BaseCharacterAttr:__addQiMax(value)
    --@desc 气血最大上限
    local qiLimit = self:getAttr("qiLimitBattle")

    local n_qiMax = self:getAttr("qiMax")

    local realQiMax = n_qiMax + value

    if realQiMax > qiLimit then
        realQiMax = qiLimit
    elseif realQiMax < 0 then
        realQiMax = 0
    end

    local n_qi = self:getAttr("qi")
    if n_qi > realQiMax then
        self:setAttr("qi", realQiMax)
    end

    self:setAttr("qiMax", realQiMax)

    local realAddValue = realQiMax - n_qiMax

    return realAddValue
end

function BaseCharacterAttr:__addQi(value)
    local n_qi = self:getAttr("qi")

    local realValue = n_qi + value

    local qiMaxValue = self:getAttr("qiMax")

    if realValue > qiMaxValue then
        realValue = qiMaxValue
    elseif realValue < 0 then
        realValue = 0
    end

    self:setAttr("qi", realValue)

    local realAddValue = realValue - n_qi

    return realAddValue
end

function BaseCharacterAttr:__addTili(value)
    local n_tili = self:getAttr("tili")

    local realValue = n_tili + value

    local tiliMax = tonumber(BattleConstConf:get("tiliMax"))

    if realValue > tiliMax then
        realValue = tiliMax
    elseif realValue < 0 then
        realValue = 0
    end

    self:setAttr("tili", realValue)

    local realAddValue = realValue - n_tili

    return realAddValue
end

function BaseCharacterAttr:__getFragile1Num()
    -- * Buff固值加成
    local buffConstValue = self.__character:getBuffAddAttr("fragile1Num")
    local value = 0 + buffConstValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETFRAGILE1NUM", self:getAttr("name"), 0, buffConstValue, value)

    return value
end

function BaseCharacterAttr:__getAugment1Num()
    -- * Buff固值加成
    local buffConstValue = self.__character:getBuffAddAttr("augment1Num")
    local value = 0 + buffConstValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETAUGMENT1NUM", self:getAttr("name"), 0, buffConstValue, value)

    return value
end

function BaseCharacterAttr:__getFdamage()
    local fistFootValue = self.__character:getFistFootFdamage()

    local value = fistFootValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETFDAMAGE", self:getAttr("name"), fistFootValue, value)

    return value
end

function BaseCharacterAttr:__getWsdamage()
    local fdamage = self:getAttr("fdamage")

    -- fdamage伤害力修正系数
    local wushufdamageCorrectionFactor = BattleConstConf:get("wushufdamageCorrectionFactor")

    local value = fdamage * wushufdamageCorrectionFactor

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETWSDAMAGE", self:getAttr("name"), fdamage, wushufdamageCorrectionFactor, value)

    return value
end

--@desc: 角色谙技值
--@author:Seven
--@time:2022-12-21 11:17:25
function BaseCharacterAttr:__getJqdamage()
    local f_jqdamage = self.__character:getFistFootJqdamage()

    local value = f_jqdamage

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETJQDAMAGE", self:getAttr("name"), f_jqdamage, value)

    return value
end

--@desc: 主手拳脚武学分支谙技值
--@author:Seven
--@time:2022-12-21 15:43:13
function BaseCharacterAttr:__getCurrjqdamage()
    local value = 0

    local f_jqdamage = 0

    if self.__character:weaponIsEmptyHand() then
        local prep_skill = self:getPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO)
        if prep_skill then
            local skillTypes = prep_skill:getSkillTypes()

            for _, skill_type_id in ipairs(skillTypes) do
                if BasicSkill.IsAttackType(skill_type_id) then
                    value = self.__character:getFistFootJqdamageByType(skill_type_id)
                    break
                end
            end
        end
    end

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETCURRJQDAMAGE", self:getAttr("name"), f_jqdamage, value)

    return value
end

--@desc: 被动普通气血伤害系数
--@author:Seven
--@time:2022-11-11 11:35:06
function BaseCharacterAttr:__getQiatkFactor()
    -- * buff固值加成
    local buffConstQiatkFactorValue = self.__character:getBuffAddAttr("qiatkFactor")

    -- * 被动普通气血伤害系数 = 角色基础值 + 战场Buff固值加成
    local value = Helper:preciseDecimal(self.__attrs.qiatkFactor + buffConstQiatkFactorValue, 6)

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETQIATKFACTOR", self:getAttr("name"), self.__attrs.qiatkFactor, buffConstQiatkFactorValue, value)

    return value
end

--@desc: 普通招架免伤强化值
--@author:Seven
--@time:2023-03-08 14:33:56
function BaseCharacterAttr:__getParryHurtFixRateFactor()
    local buffConstParryHurtFixRateFactorValue = self.__character:getBuffAddAttr("parryHurtFixRateFactor")
    -- * 普通招架免伤强化值 = 角色基础值 + 战场Buff固值加成
    local value = self.__attrs.parryHurtFixRateFactor + buffConstParryHurtFixRateFactorValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETPARRYHURTFIXRATEFACTOR", self:getAttr("name"), self.__attrs.parryHurtFixRateFactor, buffConstParryHurtFixRateFactorValue, value)

    return value
end

--@desc: 普通招架气血伤害减免值
--@author:Seven
--@time:2023-01-05 15:35:17
function BaseCharacterAttr:__getParryqiHurtFactor()
    local value = 0

    -- * buff固值加成
    local buffConstParryqiHurtFactorValue = self.__character:getBuffAddAttr("parryqiHurtFactor")

    value = value + buffConstParryqiHurtFactorValue

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETPARRYQIHURTFACOTR", self:getAttr("name"), 0, buffConstParryqiHurtFactorValue, value)

    return value
end

--@desc: 实际承伤值
function BaseCharacterAttr:__setRecordDamage(value)
    self.__attrs.recordDamage = value
end

function BaseCharacterAttr:__getRecordDamage()
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETRECORDDAMAGE", self:getAttr("name"), self.__attrs.recordDamage)

    return self.__attrs.recordDamage
end

--@desc: 加力最大值
--@author:Seven
--@time:2021-07-12 16:52:58
function BaseCharacterAttr:__getPlusPointMax()
    local prepNeiGongSkill = self.__character:getPrepSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local baseNeiGongSkill = self.__character:getBaseSkill(SKILL_SECOND_TYPE.NEI_GONG)

    local prepLv = 0

    if prepNeiGongSkill then
        prepLv = prepNeiGongSkill:getLevel()
    end

    local baseLv = baseNeiGongSkill:getLevel()

    local plusPointMax = Helper:mathFloor(prepLv / 2 + baseLv / 4)

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETPLUSPOINTMAX", self:getAttr("name"), prepLv, baseLv, plusPointMax)

    return plusPointMax
end

--@desc: 主动气血直接伤害系数
--@author:Seven
--@time:2025-01-02 15:29:08
function BaseCharacterAttr:__getQiActiveAtkFactor()
    -- * 战场Buff固值加成
    local buffConstQiActiveAtkFactorForceValue = self.__character:getBuffAddAttr("qiActiveAtkFactor")
    local value = Helper:preciseDecimal(self.__attrs.qiActiveAtkFactor + buffConstQiActiveAtkFactorForceValue, 6)

    FightUtil:printTemplateLog("BASECHARACTERATTR_GETQIACTIVEATKFACTOR", self:getAttr("name"), self.__attrs.qiActiveAtkFactor, buffConstQiActiveAtkFactorForceValue, value)

    return value
end

--@desc: 主动气血直接防御系数
--@author:Seven
--@time:2025-01-02 15:29:46
function BaseCharacterAttr:__getQiActiveDefFactor()
    -- * 战场Buff固值加成
    local buffConstQiActiveDefFactorForceValue = self.__character:getBuffAddAttr("qiActiveDefFactor")
    local value = Helper:preciseDecimal(self.__attrs.qiActiveDefFactor + buffConstQiActiveDefFactorForceValue, 6)
    FightUtil:printTemplateLog("BASECHARACTERATTR_GETQIACTIVEDEFFACTOR", self:getAttr("name"), self.__attrs.qiActiveDefFactor, buffConstQiActiveDefFactorForceValue, value)
    return value
end

function BaseCharacterAttr:correctAttrLimit()
    --@desc 修正气血上限
    local qiLimit = self:getAttr("qiLimitBattle")
    local nowQiMaxValue = self:getAttr("qiMax")
    if nowQiMaxValue < 0 then
        nowQiMaxValue = 0
    elseif nowQiMaxValue > qiLimit then
        nowQiMaxValue = qiLimit
    end
    self:setAttr("qiMax", nowQiMaxValue)

    --@desc 修正当前气血
    local nowQiValue = self:getAttr("qi")
    if nowQiValue < 0 then
        nowQiValue = 0
    elseif nowQiValue > nowQiMaxValue then
        nowQiValue = nowQiMaxValue
    end
    self:setAttr("qi", nowQiValue)

    --@desc 修正当前内力值
    local nowNeili = self:getAttr("neili")
    --@desc 内力上限值
    local neiliLimit = self:getAttr("neiliLimit")
    if nowNeili > neiliLimit then
        nowNeili = neiliLimit
    elseif nowNeili < 0 then
        nowNeili = 0
    end
    self:setAttr("neili", nowNeili)

    local nowTili = self:getAttr("tili")
    local tiliMax = self:getAttr("tiliMax")
    if nowTili > tiliMax then
        nowTili = tiliMax
    elseif nowTili < 0 then
        nowTili = 0
    end
    self:setAttr("tili", nowTili)
end

return newClass("BaseCharacterAttr", {ICharacterAttr, ABasicCharacterFuncSystem}, BaseCharacterAttr)
000000000