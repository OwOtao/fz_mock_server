local FightCharacter = require("app.FightSystem.FightRole.FightCharacter")

local FightCommons = require("app.FightSystem.FightCommons")

local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")

local ActiveFactory = require("app.FightSystem.Factory.FightSkillFactory.ActiveFactory")

local PlayerAttr = require("app.FightSystem.FightRole.CharacterAttr.PlayerAttr")

local NpcAttr = require("app.FightSystem.FightRole.CharacterAttr.NpcAttr")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local FightCharacterFactory = {
    __attrRes = {}
}

function FightCharacterFactory:create()
    local p = self.new()
    p:__init()
    return p
end

function FightCharacterFactory:setAttrRes(attrRes)
    self.__attrRes = attrRes
end

function FightCharacterFactory:__init()
end

function FightCharacterFactory:__getAttr(id)
    local attr = self.__attrRes[tonumber(id)]

    if attr == nil then
        assert(false, "找不到 属性 id ：" .. id)
    end

    return attr
end

--@desc 南柯梦境战斗测试左边玩家控制角色创建
function FightCharacterFactory:createTestFightCharacter3(id, index)
    local role_res_data = NpcAttrConf:getConf(id)

    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    local f_character = FightCharacter:create()

    if index == 1 then
        f_character:setPlayer(true)
    end

    local pos = FightCommons.CHARACTER_POSITION[index]
    f_character:setPosIndex(index)
    f_character:setPosition(pos.x, pos.y, 0)

    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.NpcAttr#NpcAttr]
    local npcAttr = NpcAttr:create(f_character)

    npcAttr:setAttr("id", index)
    npcAttr:setAttr("name", "测试角色" .. index)

    self:__initNpcAttr(npcAttr, id)
    self:__initNpcWeapon(f_character, id)
    self:__initNpcSkill(f_character, id)

    --@RefType [src.app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI#ActiveSkillReleaseAI]
    local activeAutoReleaseAI = require("app.FightSystem.FightRole.CharacterAI.ActiveSkillReleaseAI"):create()
    f_character:setActiveSkillReleaseAI(activeAutoReleaseAI)

    local attrConf = NpcAttrConf:getConf(id)
    if attrConf.activeZhao ~= nil then
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
        end
    end

    f_character:setCharacterAttr(npcAttr)
    
    f_character:init()


    return f_character
end

--@desc: 初始化NPC的初始属性
--@author:Seven
--@time:2021-06-30 21:16:11
--@npcAttr: [src.app.FightSystem.FightRole.CharacterAttr.NpcAttr#NpcAttr]
function FightCharacterFactory:__initNpcAttr(npcAttr, id)
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

function FightCharacterFactory:__initNpcWeapon(f_character, attrId)
    local attrConf = self:__getAttr(attrId)

    --@region 武器创建
    --@desc 空手武器id
    local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")
    local c_weapon
    if attrConf.weaponMain ~= nil then
        c_weapon = EquipmentFactory:createWeaponWithItemId(attrConf.weaponMain)
    else
        c_weapon = EquipmentFactory:createEmptyHandWeapon()
    end

    --@RefType [src.app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem#CharacterEquipmentSystem]
    local equipSys = require("app.FightSystem.FightRole.CharacterEquipment.CharacterEquipmentSystem"):create()
    equipSys:setEquipmentWeapon(c_weapon)
    equipSys:setStandbyWeapon(EquipmentFactory:createEmptyHandWeapon())
    equipSys:setWeapon(equipSys:getEquipmentWeapon())
    f_character:setEquipSys(equipSys)
end

--@desc: 初始化NPC技能
--@author:Seven
--@time:2021-06-30 21:20:41
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@id: npc属性配置id
function FightCharacterFactory:__initNpcSkill(f_character, id)
    local attrConf = self:__getAttr(id)

    local function initBaseSkill(skill_sec_type, level)
        local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(skill_sec_type)

        local baseSkill = SkillFactory:createSkill(baseSkillId, level)

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
        local quanjiaoSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.QUAN_JIAO, quanjiaoSkill)
    end

    if attrConf.skillJianfa then
        local id, lv = skillStrSplit(attrConf.skillJianfa)
        local sowrdSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.JIAN_FA, sowrdSkill)
    end

    if attrConf.skillDaofa then
        local id, lv = skillStrSplit(attrConf.skillDaofa)
        local knifeSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.DAO_FA, knifeSkill)
    end

    if attrConf.skillGunfa then
        local id, lv = skillStrSplit(attrConf.skillGunfa)
        local stickSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.GUN_FA, stickSkill)
    end

    if attrConf.skillAnqi then
        local id, lv = skillStrSplit(attrConf.skillAnqi)
        local projectileSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.AN_QI, projectileSkill)
    end

    if attrConf.skillBianfa then
        local id, lv = skillStrSplit(attrConf.skillBianfa)
        local scourgeSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.BIAN_FA, scourgeSkill)
    end

    if attrConf.skillShuangchi then
        local id, lv = skillStrSplit(attrConf.skillShuangchi)
        local funzerkerSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.SHUANG_CHI, funzerkerSkill)
    end

    if attrConf.skillQinfa then
        local id, lv = skillStrSplit(attrConf.skillQinfa)
        local lyraSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.QIN_FA, lyraSkill)
    end

    if attrConf.skillQinggong then
        local id, lv = skillStrSplit(attrConf.skillQinggong)
        local dodgeSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.QING_GONG, dodgeSkill)
    end

    if attrConf.skillNeigong then
        local id, lv = skillStrSplit(attrConf.skillNeigong)
        local neigongSkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.NEI_GONG, neigongSkill)
    end

    if attrConf.skillZhaojia then
        local id, lv = skillStrSplit(attrConf.skillZhaojia)
        local parrySkill = SkillFactory:createSkill(id, lv)
        f_character:addPrepSkill(SKILL_SECOND_TYPE.ZHAO_JIA, parrySkill)
    end
end

--@desc:
--@author:Seven
--@time:2021-07-20 16:08:45
--@f_character: [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
--@id: npc 属性id
function FightCharacterFactory:__initNpcActiveAutoReleaseAI(f_character, id)
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

        f_character:addPrepActiveSkill(activeSkill:getId())

        --@RefType [src.app.FightSystem.FightRole.CharacterAI.NpcReleaseActiveRule#NpcReleaseActiveRule]
        local rule = NpcReleaseActiveRule:create(activeSkill:getId(), "moban1")

        activeAutoReleaseAI:addRule(rule)
    end
end

function FightCharacterFactory:__initSpecies(f_character, role)
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

function FightCharacterFactory:createTestFightCharacter2(id, index)
    local role_res_data = self:__getAttr(id)

    --@RefType [src.app.FightSystem.FightRole.FightCharacter#FightCharacter]
    local f_character = FightCharacter:create()

    if index == 1 then
        f_character:setPlayer(true)
    end

    local pos = FightCommons.CHARACTER_POSITION[index]
    f_character:setPosIndex(index)
    f_character:setPosition(pos.x, pos.y, 0)

    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.NpcAttr#NpcAttr]
    local npcAttr = NpcAttr:create(f_character)

    npcAttr:setAttr("id", index)
    npcAttr:setAttr("name", "测试角色" .. index)

    self:__initNpcAttr(npcAttr, id)
    self:__initNpcWeapon(f_character, id)
    self:__initNpcSkill(f_character, id)
    self:__initNpcActiveAutoReleaseAI(f_character, id)

    f_character:setCharacterAttr(npcAttr)

    f_character:init()

    return f_character
end

return class("FightCharacterFactory", {}, FightCharacterFactory)
0000000