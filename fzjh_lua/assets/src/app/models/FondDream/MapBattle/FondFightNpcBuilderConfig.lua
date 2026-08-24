--[[
    author:Seven
    time:2024-01-22 15:33:32
    desc:
]]
local IFightNPCBuilderConfig = require("app.FightSystem.FightCharacterBuilder.NPCBuilder.IFightNPCBuilderConfig")

local npcAttrRes = require("script.newbattle.demo.npcAttrConf")["战斗属性"]

local newClass = require("third.class.NewClass")

--@SuperType [src.app.FightSystem.FightCharacterBuilder.NPCBuilder.IFightNPCBuilderConfig#IFightNPCBuilderConfig]
local FondFightNpcBuilderConfig = {}

function FondFightNpcBuilderConfig:create(...)
    return FondFightNpcBuilderConfig.new():__init(...)
end

function FondFightNpcBuilderConfig:__init(npcRole, attrId)
    self.__npcRole = npcRole

    self.__attrRes = npcAttrRes[tostring(attrId)]

    self.__roleAttrDict = {
        id = self.__npcRole.id,
        name = self.__npcRole.name,
        zhengqi = self.__npcRole.zhengqi,
        age = self.__npcRole.age,
        looks = self.__npcRole.looks,
        jingMax = 1000,
        intCondSkill = self.__npcRole:getFinalAttr("currInt"),
        sex = self.__npcRole.sex
    }

    return self
end

function FondFightNpcBuilderConfig:getBuilderConfigAttr(name)
    if self.__roleAttrDict[name] then
        return self.__roleAttrDict[name]
    end
    return self.__attrRes[name]
end

return newClass("FondFightNpcBuilderConfig", {IFightNPCBuilderConfig}, FondFightNpcBuilderConfig)
000000000000