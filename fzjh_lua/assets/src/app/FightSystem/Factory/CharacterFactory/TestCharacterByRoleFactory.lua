local newClass = require("third.class.NewClass")

local FightCommons = require("app.FightSystem.FightCommons")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")

local ICharacterFcatory = require("app.FightSystem.Factory.CharacterFactory.ICharacterFcatory")

--@SuperType [src.app.FightSystem.Factory.CharacterFactory.ICharacterFcatory#ICharacterFcatory]
local TestCharacterByRoleFactory = {}

function TestCharacterByRoleFactory:create(role)
    local p = TestCharacterByRoleFactory.new()
    p:init(role)
    return p
end

function TestCharacterByRoleFactory:init(role)
    self.__role = role
end

function TestCharacterByRoleFactory:setShenBingBuffArray(buffArray)
    self.__buffArray = buffArray
end

function TestCharacterByRoleFactory:setNormalBuffSystem(system)
    self.__normalBuffSystem = system
end

function TestCharacterByRoleFactory:__initAttr(character)
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

function TestCharacterByRoleFactory:__initChallengeMapRoleAttr(character)
    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.ChallengeMapPlayerAttr#ChallengeMapPlayerAttr]
    local playerAttr = require("app.FightSystem.FightRole.CharacterAttr.ChallengeMapPlayerAttr"):create(character)

    playerAttr:setNormalBuffSystem(self.__normalBuffSystem)

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

function TestCharacterByRoleFactory:__initSpecies()
    local species
    if self.__role:getAttr("sex") == "男" then
        species = FightCommons.CHARACTER_SPECIES.MALE
    else
        species = FightCommons.CHARACTER_SPECIES.FEMALE
    end

    return species
end

function TestCharacterByRoleFactory:__initPrepSkillDict()
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
                MainLogSystem:log("SkillFactory:createSkill:", skillId, self.__role:getSkillLv(skillId))
                skill = SkillFactory:createSkill(skillId, self.__role:getSkillLv(skillId))
            end
            prep_dict[second_type] = skill
        end
    end

    MainLogSystem:log("prep_dict:", prep_dict)

    return prep_dict
end

function TestCharacterByRoleFactory:__initBaseSkillDict()
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

function TestCharacterByRoleFactory:__initWeapon()
    local weapon

    local role_weapon = self.__role:getEquipByName("weapon")
    if role_weapon then
        local itemId = role_weapon.itemId
        if self.__role:isShengBing(itemId) then
            local item = self.__role:getOneItemByKey(role_weapon.itemId)
            weapon = EquipmentFactory:createShenBingWeaponWithItem(item)
            weapon:setBuffArray(self.__buffArray)
        else
            local item = self.__role:getOneItemByKey(role_weapon.itemId)
            weapon = EquipmentFactory:createWeaponWithItem(item)
        end
    end

    return weapon
end

function TestCharacterByRoleFactory:__initStandByWeapon()
    local weapon

    local role_weapon = self.__role:getPrepareWeapon()
    if role_weapon then
        local itemId = role_weapon.itemId
        if self.__role:isShengBing(itemId) then
            local item = self.__role:getOneItemByKey(role_weapon.itemId)
            weapon = EquipmentFactory:createShenBingWeaponWithItem(item)
            weapon:setBuffArray(self.__buffArray)
        else
            local item = self.__role:getOneItemByKey(role_weapon.itemId)
            weapon = EquipmentFactory:createWeaponWithItem(item)
        end
    end

    return weapon
end

--@desc: 添加适合使用的主动技能
--@author:Seven
--@time:2021-07-27 09:59:10
--@character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
function TestCharacterByRoleFactory:__addAllMatchedActiveSkill(character)
    local list = {}

    local prepSkills = character:getPrepSkills()
    MainLogSystem:log("prepSkills:", prepSkills)

    if MapIsEmpty(prepSkills) then
        return list
    end
    for skill_sec_type, fight_skill in pairs(prepSkills) do
        local actId_list = fight_skill:getActiveZhaos()

        for _, actId in ipairs(actId_list) do
            local zhaoLv = Helper:mathFloor(self.__role:getSkillZhaoLv(actId))

            MainLogSystem:log("actId, zhaoLv:", actId, zhaoLv)

            -- if zhaoLv > 0 then
            local activeSkill = ActiveFactory:createPlayerFightActiveSkill(character, actId, zhaoLv)
            character:addActiveSkill(activeSkill)
            -- end
        end
    end
end

function TestCharacterByRoleFactory:__getFamilyId()
    return self.__role:getFamilyId()
end

--[[
    @desc: 设置战斗buff列表
    author:TangJian
    time:2022-01-17 17:39:45
    --@fightBuffArray: 
    @return:
]]
function TestCharacterByRoleFactory:setFightBuffArray(fightBuffArray)
    self.__fightBuffArray = fightBuffArray
end

function TestCharacterByRoleFactory:getCharacter()
    print("TestCharacterByRoleFactory:getCharacter()")

    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    local character = require("app.FightSystem.FightRole.FightCharacter"):create()

    character.initActivePrepActiveSkill = function(self)
        if table.getn(self.__prep_act) > 0 then
            self.__prep_act = {}
        end

        local attackSkill = self:getAttackSkill()

        local attackSkill_actId_list = attackSkill:getActiveZhaos()

        local dodgeSkill = self:getDodgeSkill()
        local dodgeSkill_actId_list = dodgeSkill:getActiveZhaos()

        local parrySkill = self:getParrySkill()
        local parrySkill_actId_list = parrySkill:getActiveZhaos()

        local neiGongSkill = self:getNeiGongSkill()
        local neiGongSkill_actId_list = neiGongSkill:getActiveZhaos()

        local actId_list = table.mergeArray(table.mergeArray(table.mergeArray(attackSkill_actId_list, dodgeSkill_actId_list), parrySkill_actId_list), neiGongSkill_actId_list)

        for _, actId in ipairs(actId_list) do
            --@RefType [src.app.FightSystem.FightSkill.NormalFightActiveSkill#NormalFightActiveSkill]
            local activeSkill = self.__active_skill[actId]
            if activeSkill then
                self:addPrepActiveSkill(actId)
            end
        end
    end

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

    character:setEquipSys(equipSys)

    --@RefType [src.app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI#ActiveSkillReleaseAI]
    local activeAutoReleaseAI = require("app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI"):create()
    character:setActiveSkillReleaseAI(activeAutoReleaseAI)

    self:__addAllMatchedActiveSkill(character)

    character:init()

    return character
end

function TestCharacterByRoleFactory:setAttrId(attrId)
    self.__attrId = attrId
end

function TestCharacterByRoleFactory:__getAttr(id)
    local npcAttrRes = assert(requireWithEncrypt("script.challengeMap.fightNpcAttrs")["npcAttrLv01"])
    local attr = npcAttrRes[tonumber(id)]

    if attr == nil then
        assert(false, "找不到 属性 id ：" .. id)
    end

    return attr
end

function TestCharacterByRoleFactory:__initNpcActiveAutoReleaseAI(f_character, id)
    local attrConf = self:__getAttr(id)

    --@RefType [src.app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI#ActiveSkillReleaseAI]
    local activeAutoReleaseAI = require("app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI"):create()

    f_character:setActiveSkillReleaseAI(activeAutoReleaseAI)
    MainLogSystem:log("attrConf", attrConf)
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

        f_character:addPrepActiveSkill(activeSkill:getId())

        --@RefType [src.app.FightSystem.FightRole.CharacterAI.NpcReleaseActiveRule#NpcReleaseActiveRule]
        local rule = NpcReleaseActiveRule:create(activeSkill:getId(), "moban1")

        activeAutoReleaseAI:addRule(rule)
    end
end

function TestCharacterByRoleFactory:getChallengeMapRoleCharacter()
    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    local character = require("app.FightSystem.FightRole.FightCharacter"):create()

    character:setCharacterAttr(self:__initChallengeMapRoleAttr(character))

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

    character:setEquipSys(equipSys)

    --@RefType [src.app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI#ActiveSkillReleaseAI]
    local activeAutoReleaseAI = require("app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI"):create()
    character:setActiveSkillReleaseAI(activeAutoReleaseAI)

    self:__addAllMatchedActiveSkill(character)

    character:init()

    return character
end

function TestCharacterByRoleFactory:__initEmptyHandWeapon()
    local emptyHandWeapon = EquipmentFactory:createEmptyHandWeapon()

    return emptyHandWeapon
end

return newClass("TestCharacterByRoleFactory", {ICharacterFcatory}, TestCharacterByRoleFactory)
0000