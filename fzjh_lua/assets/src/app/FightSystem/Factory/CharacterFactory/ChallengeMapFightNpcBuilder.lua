local newClass = require("third.class.NewClass")

local NpcFightCharacter = require("app.FightSystem.FightRole.NpcFightCharacter")

local FightCommons = require("app.FightSystem.FightCommons")

local SkillFactory = require("app.FightSystem.Factory.FightSkillFactory.SkillFactory")

local NpcAttr = require("app.FightSystem.FightRole.CharacterAttr.NpcAttr")

local SkillClassifyManager = require("app.FightSystem.FightSkill.SkillClassifyManager")

local NpcCharacterBuilder = require("app.FightSystem.Factory.CharacterFactory.NpcCharacterBuilder")

local SkillConst = require("app.models.skill.SkillConst")

local SKILL_FIRST_TYPE = SkillConst.SkillFirstType

local SKILL_SECOND_TYPE = SkillConst.SkillSecondType

local ChallengeMapFightNpcBuilder = {
    __attrRes = {}
}

function ChallengeMapFightNpcBuilder:create()
    return ChallengeMapFightNpcBuilder.new()
end

function ChallengeMapFightNpcBuilder:setAttrRes(attrRes)
    self.__attrRes = attrRes
    return self
end

function ChallengeMapFightNpcBuilder:setPosIndex(posIndex)
    self.__posIndex = posIndex
    return self
end

function ChallengeMapFightNpcBuilder:setAttrId(attrId)
    self.__attrId = attrId
    return self
end

function ChallengeMapFightNpcBuilder:setBaseAttrId(baseAttrId)
    self.__baseAttrId = baseAttrId

    return self
end

function ChallengeMapFightNpcBuilder:setName(name)
    self.__name = name
    return self
end

function ChallengeMapFightNpcBuilder:__getAttr(id)
    local attr = self.__attrRes[tonumber(id)]

    if attr == nil then
        assert(false, "找不到 属性 id ：" .. id)
    end

    return attr
end

function ChallengeMapFightNpcBuilder:build()
    --@RefType [src.app.FightSystem.FightRole.NpcFightCharacter#NpcFightCharacter]
    local f_character = NpcFightCharacter:create()

    local pos = FightCommons.CHARACTER_POSITION[self.__posIndex]
    f_character:setPosIndex(self.__posIndex)
    f_character:setPosition(pos.x, pos.y, 0)

    --@RefType [src.app.FightSystem.FightRole.CharacterAttr.NpcAttr#NpcAttr]
    local npcAttr = NpcAttr:create(f_character)
    f_character:setCharacterAttr(npcAttr)

    local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")
    local baseAttrData = ChallengeMapResource:getInstance():getNpcBaseAttrMapById(self.__baseAttrId)

    f_character:setAttr("name", self.__name)

    f_character:setAttr("id", tostring(baseAttrData.id) .. "|" .. tostring(self.__posIndex))

    f_character:setAttr("zhengqi", baseAttrData.zhengqi)

    f_character:setAttr("age", baseAttrData.age)

    f_character:setAttr("looks", baseAttrData.looks)

    f_character:setAttr("jingMax", baseAttrData.jingMax)

    f_character:setSpecies(baseAttrData.species)

    self:__initNpcAttr(npcAttr, self.__attrId)
    self:__initNpcWeapon(f_character, self.__attrId)
    self:__initNpcSkill(f_character, self.__attrId)
    self:__initNpcActiveAutoReleaseAI(f_character, self.__attrId)
    self:__initFistFootSystem(f_character)

    f_character:init()

    return f_character
end

return newClass("ChallengeMapFightNpcBuilder", {NpcCharacterBuilder}, ChallengeMapFightNpcBuilder)
0000000000000