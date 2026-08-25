--[[
    author:Seven
    time:2024-01-24 12:05:13
    desc:
]]
local IConfigGetter = {}

--@desc:
--@author:Seven
--@time:2024-01-24 14:10:36
--@return [src.app.FightSystem.FightCharacterBuilder.PlayerBuilder.IFightCharacterAttrStrategyConfig#IFightCharacterAttrStrategyConfig]
function IConfigGetter:__getAttrGetterConfig()
end

function IConfigGetter:__getCharacterConfigClass()
end

local abstract = require("third.class.abstract")

local IFightCharacterBuilder = require("app.FightSystem.FightCharacterBuilder.IFightCharacterBuilder")

local FightCharacter = require("app.FightSystem.FightRole.NewFightCharacter")

local FightCommons = require("app.FightSystem.FightCommons")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local ShenBingEffct = require("app.models.ShenBing.ShenBingEffct")

local ShenBingRes = require("app.models.ShenBing.ShenBingRes")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

local FightSkillFactory = require("app.FightSystem.FightSkill.Factory.FightSkillFactory")

--@SuperType [src.app.FightSystem.FightCharacterBuilder.PlayerBuilder.APlayerFightCharacterBuilder#IConfigGetter]
local APlayerFightCharacterBuilder = {}

function APlayerFightCharacterBuilder:setRole(role)
    self.__role = role
end

--@desc: 初始化角色属性
--@author:Seven
--@time:2023-02-21 10:20:51
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initAttr(character)
    self.__strategy = self:__getAttrGetterConfig()

    character:setAttr("id", self.__strategy:getRoleAttr("id"))

    character:setAttr("name", self.__strategy:getRoleAttr("name"))

    character:setAttr("lv", self.__strategy:getRoleAttr("lv"))

    character:setAttr("jingMax", self.__strategy:getRoleAttr("jingMax"))

    character:setAttr("looks", self.__strategy:getRoleAttr("looks"))

    character:setAttr("age", self.__strategy:getRoleAttr("age"))

    character:setAttr("qi", math.max(self.__strategy:getRoleAttr("qi"), 1))
    character:setAttr("qiMax", math.max(self.__strategy:getRoleAttr("qiMax"), 1))
    character:setAttr("qiLimit", self.__strategy:getRoleAttr("qiLimit"))

    character:setAttr("neili", self.__strategy:getRoleAttr("neili"))
    character:setAttr("neiliMax", self.__strategy:getRoleAttr("neiliMax"))
    character:setAttr("neiliLimit", self.__strategy:getRoleAttr("neiliLimit"))

    character:setAttr("str", self.__strategy:getRoleAttr("str"))
    character:setAttr("dex", self.__strategy:getRoleAttr("dex"))
    character:setAttr("con", self.__strategy:getRoleAttr("con"))
    character:setAttr("int", self.__strategy:getRoleAttr("int"))

    character:setAttr("strCondSkill", self.__strategy:getRoleAttr("strCondSkill"))
    character:setAttr("dexCondSkill", self.__strategy:getRoleAttr("dexCondSkill"))
    character:setAttr("conCondSkill", self.__strategy:getRoleAttr("conCondSkill"))
    character:setAttr("intCondSkill", self.__strategy:getRoleAttr("intCondSkill"))

    character:setAttr("zhengqi", self.__strategy:getRoleAttr("zhengqi"))

    character:setAttr("plusPoint", self.__strategy:getRoleAttr("plusPoint"))

    character:setSpecies(self.__strategy:getRoleAttr("species"))

    character:setFamilyID(self.__strategy:getRoleAttr("familyID"))
end

--@desc: 初始化基本技能
--@author:Seven
--@time:2023-02-21 10:41:49
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initBasicSkill(character)
    local FightSkillFactory = require("app.FightSystem.FightSkill.Factory.FightSkillFactory")

    local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

    local baseSkillDict = {}

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.QUAN_JIAO)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseQuanjiaoSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.QUAN_JIAO] = baseQuanjiaoSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.JIAN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseSowrdSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.JIAN_FA] = baseSowrdSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.DAO_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseKnifeSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.DAO_FA] = baseKnifeSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.GUN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseStickSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.GUN_FA] = baseStickSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.AN_QI)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseProjectileSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.AN_QI] = baseProjectileSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.BIAN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseScourgeSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.BIAN_FA] = baseScourgeSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.SHUANG_CHI)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseFunzerkerSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.SHUANG_CHI] = baseFunzerkerSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.QIN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseLyraSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.QIN_FA] = baseLyraSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.QING_GONG)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseDodgeSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.QING_GONG] = baseDodgeSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.NEI_GONG)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseNeigongSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.NEI_GONG] = baseNeigongSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.ZHAO_JIA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseParrySkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.ZHAO_JIA] = baseParrySkill

    if not MapIsEmpty(baseSkillDict) then
        for base_type, baseSkill in pairs(baseSkillDict) do
            character:addBaseSkill(base_type, baseSkill)
        end
    end
end

--@desc: 初始化角色准备技能
--@author:Seven
--@time:2023-02-21 10:34:43
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initPrepSkillAndActiveSkill(character)

    local FightActiveSkillFactory = require("app.FightSystem.FightSkill.Factory.FightActiveSkillFactory")

    local pre_skill_map = {
        ["quanjiao1"] = SKILL_SECOND_TYPE.QUAN_JIAO,
        ["jianfa"] = SKILL_SECOND_TYPE.JIAN_FA,
        ["daofa"] = SKILL_SECOND_TYPE.DAO_FA,
        ["gunfa"] = SKILL_SECOND_TYPE.GUN_FA,
        ["anqi"] = SKILL_SECOND_TYPE.AN_QI,
        ["bianfa"] = SKILL_SECOND_TYPE.BIAN_FA,
        ["shuangchi"] = SKILL_SECOND_TYPE.SHUANG_CHI,
        ["qinfa"] = SKILL_SECOND_TYPE.QIN_FA,
        ["qinggong"] = SKILL_SECOND_TYPE.QING_GONG,
        ["neigong"] = SKILL_SECOND_TYPE.NEI_GONG,
        ["zhaojia"] = SKILL_SECOND_TYPE.ZHAO_JIA
    }

    for pre_id, second_type in pairs(pre_skill_map) do
        local skillId = self.__role:getPrepareSkill(pre_id)
        if skillId then
            local skill = FightSkillFactory.createBasicFightSkill(skillId, self.__role:getSkillLv(skillId))

            character:addPrepSkill(second_type, skill)

            local activeIdList = skill:getActiveZhaos()

            if not MapIsEmpty(activeIdList) then
                for _, actId in ipairs(activeIdList) do
                    local zhaoLv = self.__role:getSkillZhaoLv(actId)
                    if zhaoLv > 0 then
                        local activeSkill = FightActiveSkillFactory.createPlayerFightActiveSkill(actId, zhaoLv)
                        activeSkill:setCharacter(character)
                        character:addActiveSkill(activeSkill)
                    end
                end
            end
        end
    end
end

-- 知识类武学的功能需要逐步接入，不能一次性添加所有
local __konwledgeSkillIdList = FightCommons.ACCEPT_KONWLEDGE_SKILL
function APlayerFightCharacterBuilder:__initKonwledgeSkill(character)
    for _, skillId in ipairs(__konwledgeSkillIdList) do
        local role_skill = self.__role:getSkill(skillId)
        if role_skill ~= nil then
            local skill_exp = role_skill.exp or 0
            local skill = Skill:getSkill(skillId)
            if skill ~= nil then
                local lv = skill:getLv(skill_exp)
                local konwledgeFightSkill = FightSkillFactory.createKnowledgeFightSkill(skillId, lv)
                character:addKnowledgeSkill(skillId, konwledgeFightSkill)
            else
                error("unkonw Skill Id : " .. tostring(skillId))
            end
        end
    end
end

--@desc: 设置原始技能数据
--@author:Seven
--@time:2023-02-21 15:37:13
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initRawSkills(character)
    local inherit = require("third.inherit.inherit")

    local skillMap = self.__role:getSkills()

    character:setRawSkillMap(inherit({}, skillMap))
end

function APlayerFightCharacterBuilder:__createEquipWeapon()
    local weapon

    local role_weapon = self.__role:getEquipByName("weapon")
    if role_weapon then
        -- 存在准备了但背包中不存在该物品的情况
        local roleWeaponAttr = self.__role:getItemWithOnlyId(role_weapon.id)
        if roleWeaponAttr then
            local itemId = role_weapon.itemId
            if self.__role:isShengBing(itemId) then
                local item = self.__role:getOneItemByKey(role_weapon.itemId)
                local buffArray = ShenBingEffct:getFightBuffArray(item) -- 战斗常态buff
                local buffLauncherIdList = ShenBingEffct:getBuffLauncherIdList(item) -- 战斗buff添加器列表

                local itemTemplate = {
                    id = item.id, -- 物品id
                    damage = item:getWeaponDamage(self.__role),
                    protect = item.protect,
                    wanhaodu = item.wanhaodu,
                    cuilianCount = item.cuilianCount,
                    weight = item.weight,
                    rendu = item.rendu,
                    yindu = item.yindu,
                    name = item.name,
                    type2 = item:getCurrWeaponType2(),
                    type = item:getItemAttr("type"),
                    flyWeapon = item:getFlyWeapon(),
                    beflyWeapon = item:getBeFlyWeapon(),
                    breakWeapon = item:getBreakWeapon(),
                    brokenWeapon = item:getBrokenWeapon()
                }

                weapon = EquipmentFactory:createShenBingWeaponWithItem(role_weapon.id, itemTemplate, buffArray, buffLauncherIdList)
            else
                local item = self.__role:getOneItemByKey(role_weapon.itemId)
                weapon = EquipmentFactory:createWeaponWithItem(role_weapon.id, item)
            end
        else
            print("背包中未找到已准备的装备")
        end
    end

    return weapon
end

function APlayerFightCharacterBuilder:__createStandbyEquipWeapon()
    local weapon

    local role_weapon = self.__role:getPrepareWeapon()
    if role_weapon then
        -- 存在准备了但背包中不存在该物品的情况
        local roleWeaponAttr = self.__role:getItemWithOnlyId(role_weapon.id)
        if roleWeaponAttr then
            local itemId = role_weapon.itemId
            if self.__role:isShengBing(itemId) then
                local item = self.__role:getOneItemByKey(role_weapon.itemId)
                local buffArray = ShenBingEffct:getFightBuffArray(item)
                local buffLauncherIdList = ShenBingEffct:getBuffLauncherIdList(item)

                local itemAttr = {
                    id = item.id,
                    damage = item:getWeaponDamage(self.__role),
                    protect = item.protect,
                    wanhaodu = item.wanhaodu,
                    cuilianCount = item.cuilianCount,
                    weight = item.weight,
                    rendu = item.rendu,
                    yindu = item.yindu,
                    name = item.name,
                    type2 = item:getCurrWeaponType2(),
                    type = item:getItemAttr("type"),
                    flyWeapon = item:getFlyWeapon(),
                    beflyWeapon = item:getBeFlyWeapon(),
                    breakWeapon = item:getBreakWeapon(),
                    brokenWeapon = item:getBrokenWeapon()
                }

                weapon = EquipmentFactory:createShenBingWeaponWithItem(role_weapon.id, itemAttr, buffArray, buffLauncherIdList)
            else
                local item = self.__role:getOneItemByKey(role_weapon.itemId)
                weapon = EquipmentFactory:createWeaponWithItem(role_weapon.id, item)
            end
        end
    end

    return weapon
end

--@desc: 初始化角色装备
--@author:Seven
--@time:2023-02-21 10:48:55
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initEquipment(character)
    character:setEmptyHandWeapon(EquipmentFactory:createEmptyHandWeapon())

    character:setEquipWeapon(self:__createEquipWeapon())

    character:setStandbyWeapon(self:__createStandbyEquipWeapon())

    --@desc 除武器外的其它装备
    local parts = FightCommons.EQUIP_PART
    for _, part in pairs(parts) do
        if part ~= parts.WEAPON then
            local data = self.__role:getEquipByName(part)
            if data then
                local roleArmorAttr = self.__role:getItemWithOnlyId(data.id)
                if roleArmorAttr then
                    character:setEquipment(part, EquipmentFactory:createArmor(data.itemId))
                end
            end
        end
    end
end

--@desc: 初始化战斗拳脚系统
--@author:Seven
--@time:2023-02-21 11:39:44
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initFistFoot(character)
    local FightFistFootBranch = require("app.FightSystem.FightRole.FistFoot.FightFistFootBranch")

    local FightFistFootTechnique = require("app.FightSystem.FightRole.FistFoot.FightFistFootTechnique")

    local FightFistFootEffect = require("app.FightSystem.FightRole.FistFoot.FightFistFootEffect")

    local CharacterFistFootSystem = require("app.FightSystem.FightRole.FistFoot.CharacterFistFootSystem")

    local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

    for _, b_type in ipairs(SkillClassifyManager:getQuanJiaoSkillClassifyTypes()) do
        local b_lv = self.__role:getFistFootSystem():getBranchLv(b_type)

        if b_lv > 0 then
            --@RefType [src.app.FightSystem.FightRole.FistFoot.FightFistFootBranch#FightFistFootBranch]
            local branch = FightFistFootBranch:create(b_type, b_lv)

            local t_list = self.__role:getFistFootSystem():getTechniquesByTypeFromClassMap(b_type)

            for _, v in ipairs(t_list) do
                --@RefType [src.app.models.FistFootSystem.FistFootTechniques.PlayerFistFootTechnique#PlayerFistFootTechnique]
                local v = v
                --@RefType [src.app.FightSystem.FightRole.FistFoot.FightFistFootTechnique#FightFistFootTechnique]
                local tech = FightFistFootTechnique:create(v:getTechniqueId(), v:getLevel())

                local effectList = v:getEffects()

                for _, e in ipairs(effectList) do
                    --@RefType [src.app.models.FistFootSystem.FistFootEffect.FistFootEffect#FistFootEffect]
                    local e = e
                    local f_effect = FightFistFootEffect:create(e:getPeculiarityid(), e:getLevel())

                    tech:addFistFootEffect(f_effect)
                end

                branch:insertTechnique(tech)
            end

            character:addFistFootBranch(branch)
        end
    end
end

--@desc: 初始化武学伤害抗性系统
--@author:Seven
--@time:2025-02-27 20:50:35
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initSkillResistance(character)
    --@RefType [src.app.models.Meridian.HiddenMeridianSystem.IHiddenMeridianSystem#IHiddenMeridianSystem]
    local hiddenMeridianSystem = self.__role:getHiddenMeridianSystem()

    local buffAttrMap = hiddenMeridianSystem:getHiddenMeridianBuffAttrs()

    for skillDamageResistanceId, infoMap in pairs(buffAttrMap) do
        for skillDamageResistanceType, value in pairs(infoMap) do
            if skillDamageResistanceType == "atkDamageClass" then
                character:addSkillAtkResistance(skillDamageResistanceId, value)
            elseif skillDamageResistanceType == "defDamageClass" then
                character:addSkillDefResistance(skillDamageResistanceId, value)
            end
        end
    end
end

--@desc: 加入外部携带的buff信息
--@author:Seven
--@time:2026-01-07 16:28:36
--@character: [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:__initCarryBuffs(character)
    if MapIsEmpty(self.__carrybuffs) then
        return
    end

    local CharacterCarryBuffWhenInit = require("app.FightSystem.FightRole.CharacterBuff.CharacterCarryBuffWhenInit")

    character:setCarryBuffHandler(CharacterCarryBuffWhenInit:create(character, self.__carrybuffs))
end

--@desc: 创建战斗角色
--@author:Seven
--@time:2023-02-20 21:34:28
--@return [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
function APlayerFightCharacterBuilder:buildCharacter()
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character = FightCharacter:create(self:__getCharacterConfigClass())

    self:__initAttr(character)
    self:__initBasicSkill(character)
    self:__initPrepSkillAndActiveSkill(character)
    self:__initKonwledgeSkill(character)
    self:__initRawSkills(character)
    self:__initEquipment(character)
    self:__initFistFoot(character)
    self:__initSkillResistance(character)
    self:__initCarryBuffs(character)

    character:init()

    return character
end

return abstract("APlayerFightCharacterBuilder", {IConfigGetter, IFightCharacterBuilder}, APlayerFightCharacterBuilder)
000000000