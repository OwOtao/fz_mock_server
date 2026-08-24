local newClass = require("third.class.NewClass")

local NpcFightCharacter = require("app.FightSystem.FightRole.NpcFightCharacter")

local FightCommons = require("app.FightSystem.FightCommons")

local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")

local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")

local NpcAttr = require("app.FightSystem.FightRole.CharacterAttr.NpcAttr")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local NpcCharacterBuilder = {
    __attrRes = {}
}

function NpcCharacterBuilder:create()
    return NpcCharacterBuilder.new()
end

function NpcCharacterBuilder:setAttrRes(attrRes)
    self.__attrRes = attrRes
    return self
end

function NpcCharacterBuilder:setPosIndex(posIndex)
    self.__posIndex = posIndex
    return self
end

function NpcCharacterBuilder:setAttrId(attrId)
    self.__attrId = attrId
    return self
end

function NpcCharacterBuilder:setNpc(npc)
    self.__npc = npc
    return self
end

function NpcCharacterBuilder:__getAttr(id)
    local attr = self.__attrRes[tostring(id)]

    if attr == nil then
        assert(false, "找不到 属性 id ：" .. id)
    end

    return attr
end

--@desc: 初始化NPC的初始属性
--@author:Seven
--@time:2021-06-30 21:16:11
--@npcAttr: [src.app.FightSystem.FightRole.CharacterAttr.NpcAttr#NpcAttr]
function NpcCharacterBuilder:__initNpcAttr(npcAttr, id)
    local attrConf = self:__getAttr(id)

    --@region 基础属性
    npcAttr:setAttr("lv", attrConf.lv)
    npcAttr:setAttr("str", attrConf.str)
    npcAttr:setAttr("con", attrConf.con)
    npcAttr:setAttr("dex", attrConf.dex)
    npcAttr:setAttr("plusPoint", attrConf.plusPoint)
    npcAttr:setAttr("qi", attrConf.qiMax)
    npcAttr:setAttr("qiMax", attrConf.qiMax)
    npcAttr:setAttr("qiLimit", attrConf.qiMax)
    npcAttr:setAttr("neili", attrConf.neiliMax)
    npcAttr:setAttr("neiliMax", attrConf.neiliMax)
    npcAttr:setAttr("neiliLimit", attrConf.neiliMax)
    npcAttr:setAttr("tiliSpeed", attrConf.tiliSpeed)
    --@endregion

    --@region 战斗属性
    npcAttr:setFightAttr("atk", attrConf.atk)
    npcAttr:setFightAttr("def", attrConf.def)
    npcAttr:setFightAttr("damage", attrConf.damage)
    npcAttr:setFightAttr("protect", attrConf.protect)
    npcAttr:setFightAttr("hitForce", attrConf.hitForce)
    npcAttr:setFightAttr("dodgeForce", attrConf.dodgeForce)
    npcAttr:setFightAttr("parryForce", attrConf.parryForce)
    --@endregion
end

--[[
    @desc: 
    author:Seven
    time:2022-03-18 23:54:19
    --@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
	--@attrId: 属性模板ID
    @return:
]]
function NpcCharacterBuilder:__initNpcWeapon(f_character, attrId)
    local attrConf = self:__getAttr(attrId)

    local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

    local main_weapon
    if attrConf.weaponMain ~= nil then
        local equipType, tempId = string.splitUnpack(attrConf.weaponMain, "#")

        if equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.GOD then
            main_weapon = EquipmentFactory:createShenBingWeaponWithTemplateId(tempId)
        elseif equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.NORMAL then
            main_weapon = EquipmentFactory:createWeaponWithItemId(tempId)
        end
    end

    --@region 副手武器
    local sec_weapon
    if attrConf.weaponSecond ~= nil then
        local equipType, tempId = string.splitUnpack(attrConf.weaponSecond, "#")

        if equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.GOD then
            sec_weapon = EquipmentFactory:createShenBingWeaponWithTemplateId(tempId)
        elseif equipType == FightCommons.NPC_BUILD_WEAPON_TYPE.NORMAL then
            sec_weapon = EquipmentFactory:createWeaponWithItemId(tempId)
        end
    end

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem#CharacterEquipmentSystem]
    local equipSys = require("app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem"):create()
    equipSys:setEmptyHandWeapon(EquipmentFactory:createEmptyHandWeapon())
    equipSys:setEquipmentWeapon(main_weapon)
    equipSys:setStandbyWeapon(sec_weapon)
    equipSys:setWeapon(equipSys:getEquipmentWeapon())
    f_character:setEquipSys(equipSys)
end

--@desc: 初始化NPC技能
--@author:Seven
--@time:2021-06-30 21:20:41
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@id: npc属性配置id
function NpcCharacterBuilder:__initNpcSkill(f_character, id)
    local attrConf = self:__getAttr(id)

    local function initBaseSkill(skill_sec_type, level)
        local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(skill_sec_type)

        local baseSkill = SkillFactory:createSkill(baseSkillId)

        baseSkill:setLevel(level)

        return baseSkill
    end

    local function skillStrSplit(str)
        local list = string.split(str, "#")
        return list[1], tonumber(list[2])
    end

    for typeStr, typeValue in pairs(SKILL_SECOND_TYPE) do
        local skill_first_type = SkillClassifyManager:getFirstTypeBySecondType(typeValue)
        local baseSkill
        if skill_first_type == SKILL_FIRST_TYPE.BING_QI then
            baseSkill = initBaseSkill(typeValue, attrConf.baseBingqiLv)
        elseif skill_first_type == SKILL_FIRST_TYPE.QUAN_JIAO then
            baseSkill = initBaseSkill(typeValue, attrConf.baseQuanjiaoLv)
        elseif skill_first_type == SKILL_FIRST_TYPE.NEI_GONG then
            baseSkill = initBaseSkill(typeValue, attrConf.baseNeigongLv)
        elseif skill_first_type == SKILL_FIRST_TYPE.QING_GONG then
            baseSkill = initBaseSkill(typeValue, attrConf.baseQinggongLv)
        elseif skill_first_type == SKILL_FIRST_TYPE.ZHAO_JIA then
            baseSkill = initBaseSkill(typeValue, attrConf.baseZhaojiaLv)
        end

        f_character:addBaseSkill(typeValue, baseSkill)
    end

    if attrConf.skillQuanjiaoLeft then
        local id, lv = skillStrSplit(attrConf.skillQuanjiaoLeft)
        local quanjiaoSkill = SkillFactory:createSkill(id)
        quanjiaoSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO, quanjiaoSkill)
    end

    if attrConf.skillJianfa then
        local id, lv = skillStrSplit(attrConf.skillJianfa)
        local sowrdSkill = SkillFactory:createSkill(id)
        sowrdSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.JIAN_FA, sowrdSkill)
    end

    if attrConf.skillDaofa then
        local id, lv = skillStrSplit(attrConf.skillDaofa)
        local knifeSkill = SkillFactory:createSkill(id)
        knifeSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.DAO_FA, knifeSkill)
    end

    if attrConf.skillGunfa then
        local id, lv = skillStrSplit(attrConf.skillGunfa)
        local stickSkill = SkillFactory:createSkill(id)
        stickSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.GUN_FA, stickSkill)
    end

    if attrConf.skillAnqi then
        local id, lv = skillStrSplit(attrConf.skillAnqi)
        local projectileSkill = SkillFactory:createSkill(id)
        projectileSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.AN_QI, projectileSkill)
    end

    if attrConf.skillBianfa then
        local id, lv = skillStrSplit(attrConf.skillBianfa)
        local scourgeSkill = SkillFactory:createSkill(id)
        scourgeSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.BIAN_FA, scourgeSkill)
    end

    if attrConf.skillShuangchi then
        local id, lv = skillStrSplit(attrConf.skillShuangchi)
        local funzerkerSkill = SkillFactory:createSkill(id)
        funzerkerSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.SHUANG_CHI, funzerkerSkill)
    end

    if attrConf.skillQinfa then
        local id, lv = skillStrSplit(attrConf.skillQinfa)
        local lyraSkill = SkillFactory:createSkill(id)
        lyraSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.QIN_FA, lyraSkill)
    end

    if attrConf.skillQinggong then
        local id, lv = skillStrSplit(attrConf.skillQinggong)
        local dodgeSkill = SkillFactory:createSkill(id)
        dodgeSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.QING_GONG, dodgeSkill)
    end

    if attrConf.skillNeigong then
        local id, lv = skillStrSplit(attrConf.skillNeigong)
        local neigongSkill = SkillFactory:createSkill(id)
        neigongSkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.NEI_GONG, neigongSkill)
    end

    if attrConf.skillZhaojia then
        local id, lv = skillStrSplit(attrConf.skillZhaojia)
        local parrySkill = SkillFactory:createSkill(id)
        parrySkill:setLevel(lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.ZHAO_JIA, parrySkill)
    end
end

--@desc:
--@author:Seven
--@time:2021-07-20 16:08:45
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@id: self.__npc 属性id
function NpcCharacterBuilder:__initNpcActiveAutoReleaseAI(f_character, id)
    local attrConf = self:__getAttr(id)

    --@RefType [src.app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI#ActiveSkillReleaseAI]
    local activeAutoReleaseAI = require("app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI"):create()

    f_character:setActiveSkillReleaseAI(activeAutoReleaseAI)

    if attrConf.activeZhao == nil then
        return
    end

    local npcActiveSkillTemplates = string.split(attrConf.activeZhao, "|")

    local NpcReleaseActiveRule = require("app.FightSystem.FightRole.CharacterAI.NpcReleaseActiveRule")
    for _, template in ipairs(npcActiveSkillTemplates) do
        local template_info = string.split(template, "#")

        local combResId = template_info[1]

        local aiRuleId = template_info[2]

        if combResId == nil or aiRuleId == nil then
            error("NPC 属性id：%d 主动技能释放规则解析错误")
        end

        local activeSkill = ActiveFactory:createNpcFightActiveSkill(f_character, combResId)

        f_character:addActiveSkill(activeSkill)

        --@RefType [src.app.FightSystem.FightRole.CharacterAI.NpcReleaseActiveRule#NpcReleaseActiveRule]
        local rule = NpcReleaseActiveRule:create(activeSkill:getId(), aiRuleId)

        activeAutoReleaseAI:addRule(rule)
    end
end

function NpcCharacterBuilder:__initSpecies(f_character, role)
    local species = Helper:getDef(role.animType, "human")
    if species == "human" then
        if role.sex == "男" then
            species = FightCommons.CHARACTER_SPECIES.MALE
        else
            species = FightCommons.CHARACTER_SPECIES.FEMALE
        end
    end
    f_character:setSpecies(species)
end
--@desc:
--@author:Seven
--@time:2022-11-29 16:49:18
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function NpcCharacterBuilder:__initFistFootSystem(f_character)
    f_character:setFistFootSystem(require("app.FightSystem.FightRole.FistFoot.CharacterFistFootSystem"):create(f_character))
end

function NpcCharacterBuilder:build()
    --@RefType [src.app.FightSystem.FightRole.NpcFightCharacter#NpcFightCharacter]
    local f_character = NpcFightCharacter:create()

    local pos = FightCommons.CHARACTER_POSITION[self.__posIndex]
    f_character:setPosIndex(self.__posIndex)
    f_character:setPosition(pos.x, pos.y, 0)

    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.NpcAttr#NpcAttr]
    local npcAttr = NpcAttr:create(f_character)
    f_character:setCharacterAttr(npcAttr)

    f_character:setAttr("id", self.__npc.id)

    f_character:setAttr("name", self.__npc.name)

    f_character:setAttr("zhengqi", self.__npc.zhengqi)

    f_character:setAttr("age", self.__npc.age)

    f_character:setAttr("looks", self.__npc.looks)

    f_character:setAttr("jingMax", 1000)

    -- f_character:setAttr("strCondSkill", self.__npc:getFinalAttr("currStr"))
    -- f_character:setAttr("dexCondSkill", self.__npc:getFinalAttr("currDex"))
    -- f_character:setAttr("conCondSkill", self.__npc:getFinalAttr("currCon"))
    f_character:setAttr("intCondSkill", self.__npc:getFinalAttr("currInt"))

    self:__initNpcAttr(npcAttr, self.__attrId)
    self:__initNpcWeapon(f_character, self.__attrId)
    self:__initNpcSkill(f_character, self.__attrId)
    self:__initSpecies(f_character, self.__npc)
    self:__initNpcActiveAutoReleaseAI(f_character, self.__attrId)
    self:__initFistFootSystem(f_character)

    f_character:init()

    return f_character
end

return newClass("NpcCharacterBuilder", {}, NpcCharacterBuilder)
000000