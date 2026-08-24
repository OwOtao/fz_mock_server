local IFightNPCBuilderConfig = require("app.FightSystem.FightCharacterBuilder.NPCBuilder.IFightNPCBuilderConfig")

local NPC_ATTR_RES = requireWithEncrypt("script.challengeMap.fightNpcAttrs")

local newClass = require("third.class.NewClass")

local ChallengeMapResource = require("app.models.ChallengeMap.ChallengeMapResource")

--@SuperType [src.app.FightSystem.FightCharacterBuilder.NPCBuilder.IFightNPCBuilderConfig#IFightNPCBuilderConfig]
local ChallengeMapFightNpcBuilderConfig = {}

function ChallengeMapFightNpcBuilderConfig:create(...)
    return ChallengeMapFightNpcBuilderConfig.new():__init(...)
end

function ChallengeMapFightNpcBuilderConfig:__init(name, attrLevel, attrId, baseAttrId, pos)
    local levelRes = assert(NPC_ATTR_RES[tostring(attrLevel)], "挑战副本NPC难度类型 = " .. tostring(attrLevel) .. "不存在")

    self.__attrRes = assert(levelRes[tonumber(attrId)], "挑战副本NPC属性类型 = " .. tostring(attrId) .. "不存在")

    self.__baseRes = ChallengeMapResource:getInstance():getNpcBaseAttrMapById(baseAttrId)

    self.__roleAttrDict = {
        id = self.__baseRes.id .. "_" .. tostring(pos),
        name = name,
        zhengqi = self.__baseRes.zhengqi,
        age = self.__baseRes.age,
        looks = self.__baseRes.looks,
        jingMax = self.__baseRes.jingMax,
        species = self.__baseRes.species
    }

    return self
end

function ChallengeMapFightNpcBuilderConfig:getBuilderConfigAttr(name)
    if self.__roleAttrDict[name] then
        return self.__roleAttrDict[name]
    end
    return self.__attrRes[name]
end

return newClass("ChallengeMapFightNpcBuilderConfig", {IFightNPCBuilderConfig}, ChallengeMapFightNpcBuilderConfig)
000000