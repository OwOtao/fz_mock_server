--[[
    author:Seven
    time:2022-09-13 16:08:32
    desc: 测试战斗角色创建
]]
local FightCharacter = require("app.FightSystem.FightRole.NewFightCharacter")

local FightCommons = require("app.FightSystem.FightCommons")

local EquipmentFactory = require("app.FightSystem.Factory.EquipmentFactory.EquipmentFactory")

local FightSkillFactory = require("app.FightSystem.FightSkill.Factory.FightSkillFactory")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local SkillConst = require("app.models.skill.SkillConst")

--@RefType src.app.models.skill.SkillConst#SkillConst.SkillSecondType
local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local TestCharacterFactory = {}

local testPlayerData = {
    team_id = "team1",
    family_id = "wudang",
    species = FightCommons.CHARACTER_SPECIES.MALE,
    attrs = {
        id = "test_1",
        lv = 1000,
        name = "测试-玩家",
        jingMax = 0,
        qi = 10000,
        qiMax = 10000,
        qiLimit = 10000,
        neili = 10000,
        neiliMax = 10000,
        neiliLimit = 10000,
        age = 20,
        zhengqi = 1000,
        sex = "男",
        looks = 100,
        tili = 0,
        -- 先天臂力
        str = 30,
        -- 先天身法
        dex = 20,
        -- 先天根骨
        con = 30,
        -- 先天悟性
        int = 20,
        --@desc 加力值
        plusPoint = 100,
        strCondGWeapon = 10,
        dexCondGWeapon = 10,
        conCondGWeapon = 10,
        intCondGWeapon = 10,
        strCondSkill = 10,
        dexCondSkill = 10,
        conCondSkill = 10,
        intCondSkill = 10
    },
    base_skill_map = {
        [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = 1000,
        [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.DAO_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.GUN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = 1000,
        [tostring(SKILL_SECOND_TYPE.AN_QI)] = 1000,
        [tostring(SKILL_SECOND_TYPE.QIN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.ZHAO_JIA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.QING_GONG)] = 1000,
        [tostring(SKILL_SECOND_TYPE.NEI_GONG)] = 1000
    }
}

local testNPCData = {
    team_id = "team2",
    family_id = "wudang",
    species = FightCommons.CHARACTER_SPECIES.FEMALE,
    attrs = {
        id = "test_2",
        lv = 1000,
        name = "测试-NPC",
        jingMax = 0,
        qi = 10000,
        qiMax = 10000,
        qiLimit = 10000,
        neili = 10000,
        neiliMax = 10000,
        neiliLimit = 10000,
        age = 20,
        zhengqi = 1000,
        sex = "女",
        looks = 100,
        tili = 0,
        -- 先天臂力
        str = 30,
        -- 先天身法
        dex = 20,
        -- 先天根骨
        con = 30,
        -- 先天悟性
        int = 20,
        --@desc 加力值
        plusPoint = 100,
        strCondGWeapon = 10,
        dexCondGWeapon = 10,
        conCondGWeapon = 10,
        intCondGWeapon = 10,
        strCondSkill = 10,
        dexCondSkill = 10,
        conCondSkill = 10,
        intCondSkill = 10
    },
    base_skill_map = {
        [tostring(SKILL_SECOND_TYPE.QUAN_JIAO)] = 1000,
        [tostring(SKILL_SECOND_TYPE.JIAN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.DAO_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.GUN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.BIAN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.SHUANG_CHI)] = 1000,
        [tostring(SKILL_SECOND_TYPE.AN_QI)] = 1000,
        [tostring(SKILL_SECOND_TYPE.QIN_FA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.ZHAO_JIA)] = 1000,
        [tostring(SKILL_SECOND_TYPE.QING_GONG)] = 1000,
        [tostring(SKILL_SECOND_TYPE.NEI_GONG)] = 1000
    }
}

function TestCharacterFactory:getPlayerCharacter()
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character = FightCharacter:create()
    character:setTeamId(testPlayerData.team_id)

    character:setFamilyID(testPlayerData.family_id)
    
    for k, v in pairs(testPlayerData.attrs) do
        character:setAttr(k, v)
    end

    for sec_type, lv in pairs(testPlayerData.base_skill_map) do
        local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(tonumber(sec_type))
        local baseSkill = FightSkillFactory.createBasicFightSkill(baseSkillId,lv)
        baseSkill:setCharacter(character)
        character:addBaseSkill(sec_type, baseSkill)
    end

    character:setEmptyHandWeapon(EquipmentFactory:createEmptyHandWeapon())

    character:setEquipWeapon(EquipmentFactory:createWeaponWithItemId("jian110"))

    character:init()
    
    return character
end

function TestCharacterFactory:getNPCCharacter()
    --@RefType [src.app.FightSystem.FightRole.NewFightCharacter#FightCharacter]
    local character = FightCharacter:create(require("app.FightSystem.FightRole.CharacterConfigs.NPCCharacterConfig"))
    character:setTeamId(testNPCData.team_id)

    character:setFamilyID(testNPCData.family_id)

    for k, v in pairs(testNPCData.attrs) do
        character:setAttr(k, v)
    end

    for sec_type, lv in pairs(testNPCData.base_skill_map) do
        local baseSkillId = SkillClassifyManager:getBaseSkillIdBySecondType(tonumber(sec_type))
        local baseSkill = FightSkillFactory.createBasicFightSkill(baseSkillId,lv)
        baseSkill:setCharacter(character)
        character:addBaseSkill(sec_type, baseSkill)
    end

    character:setEmptyHandWeapon(EquipmentFactory:createEmptyHandWeapon())

    character:init()

    return character
end

return TestCharacterFactory
0000000