local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")

local ShenBingRes = require("app.models.ShenBing.ShenBingRes")

local ICharacterFcatory = require("app.FightSystem.Factory.CharacterFactory.ICharacterFcatory")

local ShenBingEffct = require("app.models.ShenBing.ShenBingEffct")

--@SuperType [src.app.FightSystem.Factory.CharacterFactory.ICharacterFcatory#ICharacterFcatory]
local CharacterByRoleFactory = {}

function CharacterByRoleFactory:create(role)
    local p = CharacterByRoleFactory.new()
    p:init(role)
    return p
end

function CharacterByRoleFactory:init(role)
    self.__role = role
end

function CharacterByRoleFactory:setShenBingBuffArray(buffArray)
    self.__buffArray = buffArray
end

function CharacterByRoleFactory:setNormalBuffSystem(system)
    self.__normalBuffSystem = system
end

function CharacterByRoleFactory:__initAttr(character)
    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.PlayerAttr#PlayerAttr]
    local playerAttr = require("app.FightSystem.FightRole.CharacterAttr.PlayerAttr"):create(character)

    playerAttr:setAttr("id", self.__role:getAttr("id"))

    playerAttr:setAttr("name", self.__role:getAttr("name"))

    playerAttr:setAttr("lv", self.__role:getAttr("lv"))

    playerAttr:setAttr("jingMax", self.__role:getJingMax())

    playerAttr:setAttr("looks", self.__role:getFinalAttr("looks"))

    playerAttr:setAttr("age", self.__role:getAge())

    playerAttr:setAttr("qi", Helper:mathFloor(self.__role:getAttr("qi")))
    playerAttr:setAttr("qiMax", Helper:mathFloor(self.__role:getFinalAttr("qiMax") * self.__role:getAttr("qiPercent")))
    playerAttr:setAttr("qiLimit", Helper:mathFloor(self.__role:getFinalAttr("qiMax")))

    playerAttr:setAttr("neili", Helper:mathFloor(self.__role:getAttr("neili")))
    playerAttr:setAttr("neiliMax", Helper:mathFloor(self.__role:getFinalAttr("neiliMax")))
    playerAttr:setAttr("neiliLimit", Helper:mathFloor(self.__role:getFinalAttr("neiliMax")))

    playerAttr:setAttr("str", self.__role:getAttr("str"))
    playerAttr:setAttr("dex", self.__role:getAttr("dex"))
    playerAttr:setAttr("con", self.__role:getAttr("con"))
    playerAttr:setAttr("int", self.__role:getAttr("int"))

    playerAttr:setAttr("strCondSkill", self.__role:getFinalAttr("currStr"))
    playerAttr:setAttr("dexCondSkill", self.__role:getFinalAttr("currDex"))
    playerAttr:setAttr("conCondSkill", self.__role:getFinalAttr("currCon"))
    playerAttr:setAttr("intCondSkill", self.__role:getFinalAttr("currInt"))

    playerAttr:setAttr("zhengqi", self.__role:getFinalAttr("zhengqi"))

    playerAttr:setAttr("plusPoint", self.__role:getAttr("jiaLi"))

    return playerAttr
end

function CharacterByRoleFactory:__initSpecies()
    local species
    if self.__role:getAttr("sex") == "男" then
        species = FightCommons.CHARACTER_SPECIES.MALE
    else
        species = FightCommons.CHARACTER_SPECIES.FEMALE
    end

    return species
end

function CharacterByRoleFactory:__initPrepSkillDict()
    local prep_dict = {}
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
            local skill
            if Skill:getSkill(skillId).type == SKILL_TYPE_SELFCREATE then
                skill = SkillFactory:createSelfCreateSkill(self.__role:getAttr("selfCreatedSkillData")[skillId], self.__role:getSkillLv(skillId))
            else
                skill = SkillFactory:createSkill(skillId, self.__role:getSkillLv(skillId))
            end
            prep_dict[second_type] = skill
        end
    end

    return prep_dict
end

function CharacterByRoleFactory:__initBaseSkillDict()
    local baseSkillDict = {}

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.QUAN_JIAO)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseQuanjiaoSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.QUAN_JIAO] = baseQuanjiaoSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.JIAN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseSowrdSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.JIAN_FA] = baseSowrdSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.DAO_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseKnifeSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.DAO_FA] = baseKnifeSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.GUN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseStickSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.GUN_FA] = baseStickSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.AN_QI)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseProjectileSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.AN_QI] = baseProjectileSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.BIAN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseScourgeSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.BIAN_FA] = baseScourgeSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.SHUANG_CHI)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseFunzerkerSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.SHUANG_CHI] = baseFunzerkerSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.QIN_FA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseLyraSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.QIN_FA] = baseLyraSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.QING_GONG)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseDodgeSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.QING_GONG] = baseDodgeSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.NEI_GONG)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseNeigongSkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.NEI_GONG] = baseNeigongSkill

    local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(SKILL_SECOND_TYPE.ZHAO_JIA)
    local lv = math.max(self.__role:getSkillLv(baseSkillId), 1)
    local baseParrySkill = SkillFactory:createSkill(baseSkillId, lv)
    baseSkillDict[SKILL_SECOND_TYPE.ZHAO_JIA] = baseParrySkill

    return baseSkillDict
end

function CharacterByRoleFactory:__initWeapon()
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

function CharacterByRoleFactory:__initEmptyHandWeapon()
    local emptyHandWeapon = EquipmentFactory:createEmptyHandWeapon()
    return emptyHandWeapon
end

function CharacterByRoleFactory:__initStandByWeapon()
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

--@desc: 防具
--@author:Seven
--@time:2022-05-06 10:57:06
function CharacterByRoleFactory:__initArmorMap()
    local map = {}
    local parts = FightCommons.EQUIP_PART
    for _, part in pairs(parts) do
        if part ~= parts.WEAPON then
            local data = self.__role:getEquipByName(part)
            if data then
                local roleArmorAttr = self.__role:getItemWithOnlyId(data.id)
                if roleArmorAttr then
                    map[part] = EquipmentFactory:createArmor(data.itemId)
                end
            end
        end
    end

    return map
end

--@desc: 添加适合使用的主动技能
--@author:Seven
--@time:2021-07-27 09:59:10
--@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function CharacterByRoleFactory:__addAllMatchedActiveSkill(character)
    local list = {}

    local prepSkills = character:getPrepSkills()

    if MapIsEmpty(prepSkills) then
        return list
    end
    for skill_sec_type, fight_skill in pairs(prepSkills) do
        local actId_list = fight_skill:getActiveZhaos()

        for _, actId in ipairs(actId_list) do
            local zhaoLv = self.__role:getSkillZhaoLv(actId)

            if zhaoLv > 0 then
                local activeSkill = ActiveFactory:createPlayerFightActiveSkill(character, actId, zhaoLv)
                character:addActiveSkill(activeSkill)
            end
        end
    end
end

--@desc: 创建拳脚系统
--@author:Seven
--@time:2022-11-29 16:39:20
--@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function CharacterByRoleFactory:__initFistFootBranchList(character)
    local FightFistFootBranch = require("app.FightSystem.FightRole.FistFoot.FightFistFootBranch")

    local FightFistFootTechnique = require("app.FightSystem.FightRole.FistFoot.FightFistFootTechnique")

    local FightFistFootEffect = require("app.FightSystem.FightRole.FistFoot.FightFistFootEffect")

    local CharacterFistFootSystem = require("app.FightSystem.FightRole.FistFoot.CharacterFistFootSystem")

    --@RefType [src.app.FightSystem.FightRole.FistFoot.CharacterFistFootSystem#CharacterFistFootSystem]
    local sys = CharacterFistFootSystem:create(character)

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

            sys:addBranch(branch)
        end
    end

    character:setFistFootSystem(sys)
end

function CharacterByRoleFactory:__getFamilyId()
    return self.__role:getFamilyId()
end

--[[
    @desc: 设置战斗buff列表
    author:TangJian
    time:2022-01-17 17:39:45
    --@fightBuffArray: 
    @return:
]]
function CharacterByRoleFactory:setFightBuffArray(fightBuffArray)
    self.__fightBuffArray = fightBuffArray
end

function CharacterByRoleFactory:getCharacter()
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    local character = require("app.FightSystem.FightRole.FightCharacter"):create()

    character:setCharacterAttr(self:__initAttr(character))

    character:setSpecies(self:__initSpecies())

    character:setFamilyID(self:__getFamilyId())

    local prep_dict = self:__initPrepSkillDict()
    if not MapIsEmpty(prep_dict) then
        for prep_type, prepSkill in pairs(prep_dict) do
            character:addPrepSkill(prep_type, prepSkill)
        end
    end

    local base_dict = self:__initBaseSkillDict()
    if not MapIsEmpty(base_dict) then
        for base_type, baseSkill in pairs(base_dict) do
            character:addBaseSkill(base_type, baseSkill)
        end
    end

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem#CharacterEquipmentSystem]
    local equipSys = require("app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem"):create()

    equipSys:setEmptyHandWeapon(self:__initEmptyHandWeapon())

    equipSys:setEquipmentWeapon(self:__initWeapon())

    equipSys:setStandbyWeapon(self:__initStandByWeapon())

    equipSys:setWeapon(equipSys:getEquipmentWeapon())

    local armorMap = self:__initArmorMap()

    if not MapIsEmpty(armorMap) then
        for part, armor in pairs(armorMap) do
            equipSys:setEquipment(part, armor)
        end
    end

    character:setEquipSys(equipSys)

    --@RefType [src.app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI#ActiveSkillReleaseAI]
    local activeAutoReleaseAI = require("app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI"):create()
    character:setActiveSkillReleaseAI(activeAutoReleaseAI)

    self:__addAllMatchedActiveSkill(character)

    self:__initFistFootBranchList(character)

    character:init()

    return character
end

return newClass("CharacterByRoleFactory", {ICharacterFcatory}, CharacterByRoleFactory)
0000000