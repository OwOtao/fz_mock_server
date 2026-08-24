--[[
    author:Seven
    time:2024-01-19 16:17:32
    desc: 基础副本角色NPC建造器
]]
local newClass = require("third.class.NewClass")

local FightCharacter = require("app.FightSystem.FightRole.NewFightCharacter")

local FightCommons = require("app.FightSystem.FightCommons")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local ShenBingEffct = require("app.models.ShenBing.ShenBingEffct")

local ShenBingRes = require("app.models.ShenBing.ShenBingRes")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local FightSkillFactory = require("app.FightSystem.FightSkill.Factory.FightSkillFactory")

local FightActiveSkillFactory = require("app.FightSystem.FightSkill.Factory.FightActiveSkillFactory")

local NpcResistanceConf = require("app.FightSystem.Configuration.NpcResistanceConf")

local FightUtil = require("app.FightSystem.FightUtil.FightUtil")

local isImplement = require("third.assertIsInstance.assertIsInstance")

--@SuperType [src.app.FightSystem.FightCharacterBuilder.IFightCharacterBuilder#IFightCharacterBuilder]
local BasicMapNpcFightCharacterBuilder = {}

function BasicMapNpcFightCharacterBuilder:create(...)
    return BasicMapNpcFightCharacterBuilder.new():__init(...)
end

function BasicMapNpcFightCharacterBuilder:__init(builderConfig)
    --@RefType [src.app.FightSystem.FightCharacterBuilder.NPCBuilder.IFightNPCBuilderConfig#IFightNPCBuilderConfig]
    self.__config = isImplement(builderConfig, require("app.FightSystem.FightCharacterBuilder.NPCBuilder.IFightNPCBuilderConfig"))

    return self
end

function BasicMapNpcFightCharacterBuilder:__initNpcAttr()
    self.__character:setAttr("id", self.__config:getBuilderConfigAttr("id"))
    self.__character:setAttr("name", self.__config:getBuilderConfigAttr("name"))
    self.__character:setAttr("zhengqi", self.__config:getBuilderConfigAttr("zhengqi"))
    self.__character:setAttr("age", self.__config:getBuilderConfigAttr("age"))
    self.__character:setAttr("looks", self.__config:getBuilderConfigAttr("looks"))
    self.__character:setAttr("jingMax", self.__config:getBuilderConfigAttr("jingMax"))
    self.__character:setAttr("intCondSkill", self.__config:getBuilderConfigAttr("intCondSkill"))

    --@region 基础属性
    self.__character:setAttr("lv", self.__config:getBuilderConfigAttr("lv"))
    self.__character:setAttr("str", self.__config:getBuilderConfigAttr("str"))
    self.__character:setAttr("con", self.__config:getBuilderConfigAttr("con"))
    self.__character:setAttr("dex", self.__config:getBuilderConfigAttr("dex"))
    self.__character:setAttr("plusPoint", self.__config:getBuilderConfigAttr("plusPoint"))
    self.__character:setAttr("qi", self.__config:getBuilderConfigAttr("qiMax"))
    self.__character:setAttr("qiMax", self.__config:getBuilderConfigAttr("qiMax"))
    self.__character:setAttr("qiLimit", self.__config:getBuilderConfigAttr("qiMax"))
    self.__character:setAttr("neili", self.__config:getBuilderConfigAttr("neiliMax"))
    self.__character:setAttr("neiliMax", self.__config:getBuilderConfigAttr("neiliMax"))
    self.__character:setAttr("neiliLimit", self.__config:getBuilderConfigAttr("neiliMax"))
    self.__character:setAttr("tiliSpeed", self.__config:getBuilderConfigAttr("tiliSpeed"))
    --@endregion

    --@region 战斗属性
    self.__character:setAttr("atk", self.__config:getBuilderConfigAttr("atk"))
    self.__character:setAttr("def", self.__config:getBuilderConfigAttr("def"))
    self.__character:setAttr("damage", self.__config:getBuilderConfigAttr("damage"))
    self.__character:setAttr("protect", self.__config:getBuilderConfigAttr("protect"))
    self.__character:setAttr("hitForce", self.__config:getBuilderConfigAttr("hitForce"))
    self.__character:setAttr("dodgeForce", self.__config:getBuilderConfigAttr("dodgeForce"))
    self.__character:setAttr("parryForce", self.__config:getBuilderConfigAttr("parryForce"))
    --@endregion

    local species = Helper:getDef(self.__config:getBuilderConfigAttr("species"), "human")
    if species == "human" then
        if self.__config:getBuilderConfigAttr("sex") == "男" then
            species = FightCommons.CHARACTER_SPECIES.MALE
        else
            species = FightCommons.CHARACTER_SPECIES.FEMALE
        end
    end
    self.__character:setSpecies(species)
end

--@desc: 解析技能字符串，获取技能id和技能等级
--@author:Seven
--@time:2024-01-22 10:32:07
--@str: 策划填表的技能字符串
--@return: skillId:string , lv:number
local function splitSkillStr(str)
    local list = string.split(str, "#")
    return list[1], tonumber(list[2])
end

--@desc: 初始化基本武学
--@author:Seven
--@time:2024-01-22 11:13:18
function BasicMapNpcFightCharacterBuilder:__initNpcBaseSkill()
    for typeStr, typeValue in pairs(SKILL_SECOND_TYPE) do
        local skill_first_type = SkillClassifyManager:getFirstTypeBySecondType(typeValue)
        local lv
        local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(typeValue)
        if skill_first_type == SKILL_FIRST_TYPE.BING_QI then
            lv = math.max(self.__config:getBuilderConfigAttr("baseBingqiLv"), 1)
        elseif skill_first_type == SKILL_FIRST_TYPE.QUAN_JIAO then
            lv = math.max(self.__config:getBuilderConfigAttr("baseQuanjiaoLv"), 1)
        elseif skill_first_type == SKILL_FIRST_TYPE.NEI_GONG then
            lv = math.max(self.__config:getBuilderConfigAttr("baseNeigongLv"), 1)
        elseif skill_first_type == SKILL_FIRST_TYPE.QING_GONG then
            lv = math.max(self.__config:getBuilderConfigAttr("baseQinggongLv"), 1)
        elseif skill_first_type == SKILL_FIRST_TYPE.ZHAO_JIA then
            lv = math.max(self.__config:getBuilderConfigAttr("baseZhaojiaLv"), 1)
        end

        local baseSkill = FightSkillFactory.createBasicFightSkill(baseSkillId, lv)

        self.__character:addBaseSkill(typeValue, baseSkill)
    end
end

--@desc: 初始化准备武学
--@author:Seven
--@time:2024-01-22 11:13:07
function BasicMapNpcFightCharacterBuilder:__initNpcPrepSkill()
    local prepSkillStrAttrName = {
        {"skillQuanjiaoLeft", SKILL_SECOND_TYPE.QUAN_JIAO},
        {"skillJianfa", SKILL_SECOND_TYPE.JIAN_FA},
        {"skillDaofa", SKILL_SECOND_TYPE.DAO_FA},
        {"skillGunfa", SKILL_SECOND_TYPE.GUN_FA},
        {"skillAnqi", SKILL_SECOND_TYPE.AN_QI},
        {"skillBianfa", SKILL_SECOND_TYPE.BIAN_FA},
        {"skillShuangchi", SKILL_SECOND_TYPE.SHUANG_CHI},
        {"skillQinfa", SKILL_SECOND_TYPE.QIN_FA},
        {"skillQinggong", SKILL_SECOND_TYPE.QING_GONG},
        {"skillNeigong", SKILL_SECOND_TYPE.NEI_GONG},
        {"skillZhaojia", SKILL_SECOND_TYPE.ZHAO_JIA}
    }

    for _, v in ipairs(prepSkillStrAttrName) do
        local confAttrName = v[1]
        local skillSecType = v[2]
        local str = self.__config:getBuilderConfigAttr(confAttrName)
        if str ~= nil then
            local skillId, lv = splitSkillStr(str)
            local skill = FightSkillFactory.createBasicFightSkill(skillId, lv)
            self.__character:addPrepSkill(skillSecType, skill)
        end
    end
end

function BasicMapNpcFightCharacterBuilder:__initNpcActiveAutoReleaseAI()
    local activeSkillStrs = self.__config:getBuilderConfigAttr("activeZhao")
    if activeSkillStrs == nil then
        return
    end

    local npcActiveSkillTemplates = string.split(activeSkillStrs, "|")

    local NpcReleaseActiveRule = require("app.FightSystem.FightRole.CharacterAI.NpcReleaseActiveRule")
    for _, template in ipairs(npcActiveSkillTemplates) do
        local template_info = string.split(template, "#")

        local combResId = template_info[1]

        local aiRuleId = template_info[2]

        if combResId == nil or aiRuleId == nil then
            error("NPC 属性id：%d 主动技能释放规则解析错误")
        end

        local activeSkill = FightActiveSkillFactory.createNpcFightAcitiveSkillByCombId(combResId)

        activeSkill:setCharacter(self.__character)

        self.__character:addActiveSkill(activeSkill)

        --@RefType [src.app.FightSystem.FightRole.CharacterAI.NpcReleaseActiveRule#NpcReleaseActiveRule]
        local rule = NpcReleaseActiveRule:create(activeSkill:getId(), aiRuleId)

        self.__character:addActiveReleaseAIRule(rule)
    end
end

function BasicMapNpcFightCharacterBuilder:__initNpcWeapon()
    local main_weapon
    local mainWeaponStr = self.__config:getBuilderConfigAttr("weaponMain")
    if mainWeaponStr ~= nil then
        local equipType, tempId = string.splitUnpack(mainWeaponStr, "#")
        if equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.GOD then
            main_weapon = EquipmentFactory:createShenBingWeaponWithTemplateId(tempId)
        elseif equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.NORMAL then
            main_weapon = EquipmentFactory:createWeaponWithItemId(tempId)
        end
    end
    self.__character:setEquipWeapon(main_weapon)

    --@region 副手武器
    local sec_weapon
    local secWeaponStr = self.__config:getBuilderConfigAttr("weaponSecond")
    if secWeaponStr ~= nil then
        local equipType, tempId = string.splitUnpack(secWeaponStr, "#")

        if equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.GOD then
            sec_weapon = EquipmentFactory:createShenBingWeaponWithTemplateId(tempId)
        elseif equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.NORMAL then
            sec_weapon = EquipmentFactory:createWeaponWithItemId(tempId)
        end
    end
    self.__character:setStandbyWeapon(sec_weapon)

    self.__character:setEmptyHandWeapon(EquipmentFactory:createEmptyHandWeapon())
end

function BasicMapNpcFightCharacterBuilder:__initNpcSkillResistance()
    local damageAttrClass = self.__config:getBuilderConfigAttr("damageAttrClass")

    if damageAttrClass == nil or tonumber(damageAttrClass) == 0 then
        return
    end

    local list = NpcResistanceConf:getNpcResistanceWithClassType(damageAttrClass)

    for _, v in ipairs(list) do
        local damageType = v.damageType
        local typeID = v.typeID
        local value = v.property

        if damageType == "atkDamageClass" then
            self.__character:addSkillAtkResistance(typeID, value)
        elseif damageType == "defDamageClass" then
            self.__character:addSkillDefResistance(typeID, value)
        else
            assert(false, "NPC抗性配置错误，抗性类型错误 : " .. tostring(damageType))
        end

        FightUtil:printFormatLog("【%s】NPC抗性添加配置：%s, %s, %s",self.__character:getAttr("name"), tostring(damageType), tostring(typeID), tostring(value))
    end
end

function BasicMapNpcFightCharacterBuilder:__getConfigClass()
    return require("app.FightSystem.FightRole.CharacterConfigs.NPCCharacterConfig")
end

function BasicMapNpcFightCharacterBuilder:buildCharacter()
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    self.__character = FightCharacter:create(self:__getConfigClass())

    self:__initNpcAttr()
    self:__initNpcWeapon()
    self:__initNpcBaseSkill()
    self:__initNpcPrepSkill()
    self:__initNpcActiveAutoReleaseAI()
    self:__initNpcSkillResistance()

    self.__character:init()

    return self.__character
end

return newClass("BasicMapNpcFightCharacterBuilder", {require("app.FightSystem.FightCharacterBuilder.IFightCharacterBuilder")}, BasicMapNpcFightCharacterBuilder)
0000000000000